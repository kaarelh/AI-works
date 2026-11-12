import NeuralGeneralization.BatchTwoOnlineReluNormalized
import NeuralGeneralization.BatchTwoContinuousDepthFiniteStability

/-! Layerwise Euclidean ReLU perturbation with summed, rather than worst-case, errors. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoOnlineReluFinite
open ConcreteModel BatchTwoContinuous BatchTwoContinuousDepthPaper
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

theorem normalizedFirst_error_bound {d N r : ℕ} (hN : 0<N) (u v : Weights d N r)
    (x : RealInput d) :
    ‖normalizedFirst (u+v) x-normalizedFirst u x‖≤normalizedLayerNorm v 0*‖normalizedInput x‖ := by
  have hh := (normalizedActivation_difference hN _ _).trans
    (linear_operator_difference (firstEnergyOperator (u+v)) (firstEnergyOperator u)
      (normalizedInput x) (normalizedInput x))
  rw [firstEnergyOperator_add,add_sub_cancel_left] at hh
  simp only [sub_self,norm_zero,mul_zero,zero_add] at hh
  simpa only [normalizedFirst,firstEnergyOperator_add] using hh.trans (mul_le_mul_of_nonneg_right (firstEnergyOperator_le_layer v) (norm_nonneg _))

theorem normalizedStep_error_bound {d N r : ℕ} (hN : 0<N) (u v : Weights d N r)
    (x y : EuclideanSpace ℝ (Fin N)) (s : Fin r) :
    ‖normalizedStep (u+v) x s-normalizedStep u y s‖≤
      (normalizedLayerNorm u s.castSucc.succ+normalizedLayerNorm v s.castSucc.succ)*‖x-y‖+
        normalizedLayerNorm v s.castSucc.succ*‖y‖ := by
  have hh := (normalizedActivation_difference hN _ _).trans
    (linear_operator_difference (internalEnergyOperator (u+v) s) (internalEnergyOperator u s) x y)
  rw [internalEnergyOperator_add,add_sub_cancel_left] at hh
  have hp := (norm_add_le (internalEnergyOperator u s) (internalEnergyOperator v s)).trans
    (add_le_add (internalEnergyOperator_le_layer u s) (internalEnergyOperator_le_layer v s))
  simpa only [normalizedStep,internalEnergyOperator_add] using hh.trans (add_le_add (mul_le_mul_of_nonneg_right hp (norm_nonneg _))
    (mul_le_mul_of_nonneg_right (internalEnergyOperator_le_layer v s) (norm_nonneg _)))

theorem normalizedOutput_error_bound {d N r : ℕ} (u v : Weights d N r) (x : RealInput d) :
    |normalizedOutput (u+v) x-normalizedOutput u x|≤
      (normalizedLayerNorm u (Fin.last (r+1))+normalizedLayerNorm v (Fin.last (r+1)))*
        ‖normalizedAfter (u+v) x r-normalizedAfter u x r‖+
      normalizedLayerNorm v (Fin.last (r+1))*‖normalizedAfter u x r‖ := by
  have he : normalizedOutput (u+v) x-normalizedOutput u x=
      ⟪readoutEnergyVector (u+v),normalizedAfter (u+v) x r-normalizedAfter u x r⟫+
      ⟪readoutEnergyVector (u+v)-readoutEnergyVector u,normalizedAfter u x r⟫ := by
    simp only [normalizedOutput,inner_sub_right,inner_sub_left]
    ring
  rw [he]
  have hp : ‖readoutEnergyVector (u+v)‖≤normalizedLayerNorm u (Fin.last (r+1))+
      normalizedLayerNorm v (Fin.last (r+1)) := by
    rw [readoutEnergyVector_add,normalizedLayerNorm_last,normalizedLayerNorm_last]
    exact norm_add_le _ _
  have hv : ‖readoutEnergyVector (u+v)-readoutEnergyVector u‖=normalizedLayerNorm v (Fin.last (r+1)) := by
    rw [readoutEnergyVector_add,add_sub_cancel_left,normalizedLayerNorm_last]
  exact (abs_add_le _ _).trans ((add_le_add (abs_real_inner_le_norm _ _) (abs_real_inner_le_norm _ _)).trans
    (add_le_add (mul_le_mul_of_nonneg_right hp (norm_nonneg _))
      (by rw [hv])))

def normalizedNormTrace {d N r : ℕ} (u : Weights d N r) (x : RealInput d) : ℕ → ℝ
  | 0 => ‖normalizedInput x‖
  | j+1 => if j ≤ r then ‖normalizedAfter u x j‖ else |normalizedOutput u x|

def normalizedErrorTrace {d N r : ℕ} (u v : Weights d N r) (x : RealInput d) : ℕ → ℝ
  | 0 => 0
  | j+1 => if j ≤ r then ‖normalizedAfter u x j-normalizedAfter v x j‖
    else |normalizedOutput u x-normalizedOutput v x|

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
    (x : RealInput d) (j : ℕ) (hj : j < r+2) :
    normalizedErrorTrace (u+v) u x (j+1) ≤
      (layerNormAt u j+layerNormAt v j)*normalizedErrorTrace (u+v) u x j+layerNormAt v j*normalizedNormTrace u x j := by
  cases j with
  | zero =>
    simpa [normalizedErrorTrace,normalizedNormTrace,normalizedAfter_zero,layerNormAt_zero] using normalizedFirst_error_bound hN u v x
  | succ j =>
    by_cases h : j < r
    · let s : Fin r := ⟨j,h⟩
      have hh := normalizedStep_error_bound hN u v (normalizedAfter (u+v) x j) (normalizedAfter u x j) s
      rw [← normalizedAfter_succ (u+v) x s,← normalizedAfter_succ u x s] at hh
      simpa only [normalizedErrorTrace,normalizedNormTrace,if_pos (by omega : j+1 ≤ r),
        if_pos (by omega : j ≤ r),← layerNormAt_internal,s] using hh
    · have he : j=r := by omega
      subst j
      simpa only [normalizedErrorTrace,normalizedNormTrace,if_pos le_rfl,
        if_neg (by omega : ¬ r+1 ≤ r),layerNormAt_last] using normalizedOutput_error_bound u v x

end NeuralGeneralization.BatchTwoOnlineReluFinite
