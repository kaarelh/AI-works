import NeuralGeneralization.BatchTwoCircuitConverseLower
import Mathlib.MeasureTheory.Integral.Bochner.Basic

/-!
# Averaging the geometric converse over random complete reveal paths

The averaged quantity is the predictable posterior-error compensator. It equals
expected actual sampling mistakes when the fresh sampled predictions obey the
specified posterior conditional law; this file does not silently assume a
complexity bound or a label-probability estimate in that law.
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse

open scoped BigOperators
open MeasureTheory
noncomputable section
open Classical

variable {d : ℕ}

theorem predictionMistakes_le_versionLoss (f : Input d → Bool)
    (query : ℕ → Input d) (n : ℕ) :
    predictionMistakes f query n ≤ versionLoss f (history query n) := by
  rw [versionLoss_eq_sum_log]
  unfold predictionMistakes
  apply Finset.sum_le_sum
  intro i hi
  have h := Real.log_le_sub_one_of_pos (correctProbability_pos f (history query i) (query i))
  linarith

/-- Random complete reveal orders, including arbitrary path-dependent stopping
indices, satisfy all three numerical bounds with the exact manuscript constants.
The only regularity assumption is measurability of the actual posterior error sum. -/
theorem geometric_random_reveal_compensator_bounds
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (f : Input d → Bool) (A : Finset (Input d))
    (query : Ω → ℕ → Input d) (stop : Ω → ℕ)
    (hcover : ∀ᵐ ω ∂μ, history (query ω) (stop ω) = A)
    (hmeas : AEStronglyMeasurable (fun ω =>
      BatchTwoOnline.cumulativeError (functionWeight d)
        (fun g x => g x = f x) (query ω) (stop ω)) μ) :
    let M := ∫ ω, BatchTwoOnline.cumulativeError (functionWeight d)
      (fun g x => g x = f x) (query ω) (stop ω) ∂μ
    ((complexity f A : ℝ)*Real.log 2) /
      (2*predictiveCost d ((complexity f A : ℝ)*Real.log 2)) ≤ M ∧
    (complexity f A : ℝ) ≤ (12*((3*d+3 : ℕ):ℝ)*M/Real.log 2) *
      Real.log (((4*d+6 : ℕ):ℝ) + 12*((3*d+3 : ℕ):ℝ)*M/Real.log 2) ∧
    M ≤ gateBudget d (complexity f A) := by
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
  have hmean0 : 0 ≤ ∫ ω, m ω ∂μ := integral_nonneg hmnonneg
  have hpath : ∀ᵐ ω ∂μ, versionLoss f A ≤ 2*predictiveCost d (versionLoss f A)*m ω :=
    hcover.mono (fun ω hcoverω => by
      simpa only [hcoverω, predictionMistakes_eq_cumulativeError] using
        geometric_pathwise_loss f (query ω) (stop ω))
  have hmeanLoss := integral_mono_ae (integrable_const (versionLoss f A))
    (hmInt.const_mul (2*predictiveCost d (versionLoss f A)))
    hpath
  simp only [integral_const, probReal_univ, one_smul, integral_const_mul] at hmeanLoss
  have hmeanUpper := integral_mono_ae hmInt (integrable_const (versionLoss f A))
    hmupper
  simp only [integral_const, probReal_univ, one_smul] at hmeanUpper
  exact ⟨complexity_lower_of_loss_bound f A hmeanLoss,
    complexity_bound_of_loss_bound f A hmean0 hmeanLoss,
    hmeanUpper.trans (versionLoss_le_budget f A)⟩

end
end NeuralGeneralization.BatchTwoCircuitConverse
