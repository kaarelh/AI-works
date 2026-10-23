import NeuralGeneralization.BatchTwoContinuousDepthPowerWidth
import NeuralGeneralization.BatchTwoContinuousDepthResources

/-! The finite-exponent width threshold is polynomial in sample count and
network depth, with degree allowed to depend on the exponent gap. -/
noncomputable section
set_option maxHeartbeats 1800000
namespace NeuralGeneralization.BatchTwoContinuousDepthPower
open ConcreteModel BatchTwoNonGaussian BatchTwoContinuousDepthLower BatchTwoContinuous.FiniteTarget

theorem widthThreshold_polynomial {ζ : ℝ} (hζ : 0<ζ) :
    ∃ B : ℝ, 0<B ∧ ∀ n r : ℕ, 0<n →
      (widthThreshold (interpolationWidth n) r (1/8) ζ : ℝ)≤
        B*((n : ℝ)+(r : ℝ)+1)^(161*widthExponent ζ) := by
  let q := widthExponent ζ
  let k : ℝ := 10^25
  let c : ℝ := 20+|Real.log (radiusCap standardGaussian)|+|Real.log 8|
  let a := k+10+c
  let b := 16+100*noisePolynomialCoefficient standardGaussian*a^7
  have hk : 0<k := by norm_num [k]
  have hc : 0≤c := by dsimp [c]; positivity
  have ha : 0<a := by dsimp [a]; positivity
  have hb : 0<b := by dsimp [b]; have := noisePolynomialCoefficient_pos standardGaussian; positivity
  have hq : 0<q := by
    have hh : (0 : ℝ)<q := (inv_pos.mpr hζ).trans_le (Nat.le_ceil _)
    exact_mod_cast hh
  refine ⟨k+b^q+1,by positivity,?_⟩
  intro n r hn
  generalize hUeq : (n : ℝ)+(r : ℝ)+1=U
  have hU : 1≤U := by rw [←hUeq]; linarith [Nat.cast_nonneg n (α := ℝ),Nat.cast_nonneg r (α := ℝ)]
  have hU0 : 0≤U := by linarith
  have hU23 : 1≤U^23 := one_le_pow₀ hU
  have hUbig : 1≤U^(161*q) := one_le_pow₀ hU
  have hnU : (n : ℝ)≤U := by rw [←hUeq]; linarith [Nat.cast_nonneg r (α := ℝ)]
  have hrU : (r : ℝ)≤U := by rw [←hUeq]; linarith [Nat.cast_nonneg n (α := ℝ)]
  have hUle : U≤U^23 := by simpa using pow_le_pow_right₀ hU (show 1≤23 by omega)
  have hM : (interpolationWidth n : ℝ)≤k*U^23 :=
    (interpolationWidth_polynomial hn).trans (mul_le_mul_of_nonneg_left
      (pow_le_pow_left₀ (Nat.cast_nonneg n) hnU 23) hk.le)
  have h23big : U^23≤U^(161*q) := pow_le_pow_right₀ hU (by omega)
  have hS : slowResourceSize (interpolationWidth n) r (1/8)≤a*U^23 := by
    have hc' : c≤c*U^23 := by nlinarith only [mul_le_mul_of_nonneg_left hU23 hc]
    have hr' : (r : ℝ)≤U^23 := hrU.trans hUle
    dsimp [slowResourceSize]
    norm_num only [show (min 1 (1/8) : ℝ)=1/8 by norm_num,one_div_div,div_one]
    have hlog := le_abs_self (Real.log (8 : ℝ))
    dsimp only [a,c] at hc' ⊢
    nlinarith only [hM,hc',hr',hlog]
  have hS0 : 0≤slowResourceSize (interpolationWidth n) r (1/8) := by
    dsimp [slowResourceSize]
    have : 0≤Real.log (1/min 1 (1/8 : ℝ)) := Real.log_nonneg (by norm_num)
    positivity
  have hbase : 16+100*noisePolynomialCoefficient standardGaussian*
      (slowResourceSize (interpolationWidth n) r (1/8))^7≤b*U^161 := by
    have hp := pow_le_pow_left₀ hS0 hS 7
    have hm := mul_le_mul_of_nonneg_left hp
      (show 0≤100*noisePolynomialCoefficient standardGaussian by have := noisePolynomialCoefficient_pos standardGaussian; positivity)
    have hU161 : 1≤U^161 := one_le_pow₀ hU
    rw [mul_pow,←pow_mul] at hm
    norm_num only [show 23*7=161 by norm_num] at hm
    dsimp only [b]
    nlinarith only [hm,hU161]
  have hbase0 : 0≤16+100*noisePolynomialCoefficient standardGaussian*
      (slowResourceSize (interpolationWidth n) r (1/8))^7 := by
    have := noisePolynomialCoefficient_pos standardGaussian
    positivity
  have hp := pow_le_pow_left₀ hbase0 hbase q
  rw [mul_pow,←pow_mul] at hp
  have hceil := Nat.ceil_lt_add_one (pow_nonneg hbase0 q)
  have hceilbound : (⌈(16+100*noisePolynomialCoefficient standardGaussian*
      (slowResourceSize (interpolationWidth n) r (1/8))^7)^q⌉₊ : ℝ)≤(k+b^q+1)*U^(161*q) := by
    have hkU : 0≤k*U^(161*q) := by positivity
    nlinarith only [hceil,hp,hUbig,hkU]
  have hMbound : (interpolationWidth n : ℝ)≤(k+b^q+1)*U^(161*q) := by
    have hm := mul_le_mul_of_nonneg_left h23big hk.le
    have hextra : 0≤(b^q+1)*U^(161*q) := by positivity
    nlinarith only [hM,hm,hextra]
  rw [widthThreshold,Nat.cast_max]
  exact max_le hMbound hceilbound

end NeuralGeneralization.BatchTwoContinuousDepthPower
