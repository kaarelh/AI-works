import NeuralGeneralization.RobustCompressionInductionBlocks
import NeuralGeneralization.RobustCompressionInductionStateMeasurable

/-! # The actual canonical law at one recursion step

A canonical state retains the remaining original standardized coefficients.
The finite message may inspect their conditional law, while the reconstruction
kernel is forbidden to inspect the future except through that finite message.
This is enforced by the kernel's domain, not by a conditional independence
hypothesis supplied by the caller.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ProbabilityTheory ENNReal
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustEntropy

variable {A : Type*} [MeasurableSpace A]

def canonicalInput (N r : ℕ) : A × FutureWeights N (r+1) →
    (A × InternalBlock N) × FutureWeights N r :=
  fun z => ((z.1,(splitFuture N r z.2).1),(splitFuture N r z.2).2)

theorem measurable_canonicalInput (N r : ℕ) : Measurable (canonicalInput (A:=A) N r) := by
  exact (measurable_fst.prodMk ((splitFuture N r).measurable.comp measurable_snd).fst).prodMk
    ((splitFuture N r).measurable.comp measurable_snd).snd

theorem canonicalInput_reference (N r : ℕ) (ν : Measure A) [SFinite ν] :
    (ν.prod (futurePrior N (r+1))).map (canonicalInput N r) =
      (ν.prod (internalBlockPrior N)).prod (futurePrior N r) := by
  have hs : MeasurePreserving (splitFuture N r) (futurePrior N (r+1))
      ((internalBlockPrior N).prod (futurePrior N r)) :=
    ⟨(splitFuture N r).measurable,splitFuture_reference N r⟩
  have h1 := (MeasurePreserving.id ν).prod hs
  have h2 := (measurePreserving_prodAssoc ν (internalBlockPrior N) (futurePrior N r)).symm
  exact (h2.comp h1).map_eq

variable {J : Type*} [MeasurableSpace J]

/-- A complete depth step on the actual standardized remaining weights. -/
def canonicalStepLaw {d N m s r : ℕ}
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1)))
    (message : Kernel ((ActivePrefix d N m s × InternalBlock N) × FutureWeights N r) J)
    (reconstruct : Kernel ((ActivePrefix d N m s × InternalBlock N) × J)
      (ActivePrefix d N m (s+1))) :
    Measure (ActivePrefix d N m (s+1) × FutureWeights N r) :=
  messagePrefixChannel reconstruct ∘ₘ ((Q.map (canonicalInput N r)) ⊗ₘ message)

instance canonicalStepLaw_probability {d N m s r : ℕ}
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (message : Kernel ((ActivePrefix d N m s × InternalBlock N) × FutureWeights N r) J)
    [IsMarkovKernel message]
    (reconstruct : Kernel ((ActivePrefix d N m s × InternalBlock N) × J)
      (ActivePrefix d N m (s+1))) [IsMarkovKernel reconstruct] :
    IsProbabilityMeasure (canonicalStepLaw Q message reconstruct) := by
  letI : IsProbabilityMeasure (Q.map (canonicalInput N r)) :=
    Measure.isProbabilityMeasure_map (measurable_canonicalInput N r).aemeasurable
  unfold canonicalStepLaw
  infer_instance

variable [Fintype J] [Nonempty J] [MeasurableSingletonClass J] [StandardBorelSpace J]

/-- The actual next state's future entropy has only the logarithmic finite
message overhead. Prefix densities and posterior independence are never assumed. -/
theorem canonicalStepLaw_futureEntropy_le {d N m s r : ℕ}
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (message : Kernel ((ActivePrefix d N m s × InternalBlock N) × FutureWeights N r) J)
    [IsMarkovKernel message]
    (reconstruct : Kernel ((ActivePrefix d N m s × InternalBlock N) × J)
      (ActivePrefix d N m (s+1))) [IsMarkovKernel reconstruct] :
    futureEntropy (canonicalStepLaw Q message reconstruct) (futurePrior N r) ≤
      futureEntropy Q (futurePrior N (r+1))+
        ENNReal.ofReal (Real.log (Fintype.card J)) := by
  letI : IsProbabilityMeasure (Q.map (canonicalInput N r)) :=
    Measure.isProbabilityMeasure_map (measurable_canonicalInput N r).aemeasurable
  have hstep := futureEntropy_message_prefix_le (Q.map (canonicalInput N r))
    (Q.fst.prod (internalBlockPrior N)) (futurePrior N r) message reconstruct
  have hdata := RobustEntropy.klDiv_map_le Q (Q.fst.prod (futurePrior N (r+1)))
    (measurable_canonicalInput N r)
  rw [canonicalInput_reference] at hdata
  exact hstep.trans (add_le_add hdata le_rfl)

end NeuralGeneralization.RobustCompressionInduction
