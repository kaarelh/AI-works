import ExactTargetProgram
import ScalarPathScoreProgram

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
namespace ConditionalNonpolynomial.Analytic

/-- Universal (loose) polynomial exponent for all target signal coordinates. -/
def targetSignalExponent : ℝ := 25+3*targetCoolingLogConstant

theorem targetSignalExponent_pos : 0<targetSignalExponent := by
  unfold targetSignalExponent
  linarith [targetCoolingLogConstant_pos]

theorem logarithm_half_le {R : ℝ} (hR : 2≤R) : 1/2≤Real.log R := by
  have hh := Real.le_log_one_add_of_nonneg (show (0:ℝ)≤1 by norm_num)
  norm_num at hh
  have hm := hh.trans (Real.log_le_log (by norm_num : (0:ℝ)<2) hR)
  linarith

theorem cooledSeedFloor_polynomial {v R : ℝ} (hv : 0<v) (hR : 2≤R)
    (hvR : 1/R^23≤v) (H : ℕ) (hHR : (H:ℝ)+1≤R) :
    Real.exp (-targetSignalExponent*Real.log R)≤cooledSeedFloor v H/2 := by
  have hR0 : 0<R := by linarith
  have hL := logarithm_half_le hR
  have hK := targetCoolingLogConstant_pos
  have hHlog := Real.log_le_log (by positivity : 0<(H:ℝ)+1) hHR
  have hlogTwo := Real.log_le_log (by norm_num : (0:ℝ)<2) hR
  have hseed : Real.exp (-(23:ℝ)*Real.log R)≤v := by
    have he : Real.exp (-(23:ℝ)*Real.log R)=1/R^23 := by
      have hm := Real.exp_nat_mul (Real.log R) 23
      norm_num only [Nat.cast_ofNat] at hm
      rw [neg_mul,Real.exp_neg,hm,Real.exp_log hR0]
      simp only [one_div]
    rw [he]
    exact hvR
  have hcool : Real.exp (-3*targetCoolingLogConstant*Real.log R)≤
      Real.exp (-2*(1+Real.log ((H:ℝ)+1))/
        (NeuralGeneralization.BatchTwoContinuousDepthCritical.coolingConstant*
          NeuralGeneralization.BatchTwoContinuousDepthCritical.derivativeFloor)) := by
    apply Real.exp_le_exp.mpr
    have he : -2*(1+Real.log ((H:ℝ)+1))/
        (NeuralGeneralization.BatchTwoContinuousDepthCritical.coolingConstant*
          NeuralGeneralization.BatchTwoContinuousDepthCritical.derivativeFloor)=
        -targetCoolingLogConstant*(1+Real.log ((H:ℝ)+1)) := by
      unfold targetCoolingLogConstant
      ring
    rw [he]
    nlinarith
  have hhalf : Real.exp (-2*Real.log R)≤1/2 := by
    apply (Real.exp_le_exp.mpr (show -2*Real.log R≤-Real.log 2 by linarith)).trans_eq
    rw [Real.exp_neg,Real.exp_log (by norm_num : (0:ℝ)<2)]
    norm_num
  have hprod := mul_le_mul hseed hcool (Real.exp_pos _).le hv.le
  have hprod' := mul_le_mul hprod hhalf (Real.exp_pos _).le
    (mul_nonneg hv.le (Real.exp_pos _).le)
  have he : Real.exp (-(23:ℝ)*Real.log R)*
      Real.exp (-3*targetCoolingLogConstant*Real.log R)*Real.exp (-2*Real.log R)=
      Real.exp (-targetSignalExponent*Real.log R) := by
    rw [← Real.exp_add,← Real.exp_add]
    congr 1
    unfold targetSignalExponent
    ring
  rw [he] at hprod'
  simpa only [cooledSeedFloor,div_eq_mul_inv,one_mul] using hprod'

theorem polynomialFloor_score_bound {v r R : ℝ} (hR : 2≤R) (P : ScalarChannelPath v r)
    (hfloor : P.SignalFloor (Real.exp (-targetSignalExponent*Real.log R))) (j : ℕ) (z : ℝ) :
    |P.score j z|≤Real.exp (targetSignalExponent*Real.log R) := by
  let β := Real.exp (-targetSignalExponent*Real.log R)
  have hβ : 0<β := Real.exp_pos _
  have hD : 0≤targetSignalExponent*Real.log R :=
    mul_nonneg targetSignalExponent_pos.le (by linarith [logarithm_half_le hR])
  have hβ1 : β≤1 := Real.exp_le_one_iff.mpr (by nlinarith)
  have hs : β≤Real.sqrt β := by
    apply (sq_le_sq₀ hβ.le (Real.sqrt_nonneg _)).mp
    rw [Real.sq_sqrt hβ.le]
    nlinarith
  apply (P.score_bound hβ hfloor j z).trans
  apply max_le (Real.one_le_exp_iff.mpr hD)
  have hh := one_div_le_one_div_of_le hβ hs
  have he : 1/β=Real.exp (targetSignalExponent*Real.log R) := by
    dsimp [β]
    rw [neg_mul,Real.exp_neg]
    simp
  exact hh.trans_eq he

#print axioms cooledSeedFloor_polynomial
#print axioms polynomialFloor_score_bound
end ConditionalNonpolynomial.Analytic
