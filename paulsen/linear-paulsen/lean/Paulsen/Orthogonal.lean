import Paulsen.Projection

/-! Orthogonal changes of coordinates preserve frames and their squared distance. -/

namespace Paulsen

open Matrix

theorem frameProjection_mul_orthogonal {n d : ℕ} (U : Frame n d)
    (R : Matrix (Fin d) (Fin d) ℝ) (hR : R * R.transpose = 1) :
    frameProjection (U * R) = frameProjection U := by
  unfold frameProjection
  rw [Matrix.transpose_mul]
  calc
    U * R * (R.transpose * U.transpose) =
        U * (R * R.transpose) * U.transpose := by simp only [Matrix.mul_assoc]
    _ = U * U.transpose := by rw [hR, Matrix.mul_one]

theorem rowNormSq_mul_orthogonal {n d : ℕ} (U : Frame n d)
    (R : Matrix (Fin d) (Fin d) ℝ) (hR : R * R.transpose = 1) (i : Fin n) :
    rowNormSq (U * R) i = rowNormSq U i := by
  rw [← frameProjection_diagonal, frameProjection_mul_orthogonal U R hR,
    frameProjection_diagonal]

theorem IsParseval.mul_orthogonal {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (R : Matrix (Fin d) (Fin d) ℝ)
    (hR : R.transpose * R = 1) : IsParseval (U * R) := by
  unfold IsParseval
  rw [Matrix.transpose_mul]
  calc
    R.transpose * U.transpose * (U * R) = R.transpose * (U.transpose * U) * R := by
      simp only [Matrix.mul_assoc]
    _ = 1 := by rw [hU, Matrix.mul_one, hR]

theorem IsEqualNorm.mul_orthogonal {n d : ℕ} {U : Frame n d}
    (hU : IsEqualNorm U) (R : Matrix (Fin d) (Fin d) ℝ)
    (hR : R * R.transpose = 1) : IsEqualNorm (U * R) := by
  intro i
  rw [rowNormSq_mul_orthogonal U R hR, hU i]

theorem sqDistance_eq_sum_rowNormSq_sub {n d : ℕ} (U V : Frame n d) :
    sqDistance U V = ∑ i, rowNormSq (U - V) i := rfl

theorem sqDistance_mul_orthogonal {n d : ℕ} (U V : Frame n d)
    (R : Matrix (Fin d) (Fin d) ℝ) (hR : R * R.transpose = 1) :
    sqDistance (U * R) (V * R) = sqDistance U V := by
  rw [sqDistance_eq_sum_rowNormSq_sub, ← Matrix.sub_mul,
    sqDistance_eq_sum_rowNormSq_sub]
  exact Finset.sum_congr rfl fun i _ ↦ rowNormSq_mul_orthogonal (U - V) R hR i

theorem frameEnergy_eq_vectorNormSq_mulVec {n d : ℕ} (U : Frame n d)
    (x : Fin d → ℝ) : frameEnergy U x = vectorNormSq (U *ᵥ x) := rfl

theorem frameEnergy_mul {n d k : ℕ} (U : Frame n d)
    (R : Matrix (Fin d) (Fin k) ℝ) (x : Fin k → ℝ) :
    frameEnergy (U * R) x = frameEnergy U (R *ᵥ x) := by
  simp only [frameEnergy_eq_vectorNormSq_mulVec, Matrix.mulVec_mulVec]

theorem IsNearlyParseval.mul_orthogonal {n d : ℕ} {ε : ℝ} {U : Frame n d}
    (hU : IsNearlyParseval ε U) (R : Matrix (Fin d) (Fin d) ℝ)
    (hR : R.transpose * R = 1) : IsNearlyParseval ε (U * R) := by
  intro x
  have h := hU (R *ᵥ x)
  have hn : vectorNormSq (R *ᵥ x) = vectorNormSq x :=
    IsParseval.frameEnergy_eq hR x
  rw [hn] at h
  rwa [frameEnergy_mul]

end Paulsen
