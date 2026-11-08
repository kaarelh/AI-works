import NeuralGeneralization.OnlineLowerReluConditioning
import NeuralGeneralization.OnlineLowerReluSubcube
import NeuralGeneralization.OnlineLowerReluCubeSigns

/-! # Concrete selected-bit scores after conditioning opposite-rail parities -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

def conditionedSelectedScore {ι α : Type*} [Fintype ι] [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α)
    (a c d : ι → ℝ) (bias : ℝ) (S : Finset α) : ℝ :=
  conditionedBlockScore blocks a c bias S +
    ∑ i, if distinguished i ∈ S then 2 * d i else 0

theorem conditionedSelectedScore_monotone {ι α : Type*}
    [Fintype ι] [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α)
    (a c d : ι → ℝ) (bias : ℝ)
    (hc : ∀ i, |c i| ≤ a i) (hd : ∀ i, 0 ≤ d i) :
    Monotone (conditionedSelectedScore blocks distinguished a c d bias) := by
  intro S T hST
  have hblocks := conditionedBlockScore_monotone blocks a c bias hc hST
  have hsum : (∑ i, if distinguished i ∈ S then 2 * d i else 0) ≤
      ∑ i, if distinguished i ∈ T then 2 * d i else 0 := by
    apply Finset.sum_le_sum
    intro i _
    by_cases hi : distinguished i ∈ S
    · rw [if_pos hi, if_pos (hST hi)]
    · rw [if_neg hi]
      split_ifs <;> nlinarith [hd i]
  unfold conditionedSelectedScore
  linarith

theorem conditionedSelectedScore_insert {ι α : Type*}
    [Fintype ι] [DecidableEq α]
    (blocks : ι → Finset α) (distinguished : ι → α)
    (hinj : Function.Injective distinguished)
    (hdisjoint : ∀ i j, distinguished i ∉ blocks j)
    (a c d : ι → ℝ) (bias : ℝ) (i : ι) (S : Finset α)
    (hiS : distinguished i ∉ S) :
    conditionedSelectedScore blocks distinguished a c d bias (insert (distinguished i) S) =
      conditionedSelectedScore blocks distinguished a c d bias S + 2 * d i := by
  classical
  have hblocks : conditionedBlockScore blocks a c bias (insert (distinguished i) S) =
      conditionedBlockScore blocks a c bias S := by
    unfold conditionedBlockScore
    simp_rw [Finset.insert_inter_of_notMem (hdisjoint i _)]
  have hterm (j : ι) :
      (if distinguished j ∈ insert (distinguished i) S then 2 * d j else 0) =
        (if distinguished j ∈ S then 2 * d j else 0) +
          if j = i then 2 * d i else 0 := by
    by_cases hji : j = i
    · subst j
      simp [hiS]
    · have he : distinguished j ≠ distinguished i := fun h => hji (hinj h)
      simp [Finset.mem_insert, he, hji]
  unfold conditionedSelectedScore
  rw [hblocks]
  simp_rw [hterm]
  rw [Finset.sum_add_distrib]
  simp
  <;> ring

theorem randomized_distinguished_coefficient_nonneg {ι : Type*}
    (a b : ι → ℝ) (hab : ∀ i, b i ≤ a i) (hb : ∀ i, 0 ≤ b i)
    (ε : ι → Bool) (i : ι) : 0 ≤ a i + railBit (ε i) * b i := by
  cases ε i <;> simp only [railBit, Bool.false_eq_true, ↓reduceIte,
    neg_mul, one_mul] <;> linarith [hab i, hb i]

/-- Every distinguished coordinate yields the sharp coefficient bound for
the concrete parity-conditioned selected score. -/
theorem conditioned_selected_parity_bound {ι α : Type*}
    [Fintype ι] [DecidableEq α]
    (selected : Finset α) (n : ℕ) (hcard : selected.card = n + 2)
    (blocks : ι → Finset α) (distinguished : ι → α)
    (hinj : Function.Injective distinguished)
    (hdisjoint : ∀ i j, distinguished i ∉ blocks j)
    (hselected : ∀ i, distinguished i ∈ selected)
    (a c d : ι → ℝ) (bias : ℝ)
    (hc : ∀ i, |c i| ≤ a i) (hd : ∀ i, 0 ≤ d i) (i : ι) :
    |(∑ S ∈ selected.powerset, (-1 : ℝ) ^ S.card *
        max (conditionedSelectedScore blocks distinguished a c d bias S) 0) /
        (2 : ℝ) ^ (n + 2)| ≤
      d i * (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) := by
  have herase : (selected.erase (distinguished i)).card = n + 1 := by
    rw [Finset.card_erase_of_mem (hselected i), hcard]
    omega
  have h := subcube_relu_parity_bound (selected.erase (distinguished i))
    (distinguished i) (Finset.notMem_erase _ _) n herase
    (conditionedSelectedScore blocks distinguished a c d bias)
    (conditionedSelectedScore_monotone blocks distinguished a c d bias hc hd)
    (d i) (hd i) (fun S hS => conditionedSelectedScore_insert blocks distinguished
      hinj hdisjoint a c d bias i S (fun hi => (Finset.mem_erase.mp (hS hi)).1 rfl))
  simpa only [Finset.insert_erase (hselected i)] using h

end NeuralGeneralization.OnlineLowerRelu
