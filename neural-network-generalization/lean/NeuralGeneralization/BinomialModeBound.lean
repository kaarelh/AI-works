import Mathlib.Data.Nat.Choose.Sum
import Mathlib.Data.Real.Basic
import Mathlib.Order.SuccPred.Archimedean
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum

/-! The elementary binomial mode bound at odds `j/(D-j)`. -/
noncomputable section
namespace NeuralGeneralization.BinomialMode
open scoped BigOperators

def term (D k : ℕ) (t : ℝ) : ℝ := (D.choose k:ℝ)*t^k

theorem term_nonneg (D k : ℕ) (t : ℝ) (ht : 0 ≤ t) : 0 ≤ term D k t := by
  unfold term
  positivity

theorem term_step (D k : ℕ) (t : ℝ) :
    (k+1:ℝ)*term D (k+1) t = (D-k:ℕ)*t*term D k t := by
  have hc : (D.choose (k+1):ℝ)*(k+1:ℝ) = (D.choose k:ℝ)*(D-k:ℕ) := by
    exact_mod_cast Nat.choose_succ_right_eq D k
  unfold term
  rw [pow_succ]
  have hh := congrArg (fun x : ℝ => x*(t^k*t)) hc
  nlinarith only [hh]

theorem term_le_next_of_lt {D j k : ℕ} (hj : j < D) (hk : k < j) :
    term D k ((j:ℝ)/(D-j:ℕ)) ≤ term D (k+1) ((j:ℝ)/(D-j:ℕ)) := by
  let t : ℝ := (j:ℝ)/(D-j:ℕ)
  have hden : (0:ℝ)<(D-j:ℕ) := by exact_mod_cast Nat.sub_pos_of_lt hj
  have ht : 0 ≤ t := by unfold t; positivity
  have hratio : (k+1:ℝ) ≤ (D-k:ℕ)*t := by
    unfold t
    rw [← mul_div_assoc]
    apply (le_div_iff₀ hden).mpr
    rw [Nat.cast_sub (le_of_lt hj), Nat.cast_sub (hk.le.trans hj.le)]
    have hjk : (k+1:ℝ)≤j := by exact_mod_cast hk
    have hD : (0:ℝ)≤D := Nat.cast_nonneg D
    have hh := mul_le_mul_of_nonneg_right hjk hD
    nlinarith only [hh, Nat.cast_nonneg j (α:=ℝ)]
  have hh := mul_le_mul_of_nonneg_right hratio (term_nonneg D k t ht)
  rw [← term_step] at hh
  exact (mul_le_mul_iff_right₀ (by positivity : (0:ℝ)<k+1)).mp hh

theorem next_term_le_of_le {D j k : ℕ} (hj : j < D) (hk : j ≤ k) :
    term D (k+1) ((j:ℝ)/(D-j:ℕ)) ≤ term D k ((j:ℝ)/(D-j:ℕ)) := by
  let t : ℝ := (j:ℝ)/(D-j:ℕ)
  have ht : 0 ≤ t := by unfold t; positivity
  by_cases hkD : k < D
  · have hden : (0:ℝ)<(D-j:ℕ) := by exact_mod_cast Nat.sub_pos_of_lt hj
    have hratio : (D-k:ℕ)*t ≤ (k+1:ℝ) := by
      unfold t
      rw [← mul_div_assoc]
      apply (div_le_iff₀ hden).mpr
      rw [Nat.cast_sub hj.le, Nat.cast_sub hkD.le]
      have hjk : (j:ℝ)≤k := by exact_mod_cast hk
      have hjD : (j:ℝ)≤D := by exact_mod_cast hj.le
      have hh := mul_le_mul_of_nonneg_right hjk (Nat.cast_nonneg D (α:=ℝ))
      nlinarith only [hh, hjD]
    have hh := mul_le_mul_of_nonneg_right hratio (term_nonneg D k t ht)
    rw [← term_step] at hh
    exact (mul_le_mul_iff_right₀ (by positivity : (0:ℝ)<k+1)).mp hh
  · have hz : D.choose (k+1)=0 := Nat.choose_eq_zero_of_lt (by omega)
    simpa only [term, hz, Nat.cast_zero, zero_mul] using term_nonneg D k t ht

theorem term_le_mode {D j : ℕ} (hj : j < D) (k : ℕ) :
    term D k ((j:ℝ)/(D-j:ℕ)) ≤ term D j ((j:ℝ)/(D-j:ℕ)) := by
  by_cases hkj : k ≤ j
  · have hm : MonotoneOn (fun k => term D k ((j:ℝ)/(D-j:ℕ))) (Set.Iic j) := by
      apply monotoneOn_of_le_succ Set.ordConnected_Iic
      intro l _ hl hls
      exact term_le_next_of_lt hj (by exact Nat.lt_of_succ_le hls)
    exact hm hkj (by simp) hkj
  · have ha : AntitoneOn (fun k => term D k ((j:ℝ)/(D-j:ℕ))) (Set.Ici j) :=
      antitoneOn_nat_Ici_of_succ_le (fun l hl => next_term_le_of_le hj hl)
    exact ha (by simp) (le_of_not_ge hkj) (le_of_not_ge hkj)

/-- The modal term is at least the average of the `D+1` binomial terms. -/
theorem modal_mass_lower {D j : ℕ} (hj : j < D) :
    (1+(j:ℝ)/(D-j:ℕ))^D ≤
      (D+1:ℝ)*(D.choose j:ℝ)*((j:ℝ)/(D-j:ℕ))^j := by
  have hs := Finset.sum_le_sum (fun k (_ : k ∈ Finset.range (D+1)) => term_le_mode hj k)
  have he : (∑ k ∈ Finset.range (D+1), term D k ((j:ℝ)/(D-j:ℕ))) =
      (1+(j:ℝ)/(D-j:ℕ))^D := by
    rw [add_comm (1:ℝ) ((j:ℝ)/(D-j:ℕ)), add_pow]
    apply Finset.sum_congr rfl
    intro k hk
    simp only [term, one_pow, mul_one]
    ring
  rw [he] at hs
  simpa only [Finset.sum_const, Finset.card_range, nsmul_eq_mul, Nat.cast_add, Nat.cast_one,
    term, mul_assoc] using hs

end NeuralGeneralization.BinomialMode
