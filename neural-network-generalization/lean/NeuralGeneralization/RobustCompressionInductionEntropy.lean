import NeuralGeneralization.RobustEntropyFuture
import NeuralGeneralization.RobustCompressionInductionHistory

/-! # Actual reference identities when consuming a Gaussian weight block

A finite message may depend on the complete source state. Once its reference
law is replaced by an independent uniform message, reconstruction acts only on
the exposed prefix/current block. The future remains an independent copy of
its prescribed reference. This module proves that identity from the concrete
channel, rather than assuming a conditional entropy estimate.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory
namespace NeuralGeneralization.RobustCompressionInduction
open RobustEntropy

variable {A B Y J : Type*} [MeasurableSpace A] [MeasurableSpace B]
  [MeasurableSpace Y] [MeasurableSpace J]

def messageReorder : (A × Y) × J → (A × J) × Y :=
  fun z => ((z.1.1,z.2),z.1.2)

theorem measurable_messageReorder : Measurable (messageReorder (A:=A) (Y:=Y) (J:=J)) := by
  unfold messageReorder
  fun_prop

/-- Reordering a genuinely independent reference message preserves the
product decomposition between the new exposed state and future. -/
theorem messageReorder_reference (ν : Measure A) (P : Measure Y) (U : Measure J)
    [SFinite ν] [SFinite P] [SFinite U] :
    ((ν.prod P).prod U).map messageReorder = (ν.prod U).prod P := by
  have h1 := measurePreserving_prodAssoc ν P U
  have h2 := (MeasurePreserving.id ν).prod
    (Measure.measurePreserving_swap (μ:=P) (ν:=U))
  have h3 := (measurePreserving_prodAssoc ν U P).symm
  have hh := (h3.comp h2).comp h1
  exact hh.map_eq

/-- Apply a reconstruction kernel to the exposed coordinates and message,
copying the future coordinate without inspecting it. -/
def messagePrefixChannel (χ : Kernel (A × J) B) : Kernel ((A × Y) × J) (B × Y) :=
  (χ ∥ₖ Kernel.id).comap messageReorder measurable_messageReorder

instance messagePrefixChannel_markov (χ : Kernel (A × J) B) [IsMarkovKernel χ] :
    IsMarkovKernel (messagePrefixChannel (Y:=Y) χ) := by
  unfold messagePrefixChannel
  infer_instance

/-- Concrete reference-law identity needed by the entropy argument. -/
theorem messagePrefixChannel_reference (χ : Kernel (A × J) B) [IsMarkovKernel χ]
    (ν : Measure A) (P : Measure Y) (U : Measure J)
    [SFinite ν] [SFinite P] [SFinite U] :
    messagePrefixChannel χ ∘ₘ ((ν.prod P).prod U) = (χ ∘ₘ (ν.prod U)).prod P := by
  unfold messagePrefixChannel
  rw [← Kernel.comp_deterministic_eq_comap, ← Measure.comp_assoc,
    Measure.deterministic_comp_eq_map, messageReorder_reference, ← Measure.prod_comp_left]

variable [StandardBorelSpace A] [StandardBorelSpace B] [StandardBorelSpace Y]
  [StandardBorelSpace J] [Nonempty A] [Nonempty B] [Nonempty Y]
  [Fintype J] [Nonempty J] [MeasurableSingletonClass J]

/-- Actual block-processing entropy bound with no unverified reference-law
premise. The finite message may depend on every original coordinate. -/
theorem futureEntropy_message_prefix_le (Q : Measure (A × Y)) [IsProbabilityMeasure Q]
    (ν : Measure A) [IsProbabilityMeasure ν]
    (P : Measure Y) [IsProbabilityMeasure P]
    (message : Kernel (A × Y) J) [IsMarkovKernel message]
    (χ : Kernel (A × J) B) [IsMarkovKernel χ] :
    futureEntropy (messagePrefixChannel χ ∘ₘ (Q ⊗ₘ message)) P ≤
      InformationTheory.klDiv Q (ν.prod P) +
        ENNReal.ofReal (Real.log (Fintype.card J)) := by
  apply futureEntropy_finite_message_channel_le Q (ν.prod P) P message
    (messagePrefixChannel χ) (χ ∘ₘ (ν.prod (messageUniform J)))
  rw [Measure.compProd_const]
  exact messagePrefixChannel_reference χ ν P (messageUniform J)

/-- Expose precisely the current block; remaining coordinates stay grouped
as the future. -/
def exposeBlock : A × (B × Y) → (A × B) × Y :=
  fun z => ((z.1,z.2.1),z.2.2)

theorem measurable_exposeBlock : Measurable (exposeBlock (A:=A) (B:=B) (Y:=Y)) := by
  unfold exposeBlock
  fun_prop

theorem exposeBlock_reference (ν : Measure A) (G : Measure B) (P : Measure Y)
    [SFinite ν] [SFinite G] [SFinite P] :
    (ν.prod (G.prod P)).map exposeBlock = (ν.prod G).prod P := by
  exact (measurePreserving_prodAssoc ν G P).symm.map_eq

variable {C : Type*} [MeasurableSpace C] [StandardBorelSpace C] [Nonempty C]

/-- One complete consumption step. The current block reference may be any
probability law, including the actual independent Gaussian matrix block.
No reference identity or conditional-KL bound remains as a premise. -/
theorem futureEntropy_consume_block_le
    (Q : Measure (A × (B × Y))) [IsProbabilityMeasure Q]
    (G : Measure B) [IsProbabilityMeasure G]
    (P : Measure Y) [IsProbabilityMeasure P]
    (message : Kernel ((A × B) × Y) J) [IsMarkovKernel message]
    (χ : Kernel ((A × B) × J) C) [IsMarkovKernel χ] :
    futureEntropy (messagePrefixChannel χ ∘ₘ
      ((Q.map exposeBlock) ⊗ₘ message)) P ≤
      futureEntropy Q (G.prod P) + ENNReal.ofReal (Real.log (Fintype.card J)) := by
  letI : IsProbabilityMeasure (Q.map (exposeBlock (A:=A) (B:=B) (Y:=Y))) :=
    Measure.isProbabilityMeasure_map measurable_exposeBlock.aemeasurable
  have hstep := futureEntropy_message_prefix_le (Q.map exposeBlock)
    (Q.fst.prod G) P message χ
  have hdata := RobustEntropy.klDiv_map_le Q (Q.fst.prod (G.prod P))
    measurable_exposeBlock
  rw [exposeBlock_reference] at hdata
  exact hstep.trans (add_le_add hdata le_rfl)

end NeuralGeneralization.RobustCompressionInduction
