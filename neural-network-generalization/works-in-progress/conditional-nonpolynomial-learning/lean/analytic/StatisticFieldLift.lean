import ConditionalMixtureMap

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic

variable {Ω X A : Type*} [MeasurableSpace Ω] [MeasurableSpace X] [MeasurableSpace A]
  [StandardBorelSpace Ω] [StandardBorelSpace X] [StandardBorelSpace A]
  [Nonempty Ω] [Nonempty X] [Nonempty A]

/-- Lift the controlled anchor marginal through a reference feature map.
Pushing this common-coordinate law through the feature map produces exactly
the full anchor replacement, not merely an entropy-dominated approximation. -/
theorem anchorStatisticLift_to_field (μ : Measure Ω) [IsProbabilityMeasure μ]
    (Q : Measure X) [IsProbabilityMeasure Q] {F : Ω → X} (hF : Measurable F)
    {a : X → A} (ha : Measurable a)
    (hKL : klDiv (Q.map a) (μ.map (a ∘ F))≠∞) :
    (statisticEntropyLift μ (a ∘ F) (Q.map a)).map F=
      fieldAnchorReplacement Q (μ.map F) a := by
  let Gamma := μ.map (anchorGraph (a ∘ F))
  let ν := Q.map a
  letI : IsProbabilityMeasure Gamma :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph (ha.comp hF)).aemeasurable
  letI : IsProbabilityMeasure ν := Measure.isProbabilityMeasure_map ha.aemeasurable
  have hac : ν≪Gamma.fst := by
    rw [anchorGraph_fst]
    exact (klDiv_ne_top_iff.mp hKL).1
  have hm := conditional_mixture_map Gamma ν hF hac
  have href : Gamma.map (anchorQueryMap F)=(μ.map F).map (anchorGraph a) := by
    dsimp [Gamma]
    rw [Measure.map_map (measurable_anchorQueryMap hF) (measurable_anchorGraph (ha.comp hF)),
      Measure.map_map (measurable_anchorGraph ha) hF]
    rfl
  have hker : (Gamma.map (anchorQueryMap F)).condKernel=((μ.map F).map (anchorGraph a)).condKernel := by
    congr 1
  rw [hker] at hm
  have hms := congrArg Measure.snd hm
  have hleft : ((ν ⊗ₘ Gamma.condKernel).map (anchorQueryMap F)).snd=
      (statisticEntropyLift μ (a ∘ F) ν).map F := by
    unfold statisticEntropyLift statisticEntropyJoint Measure.snd
    rw [Measure.map_map measurable_snd (measurable_anchorQueryMap hF),
      Measure.map_map hF measurable_snd]
    rfl
  rw [hleft] at hms
  unfold fieldAnchorReplacement anchorReplacement
  rw [anchorGraph_fst]
  exact hms

#print axioms anchorStatisticLift_to_field
end ConditionalNonpolynomial.Analytic
