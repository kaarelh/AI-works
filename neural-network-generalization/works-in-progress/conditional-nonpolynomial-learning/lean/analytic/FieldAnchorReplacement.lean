import AnchorQueryConsistency

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.RobustEntropy NeuralGeneralization.RobustCoupling

variable {X A : Type*} [MeasurableSpace X] [MeasurableSpace A]
  [StandardBorelSpace X] [StandardBorelSpace A] [Nonempty X] [Nonempty A]

def anchorGraph (a : X → A) (x : X) : A × X := (a x,x)

lemma measurable_anchorGraph {a : X → A} (ha : Measurable a) : Measurable (anchorGraph a) :=
  ha.prodMk measurable_id

lemma anchorGraph_embedding {a : X → A} (ha : Measurable a) : MeasurableEmbedding (anchorGraph a) :=
  (measurable_anchorGraph ha).measurableEmbedding (by
    intro x y h
    exact congrArg Prod.snd h)

lemma anchorGraph_fst (Q : Measure X) (a : X → A) : (Q.map (anchorGraph a)).fst=Q.map a :=
  Measure.fst_map_prodMk measurable_id

lemma anchorGraph_snd (Q : Measure X) {a : X → A} (ha : Measurable a) :
    (Q.map (anchorGraph a)).snd=Q := by
  have hh := Measure.snd_map_prodMk (X:=a) (Y:=id) ha (μ:=Q)
  change (Q.map (fun x => (a x,x))).snd=Q
  simpa only [Measure.map_id,id_eq] using hh

/-- One full-field replacement retaining a specified measurable anchor map. -/
def fieldAnchorReplacement (Q G : Measure X) [IsFiniteMeasure G] (a : X → A) : Measure X :=
  (anchorReplacement (Q.map (anchorGraph a)) (G.map (anchorGraph a))).snd

lemma fieldAnchorReplacement_probability (Q G : Measure X)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] {a : X → A} (ha : Measurable a) :
    IsProbabilityMeasure (fieldAnchorReplacement Q G a) := by
  letI : IsProbabilityMeasure (Q.map (anchorGraph a)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph ha).aemeasurable
  letI : IsProbabilityMeasure (G.map (anchorGraph a)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph ha).aemeasurable
  unfold fieldAnchorReplacement
  infer_instance

/-- The joint replacement remains supported on the actual anchor graph;
absolute continuity handles reference conditionals on null anchor values. -/
theorem anchorReplacement_graph_support (Q G : Measure X)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] {a : X → A} (ha : Measurable a)
    (hfinite : klDiv Q G≠∞) :
    ∀ᵐp ∂anchorReplacement (Q.map (anchorGraph a)) (G.map (anchorGraph a)), a p.2=p.1 := by
  letI : IsProbabilityMeasure (Q.map (anchorGraph a)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph ha).aemeasurable
  letI : IsProbabilityMeasure (G.map (anchorGraph a)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph ha).aemeasurable
  have hanchor : klDiv (Q.map a) (G.map a)≠∞ :=
    ne_top_of_le_ne_top hfinite (klDiv_map_le Q G ha)
  have hR : klDiv (anchorReplacement (Q.map (anchorGraph a)) (G.map (anchorGraph a)))
      (G.map (anchorGraph a))≠∞ := by
    rw [anchorReplacement_kl,anchorGraph_fst,anchorGraph_fst]
    exact hanchor
  have hac := (klDiv_ne_top_iff.mp hR).1
  apply hac
  change ∀ᵐp ∂G.map (anchorGraph a),a p.2=p.1
  rw [ae_map_iff (measurable_anchorGraph ha).aemeasurable]
  · exact Filter.Eventually.of_forall fun x => rfl
  · exact measurableSet_eq_fun (ha.comp measurable_snd) measurable_fst

/-- Reattaching the anchors after replacement recovers the entire joint law,
so this construction is a single consistent full-field replacement. -/
theorem fieldAnchorReplacement_graph (Q G : Measure X)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] {a : X → A} (ha : Measurable a)
    (hfinite : klDiv Q G≠∞) :
    (fieldAnchorReplacement Q G a).map (anchorGraph a)=
      anchorReplacement (Q.map (anchorGraph a)) (G.map (anchorGraph a)) := by
  unfold fieldAnchorReplacement Measure.snd
  rw [Measure.map_map (measurable_anchorGraph ha) measurable_snd]
  have heq : (fun p:A×X => anchorGraph a p.2)=ᵐ[
      anchorReplacement (Q.map (anchorGraph a)) (G.map (anchorGraph a))] id := by
    filter_upwards [anchorReplacement_graph_support Q G ha hfinite] with p hp
    exact Prod.ext hp rfl
  simp only [Function.comp_def]
  rw [Measure.map_congr heq,Measure.map_id]

/-- The replacement preserves exactly the joint anchor marginal. -/
theorem fieldAnchorReplacement_anchors (Q G : Measure X)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] {a : X → A} (ha : Measurable a)
    (hfinite : klDiv Q G≠∞) : (fieldAnchorReplacement Q G a).map a=Q.map a := by
  letI : IsProbabilityMeasure (Q.map (anchorGraph a)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph ha).aemeasurable
  letI : IsProbabilityMeasure (G.map (anchorGraph a)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph ha).aemeasurable
  have hh := congrArg Measure.fst (fieldAnchorReplacement_graph Q G ha hfinite)
  rw [anchorGraph_fst,anchorReplacement_fst,anchorGraph_fst] at hh
  exact hh

/-- Relative entropy of the full replacement is exactly that of its anchors.
This applies unchanged to singular Gaussian field references. -/
theorem fieldAnchorReplacement_kl (Q G : Measure X)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] {a : X → A} (ha : Measurable a)
    (hfinite : klDiv Q G≠∞) :
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
    rw [fieldAnchorReplacement_anchors Q G ha hfinite] at hh
    exact hh

/-- Every query of the single full-field replacement has exactly the
reference-conditional query law with the retained anchor marginal. -/
theorem fieldAnchorReplacement_query (Q G : Measure X)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] {a : X → A} (ha : Measurable a)
    (hfinite : klDiv Q G≠∞) {g : X → ℝ} (hg : Measurable g) :
    (fieldAnchorReplacement Q G a).map (fun x => (a x,g x))=
      anchorReplacement (Q.map (fun x => (a x,g x))) (G.map (fun x => (a x,g x))) := by
  letI : IsProbabilityMeasure (Q.map (anchorGraph a)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph ha).aemeasurable
  letI : IsProbabilityMeasure (G.map (anchorGraph a)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph ha).aemeasurable
  have hgraphKL : klDiv (Q.map (anchorGraph a)) (G.map (anchorGraph a))≠∞ :=
    ne_top_of_le_ne_top hfinite (klDiv_map_le Q G (measurable_anchorGraph ha))
  have hh := anchorReplacement_query_consistent_of_finite
    (Q.map (anchorGraph a)) (G.map (anchorGraph a)) hg hgraphKL
  rw [← fieldAnchorReplacement_graph Q G ha hfinite] at hh
  simp only [Measure.map_map (measurable_anchorQueryMap hg) (measurable_anchorGraph ha)] at hh
  exact hh

#print axioms fieldAnchorReplacement_graph
#print axioms fieldAnchorReplacement_anchors
#print axioms fieldAnchorReplacement_kl
#print axioms fieldAnchorReplacement_query
end ConditionalNonpolynomial.Analytic
