import Paulsen.FullSparkQuadratic

/-!
# Quantitative polar normalization

Diagonalize the Gram matrix, normalize its orthogonal columns, and rotate
back. Scalar square-root estimates give a quadratic movement cost.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

theorem gram_quadratic_eq_frameEnergy {n d : ℕ} (X : Frame n d) (x : Fin d → ℝ) :
    star x ⬝ᵥ ((X.transpose * X) *ᵥ x) = frameEnergy X x := by
  rw [frameEnergy_eq_sum_gram]
  simp only [dotProduct, Matrix.mulVec, Matrix.mul_apply, Matrix.transpose_apply,
    Pi.star_apply, star_trivial, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  apply Finset.sum_congr rfl
  intro k _
  ring

/-- A uniformly positive lower Parseval bound makes the Gram matrix positive definite. -/
theorem IsNearlyParseval.gram_posDef {n d : ℕ} {X : Frame n d} {η : ℝ}
    (hX : IsNearlyParseval η X) (hη : η < 1) : (X.transpose * X).PosDef := by
  have hpsd : (X.transpose * X).PosSemidef := by
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
      Matrix.posSemidef_conjTranspose_mul_self X
  apply Matrix.PosDef.of_dotProduct_mulVec_pos hpsd.isHermitian
  intro x hx
  have hex : ∃ i, x i ≠ 0 := by
    by_contra h
    apply hx
    ext i
    exact not_not.mp (not_exists.mp h i)
  obtain ⟨i, hi⟩ := hex
  have hnorm : 0 < vectorNormSq x := by
    exact Finset.sum_pos' (fun j _ => sq_nonneg (x j))
      ⟨i, Finset.mem_univ i, sq_pos_of_ne_zero hi⟩
  rw [gram_quadratic_eq_frameEnergy]
  exact (mul_pos (sub_pos.mpr hη) hnorm).trans_le (hX x).1

/-- The square root is one-Lipschitz relative to the base point one on
the nonnegative half-line. -/
theorem sqrt_sub_one_sq_le {v η : ℝ} (hv : 0 ≤ v) (_hη : 0 ≤ η)
    (hlo : 1 - η ≤ v) (hhi : v ≤ 1 + η) :
    (Real.sqrt v - 1) ^ 2 ≤ η ^ 2 := by
  have hs := Real.sq_sqrt hv
  have hsn := Real.sqrt_nonneg v
  have hfactor : v - 1 = (Real.sqrt v - 1) * (Real.sqrt v + 1) := by nlinarith
  have habs : |v - 1| = |Real.sqrt v - 1| * (Real.sqrt v + 1) := by
    rw [hfactor, abs_mul, abs_of_pos (by positivity : 0 < Real.sqrt v + 1)]
  have hav : |v - 1| ≤ η := abs_le.mpr (by constructor <;> linarith)
  have has : |Real.sqrt v - 1| ≤ η := by
    nlinarith [mul_nonneg (abs_nonneg (Real.sqrt v - 1)) hsn]
  have h := pow_le_pow_left₀ (abs_nonneg (Real.sqrt v - 1)) has 2
  simpa only [sq_abs] using h

theorem reciprocal_near_one {v η : ℝ} (hv : 0 < v)
    (hη0 : 0 ≤ η) (hηhalf : η ≤ 1 / 2)
    (hlo : 1 - η ≤ v) (hhi : v ≤ 1 + η) :
    1 - 2 * η ≤ 1 / v ∧ 1 / v ≤ 1 + 2 * η := by
  constructor
  · apply (le_div_iff₀ hv).mpr
    have h := mul_le_mul_of_nonneg_left hhi (by linarith : 0 ≤ 1 - 2 * η)
    nlinarith [sq_nonneg η]
  · apply (div_le_iff₀ hv).mpr
    have h := mul_le_mul_of_nonneg_left hlo (by linarith : 0 ≤ 1 + 2 * η)
    have hηsq : 2 * η ^ 2 ≤ η := by nlinarith
    nlinarith

/-- Normalizing a frame with diagonal positive Gram matrix makes it Parseval. -/
theorem diagonal_gram_normalization_parseval {n d : ℕ}
    (Y : Frame n d) (v : Fin d → ℝ) (hv : ∀ j, 0 < v j)
    (hgram : Y.transpose * Y = Matrix.diagonal v) :
    IsParseval (Y * Matrix.diagonal (fun j => 1 / Real.sqrt (v j))) := by
  let D := Matrix.diagonal (fun j => 1 / Real.sqrt (v j))
  change (Y * D).transpose * (Y * D) = 1
  rw [Matrix.transpose_mul, Matrix.diagonal_transpose]
  calc
    D * Y.transpose * (Y * D) = D * (Y.transpose * Y) * D := by
      simp only [Matrix.mul_assoc]
    _ = D * Matrix.diagonal v * D := by rw [hgram]
    _ = 1 := by
      ext i j
      simp only [D, Matrix.diagonal_mul_diagonal, Matrix.diagonal_apply, Matrix.one_apply]
      split_ifs with hij
      · have hs : Real.sqrt (v i) ≠ 0 := ne_of_gt (Real.sqrt_pos.mpr (hv i))
        have hsq := Real.sq_sqrt (le_of_lt (hv i))
        field_simp
        nlinarith
      · rfl

/-- Exact movement formula in Gram eigenvector coordinates. -/
theorem diagonal_gram_normalization_distance {n d : ℕ}
    (Y : Frame n d) (v : Fin d → ℝ) (hv : ∀ j, 0 < v j)
    (hgram : Y.transpose * Y = Matrix.diagonal v) :
    sqDistance Y (Y * Matrix.diagonal (fun j => 1 / Real.sqrt (v j))) =
      ∑ j, (Real.sqrt (v j) - 1) ^ 2 := by
  have hcol : ∀ j, (∑ i, Y i j ^ 2) = v j := by
    intro j
    have hj := congrArg (fun M : Matrix (Fin d) (Fin d) ℝ => M j j) hgram
    simpa only [Matrix.mul_apply, Matrix.transpose_apply, Matrix.diagonal_apply_eq,
      pow_two] using hj
  unfold sqDistance
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j _
  simp only [Matrix.mul_diagonal]
  have hentry : ∀ i, (Y i j - Y i j * (1 / Real.sqrt (v j))) ^ 2 =
      Y i j ^ 2 * (1 - 1 / Real.sqrt (v j)) ^ 2 := by intro i; ring
  simp_rw [hentry]
  rw [← Finset.sum_mul, hcol]
  have hs : Real.sqrt (v j) ≠ 0 := ne_of_gt (Real.sqrt_pos.mpr (hv j))
  have hsq := Real.sq_sqrt (le_of_lt (hv j))
  calc
    v j * (1 - 1 / Real.sqrt (v j)) ^ 2 =
        (Real.sqrt (v j) * (1 - 1 / Real.sqrt (v j))) ^ 2 := by rw [mul_pow, hsq]
    _ = (Real.sqrt (v j) - 1) ^ 2 := by
      congr 1
      field_simp

/-- The normalized diagonal-Gram frame preserves every row energy up to
relative error twice the original spectral error. -/
theorem diagonal_gram_normalization_row_bounds {n d : ℕ}
    (Y : Frame n d) (v : Fin d → ℝ) (η : ℝ)
    (hv : ∀ j, 0 < v j) (hη0 : 0 ≤ η) (hηhalf : η ≤ 1 / 2)
    (hvlo : ∀ j, 1 - η ≤ v j) (hvhi : ∀ j, v j ≤ 1 + η) (i : Fin n) :
    (1 - 2 * η) * rowNormSq Y i ≤
        rowNormSq (Y * Matrix.diagonal (fun j => 1 / Real.sqrt (v j))) i ∧
      rowNormSq (Y * Matrix.diagonal (fun j => 1 / Real.sqrt (v j))) i ≤
        (1 + 2 * η) * rowNormSq Y i := by
  have heq : rowNormSq (Y * Matrix.diagonal (fun j => 1 / Real.sqrt (v j))) i =
      ∑ j, Y i j ^ 2 * (1 / v j) := by
    simp only [rowNormSq, Matrix.mul_diagonal, mul_pow, div_pow, one_pow,
      Real.sq_sqrt (le_of_lt (hv _))]
  rw [heq]
  simp only [rowNormSq, Finset.mul_sum]
  constructor
  · apply Finset.sum_le_sum
    intro j _
    have h := (reciprocal_near_one (hv j) hη0 hηhalf (hvlo j) (hvhi j)).1
    simpa only [mul_comm] using mul_le_mul_of_nonneg_right h (sq_nonneg (Y i j))
  · apply Finset.sum_le_sum
    intro j _
    have h := (reciprocal_near_one (hv j) hη0 hηhalf (hvlo j) (hvhi j)).2
    simpa only [mul_comm] using mul_le_mul_of_nonneg_right h (sq_nonneg (Y i j))

/-- Quantitative polar normalization with an actual Parseval output.
Its squared distance is at most η²d and its relative row-norm error at most 2η. -/
theorem exists_polar_normalization {n d : ℕ}
    (X : Frame n d) (η : ℝ) (hη0 : 0 ≤ η) (hηhalf : η ≤ 1 / 2)
    (hXnorm : IsEqualNorm X) (hX : IsNearlyParseval η X) :
    ∃ U : Frame n d, IsParseval U ∧ IsNearlyEqualNorm (2 * η) U ∧
      sqDistance X U ≤ η ^ 2 * (d : ℝ) := by
  obtain ⟨R, hRR, hRtR, v, _hmono, hv, hGR⟩ :=
    exists_ordered_posDef_diagonalization (X.transpose * X) (hX.gram_posDef (by linarith))
  let Y := X * R
  have hYgram : Y.transpose * Y = Matrix.diagonal v := by
    change (X * R).transpose * (X * R) = _
    rw [Matrix.transpose_mul]
    calc
      R.transpose * X.transpose * (X * R) = R.transpose * ((X.transpose * X) * R) := by
        simp only [Matrix.mul_assoc]
      _ = Matrix.diagonal v := by
        rw [hGR, ← Matrix.mul_assoc, hRtR, Matrix.one_mul]
  have hYcol : ∀ j, (∑ i, Y i j ^ 2) = v j := by
    intro j
    have hj := congrArg (fun M : Matrix (Fin d) (Fin d) ℝ => M j j) hYgram
    simpa only [Matrix.mul_apply, Matrix.transpose_apply, Matrix.diagonal_apply_eq,
      pow_two] using hj
  have hYnear : IsNearlyParseval η Y := hX.mul_orthogonal R hRtR
  have hvbounds : ∀ j, 1 - η ≤ v j ∧ v j ≤ 1 + η := by
    intro j
    simpa only [hYcol] using hYnear.columnNormSq_bounds j
  let W := Y * Matrix.diagonal (fun j => 1 / Real.sqrt (v j))
  have hW : IsParseval W := diagonal_gram_normalization_parseval Y v hv hYgram
  have hWnorm : IsNearlyEqualNorm (2 * η) W := by
    intro i
    have hi := diagonal_gram_normalization_row_bounds Y v η hv hη0 hηhalf
      (fun j => (hvbounds j).1) (fun j => (hvbounds j).2) i
    rwa [(hXnorm.mul_orthogonal R hRR) i] at hi
  have hcost : sqDistance Y W ≤ η ^ 2 * (d : ℝ) := by
    rw [diagonal_gram_normalization_distance Y v hv hYgram]
    calc
      _ ≤ ∑ _j : Fin d, η ^ 2 := Finset.sum_le_sum (fun j _ =>
        sqrt_sub_one_sq_le (le_of_lt (hv j)) hη0 (hvbounds j).1 (hvbounds j).2)
      _ = _ := by simp [nsmul_eq_mul, mul_comm]
  refine ⟨W * R.transpose, ?_, ?_, ?_⟩
  · exact hW.mul_orthogonal R.transpose (by simpa only [Matrix.transpose_transpose] using hRR)
  · intro i
    simpa only [rowNormSq_mul_orthogonal W R.transpose
      (by simpa only [Matrix.transpose_transpose] using hRtR)] using hWnorm i
  · have hrecover : Y * R.transpose = X := by
      dsimp only [Y]
      rw [Matrix.mul_assoc, hRR, Matrix.mul_one]
    have hdist := sqDistance_mul_orthogonal Y W R.transpose
      (by simpa only [Matrix.transpose_transpose] using hRtR)
    rw [hrecover] at hdist
    rwa [hdist]

end Paulsen
