import Mathlib.Probability.CDF
import Mathlib.Analysis.Convex.Integral
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic
import Mathlib.Analysis.Complex.ExponentialBounds

/-!
# Mean confidence from a log-concave cumulative distribution function

This module proves the probability integral transform and its logarithmic
expectation for a continuous strictly increasing CDF. Jensen's inequality then
gives the dimension-free CDF bound at the mean. Log-concavity is an explicit
hypothesis here; deriving it for convexly conditioned Gaussian laws is separate.
-/

noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped Topology

namespace NeuralGeneralization

theorem strict_cdf_pos (μ : Measure ℝ) (hm : StrictMono (cdf μ)) (x : ℝ) :
    0 < cdf μ x :=
  (cdf_nonneg μ (x - 1)).trans_lt (hm (by linarith))

theorem strict_cdf_lt_one (μ : Measure ℝ) (hm : StrictMono (cdf μ)) (x : ℝ) :
    cdf μ x < 1 :=
  (hm (show x < x + 1 by linarith)).trans_le (cdf_le_one μ (x + 1))

/-- The actual pushforward law of a continuous strictly increasing CDF. -/
theorem map_strict_cdf (μ : Measure ℝ) [IsProbabilityMeasure μ]
    (hc : Continuous (cdf μ)) (hm : StrictMono (cdf μ)) :
    μ.map (cdf μ) = volume.restrict (Ioc (0 : ℝ) 1) := by
  apply Measure.ext_of_Iic
  intro t
  rw [Measure.map_apply hc.measurable measurableSet_Iic,
    Measure.restrict_apply measurableSet_Iic]
  by_cases h0 : t ≤ 0
  · have he : (cdf μ) ⁻¹' Iic t = ∅ := by
      ext x
      simp only [mem_preimage, mem_Iic, mem_empty_iff_false, iff_false]
      exact not_le.mpr (h0.trans_lt (strict_cdf_pos μ hm x))
    have hi : Iic t ∩ Ioc (0 : ℝ) 1 = ∅ := by
      ext x
      simp only [mem_inter_iff, mem_Iic, mem_Ioc, mem_empty_iff_false, iff_false,
        not_and]
      intro hx hx0
      linarith
    simp [he, hi]
  · by_cases h1 : 1 ≤ t
    · have he : (cdf μ) ⁻¹' Iic t = univ := by
        ext x
        simp only [mem_preimage, mem_Iic, mem_univ, iff_true]
        exact (cdf_le_one μ x).trans h1
      have hi : Iic t ∩ Ioc (0 : ℝ) 1 = Ioc 0 1 := by
        ext x
        simp only [mem_inter_iff, mem_Iic, mem_Ioc]
        constructor
        · exact fun h => h.2
        · exact fun h => ⟨h.2.trans h1, h⟩
      simp [he, hi, Real.volume_Ioc]
    · have ht : t ∈ Ioo (0 : ℝ) 1 := ⟨lt_of_not_ge h0, lt_of_not_ge h1⟩
      have hr := isPreconnected_univ.intermediate_value_Ioo
        (by simp : (atBot : Filter ℝ) ≤ 𝓟 (univ : Set ℝ))
        (by simp : (atTop : Filter ℝ) ≤ 𝓟 (univ : Set ℝ))
        hc.continuousOn (tendsto_cdf_atBot μ) (tendsto_cdf_atTop μ) ht
      obtain ⟨y, _, hy⟩ := hr
      have he : (cdf μ) ⁻¹' Iic t = Iic y := by
        ext x
        simp only [mem_preimage, mem_Iic, ← hy, hm.le_iff_le]
      have hi : Iic t ∩ Ioc (0 : ℝ) 1 = Ioc 0 t := by
        ext x
        simp only [mem_inter_iff, mem_Iic, mem_Ioc]
        constructor
        · exact fun h => ⟨h.2.1, h.1⟩
        · exact fun h => ⟨h.2, h.1, h.2.trans ht.2.le⟩
      rw [he, hi, ← ofReal_cdf μ y, hy, Real.volume_Ioc, sub_zero]

theorem integrable_log_strict_cdf (μ : Measure ℝ) [IsProbabilityMeasure μ]
    (hc : Continuous (cdf μ)) (hm : StrictMono (cdf μ)) :
    Integrable (fun x => Real.log (cdf μ x)) μ := by
  have hi : Integrable Real.log (volume.restrict (Ioc (0 : ℝ) 1)) :=
    intervalIntegral.intervalIntegrable_log'.1
  rw [← map_strict_cdf μ hc hm] at hi
  exact hi.comp_measurable hc.measurable

theorem integral_log_strict_cdf (μ : Measure ℝ) [IsProbabilityMeasure μ]
    (hc : Continuous (cdf μ)) (hm : StrictMono (cdf μ)) :
    (∫ x, Real.log (cdf μ x) ∂μ) = -1 := by
  rw [← integral_map hc.measurable.aemeasurable
    Real.measurable_log.aestronglyMeasurable, map_strict_cdf μ hc hm]
  rw [← intervalIntegral.integral_of_le (show (0 : ℝ) ≤ 1 by norm_num)]
  simp

theorem cdf_mean_ge_exp_neg_one (μ : Measure ℝ) [IsProbabilityMeasure μ]
    (hc : Continuous (cdf μ)) (hm : StrictMono (cdf μ))
    (hlog : ConcaveOn ℝ univ (fun x => Real.log (cdf μ x)))
    (hi : Integrable (fun x : ℝ => x) μ) :
    Real.exp (-1) ≤ cdf μ (∫ x, x ∂μ) := by
  have hcont : Continuous (fun x => Real.log (cdf μ x)) :=
    hc.log (fun x => (strict_cdf_pos μ hm x).ne')
  have hj := hlog.le_map_integral hcont.continuousOn isClosed_univ
    (Filter.Eventually.of_forall fun x : ℝ => mem_univ x) hi
    (integrable_log_strict_cdf μ hc hm)
  change (∫ x, Real.log (cdf μ x) ∂μ) ≤ Real.log (cdf μ (∫ x, x ∂μ)) at hj
  rw [integral_log_strict_cdf μ hc hm] at hj
  have he := Real.exp_le_exp.mpr hj
  rwa [Real.exp_log (strict_cdf_pos μ hm _)] at he

/-- High sign confidence forces a positive mean, with a quantitative margin
when the CDF has a density upper bound expressed as a Lipschitz constant. -/
theorem mean_margin_of_logconcave_cdf (μ : Measure ℝ) [IsProbabilityMeasure μ]
    (hc : Continuous (cdf μ)) (hm : StrictMono (cdf μ))
    (hlog : ConcaveOn ℝ univ (fun x => Real.log (cdf μ x)))
    (hi : Integrable (fun x : ℝ => x) μ)
    (L θ : ℝ) (hL : 0 < L) (hθ : 1 - Real.exp (-1) ≤ θ)
    (hlip : ∀ x y, |cdf μ x - cdf μ y| ≤ L * |x - y|)
    (hq : θ < 1 - cdf μ 0) :
    (Real.exp (-1) + θ - 1) / L < ∫ x, x ∂μ := by
  let m := ∫ x, x ∂μ
  have hmean := cdf_mean_ge_exp_neg_one μ hc hm hlog hi
  have hmpos : 0 < m := by
    by_contra hn
    have hF := (monotone_cdf μ) (le_of_not_gt hn)
    change cdf μ m ≤ cdf μ 0 at hF
    change Real.exp (-1) ≤ cdf μ m at hmean
    linarith
  have hh := hlip m 0
  rw [sub_zero, abs_of_pos hmpos] at hh
  have hdiff := (le_abs_self (cdf μ m - cdf μ 0)).trans hh
  apply (div_lt_iff₀ hL).mpr
  change Real.exp (-1) ≤ cdf μ m at hmean
  change Real.exp (-1) + θ - 1 < m * L
  nlinarith

theorem buffered_confidence_constant_pos : 0 < Real.exp (-1) - 7 / 20 := by
  have h := Real.exp_neg_one_gt_d9
  linarith

/-- The exact buffered confidence threshold used by the sign-posterior
argument, below the strict two-thirds threshold in the main statement. -/
theorem mean_margin_of_buffered_confidence (μ : Measure ℝ) [IsProbabilityMeasure μ]
    (hc : Continuous (cdf μ)) (hm : StrictMono (cdf μ))
    (hlog : ConcaveOn ℝ univ (fun x => Real.log (cdf μ x)))
    (hi : Integrable (fun x : ℝ => x) μ)
    (L : ℝ) (hL : 0 < L)
    (hlip : ∀ x y, |cdf μ x - cdf μ y| ≤ L * |x - y|)
    (hq : (13 : ℝ) / 20 < 1 - cdf μ 0) :
    (Real.exp (-1) - 7 / 20) / L < ∫ x, x ∂μ := by
  have hθ : 1 - Real.exp (-1) ≤ (13 : ℝ) / 20 := by
    linarith [buffered_confidence_constant_pos]
  have h := mean_margin_of_logconcave_cdf μ hc hm hlog hi L (13 / 20) hL hθ hlip hq
  convert h using 1
  ring

end NeuralGeneralization
