import NeuralGeneralization.OnlineLowerReluKappa
import Mathlib.Analysis.Real.Sqrt
import Mathlib.Tactic.Positivity.Basic

/-! # Uniform scalar cost variation along even ReLU parity degrees -/

noncomputable section

namespace NeuralGeneralization.OnlineLowerRelu

def evenReluCost (r : ℕ) : ℝ := Real.sqrt (2 * (r + 1 : ℝ)) / evenReluKappa r

theorem evenReluKappa_lower_square (r : ℕ) :
    1 ≤ 4 * (4 * (r : ℝ) + 1) * evenReluKappa r ^ 2 := by
  induction r with
  | zero => norm_num [evenReluKappa]
  | succ r ih =>
      have hr := evenReluKappa_recurrence r
      have hrsq : (2 * ((r : ℝ) + 1)) ^ 2 * evenReluKappa (r + 1) ^ 2 =
          (2 * (r : ℝ) + 1) ^ 2 * evenReluKappa r ^ 2 := by
        nlinarith [congrArg (fun z : ℝ => z ^ 2) hr]
      have hidentity :
          (2 * ((r : ℝ) + 1)) ^ 2 *
            (4 * (4 * (r : ℝ) + 5) * evenReluKappa (r + 1) ^ 2 - 1) =
          (2 * ((r : ℝ) + 1)) ^ 2 *
            (4 * (4 * (r : ℝ) + 1) * evenReluKappa r ^ 2 - 1) +
              4 * evenReluKappa r ^ 2 := by
        nlinarith [congrArg (fun z : ℝ => z * (4 * (4 * (r : ℝ) + 5))) hrsq]
      have hnonneg : 0 ≤ (2 * ((r : ℝ) + 1)) ^ 2 *
          (4 * (4 * (r : ℝ) + 5) * evenReluKappa (r + 1) ^ 2 - 1) := by
        rw [hidentity]
        exact add_nonneg (mul_nonneg (sq_nonneg _) (by linarith)) (by positivity)
      have hp : 0 < (2 * ((r : ℝ) + 1)) ^ 2 := by positivity
      have h := (mul_nonneg_iff_of_pos_left hp).mp hnonneg
      simp only [Nat.cast_add, Nat.cast_one]
      nlinarith

theorem evenReluKappa_scaled_square_succ_le (r : ℕ) :
    evenReluKappa (r + 1) ^ 2 * (2 * ((r : ℝ) + 2)) ≤
      evenReluKappa r ^ 2 * (2 * ((r : ℝ) + 1)) := by
  have hr := evenReluKappa_recurrence r
  have hrsq : (2 * ((r : ℝ) + 1)) ^ 2 * evenReluKappa (r + 1) ^ 2 =
      (2 * (r : ℝ) + 1) ^ 2 * evenReluKappa r ^ 2 := by
    nlinarith [congrArg (fun z : ℝ => z ^ 2) hr]
  have hidentity : (2 * ((r : ℝ) + 1)) ^ 2 *
      (evenReluKappa r ^ 2 * (2 * ((r : ℝ) + 1)) -
        evenReluKappa (r + 1) ^ 2 * (2 * ((r : ℝ) + 2))) =
      (6 * (r : ℝ) + 4) * evenReluKappa r ^ 2 := by
    nlinarith [congrArg (fun z : ℝ => z * (2 * ((r : ℝ) + 2))) hrsq]
  have hnonneg : 0 ≤ (2 * ((r : ℝ) + 1)) ^ 2 *
      (evenReluKappa r ^ 2 * (2 * ((r : ℝ) + 1)) -
        evenReluKappa (r + 1) ^ 2 * (2 * ((r : ℝ) + 2))) := by
    rw [hidentity]
    positivity
  have hp : 0 < (2 * ((r : ℝ) + 1)) ^ 2 := by positivity
  have h := (mul_nonneg_iff_of_pos_left hp).mp hnonneg
  linarith

theorem evenReluKappa_scaled_square_le (r : ℕ) :
    evenReluKappa r ^ 2 * (2 * ((r : ℝ) + 1)) ≤ 1 := by
  induction r with
  | zero => norm_num [evenReluKappa]
  | succ r ih =>
      have h := evenReluKappa_scaled_square_succ_le r
      simp only [Nat.cast_add, Nat.cast_one]
      nlinarith

theorem evenReluKappa_mul_sqrt_le_one (r : ℕ) :
    evenReluKappa r * Real.sqrt (2 * (r + 1 : ℝ)) ≤ 1 := by
  have h := evenReluKappa_scaled_square_le r
  have hs := Real.sq_sqrt (show 0 ≤ 2 * (r + 1 : ℝ) by positivity)
  have hmul := congrArg (fun z : ℝ => evenReluKappa r ^ 2 * z) hs
  nlinarith [sq_nonneg (evenReluKappa r * Real.sqrt (2 * (r + 1 : ℝ)) - 1)]

theorem evenReluCost_le_three (r : ℕ) : evenReluCost r ≤ 3 * (2 * (r : ℝ) + 1) := by
  have hk := evenReluKappa_pos r
  have hlower := evenReluKappa_lower_square r
  have hs := Real.sq_sqrt (show 0 ≤ 2 * (r + 1 : ℝ) by positivity)
  have hcoef : 4 * (4 * (r : ℝ) + 1) * (2 * ((r : ℝ) + 1)) ≤
      (3 * (2 * (r : ℝ) + 1)) ^ 2 := by
    nlinarith [sq_nonneg (2 * (r : ℝ) - 1)]
  have hlowermul := mul_le_mul_of_nonneg_right hlower
    (show 0 ≤ 2 * ((r : ℝ) + 1) by positivity)
  have hcoefmul := mul_le_mul_of_nonneg_right hcoef (sq_nonneg (evenReluKappa r))
  unfold evenReluCost
  apply (div_le_iff₀ hk).2
  have hR : 0 ≤ 3 * (2 * (r : ℝ) + 1) * evenReluKappa r := by positivity
  nlinarith [Real.sqrt_nonneg (2 * (r + 1 : ℝ))]

theorem evenReluCost_succ_lower (r : ℕ) : evenReluCost r ≤ evenReluCost (r + 1) := by
  unfold evenReluCost
  calc
    Real.sqrt (2 * (r + 1 : ℝ)) / evenReluKappa r ≤
        Real.sqrt (2 * ((r + 1 : ℕ) + 1 : ℝ)) / evenReluKappa r := by
      apply div_le_div_of_nonneg_right _ (evenReluKappa_pos r).le
      apply Real.sqrt_le_sqrt
      push_cast
      linarith
    _ ≤ _ := div_le_div_of_nonneg_left (Real.sqrt_nonneg _)
      (evenReluKappa_pos (r + 1)) (evenReluKappa_succ_le r)

theorem evenReluCost_monotone : Monotone evenReluCost :=
  monotone_nat_of_le_succ evenReluCost_succ_lower

theorem evenReluCost_succ_upper (r : ℕ) : evenReluCost (r + 1) ≤ evenReluCost r + 6 := by
  let n : ℝ := 2 * ((r : ℝ) + 1)
  have hn : 0 < n := by dsimp [n]; positivity
  have hnp : 0 ≤ n + 2 := by linarith
  have hsR := Real.sq_sqrt hn.le
  have hsT := Real.sq_sqrt hnp
  have hroot : n * Real.sqrt (n + 2) ≤ (n + 1) * Real.sqrt n := by
    apply (sq_le_sq₀ (by positivity) (by positivity)).mp
    have hR := congrArg (fun z : ℝ => (n + 1) ^ 2 * z) hsR
    have hT := congrArg (fun z : ℝ => n ^ 2 * z) hsT
    nlinarith
  have hcost : Real.sqrt n ≤ 3 * (2 * (r : ℝ) + 1) * evenReluKappa r := by
    exact (div_le_iff₀ (evenReluKappa_pos r)).mp (evenReluCost_le_three r)
  have hrec : n * evenReluKappa (r + 1) =
      (2 * (r : ℝ) + 1) * evenReluKappa r := evenReluKappa_recurrence r
  have hnpred : 2 * (r : ℝ) + 1 = n - 1 := by dsimp [n]; ring
  have hmain : n * Real.sqrt (n + 2) ≤
      n * ((Real.sqrt n / evenReluKappa r + 6) * evenReluKappa (r + 1)) := by
    calc
      n * Real.sqrt (n + 2) ≤ (n + 1) * Real.sqrt n := hroot
      _ ≤ (2 * (r : ℝ) + 1) * Real.sqrt n +
          6 * (2 * (r : ℝ) + 1) * evenReluKappa r := by
        rw [hnpred] at hcost ⊢
        nlinarith
      _ = n * ((Real.sqrt n / evenReluKappa r + 6) * evenReluKappa (r + 1)) := by
        calc
          _ = (Real.sqrt n / evenReluKappa r + 6) * (n * evenReluKappa (r + 1)) := by
            rw [hrec]
            field_simp [(evenReluKappa_pos r).ne']
            <;> ring
          _ = _ := by ring
  have hdiv : Real.sqrt (n + 2) / evenReluKappa (r + 1) ≤
      Real.sqrt n / evenReluKappa r + 6 :=
    (div_le_iff₀ (evenReluKappa_pos (r + 1))).mpr (le_of_mul_le_mul_left hmain hn)
  convert hdiv using 1 <;> dsimp [evenReluCost, n] <;> push_cast <;> congr 2 <;> ring

/-- The physical degree increases by two at each step, so this is the
paper's uniform slope bound `a(n+k)-a(n) ≤ 3k` for even increments. -/
theorem evenReluCost_add_le (r k : ℕ) : evenReluCost (r + k) ≤ evenReluCost r + 6 * k := by
  induction k with
  | zero => simp
  | succ k ih =>
      have h := evenReluCost_succ_upper (r + k)
      rw [Nat.add_assoc] at h
      push_cast
      nlinarith

end NeuralGeneralization.OnlineLowerRelu
