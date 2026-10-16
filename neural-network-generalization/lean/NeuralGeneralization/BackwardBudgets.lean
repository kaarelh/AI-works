import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum.Basic

/-!
# Backward layer budgets

An exact finite recurrence argument used to prevent covariance errors from
being amplified by the successive tilt Lipschitz constants. This is a
complete statement about real sequences; no probabilistic or network
hypotheses are hidden in the definitions.
-/

namespace NeuralGeneralization.BackwardBudgets

/-- The backward identity turns the multiplicative recurrence into an
additive bound after weighting each error by its own layer budget. -/
theorem weighted_error_bound
    (error budget amplification : ℕ → ℝ) (cost : ℝ) (r : ℕ)
    (hzero : error 0 = 0)
    (hbudget : ∀ n, n ≤ r → 0 < budget n)
    (hbackward : ∀ n, n < r → budget n = amplification (n + 1) * budget (n + 1))
    (hstep : ∀ n, n < r → error (n + 1) ≤
      cost / budget (n + 1) + amplification (n + 1) * error n) :
    ∀ n, n ≤ r → error n * budget n ≤ (n : ℝ) * cost := by
  intro n
  induction n with
  | zero =>
      intro hn
      simp [hzero]
  | succ n ih =>
      intro hn
      have hnr : n < r := Nat.lt_of_succ_le hn
      have hg : 0 < budget (n + 1) := hbudget (n + 1) hn
      have hprev := ih (Nat.le_of_lt hnr)
      calc
        error (n + 1) * budget (n + 1) ≤
            (cost / budget (n + 1) + amplification (n + 1) * error n) *
              budget (n + 1) := mul_le_mul_of_nonneg_right (hstep n hnr) hg.le
        _ = cost + error n * budget n := by
          rw [add_mul, div_mul_cancel₀ cost (ne_of_gt hg), hbackward n hnr]
          ring
        _ ≤ cost + (n : ℝ) * cost := add_le_add le_rfl hprev
        _ = ((n + 1 : ℕ) : ℝ) * cost := by
          rw [Nat.cast_add, Nat.cast_one]
          ring

/-- With the final budget `32 r cost²`, the total terminal error is at most
`1/(32 cost)`, independently of all intermediate amplification factors. -/
theorem terminal_error_bound
    (error budget amplification : ℕ → ℝ) (cost : ℝ) (r : ℕ)
    (hcost : 0 < cost) (hr : 0 < r)
    (hzero : error 0 = 0)
    (hbudget : ∀ n, n ≤ r → 0 < budget n)
    (hbackward : ∀ n, n < r → budget n = amplification (n + 1) * budget (n + 1))
    (hstep : ∀ n, n < r → error (n + 1) ≤
      cost / budget (n + 1) + amplification (n + 1) * error n)
    (hterminal : budget r = 32 * (r : ℝ) * cost ^ 2) :
    error r ≤ 1 / (32 * cost) := by
  have hw := weighted_error_bound error budget amplification cost r hzero hbudget
    hbackward hstep r le_rfl
  have hr_real : 0 < (r : ℝ) := Nat.cast_pos.mpr hr
  have hfactor : 0 < (r : ℝ) * cost := mul_pos hr_real hcost
  have hcancel : (r : ℝ) * cost * (error r * (32 * cost)) ≤
      (r : ℝ) * cost * 1 := by
    calc
      (r : ℝ) * cost * (error r * (32 * cost)) =
          error r * (32 * (r : ℝ) * cost ^ 2) := by ring
      _ ≤ (r : ℝ) * cost := by simpa only [hterminal] using hw
      _ = (r : ℝ) * cost * 1 := by ring
  have he : error r * (32 * cost) ≤ 1 := le_of_mul_le_mul_left hcancel hfactor
  exact (le_div_iff₀ (mul_pos (by norm_num) hcost)).2 he

end NeuralGeneralization.BackwardBudgets
