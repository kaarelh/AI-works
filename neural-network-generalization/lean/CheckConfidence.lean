import NeuralGeneralization
import Lean.Util.CollectAxioms
import Lean.Elab.Command

/-!
# Strict-confidence corollaries of the first two main theorems

The strong-prior and above-mean-field main statements bound posterior average
error. Markov's inequality, in the exact strict `> 2/3` convention, converts an
average-error bound `ε/3` into a bound `ε` on the fraction of test inputs whose
correct label has posterior probability at most `2/3`. This file applies that
conversion to the actual network posteriors, so the confidence guarantees
stated in the two manuscripts are themselves closed theorems. The cost is the
usual rescaling: `2/ε` becomes `6/ε`, and `ε` becomes `ε/3` inside the
logarithms. The mean-field statement already includes its confidence
conclusion, and the robust statement includes its margin-confidence conclusion.

This file is a supplement, like `CheckParity.lean`; it is not imported by the
library, so the main module closure is unchanged.
-/

noncomputable section

namespace NeuralGeneralization.ConfidenceCorollaries

open ConcreteModel MainStatements

/-- Positivity of the actual posterior denominator suffices for the strict
Markov conversion; no positivity of the target's own mass is needed. -/
theorem confidenceFailure_le_three_risk_of_denominator {d N r n : ℕ}
    (φ : ℝ → ℝ) (a : ℝ) (μ : MeasureTheory.Measure (Weights d N r))
    (D : InputLaw d) (f : BooleanFunction d) (s : Fin n → Cube d)
    (h : 0 < posteriorDenominator φ a μ f s) :
    ConcreteModel.confidenceFailure D f (networkPosterior φ a μ f s) ≤
      3 * ConcreteModel.posteriorRisk D f (networkPosterior φ a μ f s) := by
  classical
  have hsum : (∑ _g : BooleanFunction d, (0 : ℝ)) <
      ∑ g, (if consistent f s g then functionMass φ a μ g else 0) := by
    simpa [posteriorDenominator, NeuralGeneralization.normalizer] using h
  obtain ⟨g, -, hg⟩ := Finset.exists_lt_of_sum_lt hsum
  have hkeep : consistent f s g := by
    by_contra hk
    simp [hk] at hg
  have hmass : 0 < functionMass φ a μ g := by
    simpa [hkeep] using hg
  rw [confidenceFailure_eq_generic, posteriorRisk_eq_averageRisk]
  exact NeuralGeneralization.confidenceFailure_le_three_risk
    (networkPosterior φ a μ f s) D.mass (fun g x => g x) f
    (fun h => NeuralGeneralization.posterior_nonneg (functionMass φ a μ)
      (consistent f s) (functionMass_nonneg φ a μ) g hkeep hmass h)
    (NeuralGeneralization.posterior_sum (functionMass φ a μ)
      (consistent f s) (functionMass_nonneg φ a μ) g hkeep hmass)
    D.nonneg

/-- Strong-prior paper, Theorem 2.2, with the strict `>2/3` confidence
conclusion. Same quantifier order as `StrongPriorGeneralization`. -/
theorem strongPriorConfidence :
    ∀ r : ℕ, ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
      ∀ φ : ℝ → ℝ, admissibleActivation φ →
      ∀ d : ℕ, 1 ≤ d → ∀ f : BooleanFunction d, ∀ C : ℕ,
        isComplexity (r := r) φ f C →
      ∀ N : ℕ, C ≤ N → ∀ ε : ℝ, 0 < ε → ε < 1 →
      ∃ σ₀ : ℝ, 0 < σ₀ ∧
        ∀ σ : ℝ, 0 < σ → σ < σ₀ →
        ∀ D : InputLaw d, ∀ δ : ℝ, 0 < δ → δ < 1 →
        ∀ n : ℕ,
          (6 / ε) * (polynomialEnvelope A m d C 0 + Real.log (1 / δ)) ≤ (n : ℝ) →
          1 - δ ≤ sampleProbability D n (fun s =>
            ConcreteModel.posteriorRisk D f
                (networkPosterior φ (1 / 2) (smallPrior d N r σ) f s) ≤ ε / 3 ∧
            ConcreteModel.confidenceFailure D f
                (networkPosterior φ (1 / 2) (smallPrior d N r σ) f s) ≤ ε) := by
  intro r
  obtain ⟨A, hA, m, hmain⟩ := MainProofs.strongPrior r
  refine ⟨A, hA, m, ?_⟩
  intro φ hφ d hd f C hC N hCN ε hε hε1
  obtain ⟨σ₀, hσ₀, hlearn⟩ :=
    hmain φ hφ d hd f C hC N hCN (ε / 3) (by positivity) (by linarith)
  refine ⟨σ₀, hσ₀, ?_⟩
  intro σ hσ hσσ₀ D δ hδ hδ1 n hn
  have hscale : (2 / (ε / 3)) = 6 / ε := by field_simp; norm_num
  obtain ⟨hden, hprob⟩ := hlearn σ hσ hσσ₀ D δ hδ hδ1 n (by rw [hscale]; exact hn)
  refine hprob.trans (sampleProbability_mono D n _ _ ?_)
  intro s hs
  refine ⟨hs, ?_⟩
  have h3 := confidenceFailure_le_three_risk_of_denominator φ (1 / 2)
    (smallPrior d N r σ) D f s (hden s)
  linarith

/-- Above-mean-field paper, Theorem 4.3, with the strict `>2/3` confidence
conclusion. Same quantifier order as `AboveMeanFieldGeneralization`. -/
theorem aboveMeanFieldConfidence :
    ∀ r : ℕ, ∀ γ : ℝ, 1 < γ →
      ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
      ∀ φ : ℝ → ℝ, admissibleActivation φ →
      ∀ d : ℕ, 1 ≤ d → ∀ f : BooleanFunction d, ∀ C : ℕ,
        isComplexity (r := r) φ f C →
      ∀ N : ℕ, C ≤ N → ∀ D : InputLaw d,
      ∀ ε δ : ℝ, 0 < ε → ε < 1 → 0 < δ → δ < 1 →
      ∀ n : ℕ,
        (6 / ε) * (polynomialEnvelope A m d C (Real.log (3 / ε)) +
          Real.log (6 / (ε * δ))) ≤ (n : ℝ) →
        1 - δ ≤ sampleProbability D n (fun s =>
          ConcreteModel.posteriorRisk D f
              (networkPosterior φ (1 / 2) (powerPrior d N r γ) f s) ≤ ε / 3 ∧
          ConcreteModel.confidenceFailure D f
              (networkPosterior φ (1 / 2) (powerPrior d N r γ) f s) ≤ ε) := by
  intro r γ hγ
  obtain ⟨A, hA, m, hmain⟩ := MainProofs.aboveMeanField r γ hγ
  refine ⟨A, hA, m, ?_⟩
  intro φ hφ d hd f C hC N hCN D ε δ hε hε1 hδ hδ1 n hn
  have h1 : (2 / (ε / 3)) = 6 / ε := by field_simp; norm_num
  have h2 : (1 / (ε / 3)) = 3 / ε := by field_simp
  have h3 : (2 / (ε / 3 * δ)) = 6 / (ε * δ) := by field_simp; norm_num
  obtain ⟨hden, hprob⟩ := hmain φ hφ d hd f C hC N hCN D (ε / 3) δ
    (by positivity) (by linarith) hδ hδ1 n (by rw [h1, h2, h3]; exact hn)
  refine hprob.trans (sampleProbability_mono D n _ _ ?_)
  intro s hs
  refine ⟨hs, ?_⟩
  have h3 := confidenceFailure_le_three_risk_of_denominator φ (1 / 2)
    (powerPrior d N r γ) D f s (hden s)
  linarith

end NeuralGeneralization.ConfidenceCorollaries

open Lean Elab Command in
run_cmd do
  let allowed := #[``propext, ``Classical.choice, ``Quot.sound]
  for proofName in #[``NeuralGeneralization.ConfidenceCorollaries.strongPriorConfidence,
      ``NeuralGeneralization.ConfidenceCorollaries.aboveMeanFieldConfidence] do
    let info ← getConstInfo proofName
    unless info.isTheorem do throwError "Expected a theorem: {proofName}"
    let axioms ← Lean.collectAxioms proofName
    unless (axioms.filter fun a => !allowed.contains a).isEmpty do
      throwError "Unexpected axioms for {proofName}: {axioms}"
  logInfo "Strict >2/3 confidence corollaries of the strong-prior and above-mean-field theorems verified."
