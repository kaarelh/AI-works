import GaussianWhitening
import TanhResidualBall
import Mathlib.Analysis.InnerProductSpace.Adjoint

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Matrix
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianOrthogonal
variable {I : Type*} [Fintype I] [DecidableEq I]

def gaussianEigenScale (Q : Measure (I→ℝ)) : EuclideanSpace ℝ I→ₗ[ℝ]EuclideanSpace ℝ I where
  toFun y:=WithLp.toLp 2 (fun i=>Real.sqrt ((secondMomentMatrix_isHermitian Q).eigenvalues i)*y i)
  map_add' a b:=by ext i; simp; ring
  map_smul' c a:=by ext i; simp; ring

def gaussianUnwhiteningOperator (Q : Measure (I→ℝ)) : EuclideanSpace ℝ I→L[ℝ]EuclideanSpace ℝ I :=
  (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr.symm.toContinuousLinearMap.comp
    (gaussianEigenScale Q).toContinuousLinearMap

def gaussianFeaturePreconditioner (Q : Measure (I→ℝ)) : EuclideanSpace ℝ I→L[ℝ]EuclideanSpace ℝ I :=
  (gaussianUnwhiteningOperator Q).adjoint

theorem gaussianUnwhiten_eq_operator (Q : Measure (I→ℝ)) (y:I→ℝ) :
    gaussianUnwhiten Q y=WithLp.ofLp (gaussianUnwhiteningOperator Q (WithLp.toLp 2 y)) := rfl

theorem gaussianUnwhiteningOperator_norm (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    {g : ℝ} (hg : 0≤g) (hEig : ∀i,(secondMomentMatrix_isHermitian Q).eigenvalues i≤g^2) :
    ‖gaussianUnwhiteningOperator Q‖≤g := by
  apply ContinuousLinearMap.opNorm_le_bound _ hg
  intro y
  change ‖(secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr.symm (gaussianEigenScale Q y)‖≤g*‖y‖
  rw [LinearIsometryEquiv.norm_map]
  apply (sq_le_sq₀ (norm_nonneg _) (mul_nonneg hg (norm_nonneg _))).mp
  rw [EuclideanSpace.norm_sq_eq,mul_pow,EuclideanSpace.norm_sq_eq]
  simp only [gaussianEigenScale,LinearMap.coe_mk,AddHom.coe_mk,WithLp.ofLp_toLp,
    Real.norm_eq_abs,sq_abs,mul_pow,Real.sq_sqrt (secondMomentMatrix_eigenvalues_pos Q hKL _).le]
  rw [Finset.mul_sum]
  exact Finset.sum_le_sum fun i _=>mul_le_mul_of_nonneg_right (hEig i) (sq_nonneg (y i))

theorem gaussianFeaturePreconditioner_norm (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    {g : ℝ} (hg : 0≤g) (hEig : ∀i,(secondMomentMatrix_isHermitian Q).eigenvalues i≤g^2) :
    ‖gaussianFeaturePreconditioner Q‖≤g := by
  unfold gaussianFeaturePreconditioner
  rw [ContinuousLinearMap.adjoint.norm_map]
  exact gaussianUnwhiteningOperator_norm Q hKL hg hEig

theorem gaussianLinearForm_unwhiten (Q : Measure (I→ℝ)) (u : EuclideanSpace ℝ I) (z:I→ℝ) :
    gaussianLinearForm u (gaussianUnwhiten Q z)=
      gaussianLinearForm (gaussianFeaturePreconditioner Q u) z := by
  rw [gaussianUnwhiten_eq_operator]
  unfold gaussianLinearForm gaussianFeaturePreconditioner
  simp only [WithLp.toLp_ofLp]
  exact (ContinuousLinearMap.adjoint_inner_left (gaussianUnwhiteningOperator Q) (WithLp.toLp 2 z) u).symm

#print axioms gaussianFeaturePreconditioner_norm
#print axioms gaussianLinearForm_unwhiten
end ConditionalNonpolynomial.Analytic
