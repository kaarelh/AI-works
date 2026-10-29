import SteeringSignalLower
import SteeringSignalUpper
import SteeringTotalVariance
import SteeringGrowthArithmetic
import GaussianVarianceKL
import Mathlib.Topology.Order.IntermediateValue

/-! Exact cheap holding and prescribed growth for the actual Gaussian tanh
moment map. Existence of the inflation parameter is proved by continuity. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic

def steeringControl (ε : ℝ) : Measure ℝ := gaussianReal 0 (Real.toNNReal (1+ε))

instance steeringControl_probability (ε : ℝ) : IsProbabilityMeasure (steeringControl ε) := by
  unfold steeringControl
  infer_instance

theorem steeringControl_kl_ne_top {ε : ℝ} (hε : 0 ≤ ε) :
    klDiv (steeringControl ε) (gaussianReal 0 1) ≠ ∞ := by
  apply gaussian_variance_kl_ne_top
  exact ne_of_gt (Real.toNNReal_pos.mpr (by positivity))

theorem steeringControl_kl_le {ε : ℝ} (hε : 0 ≤ ε) :
    (klDiv (steeringControl ε) (gaussianReal 0 1)).toReal ≤ ε^2/4 := by
  have hv : (1 : ℝ≥0) ≤ Real.toNNReal (1+ε) := by
    apply NNReal.coe_le_coe.mp
    rw [Real.coe_toNNReal _ (by positivity)]
    exact le_add_of_nonneg_right hε
  have hh := gaussian_variance_kl_quadratic _ hv
  rw [Real.coe_toNNReal _ (by positivity)] at hh
  simpa only [steeringControl,add_sub_cancel_left] using hh

theorem steering_inflation_upper_endpoint {v r : ℝ}
    (hv : 0 ≤ v) (hr : 0 ≤ r) (hq : v+r ≤ 1/128) :
    v*(1+4*(v+r)) ≤ steeringSignal ((1+16*(v+r))*v) r := by
  apply (inflation_growth_lower_numeric hv hr hq).trans
  apply steeringSignal_lower (by positivity) hr
  have hh := inflation_total_variance_bound hv hr hq
  linarith

theorem exists_exact_steering {v r w : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hq : v+r ≤ 1/128) (hvw : v ≤ w) (hw : w ≤ v*(1+4*(v+r))) :
    ∃ ε ∈ Icc 0 (16*(v+r)), steeringSignal ((1+ε)*v) r = w := by
  have hparam : Continuous (fun ε : ℝ => (((1+ε)*v),r)) := by fun_prop
  have hcont := steeringSignal_continuous.comp hparam
  change Continuous (fun ε : ℝ => steeringSignal ((1+ε)*v) r) at hcont
  have hlow : steeringSignal ((1+(0:ℝ))*v) r ≤ w := by
    simpa only [add_zero,one_mul] using (steeringSignal_le hv r).trans hvw
  have hhigh : w ≤ steeringSignal ((1+16*(v+r))*v) r :=
    hw.trans (steering_inflation_upper_endpoint hv hr hq)
  exact intermediate_value_Icc (by positivity : (0:ℝ) ≤ 16*(v+r))
    hcont.continuousOn ⟨hlow,hhigh⟩

/-- The chosen control is an actual probability law with finite Mathlib KL,
not an assumed scalar control cost. -/
theorem exact_steering_step {v r w : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hq : v+r ≤ 1/128) (hvw : v ≤ w) (hw : w ≤ v*(1+4*(v+r))) :
    ∃ ε : ℝ, 0 ≤ ε ∧ ε ≤ 16*(v+r) ∧
      steeringSignal ((1+ε)*v) r = w ∧
      0 ≤ steeringResidual ((1+ε)*v) r ∧
      steeringResidual ((1+ε)*v) r ≤ r ∧
      klDiv (steeringControl ε) (gaussianReal 0 1) ≠ ∞ ∧
      (klDiv (steeringControl ε) (gaussianReal 0 1)).toReal ≤ 64*(v+r)^2 := by
  obtain ⟨ε,hε,heq⟩ := exists_exact_steering hv hr hq hvw hw
  refine ⟨ε,hε.1,hε.2,heq,steeringResidual_nonneg _ _,steeringResidual_le hr _,
    steeringControl_kl_ne_top hε.1,?_⟩
  have hkl := steeringControl_kl_le hε.1
  have hs := pow_le_pow_left₀ hε.1 hε.2 2
  nlinarith

theorem exact_holding_step {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hq : v+r ≤ 1/128) :
    ∃ ε : ℝ, 0 ≤ ε ∧ ε ≤ 16*(v+r) ∧
      steeringSignal ((1+ε)*v) r = v ∧
      0 ≤ steeringResidual ((1+ε)*v) r ∧
      steeringResidual ((1+ε)*v) r ≤ r ∧
      klDiv (steeringControl ε) (gaussianReal 0 1) ≠ ∞ ∧
      (klDiv (steeringControl ε) (gaussianReal 0 1)).toReal ≤ 64*(v+r)^2 := by
  apply exact_steering_step hv hr hq le_rfl
  nlinarith [mul_nonneg hv (add_nonneg hv hr)]

/-- Once the residual is below the target component, exact holding also
strictly contracts that residual. -/
theorem exact_purification_step {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hrv : r ≤ v) (hq : v+r ≤ 1/128) :
    ∃ ε : ℝ, 0 ≤ ε ∧ ε ≤ 16*(v+r) ∧
      steeringSignal ((1+ε)*v) r = v ∧
      0 ≤ steeringResidual ((1+ε)*v) r ∧
      steeringResidual ((1+ε)*v) r ≤ (1-purificationRate*v)*r ∧
      klDiv (steeringControl ε) (gaussianReal 0 1) ≠ ∞ ∧
      (klDiv (steeringControl ε) (gaussianReal 0 1)).toReal ≤ 256*v^2 := by
  obtain ⟨ε,hε,hbound,heq,hr0,hrle,hfinite,hcost⟩ := exact_holding_step hv hr hq
  refine ⟨ε,hε,hbound,heq,hr0,?_,hfinite,?_⟩
  · apply steeringResidual_strict hr hrv
    · nlinarith [mul_nonneg hε hv]
    · linarith
  · have hs := pow_le_pow_left₀ (add_nonneg hv hr) (show v+r ≤ 2*v by linarith) 2
    nlinarith

#print axioms exact_steering_step
#print axioms exact_purification_step
end ConditionalNonpolynomial.Analytic
