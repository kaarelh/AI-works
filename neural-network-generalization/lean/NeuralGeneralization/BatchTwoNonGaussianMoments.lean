import NeuralGeneralization.BatchTwoNonGaussianDensity
import Mathlib.Analysis.Convex.Integral
import Mathlib.Analysis.Convex.SpecificFunctions.Basic

/-! The exponentially weighted cubic moment required by relative Lindeberg is
finite for every actual coordinate law in the paper. -/

noncomputable section
open MeasureTheory
namespace NeuralGeneralization.BatchTwoNonGaussian
namespace CoordinateLaw

theorem abs_integrable (ν : CoordinateLaw) : Integrable (fun x : ℝ => |x|) ν.law := by
  apply ((ν.square_integrable.add (integrable_const (1 : ℝ))).div_const 2).mono' (by fun_prop)
  filter_upwards [] with x
  rw [Real.norm_eq_abs, abs_abs]
  change |x| ≤ (x ^ 2 + 1) / 2
  have h := sq_nonneg (|x| - 1)
  rw [sub_sq, sq_abs] at h
  nlinarith

theorem integral_abs_le_one (ν : CoordinateLaw) : (∫ x : ℝ, |x| ∂ν.law) ≤ 1 := by
  have h := integral_mono ν.abs_integrable
    ((ν.square_integrable.add (integrable_const (1 : ℝ))).div_const 2)
    (fun x => by
      change |x| ≤ (x ^ 2 + 1) / 2
      have hx := sq_nonneg (|x| - 1)
      rw [sub_sq, sq_abs] at hx
      nlinarith)
  simp only [Pi.add_apply] at h
  rw [integral_div, integral_add ν.square_integrable (integrable_const (1 : ℝ)),
    ν.square_integral] at h
  simpa using h

theorem integrable_id (ν : CoordinateLaw) : Integrable (fun x : ℝ => x) ν.law := by
  exact ν.abs_integrable.mono' (by fun_prop) (ae_of_all _ (fun _ => by simp))

theorem exp_neg_abs_integrable (ν : CoordinateLaw) (ell : ℝ) (hell : 0 ≤ ell) :
    Integrable (fun x : ℝ => Real.exp (-ell * |x|)) ν.law := by
  apply Integrable.of_bound (by fun_prop) 1
  filter_upwards [] with x
  rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
  exact Real.exp_le_one_iff.mpr (mul_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr hell) (abs_nonneg x))

/-- Jensen's lower bound used to normalize each Lindeberg replacement. -/
theorem integral_exp_neg_abs_lower (ν : CoordinateLaw) (ell : ℝ) (hell : 0 ≤ ell) (hell1 : ell ≤ 1) :
    Real.exp (-1) ≤ ∫ x : ℝ, Real.exp (-ell * |x|) ∂ν.law := by
  have hj := convexOn_exp.map_integral_le Real.continuous_exp.continuousOn
    isClosed_univ (ae_of_all ν.law (fun _ => Set.mem_univ _))
    (ν.abs_integrable.const_mul (-ell)) (ν.exp_neg_abs_integrable ell hell)
  rw [integral_const_mul] at hj
  have he : -1 ≤ -ell * (∫ x : ℝ, |x| ∂ν.law) := by
    have h0 : 0 ≤ ∫ x : ℝ, |x| ∂ν.law := integral_nonneg (fun x => abs_nonneg x)
    nlinarith [ν.integral_abs_le_one]
  exact (Real.exp_le_exp.mpr he).trans hj

private theorem abs_le_quadratic (m x : ℝ) (hm : 0 < m) :
    |x| ≤ m / 4 * x ^ 2 + 1 / m := by
  have hm0 : m ≠ 0 := hm.ne'
  have h := sq_nonneg (m * |x| - 2)
  rw [sub_sq, mul_pow, sq_abs] at h
  have hmul : m * (1 / m) = 1 := by field_simp
  have hscaled : m * |x| ≤ m * (m / 4 * x ^ 2 + 1 / m) := by nlinarith
  exact le_of_mul_le_mul_left hscaled hm

theorem cubic_exp_density_bound (ν : CoordinateLaw) (x : ℝ) :
    ν.density x * (|x| ^ 3 * Real.exp |x|) ≤
      (Real.exp (-ν.potential 0 + 1 / ν.lowerCurvature) / ν.normalizer) *
        (|x| ^ 3 * Real.exp (-(ν.lowerCurvature / 4) * x ^ 2)) := by
  have hquad := (ν.quadratic_envelopes x).1
  have habs := abs_le_quadratic ν.lowerCurvature x ν.lowerCurvature_pos
  have hexp : Real.exp (-ν.potential x + |x|) ≤
      Real.exp (-ν.potential 0 + 1 / ν.lowerCurvature) *
        Real.exp (-(ν.lowerCurvature / 4) * x ^ 2) := by
    rw [← Real.exp_add]
    apply Real.exp_le_exp.mpr
    nlinarith
  have h := mul_le_mul_of_nonneg_left hexp
    (div_nonneg (pow_nonneg (abs_nonneg x) 3) ν.normalizer_pos.le)
  unfold density
  rw [Real.exp_add] at h
  convert! h using 1 <;> ring

/-- The moment in the paper's relative Lindeberg constant is not an assumption. -/
theorem cubic_exp_integrable (ν : CoordinateLaw) :
    Integrable (fun x : ℝ => |x| ^ 3 * Real.exp |x|) ν.law := by
  apply (ν.integrable_iff_density _).mpr
  have hraw : Integrable (fun x : ℝ => x ^ 3 * Real.exp (-(ν.lowerCurvature / 4) * x ^ 2)) := by
    simpa only [Real.rpow_natCast] using
      (integrable_rpow_mul_exp_neg_mul_sq (div_pos ν.lowerCurvature_pos (by norm_num))
        (by norm_num : (-1 : ℝ) < (3 : ℕ)))
  have habs : Integrable (fun x : ℝ => |x| ^ 3 * Real.exp (-(ν.lowerCurvature / 4) * x ^ 2)) := by
    simpa only [Real.norm_eq_abs, abs_mul, abs_pow, abs_of_pos (Real.exp_pos _)] using hraw.norm
  have hmajor := habs.const_mul
    (Real.exp (-ν.potential 0 + 1 / ν.lowerCurvature) / ν.normalizer)
  apply hmajor.mono' (by fun_prop)
  filter_upwards [] with x
  rw [Real.norm_eq_abs, abs_of_nonneg (mul_nonneg (ν.density_nonneg x)
    (mul_nonneg (pow_nonneg (abs_nonneg x) 3) (Real.exp_nonneg _)))]
  exact ν.cubic_exp_density_bound x

end CoordinateLaw
end NeuralGeneralization.BatchTwoNonGaussian
