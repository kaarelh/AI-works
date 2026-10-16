import NeuralGeneralization.LargeDampedConditioningCost
import NeuralGeneralization.GaussianAmplitudeScale
import NeuralGeneralization.AdaptiveNormalizedWeights

/-! Sharp normalized entropy and Gaussian endpoint numerical closure. -/
noncomputable section
namespace NeuralGeneralization.LargeZeroScalar
open LocalizedCubeBump AdaptiveCutoff

lemma shifted_power_bound {d : ℕ} (hd : 1≤d) {β : ℝ} (hβ0 : 0≤β) (hβ1 : β≤1) :
    ((d:ℝ)+1)^(1+β)≤4*(d:ℝ)^(1+β) := by
  have hd0 : (0:ℝ)≤d := Nat.cast_nonneg _
  have hd1 : (1:ℝ)≤d := by exact_mod_cast hd
  have hpow : (2:ℝ)^(1+β)≤4 := by
    have hh := Real.rpow_le_rpow_of_exponent_le (by norm_num : (1:ℝ)≤2) (show 1+β≤2 by linarith only [hβ1])
    norm_num only [Real.rpow_two] at hh
    exact hh
  calc
    _ ≤ (2*(d:ℝ))^(1+β) := Real.rpow_le_rpow (by positivity) (by linarith only [hd1]) (by linarith only [hβ0])
    _ = (2:ℝ)^(1+β)*(d:ℝ)^(1+β) := Real.mul_rpow (by norm_num) hd0
    _ ≤ _ := mul_le_mul_of_nonneg_right hpow (Real.rpow_nonneg hd0 _)

lemma normalized_conditioning_cost {d r n : ℕ} (hd : 1≤d) (hr : 0<r)
    (k : ℕ) (a b b0 D : ℝ) (hb0 : 0<b0)
    (hlevel : b0*(d:ℝ)^(1-dampingExponent k)≤b^2)
    (hcost : D≤largeConditioningConstant k a*(n:ℝ)*((d:ℝ)+1)^(1+dampingExponent k)*(cutoffDamping k r:ℝ)) :
    D/b^2≤(4*largeConditioningConstant k a/b0)*(n:ℝ)*
      ((d:ℝ)^(2*dampingExponent k)*(r:ℝ)^(-dampingExponent k)) := by
  have hd0 : (0:ℝ)<d := Nat.cast_pos.mpr (by omega)
  have hr0 : (0:ℝ)<r := Nat.cast_pos.mpr hr
  have hC := largeConditioningConstant_pos k a
  have hβ0 := (dampingExponent_pos k).le
  have hβ1 := dampingExponent_le_one k
  have hp := shifted_power_bound hd hβ0 hβ1
  have hb : 0<b^2 := (mul_pos hb0 (Real.rpow_pos_of_pos hd0 _)).trans_le hlevel
  apply (div_le_iff₀ hb).mpr
  have he : (d:ℝ)^(2*dampingExponent k)*(d:ℝ)^(1-dampingExponent k)=(d:ℝ)^(1+dampingExponent k) := by
    rw [←Real.rpow_add hd0]
    congr 1
    ring
  have hC0 : 0≤(4*largeConditioningConstant k a/b0)*(n:ℝ)*((d:ℝ)^(2*dampingExponent k)*(r:ℝ)^(-dampingExponent k)) := by positivity
  have hh := mul_le_mul_of_nonneg_left hlevel hC0
  have heq : (4*largeConditioningConstant k a/b0)*(n:ℝ)*((d:ℝ)^(2*dampingExponent k)*(r:ℝ)^(-dampingExponent k))*(b0*(d:ℝ)^(1-dampingExponent k))=
      4*largeConditioningConstant k a*(n:ℝ)*(d:ℝ)^(1+dampingExponent k)*(r:ℝ)^(-dampingExponent k) := by
    calc
      _ = 4*largeConditioningConstant k a*(n:ℝ)*((d:ℝ)^(2*dampingExponent k)*(d:ℝ)^(1-dampingExponent k))*(r:ℝ)^(-dampingExponent k) := by field_simp
      _ = _ := by rw [he]
  rw [heq] at hh
  apply le_trans (hcost.trans ?_) hh
  change _≤4*largeConditioningConstant k a*(n:ℝ)*(d:ℝ)^(1+dampingExponent k)*(cutoffDamping k r:ℝ)
  have hg := mul_le_mul_of_nonneg_left hp (show 0≤largeConditioningConstant k a*(n:ℝ) by positivity)
  have ht := mul_le_mul_of_nonneg_right hg (show 0≤(cutoffDamping k r:ℝ) from (cutoffDamping k r).coe_nonneg)
  nlinarith only [ht]

/-- The logarithmic band controls the upper-tail entropy term after the
normalization needed at gamma zero. -/
lemma normalized_upper_tail {d n : ℕ} {ell B C W δ : ℝ}
    (hC : 0≤C) (hell : 0≤ell) (hW : W≤d)
    (hB : B≤C*(n:ℝ)*W)
    (hupper : (n:ℝ)*ell*((d:ℝ)+1)^10≤δ) : ell*B≤C*δ := by
  have hd0 : (0:ℝ)≤d := Nat.cast_nonneg _
  have hD : 1≤(d:ℝ)+1 := by linarith only [hd0]
  have hpow : (d:ℝ)≤((d:ℝ)+1)^10 := by
    have hh := pow_le_pow_right₀ hD (by decide : 1≤10)
    rw [pow_one] at hh
    exact (show (d:ℝ)≤(d:ℝ)+1 by linarith).trans hh
  have h1 := mul_le_mul_of_nonneg_left hB hell
  have h2 := mul_le_mul_of_nonneg_left (hW.trans hpow) (show 0≤C*(n:ℝ)*ell by positivity)
  have h3 := mul_le_mul_of_nonneg_left hupper hC
  nlinarith only [h1,h2,h3]

lemma gaussian_zero_moment_budgets {d n u : ℕ} {tauH tauU G ellH ellU D B b : ℝ}
    (hu : u≤d) (htH : tauH≤1) (htU : tauU≤1) (hb : 10240≤b^2)
    (hDB : D=B*b^2)
    (hhead : (u:ℝ)^2*(4*G*B/(n:ℝ)+ellH*B)≤(d:ℝ)^2/2048)
    (htail : ellU*B≤1/2048) :
    (u:ℝ)^2*(10*tauH+(16*G/(n:ℝ)+4*ellH)*D)≤(b*(d:ℝ))^2/256 ∧
      2*tauU+4*ellU*D≤b^2/256 := by
  have huR : (u:ℝ)≤d := by exact_mod_cast hu
  have hu2 : (u:ℝ)^2≤(d:ℝ)^2 := pow_le_pow_left₀ (Nat.cast_nonneg _) huR 2
  have hh := mul_le_mul_of_nonneg_left hhead (sq_nonneg b)
  have hh' := mul_le_mul_of_nonneg_left htH (show 0≤(u:ℝ)^2 by positivity)
  have hb' := mul_le_mul_of_nonneg_right hb (sq_nonneg (d:ℝ))
  have hident : (u:ℝ)^2*(10*tauH+(16*G/(n:ℝ)+4*ellH)*D)=
      10*(u:ℝ)^2*tauH+4*b^2*((u:ℝ)^2*(4*G*B/(n:ℝ)+ellH*B)) := by rw [hDB]; ring
  refine ⟨?_,?_⟩
  · rw [hident]
    nlinarith only [hh,hh',hu2,hb']
  · rw [hDB]
    have ht := mul_le_mul_of_nonneg_right htail (sq_nonneg b)
    nlinarith only [ht,htU,hb]

end NeuralGeneralization.LargeZeroScalar
