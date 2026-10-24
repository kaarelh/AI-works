import NeuralGeneralization.BatchTwoImprovedQuantileLimits
import Mathlib.InformationTheory.KullbackLeibler.Basic
import Mathlib.MeasureTheory.Integral.Bochner.ContinuousLinearMap

/-! # Actual density laws, KL, and CDF control by L1 error -/
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter InformationTheory
open scoped Topology ENNReal NNReal

namespace NeuralGeneralization.BatchTwoImprovedDensityMeasure

/-- An explicitly density-weighted law. Normalization is proved by theorems,
not bundled as an assumed probability distribution. -/
def densityLaw (μ : Measure ℝ) (ρ : ℝ → ℝ) : Measure ℝ :=
  μ.withDensity (fun x => ENNReal.ofReal (ρ x))

theorem densityLaw_probability (μ : Measure ℝ) (ρ : ℝ → ℝ)
    (hi : Integrable ρ μ) (hpos : ∀ x, 0 ≤ ρ x) (hmass : ∫ x, ρ x ∂μ = 1) :
    IsProbabilityMeasure (densityLaw μ ρ) := by
  constructor
  rw [densityLaw, withDensity_apply _ MeasurableSet.univ, Measure.restrict_univ,
    ← ofReal_integral_eq_lintegral_ofReal hi (Eventually.of_forall hpos), hmass,
    ENNReal.ofReal_one]

theorem integral_densityLaw (μ : Measure ℝ) (ρ : ℝ → ℝ)
    (hm : Measurable ρ) (hpos : ∀ x, 0 ≤ ρ x) (u : ℝ → ℝ) :
    (∫ x, u x ∂densityLaw μ ρ) = ∫ x, ρ x * u x ∂μ := by
  rw [densityLaw, integral_withDensity_eq_integral_toReal_smul hm.ennreal_ofReal
    (Eventually.of_forall fun _ => ENNReal.ofReal_lt_top)]
  simp_rw [ENNReal.toReal_ofReal (hpos _), smul_eq_mul]

theorem integrable_densityLaw_iff (μ : Measure ℝ) (ρ : ℝ → ℝ)
    (hm : Measurable ρ) (hpos : ∀ x, 0 ≤ ρ x) (u : ℝ → ℝ) :
    Integrable u (densityLaw μ ρ) ↔ Integrable (fun x => ρ x * u x) μ := by
  let r : ℝ → ℝ≥0 := fun x => ⟨ρ x, hpos x⟩
  have hr : Measurable r := hm.subtype_mk
  have heq : densityLaw μ ρ = μ.withDensity (fun x => (r x : ℝ≥0∞)) := by
    unfold densityLaw
    congr 1
    funext x
    exact ENNReal.ofReal_eq_coe_nnreal (hpos x)
  rw [heq]
  have hcoe (x : ℝ) : (r x : ℝ) = ρ x := rfl
  simpa only [NNReal.smul_def, smul_eq_mul, hcoe] using
    (integrable_withDensity_iff_integrable_smul hr (g := u))

theorem densityLaw_real_apply (μ : Measure ℝ) (ρ : ℝ → ℝ)
    (hi : Integrable ρ μ) (hpos : ∀ x, 0 ≤ ρ x) {s : Set ℝ}
    (hs : MeasurableSet s) :
    (densityLaw μ ρ).real s = ∫ x in s, ρ x ∂μ := by
  rw [measureReal_def, densityLaw, withDensity_apply _ hs,
    ← ofReal_integral_eq_lintegral_ofReal hi.integrableOn (Eventually.of_forall hpos),
    ENNReal.toReal_ofReal (integral_nonneg hpos)]

/-- Total variation at each CDF coordinate is bounded by actual density L1
error, so no weak-convergence abstraction is needed by quantile stability. -/
theorem cdf_densityLaw_sub_le (μ : Measure ℝ) (f g : ℝ → ℝ)
    (hf : Integrable f μ) (hg : Integrable g μ)
    (hfpos : ∀ x, 0 ≤ f x) (hgpos : ∀ x, 0 ≤ g x)
    (hfmass : ∫ x, f x ∂μ = 1) (hgmass : ∫ x, g x ∂μ = 1) (z : ℝ) :
    |cdf (densityLaw μ f) z - cdf (densityLaw μ g) z| ≤
      ∫ x, |f x-g x| ∂μ := by
  letI := densityLaw_probability μ f hf hfpos hfmass
  letI := densityLaw_probability μ g hg hgpos hgmass
  rw [cdf_eq_real, cdf_eq_real,
    densityLaw_real_apply μ f hf hfpos measurableSet_Iic,
    densityLaw_real_apply μ g hg hgpos measurableSet_Iic,
    ← integral_sub hf.integrableOn hg.integrableOn]
  have h := norm_integral_le_integral_norm (f := fun x => f x-g x)
    (μ := μ.restrict (Iic z))
  rw [Real.norm_eq_abs] at h
  simp only [Real.norm_eq_abs] at h
  exact h.trans (setIntegral_le_integral (hf.sub hg).abs
    (Eventually.of_forall (fun _ => abs_nonneg _)))

/-- The true KL divergence of a normalized density is its usual entropy
integral, including densities that vanish. -/
theorem klDiv_densityLaw (μ : Measure ℝ) [IsProbabilityMeasure μ]
    (ρ : ℝ → ℝ) (hm : Measurable ρ) (hi : Integrable ρ μ)
    (hpos : ∀ x, 0 ≤ ρ x) (hmass : ∫ x, ρ x ∂μ = 1)
    (hent : Integrable (fun x => ρ x * Real.log (ρ x)) μ) :
    klDiv (densityLaw μ ρ) μ =
      ENNReal.ofReal (∫ x, ρ x * Real.log (ρ x) ∂μ) := by
  letI := densityLaw_probability μ ρ hi hpos hmass
  have hac : densityLaw μ ρ ≪ μ := withDensity_absolutelyContinuous _ _
  have hrn := Measure.rnDeriv_withDensity μ hm.ennreal_ofReal
  have heq : llr (densityLaw μ ρ) μ =ᵐ[densityLaw μ ρ] (fun x => Real.log (ρ x)) := by
    filter_upwards [hac.ae_le hrn] with x hx
    change Real.log ((densityLaw μ ρ).rnDeriv μ x).toReal = _
    rw [densityLaw, hx, ENNReal.toReal_ofReal (hpos x)]
  have hlog : Integrable (fun x => Real.log (ρ x)) (densityLaw μ ρ) :=
    (integrable_densityLaw_iff μ ρ hm hpos _).mpr hent
  have hllr := hlog.congr heq.symm
  rw [klDiv_of_ac_of_integrable hac hllr, integral_congr_ae heq]
  simp only [probReal_univ, add_sub_cancel_right]
  rw [integral_densityLaw μ ρ hm hpos]


/-- L1 convergence of normalized nonnegative densities implies pointwise CDF
convergence of their actual probability laws. -/
theorem cdf_densityLaw_tendsto_of_l1 (μ : Measure ℝ)
    (f : ℕ → ℝ → ℝ) (g : ℝ → ℝ)
    (hf : ∀ n, Integrable (f n) μ) (hg : Integrable g μ)
    (hfpos : ∀ n x, 0 ≤ f n x) (hgpos : ∀ x, 0 ≤ g x)
    (hfmass : ∀ n, ∫ x, f n x ∂μ = 1) (hgmass : ∫ x, g x ∂μ = 1)
    (hl1 : Tendsto (fun n => ∫ x, |f n x-g x| ∂μ) atTop (𝓝 0)) (z : ℝ) :
    Tendsto (fun n => cdf (densityLaw μ (f n)) z) atTop
      (𝓝 (cdf (densityLaw μ g) z)) := by
  apply Metric.tendsto_nhds.mpr
  intro ε hε
  filter_upwards [hl1.eventually (Iio_mem_nhds hε)] with n hn
  rw [Real.dist_eq]
  exact (cdf_densityLaw_sub_le μ (f n) g (hf n) hg
    (hfpos n) hgpos (hfmass n) hgmass z).trans_lt hn

end NeuralGeneralization.BatchTwoImprovedDensityMeasure
