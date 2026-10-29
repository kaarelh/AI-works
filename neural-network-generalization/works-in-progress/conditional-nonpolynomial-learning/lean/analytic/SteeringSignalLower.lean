import SteeringSignal
import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlRows
import Mathlib.MeasureTheory.Integral.Prod

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.BatchTwoContinuousDepthCritical
open NeuralGeneralization.BatchTwoNonGaussian

theorem gaussian_pair_integral (F : ℝ × ℝ → ℝ)
    (hF : Integrable F ((gaussianReal 0 1).prod (gaussianReal 0 1))) :
    (∫ z : Fin 2 → ℝ, F (z 0,z 1) ∂Measure.pi (fun _ => gaussianReal 0 1)) =
      ∫ z, ∫ w, F (z,w) ∂gaussianReal 0 1 ∂gaussianReal 0 1 := by
  have hh := (measurePreserving_piFinTwo (fun _ : Fin 2 => gaussianReal 0 1)).integral_comp
    (MeasurableEquiv.piFinTwo (fun _ : Fin 2 => ℝ)).measurableEmbedding F
  rw [MeasurableEquiv.piFinTwo_apply] at hh
  exact hh.trans (integral_prod F hF)

theorem steering_correlation_integrable (a r : ℝ) :
    Integrable (fun z : ℝ => z * shiftedMean r (Real.sqrt a*z)) (gaussianReal 0 1) := by
  have hi : Integrable (fun z : ℝ => |z|) (gaussianReal 0 1) :=
    (memLp_one_iff_integrable.mp (memLp_id_gaussianReal (μ := 0) (v := 1) 1)).abs
  apply hi.mono' (continuous_id.mul (steering_mean_continuous a r)).aestronglyMeasurable
  filter_upwards [] with z
  change ‖z*shiftedMean r (Real.sqrt a*z)‖ ≤ |z|
  rw [Real.norm_eq_abs,abs_mul]
  exact (mul_le_mul_of_nonneg_left (shiftedMean_abs_le_one _ _) (abs_nonneg z)).trans_eq (mul_one _)

theorem steering_correlation {a r : ℝ} (ha : 0 ≤ a) (hr : 0 ≤ r) :
    (∫ z, z * shiftedMean r (Real.sqrt a*z) ∂gaussianReal 0 1) =
      Real.sqrt a * coolingDerivative (a+r) := by
  let F : ℝ × ℝ → ℝ := fun p => p.1 * Real.tanh (Real.sqrt a*p.1+Real.sqrt r*p.2)
  have hF : Integrable F ((gaussianReal 0 1).prod (gaussianReal 0 1)) := by
    have hi : Integrable (fun p : ℝ × ℝ => |p.1|) ((gaussianReal 0 1).prod (gaussianReal 0 1)) :=
      ((memLp_one_iff_integrable.mp (memLp_id_gaussianReal (μ := 0) (v := 1) 1)).abs).comp_fst _
    apply hi.mono' (by fun_prop)
    filter_upwards [] with p
    change ‖p.1 * Real.tanh (Real.sqrt a*p.1+Real.sqrt r*p.2)‖ ≤ |p.1|
    rw [Real.norm_eq_abs,abs_mul]
    exact (mul_le_mul_of_nonneg_left (Real.abs_tanh_lt_one _).le (abs_nonneg _)).trans_eq (mul_one _)
  have hint := gaussian_pair_integral F hF
  have hs := gaussian_projected_tanh_zero
    (![Real.sqrt a, Real.sqrt r] : Fin 2 → ℝ) (![1,0] : Fin 2 → ℝ)
  simp only [Fin.sum_univ_two,Matrix.cons_val_zero,Matrix.cons_val_one,
    one_mul,zero_mul,add_zero,Real.sq_sqrt ha,Real.sq_sqrt hr] at hs
  change (∫ z : Fin 2 → ℝ, F (z 0,z 1) ∂Measure.pi (fun _ => gaussianReal 0 1)) = _ at hs
  rw [hint] at hs
  simp only [F,integral_const_mul] at hs
  exact hs

/-- The first Hermite projection is a genuine lower bound on the conditional
mean component. The proof is the nonnegativity of its squared residual. -/
theorem steeringSignal_ge_correlation (a r : ℝ) :
    (∫ z, z * shiftedMean r (Real.sqrt a*z) ∂gaussianReal 0 1)^2 ≤ steeringSignal a r := by
  let c := ∫ z, z * shiftedMean r (Real.sqrt a*z) ∂gaussianReal 0 1
  have hi := steering_mean_memLp a r
  have hz : MemLp (fun z : ℝ => z) 2 (gaussianReal 0 1) := memLp_id_gaussianReal 2
  have hres : 0 ≤ ∫ z : ℝ, (shiftedMean r (Real.sqrt a*z)-c*z)^2 ∂gaussianReal 0 1 :=
    integral_nonneg fun _ => sq_nonneg _
  have he (z : ℝ) : (shiftedMean r (Real.sqrt a*z)-c*z)^2 =
      (shiftedMean r (Real.sqrt a*z))^2 - (2*c)*(z*shiftedMean r (Real.sqrt a*z)) + c^2*z^2 := by ring
  simp_rw [he] at hres
  have hsub : Integrable (fun z : ℝ => (shiftedMean r (Real.sqrt a*z))^2 -
      (2*c)*(z*shiftedMean r (Real.sqrt a*z))) (gaussianReal 0 1) :=
    hi.integrable_sq.sub ((steering_correlation_integrable a r).const_mul (2*c))
  have hzsq : (∫ z : ℝ, z^2 ∂gaussianReal 0 1) = 1 := standardGaussian.square_integral
  rw [integral_add hsub (hz.integrable_sq.const_mul (c^2)),
    integral_sub hi.integrable_sq ((steering_correlation_integrable a r).const_mul (2*c)),
    integral_const_mul,integral_const_mul,hzsq] at hres
  change 0 ≤ steeringSignal a r - (2*c)*c+c^2*1 at hres
  change c^2 ≤ steeringSignal a r
  nlinarith

theorem steeringSignal_lower {a r : ℝ} (ha : 0 ≤ a) (hr : 0 ≤ r) (har : a+r ≤ 1) :
    a*(1-a-r)^2 ≤ steeringSignal a r := by
  have hc := steeringSignal_ge_correlation a r
  rw [steering_correlation ha hr,mul_pow,Real.sq_sqrt ha] at hc
  have hd : 1-a-r ≤ coolingDerivative (a+r) := by
    rw [coolingDerivative_eq]
    linarith [coolingSecondMoment_le (a+r) (add_nonneg ha hr)]
  have hs := pow_le_pow_left₀ (show 0 ≤ 1-a-r by linarith) hd 2
  exact (mul_le_mul_of_nonneg_left hs ha).trans hc

#print axioms steeringSignal_lower
end ConditionalNonpolynomial.Analytic
