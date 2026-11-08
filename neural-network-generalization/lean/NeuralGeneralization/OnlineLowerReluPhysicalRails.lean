import NeuralGeneralization.OnlineLowerReluRandomizedMinimum
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise
import Mathlib.Algebra.Order.BigOperators.Ring.Finset

/-! # Literal rail signs and the parity-conditioned score formula -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

def selectedSign {α : Type*} [DecidableEq α] (S : Finset α) (j : α) : ℝ :=
  if j ∈ S then 1 else -1

theorem sum_selectedSign {α : Type*} [DecidableEq α] (B S : Finset α) :
    (∑ j ∈ B, selectedSign S j) = 2 * ((S ∩ B).card : ℝ) - B.card := by
  have heq (j : α) : selectedSign S j = 2 * (if j ∈ S then (1 : ℝ) else 0) - 1 := by
    unfold selectedSign
    split_ifs <;> norm_num
  simp_rw [heq, Finset.sum_sub_distrib, ← Finset.mul_sum]
  simp [Finset.sum_ite_mem, Finset.inter_comm]

theorem prod_selectedSign {α : Type*} [DecidableEq α] (B S : Finset α) :
    (∏ j ∈ B, selectedSign S j) =
      (-1 : ℝ) ^ B.card * (-1 : ℝ) ^ (S ∩ B).card := by
  have heq (j : α) : selectedSign S j =
      (-1 : ℝ) * (if j ∈ S then -1 else 1) := by
    unfold selectedSign
    split_ifs <;> norm_num
  simp_rw [heq, Finset.prod_mul_distrib]
  simp [Finset.prod_ite_mem, Finset.inter_comm]

def freeRailSum {ι : Type*} (r : ι → ℕ)
    (z : (i : ι) → Fin (r i) → Bool) (i : ι) : ℝ := ∑ j, railBit (z i j)

def freeRailParity {ι : Type*} (r : ι → ℕ)
    (z : (i : ι) → Fin (r i) → Bool) (i : ι) : ℝ := ∏ j, railBit (z i j)

theorem freeRailParity_abs {ι : Type*} (r : ι → ℕ)
    (z : (i : ι) → Fin (r i) → Bool) (i : ι) : |freeRailParity r z i| = 1 := by
  unfold freeRailParity
  rw [Finset.abs_prod]
  simp [railBit_abs]

def physicalLastSign {ι α : Type*} [DecidableEq α]
    (blocks : ι → Finset α) (r : ι → ℕ) (η ε : ι → Bool)
    (z : (i : ι) → Fin (r i) → Bool) (S : Finset α) (i : ι) : ℝ :=
  railBit (η i) * railBit (ε i) *
    (∏ j ∈ blocks i, selectedSign S j) * freeRailParity r z i

def physicalConditionedScore {ι α : Type*} [Fintype ι] [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α) (r : ι → ℕ)
    (a b : ι → ℝ) (η ε : ι → Bool)
    (z : (i : ι) → Fin (r i) → Bool) (bias : ℝ) (S : Finset α) : ℝ :=
  bias + ∑ i,
    (a i * (selectedSign S (distinguished i) + ∑ j ∈ blocks i, selectedSign S j) +
      b i * (railBit (ε i) * selectedSign S (distinguished i) + freeRailSum r z i +
        physicalLastSign blocks r η ε z S i))

def physicalProfileCoefficient {ι α : Type*}
    (blocks : ι → Finset α) (r : ι → ℕ) (b : ι → ℝ) (η ε : ι → Bool)
    (z : (i : ι) → Fin (r i) → Bool) (i : ι) : ℝ :=
  b i * railBit (η i) * railBit (ε i) *
    (-1 : ℝ) ^ (blocks i).card * freeRailParity r z i

def physicalProfileBias {ι α : Type*} [Fintype ι]
    (blocks : ι → Finset α) (r : ι → ℕ) (a b : ι → ℝ) (ε : ι → Bool)
    (z : (i : ι) → Fin (r i) → Bool) (bias : ℝ) : ℝ :=
  bias + ∑ i, (-a i * (blocks i).card + b i * freeRailSum r z i -
    (a i + railBit (ε i) * b i))

theorem physicalProfileCoefficient_abs {ι α : Type*}
    (blocks : ι → Finset α) (r : ι → ℕ) (b : ι → ℝ) (η ε : ι → Bool)
    (z : (i : ι) → Fin (r i) → Bool) (i : ι) (hb : 0 ≤ b i) :
    |physicalProfileCoefficient blocks r b η ε z i| = b i := by
  unfold physicalProfileCoefficient
  simp [abs_mul, railBit_abs, abs_pow, freeRailParity_abs, abs_of_nonneg hb]

/-- The explicit real-valued network input under the conditional sampler
is exactly the monotone profile expression used in the coefficient proof. -/
theorem physicalConditionedScore_eq_profile {ι α : Type*}
    [Fintype ι] [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α) (r : ι → ℕ)
    (a b : ι → ℝ) (η ε : ι → Bool)
    (z : (i : ι) → Fin (r i) → Bool) (bias : ℝ) (S : Finset α) :
    physicalConditionedScore blocks distinguished r a b η ε z bias S =
      conditionedSelectedScore blocks distinguished a
        (physicalProfileCoefficient blocks r b η ε z)
        (fun i => a i + railBit (ε i) * b i)
        (physicalProfileBias blocks r a b ε z bias) S := by
  classical
  unfold physicalConditionedScore conditionedSelectedScore conditionedBlockScore
    physicalProfileBias
  simp only [add_assoc]
  rw [← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  rw [sum_selectedSign]
  unfold physicalLastSign physicalProfileCoefficient conditionedRailProfile
  rw [prod_selectedSign]
  unfold selectedSign
  split_ifs <;> ring

/-- The randomized-minimum inequality for the actual affine ReLU score
produced by the explicit conditional rail sampler. Each opposite rail has
two distinguished positions and `r i` independent free positions. -/
theorem physical_randomized_minimum_bound {ι α : Type*}
    [Fintype ι] [Nonempty ι] [DecidableEq ι] [DecidableEq α]
    (selected : Finset α) (n : ℕ) (hcard : selected.card = n + 2)
    (blocks : ι → Finset α) (distinguished : ι → α)
    (hinj : Function.Injective distinguished)
    (hdisjoint : ∀ i j, distinguished i ∉ blocks j)
    (hselected : ∀ i, distinguished i ∈ selected)
    (r : ι → ℕ) (a b : ι → ℝ) (η : ι → Bool) (bias : ℝ)
    (hb : ∀ i, 0 ≤ b i) (hab : ∀ i, b i ≤ a i) :
    |topSubsetCoefficient selected (fun S => finiteAverage (fun ε : ι → Bool =>
        finiteAverage (fun z : (i : ι) → Fin (r i) → Bool =>
          max (physicalConditionedScore blocks distinguished r a b η ε z bias S) 0)))| ≤
      (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) *
        finiteAverage (minimumRailAmplitude a b) := by
  simp_rw [physicalConditionedScore_eq_profile]
  exact randomized_minimum_bound selected n hcard blocks distinguished hinj hdisjoint
    hselected a b (fun ε z => physicalProfileCoefficient blocks r b η ε z)
    (fun ε z => physicalProfileBias blocks r a b ε z bias) hb hab
    (fun ε z i => (physicalProfileCoefficient_abs blocks r b η ε z i (hb i)).le)

end NeuralGeneralization.OnlineLowerRelu
