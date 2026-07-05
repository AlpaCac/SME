; ModuleID = 'stencil_sme.cpp'
source_filename = "stencil_sme.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%"class.std::__1::vector" = type { ptr, ptr, %struct.anon }
%struct.anon = type { ptr }

@.str.2 = private unnamed_addr constant [7 x i8] c"vector\00", align 1
@_ZTISt12length_error = external constant ptr
@_ZTVSt12length_error = external unnamed_addr constant { [5 x ptr] }, align 8
@.str.3 = private unnamed_addr constant [48 x i8] c"FAILED: max_diff=%g idx=%zu got=%g expected=%g\0A\00", align 1
@.str.4 = private unnamed_addr constant [21 x i8] c"PASSED: max_diff=%g\0A\00", align 1
@str = private unnamed_addr constant [33 x i8] c"SME is not available on this CPU\00", align 1
@str.5 = private unnamed_addr constant [23 x i8] c"nx and ny must be >= 3\00", align 1

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

17:                                               ; preds = %6, %45
  %18 = phi i64 [ 1, %6 ], [ %46, %45 ]
  br i1 %11, label %19, label %45

19:                                               ; preds = %17
  %20 = mul nuw nsw i64 %18, %9
  %21 = getelementptr inbounds nuw float, ptr %0, i64 %20
  %22 = getelementptr inbounds nuw float, ptr %1, i64 %20
  br label %23

23:                                               ; preds = %19, %23
  %24 = phi i64 [ 1, %19 ], [ %43, %23 ]
  %25 = trunc nuw nsw i64 %24 to i32
  %26 = tail call <vscale x 4 x i1> @llvm.aarch64.sve.whilelt.nxv4i1.i32(i32 %25, i32 %10)
  %27 = getelementptr inbounds nuw float, ptr %21, i64 %24
  %28 = tail call <vscale x 4 x float> @llvm.masked.load.nxv4f32.p0(ptr nonnull align 1 %27, <vscale x 4 x i1> %26, <vscale x 4 x float> zeroinitializer), !tbaa !10
  %29 = getelementptr inbounds i8, ptr %27, i64 -4
  %30 = tail call <vscale x 4 x float> @llvm.masked.load.nxv4f32.p0(ptr nonnull align 1 %29, <vscale x 4 x i1> %26, <vscale x 4 x float> zeroinitializer), !tbaa !10
  %31 = getelementptr inbounds nuw i8, ptr %27, i64 4
  %32 = tail call <vscale x 4 x float> @llvm.masked.load.nxv4f32.p0(ptr nonnull align 1 %31, <vscale x 4 x i1> %26, <vscale x 4 x float> zeroinitializer), !tbaa !10
  %33 = getelementptr inbounds float, ptr %27, i64 %12
  %34 = tail call <vscale x 4 x float> @llvm.masked.load.nxv4f32.p0(ptr nonnull align 1 %33, <vscale x 4 x i1> %26, <vscale x 4 x float> zeroinitializer), !tbaa !10
  %35 = getelementptr inbounds nuw float, ptr %27, i64 %9
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

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <vscale x 4 x i1> @llvm.aarch64.sve.whilelt.nxv4i1.i32(i32, i32) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <vscale x 4 x float> @llvm.aarch64.sve.fadd.nxv4f32(<vscale x 4 x i1>, <vscale x 4 x float>, <vscale x 4 x float>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <vscale x 4 x float> @llvm.aarch64.sve.fmul.nxv4f32(<vscale x 4 x i1>, <vscale x 4 x float>, <vscale x 4 x float>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(none)
declare <vscale x 4 x float> @llvm.aarch64.sve.fmla.nxv4f32(<vscale x 4 x i1>, <vscale x 4 x float>, <vscale x 4 x float>, <vscale x 4 x float>) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #1

; Function Attrs: mustprogress norecurse ssp uwtable(sync)
define noundef range(i32 0, 2) i32 @main(i32 noundef %0, ptr noundef readonly captures(none) %1) local_unnamed_addr #4 personality ptr @__gxx_personality_v0 {
  %3 = alloca %"class.std::__1::vector", align 8
  %4 = alloca %"class.std::__1::vector", align 8
  %5 = icmp sgt i32 %0, 1
  br i1 %5, label %6, label %15

6:                                                ; preds = %2
  %7 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %8 = load ptr, ptr %7, align 8, !tbaa !15
  %9 = tail call i32 @atoi(ptr noundef %8)
  %10 = icmp eq i32 %0, 2
  br i1 %10, label %15, label %11

11:                                               ; preds = %6
  %12 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %13 = load ptr, ptr %12, align 8, !tbaa !15
  %14 = tail call i32 @atoi(ptr noundef %13)
  br label %15

15:                                               ; preds = %2, %6, %11
  %16 = phi i32 [ %9, %11 ], [ %9, %6 ], [ 256, %2 ]
  %17 = phi i32 [ %14, %11 ], [ 256, %6 ], [ 256, %2 ]
  %18 = icmp slt i32 %16, 3
  %19 = icmp slt i32 %17, 3
  %20 = select i1 %18, i1 true, i1 %19
  br i1 %20, label %21, label %23

21:                                               ; preds = %15
  %22 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.5)
  br label %362

23:                                               ; preds = %15
  %24 = tail call aarch64_sme_preservemost_from_x2 { i64, i64 } @__arm_sme_state() #24
  %25 = extractvalue { i64, i64 } %24, 0
  %26 = icmp slt i64 %25, 0
  br i1 %26, label %29, label %27

27:                                               ; preds = %23
  %28 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str)
  br label %362

29:                                               ; preds = %23
  %30 = zext nneg i32 %16 to i64
  %31 = zext nneg i32 %17 to i64
  %32 = shl nuw nsw i64 %30, 2
  %33 = mul nuw i64 %32, %31
  %34 = tail call noalias noundef nonnull ptr @_Znwm(i64 noundef %33) #25
  %35 = getelementptr i8, ptr %34, i64 %33
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(1) %34, i8 0, i64 %33, i1 false), !tbaa !10
  call void @llvm.lifetime.start.p0(ptr nonnull %3) #26
  %36 = ashr exact i64 %33, 2
  %37 = getelementptr inbounds nuw i8, ptr %3, i64 8
  %38 = getelementptr inbounds nuw i8, ptr %3, i64 16
  %39 = icmp ugt i64 %36, 4611686018427387903
  br i1 %39, label %40, label %42

40:                                               ; preds = %29
  invoke void @_ZNSt3__16vectorIfNS_9allocatorIfEEE20__throw_length_errorB9nqe220108Ev() #27
          to label %41 unwind label %44

41:                                               ; preds = %40
  unreachable

42:                                               ; preds = %29
  %43 = invoke noalias noundef nonnull ptr @_Znwm(i64 noundef %33) #25
          to label %46 unwind label %44

44:                                               ; preds = %42, %40
  %45 = landingpad { ptr, i32 }
          cleanup
  br label %359

46:                                               ; preds = %42
  store ptr %43, ptr %3, align 8, !tbaa !18
  %47 = getelementptr i8, ptr %43, i64 %33
  store ptr %47, ptr %38, align 8, !tbaa !22
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(1) %43, i8 0, i64 %33, i1 false), !tbaa !10
  store ptr %47, ptr %37, align 8, !tbaa !23
  call void @llvm.lifetime.start.p0(ptr nonnull %4) #26
  %48 = getelementptr inbounds nuw i8, ptr %4, i64 8
  %49 = getelementptr inbounds nuw i8, ptr %4, i64 16
  %50 = invoke noalias noundef nonnull ptr @_Znwm(i64 noundef %33) #25
          to label %51 unwind label %56

51:                                               ; preds = %46
  store ptr %50, ptr %4, align 8, !tbaa !18
  %52 = getelementptr i8, ptr %50, i64 %33
  store ptr %52, ptr %49, align 8, !tbaa !22
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(1) %50, i8 0, i64 %33, i1 false), !tbaa !10
  store ptr %52, ptr %48, align 8, !tbaa !23
  %53 = icmp ult i32 %16, 4
  %54 = and i64 %30, 2147483644
  %55 = icmp eq i64 %54, %30
  br label %58

56:                                               ; preds = %46
  %57 = landingpad { ptr, i32 }
          cleanup
  br label %350

58:                                               ; preds = %83, %51
  %59 = phi i64 [ 0, %51 ], [ %84, %83 ]
  %60 = mul nuw nsw i64 %59, 7
  %61 = mul nuw nsw i64 %59, %30
  %62 = getelementptr inbounds nuw float, ptr %34, i64 %61
  br i1 %53, label %80, label %63

63:                                               ; preds = %58
  %64 = insertelement <4 x i64> poison, i64 %60, i64 0
  %65 = shufflevector <4 x i64> %64, <4 x i64> poison, <4 x i32> zeroinitializer
  br label %66

66:                                               ; preds = %66, %63
  %67 = phi i64 [ 0, %63 ], [ %76, %66 ]
  %68 = phi <4 x i64> [ <i64 0, i64 1, i64 2, i64 3>, %63 ], [ %77, %66 ]
  %69 = mul nuw nsw <4 x i64> %68, splat (i64 13)
  %70 = add nuw nsw <4 x i64> %69, %65
  %71 = trunc nuw <4 x i64> %70 to <4 x i32>
  %72 = urem <4 x i32> %71, splat (i32 97)
  %73 = uitofp nneg <4 x i32> %72 to <4 x float>
  %74 = fmul <4 x float> %73, splat (float 0x3F847AE140000000)
  %75 = getelementptr inbounds nuw float, ptr %62, i64 %67
  store <4 x float> %74, ptr %75, align 4, !tbaa !10
  %76 = add nuw i64 %67, 4
  %77 = add nuw nsw <4 x i64> %68, splat (i64 4)
  %78 = icmp eq i64 %76, %54
  br i1 %78, label %79, label %66, !llvm.loop !24

79:                                               ; preds = %66
  br i1 %55, label %83, label %80

80:                                               ; preds = %58, %79
  %81 = phi i64 [ 0, %58 ], [ %54, %79 ]
  br label %86

82:                                               ; preds = %83
  invoke void @_ZNSt3__16vectorIfNS_9allocatorIfEEE18__assign_with_sizeB9nqe220108INS_17_ClassicAlgPolicyEPfS6_EEvT0_T1_l(ptr noundef nonnull align 8 dereferenceable(24) %3, ptr noundef nonnull %34, ptr noundef %35, i64 noundef %36)
          to label %97 unwind label %299

83:                                               ; preds = %86, %79
  %84 = add nuw nsw i64 %59, 1
  %85 = icmp eq i64 %84, %31
  br i1 %85, label %82, label %58, !llvm.loop !27

86:                                               ; preds = %80, %86
  %87 = phi i64 [ %95, %86 ], [ %81, %80 ]
  %88 = mul nuw nsw i64 %87, 13
  %89 = add nuw nsw i64 %88, %60
  %90 = trunc nuw i64 %89 to i32
  %91 = urem i32 %90, 97
  %92 = uitofp nneg i32 %91 to float
  %93 = fmul float %92, 0x3F847AE140000000
  %94 = getelementptr inbounds nuw float, ptr %62, i64 %87
  store float %93, ptr %94, align 4, !tbaa !10
  %95 = add nuw nsw i64 %87, 1
  %96 = icmp eq i64 %95, %30
  br i1 %96, label %83, label %86, !llvm.loop !28

97:                                               ; preds = %82
  invoke void @_ZNSt3__16vectorIfNS_9allocatorIfEEE18__assign_with_sizeB9nqe220108INS_17_ClassicAlgPolicyEPfS6_EEvT0_T1_l(ptr noundef nonnull align 8 dereferenceable(24) %4, ptr noundef nonnull %34, ptr noundef %35, i64 noundef %36)
          to label %98 unwind label %299

98:                                               ; preds = %97
  %99 = add nsw i32 %17, -1
  %100 = add nsw i32 %16, -1
  %101 = getelementptr float, ptr %34, i64 %30
  %102 = load ptr, ptr %3, align 8
  %103 = zext i32 %99 to i64
  %104 = zext i32 %100 to i64
  %105 = getelementptr nuw i8, ptr %102, i64 %32
  %106 = getelementptr nuw i8, ptr %105, i64 4
  %107 = shl nuw nsw i64 %103, 2
  %108 = add nsw i64 %107, -4
  %109 = mul i64 %108, %30
  %110 = shl nuw nsw i64 %104, 2
  %111 = getelementptr i8, ptr %102, i64 %109
  %112 = getelementptr i8, ptr %111, i64 %110
  %113 = shl nuw nsw i64 %30, 3
  %114 = getelementptr i8, ptr %34, i64 %113
  %115 = getelementptr i8, ptr %114, i64 4
  %116 = mul nuw nsw i64 %30, %103
  %117 = add nuw i64 %116, %104
  %118 = shl i64 %117, 2
  %119 = getelementptr i8, ptr %34, i64 %118
  %120 = getelementptr i8, ptr %34, i64 4
  %121 = add nuw nsw i64 %103, 4611686018427387902
  %122 = mul i64 %121, %30
  %123 = add i64 %122, %104
  %124 = shl i64 %123, 2
  %125 = getelementptr i8, ptr %34, i64 %124
  %126 = getelementptr i8, ptr %34, i64 %109
  %127 = getelementptr i8, ptr %126, i64 %110
  %128 = getelementptr i8, ptr %127, i64 4
  %129 = add nsw i64 %104, -1
  %130 = icmp ult i64 %129, 4
  %131 = icmp ult ptr %106, %119
  %132 = icmp ult ptr %115, %112
  %133 = and i1 %131, %132
  %134 = icmp ult ptr %106, %125
  %135 = icmp ult ptr %120, %112
  %136 = and i1 %134, %135
  %137 = or i1 %133, %136
  %138 = icmp ult ptr %106, %128
  %139 = icmp ult ptr %101, %112
  %140 = and i1 %138, %139
  %141 = or i1 %137, %140
  %142 = icmp ult i64 %129, 16
  %143 = and i64 %129, 12
  %144 = and i64 %129, -16
  %145 = icmp eq i64 %129, %144
  %146 = or disjoint i64 %144, 1
  %147 = icmp eq i64 %143, 0
  %148 = and i64 %129, -4
  %149 = or disjoint i64 %148, 1
  %150 = icmp eq i64 %129, %148
  br label %151

151:                                              ; preds = %303, %98
  %152 = phi i64 [ 1, %98 ], [ %304, %303 ]
  %153 = mul nuw nsw i64 %152, %30
  %154 = select i1 %130, i1 true, i1 %141
  br i1 %154, label %255, label %155

155:                                              ; preds = %151
  br i1 %142, label %229, label %156

156:                                              ; preds = %155, %156
  %157 = phi i64 [ %225, %156 ], [ 0, %155 ]
  %158 = or disjoint i64 %157, 1
  %159 = add nuw nsw i64 %158, %153
  %160 = getelementptr float, ptr %34, i64 %159
  %161 = getelementptr i8, ptr %160, i64 16
  %162 = getelementptr i8, ptr %160, i64 32
  %163 = getelementptr i8, ptr %160, i64 48
  %164 = load <4 x float>, ptr %160, align 4, !tbaa !10, !alias.scope !29
  %165 = load <4 x float>, ptr %161, align 4, !tbaa !10, !alias.scope !29
  %166 = load <4 x float>, ptr %162, align 4, !tbaa !10, !alias.scope !29
  %167 = load <4 x float>, ptr %163, align 4, !tbaa !10, !alias.scope !29
  %168 = getelementptr i8, ptr %160, i64 -4
  %169 = getelementptr i8, ptr %160, i64 12
  %170 = getelementptr i8, ptr %160, i64 28
  %171 = getelementptr i8, ptr %160, i64 44
  %172 = load <4 x float>, ptr %168, align 4, !tbaa !10, !alias.scope !29
  %173 = load <4 x float>, ptr %169, align 4, !tbaa !10, !alias.scope !29
  %174 = load <4 x float>, ptr %170, align 4, !tbaa !10, !alias.scope !29
  %175 = load <4 x float>, ptr %171, align 4, !tbaa !10, !alias.scope !29
  %176 = getelementptr inbounds nuw i8, ptr %160, i64 4
  %177 = getelementptr inbounds nuw i8, ptr %160, i64 20
  %178 = getelementptr inbounds nuw i8, ptr %160, i64 36
  %179 = getelementptr inbounds nuw i8, ptr %160, i64 52
  %180 = load <4 x float>, ptr %176, align 4, !tbaa !10, !alias.scope !29
  %181 = load <4 x float>, ptr %177, align 4, !tbaa !10, !alias.scope !29
  %182 = load <4 x float>, ptr %178, align 4, !tbaa !10, !alias.scope !29
  %183 = load <4 x float>, ptr %179, align 4, !tbaa !10, !alias.scope !29
  %184 = fadd <4 x float> %172, %180
  %185 = fadd <4 x float> %173, %181
  %186 = fadd <4 x float> %174, %182
  %187 = fadd <4 x float> %175, %183
  %188 = sub nuw nsw i64 %159, %30
  %189 = getelementptr inbounds nuw float, ptr %34, i64 %188
  %190 = getelementptr inbounds nuw i8, ptr %189, i64 16
  %191 = getelementptr inbounds nuw i8, ptr %189, i64 32
  %192 = getelementptr inbounds nuw i8, ptr %189, i64 48
  %193 = load <4 x float>, ptr %189, align 4, !tbaa !10, !alias.scope !32
  %194 = load <4 x float>, ptr %190, align 4, !tbaa !10, !alias.scope !32
  %195 = load <4 x float>, ptr %191, align 4, !tbaa !10, !alias.scope !32
  %196 = load <4 x float>, ptr %192, align 4, !tbaa !10, !alias.scope !32
  %197 = fadd <4 x float> %184, %193
  %198 = fadd <4 x float> %185, %194
  %199 = fadd <4 x float> %186, %195
  %200 = fadd <4 x float> %187, %196
  %201 = getelementptr inbounds nuw float, ptr %101, i64 %159
  %202 = getelementptr inbounds nuw i8, ptr %201, i64 16
  %203 = getelementptr inbounds nuw i8, ptr %201, i64 32
  %204 = getelementptr inbounds nuw i8, ptr %201, i64 48
  %205 = load <4 x float>, ptr %201, align 4, !tbaa !10, !alias.scope !34
  %206 = load <4 x float>, ptr %202, align 4, !tbaa !10, !alias.scope !34
  %207 = load <4 x float>, ptr %203, align 4, !tbaa !10, !alias.scope !34
  %208 = load <4 x float>, ptr %204, align 4, !tbaa !10, !alias.scope !34
  %209 = fadd <4 x float> %197, %205
  %210 = fadd <4 x float> %198, %206
  %211 = fadd <4 x float> %199, %207
  %212 = fadd <4 x float> %200, %208
  %213 = fmul <4 x float> %209, splat (float 1.250000e-01)
  %214 = fmul <4 x float> %210, splat (float 1.250000e-01)
  %215 = fmul <4 x float> %211, splat (float 1.250000e-01)
  %216 = fmul <4 x float> %212, splat (float 1.250000e-01)
  %217 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %164, <4 x float> splat (float 5.000000e-01), <4 x float> %213)
  %218 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %165, <4 x float> splat (float 5.000000e-01), <4 x float> %214)
  %219 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %166, <4 x float> splat (float 5.000000e-01), <4 x float> %215)
  %220 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %167, <4 x float> splat (float 5.000000e-01), <4 x float> %216)
  %221 = getelementptr inbounds nuw float, ptr %102, i64 %159
  %222 = getelementptr inbounds nuw i8, ptr %221, i64 16
  %223 = getelementptr inbounds nuw i8, ptr %221, i64 32
  %224 = getelementptr inbounds nuw i8, ptr %221, i64 48
  store <4 x float> %217, ptr %221, align 4, !tbaa !10, !alias.scope !36, !noalias !38
  store <4 x float> %218, ptr %222, align 4, !tbaa !10, !alias.scope !36, !noalias !38
  store <4 x float> %219, ptr %223, align 4, !tbaa !10, !alias.scope !36, !noalias !38
  store <4 x float> %220, ptr %224, align 4, !tbaa !10, !alias.scope !36, !noalias !38
  %225 = add nuw i64 %157, 16
  %226 = icmp eq i64 %225, %144
  br i1 %226, label %227, label %156, !llvm.loop !39

227:                                              ; preds = %156
  br i1 %145, label %303, label %228

228:                                              ; preds = %227
  br i1 %147, label %255, label %229, !prof !40

229:                                              ; preds = %155, %228
  %230 = phi i64 [ %144, %228 ], [ 0, %155 ]
  br label %231

231:                                              ; preds = %231, %229
  %232 = phi i64 [ %230, %229 ], [ %252, %231 ]
  %233 = or disjoint i64 %232, 1
  %234 = add nuw nsw i64 %233, %153
  %235 = getelementptr float, ptr %34, i64 %234
  %236 = load <4 x float>, ptr %235, align 4, !tbaa !10, !alias.scope !29
  %237 = getelementptr i8, ptr %235, i64 -4
  %238 = load <4 x float>, ptr %237, align 4, !tbaa !10, !alias.scope !29
  %239 = getelementptr inbounds nuw i8, ptr %235, i64 4
  %240 = load <4 x float>, ptr %239, align 4, !tbaa !10, !alias.scope !29
  %241 = fadd <4 x float> %238, %240
  %242 = sub nuw nsw i64 %234, %30
  %243 = getelementptr inbounds nuw float, ptr %34, i64 %242
  %244 = load <4 x float>, ptr %243, align 4, !tbaa !10, !alias.scope !32
  %245 = fadd <4 x float> %241, %244
  %246 = getelementptr inbounds nuw float, ptr %101, i64 %234
  %247 = load <4 x float>, ptr %246, align 4, !tbaa !10, !alias.scope !34
  %248 = fadd <4 x float> %245, %247
  %249 = fmul <4 x float> %248, splat (float 1.250000e-01)
  %250 = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %236, <4 x float> splat (float 5.000000e-01), <4 x float> %249)
  %251 = getelementptr inbounds nuw float, ptr %102, i64 %234
  store <4 x float> %250, ptr %251, align 4, !tbaa !10, !alias.scope !36, !noalias !38
  %252 = add nuw i64 %232, 4
  %253 = icmp eq i64 %252, %148
  br i1 %253, label %254, label %231, !llvm.loop !41

254:                                              ; preds = %231
  br i1 %150, label %303, label %255

255:                                              ; preds = %151, %228, %254
  %256 = phi i64 [ 1, %151 ], [ %149, %254 ], [ %146, %228 ]
  br label %306

257:                                              ; preds = %303
  %258 = load ptr, ptr %4, align 8, !tbaa !18
  %259 = call { ptr, ptr, i32, i32 } asm sideeffect ".inst 0xd503437f\0Abl _stencil2d5p_sme_kernel\0A.inst 0xd503427f", "={x0},={x1},={w2},={w3},{x0},{x1},{w2},{w3},~{x4},~{x5},~{x6},~{x7},~{x8},~{x9},~{x10},~{x11},~{x12},~{x13},~{x14},~{x15},~{x16},~{x17},~{memory}"(ptr nonnull %34, ptr %258, i32 range(i32 3, -2147483648) %16, i32 range(i32 3, -2147483648) %17) #26, !srcloc !42
  %260 = load ptr, ptr %48, align 8, !tbaa !23
  %261 = load ptr, ptr %4, align 8, !tbaa !18
  %262 = icmp eq ptr %260, %261
  br i1 %262, label %295, label %263

263:                                              ; preds = %257
  %264 = ptrtoint ptr %260 to i64
  %265 = ptrtoint ptr %261 to i64
  %266 = sub i64 %264, %265
  %267 = ashr exact i64 %266, 2
  %268 = load ptr, ptr %3, align 8, !tbaa !18
  br label %271

269:                                              ; preds = %271
  %270 = fcmp ule float %282, 0x3EB0C6F7A0000000
  br i1 %270, label %295, label %286

271:                                              ; preds = %271, %263
  %272 = phi i64 [ 0, %263 ], [ %284, %271 ]
  %273 = phi i64 [ 0, %263 ], [ %283, %271 ]
  %274 = phi float [ 0.000000e+00, %263 ], [ %282, %271 ]
  %275 = getelementptr inbounds nuw float, ptr %261, i64 %272
  %276 = load float, ptr %275, align 4, !tbaa !10
  %277 = getelementptr inbounds nuw float, ptr %268, i64 %272
  %278 = load float, ptr %277, align 4, !tbaa !10
  %279 = fsub float %276, %278
  %280 = call noundef float @llvm.fabs.f32(float %279)
  %281 = fcmp ogt float %280, %274
  %282 = select i1 %281, float %280, float %274
  %283 = select i1 %281, i64 %272, i64 %273
  %284 = add nuw i64 %272, 1
  %285 = icmp eq i64 %284, %267
  br i1 %285, label %269, label %271, !llvm.loop !43

286:                                              ; preds = %269
  %287 = fpext float %282 to double
  %288 = getelementptr inbounds nuw float, ptr %261, i64 %283
  %289 = load float, ptr %288, align 4, !tbaa !10
  %290 = fpext float %289 to double
  %291 = getelementptr inbounds nuw float, ptr %268, i64 %283
  %292 = load float, ptr %291, align 4, !tbaa !10
  %293 = fpext float %292 to double
  %294 = call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.3, double noundef %287, i64 noundef %283, double noundef %290, double noundef %293)
  br label %328

295:                                              ; preds = %269, %257
  %296 = phi float [ %282, %269 ], [ 0.000000e+00, %257 ]
  %297 = fpext float %296 to double
  %298 = call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.4, double noundef %297)
  br label %328

299:                                              ; preds = %97, %82
  %300 = landingpad { ptr, i32 }
          cleanup
  %301 = load ptr, ptr %4, align 8, !tbaa !18
  %302 = icmp eq ptr %301, null
  br i1 %302, label %350, label %345

303:                                              ; preds = %306, %254, %227
  %304 = add nuw nsw i64 %152, 1
  %305 = icmp eq i64 %304, %103
  br i1 %305, label %257, label %151, !llvm.loop !44

306:                                              ; preds = %255, %306
  %307 = phi i64 [ %326, %306 ], [ %256, %255 ]
  %308 = add nuw nsw i64 %307, %153
  %309 = getelementptr float, ptr %34, i64 %308
  %310 = load float, ptr %309, align 4, !tbaa !10
  %311 = getelementptr i8, ptr %309, i64 -4
  %312 = load float, ptr %311, align 4, !tbaa !10
  %313 = getelementptr inbounds nuw i8, ptr %309, i64 4
  %314 = load float, ptr %313, align 4, !tbaa !10
  %315 = fadd float %312, %314
  %316 = sub nuw nsw i64 %308, %30
  %317 = getelementptr inbounds nuw float, ptr %34, i64 %316
  %318 = load float, ptr %317, align 4, !tbaa !10
  %319 = fadd float %315, %318
  %320 = getelementptr inbounds nuw float, ptr %101, i64 %308
  %321 = load float, ptr %320, align 4, !tbaa !10
  %322 = fadd float %319, %321
  %323 = fmul float %322, 1.250000e-01
  %324 = call float @llvm.fmuladd.f32(float %310, float 5.000000e-01, float %323)
  %325 = getelementptr inbounds nuw float, ptr %102, i64 %308
  store float %324, ptr %325, align 4, !tbaa !10
  %326 = add nuw nsw i64 %307, 1
  %327 = icmp eq i64 %326, %104
  br i1 %327, label %303, label %306, !llvm.loop !45

328:                                              ; preds = %295, %286
  %329 = phi i32 [ 0, %295 ], [ 1, %286 ]
  %330 = load ptr, ptr %4, align 8, !tbaa !18
  %331 = icmp eq ptr %330, null
  br i1 %331, label %337, label %332

332:                                              ; preds = %328
  store ptr %330, ptr %48, align 8, !tbaa !23
  %333 = load ptr, ptr %49, align 8, !tbaa !22
  %334 = ptrtoint ptr %333 to i64
  %335 = ptrtoint ptr %330 to i64
  %336 = sub i64 %334, %335
  call void @_ZdlPvm(ptr noundef nonnull %330, i64 noundef %336) #28
  br label %337

337:                                              ; preds = %332, %328
  call void @llvm.lifetime.end.p0(ptr nonnull %4) #26
  %338 = load ptr, ptr %3, align 8, !tbaa !18
  %339 = icmp eq ptr %338, null
  br i1 %339, label %361, label %340

340:                                              ; preds = %337
  store ptr %338, ptr %37, align 8, !tbaa !23
  %341 = load ptr, ptr %38, align 8, !tbaa !22
  %342 = ptrtoint ptr %341 to i64
  %343 = ptrtoint ptr %338 to i64
  %344 = sub i64 %342, %343
  call void @_ZdlPvm(ptr noundef nonnull %338, i64 noundef %344) #28
  br label %361

345:                                              ; preds = %299
  store ptr %301, ptr %48, align 8, !tbaa !23
  %346 = load ptr, ptr %49, align 8, !tbaa !22
  %347 = ptrtoint ptr %346 to i64
  %348 = ptrtoint ptr %301 to i64
  %349 = sub i64 %347, %348
  call void @_ZdlPvm(ptr noundef nonnull %301, i64 noundef %349) #28
  br label %350

350:                                              ; preds = %345, %299, %56
  %351 = phi { ptr, i32 } [ %57, %56 ], [ %300, %345 ], [ %300, %299 ]
  call void @llvm.lifetime.end.p0(ptr nonnull %4) #26
  %352 = load ptr, ptr %3, align 8, !tbaa !18
  %353 = icmp eq ptr %352, null
  br i1 %353, label %359, label %354

354:                                              ; preds = %350
  store ptr %352, ptr %37, align 8, !tbaa !23
  %355 = load ptr, ptr %38, align 8, !tbaa !22
  %356 = ptrtoint ptr %355 to i64
  %357 = ptrtoint ptr %352 to i64
  %358 = sub i64 %356, %357
  call void @_ZdlPvm(ptr noundef nonnull %352, i64 noundef %358) #28
  br label %359

359:                                              ; preds = %354, %350, %44
  %360 = phi { ptr, i32 } [ %45, %44 ], [ %351, %354 ], [ %351, %350 ]
  call void @llvm.lifetime.end.p0(ptr nonnull %3) #26
  call void @_ZdlPvm(ptr noundef nonnull %34, i64 noundef %33) #28
  resume { ptr, i32 } %360

361:                                              ; preds = %337, %340
  call void @llvm.lifetime.end.p0(ptr nonnull %3) #26
  call void @_ZdlPvm(ptr noundef nonnull %34, i64 noundef %33) #28
  br label %362

362:                                              ; preds = %361, %27, %21
  %363 = phi i32 [ 1, %21 ], [ %329, %361 ], [ 1, %27 ]
  ret i32 %363
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(read)
declare i32 @atoi(ptr noundef captures(none)) local_unnamed_addr #5

; Function Attrs: nofree nounwind
declare noundef i32 @printf(ptr noundef readonly captures(none), ...) local_unnamed_addr #6

declare { i64, i64 } @__arm_sme_state() local_unnamed_addr

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.fmuladd.f32(float, float, float) #7

; Function Attrs: mustprogress noreturn ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__16vectorIfNS_9allocatorIfEEE20__throw_length_errorB9nqe220108Ev() local_unnamed_addr #8 {
  tail call void @_ZNSt3__120__throw_length_errorB9nqe220108EPKc(ptr noundef nonnull @.str.2) #27
  unreachable
}

; Function Attrs: inlinehint mustprogress noreturn ssp uwtable(sync)
define linkonce_odr hidden void @_ZNSt3__120__throw_length_errorB9nqe220108EPKc(ptr noundef %0) local_unnamed_addr #9 personality ptr @__gxx_personality_v0 {
  %2 = tail call ptr @__cxa_allocate_exception(i64 16) #26
  %3 = invoke noundef ptr @_ZNSt12length_errorC1B9nqe220108EPKc(ptr noundef nonnull align 8 dereferenceable(16) %2, ptr noundef %0)
          to label %4 unwind label %5

4:                                                ; preds = %1
  tail call void @__cxa_throw(ptr nonnull %2, ptr nonnull @_ZTISt12length_error, ptr nonnull @_ZNSt12length_errorD1Ev) #27
  unreachable

5:                                                ; preds = %1
  %6 = landingpad { ptr, i32 }
          cleanup
  tail call void @__cxa_free_exception(ptr nonnull %2) #26
  resume { ptr, i32 } %6
}

declare ptr @__cxa_allocate_exception(i64) local_unnamed_addr

; Function Attrs: mustprogress ssp uwtable(sync)
define linkonce_odr hidden noundef ptr @_ZNSt12length_errorC1B9nqe220108EPKc(ptr noundef nonnull returned align 8 dereferenceable(16) %0, ptr noundef %1) unnamed_addr #10 {
  %3 = tail call noundef ptr @_ZNSt11logic_errorC2EPKc(ptr noundef nonnull align 8 dereferenceable(16) %0, ptr noundef %1)
  store ptr getelementptr inbounds nuw inrange(-16, 24) (i8, ptr @_ZTVSt12length_error, i64 16), ptr %0, align 8, !tbaa !46
  ret ptr %0
}

declare void @__cxa_free_exception(ptr) local_unnamed_addr

; Function Attrs: nounwind
declare noundef ptr @_ZNSt12length_errorD1Ev(ptr noundef nonnull returned align 8 dereferenceable(16)) unnamed_addr #11

; Function Attrs: cold noreturn
declare void @__cxa_throw(ptr, ptr, ptr) local_unnamed_addr #12

declare noundef ptr @_ZNSt11logic_errorC2EPKc(ptr noundef nonnull returned align 8 dereferenceable(16), ptr noundef) unnamed_addr #13

; Function Attrs: nobuiltin allocsize(0)
declare noundef nonnull ptr @_Znwm(i64 noundef) local_unnamed_addr #14

; Function Attrs: nobuiltin nounwind
declare void @_ZdlPvm(ptr noundef, i64 noundef) local_unnamed_addr #15

; Function Attrs: mustprogress ssp uwtable(sync)
define linkonce_odr void @_ZNSt3__16vectorIfNS_9allocatorIfEEE18__assign_with_sizeB9nqe220108INS_17_ClassicAlgPolicyEPfS6_EEvT0_T1_l(ptr noundef nonnull align 8 dereferenceable(24) %0, ptr noundef %1, ptr noundef %2, i64 noundef %3) local_unnamed_addr #10 personality ptr @__gxx_personality_v0 {
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
  tail call void @_ZdlPvm(ptr noundef nonnull %7, i64 noundef %10) #28
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %0, i8 0, i64 24, i1 false)
  br label %36

36:                                               ; preds = %32, %34
  %37 = phi ptr [ %6, %32 ], [ null, %34 ]
  %38 = icmp ugt i64 %3, 4611686018427387903
  br i1 %38, label %39, label %40

39:                                               ; preds = %36
  tail call void @_ZNSt3__16vectorIfNS_9allocatorIfEEE20__throw_length_errorB9nqe220108Ev() #27
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
  tail call void @_ZNSt3__16vectorIfNS_9allocatorIfEEE20__throw_length_errorB9nqe220108Ev() #27
  unreachable

48:                                               ; preds = %40
  %49 = shl nuw i64 %45, 2
  %50 = tail call noalias noundef nonnull ptr @_Znwm(i64 noundef %49) #25
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

57:                                               ; preds = %20, %27, %48
  ret void
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memmove.p0.p0.i64(ptr writeonly captures(none), ptr readonly captures(none), i64, i1 immarg) #16

; Function Attrs: mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.fabs.f32(float) #7

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.vscale.i64() #17

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: read)
declare <vscale x 4 x float> @llvm.masked.load.nxv4f32.p0(ptr captures(none), <vscale x 4 x i1>, <vscale x 4 x float>) #18

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.masked.store.nxv4f32.p0(<vscale x 4 x float>, ptr captures(none), <vscale x 4 x i1>) #19

; Function Attrs: nofree nounwind
declare noundef i32 @puts(ptr noundef readonly captures(none)) local_unnamed_addr #20

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #21

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umax.i64(i64, i64) #22

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #23

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x float> @llvm.fmuladd.v4f32(<4 x float>, <4 x float>, <4 x float>) #22

attributes #0 = { mustprogress nofree norecurse nosync nounwind ssp memory(argmem: readwrite) uwtable(sync) vscale_range(1,16) "aarch64_pstate_sm_enabled" "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bf16,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+sme,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #3 = { mustprogress nocallback nofree nosync nounwind willreturn memory(none) }
attributes #4 = { mustprogress norecurse ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #5 = { mustprogress nocallback nofree nounwind willreturn memory(read) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #6 = { nofree nounwind "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #7 = { mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #8 = { mustprogress noreturn ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #9 = { inlinehint mustprogress noreturn ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #10 = { mustprogress ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #11 = { nounwind "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #12 = { cold noreturn }
attributes #13 = { "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #14 = { nobuiltin allocsize(0) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #15 = { nobuiltin nounwind "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #16 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #17 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #18 = { nocallback nofree nosync nounwind willreturn memory(argmem: read) }
attributes #19 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
attributes #20 = { nofree nounwind }
attributes #21 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #22 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #23 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #24 = { "aarch64_pstate_sm_compatible" }
attributes #25 = { builtin allocsize(0) }
attributes #26 = { nounwind }
attributes #27 = { noreturn }
attributes #28 = { builtin nounwind }

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
!42 = !{i64 3205, i64 3250, i64 3289}
!43 = distinct !{!43, !13}
!44 = distinct !{!44, !13}
!45 = distinct !{!45, !13, !25}
!46 = !{!47, !47, i64 0}
!47 = !{!"vtable pointer", !9, i64 0}
