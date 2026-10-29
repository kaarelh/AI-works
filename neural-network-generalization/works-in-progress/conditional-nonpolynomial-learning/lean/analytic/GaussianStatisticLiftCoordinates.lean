import GaussianNonGaussianExtension
import GaussianMatchingStatistic
import StatisticLiftProductCoordinates

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2200000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal NNReal BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt
variable {I J K X : Type*} [Fintype I] [Fintype J] [Fintype K] [Fintype X]
  [DecidableEq I] [DecidableEq J] [DecidableEq K] [DecidableEq X]

def splitFieldLeft (C : J⊕K→I→ℝ) : J→I→ℝ := fun j=>C (.inl j)

theorem splitField_left (C : J⊕K→I→ℝ) (z:I→ℝ) :
    (gaussianCoordinateJoin.symm (fieldLinear C z)).1=fieldLinear (splitFieldLeft C) z := rfl

theorem standardGaussianExtension_left (Q : Measure (J→ℝ)) [IsProbabilityMeasure Q] :
    (standardGaussianExtension Q K).map (fun z:J⊕K→ℝ => fun j=>z (.inl j))=Q := by
  unfold standardGaussianExtension
  rw [Measure.map_map (by fun_prop) gaussianCoordinateJoin.measurable]
  change (Q.prod (standardLaw K)).map Prod.fst=Q
  exact Measure.fst_prod

theorem statisticEntropyLift_sum_coordinates
    (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q] (hQ : klDiv Q (standardLaw I)≠∞)
    (A : X→I→ℝ) (C : J⊕K→I→ℝ)
    (hC : (standardLaw I).map (fieldLinear C)=standardLaw (J⊕K))
    (f : (J→ℝ)→(X→ℝ)) (hf : Measurable f) (g : (X→ℝ)→(J→ℝ)) (hg : Measurable g)
    (hAof : ∀z,fieldLinear A z=f (fieldLinear (splitFieldLeft C) z))
    (hUof : ∀z,fieldLinear (splitFieldLeft C) z=g (fieldLinear A z)) :
    (statisticEntropyLift (standardLaw I) (fieldLinear A) (Q.map (fieldLinear A))).map
      (fieldLinear C)=standardGaussianExtension (Q.map (fieldLinear (splitFieldLeft C))) K := by
  let E : (I→ℝ)→(J→ℝ)×(K→ℝ) := gaussianCoordinateJoin.symm ∘ fieldLinear C
  have hE : Measurable E := gaussianCoordinateJoin.symm.measurable.comp (fieldLinear C).continuous.measurable
  have hEprod : (standardLaw I).map E=(standardLaw J).prod (standardLaw K) := by
    rw [show E=gaussianCoordinateJoin.symm ∘ fieldLinear C from rfl,
      ←Measure.map_map gaussianCoordinateJoin.symm.measurable (fieldLinear C).continuous.measurable,hC,
      ←standardGaussianExtension_standard (I:=J) (J:=K)]
    exact MeasurableEquiv.map_symm_map gaussianCoordinateJoin
  have hh := statisticEntropyLift_product_coordinates (standardLaw I) Q hQ
    (fieldLinear A) (fieldLinear A).continuous.measurable E hE (standardLaw J) (standardLaw K)
    hEprod f hf g hg hAof hUof
  have he : Prod.fst ∘ E=fieldLinear (splitFieldLeft C) := rfl
  rw [he] at hh
  have hm := congrArg (fun μ=>μ.map gaussianCoordinateJoin) hh
  rw [Measure.map_map gaussianCoordinateJoin.measurable hE] at hm
  have hc : gaussianCoordinateJoin ∘ E=fieldLinear C := by
    funext z
    exact gaussianCoordinateJoin.apply_symm_apply _
  rw [hc] at hm
  exact hm

/-- Matching second moments preserves the exact Gaussian conditional
completion along a linear statistic. Orthogonal coordinate data are explicit. -/
theorem matchingGaussian_minimal_linearStatistic
    (R : Measure (I→ℝ)) [IsProbabilityMeasure R] (hR : klDiv R (standardLaw I)≠∞)
    (A : X→I→ℝ)
    (hminimal : R=statisticEntropyLift (standardLaw I) (fieldLinear A) (R.map (fieldLinear A)))
    (C : J⊕K→I→ℝ) (D : I→J⊕K→ℝ)
    (hDC : fieldLinear D ∘ fieldLinear C=id)
    (hC : (standardLaw I).map (fieldLinear C)=standardLaw (J⊕K))
    (f : (J→ℝ)→(X→ℝ)) (hf : Measurable f) (g : (X→ℝ)→(J→ℝ)) (hg : Measurable g)
    (hAof : ∀z,fieldLinear A z=f (fieldLinear (splitFieldLeft C) z))
    (hUof : ∀z,fieldLinear (splitFieldLeft C) z=g (fieldLinear A z)) :
    matchingGaussian R=statisticEntropyLift (standardLaw I) (fieldLinear A)
      ((matchingGaussian R).map (fieldLinear A)) := by
  let U := fieldLinear (splitFieldLeft C)
  have hU : Measurable U := U.continuous.measurable
  haveI : IsProbabilityMeasure (R.map U) := Measure.isProbabilityMeasure_map hU.aemeasurable
  have hRC : R.map (fieldLinear C)=standardGaussianExtension (R.map U) K := by
    conv_lhs => arg 2; rw [hminimal]
    exact statisticEntropyLift_sum_coordinates R hR A C hC f hf g hg hAof hUof
  have hRCfinite : klDiv (R.map (fieldLinear C)) (standardLaw (J⊕K))≠∞ := by
    have hd := NeuralGeneralization.RobustEntropy.klDiv_map_le R (standardLaw I)
      (fieldLinear C).continuous.measurable
    rw [hC] at hd
    exact ne_top_of_le_ne_top hR hd
  have hUreference : (standardLaw I).map U=standardLaw J := by
    have hh := congrArg (fun μ=>μ.map (fun z:J⊕K→ℝ=>fun j=>z (.inl j))) hC
    rw [Measure.map_map (by fun_prop) (fieldLinear C).continuous.measurable,
      ←standardGaussianExtension_standard (I:=J) (J:=K),standardGaussianExtension_left] at hh
    exact hh
  have hRUfinite : klDiv (R.map U) (standardLaw J)≠∞ := by
    have hd := NeuralGeneralization.RobustEntropy.klDiv_map_le R (standardLaw I) hU
    rw [hUreference] at hd
    exact ne_top_of_le_ne_top hR hd
  have hMC : (matchingGaussian R).map (fieldLinear C)=
      standardGaussianExtension (matchingGaussian (R.map U)) K := by
    rw [←matchingGaussian_map_fieldLinear R hR C hRCfinite,hRC,
      matchingGaussian_standardGaussianExtension _ hRUfinite]
  have hMU : (matchingGaussian R).map U=matchingGaussian (R.map U) := by
    have hh := congrArg (fun μ=>μ.map (fun z:J⊕K→ℝ=>fun j=>z (.inl j))) hMC
    rw [Measure.map_map (by fun_prop) (fieldLinear C).continuous.measurable,
      standardGaussianExtension_left] at hh
    exact hh
  have hHC := statisticEntropyLift_sum_coordinates (matchingGaussian R)
    (matchingGaussian_kl_finite R hR) A C hC f hf g hg hAof hUof
  rw [hMU] at hHC
  have he := hMC.trans hHC.symm
  have hd := congrArg (fun μ=>μ.map (fieldLinear D)) he
  rw [Measure.map_map (fieldLinear D).continuous.measurable (fieldLinear C).continuous.measurable,
    Measure.map_map (fieldLinear D).continuous.measurable (fieldLinear C).continuous.measurable,
    hDC,Measure.map_id,Measure.map_id] at hd
  exact hd

#print axioms matchingGaussian_minimal_linearStatistic
end ConditionalNonpolynomial.Analytic
