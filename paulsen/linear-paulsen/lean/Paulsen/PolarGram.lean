import Paulsen.PolarNormalization
import Paulsen.GramStability

/-!
# Per-row Gram control under polar normalization

In Gram eigenvector coordinates, the projection error is
Y diag(1/v - 1) Yᵀ. Bounding its rows avoids any factor depending on the
number of frame vectors.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

theorem IsFullSpark.mul_of_det_ne_zero {n d : ℕ} {V : Frame n d}
    (hV : IsFullSpark V) (M : Matrix (Fin d) (Fin d) ℝ) (hM : M.det ≠ 0) :
    IsFullSpark (V * M) := by
  intro f
  have heq : (V * M).submatrix f id = V.submatrix f id * M := by
    ext i j
    simp [Matrix.mul_apply, Matrix.submatrix_apply]
  rw [heq, Matrix.det_mul]
  exact mul_ne_zero (hV f) hM

theorem IsNearlyParseval.euclidean_operator_norm_sq_le {n d : ℕ}
    {V : Frame n d} {δ : ℝ} (hV : IsNearlyParseval δ V) (hδ : 0 ≤ δ) :
    ‖(Matrix.toEuclideanLin V).toContinuousLinearMap‖ ^ 2 ≤ 1 + δ := by
  have hs : (Real.sqrt (1 + δ)) ^ 2 = 1 + δ := Real.sq_sqrt (by linarith)
  have hop : ‖(Matrix.toEuclideanLin V).toContinuousLinearMap‖ ≤ Real.sqrt (1 + δ) := by
    apply ContinuousLinearMap.opNorm_le_bound _ (Real.sqrt_nonneg _)
    intro x
    have h := (hV x.ofLp).2
    have hsq : ‖Matrix.toEuclideanLin V x‖ ^ 2 ≤ (1 + δ) * ‖x‖ ^ 2 := by
      simpa only [EuclideanSpace.real_norm_sq_eq, Matrix.toLpLin_apply,
        frameEnergy, vectorNormSq, Matrix.mulVec, dotProduct] using h
    change ‖Matrix.toEuclideanLin V x‖ ≤ Real.sqrt (1 + δ) * ‖x‖
    have hnonneg := mul_nonneg (Real.sqrt_nonneg (1 + δ)) (norm_nonneg x)
    have hprod : (Real.sqrt (1 + δ) * ‖x‖) ^ 2 = (1 + δ) * ‖x‖ ^ 2 := by
      rw [mul_pow, hs]
    nlinarith [norm_nonneg (Matrix.toEuclideanLin V x)]
  exact (pow_le_pow_left₀ (norm_nonneg _) hop 2).trans_eq hs

theorem diagonal_gram_normalization_projection_error {n d : ℕ}
    (Y : Frame n d) (v : Fin d → ℝ) (hv : ∀ j, 0 < v j) :
    frameProjection (Y * Matrix.diagonal (fun j => 1 / Real.sqrt (v j))) -
      frameProjection Y = Y * Matrix.diagonal (fun j => 1 / v j - 1) * Y.transpose := by
  let D := Matrix.diagonal (fun j => 1 / Real.sqrt (v j))
  have hDD : D * D = Matrix.diagonal (fun j => 1 / v j) := by
    rw [Matrix.diagonal_mul_diagonal]
    congr 1
    ext j
    rw [← pow_two, div_pow, one_pow, Real.sq_sqrt (hv j).le]
  change (Y * D) * (Y * D).transpose - Y * Y.transpose = _
  rw [Matrix.transpose_mul, Matrix.diagonal_transpose]
  calc
    Y * D * (D * Y.transpose) - Y * Y.transpose =
        Y * (D * D) * Y.transpose - Y * (1 : Matrix (Fin d) (Fin d) ℝ) * Y.transpose := by
      simp only [Matrix.mul_assoc, Matrix.mul_one]
    _ = Y * (D * D - 1) * Y.transpose := by
      rw [Matrix.mul_sub, Matrix.sub_mul]
    _ = _ := by
      rw [hDD]
      congr 2
      ext j k
      by_cases hjk : j = k <;> simp [hjk]

theorem diagonal_gram_normalization_projection_row_bound {n d : ℕ}
    (Y : Frame n d) (v : Fin d → ℝ) (δ : ℝ)
    (hv : ∀ j, 0 < v j) (hδ0 : 0 ≤ δ) (hδhalf : δ ≤ 1 / 2)
    (hvlo : ∀ j, 1 - δ ≤ v j) (hvhi : ∀ j, v j ≤ 1 + δ)
    (hY : IsNearlyParseval δ Y) (i : Fin n) :
    rowNormSq (frameProjection (Y * Matrix.diagonal (fun j => 1 / Real.sqrt (v j))) -
      frameProjection Y) i ≤ 6 * rowNormSq Y i * δ ^ 2 := by
  let D := Matrix.diagonal (fun j => 1 / v j - 1)
  have hd (j : Fin d) : (1 / v j - 1) ^ 2 ≤ 4 * δ ^ 2 := by
    obtain ⟨hlo, hhi⟩ := reciprocal_near_one (hv j) hδ0 hδhalf (hvlo j) (hvhi j)
    have habs : |1 / v j - 1| ≤ 2 * δ := abs_le.mpr (by constructor <;> linarith)
    have hsq := pow_le_pow_left₀ (abs_nonneg _) habs 2
    norm_num only [sq_abs, mul_pow, show (2 : ℝ) ^ 2 = 4 by norm_num] at hsq
    exact hsq
  have hrow : rowNormSq (Y * D) i ≤ 4 * δ ^ 2 * rowNormSq Y i := by
    simp only [D, rowNormSq, Matrix.mul_diagonal, mul_pow, Finset.mul_sum]
    apply Finset.sum_le_sum
    intro j _
    simpa only [mul_comm] using mul_le_mul_of_nonneg_left (hd j) (sq_nonneg (Y i j))
  rw [diagonal_gram_normalization_projection_error Y v hv]
  have h := rowNormSq_mul_le (Y * D) Y.transpose i
  rw [euclidean_operator_norm_transpose] at h
  calc
    _ ≤ ‖(Matrix.toEuclideanLin Y).toContinuousLinearMap‖ ^ 2 * rowNormSq (Y * D) i := h
    _ ≤ (1 + δ) * (4 * δ ^ 2 * rowNormSq Y i) := by
      exact mul_le_mul (hY.euclidean_operator_norm_sq_le hδ0) hrow
        (rowNormSq_nonneg _ _) (by linarith)
    _ ≤ _ := by
      have hr := rowNormSq_nonneg Y i
      nlinarith [mul_nonneg (sq_nonneg δ) hr,
        mul_nonneg (by linarith : 0 ≤ 1 / 2 - δ) (mul_nonneg (sq_nonneg δ) hr)]

/-- Polar normalization simultaneously controls the movement, row lengths,
and each row of the Gram projection error. -/
theorem exists_polar_normalization_row_gram_and_fullSpark {n d : ℕ}
    (V : Frame n d) (δ : ℝ) (hδ0 : 0 ≤ δ) (hδhalf : δ ≤ 1 / 2)
    (hVnorm : IsEqualNorm V) (hV : IsNearlyParseval δ V) :
    ∃ U : Frame n d, IsParseval U ∧ IsNearlyEqualNorm (2 * δ) U ∧
      sqDistance V U ≤ δ ^ 2 * (d : ℝ) ∧
      (∀ i, rowNormSq (frameProjection U - frameProjection V) i ≤
        6 * ((d : ℝ) / n) * δ ^ 2) ∧
      (IsFullSpark V → IsFullSpark U) := by
  obtain ⟨R, hRR, hRtR, v, _hmono, hv, hGR⟩ :=
    exists_ordered_posDef_diagonalization (V.transpose * V) (hV.gram_posDef (by linarith))
  let Y := V * R
  have hYgram : Y.transpose * Y = Matrix.diagonal v := by
    change (V * R).transpose * (V * R) = _
    rw [Matrix.transpose_mul]
    calc
      R.transpose * V.transpose * (V * R) = R.transpose * ((V.transpose * V) * R) := by
        simp only [Matrix.mul_assoc]
      _ = Matrix.diagonal v := by
        rw [hGR, ← Matrix.mul_assoc, hRtR, Matrix.one_mul]
  have hYcol : ∀ j, (∑ i, Y i j ^ 2) = v j := by
    intro j
    have hj := congrArg (fun M : Matrix (Fin d) (Fin d) ℝ => M j j) hYgram
    simpa only [Matrix.mul_apply, Matrix.transpose_apply, Matrix.diagonal_apply_eq,
      pow_two] using hj
  have hYnear : IsNearlyParseval δ Y := hV.mul_orthogonal R hRtR
  have hvbounds : ∀ j, 1 - δ ≤ v j ∧ v j ≤ 1 + δ := by
    intro j
    simpa only [hYcol] using hYnear.columnNormSq_bounds j
  let W := Y * Matrix.diagonal (fun j => 1 / Real.sqrt (v j))
  have hW : IsParseval W := diagonal_gram_normalization_parseval Y v hv hYgram
  have hWnorm : IsNearlyEqualNorm (2 * δ) W := by
    intro i
    have hi := diagonal_gram_normalization_row_bounds Y v δ hv hδ0 hδhalf
      (fun j => (hvbounds j).1) (fun j => (hvbounds j).2) i
    rwa [(hVnorm.mul_orthogonal R hRR) i] at hi
  have hcost : sqDistance Y W ≤ δ ^ 2 * (d : ℝ) := by
    rw [diagonal_gram_normalization_distance Y v hv hYgram]
    calc
      _ ≤ ∑ _j : Fin d, δ ^ 2 := Finset.sum_le_sum (fun j _ =>
        sqrt_sub_one_sq_le (le_of_lt (hv j)) hδ0 (hvbounds j).1 (hvbounds j).2)
      _ = _ := by simp [nsmul_eq_mul, mul_comm]
  have hrow (i : Fin n) : rowNormSq (frameProjection W - frameProjection Y) i ≤
      6 * ((d : ℝ) / n) * δ ^ 2 := by
    have hi := diagonal_gram_normalization_projection_row_bound Y v δ hv hδ0 hδhalf
      (fun j => (hvbounds j).1) (fun j => (hvbounds j).2) hYnear i
    rwa [(hVnorm.mul_orthogonal R hRR) i] at hi
  refine ⟨W * R.transpose, ?_, ?_, ?_, ?_, ?_⟩
  · exact hW.mul_orthogonal R.transpose (by simpa only [Matrix.transpose_transpose] using hRR)
  · intro i
    simpa only [rowNormSq_mul_orthogonal W R.transpose
      (by simpa only [Matrix.transpose_transpose] using hRtR)] using hWnorm i
  · have hrecover : Y * R.transpose = V := by
      dsimp only [Y]
      rw [Matrix.mul_assoc, hRR, Matrix.mul_one]
    have hdist := sqDistance_mul_orthogonal Y W R.transpose
      (by simpa only [Matrix.transpose_transpose] using hRtR)
    rw [hrecover] at hdist
    rwa [hdist]
  · intro i
    rw [frameProjection_mul_orthogonal W R.transpose
      (by simpa only [Matrix.transpose_transpose] using hRtR),
      ← frameProjection_mul_orthogonal V R hRR]
    exact hrow i
  · intro hVfull
    have hRdet : R.det ≠ 0 := by
      have h := congrArg Matrix.det hRR
      rw [Matrix.det_mul, Matrix.det_transpose, Matrix.det_one] at h
      intro hz
      simp [hz] at h
    apply IsFullSpark.mul_of_det_ne_zero _ R.transpose (by simpa using hRdet)
    apply IsFullSpark.mul_of_det_ne_zero (hVfull.mul_of_det_ne_zero R hRdet)
    rw [Matrix.det_diagonal]
    exact Finset.prod_ne_zero_iff.mpr fun j _ => one_div_ne_zero
      (Real.sqrt_ne_zero'.mpr (hv j))

theorem exists_polar_normalization_row_gram {n d : ℕ}
    (V : Frame n d) (δ : ℝ) (hδ0 : 0 ≤ δ) (hδhalf : δ ≤ 1 / 2)
    (hVnorm : IsEqualNorm V) (hV : IsNearlyParseval δ V) :
    ∃ U : Frame n d, IsParseval U ∧ IsNearlyEqualNorm (2 * δ) U ∧
      sqDistance V U ≤ δ ^ 2 * (d : ℝ) ∧
      ∀ i, rowNormSq (frameProjection U - frameProjection V) i ≤
        6 * ((d : ℝ) / n) * δ ^ 2 := by
  obtain ⟨U, hU, hUnorm, hcost, hgram, _⟩ :=
    exists_polar_normalization_row_gram_and_fullSpark V δ hδ0 hδhalf hVnorm hV
  exact ⟨U, hU, hUnorm, hcost, hgram⟩

end Paulsen
