import NeuralGeneralization.BatchTwoContinuousDepthFiniteBulkGeometry
import NeuralGeneralization.BatchTwoContinuousDepthPaperCeiling

/-! The actual tanh network in its Euclidean energy coordinates. -/
noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoContinuous
set_option maxHeartbeats 1400000
set_option backward.isDefEq.respectTransparency false

def normalizedActivation (N : ℕ) (x : EuclideanSpace ℝ (Fin N)) : EuclideanSpace ℝ (Fin N) :=
  WithLp.toLp 2 (fun i => Real.tanh (Real.sqrt N*x i)/Real.sqrt N)

theorem normalizedActivation_zero (N : ℕ) : normalizedActivation N 0=0 := by
  ext i
  simp [normalizedActivation]

theorem normalizedActivation_scalar {N : ℕ} (hN : 0 < N) (a b : ℝ) :
    |Real.tanh (Real.sqrt N*a)/Real.sqrt N-Real.tanh (Real.sqrt N*b)/Real.sqrt N| ≤ |a-b| := by
  have hsqrt : 0 < Real.sqrt N := Real.sqrt_pos.2 (by exact_mod_cast hN)
  have hh := tanh_admissible.2 (Real.sqrt N*a) (Real.sqrt N*b)
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

theorem coordinateMatrixOperator_norm_le {ι κ : Type*} [Fintype ι] [Fintype κ]
    (z : ι × κ → ℝ) : ‖coordinateMatrixOperator z‖ ≤ ‖WithLp.toLp 2 z‖ := by
  apply (coordinateMatrixOperator z).opNorm_le_bound (norm_nonneg _)
  intro x
  have hh := Compression.matrix_action_squaredSum_le (fun i j => z (i,j)) (fun j => x j)
  have hs : ‖coordinateMatrixOperator z x‖^2 ≤ (‖WithLp.toLp 2 z‖*‖x‖)^2 := by
    simpa only [mul_pow,EuclideanSpace.real_norm_sq_eq,coordinateMatrixOperator,
      LinearMap.coe_toContinuousLinearMap',Matrix.toLpLin_apply,Matrix.mulVec,dotProduct,
      PiLp.toLp_apply,Fintype.sum_prod_type] using hh
  nlinarith [norm_nonneg (coordinateMatrixOperator z x),mul_nonneg (norm_nonneg (WithLp.toLp 2 z)) (norm_nonneg x)]

theorem linear_operator_difference {E F : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F] (A B : E →L[ℝ] F) (x y : E) :
    ‖A x-B y‖ ≤ ‖A‖*‖x-y‖+‖A-B‖*‖y‖ := by
  have he : A x-B y=A (x-y)+(A-B) y := by simp [map_sub]
  rw [he]
  exact (norm_add_le _ _).trans (add_le_add (A.le_opNorm (x-y)) ((A-B).le_opNorm y))

def normalizedInput {d : ℕ} (x : RealInput d) : EuclideanSpace ℝ (Fin (d+1)) :=
  WithLp.toLp 2 (fun j => augmentedInput x j/Real.sqrt d)

theorem normalizedInput_norm {d : ℕ} (hd : 0 < d) (x : RealInput d)
    (hx : ∑ i,x i^2 ≤ 1) : ‖normalizedInput x‖ ≤ Real.sqrt 2 := by
  have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd
  have he : ‖normalizedInput x‖^2=((∑ i,x i^2)+1)/(d : ℝ) := by
    simp only [EuclideanSpace.real_norm_sq_eq,normalizedInput,PiLp.toLp_apply,div_pow,
      Real.sq_sqrt (Nat.cast_nonneg d),← Finset.sum_div,augmentedInput_sq_sum]
    ring
  have hh : ((∑ i,x i^2)+1)/(d : ℝ) ≤ 2 := by
    apply (div_le_iff₀ (by positivity)).mpr
    linarith
  have hs := Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 2)
  nlinarith [Real.sqrt_nonneg 2,norm_nonneg (normalizedInput x)]

def firstEnergyOperator {d N r : ℕ} (u : Weights d N r) :
    EuclideanSpace ℝ (Fin (d+1)) →L[ℝ] EuclideanSpace ℝ (Fin N) :=
  coordinateMatrixOperator (fun ij => u (Sum.inl ij))

def internalEnergyOperator {d N r : ℕ} (u : Weights d N r) (s : Fin r) :
    EuclideanSpace ℝ (Fin N) →L[ℝ] EuclideanSpace ℝ (Fin N) :=
  internalBlockProjection d N r s (WithLp.toLp 2 u)

def readoutEnergyVector {d N r : ℕ} (u : Weights d N r) : EuclideanSpace ℝ (Fin N) :=
  readoutBlockProjection d N r (WithLp.toLp 2 u)

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
    normalizedFirst u x i=BatchTwoContinuous.firstHidden Real.tanh (unwhiten u) x i/Real.sqrt N := by
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
      hiddenStep Real.tanh (unwhiten u) v s i/Real.sqrt N := by
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
      BatchTwoContinuous.finalHidden Real.tanh (unwhiten u) x i/Real.sqrt N) := by
  have hfold (ss : List (Fin r)) (v : Fin N → ℝ) :
      ss.foldl (normalizedStep u) (WithLp.toLp 2 (fun i => v i/Real.sqrt N))=
        WithLp.toLp 2 (fun i => (ss.foldl (hiddenStep Real.tanh (unwhiten u)) v) i/Real.sqrt N) := by
    induction ss generalizing v with
    | nil => rfl
    | cons a ss ih =>
      simp only [List.foldl_cons]
      have he : normalizedStep u (WithLp.toLp 2 (fun i => v i/Real.sqrt N)) a=
          WithLp.toLp 2 (fun i => hiddenStep Real.tanh (unwhiten u) v a i/Real.sqrt N) := by
        ext i
        exact normalizedStep_unwhiten hN u v a i
      rw [he]
      exact ih _
  have hf : normalizedFirst u x=WithLp.toLp 2 (fun i =>
      BatchTwoContinuous.firstHidden Real.tanh (unwhiten u) x i/Real.sqrt N) := by
    ext i
    exact normalizedFirst_unwhiten hd hN u x i
  unfold normalizedAfter
  rw [List.take_of_length_le (by simp),hf,hfold]
  rfl

theorem normalizedOutput_eq_output {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (u : Weights d N r) (x : RealInput d) :
    normalizedOutput u x=output Real.tanh (unwhiten u) x := by
  rw [normalizedOutput,normalizedAfter_unwhiten hd hN]
  simp only [readoutEnergyVector,readoutBlockProjection,LinearMap.coe_mk,AddHom.coe_mk,
    PiLp.inner_apply,RCLike.inner_apply,conj_trivial,PiLp.toLp_apply,output,unwhiten,
    coordinateScale,smallVariance,one_pow,Real.sqrt_div (by norm_num : (0 : ℝ) ≤ 1),Real.sqrt_one]
  apply Finset.sum_congr rfl
  intro i _
  ring

end NeuralGeneralization.BatchTwoContinuousDepthPaper
