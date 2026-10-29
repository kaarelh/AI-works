import SteeringExactSteps

noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic

theorem steering_inflation_budget_endpoint {v r δ : ℝ}
    (hv : 0 ≤ v) (hr : 0 ≤ r) (hrδ : r ≤ δ) (hq : v+δ ≤ 1/128) :
    v*(1+4*(v+δ)) ≤ steeringSignal ((1+16*(v+δ))*v) r := by
  have hδ := hr.trans hrδ
  let a := (1+16*(v+δ))*v
  have ha : 0 ≤ a := by dsimp [a]; positivity
  have hu : a+δ ≤ (9/8:ℝ)*(v+δ) := inflation_total_variance_bound hv hδ hq
  have hnon : 0 ≤ 1-a-δ := by linarith
  have hsq := pow_le_pow_left₀ hnon (show 1-a-δ ≤ 1-a-r by linarith) 2
  have hlo := inflation_growth_lower_numeric hv hδ hq
  have hmid := mul_le_mul_of_nonneg_left hsq ha
  have hupper := steeringSignal_lower ha hr (show a+r ≤ 1 by linarith)
  exact hlo.trans (hmid.trans hupper)

theorem exists_exact_steering_budget {v r δ w : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hrδ : r ≤ δ) (hq : v+δ ≤ 1/128) (hvw : v ≤ w)
    (hw : w ≤ v*(1+4*(v+δ))) :
    ∃ ε ∈ Icc 0 (16*(v+δ)), steeringSignal ((1+ε)*v) r = w := by
  have hparam : Continuous (fun ε : ℝ => (((1+ε)*v),r)) := by fun_prop
  have hcont := steeringSignal_continuous.comp hparam
  change Continuous (fun ε : ℝ => steeringSignal ((1+ε)*v) r) at hcont
  have hlow : steeringSignal ((1+(0:ℝ))*v) r ≤ w := by
    simpa only [add_zero,one_mul] using (steeringSignal_le hv r).trans hvw
  have hhigh := hw.trans (steering_inflation_budget_endpoint hv hr hrδ hq)
  exact intermediate_value_Icc (by linarith : (0:ℝ) ≤ 16*(v+δ))
    hcont.continuousOn ⟨hlow,hhigh⟩

theorem exact_steering_budget {v r δ w : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hrδ : r ≤ δ) (hq : v+δ ≤ 1/128) (hvw : v ≤ w)
    (hw : w ≤ v*(1+4*(v+δ))) :
    ∃ ε : ℝ, 0 ≤ ε ∧ ε ≤ 16*(v+δ) ∧
      steeringSignal ((1+ε)*v) r = w ∧
      0 ≤ steeringResidual ((1+ε)*v) r ∧
      steeringResidual ((1+ε)*v) r ≤ r ∧
      klDiv (steeringControl ε) (gaussianReal 0 1) ≠ ∞ ∧
      (klDiv (steeringControl ε) (gaussianReal 0 1)).toReal ≤ 64*(v+δ)^2 := by
  obtain ⟨ε,hε,heq⟩ := exists_exact_steering_budget hv hr hrδ hq hvw hw
  refine ⟨ε,hε.1,hε.2,heq,steeringResidual_nonneg _ _,steeringResidual_le hr _,
    steeringControl_kl_ne_top hε.1,?_⟩
  have hkl := steeringControl_kl_le hε.1
  have hs := pow_le_pow_left₀ hε.1 hε.2 2
  nlinarith

#print axioms exact_steering_budget
end ConditionalNonpolynomial.Analytic
