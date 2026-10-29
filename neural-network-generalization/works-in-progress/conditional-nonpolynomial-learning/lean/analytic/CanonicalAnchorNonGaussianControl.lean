import CanonicalAnchorStep
import GaussianLinearStatisticMinimal

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2200000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal NNReal BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.RobustEntropy
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt
variable {X I J : Type*} [Fintype X] [DecidableEq X] [Fintype I] [DecidableEq I]
  [Fintype J] [DecidableEq J]

/-- The genuine anchor-only Gaussian completion has no more non-Gaussian
entropy than the original full coefficient row, in addition to all exact
anchor and query-law properties used by the canonical construction. -/
theorem canonical_anchor_control_nonGaussian
    (A : X→J→ℝ) (B : X→EuclideanSpace ℝ I)
    (Q : Measure (X→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (fieldLaw A)≠∞) (S : Finset X)
    (hanchor : ∀x∈S,∀y∈S,gram A x y=inner ℝ (B x) (B y))
    (Qsource : Measure (J→ℝ)) [IsProbabilityMeasure Qsource]
    (hsourceKL : klDiv Qsource (standardLaw J)≠∞)
    (hsourceMap : Qsource.map (fieldLinear A)=Q) :
    ∃L : Measure (I→ℝ), IsProbabilityMeasure L ∧
      klDiv L (standardLaw I)≠∞ ∧
      (klDiv L (standardLaw I)).toReal≤(klDiv Q (fieldLaw A)).toReal ∧
      L.map (maskCoordinates S ∘ fieldLinear (fun x i=>B x i))=Q.map (maskCoordinates S) ∧
      L.map (fieldLinear (fun x i=>B x i))=
        fieldAnchorReplacement Q (fieldLaw (fun x i=>B x i)) (maskCoordinates S) ∧
      klDiv L (matchingGaussian L)≤klDiv Qsource (matchingGaussian Qsource) := by
  let μ := standardLaw I
  let F := maskCoordinates S ∘ fieldLinear (fun x i=>B x i)
  let ν := Q.map (maskCoordinates S)
  have hF : Measurable F := (measurable_maskCoordinates S).comp (fieldLinear _).continuous.measurable
  letI : IsProbabilityMeasure ν := Measure.isProbabilityMeasure_map (measurable_maskCoordinates S).aemeasurable
  have hG := gaussian_anchor_marginal_eq A (fun x i=>B x i) S (by
    intro x hx y hy
    rw [gram_euclidean_coefficients]
    exact hanchor x hx y hy)
  have hμ : μ.map F=(fieldLaw A).map (maskCoordinates S) := by
    have hh := Measure.map_map (μ:=μ) (measurable_maskCoordinates S) (fieldLinear (fun x i=>B x i)).continuous.measurable
    exact hh.symm.trans hG.symm
  have hd : klDiv ν (μ.map F)≤klDiv Q (fieldLaw A) := by
    rw [hμ]
    exact klDiv_map_le Q (fieldLaw A) (measurable_maskCoordinates S)
  have hf : klDiv ν (μ.map F)≠∞ := ne_top_of_le_ne_top hKL hd
  let L := statisticEntropyLift μ F ν
  letI := statisticEntropyLift_probability μ F ν
  have hc : klDiv L μ=klDiv ν (μ.map F) := statisticEntropyLift_kl μ hF ν hf
  have hLKL : klDiv L (standardLaw I)≠∞ := by rw [hc]; exact hf
  have hmapL : L.map F=ν := statisticEntropyLift_map μ hF ν hf
  refine ⟨L,inferInstance,hLKL,?_,hmapL,?_,?_⟩
  · rw [hc]
    exact ENNReal.toReal_mono hKL hd
  · exact anchorStatisticLift_to_field μ Q
      (fieldLinear (fun x i=>B x i)).continuous.measurable (measurable_maskCoordinates S) hf
  · let A' := maskedField A S
    let B' := maskedField (fun x i=>B x i) S
    have hB' : fieldLinear B'=F := maskedField_linear _ _
    have hsource : Qsource.map (fieldLinear A')=ν := by
      rw [maskedField_linear,←Measure.map_map (measurable_maskCoordinates S)
        (fieldLinear A).continuous.measurable,hsourceMap]
    have hmap : Qsource.map (fieldLinear A')=L.map (fieldLinear B') := by
      rw [hB',hmapL,hsource]
    have hminimal : L=statisticEntropyLift (standardLaw I) (fieldLinear B')
        (L.map (fieldLinear B')) := by
      rw [hB',hmapL]
    exact nonGaussianKL_linearStatistic_completion Qsource L hsourceKL hLKL A' B' hmap hminimal

#print axioms canonical_anchor_control_nonGaussian
end ConditionalNonpolynomial.Analytic
