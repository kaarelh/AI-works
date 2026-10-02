import Paulsen.GaussianQuadraticForm
import Mathlib.Analysis.InnerProductSpace.Adjoint

/-!
# Quadratic forms of deterministic linear Gaussian images

A rectangular linear map pulls a quadratic form back to its congruence matrix.
This gives exact moments and tails for Gaussian vectors with correlated entries,
including singular laws obtained by orthogonal conditioning.
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory NNReal

noncomputable section

namespace Paulsen

variable {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]

/-- Pulling back a real quadratic form by a rectangular matrix. -/
theorem euclideanQuadratic_linear_image (A : Matrix ι ι ℝ) (C : Matrix ι κ ℝ)
    (x : EuclideanSpace ℝ κ) :
    euclideanQuadratic A (Matrix.toEuclideanLin C x) =
      euclideanQuadratic (C.transpose * A * C) x := by
  unfold euclideanQuadratic
  have htranspose : Matrix.toEuclideanLin C.transpose = (Matrix.toEuclideanLin C).adjoint := by
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
      Matrix.toEuclideanLin_conjTranspose_eq_adjoint C
  simp only [Matrix.toEuclideanLin, Matrix.toLpLin_mul_same, LinearMap.comp_apply]
  change inner ℝ (Matrix.toEuclideanLin C x) (Matrix.toEuclideanLin A (Matrix.toEuclideanLin C x)) =
    inner ℝ x (Matrix.toEuclideanLin C.transpose
      (Matrix.toEuclideanLin A (Matrix.toEuclideanLin C x)))
  rw [htranspose, LinearMap.adjoint_inner_right]

omit [DecidableEq ι] [Fintype κ] [DecidableEq κ] in
theorem isHermitian_quadratic_pullback (A : Matrix ι ι ℝ) (hA : A.IsHermitian)
    (C : Matrix ι κ ℝ) : (C.transpose * A * C).IsHermitian := by
  simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
    Matrix.isHermitian_conjTranspose_mul_mul C hA

/-- Exact variance for an arbitrary deterministic linear Gaussian image. -/
theorem variance_euclideanQuadratic_linear_image (A : Matrix ι ι ℝ)
    (hA : A.IsHermitian) (C : Matrix ι κ ℝ) :
    variance (fun x : EuclideanSpace ℝ κ =>
      euclideanQuadratic A (Matrix.toEuclideanLin C x) - (C.transpose * A * C).trace)
      (stdGaussian (EuclideanSpace ℝ κ)) =
      2 * ∑ i, ∑ j, ((C.transpose * A * C) i j) ^ 2 := by
  simp_rw [euclideanQuadratic_linear_image]
  exact variance_euclideanQuadratic_stdGaussian _ (isHermitian_quadratic_pullback A hA C)

/-- Exact centered second moment, also valid when the linear image is singular. -/
theorem integral_sq_centered_euclideanQuadratic_linear_image (A : Matrix ι ι ℝ)
    (hA : A.IsHermitian) (C : Matrix ι κ ℝ) :
    (∫ x : EuclideanSpace ℝ κ,
      (euclideanQuadratic A (Matrix.toEuclideanLin C x) - (C.transpose * A * C).trace) ^ 2
      ∂stdGaussian (EuclideanSpace ℝ κ)) =
      2 * ∑ i, ∑ j, ((C.transpose * A * C) i j) ^ 2 := by
  simp_rw [euclideanQuadratic_linear_image]
  exact integral_sq_centered_euclideanQuadratic_stdGaussian _
    (isHermitian_quadratic_pullback A hA C)

/-- A correlated Gaussian quadratic-form tail from the pullback matrix norms. -/
theorem euclideanQuadratic_linear_image_abs_tail (A : Matrix ι ι ℝ)
    (hA : A.IsHermitian) (C : Matrix ι κ ℝ) (B V u : ℝ)
    (hB : 0 < B) (hV : 0 < V) (hu : 0 ≤ u)
    (hnorm : ‖(Matrix.toEuclideanLin (C.transpose * A * C)).toContinuousLinearMap‖ ≤ B)
    (henergy : (∑ i, ∑ j, ((C.transpose * A * C) i j) ^ 2) ≤ V) :
    (stdGaussian (EuclideanSpace ℝ κ)).real
      {x | u ≤ |euclideanQuadratic A (Matrix.toEuclideanLin C x) -
        (C.transpose * A * C).trace|} ≤
      2 * Real.exp (-min (u ^ 2 / (16 * V)) (u / (16 * B))) := by
  simp_rw [euclideanQuadratic_linear_image]
  exact euclideanQuadratic_stdGaussian_abs_tail_of_operator_norm _
    (isHermitian_quadratic_pullback A hA C) B V u hB hV hu hnorm henergy

/-- Euclidean operator norm is unchanged by matrix transpose. -/
theorem euclidean_operator_norm_transpose (C : Matrix ι κ ℝ) :
    ‖(Matrix.toEuclideanLin C.transpose).toContinuousLinearMap‖ =
      ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ := by
  have htranspose : Matrix.toEuclideanLin C.transpose = (Matrix.toEuclideanLin C).adjoint := by
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
      Matrix.toEuclideanLin_conjTranspose_eq_adjoint C
  rw [htranspose, LinearMap.adjoint_toContinuousLinearMap]
  exact ContinuousLinearMap.adjoint.norm_map _

variable {υ : Type*} [Fintype υ] [DecidableEq υ]

omit [DecidableEq ι] [DecidableEq υ] in
/-- Left multiplication costs at most the squared Euclidean operator norm in
squared Frobenius norm. -/
theorem entry_sq_sum_mul_le (C : Matrix ι κ ℝ) (D : Matrix κ υ ℝ) :
    (∑ i, ∑ j, ((C * D) i j) ^ 2) ≤
      ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 *
        ∑ i, ∑ j, (D i j) ^ 2 := by
  rw [Finset.sum_comm, Finset.sum_comm (f := fun i j => (D i j) ^ 2), Finset.mul_sum]
  apply Finset.sum_le_sum
  intro j hj
  let x : EuclideanSpace ℝ κ := WithLp.toLp 2 (fun i => D i j)
  have h := (Matrix.toEuclideanLin C).toContinuousLinearMap.le_opNorm x
  have hsq := sq_le_sq₀ (norm_nonneg (Matrix.toEuclideanLin C x))
    (mul_nonneg (norm_nonneg _) (norm_nonneg x)) |>.2 h
  simpa only [mul_pow, EuclideanSpace.real_norm_sq_eq, Matrix.toLpLin_apply,
    Matrix.mulVec, dotProduct, x, Matrix.mul_apply] using hsq

omit [DecidableEq υ] in
/-- The corresponding estimate for right multiplication. -/
theorem entry_sq_sum_mul_le_right (D : Matrix υ ι ℝ) (C : Matrix ι κ ℝ) :
    (∑ i, ∑ j, ((D * C) i j) ^ 2) ≤
      ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 *
        ∑ i, ∑ j, (D i j) ^ 2 := by
  have h := entry_sq_sum_mul_le C.transpose D.transpose
  rw [← Matrix.transpose_mul, euclidean_operator_norm_transpose] at h
  simp only [Matrix.transpose_apply] at h
  rw [Finset.sum_comm (f := fun i j => ((D * C) i j) ^ 2),
    Finset.sum_comm (f := fun i j => (D i j) ^ 2)]
  exact h

/-- Congruence costs at most the fourth power of the linear-image operator norm. -/
theorem entry_sq_sum_quadratic_pullback_le (A : Matrix ι ι ℝ) (C : Matrix ι κ ℝ) :
    (∑ i, ∑ j, ((C.transpose * A * C) i j) ^ 2) ≤
      ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 4 *
        ∑ i, ∑ j, (A i j) ^ 2 := by
  have hleft := entry_sq_sum_mul_le C.transpose A
  rw [euclidean_operator_norm_transpose] at hleft
  calc
    _ ≤ ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 *
        ∑ i, ∑ j, ((C.transpose * A) i j) ^ 2 := entry_sq_sum_mul_le_right _ _
    _ ≤ ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 *
        (‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 *
          ∑ i, ∑ j, (A i j) ^ 2) := mul_le_mul_of_nonneg_left hleft (sq_nonneg _)
    _ = _ := by ring

omit [DecidableEq ι] in
/-- Multiplicativity bound for Euclidean operator norms of rectangular matrices. -/
theorem euclidean_operator_norm_mul_le (C : Matrix ι κ ℝ) (D : Matrix κ υ ℝ) :
    ‖(Matrix.toEuclideanLin (C * D)).toContinuousLinearMap‖ ≤
      ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ *
        ‖(Matrix.toEuclideanLin D).toContinuousLinearMap‖ := by
  have hcomp : (Matrix.toEuclideanLin (C * D)).toContinuousLinearMap =
      (Matrix.toEuclideanLin C).toContinuousLinearMap.comp
        (Matrix.toEuclideanLin D).toContinuousLinearMap := by
    ext x
    simp only [LinearMap.coe_toContinuousLinearMap', ContinuousLinearMap.comp_apply,
      Matrix.toEuclideanLin, Matrix.toLpLin_mul_same, LinearMap.comp_apply]
  rw [hcomp]
  exact ContinuousLinearMap.opNorm_comp_le _ _

/-- The covariance square-root contributes its operator norm squared. -/
theorem euclidean_operator_norm_quadratic_pullback_le (A : Matrix ι ι ℝ)
    (C : Matrix ι κ ℝ) :
    ‖(Matrix.toEuclideanLin (C.transpose * A * C)).toContinuousLinearMap‖ ≤
      ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 *
        ‖(Matrix.toEuclideanLin A).toContinuousLinearMap‖ := by
  have hleft := euclidean_operator_norm_mul_le C.transpose A
  rw [euclidean_operator_norm_transpose] at hleft
  calc
    _ ≤ ‖(Matrix.toEuclideanLin (C.transpose * A)).toContinuousLinearMap‖ *
        ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ := euclidean_operator_norm_mul_le _ _
    _ ≤ (‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ *
        ‖(Matrix.toEuclideanLin A).toContinuousLinearMap‖) *
        ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ :=
      mul_le_mul_of_nonneg_right hleft (norm_nonneg _)
    _ = _ := by ring

/-- Variance bound from a covariance-factor norm bound, with no nonsingularity
assumption. In particular a contraction scaled by 1/√n gives 2/n² times the
squared Frobenius norm of the coefficient matrix. -/
theorem variance_euclideanQuadratic_linear_image_le (A : Matrix ι ι ℝ)
    (hA : A.IsHermitian) (C : Matrix ι κ ℝ) (σ : ℝ)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ σ) :
    variance (fun x : EuclideanSpace ℝ κ =>
      euclideanQuadratic A (Matrix.toEuclideanLin C x) - (C.transpose * A * C).trace)
      (stdGaussian (EuclideanSpace ℝ κ)) ≤
      2 * σ ^ 2 * ∑ i, ∑ j, (A i j) ^ 2 := by
  rw [variance_euclideanQuadratic_linear_image A hA C]
  have hpow : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 4 ≤ σ ^ 2 := by
    nlinarith [sq_nonneg (σ - ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2)]
  calc
    _ ≤ 2 * (‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 4 *
        ∑ i, ∑ j, (A i j) ^ 2) :=
      mul_le_mul_of_nonneg_left (entry_sq_sum_quadratic_pullback_le A C) (by norm_num)
    _ ≤ 2 * (σ ^ 2 * ∑ i, ∑ j, (A i j) ^ 2) := by
      gcongr
    _ = _ := by ring

/-- A quantitative correlated-Gaussian tail in terms of the original coefficient
matrix norms and a bound σ on the covariance-factor operator norm squared. -/
theorem euclideanQuadratic_linear_image_abs_tail_of_bounds
    (A : Matrix ι ι ℝ) (hA : A.IsHermitian) (C : Matrix ι κ ℝ) (σ B V u : ℝ)
    (hσ : 0 < σ) (hB : 0 < B) (hV : 0 < V) (hu : 0 ≤ u)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ σ)
    (hAop : ‖(Matrix.toEuclideanLin A).toContinuousLinearMap‖ ≤ B)
    (hAF : (∑ i, ∑ j, (A i j) ^ 2) ≤ V) :
    (stdGaussian (EuclideanSpace ℝ κ)).real
      {x | u ≤ |euclideanQuadratic A (Matrix.toEuclideanLin C x) -
        (C.transpose * A * C).trace|} ≤
      2 * Real.exp (-min (u ^ 2 / (16 * (σ ^ 2 * V))) (u / (16 * (σ * B)))) := by
  apply euclideanQuadratic_linear_image_abs_tail A hA C (σ * B) (σ ^ 2 * V) u
    (mul_pos hσ hB) (mul_pos (sq_pos_of_pos hσ) hV) hu
  · exact (euclidean_operator_norm_quadratic_pullback_le A C).trans
      (mul_le_mul hC hAop (norm_nonneg _) hσ.le)
  · have hpow : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 4 ≤ σ ^ 2 := by
      nlinarith [sq_nonneg (σ - ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2)]
    exact (entry_sq_sum_quadratic_pullback_le A C).trans
      (mul_le_mul hpow hAF (by positivity) (sq_nonneg _))

/-- The covariance matrix has operator norm equal to the square of the factor's
operator norm; rectangular and singular factors are allowed. -/
theorem euclidean_operator_norm_covariance (C : Matrix ι κ ℝ) :
    ‖(Matrix.toEuclideanLin (C * C.transpose)).toContinuousLinearMap‖ =
      ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 := by
  have hcomp : (Matrix.toEuclideanLin (C * C.transpose)).toContinuousLinearMap =
      (Matrix.toEuclideanLin C).toContinuousLinearMap.comp
        (Matrix.toEuclideanLin C.transpose).toContinuousLinearMap := by
    ext x
    simp only [LinearMap.coe_toContinuousLinearMap', ContinuousLinearMap.comp_apply,
      Matrix.toEuclideanLin, Matrix.toLpLin_mul_same, LinearMap.comp_apply]
  have hadj : (Matrix.toEuclideanLin C).toContinuousLinearMap =
      (Matrix.toEuclideanLin C.transpose).toContinuousLinearMap.adjoint := by
    rw [← LinearMap.adjoint_toContinuousLinearMap,
      ← Matrix.toEuclideanLin_conjTranspose_eq_adjoint]
    simp only [Matrix.conjTranspose_eq_transpose_of_trivial, Matrix.transpose_transpose]
  rw [hcomp]
  nth_rw 1 [hadj]
  rw [ContinuousLinearMap.norm_adjoint_comp_self, euclidean_operator_norm_transpose, pow_two]

/-- Covariance domination supplies the variance bound used after conditioning. -/
theorem variance_euclideanQuadratic_linear_image_le_of_covariance
    (A : Matrix ι ι ℝ) (hA : A.IsHermitian) (C : Matrix ι κ ℝ) (σ : ℝ)
    (hCov : ‖(Matrix.toEuclideanLin (C * C.transpose)).toContinuousLinearMap‖ ≤ σ) :
    variance (fun x : EuclideanSpace ℝ κ =>
      euclideanQuadratic A (Matrix.toEuclideanLin C x) - (C.transpose * A * C).trace)
      (stdGaussian (EuclideanSpace ℝ κ)) ≤
      2 * σ ^ 2 * ∑ i, ∑ j, (A i j) ^ 2 := by
  apply variance_euclideanQuadratic_linear_image_le A hA C σ
  rwa [euclidean_operator_norm_covariance] at hCov

end Paulsen
