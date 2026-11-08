import NeuralGeneralization.OnlineLowerBernsteinTransform
import Mathlib.Analysis.Convolution
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic
import Mathlib.MeasureTheory.Integral.Gamma

noncomputable section
open MeasureTheory Set ProbabilityTheory

namespace NeuralGeneralization.OnlineLowerBernstein

theorem moment_zero_explicit {t : ℝ} (ht : t ≠ 0) :
    moment 0 t = (1 - Real.exp (-t)) / t := by
  unfold moment
  simp only [pow_zero, one_mul, neg_mul]
  have he := intervalIntegral.integral_comp_mul_right Real.exp (neg_ne_zero.mpr ht)
    (a := (0 : ℝ)) (b := 1)
  simp only [zero_mul, one_mul, integral_exp, neg_zero, Real.exp_zero,
    smul_eq_mul, mul_neg] at he
  rw [he]
  field_simp
  <;> ring

theorem kernel_explicit {t : ℝ} (ht : 0 < t) :
    kernel t = t ^ (1 / 2 : ℝ) * betaLaplaceKernel t := by
  have hn : 0 < 1 - Real.exp (-t) := by
    have : Real.exp (-t) < 1 := Real.exp_lt_one_iff.mpr (by linarith)
    linarith
  rw [kernel, moment_zero_explicit ht.ne', Real.sqrt_div hn.le]
  rw [betaLaplaceKernel, Real.rpow_neg hn.le, ← Real.sqrt_eq_rpow]
  rw [← Real.sqrt_eq_rpow]
  field_simp

theorem arcsine_integral_density (f : ℝ → ℝ) :
    (∫ u, f u ∂arcsineMeasure) =
      (1 / beta (1/2) (1/2)) *
        ∫ u in Ioo (0 : ℝ) 1, u ^ (-(1/2 : ℝ)) * (1-u) ^ (-(1/2 : ℝ)) * f u := by
  unfold arcsineMeasure betaMeasure
  rw [integral_withDensity_eq_integral_toReal_smul
    (by unfold betaPDF; fun_prop)
    (by filter_upwards [] with x; exact ENNReal.ofReal_lt_top)]
  have he : (fun x : ℝ => (betaPDF (1/2) (1/2) x).toReal • f x) =
      (Ioo (0 : ℝ) 1).indicator
        (fun x => (1 / beta (1/2) (1/2)) *
          (x ^ (-(1/2 : ℝ)) * (1-x) ^ (-(1/2 : ℝ)) * f x)) := by
    funext x
    by_cases hx : x ∈ Ioo (0 : ℝ) 1
    · rw [Set.indicator_of_mem hx]
      change 0 < x ∧ x < 1 at hx
      simp only [betaPDF, betaPDFReal, if_pos hx]
      have hb : 0 < beta (1/2) (1/2) := beta_pos (by norm_num) (by norm_num)
      rw [ENNReal.toReal_ofReal (mul_nonneg
        (mul_nonneg (one_div_nonneg.mpr hb.le) (Real.rpow_nonneg hx.1.le _))
        (Real.rpow_nonneg (sub_nonneg.mpr hx.2.le) _))]
      norm_num only [show (1/2 : ℝ)-1 = -(1/2 : ℝ) by ring, smul_eq_mul]
      ring
    · rw [Set.indicator_of_notMem hx]
      change ¬(0 < x ∧ x < 1) at hx
      simp [betaPDF, betaPDFReal, hx]
  rw [he, integral_indicator measurableSet_Ioo, integral_const_mul]

theorem convolution_integrand (t u : ℝ) (ht : 0 < t) (hu : u ∈ Ioo (0 : ℝ) 1) :
    u ^ (-(1/2 : ℝ)) * (1-u) ^ (-(1/2 : ℝ)) * kernel (t*u) =
      t * (betaLaplaceKernel (t*u) * (t-t*u) ^ (-(1/2 : ℝ))) := by
  rw [kernel_explicit (mul_pos ht hu.1), Real.mul_rpow ht.le hu.1.le]
  have hcancel : u ^ (-(1/2 : ℝ)) * u ^ (1/2 : ℝ) = 1 := by
    rw [← Real.rpow_add hu.1]
    norm_num
  have hcancelT : t * t ^ (-(1/2 : ℝ)) = t ^ (1/2 : ℝ) := by
    nth_rw 1 [← Real.rpow_one t]
    rw [← Real.rpow_add ht]
    norm_num
  rw [show t-t*u = t*(1-u) by ring, Real.mul_rpow ht.le (sub_nonneg.mpr hu.2.le)]
  calc
    _ = (u ^ (-(1/2 : ℝ)) * u ^ (1/2 : ℝ)) *
      t ^ (1/2 : ℝ) * (1-u) ^ (-(1/2 : ℝ)) * betaLaplaceKernel (t*u) := by ring
    _ = _ := by rw [hcancel]; simp only [one_mul]; rw [← hcancelT]; ring

theorem B_convolution {t : ℝ} (ht : 0 < t) :
    B t = (1 / beta (1/2) (1/2)) *
      ∫ s in (0 : ℝ)..t, betaLaplaceKernel s * (t-s) ^ (-(1/2 : ℝ)) := by
  simp only [B, arcAverage, pow_zero, one_mul]
  rw [arcsine_integral_density]
  congr 1
  have hs := intervalIntegral.mul_integral_comp_mul_left
    t (f := fun s => betaLaplaceKernel s * (t-s) ^ (-(1/2 : ℝ))) (a := 0) (b := 1)
  simp only [mul_zero, mul_one] at hs
  rw [← hs]
  rw [intervalIntegral.integral_of_le (by norm_num : (0 : ℝ) ≤ 1),
    integral_Ioc_eq_integral_Ioo, ← integral_const_mul]
  exact setIntegral_congr_fun measurableSet_Ioo fun u hu => convolution_integrand t u ht hu


theorem integrable_halfPower_laplace {z : ℝ} (hz : 0 < z) :
    IntegrableOn (fun t : ℝ => Real.exp (-z*t) * t ^ (-(1/2 : ℝ))) (Ioi 0) := by
  have hi := (integrableOn_Ioi_comp_mul_left_iff
    (fun t : ℝ => Real.exp (-t) * t ^ ((1/2 : ℝ)-1)) 0 hz).mpr
      (by simpa only [mul_zero] using Real.GammaIntegral_convergent (by norm_num : (0 : ℝ)<1/2))
  have hc := hi.const_mul (z ^ (1/2 : ℝ))
  apply hc.congr
  filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
  rw [show (1/2 : ℝ)-1 = -(1/2 : ℝ) by ring, Real.mul_rpow hz.le ht.le]
  have hc : z ^ (1/2 : ℝ) * z ^ (-(1/2 : ℝ)) = 1 := by
    rw [← Real.rpow_add hz]; norm_num
  calc
    _ = (z ^ (1/2 : ℝ) * z ^ (-(1/2 : ℝ))) *
      (Real.exp (-z*t) * t ^ (-(1/2 : ℝ))) := by ring
    _ = _ := by rw [hc, one_mul]

theorem laplace_halfPower {z : ℝ} (hz : 0 < z) :
    (∫ t in Ioi (0 : ℝ), Real.exp (-z*t) * t ^ (-(1/2 : ℝ))) =
      Real.Gamma (1/2) / Real.sqrt z := by
  have hi := integral_rpow_mul_exp_neg_mul_rpow (p := (1 : ℝ))
    (q := -(1/2 : ℝ)) (b := z) (by norm_num) (by norm_num) hz
  norm_num only [Real.rpow_one, one_div, one_mul, div_one,
    show (-(1/2 : ℝ))+1 = 1/2 by ring, mul_one] at hi
  rw [show (fun t : ℝ => Real.exp (-z*t) * t ^ (-(1/2 : ℝ))) =
    (fun t : ℝ => t ^ (-(1/2 : ℝ)) * Real.exp (-z*t)) by funext t; ring, hi]
  rw [Real.rpow_neg hz.le, ← Real.sqrt_eq_rpow]
  ring

theorem weighted_convolution (z t : ℝ) :
    Real.exp (-z*t) *
        (∫ s in (0 : ℝ)..t, betaLaplaceKernel s * (t-s) ^ (-(1/2 : ℝ))) =
      ∫ s in (0 : ℝ)..t,
        (Real.exp (-z*s) * betaLaplaceKernel s) *
          (Real.exp (-z*(t-s)) * (t-s) ^ (-(1/2 : ℝ))) := by
  rw [← intervalIntegral.integral_const_mul]
  congr 1
  funext s
  rw [show (Real.exp (-z*s) * betaLaplaceKernel s) *
    (Real.exp (-z*(t-s)) * (t-s) ^ (-(1/2 : ℝ))) =
    (Real.exp (-z*s) * Real.exp (-z*(t-s))) *
      (betaLaplaceKernel s * (t-s) ^ (-(1/2 : ℝ))) by ring,
    ← Real.exp_add, show -z*s + -z*(t-s) = -z*t by ring]

theorem laplace_B_gamma {z : ℝ} (hz : 0 < z) :
    laplace z B = Real.Gamma z / (Real.sqrt z * Real.Gamma (z+1/2)) := by
  unfold laplace
  calc
    _ = (1 / beta (1/2) (1/2)) *
      ∫ t in Ioi (0 : ℝ), ∫ s in (0 : ℝ)..t,
        (Real.exp (-z*s) * betaLaplaceKernel s) *
          (Real.exp (-z*(t-s)) * (t-s) ^ (-(1/2 : ℝ))) := by
      rw [← integral_const_mul]
      apply setIntegral_congr_fun measurableSet_Ioi
      intro t ht
      dsimp only
      rw [B_convolution ht]
      rw [mul_left_comm, weighted_convolution]
    _ = (1 / beta (1/2) (1/2)) *
      ((Real.Gamma z * Real.Gamma (1/2) / Real.Gamma (z+1/2)) *
        (Real.Gamma (1/2) / Real.sqrt z)) := by
      have hc := integral_posConvolution (integrable_betaLaplace hz)
        (integrable_halfPower_laplace hz) (ContinuousLinearMap.mul ℝ ℝ)
      simp only [ContinuousLinearMap.mul_apply'] at hc
      rw [hc, laplace_beta_kernel hz, laplace_halfPower hz]
    _ = _ := by
      have gh : Real.Gamma (1/2) ≠ 0 := (Real.Gamma_pos_of_pos (by norm_num)).ne'
      have gz : Real.Gamma (z+1/2) ≠ 0 := (Real.Gamma_pos_of_pos (by linarith)).ne'
      have sz : Real.sqrt z ≠ 0 := (Real.sqrt_pos.mpr hz).ne'
      norm_num [beta]
      field_simp
      <;> ring

end NeuralGeneralization.OnlineLowerBernstein

