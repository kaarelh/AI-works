import NNBayesStatement
import PosteriorBridge
import FiniteReductionCircuits

/-!
# The actual posterior-circuit ceiling

`AnalyticPosteriorCeiling` defines the concrete integer-budget version of the
uniform actual-posterior ceiling, at beta=1/6. Its closed proof is
`analyticPosteriorCeiling` in `ClosedConditionalImpossibility.lean`.
It concerns the original Gaussian posterior and a threshold-circuit class
independent of sample, scale and width. No ceiling is declared as an axiom.

Natural logarithms can be changed to `Nat.log2` by changing universal constants.
At beta=1/6 the width summand `2*W*H` dominates `W*H*log 6`.
The final theorem here is the reusable finite consequence of the ceiling;
the actual analytic proof is supplied by the modules under `analytic/`.
-/

noncomputable section
attribute [local instance] Classical.propDecidable
open scoped BigOperators
namespace ConditionalNonpolynomial
open NeuralGeneralization.ConcreteModel

/-- The common resource parameter: input dimension, samples, and learner depth. -/
def ceilingResource (d n r : ℕ) : ℕ := d + n + (r+2) + 2

/-- Bounds are uniform constants, not functions of dimension or depth. -/
structure CeilingConstants where
  padding : ℕ
  width : ℕ
  circuit : ℕ
  padding_pos : 0 < padding
  width_pos : 0 < width
  circuit_pos : 0 < circuit

/-- A concrete class of actual threshold circuits with common resource bounds. -/
def ceilingClass (b : CeilingConstants) (d n r : ℕ) : Set (BooleanFunction d) :=
  {g | ∃ c : ThresholdCircuit d,
    c.size ≤ (ceilingResource d n r)^b.circuit ∧
    c.depth ≤ b.circuit * Nat.log2 (ceilingResource d n r) ∧ c.eval = g}

/-- A natural-number bound sufficient for beta=1/6. Its size may be exponential
in input dimension; the learning statement nevertheless must cover this width. -/
def ceilingWidth (b : CeilingConstants) (d n r : ℕ) : ℕ :=
  2^(b.width*d) * (ceilingResource d n r)^b.width + 2*b.width*(r+1)

/-- The actual analytic ceiling at the given uniform constants. This is not
replaced by an abstract concentration oracle in the main theorem statement. -/
def CeilingAt (b : CeilingConstants) : Prop :=
  ∀ T : CanonicalSchedule, ∀ d n r C N : ℕ,
    1 ≤ d → 1 ≤ n → 1 ≤ r →
    b.padding * Nat.log2 (ceilingResource d n r) ≤ r+2 →
    ceilingWidth b d n r ≤ N → C ≤ N →
    ∀ f : BooleanFunction d,
      realizesAtComplexity (r := r) Real.tanh f C →
    ∀ s : Fin n → Cube d,
      (5/6:ℝ) ≤ ∑ g, if g ∈ ceilingClass b d n r then
        networkPosterior Real.tanh (1/2) (canonicalPrior T d N r) f s g else 0

/-- The concrete analytic proposition proved by `analyticPosteriorCeiling`
in `ClosedConditionalImpossibility.lean`. -/
def AnalyticPosteriorCeiling : Prop := ∃ b : CeilingConstants, CeilingAt b

/-- Pointwise learning-to-majority reduction under the separately stated
analytic ceiling. All Gaussian and statistical definitions are concrete. -/
theorem exact_majority_of_ceiling (b : CeilingConstants) (hceil : CeilingAt b)
    (T : CanonicalSchedule) {d n r C N : ℕ} (hd : 1 ≤ d) (hn : 1 ≤ n) (hr : 1 ≤ r)
    (hpad : b.padding * Nat.log2 (ceilingResource d n r) ≤ r+2)
    (hwidth : ceilingWidth b d n r ≤ N) (hCN : C ≤ N)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r := r) Real.tanh f C)
    (hsuccess : ∀ D : InputLaw d,
      0 < successProbability (r := r) (N := N) (n := n) T f D) :
    ∃ gs : Fin (400*(d+1)) → BooleanFunction d,
      (∀ i, gs i ∈ ceilingClass b d n r) ∧
      ∀ x, 0 < ∑ i, signedVote f (gs i) x := by
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have ht := T.positive d (r+2) N (by omega) (by omega) hN
  have hσ : 0 < T.scale d (r+2) N / Real.sqrt N :=
    div_pos ht (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hN))
  exact gaussian_learning_implies_exact_majority (by omega) hσ f hf hCN
    (ceilingClass b d n r) (hceil T d n r C N hd hn hr hpad hwidth hCN f hf) hsuccess

/-- Concrete circuit output of the actual learning-to-circuit reduction,
conditional only on the explicitly named analytical ceiling. -/
theorem circuit_of_ceiling (b : CeilingConstants) (hceil : CeilingAt b)
    (T : CanonicalSchedule) {d n r C N : ℕ} (hd : 1 ≤ d) (hn : 1 ≤ n) (hr : 1 ≤ r)
    (hpad : b.padding * Nat.log2 (ceilingResource d n r) ≤ r+2)
    (hwidth : ceilingWidth b d n r ≤ N) (hCN : C ≤ N)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r := r) Real.tanh f C)
    (hsuccess : ∀ D : InputLaw d,
      0 < successProbability (r := r) (N := N) (n := n) T f D) :
    ∃ c : ThresholdCircuit d,
      c.size ≤ (400*(d+1))*((ceilingResource d n r)^b.circuit+1)+1 ∧
      c.depth ≤ b.circuit*Nat.log2 (ceilingResource d n r)+1 ∧ c.eval = f := by
  obtain ⟨gs,hgs,hvote⟩ := exact_majority_of_ceiling b hceil T hd hn hr
    hpad hwidth hCN f hf hsuccess
  exact compile_exact_majority f gs hvote ((ceilingResource d n r)^b.circuit)
    (b.circuit*Nat.log2 (ceilingResource d n r)) (fun i => hgs i)

#print axioms circuit_of_ceiling
#print axioms exact_majority_of_ceiling
end ConditionalNonpolynomial
