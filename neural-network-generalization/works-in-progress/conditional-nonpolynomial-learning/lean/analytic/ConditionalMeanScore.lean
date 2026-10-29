import SteeringScalarLift
import SplitRowChannelError

noncomputable section
set_option maxHeartbeats 800000
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.BatchTwoContinuousDepthCritical

def normalizedConditionalScore (Q : Measure ℝ) (a r : ℝ) (z : ℝ) : ℝ :=
  shiftedMean r (Real.sqrt a*z)/Real.sqrt (controlledSignal Q a r)

theorem normalizedConditionalScore_measurable (Q : Measure ℝ) (a r : ℝ) :
    Measurable (normalizedConditionalScore Q a r) :=
  ((shiftedMean_continuous.comp (continuous_const.prodMk (by fun_prop))).measurable).div_const _

theorem normalizedConditionalScore_bound (Q : Measure ℝ) (a r : ℝ)
    (hS : 0<controlledSignal Q a r) (z : ℝ) :
    |normalizedConditionalScore Q a r z|≤1/Real.sqrt (controlledSignal Q a r) := by
  unfold normalizedConditionalScore
  rw [abs_div,abs_of_pos (Real.sqrt_pos.mpr hS)]
  exact div_le_div_of_nonneg_right (shiftedMean_abs_le_one _ _) (Real.sqrt_nonneg _)

theorem normalizedConditionalScore_memLp (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (a r : ℝ) (hS : 0<controlledSignal Q a r) :
    MemLp (normalizedConditionalScore Q a r) 2 Q :=
  MemLp.of_bound (normalizedConditionalScore_measurable Q a r).aestronglyMeasurable
    (1/Real.sqrt (controlledSignal Q a r))
    (ae_of_all _ fun z=>by simpa only [Real.norm_eq_abs] using normalizedConditionalScore_bound Q a r hS z)

theorem normalizedConditionalScore_unit (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (a r : ℝ) (hS : 0<controlledSignal Q a r) :
    (∫z,(normalizedConditionalScore Q a r z)^2 ∂Q)=1 := by
  simp only [normalizedConditionalScore,div_pow]
  rw [integral_div,Real.sq_sqrt hS.le]
  change controlledSignal Q a r/controlledSignal Q a r=1
  exact div_self hS.ne'

theorem shiftedSecond_even (r a : ℝ) : shiftedSecond r (-a)=shiftedSecond r a := by
  have hmp : MeasurePreserving (MeasurableEquiv.neg ℝ)
      (gaussianReal 0 1) (gaussianReal 0 1) := by
    refine ⟨by fun_prop,?_⟩
    simpa only [MeasurableEquiv.neg_apply,neg_zero] using
      (gaussianReal_map_neg (μ:=(0:ℝ)) (v:=(1:ℝ≥0)))
  have hh := hmp.integral_comp' (fun z : ℝ=>(Real.tanh (-a+Real.sqrt r*z))^2)
  have he (z : ℝ) : (Real.tanh (-a+Real.sqrt r*(-z)))^2=
      (Real.tanh (a+Real.sqrt r*z))^2 := by
    rw [show -a+Real.sqrt r*(-z)=-(a+Real.sqrt r*z) by ring,Real.tanh_neg,neg_sq]
  simpa only [MeasurableEquiv.neg_apply,he,shiftedSecond] using hh.symm

def signedScalarFeature (a r : ℝ) (f : Bool) (p : ℝ×ℝ) : ℝ :=
  Real.tanh (labelReal f*Real.sqrt a*p.1+Real.sqrt r*p.2)

theorem signedScalarFeature_measurable (a r : ℝ) (f : Bool) :
    Measurable (signedScalarFeature a r f) := by unfold signedScalarFeature; fun_prop

theorem signedScalarFeature_mean (a r : ℝ) (f : Bool) (z : ℝ) :
    (∫g,signedScalarFeature a r f (z,g) ∂gaussianReal 0 1)=
      labelReal f*shiftedMean r (Real.sqrt a*z) := by
  cases f
  · change shiftedMean r (-1*Real.sqrt a*z)= -1*shiftedMean r (Real.sqrt a*z)
    simpa only [neg_one_mul,neg_mul,one_mul] using shiftedMean_odd r (Real.sqrt a*z)
  · simp only [signedScalarFeature,labelReal_true,one_mul,shiftedMean]

theorem signedScalarFeature_second (a r : ℝ) (f : Bool) (z : ℝ) :
    (∫g,(signedScalarFeature a r f (z,g))^2 ∂gaussianReal 0 1)=
      shiftedSecond r (Real.sqrt a*z) := by
  cases f
  · change shiftedSecond r (-1*Real.sqrt a*z)=_
    simpa only [neg_one_mul,neg_mul,one_mul] using shiftedSecond_even r (Real.sqrt a*z)
  · simp only [signedScalarFeature,labelReal_true,one_mul,shiftedSecond]

theorem normalizedConditionalScore_correlation (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (a r : ℝ) (hS : 0<controlledSignal Q a r) (f : Bool) :
    (∫p,normalizedConditionalScore Q a r p.1*signedScalarFeature a r f p
      ∂Q.prod (gaussianReal 0 1))=labelReal f*Real.sqrt (controlledSignal Q a r) := by
  have hi : Integrable (fun p : ℝ×ℝ=>normalizedConditionalScore Q a r p.1*
      signedScalarFeature a r f p) (Q.prod (gaussianReal 0 1)) := by
    apply Integrable.of_bound
      (((normalizedConditionalScore_measurable Q a r).comp measurable_fst).mul
        (signedScalarFeature_measurable a r f)).aestronglyMeasurable
      (1/Real.sqrt (controlledSignal Q a r))
    filter_upwards [] with p
    change |normalizedConditionalScore Q a r p.1*signedScalarFeature a r f p|≤_
    rw [abs_mul]
    exact (mul_le_mul (normalizedConditionalScore_bound Q a r hS p.1)
      (Real.abs_tanh_lt_one _).le (abs_nonneg _) (by positivity)).trans_eq (mul_one _)
  rw [integral_prod _ hi]
  simp_rw [integral_const_mul,signedScalarFeature_mean]
  have he (z : ℝ) : normalizedConditionalScore Q a r z*
      (labelReal f*shiftedMean r (Real.sqrt a*z))=
      (labelReal f/Real.sqrt (controlledSignal Q a r))*(shiftedMean r (Real.sqrt a*z))^2 := by
    unfold normalizedConditionalScore
    ring
  simp_rw [he]
  rw [integral_const_mul]
  change (labelReal f/Real.sqrt (controlledSignal Q a r))*controlledSignal Q a r=_
  have hs : Real.sqrt (controlledSignal Q a r)≠0 := (Real.sqrt_pos.mpr hS).ne'
  calc
    _ = (labelReal f/Real.sqrt (controlledSignal Q a r))*(Real.sqrt (controlledSignal Q a r))^2 := by
      rw [Real.sq_sqrt hS.le]
    _ = _ := by field_simp

theorem signedScalarFeature_total_second (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (a r : ℝ) (f : Bool) :
    (∫p,(signedScalarFeature a r f p)^2 ∂Q.prod (gaussianReal 0 1))=
      controlledSignal Q a r+controlledResidual Q a r := by
  have hi : Integrable (fun p : ℝ×ℝ=>(signedScalarFeature a r f p)^2)
      (Q.prod (gaussianReal 0 1)) := by
    apply Integrable.of_bound ((signedScalarFeature_measurable a r f).pow_const 2).aestronglyMeasurable 1
    filter_upwards [] with p
    rw [Real.norm_eq_abs,abs_of_nonneg (sq_nonneg _)]
    exact (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one _).le
  rw [integral_prod _ hi]
  simp_rw [signedScalarFeature_second]
  unfold controlledSignal controlledResidual
  rw [←integral_add (controlledSignal_integrable Q a r) (controlledResidual_integrable Q a r)]
  apply integral_congr_ae
  filter_upwards [] with z
  unfold shiftedVariance
  ring

/-- The actual scalar-channel moment recursion generated by the normalized
conditional-mean score, valid for arbitrary scalar controls. -/
theorem scalarSourceMoment_normalizedConditionalScore (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (a r : ℝ) (hr : 0≤r) (hS : 0<controlledSignal Q a r) (f : Bool) :
    scalarSourceMoment Q id (normalizedConditionalScore Q a r)
      (WithLp.toLp 2 (labelReal f*Real.sqrt a,Real.sqrt r))=
      WithLp.toLp 2 (labelReal f*Real.sqrt (controlledSignal Q a r),
        Real.sqrt (controlledResidual Q a r)) := by
  have hfeature : scalarChannelFeature (scalarSourceCoordinates (id : ℝ→ℝ))
      (channelPairCoefficients (WithLp.toLp 2 (labelReal f*Real.sqrt a,Real.sqrt r)))=
      signedScalarFeature a r f := by
    funext p
    unfold scalarChannelFeature scalarSourceCoordinates
    rw [channelPair_linear]
    rfl
  unfold scalarSourceMoment scalarChannelMoment
  rw [hfeature,normalizedConditionalScore_correlation Q a r hS f,
    signedScalarFeature_total_second Q a r f]
  have hs : ‖labelReal f*Real.sqrt (controlledSignal Q a r)‖^2=controlledSignal Q a r := by
    rw [Real.norm_eq_abs,sq_abs,mul_pow,Real.sq_sqrt hS.le]
    cases f <;> simp
  have hR := (controlledResidual_bounds Q hr a).1
  unfold canonicalCompletion
  rw [hs,add_sub_cancel_left,max_eq_right hR]

#print axioms normalizedConditionalScore_correlation
#print axioms signedScalarFeature_total_second
#print axioms scalarSourceMoment_normalizedConditionalScore
end ConditionalNonpolynomial.Analytic
