import TanhWalshMeasure

/-! Actual finite mixtures of probability measures with real nonnegative weights. -/

noncomputable section
open scoped BigOperators ENNReal
open MeasureTheory

namespace ConditionalNonpolynomial.Analytic

variable {ι Ω : Type*} [Fintype ι] [MeasurableSpace Ω]

def finiteProbabilityMixture (p : ι → ℝ) (μ : ι → Measure Ω) : Measure Ω :=
  ∑ i, ENNReal.ofReal (p i) • μ i

theorem finiteProbabilityMixture_isProbability (p : ι → ℝ) (μ : ι → Measure Ω)
    [∀ i, IsProbabilityMeasure (μ i)] (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1) :
    IsProbabilityMeasure (finiteProbabilityMixture p μ) := by
  constructor
  simp only [finiteProbabilityMixture, Measure.finsetSum_apply, Measure.smul_apply,
    measure_univ, smul_eq_mul, mul_one]
  rw [← ENNReal.ofReal_sum_of_nonneg (fun i _ => hp i), hsum, ENNReal.ofReal_one]

theorem finiteProbabilityMixture_integral (p : ι → ℝ) (μ : ι → Measure Ω)
    (hp : ∀ i, 0 ≤ p i) (F : Ω → ℝ) (hF : ∀ i, Integrable F (μ i)) :
    (∫ x, F x ∂finiteProbabilityMixture p μ) = ∑ i, p i * ∫ x, F x ∂μ i := by
  rw [finiteProbabilityMixture, integral_finsetSum_measure
    (fun i _ => (hF i).smul_measure ENNReal.ofReal_ne_top)]
  simp only [integral_smul_measure, ENNReal.toReal_ofReal (hp _), smul_eq_mul]

end ConditionalNonpolynomial.Analytic

#print axioms ConditionalNonpolynomial.Analytic.finiteProbabilityMixture_integral
