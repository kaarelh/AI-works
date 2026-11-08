import NeuralGeneralization.OnlineLowerReluPhysicalRails
import Mathlib.Data.Fintype.BigOperators

/-! # Exact uniform parity conditioning for physical ReLU rails -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

def realSignBit (s : ℝ) : Bool := by
  classical
  exact decide (s = 1)

theorem railBit_realSignBit (s : ℝ) (hs : |s| = 1) : railBit (realSignBit s) = s := by
  by_cases h : 0 ≤ s
  · rw [abs_of_nonneg h] at hs
    subst s
    norm_num [realSignBit, railBit]
  · rw [abs_of_neg (lt_of_not_ge h)] at hs
    have he : s = -1 := by linarith
    subst s
    norm_num [realSignBit, railBit]

theorem selectedSign_abs {α : Type*} [DecidableEq α] (S : Finset α) (j : α) :
    |selectedSign S j| = 1 := by
  unfold selectedSign
  split_ifs <;> norm_num

theorem selectedSign_sq {α : Type*} [DecidableEq α] (S : Finset α) (j : α) :
    selectedSign S j ^ 2 = 1 := by
  unfold selectedSign
  split_ifs <;> norm_num

def selectedBit {α : Type*} [DecidableEq α] (S : Finset α) (j : α) : Bool :=
  decide (j ∈ S)

theorem railBit_selectedBit {α : Type*} [DecidableEq α] (S : Finset α) (j : α) :
    railBit (selectedBit S j) = selectedSign S j := by
  simp [railBit, selectedBit, selectedSign]

def selectedRailParity {ι α : Type*} [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α) (S : Finset α) (i : ι) : ℝ :=
  selectedSign S (distinguished i) * ∏ j ∈ blocks i, selectedSign S j

theorem selectedRailParity_abs {ι α : Type*} [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α) (S : Finset α) (i : ι) :
    |selectedRailParity blocks distinguished S i| = 1 := by
  unfold selectedRailParity
  rw [abs_mul, Finset.abs_prod]
  simp [selectedSign_abs]

def forcedLastSign {ι α : Type*} [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α) (r : ι → ℕ)
    (η y : ι → Bool) (z : (i : ι) → Fin (r i) → Bool) (S : Finset α) (i : ι) : ℝ :=
  railBit (η i) * selectedRailParity blocks distinguished S i *
    railBit (y i) * freeRailParity r z i

theorem forcedLastSign_abs {ι α : Type*} [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α) (r : ι → ℕ)
    (η y : ι → Bool) (z : (i : ι) → Fin (r i) → Bool) (S : Finset α) (i : ι) :
    |forcedLastSign blocks distinguished r η y z S i| = 1 := by
  unfold forcedLastSign
  simp [abs_mul, railBit_abs, selectedRailParity_abs, freeRailParity_abs]

def forcedLastBits {ι α : Type*} [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α) (r : ι → ℕ)
    (η y : ι → Bool) (z : (i : ι) → Fin (r i) → Bool) (S : Finset α) : ι → Bool :=
  fun i => realSignBit (forcedLastSign blocks distinguished r η y z S i)

theorem railBit_forcedLastBits {ι α : Type*} [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α) (r : ι → ℕ)
    (η y : ι → Bool) (z : (i : ι) → Fin (r i) → Bool) (S : Finset α) (i : ι) :
    railBit (forcedLastBits blocks distinguished r η y z S i) =
      forcedLastSign blocks distinguished r η y z S i :=
  railBit_realSignBit _ (forcedLastSign_abs blocks distinguished r η y z S i)

/-- The unconditioned physical affine score, with the first, free, and
last opposite-rail coordinates all displayed independently. -/
def unconditionedRailScore {ι α : Type*} [Fintype ι] [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α) (r : ι → ℕ)
    (a b : ι → ℝ) (y : ι → Bool)
    (z : (i : ι) → Fin (r i) → Bool) (last : ι → Bool)
    (bias : ℝ) (S : Finset α) : ℝ :=
  bias + ∑ i,
    (a i * (selectedSign S (distinguished i) + ∑ j ∈ blocks i, selectedSign S j) +
      b i * (railBit (y i) + freeRailSum r z i + railBit (last i)))

def parityConditioningWeight {ι α : Type*} [Fintype ι] [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α) (r : ι → ℕ)
    (η y : ι → Bool) (z : (i : ι) → Fin (r i) → Bool)
    (last : ι → Bool) (S : Finset α) : ℝ :=
  ∏ i, (1 + railBit (η i) * selectedRailParity blocks distinguished S i *
    (railBit (y i) * freeRailParity r z i * railBit (last i)))

theorem parityConditioningWeight_eq_projection {ι α : Type*}
    [Fintype ι] [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α) (r : ι → ℕ)
    (η y : ι → Bool) (z : (i : ι) → Fin (r i) → Bool)
    (last : ι → Bool) (S : Finset α) :
    parityConditioningWeight blocks distinguished r η y z last S =
      ∏ i, (1 + railBit (forcedLastBits blocks distinguished r η y z S i) *
        railBit (last i)) := by
  unfold parityConditioningWeight
  apply Finset.prod_congr rfl
  intro i _
  rw [railBit_forcedLastBits]
  unfold forcedLastSign
  ring

theorem last_bit_conditioning_exact {ι α : Type*}
    [Fintype ι] [DecidableEq ι] [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α) (r : ι → ℕ)
    (η y : ι → Bool) (z : (i : ι) → Fin (r i) → Bool)
    (S : Finset α) (F : (ι → Bool) → ℝ) :
    finiteAverage (fun last : ι → Bool =>
      parityConditioningWeight blocks distinguished r η y z last S * F last) =
      F (forcedLastBits blocks distinguished r η y z S) := by
  unfold finiteAverage
  simp_rw [parityConditioningWeight_eq_projection]
  simp only [Fintype.card_fun, Fintype.card_bool, Nat.cast_pow, Nat.cast_ofNat]
  exact parity_class_projection_normalized _ F

theorem forcedLastSign_after_reparam {ι α : Type*} [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α) (r : ι → ℕ)
    (η ε : ι → Bool) (z : (i : ι) → Fin (r i) → Bool)
    (S : Finset α) (i : ι) :
    forcedLastSign blocks distinguished r η
      (multiplyRailBits (fun i => selectedBit S (distinguished i)) ε) z S i =
      physicalLastSign blocks r η ε z S i := by
  unfold forcedLastSign selectedRailParity physicalLastSign
  change railBit (η i) *
    (selectedSign S (distinguished i) * ∏ j ∈ blocks i, selectedSign S j) *
    railBit (ε i == selectedBit S (distinguished i)) * freeRailParity r z i = _
  rw [railBit_multiply, railBit_selectedBit]
  have hs := selectedSign_sq S (distinguished i)
  calc
    _ = (selectedSign S (distinguished i)) ^ 2 *
        (railBit (η i) * railBit (ε i) *
          (∏ j ∈ blocks i, selectedSign S j) * freeRailParity r z i) := by ring
    _ = _ := by rw [hs, one_mul]

theorem unconditionedRailScore_after_reparam {ι α : Type*}
    [Fintype ι] [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α) (r : ι → ℕ)
    (a b : ι → ℝ) (η ε : ι → Bool) (z : (i : ι) → Fin (r i) → Bool)
    (bias : ℝ) (S : Finset α) :
    let y := multiplyRailBits (fun i => selectedBit S (distinguished i)) ε
    unconditionedRailScore blocks distinguished r a b y z
      (forcedLastBits blocks distinguished r η y z S) bias S =
      physicalConditionedScore blocks distinguished r a b η ε z bias S := by
  dsimp only
  unfold unconditionedRailScore physicalConditionedScore
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  rw [railBit_forcedLastBits, forcedLastSign_after_reparam]
  change a i * _ + b i *
    (railBit (ε i == selectedBit S (distinguished i)) + _ + _) = _
  rw [railBit_multiply, railBit_selectedBit]

theorem finiteAverage_perm {Ω : Type*} [Fintype Ω] (e : Ω ≃ Ω) (f : Ω → ℝ) :
    finiteAverage (fun ω => f (e ω)) = finiteAverage f := by
  unfold finiteAverage
  rw [Equiv.sum_comp e f]

/-- The product of parity-conditioning factors under the original uniform
opposite-rail law equals the explicit conditional sampler exactly. -/
theorem parity_conditioned_prediction_eq_sampler {ι α : Type*}
    [Fintype ι] [DecidableEq ι] [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α) (r : ι → ℕ)
    (a b : ι → ℝ) (η : ι → Bool) (bias : ℝ) (S : Finset α) :
    finiteAverage (fun y : ι → Bool =>
      finiteAverage (fun z : (i : ι) → Fin (r i) → Bool =>
        finiteAverage (fun last : ι → Bool =>
          parityConditioningWeight blocks distinguished r η y z last S *
            max (unconditionedRailScore blocks distinguished r a b y z last bias S) 0))) =
    finiteAverage (fun ε : ι → Bool =>
      finiteAverage (fun z : (i : ι) → Fin (r i) → Bool =>
        max (physicalConditionedScore blocks distinguished r a b η ε z bias S) 0)) := by
  simp_rw [last_bit_conditioning_exact]
  rw [← finiteAverage_perm (multiplyRailBits (fun i => selectedBit S (distinguished i)))]
  simp_rw [unconditionedRailScore_after_reparam]

/-- The randomized-minimum bound directly under the original independent
uniform rail signs, weighted by the exact parity-class projector. -/
theorem block_constant_randomized_minimum_bound {ι α : Type*}
    [Fintype ι] [Nonempty ι] [DecidableEq ι] [DecidableEq α]
    (selected : Finset α) (n : ℕ) (hcard : selected.card = n + 2)
    (blocks : ι → Finset α) (distinguished : ι → α)
    (hinj : Function.Injective distinguished)
    (hdisjoint : ∀ i j, distinguished i ∉ blocks j)
    (hselected : ∀ i, distinguished i ∈ selected)
    (r : ι → ℕ) (a b : ι → ℝ) (η : ι → Bool) (bias : ℝ)
    (hb : ∀ i, 0 ≤ b i) (hab : ∀ i, b i ≤ a i) :
    |topSubsetCoefficient selected (fun S => finiteAverage (fun y : ι → Bool =>
      finiteAverage (fun z : (i : ι) → Fin (r i) → Bool =>
        finiteAverage (fun last : ι → Bool =>
          parityConditioningWeight blocks distinguished r η y z last S *
            max (unconditionedRailScore blocks distinguished r a b y z last bias S) 0))))| ≤
      (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) *
        finiteAverage (minimumRailAmplitude a b) := by
  simp_rw [parity_conditioned_prediction_eq_sampler]
  exact physical_randomized_minimum_bound selected n hcard blocks distinguished hinj
    hdisjoint hselected r a b η bias hb hab

end NeuralGeneralization.OnlineLowerRelu
