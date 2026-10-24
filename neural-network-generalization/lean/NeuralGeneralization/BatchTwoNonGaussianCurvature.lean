import NeuralGeneralization.BatchTwoNonGaussianModel
import Mathlib.Analysis.Convex.Deriv
import Mathlib.Analysis.SpecialFunctions.Gaussian.GaussianIntegral

/-! Exact second-order supporting inequalities derived from the density's
curvature hypotheses. These are the analytic starting point for both the
small-scale rate and the translation estimate. -/

noncomputable section
open MeasureTheory Set
namespace NeuralGeneralization.BatchTwoNonGaussian

private theorem convex_support {f : ℝ → ℝ} {f' x : ℝ}
    (hc : ConvexOn ℝ univ f) (hd : HasDerivAt f f' x) (y : ℝ) :
    f x + f' * (y - x) ≤ f y := by
  rcases lt_trichotomy x y with h | h | h
  · have hs := hc.le_slope_of_hasDerivAt (mem_univ x) (mem_univ y) h hd
    rw [slope_def_field] at hs
    have hmul := (le_div_iff₀ (sub_pos.mpr h)).mp hs
    linarith
  · subst y
    simp
  · have hs := hc.slope_le_of_hasDerivAt (mem_univ y) (mem_univ x) h hd
    rw [slope_def_field] at hs
    have hmul := (div_le_iff₀ (sub_pos.mpr h)).mp hs
    nlinarith

/-- The lower Taylor inequality, with no assumed Taylor remainder bound. -/
theorem quadratic_lower_of_curvature {f f' f'' : ℝ → ℝ} {m : ℝ}
    (hf : ∀ x, HasDerivAt f (f' x) x)
    (hf' : ∀ x, HasDerivAt f' (f'' x) x)
    (hm : ∀ x, m ≤ f'' x) (x y : ℝ) :
    f x + f' x * (y - x) + m / 2 * (y - x) ^ 2 ≤ f y := by
  let F : ℝ → ℝ := fun t => f t - m / 2 * t ^ 2
  let F' : ℝ → ℝ := fun t => f' t - m * t
  have hF (t : ℝ) : HasDerivAt F (F' t) t := by
    convert! (hf t).sub (((hasDerivAt_id t).pow 2).const_mul (m / 2)) using 1 <;>
      (try dsimp [F, F']) <;> ring
  have hF' (t : ℝ) : HasDerivAt F' (f'' t - m) t := by
    simpa [F'] using! (hf' t).sub ((hasDerivAt_id t).const_mul m)
  have hFc : ConvexOn ℝ univ F := by
    apply convexOn_of_hasDerivWithinAt2_nonneg convex_univ
      (continuous_iff_continuousAt.mpr (fun t => (hF t).continuousAt)).continuousOn
      (fun t _ => (hF t).hasDerivWithinAt)
      (fun t _ => (hF' t).hasDerivWithinAt)
    intro t _
    exact sub_nonneg.mpr (hm t)
  have hs := convex_support hFc (hF x) y
  dsimp [F, F'] at hs
  nlinarith

/-- The upper Taylor inequality used in the non-Gaussian translation argument. -/
theorem quadratic_upper_of_curvature {f f' f'' : ℝ → ℝ} {M : ℝ}
    (hf : ∀ x, HasDerivAt f (f' x) x)
    (hf' : ∀ x, HasDerivAt f' (f'' x) x)
    (hM : ∀ x, f'' x ≤ M) (x y : ℝ) :
    f y ≤ f x + f' x * (y - x) + M / 2 * (y - x) ^ 2 := by
  have h := quadratic_lower_of_curvature (m := -M)
    (fun t => (hf t).neg) (fun t => (hf' t).neg)
    (fun t => neg_le_neg (hM t)) x y
  dsimp at h
  linarith

namespace CoordinateLaw

theorem potential_lower (ν : CoordinateLaw) (x y : ℝ) :
    ν.potential x + deriv ν.potential x * (y - x) +
      ν.lowerCurvature / 2 * (y - x) ^ 2 ≤ ν.potential y :=
  quadratic_lower_of_curvature ν.hasDerivAt_potential ν.hasDerivAt_deriv
    ν.curvature_lower x y

theorem potential_upper (ν : CoordinateLaw) (x y : ℝ) :
    ν.potential y ≤ ν.potential x + deriv ν.potential x * (y - x) +
      ν.upperCurvature / 2 * (y - x) ^ 2 :=
  quadratic_upper_of_curvature ν.hasDerivAt_potential ν.hasDerivAt_deriv
    ν.curvature_upper x y

theorem quadratic_envelopes (ν : CoordinateLaw) (x : ℝ) :
    ν.lowerCurvature / 2 * x ^ 2 ≤ ν.potential x - ν.potential 0 ∧
    ν.potential x - ν.potential 0 ≤ ν.upperCurvature / 2 * x ^ 2 := by
  have hl := ν.potential_lower 0 x
  have hu := ν.potential_upper 0 x
  simp only [ν.deriv_zero, zero_mul, sub_zero, add_zero] at hl hu
  constructor <;> linarith

theorem translated_potential_upper (ν : CoordinateLaw) (x a : ℝ) :
    ν.potential (x + a) - ν.potential x ≤
      a * deriv ν.potential x + ν.upperCurvature / 2 * a ^ 2 := by
  have h := ν.potential_upper x (x + a)
  simp only [add_sub_cancel_left] at h
  nlinarith

theorem exp_potential_upper (ν : CoordinateLaw) (x : ℝ) :
    Real.exp (-ν.potential x) ≤
      Real.exp (-ν.potential 0) * Real.exp (-(ν.lowerCurvature / 2) * x ^ 2) := by
  rw [← Real.exp_add]
  apply Real.exp_le_exp.mpr
  have h := (ν.quadratic_envelopes x).1
  nlinarith

theorem integrable_exp_potential (ν : CoordinateLaw) :
    Integrable (fun x : ℝ => Real.exp (-ν.potential x)) := by
  have h := (integrable_exp_neg_mul_sq (half_pos ν.lowerCurvature_pos)).const_mul
    (Real.exp (-ν.potential 0))
  apply h.mono' ((Real.continuous_exp.comp ν.smooth.continuous.neg).aestronglyMeasurable)
  filter_upwards [] with x
  change |Real.exp (-ν.potential x)| ≤ _
  rw [abs_of_pos (Real.exp_pos _)]
  exact ν.exp_potential_upper x

end CoordinateLaw
end NeuralGeneralization.BatchTwoNonGaussian
