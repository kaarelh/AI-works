import NeuralGeneralization.OnlineLowerBernsteinAverage
import NeuralGeneralization.OnlineLowerBernsteinLaplace
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals
import Mathlib.Analysis.Calculus.FDeriv.Measurable

/-! Positivity and actual integration-by-parts identity for the ReLU kernel. -/

noncomputable section
open MeasureTheory Set Filter
open scoped Topology

namespace NeuralGeneralization.OnlineLowerBernstein

theorem B_continuous : Continuous B :=
  continuous_iff_continuousAt.mpr fun t => (B_hasDerivAt t).continuousAt

theorem Bprime_continuous : Continuous Bprime :=
  continuous_iff_continuousAt.mpr fun t => (Bprime_hasDerivAt t).continuousAt

theorem Bsecond_measurable : Measurable Bsecond := by
  have he : Bsecond = deriv Bprime := funext fun t => (Bprime_hasDerivAt t).deriv.symm
  rw [he]
  exact measurable_deriv Bprime

theorem positiveKernel_integral (t : ℝ) :
    positiveKernel t = ∫ u,
      u * kernelPrime (t * u) / 2 - u ^ 2 * kernelSecond (t * u) ∂arcsineMeasure := by
  have h₁ := arcAverage_integrable 1 kernelPrime (1 / 2) t
    kernelPrime_continuous (by norm_num) kernelPrime_abs_bound
  have h₂ := arcAverage_integrable 2 kernelSecond (5 / 4) t
    kernelSecond_continuous (by norm_num) kernelSecond_abs_bound
  simp only [pow_one] at h₁
  unfold positiveKernel Bprime Bsecond arcAverage
  simp only [pow_one]
  rw [integral_sub (h₁.div_const 2) h₂, integral_div]

theorem positiveKernel_pos (t : ℝ) : 0 < positiveKernel t := by
  have h₁ := arcAverage_integrable 1 kernelPrime (1 / 2) t
    kernelPrime_continuous (by norm_num) kernelPrime_abs_bound
  have h₂ := arcAverage_integrable 2 kernelSecond (5 / 4) t
    kernelSecond_continuous (by norm_num) kernelSecond_abs_bound
  simp only [pow_one] at h₁
  have hp : ∀ᵐ u ∂arcsineMeasure,
      (0 : ℝ) < u * kernelPrime (t * u) / 2 - u ^ 2 * kernelSecond (t * u) := by
    filter_upwards [arcsine_ae_mem] with u hu
    exact positive_bernstein_integrand t u hu.1 hu.2.le
  have hi := NeuralGeneralization.OnlineLower.integral_strict_mono_of_ae_lt
    arcsineMeasure (NeZero.ne arcsineMeasure) (integrable_const (0 : ℝ))
    ((h₁.div_const 2).sub h₂) hp
  simpa [positiveKernel_integral] using hi

theorem positiveKernel_abs_bound (t : ℝ) :
    |positiveKernel t| ≤ 2 * Real.exp (|t| / 2) := by
  have hp := Bprime_abs_bound t
  have hpp := Bsecond_abs_bound t
  have he := (Real.exp_pos (|t| / 2)).le
  have htriangle : |positiveKernel t| ≤ |Bprime t| / 2 + |Bsecond t| := by
    unfold positiveKernel
    rw [sub_eq_add_neg]
    have h := abs_add_le (Bprime t / 2) (-Bsecond t)
    simpa [abs_div] using h
  linarith

theorem weighted_exp_bound (z C : ℝ) (f : ℝ → ℝ) (hC : 0 ≤ C)
    (hf : ∀ t, |f t| ≤ C * Real.exp (|t| / 2)) (t : ℝ) (ht : 0 ≤ t) :
    ‖Real.exp (-z * t) * f t‖ ≤ C * Real.exp ((1 / 2 - z) * t) := by
  have h := mul_le_mul_of_nonneg_left (hf t) (Real.exp_pos (-z * t)).le
  rw [abs_of_nonneg ht] at h
  calc
    _ = Real.exp (-z * t) * |f t| := by
      rw [Real.norm_eq_abs, abs_mul, abs_of_pos (Real.exp_pos _)]
    _ ≤ Real.exp (-z * t) * (C * Real.exp (t / 2)) := h
    _ = C * Real.exp ((1 / 2 - z) * t) := by
      rw [mul_left_comm, ← Real.exp_add]
      congr 2
      ring

theorem laplaceIntegrable_of_exp_bound (z C : ℝ) (f : ℝ → ℝ)
    (hz : 1 / 2 < z) (hC : 0 ≤ C) (hm : Measurable f)
    (hf : ∀ t, |f t| ≤ C * Real.exp (|t| / 2)) : LaplaceIntegrable z f := by
  have hi := (integrableOn_exp_mul_Ioi (show (1 / 2 : ℝ) - z < 0 by linarith) 0).const_mul C
  apply hi.mono' ?_ ?_
  · exact ((Real.continuous_exp.comp (continuous_const.mul continuous_id)).measurable.mul hm).aestronglyMeasurable
  · filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    exact weighted_exp_bound z C f hC hf t ht.le

theorem laplace_boundary_zero_of_exp_bound (z C : ℝ) (f : ℝ → ℝ)
    (hz : 1 / 2 < z) (hC : 0 ≤ C)
    (hf : ∀ t, |f t| ≤ C * Real.exp (|t| / 2)) :
    Tendsto (fun t => Real.exp (-z * t) * f t) atTop (𝓝 0) := by
  have hlim : Tendsto (fun t : ℝ => C * Real.exp ((1 / 2 - z) * t)) atTop (𝓝 0) := by
    have hneg := Tendsto.const_mul_atTop_of_neg (show (1 / 2 : ℝ) - z < 0 by linarith)
      (tendsto_id : Tendsto (fun t : ℝ => t) atTop atTop)
    simpa using (Real.tendsto_exp_atBot.comp hneg).const_mul C
  apply squeeze_zero_norm' ?_ hlim
  filter_upwards [eventually_ge_atTop (0 : ℝ)] with t ht
  exact weighted_exp_bound z C f hC hf t ht

theorem B_laplaceIntegrable {z : ℝ} (hz : 1 / 2 < z) : LaplaceIntegrable z B :=
  laplaceIntegrable_of_exp_bound z 1 B hz (by norm_num) B_continuous.measurable
    (fun t => by simpa using B_abs_bound t)

theorem Bprime_laplaceIntegrable {z : ℝ} (hz : 1 / 2 < z) : LaplaceIntegrable z Bprime :=
  laplaceIntegrable_of_exp_bound z (1 / 2) Bprime hz (by norm_num) Bprime_continuous.measurable
    Bprime_abs_bound

theorem Bsecond_laplaceIntegrable {z : ℝ} (hz : 1 / 2 < z) : LaplaceIntegrable z Bsecond :=
  laplaceIntegrable_of_exp_bound z (5 / 4) Bsecond hz (by norm_num) Bsecond_measurable
    Bsecond_abs_bound

theorem actual_bernstein_laplace_identity {z : ℝ} (hz : 1 / 2 < z) :
    z * (z - 1 / 2) * laplace z B = z - 3 / 8 - laplace z positiveKernel := by
  have h := bernstein_laplace_identity z B Bprime Bsecond
    (fun t _ => B_hasDerivAt t) (fun t _ => Bprime_hasDerivAt t)
    (B_laplaceIntegrable hz) (Bprime_laplaceIntegrable hz) (Bsecond_laplaceIntegrable hz)
    (laplace_boundary_zero_of_exp_bound z 1 B hz (by norm_num)
      (fun t => by simpa using B_abs_bound t))
    (laplace_boundary_zero_of_exp_bound z (1 / 2) Bprime hz (by norm_num) Bprime_abs_bound)
    B_zero Bprime_zero
  change z * (z - 1 / 2) * laplace z B = z - 3 / 8 -
    laplace z (fun t => Bprime t / 2 - Bsecond t)
  simpa only [div_eq_mul_inv, mul_comm, one_mul] using h

end NeuralGeneralization.OnlineLowerBernstein
