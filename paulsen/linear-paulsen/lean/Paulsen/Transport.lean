import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.SplitIfs

/-!
# Ordered coordinate transport

This file isolates the finite-sum inequality in the elementary quadratic
Paulsen estimate. It does not assume the existence of a radial correction.
-/

namespace Paulsen

open scoped BigOperators

/-- The sum of the first `k` entries of a sequence indexed by `Fin n`. -/
def initialSum {n : ℕ} (a : Fin n → ℝ) (k : ℕ) : ℝ :=
  ∑ i : Fin n, if i.val < k then a i else 0

@[simp] theorem initialSum_zero {n : ℕ} (a : Fin n → ℝ) :
    initialSum a 0 = 0 := by
  simp [initialSum]

@[simp] theorem initialSum_full {n : ℕ} (a : Fin n → ℝ) :
    initialSum a n = ∑ i : Fin n, a i := by
  simp [initialSum, Fin.is_lt]

/-- A zero-sum sequence with one sign change has nonnegative prefix sums. -/
theorem initialSum_nonneg_of_singleCrossing {n : ℕ}
    (a : Fin n → ℝ) (c : ℕ)
    (hsum : ∑ i : Fin n, a i = 0)
    (hleft : ∀ i : Fin n, i.val < c → 0 ≤ a i)
    (hright : ∀ i : Fin n, c ≤ i.val → a i ≤ 0)
    (k : ℕ) :
    0 ≤ initialSum a k := by
  by_cases hk : k ≤ c
  · unfold initialSum
    apply Finset.sum_nonneg
    intro i _
    split_ifs with hi
    · exact hleft i (lt_of_lt_of_le hi hk)
    · exact le_rfl
  · have htail : (∑ i : Fin n, if i.val < k then 0 else a i) ≤ 0 := by
      apply Finset.sum_nonpos
      intro i _
      split_ifs with hi
      · exact le_rfl
      · apply hright i
        exact le_trans (le_of_lt (lt_of_not_ge hk)) (Nat.le_of_not_gt hi)
    have hsplit : initialSum a k +
        (∑ i : Fin n, if i.val < k then 0 else a i) = 0 := by
      calc
        initialSum a k + (∑ i : Fin n, if i.val < k then 0 else a i)
            = ∑ i : Fin n, a i := by
              simp only [initialSum, ← Finset.sum_add_distrib]
              apply Finset.sum_congr rfl
              intro i _
              split_ifs <;> simp
        _ = 0 := hsum
    linarith

/-- The total absolute mass equals twice the mass before the sign change. -/
theorem sum_abs_eq_twice_initialSum {n : ℕ}
    (a : Fin n → ℝ) (c : ℕ)
    (hsum : ∑ i : Fin n, a i = 0)
    (hleft : ∀ i : Fin n, i.val < c → 0 ≤ a i)
    (hright : ∀ i : Fin n, c ≤ i.val → a i ≤ 0) :
    (∑ i : Fin n, |a i|) = 2 * initialSum a c := by
  have hpoint : ∀ i : Fin n,
      |a i| = 2 * (if i.val < c then a i else 0) - a i := by
    intro i
    by_cases hi : i.val < c
    · rw [if_pos hi, abs_of_nonneg (hleft i hi)]
      ring
    · rw [if_neg hi, abs_of_nonpos (hright i (Nat.le_of_not_gt hi))]
      ring
  calc
    (∑ i : Fin n, |a i|)
        = ∑ i : Fin n, (2 * (if i.val < c then a i else 0) - a i) := by
          apply Finset.sum_congr rfl
          intro i _
          exact hpoint i
    _ = 2 * initialSum a c := by
      simp only [Finset.sum_sub_distrib, ← Finset.mul_sum, hsum, sub_zero,
        initialSum]

/-- The absolute mass is bounded by twice the sum of all strict prefixes.
The empty prefix is included, and the full prefix is omitted; both are zero. -/
theorem sum_abs_le_twice_sum_initialSum {n : ℕ}
    (a : Fin n → ℝ) (c : ℕ) (hc : c ≤ n)
    (hsum : ∑ i : Fin n, a i = 0)
    (hleft : ∀ i : Fin n, i.val < c → 0 ≤ a i)
    (hright : ∀ i : Fin n, c ≤ i.val → a i ≤ 0) :
    (∑ i : Fin n, |a i|) ≤
      2 * ∑ k : Fin n, initialSum a k.val := by
  rw [sum_abs_eq_twice_initialSum a c hsum hleft hright]
  apply mul_le_mul_of_nonneg_left _ (by norm_num)
  have hprefix : ∀ k : ℕ, 0 ≤ initialSum a k :=
    initialSum_nonneg_of_singleCrossing a c hsum hleft hright
  by_cases hcn : c < n
  · simpa using
      (Finset.single_le_sum
        (fun k (_ : k ∈ (Finset.univ : Finset (Fin n))) => hprefix k.val)
        (Finset.mem_univ (⟨c, hcn⟩ : Fin n)))
  · have hcn' : c = n := le_antisymm hc (Nat.le_of_not_gt hcn)
    rw [hcn', initialSum_full, hsum]
    exact Finset.sum_nonneg (fun k _ => hprefix k.val)

/-- For two real coordinates of the same sign, squared displacement is
at most the absolute difference of their squared magnitudes. -/
theorem sq_sub_le_abs_sq_sub (x y : ℝ) (hsign : 0 ≤ x * y) :
    (x - y) ^ 2 ≤ |x ^ 2 - y ^ 2| := by
  have hprod : 0 ≤ x * y * (x - y) ^ 2 :=
    mul_nonneg hsign (sq_nonneg (x - y))
  have hsquares : ((x - y) ^ 2) ^ 2 ≤ |x ^ 2 - y ^ 2| ^ 2 := by
    rw [sq_abs]
    nlinarith
  exact (sq_le_sq₀ (sq_nonneg (x - y)) (abs_nonneg (x ^ 2 - y ^ 2))).mp
    hsquares

/-- The coordinate-transport inequality for one row, before summing the
prefix bounds supplied by a nearly Parseval frame. -/
theorem coordinate_transport_bound {n : ℕ}
    (x y : Fin n → ℝ) (c : ℕ) (hc : c ≤ n)
    (hmass : (∑ i : Fin n, (x i) ^ 2) = ∑ i : Fin n, (y i) ^ 2)
    (hsign : ∀ i : Fin n, 0 ≤ x i * y i)
    (hleft : ∀ i : Fin n, i.val < c → (y i) ^ 2 ≤ (x i) ^ 2)
    (hright : ∀ i : Fin n, c ≤ i.val → (x i) ^ 2 ≤ (y i) ^ 2) :
    (∑ i : Fin n, (x i - y i) ^ 2) ≤
      2 * ∑ k : Fin n, initialSum (fun i => (x i) ^ 2 - (y i) ^ 2) k.val := by
  calc
    (∑ i : Fin n, (x i - y i) ^ 2)
        ≤ ∑ i : Fin n, |(x i) ^ 2 - (y i) ^ 2| := by
          apply Finset.sum_le_sum
          intro i _
          exact sq_sub_le_abs_sq_sub (x i) (y i) (hsign i)
    _ ≤ 2 * ∑ k : Fin n,
        initialSum (fun i => (x i) ^ 2 - (y i) ^ 2) k.val := by
          apply sum_abs_le_twice_sum_initialSum _ c hc
          · simpa only [Finset.sum_sub_distrib, sub_eq_zero] using hmass
          · intro i hi
            exact sub_nonneg.mpr (hleft i hi)
          · intro i hi
            exact sub_nonpos.mpr (hright i hi)

/-- Twice the sum of the coordinate indices, expressed without natural
number subtraction on the right-hand side. -/
theorem twice_sum_fin_val (n : ℕ) :
    2 * (∑ i : Fin n, (i.val : ℝ)) = (n : ℝ) * ((n : ℝ) - 1) := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Fin.sum_univ_castSucc]
      simp only [Fin.val_castSucc, Fin.val_last, Nat.cast_succ]
      nlinarith

/-- Sum the coordinate-transport inequalities over rows, assuming the
summed prefix deficit is bounded by `k * η`. This is the finite-sum part
of the bound `η * d * (d - 1)`; existence of the corrected frame and the
prefix-deficit hypotheses are separate mathematical obligations. -/
theorem summed_coordinate_transport_bound {m d : ℕ}
    (x y : Fin m → Fin d → ℝ) (c : Fin m → ℕ) (η : ℝ)
    (hc : ∀ r : Fin m, c r ≤ d)
    (hmass : ∀ r : Fin m,
      (∑ i : Fin d, (x r i) ^ 2) = ∑ i : Fin d, (y r i) ^ 2)
    (hsign : ∀ (r : Fin m) (i : Fin d), 0 ≤ x r i * y r i)
    (hleft : ∀ (r : Fin m) (i : Fin d),
      i.val < c r → (y r i) ^ 2 ≤ (x r i) ^ 2)
    (hright : ∀ (r : Fin m) (i : Fin d),
      c r ≤ i.val → (x r i) ^ 2 ≤ (y r i) ^ 2)
    (hprefix : ∀ k : Fin d,
      (∑ r : Fin m,
        initialSum (fun i => (x r i) ^ 2 - (y r i) ^ 2) k.val) ≤
          (k.val : ℝ) * η) :
    (∑ r : Fin m, ∑ i : Fin d, (x r i - y r i) ^ 2) ≤
      η * (d : ℝ) * ((d : ℝ) - 1) := by
  calc
    (∑ r : Fin m, ∑ i : Fin d, (x r i - y r i) ^ 2)
        ≤ ∑ r : Fin m, 2 * ∑ k : Fin d,
          initialSum (fun i => (x r i) ^ 2 - (y r i) ^ 2) k.val := by
            apply Finset.sum_le_sum
            intro r _
            exact coordinate_transport_bound (x r) (y r) (c r) (hc r)
              (hmass r) (hsign r) (hleft r) (hright r)
    _ = 2 * ∑ k : Fin d, ∑ r : Fin m,
          initialSum (fun i => (x r i) ^ 2 - (y r i) ^ 2) k.val := by
            simp only [Finset.mul_sum]
            exact Finset.sum_comm
    _ ≤ 2 * ∑ k : Fin d, (k.val : ℝ) * η := by
      apply mul_le_mul_of_nonneg_left _ (by norm_num)
      exact Finset.sum_le_sum (fun k _ => hprefix k)
    _ = η * (d : ℝ) * ((d : ℝ) - 1) := by
      rw [← Finset.sum_mul]
      calc
        2 * ((∑ k : Fin d, (k.val : ℝ)) * η)
            = η * (2 * ∑ k : Fin d, (k.val : ℝ)) := by ring
        _ = η * ((d : ℝ) * ((d : ℝ) - 1)) := by rw [twice_sum_fin_val]
        _ = η * (d : ℝ) * ((d : ℝ) - 1) := by ring

end Paulsen
