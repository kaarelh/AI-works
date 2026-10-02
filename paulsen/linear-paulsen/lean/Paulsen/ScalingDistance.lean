import Paulsen.ScalingExistence
import Paulsen.GaussianLinearImage
import Paulsen.Orthogonal

/-!
# Static distance estimates for diagonal scaling

Projection distance is twice an orthogonal residual. Diagonal scaling has
residual energy equal to the initial projection's graph Dirichlet form.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

theorem entry_sq_sum_eq_trace {n d : ℕ} (A : Frame n d) :
    (∑ i, ∑ j, A i j ^ 2) = (A.transpose * A).trace := by
  simp only [Matrix.trace, Matrix.diag, Matrix.mul_apply, Matrix.transpose_apply, pow_two]
  exact Finset.sum_comm

theorem sqDistance_eq_trace_sub {n d : ℕ} (A B : Frame n d) :
    sqDistance A B = ((A - B).transpose * (A - B)).trace :=
  entry_sq_sum_eq_trace (A - B)

theorem IsParseval.frameProjection_trace {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) : (frameProjection U).trace = (d : ℝ) := by
  rw [frameProjection, Matrix.trace_mul_comm, hU]
  simp

/-- The squared Frobenius norm of an orthogonal residual. -/
theorem projection_residual_sq_sum {n d k : ℕ} (U : Frame n d) (A : Frame n k)
    (hU : IsParseval U) :
    (∑ i, ∑ j, ((((1 : Matrix (Fin n) (Fin n) ℝ) - frameProjection U) * A) i j) ^ 2) =
      (A.transpose * A).trace - (A.transpose * frameProjection U * A).trace := by
  have hP : ((1 : Matrix (Fin n) (Fin n) ℝ) - frameProjection U) * ((1 : Matrix (Fin n) (Fin n) ℝ) - frameProjection U) =
      1 - frameProjection U := by
    rw [Matrix.sub_mul, Matrix.mul_sub, Matrix.mul_sub, Matrix.one_mul,
      Matrix.one_mul, Matrix.mul_one, hU.frameProjection_idempotent]
    abel
  rw [entry_sq_sum_eq_trace, Matrix.transpose_mul, Matrix.transpose_sub,
    Matrix.transpose_one, frameProjection_transpose]
  calc
    (A.transpose * ((1 : Matrix (Fin n) (Fin n) ℝ) - frameProjection U) * (((1 : Matrix (Fin n) (Fin n) ℝ) - frameProjection U) * A)).trace =
        (A.transpose * (((1 : Matrix (Fin n) (Fin n) ℝ) - frameProjection U) * ((1 : Matrix (Fin n) (Fin n) ℝ) - frameProjection U)) * A).trace := by
      simp only [Matrix.mul_assoc]
    _ = (A.transpose * ((1 : Matrix (Fin n) (Fin n) ℝ) - frameProjection U) * A).trace := by rw [hP]
    _ = _ := by rw [Matrix.mul_sub, Matrix.mul_one, Matrix.sub_mul, Matrix.trace_sub]

/-- Two Parseval frames of the same rank have projection distance equal to
twice the squared orthogonal residual of either frame. -/
theorem projection_sqDistance_eq_twice_residual {n d : ℕ}
    (U V : Frame n d) (hU : IsParseval U) (hV : IsParseval V) :
    sqDistance (frameProjection U) (frameProjection V) =
      2 * ∑ i, ∑ j, ((((1 : Matrix (Fin n) (Fin n) ℝ) - frameProjection U) * V) i j) ^ 2 := by
  rw [projection_residual_sq_sum U V hU, hV]
  have hcyc : (V.transpose * frameProjection U * V).trace =
      (frameProjection U * frameProjection V).trace := by
    rw [Matrix.trace_mul_cycle, Matrix.trace_mul_comm]
    rfl
  rw [hcyc, sqDistance_eq_trace_sub, Matrix.transpose_sub,
    frameProjection_transpose, frameProjection_transpose,
    Matrix.sub_mul, Matrix.mul_sub, Matrix.mul_sub,
    hU.frameProjection_idempotent, hV.frameProjection_idempotent,
    Matrix.trace_sub, Matrix.trace_sub, Matrix.trace_sub,
    hU.frameProjection_trace, hV.frameProjection_trace,
    Matrix.trace_mul_comm (frameProjection V) (frameProjection U)]
  simp only [Matrix.trace_one, Fintype.card_fin]
  ring

/-- The residual created by row scaling is precisely the original projection
Laplacian's quadratic form. -/
theorem rowScale_residual_energy {n d : ℕ}
    (U : Frame n d) (hU : IsParseval U) (w : Fin n → ℝ) :
    (∑ i, ∑ j, ((((1 : Matrix (Fin n) (Fin n) ℝ) - frameProjection U) * rowScale U w) i j) ^ 2) =
      matrixQuadratic (projectionLaplacian (frameProjection U)) w := by
  rw [projection_residual_sq_sum U (rowScale U w) hU]
  have hfirst : ((rowScale U w).transpose * rowScale U w).trace =
      ∑ i, (frameProjection U i i) * w i ^ 2 := by
    rw [← entry_sq_sum_eq_trace]
    simp only [rowScale, Matrix.diagonal_mul, mul_pow]
    simp only [← Finset.mul_sum, frameProjection_diagonal, rowNormSq]
    apply Finset.sum_congr rfl
    intro i _
    ring
  have hsecond : ((rowScale U w).transpose * frameProjection U * rowScale U w).trace =
      ∑ i, ∑ j, w i * (frameProjection U i j) ^ 2 * w j := by
    have hmat : (frameProjection U * rowScale U w) * (rowScale U w).transpose =
        (frameProjection U * Matrix.diagonal w) *
          (frameProjection U * Matrix.diagonal w) := by
      simp only [rowScale, Matrix.transpose_mul, Matrix.diagonal_transpose,
        frameProjection, Matrix.mul_assoc]
    rw [Matrix.trace_mul_cycle, Matrix.trace_mul_comm, ← Matrix.mul_assoc, hmat]
    change (∑ i, ∑ j, (frameProjection U * Matrix.diagonal w) i j *
      (frameProjection U * Matrix.diagonal w) j i) = _
    simp only [Matrix.mul_diagonal]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    rw [frameProjection_symm U j i]
    ring
  rw [hfirst, hsecond, projectionLaplacian, matrixQuadratic_sub,
    matrixQuadratic_diagonal]
  rfl

/-- A lower bound on every row scale gives a lower bound on all frame energies. -/
theorem frameEnergy_rowScale_lower {n d : ℕ} (U : Frame n d)
    (w : Fin n → ℝ) (m : ℝ) (hm : 0 ≤ m) (hw : ∀ i, m ≤ w i)
    (x : Fin d → ℝ) :
    m ^ 2 * frameEnergy U x ≤ frameEnergy (rowScale U w) x := by
  simp only [frameEnergy, rowScale, Matrix.diagonal_mul,
    mul_assoc, ← Finset.mul_sum, mul_pow]
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  apply mul_le_mul_of_nonneg_right _ (sq_nonneg _)
  exact pow_le_pow_left₀ hm (hw i) 2

/-- The Euclidean operator norm of any Parseval right whitening is bounded
by the reciprocal of the minimum row scale. -/
theorem whitening_operator_norm_le {n d : ℕ}
    (U : Frame n d) (w : Fin n → ℝ) (M : Matrix (Fin d) (Fin d) ℝ)
    (hU : IsParseval U) (hV : IsParseval (rowScale U w * M))
    (m : ℝ) (hm : 0 < m) (hw : ∀ i, m ≤ w i) :
    ‖(Matrix.toEuclideanLin M).toContinuousLinearMap‖ ≤ 1 / m := by
  apply ContinuousLinearMap.opNorm_le_bound _ (le_of_lt (one_div_pos.mpr hm))
  intro x
  have he := frameEnergy_rowScale_lower U w m (le_of_lt hm) hw (M *ᵥ x.ofLp)
  rw [hU.frameEnergy_eq, ← frameEnergy_mul, hV.frameEnergy_eq] at he
  have he' : m ^ 2 * ‖Matrix.toEuclideanLin M x‖ ^ 2 ≤ ‖x‖ ^ 2 := by
    simpa only [EuclideanSpace.real_norm_sq_eq, Matrix.toLpLin_apply,
      vectorNormSq] using he
  have hn : m * ‖Matrix.toEuclideanLin M x‖ ≤ ‖x‖ := by
    nlinarith [norm_nonneg x, norm_nonneg (Matrix.toEuclideanLin M x)]
  change ‖Matrix.toEuclideanLin M x‖ ≤ 1 / m * ‖x‖
  calc
    ‖Matrix.toEuclideanLin M x‖ ≤ ‖x‖ / m := by
      apply (le_div_iff₀ hm).mpr
      simpa only [mul_comm] using hn
    _ = 1 / m * ‖x‖ := by ring

/-- Static projection-distance control for diagonal scaling followed by any
Parseval right whitening. This replaces the distance estimate from a
horizontal scaling flow. -/
theorem diagonal_scaling_projection_distance_le {n d : ℕ}
    (U : Frame n d) (w : Fin n → ℝ) (M : Matrix (Fin d) (Fin d) ℝ)
    (hU : IsParseval U) (hV : IsParseval (rowScale U w * M))
    (m : ℝ) (hm : 0 < m) (hw : ∀ i, m ≤ w i) :
    sqDistance (frameProjection U) (frameProjection (rowScale U w * M)) ≤
      (2 / m ^ 2) * matrixQuadratic (projectionLaplacian (frameProjection U)) w := by
  rw [projection_sqDistance_eq_twice_residual U _ hU hV]
  have hnorm := whitening_operator_norm_le U w M hU hV m hm hw
  have hnormsq : ‖(Matrix.toEuclideanLin M).toContinuousLinearMap‖ ^ 2 ≤ (1 / m) ^ 2 :=
    pow_le_pow_left₀ (norm_nonneg _) hnorm 2
  have henergy : 0 ≤ matrixQuadratic (projectionLaplacian (frameProjection U)) w := by
    rw [← rowScale_residual_energy U hU w]
    positivity
  have hmul := entry_sq_sum_mul_le_right (((1 : Matrix (Fin n) (Fin n) ℝ) - frameProjection U) * rowScale U w) M
  rw [Matrix.mul_assoc, rowScale_residual_energy U hU w] at hmul
  calc
    _ ≤ 2 * (‖(Matrix.toEuclideanLin M).toContinuousLinearMap‖ ^ 2 *
        matrixQuadratic (projectionLaplacian (frameProjection U)) w) := by linarith
    _ ≤ 2 * ((1 / m) ^ 2 * matrixQuadratic (projectionLaplacian (frameProjection U)) w) := by
      gcongr
    _ = _ := by ring

/-- Pairwise form of the static diagonal-scaling distance estimate. -/
theorem diagonal_scaling_projection_distance_le_pairs {n d : ℕ}
    (U : Frame n d) (w : Fin n → ℝ) (M : Matrix (Fin d) (Fin d) ℝ)
    (hU : IsParseval U) (hV : IsParseval (rowScale U w * M))
    (m : ℝ) (hm : 0 < m) (hw : ∀ i, m ≤ w i) :
    sqDistance (frameProjection U) (frameProjection (rowScale U w * M)) ≤
      (1 / m ^ 2) * ∑ i, ∑ j, (frameProjection U i j) ^ 2 * (w i - w j) ^ 2 := by
  have h := diagonal_scaling_projection_distance_le U w M hU hV m hm hw
  rw [hU.laplacian_energy] at h
  convert h using 1
  ring

end Paulsen
