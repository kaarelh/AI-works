import SmoothedTanhNoise
import SteeringTotalVariance
import SteeringSignalUpper

noncomputable section
open MeasureTheory ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.BatchTwoContinuousDepthCritical

theorem coolingSecondMoment_monotone_nonnegative {a b : ℝ} (ha : 0 ≤ a) (hab : a ≤ b) :
    coolingSecondMoment a ≤ coolingSecondMoment b := by
  apply integral_mono (cooling_second_integrable a) (cooling_second_integrable b)
  intro z
  apply tanh_square_mono_abs
  rw [abs_mul,abs_mul,abs_of_nonneg (Real.sqrt_nonneg a),abs_of_nonneg (Real.sqrt_nonneg b)]
  exact mul_le_mul_of_nonneg_right (Real.sqrt_le_sqrt hab) (abs_nonneg z)

theorem steeringSignal_antitone_noise {r s : ℝ} (hr : 0 ≤ r) (hrs : r ≤ s) (a : ℝ) :
    steeringSignal a s ≤ steeringSignal a r := by
  exact integral_mono (steering_mean_memLp a s).integrable_sq (steering_mean_memLp a r).integrable_sq
    (fun z => shiftedMean_square_antitone_noise hr hrs (Real.sqrt a*z))

/-- Reuse a critical Gaussian stage under any smaller residual noise. Keeping
exactly the critical signal component leaves no more residual variance than
the critical comparator. The score-downgrade construction supplies the actual
score realizing this prescribed component. -/
theorem gaussian_stage_reuse {a r rCrit t : ℝ}
    (ha : 0 ≤ a) (hr : 0 ≤ r) (hrr : r ≤ rCrit) (ht : 0 ≤ t) (ht1 : t ≤ 1) :
    steeringSignal a rCrit ≤ steeringSignal a (t^2*r) ∧
    0 ≤ coolingSecondMoment (a+t^2*r)-steeringSignal a rCrit ∧
    coolingSecondMoment (a+t^2*r)-steeringSignal a rCrit ≤ steeringResidual a rCrit ∧
    coolingSecondMoment (a+t^2*r) ≤ 1 := by
  have hnoise : 0 ≤ t^2*r := mul_nonneg (sq_nonneg _) hr
  have hnoiseLe : t^2*r ≤ rCrit := by
    have ht2 : t^2 ≤ 1 := by nlinarith
    have hm := mul_le_mul_of_nonneg_right ht2 hr
    linarith
  have hsig := steeringSignal_antitone_noise hnoise hnoiseLe a
  have htotal := steeringSignal_add_residual ha hnoise
  have hcrit := steeringSignal_add_residual ha (hr.trans hrr)
  have hq := coolingSecondMoment_monotone_nonnegative (add_nonneg ha hnoise)
    (show a+t^2*r ≤ a+rCrit by linarith)
  refine ⟨hsig,?_,?_,?_⟩
  · linarith [steeringResidual_nonneg a (t^2*r)]
  · linarith
  · have hp (z : ℝ) : (Real.tanh (Real.sqrt (a+t^2*r)*z))^2 ≤ 1 :=
      (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one _).le
    have hh := integral_mono (cooling_second_integrable (a+t^2*r)) (integrable_const 1) hp
    simpa only [coolingSecondMoment,integral_const,probReal_univ,smul_eq_mul,one_mul] using hh

#print axioms gaussian_stage_reuse
end ConditionalNonpolynomial.Analytic
