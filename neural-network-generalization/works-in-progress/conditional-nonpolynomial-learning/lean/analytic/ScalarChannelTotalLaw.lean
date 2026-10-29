import ScalarChannelPath
import ScalarChannelCoordinates
import ScalarVarianceSum

/-! The total variance of an actual signal-plus-residual scalar channel is
itself an actual Gaussian-controlled scalar path, with no larger entropy. -/
noncomputable section
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.BatchTwoContinuousDepthCritical

def channelTotalCoordinate (v r : ℝ) (p : ℝ×ℝ) : ℝ :=
  (Real.sqrt v*p.1+Real.sqrt r*p.2)/Real.sqrt (v+r)

def channelTotalLaw (Q : Measure ℝ) (v r : ℝ) : Measure ℝ :=
  (Q.prod (gaussianReal 0 1)).map (channelTotalCoordinate v r)

lemma channelTotalCoordinate_measurable (v r : ℝ) : Measurable (channelTotalCoordinate v r) := by
  unfold channelTotalCoordinate
  fun_prop

instance channelTotalLaw_probability (Q : Measure ℝ) [IsProbabilityMeasure Q] (v r : ℝ) :
    IsProbabilityMeasure (channelTotalLaw Q v r) :=
  Measure.isProbabilityMeasure_map (channelTotalCoordinate_measurable v r).aemeasurable

lemma channelTotalCoordinate_reference {v r : ℝ} (hv : 0<v) (hr : 0≤r) :
    ((gaussianReal 0 1).prod (gaussianReal 0 1)).map (channelTotalCoordinate v r)=
      gaussianReal 0 1 := by
  let c : Fin 2→ℝ := ![Real.sqrt v/Real.sqrt (v+r),Real.sqrt r/Real.sqrt (v+r)]
  have hq : 0<v+r := by linarith
  have hc : ∑i,c i^2=1 := by
    simp only [c,Fin.sum_univ_two,Matrix.cons_val_zero,Matrix.cons_val_one,
      div_pow,Real.sq_sqrt hv.le,Real.sq_sqrt hr,Real.sq_sqrt hq.le]
    field_simp
  have hg := gaussian_unit_row_map c hc
  rw [←channelPairCoordinates_reference,Measure.map_map
    (show Measurable (fun z : Fin 2→ℝ=>∑i,c i*z i) by fun_prop)
    channelPairCoordinates_measurable] at hg
  convert hg using 1
  congr 1
  funext p
  simp [channelTotalCoordinate,c,channelPairCoordinates,
    MeasurableEquiv.piFinTwo_symm_apply,Fin.sum_univ_two]
  ring

theorem channelTotalLaw_entropy (Q : Measure ℝ) [IsProbabilityMeasure Q]
    {v r : ℝ} (hv : 0<v) (hr : 0≤r) :
    klDiv (channelTotalLaw Q v r) (gaussianReal 0 1)≤klDiv Q (gaussianReal 0 1) := by
  have hh := mapped_product_control_kl Q (gaussianReal 0 1) (gaussianReal 0 1) (gaussianReal 0 1)
    (channelTotalCoordinate v r) (channelTotalCoordinate_measurable v r)
  rw [channelTotalCoordinate_reference hv hr] at hh
  simpa only [klDiv_self,add_zero,channelTotalLaw] using hh

lemma totalTanh_integrable (Q : Measure ℝ) [IsProbabilityMeasure Q] (v r : ℝ) :
    Integrable (fun p : ℝ×ℝ=>(Real.tanh (Real.sqrt v*p.1+Real.sqrt r*p.2))^2)
      (Q.prod (gaussianReal 0 1)) := by
  apply Integrable.of_bound (by fun_prop) 1
  apply Filter.Eventually.of_forall
  intro p
  rw [Real.norm_eq_abs,abs_of_nonneg (sq_nonneg _)]
  exact (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one _).le

theorem controlledTotal_integral (Q : Measure ℝ) [IsProbabilityMeasure Q] (v r : ℝ) :
    controlledSignal Q v r+controlledResidual Q v r=
      ∫p : ℝ×ℝ,(Real.tanh (Real.sqrt v*p.1+Real.sqrt r*p.2))^2 ∂Q.prod (gaussianReal 0 1) := by
  rw [controlledSignal,controlledResidual,←integral_add
    (controlledSignal_integrable Q v r) (controlledResidual_integrable Q v r),
    integral_prod _ (totalTanh_integrable Q v r)]
  apply integral_congr_ae
  exact Filter.Eventually.of_forall fun z=>by
    change (shiftedMean r (Real.sqrt v*z))^2+
      (shiftedSecond r (Real.sqrt v*z)-(shiftedMean r (Real.sqrt v*z))^2)=
      shiftedSecond r (Real.sqrt v*z)
    ring

theorem controlledTotal_le_one (Q : Measure ℝ) [IsProbabilityMeasure Q] (v r : ℝ) :
    controlledSignal Q v r+controlledResidual Q v r≤1 := by
  rw [controlledTotal_integral]
  calc
    _ ≤ ∫_p : ℝ×ℝ,(1:ℝ) ∂Q.prod (gaussianReal 0 1) :=
      integral_mono (totalTanh_integrable Q v r) (integrable_const _)
        (fun p=>(sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one _).le)
    _ = 1 := by simp

/-- Exact actual scalar transition, not merely an entropy or variance bound. -/
theorem channelTotalLaw_transition (Q : Measure ℝ) [IsProbabilityMeasure Q]
    {v r : ℝ} (hv : 0<v) (hr : 0≤r) :
    scalarTransition (v+r) (channelTotalLaw Q v r)=
      controlledSignal Q v r+controlledResidual Q v r := by
  rw [controlledTotal_integral,scalarTransition,channelTotalLaw,
    integral_map (channelTotalCoordinate_measurable v r).aemeasurable (by unfold varianceTest; fun_prop)]
  apply integral_congr_ae
  have hq : Real.sqrt (v+r)≠0 := (Real.sqrt_pos.mpr (by linarith)).ne'
  exact Filter.Eventually.of_forall fun p=>by
    dsimp only
    unfold varianceTest channelTotalCoordinate
    rw [mul_div_cancel₀ _ hq]

#print axioms channelTotalLaw_transition
#print axioms channelTotalLaw_entropy
end ConditionalNonpolynomial.Analytic
