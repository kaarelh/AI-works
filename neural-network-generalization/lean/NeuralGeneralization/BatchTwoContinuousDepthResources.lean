import NeuralGeneralization.BatchTwoContinuousDepthInterpolation

/-! Numerical width and energy resources for the actual separated-sample
interpolant in the continuous-domain depth lower bound. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoContinuousDepthLower

def interpolationWidth (n : ℕ) : ℕ :=
  ⌈max (4 : ℝ) (max (n : ℝ)
    (6*(n : ℝ)*(max 2 (interpolationSlope n (sampleSeparation n)))^2))⌉₊

theorem inverse_frostmanExponent_le_five : 1/frostmanExponent ≤ 5 := by
  have hlog : Real.log 20 ≤ 5*Real.log 2 := by
    have h := Real.log_le_log (by norm_num : (0 : ℝ)<20) (show (20 : ℝ)≤2^5 by norm_num)
    simpa only [Real.log_pow,Nat.cast_ofNat] using h
  apply (div_le_iff₀ frostmanExponent_pos).mpr
  unfold frostmanExponent
  rw [← mul_div_assoc]
  apply (le_div_iff₀ (Real.log_pos (by norm_num : (1 : ℝ)<20))).mpr
  simpa using hlog

theorem sampleSeparation_inverse_polynomial {n : ℕ} (hn : 0 < n) :
    (sampleSeparation n)⁻¹ ≤ (100 : ℝ)^5*(n : ℝ)^10 := by
  have hn1 : (1 : ℝ)≤n := by exact_mod_cast hn
  have hb : (1 : ℝ)≤100*(n : ℝ)^2 := by nlinarith only [hn1,sq_nonneg ((n:ℝ)-1)]
  unfold sampleSeparation
  rw [← Real.rpow_neg (by positivity),show -(-1/frostmanExponent)=1/frostmanExponent by ring]
  calc
    _ ≤ (100*(n : ℝ)^2)^(5 : ℝ) := Real.rpow_le_rpow_of_exponent_le hb inverse_frostmanExponent_le_five
    _ = _ := by norm_num [Real.rpow_ofNat]; ring

theorem interpolationSlope_polynomial {n : ℕ} (hn : 0 < n) :
    interpolationSlope n (sampleSeparation n) ≤ 160000000000*(n : ℝ)^11 := by
  have hnR : (0 : ℝ)<n := by exact_mod_cast hn
  have hlog : Real.log (16*(n : ℝ)) ≤ 16*n :=
    (Real.log_le_sub_one_of_pos (by positivity)).trans (by linarith)
  have hi := sampleSeparation_inverse_polynomial hn
  have hpos := inv_nonneg.mpr (sampleSeparation_pos hn).le
  calc
    _ ≤ (sampleSeparation n)⁻¹*(16*(n : ℝ)) := mul_le_mul_of_nonneg_left hlog hpos
    _ ≤ ((100 : ℝ)^5*(n : ℝ)^10)*(16*(n : ℝ)) :=
      mul_le_mul_of_nonneg_right hi (by positivity)
    _ = _ := by ring

theorem interpolationWidth_ge {n : ℕ} (hn : 0 < n) :
    2*n ≤ interpolationWidth n ∧
    14*(n : ℝ)*(interpolationSlope n (sampleSeparation n))^2 ≤
      3*(interpolationWidth n : ℝ) := by
  have hnR : (0 : ℝ)<n := by exact_mod_cast hn
  let a := interpolationSlope n (sampleSeparation n)
  have ha : 0 < a := interpolationSlope_pos hn (sampleSeparation_pos hn)
  have hmax : (2 : ℝ)≤max 2 a := le_max_left _ _
  have hs : a^2 ≤ (max 2 a)^2 := pow_le_pow_left₀ ha.le (le_max_right _ _) 2
  have hh : 6*(n : ℝ)*(max 2 a)^2 ≤ (interpolationWidth n : ℝ) :=
    (le_max_right _ _).trans ((le_max_right _ _).trans (Nat.le_ceil _))
  have hsq : (4 : ℝ)≤(max 2 a)^2 := by nlinarith only [hmax]
  have hm := mul_le_mul_of_nonneg_left hsq hnR.le
  have hm2 := mul_le_mul_of_nonneg_left hs hnR.le
  constructor
  · have h : (2 : ℝ)*n ≤ interpolationWidth n := by nlinarith only [hh,hm,hnR]
    exact_mod_cast h
  · change 14*(n : ℝ)*a^2≤_
    nlinarith only [hh,hm2,mul_nonneg hnR.le (sq_nonneg a)]

theorem interpolationWidth_polynomial {n : ℕ} (hn : 0 < n) :
    (interpolationWidth n : ℝ) ≤ (10 : ℝ)^25*(n : ℝ)^23 := by
  have hn1 : (1 : ℝ)≤n := by exact_mod_cast hn
  have hp11 : (1 : ℝ)≤(n : ℝ)^11 := one_le_pow₀ hn1
  have hp23 : (1 : ℝ)≤(n : ℝ)^23 := one_le_pow₀ hn1
  have hmax : max 2 (interpolationSlope n (sampleSeparation n)) ≤
      160000000000*(n : ℝ)^11 := max_le (by nlinarith only [hp11]) (interpolationSlope_polynomial hn)
  have hmax0 : (0 : ℝ)≤max 2 (interpolationSlope n (sampleSeparation n)) := le_max_of_le_left (by norm_num)
  have hs := pow_le_pow_left₀ hmax0 hmax 2
  have hm := mul_le_mul_of_nonneg_left hs (show 0≤6*(n : ℝ) by positivity)
  have ht : 6*(n : ℝ)*(max 2 (interpolationSlope n (sampleSeparation n)))^2 ≤
      153600000000000000000000*(n : ℝ)^23 := by nlinarith only [hm]
  have hnp : (n : ℝ)≤(n : ℝ)^23 := by
    simpa only [pow_one] using pow_le_pow_right₀ hn1 (show 1≤23 by omega)
  have hu : max (4 : ℝ) (max (n : ℝ)
      (6*(n : ℝ)*(max 2 (interpolationSlope n (sampleSeparation n)))^2)) ≤
      153600000000000000000000*(n : ℝ)^23 := by
    exact max_le (by nlinarith only [hp23]) (max_le (by nlinarith only [hnp,hp23]) ht)
  have hc : (interpolationWidth n : ℝ) <
      max (4 : ℝ) (max (n : ℝ)
        (6*(n : ℝ)*(max 2 (interpolationSlope n (sampleSeparation n)))^2))+1 :=
    Nat.ceil_lt_add_one (le_max_of_le_left (by norm_num))
  nlinarith only [hu,hc,hp23]

theorem interpolationWidth_times_square_polynomial {n : ℕ} (hn : 0 < n) :
    (interpolationWidth n : ℝ)*(n : ℝ)^2 ≤ (10 : ℝ)^25*(n : ℝ)^25 := by
  have h := mul_le_mul_of_nonneg_right (interpolationWidth_polynomial hn) (sq_nonneg (n : ℝ))
  simpa only [mul_assoc,← pow_add] using h

end NeuralGeneralization.BatchTwoContinuousDepthLower
