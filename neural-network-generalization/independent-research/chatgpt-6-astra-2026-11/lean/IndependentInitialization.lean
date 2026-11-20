import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic

/-!
Exact trigonometric ingredients for the independent discrete-initialization
comparison. The Fourier integral, probability arguments, and asymptotic
kernel theorems are not formalized by this file.
-/
namespace IndependentResearch

theorem mixed_lattice_sine_identity (t : ℝ) :
    ((Real.sin t) ^ 2 + (Real.sin (2 * t)) ^ 2) / 2 =
      (25 : ℝ) / 32 - 2 * ((Real.sin t) ^ 2 - 5 / 8) ^ 2 := by
  rw [Real.sin_two_mul]
  have h := congrArg (fun z : ℝ => (Real.sin t) ^ 2 * z)
    (Real.sin_sq_add_cos_sq t)
  nlinarith [h]

/-- Exact sine-gap upper bound for uniform weights on {±1,±2}. -/
theorem mixed_lattice_sine_upper (t : ℝ) :
    ((Real.sin t) ^ 2 + (Real.sin (2 * t)) ^ 2) / 2 ≤ (25 : ℝ) / 32 := by
  rw [mixed_lattice_sine_identity]
  nlinarith [sq_nonneg ((Real.sin t) ^ 2 - 5 / 8)]

/-- Every odd integer multiple of one lattice spacing has zero cosine
at the common half-period, including negative odd integers. -/
theorem odd_lattice_cos_zero (a : ℝ) (ha : a ≠ 0) (k : ℤ) :
    Real.cos ((Real.pi / (2 * a)) * (a * (2 * (k : ℝ) + 1))) = 0 := by
  have heq : (Real.pi / (2 * a)) * (a * (2 * (k : ℝ) + 1)) =
      Real.pi / 2 + (k : ℝ) * Real.pi := by field_simp; ring
  rw [heq, Real.cos_add_int_mul_pi, Real.cos_pi_div_two, mul_zero]

/-- The corresponding sine is a unit Boolean-valued witness. -/
theorem odd_lattice_sine_sq (a : ℝ) (ha : a ≠ 0) (k : ℤ) :
    (Real.sin ((Real.pi / (2 * a)) * (a * (2 * (k : ℝ) + 1)))) ^ 2 = 1 := by
  have h := Real.sin_sq_add_cos_sq ((Real.pi / (2 * a)) * (a * (2 * (k : ℝ) + 1)))
  rw [odd_lattice_cos_zero a ha k] at h
  nlinarith

/-- Exact resonant witness identity used before averaging over the
odd-lattice law. No distributional or asymptotic premise is hidden here. -/
theorem odd_lattice_witness (a : ℝ) (ha : a ≠ 0) (k : ℤ) (t : ℝ) :
    Real.sin ((Real.pi / (2 * a)) * (a * (2 * (k : ℝ) + 1))) *
      Real.sin (t * (a * (2 * (k : ℝ) + 1))) =
    Real.cos ((t - Real.pi / (2 * a)) * (a * (2 * (k : ℝ) + 1))) := by
  rw [sub_mul, Real.cos_sub, odd_lattice_cos_zero a ha k, mul_zero, zero_add]
  ring

end IndependentResearch
