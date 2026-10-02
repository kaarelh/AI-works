import Paulsen.Definitions
import Paulsen.Graph

/-! The projection and graph identities specialized to Parseval frames. -/

namespace Paulsen

def frameProjection {n d : ℕ} (U : Frame n d) : Matrix (Fin n) (Fin n) ℝ :=
  U * U.transpose

theorem frameProjection_transpose {n d : ℕ} (U : Frame n d) :
    (frameProjection U).transpose = frameProjection U := by
  simp [frameProjection, Matrix.transpose_mul]

theorem frameProjection_symm {n d : ℕ} (U : Frame n d) (i j : Fin n) :
    frameProjection U i j = frameProjection U j i := by
  have h := congrArg (fun P : Matrix (Fin n) (Fin n) ℝ ↦ P j i)
    (frameProjection_transpose U)
  exact h

theorem IsParseval.frameProjection_idempotent {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) :
    frameProjection U * frameProjection U = frameProjection U := by
  change (U * U.transpose) * (U * U.transpose) = U * U.transpose
  calc
    (U * U.transpose) * (U * U.transpose) =
        U * (U.transpose * U) * U.transpose := by simp only [Matrix.mul_assoc]
    _ = U * U.transpose := by rw [hU, Matrix.mul_one]

theorem frameProjection_diagonal {n d : ℕ} (U : Frame n d) (i : Fin n) :
    frameProjection U i i = rowNormSq U i := by
  simp [frameProjection, Matrix.mul_apply, rowNormSq, pow_two]

theorem IsParseval.projection_row_squares {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (i : Fin n) :
    (∑ j, (frameProjection U i j) ^ 2) = rowNormSq U i := by
  rw [← frameProjection_diagonal]
  exact Paulsen.projection_row_squares _ (frameProjection_symm U)
    hU.frameProjection_idempotent i

theorem IsParseval.laplacian_posSemidef {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) :
    (projectionLaplacian (frameProjection U)).PosSemidef :=
  projectionLaplacian_posSemidef _ (frameProjection_symm U) hU.frameProjection_idempotent

theorem IsParseval.laplacian_energy {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (x : Fin n → ℝ) :
    matrixQuadratic (projectionLaplacian (frameProjection U)) x =
      (1 / 2 : ℝ) * ∑ i, ∑ j, (frameProjection U i j) ^ 2 * (x i - x j) ^ 2 :=
  projectionLaplacian_quadratic _ (frameProjection_symm U) hU.frameProjection_idempotent x

theorem IsParseval.leverage_le_one {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (i : Fin n) :
    rowNormSq U i ≤ 1 := by
  have hsum := hU.projection_row_squares i
  have hdiag : (frameProjection U i i) ^ 2 ≤ ∑ j, (frameProjection U i j) ^ 2 :=
    Finset.single_le_sum (fun j _ ↦ sq_nonneg _) (Finset.mem_univ i)
  rw [hsum, frameProjection_diagonal] at hdiag
  have hp := rowNormSq_nonneg U i
  nlinarith

theorem IsEqualNorm.projection_diagonal {n d : ℕ} {U : Frame n d}
    (hU : IsEqualNorm U) (i : Fin n) :
    frameProjection U i i = (d : ℝ) / (n : ℝ) := by
  rw [frameProjection_diagonal, hU i]

end Paulsen
