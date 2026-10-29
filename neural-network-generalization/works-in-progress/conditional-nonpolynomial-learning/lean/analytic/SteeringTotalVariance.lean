import SteeringSignalLower
import GaussianConditionalVariance

noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.BatchTwoContinuousDepthCritical

theorem steering_second_moment {a r : ℝ} (ha : 0 ≤ a) (hr : 0 ≤ r) :
    (∫ z, shiftedSecond r (Real.sqrt a*z) ∂gaussianReal 0 1) =
      coolingSecondMoment (a+r) := by
  let F : ℝ × ℝ → ℝ := fun p => (Real.tanh (Real.sqrt a*p.1+Real.sqrt r*p.2))^2
  have hF : Integrable F ((gaussianReal 0 1).prod (gaussianReal 0 1)) := by
    apply Integrable.of_bound (by fun_prop) 1
    filter_upwards [] with p
    change ‖(Real.tanh (Real.sqrt a*p.1+Real.sqrt r*p.2))^2‖ ≤ 1
    rw [Real.norm_eq_abs,abs_of_nonneg (sq_nonneg _)]
    exact (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one _).le
  have hs := gaussian_row_secondMoment (![Real.sqrt a, Real.sqrt r] : Fin 2 → ℝ)
  simp only [Fin.sum_univ_two,Matrix.cons_val_zero,Matrix.cons_val_one,
    Real.sq_sqrt ha,Real.sq_sqrt hr] at hs
  change (∫ z : Fin 2 → ℝ, F (z 0,z 1) ∂Measure.pi (fun _ => gaussianReal 0 1)) = _ at hs
  rw [gaussian_pair_integral F hF] at hs
  exact hs

theorem steeringSignal_add_residual {a r : ℝ} (ha : 0 ≤ a) (hr : 0 ≤ r) :
    steeringSignal a r + steeringResidual a r = coolingSecondMoment (a+r) := by
  rw [← steering_second_moment ha hr]
  unfold steeringSignal steeringResidual
  rw [← integral_add (steering_mean_memLp a r).integrable_sq (steeringResidual_integrable a r)]
  apply integral_congr_ae
  filter_upwards [] with z
  simp only [shiftedVariance]
  ring

#print axioms steeringSignal_add_residual
end ConditionalNonpolynomial.Analytic
