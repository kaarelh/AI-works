import NeuralGeneralization.RobustEntropyChain
import NeuralGeneralization.RobustEntropyFiniteMessage
import Mathlib.Probability.Kernel.Composition.Lemmas

/-!
# Entropy of unprocessed weights conditional on an arbitrary prefix

The prefix distribution is not required to have a density with respect to any
Gaussian reference. We compare a joint law with the product of its *own* first
marginal and the fixed future reference. Markov compression of the prefix can
only decrease this conditional relative entropy.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory

namespace NeuralGeneralization.RobustEntropy

variable {A B Y : Type*} [MeasurableSpace A] [MeasurableSpace B] [MeasurableSpace Y]

/-- Conditional future entropy, defined without integrating a possibly
nonmeasurable pointwise KL expression. -/
def futureEntropy (Q : Measure (A × Y)) (P : Measure Y) : ℝ≥0∞ :=
  InformationTheory.klDiv Q (Q.fst.prod P)

/-- The actual prefix marginal minimizes the product-reference KL. -/
theorem futureEntropy_le_reference [StandardBorelSpace Y] [Nonempty Y]
    (Q : Measure (A × Y)) [IsFiniteMeasure Q]
    (ν : Measure A) [IsFiniteMeasure ν]
    (P : Measure Y) [IsProbabilityMeasure P] :
    futureEntropy Q P ≤ InformationTheory.klDiv Q (ν.prod P) := by
  have h := conditional_klDiv_le Q.fst ν Q.condKernel (Kernel.const A P)
  simpa only [Measure.disintegrate, Measure.compProd_const, futureEntropy] using h

/-- General reference-preserving channel form. The reference identity is an
explicit identity of measures, not an assumed entropy bound. -/
theorem futureEntropy_channel_le [StandardBorelSpace A] [StandardBorelSpace B]
    [StandardBorelSpace Y] [Nonempty A] [Nonempty B] [Nonempty Y]
    (Q : Measure (A × Y)) [IsFiniteMeasure Q]
    (ν : Measure A) [IsFiniteMeasure ν]
    (P : Measure Y) [IsProbabilityMeasure P]
    (χ : Kernel (A × Y) (B × Y)) [IsMarkovKernel χ]
    (ν' : Measure B) [IsFiniteMeasure ν']
    (href : χ ∘ₘ (ν.prod P) = ν'.prod P) :
    futureEntropy (χ ∘ₘ Q) P ≤ InformationTheory.klDiv Q (ν.prod P) := by
  calc
    futureEntropy (χ ∘ₘ Q) P ≤
        InformationTheory.klDiv (χ ∘ₘ Q) (ν'.prod P) :=
      futureEntropy_le_reference _ ν' P
    _ = InformationTheory.klDiv (χ ∘ₘ Q) (χ ∘ₘ (ν.prod P)) := by rw [href]
    _ ≤ InformationTheory.klDiv Q (ν.prod P) := klDiv_comp_le _ _ χ

/-- Compressing the exposed prefix, while leaving the future untouched, does
not increase its conditional relative entropy. This permits arbitrary singular
prefixes and arbitrary random prefix channels. -/
theorem futureEntropy_prefix_channel_le [StandardBorelSpace A]
    [StandardBorelSpace B] [StandardBorelSpace Y]
    [Nonempty A] [Nonempty B] [Nonempty Y]
    (Q : Measure (A × Y)) [IsFiniteMeasure Q]
    (P : Measure Y) [IsProbabilityMeasure P]
    (κ : Kernel A B) [IsMarkovKernel κ] :
    futureEntropy ((κ ∥ₖ Kernel.id) ∘ₘ Q) P ≤ futureEntropy Q P := by
  exact futureEntropy_channel_le Q Q.fst P (κ ∥ₖ Kernel.id)
    (κ ∘ₘ Q.fst) (Measure.prod_comp_left.symm)

/-- A finite message followed by a reference-preserving random channel costs
at most `log card J` in future entropy. The message can depend on every original
coordinate. The hypothesis `href` is only the explicit reference-law identity;
no conditional-KL estimate is assumed. -/
theorem futureEntropy_finite_message_channel_le
    {W J : Type*} [MeasurableSpace W] [StandardBorelSpace W] [Nonempty W]
    [MeasurableSpace J] [Fintype J] [Nonempty J] [MeasurableSingletonClass J]
    [StandardBorelSpace J] [StandardBorelSpace B] [StandardBorelSpace Y]
    [Nonempty B] [Nonempty Y]
    (Q R : Measure W) [IsProbabilityMeasure Q] [IsProbabilityMeasure R]
    (P : Measure Y) [IsProbabilityMeasure P]
    (κ : Kernel W J) [IsMarkovKernel κ]
    (χ : Kernel (W × J) (B × Y)) [IsMarkovKernel χ]
    (ν : Measure B) [IsFiniteMeasure ν]
    (href : χ ∘ₘ (R ⊗ₘ Kernel.const W (messageUniform J)) = ν.prod P) :
    futureEntropy (χ ∘ₘ (Q ⊗ₘ κ)) P ≤
      InformationTheory.klDiv Q R + ENNReal.ofReal (Real.log (Fintype.card J)) := by
  calc
    futureEntropy (χ ∘ₘ (Q ⊗ₘ κ)) P ≤
        InformationTheory.klDiv (χ ∘ₘ (Q ⊗ₘ κ)) (ν.prod P) :=
      futureEntropy_le_reference _ ν P
    _ = InformationTheory.klDiv (χ ∘ₘ (Q ⊗ₘ κ))
        (χ ∘ₘ (R ⊗ₘ Kernel.const W (messageUniform J))) := by rw [href]
    _ ≤ InformationTheory.klDiv (Q ⊗ₘ κ)
        (R ⊗ₘ Kernel.const W (messageUniform J)) := klDiv_comp_le _ _ χ
    _ ≤ _ := finite_message_kl_cost Q R κ

end NeuralGeneralization.RobustEntropy
