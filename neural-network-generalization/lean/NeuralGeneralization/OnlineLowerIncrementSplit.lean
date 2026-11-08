import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Algebra.Group.Nat.Even
import Mathlib.Tactic

/-! # Exact splitting of a large even increment into bounded even pieces -/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

def splitCount (H R : ℕ) : ℕ := H / R + if H % R = 0 then 0 else 1

def splitIncrement (H R : ℕ) (j : Fin (splitCount H R)) : ℕ :=
  if j.val < H / R then R else H % R

theorem splitCount_pos (H R : ℕ) (hH : 0 < H) (hR : 0 < R) : 0 < splitCount H R := by
  by_cases hz : H % R = 0
  · have hq : 0 < H / R := Nat.div_pos (Nat.le_of_dvd hH (Nat.dvd_of_mod_eq_zero hz)) hR
    simpa [splitCount, hz] using hq
  · simp [splitCount, hz]

theorem splitCount_le (H R : ℕ) : splitCount H R ≤ H / R + 1 := by
  unfold splitCount
  split_ifs <;> omega

theorem splitIncrement_pos (H R : ℕ) (hR : 0 < R) (j : Fin (splitCount H R)) :
    0 < splitIncrement H R j := by
  unfold splitIncrement
  split_ifs with hj
  · exact hR
  · have hlt := j.isLt
    unfold splitCount at hlt
    split_ifs at hlt <;> omega

theorem splitIncrement_le (H R : ℕ) (hR : 0 < R) (j : Fin (splitCount H R)) :
    splitIncrement H R j ≤ R := by
  unfold splitIncrement
  split_ifs
  · exact le_rfl
  · exact (Nat.mod_lt H hR).le

theorem splitIncrement_even (H R : ℕ) (hH : Even H) (hR : Even R)
    (j : Fin (splitCount H R)) : Even (splitIncrement H R j) := by
  unfold splitIncrement
  split_ifs
  · exact hR
  · have hsum : Even (H % R + R * (H / R)) := by rw [Nat.mod_add_div]; exact hH
    exact (Nat.even_add.mp hsum).mpr (hR.mul_right _)

theorem splitIncrement_sum (H R : ℕ) : (∑ j, splitIncrement H R j) = H := by
  have hdiv := Nat.mod_add_div H R
  by_cases hzero : H % R = 0
  · have hc : splitCount H R = H / R := by simp [splitCount, hzero]
    have he (j : Fin (splitCount H R)) : splitIncrement H R j = R := by
      unfold splitIncrement
      rw [if_pos]
      simpa [hc] using j.isLt
    simp only [he, Finset.sum_const, Finset.card_univ, Fintype.card_fin, smul_eq_mul, hc]
    simpa [hzero, Nat.mul_comm] using hdiv
  · have hc : splitCount H R = H / R + 1 := by simp [splitCount, hzero]
    change (∑ j : Fin (splitCount H R), if j.val < H / R then R else H % R) = H
    rw [Fin.sum_univ_eq_sum_range (fun j : ℕ => if j < H / R then R else H % R)]
    rw [hc, Finset.sum_range_succ]
    have hs : (∑ j ∈ Finset.range (H / R), if j < H / R then R else H % R) = (H / R) * R := by
      calc
        _ = ∑ _j ∈ Finset.range (H / R), R :=
          Finset.sum_congr rfl (fun j hj => if_pos (Finset.mem_range.mp hj))
        _ = _ := by simp
    rw [hs, if_neg (Nat.lt_irrefl _)]
    simpa [Nat.mul_comm, Nat.add_comm] using hdiv

end NeuralGeneralization.OnlineLowerTanh
