import DimensionFreeGaussianTransfer
import StatisticFieldLift
import CoordinatePairEntropy

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.RobustEntropy
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianFieldTilt

variable {X I : Type*} [Fintype X] [DecidableEq X] [Fintype I]

lemma mask_fields_eq (A B : X → I → ℝ) (S : Finset X)
    (hanchor : ∀x∈S,A x=B x) :
    maskCoordinates S ∘ fieldLinear A=maskCoordinates S ∘ fieldLinear B := by
  funext z x
  by_cases hx : x∈S
  · simp only [Function.comp_apply,maskCoordinates,if_pos hx,fieldLinear_apply,hanchor x hx]
  · simp only [Function.comp_apply,maskCoordinates,if_neg hx]

/-- Shared Gaussian coordinates transport the *anchor replacement* between
nearby references with identical anchor rows. The single lifted law has exact
anchor entropy and both required full-field marginals, and one-query errors
have the dimension-free gain 1+sqrt(2D). No bounded tilt is assumed. -/
theorem anchor_gaussian_dimension_free_coupling_pointwise
    (A B : X → I → ℝ) (Q : Measure (X → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (fieldLaw A)≠∞) (S : Finset X)
    (hanchor : ∀x∈S,A x=B x) :
    ∃L : Measure (I → ℝ), IsProbabilityMeasure L ∧
      klDiv L (standardLaw I)≠∞ ∧
      (klDiv L (standardLaw I)).toReal≤(klDiv Q (fieldLaw A)).toReal ∧
      L.map (fieldLinear A)=fieldAnchorReplacement Q (fieldLaw A) (maskCoordinates S) ∧
      L.map (fieldLinear B)=fieldAnchorReplacement Q (fieldLaw B) (maskCoordinates S) ∧
      ∀x,∀δ:ℝ,(∑i,(A x i-B x i)^2≤δ^2) →
        (∫z,(Real.tanh (fieldLinear A z x)-Real.tanh (fieldLinear B z x))^2 ∂L)≤
        (1+Real.sqrt (2*(klDiv Q (fieldLaw A)).toReal))^2*δ^2 := by
  let μ := standardLaw I
  let a := maskCoordinates S
  let ν := Q.map a
  have ha : Measurable a := measurable_maskCoordinates S
  have hA : Measurable (fieldLinear A) := (fieldLinear A).continuous.measurable
  have hB : Measurable (fieldLinear B) := (fieldLinear B).continuous.measurable
  letI : IsProbabilityMeasure ν := Measure.isProbabilityMeasure_map ha.aemeasurable
  have hμA : μ.map (a ∘ fieldLinear A)=(fieldLaw A).map a :=
    (Measure.map_map ha hA).symm
  have hcostle : klDiv ν (μ.map (a ∘ fieldLinear A))≤klDiv Q (fieldLaw A) := by
    rw [hμA]
    exact klDiv_map_le Q (fieldLaw A) ha
  have hanchorKL : klDiv ν (μ.map (a ∘ fieldLinear A))≠∞ :=
    ne_top_of_le_ne_top hKL hcostle
  let L := statisticEntropyLift μ (a ∘ fieldLinear A) ν
  letI : IsProbabilityMeasure L := statisticEntropyLift_probability μ _ ν
  have hcost : klDiv L μ=klDiv ν (μ.map (a ∘ fieldLinear A)) :=
    statisticEntropyLift_kl μ (ha.comp hA) ν hanchorKL
  have hfinite : klDiv L μ≠∞ := by rw [hcost]; exact hanchorKL
  have hreal : (klDiv L μ).toReal≤(klDiv Q (fieldLaw A)).toReal := by
    rw [hcost]
    exact ENNReal.toReal_mono hKL hcostle
  have hmapA : L.map (fieldLinear A)=fieldAnchorReplacement Q (fieldLaw A) a :=
    anchorStatisticLift_to_field μ Q hA ha hanchorKL
  have hF : a ∘ fieldLinear A=a ∘ fieldLinear B := mask_fields_eq A B S hanchor
  have hanchorKLB : klDiv ν (μ.map (a ∘ fieldLinear B))≠∞ := by rw [← hF]; exact hanchorKL
  have hmapB : L.map (fieldLinear B)=fieldAnchorReplacement Q (fieldLaw B) a := by
    have hh := anchorStatisticLift_to_field μ Q hB ha hanchorKLB
    rw [← hF] at hh
    exact hh
  refine ⟨L,inferInstance,hfinite,hreal,hmapA,hmapB,?_⟩
  intro x δ hclose
  have hh := tanh_feature_dimension_free_squared L hfinite (A x) (B x) hclose
  have hs := Real.sqrt_le_sqrt (mul_le_mul_of_nonneg_left hreal (by norm_num : (0:ℝ)≤2))
  have hp := pow_le_pow_left₀ (show 0≤1+Real.sqrt (2*(klDiv L μ).toReal) by positivity)
    (show 1+Real.sqrt (2*(klDiv L μ).toReal)≤1+Real.sqrt (2*(klDiv Q (fieldLaw A)).toReal) by linarith) 2
  have hm := mul_le_mul_of_nonneg_right hp (sq_nonneg δ)
  simpa only [fieldLinear_apply] using hh.trans hm

theorem anchor_gaussian_dimension_free_coupling
    (A B : X → I → ℝ) (Q : Measure (X → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (fieldLaw A)≠∞) (S : Finset X)
    (hanchor : ∀x∈S,A x=B x) {δ : ℝ}
    (hclose : ∀x,∑i,(A x i-B x i)^2≤δ^2) :
    ∃L : Measure (I → ℝ), IsProbabilityMeasure L ∧
      klDiv L (standardLaw I)≠∞ ∧
      (klDiv L (standardLaw I)).toReal≤(klDiv Q (fieldLaw A)).toReal ∧
      L.map (fieldLinear A)=fieldAnchorReplacement Q (fieldLaw A) (maskCoordinates S) ∧
      L.map (fieldLinear B)=fieldAnchorReplacement Q (fieldLaw B) (maskCoordinates S) ∧
      ∀x,(∫z,(Real.tanh (fieldLinear A z x)-Real.tanh (fieldLinear B z x))^2 ∂L)≤
        (1+Real.sqrt (2*(klDiv Q (fieldLaw A)).toReal))^2*δ^2 := by
  obtain ⟨L,hprob,hfinite,hcost,hleft,hright,herror⟩ :=
    anchor_gaussian_dimension_free_coupling_pointwise A B Q hKL S hanchor
  exact ⟨L,hprob,hfinite,hcost,hleft,hright,fun x => herror x δ (hclose x)⟩

#print axioms anchor_gaussian_dimension_free_coupling
end ConditionalNonpolynomial.Analytic
