; ModuleID = '/Users/alpaca/Documents/SME/llvm-pass-flow/out/stencil_sme.before.ll'
source_filename = "/Users/alpaca/Documents/SME/stencil_sme.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%"class.std::__1::vector" = type { ptr, ptr, %struct.anon }
%struct.anon = type { ptr }

@.str.3 = private unnamed_addr constant [44 x i8] c"METRIC nx=%d ny=%d warmup=%d iterations=%d\0A\00", align 1
@.str.4 = private unnamed_addr constant [66 x i8] c"METRIC kernel_total_ms=%.6f kernel_avg_ms=%.6f mcells_per_s=%.6f\0A\00", align 1
@.str.5 = private unnamed_addr constant [7 x i8] c"vector\00", align 1
@_ZTISt12length_error = external constant ptr
@_ZTVSt12length_error = external unnamed_addr constant { [5 x ptr] }, align 8
@.str.6 = private unnamed_addr constant [48 x i8] c"FAILED: max_diff=%g idx=%zu got=%g expected=%g\0A\00", align 1
@.str.7 = private unnamed_addr constant [21 x i8] c"PASSED: max_diff=%g\0A\00", align 1
@str = private unnamed_addr constant [33 x i8] c"SME is not available on this CPU\00", align 1
@str.8 = private unnamed_addr constant [48 x i8] c"iterations must be >= 1 and warmup must be >= 0\00", align 1
@str.9 = private unnamed_addr constant [23 x i8] c"nx and ny must be >= 3\00", align 1

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp memory(argmem: readwrite) uwtable(sync) vscale_range(1,16)
define void @stencil2d5p_sme_kernel(ptr noundef readonly captures(none) %0, ptr noundef writeonly captures(none) %1, i32 noundef %2, i32 noundef %3) local_unnamed_addr #0 {
  %5 = icmp sgt i32 %3, 2
  br i1 %5, label %6, label %16

6:                                                ; preds = %4
  %7 = add nsw i32 %3, -1
  %8 = tail call i64 @llvm.vscale.i64()
  %9 = sext i32 %2 to i64
  %10 = add nsw i32 %2, -1
  %11 = icmp sgt i32 %2, 2
  %12 = sub nsw i64 0, %9
  %13 = shl nuw nsw i64 %8, 2
  %14 = sext i32 %10 to i64
  %15 = zext nneg i32 %7 to i64
  br label %17

16:                                               ; preds = %45, %4
  ret void

17:                                               ; preds = %45, %6
  %18 = phi i64 [ 1, %6 ], [ %46, %45 ]
  br i1 %11, label %19, label %45

19:                                               ; preds = %17
  %20 = mul nuw nsw i64 %18, %9
  %21 = getelementptr inbounds nuw float, ptr %0, i64 %20
  %22 = getelementptr inbounds nuw float, ptr %1, i64 %20
  br label %23

23:                                               ; preds = %23, %19
  %24 = phi i64 [ 1, %19 ], [ %43, %23 ]
  %25 = trunc nuw nsw i64 %24 to i32
  %26 = tail call <vscale x 4 x i1> @llvm.aarch64.sve.whilelt.nxv4i1.i32(i32 %25, i32 %10)
  %27 = getelementptr inbounds nuw float, ptr %21, i64 %24
  call void @llvm.prefetch.p0(ptr %27, i32 0, i32 3, i32 1)
  %28 = tail call <vscale x 4 x float> @llvm.masked.load.nxv4f32.p0(ptr nonnull align 1 %27, <vscale x 4 x i1> %26, <vscale x 4 x float> zeroinitializer), !tbaa !10
  %29 = getelementptr inbounds i8, ptr %27, i64 -4
  call void @llvm.prefetch.p0(ptr %29, i32 0, i32 3, i32 1)
  %30 = tail call <vscale x 4 x float> @llvm.masked.load.nxv4f32.p0(ptr nonnull align 1 %29, <vscale x 4 x i1> %26, <vscale x 4 x float> zeroinitializer), !tbaa !10
  %31 = getelementptr inbounds nuw i8, ptr %27, i64 4
  call void @llvm.prefetch.p0(ptr %31, i32 0, i32 3, i32 1)
  %32 = tail call <vscale x 4 x float> @llvm.masked.load.nxv4f32.p0(ptr nonnull align 1 %31, <vscale x 4 x i1> %26, <vscale x 4 x float> zeroinitializer), !tbaa !10
  %33 = getelementptr inbounds float, ptr %27, i64 %12
  call void @llvm.prefetch.p0(ptr %33, i32 0, i32 3, i32 1)
  %34 = tail call <vscale x 4 x float> @llvm.masked.load.nxv4f32.p0(ptr nonnull align 1 %33, <vscale x 4 x i1> %26, <vscale x 4 x float> zeroinitializer), !tbaa !10
  %35 = getelementptr inbounds nuw float, ptr %27, i64 %9
  call void @llvm.prefetch.p0(ptr %35, i32 0, i32 3, i32 1)
  %36 = tail call <vscale x 4 x float> @llvm.masked.load.nxv4f32.p0(ptr nonnull align 1 %35, <vscale x 4 x i1> %26, <vscale x 4 x float> zeroinitializer), !tbaa !10
  %37 = tail call <vscale x 4 x float> @llvm.aarch64.sve.fadd.nxv4f32(<vscale x 4 x i1> %26, <vscale x 4 x float> %30, <vscale x 4 x float> %32)
  %38 = tail call <vscale x 4 x float> @llvm.aarch64.sve.fadd.nxv4f32(<vscale x 4 x i1> %26, <vscale x 4 x float> %37, <vscale x 4 x float> %34)
  %39 = tail call <vscale x 4 x float> @llvm.aarch64.sve.fadd.nxv4f32(<vscale x 4 x i1> %26, <vscale x 4 x float> %38, <vscale x 4 x float> %36)
  %40 = tail call <vscale x 4 x float> @llvm.aarch64.sve.fmul.nxv4f32(<vscale x 4 x i1> %26, <vscale x 4 x float> %28, <vscale x 4 x float> splat (float 5.000000e-01))
  %41 = tail call <vscale x 4 x float> @llvm.aarch64.sve.fmla.nxv4f32(<vscale x 4 x i1> %26, <vscale x 4 x float> %40, <vscale x 4 x float> %39, <vscale x 4 x float> splat (float 1.250000e-01))
  %42 = getelementptr inbounds nuw float, ptr %22, i64 %24
  tail call void @llvm.masked.store.nxv4f32.p0(<vscale x 4 x float> %41, ptr nonnull align 1 %42, <vscale x 4 x i1> %26), !tbaa !10
  %43 = add nuw nsw i64 %24, %13
  %44 = icmp slt i64 %43, %14
  br i1 %44, label %23, label %45, !llvm.loop !12

45:                                               ; preds = %23, %17
  %46 = add nuw nsw i64 %18, 1
  %47 = icmp eq i64 %46, %15
  br i1 %47, label %16, label %17, !llvm.loop !14
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <vscale x 4 x i1> @llvm.aarch64.sve.whilelt.nxv4i1.i32(i32, i32) #2

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare <vscale x 4 x float> @llvm.aarch64.sve.fadd.nxv4f32(<vscale x 4 x i1>, <vscale x 4 x float>, <vscale x 4 x float>) #3

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare <vscale x 4 x float> @llvm.aarch64.sve.fmul.nxv4f32(<vscale x 4 x i1>, <vscale x 4 x float>, <vscale x 4 x float>) #3

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(none)
declare <vscale x 4 x float> @llvm.aarch64.sve.fmla.nxv4f32(<vscale x 4 x i1>, <vscale x 4 x float>, <vscale x 4 x float>, <vscale x 4 x float>) #3

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #1

; Function Attrs: mustprogress norecurse ssp uwtable(sync)
define noundef range(i32 0, 2) i32 @main(i32 noundef %0, ptr noundef readonly captures(none) %1) local_unnamed_addr #4 personality ptr @__gxx_personality_v0 {
  %3 = alloca %"class.std::__1::vector", align 8
  %4 = alloca %"class.std::__1::vector", align 8
  %5 = icmp sgt i32 %0, 1
  br i1 %5, label %6, label %25

6:                                                ; preds = %2
  %7 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %8 = load ptr, ptr %7, align 8, !tbaa !15
  %9 = tail call i32 @atoi(ptr noundef %8)
  %10 = icmp eq i32 %0, 2
  br i1 %10, label %25, label %11

11:                                               ; preds = %6
  %12 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %13 = load ptr, ptr %12, align 8, !tbaa !15
  %14 = tail call i32 @atoi(ptr noundef %13)
  %15 = icmp samesign ugt i32 %0, 3
  br i1 %15, label %16, label %25

16:                                               ; preds = %11
  %17 = getelementptr inbounds nuw i8, ptr %1, i64 24
  %18 = load ptr, ptr %17, align 8, !tbaa !15
  %19 = tail call i32 @atoi(ptr noundef %18)
  %20 = icmp eq i32 %0, 4
  br i1 %20, label %25, label %21

21:                                               ; preds = %16
  %22 = getelementptr inbounds nuw i8, ptr %1, i64 32
  %23 = load ptr, ptr %22, align 8, !tbaa !15
  %24 = tail call i32 @atoi(ptr noundef %23)
  br label %25

25:                                               ; preds = %21, %16, %11, %6, %2
  %26 = phi i32 [ %19, %21 ], [ %19, %16 ], [ 50, %11 ], [ 50, %6 ], [ 50, %2 ]
  %27 = phi i32 [ %9, %21 ], [ %9, %16 ], [ %9, %11 ], [ %9, %6 ], [ 256, %2 ]
  %28 = phi i32 [ %14, %21 ], [ %14, %16 ], [ %14, %11 ], [ 256, %6 ], [ 256, %2 ]
  %29 = phi i32 [ %24, %21 ], [ 5, %16 ], [ 5, %11 ], [ 5, %6 ], [ 5, %2 ]
  %30 = icmp slt i32 %27, 3
  %31 = icmp slt i32 %28, 3
  %32 = select i1 %30, i1 true, i1 %31
  br i1 %32, label %33, label %35

33:                                               ; preds = %25
  %34 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.9)
  br label %410

35:                                               ; preds = %25
  %36 = icmp slt i32 %26, 1
  %37 = icmp slt i32 %29, 0
  %38 = select i1 %36, i1 true, i1 %37
  br i1 %38, label %39, label %41

39:                                               ; preds = %35
  %40 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.8)
  br label %410

41:                                               ; preds = %35
  %42 = tail call aarch64_sme_preservemost_from_x2 { i64, i64 } @__arm_sme_state() #22
  %43 = extractvalue { i64, i64 } %42, 0
  %44 = icmp slt i64 %43, 0
  br i1 %44, label %47, label %45

45:                                               ; preds = %41
  %46 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str)
  br label %410

47:                                               ; preds = %41
  %48 = zext nneg i32 %27 to i64
  %49 = zext nneg i32 %28 to i64
  %50 = shl nuw nsw i64 %48, 2
  %51 = mul nuw i64 %50, %49
  %52 = tail call noalias noundef nonnull ptr @_Znwm(i64 noundef %51) #23
  %53 = getelementptr i8, ptr %52, i64 %51
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(1) %52, i8 0, i64 %51, i1 false), !tbaa !10
  call void @llvm.lifetime.start.p0(ptr nonnull %3) #24
  %54 = ashr exact i64 %51, 2
  %55 = getelementptr inbounds nuw i8, ptr %3, i64 8
  %56 = getelementptr inbounds nuw i8, ptr %3, i64 16
  %57 = icmp ugt i64 %54, 4611686018427387903
  br i1 %57, label %58, label %60

58:                                               ; preds = %47
  invoke void @_ZNSt3__16vectorIfNS_9allocatorIfEEE20__throw_length_errorB9nqe220108Ev() #25
          to label %59 unwind label %62

59:                                               ; preds = %58
  unreachable

60:                                               ; preds = %47
  %61 = invoke noalias noundef nonnull ptr @_Znwm(i64 noundef %51) #23
          to label %64 unwind label %62

62:                                               ; preds = %60, %58
  %63 = landingpad { ptr, i32 }
          cleanup
  br label %407

64:                                               ; preds = %60
  store ptr %61, ptr %3, align 8, !tbaa !18
  %65 = getelementptr i8, ptr %61, i64 %51
  store ptr %65, ptr %56, align 8, !tbaa !22
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(1) %61, i8 0, i64 %51, i1 false), !tbaa !10
  store ptr %65, ptr %55, align 8, !tbaa !23
  call void @llvm.lifetime.start.p0(ptr nonnull %4) #24
  %66 = getelementptr inbounds nuw i8, ptr %4, i64 8
  %67 = getelementptr inbounds nuw i8, ptr %4, i64 16
  %68 = invoke noalias noundef nonnull ptr @_Znwm(i64 noundef %51) #23
          to label %69 unwind label %74

69:                                               ; preds = %64
  store ptr %68, ptr %4, align 8, !tbaa !18
  %70 = getelementptr i8, ptr %68, i64 %51
  store ptr %70, ptr %67, align 8, !tbaa !22
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(1) %68, i8 0, i64 %51, i1 false), !tbaa !10
  store ptr %70, ptr %66, align 8, !tbaa !23
  %71 = icmp ult i32 %27, 4
  %72 = and i64 %48, 2147483644
  %73 = icmp eq i64 %72, %48
  br label %76

74:                                               ; preds = %64
  %75 = landingpad { ptr, i32 }
          cleanup
  br label %398

76:                                               ; preds = %101, %69
  %77 = phi i64 [ 0, %69 ], [ %102, %101 ]
  %78 = mul nuw nsw i64 %77, 7
  %79 = mul nuw nsw i64 %77, %48
  %80 = getelementptr inbounds nuw float, ptr %52, i64 %79
  br i1 %71, label %98, label %81

81:                                               ; preds = %76
  %82 = insertelement <4 x i64> poison, i64 %78, i64 0
  %83 = shufflevector <4 x i64> %82, <4 x i64> poison, <4 x i32> zeroinitializer
  br label %84

84:                                               ; preds = %84, %81
  %85 = phi i64 [ 0, %81 ], [ %94, %84 ]
  %86 = phi <4 x i64> [ <i64 0, i64 1, i64 2, i64 3>, %81 ], [ %95, %84 ]
  %87 = mul nuw nsw <4 x i64> %86, splat (i64 13)
  %88 = add nuw nsw <4 x i64> %87, %83
  %89 = trunc nuw <4 x i64> %88 to <4 x i32>
  %90 = urem <4 x i32> %89, splat (i32 97)
  %91 = uitofp nneg <4 x i32> %90 to <4 x float>
  %92 = fmul <4 x float> %91, splat (float 0x3F847AE140000000)
  %93 = getelementptr inbounds nuw float, ptr %80, i64 %85
  store <4 x float> %92, ptr %93, align 4, !tbaa !10
  %94 = add nuw i64 %85, 4
  %95 = add nuw nsw <4 x i64> %86, splat (i64 4)
  %96 = icmp eq i64 %94, %72
  br i1 %96, label %97, label %84, !llvm.loop !24

97:                                               ; preds = %84
  br i1 %73, label %101, label %98

98:                                               ; preds = %97, %76
  %99 = phi i64 [ 0, %76 ], [ %72, %97 ]
  br label %104

100:                                              ; preds = %101
  invoke void @_ZNSt3__16vectorIfNS_9allocatorIfEEE18__assign_with_sizeB9nqe220108INS_17_ClassicAlgPolicyEPfS6_EEvT0_T1_l(ptr noundef nonnull align 8 dereferenceable(24) %3, ptr noundef nonnull %52, ptr noundef %53, i64 noundef %54)
          to label %115 unwind label %277

101:                                              ; preds = %104, %97
  %102 = add nuw nsw i64 %77, 1
  %103 = icmp eq i64 %102, %49
  br i1 %103, label %100, label %76, !llvm.loop !27

104:                                              ; preds = %104, %98
  %105 = phi i64 [ %113, %104 ], [ %99, %98 ]
  %106 = mul nuw nsw i64 %105, 13
  %107 = add nuw nsw i64 %106, %78
  %108 = trunc nuw i64 %107 to i32
  %109 = urem i32 %108, 97
  %110 = uitofp nneg i32 %109 to float
  %111 = fmul float %110, 0x3F847AE140000000
  %112 = getelementptr inbounds nuw float, ptr %80, i64 %105
  store float %111, ptr %112, align 4, !tbaa !10
  %113 = add nuw nsw i64 %105, 1
  %114 = icmp eq i64 %113, %48
  br i1 %114, label %101, label %104, !llvm.loop !28

115:                                              ; preds = %100
  invoke void @_ZNSt3__16vectorIfNS_9allocatorIfEEE18__assign_with_sizeB9nqe220108INS_17_ClassicAlgPolicyEPfS6_EEvT0_T1_l(ptr noundef nonnull align 8 dereferenceable(24) %4, ptr noundef nonnull %52, ptr noundef %53, i64 noundef %54)
          to label %116 unwind label %277

116:                                              ; preds = %115
  %117 = add nsw i32 %28, -1
  %118 = add nsw i32 %27, -1
  %119 = getelementptr float, ptr %52, i64 %48
  %120 = load ptr, ptr %3, align 8
  %121 = zext i32 %117 to i64
  %122 = zext i32 %118 to i64
  %123 = getelementptr nuw i8, ptr %120, i64 %50
  %124 = getelementptr nuw i8, ptr %123, i64 4
  %125 = shl nuw nsw i64 %121, 2
  %126 = add nsw i64 %125, -4
  %127 = mul i64 %126, %48
  %128 = shl nuw nsw i64 %122, 2
  %129 = getelementptr i8, ptr %120, i64 %127
  %130 = getelementptr i8, ptr %129, i64 %128
  %131 = shl nuw nsw i64 %48, 3
  %132 = getelementptr i8, ptr %52, i64 %131
  %133 = getelementptr i8, ptr %132, i64 4
  %134 = mul nuw nsw i64 %48, %121
  %135 = add nuw i64 %134, %122
  %136 = shl i64 %135, 2
  %137 = getelementptr i8, ptr %52, i64 %136
  %138 = getelementptr i8, ptr %52, i64 4
  %139 = add nuw nsw i64 %121, 4611686018427387902
  %140 = mul i64 %139, %48
  %141 = add i64 %140, %122
  %142 = shl i64 %141, 2
  %143 = getelementptr i8, ptr %52, i64 %142
  %144 = getelementptr i8, ptr %52, i64 %127
  %145 = getelementptr i8, ptr %144, i64 %128
  %146 = getelementptr i8, ptr %145, i64 4
  %147 = add nsw i64 %122, -1
  %148 = icmp ult i64 %147, 4
  %149 = icmp ult ptr %124, %137
  %150 = icmp ult ptr %133, %130
  %151 = and i1 %149, %150
  %152 = icmp ult ptr %124, %143
  %153 = icmp ult ptr %138, %130
  %154 = and i1 %152, %153
  %155 = or i1 %151, %154
  %156 = icmp ult ptr %124, %146
  %157 = icmp ult ptr %119, %130
  %158 = and i1 %156, %157
  %159 = or i1 %155, %158
  %160 = icmp ult i64 %147, 16
  %161 = and i64 %147, 12
  %162 = and i64 %147, -16
  %163 = icmp eq i64 %147, %162
  %164 = or disjoint i64 %162, 1
  %165 = icmp eq i64 %161, 0
  %166 = and i64 %147, -4
  %167 = or disjoint i64 %166, 1
  %168 = icmp eq i64 %147, %166
  br label %169

169:                                              ; preds = %281, %116
  %170 = phi i64 [ 1, %116 ], [ %282, %281 ]
  %171 = mul nuw nsw i64 %170, %48
  %172 = select i1 %148, i1 true, i1 %159
  br i1 %172, label %273, label %173

173:                                              ; preds = %169
  br i1 %160, label %247, label %174

174:                                              ; preds = %174, %173
  %175 = phi i64 [ %243, %174 ], [ 0, %173 ]
  %176 = or disjoint i64 %175, 1
  %177 = add nuw nsw i64 %176, %171
  %178 = getelementptr float, ptr %52, i64 %177
  %179 = getelementptr i8, ptr %178, i64 16
  %180 = getelementptr i8, ptr %178, i64 32
  %181 = getelementptr i8, ptr %178, i64 48
  %182 = load <4 x float>, ptr %178, align 4, !tbaa !10, !alias.scope !29
  %183 = load <4 x float>, ptr %179, align 4, !tbaa !10, !alias.scope !29
  %184 = load <4 x float>, ptr %180, align 4, !tbaa !10, !alias.scope !29
  %185 = load <4 x float>, ptr %181, align 4, !tbaa !10, !alias.scope !29
  %186 = getelementptr i8, ptr %178, i64 -4
  %187 = getelementptr i8, ptr %178, i64 12
  %188 = getelementptr i8, ptr %178, i64 28
  %189 = getelementptr i8, ptr %178, i64 44
  %190 = load <4 x float>, ptr %186, align 4, !tbaa !10, !alias.scope !29
  %191 = load <4 x float>, ptr %187, align 4, !tbaa !10, !alias.scope !29
  %192 = load <4 x float>, ptr %188, align 4, !tbaa !10, !alias.scope !29
  %193 = load <4 x float>, ptr %189, align 4, !tbaa !10, !alias.scope !29
  %194 = getelementptr inbounds nuw i8, ptr %178, i64 4
  %195 = getelementptr inbounds nuw i8, ptr %178, i64 20
  %196 = getelementptr inbounds nuw i8, ptr %178, i64 36
  %197 = getelementptr inbounds nuw i8, ptr %178, i64 52
  %198 = load <4 x float>, ptr %194, align 4, !tbaa !10, !alias.scope !29
  %199 = load <4 x float>, ptr %195, align 4, !tbaa !10, !alias.scope !29
  %200 = load <4 x float>, ptr %196, align 4, !tbaa !10, !alias.scope !29
  %201 = load <4 x float>, ptr %197, align 4, !tbaa !10, !alias.scope !29
  %202 = fadd <4 x float> %190, %198
  %203 = fadd <4 x float> %191, %199
  %204 = fadd <4 x float> %192, %200
  %205 = fadd <4 x float> %193, %201
  %206 = sub nuw nsw i64 %177, %48
  %207 = getelementptr inbounds nuw float, ptr %52, i64 %206
  %208 = getelementptr inbounds nuw i8, ptr %207, i64 16
  %209 = getelementptr inbounds nuw i8, ptr %207, i64 32
  %210 = getelementptr inbounds nuw i8, ptr %207, i64 48
  %211 = load <4 x float>, ptr %207, align 4, !tbaa !10, !alias.scope !32
  %212 = load <4 x float>, ptr %208, align 4, !tbaa !10, !alias.scope !32
  %213 = load <4 x float>, ptr %209, align 4, !tbaa !10, !alias.scope !32
  %214 = load <4 x float>, ptr %210, align 4, !tbaa !10, !alias.scope !32
  %215 = fadd <4 x float> %202, %211
  %216 = fadd <4 x float> %203, %212
  %217 = fadd <4 x float> %204, %213
  %218 = fadd <4 x float> %205, %214
  %219 = getelementptr inbounds nuw float, ptr %119, i64 %177
  %220 = getelementptr inbounds nuw i8, ptr %219, i64 16
  %221 = getelementptr inbounds nuw i8, ptr %219, i64 32
  %222 = getelementptr inbounds nuw i8, ptr %219, i64 48
  %223 = load <4 x float>, ptr %219, align 4, !tbaa !10, !alias.scope !34
  %224 = load <4 x float>, ptr %220, align 4, !tbaa !10, !alias.scope !34
  %225 = load <4 x float>, ptr %221, align 4, !tbaa !10, !alias.scope !34
  %226 = load <4 x float>, ptr %222, align 4, !tbaa !10, !alias.scope !34
  %227 = fadd <4 x float> %215, %223
  %228 = fadd <4 x float> %216, %224
  %229 = fadd <4 x float> %217, %225
  %230 = fadd <4 x float> %218, %226
  %231 = fmul <4 x float> %227, splat (float 1.250000e-01)
  %232 = fmul <4 x float> %228, splat (float 1.250000e-01)
  %233 = fmul <4 x float> %229, splat (float 1.250000e-01)
  %234 = fmul <4 x float> %230, splat (float 1.250000e-01)
  %235 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %182, <4 x float> splat (float 5.000000e-01), <4 x float> %231)
  %236 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %183, <4 x float> splat (float 5.000000e-01), <4 x float> %232)
  %237 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %184, <4 x float> splat (float 5.000000e-01), <4 x float> %233)
  %238 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %185, <4 x float> splat (float 5.000000e-01), <4 x float> %234)
  %239 = getelementptr inbounds nuw float, ptr %120, i64 %177
  %240 = getelementptr inbounds nuw i8, ptr %239, i64 16
  %241 = getelementptr inbounds nuw i8, ptr %239, i64 32
  %242 = getelementptr inbounds nuw i8, ptr %239, i64 48
  store <4 x float> %235, ptr %239, align 4, !tbaa !10, !alias.scope !36, !noalias !38
  store <4 x float> %236, ptr %240, align 4, !tbaa !10, !alias.scope !36, !noalias !38
  store <4 x float> %237, ptr %241, align 4, !tbaa !10, !alias.scope !36, !noalias !38
  store <4 x float> %238, ptr %242, align 4, !tbaa !10, !alias.scope !36, !noalias !38
  %243 = add nuw i64 %175, 16
  %244 = icmp eq i64 %243, %162
  br i1 %244, label %245, label %174, !llvm.loop !39

245:                                              ; preds = %174
  br i1 %163, label %281, label %246

246:                                              ; preds = %245
  br i1 %165, label %273, label %247, !prof !40

247:                                              ; preds = %246, %173
  %248 = phi i64 [ %162, %246 ], [ 0, %173 ]
  br label %249

249:                                              ; preds = %249, %247
  %250 = phi i64 [ %248, %247 ], [ %270, %249 ]
  %251 = or disjoint i64 %250, 1
  %252 = add nuw nsw i64 %251, %171
  %253 = getelementptr float, ptr %52, i64 %252
  %254 = load <4 x float>, ptr %253, align 4, !tbaa !10, !alias.scope !29
  %255 = getelementptr i8, ptr %253, i64 -4
  %256 = load <4 x float>, ptr %255, align 4, !tbaa !10, !alias.scope !29
  %257 = getelementptr inbounds nuw i8, ptr %253, i64 4
  %258 = load <4 x float>, ptr %257, align 4, !tbaa !10, !alias.scope !29
  %259 = fadd <4 x float> %256, %258
  %260 = sub nuw nsw i64 %252, %48
  %261 = getelementptr inbounds nuw float, ptr %52, i64 %260
  %262 = load <4 x float>, ptr %261, align 4, !tbaa !10, !alias.scope !32
  %263 = fadd <4 x float> %259, %262
  %264 = getelementptr inbounds nuw float, ptr %119, i64 %252
  %265 = load <4 x float>, ptr %264, align 4, !tbaa !10, !alias.scope !34
  %266 = fadd <4 x float> %263, %265
  %267 = fmul <4 x float> %266, splat (float 1.250000e-01)
  %268 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %254, <4 x float> splat (float 5.000000e-01), <4 x float> %267)
  %269 = getelementptr inbounds nuw float, ptr %120, i64 %252
  store <4 x float> %268, ptr %269, align 4, !tbaa !10, !alias.scope !36, !noalias !38
  %270 = add nuw i64 %250, 4
  %271 = icmp eq i64 %270, %166
  br i1 %271, label %272, label %249, !llvm.loop !41

272:                                              ; preds = %249
  br i1 %168, label %281, label %273

273:                                              ; preds = %272, %246, %169
  %274 = phi i64 [ 1, %169 ], [ %167, %272 ], [ %164, %246 ]
  br label %284

275:                                              ; preds = %281
  %276 = icmp eq i32 %29, 0
  br i1 %276, label %306, label %308

277:                                              ; preds = %115, %100
  %278 = landingpad { ptr, i32 }
          cleanup
  %279 = load ptr, ptr %4, align 8, !tbaa !18
  %280 = icmp eq ptr %279, null
  br i1 %280, label %398, label %393

281:                                              ; preds = %284, %272, %245
  %282 = add nuw nsw i64 %170, 1
  %283 = icmp eq i64 %282, %121
  br i1 %283, label %275, label %169, !llvm.loop !42

284:                                              ; preds = %284, %273
  %285 = phi i64 [ %304, %284 ], [ %274, %273 ]
  %286 = add nuw nsw i64 %285, %171
  %287 = getelementptr float, ptr %52, i64 %286
  %288 = load float, ptr %287, align 4, !tbaa !10
  %289 = getelementptr i8, ptr %287, i64 -4
  %290 = load float, ptr %289, align 4, !tbaa !10
  %291 = getelementptr inbounds nuw i8, ptr %287, i64 4
  %292 = load float, ptr %291, align 4, !tbaa !10
  %293 = fadd float %290, %292
  %294 = sub nuw nsw i64 %286, %48
  %295 = getelementptr inbounds nuw float, ptr %52, i64 %294
  %296 = load float, ptr %295, align 4, !tbaa !10
  %297 = fadd float %293, %296
  %298 = getelementptr inbounds nuw float, ptr %119, i64 %286
  %299 = load float, ptr %298, align 4, !tbaa !10
  %300 = fadd float %297, %299
  %301 = fmul float %300, 1.250000e-01
  %302 = call float @llvm.fmuladd.f32(float %288, float 5.000000e-01, float %301)
  %303 = getelementptr inbounds nuw float, ptr %120, i64 %286
  store float %302, ptr %303, align 4, !tbaa !10
  %304 = add nuw nsw i64 %285, 1
  %305 = icmp eq i64 %304, %122
  br i1 %305, label %281, label %284, !llvm.loop !43

306:                                              ; preds = %308, %275
  %307 = call i64 @_ZNSt3__16chrono12steady_clock3nowEv() #24
  br label %314

308:                                              ; preds = %308, %275
  %309 = phi i32 [ %312, %308 ], [ 0, %275 ]
  %310 = load ptr, ptr %4, align 8, !tbaa !18
  %311 = call { ptr, ptr, i32, i32 } asm sideeffect ".inst 0xd503437f\0Abl _stencil2d5p_sme_kernel\0A.inst 0xd503427f", "={x0},={x1},={w2},={w3},{x0},{x1},{w2},{w3},~{x4},~{x5},~{x6},~{x7},~{x8},~{x9},~{x10},~{x11},~{x12},~{x13},~{x14},~{x15},~{x16},~{x17},~{memory}"(ptr nonnull %52, ptr %310, i32 range(i32 3, -2147483648) %27, i32 range(i32 3, -2147483648) %28) #24, !srcloc !44
  %312 = add nuw nsw i32 %309, 1
  %313 = icmp eq i32 %312, %29
  br i1 %313, label %306, label %308, !llvm.loop !45

314:                                              ; preds = %314, %306
  %315 = phi i32 [ 0, %306 ], [ %318, %314 ]
  %316 = load ptr, ptr %4, align 8, !tbaa !18
  %317 = call { ptr, ptr, i32, i32 } asm sideeffect ".inst 0xd503437f\0Abl _stencil2d5p_sme_kernel\0A.inst 0xd503427f", "={x0},={x1},={w2},={w3},{x0},{x1},{w2},{w3},~{x4},~{x5},~{x6},~{x7},~{x8},~{x9},~{x10},~{x11},~{x12},~{x13},~{x14},~{x15},~{x16},~{x17},~{memory}"(ptr nonnull %52, ptr %316, i32 range(i32 3, -2147483648) %27, i32 range(i32 3, -2147483648) %28) #24, !srcloc !44
  %318 = add nuw nsw i32 %315, 1
  %319 = icmp eq i32 %318, %26
  br i1 %319, label %320, label %314, !llvm.loop !46

320:                                              ; preds = %314
  %321 = call i64 @_ZNSt3__16chrono12steady_clock3nowEv() #24
  %322 = sub nsw i64 %321, %307
  %323 = sitofp i64 %322 to double
  %324 = fdiv double %323, 1.000000e+06
  %325 = uitofp nneg i32 %26 to double
  %326 = fdiv double %324, %325
  %327 = add nsw i32 %27, -2
  %328 = uitofp nneg i32 %327 to double
  %329 = add nsw i32 %28, -2
  %330 = uitofp nneg i32 %329 to double
  %331 = fmul double %328, %330
  %332 = fmul double %331, %325
  %333 = fmul double %324, 1.000000e+03
  %334 = fdiv double %332, %333
  %335 = call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.3, i32 noundef range(i32 3, -2147483648) %27, i32 noundef range(i32 3, -2147483648) %28, i32 noundef range(i32 0, -2147483648) %29, i32 noundef range(i32 1, -2147483648) %26)
  %336 = call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.4, double noundef %324, double noundef %326, double noundef %334)
  %337 = load ptr, ptr %66, align 8, !tbaa !23
  %338 = load ptr, ptr %4, align 8, !tbaa !18
  %339 = icmp eq ptr %337, %338
  br i1 %339, label %372, label %340

340:                                              ; preds = %320
  %341 = ptrtoint ptr %337 to i64
  %342 = ptrtoint ptr %338 to i64
  %343 = sub i64 %341, %342
  %344 = ashr exact i64 %343, 2
  %345 = load ptr, ptr %3, align 8, !tbaa !18
  br label %348

346:                                              ; preds = %348
  %347 = fcmp ule float %359, 0x3EB0C6F7A0000000
  br i1 %347, label %372, label %363

348:                                              ; preds = %348, %340
  %349 = phi i64 [ 0, %340 ], [ %361, %348 ]
  %350 = phi i64 [ 0, %340 ], [ %360, %348 ]
  %351 = phi float [ 0.000000e+00, %340 ], [ %359, %348 ]
  %352 = getelementptr inbounds nuw float, ptr %338, i64 %349
  %353 = load float, ptr %352, align 4, !tbaa !10
  %354 = getelementptr inbounds nuw float, ptr %345, i64 %349
  %355 = load float, ptr %354, align 4, !tbaa !10
  %356 = fsub float %353, %355
  %357 = call noundef float @llvm.fabs.f32(float %356)
  %358 = fcmp ogt float %357, %351
  %359 = select i1 %358, float %357, float %351
  %360 = select i1 %358, i64 %349, i64 %350
  %361 = add nuw i64 %349, 1
  %362 = icmp eq i64 %361, %344
  br i1 %362, label %346, label %348, !llvm.loop !47

363:                                              ; preds = %346
  %364 = fpext float %359 to double
  %365 = getelementptr inbounds nuw float, ptr %338, i64 %360
  %366 = load float, ptr %365, align 4, !tbaa !10
  %367 = fpext float %366 to double
  %368 = getelementptr inbounds nuw float, ptr %345, i64 %360
  %369 = load float, ptr %368, align 4, !tbaa !10
  %370 = fpext float %369 to double
  %371 = call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.6, double noundef %364, i64 noundef %360, double noundef %367, double noundef %370)
  br label %376

372:                                              ; preds = %346, %320
  %373 = phi float [ %359, %346 ], [ 0.000000e+00, %320 ]
  %374 = fpext float %373 to double
  %375 = call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.7, double noundef %374)
  br label %376

376:                                              ; preds = %372, %363
  %377 = phi i32 [ 0, %372 ], [ 1, %363 ]
  %378 = load ptr, ptr %4, align 8, !tbaa !18
  %379 = icmp eq ptr %378, null
  br i1 %379, label %385, label %380

380:                                              ; preds = %376
  store ptr %378, ptr %66, align 8, !tbaa !23
  %381 = load ptr, ptr %67, align 8, !tbaa !22
  %382 = ptrtoint ptr %381 to i64
  %383 = ptrtoint ptr %378 to i64
  %384 = sub i64 %382, %383
  call void @_ZdlPvm(ptr noundef nonnull %378, i64 noundef %384) #26
  br label %385

385:                                              ; preds = %380, %376
  call void @llvm.lifetime.end.p0(ptr nonnull %4) #24
  %386 = load ptr, ptr %3, align 8, !tbaa !18
  %387 = icmp eq ptr %386, null
  br i1 %387, label %409, label %388

388:                                              ; preds = %385
  store ptr %386, ptr %55, align 8, !tbaa !23
  %389 = load ptr, ptr %56, align 8, !tbaa !22
  %390 = ptrtoint ptr %389 to i64
  %391 = ptrtoint ptr %386 to i64
  %392 = sub i64 %390, %391
  call void @_ZdlPvm(ptr noundef nonnull %386, i64 noundef %392) #26
  br label %409

393:                                              ; preds = %277
  store ptr %279, ptr %66, align 8, !tbaa !23
  %394 = load ptr, ptr %67, align 8, !tbaa !22
  %395 = ptrtoint ptr %394 to i64
  %396 = ptrtoint ptr %279 to i64
  %397 = sub i64 %395, %396
  call void @_ZdlPvm(ptr noundef nonnull %279, i64 noundef %397) #26
  br label %398

398:                                              ; preds = %393, %277, %74
  %399 = phi { ptr, i32 } [ %75, %74 ], [ %278, %393 ], [ %278, %277 ]
  call void @llvm.lifetime.end.p0(ptr nonnull %4) #24
  %400 = load ptr, ptr %3, align 8, !tbaa !18
  %401 = icmp eq ptr %400, null
  br i1 %401, label %407, label %402

402:                                              ; preds = %398
  store ptr %400, ptr %55, align 8, !tbaa !23
  %403 = load ptr, ptr %56, align 8, !tbaa !22
  %404 = ptrtoint ptr %403 to i64
  %405 = ptrtoint ptr %400 to i64
  %406 = sub i64 %404, %405
  call void @_ZdlPvm(ptr noundef nonnull %400, i64 noundef %406) #26
  br label %407

407:                                              ; preds = %402, %398, %62
  %408 = phi { ptr, i32 } [ %63, %62 ], [ %399, %402 ], [ %399, %398 ]
  call void @llvm.lifetime.end.p0(ptr nonnull %3) #24
  call void @_ZdlPvm(ptr noundef nonnull %52, i64 noundef %51) #26
  resume { ptr, i32 } %408

409:                                              ; preds = %388, %385
  call void @llvm.lifetime.end.p0(ptr nonnull %3) #24
  call void @_ZdlPvm(ptr noundef nonnull %52, i64 noundef %51) #26
  br label %410

410:                                              ; preds = %409, %45, %39, %33
  %411 = phi i32 [ 1, %33 ], [ 1, %39 ], [ %377, %409 ], [ 1, %45 ]
  ret i32 %411
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(read)
declare i32 @atoi(ptr noundef captures(none)) local_unnamed_addr #5

; Function Attrs: nofree nounwind
declare noundef i32 @printf(ptr noundef readonly captures(none), ...) local_unnamed_addr #6

declare { i64, i64 } @__arm_sme_state() local_unnamed_addr

declare i32 @__gxx_personality_v0(...)

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.fmuladd.f32(float, float, float) #7

; Function Attrs: nounwind
declare i64 @_ZNSt3__16chrono12steady_clock3nowEv() local_unnamed_addr #8

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #9

; Function Attrs: mustprogress noreturn ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__16vectorIfNS_9allocatorIfEEE20__throw_length_errorB9nqe220108Ev() local_unnamed_addr #10 {
  tail call void @_ZNSt3__120__throw_length_errorB9nqe220108EPKc(ptr noundef nonnull @.str.5) #25
  unreachable
}

; Function Attrs: inlinehint mustprogress noreturn ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__120__throw_length_errorB9nqe220108EPKc(ptr noundef %0) local_unnamed_addr #11 personality ptr @__gxx_personality_v0 {
  %2 = tail call ptr @__cxa_allocate_exception(i64 16) #24
  %3 = invoke noundef ptr @_ZNSt12length_errorC1B9nqe220108EPKc(ptr noundef nonnull align 8 dereferenceable(16) %2, ptr noundef %0)
          to label %4 unwind label %5

4:                                                ; preds = %1
  tail call void @__cxa_throw(ptr nonnull %2, ptr nonnull @_ZTISt12length_error, ptr nonnull @_ZNSt12length_errorD1Ev) #25
  unreachable

5:                                                ; preds = %1
  %6 = landingpad { ptr, i32 }
          cleanup
  tail call void @__cxa_free_exception(ptr nonnull %2) #24
  resume { ptr, i32 } %6
}

declare ptr @__cxa_allocate_exception(i64) local_unnamed_addr

; Function Attrs: mustprogress ssp uwtable(sync)
define linkonce_odr hidden noundef ptr @_ZNSt12length_errorC1B9nqe220108EPKc(ptr noundef nonnull returned align 8 dereferenceable(16) %0, ptr noundef %1) unnamed_addr #12 {
  %3 = tail call noundef ptr @_ZNSt11logic_errorC2EPKc(ptr noundef nonnull align 8 dereferenceable(16) %0, ptr noundef %1)
  store ptr getelementptr inbounds nuw inrange(-16, 24) (i8, ptr @_ZTVSt12length_error, i64 16), ptr %0, align 8, !tbaa !48
  ret ptr %0
}

declare void @__cxa_free_exception(ptr) local_unnamed_addr

; Function Attrs: nounwind
declare noundef ptr @_ZNSt12length_errorD1Ev(ptr noundef nonnull returned align 8 dereferenceable(16)) unnamed_addr #8

; Function Attrs: cold noreturn
declare void @__cxa_throw(ptr, ptr, ptr) local_unnamed_addr #13

declare noundef ptr @_ZNSt11logic_errorC2EPKc(ptr noundef nonnull returned align 8 dereferenceable(16), ptr noundef) unnamed_addr #14

; Function Attrs: nobuiltin allocsize(0)
declare noundef nonnull ptr @_Znwm(i64 noundef) local_unnamed_addr #15

; Function Attrs: nobuiltin nounwind
declare void @_ZdlPvm(ptr noundef, i64 noundef) local_unnamed_addr #16

; Function Attrs: mustprogress ssp uwtable(sync)
define linkonce_odr void @_ZNSt3__16vectorIfNS_9allocatorIfEEE18__assign_with_sizeB9nqe220108INS_17_ClassicAlgPolicyEPfS6_EEvT0_T1_l(ptr noundef nonnull align 8 dereferenceable(24) %0, ptr noundef %1, ptr noundef %2, i64 noundef %3) local_unnamed_addr #12 personality ptr @__gxx_personality_v0 {
  %5 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %6 = load ptr, ptr %5, align 8, !tbaa !22
  %7 = load ptr, ptr %0, align 8, !tbaa !18
  %8 = ptrtoint ptr %6 to i64
  %9 = ptrtoint ptr %7 to i64
  %10 = sub i64 %8, %9
  %11 = ashr exact i64 %10, 2
  %12 = icmp ugt i64 %3, %11
  br i1 %12, label %32, label %13

13:                                               ; preds = %4
  %14 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %15 = load ptr, ptr %14, align 8, !tbaa !23
  %16 = ptrtoint ptr %15 to i64
  %17 = sub i64 %16, %9
  %18 = ashr exact i64 %17, 2
  %19 = icmp ugt i64 %3, %18
  br i1 %19, label %20, label %27

20:                                               ; preds = %13
  %21 = getelementptr inbounds i8, ptr %1, i64 %17
  %22 = ptrtoint ptr %21 to i64
  tail call void @llvm.memmove.p0.p0.i64(ptr align 4 %7, ptr align 4 %1, i64 %17, i1 false)
  %23 = load ptr, ptr %14, align 8, !tbaa !23
  %24 = ptrtoint ptr %2 to i64
  %25 = sub i64 %24, %22
  tail call void @llvm.memmove.p0.p0.i64(ptr align 4 %23, ptr align 4 %21, i64 %25, i1 false)
  %26 = getelementptr inbounds nuw i8, ptr %23, i64 %25
  store ptr %26, ptr %14, align 8, !tbaa !23
  br label %57

27:                                               ; preds = %13
  %28 = ptrtoint ptr %1 to i64
  %29 = ptrtoint ptr %2 to i64
  %30 = sub i64 %29, %28
  tail call void @llvm.memmove.p0.p0.i64(ptr align 4 %7, ptr align 4 %1, i64 %30, i1 false)
  %31 = getelementptr inbounds nuw i8, ptr %7, i64 %30
  store ptr %31, ptr %14, align 8, !tbaa !23
  br label %57

32:                                               ; preds = %4
  %33 = icmp eq ptr %7, null
  br i1 %33, label %36, label %34

34:                                               ; preds = %32
  %35 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store ptr %7, ptr %35, align 8, !tbaa !23
  tail call void @_ZdlPvm(ptr noundef nonnull %7, i64 noundef %10) #26
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %0, i8 0, i64 24, i1 false)
  br label %36

36:                                               ; preds = %34, %32
  %37 = phi ptr [ %6, %32 ], [ null, %34 ]
  %38 = icmp ugt i64 %3, 4611686018427387903
  br i1 %38, label %39, label %40

39:                                               ; preds = %36
  tail call void @_ZNSt3__16vectorIfNS_9allocatorIfEEE20__throw_length_errorB9nqe220108Ev() #25
  unreachable

40:                                               ; preds = %36
  %41 = ptrtoint ptr %37 to i64
  %42 = icmp ult ptr %37, inttoptr (i64 9223372036854775804 to ptr)
  %43 = ashr exact i64 %41, 1
  %44 = tail call i64 @llvm.umax.i64(i64 %43, i64 %3)
  %45 = select i1 %42, i64 %44, i64 4611686018427387903
  %46 = icmp ugt i64 %45, 4611686018427387903
  br i1 %46, label %47, label %48

47:                                               ; preds = %40
  tail call void @_ZNSt3__16vectorIfNS_9allocatorIfEEE20__throw_length_errorB9nqe220108Ev() #25
  unreachable

48:                                               ; preds = %40
  %49 = shl nuw i64 %45, 2
  %50 = tail call noalias noundef nonnull ptr @_Znwm(i64 noundef %49) #23
  store ptr %50, ptr %0, align 8, !tbaa !18
  %51 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store ptr %50, ptr %51, align 8, !tbaa !23
  %52 = getelementptr inbounds nuw float, ptr %50, i64 %45
  store ptr %52, ptr %5, align 8, !tbaa !22
  %53 = ptrtoint ptr %1 to i64
  %54 = ptrtoint ptr %2 to i64
  %55 = sub i64 %54, %53
  tail call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 4 %50, ptr align 4 %1, i64 %55, i1 false)
  %56 = getelementptr inbounds nuw i8, ptr %50, i64 %55
  store ptr %56, ptr %51, align 8, !tbaa !23
  br label %57

57:                                               ; preds = %48, %27, %20
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memmove.p0.p0.i64(ptr writeonly captures(none), ptr readonly captures(none), i64, i1 immarg) #9

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.fabs.f32(float) #7

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.vscale.i64() #2

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: read)
declare <vscale x 4 x float> @llvm.masked.load.nxv4f32.p0(ptr captures(none), <vscale x 4 x i1>, <vscale x 4 x float>) #17

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.masked.store.nxv4f32.p0(<vscale x 4 x float>, ptr captures(none), <vscale x 4 x i1>) #18

; Function Attrs: nofree nounwind
declare noundef i32 @puts(ptr noundef readonly captures(none)) local_unnamed_addr #19

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #20

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umax.i64(i64, i64) #7

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x float> @llvm.fmuladd.v4f32(<4 x float>, <4 x float>, <4 x float>) #7

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @llvm.prefetch.p0(ptr readonly captures(none), i32 immarg, i32 immarg, i32 immarg) #21

attributes #0 = { mustprogress nofree norecurse nosync nounwind ssp memory(argmem: readwrite) uwtable(sync) vscale_range(1,16) "aarch64_pstate_sm_enabled" "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bf16,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+sme,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #3 = { nocallback nofree nosync nounwind willreturn memory(none) }
attributes #4 = { mustprogress norecurse ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #5 = { mustprogress nocallback nofree nounwind willreturn memory(read) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #6 = { nofree nounwind "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #7 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #8 = { nounwind "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #9 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #10 = { mustprogress noreturn ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #11 = { inlinehint mustprogress noreturn ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #12 = { mustprogress ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #13 = { cold noreturn }
attributes #14 = { "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #15 = { nobuiltin allocsize(0) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #16 = { nobuiltin nounwind "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #17 = { nocallback nofree nosync nounwind willreturn memory(argmem: read) }
attributes #18 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
attributes #19 = { nofree nounwind }
attributes #20 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #21 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite) }
attributes #22 = { "aarch64_pstate_sm_compatible" }
attributes #23 = { builtin allocsize(0) }
attributes #24 = { nounwind }
attributes #25 = { noreturn }
attributes #26 = { builtin nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}
!llvm.errno.tbaa = !{!6}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 4}
!5 = !{!"clang version 22.1.8 (https://github.com/llvm/llvm-project ca7933e47d3a3451d81e72ac174dcb5aa28b59d1)"}
!6 = !{!7, !7, i64 0}
!7 = !{!"int", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C++ TBAA"}
!10 = !{!11, !11, i64 0}
!11 = !{!"float", !8, i64 0}
!12 = distinct !{!12, !13}
!13 = !{!"llvm.loop.mustprogress"}
!14 = distinct !{!14, !13}
!15 = !{!16, !16, i64 0}
!16 = !{!"p1 omnipotent char", !17, i64 0}
!17 = !{!"any pointer", !8, i64 0}
!18 = !{!19, !20, i64 0}
!19 = !{!"_ZTSNSt3__16vectorIfNS_9allocatorIfEEEE", !20, i64 0, !20, i64 8, !21, i64 16}
!20 = !{!"p1 float", !17, i64 0}
!21 = !{!"_ZTSNSt3__16vectorIfNS_9allocatorIfEEEUt_E", !20, i64 0}
!22 = !{!19, !20, i64 16}
!23 = !{!19, !20, i64 8}
!24 = distinct !{!24, !13, !25, !26}
!25 = !{!"llvm.loop.isvectorized", i32 1}
!26 = !{!"llvm.loop.unroll.runtime.disable"}
!27 = distinct !{!27, !13}
!28 = distinct !{!28, !13, !26, !25}
!29 = !{!30}
!30 = distinct !{!30, !31}
!31 = distinct !{!31, !"LVerDomain"}
!32 = !{!33}
!33 = distinct !{!33, !31}
!34 = !{!35}
!35 = distinct !{!35, !31}
!36 = !{!37}
!37 = distinct !{!37, !31}
!38 = !{!35, !33, !30}
!39 = distinct !{!39, !13, !25, !26}
!40 = !{!"branch_weights", i32 4, i32 12}
!41 = distinct !{!41, !13, !25, !26}
!42 = distinct !{!42, !13}
!43 = distinct !{!43, !13, !25}
!44 = !{i64 2433, i64 2478, i64 2517}
!45 = distinct !{!45, !13}
!46 = distinct !{!46, !13}
!47 = distinct !{!47, !13}
!48 = !{!49, !49, i64 0}
!49 = !{!"vtable pointer", !9, i64 0}
