import NeuralGeneralization.PowerSeriesEndpoint
import NeuralGeneralization.ArcsineCoefficients
import Mathlib.Analysis.Analytic.Binomial
import Mathlib.Analysis.SpecialFunctions.Trigonometric.InverseDeriv
import Mathlib.MeasureTheory.Integral.DominatedConvergence
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus

/-!
# The actual arcsine power series

This module derives the inverse-square-root derivative series from
mathlib's binomial series and integrates it to identify the actual
arcsine function. No spectral or arcsine-series certificate is assumed.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators Topology
open Filter Set MeasureTheory

theorem hasSum_arcsine_derivative {x : ℝ} (hx : |x| < 1) :
    HasSum (fun n => arcsineDerivativeCoefficient n * x ^ (2 * n))
      (1 / Real.sqrt (1 - x ^ 2)) := by
  have hball : x ^ 2 ∈ Metric.eball (0 : ℝ) 1 := by
    rw [← ENNReal.ofReal_one, Metric.eball_ofReal, Metric.mem_ball]
    rw [Real.dist_eq, sub_zero, abs_of_nonneg (sq_nonneg x)]
    exact (sq_lt_one_iff_abs_lt_one x).mpr hx
  have h := (Real.one_div_one_sub_rpow_hasFPowerSeriesOnBall_zero (1 / 2 : ℝ)).hasSum hball
  simpa only [FormalMultilinearSeries.ofScalars_apply_eq, smul_eq_mul, zero_add,
    ← Ring.multichoose_eq, ← Real.sqrt_eq_rpow, ← pow_mul, arcsineDerivativeCoefficient] using h

/-- Elementary monomial integral, proved directly from its derivative. -/
theorem intervalIntegral_monomial (n : ℕ) (x : ℝ) :
    (∫ t in (0 : ℝ)..x, t ^ n) = x ^ (n + 1) / (n + 1 : ℝ) := by
  have hderiv (t : ℝ) : HasDerivAt (fun y : ℝ => y ^ (n + 1) / (n + 1 : ℝ)) (t ^ n) t := by
    have h := (hasDerivAt_pow (n + 1) t).div_const (n + 1 : ℝ)
    have heq : (((n + 1 : ℕ) : ℝ) * t ^ ((n + 1) - 1)) / (n + 1 : ℝ) = t ^ n := by
      simp only [Nat.add_sub_cancel, Nat.cast_add, Nat.cast_one]
      field_simp
    rwa [heq] at h
  have h := intervalIntegral.integral_eq_sub_of_hasDerivAt
    (fun t ht => hderiv t) (Continuous.intervalIntegrable (by fun_prop) 0 x)
  simpa using h

/-- Integrating the actual binomial derivative series on an interior
interval identifies the odd-power series with `Real.arcsin`. -/
theorem hasSum_arcsine_nonneg_interior {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x < 1) :
    HasSum (fun n => arcsineCoefficient n * x ^ (2 * n + 1)) (Real.arcsin x) := by
  have hxabs : |x| < 1 := by simpa only [abs_of_nonneg hx0] using hx1
  have hsumx := hasSum_arcsine_derivative hxabs
  have hclosed {t : ℝ} (ht : t ∈ uIoc (0 : ℝ) x) : t ∈ Icc (0 : ℝ) x := by
    rw [uIoc_of_le hx0] at ht
    exact ⟨ht.1.le, ht.2⟩
  have ht_bounds {t : ℝ} (ht : t ∈ Icc (0 : ℝ) x) : |t| < 1 := by
    rw [abs_of_nonneg ht.1]
    exact ht.2.trans_lt hx1
  have hcontinuous : ContinuousOn (fun t : ℝ => 1 / Real.sqrt (1 - t ^ 2)) (Icc 0 x) := by
    apply continuousOn_const.div
    · exact (Real.continuous_sqrt.comp (continuous_const.sub (continuous_id.pow 2))).continuousOn
    · intro t ht
      apply ne_of_gt
      apply Real.sqrt_pos.mpr
      have hb := ht_bounds ht
      exact sub_pos.mpr ((sq_lt_one_iff_abs_lt_one t).mpr hb)
  have hintegral : (∫ t in (0 : ℝ)..x, 1 / Real.sqrt (1 - t ^ 2)) = Real.arcsin x := by
    have h := intervalIntegral.integral_eq_sub_of_hasDerivAt
      (fun t ht => Real.hasDerivAt_arcsin
        (by have hb := ht_bounds (by simpa only [uIcc_of_le hx0] using ht); exact ne_of_gt (abs_lt.mp hb).1)
        (by have hb := ht_bounds (by simpa only [uIcc_of_le hx0] using ht); exact ne_of_lt (abs_lt.mp hb).2))
      (hcontinuous.intervalIntegrable_of_Icc hx0)
    simpa only [Real.arcsin_zero, sub_zero] using h
  have h := intervalIntegral.hasSum_integral_of_dominated_convergence
    (a := (0 : ℝ)) (b := x) (μ := volume)
    (F := fun n t => arcsineDerivativeCoefficient n * t ^ (2 * n))
    (f := fun t => 1 / Real.sqrt (1 - t ^ 2))
    (fun n _ => arcsineDerivativeCoefficient n * x ^ (2 * n))
    (fun n => (show Continuous (fun t : ℝ => arcsineDerivativeCoefficient n * t ^ (2 * n)) by
      fun_prop).aestronglyMeasurable)
    (fun n => ae_of_all _ (fun t ht => by
      have ht' : t ∈ Icc (0 : ℝ) x := hclosed ht
      rw [Real.norm_eq_abs, abs_of_nonneg (mul_nonneg (arcsineDerivativeCoefficient_pos n).le
        (pow_nonneg ht'.1 _))]
      exact mul_le_mul_of_nonneg_left (pow_le_pow_left₀ ht'.1 ht'.2 _) (arcsineDerivativeCoefficient_pos n).le))
    (ae_of_all _ (fun t ht => hsumx.summable))
    intervalIntegrable_const
    (ae_of_all _ (fun t ht => hasSum_arcsine_derivative (ht_bounds (hclosed ht))))
  rw [hintegral] at h
  apply h.congr_fun
  intro n
  rw [intervalIntegral.integral_const_mul, intervalIntegral_monomial]
  simp only [arcsineCoefficient, Nat.cast_mul, Nat.cast_ofNat]
  ring

/-- Endpoint convergence is proved from nonnegative coefficients and
continuity; summability at one is not a premise. -/
theorem hasSum_arcsine_one : HasSum arcsineCoefficient (Real.arcsin 1) := by
  apply hasSum_nonnegative_powerSeries_endpoint arcsineCoefficient (fun n => 2 * n + 1)
    Real.arcsin (fun n => (arcsineCoefficient_pos n).le)
  · intro x hx0 hx1
    exact hasSum_arcsine_nonneg_interior hx0 hx1
  · exact Real.continuous_arcsin.continuousAt.tendsto.mono_left nhdsWithin_le_nhds

theorem hasSum_arcsine_closed {x : ℝ} (hx : |x| ≤ 1) :
    HasSum (fun n => arcsineCoefficient n * x ^ (2 * n + 1)) (Real.arcsin x) := by
  have hnonneg {y : ℝ} (hy0 : 0 ≤ y) (hy1 : y ≤ 1) :
      HasSum (fun n => arcsineCoefficient n * y ^ (2 * n + 1)) (Real.arcsin y) := by
    rcases hy1.eq_or_lt with rfl | hy1
    · simpa using hasSum_arcsine_one
    · exact hasSum_arcsine_nonneg_interior hy0 hy1
  by_cases hx0 : 0 ≤ x
  · exact hnonneg hx0 (abs_le.mp hx).2
  · have h := (hnonneg (neg_nonneg.mpr (le_of_not_ge hx0))
      (by linarith [(abs_le.mp hx).1])).neg
    have hpow (n : ℕ) : (-x) ^ (2 * n + 1) = -(x ^ (2 * n + 1)) := by
      simp only [pow_add, pow_mul, neg_sq, pow_one]
      ring
    simpa only [hpow, mul_neg, neg_neg, Real.arcsin_neg] using h

theorem hasSum_arcsine_closed_centralBinom {x : ℝ} (hx : |x| ≤ 1) :
    HasSum (fun n => ((Nat.centralBinom n : ℝ) /
      ((4 : ℝ) ^ n * (2 * n + 1 : ℝ))) * x ^ (2 * n + 1)) (Real.arcsin x) := by
  simpa only [arcsineCoefficient_eq_centralBinom] using hasSum_arcsine_closed hx

def arcsineLink (x : ℝ) : ℝ := (2 / Real.pi) * Real.arcsin x

def arcsineLinkCoefficient (n : ℕ) : ℝ := (2 / Real.pi) * arcsineCoefficient n

theorem arcsineLinkCoefficient_pos (n : ℕ) : 0 < arcsineLinkCoefficient n := by
  exact mul_pos (div_pos (by norm_num) Real.pi_pos) (arcsineCoefficient_pos n)

theorem arcsineLinkCoefficient_zero : arcsineLinkCoefficient 0 = 2 / Real.pi := by
  simp [arcsineLinkCoefficient, arcsineCoefficient, arcsineDerivativeCoefficient]

theorem hasSum_arcsineLink_closed {x : ℝ} (hx : |x| ≤ 1) :
    HasSum (fun n => arcsineLinkCoefficient n * x ^ (2 * n + 1)) (arcsineLink x) := by
  simpa only [arcsineLinkCoefficient, arcsineLink, mul_assoc]
    using (hasSum_arcsine_closed hx).mul_left (2 / Real.pi)

theorem arcsineLink_one : arcsineLink 1 = 1 := by
  unfold arcsineLink
  rw [Real.arcsin_one]
  field_simp [Real.pi_ne_zero]

theorem hasSum_arcsineLinkCoefficient : HasSum arcsineLinkCoefficient 1 := by
  simpa only [one_pow, mul_one, arcsineLink_one] using
    hasSum_arcsineLink_closed (x := 1) (by norm_num)

theorem abs_arcsineLink_le_one (x : ℝ) : |arcsineLink x| ≤ 1 := by
  rw [abs_le]
  have hp : 0 < Real.pi := Real.pi_pos
  have hl := Real.neg_pi_div_two_le_arcsin x
  have hu := Real.arcsin_le_pi_div_two x
  unfold arcsineLink
  constructor
  · rw [div_mul_eq_mul_div, le_div_iff₀ hp]
    linarith
  · rw [div_mul_eq_mul_div, div_le_iff₀ hp]
    linarith

end NeuralGeneralization
