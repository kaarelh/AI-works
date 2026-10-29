import ConditionalMeanScore
import ScoreDowngrade

noncomputable section
set_option maxHeartbeats 1200000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.BatchTwoContinuousDepthCritical

def prescribedScoreRatio (Q : Measure ℝ) (a r s : ℝ) : ℝ :=
  Real.sqrt s / Real.sqrt (controlledSignal Q a r)

def prescribedConditionalScore (Q : Measure ℝ) (a r s : ℝ) : ℝ×Bool → ℝ :=
  downgradedScore (prescribedScoreRatio Q a r s) (normalizedConditionalScore Q a r)

theorem prescribedScoreRatio_bounds (Q : Measure ℝ) {a r s : ℝ}
    (hs : 0<s) (hsS : s≤controlledSignal Q a r) :
    0≤prescribedScoreRatio Q a r s ∧ prescribedScoreRatio Q a r s≤1 := by
  have hS := hs.trans_le hsS
  exact ⟨div_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _),
    (div_le_one (Real.sqrt_pos.mpr hS)).mpr (Real.sqrt_le_sqrt hsS)⟩

theorem prescribedConditionalScore_measurable (Q : Measure ℝ) (a r s : ℝ) :
    Measurable (prescribedConditionalScore Q a r s) :=
  downgradedScore_measurable _ _ (normalizedConditionalScore_measurable Q a r)

theorem prescribedConditionalScore_bound (Q : Measure ℝ) {a r s : ℝ}
    (hs : 0<s) (hsS : s≤controlledSignal Q a r) (p : ℝ×Bool) :
    |prescribedConditionalScore Q a r s p|≤1/Real.sqrt s+1 := by
  have hS := hs.trans_le hsS
  have ha := prescribedScoreRatio_bounds Q hs hsS
  have hh := downgradedScore_bound (normalizedConditionalScore Q a r) ha.1 ha.2
    (show 0≤1/Real.sqrt (controlledSignal Q a r) by positivity)
    (normalizedConditionalScore_bound Q a r hS) p
  have hinv := one_div_le_one_div_of_le (Real.sqrt_pos.mpr hs) (Real.sqrt_le_sqrt hsS)
  unfold prescribedConditionalScore
  linarith

theorem prescribedConditionalScore_unit (Q : Measure ℝ) [IsProbabilityMeasure Q]
    {a r s : ℝ} (hs : 0<s) (hsS : s≤controlledSignal Q a r) :
    (∫p,(prescribedConditionalScore Q a r s p)^2 ∂Q.prod scoreSignLaw)=1 := by
  have hS := hs.trans_le hsS
  have ha := prescribedScoreRatio_bounds Q hs hsS
  exact downgradedScore_unit Q (normalizedConditionalScore Q a r) ha.1 ha.2
    (show 0≤1/Real.sqrt (controlledSignal Q a r) by positivity)
    (normalizedConditionalScore_measurable Q a r)
    (normalizedConditionalScore_bound Q a r hS)
    (normalizedConditionalScore_unit Q a r hS)

def taggedSignedScalarFeature (a r : ℝ) (f : Bool) (p : (ℝ×Bool)×ℝ) : ℝ :=
  signedScalarFeature a r f (p.1.1,p.2)

theorem taggedSignedScalarFeature_measurable (a r : ℝ) (f : Bool) :
    Measurable (taggedSignedScalarFeature a r f) := by
  unfold taggedSignedScalarFeature
  exact (signedScalarFeature_measurable a r f).comp
    ((measurable_fst.comp measurable_fst).prodMk measurable_snd)

theorem prescribedConditionalScore_correlation (Q : Measure ℝ) [IsProbabilityMeasure Q]
    {a r s : ℝ} (hs : 0<s) (hsS : s≤controlledSignal Q a r) (f : Bool) :
    (∫p,prescribedConditionalScore Q a r s p.1*taggedSignedScalarFeature a r f p
      ∂(Q.prod scoreSignLaw).prod (gaussianReal 0 1))=labelReal f*Real.sqrt s := by
  have hS := hs.trans_le hsS
  have ha := prescribedScoreRatio_bounds Q hs hsS
  have hlabel : |labelReal f|=1 := by cases f <;> norm_num [labelReal]
  have hf : Measurable (fun z:ℝ=>labelReal f*shiftedMean r (Real.sqrt a*z)) :=
    ((shiftedMean_continuous.comp (continuous_const.prodMk (by fun_prop))).measurable).const_mul _
  have hfB (z:ℝ) : |labelReal f*shiftedMean r (Real.sqrt a*z)|≤1 := by
    rw [abs_mul,hlabel,one_mul]
    exact shiftedMean_abs_le_one _ _
  have hi : Integrable (fun p=>prescribedConditionalScore Q a r s p.1*
      taggedSignedScalarFeature a r f p) ((Q.prod scoreSignLaw).prod (gaussianReal 0 1)) := by
    apply Integrable.of_bound (((prescribedConditionalScore_measurable Q a r s).comp
      measurable_fst).mul (taggedSignedScalarFeature_measurable a r f)).aestronglyMeasurable
      (1/Real.sqrt s+1)
    filter_upwards [] with p
    change |prescribedConditionalScore Q a r s p.1*taggedSignedScalarFeature a r f p|≤_
    rw [abs_mul]
    exact (mul_le_mul (prescribedConditionalScore_bound Q hs hsS p.1)
      (Real.abs_tanh_lt_one _).le (abs_nonneg _) (by positivity)).trans_eq (mul_one _)
  have hi0 : Integrable (fun p:ℝ×ℝ=>normalizedConditionalScore Q a r p.1*
      signedScalarFeature a r f p) (Q.prod (gaussianReal 0 1)) := by
    apply Integrable.of_bound (((normalizedConditionalScore_measurable Q a r).comp
      measurable_fst).mul (signedScalarFeature_measurable a r f)).aestronglyMeasurable
      (1/Real.sqrt (controlledSignal Q a r))
    filter_upwards [] with p
    change |normalizedConditionalScore Q a r p.1*signedScalarFeature a r f p|≤_
    rw [abs_mul]
    exact (mul_le_mul (normalizedConditionalScore_bound Q a r hS p.1)
      (Real.abs_tanh_lt_one _).le (abs_nonneg _) (by positivity)).trans_eq (mul_one _)
  have hc := normalizedConditionalScore_correlation Q a r hS f
  rw [integral_prod _ hi0] at hc
  simp_rw [integral_const_mul,signedScalarFeature_mean] at hc
  rw [integral_prod _ hi]
  simp_rw [taggedSignedScalarFeature,integral_const_mul,signedScalarFeature_mean]
  rw [prescribedConditionalScore,downgradedScore_correlation Q _ _ ha.1 ha.2
    (show 0≤1/Real.sqrt (controlledSignal Q a r) by positivity)
    (normalizedConditionalScore_measurable Q a r) hf
    (normalizedConditionalScore_bound Q a r hS) hfB,hc]
  unfold prescribedScoreRatio
  field_simp

theorem taggedSignedScalarFeature_total_second (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (a r : ℝ) (f : Bool) :
    (∫p,(taggedSignedScalarFeature a r f p)^2
      ∂(Q.prod scoreSignLaw).prod (gaussianReal 0 1))=
      controlledSignal Q a r+controlledResidual Q a r := by
  have hi : Integrable (fun p=>(taggedSignedScalarFeature a r f p)^2)
      ((Q.prod scoreSignLaw).prod (gaussianReal 0 1)) := by
    apply Integrable.of_bound ((taggedSignedScalarFeature_measurable a r f).pow_const 2).aestronglyMeasurable 1
    filter_upwards [] with p
    rw [Real.norm_eq_abs,abs_of_nonneg (sq_nonneg _)]
    exact (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one _).le
  have hi0 : Integrable (fun p:ℝ×ℝ=>(signedScalarFeature a r f p)^2)
      (Q.prod (gaussianReal 0 1)) := by
    apply Integrable.of_bound ((signedScalarFeature_measurable a r f).pow_const 2).aestronglyMeasurable 1
    filter_upwards [] with p
    rw [Real.norm_eq_abs,abs_of_nonneg (sq_nonneg _)]
    exact (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one _).le
  have hh := signedScalarFeature_total_second Q a r f
  rw [integral_prod _ hi0] at hh
  simp_rw [signedScalarFeature_second] at hh
  rw [integral_prod _ hi]
  simp_rw [taggedSignedScalarFeature,signedScalarFeature_second]
  calc
    _ = ∫z,shiftedSecond r (Real.sqrt a*z) ∂Q := by
      simpa only [probReal_univ,one_smul] using
        (integral_fun_fst (μ:=Q) (ν:=scoreSignLaw) (fun z=>shiftedSecond r (Real.sqrt a*z)))
    _ = _ := hh

/-- An actual bounded unit score selecting any smaller positive signal component;
its independent sign tag costs exactly zero relative entropy. -/
theorem scalarSourceMoment_prescribedConditionalScore (Q : Measure ℝ) [IsProbabilityMeasure Q]
    {a r s : ℝ} (hr : 0≤r) (hs : 0<s) (hsS : s≤controlledSignal Q a r) (f : Bool) :
    scalarSourceMoment (Q.prod scoreSignLaw) Prod.fst (prescribedConditionalScore Q a r s)
      (WithLp.toLp 2 (labelReal f*Real.sqrt a,Real.sqrt r))=
      WithLp.toLp 2 (labelReal f*Real.sqrt s,
        Real.sqrt (controlledSignal Q a r+controlledResidual Q a r-s)) := by
  have hfeature : scalarChannelFeature (scalarSourceCoordinates (Prod.fst : ℝ×Bool→ℝ))
      (channelPairCoefficients (WithLp.toLp 2 (labelReal f*Real.sqrt a,Real.sqrt r)))=
      taggedSignedScalarFeature a r f := by
    funext p
    unfold scalarChannelFeature scalarSourceCoordinates
    rw [channelPair_linear]
    rfl
  unfold scalarSourceMoment scalarChannelMoment
  rw [hfeature,prescribedConditionalScore_correlation Q hs hsS f,
    taggedSignedScalarFeature_total_second Q a r f]
  have hsq : ‖labelReal f*Real.sqrt s‖^2=s := by
    rw [Real.norm_eq_abs,sq_abs,mul_pow,Real.sq_sqrt hs.le]
    cases f <;> simp
  have hR := (controlledResidual_bounds Q hr a).1
  unfold canonicalCompletion
  rw [hsq,max_eq_right (show 0≤controlledSignal Q a r+controlledResidual Q a r-s by linarith)]

#print axioms scalarSourceMoment_prescribedConditionalScore
#print axioms prescribedConditionalScore_unit
end ConditionalNonpolynomial.Analytic
