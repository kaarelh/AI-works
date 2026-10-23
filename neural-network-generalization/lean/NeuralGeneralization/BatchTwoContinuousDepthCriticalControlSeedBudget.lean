import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlSeedMain

/-! Explicit seed cost for the logarithmic critical-depth schedule. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false

theorem seedSlope_upper {n:ℕ} (hn:0<n) {δ:ℝ} (hδ:0<δ):
    seedSlope n δ≤17*(n:ℝ)/δ:=by
  have hn1:(1:ℝ)≤n:=by exact_mod_cast hn
  have hh:=Real.log_le_sub_one_of_pos (show (0:ℝ)<16*(n:ℝ) by positivity)
  unfold seedSlope
  apply div_le_div_of_nonneg_right _ hδ.le
  linarith

theorem seedDilution_budget {n:ℕ} (hn:0<n) {δ:ℝ} (hδ:0<δ) (hδ1:δ≤1):
    (seedDilution n δ:ℝ)*δ^2≤2892*(n:ℝ)^2:=by
  have hn1:(1:ℝ)≤n:=by exact_mod_cast hn
  have hceil:(seedDilution n δ:ℝ)≤2+10*(seedSlope n δ)^2:=by
    have hh:=(Nat.ceil_lt_add_one (show 0≤1+10*(seedSlope n δ)^2 by positivity)).le
    dsimp only [seedDilution]
    linarith
  have hs:0≤seedSlope n δ:=(seedSlope_pos hn hδ).le
  have hsle:=seedSlope_upper hn hδ
  have hsδ:seedSlope n δ*δ≤17*(n:ℝ):=(le_div_iff₀ hδ).mp hsle
  have hsq:(seedSlope n δ)^2*δ^2≤289*(n:ℝ)^2:=by
    have hh:=pow_le_pow_left₀ (mul_nonneg hs hδ.le) hsδ 2
    nlinarith only [hh]
  have hb:=mul_le_mul_of_nonneg_right hceil (sq_nonneg δ)
  have hd:δ^2≤1:=by nlinarith
  nlinarith [sq_nonneg ((n:ℝ)-1)]

theorem dilutedSeedGain_inverse_polynomial {n:ℕ} (hn:0<n) {δ:ℝ} (hδ:0<δ) (hδ1:δ≤1):
    1/dilutedSeedGain n δ≤16384*(n:ℝ)^3/δ^2:=by
  have hb:=seedDilution_budget hn hδ hδ1
  have hnR:(0:ℝ)<n:=by exact_mod_cast hn
  have hPR:(0:ℝ)<(seedDilution n δ:ℝ):=by exact_mod_cast seedDilution_pos n δ
  have he:1/dilutedSeedGain n δ=32*(n:ℝ)*(seedDilution n δ:ℝ)/7:=by
    unfold dilutedSeedGain
    field_simp
  rw [he]
  apply (le_div_iff₀ (sq_pos_of_pos hδ)).mpr
  have hh:=mul_le_mul_of_nonneg_left hb (show 0≤32*(n:ℝ)/7 by positivity)
  have hp:0≤(n:ℝ)^3:=by positivity
  nlinarith only [hh,hp]

theorem dilutedSeedGain_log_budget {n:ℕ} (hn:0<n) {δ:ℝ} (hδ:0<δ) (hδ1:δ≤1):
    Real.log (1/dilutedSeedGain n δ)≤14+3*Real.log (n:ℝ)+2*Real.log (1/δ):=by
  have hnR:(0:ℝ)<n:=by exact_mod_cast hn
  have hg:=dilutedSeedGain_pos hn δ
  have hh:=Real.log_le_log (one_div_pos.mpr hg) (dilutedSeedGain_inverse_polynomial hn hδ hδ1)
  have he:Real.log (16384*(n:ℝ)^3/δ^2)=
      Real.log (16384:ℝ)+3*Real.log (n:ℝ)+2*Real.log (1/δ):=by
    rw [Real.log_div (by positivity) (by positivity),Real.log_mul (by norm_num) (by positivity),
      Real.log_pow,Real.log_pow,Real.log_div (by norm_num) hδ.ne',Real.log_one]
    ring
  rw [he] at hh
  have hnum:Real.log (16384:ℝ)≤14:=by
    have he:(16384:ℝ)=2^14:=by norm_num
    rw [he,Real.log_pow]
    have h2:=Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at *
    linarith
  linarith

end NeuralGeneralization.BatchTwoContinuousDepthCritical
