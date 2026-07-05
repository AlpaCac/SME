#include "llvm/IR/Constants.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Plugins/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace {

// 当前 pass 是一个 ModulePass：一次拿到整个 LLVM Module，然后在里面寻找
// stencil kernel。后续如果要支持多个 stencil 示例，可以在函数筛选逻辑里
// 增加更多 kernel 名称或改成基于函数属性/命名规则的匹配。
struct StencilPrefetchPass : PassInfoMixin<StencilPrefetchPass> {
    PreservedAnalyses run(Module& M, ModuleAnalysisManager&) {
        LLVMContext& Ctx = M.getContext();

        // 准备 llvm.prefetch intrinsic 的声明。
        //
        // 这里手动声明 llvm.prefetch.p0，而不是使用 Intrinsic helper。
        // 原因是当前 LLVM 22.1.8 环境里，之前直接使用
        // Intrinsic::getOrInsertDeclaration 曾触发 opt 崩溃。
        //
        // IR 里最终插入的形式大致是：
        //   call void @llvm.prefetch.p0(ptr %addr, i32 rw, i32 locality, i32 cache)
        FunctionCallee Prefetch = M.getOrInsertFunction(
            "llvm.prefetch.p0",
            FunctionType::get(Type::getVoidTy(Ctx),
                              {PointerType::getUnqual(Ctx), Type::getInt32Ty(Ctx),
                               Type::getInt32Ty(Ctx), Type::getInt32Ty(Ctx)},
                              false));
        unsigned Inserted = 0;

        for (Function& F : M) {
            // 只处理当前 2D5P SME stencil kernel。
            //
            // 【后续扩展点】
            // 如果以后加入 2D9P、3D7P 或其他 stencil 示例，可以先改这里：
            //   1. 增加更多函数名匹配；
            //   2. 或者改成读取函数 attribute/metadata；
            //   3. 或者把 kernel 名称做成 pass 参数。
            if (F.isDeclaration() || !F.getName().contains("stencil2d5p_sme_kernel")) {
                continue;
            }

            // 第一阶段：扫描函数，把“像 load 的指令”先收集起来。
            //
            // 不在扫描时直接插入 prefetch，是为了避免修改 basic block 的
            // instruction list 后影响当前迭代器。
            SmallVector<Instruction*, 16> LoadLikeInsts;
            for (BasicBlock& BB : F) {
                for (Instruction& I : BB) {
                    // 普通 LLVM load，例如：
                    //   %v = load float, ptr %p
                    if (auto* LI = dyn_cast<LoadInst>(&I)) {
                        LoadLikeInsts.push_back(LI);
                        continue;
                    }

                    auto* CI = dyn_cast<CallInst>(&I);
                    if (!CI) {
                        continue;
                    }

                    // SME/SVE masked load 在 IR 中不是 LoadInst，而是 intrinsic call，
                    // 例如：
                    //   call <vscale x 4 x float> @llvm.masked.load.nxv4f32.p0(...)
                    //
                    // 当前 stencil 的 5 路读取 center/west/east/north/south
                    // 都会落到这一类。
                    Function* Callee = CI->getCalledFunction();
                    if (Callee && Callee->getName().starts_with("llvm.masked.load.")) {
                        LoadLikeInsts.push_back(CI);
                    }
                }
            }

            // 第二阶段：在每个目标 load 前插入 prefetch。
            for (Instruction* I : LoadLikeInsts) {
                // 当前只对浮点标量或向量结果插入预取，避免把控制逻辑、
                // 指针读取等非 stencil 数据访问也一起预取。
                if (!I->getType()->isFloatingPointTy() && !I->getType()->isVectorTy()) {
                    continue;
                }

                IRBuilder<> B(I);
                Value* Ptr = nullptr;
                if (auto* LI = dyn_cast<LoadInst>(I)) {
                    // 普通 load 的地址在 pointer operand。
                    Ptr = LI->getPointerOperand();
                } else if (auto* CI = dyn_cast<CallInst>(I)) {
                    // llvm.masked.load.* 的第 0 个参数是要读取的地址。
                    Ptr = CI->getArgOperand(0);
                }

                if (!Ptr) {
                    continue;
                }

                // 【预取决策核心位置】
                //
                // 当前策略是最简单的 baseline：在 load 前预取“同一个地址”。
                // 这主要用于跑通 LLVM pass 流程，不一定能带来性能提升。
                //
                // 后续如果要实验不同预取策略，重点改这里：
                //   1. 把 Ptr 改成未来地址，例如 Ptr + 1/2/4 个 VL；
                //   2. 根据 center/north/south/west/east 区分不同访问；
                //   3. 调整 rw/locality/cache 参数；
                //   4. 结合 LoopInfo/ScalarEvolution 找到内层循环和 GEP 规律。
                //
                // llvm.prefetch 参数含义：
                //   arg0: 预取地址
                //   arg1: rw，0 表示 read prefetch，1 表示 write prefetch
                //   arg2: locality，0~3，数值越大表示越希望留在 cache 中
                //   arg3: cache type，1 表示 data cache
                Value* Args[] = {
                    Ptr,
                    ConstantInt::get(Type::getInt32Ty(Ctx), 0),  // read
                    ConstantInt::get(Type::getInt32Ty(Ctx), 3),  // high locality
                    ConstantInt::get(Type::getInt32Ty(Ctx), 1),  // data cache
                };
                B.CreateCall(Prefetch, Args);
                ++Inserted;
            }
        }

        errs() << "StencilPrefetchPass: inserted " << Inserted
               << " llvm.prefetch calls\n";
        return Inserted == 0 ? PreservedAnalyses::all() : PreservedAnalyses::none();
    }
};

}  // namespace

// LLVM pass 插件入口。opt 通过 -load-pass-plugin 加载动态库时，会查找
// llvmGetPassPluginInfo 这个符号。
extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo llvmGetPassPluginInfo() {
    return {
        LLVM_PLUGIN_API_VERSION,
        "StencilPrefetchPass",
        LLVM_VERSION_STRING,
        [](PassBuilder& PB) {
            // 注册命令行 pipeline 名称：
            //
            //   opt -load-pass-plugin build/StencilPrefetchPass.dylib \
            //       -passes=stencil-prefetch input.ll -o output.ll
            //
            // 当 opt 看到 stencil-prefetch 时，就创建并运行上面的
            // StencilPrefetchPass。
            PB.registerPipelineParsingCallback(
                [](StringRef Name, ModulePassManager& MPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                    if (Name == "stencil-prefetch") {
                        MPM.addPass(StencilPrefetchPass());
                        return true;
                    }
                    return false;
                });
        },
    };
}
