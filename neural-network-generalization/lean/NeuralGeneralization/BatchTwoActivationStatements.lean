import NeuralGeneralization.Statements
import Mathlib.Topology.MetricSpace.Lipschitz

/-!
# Exact target statement for the unified activation manuscript

`UniformUnboundedActivationLearning` records the paper's simultaneous
all-width, all-scale existential-polynomial guarantee in the concrete
Gaussian model. It is proved by `uniform_unbounded_activation_learning` in
`BatchTwoActivationUniformMain`. The proof gives a looser polynomial than
the manuscript's displayed optimized capacity formula; see the theorem map.
No mean-field compression conclusion is inserted as a hypothesis.

Depth is `r+2`. The actual learner always has the one fixed activation `φ`.
The simultaneous sample event quantifies over every eligible width and every
scale in `(0,1]`, exactly as in Theorem `uniform-all-scales` of the manuscript.
-/

noncomputable section
open MeasureTheory

namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

/-- The unbounded manuscript's activation assumption. Unlike the older
`admissibleActivation`, it imposes no global bound on activation values. -/
def zeroLipschitzActivation (ℓ : ℝ) (φ : ℝ → ℝ) : Prop :=
  φ 0 = 0 ∧ ∀ x y, |φ x - φ y| ≤ ℓ * |x-y|

theorem activation_abs_le {ℓ : ℝ} {φ : ℝ → ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (x : ℝ) : |φ x| ≤ ℓ * |x| := by
  simpa only [hφ.1, sub_zero] using hφ.2 x 0

def relu (x : ℝ) : ℝ := max 0 x

theorem relu_zeroLipschitz : zeroLipschitzActivation 1 relu := by
  refine ⟨by simp [relu], ?_⟩
  intro x y
  have h := abs_max_sub_max_le_max (0 : ℝ) x 0 y
  simpa only [relu, sub_self, abs_zero, max_eq_right (abs_nonneg (x-y)), one_mul] using h

/-- The paper's `ν_(N,t)`: first-layer variance `t²/d`, internal variance
`t²/N`, and readout variance `t²/N²` when `N>0`. -/
def activationBandPrior (d N r : ℕ) (t : ℝ) : Measure (Weights d N r) :=
  smallPrior d N r (t / Real.sqrt N)

/-- Unified unbounded-activation paper, Theorem `uniform-all-scales`.
The polynomial envelope depends only on depth and the Lipschitz bound.
The teacher need not be minimum complexity: a specified bounded teacher is
enough. Posterior positivity is stated separately for every sample.

The existence and simultaneous quantifiers are proved in
`BatchTwoActivationUniformMain`; this proposition does not specify the
manuscript's sharper explicit polynomial coefficients. -/
def UniformUnboundedActivationLearning : Prop :=
  ∀ r : ℕ, ∀ ℓ : ℝ, 1 ≤ ℓ →
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
    ∀ φ : ℝ → ℝ, zeroLipschitzActivation ℓ φ →
    ∀ d : ℕ, 1 ≤ d → ∀ f : BooleanFunction d, ∀ C : ℕ,
      realizesAtComplexity (r := r) φ f C →
    ∀ D : InputLaw d, ∀ ε δ : ℝ,
      0 < ε → ε < 1 → 0 < δ → δ < 1 →
    ∀ n : ℕ,
      (2 / ε) * (MainStatements.polynomialEnvelope A m d C (Real.log (1/ε)) +
        Real.log (1/δ)) ≤ (n : ℝ) →
      (∀ N : ℕ, C ≤ N → ∀ t : ℝ, 0 < t → t ≤ 1 →
        ∀ s : Fin n → Cube d,
          0 < posteriorDenominator φ (1/2) (activationBandPrior d N r t) f s) ∧
      1 - δ ≤ sampleProbability D n (fun s =>
        ∀ N : ℕ, C ≤ N → ∀ t : ℝ, 0 < t → t ≤ 1 →
          posteriorRisk D f
            (networkPosterior φ (1/2) (activationBandPrior d N r t) f s) ≤ ε)

end NeuralGeneralization.BatchTwoActivation
