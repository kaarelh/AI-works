import NeuralGeneralization.RudelsonFiniteRestriction
import NeuralGeneralization.RankOneGrowthConstants

/-! The logarithmic random-matrix loss is linear in cube dimension. -/
noncomputable section
namespace NeuralGeneralization.SquaredSampling

lemma log_cube_card (d : ℕ) :
    Real.log (Fintype.card (ClippingCube d):ℝ)=(d:ℝ)*Real.log 2 := by
  simp only [ClippingCube, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin,
    Nat.cast_pow, Nat.cast_ofNat, Real.log_pow]

lemma log_cube_card_le (d : ℕ) : Real.log (Fintype.card (ClippingCube d):ℝ) ≤ d := by
  rw [log_cube_card]
  have hl : Real.log (2:ℝ) ≤ 1 := by linarith only [Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)]
  simpa only [mul_one] using mul_le_mul_of_nonneg_left hl (Nat.cast_nonneg d : (0:ℝ)≤d)

lemma restrictionLog_cube_le {d : ℕ} (hd : 0 < d) :
    restrictionLog (Fintype.card (ClippingCube d)) (Fintype.card (ClippingCube d)) ≤ 8*(d:ℝ) := by
  have hc : (0:ℝ)<Fintype.card (ClippingCube d) := by positivity
  have hl := log_cube_card_le d
  have hdim := dimensionCutoff_le_two_log (Fintype.card (ClippingCube d))
  have h8 : Real.log (8:ℝ) ≤ 3 := by
    rw [show (8:ℝ)=2^3 by norm_num, Real.log_pow]
    have h2 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at h2 ⊢
    linarith
  have hd1 : (1:ℝ) ≤ d := by exact_mod_cast hd
  unfold restrictionLog
  rw [Real.log_mul (by norm_num) hc.ne']
  push_cast
  linarith

end NeuralGeneralization.SquaredSampling
