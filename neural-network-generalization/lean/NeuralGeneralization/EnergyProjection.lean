import NeuralGeneralization.MaximalEnergyFamily
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Tactic.Ring

/-! # The actual finite-rank capture and its orthogonal residual -/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators RealInnerProductSpace
open InnerProductSpace

variable {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [NormedAddCommGroup F] [InnerProductSpace ℝ F]

/-- Explicit projection onto finitely many orthonormal input vectors. -/
def energyProjection (s : Finset E) : E →L[ℝ] E :=
  ∑ v ∈ s, rankOne ℝ v v

lemma energyProjection_apply (s : Finset E) (x : E) :
    energyProjection s x = ∑ v ∈ s, ⟪v, x⟫ • v := by
  simp [energyProjection]

lemma inner_energyProjection (s : Finset E) (hs : orthonormalFinset s)
    (v : E) (hv : v ∈ s) (x : E) : ⟪v, energyProjection s x⟫ = ⟪v, x⟫ := by
  classical
  rw [energyProjection_apply, inner_sum]
  rw [Finset.sum_eq_single v]
  · simp [inner_smul_right, hs.1 v hv]
  · intro w hw hwv
    rw [inner_smul_right, hs.2 v hv w hw (Ne.symm hwv), mul_zero]
  · exact fun h => (h hv).elim

lemma inner_energyResidual (s : Finset E) (hs : orthonormalFinset s)
    (v : E) (hv : v ∈ s) (x : E) : ⟪v, x - energyProjection s x⟫ = 0 := by
  rw [inner_sub_right, inner_energyProjection s hs v hv x, sub_self]

lemma energyProjection_inner_residual (s : Finset E) (hs : orthonormalFinset s)
    (x : E) : ⟪energyProjection s x, x - energyProjection s x⟫ = 0 := by
  nth_rw 1 [energyProjection_apply s x]
  rw [sum_inner]
  apply Finset.sum_eq_zero
  intro v hv
  rw [inner_smul_left, inner_energyResidual s hs v hv x, mul_zero]

lemma energyResidual_norm_le (s : Finset E) (hs : orthonormalFinset s)
    (x : E) : ‖x - energyProjection s x‖ ≤ ‖x‖ := by
  have hpy := norm_add_sq_real (energyProjection s x) (x - energyProjection s x)
  rw [energyProjection_inner_residual s hs x, add_sub_cancel, mul_zero, add_zero] at hpy
  nlinarith [sq_nonneg ‖energyProjection s x‖, norm_nonneg (x - energyProjection s x),
    norm_nonneg x]

/-- The captured part of `A` is an explicit sum of rank-one maps. -/
def energyCapture (A : E →L[ℝ] F) (s : Finset E) : E →L[ℝ] F :=
  A.comp (energyProjection s)

lemma energyCapture_apply (A : E →L[ℝ] F) (s : Finset E) (x : E) :
    energyCapture A s x = ∑ v ∈ s, ⟪v, x⟫ • A v := by
  simp [energyCapture, energyProjection_apply, map_sum, map_smul]

lemma energyCapture_eq_sum_rankOne (A : E →L[ℝ] F) (s : Finset E) :
    energyCapture A s = ∑ v ∈ s, rankOne ℝ (A v) v := by
  ext x
  simp [energyCapture_apply]

lemma energyCapture_residual_apply (A : E →L[ℝ] F) (s : Finset E) (x : E) :
    (A - energyCapture A s) x = A (x - energyProjection s x) := by
  simp [energyCapture, map_sub]

/-- If the operator residual exceeds `a`, an orthogonal unit direction has
image norm exceeding `a`. -/
theorem exists_orthogonal_direction_of_residual
    (A : E →L[ℝ] F) (s : Finset E) (hs : orthonormalFinset s)
    (a : ℝ) (ha : 0 ≤ a) (hres : a < ‖A - energyCapture A s‖) :
    ∃ v : E, ‖v‖ = 1 ∧ (∀ w ∈ s, ⟪v, w⟫ = 0) ∧ a < ‖A v‖ := by
  have hex : ∃ x : E, ‖x‖ = 1 ∧ a < ‖(A - energyCapture A s) x‖ := by
    by_contra h
    have hb : ‖A - energyCapture A s‖ ≤ a :=
      ContinuousLinearMap.opNorm_le_of_unit_norm ha (by
        intro x hx
        exact le_of_not_gt (fun hlarge => h ⟨x, hx, hlarge⟩))
    exact (not_le_of_gt hres) hb
  obtain ⟨x, hx, hlarge⟩ := hex
  let y := x - energyProjection s x
  have hy : ‖y‖ ≤ 1 := (energyResidual_norm_le s hs x).trans hx.le
  have hAy : a < ‖A y‖ := by simpa only [energyCapture_residual_apply] using hlarge
  have hypos : 0 < ‖y‖ := by
    apply norm_pos_iff.mpr
    intro hz
    simp [hz] at hAy
    linarith
  refine ⟨‖y‖⁻¹ • y, ?_, ?_, ?_⟩
  · rw [norm_smul, Real.norm_eq_abs, abs_of_pos (inv_pos.mpr hypos)]
    exact inv_mul_cancel₀ (ne_of_gt hypos)
  · intro w hw
    have hinner : ⟪y, w⟫ = 0 := by
      rw [real_inner_comm]
      exact inner_energyResidual s hs w hw x
    simp [inner_smul_left, hinner]
  · rw [map_smul, norm_smul, Real.norm_eq_abs, abs_of_pos (inv_pos.mpr hypos)]
    have hmul : a * ‖y‖ < ‖A y‖ := lt_of_le_of_lt (mul_le_of_le_one_right ha hy) hAy
    have hdiv := (lt_div_iff₀ hypos).mpr hmul
    simpa only [div_eq_mul_inv, mul_comm] using hdiv

end NeuralGeneralization
