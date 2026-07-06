# stencil_sme.cpp 流程说明

本文档说明 `stencil_sme.cpp` 的代码结构、执行流程，以及它在 LLVM Pass
预取实验中的作用。

## 1. 程序目标

`stencil_sme.cpp` 是一个 2D 5-point stencil 测试用例。它使用：

- `arm_sme.h`：启用 SME streaming mode kernel；
- `arm_sve.h`：使用 SVE scalable vector load/store 和向量计算；
- `std::chrono`：记录 kernel 运行时间；
- 普通 C++ 标量代码：生成输入数据、计算参考结果、做正确性检查。

当前 stencil 计算公式是：

```text
out[y][x] =
    0.50  * input[y][x]
  + 0.125 * (input[y][x - 1]
           + input[y][x + 1]
           + input[y - 1][x]
           + input[y + 1][x])
```

也就是中心点加上下左右四个邻居，共 5 个点。

## 2. 整体执行流程

程序运行时的主流程如下：

```text
main
  -> 解析命令行参数
  -> 检查 nx/ny/iterations/warmup 是否合法
  -> 检查 CPU 是否支持 SME
  -> run_stencil2d5p
       -> 分配 input/expected/actual
       -> 初始化 input
       -> 用标量 C++ 计算 expected
       -> warmup 多次调用 SME kernel
       -> 正式计时调用 SME kernel
       -> 输出 METRIC 计时结果
       -> check_result 校验 actual 与 expected
```

## 3. 命令行参数

`main` 支持 4 个可选参数：

```text
./stencil_sme nx ny iterations warmup
```

含义如下：

```text
nx          网格宽度，默认 256
ny          网格高度，默认 256
iterations 计时阶段重复执行 kernel 的次数，默认 50
warmup      计时前预热执行 kernel 的次数，默认 5
```

示例：

```bash
./stencil_sme 1024 1024 100 10
```

程序会检查：

- `nx >= 3`
- `ny >= 3`
- `iterations >= 1`
- `warmup >= 0`
- 当前 CPU 支持 SME

如果 CPU 不支持 SME，会输出：

```text
SME is not available on this CPU
```

## 4. 数据准备

`run_stencil2d5p` 中创建了 3 个数组：

```cpp
std::vector<float> input;
std::vector<float> expected;
std::vector<float> actual;
```

它们的作用是：

- `input`：输入网格；
- `expected`：标量 C++ 计算出的参考结果；
- `actual`：SME kernel 计算出的结果。

输入数据用固定公式生成：

```cpp
0.01f * static_cast<float>((x * 13 + y * 7) % 97)
```

这样做的好处是：

- 数据确定，每次运行结果一致；
- 不需要随机数；
- 网格中不同位置的值不同，便于发现计算错误。

初始化后：

```cpp
expected = input;
actual = input;
```

边界点不参与 stencil 更新，因此边界保持原值。

## 5. 标量参考计算

`expected` 由普通 C++ 双重循环计算：

```text
for y = 1 .. ny - 2
  for x = 1 .. nx - 2
    expected[y][x] = 2D5P stencil(input)
```

这部分不使用 SME/SVE，只作为正确性参考。

后面 SME kernel 执行结束后，会用 `check_result` 比较：

```text
actual vs expected
```

允许误差为：

```text
1.0e-6
```

## 6. SME/SVE kernel

核心计算函数是：

```cpp
extern "C" __attribute__((target("sme")))
void stencil2d5p_sme_kernel(const float* input, float* actual, int nx, int ny)
    __arm_streaming
```

几个关键点：

- `extern "C"`：避免 C++ name mangling，方便 inline asm 用固定符号名调用；
- `target("sme")`：告诉编译器该函数使用 SME；
- `__arm_streaming`：该函数运行在 SME streaming mode 中；
- `svcntsw()`：获取当前 SVE/SME 向量中能容纳多少个 `float32` 元素。

kernel 的循环结构是：

```text
for each inner row y
  x = 1
  while x < nx - 1
    用 svwhilelt_b32 生成 predicate
    一次处理 VL 个 float
    x += VL
```

其中 `VL` 是运行时向量长度。因为 SVE/SME 是 scalable vector，
代码不写死向量宽度，而是用 `svcntsw()` 动态获取。

## 7. 五路读取

每个向量位置会读取 5 路数据：

```cpp
center = svld1(pg, p);
west   = svld1(pg, p - 1);
east   = svld1(pg, p + 1);
north  = svld1(pg, p - nx);
south  = svld1(pg, p + nx);
```

对应 stencil 语义：

```text
center: input[y][x]
west:   input[y][x - 1]
east:   input[y][x + 1]
north:  input[y - 1][x]
south:  input[y + 1][x]
```

`pg` 是 predicate，用来处理一行末尾不足一个完整向量的部分。

## 8. 向量计算与写回

kernel 先把四个邻居相加：

```cpp
sum = west + east + north + south
```

再计算：

```cpp
out = center * 0.50 + sum * 0.125
```

最后写回：

```cpp
svst1(pg, actual + row + x, out);
```

由于使用了 predicate，最后一个向量块不会越界写入。

## 9. 为什么需要 call_stencil2d5p_sme_kernel

SME kernel 不是直接从普通 C++ 调用，而是通过：

```cpp
call_stencil2d5p_sme_kernel
```

这个函数使用 inline assembly：

```asm
smstart sm
bl _stencil2d5p_sme_kernel
smstop sm
```

作用是：

1. 手动进入 SME streaming mode；
2. 调用真正的 SME kernel；
3. 调用结束后退出 SME streaming mode。

这样可以避免 `main` 或普通 C++ 调用路径被编译器生成不合适的 SME prologue/epilogue，
也避免在不支持 SME 的路径上过早执行 SME 指令。

参数通过 AArch64 ABI 寄存器传入：

```text
x0: input
x1: actual
w2: nx
w3: ny
```

## 10. 计时流程

计时分为两个阶段：

```text
warmup 阶段：执行 kernel，但不计入时间
timed 阶段：执行 iterations 次 kernel，并记录总时间
```

计时使用：

```cpp
std::chrono::steady_clock
```

输出指标包括：

```text
kernel_total_ms  iterations 次 kernel 的总耗时
kernel_avg_ms    单次 kernel 平均耗时
mcells_per_s     每秒处理多少百万个内部网格点
```

程序输出格式是固定的，方便脚本解析：

```text
METRIC nx=256 ny=256 warmup=5 iterations=50
METRIC kernel_total_ms=... kernel_avg_ms=... mcells_per_s=...
```

`llvm-pass-flow/scripts/run_pass.sh` 会读取这些输出，并追加写入：

```text
llvm-pass-flow/out/metrics.csv
```

## 11. 正确性检查

`check_result` 会遍历整个数组，找到最大误差：

```text
max_diff = max(abs(actual[i] - expected[i]))
```

如果最大误差小于等于 `1.0e-6`，输出：

```text
PASSED: max_diff=...
```

否则输出：

```text
FAILED: max_diff=... idx=... got=... expected=...
```

## 12. 和 LLVM Pass 的关系

这个文件既是可执行测试程序，也是 LLVM Pass 的输入样例。

`run_pass.sh` 会对它执行：

```text
stencil_sme.cpp
  -> clang++ -S -emit-llvm
  -> stencil_sme.before.ll
  -> opt -passes=stencil-prefetch
  -> stencil_sme.after.ll
  -> clang++ 编译成可执行文件
```

当前 LLVM Pass 会在 `stencil2d5p_sme_kernel` 中识别：

```text
llvm.masked.load.*
```

也就是 SME/SVE 五路读取对应的 IR intrinsic，然后在读取前插入：

```llvm
call void @llvm.prefetch.p0(...)
```

因此 `stencil_sme.cpp` 里的 kernel 结构会直接影响 Pass 能否识别计算语义和内存访问模式。

## 13. 后续实验关注点

后续如果要比较不同预取策略，主要关注：

- `stencil2d5p_sme_kernel` 中五路 load 的地址模式；
- LLVM IR 中 `llvm.masked.load.*` 的地址参数；
- `run_pass.sh` 记录的 `baseline` 与不同 `RUN_LABEL` 的 `prefetch` 结果；
- `metrics.csv` 中的 `avg_ms` 和 `mcells_per_s`；
- 可选的 `profile_counters.sh` 生成的硬件计数器 trace。

当前 C++ 测试程序已经提供了：

```text
正确性校验 + kernel 计时 + 脚本可解析输出
```

这使得后续修改 LLVM Pass 的预取决策后，可以直接对比不同策略的效果。
