import StatisticEntropyLift

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic

variable {A B C : Type*} [MeasurableSpace A] [MeasurableSpace B] [MeasurableSpace C]
  [StandardBorelSpace A] [StandardBorelSpace B] [StandardBorelSpace C]
  [Nonempty A] [Nonempty B] [Nonempty C]

/-- A reference conditional mixture commutes with applying any measurable
query map to its second coordinate. -/
theorem conditional_mixture_map (G : Measure (A × B)) [IsProbabilityMeasure G]
    (ν : Measure A) [IsProbabilityMeasure ν] {g : B → C} (hg : Measurable g)
    (hac : ν≪G.fst) :
    (ν ⊗ₘ G.condKernel).map (anchorQueryMap g)=
      ν ⊗ₘ (G.map (anchorQueryMap g)).condKernel := by
  let D : Measure (A × B) := ν.prod G.snd
  have hDf : D.fst=ν := by exact Measure.fst_prod
  have hDA : D.fst≪G.fst := by rwa [hDf]
  have hh := anchorReplacement_query_consistent D G hg hDA
  unfold anchorReplacement at hh
  rw [hDf,anchorQueryMap_fst D hg,hDf] at hh
  exact hh

#print axioms conditional_mixture_map
end ConditionalNonpolynomial.Analytic
