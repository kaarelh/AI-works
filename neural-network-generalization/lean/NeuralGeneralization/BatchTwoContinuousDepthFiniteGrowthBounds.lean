import NeuralGeneralization.BatchTwoContinuousDepthFiniteParameters

/-! Polynomial control of every literal finite-ceiling radius factor. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
set_option maxHeartbeats 1400000
set_option backward.isDefEq.respectTransparency false

theorem energyBudget_add_two {L : ℕ} (hL : 3 ≤ L) {T : ℝ} (hT : 1 ≤ T) :
    energyBudget L T+2 ≤ ((L : ℝ)+18)*T^(1/((L : ℝ)-1)) := by
  have hLR : (3 : ℝ) ≤ L := by exact_mod_cast hL
  have ht := Real.one_le_rpow hT (show 0 ≤ 1/((L : ℝ)-1) by apply div_nonneg (by norm_num);linarith)
  unfold energyBudget
  nlinarith

theorem approximationAmplification_square {L : ℕ} (hL : 3 ≤ L) {T : ℝ} (hT : 1 ≤ T) :
    (approximationAmplification L (energyBudget L T))^2 ≤ Real.exp 19*T := by
  have hLR : (3 : ℝ) ≤ L := by exact_mod_cast hL
  have hu : 0 < (L : ℝ)-1 := by linarith
  have hTp : 0 < T := by linarith
  have hK := energyBudget_nonneg (L:=L) hT
  have hbase : (energyBudget L T+2)/((L : ℝ)-1) ≤
      (1+19/((L : ℝ)-1))*T^(1/((L : ℝ)-1)) := by
    calc
      _ ≤ (((L : ℝ)+18)*T^(1/((L : ℝ)-1)))/((L : ℝ)-1) :=
        div_le_div_of_nonneg_right (energyBudget_add_two hL hT) hu.le
      _ = _ := by field_simp <;> ring
  have hc : (1+19/((L : ℝ)-1))^((L : ℝ)-1) ≤ Real.exp 19 := by
    calc
      _ ≤ (Real.exp (19/((L : ℝ)-1)))^((L : ℝ)-1) :=
        Real.rpow_le_rpow (by positivity) (by linarith only [Real.add_one_le_exp (19/((L : ℝ)-1))]) hu.le
      _ = _ := by rw [← Real.exp_mul,div_mul_cancel₀ _ hu.ne']
  have ht : (T^(1/((L : ℝ)-1)))^((L : ℝ)-1)=T := by
    rw [← Real.rpow_mul hTp.le,div_mul_cancel₀ _ hu.ne',Real.rpow_one]
  have he : (approximationAmplification L (energyBudget L T))^2=
      ((energyBudget L T+2)/((L : ℝ)-1))^((L : ℝ)-1) := by
    unfold approximationAmplification
    rw [← Real.rpow_natCast,← Real.rpow_mul (by positivity)]
    norm_num only [Nat.cast_ofNat]
    rw [div_mul_cancel₀ _ (by norm_num : (2 : ℝ) ≠ 0)]
  rw [he]
  calc
    _ ≤ ((1+19/((L : ℝ)-1))*T^(1/((L : ℝ)-1)))^((L : ℝ)-1) :=
      Real.rpow_le_rpow (by positivity) hbase hu.le
    _ = (1+19/((L : ℝ)-1))^((L : ℝ)-1)*T := by rw [Real.mul_rpow (by positivity) (by positivity),ht]
    _ ≤ Real.exp 19*T := mul_le_mul_of_nonneg_right hc hTp.le

theorem energyBudget_linear_product {L : ℕ} (hL : 3 ≤ L) {T : ℝ} (hT : 1 ≤ T) :
    energyBudget L T+1 ≤ 18*(L : ℝ)*T := by
  have hLR : (3 : ℝ) ≤ L := by exact_mod_cast hL
  have ht : T^(1/((L : ℝ)-1)) ≤ T :=
    Real.rpow_le_self_of_one_le hT ((div_le_one (by linarith)).mpr (by linarith))
  have hh := energyBudget_add_one hL hT
  have hm := mul_le_mul_of_nonneg_left ht (show 0 ≤ (L : ℝ)+17 by positivity)
  have hT0 : 0 ≤ T := by linarith
  nlinarith [mul_nonneg (show 0 ≤ (L : ℝ)-1 by linarith) hT0]

theorem noiseSquared_polynomial_bound (d : ℕ) {L : ℕ} (hL : 1 ≤ L) :
    noiseSquared d L ≤ 2*(d : ℝ)+64*(L : ℝ)+150 := by
  have hLR : (1 : ℝ) ≤ L := by exact_mod_cast hL
  have h2 := Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 2)
  have h8 := Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 8)
  have h9 := Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 9)
  have h8L := Real.log_le_sub_one_of_pos (show 0 < 8*(L : ℝ) by positivity)
  unfold noiseSquared
  apply max_le
  · have hh := mul_le_mul_of_nonneg_left h2 (show 0 ≤ 2*((d : ℝ)+1) by positivity)
    unfold firstNoiseSquared
    nlinarith [Nat.cast_nonneg d (α:=ℝ)]
  · unfold internalNoiseSquared
    nlinarith [Nat.cast_nonneg d (α:=ℝ)]

theorem approximationRadius_inverse_square {L : ℕ} (hL : 2 ≤ L) {K h : ℝ}
    (hK : 0 ≤ K) (hh : 0 < h) :
    1/(approximationRadius L K h)^2 ≤
      1+16*(L : ℝ)*(K+1)+2*(L : ℝ)^2*(approximationAmplification L K)^2/h^2 := by
  have hLR : (2 : ℝ) ≤ L := by exact_mod_cast hL
  have hA := approximationAmplification_pos hL hK
  have he1 : 1/(1/(4*Real.sqrt ((L : ℝ)*(K+1))))^2=16*(L : ℝ)*(K+1) := by
    rw [div_pow,one_pow,one_div_div,mul_pow,Real.sq_sqrt (by positivity)]
    ring
  have he2 : 1/(h/(Real.sqrt 2*(L : ℝ)*approximationAmplification L K))^2=
      2*(L : ℝ)^2*(approximationAmplification L K)^2/h^2 := by
    rw [div_pow,one_div_div,mul_pow,mul_pow,Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 2)]
  have hpos1 : 0 ≤ 16*(L : ℝ)*(K+1) := by positivity
  have hpos2 : 0 ≤ 2*(L : ℝ)^2*(approximationAmplification L K)^2/h^2 := by positivity
  unfold approximationRadius
  by_cases ha : 1 ≤ min (1/(4*Real.sqrt ((L : ℝ)*(K+1))))
      (h/(Real.sqrt 2*(L : ℝ)*approximationAmplification L K))
  · rw [min_eq_left ha]
    norm_num
    linarith
  · rw [min_eq_right (le_of_lt (lt_of_not_ge ha))]
    by_cases hb : 1/(4*Real.sqrt ((L : ℝ)*(K+1))) ≤ h/(Real.sqrt 2*(L : ℝ)*approximationAmplification L K)
    · rw [min_eq_left hb,he1]
      linarith
    · rw [min_eq_right (le_of_lt (lt_of_not_ge hb)),he2]
      linarith

end NeuralGeneralization.BatchTwoContinuousDepthPaper
