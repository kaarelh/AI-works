import NeuralGeneralization.BatchTwoCircuitConverseCircuits
import Mathlib.Data.Nat.Log
import Mathlib.Data.List.FinRange
import Mathlib.Tactic.NormNum

/-!
# Concrete circuit classes for the conditional learning statement

`PPoly` uses the existing, explicit, topologically ordered NAND circuits.
`TC1` uses the explicit acyclic threshold circuits below: each threshold gate
counts true incoming wires and compares with an integer threshold. NAND gates
are also permitted. Inputs of a gate are always earlier wires. Circuit size
counts gates and incoming wires, so unbounded fan-in is not free.

Only circuit definitions and the explicitly listed lemmas are verified here.
In particular the standard polynomial threshold-to-NAND simulation is NOT
silently built into a definition or postulated as an axiom.
-/

namespace ConditionalNonpolynomial

abbrev Input (d : ℕ) := Fin d → Bool
abbrev Family := (d : ℕ) → Input d → Bool

abbrev BooleanCircuit := NeuralGeneralization.BatchTwoCircuitConverse.Circuit

/-- One gate with access to `n` earlier wires. The list may contain repeats. -/
inductive ThresholdGate (n : ℕ) where
  | nand (i j : Fin n)
  | threshold (inputs : List (Fin n)) (cutoff : ℕ)

def ThresholdGate.eval {n : ℕ} : ThresholdGate n → (Fin n → Bool) → Bool
  | .nand i j, x => !(x i && x j)
  | .threshold is k, x => decide (k ≤ (is.filter fun i => x i).length)

def ThresholdGate.fanIn {n : ℕ} : ThresholdGate n → ℕ
  | .nand _ _ => 2
  | .threshold is _ => is.length

def ThresholdGate.inputDepth {n : ℕ} : ThresholdGate n → (Fin n → ℕ) → ℕ
  | .nand i j, a => max (a i) (a j)
  | .threshold is _, a => (is.map a).foldl max 0

/-- Topological gate ordering; the first `d+2` wires are inputs, false, true. -/
def ThresholdGates (d : ℕ) : ℕ → Type
  | 0 => Unit
  | n + 1 => ThresholdGates d n × ThresholdGate (d + 2 + n)

def ThresholdGates.eval {d : ℕ} : {n : ℕ} → ThresholdGates d n → Input d → ℕ → Bool
  | 0, _, x => NeuralGeneralization.BatchTwoCircuitConverse.initialWire x
  | n + 1, (g, a), x => Function.update (ThresholdGates.eval g x) (d + 2 + n)
      (a.eval fun i => ThresholdGates.eval g x i)

def ThresholdGates.wireDepth {d : ℕ} : {n : ℕ} → ThresholdGates d n → ℕ → ℕ
  | 0, _ => fun _ => 0
  | n + 1, (g, a) => Function.update (ThresholdGates.wireDepth g) (d + 2 + n)
      (a.inputDepth (fun i => ThresholdGates.wireDepth g i) + 1)

def ThresholdGates.depth {d : ℕ} : {n : ℕ} → ThresholdGates d n → ℕ
  | 0, _ => 0
  | _ + 1, (g, a) => max (ThresholdGates.depth g)
      (a.inputDepth (fun i => ThresholdGates.wireDepth g i) + 1)

def ThresholdGates.wireCount {d : ℕ} : {n : ℕ} → ThresholdGates d n → ℕ
  | 0, _ => 0
  | _ + 1, (g, a) => ThresholdGates.wireCount g + a.fanIn

structure ThresholdCircuit (d : ℕ) where
  gateCount : ℕ
  gates : ThresholdGates d gateCount
  output : Fin (d + 2 + gateCount)

def ThresholdCircuit.eval {d : ℕ} (c : ThresholdCircuit d) (x : Input d) : Bool :=
  c.gates.eval x c.output

def ThresholdCircuit.size {d : ℕ} (c : ThresholdCircuit d) : ℕ :=
  c.gateCount + c.gates.wireCount

def ThresholdCircuit.depth {d : ℕ} (c : ThresholdCircuit d) : ℕ := c.gates.depth

/-- Nonuniform polynomial-size NAND circuit families. -/
def PPoly : Set Family := {f | ∃ A k : ℕ, ∀ d : ℕ,
  ∃ c : BooleanCircuit d, c.size ≤ A * (d + 2)^k ∧ c.eval = f d}

/-- Nonuniform polynomial-size, logarithmic-depth threshold circuit families. -/
def TC1 : Set Family := {f | ∃ A k B : ℕ, ∀ d : ℕ,
  ∃ c : ThresholdCircuit d, c.size ≤ A * (d + 2)^k ∧
    c.depth ≤ B * Nat.log2 (d + 2) ∧ c.eval = f d}

/-- Nonuniform polynomial-size, constant-depth threshold circuit families. -/
def TC0 : Set Family := {f | ∃ A k B : ℕ, ∀ d : ℕ,
  ∃ c : ThresholdCircuit d, c.size ≤ A * (d + 2)^k ∧
    c.depth ≤ B ∧ c.eval = f d}

/-- Every constant-depth family satisfies the logarithmic-depth resource bound. -/
theorem TC0_subset_TC1 : TC0 ⊆ TC1 := by
  rintro f ⟨A, k, B, h⟩
  refine ⟨A, k, B, fun d => ?_⟩
  rcases h d with ⟨c, hs, hd, he⟩
  refine ⟨c, hs, hd.trans ?_, he⟩
  have hlog : 1 ≤ Nat.log2 (d + 2) := by
    rw [Nat.le_log2] <;> omega
  exact le_mul_of_one_le_right (Nat.zero_le B) hlog

/-- Actual strict majority as one threshold gate. Ties give false. -/
def strictMajorityGate {n : ℕ} (is : List (Fin n)) : ThresholdGate n :=
  .threshold is (is.length / 2 + 1)

@[simp] theorem strictMajorityGate_eval {n : ℕ} (is : List (Fin n)) (x : Fin n → Bool) :
    (strictMajorityGate is).eval x =
      decide (is.length / 2 < (is.filter fun i => x i).length) := by
  simp [strictMajorityGate, ThresholdGate.eval, Nat.succ_le_iff]

end ConditionalNonpolynomial
