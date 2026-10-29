import ConditionalMeanScore
import SteeringExactSteps

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped NNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.BatchTwoContinuousDepthCritical

theorem steeringControl_scaled_map {ε : ℝ} (hε : 0≤ε) :
    (gaussianReal 0 1).map (fun z : ℝ=>Real.sqrt (1+ε)*z)=steeringControl ε := by
  rw [gaussianReal_map_const_mul,mul_zero]
  unfold steeringControl
  congr 1
  apply NNReal.coe_injective
  simp only [NNReal.coe_mul,NNReal.coe_mk,NNReal.coe_one,mul_one,
    Real.sq_sqrt (show 0≤1+ε by positivity),Real.coe_toNNReal _ (show 0≤1+ε by positivity)]

theorem controlledSignal_steeringControl {ε a : ℝ} (hε : 0≤ε) (ha : 0≤a) (r : ℝ) :
    controlledSignal (steeringControl ε) a r=steeringSignal ((1+ε)*a) r := by
  unfold controlledSignal
  have hm : Measurable (fun z : ℝ=>(shiftedMean r (Real.sqrt a*z))^2) :=
    (steering_mean_continuous a r).measurable.pow_const 2
  rw [←steeringControl_scaled_map hε,integral_map (by fun_prop) hm.aestronglyMeasurable]
  unfold steeringSignal
  apply integral_congr_ae
  filter_upwards [] with z
  rw [Real.sqrt_mul (show 0≤1+ε by positivity)]
  rw [show Real.sqrt a*(Real.sqrt (1+ε)*z)=(Real.sqrt (1+ε)*Real.sqrt a)*z by ring]

theorem controlledResidual_steeringControl {ε a : ℝ} (hε : 0≤ε) (ha : 0≤a) (r : ℝ) :
    controlledResidual (steeringControl ε) a r=steeringResidual ((1+ε)*a) r := by
  unfold controlledResidual
  have hm : Measurable (fun z : ℝ=>shiftedVariance r (Real.sqrt a*z)) :=
    (shiftedVariance_continuous.comp (continuous_const.prodMk (by fun_prop))).measurable
  rw [←steeringControl_scaled_map hε,integral_map (by fun_prop) hm.aestronglyMeasurable]
  unfold steeringResidual
  apply integral_congr_ae
  filter_upwards [] with z
  rw [Real.sqrt_mul (show 0≤1+ε by positivity)]
  rw [show Real.sqrt a*(Real.sqrt (1+ε)*z)=(Real.sqrt (1+ε)*Real.sqrt a)*z by ring]

/-- Gaussian steering is an actual bounded-score scalar channel with the
precise signal/residual recursion used by the population construction. -/
theorem steering_score_channel {ε a r : ℝ} (hε : 0≤ε) (ha : 0≤a) (hr : 0≤r)
    (hS : 0<steeringSignal ((1+ε)*a) r) (f : Bool) :
    scalarSourceMoment (steeringControl ε) id (normalizedConditionalScore (steeringControl ε) a r)
      (WithLp.toLp 2 (labelReal f*Real.sqrt a,Real.sqrt r))=
      WithLp.toLp 2 (labelReal f*Real.sqrt (steeringSignal ((1+ε)*a) r),
        Real.sqrt (steeringResidual ((1+ε)*a) r)) := by
  have hs : 0<controlledSignal (steeringControl ε) a r := by
    rw [controlledSignal_steeringControl hε ha]
    exact hS
  simpa only [controlledSignal_steeringControl hε ha,controlledResidual_steeringControl hε ha]
    using scalarSourceMoment_normalizedConditionalScore (steeringControl ε) a r hr hs f

#print axioms steering_score_channel
end ConditionalNonpolynomial.Analytic
