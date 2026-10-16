import NeuralGeneralization.GaussianConditionalEnergy

/-!
# Exponential moments restricted to the conditioning event

The restricted moment form retains dependence between the conditioning event
and the random variable. It is useful when the event itself suppresses large
values, as in the Gaussian fixed-margin amplitude estimate.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization

/-- An actual restricted exponential moment controls the conditional mean.
No independence between the event and the observable is required. -/
theorem conditional_expectation_le_of_restricted_exponential_moment
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (Q : Ω → ℝ) (s B : ℝ) (hs : 0 < s)
    (hQ : Integrable Q μ) (he : Integrable (fun x => Real.exp (s * Q x)) μ)
    (E : Set Ω) (hE : μ E ≠ 0)
    (hmgf : (∫ x in E, Real.exp (s * Q x) ∂μ) ≤ Real.exp B) :
    (∫ x, Q x ∂cond μ E) ≤ (B + Real.log (1 / μ.real E)) / s := by
  letI : IsProbabilityMeasure (cond μ E) := cond_isProbabilityMeasure hE
  have hp : 0 < μ.real E := ENNReal.toReal_pos hE (measure_ne_top μ E)
  have hQE : Integrable Q (cond μ E) :=
    hQ.restrict.smul_measure (ENNReal.inv_ne_top.mpr hE)
  have heE : Integrable (fun x => Real.exp (s * Q x)) (cond μ E) :=
    he.restrict.smul_measure (ENNReal.inv_ne_top.mpr hE)
  have hJ := exp_integral_le_of_integrable (cond μ E) (fun x => s * Q x)
    (hQE.const_mul s) heE
  rw [integral_const_mul] at hJ
  have hcond : (∫ x, Real.exp (s * Q x) ∂cond μ E) ≤
      (μ.real E)⁻¹ * Real.exp B := by
    unfold ProbabilityTheory.cond
    rw [integral_smul_measure, ENNReal.toReal_inv]
    change (μ.real E)⁻¹ * (∫ x in E, Real.exp (s * Q x) ∂μ) ≤ _
    exact mul_le_mul_of_nonneg_left hmgf (inv_nonneg.mpr hp.le)
  have hid : (μ.real E)⁻¹ * Real.exp B = Real.exp (B + Real.log (1 / μ.real E)) := by
    rw [Real.exp_add, Real.exp_log (one_div_pos.mpr hp)]
    ring
  have hbound := hJ.trans hcond
  rw [hid, Real.exp_le_exp] at hbound
  exact (le_div_iff₀ hs).mpr (by linarith)


/-- The exponential-moment bound for normalizing a nonzero finite measure.
The normalizing mass is retained explicitly rather than assumed to be one. -/
theorem finite_normalized_expectation_le_of_exponential_moment
    {Ω : Type*} [MeasurableSpace Ω] (κ : Measure Ω) [IsFiniteMeasure κ]
    (Q : Ω → ℝ) (s B : ℝ) (hs : 0 < s)
    (hQ : Integrable Q κ) (he : Integrable (fun x => Real.exp (s * Q x)) κ)
    (hκ : κ Set.univ ≠ 0)
    (hmgf : (∫ x, Real.exp (s * Q x) ∂κ) ≤ Real.exp B) :
    (∫ x, Q x ∂cond κ Set.univ) ≤ (B + Real.log (1 / κ.real Set.univ)) / s := by
  letI : IsProbabilityMeasure (cond κ Set.univ) := cond_isProbabilityMeasure hκ
  have hp : 0 < κ.real Set.univ := ENNReal.toReal_pos hκ (measure_ne_top κ Set.univ)
  have hQE : Integrable Q (cond κ Set.univ) :=
    hQ.restrict.smul_measure (ENNReal.inv_ne_top.mpr hκ)
  have heE : Integrable (fun x => Real.exp (s * Q x)) (cond κ Set.univ) :=
    he.restrict.smul_measure (ENNReal.inv_ne_top.mpr hκ)
  have hJ := exp_integral_le_of_integrable (cond κ Set.univ) (fun x => s * Q x)
    (hQE.const_mul s) heE
  rw [integral_const_mul] at hJ
  have hcond : (∫ x, Real.exp (s * Q x) ∂cond κ Set.univ) ≤
      (κ.real Set.univ)⁻¹ * Real.exp B := by
    unfold ProbabilityTheory.cond
    rw [integral_smul_measure, ENNReal.toReal_inv, Measure.restrict_univ]
    exact mul_le_mul_of_nonneg_left hmgf (inv_nonneg.mpr hp.le)
  have hid : (κ.real Set.univ)⁻¹ * Real.exp B =
      Real.exp (B + Real.log (1 / κ.real Set.univ)) := by
    rw [Real.exp_add, Real.exp_log (one_div_pos.mpr hp)]
    ring
  have hbound := hJ.trans hcond
  rw [hid, Real.exp_le_exp] at hbound
  exact (le_div_iff₀ hs).mpr (by linarith)

end NeuralGeneralization
