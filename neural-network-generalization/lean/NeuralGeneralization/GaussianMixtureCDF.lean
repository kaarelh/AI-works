import NeuralGeneralization.CDFMeanConfidence
import Mathlib.Probability.Distributions.Gaussian.Real
import Mathlib.MeasureTheory.Integral.Prod

/-!
# CDF regularity for an actual Gaussian location mixture

The measure is the pushforward of an independent product by addition.
Its nondegenerate Gaussian noise gives a strictly increasing, globally
Lipschitz CDF, without restrictions on the distribution of the location.
-/

noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped NNReal

namespace NeuralGeneralization.GaussianMixtureCDF

def law (μ : Measure ℝ) (v : ℝ≥0) : Measure ℝ :=
  (μ.prod (gaussianReal 0 v)).map (fun z : ℝ × ℝ => z.1 + z.2)

instance (μ : Measure ℝ) [IsProbabilityMeasure μ] (v : ℝ≥0) :
    IsProbabilityMeasure (law μ v) := by
  unfold law
  exact Measure.isProbabilityMeasure_map (by fun_prop)

def densityBound (v : ℝ≥0) : ℝ := 1 / Real.sqrt (2 * Real.pi * v)

theorem densityBound_pos (v : ℝ≥0) (hv : v ≠ 0) : 0 < densityBound v := by
  have hv' : 0 < (v : ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr hv)
  unfold densityBound
  positivity

theorem pdf_le_densityBound (m : ℝ) (v : ℝ≥0) (x : ℝ) :
    gaussianPDFReal m v x ≤ densityBound v := by
  unfold gaussianPDFReal densityBound
  have he : Real.exp (-(x - m) ^ 2 / (2 * (v : ℝ))) ≤ 1 := by
    apply Real.exp_le_one_iff.mpr
    exact div_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr (sq_nonneg _)) (by positivity)
  simpa [one_div] using mul_le_mul_of_nonneg_left he
    (show 0 ≤ (Real.sqrt (2 * Real.pi * v))⁻¹ by positivity)

theorem gaussian_interval_le (m : ℝ) (v : ℝ≥0) (hv : v ≠ 0)
    (a b : ℝ) (hab : a ≤ b) :
    gaussianReal m v (Ioc a b) ≤ ENNReal.ofReal (densityBound v * (b - a)) := by
  rw [gaussianReal_apply_eq_integral m hv]
  apply ENNReal.ofReal_le_ofReal
  have h := setIntegral_mono_on (integrable_gaussianPDFReal m v).integrableOn
    (integrableOn_const (measure_Ioc_lt_top.ne : volume (Ioc a b) ≠ ⊤))
    measurableSet_Ioc (fun x _ => pdf_le_densityBound m v x)
  rw [setIntegral_const, smul_eq_mul, measureReal_def, Real.volume_Ioc,
    ENNReal.toReal_ofReal (sub_nonneg.mpr hab)] at h
  simpa only [mul_comm] using h

theorem gaussian_interval_pos (m : ℝ) (v : ℝ≥0) (hv : v ≠ 0)
    (a b : ℝ) (hab : a < b) : 0 < gaussianReal m v (Ioc a b) := by
  apply pos_iff_ne_zero.mpr
  intro hz
  have hz' := gaussianReal_absolutelyContinuous' m hv hz
  rw [Real.volume_Ioc] at hz'
  exact (ENNReal.ofReal_pos.mpr (sub_pos.mpr hab)).ne' hz'

theorem interval_law (μ : Measure ℝ) [IsProbabilityMeasure μ] (v : ℝ≥0)
    (a b : ℝ) :
    law μ v (Ioc a b) = ∫⁻ h, gaussianReal 0 v (Ioc (a - h) (b - h)) ∂μ := by
  rw [law, Measure.map_apply (by fun_prop) measurableSet_Ioc,
    Measure.prod_apply (by measurability)]
  apply lintegral_congr
  intro h
  congr 1
  ext z
  simp only [mem_preimage, mem_Ioc]
  constructor <;> intro hh <;> constructor <;> linarith [hh.1, hh.2]

theorem interval_le (μ : Measure ℝ) [IsProbabilityMeasure μ] (v : ℝ≥0)
    (hv : v ≠ 0) (a b : ℝ) (hab : a ≤ b) :
    law μ v (Ioc a b) ≤ ENNReal.ofReal (densityBound v * (b - a)) := by
  rw [interval_law]
  calc
    _ ≤ ∫⁻ _ : ℝ, ENNReal.ofReal (densityBound v * (b - a)) ∂μ := by
      apply lintegral_mono
      intro h
      simpa only [sub_sub_sub_cancel_right] using
        gaussian_interval_le 0 v hv (a - h) (b - h) (sub_le_sub_right hab h)
    _ = _ := by simp

theorem interval_pos (μ : Measure ℝ) [IsProbabilityMeasure μ] (v : ℝ≥0)
    (hv : v ≠ 0) (a b : ℝ) (hab : a < b) :
    0 < law μ v (Ioc a b) := by
  rw [interval_law]
  have hm : Measurable (fun h : ℝ => gaussianReal 0 v (Ioc (a - h) (b - h))) := by
    have he : (fun h : ℝ => gaussianReal 0 v (Ioc (a - h) (b - h))) =
        fun h => gaussianReal 0 v (Prod.mk h ⁻¹'
          ((fun z : ℝ × ℝ => z.1 + z.2) ⁻¹' Ioc a b)) := by
      funext h
      congr 1
      ext z
      simp only [mem_Ioc, mem_preimage]
      constructor <;> intro hh <;> constructor <;> linarith [hh.1, hh.2]
    rw [he]
    exact measurable_measure_prodMk_left (by measurability)
  rw [lintegral_pos_iff_support hm]
  have hs : Function.support (fun h : ℝ => gaussianReal 0 v (Ioc (a - h) (b - h))) = univ := by
    ext h
    simp only [Function.mem_support, mem_univ, iff_true]
    exact (gaussian_interval_pos 0 v hv _ _ (sub_lt_sub_right hab h)).ne'
  simp [hs]

theorem cdf_difference (μ : Measure ℝ) [IsProbabilityMeasure μ]
    (a b : ℝ) (hab : a ≤ b) :
    μ.real (Ioc a b) = cdf μ b - cdf μ a := by
  have hh : μ (Ioc a b) = ENNReal.ofReal (cdf μ b - cdf μ a) := by
    conv_lhs => rw [← measure_cdf μ]
    exact (cdf μ).measure_Ioc a b
  rw [measureReal_def, hh]
  exact ENNReal.toReal_ofReal (sub_nonneg.mpr (monotone_cdf μ hab))

theorem strictMono_cdf (μ : Measure ℝ) [IsProbabilityMeasure μ] (v : ℝ≥0)
    (hv : v ≠ 0) : StrictMono (cdf (law μ v)) := by
  intro a b hab
  have hh : 0 < (law μ v).real (Ioc a b) :=
    ENNReal.toReal_pos (interval_pos μ v hv a b hab).ne' (measure_ne_top _ _)
  rw [cdf_difference _ a b hab.le] at hh
  linarith

theorem cdf_lipschitz_bound (μ : Measure ℝ) [IsProbabilityMeasure μ] (v : ℝ≥0)
    (hv : v ≠ 0) (a b : ℝ) :
    |cdf (law μ v) a - cdf (law μ v) b| ≤ densityBound v * |a - b| := by
  wlog hab : b ≤ a generalizing a b
  · simpa only [abs_sub_comm] using this b a (le_of_not_ge hab)
  rw [abs_of_nonneg (sub_nonneg.mpr (monotone_cdf (law μ v) hab)),
    abs_of_nonneg (sub_nonneg.mpr hab), ← cdf_difference _ b a hab]
  have h := ENNReal.toReal_mono (ENNReal.ofReal_ne_top)
    (interval_le μ v hv b a hab)
  simpa only [measureReal_def, ENNReal.toReal_ofReal (mul_nonneg (densityBound_pos v hv).le
    (sub_nonneg.mpr hab))] using h

theorem continuous_cdf (μ : Measure ℝ) [IsProbabilityMeasure μ] (v : ℝ≥0)
    (hv : v ≠ 0) : Continuous (cdf (law μ v)) := by
  apply LipschitzWith.continuous (K := ⟨densityBound v, (densityBound_pos v hv).le⟩)
  apply LipschitzWith.of_dist_le_mul
  intro a b
  change |cdf (law μ v) a - cdf (law μ v) b| ≤ densityBound v * |a - b|
  exact cdf_lipschitz_bound μ v hv a b

theorem sign_probability (μ : Measure ℝ) [IsProbabilityMeasure μ] :
    μ.real (Ioi (0 : ℝ)) = 1 - cdf μ 0 := by
  rw [cdf_eq_real]
  simpa only [compl_Iic] using probReal_compl_eq_one_sub (μ := μ)
    (measurableSet_Iic : MeasurableSet (Iic (0 : ℝ)))

/-- For the actual product-noise law, log-concavity of its CDF converts
buffered sign confidence to a positive mean at the Gaussian noise scale. -/
theorem mean_margin (μ : Measure ℝ) [IsProbabilityMeasure μ] (v : ℝ≥0)
    (hv : v ≠ 0)
    (hlog : ConcaveOn ℝ univ (fun x => Real.log (cdf (law μ v) x)))
    (hi : Integrable (fun x : ℝ => x) (law μ v))
    (hq : (13 : ℝ) / 20 < (law μ v).real (Ioi 0)) :
    Real.sqrt (2 * Real.pi * v) * (Real.exp (-1) - 7 / 20) <
      ∫ x, x ∂law μ v := by
  rw [sign_probability] at hq
  have hh := mean_margin_of_buffered_confidence (law μ v)
    (continuous_cdf μ v hv) (strictMono_cdf μ v hv) hlog hi
    (densityBound v) (densityBound_pos v hv) (cdf_lipschitz_bound μ v hv) hq
  simpa [densityBound, div_eq_mul_inv, mul_comm] using hh

end NeuralGeneralization.GaussianMixtureCDF
