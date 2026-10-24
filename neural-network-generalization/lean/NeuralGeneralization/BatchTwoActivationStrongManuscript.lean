import NeuralGeneralization.BatchTwoActivationStrongCommon
import NeuralGeneralization.BatchTwoActivationProductNormalizationMain
import NeuralGeneralization.BatchTwoActivationManuscriptBudgets

/-! The literal optimized strong-prior main theorem from the manuscript,
including its common event across learner widths and exact `B(B_*+1)`.
-/
noncomputable section
set_option maxHeartbeats 1600000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

theorem sharpAuxiliaryCapacity_productScale (d r:ℕ) (ℓ K:ℝ) :
    sharpAuxiliaryCapacity d (r+1) (sharpProductScale d r ℓ K)=manuscriptCapacity d r ℓ K := by
  unfold sharpAuxiliaryCapacity sharpProductScale manuscriptCapacity
  rw [Real.sqrt_div (by positivity : (0:ℝ)≤(d:ℝ)+1)]
  congr 1
  push_cast
  ring

theorem sharp_energy_class_card_le {d r:ℕ} (hd:1≤d) {ℓ K:ℝ} (hℓ:0<ℓ) (hK:0<K) :
    ((auxiliaryFunctions d (r+1) (sharpProductScale d r ℓ K)).card:ℝ)≤
      Real.exp (manuscriptLogCapacity d r ℓ K) := by
  have hh:=auxiliaryFunctions_sharp_card_le_exp (d:=d) (H:=r+1)
    (P:=sharpProductScale d r ℓ K) (by omega : 0<r+1)
    (sharpProductScale_pos (by omega) hℓ hK)
  rw [sharpAuxiliaryCapacity_productScale] at hh
  exact hh

/-- Paper Theorem `thm:strong`, with the exact printed capacity and teacher
energy, and one sample event for every admissible learner width. -/
theorem strong_prior_manuscript_learning {d C r:ℕ} (hd:1≤d) {φ:ℝ→ℝ} {ℓ:ℝ}
    (hφ:zeroLipschitzActivation ℓ φ) (hℓ:1≤ℓ)
    (f:BooleanFunction d) (hf:realizesAtComplexity (r:=r) φ f C)
    {ε:ℝ} (hε:0<ε) (hε1:ε<1) :
    ∃σ₀:ℕ→ℝ,(∀N,0<σ₀ N) ∧
      ∀D:InputLaw d,∀δ:ℝ,0<δ→∀n:ℕ,
      (2/ε)*(manuscriptLogCapacity d r ℓ (sharpTeacherBudget d C r+1)+Real.log (1/δ))≤(n:ℝ)→
      (∀N,C≤N→∀σ,0<σ→σ<σ₀ N→∀s:Fin n→Cube d,
        0<posteriorDenominator φ (1/2) (smallPrior d N r σ) f s) ∧
      1-δ≤sampleProbability D n (fun s=>∀N,C≤N→∀σ,0<σ→σ<σ₀ N→
        posteriorRisk D f (networkPosterior φ (1/2) (smallPrior d N r σ) f s)≤ε) := by
  have hℓ0:0<ℓ:=by linarith
  have hK:0<sharpTeacherBudget d C r+1:=by linarith [sharpTeacherBudget_nonneg d C r]
  apply strong_common_class_learning hd (zeroLipschitzActivation_continuous hφ hℓ0.le) f hf
    (auxiliaryFunctions d (r+1) (sharpProductScale d r ℓ (sharpTeacherBudget d C r+1)))
    (sharp_energy_class_card_le hd hℓ0 hK) _ hε hε1
  intro N hCN
  exact lowEnergyFunctions_subset_sharp_auxiliary (by omega) hφ hℓ0 f hf hCN

end NeuralGeneralization.BatchTwoActivation
