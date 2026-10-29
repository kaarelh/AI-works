import AnchorReplacement

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.RobustEntropy NeuralGeneralization.RobustCoupling

variable {A B C : Type*} [MeasurableSpace A] [MeasurableSpace B] [MeasurableSpace C]
  [StandardBorelSpace A] [StandardBorelSpace B] [StandardBorelSpace C]
  [Nonempty A] [Nonempty B] [Nonempty C]

def anchorQueryMap (g : B → C) (p : A × B) : A × C := (p.1,g p.2)

lemma measurable_anchorQueryMap {g : B → C} (hg : Measurable g) : Measurable (anchorQueryMap g : A × B → A × C) :=
  measurable_fst.prodMk (hg.comp measurable_snd)

lemma anchorQueryMap_fst (Q : Measure (A × B)) {g : B → C} (hg : Measurable g) :
    (Q.map (anchorQueryMap g)).fst=Q.fst := by
  have hh := Measure.fst_map_prodMk (X:=Prod.fst) (Y:=fun p:A×B => g p.2) (hg.comp measurable_snd) (μ:=Q)
  exact hh

/-- Query projection commutes with replacement by the reference conditional
law. Thus all query replacements arise from one full-field measure, rather
than from an unrelated choice for every query. -/
theorem anchorReplacement_query_consistent (Q G : Measure (A × B))
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    {g : B → C} (hg : Measurable g) (hac : Q.fst≪G.fst) :
    (anchorReplacement Q G).map (anchorQueryMap g)=
      anchorReplacement (Q.map (anchorQueryMap g)) (G.map (anchorQueryMap g)) := by
  have hm := measurable_anchorQueryMap (A:=A) hg
  let Qg := Q.map (anchorQueryMap g)
  let Gg := G.map (anchorQueryMap g)
  let η : Kernel A C := G.condKernel.map g
  letI : IsMarkovKernel η := Kernel.IsMarkovKernel.map _ hg
  letI : IsProbabilityMeasure Qg := Measure.isProbabilityMeasure_map hm.aemeasurable
  letI : IsProbabilityMeasure Gg := Measure.isProbabilityMeasure_map hm.aemeasurable
  have hη (a:A) : (G.condKernel a).map g=η a := (Kernel.map_apply G.condKernel hg a).symm
  have hmap (μ:Measure A) [IsProbabilityMeasure μ] :
      (μ ⊗ₘ G.condKernel).map (anchorQueryMap g)=μ ⊗ₘ η := by
    have hh := map_compProd_pair μ G.condKernel η id g measurable_id hg hη
    change (μ ⊗ₘ G.condKernel).map (fun p => (p.1,g p.2))=μ ⊗ₘ η
    simpa only [Measure.map_id,id_eq] using hh
  have hGmap : Gg=G.fst ⊗ₘ η := by
    have hh := hmap G.fst
    rw [Measure.disintegrate G G.condKernel] at hh
    exact hh
  have hGfst : Gg.fst=G.fst := anchorQueryMap_fst G hg
  have hQfst : Qg.fst=Q.fst := anchorQueryMap_fst Q hg
  have hk : Gg.condKernel=ᵐ[G.fst] η := by
    apply Kernel.ae_eq_of_compProd_eq
    have hdis := Measure.disintegrate Gg Gg.condKernel
    rw [hGfst] at hdis
    exact hdis.trans hGmap
  have hkQ : Gg.condKernel=ᵐ[Q.fst] η := hac hk
  change (Q.fst ⊗ₘ G.condKernel).map (anchorQueryMap g)=Qg.fst ⊗ₘ Gg.condKernel
  rw [hmap Q.fst,hQfst,Measure.compProd_congr hkQ]

/-- Finite original KL automatically supplies the absolute continuity needed
for query consistency, including singular reference Gaussian laws. -/
theorem anchorReplacement_query_consistent_of_finite (Q G : Measure (A × B))
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    {g : B → C} (hg : Measurable g) (hfinite : klDiv Q G≠∞) :
    (anchorReplacement Q G).map (anchorQueryMap g)=
      anchorReplacement (Q.map (anchorQueryMap g)) (G.map (anchorQueryMap g)) := by
  have hanchor : klDiv Q.fst G.fst≠∞ :=
    ne_top_of_le_ne_top hfinite (klDiv_fst_le Q G)
  exact anchorReplacement_query_consistent Q G hg (klDiv_ne_top_iff.mp hanchor).1

#print axioms anchorReplacement_query_consistent_of_finite
end ConditionalNonpolynomial.Analytic
