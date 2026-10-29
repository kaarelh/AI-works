import FiniteProbabilityMixture
import NeuralGeneralization.RobustEntropyKernel

/-! Joint convexity for actual finite mixtures, derived from the conditional KL
chain rule and data processing on the explicit labelled joint probability laws. -/

noncomputable section
open scoped BigOperators ENNReal ProbabilityTheory
open MeasureTheory ProbabilityTheory InformationTheory

namespace ConditionalNonpolynomial.Analytic

variable {ι Ω : Type*} [Fintype ι] [MeasurableSpace ι] [MeasurableSingletonClass ι]
    [MeasurableSpace Ω]

def finiteWeightLaw (p : ι → ℝ) : Measure ι :=
  finiteProbabilityMixture p (fun i => Measure.dirac i)

theorem finiteWeightLaw_isProbability (p : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1) :
    IsProbabilityMeasure (finiteWeightLaw p) :=
  finiteProbabilityMixture_isProbability p _ hp hsum

theorem finiteWeightLaw_lintegral (p : ι → ℝ) (F : ι → ℝ≥0∞) :
    (∫⁻ i, F i ∂finiteWeightLaw p) = ∑ i, ENNReal.ofReal (p i)*F i := by
  simp [finiteWeightLaw, finiteProbabilityMixture, lintegral_finsetSum_measure,
    lintegral_smul_measure, lintegral_dirac]

def finiteMeasureKernel (μ : ι → Measure Ω) : Kernel ι Ω where
  toFun := μ
  measurable' := measurable_of_countable _

instance finiteMeasureKernel_markov (μ : ι → Measure Ω) [∀ i, IsProbabilityMeasure (μ i)] :
    IsMarkovKernel (finiteMeasureKernel μ) := ⟨fun i =>
      (show IsProbabilityMeasure (μ i) from inferInstance)⟩

theorem finiteProbabilityMixture_eq_kernel_comp (p : ι → ℝ) (μ : ι → Measure Ω) :
    finiteMeasureKernel μ ∘ₘ finiteWeightLaw p = finiteProbabilityMixture p μ := by
  ext E hE
  rw [Measure.bind_apply hE (finiteMeasureKernel μ).aemeasurable, finiteWeightLaw_lintegral]
  simp [finiteProbabilityMixture, Measure.finsetSum_apply, Measure.smul_apply,
    finiteMeasureKernel]

theorem finiteProbabilityMixture_const (p : ι → ℝ) (μ : Measure Ω)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1) :
    finiteProbabilityMixture p (fun _ => μ) = μ := by
  ext E hE
  simp only [finiteProbabilityMixture, Measure.finsetSum_apply, Measure.smul_apply,
    smul_eq_mul]
  rw [← Finset.sum_mul, ← ENNReal.ofReal_sum_of_nonneg (fun i _ => hp i), hsum,
    ENNReal.ofReal_one, one_mul]

/-- Actual joint convexity of KL for finite mixtures, including infinite KL.
There is no componentwise absolute-continuity or finite-KL premise. -/
theorem finiteProbabilityMixture_klDiv_le [StandardBorelSpace ι] [StandardBorelSpace Ω]
    [Nonempty ι] [Nonempty Ω] (p : ι → ℝ) (μ ν : ι → Measure Ω)
    [∀ i, IsProbabilityMeasure (μ i)] [∀ i, IsProbabilityMeasure (ν i)]
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1) :
    klDiv (finiteProbabilityMixture p μ) (finiteProbabilityMixture p ν) ≤
      ∑ i, ENNReal.ofReal (p i)*klDiv (μ i) (ν i) := by
  letI := finiteWeightLaw_isProbability p hp hsum
  have h := NeuralGeneralization.RobustEntropy.klDiv_map_le
    (finiteWeightLaw p ⊗ₘ finiteMeasureKernel μ)
    (finiteWeightLaw p ⊗ₘ finiteMeasureKernel ν) measurable_snd
  change klDiv (finiteWeightLaw p ⊗ₘ finiteMeasureKernel μ).snd
    (finiteWeightLaw p ⊗ₘ finiteMeasureKernel ν).snd ≤ _ at h
  rw [Measure.snd_compProd, Measure.snd_compProd,
    finiteProbabilityMixture_eq_kernel_comp, finiteProbabilityMixture_eq_kernel_comp,
    NeuralGeneralization.RobustEntropy.klDiv_compProd_same_left_eq_lintegral,
    finiteWeightLaw_lintegral] at h
  exact h

theorem finiteProbabilityMixture_klDiv_reference_le
    [StandardBorelSpace ι] [StandardBorelSpace Ω] [Nonempty ι] [Nonempty Ω]
    (p : ι → ℝ) (μ : ι → Measure Ω) (G : Measure Ω)
    [∀ i, IsProbabilityMeasure (μ i)] [IsProbabilityMeasure G]
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1) :
    klDiv (finiteProbabilityMixture p μ) G ≤ ∑ i, ENNReal.ofReal (p i)*klDiv (μ i) G := by
  have h := finiteProbabilityMixture_klDiv_le p μ (fun _ => G) hp hsum
  rwa [finiteProbabilityMixture_const p G hp hsum] at h

end ConditionalNonpolynomial.Analytic

#print axioms ConditionalNonpolynomial.Analytic.finiteProbabilityMixture_klDiv_le
#print axioms ConditionalNonpolynomial.Analytic.finiteProbabilityMixture_klDiv_reference_le
