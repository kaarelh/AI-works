import NeuralGeneralization.RobustCompressionInductionBlocks
import NeuralGeneralization.RobustEntropyCurrentBlock

/-! # Conditional-current entropy for the literal original network blocks -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustCompressionInduction
open RobustEntropy
variable {A : Type*} [MeasurableSpace A] [StandardBorelSpace A] [Nonempty A]

def splitState (N r : ℕ) : A × FutureWeights N (r+1) →
    A × (InternalBlock N × FutureWeights N r) := Prod.map id (splitFuture N r)

theorem measurable_splitState (N r : ℕ) : Measurable (splitState (A:=A) N r) :=
  measurable_id.prodMap (splitFuture N r).measurable

theorem splitState_reference (N r : ℕ) (ν : Measure A) [SFinite ν] :
    (ν.prod (futurePrior N (r+1))).map (splitState N r) =
      ν.prod ((internalBlockPrior N).prod (futurePrior N r)) := by
  have hs : MeasurePreserving (splitFuture N r) (futurePrior N (r+1))
      ((internalBlockPrior N).prod (futurePrior N r)) :=
    ⟨(splitFuture N r).measurable,splitFuture_reference N r⟩
  exact ((MeasurePreserving.id ν).prod hs).map_eq

def currentConditioningLaw {N r : ℕ} (Q : Measure (A × FutureWeights N (r+1))) :
    Measure ((A × FutureWeights N r) × InternalBlock N) :=
  (Q.map (splitState N r)).map currentGivenFuture

instance currentConditioningLaw_probability {N r : ℕ}
    (Q : Measure (A × FutureWeights N (r+1))) [IsProbabilityMeasure Q] :
    IsProbabilityMeasure (currentConditioningLaw Q) := by
  letI : IsProbabilityMeasure (Q.map (splitState N r)) :=
    Measure.isProbabilityMeasure_map (measurable_splitState N r).aemeasurable
  exact Measure.isProbabilityMeasure_map measurable_currentGivenFuture.aemeasurable

theorem currentConditioningLaw_entropy_le {N r : ℕ}
    (Q : Measure (A × FutureWeights N (r+1))) [IsProbabilityMeasure Q] :
    (∫⁻ a, klDiv ((currentConditioningLaw Q).condKernel a) (internalBlockPrior N)
      ∂(currentConditioningLaw Q).fst) ≤ futureEntropy Q (futurePrior N (r+1)) := by
  letI : IsProbabilityMeasure (Q.map (splitState N r)) :=
    Measure.isProbabilityMeasure_map (measurable_splitState N r).aemeasurable
  have hcurrent := current_given_future_entropy_le (Q.map (splitState N r))
    (internalBlockPrior N) (futurePrior N r)
  have hprefix := futureEntropy_le_reference (Q.map (splitState N r)) Q.fst
    ((internalBlockPrior N).prod (futurePrior N r))
  have hdata := RobustEntropy.klDiv_map_le Q (Q.fst.prod (futurePrior N (r+1)))
    (measurable_splitState N r)
  rw [splitState_reference] at hdata
  exact hcurrent.trans (hprefix.trans hdata)

theorem currentConditioningLaw_entropy_ae_finite {N r : ℕ}
    (Q : Measure (A × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (hfin : futureEntropy Q (futurePrior N (r+1)) ≠ ∞) :
    ∀ᵐ a ∂(currentConditioningLaw Q).fst,
      klDiv ((currentConditioningLaw Q).condKernel a) (internalBlockPrior N) ≠ ∞ := by
  have hmean := ne_top_of_le_ne_top hfin (currentConditioningLaw_entropy_le Q)
  have hm : Measurable (fun a => klDiv ((currentConditioningLaw Q).condKernel a)
      (internalBlockPrior N)) :=
    measurable_kernel_klDiv _ (Kernel.const _ (internalBlockPrior N))
  filter_upwards [ae_lt_top hm hmean] with a ha
  exact ha.ne

end NeuralGeneralization.RobustCompressionInduction
