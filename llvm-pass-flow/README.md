# Stencil 预取 LLVM Pass 实验流程

这个目录用于实验“在 LLVM IR 层自动插入预取指令”，当前目标是给
`stencil_sme.cpp` 里的 SME stencil kernel 插入 `llvm.prefetch`，再重新编译运行。

## 目录内容

- `src/StencilPrefetchPass.cpp`：LLVM 新 Pass Manager 插件源码。
- `PASS_DESIGN.md`：说明 LLVM Pass 的代码结构、工作流程和工作原理。
- `CMakeLists.txt`：CMake 构建入口，适合完整 LLVM + CMake 环境。
- `scripts/check_toolchain.sh`：检查是否存在完整 LLVM 工具链。
- `scripts/build_pass.sh`：使用 CMake 构建 pass 插件。
- `scripts/build_pass_direct.sh`：不使用 CMake，直接通过 `llvm-config` 构建插件。
- `scripts/build_pass_macos_dynamic.sh`：macOS 推荐构建方式，使用动态符号查找构建插件。
- `scripts/run_pass.sh`：执行完整流程：生成 LLVM IR、运行 pass、重新编译、运行验证。
- `scripts/profile_counters.sh`：可选使用 `xctrace` 采集硬件计数器 trace。
- `out/`：保存生成的 IR 和可执行文件。
- `build/`：保存构建出的 pass 插件。

## 当前 Pass 行为

当前 pass 会查找函数名包含 `stencil2d5p_sme_kernel` 的函数，并在其中的
`llvm.masked.load.*` 或普通浮点/vector load 前插入：

```llvm
call void @llvm.prefetch.p0(ptr ..., i32 0, i32 3, i32 1)
```

当前已经验证会插入 5 条预取调用，对应 2D5P stencil 的 5 路读取。

这只是基线版本，后续可以继续扩展不同策略：

- 只预取 center 行；
- 预取 north/current/south 三行；
- 按 `1/2/4/8` 个 streaming vector length 调整预取距离；
- 对比 read prefetch 和 write/store prefetch；
- 调整 locality 参数 `0/1/2/3`；
- 针对 2D5P、2D9P、3D7P 等不同 stencil 形态做专门策略。

## 工具链

Xcode 自带 LLVM 不包含 `opt` 和 `llvm-config`，不能直接构建/运行 LLVM pass。

当前使用的是工作区内的 LLVM 22.1.8：

```bash
/Users/alpaca/Documents/SME/toolchains/LLVM-22.1.8-macOS-ARM64
```

如果后续换工具链，只需要修改下面这些环境变量。

## 构建并运行

从仓库根目录执行：

```bash
cd /Users/alpaca/Documents/SME

llvm-pass-flow/scripts/build_pass_macos_dynamic.sh
llvm-pass-flow/scripts/run_pass.sh
```

`run_pass.sh` 支持传入网格大小、计时迭代次数和 warmup 次数：

```bash
llvm-pass-flow/scripts/run_pass.sh 1024 1024 100 10
```

参数含义依次是：

```text
nx ny iterations warmup
```

如果 LLVM 工具链位于默认路径
`/Users/alpaca/Documents/SME/toolchains/LLVM-22.1.8-macOS-ARM64`，脚本会自动发现，
不需要手动设置环境变量。

如果换了 LLVM 安装位置，可以手动指定：

```bash
export LLVM_HOME=/path/to/LLVM
export LLVM_CONFIG=$LLVM_HOME/bin/llvm-config
export OPT=$LLVM_HOME/bin/opt
export CLANGXX=$LLVM_HOME/bin/clang++
```

期望输出类似：

```text
StencilPrefetchPass: inserted 5 llvm.prefetch calls
== baseline ==
METRIC nx=256 ny=256 warmup=5 iterations=50
METRIC kernel_total_ms=... kernel_avg_ms=... mcells_per_s=...
PASSED: max_diff=0
== prefetch ==
METRIC nx=256 ny=256 warmup=5 iterations=50
METRIC kernel_total_ms=... kernel_avg_ms=... mcells_per_s=...
PASSED: max_diff=0
```

脚本会同时运行两个版本：

- `baseline`：未插入 prefetch 的原始 IR 编译结果；
- `prefetch`：经过当前 LLVM Pass 插入 prefetch 后的结果。

每次运行会把结果追加写入：

```text
llvm-pass-flow/out/metrics.csv
```

CSV 字段为：

```text
timestamp,label,nx,ny,warmup,iterations,total_ms,avg_ms,mcells_per_s,status
```

后续实验不同预取策略时，可以用 `RUN_LABEL` 标记当前策略：

```bash
RUN_LABEL=prefetch_distance_2vl llvm-pass-flow/scripts/run_pass.sh 1024 1024 100 10
```

## 硬件计数器和 miss 事件

macOS 上没有 Linux `perf`。Apple 芯片的硬件计数器通常需要通过 Xcode
Instruments / `xctrace` 采集，并且可能需要开发者工具权限。

如果本机 `xctrace` 可用，可以在 `run_pass.sh` 生成可执行文件后尝试：

```bash
llvm-pass-flow/scripts/profile_counters.sh \
  llvm-pass-flow/out/stencil_sme.prefetch \
  1024 1024 100 10
```

默认使用 `Counters` 模板，并生成：

```text
llvm-pass-flow/out/stencil_sme_counters.trace
llvm-pass-flow/out/stencil_sme_counters_toc.xml
```

`.trace` 可以用 Instruments 打开，查看 cache miss、memory access 等硬件计数器。
不同 Xcode 版本模板名可能不同，如果默认模板不可用，可以手动指定：

```bash
TRACE_TEMPLATE="CPU Counters" llvm-pass-flow/scripts/profile_counters.sh \
  llvm-pass-flow/out/stencil_sme.prefetch \
  1024 1024 100 10
```

## 生成物

运行后主要生成：

- `out/stencil_sme.before.ll`：原始 LLVM IR。
- `out/stencil_sme.after.ll`：插入预取后的 LLVM IR。
- `out/stencil_sme.baseline`：由原始 IR 编译出的可执行文件。
- `out/stencil_sme.prefetch`：由插入预取后的 IR 编译出的可执行文件。
- `out/metrics.csv`：每次实验追加记录的计时结果。
- `build/StencilPrefetchPass.dylib`：LLVM pass 插件。

可以用下面命令确认预取是否插入：

```bash
rg "llvm.prefetch" llvm-pass-flow/out/stencil_sme.after.ll
```

## 注意事项

- macOS 上推荐使用 `build_pass_macos_dynamic.sh`，它通过
  `-Wl,-undefined,dynamic_lookup` 让 `opt` 加载插件时解析 LLVM 符号。
- `run_pass.sh` 会自动使用 `xcrun --show-sdk-path` 找到 macOS SDK，并传给
  `clang++`，避免标准 C/C++ 头文件找不到。
- 如果重新下载 LLVM 包后工具运行时被系统拦截，可在工作区内移除隔离属性：

```bash
xattr -dr com.apple.quarantine toolchains/LLVM-22.1.8-macOS-ARM64
xattr -dr com.apple.provenance toolchains/LLVM-22.1.8-macOS-ARM64
```
