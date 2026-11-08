import NeuralGeneralization.OnlineLowerSignedSeries
import Mathlib.Tactic.FieldSimp

/-!
# Exact triangular transfer algebra for the tanh path code

The transfer acts on two real coordinates. Writing it as a pair-valued map
keeps the matrix identity literal while avoiding any matrix convention.
The conversion from the analytic enumerator to this transfer is a separate
obligation; this file does not assert the complete neural lower bound.
-/

noncomputable section

namespace NeuralGeneralization.OnlineLower

def pathRatio (x : ℝ) : ℝ := x ^ 4 / (1 + x ^ 2 + x ^ 4)
def pathSlope (x : ℝ) : ℝ := x * (1 + x ^ 2) / (1 + x ^ 2 + x ^ 4)

theorem pathDenominator_pos (x : ℝ) : 0 < 1 + x ^ 2 + x ^ 4 := by
  nlinarith [sq_nonneg x, sq_nonneg (x ^ 2)]

theorem pathRatio_pos (x : ℝ) (hx : 0 < x) : 0 < pathRatio x :=
  div_pos (pow_pos hx 4) (pathDenominator_pos x)

theorem pathSlope_pos (x : ℝ) (hx : 0 < x) : 0 < pathSlope x := by
  apply div_pos _ (pathDenominator_pos x)
  exact mul_pos hx (by nlinarith [sq_nonneg x])

theorem pathRatio_le_third (x : ℝ) (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    pathRatio x ≤ 1 / 3 := by
  have hx2 : x ^ 2 ≤ 1 := by nlinarith
  have hp := mul_nonneg (sub_nonneg.mpr hx2) (show 0 ≤ 1 + 2 * x ^ 2 by nlinarith [sq_nonneg x])
  apply (div_le_iff₀ (pathDenominator_pos x)).mpr
  nlinarith

def pathStep (x y : ℝ) (z : ℝ × ℝ) : ℝ × ℝ :=
  (z.1 + x * z.2, y * x * z.1 + y * z.2)

def pathFlip (z : ℝ × ℝ) : ℝ × ℝ := (z.1, -z.2)

/-- Alternating edge increments six and two, with loop increment four,
give an exactly upper-triangular two-step transfer. -/
theorem path_two_step_triangular (x : ℝ) (z : ℝ × ℝ) :
    pathStep (x ^ 3) (x ^ 2) (pathFlip (pathStep x (x ^ 2) z)) =
      ((1 - x ^ 6) * (z.1 + pathSlope x * z.2),
        -(1 - x ^ 6) * pathRatio x * z.2) := by
  have hd := (pathDenominator_pos x).ne'
  apply Prod.ext <;> simp only [pathStep, pathFlip, pathSlope, pathRatio]
    <;> field_simp <;> ring

/-- Once the common positive factors and boundary terms are removed,
the scalar transfer distinguishes every finite signed digit string. -/
theorem path_signed_digits_injective (x : ℝ) (hx0 : 0 < x) (hx1 : x ≤ 1) :
    Function.Injective (signedSeries (pathRatio x)) :=
  signedSeries_injective _ (pathRatio_pos x hx0) (pathRatio_le_third x hx0.le hx1)

end NeuralGeneralization.OnlineLower
