import GaussianAnchorMarginal
import ActualCanonicalLayer
import StatisticEntropyLift
import StatisticFieldLift

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.RobustEntropy
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt

variable {X I J : Type*} [Fintype X] [DecidableEq X] [Fintype I] [Fintype J]

lemma gram_euclidean_coefficients (B : X → EuclideanSpace ℝ I) (x y : X) :
    gram (fun x i => B x i) x y=inner ℝ (B x) (B y) := by
  simp only [gram,PiLp.inner_apply,Real.inner_apply]

/-- Build the genuine Gaussian-coordinate control for a canonical layer from
its exact anchor Gram invariant. Only anchor data, not the full query kernel,
is required to transfer the prescribed original anchor law. -/
theorem canonical_anchor_control (A : X → J → ℝ) (B : X → EuclideanSpace ℝ I)
    (Q : Measure (X → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (fieldLaw A)≠∞) (S : Finset X)
    (hanchor : ∀x∈S,∀y∈S,gram A x y=inner ℝ (B x) (B y)) :
    ∃L : Measure (I → ℝ), IsProbabilityMeasure L ∧
      klDiv L (standardLaw I)≠∞ ∧
      (klDiv L (standardLaw I)).toReal≤(klDiv Q (fieldLaw A)).toReal ∧
      L.map (maskCoordinates S ∘ fieldLinear (fun x i => B x i))=Q.map (maskCoordinates S) ∧
      L.map (fieldLinear (fun x i => B x i))=
        fieldAnchorReplacement Q (fieldLaw (fun x i => B x i)) (maskCoordinates S) := by
  let μ := standardLaw I
  let F := maskCoordinates S ∘ fieldLinear (fun x i => B x i)
  let ν := Q.map (maskCoordinates S)
  have hF : Measurable F := (measurable_maskCoordinates S).comp (fieldLinear _).continuous.measurable
  letI : IsProbabilityMeasure ν := Measure.isProbabilityMeasure_map (measurable_maskCoordinates S).aemeasurable
  have hG := gaussian_anchor_marginal_eq A (fun x i => B x i) S (by
    intro x hx y hy
    rw [gram_euclidean_coefficients]
    exact hanchor x hx y hy)
  have hμ : μ.map F=(fieldLaw A).map (maskCoordinates S) := by
    have hh := Measure.map_map (μ:=μ) (measurable_maskCoordinates S) (fieldLinear (fun x i => B x i)).continuous.measurable
    exact hh.symm.trans hG.symm
  have hd : klDiv ν (μ.map F)≤klDiv Q (fieldLaw A) := by
    rw [hμ]
    exact klDiv_map_le Q (fieldLaw A) (measurable_maskCoordinates S)
  have hf : klDiv ν (μ.map F)≠∞ := ne_top_of_le_ne_top hKL hd
  let L := statisticEntropyLift μ F ν
  letI := statisticEntropyLift_probability μ F ν
  have hc : klDiv L μ=klDiv ν (μ.map F) := statisticEntropyLift_kl μ hF ν hf
  refine ⟨L,inferInstance,by rw [hc]; exact hf,?_,statisticEntropyLift_map μ hF ν hf,?_⟩
  · rw [hc]
    exact ENNReal.toReal_mono hKL hd
  · exact anchorStatisticLift_to_field μ Q
      (fieldLinear (fun x i => B x i)).continuous.measurable (measurable_maskCoordinates S) hf

/-- The canonical next layer preserves the actual prescribed anchor covariance
and grows the coordinate dimension by at most the anchor count plus one. -/
theorem canonical_anchor_step_moments (B : X → EuclideanSpace ℝ I)
    (Q : Measure (X → ℝ)) [IsProbabilityMeasure Q] (S : Finset X)
    (L : Measure (I → ℝ)) [IsProbabilityMeasure L]
    (hKL : klDiv L (standardLaw I)≠∞)
    (hmap : L.map (maskCoordinates S ∘ fieldLinear (fun x i => B x i))=Q.map (maskCoordinates S)) :
    (∀x∈S,∀y∈S,
      inner ℝ (canonicalGaussianMap L hKL (fun u:S => B u) (B x))
        (canonicalGaussianMap L hKL (fun u:S => B u) (B y))=
        ∫z,Real.tanh (z x)*Real.tanh (z y) ∂Q) ∧
    Fintype.card (CanonicalIndex L hKL (fun u:S => B u))≤Fintype.card I+S.card+1 := by
  constructor
  · intro x hx y hy
    have hh := canonicalGaussian_anchor_gram L hKL (fun u:S => B u) (B x) ⟨y,hy⟩
    have htest : Measurable (fun z:X→ℝ => Real.tanh (z x)*Real.tanh (z y)) := by fun_prop
    have hm := congrArg (fun μ : Measure (X → ℝ) => ∫z,Real.tanh (z x)*Real.tanh (z y) ∂μ) hmap
    rw [integral_map ((measurable_maskCoordinates S).comp (fieldLinear _).continuous.measurable).aemeasurable
      htest.aestronglyMeasurable,
      integral_map (measurable_maskCoordinates S).aemeasurable htest.aestronglyMeasurable] at hm
    simp only [Function.comp_apply,maskCoordinates,if_pos hx,if_pos hy,fieldLinear_apply] at hm
    have hlin (v : EuclideanSpace ℝ I) (z : I → ℝ) : gaussianLinearForm v z=∑i,v i*z i := by
      simp only [gaussianLinearForm,PiLp.inner_apply,Real.inner_apply]
    simp only [hlin] at hh
    exact hh.trans hm
  · simpa only [Fintype.card_coe] using canonicalGaussian_dimension L hKL (fun u:S => B u)

#print axioms canonical_anchor_control
#print axioms canonical_anchor_step_moments
end ConditionalNonpolynomial.Analytic
