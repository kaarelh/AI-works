import GaussianCovarianceCost
import GaussianMatchingMoments
import IndependentCoordinateEntropy
import ScalarMomentEntropy

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Matrix
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianOrthogonal
variable {I : Type*} [Fintype I] [DecidableEq I]

theorem matchingGaussian_kl_finite (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    klDiv (matchingGaussian Q) (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞ := by
  let u := (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr
  have hrot := orthogonal_kl_invariant (matchingGaussian Q)
    (Measure.pi fun _ : I=>gaussianReal 0 1) u
  rw [matchingGaussian_eigen_map,productGaussian_map_coordinateMap] at hrot
  rw [←hrot,coordinate_control_kl]
  exact ENNReal.sum_ne_top.mpr fun i _=>gaussian_variance_kl_ne_top _ (matchingEigenvariances_pos Q hKL i).ne'

theorem matchingGaussian_kl_covarianceCost (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    (klDiv (matchingGaussian Q) (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal=
      gaussianCovarianceCost Q := by
  let u := (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr
  have hrot := orthogonal_kl_invariant (matchingGaussian Q)
    (Measure.pi fun _ : I=>gaussianReal 0 1) u
  rw [matchingGaussian_eigen_map,productGaussian_map_coordinateMap] at hrot
  rw [←hrot,coordinate_control_kl,ENNReal.toReal_sum
    (fun i _=>gaussian_variance_kl_ne_top _ (matchingEigenvariances_pos Q hKL i).ne')]
  simp_rw [gaussian_variance_kl_toReal _ (matchingEigenvariances_pos Q hKL _).ne']
  simp only [matchingEigenvariances,Real.coe_toNNReal _ (secondMomentMatrix_eigenvalues_pos Q hKL _).le]
  exact (Finset.sum_div _ _ _).symm

/-- The Gaussian covariance cost pays the scalar variance cost in every unit
direction; the non-Gaussian part of KL is not used in this estimate. -/
theorem gaussian_directional_covariance_cost (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (u : I→ℝ) (hu : ∑i,(u i)^2=1) :
    let M := ∫x:I→ℝ,(∑i,u i*x i)^2 ∂Q
    (M-1-Real.log M)/2≤gaussianCovarianceCost Q := by
  let a : EuclideanSpace ℝ I := WithLp.toLp 2 u
  let g := gaussianLinearForm a
  have hg : Measurable g := gaussianLinearForm_measurable a
  have heq : g=(fun x:I→ℝ=>∑i,u i*x i) := by
    funext x
    simp [g,a,gaussianLinearForm,PiLp.inner_apply,Real.inner_apply,mul_comm]
  have hanorm : ‖a‖^2=1 := by
    rw [EuclideanSpace.norm_sq_eq]
    simpa only [a,WithLp.ofLp_toLp,Real.norm_eq_abs,sq_abs] using hu
  have hG : (Measure.pi fun _ : I=>gaussianReal 0 1).map g=gaussianReal 0 1 := by
    have h := (gaussianLinearForm_hasLaw a).map_eq
    simpa only [hanorm,Real.toNNReal_one] using h
  have hf := matchingGaussian_kl_finite Q hKL
  have hd := NeuralGeneralization.RobustEntropy.klDiv_map_le (matchingGaussian Q)
    (Measure.pi fun _ : I=>gaussianReal 0 1) hg
  rw [hG] at hd
  have hmapfinite : klDiv ((matchingGaussian Q).map g) (gaussianReal 0 1)≠∞ :=
    ne_of_lt (lt_of_le_of_lt hd (lt_top_iff_ne_top.mpr hf))
  haveI : IsProbabilityMeasure ((matchingGaussian Q).map g) := Measure.isProbabilityMeasure_map hg.aemeasurable
  have hscalar := scalar_gaussian_second_moment_entropy ((matchingGaussian Q).map g) hmapfinite
  have hm : (∫z:ℝ,z^2 ∂(matchingGaussian Q).map g)=(∫x:I→ℝ,(∑i,u i*x i)^2 ∂Q) := by
    rw [integral_map hg.aemeasurable (by fun_prop),heq]
    change (∫x:I→ℝ,(u ⬝ᵥ x)^2 ∂matchingGaussian Q)=(∫x:I→ℝ,(u ⬝ᵥ x)^2 ∂Q)
    rw [gaussian_integral_dotProduct_sq _ hf,gaussian_integral_dotProduct_sq _ hKL,
      matchingGaussian_secondMomentMatrix Q hKL]
  rw [hm] at hscalar
  have hreal := ENNReal.toReal_mono hf hd
  rw [matchingGaussian_kl_covarianceCost Q hKL] at hreal
  exact hscalar.trans hreal

#print axioms matchingGaussian_kl_covarianceCost
#print axioms gaussian_directional_covariance_cost
end ConditionalNonpolynomial.Analytic
