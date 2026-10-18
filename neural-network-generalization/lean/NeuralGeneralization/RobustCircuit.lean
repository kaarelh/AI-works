import NeuralGeneralization.RobustCircuitSaturation
import Mathlib.Data.Fintype.Pi

/-!
# A concrete layered Boolean circuit with counted constant wires

The gate basis is copies, negations, and NAND. Each hidden layer has exactly
`C` slots, one of which carries `true` for use as an ordinary internal bias
wire. All padding/copies must be included in this width. There are `r+1`
hidden Boolean stages, matching the actual tanh network.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel

inductive DigitalGate (I : Type*) where
  | copy (i : I)
  | negate (i : I)
  | nand (i j : I)

def DigitalGate.eval {I : Type*} (g : DigitalGate I) (b : I → Bool) : Bool :=
  match g with
  | .copy i => b i
  | .negate i => !(b i)
  | .nand i j => !(b i && b j)

/-- The constant is supplied by an actual counted wire, not a new bias. -/
def DigitalGate.linear {I : Type*} (g : DigitalGate I) (one : ℝ) (h : I → ℝ) : ℝ :=
  match g with
  | .copy i => h i
  | .negate i => -h i
  | .nand i j => one - h i - h j

/-- Every Boolean gate has an ideal signed preactivation of at least one. -/
theorem DigitalGate.signed_linear_margin {I : Type*} (g : DigitalGate I) (b : I → Bool) :
    1 ≤ labelReal (g.eval b) * g.linear 1 (fun i => labelReal (b i)) := by
  cases g with
  | copy i => cases hi : b i <;> norm_num [DigitalGate.eval, DigitalGate.linear, labelReal, hi]
  | negate i => cases hi : b i <;> norm_num [DigitalGate.eval, DigitalGate.linear, labelReal, hi]
  | nand i j => cases hi : b i <;> cases hj : b j <;>
      norm_num [DigitalGate.eval, DigitalGate.linear, labelReal, hi, hj]

/-- The simultaneous input error for a gate is bounded by three coordinate
errors, including the constant wire. -/
theorem DigitalGate.linear_error {I : Type*} (g : DigitalGate I)
    (h b : I → ℝ) (one one' ε : ℝ) (hε : 0 ≤ ε)
    (hone : |one-one'| ≤ ε) (hh : ∀ i, |h i-b i| ≤ ε) :
    |g.linear one h - g.linear one' b| ≤ 3*ε := by
  cases g with
  | copy i => simpa only [DigitalGate.linear] using (hh i).trans (by linarith)
  | negate i =>
      have hi := hh i
      simpa only [DigitalGate.linear, neg_sub_neg, abs_sub_comm] using hi.trans (by linarith)
  | nand i j =>
      calc
        _ = |(one-one') - (h i-b i) - (h j-b j)| := by
          congr 1
          simp only [DigitalGate.linear]
          ring
        _ ≤ |one-one'| + |h i-b i| + |h j-b j| :=
          by
            have h1 := abs_sub ((one-one')-(h i-b i)) (h j-b j)
            have h2 := abs_sub (one-one') (h i-b i)
            linarith
        _ ≤ 3*ε := by linarith [hh i, hh j]

/-- Actual row coefficients of the gate's linear preactivation. -/
def DigitalGate.coeff {I : Type*} [DecidableEq I] (g : DigitalGate I) (constant j : I) : ℝ :=
  match g with
  | .copy i => if j=i then 1 else 0
  | .negate i => if j=i then -1 else 0
  | .nand i k => (if j=constant then 1 else 0) -
      (if j=i then 1 else 0) - (if j=k then 1 else 0)

theorem DigitalGate.sum_coeff {I : Type*} [Fintype I] [DecidableEq I]
    (g : DigitalGate I) (constant : I) (h : I → ℝ) :
    (∑ j, g.coeff constant j * h j) = g.linear (h constant) h := by
  cases g <;> simp [DigitalGate.coeff, DigitalGate.linear, sub_mul,
    Finset.sum_sub_distrib]

theorem DigitalGate.abs_coeff_le {I : Type*} [DecidableEq I]
    (g : DigitalGate I) (constant j : I) : |g.coeff constant j| ≤ 3 := by
  cases g <;> simp only [DigitalGate.coeff] <;> split_ifs <;> norm_num

/-- Exactly `C` Boolean wires at each of the `r+1` stages. -/
structure LayeredBooleanCircuit (d C r : ℕ) where
  constant : Fin C
  first : Fin C → DigitalGate (Fin (d+1))
  internal : Fin r → Fin C → DigitalGate (Fin C)
  output : Fin C
  first_constant : first constant = .copy 0
  internal_constant : ∀ s, internal s constant = .copy constant

namespace LayeredBooleanCircuit
variable {d C r : ℕ}

def firstBits (B : LayeredBooleanCircuit d C r) (x : Cube d) : Fin C → Bool :=
  fun i => (B.first i).eval (Fin.cases true x)

def stepBits (B : LayeredBooleanCircuit d C r) (h : Fin C → Bool)
    (s : Fin r) : Fin C → Bool := fun i => (B.internal s i).eval h

def finalBits (B : LayeredBooleanCircuit d C r) (x : Cube d) : Fin C → Bool :=
  (List.finRange r).foldl B.stepBits (B.firstBits x)

def computes (B : LayeredBooleanCircuit d C r) : BooleanFunction d :=
  fun x => B.finalBits x B.output

@[simp] theorem firstBits_constant (B : LayeredBooleanCircuit d C r) (x : Cube d) :
    B.firstBits x B.constant = true := by
  simp [firstBits, B.first_constant, DigitalGate.eval]

@[simp] theorem stepBits_constant (B : LayeredBooleanCircuit d C r)
    (h : Fin C → Bool) (s : Fin r) : B.stepBits h s B.constant = h B.constant := by
  simp [stepBits, B.internal_constant, DigitalGate.eval]

theorem fold_constant (B : LayeredBooleanCircuit d C r)
    (ss : List (Fin r)) (h : Fin C → Bool) :
    ss.foldl B.stepBits h B.constant = h B.constant := by
  induction ss generalizing h with
  | nil => rfl
  | cons s ss ih => simpa only [List.foldl_cons, ih, stepBits_constant]

@[simp] theorem finalBits_constant (B : LayeredBooleanCircuit d C r) (x : Cube d) :
    B.finalBits x B.constant = true := by
  simp [finalBits, fold_constant]

/-- Direct tanh gate simulation at an arbitrary positive gain and readout
scale. This is a concrete weight vector, not a realizability assumption. -/
def teacher (B : LayeredBooleanCircuit d C r) (A a : ℝ) : Weights d C r
  | Sum.inl (i,j) => A * (B.first i).coeff 0 j
  | Sum.inr (Sum.inl (s,i,j)) => A * (B.internal s i).coeff B.constant j
  | Sum.inr (Sum.inr i) => if i=B.output then a else 0

theorem first_teacher_preactivation (B : LayeredBooleanCircuit d C r)
    (A a : ℝ) (x : Cube d) (i : Fin C) :
    (∑ j, B.teacher A a (Sum.inl (i,j)) * inputVector x j) =
      A * (B.first i).linear 1 (inputVector x) := by
  simp only [teacher, mul_assoc, ← Finset.mul_sum, DigitalGate.sum_coeff]
  rfl

theorem internal_teacher_preactivation (B : LayeredBooleanCircuit d C r)
    (A a : ℝ) (h : Fin C → ℝ) (s : Fin r) (i : Fin C) :
    (∑ j, B.teacher A a (Sum.inr (Sum.inl (s,i,j))) * h j) =
      A * (B.internal s i).linear (h B.constant) h := by
  simp only [teacher, mul_assoc, ← Finset.mul_sum, DigitalGate.sum_coeff]

theorem readout_teacher (B : LayeredBooleanCircuit d C r) (A a : ℝ) (h : Fin C → ℝ) :
    (∑ i, B.teacher A a (Sum.inr (Sum.inr i)) * h i) = a * h B.output := by
  simp [teacher]

end LayeredBooleanCircuit
end NeuralGeneralization.ConcreteModel
