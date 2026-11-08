import NeuralGeneralization.OnlineLowerModel

/-!
# Exact target propositions for the adversarial online lower bounds

These definitions separate theorem statements from their proofs. The ReLU
propositions are proved in `OnlineLowerReluMain` using the complete analytic
and finite-width construction. The tanh propositions remain formal targets,
not proved main theorems. No axiom supplies any of these propositions.

`PolynomialResourceFamily` keeps the resource exponents explicit and permits
a stronger construction to replace them without changing the model.  The
current ReLU paper uses `(dimensionPower, teacherPower) = (1,2)`. The
earlier tanh cycle construction used `(6,8)`; its strengthened path
construction uses `PolylogResourceFamily` with powers `(1,2,2)`. Each has
an exponential number of designated rounds in its family index.
-/

noncomputable section
open scoped Topology

namespace NeuralGeneralization.OnlineLower
open ConcreteModel

/-- A complete manuscript-level resource statement.  One target, one full
permutation, and one designated set are fixed before the quantification over
all sufficiently large learner widths and before the strong-prior limit.
The uniform integer constant controls both polynomial resources and the
actual bounded-fan-in circuit size. -/
def PolynomialResourceFamily (φ : ℝ → ℝ)
    (dimensionPower teacherPower : ℕ) : Prop :=
  ∃ K : ℕ, 0 < K ∧ ∃ c : ℝ, 0 < c ∧ ∃ k₀ : ℕ, 0 < k₀ ∧
    ∀ k : ℕ, k₀ ≤ k →
      ∃ d C : ℕ, ∃ f : BooleanFunction d,
      ∃ π : InputOrder d, ∃ J : Finset (Fin (Fintype.card (Cube d))),
        0 < d ∧ 1 ≤ C ∧
        k ^ dimensionPower ≤ K * d ∧ d ≤ K * k ^ dimensionPower ∧
        C ≤ K * k ^ teacherPower ∧
        BoundedTeacher φ f C ∧ HasCircuitAtMost f (K * d) ∧
        Real.exp (c * (k : ℝ)) ≤ (J.card : ℝ) ∧
        AllLargeWidthsFail φ f C π J

/-- The core width-complexity conclusion, including arbitrarily large
specified teacher widths and the actual posterior limit. -/
def WidthExponentLowerBound (φ : ℝ → ℝ) (α : ℝ) : Prop :=
  ∃ c : ℝ, 0 < c ∧ ∀ Cmin : ℕ,
    ∃ d C : ℕ, ∃ f : BooleanFunction d,
    ∃ π : InputOrder d, ∃ J : Finset (Fin (Fintype.card (Cube d))),
      0 < d ∧ Cmin ≤ C ∧ BoundedTeacher φ f C ∧
      Real.exp (c * (C : ℝ) ^ α) ≤ (J.card : ℝ) ∧
      AllLargeWidthsFail φ f C π J

/-- The same literal online conclusion with an explicitly specified growth
rate in the teacher width. This also expresses rates with logarithmic losses.
It is a target proposition, not an assumed analytic premise. -/
def WidthRateLowerBound (φ : ℝ → ℝ) (rate : ℕ → ℝ) : Prop :=
  ∃ c : ℝ, 0 < c ∧ ∀ Cmin : ℕ,
    ∃ d C : ℕ, ∃ f : BooleanFunction d,
    ∃ π : InputOrder d, ∃ J : Finset (Fin (Fintype.card (Cube d))),
      0 < d ∧ Cmin ≤ C ∧ BoundedTeacher φ f C ∧
      Real.exp (c * rate C) ≤ (J.card : ℝ) ∧
      AllLargeWidthsFail φ f C π J

/-- Resource statement allowing the logarithmic factors in improved cycle
constructions. `k₀ ≥ 2` makes the displayed logarithms positive. -/
def PolylogResourceFamily (φ : ℝ → ℝ)
    (dimensionPower teacherPower logPower : ℕ) : Prop :=
  ∃ K : ℕ, 0 < K ∧ ∃ c : ℝ, 0 < c ∧ ∃ k₀ : ℕ, 2 ≤ k₀ ∧
    ∀ k : ℕ, k₀ ≤ k →
      ∃ d C : ℕ, ∃ f : BooleanFunction d,
      ∃ π : InputOrder d, ∃ J : Finset (Fin (Fintype.card (Cube d))),
        0 < d ∧ 1 ≤ C ∧
        (k : ℝ) ^ dimensionPower * Real.log k ^ logPower ≤ (K : ℝ) * d ∧
        (d : ℝ) ≤ K * (k : ℝ) ^ dimensionPower * Real.log k ^ logPower ∧
        (C : ℝ) ≤ K * (k : ℝ) ^ teacherPower * Real.log k ^ logPower ∧
        BoundedTeacher φ f C ∧ HasCircuitAtMost f (K * d) ∧
        Real.exp (c * (k : ℝ)) ≤ (J.card : ℝ) ∧
        AllLargeWidthsFail φ f C π J

/-- Current ReLU main theorem, with all resource and posterior conventions.
This declaration records its target proposition; it is not a proof. -/
def ReLUSquareRootStatement : Prop :=
  PolynomialResourceFamily (fun x : ℝ => max 0 x) 1 2

/-- Earlier ordinary-tanh cycle theorem target, indexed by cycle blocks.
Its `d = Θ(k^6)`, `C = O(k^8)`, and `exp(Ω(k))` resources give the
eighth-root width exponent.  This declaration is not a proof. -/
def TanhEighthRootStatement : Prop :=
  PolynomialResourceFamily Real.tanh 6 8

/-- Improved logarithmic-rail tanh resource target, indexed by cycle blocks:
`d = Θ(k^4 log² k)`, `C = O(k^6 log² k)`, `exp(Ω(k))` designated rounds.
This is a separate unproved target; it does not overwrite the earlier one. -/
def TanhLogarithmicRailStatement : Prop :=
  PolylogResourceFamily Real.tanh 4 6 2

/-- The corresponding width-rate target, using `log(C+2)` to make the rate
defined harmlessly also at small natural widths. -/
def TanhSixthRootLogLossStatement : Prop :=
  WidthRateLowerBound Real.tanh
    (fun C => (C : ℝ) ^ (1 / 6 : ℝ) / Real.log (C + 2 : ℝ) ^ (1 / 3 : ℝ))

/-- Improved path-ordering target: `d = Θ(k log² k)`,
`C = O(k² log² k)`, and `exp(Ω(k))` designated rounds. As above,
this definition records the theorem to prove and supplies no proof. -/
def TanhPathLogarithmicRailStatement : Prop :=
  PolylogResourceFamily Real.tanh 1 2 2

/-- The path-ordering width-rate target, up to one logarithmic loss. -/
def TanhSquareRootLogLossStatement : Prop :=
  WidthRateLowerBound Real.tanh
    (fun C => (C : ℝ) ^ (1 / 2 : ℝ) / Real.log (C + 2 : ℝ))

end NeuralGeneralization.OnlineLower
