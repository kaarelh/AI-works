import NeuralGeneralization.BatchTwoContinuousDepthCriticalScalar

/-! A genuine Gaussian recursion loses only polynomial seed amplitude over
arbitrarily many free layers: its diagonal decreases quadratically. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel TanhDifferential BatchTwoNonGaussian

def coolingInterval : Set ℝ := Icc (1/2) 1
def coolingMass : ℝ := (gaussianReal 0 1).real coolingInterval
def coolingConstant : ℝ := coolingMass/96
def derivativeFloor : ℝ := coolingMass*(1-(Real.tanh 1)^2)

theorem coolingMass_pos : 0<coolingMass := by
  apply ENNReal.toReal_pos
  · intro hz
    have hv := (gaussianReal_absolutelyContinuous' 0 (by norm_num : (1:NNReal)≠0)) hz
    norm_num [coolingInterval,Real.volume_Icc] at hv
  · exact measure_ne_top _ _

theorem coolingConstant_pos : 0<coolingConstant := div_pos coolingMass_pos (by norm_num)

theorem derivativeFloor_pos : 0<derivativeFloor := by
  apply mul_pos coolingMass_pos
  have hs := (sq_lt_one_iff_abs_lt_one _).mpr (Real.abs_tanh_lt_one (1:ℝ))
  linarith

theorem coolingSecondMoment_quadratic {q : ℝ} (hq : 0≤q) (hq1 : q≤1) :
    coolingSecondMoment q≤q-coolingConstant*q^2 := by
  have hgauss : (∫ z:ℝ,z^2 ∂gaussianReal 0 1)=1 := standardGaussian.square_integral
  have hdiff : Integrable (fun z:ℝ=>q*z^2-(Real.tanh (Real.sqrt q*z))^2) (gaussianReal 0 1) :=
    (standardGaussian.square_integrable.const_mul q).sub (cooling_second_integrable q)
  have hpoint (z:ℝ) : coolingInterval.indicator (fun _ : ℝ=>q^2/96) z≤
      q*z^2-(Real.tanh (Real.sqrt q*z))^2 := by
    by_cases hz : z∈coolingInterval
    · rw [Set.indicator_of_mem hz]
      have hz' : 1/2≤z ∧ z≤1 := hz
      have hsqrt := Real.sq_sqrt hq
      have hsqrtle : Real.sqrt q≤1 := (Real.sqrt_le_one).mpr hq1
      have hu : |Real.sqrt q*z|≤1 := by
        rw [abs_of_nonneg (mul_nonneg (Real.sqrt_nonneg _) (by linarith))]
        nlinarith
      have hl := tanh_quartic_loss hu
      have hpow : z^4≥1/16 := by
        have hzz : z^2≥1/4 := by nlinarith
        nlinarith [sq_nonneg (z^2-1/4)]
      have hh := mul_le_mul_of_nonneg_left hpow (sq_nonneg q)
      have he : (Real.sqrt q*z)^4=q^2*z^4 := by rw [mul_pow,show (Real.sqrt q)^4=((Real.sqrt q)^2)^2 by ring,hsqrt]
      rw [he,mul_pow,hsqrt] at hl
      nlinarith
    · rw [Set.indicator_of_notMem hz]
      have hh := pow_le_pow_left₀ (abs_nonneg _) (abs_tanh_le_abs (Real.sqrt q*z)) 2
      simp only [sq_abs,mul_pow,Real.sq_sqrt hq] at hh
      linarith
  have hi := (integrable_const (μ := gaussianReal 0 1) (q^2/96 : ℝ)).indicator (show MeasurableSet coolingInterval from measurableSet_Icc)
  have hh := integral_mono hi hdiff hpoint
  rw [integral_indicator (show MeasurableSet coolingInterval from measurableSet_Icc),setIntegral_const,smul_eq_mul,
    integral_sub (show Integrable (fun z:ℝ=>q*z^2) (gaussianReal 0 1) from standardGaussian.square_integrable.const_mul q) (cooling_second_integrable q),
    integral_const_mul,hgauss,mul_one] at hh
  change coolingMass*(q^2/96)≤q-coolingSecondMoment q at hh
  unfold coolingConstant
  nlinarith

theorem coolingDerivative_ge_floor {q : ℝ} (hq : 0≤q) (hq1 : q≤1) :
    derivativeFloor≤coolingDerivative q := by
  have ht0 : 0≤Real.tanh 1 := by
    simpa only [Real.tanh_zero] using BatchTwoNonGaussian.tanh_monotone (show (0:ℝ)≤1 by norm_num)
  have hp (z:ℝ) : coolingInterval.indicator (fun _ : ℝ=>1-(Real.tanh 1)^2) z≤tanhFirst (Real.sqrt q*z) := by
    by_cases hz : z∈coolingInterval
    · rw [Set.indicator_of_mem hz]
      have hz' : 1/2≤z ∧ z≤1 := hz
      have hsqrtle : Real.sqrt q≤1 := Real.sqrt_le_one.mpr hq1
      have hu : 0≤Real.sqrt q*z := mul_nonneg (Real.sqrt_nonneg _) (by linarith)
      have hu1 : Real.sqrt q*z≤1 := by nlinarith [Real.sqrt_nonneg q]
      have ht := BatchTwoNonGaussian.tanh_monotone hu1
      have ht' : 0≤Real.tanh (Real.sqrt q*z) := by
        simpa only [Real.tanh_zero] using BatchTwoNonGaussian.tanh_monotone hu
      have hh := pow_le_pow_left₀ ht' ht 2
      unfold tanhFirst
      linarith
    · rw [Set.indicator_of_notMem hz]
      exact tanhFirst_nonneg _
  have hi := (integrable_const (μ := gaussianReal 0 1) (1-(Real.tanh 1)^2 : ℝ)).indicator
    (show MeasurableSet coolingInterval from measurableSet_Icc)
  have hh := integral_mono hi (cooling_derivative_integrable q) hp
  rw [integral_indicator (show MeasurableSet coolingInterval from measurableSet_Icc),setIntegral_const,smul_eq_mul] at hh
  exact hh

theorem cooling_log_loss {q : ℝ} (hq : 0≤q) (hq1 : q≤1) :
    -Real.log (coolingDerivative q)≤q/derivativeFloor := by
  have hh := coolingDerivative_pos q
  have hlog := Real.log_le_sub_one_of_pos (inv_pos.mpr hh)
  rw [Real.log_inv] at hlog
  have hF := coolingSecondMoment_nonneg q
  have hFq := coolingSecondMoment_le q hq
  have hfloor := coolingDerivative_ge_floor hq hq1
  have he : (coolingDerivative q)⁻¹-1=coolingSecondMoment q/coolingDerivative q := by
    rw [coolingDerivative_eq]
    have hn : 1-coolingSecondMoment q≠0 := by rw [←coolingDerivative_eq]; exact hh.ne'
    field_simp
    ring
  rw [he] at hlog
  have hfrac := div_le_div_of_nonneg_left hF derivativeFloor_pos hfloor
  exact hlog.trans (hfrac.trans (div_le_div_of_nonneg_right hFq derivativeFloor_pos.le))

end NeuralGeneralization.BatchTwoContinuousDepthCritical
