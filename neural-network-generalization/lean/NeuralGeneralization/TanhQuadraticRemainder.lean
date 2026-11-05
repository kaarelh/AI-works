import NeuralGeneralization.TanhScalarJet
import NeuralGeneralization.BatchTwoNonGaussianCurvature

/-! A global second-order remainder for the actual tanh activation. -/
noncomputable section
namespace NeuralGeneralization.TanhDifferential

/-- The bound needed for the paper's factor `1/2` in Taylor's remainder. -/
theorem abs_tanhSecond_le_one (x : ℝ) : |tanhSecond x| ≤ 1 := by
  have ht0 := abs_nonneg (Real.tanh x)
  have ht1 := (Real.abs_tanh_lt_one x).le
  have hs : |Real.tanh x| ^ 2 = Real.tanh x ^ 2 := sq_abs _
  have he : |tanhSecond x| = 2 * |Real.tanh x| * (1 - |Real.tanh x| ^ 2) := by
    simp only [tanhSecond, abs_mul, abs_of_nonneg (tanhFirst_nonneg x)]
    rw [show |(-2 : ℝ)| = 2 by norm_num]
    rw [tanhFirst, hs]
  rw [he]
  by_cases h : |Real.tanh x| ≤ 1/2
  · nlinarith [mul_nonneg ht0 (sq_nonneg |Real.tanh x|)]
  · have hp := mul_nonneg (show 0 ≤ 2 * |Real.tanh x| - 1 by linarith)
      (sq_nonneg |Real.tanh x|)
    nlinarith [sq_nonneg (1 - |Real.tanh x|)]

/-- Uniform Taylor control about an arbitrary clean preactivation. -/
theorem quadratic_remainder (a h : ℝ) :
    |Real.tanh (a+h) - Real.tanh a - tanhFirst a * h| ≤ h^2/2 := by
  have hl := BatchTwoNonGaussian.quadratic_lower_of_curvature
    hasDerivAt_tanh_first hasDerivAt_tanhFirst
    (m := -1) (fun x => (abs_le.mp (abs_tanhSecond_le_one x)).1) a (a+h)
  have hu := BatchTwoNonGaussian.quadratic_upper_of_curvature
    hasDerivAt_tanh_first hasDerivAt_tanhFirst
    (M := 1) (fun x => (abs_le.mp (abs_tanhSecond_le_one x)).2) a (a+h)
  apply abs_le.mpr
  constructor <;> linarith

end NeuralGeneralization.TanhDifferential
