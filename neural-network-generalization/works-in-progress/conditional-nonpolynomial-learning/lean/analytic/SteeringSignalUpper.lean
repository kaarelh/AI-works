import SteeringSignal
import ShiftedMeanGeometry

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.BatchTwoContinuousDepthCritical

theorem steeringSignal_le {a : ℝ} (ha : 0 ≤ a) (r : ℝ) :
    steeringSignal a r ≤ a := by
  have hp (z : ℝ) : (shiftedMean r (Real.sqrt a*z))^2 ≤ a*z^2 := by
    have hh := pow_le_pow_left₀ (abs_nonneg _) (shiftedMean_abs_le_abs r (Real.sqrt a*z)) 2
    simpa only [sq_abs,mul_pow,Real.sq_sqrt ha] using hh
  have hh := integral_mono (steering_mean_memLp a r).integrable_sq
    (BatchTwoNonGaussian.standardGaussian.square_integrable.const_mul a) hp
  have hg : (∫ z : ℝ, z^2 ∂gaussianReal 0 1)=1 :=
    BatchTwoNonGaussian.standardGaussian.square_integral
  rw [integral_const_mul,hg,mul_one] at hh
  exact hh

theorem steeringSignal_le_one (a r : ℝ) : steeringSignal a r ≤ 1 := by
  have hp (z : ℝ) : (shiftedMean r (Real.sqrt a*z))^2 ≤ 1 :=
    (sq_le_one_iff_abs_le_one _).mpr (shiftedMean_abs_le_one _ _)
  have hh := integral_mono (steering_mean_memLp a r).integrable_sq (integrable_const 1) hp
  simpa only [steeringSignal,integral_const,probReal_univ,smul_eq_mul,mul_one,one_mul] using hh

theorem steeringSignal_continuous : Continuous (fun p : ℝ×ℝ => steeringSignal p.1 p.2) := by
  unfold steeringSignal
  apply continuous_of_dominated
    (F := fun (p : ℝ×ℝ) (z : ℝ) => (shiftedMean p.2 (Real.sqrt p.1*z))^2)
    (bound := fun _ : ℝ => 1)
    (fun p => (steering_mean_memLp p.1 p.2).integrable_sq.aestronglyMeasurable)
    (fun p => Filter.Eventually.of_forall fun z => by
      rw [Real.norm_eq_abs,abs_of_nonneg (sq_nonneg _)]
      exact (sq_le_one_iff_abs_le_one _).mpr (shiftedMean_abs_le_one _ _))
    (integrable_const 1)
  filter_upwards [] with z
  exact (shiftedMean_continuous.comp
    (continuous_snd.prodMk ((Real.continuous_sqrt.comp continuous_fst).mul continuous_const))).pow 2

theorem steeringSignal_monotone (r : ℝ) : Monotone (fun a : ℝ => steeringSignal a r) := by
  intro a b hab
  apply integral_mono (steering_mean_memLp a r).integrable_sq (steering_mean_memLp b r).integrable_sq
  intro z
  have hs := Real.sqrt_le_sqrt hab
  by_cases hz : 0 ≤ z
  · have hn := shiftedMean_nonneg (mul_nonneg (Real.sqrt_nonneg a) hz) r
    have hm := shiftedMean_monotone r (mul_le_mul_of_nonneg_right hs hz)
    exact pow_le_pow_left₀ hn hm 2
  · have hz' : 0 ≤ -z := by linarith
    have hn := shiftedMean_nonneg (mul_nonneg (Real.sqrt_nonneg a) hz') r
    have hm := shiftedMean_monotone r (mul_le_mul_of_nonneg_right hs hz')
    have hh := pow_le_pow_left₀ hn hm 2
    simpa only [mul_neg,shiftedMean_odd,neg_sq] using hh

#print axioms steeringSignal_continuous
#print axioms steeringSignal_monotone
end ConditionalNonpolynomial.Analytic
