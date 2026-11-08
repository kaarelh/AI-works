import NeuralGeneralization.OnlineLowerBernsteinAlgebra
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic
import Mathlib.Analysis.Complex.Exponential

/-!
# Exponentially tilted moments on the unit interval

These are the actual integrals used to obtain the ReLU Bernstein kernel.
In particular the moment Cauchy inequality is proved from a nonnegative
variance integral, rather than assumed as an analytic certificate.
-/

noncomputable section
open MeasureTheory Set

namespace NeuralGeneralization.OnlineLowerBernstein

def moment (j : ℕ) (t : ℝ) : ℝ :=
  ∫ u in (0 : ℝ)..1, u ^ j * Real.exp (-u * t)

theorem momentIntegrand_continuous (j : ℕ) (t : ℝ) :
    Continuous (fun u : ℝ => u ^ j * Real.exp (-u * t)) :=
  (continuous_id.pow j).mul
    (Real.continuous_exp.comp (continuous_id.neg.mul_const t))

theorem momentIntegrand_integrable (j : ℕ) (t : ℝ) :
    IntervalIntegrable (fun u : ℝ => u ^ j * Real.exp (-u * t)) volume 0 1 :=
  (momentIntegrand_continuous j t).intervalIntegrable 0 1

theorem moment_pos (j : ℕ) (t : ℝ) : 0 < moment j t := by
  unfold moment
  apply intervalIntegral.integral_pos (by norm_num)
    (momentIntegrand_continuous j t).continuousOn
  · intro u hu
    exact mul_nonneg (pow_nonneg hu.1.le j) (Real.exp_pos _).le
  · refine ⟨1 / 2, by norm_num, ?_⟩
    exact mul_pos (pow_pos (by norm_num) j) (Real.exp_pos _)

theorem moment_one_lt_zero (t : ℝ) : moment 1 t < moment 0 t := by
  unfold moment
  apply intervalIntegral.integral_lt_integral_of_continuousOn_of_le_of_exists_lt
    (by norm_num) (momentIntegrand_continuous 1 t).continuousOn
    (momentIntegrand_continuous 0 t).continuousOn
  · intro u hu
    simp only [pow_one, pow_zero, one_mul]
    exact mul_le_of_le_one_left (Real.exp_pos _).le hu.2
  · refine ⟨0, by norm_num, ?_⟩
    norm_num

theorem moment_le_zero (j : ℕ) (t : ℝ) : moment j t ≤ moment 0 t := by
  apply intervalIntegral.integral_mono_on (by norm_num)
    (momentIntegrand_integrable j t) (momentIntegrand_integrable 0 t)
  intro u hu
  simp only [pow_zero, one_mul]
  exact mul_le_of_le_one_left (Real.exp_pos _).le (pow_le_one₀ hu.1 hu.2)

theorem moment_zero_lower_bound (t : ℝ) : Real.exp (-|t|) ≤ moment 0 t := by
  have hconst : IntervalIntegrable (fun _ : ℝ => Real.exp (-|t|)) volume 0 1 :=
    intervalIntegrable_const
  have h := intervalIntegral.integral_mono_on (by norm_num : (0 : ℝ) ≤ 1)
    hconst (momentIntegrand_integrable 0 t) ?_
  · simpa [moment] using h
  · intro u hu
    simp only [pow_zero, one_mul]
    apply Real.exp_le_exp.mpr
    have hmul : u * t ≤ |t| := by
      calc
        u * t ≤ |u * t| := le_abs_self _
        _ = u * |t| := by rw [abs_mul, abs_of_nonneg hu.1]
        _ ≤ |t| := mul_le_of_le_one_left (abs_nonneg t) hu.2
    linarith

theorem variance_integral (t c : ℝ) :
    (∫ u in (0 : ℝ)..1, (u - c) ^ 2 * Real.exp (-u * t)) =
      moment 2 t - 2 * c * moment 1 t + c ^ 2 * moment 0 t := by
  have h₀ := momentIntegrand_integrable 0 t
  have h₁ := momentIntegrand_integrable 1 t
  have h₂ := momentIntegrand_integrable 2 t
  calc
    _ = ∫ u in (0 : ℝ)..1,
        (u ^ 2 * Real.exp (-u * t) - 2 * c * (u ^ 1 * Real.exp (-u * t)))
          + c ^ 2 * (u ^ 0 * Real.exp (-u * t)) := by
      apply intervalIntegral.integral_congr
      intro u hu
      ring
    _ = _ := by
      rw [intervalIntegral.integral_add (h₂.sub (h₁.const_mul (2 * c)))
        (h₀.const_mul (c ^ 2)),
        intervalIntegral.integral_sub h₂ (h₁.const_mul (2 * c)),
        intervalIntegral.integral_const_mul, intervalIntegral.integral_const_mul]
      rfl

theorem moment_cauchy (t : ℝ) : moment 1 t ^ 2 ≤ moment 0 t * moment 2 t := by
  have h₀ := moment_pos 0 t
  have hv : 0 ≤ ∫ u in (0 : ℝ)..1,
      (u - moment 1 t / moment 0 t) ^ 2 * Real.exp (-u * t) := by
    apply intervalIntegral.integral_nonneg_of_forall (by norm_num)
    intro u
    exact mul_nonneg (sq_nonneg _) (Real.exp_pos _).le
  rw [variance_integral] at hv
  have hmul := mul_nonneg h₀.le hv
  field_simp at hmul
  nlinarith

/-- The actual moment values satisfy all premises of the kernel-positivity
algebra, for every real tilt parameter, including at zero. -/
theorem actual_secondKernelDerivative_lt_half_first (t : ℝ) :
    secondKernelDerivative (moment 0 t) (moment 1 t) (moment 2 t) <
      firstKernelDerivative (moment 0 t) (moment 1 t) / 2 :=
  secondKernelDerivative_lt_half_first _ _ _ (moment_pos 0 t)
    (moment_pos 1 t) (moment_one_lt_zero t) (moment_cauchy t)

end NeuralGeneralization.OnlineLowerBernstein
