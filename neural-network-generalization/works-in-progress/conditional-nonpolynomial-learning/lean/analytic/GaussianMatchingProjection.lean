import GaussianMatchingMoments
import NeuralGeneralization.GaussianFieldCovariance

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Matrix
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt
open NeuralGeneralization.GaussianFieldCovariance
variable {I J K : Type*} [Fintype I] [Fintype J] [Fintype K]

def fieldMatrixCompose (A : J→I→ℝ) (B : I→K→ℝ) : J→K→ℝ :=
  fun j k=>∑i,A j i*B i k

theorem fieldLinear_comp_matrix (A : J→I→ℝ) (B : I→K→ℝ) :
    fieldLinear A ∘ fieldLinear B=fieldLinear (fieldMatrixCompose A B) := by
  funext z j
  simp only [Function.comp_apply,fieldLinear_apply,fieldMatrixCompose,Finset.mul_sum,Finset.sum_mul]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro k _
  apply Finset.sum_congr rfl
  intro i _
  ring

theorem fieldLaw_secondMomentMatrix (A : J→I→ℝ) (i j:J) :
    secondMomentMatrix (fieldLaw A) i j=gram A i j := by
  classical
  change secondMomentMatrix ((Measure.pi fun _ : I=>gaussianReal 0 1).map (fieldLinear A)) i j=_
  rw [secondMomentMatrix_map_fieldLinear _ (by simp),standardGaussian_secondMomentMatrix,
    Matrix.one_mulVec]
  rfl

theorem fieldLaw_eq_of_secondMomentMatrix_eq (A : J→I→ℝ) (B : J→K→ℝ)
    (hM : secondMomentMatrix (fieldLaw A)=secondMomentMatrix (fieldLaw B)) :
    fieldLaw A=fieldLaw B := by
  apply fieldLaw_eq_of_gram_eq
  intro i j
  have hh := congrFun (congrFun hM i) j
  simpa only [fieldLaw_secondMomentMatrix] using hh

theorem matchingGaussian_eq_fieldLaw [DecidableEq I] (Q : Measure (I→ℝ))
    [IsProbabilityMeasure Q] (hKL : klDiv Q (standardLaw I)≠∞) :
    matchingGaussian Q=fieldLaw (gaussianUnwhiteningMatrix Q) := by
  rw [matchingGaussian_eq_unwhiten Q hKL,gaussianUnwhiten_eq_fieldLinear]
  rfl

/-- The actual matching centered Gaussian commutes with every finite linear
projection whose controlled output has finite standard-Gaussian entropy. -/
theorem matchingGaussian_map_fieldLinear [DecidableEq I] [DecidableEq J]
    (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (standardLaw I)≠∞) (A : J→I→ℝ)
    (hR : klDiv (Q.map (fieldLinear A)) (standardLaw J)≠∞) :
    matchingGaussian (Q.map (fieldLinear A))=(matchingGaussian Q).map (fieldLinear A) := by
  let W := Q.map (gaussianWhiten Q)
  let R := Q.map (fieldLinear A)
  let B := gaussianUnwhiteningMatrix Q
  haveI : IsProbabilityMeasure W := Measure.isProbabilityMeasure_map (gaussianWhiten_measurable Q).aemeasurable
  haveI : IsProbabilityMeasure R := Measure.isProbabilityMeasure_map (fieldLinear A).continuous.measurable.aemeasurable
  have hW : klDiv W (standardLaw I)≠∞ := by
    change klDiv (Q.map (gaussianWhiten Q)) (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞
    rw [whitening_kl_identity Q hKL]
    exact (gaussian_full_moment_entropy_decomposition Q hKL).1
  have hrec : W.map (fieldLinear B)=Q := by
    have hh := whitened_reconstruction Q hKL
    rwa [gaussianUnwhiten_eq_fieldLinear] at hh
  have hRLaw : W.map (fieldLinear (fieldMatrixCompose A B))=R := by
    rw [←fieldLinear_comp_matrix,←Measure.map_map (fieldLinear A).continuous.measurable
      (fieldLinear B).continuous.measurable,hrec]
  have href : (matchingGaussian Q).map (fieldLinear A)=fieldLaw (fieldMatrixCompose A B) := by
    rw [matchingGaussian_eq_fieldLaw Q hKL,fieldLaw,Measure.map_map
      (fieldLinear A).continuous.measurable (fieldLinear B).continuous.measurable,
      fieldLinear_comp_matrix]
    rfl
  rw [href,matchingGaussian_eq_fieldLaw R hR]
  apply fieldLaw_eq_of_secondMomentMatrix_eq
  rw [←matchingGaussian_eq_fieldLaw R hR,matchingGaussian_secondMomentMatrix R hR,←hRLaw]
  ext i j
  have hWM : secondMomentMatrix W=1 := whitened_secondMomentMatrix Q hKL
  rw [secondMomentMatrix_map_fieldLinear W hW,hWM,
    Matrix.one_mulVec,fieldLaw_secondMomentMatrix]
  rfl

/-- Non-Gaussian entropy contracts under an actual finite linear observation. -/
theorem nonGaussianKL_map_fieldLinear_le [DecidableEq I] [DecidableEq J]
    (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (standardLaw I)≠∞) (A : J→I→ℝ)
    (hR : klDiv (Q.map (fieldLinear A)) (standardLaw J)≠∞) :
    klDiv (Q.map (fieldLinear A)) (matchingGaussian (Q.map (fieldLinear A)))≤
      klDiv Q (matchingGaussian Q) := by
  haveI : IsProbabilityMeasure (Q.map (fieldLinear A)) :=
    Measure.isProbabilityMeasure_map (fieldLinear A).continuous.measurable.aemeasurable
  rw [matchingGaussian_map_fieldLinear Q hKL A hR]
  exact NeuralGeneralization.RobustEntropy.klDiv_map_le Q (matchingGaussian Q)
    (fieldLinear A).continuous.measurable

#print axioms matchingGaussian_map_fieldLinear
#print axioms nonGaussianKL_map_fieldLinear_le
end ConditionalNonpolynomial.Analytic
