import Mathlib.Data.Real.Basic
import Mathlib.Data.Nat.Choose.Basic
import Mathlib.Data.Fintype.Powerset
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.SplitIfs

/-!
# Exact finite binomial identities for the online ReLU lower bound

These are scalar lemmas used by the sharp monotone parity estimate. They do
not assert the neural atomic inequality or the online lower-bound theorem.
-/

noncomputable section

namespace NeuralGeneralization.OnlineLowerRelu

open scoped BigOperators

/-- The unnormalized alternating binomial transform. -/
def alternatingBinomial (n : ℕ) (f : ℕ → ℝ) : ℝ :=
  ∑ k ∈ Finset.range (n + 1), (-1 : ℝ) ^ k * (n.choose k : ℝ) * f k

/-- Exact partial alternating sum, including prefixes beyond the support. -/
theorem alternating_binomial_prefix (n r : ℕ) :
    (∑ k ∈ Finset.range (r + 1), (-1 : ℝ) ^ k * ((n + 1).choose k : ℝ)) =
      (-1 : ℝ) ^ r * (n.choose r : ℝ) := by
  induction r with
  | zero => simp
  | succ r ih =>
      rw [Finset.sum_range_succ, ih]
      simp only [Nat.choose_succ_succ, Nat.cast_add, pow_succ]
      ring

/-- Pascal's identity is the exact discrete integration-by-parts formula. -/
theorem alternatingBinomial_succ (n : ℕ) (f : ℕ → ℝ) :
    alternatingBinomial (n + 1) f =
      alternatingBinomial n (fun k => f k - f (k + 1)) := by
  classical
  have hshift : alternatingBinomial n f = f 0 +
      ∑ k ∈ Finset.range (n + 1),
        (-1 : ℝ) ^ (k + 1) * (n.choose (k + 1) : ℝ) * f (k + 1) := by
    have hext : alternatingBinomial n f =
        ∑ k ∈ Finset.range (n + 2), (-1 : ℝ) ^ k * (n.choose k : ℝ) * f k := by
      rw [show n + 2 = (n + 1) + 1 by omega, Finset.sum_range_succ]
      simp [alternatingBinomial]
    rw [hext, Finset.sum_range_succ']
    simp [add_comm]
  unfold alternatingBinomial at hshift ⊢
  rw [Finset.sum_range_succ']
  simp only [pow_zero, Nat.choose_zero_right, Nat.cast_one, mul_one, one_mul]
  simp_rw [Nat.choose_succ_succ, Nat.cast_add, mul_add, add_mul]
  rw [Finset.sum_add_distrib]
  simp_rw [pow_succ]
  have hsum : (∑ k ∈ Finset.range (n + 1),
      (-1 : ℝ) ^ k * (n.choose k : ℝ) * (f k - f (k + 1))) =
      (∑ k ∈ Finset.range (n + 1), (-1 : ℝ) ^ k * (n.choose k : ℝ) * f k) -
      ∑ k ∈ Finset.range (n + 1), (-1 : ℝ) ^ k * (n.choose k : ℝ) * f (k + 1) := by
    simp_rw [mul_sub]
    rw [Finset.sum_sub_distrib]
  rw [hsum]
  simp_rw [pow_succ, mul_neg_one, neg_mul] at hshift ⊢
  simp only [Finset.sum_neg_distrib] at hshift ⊢
  linarith

/-- A monotone layer profile is controlled by the largest previous-row
binomial coefficient times its total variation. This statement keeps the
coefficient cap explicit; specializing it to the central coefficient is the
sharp monotone parity bound. -/
theorem alternatingBinomial_abs_le_of_monotone
    (n : ℕ) (f : ℕ → ℝ) (M : ℝ)
    (hmono : ∀ k < n + 1, f k ≤ f (k + 1))
    (hcap : ∀ k < n + 1, (n.choose k : ℝ) ≤ M) :
    |alternatingBinomial (n + 1) f| ≤ M * (f (n + 1) - f 0) := by
  rw [alternatingBinomial_succ]
  unfold alternatingBinomial
  calc
    |∑ k ∈ Finset.range (n + 1),
        (-1 : ℝ) ^ k * (n.choose k : ℝ) * (f k - f (k + 1))| ≤
        ∑ k ∈ Finset.range (n + 1),
        |(-1 : ℝ) ^ k * (n.choose k : ℝ) * (f k - f (k + 1))| :=
      Finset.abs_sum_le_sum_abs _ _
    _ = ∑ k ∈ Finset.range (n + 1),
        (n.choose k : ℝ) * (f (k + 1) - f k) := by
      apply Finset.sum_congr rfl
      intro k hk
      have hstep := hmono k (Finset.mem_range.mp hk)
      rw [abs_mul, abs_mul, abs_pow]
      simp only [abs_neg, abs_one, one_pow, one_mul, Nat.abs_cast]
      rw [abs_of_nonpos (sub_nonpos.mpr hstep)]
      ring
    _ ≤ ∑ k ∈ Finset.range (n + 1), M * (f (k + 1) - f k) := by
      apply Finset.sum_le_sum
      intro k hk
      exact mul_le_mul_of_nonneg_right (hcap k (Finset.mem_range.mp hk))
        (sub_nonneg.mpr (hmono k (Finset.mem_range.mp hk)))
    _ = M * (f (n + 1) - f 0) := by
      rw [← Finset.mul_sum, Finset.sum_range_sub]

/-- The central binomial coefficient is the sharp coefficient cap. -/
theorem alternatingBinomial_abs_le_middle
    (n : ℕ) (f : ℕ → ℝ)
    (hmono : ∀ k < n + 1, f k ≤ f (k + 1)) :
    |alternatingBinomial (n + 1) f| ≤
      (n.choose (n / 2) : ℝ) * (f (n + 1) - f 0) := by
  apply alternatingBinomial_abs_le_of_monotone n f _ hmono
  intro k _
  exact_mod_cast Nat.choose_le_middle k n

/-- Sharp alternating-binomial bound for an increasing profile in `[0,1]`. -/
theorem alternatingBinomial_abs_le_middle_of_unit_interval
    (n : ℕ) (f : ℕ → ℝ)
    (hmono : ∀ k < n + 1, f k ≤ f (k + 1))
    (hzero : 0 ≤ f 0) (hone : f (n + 1) ≤ 1) :
    |alternatingBinomial (n + 1) f| ≤ (n.choose (n / 2) : ℝ) := by
  have h := alternatingBinomial_abs_le_middle n f hmono
  have hc : (0 : ℝ) ≤ (n.choose (n / 2) : ℝ) := Nat.cast_nonneg _
  nlinarith

/-- Exact centered ReLU finite difference on its even Hamming grid. -/
theorem relu_hamming_grid_difference (r k : ℕ) :
    max ((2 : ℝ) * (r + 1) - 2 * k) 0 -
      max ((2 : ℝ) * (r + 1) - 2 * (k + 1)) 0 =
        if k ≤ r then 2 else 0 := by
  by_cases h : k ≤ r
  · rw [if_pos h]
    have hh : (k : ℝ) ≤ r := by exact_mod_cast h
    rw [max_eq_left (by linarith), max_eq_left (by linarith)]
    ring
  · rw [if_neg h]
    have hh : (r : ℝ) + 1 ≤ k := by exact_mod_cast (by omega : r + 1 ≤ k)
    rw [max_eq_right (by linarith), max_eq_right (by linarith)]
    ring

/-- The exact unnormalized parity coefficient of a balanced even-degree ReLU
ridge, written on Hamming levels. -/
theorem balanced_relu_alternatingBinomial (r : ℕ) :
    alternatingBinomial (2 * r + 2)
      (fun k => max ((2 : ℝ) * (r + 1) - 2 * k) 0) =
      2 * (-1 : ℝ) ^ r * ((2 * r).choose r : ℝ) := by
  rw [show 2 * r + 2 = (2 * r + 1) + 1 by omega,
    alternatingBinomial_succ]
  unfold alternatingBinomial
  simp only [Nat.cast_add, Nat.cast_one]
  simp_rw [relu_hamming_grid_difference, mul_ite, mul_zero]
  rw [← Finset.sum_filter]
  have hfilter : (Finset.range (2 * r + 1 + 1)).filter (fun k => k ≤ r) =
      Finset.range (r + 1) := by
    ext k
    simp only [Finset.mem_filter, Finset.mem_range]
    omega
  rw [hfilter, ← Finset.sum_mul, alternating_binomial_prefix]
  ring

/-- Grouping a symmetric Boolean-cube function by Hamming level. Inputs are
represented by the finite set of coordinates whose signs are negative. -/
theorem subset_parity_sum_eq_alternatingBinomial (n : ℕ) (f : ℕ → ℝ) :
    (∑ S : Finset (Fin n), (-1 : ℝ) ^ S.card * f S.card) =
      alternatingBinomial n f := by
  classical
  have hgroup (g : ℕ → ℝ) (x : Finset (Fin n)) :
      ∑ S ∈ x.powerset, g S.card =
        ∑ k ∈ Finset.range (x.card + 1), x.card.choose k • g k := by
    trans ∑ k ∈ Finset.range (x.card + 1),
      ∑ S ∈ x.powerset.filter (fun S => S.card = k), g S.card
    · refine (Finset.sum_fiberwise_of_maps_to ?_ _).symm
      intro S hS
      rw [Finset.mem_range, Nat.lt_succ_iff]
      exact Finset.card_le_card (Finset.mem_powerset.mp hS)
    · apply Finset.sum_congr rfl
      intro k _
      rw [← Finset.card_powersetCard, ← Finset.sum_const]
      refine Finset.sum_congr Finset.powersetCard_eq_filter.symm ?_
      intro S hS
      rw [(Finset.mem_powersetCard.mp hS).2]
  have h := hgroup (fun k => (-1 : ℝ) ^ k * f k) Finset.univ
  simp only [Finset.powerset_univ, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul] at h
  rw [h]
  unfold alternatingBinomial
  apply Finset.sum_congr rfl
  intro k _
  ring

/-- Exact parity coefficient of the balanced ReLU neuron on `2r+2` inputs. -/
theorem balanced_relu_subset_parity (r : ℕ) :
    (∑ S : Finset (Fin (2 * r + 2)), (-1 : ℝ) ^ S.card *
      max ((2 : ℝ) * (r + 1) - 2 * S.card) 0) /
        (2 : ℝ) ^ (2 * r + 2) =
      (-1 : ℝ) ^ r * ((2 * r).choose r : ℝ) / (2 : ℝ) ^ (2 * r + 1) := by
  rw [subset_parity_sum_eq_alternatingBinomial (2 * r + 2)
    (fun k => max ((2 : ℝ) * (r + 1) - 2 * k) 0),
    balanced_relu_alternatingBinomial]
  rw [show 2 * r + 2 = (2 * r + 1) + 1 by omega, pow_succ]
  field_simp

/-- The unnormalized centered finite difference of ReLU. -/
def reluDifference (a t : ℝ) : ℝ := max (t + a) 0 - max (t - a) 0

theorem reluDifference_eq_clip {a : ℝ} (ha : 0 ≤ a) (t : ℝ) :
    reluDifference a t = min (2 * a) (max (t + a) 0) := by
  unfold reluDifference
  simp only [max_def, min_def]
  split_ifs <;> linarith

theorem reluDifference_nonneg {a : ℝ} (ha : 0 ≤ a) (t : ℝ) :
    0 ≤ reluDifference a t := by
  rw [reluDifference_eq_clip ha]
  exact le_min (by linarith) (le_max_right _ _)

theorem reluDifference_le {a : ℝ} (ha : 0 ≤ a) (t : ℝ) :
    reluDifference a t ≤ 2 * a := by
  rw [reluDifference_eq_clip ha]
  exact min_le_left _ _

theorem reluDifference_monotone {a : ℝ} (ha : 0 ≤ a) :
    Monotone (reluDifference a) := by
  intro s t hst
  rw [reluDifference_eq_clip ha, reluDifference_eq_clip ha]
  exact min_le_min_left _ (max_le_max (by linarith : s + a ≤ t + a) le_rfl)

/-- Integrating one Boolean input out of a ReLU neuron produces a monotone
function with values in `[0,1]`, after division by twice its positive weight. -/
theorem normalized_reluDifference_properties {a : ℝ} (ha : 0 < a) :
    Monotone (fun t => reluDifference a t / (2 * a)) ∧
    ∀ t, 0 ≤ reluDifference a t / (2 * a) ∧
      reluDifference a t / (2 * a) ≤ 1 := by
  constructor
  · intro s t hst
    exact div_le_div_of_nonneg_right (reluDifference_monotone ha.le hst)
      (mul_nonneg (by norm_num) ha.le)
  · intro t
    constructor
    · exact div_nonneg (reluDifference_nonneg ha.le t) (mul_nonneg (by norm_num) ha.le)
    · apply (div_le_one (mul_pos (by norm_num) ha : (0 : ℝ) < 2 * a)).mpr
      exact reluDifference_le ha.le t

end NeuralGeneralization.OnlineLowerRelu
