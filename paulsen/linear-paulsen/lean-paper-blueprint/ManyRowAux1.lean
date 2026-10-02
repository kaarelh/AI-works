import Paulsen.Paper.Gaussian
import Paulsen.Linear.ManyRow

/-!
# Helpers for `Paulsen.Paper.ManyRow`: generic operator-norm facts

Elementary facts about the Euclidean operator norm `opNorm` of real matrices
(triangle inequality, scaling, Frobenius bound, the quadratic-form criterion for symmetric
matrices).  These are not paper items.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

variable {ι κ : Type*} [Fintype ι] [Fintype κ] [DecidableEq κ]

theorem mrx_opNorm_nonneg (A : Matrix ι κ ℝ) : 0 ≤ opNorm A := norm_nonneg _

theorem mrx_opNorm_add_le (A B : Matrix ι κ ℝ) : opNorm (A + B) ≤ opNorm A + opNorm B := by
  unfold opNorm
  rw [map_add, map_add]
  exact norm_add_le _ _

theorem mrx_opNorm_smul (c : ℝ) (A : Matrix ι κ ℝ) : opNorm (c • A) = |c| * opNorm A := by
  unfold opNorm
  rw [map_smul, map_smul, norm_smul, Real.norm_eq_abs]

theorem mrx_opNorm_neg (A : Matrix ι κ ℝ) : opNorm (-A) = opNorm A := by
  unfold opNorm
  rw [map_neg, map_neg, norm_neg]

theorem mrx_opNorm_sub_le (A B : Matrix ι κ ℝ) : opNorm (A - B) ≤ opNorm A + opNorm B := by
  rw [sub_eq_add_neg]
  exact (mrx_opNorm_add_le A (-B)).trans (by rw [mrx_opNorm_neg])

theorem mrx_opNorm_sum_le {α : Type*} (s : Finset α) (A : α → Matrix ι κ ℝ) :
    opNorm (∑ a ∈ s, A a) ≤ ∑ a ∈ s, opNorm (A a) := by
  unfold opNorm
  rw [map_sum, map_sum]
  exact norm_sum_le _ _

theorem mrx_opNorm_zero : opNorm (0 : Matrix ι κ ℝ) = 0 := by
  unfold opNorm
  rw [map_zero, map_zero, norm_zero]

theorem mrx_opNorm_mul_le {υ : Type*} [Fintype υ] [DecidableEq υ] (A : Matrix ι κ ℝ)
    (B : Matrix κ υ ℝ) : opNorm (A * B) ≤ opNorm A * opNorm B :=
  euclidean_operator_norm_mul_le A B

theorem mrx_opNorm_transpose [DecidableEq ι] (A : Matrix ι κ ℝ) :
    opNorm A.transpose = opNorm A :=
  euclidean_operator_norm_transpose A

/-- `‖A‖_op ≤ ‖A‖_F`. -/
theorem mrx_opNorm_le_sqrt_frobSq (A : Matrix ι κ ℝ) : opNorm A ≤ Real.sqrt (frobSq A) := by
  unfold opNorm
  apply ContinuousLinearMap.opNorm_le_bound _ (Real.sqrt_nonneg _)
  intro x
  apply (sq_le_sq₀ (norm_nonneg _) (mul_nonneg (Real.sqrt_nonneg _) (norm_nonneg _))).1
  change ‖Matrix.toEuclideanLin A x‖ ^ 2 ≤ _
  have hF : 0 ≤ frobSq A := Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ =>
    sq_nonneg _
  rw [mul_pow, Real.sq_sqrt hF, EuclideanSpace.real_norm_sq_eq, EuclideanSpace.real_norm_sq_eq]
  simp only [Matrix.toLpLin_apply, Matrix.mulVec, dotProduct]
  unfold frobSq
  rw [Finset.sum_mul]
  apply Finset.sum_le_sum
  intro i _
  exact Finset.sum_mul_sq_le_sq_mul_sq _ _ _

/-- `‖Ax‖² ≤ ‖A‖² ‖x‖²` in coordinates. -/
theorem mrx_sum_sq_mulVec_le (A : Matrix ι κ ℝ) (x : κ → ℝ) :
    ∑ i, (∑ j, A i j * x j) ^ 2 ≤ opNorm A ^ 2 * ∑ j, x j ^ 2 := by
  have h := (Matrix.toEuclideanLin A).toContinuousLinearMap.le_opNorm (WithLp.toLp 2 x)
  have hs := pow_le_pow_left₀ (norm_nonneg _) h 2
  unfold opNorm
  simpa only [mul_pow, EuclideanSpace.real_norm_sq_eq, Matrix.toLpLin_apply,
    LinearMap.coe_toContinuousLinearMap', Matrix.mulVec, dotProduct] using hs

/-- An eigenvalue of a symmetric matrix is the quadratic form at its unit eigenvector. -/
theorem mrx_eigenvalue_eq_quadratic [DecidableEq ι] (A : Matrix ι ι ℝ) (hA : A.IsHermitian)
    (k : ι) :
    hA.eigenvalues k = matrixQuadratic A (fun j => (hA.eigenvectorBasis k) j) ∧
    ∑ j, ((hA.eigenvectorBasis k) j) ^ 2 = 1 := by
  have h := euclideanQuadratic_eigenbasis A hA (Pi.single k 1)
  simp only [Pi.single_apply, ite_smul, one_smul, zero_smul, Finset.sum_ite_eq',
    Finset.mem_univ, if_true, ite_pow, one_pow, ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true,
    zero_pow, mul_ite, mul_one, mul_zero] at h
  rw [euclideanQuadratic_eq_matrixQuadratic] at h
  refine ⟨h.symm, ?_⟩
  have hn := hA.eigenvectorBasis.orthonormal.norm_eq_one k
  rw [← EuclideanSpace.real_norm_sq_eq, hn, one_pow]

/-- Quadratic-form criterion for the operator norm of a symmetric matrix. -/
theorem mrx_opNorm_le_of_quadratic [DecidableEq ι] (A : Matrix ι ι ℝ) (hA : A.IsHermitian) {C : ℝ}
    (hC : 0 ≤ C) (hq : ∀ x : ι → ℝ, |matrixQuadratic A x| ≤ C * ∑ i, x i ^ 2) :
    opNorm A ≤ C := by
  apply euclidean_operator_norm_le_of_eigenvalues A hA C hC
  intro i
  have h := euclideanQuadratic_eigenbasis A hA (Pi.single i 1)
  simp only [Pi.single_apply, ite_smul, one_smul, zero_smul, Finset.sum_ite_eq',
    Finset.mem_univ, if_true, ite_pow, one_pow, ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true,
    zero_pow, mul_ite, mul_one, mul_zero] at h
  rw [euclideanQuadratic_eq_matrixQuadratic] at h
  rw [← h]
  have hn := hA.eigenvectorBasis.orthonormal.norm_eq_one i
  have hsq : ∑ j, ((hA.eigenvectorBasis i) j) ^ 2 = 1 := by
    rw [← EuclideanSpace.real_norm_sq_eq, hn, one_pow]
  have := hq (fun j => (hA.eigenvectorBasis i) j)
  rwa [hsq, mul_one] at this

/-- `|xᵀAx| ≤ ‖A‖ ‖x‖²`. -/
theorem mrx_abs_matrixQuadratic_le_opNorm [DecidableEq ι] (A : Matrix ι ι ℝ) (x : ι → ℝ) :
    |matrixQuadratic A x| ≤ opNorm A * ∑ i, x i ^ 2 := by
  have heq : matrixQuadratic A x = inner ℝ (WithLp.toLp 2 x : EuclideanSpace ℝ ι)
      (Matrix.toEuclideanLin A (WithLp.toLp 2 x)) := by
    rw [← euclideanQuadratic, euclideanQuadratic_eq_matrixQuadratic]
  rw [heq]
  have h1 := abs_real_inner_le_norm (WithLp.toLp 2 x : EuclideanSpace ℝ ι)
    (Matrix.toEuclideanLin A (WithLp.toLp 2 x))
  have h2 := (Matrix.toEuclideanLin A).toContinuousLinearMap.le_opNorm (WithLp.toLp 2 x)
  have hx : ‖(WithLp.toLp 2 x : EuclideanSpace ℝ ι)‖ ^ 2 = ∑ i, x i ^ 2 :=
    EuclideanSpace.real_norm_sq_eq _
  calc _ ≤ _ := h1
    _ ≤ ‖(WithLp.toLp 2 x : EuclideanSpace ℝ ι)‖ *
        (opNorm A * ‖(WithLp.toLp 2 x : EuclideanSpace ℝ ι)‖) :=
      mul_le_mul_of_nonneg_left h2 (norm_nonneg _)
    _ = _ := by rw [← hx]; unfold opNorm; ring

end

end Paulsen.Paper
