import Mathlib.Analysis.InnerProductSpace.LinearMap
import Mathlib.Tactic.Linarith

/-!
# Operator norm controlled by two finite nets

For quarter-nets in two real Hilbert unit balls, a bound on all bilinear
evaluations on the nets gives twice that bound for the actual operator norm.
No matrix concentration inequality is assumed in this deterministic step.
-/

noncomputable section

namespace NeuralGeneralization

open scoped RealInnerProductSpace

variable {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [NormedAddCommGroup F] [InnerProductSpace ℝ F]

/-- Approximation by two quarter-nets loses only a factor two. -/
theorem operator_norm_le_two_of_quarter_nets
    (s : Finset E) (t : Finset F)
    (hsunit : ∀ x ∈ s, ‖x‖ ≤ 1)
    (hscover : ∀ x : E, ‖x‖ ≤ 1 → ∃ y ∈ s, dist x y ≤ (1 / 4 : ℝ))
    (htcover : ∀ x : F, ‖x‖ ≤ 1 → ∃ y ∈ t, dist x y ≤ (1 / 4 : ℝ))
    (A : E →L[ℝ] F) (B : ℝ) (hB : 0 ≤ B)
    (hnet : ∀ x ∈ s, ∀ y ∈ t, |⟪A x, y⟫| ≤ B) :
    ‖A‖ ≤ 2 * B := by
  have hbound : ‖A‖ ≤ B + ‖A‖ / 2 := by
    apply ContinuousLinearMap.opNorm_le_of_re_inner_le (by positivity)
    intro x y hx hy
    obtain ⟨x₀, hx₀, hxx₀⟩ := hscover x hx.le
    obtain ⟨y₀, hy₀, hyy₀⟩ := htcover y hy.le
    rw [dist_eq_norm] at hxx₀ hyy₀
    have hfirst : |⟪A (x - x₀), y⟫| ≤ ‖A‖ / 4 := by
      calc
        _ ≤ ‖A (x - x₀)‖ * ‖y‖ := abs_real_inner_le_norm _ _
        _ = ‖A (x - x₀)‖ := by rw [hy, mul_one]
        _ ≤ ‖A‖ * ‖x - x₀‖ := A.le_opNorm _
        _ ≤ ‖A‖ / 4 := by nlinarith [norm_nonneg A]
    have hsecond : |⟪A x₀, y - y₀⟫| ≤ ‖A‖ / 4 := by
      calc
        _ ≤ ‖A x₀‖ * ‖y - y₀‖ := abs_real_inner_le_norm _ _
        _ ≤ ‖A‖ * ‖y - y₀‖ :=
          mul_le_mul_of_nonneg_right (A.unit_le_opNorm x₀ (hsunit x₀ hx₀)) (norm_nonneg _)
        _ ≤ ‖A‖ / 4 := by nlinarith [norm_nonneg A]
    have hid : ⟪A x, y⟫ =
        ⟪A x₀, y₀⟫ + ⟪A (x - x₀), y⟫ + ⟪A x₀, y - y₀⟫ := by
      rw [map_sub, inner_sub_left, inner_sub_right]
      ring
    have hbase := hnet x₀ hx₀ y₀ hy₀
    change ⟪A x, y⟫ ≤ B + ‖A‖ / 2
    rw [hid]
    linarith [le_abs_self ⟪A x₀, y₀⟫,
      le_abs_self ⟪A (x - x₀), y⟫, le_abs_self ⟪A x₀, y - y₀⟫]
  linarith

end NeuralGeneralization
