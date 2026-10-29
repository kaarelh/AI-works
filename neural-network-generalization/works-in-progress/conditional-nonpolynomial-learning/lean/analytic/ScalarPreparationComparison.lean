import ExactGaussianPreparation
import StableScalarChannelPath

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
namespace ConditionalNonpolynomial.Analytic
open scoped BigOperators ENNReal

theorem ScalarChannelPath.exists_stable_continuation {v r q : ℝ}
    (prep : ScalarChannelPath v r) (nominal : ScalarPath q)
    (ht : prep.terminal.1=q) (hδ : 0≤prep.terminal.2) (hδ1 : prep.terminal.2<1)
    (hsmall : 4*(nominal.length:ℝ)*prep.terminal.2≤1) :
    ∃ C : ScalarChannelPath v r,
      C.length=prep.length+nominal.length ∧
      (∀ j<prep.length,C.control j=prep.control j) ∧
      (∀ j<nominal.length,C.control (prep.length+j)=nominal.control j) ∧
      C.cost≤prep.hiddenCost+(1+4*(nominal.length:ℝ)*prep.terminal.2)*nominal.cost := by
  subst q
  obtain ⟨tail,htailLen,htailState,htailControl,htailHidden,htailCost⟩ :=
    exists_stable_scalar_channel_path nominal hδ hδ1 hsmall
  have hnon : 0≤∑ j∈Finset.range nominal.length,nominal.charge j :=
    Finset.sum_nonneg fun j _ => ENNReal.toReal_nonneg
  have hread : 1/(8*nominal.state nominal.length)≤nominal.cost := by
    rw [nominal.cost_eq_sum]
    linarith
  have hm := mul_le_mul_of_nonneg_left hread
    (show 0≤4*(nominal.length:ℝ)*prep.terminal.2 by positivity)
  have hcost : tail.cost≤(1+4*(nominal.length:ℝ)*prep.terminal.2)*nominal.cost := by
    have he : 4*(nominal.length:ℝ)*prep.terminal.2*(1/(8*nominal.state nominal.length))=
        4*(nominal.length:ℝ)*prep.terminal.2/(8*nominal.state nominal.length) := by ring
    rw [he] at hm
    nlinarith
  refine ⟨prep.append tail,?_,?_,?_,?_⟩
  · rw [prep.append_length,htailLen]
  · intro j hj
    exact prep.append_control_prefix tail j hj
  · intro j hj
    rw [prep.append_control_suffix]
    exact htailControl j hj
  · rw [prep.append_cost]
    linarith

#print axioms ScalarChannelPath.exists_stable_continuation
end ConditionalNonpolynomial.Analytic
