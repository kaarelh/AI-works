import NeuralGeneralization.RankOneAllLevelGrowth

/-! Elementary logarithmic bounds on the explicit dimension cutoff. -/

noncomputable section
namespace NeuralGeneralization.SquaredSampling

theorem dimensionCutoff_le_log_ratio (D : ℕ) :
    (dimensionCutoff D:ℝ) ≤ Real.log (D:ℝ)/Real.log 2+1 := by
  have hlog2 : 0 < Real.log (2:ℝ) := Real.log_pos (by norm_num)
  by_cases hD : 1 < D
  · have hcut : 0 < dimensionCutoff D := Nat.clog_pos (by decide) hD
    have hp : (2:ℝ)^((dimensionCutoff D)-1) < (D:ℝ) := by
      exact_mod_cast Nat.pow_pred_clog_lt_self (by decide : 1<2) hD
    have hl := Real.log_lt_log (by positivity : (0:ℝ)<2^((dimensionCutoff D)-1)) hp
    rw [Real.log_pow, Nat.cast_sub hcut, Nat.cast_one] at hl
    have hh : (dimensionCutoff D:ℝ)-1 ≤ Real.log (D:ℝ)/Real.log 2 :=
      (le_div_iff₀ hlog2).mpr hl.le
    linarith
  · have hc : dimensionCutoff D=0 := Nat.clog_of_right_le_one (le_of_not_gt hD) 2
    rw [hc, Nat.cast_zero]
    have hlog : 0 ≤ Real.log (D:ℝ) := Real.log_natCast_nonneg D
    positivity

theorem dimensionCutoff_le_two_log (D : ℕ) :
    (dimensionCutoff D:ℝ) ≤ 2*Real.log (D:ℝ)+1 := by
  have hlog2 : (1:ℝ)/2 ≤ Real.log 2 := by
    have hh := Real.one_sub_inv_le_log_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at hh ⊢
    exact hh
  have hlog : 0 ≤ Real.log (D:ℝ) := Real.log_natCast_nonneg D
  have hdiv : Real.log (D:ℝ)/Real.log 2 ≤ 2*Real.log (D:ℝ) := by
    apply (div_le_iff₀ (by linarith : 0<Real.log 2)).mpr
    have hh := mul_le_mul_of_nonneg_left hlog2 hlog
    nlinarith only [hh]
  linarith only [dimensionCutoff_le_log_ratio D, hdiv]

end NeuralGeneralization.SquaredSampling
