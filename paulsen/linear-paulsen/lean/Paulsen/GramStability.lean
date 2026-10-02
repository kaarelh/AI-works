import Paulsen.Projection
import Paulsen.GaussianLinearImage

/-! Frobenius and row-energy estimates for perturbing Gram matrices. -/

namespace Paulsen

open Matrix
open scoped BigOperators

theorem sqDistance_gram_le {n d : ℕ} (U V : Frame n d) :
    sqDistance (frameProjection U) (frameProjection V) ≤
      2 * (‖(Matrix.toEuclideanLin U).toContinuousLinearMap‖ ^ 2 +
        ‖(Matrix.toEuclideanLin V).toContinuousLinearMap‖ ^ 2) * sqDistance U V := by
  let A := (U - V) * U.transpose
  let B := V * (U - V).transpose
  have hdiff : frameProjection U - frameProjection V = A + B := by
    dsimp [A, B, frameProjection]
    rw [Matrix.transpose_sub, Matrix.sub_mul, Matrix.mul_sub]
    abel
  have hpoint : sqDistance (frameProjection U) (frameProjection V) ≤
      2 * (∑ i, ∑ j, (A i j) ^ 2) + 2 * (∑ i, ∑ j, (B i j) ^ 2) := by
    unfold sqDistance
    simp only [Finset.mul_sum, ← Finset.sum_add_distrib]
    apply Finset.sum_le_sum
    intro i _
    apply Finset.sum_le_sum
    intro j _
    have he := congrArg (fun M : Matrix (Fin n) (Fin n) ℝ => M i j) hdiff
    simp only [Matrix.sub_apply, Matrix.add_apply] at he
    rw [he]
    nlinarith [sq_nonneg (A i j - B i j)]
  have hA := entry_sq_sum_mul_le_right (U - V) U.transpose
  rw [euclidean_operator_norm_transpose] at hA
  have hB := entry_sq_sum_mul_le V (U - V).transpose
  have hnormD : (∑ i, ∑ j, ((U - V).transpose i j) ^ 2) = sqDistance U V := by
    rw [Finset.sum_comm]
    rfl
  rw [hnormD] at hB
  change (∑ i, ∑ j, (A i j) ^ 2) ≤
    ‖(Matrix.toEuclideanLin U).toContinuousLinearMap‖ ^ 2 * sqDistance U V at hA
  change (∑ i, ∑ j, (B i j) ^ 2) ≤
    ‖(Matrix.toEuclideanLin V).toContinuousLinearMap‖ ^ 2 * sqDistance U V at hB
  nlinarith

/-- Right multiplication controls each row separately, with no row-count loss. -/
theorem rowNormSq_mul_le {n d k : ℕ} (U : Frame n d) (M : Frame d k) (i : Fin n) :
    rowNormSq (U * M) i ≤
      ‖(Matrix.toEuclideanLin M).toContinuousLinearMap‖ ^ 2 * rowNormSq U i := by
  let R : Frame 1 d := Matrix.of (fun _ j => U i j)
  have h := entry_sq_sum_mul_le_right R M
  simpa only [R, Fin.sum_univ_one, Matrix.mul_apply, Matrix.of_apply, rowNormSq] using h

/-- Multiplying a covariance error on both sides controls every affected Gram
row by the corresponding leverage and the two operator norms. -/
theorem rowNormSq_gram_error_le {n d : ℕ}
    (V : Frame n d) (E : Matrix (Fin d) (Fin d) ℝ) (i : Fin n) :
    rowNormSq (V * E * V.transpose) i ≤
      ‖(Matrix.toEuclideanLin V).toContinuousLinearMap‖ ^ 2 *
        ‖(Matrix.toEuclideanLin E).toContinuousLinearMap‖ ^ 2 * rowNormSq V i := by
  have h := rowNormSq_mul_le (V * E) V.transpose i
  rw [euclidean_operator_norm_transpose] at h
  apply h.trans
  simpa only [mul_assoc] using mul_le_mul_of_nonneg_left
    (rowNormSq_mul_le V E i) (sq_nonneg ‖(Matrix.toEuclideanLin V).toContinuousLinearMap‖)

end Paulsen
