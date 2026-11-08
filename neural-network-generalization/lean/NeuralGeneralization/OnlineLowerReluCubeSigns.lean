import NeuralGeneralization.OnlineLowerReluMonotone
import Mathlib.Data.Fintype.Pi

/-! # Finite sign cubes and exact parity-class elimination -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

/-- The sign convention used by the existing Boolean-cube network model. -/
def railBit (b : Bool) : ℝ := if b then 1 else -1

@[simp] theorem railBit_true : railBit true = 1 := rfl
@[simp] theorem railBit_false : railBit false = -1 := rfl

theorem railBit_sq (b : Bool) : railBit b ^ 2 = 1 := by
  cases b <;> norm_num [railBit]

theorem railBit_abs (b : Bool) : |railBit b| = 1 := by
  cases b <;> norm_num [railBit]

theorem railBit_eq_one_or_neg_one (b : Bool) : railBit b = 1 ∨ railBit b = -1 := by
  cases b <;> simp [railBit]

theorem railBit_injective : Function.Injective railBit := by
  intro b c h
  cases b <;> cases c <;> simp_all [railBit] <;> linarith

theorem railBit_product_factor (b c : Bool) :
    1 + railBit b * railBit c = if b = c then 2 else 0 := by
  cases b <;> cases c <;> norm_num [railBit]

/-- Exact elimination of the last sign in every conditioned rail. The
product on the left is the indicator of the specified parity class,
multiplied by its reciprocal uniform probability. -/
theorem parity_class_projection {ι : Type*} [Fintype ι] [DecidableEq ι]
    (target : ι → Bool) (F : (ι → Bool) → ℝ) :
    (∑ y : ι → Bool, (∏ i, (1 + railBit (target i) * railBit (y i))) * F y) =
      (2 : ℝ) ^ Fintype.card ι * F target := by
  classical
  rw [Finset.sum_eq_single target]
  · simp_rw [railBit_product_factor]
    simp
  · intro y _ hy
    have hdiff : ∃ i, target i ≠ y i := by
      by_contra h
      push Not at h
      exact hy (funext (fun i => (h i).symm))
    obtain ⟨i, hi⟩ := hdiff
    have hzero : (∏ j, (1 + railBit (target j) * railBit (y j))) = 0 := by
      apply Finset.prod_eq_zero (Finset.mem_univ i)
      rw [railBit_product_factor, if_neg hi]
    rw [hzero, zero_mul]
  · simp

/-- Uniform averaging therefore gives exactly evaluation at the forced
last-bit vector, not an approximation to a conditional distribution. -/
theorem parity_class_projection_normalized {ι : Type*} [Fintype ι] [DecidableEq ι]
    (target : ι → Bool) (F : (ι → Bool) → ℝ) :
    (∑ y : ι → Bool, (∏ i, (1 + railBit (target i) * railBit (y i))) * F y) /
      (2 : ℝ) ^ Fintype.card ι = F target := by
  rw [parity_class_projection]
  field_simp

/-- Multiplication by a fixed sign is an exact permutation of uniform
signs. The Boolean equality operation implements sign multiplication. -/
def multiplyRailBits {ι : Type*} (x : ι → Bool) : (ι → Bool) ≃ (ι → Bool) where
  toFun ε i := (ε i == x i)
  invFun y i := (y i == x i)
  left_inv ε := by
    funext i
    change ((ε i == x i) == x i) = ε i
    cases ε i <;> cases x i <;> rfl
  right_inv y := by
    funext i
    change ((y i == x i) == x i) = y i
    cases y i <;> cases x i <;> rfl

theorem railBit_multiply (b c : Bool) : railBit (b == c) = railBit b * railBit c := by
  cases b <;> cases c <;> norm_num [railBit]

theorem sum_multiplyRailBits {ι : Type*} [Fintype ι] [DecidableEq ι]
    (x : ι → Bool) (F : (ι → Bool) → ℝ) :
    (∑ ε : ι → Bool, F (multiplyRailBits x ε)) = ∑ y : ι → Bool, F y :=
  Equiv.sum_comp (multiplyRailBits x) F

end NeuralGeneralization.OnlineLowerRelu
