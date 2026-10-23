import NeuralGeneralization.BatchTwoContinuousModel
import NeuralGeneralization.IIDLaw

/-!
# Exact proof targets for continuous-domain regression

These are propositions, not axioms or proved learning theorems. The parameter
measure is the actual independent coordinate prior. The posterior only sees
the training constraints, and the risk is computed under the full posterior.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators

namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel

def admissibleDomain {d : ℕ} (X : Set (RealInput d)) : Prop :=
  X.Nonempty ∧ IsCompact X ∧ ∀ x ∈ X, ∑ i, x i ^ 2 ≤ 1

def inverseGap (ρ τ : ℝ) : ℝ := 1 / min 1 (τ - ρ)
def logInverseTolerance (ρ : ℝ) : ℝ := Real.log (1 / min 1 ρ)

def regressionEnvelope (A : ℝ) (m d C : ℕ) (B u v t : ℝ) : ℝ :=
  A * (1 + (d : ℝ) + (C : ℝ) + B + u + v + t) ^ m

/-- Continuous-domain paper, strong-prior regression theorem. A specified
bounded teacher suffices; no minimum-complexity or margin premise is added.
The variance threshold is chosen before the input law, sample size and delta. -/
def StrongPriorRegression : Prop :=
  ∀ r : ℕ, ∀ ν : BatchTwoNonGaussian.CoordinateLaw,
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
    ∀ d C : ℕ, 1 ≤ d → 1 ≤ C → ∀ B : ℝ, 1 ≤ B →
    ∀ teacher : Weights d C r, boundedWeights B teacher →
    ∀ X : Set (RealInput d), admissibleDomain X →
    ∀ N : ℕ, C ≤ N → ∀ ρ τ ε : ℝ, 0 < ρ → ρ < τ → 0 < ε → ε < 1 →
    ∃ σ₀ : ℝ, 0 < σ₀ ∧ ∀ σ : ℝ, 0 < σ → σ < σ₀ →
    ∀ D : Measure (RealInput d), IsProbabilityMeasure D → D Xᶜ = 0 →
    ∀ δ : ℝ, 0 < δ → δ < 1 → ∀ n : ℕ,
      (6 / ε) * (regressionEnvelope A m d C B (inverseGap ρ τ) 0 0 +
        Real.log (1 / δ)) ≤ (n : ℝ) →
      1 - δ ≤ (CompressionSampling.iidSamples D n).real {s |
        let Q := posterior Real.tanh (BatchTwoNonGaussian.smallPrior ν d N r σ)
          (output Real.tanh teacher) ρ s
        risk Real.tanh D Q (output Real.tanh teacher) τ ≤ ε / 3 ∧
        confidenceFailure Real.tanh D Q (output Real.tanh teacher) τ ≤ ε}

/-- Continuous-domain paper, finite-scale regression theorem including gamma=1.
The polynomial may depend on gamma, depth and the fixed scalar coordinate law;
it cannot depend on learner width or the target teacher. -/
def FiniteScaleRegression : Prop :=
  ∀ r : ℕ, ∀ ν : BatchTwoNonGaussian.CoordinateLaw, ∀ γ : ℝ, 1 ≤ γ →
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
    ∀ d C : ℕ, 1 ≤ d → 1 ≤ C → ∀ B : ℝ, 1 ≤ B →
    ∀ teacher : Weights d C r, boundedWeights B teacher →
    ∀ X : Set (RealInput d), admissibleDomain X →
    ∀ N : ℕ, C ≤ N →
    ∀ D : Measure (RealInput d), IsProbabilityMeasure D → D Xᶜ = 0 →
    ∀ ρ τ ε δ : ℝ, 0 < ρ → ρ < τ → 0 < ε → ε < 1 → 0 < δ → δ < 1 →
    ∀ n : ℕ,
      (6 / ε) * (regressionEnvelope A m d C B (inverseGap ρ τ)
        (logInverseTolerance ρ) (Real.log (1 / ε)) + Real.log (6 / (ε * δ))) ≤ (n : ℝ) →
      1 - δ ≤ (CompressionSampling.iidSamples D n).real {s |
        let Q := posterior Real.tanh (BatchTwoNonGaussian.powerPrior ν d N r γ)
          (output Real.tanh teacher) ρ s
        risk Real.tanh D Q (output Real.tanh teacher) τ ≤ ε / 3 ∧
        confidenceFailure Real.tanh D Q (output Real.tanh teacher) τ ≤ ε}

end NeuralGeneralization.BatchTwoContinuous
