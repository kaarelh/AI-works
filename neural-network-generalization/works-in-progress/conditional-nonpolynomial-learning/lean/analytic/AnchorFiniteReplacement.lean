import FieldAnchorReplacement

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.RobustEntropy

variable {X A : Type*} [MeasurableSpace X] [MeasurableSpace A]
  [StandardBorelSpace X] [StandardBorelSpace A] [Nonempty X] [Nonempty A]

theorem anchorReplacement_graph_support_of_anchor_ac (Q G : Measure X)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] {a : X → A} (ha : Measurable a)
    (hac : Q.map a≪G.map a) :
    ∀ᵐp ∂anchorReplacement (Q.map (anchorGraph a)) (G.map (anchorGraph a)), a p.2=p.1 := by
  letI : IsProbabilityMeasure (Q.map (anchorGraph a)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph ha).aemeasurable
  letI : IsProbabilityMeasure (G.map (anchorGraph a)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph ha).aemeasurable
  have hac' : (Q.map (anchorGraph a)).fst≪(G.map (anchorGraph a)).fst := by
    simpa only [anchorGraph_fst] using hac
  have hR := hac'.compProd_left (G.map (anchorGraph a)).condKernel
  rw [Measure.disintegrate (G.map (anchorGraph a)) (G.map (anchorGraph a)).condKernel] at hR
  apply hR
  change ∀ᵐp ∂G.map (anchorGraph a),a p.2=p.1
  rw [ae_map_iff (measurable_anchorGraph ha).aemeasurable]
  · exact Filter.Eventually.of_forall fun x => rfl
  · exact measurableSet_eq_fun (ha.comp measurable_snd) measurable_fst

/-- Only the anchor marginal must be absolutely continuous. The original
full field may be singular relative to the new canonical reference. -/
theorem fieldAnchorReplacement_graph_of_anchor_ac (Q G : Measure X)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] {a : X → A} (ha : Measurable a)
    (hac : Q.map a≪G.map a) :
    (fieldAnchorReplacement Q G a).map (anchorGraph a)=
      anchorReplacement (Q.map (anchorGraph a)) (G.map (anchorGraph a)) := by
  unfold fieldAnchorReplacement Measure.snd
  rw [Measure.map_map (measurable_anchorGraph ha) measurable_snd]
  have heq : (fun p:A×X => anchorGraph a p.2)=ᵐ[
      anchorReplacement (Q.map (anchorGraph a)) (G.map (anchorGraph a))] id := by
    filter_upwards [anchorReplacement_graph_support_of_anchor_ac Q G ha hac] with p hp
    exact Prod.ext hp rfl
  simp only [Function.comp_def]
  rw [Measure.map_congr heq,Measure.map_id]

theorem fieldAnchorReplacement_anchors_of_anchor_ac (Q G : Measure X)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] {a : X → A} (ha : Measurable a)
    (hac : Q.map a≪G.map a) : (fieldAnchorReplacement Q G a).map a=Q.map a := by
  letI : IsProbabilityMeasure (Q.map (anchorGraph a)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph ha).aemeasurable
  letI : IsProbabilityMeasure (G.map (anchorGraph a)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph ha).aemeasurable
  have hh := congrArg Measure.fst (fieldAnchorReplacement_graph_of_anchor_ac Q G ha hac)
  rw [anchorGraph_fst,anchorReplacement_fst,anchorGraph_fst] at hh
  exact hh

theorem fieldAnchorReplacement_kl_of_anchor_ac (Q G : Measure X)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] {a : X → A} (ha : Measurable a)
    (hac : Q.map a≪G.map a) :
    klDiv (fieldAnchorReplacement Q G a) G=klDiv (Q.map a) (G.map a) := by
  letI : IsProbabilityMeasure (Q.map (anchorGraph a)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph ha).aemeasurable
  letI : IsProbabilityMeasure (G.map (anchorGraph a)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph ha).aemeasurable
  letI := fieldAnchorReplacement_probability Q G ha
  apply le_antisymm
  · have hh := klDiv_map_le
      (anchorReplacement (Q.map (anchorGraph a)) (G.map (anchorGraph a)))
      (G.map (anchorGraph a)) measurable_snd
    change klDiv (fieldAnchorReplacement Q G a) (G.map (anchorGraph a)).snd≤_ at hh
    rw [anchorGraph_snd G ha,anchorReplacement_kl,anchorGraph_fst,anchorGraph_fst] at hh
    exact hh
  · have hh := klDiv_map_le (fieldAnchorReplacement Q G a) G ha
    rw [fieldAnchorReplacement_anchors_of_anchor_ac Q G ha hac] at hh
    exact hh

theorem fieldAnchorReplacement_query_of_anchor_ac (Q G : Measure X)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] {a : X → A} (ha : Measurable a)
    (hac : Q.map a≪G.map a) {g : X → ℝ} (hg : Measurable g) :
    (fieldAnchorReplacement Q G a).map (fun x => (a x,g x))=
      anchorReplacement (Q.map (fun x => (a x,g x))) (G.map (fun x => (a x,g x))) := by
  letI : IsProbabilityMeasure (Q.map (anchorGraph a)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph ha).aemeasurable
  letI : IsProbabilityMeasure (G.map (anchorGraph a)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph ha).aemeasurable
  have hac' : (Q.map (anchorGraph a)).fst≪(G.map (anchorGraph a)).fst := by
    simpa only [anchorGraph_fst] using hac
  have hh := anchorReplacement_query_consistent
    (Q.map (anchorGraph a)) (G.map (anchorGraph a)) hg hac'
  rw [← fieldAnchorReplacement_graph_of_anchor_ac Q G ha hac] at hh
  simp only [Measure.map_map (measurable_anchorQueryMap hg) (measurable_anchorGraph ha)] at hh
  exact hh

#print axioms fieldAnchorReplacement_kl_of_anchor_ac
#print axioms fieldAnchorReplacement_query_of_anchor_ac
end ConditionalNonpolynomial.Analytic
