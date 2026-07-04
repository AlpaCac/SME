# LLVM Pass 代码结构、工作流程与工作原理

本文档说明 `llvm-pass-flow` 中 LLVM Pass 的实现结构、运行流程，以及当前预取插入逻辑的工作原理。README 主要说明“怎么跑”，本文档主要说明“代码如何工作”。

## 1. 整体目标

当前 pass 的目标是在 LLVM IR 层识别 SME stencil kernel 中的内存读取，并在读取前插入 LLVM 预取 intrinsic：

```llvm
call void @llvm.prefetch.p0(ptr ..., i32 0, i32 3, i32 1)
```

当前实验对象是 `stencil_sme.cpp` 中的：

```cpp
stencil2d5p_sme_kernel
```

该 kernel 使用 SME streaming mode 和 SVE masked load/store 实现 2D5P stencil。Clang 生成 LLVM IR 后，SME/SVE load 会表现为：

```llvm
call <vscale x 4 x float> @llvm.masked.load.nxv4f32.p0(...)
```

因此 pass 需要识别普通 `load` 和 `llvm.masked.load.*` 两类读操作。

## 2. 目录结构

```text
llvm-pass-flow/
├── CMakeLists.txt
├── README.md
├── PASS_DESIGN.md
├── src/
│   └── StencilPrefetchPass.cpp
├── scripts/
│   ├── check_toolchain.sh
│   ├── build_pass.sh
│   ├── build_pass_direct.sh
│   ├── build_pass_macos_dynamic.sh
│   └── run_pass.sh
├── build/
│   └── StencilPrefetchPass.dylib
└── out/
    ├── stencil_sme.before.ll
    ├── stencil_sme.after.ll
    └── stencil_sme.prefetch
```

其中核心文件是：

- `src/StencilPrefetchPass.cpp`：pass 实现。
- `scripts/build_pass_macos_dynamic.sh`：在 macOS 上构建 pass 插件。
- `scripts/run_pass.sh`：生成 IR、运行 pass、重新编译并执行。

`build/` 和 `out/` 是生成目录，已在 `.gitignore` 中排除。

## 3. Pass 插件结构

当前 pass 使用 LLVM New Pass Manager 插件接口。

核心结构如下：

```cpp
struct StencilPrefetchPass : PassInfoMixin<StencilPrefetchPass> {
    PreservedAnalyses run(Module& M, ModuleAnalysisManager&);
};
```

这里的 pass 是一个 `ModulePass`，也就是一次处理整个 LLVM module，而不是单个函数或单个 basic block。

选择 `ModulePass` 的原因：

- 可以遍历 module 中所有函数；
- 可以方便创建或复用 module 级别的 intrinsic 声明；
- 后续可以同时处理多个 stencil kernel。

## 4. 插件注册方式

文件末尾的：

```cpp
extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo llvmGetPassPluginInfo()
```

是 LLVM pass 插件的入口。`opt` 加载动态库时会查找这个符号。

当前注册了一个 pipeline 名称：

```text
stencil-prefetch
```

因此运行 pass 时使用：

```bash
opt -load-pass-plugin build/StencilPrefetchPass.dylib \
    -passes=stencil-prefetch \
    input.ll \
    -o output.ll
```

当 `opt` 解析到 `-passes=stencil-prefetch` 时，会创建并运行：

```cpp
StencilPrefetchPass()
```

## 5. Pass 执行流程

`run(Module& M, ModuleAnalysisManager&)` 的主要流程如下：

```text
1. 获取 LLVMContext
2. 在 module 中声明或复用 llvm.prefetch.p0
3. 遍历 module 中所有 Function
4. 只处理名字包含 stencil2d5p_sme_kernel 的函数
5. 遍历函数中的 BasicBlock 和 Instruction
6. 收集普通 LoadInst
7. 收集 llvm.masked.load.* 调用
8. 对收集到的读取指令插入 llvm.prefetch
9. 输出插入数量
10. 返回 PreservedAnalyses
```

对应代码分布：

```cpp
FunctionCallee Prefetch = M.getOrInsertFunction(...);
```

负责准备 `llvm.prefetch.p0` 声明。

```cpp
for (Function& F : M) { ... }
```

遍历所有函数。

```cpp
if (F.isDeclaration() || !F.getName().contains("stencil2d5p_sme_kernel")) {
    continue;
}
```

只处理目标 stencil kernel。

```cpp
SmallVector<Instruction*, 16> LoadLikeInsts;
```

保存后续要插入预取的 load-like 指令。

## 6. 为什么要收集后再插入

pass 没有一边遍历 instruction 一边插入，而是先收集到 `LoadLikeInsts`，再统一插入。

原因是：插入新 instruction 会修改 basic block 的 instruction list。如果边遍历边插入，容易影响迭代器，导致漏处理或重复处理。

当前流程更稳：

```text
先扫描原始 IR -> 保存目标指令指针 -> 第二阶段插入新 IR
```

## 7. Load 识别逻辑

### 7.1 普通 load

普通标量或固定向量 load 会表现为：

```llvm
%x = load float, ptr %p
```

对应代码：

```cpp
if (auto* LI = dyn_cast<LoadInst>(&I)) {
    LoadLikeInsts.push_back(LI);
}
```

### 7.2 SME/SVE masked load

当前 SME kernel 的向量读取会表现为：

```llvm
%v = call <vscale x 4 x float> @llvm.masked.load.nxv4f32.p0(...)
```

对应代码：

```cpp
auto* CI = dyn_cast<CallInst>(&I);
Function* Callee = CI->getCalledFunction();
if (Callee && Callee->getName().starts_with("llvm.masked.load.")) {
    LoadLikeInsts.push_back(CI);
}
```

这一步是当前 pass 能处理 SME/SVE stencil 的关键。

## 8. 类型过滤

当前只对浮点或 vector 类型插入预取：

```cpp
if (!I->getType()->isFloatingPointTy() && !I->getType()->isVectorTy()) {
    continue;
}
```

这样可以跳过一些与 stencil 数据无关的指针 load、控制逻辑 load 等。

当前 2D5P SME kernel 中会识别到 5 个 masked vector load，对应：

```text
center
west
east
north
south
```

因此当前输出是：

```text
StencilPrefetchPass: inserted 5 llvm.prefetch calls
```

## 9. 取出预取地址

普通 `LoadInst` 的地址来自：

```cpp
LI->getPointerOperand()
```

`llvm.masked.load.*` 的地址是第 0 个参数：

```cpp
CI->getArgOperand(0)
```

当前插入的是“同地址预取”，也就是在 load 前对该 load 的地址执行 prefetch。

这只是跑通流程的基线策略。后续真正做性能实验时，更合理的做法是预取未来地址，例如：

```text
x + 1 * VL
x + 2 * VL
x + 4 * VL
```

## 10. 插入 llvm.prefetch

当前通过 `IRBuilder` 在目标 load 前插入：

```cpp
IRBuilder<> B(I);
B.CreateCall(Prefetch, Args);
```

插入位置是目标读取指令之前。

预取 intrinsic 参数为：

```cpp
Value* Args[] = {
    Ptr,
    ConstantInt::get(Type::getInt32Ty(Ctx), 0),
    ConstantInt::get(Type::getInt32Ty(Ctx), 3),
    ConstantInt::get(Type::getInt32Ty(Ctx), 1),
};
```

含义如下：

```text
参数 0：Ptr，要预取的地址
参数 1：rw，0 表示 read prefetch，1 表示 write prefetch
参数 2：locality，0~3，当前为 3，表示较高局部性
参数 3：cache type，1 表示 data cache
```

生成后的 IR 形态类似：

```llvm
call void @llvm.prefetch.p0(ptr %27, i32 0, i32 3, i32 1)
%28 = call <vscale x 4 x float> @llvm.masked.load.nxv4f32.p0(...)
```

## 11. 为什么手动声明 llvm.prefetch.p0

LLVM 有 intrinsic helper API，但在当前 LLVM 22.1.8 环境中，直接使用：

```cpp
Intrinsic::getOrInsertDeclaration(&M, Intrinsic::prefetch)
```

曾经触发过 `opt` 崩溃。

因此当前代码改用更直接的：

```cpp
M.getOrInsertFunction("llvm.prefetch.p0", FunctionType::get(...))
```

这样可以绕开版本相关问题，也更容易看出最终 IR 中要生成什么声明。

## 12. 脚本工作流程

### 12.1 构建 pass 插件

运行：

```bash
llvm-pass-flow/scripts/build_pass_macos_dynamic.sh
```

流程如下：

```text
1. 定位 llvm-pass-flow 根目录
2. 自动查找 toolchains/LLVM-22.1.8-macOS-ARM64
3. 找到 llvm-config
4. 默认使用 /usr/bin/clang++ 编译插件
5. 通过 xcrun --show-sdk-path 获取 macOS SDK
6. 使用 llvm-config --cxxflags 获取 LLVM 头文件路径和编译选项
7. 使用 -Wl,-undefined,dynamic_lookup 构建 macOS dylib
8. 输出 build/StencilPrefetchPass.dylib
```

macOS 上使用：

```bash
-Wl,-undefined,dynamic_lookup
```

是为了让插件在被 `opt` 加载时，再从 `opt` 进程中解析 LLVM 符号，避免手动链接一大串 LLVM 静态库。

### 12.2 运行 pass

运行：

```bash
llvm-pass-flow/scripts/run_pass.sh
```

流程如下：

```text
1. 自动查找 LLVM_HOME
2. 设置 CLANGXX 和 OPT
3. 检查 pass 插件是否存在
4. 用 clang++ -S -emit-llvm 生成 before.ll
5. 用 opt 加载 pass 插件并生成 after.ll
6. 用 clang++ 把 after.ll 编译成可执行文件
7. 执行可执行文件，检查 max_diff
```

对应产物：

```text
out/stencil_sme.before.ll
out/stencil_sme.after.ll
out/stencil_sme.prefetch
```

## 13. 当前方案的局限

当前 pass 只是“流程基线”，主要用于验证：

```text
C++ -> LLVM IR -> opt pass -> 修改后 IR -> executable
```

它还不是最终性能优化策略。

当前局限包括：

- 只通过函数名匹配 `stencil2d5p_sme_kernel`；
- 只在 load 原地址前插入 prefetch；
- 没有计算 `x + prefetch_distance`；
- 没有区分 center、north、south 等行；
- 没有基于 LoopInfo 或 ScalarEvolution 分析循环；
- 没有根据 cache line、VL、网格大小自动调参。

## 14. 后续扩展方向

后续可以逐步演进为真正的 stencil prefetch 实验框架：

1. 增加 pass 参数，例如：

```text
prefetch-distance-vl=1/2/4/8
prefetch-mode=center/3rows/5loads/store
prefetch-locality=0/1/2/3
```

2. 使用 `LoopInfo` 找到内层循环。

3. 使用 `ScalarEvolution` 分析 GEP 地址表达式。

4. 将当前地址：

```text
input + row + x
```

改写为未来地址：

```text
input + row + x + distance
```

5. 区分不同 stencil shape：

```text
2D5P
2D9P
3D7P
3D27P
```

6. 增加实验脚本，批量生成不同预取策略的可执行文件并记录运行时间。

## 15. 调试建议

查看 pass 是否插入预取：

```bash
rg "llvm.prefetch" llvm-pass-flow/out/stencil_sme.after.ll
```

查看 SME/SVE masked load：

```bash
rg "llvm.masked.load|llvm.aarch64.sve" llvm-pass-flow/out/stencil_sme.before.ll
```

单独运行 pass：

```bash
toolchains/LLVM-22.1.8-macOS-ARM64/bin/opt \
  -S \
  -load-pass-plugin llvm-pass-flow/build/StencilPrefetchPass.dylib \
  -passes=stencil-prefetch \
  llvm-pass-flow/out/stencil_sme.before.ll \
  -o llvm-pass-flow/out/stencil_sme.after.ll
```

验证最终程序：

```bash
llvm-pass-flow/out/stencil_sme.prefetch
```

期望输出：

```text
PASSED: max_diff=0
```
