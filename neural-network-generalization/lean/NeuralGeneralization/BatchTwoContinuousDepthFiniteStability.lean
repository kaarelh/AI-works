import NeuralGeneralization.BatchTwoContinuousDepthFiniteLayerNorms
import NeuralGeneralization.BatchTwoContinuousDepthFiniteTelescoping

/-! The sharp perturbation inequality for the actual normalized network. -/
noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoContinuous
set_option maxHeartbeats 1600000
set_option backward.isDefEq.respectTransparency false

theorem normalizedFirst_norm_bound {d N r : ℕ} (hN : 0 < N) (u : Weights d N r)
    (x : RealInput d) : ‖normalizedFirst u x‖ ≤ normalizedLayerNorm u 0*‖normalizedInput x‖ :=
  (normalizedActivation_norm hN _).trans (((firstEnergyOperator u).le_opNorm _).trans
    (mul_le_mul_of_nonneg_right (firstEnergyOperator_le_layer u) (norm_nonneg _)))

theorem normalizedStep_norm_bound {d N r : ℕ} (hN : 0 < N) (u : Weights d N r)
    (x : EuclideanSpace ℝ (Fin N)) (s : Fin r) :
    ‖normalizedStep u x s‖ ≤ normalizedLayerNorm u s.castSucc.succ*‖x‖ :=
  (normalizedActivation_norm hN _).trans (((internalEnergyOperator u s).le_opNorm _).trans
    (mul_le_mul_of_nonneg_right (internalEnergyOperator_le_layer u s) (norm_nonneg _)))

theorem normalizedOutput_norm_bound {d N r : ℕ} (u : Weights d N r) (x : RealInput d) :
    |normalizedOutput u x| ≤ normalizedLayerNorm u (Fin.last (r+1))*‖normalizedAfter u x r‖ := by
  rw [normalizedLayerNorm_last]
  exact abs_real_inner_le_norm _ _

theorem normalizedFirst_error_bound {d N r : ℕ} (hN : 0 < N) (u v : Weights d N r)
    {η : ℝ} (hv : smallEnergyBlocks v η) (x : RealInput d) :
    ‖normalizedFirst (u+v) x-normalizedFirst u x‖ ≤ η*‖normalizedInput x‖ := by
  have hh := (normalizedActivation_difference hN _ _).trans
    (linear_operator_difference (firstEnergyOperator (u+v)) (firstEnergyOperator u)
      (normalizedInput x) (normalizedInput x))
  simp only [sub_self,norm_zero,mul_zero,zero_add] at hh
  exact hh.trans (mul_le_mul_of_nonneg_right (first_perturbed_operator u v hv).2 (norm_nonneg _))

theorem normalizedStep_error_bound {d N r : ℕ} (hN : 0 < N) (u v : Weights d N r)
    {η : ℝ} (hv : smallEnergyBlocks v η) (x y : EuclideanSpace ℝ (Fin N)) (s : Fin r) :
    ‖normalizedStep (u+v) x s-normalizedStep u y s‖ ≤
      (normalizedLayerNorm u s.castSucc.succ+η)*‖x-y‖+η*‖y‖ := by
  have hh := (normalizedActivation_difference hN _ _).trans
    (linear_operator_difference (internalEnergyOperator (u+v) s) (internalEnergyOperator u s) x y)
  have hp := internal_perturbed_operator u v hv s
  exact hh.trans (add_le_add (mul_le_mul_of_nonneg_right hp.1 (norm_nonneg _))
    (mul_le_mul_of_nonneg_right hp.2 (norm_nonneg _)))

theorem normalizedOutput_error_bound {d N r : ℕ} (u v : Weights d N r)
    {η : ℝ} (hv : smallEnergyBlocks v η) (x : RealInput d) :
    |normalizedOutput (u+v) x-normalizedOutput u x| ≤
      (normalizedLayerNorm u (Fin.last (r+1))+η)*‖normalizedAfter (u+v) x r-normalizedAfter u x r‖+
        η*‖normalizedAfter u x r‖ := by
  have he : normalizedOutput (u+v) x-normalizedOutput u x=
      ⟪readoutEnergyVector (u+v),normalizedAfter (u+v) x r-normalizedAfter u x r⟫+
      ⟪readoutEnergyVector (u+v)-readoutEnergyVector u,normalizedAfter u x r⟫ := by
    simp only [normalizedOutput,inner_sub_right,inner_sub_left]
    ring
  rw [he]
  have hp := readout_perturbed_operator u v hv
  exact (abs_add_le _ _).trans ((add_le_add (abs_real_inner_le_norm _ _) (abs_real_inner_le_norm _ _)).trans
    (add_le_add (mul_le_mul_of_nonneg_right hp.1 (norm_nonneg _))
      (mul_le_mul_of_nonneg_right hp.2 (norm_nonneg _))))

def layerNormAt {d N r : ℕ} (u : Weights d N r) (j : ℕ) : ℝ :=
  if hj : j < r+2 then normalizedLayerNorm u ⟨j,hj⟩ else 0

def normalizedNormTrace {d N r : ℕ} (u : Weights d N r) (x : RealInput d) : ℕ → ℝ
  | 0 => ‖normalizedInput x‖
  | j+1 => if j ≤ r then ‖normalizedAfter u x j‖ else |normalizedOutput u x|

def normalizedErrorTrace {d N r : ℕ} (u v : Weights d N r) (x : RealInput d) : ℕ → ℝ
  | 0 => 0
  | j+1 => if j ≤ r then ‖normalizedAfter u x j-normalizedAfter v x j‖
    else |normalizedOutput u x-normalizedOutput v x|

theorem layerNormAt_fin {d N r : ℕ} (u : Weights d N r) (s : Fin (r+2)) :
    layerNormAt u s.val=normalizedLayerNorm u s := by
  simp only [layerNormAt,dif_pos s.isLt,Fin.eta]

theorem layerNormAt_zero {d N r : ℕ} (u : Weights d N r) :
    layerNormAt u 0=normalizedLayerNorm u 0 := layerNormAt_fin u 0

theorem layerNormAt_internal {d N r : ℕ} (u : Weights d N r) (s : Fin r) :
    layerNormAt u (s.val+1)=normalizedLayerNorm u s.castSucc.succ := layerNormAt_fin u s.castSucc.succ

theorem layerNormAt_last {d N r : ℕ} (u : Weights d N r) :
    layerNormAt u (r+1)=normalizedLayerNorm u (Fin.last (r+1)) := layerNormAt_fin u (Fin.last (r+1))

theorem normalizedNormTrace_nonneg {d N r : ℕ} (u : Weights d N r) (x : RealInput d) (j : ℕ) :
    0 ≤ normalizedNormTrace u x j := by
  cases j with
  | zero => exact norm_nonneg _
  | succ j => unfold normalizedNormTrace;split <;> positivity

theorem normalizedNormTrace_step {d N r : ℕ} (hN : 0 < N) (u : Weights d N r)
    (x : RealInput d) (j : ℕ) (hj : j < r+2) :
    normalizedNormTrace u x (j+1) ≤ layerNormAt u j*normalizedNormTrace u x j := by
  cases j with
  | zero => simpa [normalizedNormTrace,normalizedAfter_zero,layerNormAt_zero] using normalizedFirst_norm_bound hN u x
  | succ j =>
    by_cases h : j < r
    · let s : Fin r := ⟨j,h⟩
      have hh := normalizedStep_norm_bound hN u (normalizedAfter u x j) s
      rw [← normalizedAfter_succ u x s] at hh
      simpa only [normalizedNormTrace,if_pos (by omega : j+1 ≤ r),if_pos (by omega : j ≤ r),
        ← layerNormAt_internal,s] using hh
    · have he : j=r := by omega
      subst j
      simpa only [normalizedNormTrace,if_pos le_rfl,if_neg (by omega : ¬ r+1 ≤ r),layerNormAt_last]
        using normalizedOutput_norm_bound u x

theorem normalizedErrorTrace_step {d N r : ℕ} (hN : 0 < N) (u v : Weights d N r)
    {η : ℝ} (hv : smallEnergyBlocks v η) (x : RealInput d) (j : ℕ) (hj : j < r+2) :
    normalizedErrorTrace (u+v) u x (j+1) ≤
      (layerNormAt u j+η)*normalizedErrorTrace (u+v) u x j+η*normalizedNormTrace u x j := by
  cases j with
  | zero =>
    simpa [normalizedErrorTrace,normalizedNormTrace,normalizedAfter_zero] using normalizedFirst_error_bound hN u v hv x
  | succ j =>
    by_cases h : j < r
    · let s : Fin r := ⟨j,h⟩
      have hh := normalizedStep_error_bound hN u v hv (normalizedAfter (u+v) x j) (normalizedAfter u x j) s
      rw [← normalizedAfter_succ (u+v) x s,← normalizedAfter_succ u x s] at hh
      simpa only [normalizedErrorTrace,normalizedNormTrace,if_pos (by omega : j+1 ≤ r),
        if_pos (by omega : j ≤ r),← layerNormAt_internal,s] using hh
    · have he : j=r := by omega
      subst j
      simpa only [normalizedErrorTrace,normalizedNormTrace,if_pos le_rfl,
        if_neg (by omega : ¬ r+1 ≤ r),layerNormAt_last] using normalizedOutput_error_bound u v hv x

end NeuralGeneralization.BatchTwoContinuousDepthPaper
