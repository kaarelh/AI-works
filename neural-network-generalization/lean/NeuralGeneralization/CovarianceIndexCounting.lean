import NeuralGeneralization.Network
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Positivity

/-! # Covariance indexing contributes only a linear factor in input dimension -/
namespace NeuralGeneralization.CovarianceIndexCounting
open ConcreteModel

theorem covariance_index_card (d : ℕ) :
    Fintype.card (Cube d × Cube d) = 2 ^ (2 * d) := by
  simp only [Cube, Fintype.card_prod, Fintype.card_fun, Fintype.card_bool,
    Fintype.card_fin, ← pow_add, two_mul]

/-- The sparse-dual net counts exponentially many covariance coordinates,
but only their logarithm enters the empirical certificate. -/
theorem covariance_log_atom_count_le (d : ℕ) :
    Real.log (2 * (Fintype.card (Cube d × Cube d) : ℝ) + 1) ≤ 2 * (d : ℝ) + 2 := by
  have hpow : 1 ≤ (2 : ℝ) ^ (2 * d) := one_le_pow₀ (by norm_num)
  have hbase : 0 < 2 * (Fintype.card (Cube d × Cube d) : ℝ) + 1 := by positivity
  have harg : 2 * (Fintype.card (Cube d × Cube d) : ℝ) + 1 ≤ (2 : ℝ) ^ (2 * d + 2) := by
    rw [covariance_index_card, Nat.cast_pow, Nat.cast_ofNat, pow_add]
    norm_num
    nlinarith
  have hlog := Real.log_le_log hbase harg
  rw [Real.log_pow] at hlog
  have hlog2 : Real.log 2 ≤ 1 := by
    have h := Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 2)
    norm_num at h
    exact h
  have hmul := mul_le_mul_of_nonneg_left hlog2
    (Nat.cast_nonneg (2 * d + 2) : (0 : ℝ) ≤ (2 * d + 2 : ℕ))
  push_cast at hlog hmul
  nlinarith

theorem covariance_log_atom_count_le_four_mul {d : ℕ} (hd : 0 < d) :
    Real.log (2 * (Fintype.card (Cube d × Cube d) : ℝ) + 1) ≤ 4 * (d : ℝ) := by
  have hdR : (1 : ℝ) ≤ (d : ℝ) := by exact_mod_cast hd
  exact (covariance_log_atom_count_le d).trans (by linarith)

end NeuralGeneralization.CovarianceIndexCounting
