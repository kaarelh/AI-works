import NeuralGeneralization.RobustCircuit
import NeuralGeneralization.RobustLearningReduction

/-!
# Exact target statement for polynomial-depth robust Bayesian learning

This file defines the proposition to be proved. Its existence is not a proof.
The coefficient and exponent are outside every architecture, circuit, and
robustness parameter. One measurable sample event works for all eligible widths
and all positive scales satisfying `N * σ² ≤ 1`.

The actual Gaussian entry variances are `N*σ²/d`, `σ²`, and `σ²/N`.
Thus `σ²=N^(-γ)` is covered simultaneously for every `γ≥1`.
Only the robustness support event is imposed before training; no global clean
output margin is needed. Training uses signed output `>1/2`; test loss uses
signed output `≤1/4`. The comparator is a concrete layered Boolean circuit,
including its constant wire, and is not an arbitrary analog neural circuit.
-/

noncomputable section
open MeasureTheory ProbabilityTheory

namespace NeuralGeneralization.RobustMainStatements
open ConcreteModel RobustPosterior RobustConfidence

def depthPolynomialEnvelope (A : ℝ) (m d C r : ℕ) (c ε δ : ℝ) : ℝ :=
  A * (2 + (d : ℝ) + (C : ℝ) + (r : ℝ) + c + c⁻¹ + ε⁻¹ +
    Real.log (1 / δ)) ^ m

/-- Exact uniform-depth claim: no compression, prior-mass, transport,
generalization, or circuit-realizability premise replaces its proof. -/
def RobustPolynomialDepthGeneralization : Prop :=
  ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
    ∀ d C r : ℕ, 0 < d →
    ∀ B : LayeredBooleanCircuit d C r,
    ∀ c ε δ : ℝ, 0 < c → 0 < ε → ε < 1 → 0 < δ → δ < 1 →
    ∀ D : Measure (Cube d), IsProbabilityMeasure D →
    ∀ n : ℕ, depthPolynomialEnvelope A m d C r c ε δ ≤ (n : ℝ) →
    ∃ E : Set (Fin n → Cube d), MeasurableSet E ∧
      1 - δ ≤ (CompressionSampling.iidSamples D n).real E ∧
      ∀ sample ∈ E, ∀ N : ℕ, C ≤ N →
      ∀ σ : ℝ, 0 < σ → (N : ℝ) * σ ^ 2 ≤ 1 →
        0 < (smallPrior d N r σ).real
          (robustPosteriorEvent Real.tanh c B.computes sample) ∧
        gibbsMarginRisk D
          (robustPosterior (N := N) (r := r) Real.tanh c σ B.computes sample)
          (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1 / 4)
          ≤ ε / 3 ∧
        D.real {x | correctConfidence
          (robustPosterior (N := N) (r := r) Real.tanh c σ B.computes sample)
          (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1 / 4) x
          ≤ (2 / 3 : ℝ)} ≤ ε

end NeuralGeneralization.RobustMainStatements
