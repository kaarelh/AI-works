import NeuralGeneralization.OnlineLowerTanhScalarBudget
import NeuralGeneralization.OnlineLowerTanhPathDistinguishedBudget
import NeuralGeneralization.OnlineLowerTanhRectangleConditions

/-! # The unconditional scalar certificate for the actual tanh family

All fields concern the literal inverse balanced-neuron costs, the explicit
prefix/path candidates, and the actual split-column physical dimension. The
sign, ordering, paired-dominance and absorption premises are discharged here.
-/
noncomputable section
open scoped BigOperators Classical Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerGeometry

/-- Every fixed positive logarithmic-rail constant yields the complete
actual scalar certificate at all sufficiently large construction indices. -/
theorem construction_rectangle_scalar_certificate_eventually
    (b:ActualGainBranch) (K:ℕ) (hK:1≤K) :
    ∀ᶠk:ℕ in atTop,3≤k ∧ ∀hk:3≤k,
      RectangleScalarCertificate (constructionBaseline K k) (constructionIncrement k) k
        (constructionBaseline_pos K k (by omega)) (constructionIncrement_pos k) hk
        (constructionPrefixEnvelope K k) (20*(constructionDimension K k:ℝ)) := by
  have hC:=optimizedCostCurvature_pos
  filter_upwards [construction_rectangle_cost_conditions_eventually b K hK,
    construction_live_scalar_eventually b K hK,
    construction_candidate_injective_eventually b K hK,
    construction_distinguished_bounds_eventually b K hK,
    construction_prefix_dimension_absorption K hK
      (44*(4/optimizedCostCurvature)+34000000) (by positivity) 3,
    eventually_ge_atTop 3] with k hc hlive hinj hdist habs hk
  refine ⟨hk,?_⟩
  intro hk
  let R:=constructionBaseline K k
  let H:=constructionIncrement k
  have hR:0<R:=constructionBaseline_pos K k (by omega)
  have hH:0<H:=constructionIncrement_pos k
  refine {
    cost_conditions:=hc
    coset_order:=?_
    candidate_injective:=hinj.2 (by omega) false
    envelope_nonneg:=(constructionPrefixEnvelope_pos K k).le
    envelope:=?_
    candidate_negative:=?_
    cap_nonneg:=by positivity
    candidate_cap:=?_
    absorption:=?_ }
  · intro z hz
    have hh:=hlive false z hz
    exact ⟨hh.1.le,hh.2.1.le⟩
  · intro z hz
    exact (hlive false z hz).2.2.2
  · intro digits
    exact (hlive false (candidatePoint k (by omega) false digits)
      (candidatePoint_mem k (by omega) false digits)).2.2.1
  · intro digits
    exact rectangle_cost_lt_twenty_dimension R H k hR hH
      (constructionBaseline_even K k) (constructionIncrement_even k) _ _
  · have hb:=rectangle_rounding_polynomial_bound R H k hR hH hc
      (4/optimizedCostCurvature) (by positivity) hdist.2.2.2
    have hh:=mul_le_mul_of_nonneg_left hb (constructionPrefixEnvelope_pos K k).le
    apply hh.trans_lt
    simpa only [mul_assoc] using habs

/-- The concrete chosen analytic branch supplies the witnesses expected by
the protocol assembly, with no analytic or scalar premise remaining. -/
theorem construction_rectangle_scalar_witnesses_eventually (K:ℕ) (hK:1≤K) :
    ∀ᶠk:ℕ in atTop,∃W Bcap:ℝ,∀hk:3≤k,
      RectangleScalarCertificate (constructionBaseline K k) (constructionIncrement k) k
        (constructionBaseline_pos K k (by omega)) (constructionIncrement_pos k) hk W Bcap := by
  filter_upwards [construction_rectangle_scalar_certificate_eventually actualGainBranch K hK]
    with k hk
  exact ⟨constructionPrefixEnvelope K k,20*(constructionDimension K k:ℝ),hk.2⟩

end NeuralGeneralization.OnlineLowerTanh.Family
