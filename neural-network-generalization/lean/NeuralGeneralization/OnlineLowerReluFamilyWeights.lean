import NeuralGeneralization.OnlineLowerFamilyAtomCost
import NeuralGeneralization.OnlineLowerReluSynthesisZero

/-! # Exact common scalar weights for the concrete ReLU family

These weights are both the analytic Gamma cost used in strict ordering and
the exact inverse coefficient cost of actual even-support ReLU atoms.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerRelu.Family
open OnlineLower OnlineLowerBernstein

def degreeIndex (R k : ℕ) (s : Finset (Fin (logicalDim k))) : ℕ :=
  ((targetSupport R k s).card - 2) / 2

def weight (R k : ℕ) (s : Finset (Fin (logicalDim k))) : ℝ :=
  gammaCost (targetSupport R k s).card

theorem degreeIndex_card (R k : ℕ) (hR : 2 ≤ R) (heven : Even R)
    (s : Finset (Fin (logicalDim k))) :
    (targetSupport R k s).card = 2 * degreeIndex R k s + 2 := by
  have hn := targetSupport_card_ge_two R k hR s
  obtain ⟨n, hnEven⟩ := targetSupport_even R k heven s
  unfold degreeIndex
  omega

theorem weight_eq_evenReluCost (R k : ℕ) (hR : 2 ≤ R) (heven : Even R)
    (s : Finset (Fin (logicalDim k))) :
    weight R k s = OnlineLowerRelu.evenReluCost (degreeIndex R k s) := by
  unfold weight
  rw [degreeIndex_card R k hR heven s]
  push_cast
  rw [gammaCost_even]
  unfold balancedReluCost OnlineLowerRelu.evenReluCost
  congr 1
  congr 1
  ring

theorem weight_eq_columnCost (R k : ℕ) (s : Finset (Fin (logicalDim k))) :
    weight R k s = gammaCost (columnDegree ((pairDim k * R : ℕ) : ℝ)
      (column k) (fun j => (increment k j : ℝ)) (negativeBitsCube s)) := by
  unfold weight
  rw [support_card_eq_columnDegree]

private theorem reluCost_degree_lower (r : ℕ) :
    2 * (r + 1 : ℝ) ≤ OnlineLowerRelu.evenReluCost r := by
  have hn : 0 ≤ 2 * (r + 1 : ℝ) := by positivity
  have hh := OnlineLowerRelu.evenReluKappa_mul_sqrt_le_one r
  have hm := mul_le_mul_of_nonneg_right hh (Real.sqrt_nonneg (2 * (r + 1 : ℝ)))
  have hs := Real.sq_sqrt hn
  unfold OnlineLowerRelu.evenReluCost
  apply (le_div_iff₀ (OnlineLowerRelu.evenReluKappa_pos r)).mpr
  rw [mul_assoc, ← pow_two, hs, one_mul] at hm
  simpa only [mul_comm] using hm

theorem weight_card_bounds (R k : ℕ) (hR : 2 ≤ R) (heven : Even R)
    (s : Finset (Fin (logicalDim k))) :
    (targetSupport R k s).card ≤ weight R k s ∧
      weight R k s ≤ 3 * (targetSupport R k s).card := by
  rw [weight_eq_evenReluCost R k hR heven s, degreeIndex_card R k hR heven s]
  push_cast
  constructor
  · convert reluCost_degree_lower (degreeIndex R k s) using 1 <;> ring
  · have hh := OnlineLowerRelu.evenReluCost_le_three (degreeIndex R k s)
    linarith

theorem targetSupport_empty_card (R k : ℕ) :
    (targetSupport R k ∅).card = pairDim k * R := by
  unfold targetSupport
  rw [support_card]
  simp

theorem weight_pos (R k : ℕ) (hR : 2 ≤ R) (heven : Even R)
    (s : Finset (Fin (logicalDim k))) : 0 < weight R k s := by
  have hcard := targetSupport_card_ge_two R k hR s
  have hh := (weight_card_bounds R k hR heven s).1
  have hc : (0 : ℝ) < (targetSupport R k s).card := Nat.cast_pos.mpr (by omega)
  exact hc.trans_le hh

theorem weight_empty_le (R k : ℕ) (hR : 2 ≤ R) (heven : Even R)
    (s : Finset (Fin (logicalDim k))) : weight R k ∅ ≤ weight R k s := by
  rw [weight_eq_evenReluCost R k hR heven ∅, weight_eq_evenReluCost R k hR heven s]
  apply OnlineLowerRelu.evenReluCost_monotone
  have hh := (support_card_bounds R k s).1
  change pairDim k * R ≤ (targetSupport R k s).card at hh
  rw [← targetSupport_empty_card] at hh
  unfold degreeIndex
  exact Nat.div_le_div_right (Nat.sub_le_sub_right hh 2)

/-- The weights vary by a factor less than six already at rail size four.
The online construction uses a much larger fixed rail size. -/
theorem weight_le_six_base (R k : ℕ) (hR : 4 ≤ R) (heven : Even R)
    (s : Finset (Fin (logicalDim k))) : weight R k s ≤ 6 * weight R k ∅ := by
  have hs := (weight_card_bounds R k (by omega) heven s).2
  have hb := (weight_card_bounds R k (by omega) heven ∅).1
  rw [targetSupport_empty_card] at hb
  have hc := (support_card_bounds R k s).2
  change (targetSupport R k s).card ≤ pairDim k * (R + 4) at hc
  have hcR : ((targetSupport R k s).card : ℝ) ≤ (pairDim k : ℝ) * (R + 4) := by exact_mod_cast hc
  have hRr : (4 : ℝ) ≤ R := by exact_mod_cast hR
  have hp : (0 : ℝ) ≤ pairDim k := Nat.cast_nonneg _
  have hbR : (pairDim k : ℝ) * (R : ℝ) ≤ weight R k ∅ := by exact_mod_cast hb
  nlinarith [mul_nonneg hp (by linarith : 0 ≤ (R : ℝ) - 4)]

theorem six_base_le_sum_weights (R k : ℕ) (hR : 2 ≤ R) (heven : Even R) :
    6 * weight R k ∅ ≤ ∑ s, weight R k s := by
  have hh := Finset.sum_le_sum (fun s (_ : s ∈ Finset.univ) => weight_empty_le R k hR heven s)
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul] at hh
  have hcard : 6 ≤ Fintype.card (Finset (Fin (logicalDim k))) := by
    rw [Fintype.card_finset, Fintype.card_fin]
    have hp : (2 : ℕ) ^ 4 ≤ 2 ^ logicalDim k := Nat.pow_le_pow_right (by norm_num) (by rw [logicalDim_eq]; omega)
    exact (by norm_num : (6 : ℕ) ≤ 2 ^ 4).trans hp
  have hcardR : (6 : ℝ) ≤ Fintype.card (Finset (Fin (logicalDim k))) := by exact_mod_cast hcard
  exact (mul_le_mul_of_nonneg_right hcardR (weight_pos R k hR heven ∅).le).trans hh

end NeuralGeneralization.OnlineLowerRelu.Family
