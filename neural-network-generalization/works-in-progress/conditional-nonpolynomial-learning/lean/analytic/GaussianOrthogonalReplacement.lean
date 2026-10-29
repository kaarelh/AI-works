import GaussianNonGaussianExtension

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open MeasureTheory ProbabilityTheory InformationTheory Matrix
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt
open NeuralGeneralization.GaussianFieldCovariance
variable {I J K : Type*} [Fintype I] [Fintype J] [Fintype K]
  [DecidableEq I] [DecidableEq J] [DecidableEq K]

theorem orthogonalRows_fieldLaw (A : J→I→ℝ)
    (horth : ∀i j,NeuralGeneralization.GaussianAngularPrice.gram A i j=if i=j then 1 else 0) :
    fieldLaw A=standardLaw J := by
  let B : J→J→ℝ := fun i j=>if i=j then 1 else 0
  have hAB : fieldLaw A=fieldLaw B := by
    apply fieldLaw_eq_of_gram_eq
    intro i j
    rw [horth]
    simp [B,NeuralGeneralization.GaussianAngularPrice.gram]
  have hB : fieldLinear B=ContinuousLinearMap.id ℝ (J→ℝ) := by
    ext z i
    simp [fieldLinear_apply,B]
  rw [hAB,fieldLaw,hB]
  exact Measure.map_id

theorem orthogonalRows_control_finite (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (standardLaw I)≠∞) (A : J→I→ℝ)
    (horth : ∀i j,NeuralGeneralization.GaussianAngularPrice.gram A i j=if i=j then 1 else 0) :
    klDiv (Q.map (fieldLinear A)) (standardLaw J)≠∞ := by
  have hh := NeuralGeneralization.RobustEntropy.klDiv_map_le Q (standardLaw I)
    (fieldLinear A).continuous.measurable
  change klDiv (Q.map (fieldLinear A)) (fieldLaw A)≤klDiv Q (standardLaw I) at hh
  rw [orthogonalRows_fieldLaw A horth] at hh
  exact ne_top_of_le_ne_top hKL hh

/-- Retain any orthonormal family of linear observations and fill the discarded
coordinates with fresh independent standard Gaussian noise. The actual
non-Gaussian entropy can only decrease. -/
theorem nonGaussianKL_orthogonal_replacement_le (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (standardLaw I)≠∞) (A : J→I→ℝ)
    (horth : ∀i j,NeuralGeneralization.GaussianAngularPrice.gram A i j=if i=j then 1 else 0) :
    klDiv (standardGaussianExtension (Q.map (fieldLinear A)) K)
      (matchingGaussian (standardGaussianExtension (Q.map (fieldLinear A)) K))≤
      klDiv Q (matchingGaussian Q) := by
  haveI : IsProbabilityMeasure (Q.map (fieldLinear A)) :=
    Measure.isProbabilityMeasure_map (fieldLinear A).continuous.measurable.aemeasurable
  have hfinite := orthogonalRows_control_finite Q hKL A horth
  rw [nonGaussianKL_standardGaussianExtension _ hfinite]
  exact nonGaussianKL_map_fieldLinear_le Q hKL A hfinite

#print axioms nonGaussianKL_orthogonal_replacement_le
end ConditionalNonpolynomial.Analytic
