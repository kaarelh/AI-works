import NeuralGeneralization.OnlineLowerReluBalancing
import Mathlib.MeasureTheory.Integral.Bochner.SumMeasure

/-! # Finite coefficient copies of the Fourier integration line -/

noncomputable section
open scoped BigOperators
open MeasureTheory

namespace NeuralGeneralization.OnlineLowerRelu

variable {ι α : Type*} [Fintype ι] [MeasurableSpace ι] [MeasurableSingletonClass ι]
variable [MeasurableSpace α] {μ : Measure α} [SFinite μ]

theorem integrable_finite_copies (f : ι → α → ℝ)
    (hm : ∀ i, Measurable (f i)) (hi : ∀ i, Integrable (f i) μ) :
    Integrable (fun z : ι × α => f z.1 z.2) (Measure.count.prod μ) := by
  have hm' : Measurable (fun z : ι × α => f z.1 z.2) :=
    measurable_from_prod_countable_right hm
  apply (integrable_prod_iff hm'.aestronglyMeasurable).2
  constructor
  · exact Filter.Eventually.of_forall hi
  · exact integrable_count_iff.2 Summable.of_finite

theorem integral_finite_copies (f : ι → α → ℝ)
    (hm : ∀ i, Measurable (f i)) (hi : ∀ i, Integrable (f i) μ) :
    (∫ z : ι × α, f z.1 z.2 ∂(Measure.count.prod μ)) = ∑ i, ∫ x, f i x ∂μ := by
  rw [integral_prod _ (integrable_finite_copies f hm hi), integral_count]

variable {κ : Type*} [Fintype κ] [DecidableEq κ] {β : κ → Type*}
variable [∀ j, Fintype (β j)] [∀ j, Nonempty (β j)]

/-- Exact simultaneous balancing for a finite sum of Fourier coefficients.
The measure is the actual counting measure on coefficient copies times the
original integration measure. -/
theorem square_sum_integral_all_blocks_replacement
    (g : ι → α → ℝ) (f : (j : κ) → β j → ι → α → ℝ)
    (hg : ∀ i x, 0 ≤ g i x) (hf : ∀ j k i x, 0 ≤ f j k i x)
    (hbasem : ∀ i, Measurable (fun x => g i x * ∏ j, ∏ k, f j k i x))
    (hbase : ∀ i, Integrable (fun x => g i x * ∏ j, ∏ k, f j k i x) μ)
    (hreplacem : ∀ (pick : (j : κ) → β j) i,
      Measurable (fun x => g i x * ∏ j, f j (pick j) i x ^ Fintype.card (β j)))
    (hreplace : ∀ (pick : (j : κ) → β j) i,
      Integrable (fun x => g i x * ∏ j, f j (pick j) i x ^ Fintype.card (β j)) μ) :
    (∑ i, ∫ x, g i x * ∏ j, ∏ k, f j k i x ∂μ) ^ 2 ≤
      (∏ j, (Fintype.card (β j) : ℝ)⁻¹) *
        ∑ pick : (j : κ) → β j,
          (∑ i, ∫ x, g i x * ∏ j, f j (pick j) i x ^ Fintype.card (β j) ∂μ) ^ 2 := by
  have h := square_integral_all_blocks_replacement
    (μ := Measure.count.prod μ)
    (fun z : ι × α => g z.1 z.2)
    (fun j k z => f j k z.1 z.2)
    (fun z => hg z.1 z.2) (fun j k z => hf j k z.1 z.2)
    (integrable_finite_copies _ hbasem hbase)
    (fun pick => integrable_finite_copies _ (hreplacem pick) (hreplace pick))
  rw [integral_finite_copies _ hbasem hbase] at h
  have he (pick : (j : κ) → β j) :
      (∫ z : ι × α, g z.1 z.2 * ∏ j, f j (pick j) z.1 z.2 ^ Fintype.card (β j)
        ∂(Measure.count.prod μ)) =
      ∑ i, ∫ x, g i x * ∏ j, f j (pick j) i x ^ Fintype.card (β j) ∂μ :=
    integral_finite_copies _ (hreplacem pick) (hreplace pick)
  simp_rw [he] at h
  exact h

end NeuralGeneralization.OnlineLowerRelu
