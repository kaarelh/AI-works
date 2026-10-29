import GaussianWhiteningOperator
import Mathlib.Probability.Independence.Integration

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Matrix
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianOrthogonal NeuralGeneralization.FiniteDifferential
open NeuralGeneralization.GaussianAngularFields
variable {I : Type*} [Fintype I] [DecidableEq I]

theorem diagonalGaussian_secondMomentMatrix (v : I→ℝ≥0) :
    secondMomentMatrix (Measure.pi fun i=>gaussianReal 0 (v i))=Matrix.diagonal (fun i=>(v i:ℝ)) := by
  ext i j
  by_cases hij : i=j
  · subst j
    simp only [secondMomentMatrix,Matrix.diagonal_apply_eq,←pow_two]
    have hh := integral_comp_eval (μ:=fun i=>gaussianReal 0 (v i)) (i:=i) (f:=fun x:ℝ=>x^2) (measurable_id.pow_const 2).aestronglyMeasurable
    exact hh.trans (gaussian_centered_second_moment (v i))
  · have hi : IndepFun (fun x:I→ℝ=>x i) (fun x:I→ℝ=>x j)
        (Measure.pi fun i=>gaussianReal 0 (v i)) :=
      (iIndepFun_pi (X:=fun _=>id) (fun _=>aemeasurable_id)).indepFun hij
    simp only [secondMomentMatrix,Matrix.diagonal_apply_ne _ hij]
    rw [hi.integral_fun_mul_eq_mul_integral (measurable_pi_apply i).aestronglyMeasurable
      (measurable_pi_apply j).aestronglyMeasurable]
    have hm (k:I) : (∫x:I→ℝ,x k ∂Measure.pi fun i=>gaussianReal 0 (v i))=0 := by
      have hh := integral_comp_eval (μ:=fun i=>gaussianReal 0 (v i)) (i:=k) (f:=fun x:ℝ=>x) measurable_id.aestronglyMeasurable
      exact hh.trans integral_id_gaussianReal
    rw [hm i,hm j]
    ring

theorem standardGaussian_secondMomentMatrix :
    secondMomentMatrix (Measure.pi fun _ : I=>gaussianReal 0 1)=1 := by
  rw [diagonalGaussian_secondMomentMatrix]
  simp

theorem secondMomentMatrix_map_fieldLinear {J : Type*} [Fintype J]
    (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (A : J→I→ℝ) (i j:J) :
    secondMomentMatrix (Q.map (fieldLinear A)) i j=A i ⬝ᵥ (secondMomentMatrix Q *ᵥ A j) := by
  change (∫x, x i*x j ∂Q.map (fieldLinear A))=A i ⬝ᵥ (secondMomentMatrix Q *ᵥ A j)
  rw [integral_map (fieldLinear A).continuous.measurable.aemeasurable (by fun_prop),
    ←gaussian_integral_dotProduct_mul Q hKL (A i) (A j)]
  apply integral_congr_ae
  filter_upwards [] with x
  simp only [fieldLinear_apply,dotProduct]

def gaussianUnwhiteningMatrix (Q : Measure (I→ℝ)) : I→I→ℝ :=
  fun i j=>Real.sqrt ((secondMomentMatrix_isHermitian Q).eigenvalues j)*
    (secondMomentMatrix_isHermitian Q).eigenvectorBasis j i

theorem gaussianUnwhiten_eq_fieldLinear (Q : Measure (I→ℝ)) :
    gaussianUnwhiten Q=fieldLinear (gaussianUnwhiteningMatrix Q) := by
  funext z i
  unfold gaussianUnwhiten coordinateMap
  rw [←(secondMomentMatrix_isHermitian Q).eigenvectorBasis.sum_repr_symm]
  simp only [WithLp.ofLp_sum,WithLp.ofLp_smul,WithLp.ofLp_toLp,Finset.sum_apply,
    Pi.smul_apply,smul_eq_mul,fieldLinear_apply,gaussianUnwhiteningMatrix]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem whitened_reconstruction (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    (Q.map (gaussianWhiten Q)).map (gaussianUnwhiten Q)=Q := by
  rw [Measure.map_map (gaussianUnwhiten_measurable Q) (gaussianWhiten_measurable Q),
    gaussianUnwhiten_whiten Q hKL,Measure.map_id]

/-- The actual rotated independent Gaussian construction matches every raw
second moment, including all cross moments. -/
theorem matchingGaussian_secondMomentMatrix (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    secondMomentMatrix (matchingGaussian Q)=secondMomentMatrix Q := by
  let W := Q.map (gaussianWhiten Q)
  haveI : IsProbabilityMeasure W := Measure.isProbabilityMeasure_map (gaussianWhiten_measurable Q).aemeasurable
  have hW : klDiv W (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞ := by
    rw [whitening_kl_identity Q hKL]
    exact (gaussian_full_moment_entropy_decomposition Q hKL).1
  have hwM := whitened_secondMomentMatrix Q hKL
  have hrec := whitened_reconstruction Q hKL
  have href := matchingGaussian_eq_unwhiten Q hKL
  rw [gaussianUnwhiten_eq_fieldLinear] at hrec href
  ext i j
  rw [href]
  conv_rhs => rw [←hrec]
  rw [secondMomentMatrix_map_fieldLinear _ (by simp),
    secondMomentMatrix_map_fieldLinear W hW,standardGaussian_secondMomentMatrix,hwM]

#print axioms matchingGaussian_secondMomentMatrix
end ConditionalNonpolynomial.Analytic
