import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-! Elementary constants for a uniform Gaussian matrix good event. -/

noncomputable section

namespace NeuralGeneralization.GaussianTail

/-- At positive square dimension, the net entropy is absorbed by the scalar
Gaussian tail at radius sixteen times the natural matrix scale. -/
theorem matrix_net_tail_le_half (N : ℕ) (hN : 1 ≤ N) :
    2 * (9 : ℝ) ^ (N + N) * Real.exp (-32 * (N : ℝ)) ≤ 1 / 2 := by
  have h9 : (9 : ℝ) ≤ Real.exp 9 := by linarith [Real.add_one_le_exp (9 : ℝ)]
  have hp : (9 : ℝ) ^ (N + N) ≤ Real.exp (18 * (N : ℝ)) := by
    have hh := pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 9) h9 (N + N)
    rw [← Real.exp_nat_mul] at hh
    convert hh using 1 <;> push_cast <;> congr 1 <;> ring
  have h2 : (2 : ℝ) ≤ Real.exp 1 := by linarith [Real.add_one_le_exp (1 : ℝ)]
  have h4 : (4 : ℝ) ≤ Real.exp 2 := by
    have hh := mul_le_mul h2 h2 (by norm_num : (0 : ℝ) ≤ 2) (Real.exp_pos 1).le
    rw [← Real.exp_add] at hh
    norm_num at hh ⊢
    exact hh
  have hsmall : Real.exp (-2 : ℝ) ≤ 1 / 4 := by
    rw [Real.exp_neg, ← one_div]
    exact one_div_le_one_div_of_le (by norm_num) h4
  have hNr : (1 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
  calc
    _ ≤ 2 * Real.exp (18 * (N : ℝ)) * Real.exp (-32 * (N : ℝ)) := by
      exact mul_le_mul_of_nonneg_right
        (mul_le_mul_of_nonneg_left hp (by norm_num)) (Real.exp_pos _).le
    _ = 2 * Real.exp (-14 * (N : ℝ)) := by
      rw [mul_assoc, ← Real.exp_add]
      congr 2
      ring
    _ ≤ 2 * Real.exp (-2 : ℝ) := by
      apply mul_le_mul_of_nonneg_left _ (by norm_num)
      apply Real.exp_le_exp.mpr
      linarith
    _ ≤ _ := by linarith

end NeuralGeneralization.GaussianTail
