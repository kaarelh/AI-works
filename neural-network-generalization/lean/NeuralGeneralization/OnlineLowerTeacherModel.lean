import NeuralGeneralization.Network
import NeuralGeneralization.BatchTwoCircuitConverseCircuits

/-!
# Concrete teacher and deterministic online-order conventions

These deterministic definitions use the literal network architecture and
actual bounded-fan-in NAND circuits. The Gaussian posterior and width/scale
quantifiers are introduced in `OnlineLowerModel`.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower
open ConcreteModel

/-- One hidden layer and a linear readout. -/
abbrev ShallowWeights (d N : ℕ) := Weights d N 0

/-- A complete nonrepeating input order, independent of width and scale. -/
abbrev InputOrder (d : ℕ) := Fin (Fintype.card (Cube d)) ≃ Cube d

/-- The exact observations available before predicting at position `j`. -/
def observedPrefix {d : ℕ} (π : InputOrder d)
    (j : Fin (Fintype.card (Cube d))) : Fin j.val → Cube d :=
  fun i => π ⟨i.val, lt_trans i.isLt j.isLt⟩

theorem observedPrefix_injective {d : ℕ} (π : InputOrder d)
    (j : Fin (Fintype.card (Cube d))) : Function.Injective (observedPrefix π j) := by
  intro a b hab
  apply Fin.ext
  exact congrArg (fun k : Fin (Fintype.card (Cube d)) => k.val) (π.injective hab)

theorem current_not_in_observedPrefix {d : ℕ} (π : InputOrder d)
    (j : Fin (Fintype.card (Cube d))) (i : Fin j.val) :
    observedPrefix π j i ≠ π j := by
  intro h
  have hv := congrArg (fun k : Fin (Fintype.card (Cube d)) => k.val) (π.injective h)
  exact (Nat.ne_of_lt i.isLt) hv

/-- A specified same-depth teacher, with margin at least one and coefficients
bounded by its hidden width.  The width need not be the minimum possible. -/
def BoundedTeacher {d : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d)
    (C : ℕ) : Prop :=
  1 ≤ C ∧ ∃ w : ShallowWeights d C,
    (∀ x, 1 ≤ labelReal (f x) * networkOutput φ w x) ∧ boundedWeights C w

theorem BoundedTeacher.realizesAtComplexity {d C : ℕ} {φ : ℝ → ℝ}
    {f : BooleanFunction d} (h : BoundedTeacher φ f C) :
    realizesAtComplexity (r := 0) φ f C := by
  obtain ⟨hC, w, hw, hb⟩ := h
  refine ⟨hC, w, ?_, hb⟩
  intro x
  exact lt_of_lt_of_le (by norm_num : (1 / 2 : ℝ) < 1) (hw x)

/-- The additional small Boolean-circuit claim uses actual fan-in-two NAND
circuits, with their usual gate count; it is not a cardinality surrogate. -/
def HasCircuitAtMost {d : ℕ} (f : BooleanFunction d) (B : ℕ) : Prop :=
  ∃ c : BatchTwoCircuitConverse.Circuit d, c.size ≤ B ∧ c.eval = f

end NeuralGeneralization.OnlineLower
