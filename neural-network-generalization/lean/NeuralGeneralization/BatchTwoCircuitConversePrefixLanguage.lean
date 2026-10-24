import NeuralGeneralization.BatchTwoCircuitConversePrior
import Mathlib.Data.Nat.Log

/-!
# The explicit prefix exception language

Programs have a base NAND description and a finite chain of exception
constructors. This is the abstract syntax of the paper's bitstring grammar:
`00`, `01` followed by a unary length and fixed-width addresses, and `1 x y p`.
The bit length below counts those exact tags, unary bits, addresses, and metadata.
No circuit-complexity-to-code-length hypothesis is assumed.
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse.Prefix

open scoped BigOperators ENNReal
noncomputable section
open Classical

abbrev Patch (d : ℕ) := Input d × Bool

/-- Total fixed-width address length for one input address per gate. -/
def addressBits (d n : ℕ) : ℕ := ∑ i ∈ Finset.range n, Nat.clog 2 (d+2+i)

/-- Exact base-code length: 00 for empty; 01 + unary 1^n0 + two addresses per gate. -/
def baseLength (d : ℕ) (n : ℕ) : ℕ :=
  if n = 0 then 2 else 3+n+2*addressBits d n

/-- An exception chain followed by one base code. The vector lists outermost
exceptions first, corresponding to the recursive `1 x y p` constructor. -/
def Program (d : ℕ) := (n : ℕ) × (Fin n → Patch d) × Circuit d

def Program.base {d : ℕ} (c : Circuit d) : Program d := ⟨0, Fin.elim0, c⟩

def Program.exception {d : ℕ} (x : Input d) (y : Bool) (p : Program d) : Program d :=
  ⟨p.1+1, Fin.cons (x,y) p.2.1, p.2.2⟩

def Program.length {d : ℕ} (p : Program d) : ℕ :=
  baseLength d p.2.2.size + p.1*(d+2)

def compileChain {d : ℕ} (c : Circuit d) : {n : ℕ} → (Fin n → Patch d) → Circuit d
  | 0, _ => c
  | n+1, patches => (compileChain c (Fin.tail patches)).overwrite
      (patches 0).1 (patches 0).2

def Program.compile {d : ℕ} (p : Program d) : Circuit d := compileChain p.2.2 p.2.1

def Program.eval {d : ℕ} (p : Program d) : Input d → Bool := p.compile.eval

@[simp] theorem Program.length_base {d : ℕ} (c : Circuit d) :
    (Program.base c).length = baseLength d c.size := by simp [Program.base, Program.length]

@[simp] theorem Program.length_exception {d : ℕ} (x : Input d) (y : Bool) (p : Program d) :
    (Program.exception x y p).length = p.length + (d+2) := by
  simp [Program.exception, Program.length, Nat.add_mul, Nat.add_assoc]

@[simp] theorem Program.compile_base {d : ℕ} (c : Circuit d) :
    (Program.base c).compile = c := rfl

@[simp] theorem Program.compile_exception {d : ℕ} (x : Input d) (y : Bool) (p : Program d) :
    (Program.exception x y p).compile = p.compile.overwrite x y := by
  simp [Program.exception, Program.compile, compileChain]

@[simp] theorem Program.eval_exception {d : ℕ} (x z : Input d) (y : Bool) (p : Program d) :
    (Program.exception x y p).eval z = if z = x then y else p.eval z := by
  simp [Program.eval]

def Program.pop {d : ℕ} : Program d → Program d
  | ⟨0, _, c⟩ => Program.base c
  | ⟨n+1, patches, c⟩ => ⟨n, Fin.tail patches, c⟩

@[simp] theorem Program.pop_exception {d : ℕ} (x : Input d) (y : Bool) (p : Program d) :
    (Program.exception x y p).pop = p := by
  cases p with
  | mk n p =>
    rcases p with ⟨patches, c⟩
    simp [Program.exception, Program.pop]

theorem Program.exception_injective {d : ℕ} (x : Input d) (y : Bool) :
    Function.Injective (Program.exception x y) := by
  intro a b hab
  have he := congrArg Program.pop hab
  simpa only [Program.pop_exception] using he

@[simp] theorem addressBits_zero (d : ℕ) : addressBits d 0 = 0 := by simp [addressBits]

@[simp] theorem addressBits_succ (d n : ℕ) :
    addressBits d (n+1) = addressBits d n + Nat.clog 2 (d+2+n) := by
  simp [addressBits, Finset.sum_range_succ]

theorem baseLength_ge (d n : ℕ) : n+2+2*addressBits d n ≤ baseLength d n := by
  unfold baseLength
  split_ifs with hn
  · simp [hn]
  · omega

theorem compileChain_size {d n : ℕ} (c : Circuit d) (p : Fin n → Patch d) :
    (compileChain c p).size = c.size + n*(3*d+3) := by
  induction n with
  | zero => simp [compileChain]
  | succ n ih => simp [compileChain, ih, Nat.add_mul, Nat.add_assoc]

theorem Program.compile_size_le {d : ℕ} (p : Program d) :
    p.compile.size ≤ 3*p.length := by
  rw [Program.compile, compileChain_size]
  have hbase := baseLength_ge d p.2.2.size
  have hp : p.1*(3*d+3) ≤ p.1*(3*(d+2)) := Nat.mul_le_mul_left _ (by omega)
  unfold Program.length
  nlinarith

/-- The address fields provide enough syntactic capacity for every legal wiring list. -/
theorem card_gates_le_address_space (d n : ℕ) :
    Fintype.card (Gates d n) ≤ 2^(2*addressBits d n) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Gates.card_succ, addressBits_succ]
    calc
      Fintype.card (Gates d n) * (d+2+n)^2 ≤
          2^(2*addressBits d n) * (2^(Nat.clog 2 (d+2+n)))^2 :=
        Nat.mul_le_mul ih (Nat.pow_le_pow_left (Nat.le_pow_clog (by norm_num) _) _)
      _ = 2^(2*(addressBits d n+Nat.clog 2 (d+2+n))) := by
        rw [← pow_mul, ← pow_add]
        congr 1
        omega

end
end NeuralGeneralization.BatchTwoCircuitConverse.Prefix
