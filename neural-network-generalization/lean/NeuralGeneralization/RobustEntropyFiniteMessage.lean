import NeuralGeneralization.RobustEntropyChain
import NeuralGeneralization.RobustEntropyDomination
import Mathlib.Probability.Distributions.Uniform

/-!
# Finite messages in the entropy bookkeeping

A probability kernel with a finite output alphabet is dominated by the alphabet
size times the uniform reference kernel. This is the measure-level input to the
logarithmic message entropy cost, including randomized messages.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory

namespace NeuralGeneralization.RobustEntropy

variable {J A : Type*} [MeasurableSpace J] [Fintype J] [Nonempty J]
    [MeasurableSingletonClass J] [MeasurableSpace A]

def messageUniform (J : Type*) [MeasurableSpace J] [Fintype J] [Nonempty J] :
    Measure J := (PMF.uniformOfFintype J).toMeasure

instance messageUniform_probability : IsProbabilityMeasure (messageUniform J) := by
  unfold messageUniform
  infer_instance

theorem probability_le_card_uniform (P : Measure J) [IsProbabilityMeasure P] :
    P ≤ (Fintype.card J : ℝ≥0∞) • messageUniform J := by
  classical
  apply Measure.le_iff.mpr
  intro s hs
  by_cases hse : s = ∅
  · simp [hse]
  obtain ⟨j, hj⟩ := Set.nonempty_iff_ne_empty.mpr hse
  have hcard : (Fintype.card J : ℝ≥0∞) ≠ 0 := by
    exact_mod_cast Fintype.card_ne_zero
  rw [Measure.smul_apply, smul_eq_mul]
  calc
    P s ≤ 1 := prob_le_one
    _ = (Fintype.card J : ℝ≥0∞) * messageUniform J {j} := by
      simp [messageUniform, PMF.toMeasure_apply_singleton _ _ (measurableSet_singleton _),
        ENNReal.mul_inv_cancel hcard (by simp)]
    _ ≤ (Fintype.card J : ℝ≥0∞) * messageUniform J s := by
      exact mul_le_mul_right (measure_mono (μ := messageUniform J)
        (Set.singleton_subset_iff.mpr hj)) _

/-- The bound holds for an arbitrary message kernel, not only a deterministic
message. It retains the entire original source state in the first marginal. -/
theorem message_joint_le_card_reference (μ : Measure A) [IsFiniteMeasure μ]
    (κ : Kernel A J) [IsMarkovKernel κ] :
    μ ⊗ₘ κ ≤ (Fintype.card J : ℝ≥0∞) •
      (μ ⊗ₘ Kernel.const A (messageUniform J)) := by
  apply Measure.le_iff.mpr
  intro s hs
  rw [Measure.compProd_apply hs, Measure.smul_apply, smul_eq_mul,
    Measure.compProd_apply hs]
  simp only [Kernel.const_apply]
  rw [← lintegral_const_mul _ (measurable_measure_prodMk_left hs)]
  apply lintegral_mono
  intro a
  exact (probability_le_card_uniform (κ a)) _

/-- Revealing a finite message costs at most the logarithm of its alphabet,
even if the message depends on the entire uncompressed state. -/
theorem finite_message_kl_cost (μ ν : Measure A)
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (κ : Kernel A J) [IsMarkovKernel κ] :
    InformationTheory.klDiv (μ ⊗ₘ κ) (ν ⊗ₘ Kernel.const A (messageUniform J)) ≤
      InformationTheory.klDiv μ ν +
        ENNReal.ofReal (Real.log (Fintype.card J)) := by
  rw [InformationTheory.klDiv_compProd_eq_add]
  apply add_le_add le_rfl
  apply RobustEntropyDomination.klDiv_le_log_of_le_smul
  · exact_mod_cast Fintype.card_pos
  · simpa only [ENNReal.ofReal_natCast] using message_joint_le_card_reference μ κ

end NeuralGeneralization.RobustEntropy
