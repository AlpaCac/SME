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

struct StencilPrefetchPass : PassInfoMixin<StencilPrefetchPass> {
    PreservedAnalyses run(Module& M, ModuleAnalysisManager&) {
        LLVMContext& Ctx = M.getContext();
        FunctionCallee Prefetch = M.getOrInsertFunction(
            "llvm.prefetch.p0",
            FunctionType::get(Type::getVoidTy(Ctx),
                              {PointerType::getUnqual(Ctx), Type::getInt32Ty(Ctx),
                               Type::getInt32Ty(Ctx), Type::getInt32Ty(Ctx)},
                              false));
        unsigned Inserted = 0;

        for (Function& F : M) {
            if (F.isDeclaration() || !F.getName().contains("stencil2d5p_sme_kernel")) {
                continue;
            }

            SmallVector<Instruction*, 16> LoadLikeInsts;
            for (BasicBlock& BB : F) {
                for (Instruction& I : BB) {
                    if (auto* LI = dyn_cast<LoadInst>(&I)) {
                        LoadLikeInsts.push_back(LI);
                        continue;
                    }

                    auto* CI = dyn_cast<CallInst>(&I);
                    if (!CI) {
                        continue;
                    }
                    Function* Callee = CI->getCalledFunction();
                    if (Callee && Callee->getName().starts_with("llvm.masked.load.")) {
                        LoadLikeInsts.push_back(CI);
                    }
                }
            }

            for (Instruction* I : LoadLikeInsts) {
                if (!I->getType()->isFloatingPointTy() && !I->getType()->isVectorTy()) {
                    continue;
                }

                IRBuilder<> B(I);
                Value* Ptr = nullptr;
                if (auto* LI = dyn_cast<LoadInst>(I)) {
                    Ptr = LI->getPointerOperand();
                } else if (auto* CI = dyn_cast<CallInst>(I)) {
                    Ptr = CI->getArgOperand(0);
                }

                if (!Ptr) {
                    continue;
                }

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

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo llvmGetPassPluginInfo() {
    return {
        LLVM_PLUGIN_API_VERSION,
        "StencilPrefetchPass",
        LLVM_VERSION_STRING,
        [](PassBuilder& PB) {
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
