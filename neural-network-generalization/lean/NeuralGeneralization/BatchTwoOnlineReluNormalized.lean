import NeuralGeneralization.BatchTwoContinuousDepthFiniteLayerNorms
import NeuralGeneralization.BatchTwoOnlineReluStrong

/-! ReLU networks in actual isotropic Gaussian energy coordinates. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoOnlineReluFinite
open ConcreteModel BatchTwoContinuous BatchTwoContinuousDepthPaper BatchTwoActivation
set_option maxHeartbeats 1400000
set_option backward.isDefEq.respectTransparency false

def normalizedActivation (N : ℕ) (x : EuclideanSpace ℝ (Fin N)) : EuclideanSpace ℝ (Fin N) :=
  WithLp.toLp 2 (fun i => relu (Real.sqrt N*x i)/Real.sqrt N)

theorem normalizedActivation_zero (N : ℕ) : normalizedActivation N 0=0 := by
  ext i
  simp [normalizedActivation,relu]

theorem normalizedActivation_scalar {N : ℕ} (hN : 0 < N) (a b : ℝ) :
    |relu (Real.sqrt N*a)/Real.sqrt N-relu (Real.sqrt N*b)/Real.sqrt N| ≤ |a-b| := by
  have hsqrt : 0 < Real.sqrt N := Real.sqrt_pos.2 (by exact_mod_cast hN)
  have hh := relu_zeroLipschitz.2 (Real.sqrt N*a) (Real.sqrt N*b)
  simp only [one_mul] at hh
  rw [← mul_sub,abs_mul,abs_of_pos hsqrt] at hh
  rw [← sub_div,abs_div,abs_of_pos hsqrt]
  apply (div_le_iff₀ hsqrt).mpr
  simpa only [mul_comm] using hh

theorem normalizedActivation_difference {N : ℕ} (hN : 0 < N)
    (x y : EuclideanSpace ℝ (Fin N)) :
    ‖normalizedActivation N x-normalizedActivation N y‖ ≤ ‖x-y‖ := by
  have hs : ‖normalizedActivation N x-normalizedActivation N y‖^2 ≤ ‖x-y‖^2 := by
    simp only [EuclideanSpace.real_norm_sq_eq,PiLp.sub_apply,normalizedActivation,PiLp.toLp_apply]
    apply Finset.sum_le_sum
    intro i _
    have hh := pow_le_pow_left₀ (abs_nonneg _) (normalizedActivation_scalar hN (x i) (y i)) 2
    simpa only [sq_abs] using hh
  nlinarith [norm_nonneg (normalizedActivation N x-normalizedActivation N y),norm_nonneg (x-y)]

theorem normalizedActivation_norm {N : ℕ} (hN : 0 < N) (x : EuclideanSpace ℝ (Fin N)) :
    ‖normalizedActivation N x‖ ≤ ‖x‖ := by
  simpa only [normalizedActivation_zero,sub_zero] using normalizedActivation_difference hN x 0

def normalizedFirst {d N r : ℕ} (u : Weights d N r) (x : RealInput d) : EuclideanSpace ℝ (Fin N) :=
  normalizedActivation N (firstEnergyOperator u (normalizedInput x))

def normalizedStep {d N r : ℕ} (u : Weights d N r) (v : EuclideanSpace ℝ (Fin N))
    (s : Fin r) : EuclideanSpace ℝ (Fin N) := normalizedActivation N (internalEnergyOperator u s v)

def normalizedAfter {d N r : ℕ} (u : Weights d N r) (x : RealInput d) (t : ℕ) : EuclideanSpace ℝ (Fin N) :=
  ((List.finRange r).take t).foldl (normalizedStep u) (normalizedFirst u x)

def normalizedOutput {d N r : ℕ} (u : Weights d N r) (x : RealInput d) : ℝ :=
  ⟪readoutEnergyVector u,normalizedAfter u x r⟫

theorem normalizedAfter_zero {d N r : ℕ} (u : Weights d N r) (x : RealInput d) :
    normalizedAfter u x 0=normalizedFirst u x := by simp [normalizedAfter]

theorem normalizedAfter_succ {d N r : ℕ} (u : Weights d N r) (x : RealInput d) (s : Fin r) :
    normalizedAfter u x (s.val+1)=normalizedStep u (normalizedAfter u x s.val) s := by
  unfold normalizedAfter
  rw [List.take_succ_eq_append_getElem (by simpa using s.isLt),List.foldl_append]
  simp only [List.foldl_cons,List.foldl_nil,List.getElem_finRange]
  rfl

theorem normalizedFirst_unwhiten {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (u : Weights d N r) (x : RealInput d) (i : Fin N) :
    normalizedFirst u x i=BatchTwoContinuous.firstHidden relu (unwhiten u) x i/Real.sqrt N := by
  simp only [normalizedFirst,normalizedActivation,PiLp.toLp_apply,firstEnergyOperator,
    coordinateMatrixOperator,LinearMap.coe_toContinuousLinearMap',Matrix.toLpLin_apply,
    Matrix.mulVec,dotProduct,normalizedInput,BatchTwoContinuous.firstHidden,
    unwhiten,coordinateScale,smallVariance,one_pow,Real.sqrt_div (Nat.cast_nonneg N),
    mul_one]
  congr 2
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem normalizedStep_unwhiten {d N r : ℕ} (hN : 0 < N) (u : Weights d N r)
    (v : Fin N → ℝ) (s : Fin r) (i : Fin N) :
    normalizedStep u (WithLp.toLp 2 (fun j => v j/Real.sqrt N)) s i=
      hiddenStep relu (unwhiten u) v s i/Real.sqrt N := by
  have hroot : Real.sqrt N ≠ 0 := (Real.sqrt_pos.2 (by exact_mod_cast hN)).ne'
  simp only [normalizedStep,normalizedActivation,internalEnergyOperator,internalBlockProjection,
    LinearMap.coe_mk,AddHom.coe_mk,PiLp.toLp_apply,coordinateMatrixOperator,
    LinearMap.coe_toContinuousLinearMap',Matrix.toLpLin_apply,Matrix.mulVec,dotProduct,
    hiddenStep,unwhiten,coordinateScale,smallVariance,one_pow,Real.sqrt_one,one_mul]
  congr 2
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  field_simp

theorem normalizedAfter_unwhiten {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (u : Weights d N r) (x : RealInput d) :
    normalizedAfter u x r=WithLp.toLp 2 (fun i =>
      BatchTwoContinuous.finalHidden relu (unwhiten u) x i/Real.sqrt N) := by
  have hfold (ss : List (Fin r)) (v : Fin N → ℝ) :
      ss.foldl (normalizedStep u) (WithLp.toLp 2 (fun i => v i/Real.sqrt N))=
        WithLp.toLp 2 (fun i => (ss.foldl (hiddenStep relu (unwhiten u)) v) i/Real.sqrt N) := by
    induction ss generalizing v with
    | nil => rfl
    | cons a ss ih =>
      simp only [List.foldl_cons]
      have he : normalizedStep u (WithLp.toLp 2 (fun i => v i/Real.sqrt N)) a=
          WithLp.toLp 2 (fun i => hiddenStep relu (unwhiten u) v a i/Real.sqrt N) := by
        ext i
        exact normalizedStep_unwhiten hN u v a i
      rw [he]
      exact ih _
  have hf : normalizedFirst u x=WithLp.toLp 2 (fun i =>
      BatchTwoContinuous.firstHidden relu (unwhiten u) x i/Real.sqrt N) := by
    ext i
    exact normalizedFirst_unwhiten hd hN u x i
  unfold normalizedAfter
  rw [List.take_of_length_le (by simp),hf,hfold]
  rfl

theorem normalizedOutput_eq_output {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (u : Weights d N r) (x : RealInput d) :
    normalizedOutput u x=output relu (unwhiten u) x := by
  rw [normalizedOutput,normalizedAfter_unwhiten hd hN]
  simp only [readoutEnergyVector,readoutBlockProjection,LinearMap.coe_mk,AddHom.coe_mk,
    PiLp.inner_apply,RCLike.inner_apply,conj_trivial,PiLp.toLp_apply,output,unwhiten,
    coordinateScale,smallVariance,one_pow,Real.sqrt_div (by norm_num : (0 : ℝ) ≤ 1),Real.sqrt_one]
  apply Finset.sum_congr rfl
  intro i _
  ring

end NeuralGeneralization.BatchTwoOnlineReluFinite
