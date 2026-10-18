import NeuralGeneralization.RobustEntropyResidualKernel
import NeuralGeneralization.RobustEntropyFuture

/-! # Current-block entropy conditioned on the entire future

The source current block is conditioned on both the compressed prefix and the
untouched future, not merely on the prefix. Its averaged actual conditional
KL is bounded by the old conditional future entropy.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal ProbabilityTheory

namespace NeuralGeneralization.RobustEntropy

variable {A B Y : Type*} [MeasurableSpace A] [MeasurableSpace B] [MeasurableSpace Y]
    [StandardBorelSpace A] [StandardBorelSpace B] [StandardBorelSpace Y]
    [Nonempty A] [Nonempty B] [Nonempty Y]

/-- Reorder so the conditioning variables are precisely (prefix,future). -/
def currentGivenFuture : A × (B × Y) → (A × Y) × B :=
  fun p => ((p.1,p.2.2),p.2.1)

theorem measurable_currentGivenFuture :
    Measurable (currentGivenFuture (A := A) (B := B) (Y := Y)) := by
  unfold currentGivenFuture
  fun_prop

theorem currentGivenFuture_reference
    (ν : Measure A) (G : Measure B) (P : Measure Y)
    [SFinite ν] [SFinite G] [SFinite P] :
    (ν.prod (G.prod P)).map currentGivenFuture = (ν.prod P).prod G := by
  have h1 := (MeasurePreserving.id ν).prod (Measure.measurePreserving_swap (μ := G) (ν := P))
  have h2 := (measurePreserving_prodAssoc ν P G).symm
  exact (h2.comp h1).map_eq

/-- Exact integral formula for disintegrating a probability measure. -/
theorem futureEntropy_eq_lintegral_conditional
    (Q : Measure (A × B)) [IsProbabilityMeasure Q]
    (G : Measure B) [IsProbabilityMeasure G] :
    futureEntropy Q G = ∫⁻ a, klDiv (Q.condKernel a) G ∂Q.fst := by
  have h := klDiv_compProd_same_left_eq_lintegral Q.fst Q.condKernel (Kernel.const A G)
  simpa only [Measure.disintegrate,Measure.compProd_const,Kernel.const_apply,futureEntropy] using h

/-- The actual conditional-current KL has the old entropy budget. No premise
about Gaussian conditioning or independence under the posterior is imposed. -/
theorem current_given_future_entropy_le
    (Q : Measure (A × (B × Y))) [IsProbabilityMeasure Q]
    (G : Measure B) [IsProbabilityMeasure G]
    (P : Measure Y) [IsProbabilityMeasure P] :
    (∫⁻ a, klDiv ((Q.map currentGivenFuture).condKernel a) G
      ∂(Q.map currentGivenFuture).fst) ≤ futureEntropy Q (G.prod P) := by
  let ρ := Q.map (currentGivenFuture (A := A) (B := B) (Y := Y))
  letI : IsProbabilityMeasure ρ := Measure.isProbabilityMeasure_map
    measurable_currentGivenFuture.aemeasurable
  change (∫⁻ a, klDiv (ρ.condKernel a) G ∂ρ.fst) ≤ _
  rw [← futureEntropy_eq_lintegral_conditional]
  have hchain := futureEntropy_le_reference ρ (Q.fst.prod P) G
  have hdata := klDiv_map_le Q (Q.fst.prod (G.prod P)) measurable_currentGivenFuture
  rw [currentGivenFuture_reference] at hdata
  exact hchain.trans hdata

/-- Finite old future entropy makes all infinite conditional-KL fibers null. -/
theorem current_given_future_entropy_ae_finite
    (Q : Measure (A × (B × Y))) [IsProbabilityMeasure Q]
    (G : Measure B) [IsProbabilityMeasure G]
    (P : Measure Y) [IsProbabilityMeasure P]
    (hfin : futureEntropy Q (G.prod P) ≠ ∞) :
    ∀ᵐ a ∂(Q.map currentGivenFuture).fst,
      klDiv ((Q.map currentGivenFuture).condKernel a) G ≠ ∞ := by
  have hmean := ne_top_of_le_ne_top hfin (current_given_future_entropy_le Q G P)
  have hm : Measurable (fun a => klDiv ((Q.map currentGivenFuture).condKernel a) G) :=
    measurable_kernel_klDiv _ (Kernel.const _ G)
  filter_upwards [ae_lt_top hm hmean] with a ha
  exact ha.ne

end NeuralGeneralization.RobustEntropy
