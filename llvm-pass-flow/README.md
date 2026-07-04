# Stencil 预取 LLVM Pass 实验流程

这个目录用于实验“在 LLVM IR 层自动插入预取指令”，当前目标是给
`stencil_sme.cpp` 里的 SME stencil kernel 插入 `llvm.prefetch`，再重新编译运行。

## 目录内容

- `src/StencilPrefetchPass.cpp`：LLVM 新 Pass Manager 插件源码。
- `CMakeLists.txt`：CMake 构建入口，适合完整 LLVM + CMake 环境。
- `scripts/check_toolchain.sh`：检查是否存在完整 LLVM 工具链。
- `scripts/build_pass.sh`：使用 CMake 构建 pass 插件。
- `scripts/build_pass_direct.sh`：不使用 CMake，直接通过 `llvm-config` 构建插件。
- `scripts/build_pass_macos_dynamic.sh`：macOS 推荐构建方式，使用动态符号查找构建插件。
- `scripts/run_pass.sh`：执行完整流程：生成 LLVM IR、运行 pass、重新编译、运行验证。
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

export LLVM_HOME=/Users/alpaca/Documents/SME/toolchains/LLVM-22.1.8-macOS-ARM64
export LLVM_CONFIG=$LLVM_HOME/bin/llvm-config
export OPT=$LLVM_HOME/bin/opt
export CLANGXX=$LLVM_HOME/bin/clang++

llvm-pass-flow/scripts/build_pass_macos_dynamic.sh
llvm-pass-flow/scripts/run_pass.sh
```

期望输出类似：

```text
StencilPrefetchPass: inserted 5 llvm.prefetch calls
PASSED: max_diff=0
```

## 生成物

运行后主要生成：

- `out/stencil_sme.before.ll`：原始 LLVM IR。
- `out/stencil_sme.after.ll`：插入预取后的 LLVM IR。
- `out/stencil_sme.prefetch`：由插入预取后的 IR 编译出的可执行文件。
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
