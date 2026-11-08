import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Strict separation of finite signed geometric expansions

The triangular path construction produces these expansions with a ratio in
`(0,1/3]`. This file checks their injectivity, independently of the analytic
realization of that ratio by the tanh code's transfer matrices.
-/

namespace NeuralGeneralization.OnlineLower

def digitSign (b : Bool) : ℝ := if b then 1 else -1

def signedSeries (r : ℝ) : List Bool → ℝ
  | [] => 0
  | b :: bs => digitSign b + r * signedSeries r bs

theorem abs_digitSign (b : Bool) : |digitSign b| = 1 := by
  cases b <;> norm_num [digitSign]

theorem signedSeries_abs_le (r : ℝ) (hr0 : 0 ≤ r) (hr : r ≤ 1 / 3)
    (bs : List Bool) : |signedSeries r bs| ≤ 3 / 2 := by
  induction bs with
  | nil => norm_num [signedSeries]
  | cons b bs ih =>
    calc
      |signedSeries r (b :: bs)|
          ≤ |digitSign b| + |r * signedSeries r bs| := abs_add_le _ _
      _ = 1 + r * |signedSeries r bs| := by rw [abs_digitSign, abs_mul, abs_of_nonneg hr0]
      _ ≤ 1 + r * (3 / 2) := add_le_add le_rfl (mul_le_mul_of_nonneg_left ih hr0)
      _ ≤ 3 / 2 := by linarith

theorem signedSeries_cons_ne_zero (r : ℝ) (hr0 : 0 ≤ r) (hr : r ≤ 1 / 3)
    (b : Bool) (bs : List Bool) : signedSeries r (b :: bs) ≠ 0 := by
  have h := signedSeries_abs_le r hr0 hr bs
  have hlo := (abs_le.mp h).1
  have hhi := (abs_le.mp h).2
  have hprodlo := mul_le_mul_of_nonneg_left hlo hr0
  have hprodhi := mul_le_mul_of_nonneg_left hhi hr0
  cases b <;> simp only [signedSeries, digitSign, Bool.false_eq_true, if_false, if_true]
    <;> intro he <;> nlinarith

/-- All finite signed expansions are distinct. In particular, restricting to
lists of length `k` gives `2^k` different values. -/
theorem signedSeries_injective (r : ℝ) (hr0 : 0 < r) (hr : r ≤ 1 / 3) :
    Function.Injective (signedSeries r) := by
  intro xs
  induction xs with
  | nil =>
    intro ys he
    cases ys with
    | nil => rfl
    | cons b bs =>
      exact False.elim (signedSeries_cons_ne_zero r hr0.le hr b bs he.symm)
  | cons a xs ih =>
    intro ys he
    cases ys with
    | nil => exact False.elim (signedSeries_cons_ne_zero r hr0.le hr a xs he)
    | cons b ys =>
      have hx := abs_le.mp (signedSeries_abs_le r hr0.le hr xs)
      have hy := abs_le.mp (signedSeries_abs_le r hr0.le hr ys)
      have hab : a = b := by
        by_contra hne
        have hxlo := mul_le_mul_of_nonneg_left hx.1 hr0.le
        have hxhi := mul_le_mul_of_nonneg_left hx.2 hr0.le
        have hylo := mul_le_mul_of_nonneg_left hy.1 hr0.le
        have hyhi := mul_le_mul_of_nonneg_left hy.2 hr0.le
        cases a <;> cases b <;> simp_all [signedSeries, digitSign] <;> nlinarith
      subst b
      have ht : signedSeries r xs = signedSeries r ys := by
        simp only [signedSeries] at he
        exact (mul_left_cancel₀ hr0.ne') (add_left_cancel he)
      exact congrArg (List.cons a) (ih ht)

end NeuralGeneralization.OnlineLower
