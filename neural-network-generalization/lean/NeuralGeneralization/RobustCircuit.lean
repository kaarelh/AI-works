import NeuralGeneralization.RobustCircuitSaturation
import Mathlib.Data.Fintype.Pi

/-!
# A concrete layered Boolean circuit with counted constant wires

The gate basis is copies, negations, and NAND. Each hidden layer has exactly
`C` slots. A counted bias wire must carry `true` only at a stage whose
successor uses NAND. Copies and negations need no bias; in particular, no
constant wire is reserved at the final stage. Padding counts toward width. There are `r+1`
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
  /-- The designated wire is a bias only where a NAND actually consumes it.
  The prefix equation identifies the actual preceding stage, without imposing
  any condition on unreachable Boolean states or the final hidden stage. -/
  bias_available : ∀ (pre post : List (Fin r)) (s : Fin r) (x : Cube d),
    pre ++ s :: post = List.finRange r →
    ∀ i j k, internal s i = .nand j k →
      (pre.foldl (fun h t a => (internal t a).eval h)
        (fun a => (first a).eval (Fin.cases true x))) constant = true

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

/-- The previous, stronger circuit convention embeds at exactly the same
width and depth. This also preserves existing constant-wire witnesses. -/
def ofConstantWire (constant : Fin C)
    (first : Fin C → DigitalGate (Fin (d+1)))
    (internal : Fin r → Fin C → DigitalGate (Fin C)) (output : Fin C)
    (hfirst : first constant = .copy 0)
    (hstep : ∀ s, internal s constant = .copy constant) :
    LayeredBooleanCircuit d C r where
  constant := constant
  first := first
  internal := internal
  output := output
  bias_available := by
    intro pre post s x _ i j k _
    have hfold (ss : List (Fin r)) (h : Fin C → Bool) :
        (ss.foldl (fun b t a => (internal t a).eval b) h) constant = h constant := by
      induction ss generalizing h with
      | nil => rfl
      | cons t ss ih =>
        rw [List.foldl_cons, ih]
        simp only [hstep, DigitalGate.eval]
    rw [hfold, hfirst]
    rfl

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
