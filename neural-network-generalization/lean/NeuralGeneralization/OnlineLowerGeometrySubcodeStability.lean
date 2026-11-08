import NeuralGeneralization.OnlineLowerGeometryCore
import Mathlib.Analysis.Normed.Group.Basic

/-!
# Stability after retaining a subcode

The scalar theorem is usable directly with square-root Euclidean energies.
The normed-space wrapper must be instantiated with `EuclideanSpace` (or
another intended normed model), not the default sup norm on a function
space. The omitted-ray coefficient estimate is an explicit input.
-/

noncomputable section

namespace NeuralGeneralization.OnlineLowerGeometry

theorem omitted_ray_scalar_transfer (r δ t K W : ℝ)
    (hr : 0 ≤ r) (hδ : 0 ≤ δ) (ht : 0 ≤ t) (hK : 1 ≤ K) (hW : 0 ≤ W)
    (hfull : t ^ 2 ≤ K * r * δ) (hmissing : r ≤ δ + (W + 1) * t) :
    r ^ 2 ≤ 4 * K * (W + 1) ^ 2 * r * δ := by
  have ha : 1 ≤ (W + 1) ^ 2 := by nlinarith [sq_nonneg W]
  have hKa : 1 ≤ K * (W + 1) ^ 2 := by
    nlinarith [mul_nonneg (by linarith : 0 ≤ K - 1)
      (by nlinarith : 0 ≤ (W + 1) ^ 2)]
  by_cases hsmall : r ≤ 2 * δ
  · have hsq := mul_le_mul_of_nonneg_left hsmall hr
    have hcoef : (2 : ℝ) ≤ 4 * K * (W + 1) ^ 2 := by nlinarith
    have hmul := mul_le_mul_of_nonneg_right hcoef (mul_nonneg hr hδ)
    nlinarith
  · have hlinear : r ≤ 2 * (W + 1) * t := by linarith
    have hsquare := mul_self_le_mul_self hr hlinear
    have hdist := mul_le_mul_of_nonneg_left hfull
      (mul_nonneg (by norm_num : (0 : ℝ) ≤ 4) (sq_nonneg (W + 1)))
    nlinarith

theorem retained_subcode_stability {E : Type*} [NormedAddCommGroup E]
    (u v : E) (retained : E → Prop) (δ K W : ℝ)
    (hδ : 0 ≤ δ) (hK : 1 ≤ K) (hW : 0 ≤ W)
    (hfull : ‖u - v‖ ^ 2 ≤ K * ‖u‖ * δ)
    (homitted : ¬ retained v → ‖v‖ ≤ δ + W * ‖u - v‖) :
    ∃ v', (v' = 0 ∨ retained v') ∧
      ‖u - v'‖ ^ 2 ≤ 4 * K * (W + 1) ^ 2 * ‖u‖ * δ := by
  by_cases hv : retained v
  · refine ⟨v, Or.inr hv, ?_⟩
    have hcoef : (1 : ℝ) ≤ 4 * (W + 1) ^ 2 := by nlinarith [sq_nonneg W]
    have hmul := mul_le_mul_of_nonneg_right hcoef
      (mul_nonneg (mul_nonneg (by linarith : 0 ≤ K) (norm_nonneg u)) hδ)
    nlinarith
  · refine ⟨0, Or.inl rfl, ?_⟩
    rw [sub_zero]
    apply omitted_ray_scalar_transfer ‖u‖ δ ‖u - v‖ K W
      (norm_nonneg u) hδ (norm_nonneg _) hK hW hfull
    have htriangle : ‖u‖ ≤ ‖u - v‖ + ‖v‖ := by
      have h := norm_add_le (u - v) v
      simpa only [sub_add_cancel] using h
    have hmiss := homitted hv
    nlinarith

/-- The explicit polynomial constant used after the full atom theorem
with constant `2^9 R^2` and degree bound `7 p R / 6`. -/
theorem subcode_polynomial_constant (p R W : ℝ)
    (hp : 1 ≤ p) (hR : 2 ≤ R) (hW : 0 ≤ W) (hWmax : W ≤ 7 * p * R / 2) :
    4 * (2 ^ 9 * R ^ 2) * (W + 1) ^ 2 ≤ 2 ^ 16 * p ^ 2 * R ^ 4 := by
  have hp0 : 0 ≤ p := by linarith
  have hR0 : 0 ≤ R := by linarith
  have hpR : 2 ≤ p * R := by nlinarith
  have hbase : W + 1 ≤ 4 * p * R := by nlinarith
  have hsquare := mul_self_le_mul_self (by linarith : 0 ≤ W + 1) hbase
  have hcoef : 0 ≤ 4 * (2 ^ 9 * R ^ 2) := by positivity
  have hmul := mul_le_mul_of_nonneg_left hsquare hcoef
  have hprod : 0 ≤ p ^ 2 * R ^ 4 := mul_nonneg (sq_nonneg _) (pow_nonneg hR0 _)
  nlinarith

end NeuralGeneralization.OnlineLowerGeometry
