import Mathlib.Data.Fintype.Pi
import Mathlib.Data.Finset.Basic
import Mathlib.Tactic.NormNum

/-!
# Explicit topologically ordered NAND circuits for online mistake converses

The initial wires are the `d` input bits followed by constants false and true.
Each new gate is a NAND of two earlier wires; the last gate is the output,
and the empty circuit outputs false. Dead gates and repeated inputs are allowed.
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse

abbrev Input (d : ℕ) := Fin d → Bool

def Gates (d : ℕ) : ℕ → Type
  | 0 => Unit
  | n + 1 => Gates d n × Fin (d + 2 + n) × Fin (d + 2 + n)

def initialWire {d : ℕ} (x : Input d) (i : ℕ) : Bool :=
  if h : i < d then x ⟨i, h⟩ else decide (i = d + 1)

def Gates.eval {d : ℕ} : {n : ℕ} → Gates d n → Input d → ℕ → Bool
  | 0, _, x => initialWire x
  | n + 1, (g, i, j), x =>
      Function.update (Gates.eval g x) (d + 2 + n)
        (!(Gates.eval g x i && Gates.eval g x j))

structure Circuit (d : ℕ) where
  size : ℕ
  gates : Gates d size

def Circuit.empty (d : ℕ) : Circuit d := ⟨0, ()⟩

def Circuit.wires {d : ℕ} (c : Circuit d) : ℕ := d + 2 + c.size

def Circuit.evalWire {d : ℕ} (c : Circuit d) (x : Input d) (i : ℕ) : Bool :=
  c.gates.eval x i

def Circuit.outputWire {d : ℕ} (c : Circuit d) : ℕ :=
  if c.size = 0 then d else d + 1 + c.size

def Circuit.eval {d : ℕ} (c : Circuit d) (x : Input d) : Bool :=
  c.evalWire x c.outputWire

def Circuit.add {d : ℕ} (c : Circuit d) (i j : Fin c.wires) : Circuit d :=
  ⟨c.size + 1, (c.gates, i, j)⟩

@[simp] theorem Circuit.size_empty (d : ℕ) : (Circuit.empty d).size = 0 := rfl

@[simp] theorem Circuit.size_add {d : ℕ} (c : Circuit d) (i j : Fin c.wires) :
    (c.add i j).size = c.size + 1 := rfl

theorem Circuit.outputWire_lt {d : ℕ} (c : Circuit d) :
    c.outputWire < c.wires := by
  simp only [Circuit.outputWire, Circuit.wires]
  split <;> omega

@[simp] theorem Circuit.evalWire_add_old {d : ℕ} (c : Circuit d)
    (i j : Fin c.wires) (x : Input d) (k : ℕ) (hk : k < c.wires) :
    (c.add i j).evalWire x k = c.evalWire x k := by
  simp only [Circuit.add, Circuit.evalWire, Gates.eval]
  apply Function.update_of_ne
  exact Nat.ne_of_lt hk

@[simp] theorem Circuit.evalWire_add_new {d : ℕ} (c : Circuit d)
    (i j : Fin c.wires) (x : Input d) :
    (c.add i j).evalWire x c.wires = !(c.evalWire x i && c.evalWire x j) := by
  simp [Circuit.add, Circuit.evalWire, Circuit.wires, Gates.eval]

@[simp] theorem Circuit.eval_add {d : ℕ} (c : Circuit d)
    (i j : Fin c.wires) (x : Input d) :
    (c.add i j).eval x = !(c.evalWire x i && c.evalWire x j) := by
  have h : (c.add i j).outputWire = c.wires := by
    simp [Circuit.outputWire, Circuit.wires, Circuit.add]
    omega
  rw [Circuit.eval, h, Circuit.evalWire_add_new]

@[simp] theorem Circuit.eval_empty {d : ℕ} (x : Input d) :
    (Circuit.empty d).eval x = false := by
  simp [Circuit.eval, Circuit.evalWire, Circuit.outputWire, Circuit.empty,
    Gates.eval, initialWire]

theorem Gates.eval_input {d n : ℕ} (g : Gates d n) (x : Input d) (i : Fin d) :
    g.eval x i = x i := by
  induction n with
  | zero => simp [Gates.eval, initialWire, i.isLt]
  | succ n ih =>
    rcases g with ⟨g, a, b⟩
    simp only [Gates.eval]
    rw [Function.update_of_ne (by omega : (i : ℕ) ≠ d + 2 + n)]
    exact ih g

theorem Gates.eval_false {d n : ℕ} (g : Gates d n) (x : Input d) :
    g.eval x d = false := by
  induction n with
  | zero => simp [Gates.eval, initialWire]
  | succ n ih =>
    rcases g with ⟨g, a, b⟩
    simp only [Gates.eval]
    rw [Function.update_of_ne (by omega : d ≠ d + 2 + n)]
    exact ih g

theorem Gates.eval_true {d n : ℕ} (g : Gates d n) (x : Input d) :
    g.eval x (d + 1) = true := by
  induction n with
  | zero => simp [Gates.eval, initialWire]
  | succ n ih =>
    rcases g with ⟨g, a, b⟩
    simp only [Gates.eval]
    rw [Function.update_of_ne (by omega : d + 1 ≠ d + 2 + n)]
    exact ih g

@[simp] theorem Circuit.evalWire_input {d : ℕ} (c : Circuit d)
    (x : Input d) (i : Fin d) : c.evalWire x i = x i := Gates.eval_input _ _ _

@[simp] theorem Circuit.evalWire_false {d : ℕ} (c : Circuit d)
    (x : Input d) : c.evalWire x d = false := Gates.eval_false _ _

@[simp] theorem Circuit.evalWire_true {d : ℕ} (c : Circuit d)
    (x : Input d) : c.evalWire x (d + 1) = true := Gates.eval_true _ _


/-- An extension keeps every earlier wire, including any previously selected output. -/
def Circuit.Extends {d : ℕ} (c c' : Circuit d) : Prop :=
  c.size ≤ c'.size ∧ ∀ (x : Input d) (i : ℕ), i < c.wires →
    c'.evalWire x i = c.evalWire x i

theorem Circuit.Extends.refl {d : ℕ} (c : Circuit d) : c.Extends c :=
  ⟨le_rfl, fun _ _ _ => rfl⟩

theorem Circuit.Extends.trans {d : ℕ} {a b c : Circuit d}
    (hab : a.Extends b) (hbc : b.Extends c) : a.Extends c := by
  refine ⟨le_trans hab.1 hbc.1, ?_⟩
  intro x i hi
  have hs := hab.1
  rw [hbc.2 x i (by unfold Circuit.wires at *; omega), hab.2 x i hi]

theorem Circuit.extends_add {d : ℕ} (c : Circuit d) (i j : Fin c.wires) :
    c.Extends (c.add i j) :=
  ⟨by simp, fun x k hk => c.evalWire_add_old i j x k hk⟩

/-- Append three gates computing the conjunction of a selected wire and one input
literal. The first gate is kept even for a positive literal, as dead gates are allowed. -/
def Circuit.andLiteral {d : ℕ} (c : Circuit d) (a : Fin c.wires)
    (j : Fin d) (b : Bool) : Circuit d :=
  let ji : Fin c.wires := ⟨j, by unfold Circuit.wires; omega⟩
  let c₁ := c.add ji ji
  let ai : Fin c₁.wires := ⟨a, by simp [c₁, Circuit.wires]; omega⟩
  let li : Fin c₁.wires := ⟨if b then j else c.wires, by
    split <;> simp [c₁, Circuit.wires] <;> omega⟩
  let c₂ := c₁.add ai li
  let ni : Fin c₂.wires := ⟨c₁.wires, by simp [c₂, Circuit.wires]⟩
  c₂.add ni ni

@[simp] theorem Circuit.size_andLiteral {d : ℕ} (c : Circuit d)
    (a : Fin c.wires) (j : Fin d) (b : Bool) :
    (c.andLiteral a j b).size = c.size + 3 := by
  simp [Circuit.andLiteral]

theorem Circuit.extends_andLiteral {d : ℕ} (c : Circuit d)
    (a : Fin c.wires) (j : Fin d) (b : Bool) :
    c.Extends (c.andLiteral a j b) := by
  unfold Circuit.andLiteral
  exact (c.extends_add _ _).trans ((Circuit.extends_add _ _ _).trans
    (Circuit.extends_add _ _ _))

@[simp] theorem Circuit.eval_andLiteral {d : ℕ} (c : Circuit d)
    (a : Fin c.wires) (j : Fin d) (b : Bool) (x : Input d) :
    (c.andLiteral a j b).eval x = (c.evalWire x a && decide (x j = b)) := by
  have ha : (a : ℕ) < c.wires := a.isLt
  have hj : (j : ℕ) < c.wires := by unfold Circuit.wires; omega
  cases b <;>
    simp only [Circuit.andLiteral, Bool.false_eq_true, ↓reduceIte,
      Circuit.eval_add, Circuit.evalWire_add_new, Bool.and_self, Bool.not_not,
      Circuit.evalWire_add_old, ha, hj, Circuit.evalWire_input] <;>
    simp

/-- A circuit together with a selected accumulator wire. -/
structure AccCircuit (d : ℕ) where
  circuit : Circuit d
  wire : Fin circuit.wires

def AccCircuit.eval {d : ℕ} (a : AccCircuit d) (x : Input d) : Bool :=
  a.circuit.evalWire x a.wire

def AccCircuit.step {d : ℕ} (a : AccCircuit d) (j : Fin d) (b : Bool) : AccCircuit d :=
  let c := a.circuit.andLiteral a.wire j b
  ⟨c, ⟨c.outputWire, c.outputWire_lt⟩⟩

@[simp] theorem AccCircuit.eval_step {d : ℕ} (a : AccCircuit d)
    (j : Fin d) (b : Bool) (x : Input d) :
    (a.step j b).eval x = (a.eval x && decide (x j = b)) := by
  exact Circuit.eval_andLiteral _ _ _ _ _

@[simp] theorem AccCircuit.size_step {d : ℕ} (a : AccCircuit d)
    (j : Fin d) (b : Bool) : (a.step j b).circuit.size = a.circuit.size + 3 :=
  Circuit.size_andLiteral _ _ _ _

def AccCircuit.build {d : ℕ} (target : Input d) : AccCircuit d → List (Fin d) → AccCircuit d
  | a, [] => a
  | a, j :: js => build target (a.step j (target j)) js

@[simp] theorem AccCircuit.size_build {d : ℕ} (target : Input d)
    (a : AccCircuit d) (js : List (Fin d)) :
    (a.build target js).circuit.size = a.circuit.size + 3 * js.length := by
  induction js generalizing a with
  | nil => simp [AccCircuit.build]
  | cons j js ih => simp [AccCircuit.build, ih]; omega

theorem AccCircuit.extends_build {d : ℕ} (target : Input d)
    (a : AccCircuit d) (js : List (Fin d)) :
    a.circuit.Extends (a.build target js).circuit := by
  induction js generalizing a with
  | nil => exact Circuit.Extends.refl _
  | cons j js ih =>
    exact (Circuit.extends_andLiteral a.circuit a.wire j (target j)).trans
      (ih (a.step j (target j)))

@[simp] theorem AccCircuit.eval_build {d : ℕ} (target : Input d)
    (a : AccCircuit d) (js : List (Fin d)) (x : Input d) :
    (a.build target js).eval x =
      (a.eval x && js.all (fun j => decide (x j = target j))) := by
  induction js generalizing a with
  | nil => simp [AccCircuit.build]
  | cons j js ih => simp [AccCircuit.build, ih, Bool.and_assoc]


def Circuit.equalityAccumulator {d : ℕ} (c : Circuit d) (target : Input d) : AccCircuit d :=
  AccCircuit.build target ⟨c, ⟨d + 1, by unfold Circuit.wires; omega⟩⟩ (List.finRange d)

@[simp] theorem Circuit.size_equalityAccumulator {d : ℕ} (c : Circuit d) (target : Input d) :
    (c.equalityAccumulator target).circuit.size = c.size + 3 * d := by
  simp [Circuit.equalityAccumulator]

theorem Circuit.extends_equalityAccumulator {d : ℕ} (c : Circuit d) (target : Input d) :
    c.Extends (c.equalityAccumulator target).circuit :=
  AccCircuit.extends_build target ⟨c, ⟨d + 1, by unfold Circuit.wires; omega⟩⟩
    (List.finRange d)

@[simp] theorem Circuit.eval_equalityAccumulator {d : ℕ} (c : Circuit d)
    (target x : Input d) : (c.equalityAccumulator target).eval x = decide (x = target) := by
  unfold Circuit.equalityAccumulator
  rw [AccCircuit.eval_build]
  simp only [AccCircuit.eval, Circuit.evalWire_true, Bool.true_and]
  apply Bool.eq_iff_iff.mpr
  simp only [List.all_eq_true, List.mem_finRange, decide_eq_true_eq, forall_const]
  exact ⟨fun h => funext h, fun h i => congrFun h i⟩

/-- A three-gate multiplexer: overwrite h with y exactly when e is true. -/
def Circuit.overrideWire {d : ℕ} (c : Circuit d) (h e : Fin c.wires)
    (y : Bool) : Circuit d :=
  let i := if y then h else e
  let c₁ := c.add i i
  let hi : Fin c₁.wires := ⟨h, by
    have hh := h.isLt
    change (h : ℕ) < d + 2 + c.size at hh
    change (h : ℕ) < d + 2 + (c.size + 1)
    omega⟩
  let ei : Fin c₁.wires := ⟨e, by
    have he := e.isLt
    change (e : ℕ) < d + 2 + c.size at he
    change (e : ℕ) < d + 2 + (c.size + 1)
    omega⟩
  let ni : Fin c₁.wires := ⟨c.wires, by simp [c₁, Circuit.wires]⟩
  let c₂ := if y then c₁.add ei ei else c₁.add hi ni
  let n₁ : Fin c₂.wires := ⟨c.wires, by
    dsimp [c₂]; split <;> simp [Circuit.wires, c₁] <;> omega⟩
  let n₂ : Fin c₂.wires := ⟨c₁.wires, by
    dsimp [c₂]; split <;> simp [Circuit.wires]⟩
  if y then c₂.add n₁ n₂ else c₂.add n₂ n₂

@[simp] theorem Circuit.size_overrideWire {d : ℕ} (c : Circuit d)
    (h e : Fin c.wires) (y : Bool) :
    (c.overrideWire h e y).size = c.size + 3 := by
  cases y <;> simp [Circuit.overrideWire]

theorem Circuit.extends_overrideWire {d : ℕ} (c : Circuit d)
    (h e : Fin c.wires) (y : Bool) : c.Extends (c.overrideWire h e y) := by
  cases y <;> unfold Circuit.overrideWire <;> dsimp <;>
    exact (Circuit.extends_add _ _ _).trans
      ((Circuit.extends_add _ _ _).trans (Circuit.extends_add _ _ _))

@[simp] theorem Circuit.eval_overrideWire {d : ℕ} (c : Circuit d)
    (h e : Fin c.wires) (y : Bool) (x : Input d) :
    (c.overrideWire h e y).eval x = if c.evalWire x e then y else c.evalWire x h := by
  have hh := h.isLt
  have he := e.isLt
  cases y <;> dsimp [Circuit.overrideWire] <;>
    simp only [Circuit.eval_add, Circuit.evalWire_add_new, Bool.and_self, Bool.not_not]
  · rw [Circuit.evalWire_add_old _ _ _ _ _ hh]
    cases c.evalWire x e <;> simp
  · rw [Circuit.evalWire_add_old _ _ _ _ _ (by simp [Circuit.wires])]
    rw [Circuit.evalWire_add_new, Circuit.evalWire_add_old _ _ _ _ _ he]
    cases c.evalWire x e <;> simp

/-- Append exactly 3d+3 gates to change one truth-table entry. -/
def Circuit.overwrite {d : ℕ} (c : Circuit d) (target : Input d) (y : Bool) : Circuit d :=
  let a := c.equalityAccumulator target
  let h : Fin a.circuit.wires := ⟨c.outputWire, by
    have ho := c.outputWire_lt
    have hs := (c.extends_equalityAccumulator target).1
    dsimp [a]
    unfold Circuit.wires at *; omega⟩
  a.circuit.overrideWire h a.wire y

@[simp] theorem Circuit.size_overwrite {d : ℕ} (c : Circuit d)
    (target : Input d) (y : Bool) :
    (c.overwrite target y).size = c.size + (3 * d + 3) := by
  simp [Circuit.overwrite]; omega

@[simp] theorem Circuit.eval_overwrite {d : ℕ} (c : Circuit d)
    (target x : Input d) (y : Bool) :
    (c.overwrite target y).eval x = if x = target then y else c.eval x := by
  simp only [Circuit.overwrite, Circuit.eval_overrideWire]
  change (if (c.equalityAccumulator target).eval x then y else
    (c.equalityAccumulator target).circuit.evalWire x c.outputWire) = _
  rw [Circuit.eval_equalityAccumulator,
    (c.extends_equalityAccumulator target).2 x c.outputWire c.outputWire_lt]
  simp [Circuit.eval]

end NeuralGeneralization.BatchTwoCircuitConverse
