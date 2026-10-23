import NeuralGeneralization.BatchTwoCircuitConversePrefixPosterior
import NeuralGeneralization.BatchTwoCircuitConversePrefixCoding
import Mathlib.MeasureTheory.Integral.Bochner.Basic

/-!
# Averaging the prefix-code converse over random complete reveal paths

The averaged quantity is the predictable posterior-error compensator. It equals
expected actual sampling mistakes when the fresh sampled predictions obey the
specified posterior conditional law; this file does not silently assume a
complexity bound or a label-probability estimate in that law.
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse.Prefix

open scoped BigOperators
open MeasureTheory
noncomputable section
open Classical

variable {d : ℕ}

/-- Random complete reveal orders, including arbitrary path-dependent stopping
indices, satisfy all linear converse and code bound with the exact manuscript constants.
The only regularity assumption is measurability of the actual posterior error sum. -/
theorem prefix_random_reveal_compensator_bounds
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (f : Input d → Bool) (A : Finset (Input d))
    (query : Ω → ℕ → Input d) (stop : Ω → ℕ)
    (hcover : ∀ᵐ ω ∂μ, history (query ω) (stop ω) = A)
    (hmeas : AEStronglyMeasurable (fun ω =>
      BatchTwoOnline.cumulativeError (functionWeight d)
        (fun g x => g x = f x) (query ω) (stop ω)) μ) :
    let M := ∫ ω, BatchTwoOnline.cumulativeError (functionWeight d)
      (fun g x => g x = f x) (query ω) (stop ω) ∂μ
    (complexity f A : ℝ) ≤ (6*(d+2)/(1-beta d))*M+12 ∧
    M ≤ 2*(codeComplexity f A)*Real.log 2 ∧
    codeComplexity f A ≤ 3+complexity f A+
      2*complexity f A*Nat.clog 2 (d+complexity f A+1) := by
  let m := fun ω => BatchTwoOnline.cumulativeError (functionWeight d)
    (fun g x => g x = f x) (query ω) (stop ω)
  have hmnonneg : ∀ ω, 0 ≤ m ω := by
    intro ω
    dsimp [m]
    rw [← predictionMistakes_eq_cumulativeError]
    exact predictionMistakes_nonneg _ _ _
  have hmupper : ∀ᵐ ω ∂μ, m ω ≤ versionLoss f A := hcover.mono (fun ω hcoverω => by
    have h := predictionMistakes_le_versionLoss f (query ω) (stop ω)
    simpa only [hcoverω, predictionMistakes_eq_cumulativeError] using h)
  have hmInt : Integrable m μ := (integrable_const (versionLoss f A)).mono' hmeas
    (hmupper.mono (fun ω hupperω => by
      rw [Real.norm_eq_abs, abs_of_nonneg (hmnonneg ω)]
      exact hupperω))
  have hpath : ∀ᵐ ω ∂μ, versionLoss f A ≤ cost d*m ω :=
    hcover.mono (fun ω hcoverω => by
      simpa only [hcoverω, predictionMistakes_eq_cumulativeError] using
        prefix_pathwise_loss f (query ω) (stop ω))
  have hmeanLoss := integral_mono_ae (integrable_const (versionLoss f A))
    (hmInt.const_mul (cost d))
    hpath
  simp only [integral_const, probReal_univ, one_smul, integral_const_mul] at hmeanLoss
  have hmeanUpper := integral_mono_ae hmInt (integrable_const (versionLoss f A))
    hmupper
  simp only [integral_const, probReal_univ, one_smul] at hmeanUpper
  exact ⟨complexity_bound_of_loss_bound f A hmeanLoss,
    hmeanUpper.trans (versionLoss_le_code f A), codeComplexity_le_gate_code f A⟩

end
end NeuralGeneralization.BatchTwoCircuitConverse.Prefix
