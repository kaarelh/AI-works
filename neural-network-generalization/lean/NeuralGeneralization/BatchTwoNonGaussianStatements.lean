import NeuralGeneralization.BatchTwoNonGaussianModel
import NeuralGeneralization.Statements

/-! Exact main proof targets from `side-results/non-gaussian-priors/source/paper.tex`.
These are propositions, not proof assumptions or claimed verification gates. -/

noncomputable section
open NeuralGeneralization.ConcreteModel
namespace NeuralGeneralization.BatchTwoNonGaussian

/-- Paper Theorem 2.1: the scale threshold precedes the input law, confidence,
and sample size, and may depend on the fixed finite learner width. -/
def StrongPriorGeneralization : Prop :=
  ∀ r : ℕ, ∀ ν : CoordinateLaw, ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
    ∀ d : ℕ, 1 ≤ d → ∀ f : BooleanFunction d, ∀ C : ℕ,
      isComplexity (r := r) Real.tanh f C →
    ∀ N : ℕ, C ≤ N → ∀ ε : ℝ, 0 < ε → ε < 1 →
    ∃ σ₀ : ℝ, 0 < σ₀ ∧
      ∀ σ : ℝ, 0 < σ → σ < σ₀ →
      ∀ D : InputLaw d, ∀ δ : ℝ, 0 < δ → δ < 1 →
      ∀ n : ℕ,
        (6 / ε) * (MainStatements.polynomialEnvelope A m d C 0 + Real.log (1 / δ)) ≤ (n : ℝ) →
        (∀ s : Fin n → Cube d,
          0 < posteriorDenominator Real.tanh (1 / 2) (smallPrior ν d N r σ) f s) ∧
        1 - δ ≤ sampleProbability D n (fun s =>
          posteriorRisk D f
              (networkPosterior Real.tanh (1 / 2) (smallPrior ν d N r σ) f s) ≤ ε / 3 ∧
          ConcreteModel.confidenceFailure D f
              (networkPosterior Real.tanh (1 / 2) (smallPrior ν d N r σ) f s) ≤ ε)

/-- Paper Theorem 2.2: every fixed exponent, including the mean-field endpoint,
and every width at least the bounded-weight tanh teacher complexity. -/
def FiniteScaleGeneralization : Prop :=
  ∀ r : ℕ, ∀ ν : CoordinateLaw, ∀ γ : ℝ, 1 ≤ γ →
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
    ∀ d : ℕ, 1 ≤ d → ∀ f : BooleanFunction d, ∀ C : ℕ,
      isComplexity (r := r) Real.tanh f C →
    ∀ N : ℕ, C ≤ N → ∀ D : InputLaw d,
    ∀ ε δ : ℝ, 0 < ε → ε < 1 → 0 < δ → δ < 1 →
    ∀ n : ℕ,
      (6 / ε) * (MainStatements.polynomialEnvelope A m d C (Real.log (1 / ε)) +
        Real.log (6 / (ε * δ))) ≤ (n : ℝ) →
      (∀ s : Fin n → Cube d,
        0 < posteriorDenominator Real.tanh (1 / 2) (powerPrior ν d N r γ) f s) ∧
      1 - δ ≤ sampleProbability D n (fun s =>
        posteriorRisk D f
            (networkPosterior Real.tanh (1 / 2) (powerPrior ν d N r γ) f s) ≤ ε / 3 ∧
        ConcreteModel.confidenceFailure D f
            (networkPosterior Real.tanh (1 / 2) (powerPrior ν d N r γ) f s) ≤ ε)

end NeuralGeneralization.BatchTwoNonGaussian
