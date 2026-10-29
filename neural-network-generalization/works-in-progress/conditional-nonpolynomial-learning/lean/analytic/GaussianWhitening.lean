import GaussianEigenMoments
import NeuralGeneralization.GaussianDampedField

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Matrix
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianOrthogonal NeuralGeneralization.GaussianAngularPrice
open NeuralGeneralization.GaussianDiagonalComparison
variable {I : Type*} [Fintype I] [DecidableEq I]

def gaussianWhiten (Q : Measure (I→ℝ)) (x:I→ℝ) : I→ℝ :=
  fun i=>coordinateMap (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr x i/
    Real.sqrt ((secondMomentMatrix_isHermitian Q).eigenvalues i)

def gaussianUnwhiten (Q : Measure (I→ℝ)) (y:I→ℝ) : I→ℝ :=
  coordinateMap (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr.symm
    (fun i=>Real.sqrt ((secondMomentMatrix_isHermitian Q).eigenvalues i)*y i)

@[fun_prop] theorem gaussianWhiten_measurable (Q : Measure (I→ℝ)) : Measurable (gaussianWhiten Q) := by
  unfold gaussianWhiten
  apply measurable_pi_lambda
  intro i
  exact ((measurable_pi_apply i).comp (coordinateMap_measurable _)).div_const _

@[fun_prop] theorem gaussianUnwhiten_measurable (Q : Measure (I→ℝ)) : Measurable (gaussianUnwhiten Q) := by
  unfold gaussianUnwhiten
  exact (coordinateMap_measurable _).comp (by fun_prop)

theorem gaussianWhiten_unwhiten (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    gaussianWhiten Q ∘ gaussianUnwhiten Q=id := by
  funext y i
  have hpos := Real.sqrt_pos.mpr (secondMomentMatrix_eigenvalues_pos Q hKL i)
  unfold gaussianWhiten gaussianUnwhiten
  simp only [Function.comp_apply,id_eq]
  have he := congrFun (coordinateMap_comp_inverse (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr.symm)
    (fun i=>Real.sqrt ((secondMomentMatrix_isHermitian Q).eigenvalues i)*y i)
  simp only [LinearIsometryEquiv.symm_symm,Function.comp_apply,id_eq] at he
  rw [he]
  exact mul_div_cancel_left₀ (y i) hpos.ne'

theorem gaussianUnwhiten_whiten (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    gaussianUnwhiten Q ∘ gaussianWhiten Q=id := by
  funext x
  unfold gaussianWhiten gaussianUnwhiten
  simp only [Function.comp_apply,id_eq]
  have he : (fun i=>Real.sqrt ((secondMomentMatrix_isHermitian Q).eigenvalues i)*
      (coordinateMap (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr x i/
        Real.sqrt ((secondMomentMatrix_isHermitian Q).eigenvalues i)))=
      coordinateMap (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr x := by
    funext i
    exact mul_div_cancel₀ _ (Real.sqrt_pos.mpr (secondMomentMatrix_eigenvalues_pos Q hKL i)).ne'
  rw [he]
  exact congrFun (coordinateMap_comp_inverse (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr) x

theorem matchingGaussian_eq_unwhiten (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    matchingGaussian Q=(Measure.pi fun _ : I=>gaussianReal 0 1).map (gaussianUnwhiten Q) := by
  unfold matchingGaussian
  rw [←standard_map_diagonal (matchingEigenvariances Q),
    Measure.map_map (coordinateMap_measurable _) (by fun_prop)]
  congr 1
  funext y
  unfold gaussianUnwhiten matchingEigenvariances
  simp only [Real.coe_toNNReal _ (secondMomentMatrix_eigenvalues_pos Q hKL _).le,
    Function.comp_apply]

theorem matchingGaussian_whiten (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    (matchingGaussian Q).map (gaussianWhiten Q)=Measure.pi fun _ : I=>gaussianReal 0 1 := by
  rw [matchingGaussian_eq_unwhiten Q hKL,
    Measure.map_map (gaussianWhiten_measurable Q) (gaussianUnwhiten_measurable Q),
    gaussianWhiten_unwhiten Q hKL,Measure.map_id]

theorem whitening_kl_identity (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    klDiv (Q.map (gaussianWhiten Q)) (Measure.pi fun _ : I=>gaussianReal 0 1)=
      klDiv Q (matchingGaussian Q) := by
  have hw := gaussianWhiten_measurable Q
  have hu := gaussianUnwhiten_measurable Q
  have hm := matchingGaussian_whiten Q hKL
  haveI : IsProbabilityMeasure (Q.map (gaussianWhiten Q)) := Measure.isProbabilityMeasure_map hw.aemeasurable
  apply le_antisymm
  · have hh := NeuralGeneralization.RobustEntropy.klDiv_map_le Q (matchingGaussian Q) hw
    rwa [hm] at hh
  · have hh := NeuralGeneralization.RobustEntropy.klDiv_map_le
      (Q.map (gaussianWhiten Q)) (Measure.pi fun _ : I=>gaussianReal 0 1) hu
    rw [Measure.map_map hu hw,gaussianUnwhiten_whiten Q hKL,Measure.map_id,
      ←matchingGaussian_eq_unwhiten Q hKL] at hh
    exact hh

theorem whitened_secondMomentMatrix (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    secondMomentMatrix (Q.map (gaussianWhiten Q))=1 := by
  ext i j
  unfold secondMomentMatrix
  rw [integral_map (gaussianWhiten_measurable Q).aemeasurable (by fun_prop)]
  simp only [gaussianWhiten,div_mul_div_comm]
  rw [integral_div,eigen_coordinate_cross_moment Q hKL]
  by_cases hij : i=j
  · subst j
    rw [if_pos rfl,←pow_two,Real.sq_sqrt (secondMomentMatrix_eigenvalues_pos Q hKL i).le]
    simp [(secondMomentMatrix_eigenvalues_pos Q hKL i).ne']
  · simp [hij]

#print axioms whitening_kl_identity
#print axioms whitened_secondMomentMatrix
end ConditionalNonpolynomial.Analytic
