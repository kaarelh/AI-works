import StableScalarPathLift
import ScalarChannelSequence

noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

/-- Replay the actual nominal controls with a residual Gaussian component.
The lifted path has the same number of layers and exactly the same hidden
entropy charges; only its terminal readout cost increases. -/
theorem exists_stable_scalar_channel_path {q δ : ℝ} (p : ScalarPath q)
    (hδ : 0 ≤ δ) (hδ1 : δ < 1) (hsmall : 4*(p.length : ℝ)*δ ≤ 1) :
    ∃ P : ScalarChannelPath q δ,
      P.length=p.length ∧
      (∀ j ≤ p.length, P.state j=liftedScalarState p δ j) ∧
      (∀ j < p.length, P.control j=p.control j) ∧
      P.hiddenCost=(∑ j ∈ Finset.range p.length,p.charge j) ∧
      P.cost ≤ p.cost+4*(p.length : ℝ)*δ/(8*p.state p.length) := by
  obtain ⟨P,hlen,hstate,hcontrol⟩ := ScalarChannelPath.exists_of_sequence p.length
    (liftedScalarState p δ) p.control
    (fun j hj => ⟨(liftedScalarState_bounds p hδ hδ1 j hj).1,
      (liftedScalarState_bounds p hδ hδ1 j hj).2.2.2.1⟩)
    (fun j _ => p.control_probability j) (fun j _ => p.control_finiteKL j)
    (fun j _ => rfl)
  have hcost : P.hiddenCost=∑ j ∈ Finset.range p.length,p.charge j := by
    rw [P.hiddenCost_eq_sum,hlen]
    apply Finset.sum_congr rfl
    intro j hj
    rw [hcontrol j (Finset.mem_range.mp hj)]
    rfl
  refine ⟨P,hlen,hstate,hcontrol,hcost,?_⟩
  have ht : P.terminal=liftedScalarState p δ p.length := by
    rw [← P.state_terminal,hlen,hstate p.length le_rfl]
  have hr := liftedScalarState_readout p hδ hδ1 hsmall
  rw [add_div] at hr
  rw [ScalarChannelPath.cost,ht,hcost,p.cost_eq_sum]
  linarith

theorem stable_scalar_channel_path_relative_cost {q δ : ℝ} (p : ScalarPath q)
    (hδ : 0 ≤ δ) (hδ1 : δ < 1) (hsmall : 4*(p.length : ℝ)*δ ≤ 1) :
    ∃ P : ScalarChannelPath q δ,
      P.length=p.length ∧ P.cost ≤ (1+4*(p.length : ℝ)*δ)*p.cost ∧
      (∀ j ≤ p.length, 0 < (P.state j).1 ∧
        (1-δ)^(2*j)*p.state j ≤ (P.state j).1 ∧ (P.state j).2 ≤ δ) := by
  obtain ⟨P,hlen,hstate,hcontrol,hhidden,hcost⟩ := exists_stable_scalar_channel_path p hδ hδ1 hsmall
  have hnon : 0 ≤ ∑ j ∈ Finset.range p.length,p.charge j :=
    Finset.sum_nonneg fun j _ => ENNReal.toReal_nonneg
  have hr : 1/(8*p.state p.length) ≤ p.cost := by rw [p.cost_eq_sum]; linarith
  have hm := mul_le_mul_of_nonneg_left hr (show 0 ≤ 4*(p.length : ℝ)*δ by positivity)
  refine ⟨P,hlen,?_,?_⟩
  · have he : 4*(p.length : ℝ)*δ*(1/(8*p.state p.length))=
        4*(p.length : ℝ)*δ/(8*p.state p.length) := by ring
    rw [he] at hm
    nlinarith
  · intro j hj
    rw [hstate j hj]
    have hb := liftedScalarState_bounds p hδ hδ1 j hj
    exact ⟨hb.1,hb.2.2.1,hb.2.2.2.2⟩

#print axioms stable_scalar_channel_path_relative_cost
end ConditionalNonpolynomial.Analytic
