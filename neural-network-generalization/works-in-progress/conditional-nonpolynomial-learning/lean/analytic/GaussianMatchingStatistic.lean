import GaussianMatchingProjection
import GaussianDirectionalCovarianceCost
import StatisticLiftRelativeEntropy

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1800000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal NNReal BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt
variable {I J X : Type*} [Fintype I] [Fintype J] [Fintype X]
  [DecidableEq I] [DecidableEq J] [DecidableEq X]

/-- Equal controlled laws of linear statistics have equal Gaussian laws
obtained from the actual matching second moments, including singular outputs. -/
theorem matchingGaussian_statistic_eq_of_map_eq
    (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q] (R : Measure (J→ℝ)) [IsProbabilityMeasure R]
    (hQ : klDiv Q (standardLaw I)≠∞) (hR : klDiv R (standardLaw J)≠∞)
    (A : X→I→ℝ) (B : X→J→ℝ)
    (hmap : Q.map (fieldLinear A)=R.map (fieldLinear B)) :
    (matchingGaussian Q).map (fieldLinear A)=(matchingGaussian R).map (fieldLinear B) := by
  have hQA : (matchingGaussian Q).map (fieldLinear A)=
      fieldLaw (fieldMatrixCompose A (gaussianUnwhiteningMatrix Q)) := by
    rw [matchingGaussian_eq_fieldLaw Q hQ,fieldLaw,Measure.map_map
      (fieldLinear A).continuous.measurable (fieldLinear _).continuous.measurable,
      fieldLinear_comp_matrix]
    rfl
  have hRB : (matchingGaussian R).map (fieldLinear B)=
      fieldLaw (fieldMatrixCompose B (gaussianUnwhiteningMatrix R)) := by
    rw [matchingGaussian_eq_fieldLaw R hR,fieldLaw,Measure.map_map
      (fieldLinear B).continuous.measurable (fieldLinear _).continuous.measurable,
      fieldLinear_comp_matrix]
    rfl
  rw [hQA,hRB]
  apply fieldLaw_eq_of_secondMomentMatrix_eq
  rw [←hQA,←hRB]
  ext i j
  rw [secondMomentMatrix_map_fieldLinear _ (matchingGaussian_kl_finite Q hQ),
    secondMomentMatrix_map_fieldLinear _ (matchingGaussian_kl_finite R hR),
    matchingGaussian_secondMomentMatrix Q hQ,matchingGaussian_secondMomentMatrix R hR]
  have hh := congrFun (congrFun (congrArg secondMomentMatrix hmap) i) j
  rwa [secondMomentMatrix_map_fieldLinear Q hQ,secondMomentMatrix_map_fieldLinear R hR] at hh

/-- A minimal Gaussian-statistic lift whose matching Gaussian is itself a
minimal lift inherits at most the source law's non-Gaussian entropy. -/
theorem nonGaussianKL_statistic_transfer
    (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q] (R : Measure (J→ℝ)) [IsProbabilityMeasure R]
    (hQ : klDiv Q (standardLaw I)≠∞) (hR : klDiv R (standardLaw J)≠∞)
    (A : X→I→ℝ) (B : X→J→ℝ)
    (hmap : Q.map (fieldLinear A)=R.map (fieldLinear B))
    (hminimal : R=statisticEntropyLift (standardLaw J) (fieldLinear B) (R.map (fieldLinear B)))
    (hGaussianMinimal : matchingGaussian R=statisticEntropyLift (standardLaw J)
      (fieldLinear B) ((matchingGaussian R).map (fieldLinear B))) :
    klDiv R (matchingGaussian R)≤klDiv Q (matchingGaussian Q) := by
  have hRB : klDiv (R.map (fieldLinear B)) ((standardLaw J).map (fieldLinear B))≠∞ :=
    ne_top_of_le_ne_top hR (NeuralGeneralization.RobustEntropy.klDiv_map_le R
      (standardLaw J) (fieldLinear B).continuous.measurable)
  have hGB : klDiv ((matchingGaussian R).map (fieldLinear B))
      ((standardLaw J).map (fieldLinear B))≠∞ :=
    ne_top_of_le_ne_top (matchingGaussian_kl_finite R hR)
      (NeuralGeneralization.RobustEntropy.klDiv_map_le (matchingGaussian R)
        (standardLaw J) (fieldLinear B).continuous.measurable)
  haveI : IsProbabilityMeasure (R.map (fieldLinear B)) :=
    Measure.isProbabilityMeasure_map (fieldLinear B).continuous.measurable.aemeasurable
  haveI : IsProbabilityMeasure ((matchingGaussian R).map (fieldLinear B)) :=
    Measure.isProbabilityMeasure_map (fieldLinear B).continuous.measurable.aemeasurable
  calc
    klDiv R (matchingGaussian R)=
        klDiv (R.map (fieldLinear B)) ((matchingGaussian R).map (fieldLinear B)) := by
      conv_lhs => arg 1; rw [hminimal]
      conv_lhs => arg 2; rw [hGaussianMinimal]
      exact statisticEntropyLift_relative_kl (standardLaw J) (fieldLinear B)
        (fieldLinear B).continuous.measurable _ _ hRB hGB
    _ = klDiv (Q.map (fieldLinear A)) ((matchingGaussian Q).map (fieldLinear A)) := by
      rw [hmap,matchingGaussian_statistic_eq_of_map_eq Q R hQ hR A B hmap]
    _ ≤ _ := NeuralGeneralization.RobustEntropy.klDiv_map_le Q (matchingGaussian Q)
      (fieldLinear A).continuous.measurable

#print axioms matchingGaussian_statistic_eq_of_map_eq
#print axioms nonGaussianKL_statistic_transfer
end ConditionalNonpolynomial.Analytic
