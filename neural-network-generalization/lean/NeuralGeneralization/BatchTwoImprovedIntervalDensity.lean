import NeuralGeneralization.BatchTwoImprovedGaussianTransportCompact
import NeuralGeneralization.BatchTwoImprovedQuantile
import Mathlib.InformationTheory.KullbackLeibler.Basic
import Mathlib.MeasureTheory.Integral.Bochner.ContinuousLinearMap

/-! # Actual normalized interval densities and their inverse CDFs

These lemmas connect the compact transport calculation to probability measures
and the measurable quantile coupling used for general-law approximation.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter InformationTheory
open scoped Topology ENNReal

namespace NeuralGeneralization.BatchTwoImprovedIntervalDensity
open PositiveCDFTransport

/-- A normalized density on `(a,b]`; endpoints have zero Lebesgue mass. -/
def intervalDensity (f : ℝ → ℝ) (a b : ℝ) : Measure ℝ :=
  (volume.restrict (Ioc a b)).withDensity (fun x => ENNReal.ofReal (f x / mass f a b))

theorem intervalDensity_probability {f : ℝ → ℝ} {a b : ℝ}
    (hf : Continuous f) (hfpos : ∀ x, 0 < f x) (hab : a < b) :
    IsProbabilityMeasure (intervalDensity f a b) := by
  constructor
  rw [intervalDensity, withDensity_apply _ MeasurableSet.univ]
  simp only [Measure.restrict_univ]
  have hi : Integrable (fun x => f x / mass f a b) (volume.restrict (Ioc a b)) :=
    ((hf.div_const _).intervalIntegrable a b).1
  rw [← ofReal_integral_eq_lintegral_ofReal hi
    (Eventually.of_forall (fun x => (div_pos (hfpos x) (mass_pos hf hfpos hab)).le)),
    ← intervalIntegral.integral_of_le hab.le, intervalIntegral.integral_div]
  change ENNReal.ofReal (mass f a b / mass f a b) = 1
  rw [div_self (mass_pos hf hfpos hab).ne', ENNReal.ofReal_one]

theorem integral_intervalDensity {f : ℝ → ℝ} {a b : ℝ}
    (hf : Continuous f) (hfpos : ∀ x, 0 < f x) (hab : a < b) (u : ℝ → ℝ) :
    (∫ x, u x ∂intervalDensity f a b) =
      ∫ x in a..b, (f x / mass f a b) * u x := by
  rw [intervalDensity, integral_withDensity_eq_integral_toReal_smul
    (hf.measurable.div_const _ |>.ennreal_ofReal)
    (Eventually.of_forall fun x => ENNReal.ofReal_lt_top)]
  simp_rw [ENNReal.toReal_ofReal (div_pos (hfpos _) (mass_pos hf hfpos hab)).le,
    smul_eq_mul]
  rw [intervalIntegral.integral_of_le hab.le]

/-- Every continuous observable is integrable for a compact interval density. -/
theorem integrable_intervalDensity {f u : ℝ → ℝ} {a b : ℝ}
    (hf : Continuous f) (hfpos : ∀ x, 0 < f x) (hab : a < b)
    (hu : Continuous u) : Integrable u (intervalDensity f a b) := by
  letI := intervalDensity_probability hf hfpos hab
  obtain ⟨B, hB⟩ := isCompact_Icc.exists_bound_of_continuousOn hu.continuousOn
  apply (integrable_const B).mono' hu.aestronglyMeasurable
  have hmem : ∀ᵐ x ∂intervalDensity f a b, x ∈ Ioc a b := by
    have hac : intervalDensity f a b ≪ volume.restrict (Ioc a b) :=
      withDensity_absolutelyContinuous _ _
    exact hac.ae_le (ae_restrict_mem measurableSet_Ioc)
  filter_upwards [hmem] with x hx
  exact hB x ⟨hx.1.le, hx.2⟩

/-- The CDF in the interior is exactly the elementary normalized integral. -/
theorem cdf_intervalDensity {f : ℝ → ℝ} {a b x : ℝ}
    (hf : Continuous f) (hfpos : ∀ x, 0 < f x) (hab : a < b)
    (hx : x ∈ Icc a b) :
    ProbabilityTheory.cdf (intervalDensity f a b) x = PositiveCDFTransport.cdf f a b x := by
  letI := intervalDensity_probability hf hfpos hab
  have hset : Iic x ∩ Ioc a b = Ioc a x := by
    ext y
    simp only [mem_inter_iff, mem_Iic, mem_Ioc]
    constructor
    · exact fun h => ⟨h.2.1, h.1⟩
    · exact fun h => ⟨h.2, h.1, h.2.trans hx.2⟩
  have hi : Integrable (fun y => f y / mass f a b) (volume.restrict (Ioc a x)) :=
    ((hf.div_const _).intervalIntegrable a x).1
  have hμ : intervalDensity f a b (Iic x) =
      ENNReal.ofReal (PositiveCDFTransport.cdf f a b x) := by
    rw [intervalDensity, withDensity_apply _ measurableSet_Iic,
      Measure.restrict_restrict measurableSet_Iic, hset,
      ← ofReal_integral_eq_lintegral_ofReal hi
        (Eventually.of_forall fun y => (div_pos (hfpos y) (mass_pos hf hfpos hab)).le),
      ← intervalIntegral.integral_of_le hx.1, intervalIntegral.integral_div]
    rfl
  rw [ProbabilityTheory.cdf_eq_real, measureReal_def, hμ,
    ENNReal.toReal_ofReal (cdf_mem_Icc hf hfpos hab hx).1]

/-- The analytic inverse CDF is the same map as the measurable measure-theoretic
quantile, at every non-endpoint uniform seed. -/
theorem quantile_intervalDensity {f : ℝ → ℝ} {a b u : ℝ}
    (hf : Continuous f) (hfpos : ∀ x, 0 < f x) (hab : a < b)
    (hu : u ∈ Ioo (0 : ℝ) 1) :
    BatchTwoImprovedQuantile.quantile (intervalDensity f a b) u =
      PositiveCDFTransport.quantile hf hfpos hab u := by
  let μ := intervalDensity f a b
  let q := PositiveCDFTransport.quantile hf hfpos hab u
  have hqmem : q ∈ Icc a b := quantile_mem_Icc hf hfpos hab u
  have hqu : PositiveCDFTransport.cdf f a b q = u := cdf_quantile hf hfpos hab ⟨hu.1.le, hu.2.le⟩
  have hcqu : ProbabilityTheory.cdf μ q = u :=
    (cdf_intervalDensity hf hfpos hab hqmem).trans hqu
  apply le_antisymm
  · exact (BatchTwoImprovedQuantile.quantile_le_iff μ hu).mpr hcqu.ge
  · by_contra hnot
    have hlt : BatchTwoImprovedQuantile.quantile μ u < q := lt_of_not_ge hnot
    have hlevel := BatchTwoImprovedQuantile.quantile_mem_level μ hu
    by_cases hlow : BatchTwoImprovedQuantile.quantile μ u < a
    · have hc0 : ProbabilityTheory.cdf μ a = 0 := by
        rw [cdf_intervalDensity hf hfpos hab (left_mem_Icc.mpr hab.le), cdf_left]
      have hle := (ProbabilityTheory.monotone_cdf μ) hlow.le
      rw [hc0] at hle
      exact (not_le_of_gt hu.1) (hlevel.trans hle)
    · have hin : BatchTwoImprovedQuantile.quantile μ u ∈ Icc a b :=
        ⟨le_of_not_gt hlow, hlt.le.trans hqmem.2⟩
      rw [cdf_intervalDensity hf hfpos hab hin] at hlevel
      have hs := strictMono_cdf hf hfpos hab hlt
      rw [hqu] at hs
      exact (not_lt_of_ge hlevel) hs


/-- Exact change of normalized density on a common compact interval. -/
theorem intervalDensity_change {f g : ℝ → ℝ} {a b : ℝ}
    (hf : Continuous f) (hfpos : ∀ x, 0 < f x)
    (hg : Continuous g) (hgpos : ∀ x, 0 < g x) (hab : a < b) :
    (intervalDensity f a b).withDensity (fun x => ENNReal.ofReal
      ((g x / mass g a b) / (f x / mass f a b))) = intervalDensity g a b := by
  have hfm : Measurable (fun x => ENNReal.ofReal (f x / mass f a b)) :=
    (hf.measurable.div_const _).ennreal_ofReal
  have hgm : Measurable (fun x => ENNReal.ofReal
      ((g x / mass g a b) / (f x / mass f a b))) := by fun_prop
  rw [intervalDensity, ← withDensity_mul _ hfm hgm]
  apply withDensity_congr_ae
  filter_upwards with x
  simp only [Pi.mul_apply]
  rw [← ENNReal.ofReal_mul (div_pos (hfpos x) (mass_pos hf hfpos hab)).le]
  congr 1
  field_simp [(hfpos x).ne', (mass_pos hf hfpos hab).ne']

/-- The actual likelihood ratio is the normalized density ratio. -/
theorem llr_intervalDensity {f g : ℝ → ℝ} {a b : ℝ}
    (hf : Continuous f) (hfpos : ∀ x, 0 < f x)
    (hg : Continuous g) (hgpos : ∀ x, 0 < g x) (hab : a < b) :
    llr (intervalDensity g a b) (intervalDensity f a b) =ᵐ[intervalDensity g a b]
      (fun x => Real.log ((g x / mass g a b) / (f x / mass f a b))) := by
  letI := intervalDensity_probability hf hfpos hab
  letI := intervalDensity_probability hg hgpos hab
  have hm : Measurable (fun x => ENNReal.ofReal
      ((g x / mass g a b) / (f x / mass f a b))) := by fun_prop
  have heq := intervalDensity_change hf hfpos hg hgpos hab
  have hac : intervalDensity g a b ≪ intervalDensity f a b := by
    rw [← heq]
    exact withDensity_absolutelyContinuous _ _
  have hrn := Measure.rnDeriv_withDensity (intervalDensity f a b) hm
  rw [heq] at hrn
  filter_upwards [hac.ae_le hrn] with x hx
  change Real.log ((intervalDensity g a b).rnDeriv (intervalDensity f a b) x).toReal = _
  rw [hx, ENNReal.toReal_ofReal]
  exact (div_pos (div_pos (hgpos x) (mass_pos hg hgpos hab))
    (div_pos (hfpos x) (mass_pos hf hfpos hab))).le

/-- KL is exactly the usual integral of the log density ratio. -/
theorem klDiv_intervalDensity {f g : ℝ → ℝ} {a b : ℝ}
    (hf : Continuous f) (hfpos : ∀ x, 0 < f x)
    (hg : Continuous g) (hgpos : ∀ x, 0 < g x) (hab : a < b) :
    klDiv (intervalDensity g a b) (intervalDensity f a b) =
      ENNReal.ofReal (∫ x in a..b, (g x / mass g a b) *
        Real.log ((g x / mass g a b) / (f x / mass f a b))) := by
  letI := intervalDensity_probability hf hfpos hab
  letI := intervalDensity_probability hg hgpos hab
  have heq := intervalDensity_change hf hfpos hg hgpos hab
  have hac : intervalDensity g a b ≪ intervalDensity f a b := by
    rw [← heq]
    exact withDensity_absolutelyContinuous _ _
  have hratio : Continuous (fun x => (g x / mass g a b) / (f x / mass f a b)) :=
    (hg.div_const _).div (hf.div_const _)
      (fun x => (div_pos (hfpos x) (mass_pos hf hfpos hab)).ne')
  have hlog : Continuous (fun x => Real.log
      ((g x / mass g a b) / (f x / mass f a b))) :=
    hratio.log (fun x => (div_pos (div_pos (hgpos x) (mass_pos hg hgpos hab))
      (div_pos (hfpos x) (mass_pos hf hfpos hab))).ne')
  have hllr := llr_intervalDensity hf hfpos hg hgpos hab
  have hint : Integrable (llr (intervalDensity g a b) (intervalDensity f a b))
      (intervalDensity g a b) :=
    (integrable_intervalDensity hg hgpos hab hlog).congr hllr.symm
  rw [klDiv_of_ac_of_integrable hac hint, integral_congr_ae hllr]
  simp only [probReal_univ, add_sub_cancel_right]
  rw [integral_intervalDensity hg hgpos hab]

end NeuralGeneralization.BatchTwoImprovedIntervalDensity
