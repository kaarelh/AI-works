import NeuralGeneralization.Model
import Mathlib.Order.LiminfLimsup

/-!
# Formal statements of the four main research claims

**These declarations are propositions, not proved theorems.** No axiom, `sorry`,
or proof assumption asserts any of them. Their purpose is to record the exact
proof targets in the actual finite Gaussian neural-network model. All four
have closed proofs in the corresponding `*Main.lean` modules. The separate
`CheckMain.lean` gate verifies their exact types and axiom dependencies.

An existential polynomial is represented by a positive multiple of
`(1 + d + C + t)^m`. On nonnegative arguments this is equivalent to the
existence of an arbitrary polynomial upper bound, after increasing its
coefficient and degree. The exponent and coefficient are independent of width.

Depth is `r + 2` throughout. All labels are Boolean encodings of `{-1,+1}`.
-/

noncomputable section

open Filter
open NeuralGeneralization.ConcreteModel

namespace NeuralGeneralization.MainStatements

/-- A concrete polynomial envelope, with a natural degree. -/
def polynomialEnvelope (A : ℝ) (m d C : ℕ) (t : ℝ) : ℝ :=
  A * (1 + (d : ℝ) + (C : ℝ) + t) ^ m

/-- Strong-prior paper, Theorem 2.2: first fix width, then take variance small.
The threshold `σ₀` is independent of the input law, sample size, and `δ`.
Proved by `MainProofs.strongPrior` in `StrongPriorMain.lean`. -/
def StrongPriorGeneralization : Prop :=
  ∀ r : ℕ, ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
    ∀ φ : ℝ → ℝ, admissibleActivation φ →
    ∀ d : ℕ, 1 ≤ d → ∀ f : BooleanFunction d, ∀ C : ℕ,
      isComplexity (r := r) φ f C →
    ∀ N : ℕ, C ≤ N → ∀ ε : ℝ, 0 < ε → ε < 1 →
    ∃ σ₀ : ℝ, 0 < σ₀ ∧
      ∀ σ : ℝ, 0 < σ → σ < σ₀ →
      ∀ D : InputLaw d, ∀ δ : ℝ, 0 < δ → δ < 1 →
      ∀ n : ℕ,
        (2 / ε) * (polynomialEnvelope A m d C 0 + Real.log (1 / δ)) ≤ (n : ℝ) →
        (∀ s : Fin n → Cube d,
          0 < posteriorDenominator φ (1 / 2) (smallPrior d N r σ) f s) ∧
        1 - δ ≤ sampleProbability D n (fun s =>
          posteriorRisk D f
            (networkPosterior φ (1 / 2) (smallPrior d N r σ) f s) ≤ ε)

/-- Above-mean-field paper, Theorem 4.3: fixed `γ > 1`, every `N ≥ C_L(f)`.
The polynomial is permitted to depend on `γ`; its degree is not uniform as
`γ` decreases to one. Proved by `MainProofs.aboveMeanField` in `AboveMeanFieldMain.lean`. -/
def AboveMeanFieldGeneralization : Prop :=
  ∀ r : ℕ, ∀ γ : ℝ, 1 < γ →
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
    ∀ φ : ℝ → ℝ, admissibleActivation φ →
    ∀ d : ℕ, 1 ≤ d → ∀ f : BooleanFunction d, ∀ C : ℕ,
      isComplexity (r := r) φ f C →
    ∀ N : ℕ, C ≤ N → ∀ D : InputLaw d,
    ∀ ε δ : ℝ, 0 < ε → ε < 1 → 0 < δ → δ < 1 →
    ∀ n : ℕ,
      (2 / ε) * (polynomialEnvelope A m d C (Real.log (1 / ε)) +
        Real.log (2 / (ε * δ))) ≤ (n : ℝ) →
      (∀ s : Fin n → Cube d,
        0 < posteriorDenominator φ (1 / 2) (powerPrior d N r γ) f s) ∧
      1 - δ ≤ sampleProbability D n (fun s =>
        posteriorRisk D f
          (networkPosterior φ (1 / 2) (powerPrior d N r γ) f s) ≤ ε)

/-- Mean-field paper, Theorem 1.1, including the strict `>2/3` prediction rule.
The activation is specifically `tanh`. Proved by `MainProofs.meanField`
in `MeanFieldMain.lean`. -/
def MeanFieldGeneralization : Prop :=
  ∀ r : ℕ, ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
    ∀ d : ℕ, 1 ≤ d → ∀ f : BooleanFunction d, ∀ C : ℕ,
      isComplexity (r := r) Real.tanh f C →
    ∀ N : ℕ, C ≤ N → ∀ D : InputLaw d,
    ∀ ε δ : ℝ, 0 < ε → ε < 1 → 0 < δ → δ < 1 →
    ∀ n : ℕ,
      (6 / ε) * (polynomialEnvelope A m d C (Real.log (1 / ε)) +
        Real.log (6 / (ε * δ))) ≤ (n : ℝ) →
      (∀ s : Fin n → Cube d,
        0 < posteriorDenominator Real.tanh (1 / 2) (powerPrior d N r 1) f s) ∧
      1 - δ ≤ sampleProbability D n (fun s =>
        posteriorRisk D f
            (networkPosterior Real.tanh (1 / 2) (powerPrior d N r 1) f s) ≤ ε / 3 ∧
        ConcreteModel.confidenceFailure D f
            (networkPosterior Real.tanh (1 / 2) (powerPrior d N r 1) f s) ≤ ε)

/-- The actual finite-width confidence-failure fraction for full parity. -/
def parityFailure (d r n : ℕ) (a γ : ℝ)
    (s : Fin n → Cube d) (N : ℕ) : ℝ :=
  ConcreteModel.confidenceFailure (uniformLaw d) (parity d)
    (networkPosterior Real.tanh a (powerPrior d N r γ) (parity d) s)

/-- Unified exponential paper, Theorem 1.1: every fixed `γ<1`, including
`γ=0` and `γ<0`; width tends to infinity before dimension. The event is for
each specified sample size, not simultaneously for all sample prefixes.
Proved by `MainProofs.subcriticalExponential` in `SubcriticalMain.lean`. -/
def SubcriticalExponentialLowerBound : Prop :=
  ∀ r : ℕ, ∀ a : ℝ, 0 < a →
    ∃ c : ℝ, 0 < c ∧ ∃ d₀ : ℕ,
    ∀ d : ℕ, d₀ ≤ d → 1 ≤ d →
    ∀ n : ℕ, (n : ℝ) ≤ Real.exp (c * (d : ℝ)) →
    ∀ γ : ℝ, γ < 1 →
      (∀ᶠ N : ℕ in atTop, ∀ s : Fin n → Cube d,
        0 < posteriorDenominator Real.tanh a (powerPrior d N r γ) (parity d) s) ∧
      (3 : ℝ) / 4 ≤ sampleProbability (uniformLaw d) n (fun s =>
        (1 : ℝ) / 16 ≤ Filter.liminf (parityFailure d r n a γ s) atTop)

end NeuralGeneralization.MainStatements
