import NeuralGeneralization.BatchTwoMergingGeometry
import NeuralGeneralization.ParameterStability

/-! # Exact Boolean NOR/COPY/NOT compilation into ReLU networks -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.BatchTwoMerging

open ConcreteModel

def bitReal (b : Bool) : ℝ := if b then 1 else 0

@[simp] theorem bitReal_true : bitReal true = 1 := rfl
@[simp] theorem bitReal_false : bitReal false = 0 := rfl

theorem bitReal_nonneg (b : Bool) : 0 ≤ bitReal b := by cases b <;> norm_num [bitReal]
theorem bitReal_le_one (b : Bool) : bitReal b ≤ 1 := by cases b <;> norm_num [bitReal]
theorem two_bitReal_sub_one (b : Bool) : 2 * bitReal b - 1 = labelReal b := by
  cases b <;> norm_num [bitReal, labelReal]

inductive NorGate (I : Type*)
  | copy (i : I)
  | negate (i : I)
  | nor (i j : I)
  deriving DecidableEq, Fintype

namespace NorGate

def eval {I : Type*} (g : NorGate I) (h : I → Bool) : Bool := match g with
  | .copy i => h i
  | .negate i => !(h i)
  | .nor i j => !(h i || h j)

def coefficients {I : Type*} [DecidableEq I] (one : I) (g : NorGate I) : I → ℝ :=
  match g with
  | .copy i => fun j => if i = j then 1 else 0
  | .negate i => fun j => (if one = j then 1 else 0) - (if i = j then 1 else 0)
  | .nor i k => fun j => (if one = j then 1 else 0) -
      (if i = j then 1 else 0) - (if k = j then 1 else 0)

theorem coefficient_sum {I : Type*} [Fintype I] [DecidableEq I]
    (one : I) (g : NorGate I) (h : I → ℝ) :
    (∑ j, coefficients one g j * h j) = match g with
      | .copy i => h i
      | .negate i => h one - h i
      | .nor i k => h one - h i - h k := by
  cases g <;> simp [coefficients, sub_mul, Finset.sum_sub_distrib]

theorem relu_coefficients {I : Type*} [Fintype I] [DecidableEq I]
    (one : I) (g : NorGate I) (h : I → Bool) (hconst : h one = true) :
    relu (∑ j, coefficients one g j * bitReal (h j)) = bitReal (g.eval h) := by
  rw [coefficient_sum]
  cases g with
  | copy i => cases hi : h i <;> norm_num [eval, hi, bitReal, relu]
  | negate i => cases hi : h i <;> norm_num [eval, hi, hconst, bitReal, relu]
  | nor i j => cases hi : h i <;> cases hj : h j <;>
      norm_num [eval, hi, hj, hconst, bitReal, relu]

def firstCoefficients {d : ℕ} (g : NorGate (Fin (d + 1))) : Fin (d + 1) → ℝ :=
  match g with
  | .copy i => fun j => (1 / 2 : ℝ) * (if (0 : Fin (d + 1)) = j then 1 else 0) +
      (1 / 2 : ℝ) * (if i = j then 1 else 0)
  | .negate i => fun j => (1 / 2 : ℝ) * (if (0 : Fin (d + 1)) = j then 1 else 0) -
      (1 / 2 : ℝ) * (if i = j then 1 else 0)
  | .nor i k => fun j => -(1 / 2 : ℝ) * (if i = j then 1 else 0) -
      (1 / 2 : ℝ) * (if k = j then 1 else 0)

theorem firstCoefficients_sum {d : ℕ} (g : NorGate (Fin (d + 1))) (x : Cube d) :
    (∑ j, firstCoefficients g j * inputVector x j) = match g with
      | .copy i => (1 + inputVector x i) / 2
      | .negate i => (1 - inputVector x i) / 2
      | .nor i k => -(inputVector x i + inputVector x k) / 2 := by
  cases g <;>
    simp [firstCoefficients, add_mul, sub_mul, Finset.sum_add_distrib,
      Finset.sum_sub_distrib, mul_assoc, ← Finset.mul_sum, inputVector] <;> ring

theorem inputVector_eq_labelReal {d : ℕ} (x : Cube d) (i : Fin (d + 1)) :
    inputVector x i = labelReal (Fin.cases true x i) := by
  induction i using Fin.cases <;> simp [inputVector]

theorem relu_firstCoefficients {d : ℕ} (g : NorGate (Fin (d + 1))) (x : Cube d) :
    relu (∑ j, firstCoefficients g j * inputVector x j) =
      bitReal (g.eval (Fin.cases true x)) := by
  rw [firstCoefficients_sum]
  cases g with
  | copy i =>
      dsimp only
      rw [inputVector_eq_labelReal]
      cases h : (Fin.cases true x i : Bool) <;> norm_num [eval, h, labelReal, bitReal, relu]
  | negate i =>
      dsimp only
      rw [inputVector_eq_labelReal]
      cases h : (Fin.cases true x i : Bool) <;> norm_num [eval, h, labelReal, bitReal, relu]
  | nor i j =>
      dsimp only
      rw [inputVector_eq_labelReal, inputVector_eq_labelReal]
      cases hi : (Fin.cases true x i : Bool) <;> cases hj : (Fin.cases true x j : Bool) <;>
        norm_num [eval, hi, hj, labelReal, bitReal, relu]

end NorGate

structure LayeredNorCircuit (d C r : ℕ) where
  constant : Fin C
  first : Fin C → NorGate (Fin (d + 1))
  internal : Fin r → Fin C → NorGate (Fin C)
  output : Fin C
  first_constant : first constant = .copy 0
  internal_constant : ∀ s, internal s constant = .copy constant

namespace LayeredNorCircuit

variable {d C r : ℕ}

def firstBits (B : LayeredNorCircuit d C r) (x : Cube d) : Fin C → Bool :=
  fun i => (B.first i).eval (Fin.cases true x)

def stepBits (B : LayeredNorCircuit d C r) (h : Fin C → Bool) (s : Fin r) : Fin C → Bool :=
  fun i => (B.internal s i).eval h

def finalBits (B : LayeredNorCircuit d C r) (x : Cube d) : Fin C → Bool :=
  (List.finRange r).foldl B.stepBits (B.firstBits x)

def computes (B : LayeredNorCircuit d C r) : BooleanFunction d :=
  fun x => B.finalBits x B.output

theorem firstBits_constant (B : LayeredNorCircuit d C r) (x : Cube d) :
    B.firstBits x B.constant = true := by
  simp [firstBits, B.first_constant, NorGate.eval]

theorem stepBits_constant (B : LayeredNorCircuit d C r) (h : Fin C → Bool)
    (hconst : h B.constant = true) (s : Fin r) :
    B.stepBits h s B.constant = true := by
  simp [stepBits, B.internal_constant, NorGate.eval, hconst]

theorem foldBits_constant (B : LayeredNorCircuit d C r) (ss : List (Fin r))
    (h : Fin C → Bool) (hconst : h B.constant = true) :
    ss.foldl B.stepBits h B.constant = true := by
  induction ss generalizing h with
  | nil => exact hconst
  | cons s ss ih => exact ih _ (B.stepBits_constant h hconst s)

theorem finalBits_constant (B : LayeredNorCircuit d C r) (x : Cube d) :
    B.finalBits x B.constant = true :=
  B.foldBits_constant _ _ (B.firstBits_constant x)

def weights (B : LayeredNorCircuit d C r) (a : ℝ) : Weights d C r
  | Sum.inl (i, j) => (B.first i).firstCoefficients j
  | Sum.inr (Sum.inl (s, i, j)) => (B.internal s i).coefficients B.constant j
  | Sum.inr (Sum.inr i) => a * ((if B.output = i then 2 else 0) -
      (if B.constant = i then 1 else 0))

theorem firstHidden_weights (B : LayeredNorCircuit d C r) (a : ℝ) (x : Cube d) :
    firstHidden relu (B.weights a) x = fun i => bitReal (B.firstBits x i) := by
  funext i
  exact NorGate.relu_firstCoefficients (B.first i) x

theorem hiddenStep_weights (B : LayeredNorCircuit d C r) (a : ℝ)
    (h : Fin C → Bool) (hconst : h B.constant = true) (s : Fin r) :
    hiddenStep relu (B.weights a) (fun i => bitReal (h i)) s =
      fun i => bitReal (B.stepBits h s i) := by
  funext i
  exact NorGate.relu_coefficients B.constant (B.internal s i) h hconst

theorem hiddenFold_weights (B : LayeredNorCircuit d C r) (a : ℝ)
    (ss : List (Fin r)) (h : Fin C → Bool) (hconst : h B.constant = true) :
    ss.foldl (hiddenStep relu (B.weights a)) (fun i => bitReal (h i)) =
      fun i => bitReal (ss.foldl B.stepBits h i) := by
  induction ss generalizing h with
  | nil => rfl
  | cons s ss ih =>
      simp only [List.foldl_cons, hiddenStep_weights B a h hconst s]
      exact ih _ (B.stepBits_constant h hconst s)

theorem finalHidden_weights (B : LayeredNorCircuit d C r) (a : ℝ) (x : Cube d) :
    finalHidden relu (B.weights a) x = fun i => bitReal (B.finalBits x i) := by
  unfold finalHidden
  rw [firstHidden_weights]
  exact hiddenFold_weights B a _ _ (B.firstBits_constant x)

/-- This is the actual finite ReLU network, with no threshold gate hidden in
its evaluation.  It computes the target with exactly signed score `a`. -/
theorem networkOutput_weights (B : LayeredNorCircuit d C r) (a : ℝ) (x : Cube d) :
    networkOutput relu (B.weights a) x = a * labelReal (B.computes x) := by
  unfold networkOutput
  rw [finalHidden_weights]
  simp only [weights, mul_sub, sub_mul, Finset.sum_sub_distrib, mul_assoc]
  simp only [mul_ite, mul_zero, ite_mul, zero_mul]
  simp only [Finset.sum_ite_eq, Finset.mem_univ, ↓reduceIte, mul_one]
  rw [B.finalBits_constant, bitReal_true]
  simp only [one_mul]
  change a * (2 * bitReal (B.computes x)) - a * 1 = a * labelReal (B.computes x)
  rw [← mul_sub, two_bitReal_sub_one]

end LayeredNorCircuit

end NeuralGeneralization.BatchTwoMerging
