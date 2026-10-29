import NeuralGeneralization.BatchTwoContinuousDepthCriticalPopulation

noncomputable section
open MeasureTheory ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.BatchTwoContinuousDepthCritical

def steeringSignal (a r : ℝ) : ℝ :=
  ∫ z, (shiftedMean r (Real.sqrt a*z))^2 ∂gaussianReal 0 1

theorem steering_mean_continuous (a r : ℝ) :
    Continuous (fun z => shiftedMean r (Real.sqrt a*z)) :=
  shiftedMean_continuous.comp (continuous_const.prodMk (by fun_prop))

theorem steering_mean_memLp (a r : ℝ) :
    MemLp (fun z => shiftedMean r (Real.sqrt a*z)) 2 (gaussianReal 0 1) := by
  apply MemLp.of_bound (steering_mean_continuous a r).aestronglyMeasurable 1
  filter_upwards [] with z
  simpa only [Real.norm_eq_abs] using shiftedMean_abs_le_one r (Real.sqrt a*z)

theorem steeringSignal_nonneg (a r : ℝ) : 0 ≤ steeringSignal a r :=
  integral_nonneg (fun _ => sq_nonneg _)

end ConditionalNonpolynomial.Analytic
