import Paulsen.HorizontalRetraction
import Paulsen.ScalingExistence
import Paulsen.NormalBaseMean

/-!
# Second-order diagonal expansion of horizontal polar retraction

Diagonalizing the positive semidefinite matrix HᵀH reduces the resolvent
expansion to a scalar identity. The remainder retains the row energy scale.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

/-- An orthogonal coordinate change diagonalizes the noise Gram matrix, with
all eigenvalues bounded by the squared Euclidean operator norm. -/
theorem exists_gram_diagonalization_bounded {n d : ℕ} (H : Frame n d) (K : ℝ)
    (hK : ‖(Matrix.toEuclideanLin H).toContinuousLinearMap‖ ^ 2 ≤ K) :
    ∃ R : Matrix (Fin d) (Fin d) ℝ,
      R * R.transpose = 1 ∧ R.transpose * R = 1 ∧
      ∃ v : Fin d → ℝ, (∀ j, 0 ≤ v j ∧ v j ≤ K) ∧
        (H * R).transpose * (H * R) = Matrix.diagonal v := by
  classical
  have hS : (H.transpose * H).PosSemidef := by
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
      Matrix.posSemidef_conjTranspose_mul_self H
  let R : Matrix (Fin d) (Fin d) ℝ := hS.isHermitian.eigenvectorUnitary
  let v : Fin d → ℝ := hS.isHermitian.eigenvalues
  have hRR : R * R.transpose = 1 := by
    simpa only [R, Unitary.coe_star, Matrix.star_eq_conjTranspose,
      Matrix.conjTranspose_eq_transpose_of_trivial] using
      Unitary.coe_mul_star_self hS.isHermitian.eigenvectorUnitary
  have hRtR : R.transpose * R = 1 := by
    simpa only [R, Matrix.star_eq_conjTranspose,
      Matrix.conjTranspose_eq_transpose_of_trivial] using
      Unitary.coe_star_mul_self hS.isHermitian.eigenvectorUnitary
  have hSR : (H.transpose * H) * R = R * Matrix.diagonal v := by
    ext i j
    have h := congrFun (hS.isHermitian.mulVec_eigenvectorBasis j) i
    rw [Matrix.mul_diagonal]
    simpa only [Matrix.mul_apply, R, Matrix.IsHermitian.eigenvectorUnitary_apply,
      Matrix.mulVec, dotProduct, Pi.smul_apply, smul_eq_mul, v, mul_comm] using h
  have hgram : (H * R).transpose * (H * R) = Matrix.diagonal v := by
    rw [Matrix.transpose_mul]
    calc
      R.transpose * H.transpose * (H * R) = R.transpose * ((H.transpose * H) * R) := by
        simp only [Matrix.mul_assoc]
      _ = _ := by rw [hSR, ← Matrix.mul_assoc, hRtR, Matrix.one_mul]
  refine ⟨R, hRR, hRtR, v, fun j => ⟨hS.eigenvalues_nonneg j, ?_⟩, hgram⟩
  have hcol : frameEnergy H (fun i => R i j) = v j := by
    have h := congrArg (fun M : Matrix (Fin d) (Fin d) ℝ => M j j) hgram
    simpa only [frameEnergy, Matrix.mul_apply, Matrix.transpose_apply,
      Matrix.diagonal_apply_eq, pow_two] using h
  have hnorm : vectorNormSq (fun i => R i j) = 1 := by
    have h := congrArg (fun M : Matrix (Fin d) (Fin d) ℝ => M j j) hRtR
    simpa only [vectorNormSq, Matrix.mul_apply, Matrix.transpose_apply,
      Matrix.one_apply_eq, pow_two] using h
  have he := frameEnergy_le_operator_norm_sq H (fun i => R i j)
  rw [hcol, hnorm, mul_one] at he
  exact he.trans hK

/-- Scalar resolvent expansion with a uniform, sign-independent remainder. -/
theorem scalar_horizontal_taylor_bound (u h t v K : ℝ)
    (hv : 0 ≤ v) (hvK : v ≤ K) :
    |(u + t * h) ^ 2 / (1 + t ^ 2 * v) -
      (u ^ 2 + 2 * t * u * h + t ^ 2 * (h ^ 2 - v * u ^ 2))| ≤
      |t| ^ 3 * K * (u ^ 2 + h ^ 2) +
        t ^ 4 * (K ^ 2 * u ^ 2 + K * h ^ 2) := by
  have hK : 0 ≤ K := hv.trans hvK
  have hden : 1 ≤ 1 + t ^ 2 * v := by nlinarith [mul_nonneg (sq_nonneg t) hv]
  have hdenpos : 0 < 1 + t ^ 2 * v := lt_of_lt_of_le zero_lt_one hden
  have heq : (u + t * h) ^ 2 / (1 + t ^ 2 * v) -
      (u ^ 2 + 2 * t * u * h + t ^ 2 * (h ^ 2 - v * u ^ 2)) =
      (-2 * t ^ 3 * v * u * h + t ^ 4 * (v ^ 2 * u ^ 2 - v * h ^ 2)) /
        (1 + t ^ 2 * v) := by
    field_simp
    ring
  rw [heq, abs_div, abs_of_pos hdenpos]
  apply (div_le_self (abs_nonneg _) hden).trans
  have huv : 2 * |u * h| ≤ u ^ 2 + h ^ 2 := by
    rw [abs_mul]
    nlinarith [sq_nonneg (|u| - |h|), sq_abs u, sq_abs h]
  have hcross : |-2 * t ^ 3 * v * u * h| ≤ |t| ^ 3 * K * (u ^ 2 + h ^ 2) := by
    have hscale := mul_le_mul_of_nonneg_left huv (mul_nonneg (pow_nonneg (abs_nonneg t) 3) hv)
    have hscaleK := mul_le_mul_of_nonneg_left hvK
      (mul_nonneg (pow_nonneg (abs_nonneg t) 3) (add_nonneg (sq_nonneg u) (sq_nonneg h)))
    simp only [abs_mul, abs_neg, abs_pow, abs_of_nonneg hv] at *
    norm_num only [abs_of_pos (by norm_num : (0 : ℝ) < 2)] at *
    nlinarith
  have hquartic : |t ^ 4 * (v ^ 2 * u ^ 2 - v * h ^ 2)| ≤
      t ^ 4 * (K ^ 2 * u ^ 2 + K * h ^ 2) := by
    rw [abs_mul, abs_of_nonneg (by positivity : 0 ≤ t ^ 4)]
    apply mul_le_mul_of_nonneg_left _ (by positivity)
    apply (abs_sub _ _).trans
    rw [abs_of_nonneg (by positivity : 0 ≤ v ^ 2 * u ^ 2),
      abs_of_nonneg (mul_nonneg hv (sq_nonneg h))]
    exact add_le_add (mul_le_mul_of_nonneg_right
      (pow_le_pow_left₀ hv hvK 2) (sq_nonneg u))
      (mul_le_mul_of_nonneg_right hvK (sq_nonneg h))
  exact (abs_add_le _ _).trans (add_le_add hcross hquartic)

/-- A diagonal noise Gram matrix makes the quadratic correction entrywise. -/
theorem rowNormSq_mul_transpose_of_diagonal_gram {n d : ℕ}
    (U H : Frame n d) (v : Fin d → ℝ)
    (hgram : H.transpose * H = Matrix.diagonal v) (i : Fin n) :
    rowNormSq (U * H.transpose) i = ∑ j, v j * (U i j) ^ 2 := by
  rw [← frameProjection_diagonal]
  have hprod : frameProjection (U * H.transpose) = U * Matrix.diagonal v * U.transpose := by
    simp only [frameProjection, Matrix.transpose_mul, Matrix.transpose_transpose]
    calc
      _ = U * (H.transpose * H) * U.transpose := by simp only [Matrix.mul_assoc]
      _ = _ := by rw [hgram]
  rw [hprod]
  change (∑ j, (U * Matrix.diagonal v) i j * U i j) = _
  simp only [Matrix.mul_diagonal]
  apply Finset.sum_congr rfl
  intro j _
  ring

/-- The diagonal expansion in eigenvector coordinates. -/
theorem diagonal_horizontal_polar_taylor_bound {n d : ℕ}
    (U H : Frame n d) (v : Fin d → ℝ) (t K : ℝ)
    (hv : ∀ j, 0 ≤ v j ∧ v j ≤ K)
    (hgram : H.transpose * H = Matrix.diagonal v) (i : Fin n) :
    |rowNormSq ((U + t • H) * Matrix.diagonal
        (fun j => 1 / Real.sqrt (1 + t ^ 2 * v j))) i -
      (rowNormSq U i + 2 * t * (H * U.transpose) i i +
        t ^ 2 * horizontalQuadraticDiagonal U H i)| ≤
      |t| ^ 3 * K * (rowNormSq U i + rowNormSq H i) +
        t ^ 4 * (K ^ 2 * rowNormSq U i + K * rowNormSq H i) := by
  have hpos (j : Fin d) : 0 < 1 + t ^ 2 * v j := by
    nlinarith [mul_nonneg (sq_nonneg t) (hv j).1]
  have hnorm : rowNormSq ((U + t • H) * Matrix.diagonal
      (fun j => 1 / Real.sqrt (1 + t ^ 2 * v j))) i =
      ∑ j, (U i j + t * H i j) ^ 2 / (1 + t ^ 2 * v j) := by
    simp only [rowNormSq, Matrix.mul_diagonal, Matrix.add_apply, Matrix.smul_apply,
      smul_eq_mul, div_pow, Real.sq_sqrt (hpos _).le, mul_one_div]
  rw [hnorm, horizontalQuadraticDiagonal,
    rowNormSq_mul_transpose_of_diagonal_gram U H v hgram]
  have heq : (∑ j, (U i j + t * H i j) ^ 2 / (1 + t ^ 2 * v j)) -
      (rowNormSq U i + 2 * t * (H * U.transpose) i i +
        t ^ 2 * (rowNormSq H i - ∑ j, v j * U i j ^ 2)) =
      ∑ j, ((U i j + t * H i j) ^ 2 / (1 + t ^ 2 * v j) -
        (U i j ^ 2 + 2 * t * U i j * H i j +
          t ^ 2 * (H i j ^ 2 - v j * U i j ^ 2))) := by
    simp only [rowNormSq, Matrix.mul_apply, Matrix.transpose_apply, Finset.sum_sub_distrib,
      Finset.sum_add_distrib, mul_sub, Finset.mul_sum]
    congr 3
    apply Finset.sum_congr rfl
    intro j _
    ring
  rw [heq]
  calc
    _ ≤ ∑ j, |(U i j + t * H i j) ^ 2 / (1 + t ^ 2 * v j) -
        (U i j ^ 2 + 2 * t * U i j * H i j +
          t ^ 2 * (H i j ^ 2 - v j * U i j ^ 2))| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ j, (|t| ^ 3 * K * (U i j ^ 2 + H i j ^ 2) +
        t ^ 4 * (K ^ 2 * U i j ^ 2 + K * H i j ^ 2)) :=
      Finset.sum_le_sum fun j _ => scalar_horizontal_taylor_bound _ _ t (v j) K (hv j).1 (hv j).2
    _ = _ := by simp only [rowNormSq, Finset.sum_add_distrib, Finset.mul_sum, mul_add]

/-- The diagonal Taylor estimate depends only on the column space of the
Parseval retraction, so it applies to any right whitening of U+tH. -/
theorem horizontal_polar_taylor_bound_of_right_factor {n d : ℕ}
    (U H W : Frame n d) (M : Matrix (Fin d) (Fin d) ℝ) (t K : ℝ)
    (hU : IsParseval U) (hUH : U.transpose * H = 0)
    (hK : ‖(Matrix.toEuclideanLin H).toContinuousLinearMap‖ ^ 2 ≤ K)
    (hW : IsParseval W) (hfactor : W = (U + t • H) * M) (i : Fin n) :
    |rowNormSq W i - (rowNormSq U i + 2 * t * (H * U.transpose) i i +
        t ^ 2 * horizontalQuadraticDiagonal U H i)| ≤
      |t| ^ 3 * K * (rowNormSq U i + rowNormSq H i) +
        t ^ 4 * (K ^ 2 * rowNormSq U i + K * rowNormSq H i) := by
  obtain ⟨R, hRR, hRtR, v, hv, hgram⟩ := exists_gram_diagonalization_bounded H K hK
  let Y := U * R
  let J := H * R
  let D := Matrix.diagonal (fun j => 1 / Real.sqrt (1 + t ^ 2 * v j))
  let N := (Y + t • J) * D
  have hY : IsParseval Y := hU.mul_orthogonal R hRtR
  have hYJ : Y.transpose * J = 0 := by
    change (U * R).transpose * (H * R) = 0
    rw [Matrix.transpose_mul]
    calc
      _ = R.transpose * (U.transpose * H) * R := by simp only [Matrix.mul_assoc]
      _ = 0 := by simp only [hUH, Matrix.mul_zero, Matrix.zero_mul]
  have hden (j : Fin d) : 0 < 1 + t ^ 2 * v j := by
    nlinarith [mul_nonneg (sq_nonneg t) (hv j).1]
  have hNg : (Y + t • J).transpose * (Y + t • J) =
      Matrix.diagonal (fun j => 1 + t ^ 2 * v j) := by
    rw [gram_horizontal_perturbation Y J t hY hYJ, hgram]
    ext j k
    by_cases hjk : j = k <;> simp [hjk]
  have hN : IsParseval N :=
    diagonal_gram_normalization_parseval (Y + t • J) _ hden hNg
  have hNfactor : N = (U + t • H) * (R * D) := by
    dsimp only [N, Y, J]
    simp only [Matrix.add_mul, Matrix.smul_mul, Matrix.mul_assoc]
  have hPN : frameProjection W = frameProjection N := by
    rw [hfactor, ← columnSpaceProjection_eq_of_parseval_right_mul (U + t • H) M
      (by rwa [← hfactor])]
    rw [hNfactor, ← columnSpaceProjection_eq_of_parseval_right_mul (U + t • H) (R * D)
      (by rwa [← hNfactor])]
  have hrow : rowNormSq W i = rowNormSq N i := by
    rw [← frameProjection_diagonal, hPN, frameProjection_diagonal]
  have hJY : J * Y.transpose = H * U.transpose := by
    dsimp only [J, Y]
    rw [Matrix.transpose_mul]
    calc
      _ = H * (R * R.transpose) * U.transpose := by simp only [Matrix.mul_assoc]
      _ = _ := by rw [hRR, Matrix.mul_one]
  have hYJt : Y * J.transpose = U * H.transpose := by
    dsimp only [J, Y]
    rw [Matrix.transpose_mul]
    calc
      _ = U * (R * R.transpose) * H.transpose := by simp only [Matrix.mul_assoc]
      _ = _ := by rw [hRR, Matrix.mul_one]
  have hYrow : rowNormSq Y i = rowNormSq U i := rowNormSq_mul_orthogonal U R hRR i
  have hJrow : rowNormSq J i = rowNormSq H i := rowNormSq_mul_orthogonal H R hRR i
  have hq : horizontalQuadraticDiagonal Y J i = horizontalQuadraticDiagonal U H i := by
    simp only [horizontalQuadraticDiagonal, hJrow, hYJt]
  have hb := diagonal_horizontal_polar_taylor_bound Y J v t K hv hgram i
  change |rowNormSq N i - (rowNormSq Y i + 2 * t * (J * Y.transpose) i i +
      t ^ 2 * horizontalQuadraticDiagonal Y J i)| ≤ _ at hb
  rwa [hYrow, hJrow, hJY, hq, ← hrow] at hb

/-- One polar retraction simultaneously satisfies the movement, rowwise Gram,
and second-order diagonal estimates. The projection is the exact resolvent. -/
theorem exists_horizontal_polar_retraction_second_order {n d : ℕ}
    (U H : Frame n d) (t K : ℝ) (hU : IsParseval U)
    (hUH : U.transpose * H = 0)
    (hK : ‖(Matrix.toEuclideanLin H).toContinuousLinearMap‖ ^ 2 ≤ K)
    (hsmall : t ^ 2 * K ≤ 1 / 2) :
    ∃ W : Frame n d, IsParseval W ∧
      sqDistance U W ≤ 2 * t ^ 2 * (∑ i, rowNormSq H i) + 2 * t ^ 4 * K ^ 2 * (d : ℝ) ∧
      (∀ i, rowNormSq (frameProjection W - frameProjection U -
        t • (H * U.transpose + U * H.transpose)) i ≤
          24 * t ^ 4 * K ^ 2 * (rowNormSq U i + t ^ 2 * rowNormSq H i) +
            2 * t ^ 4 * K * rowNormSq H i) ∧
      (∀ i, |rowNormSq W i - (rowNormSq U i + 2 * t * (H * U.transpose) i i +
          t ^ 2 * horizontalQuadraticDiagonal U H i)| ≤
        |t| ^ 3 * K * (rowNormSq U i + rowNormSq H i) +
          t ^ 4 * (K ^ 2 * rowNormSq U i + K * rowNormSq H i)) ∧
      frameProjection W = (U + t • H) * (1 + t ^ 2 • (H.transpose * H))⁻¹ *
        (U + t • H).transpose ∧
      (IsFullSpark (U + t • H) → IsFullSpark W) := by
  obtain ⟨W, hW, hcost, hgram, hspark, M, hfactor⟩ :=
    exists_horizontal_polar_retraction_with_multiplier U H t K hU hUH hK hsmall
  refine ⟨W, hW, hcost, hgram,
    horizontal_polar_taylor_bound_of_right_factor U H W M t K hU hUH hK hW hfactor,
    ?_, hspark⟩
  have hproj := columnSpaceProjection_eq_of_parseval_right_mul (U + t • H) M
    (by rwa [← hfactor])
  rw [← hfactor, columnSpaceProjection,
    gram_horizontal_perturbation U H t hU hUH] at hproj
  exact hproj.symm

/-- Uniform row energies produce the leverage-scale cubic Taylor remainder.
The remainder is an actual vector, with an exact diagonal expansion. -/
theorem exists_horizontal_polar_retraction_taylor_uniform {n d : ℕ}
    (U H : Frame n d) (t K A : ℝ) (hU : IsParseval U)
    (hUH : U.transpose * H = 0)
    (hK : ‖(Matrix.toEuclideanLin H).toContinuousLinearMap‖ ^ 2 ≤ K)
    (hsmall : t ^ 2 * K ≤ 1 / 2) (ht : t ^ 2 ≤ 1)
    (hUrow : ∀ i, rowNormSq U i ≤ A) (hHrow : ∀ i, rowNormSq H i ≤ A) :
    ∃ (W : Frame n d) (r : Fin n → ℝ), IsParseval W ∧
      sqDistance U W ≤ 2 * t ^ 2 * (∑ i, rowNormSq H i) + 2 * t ^ 4 * K ^ 2 * (d : ℝ) ∧
      (∀ i, rowNormSq (frameProjection W - frameProjection U -
        t • (H * U.transpose + U * H.transpose)) i ≤ (48 * K ^ 2 + 2 * K) * A * t ^ 4) ∧
      (∀ i, rowNormSq W i = rowNormSq U i + 2 * t * (H * U.transpose) i i +
        t ^ 2 * horizontalQuadraticDiagonal U H i + r i) ∧
      (∀ i, |r i| ≤ A * (2 * K * |t| ^ 3 + (K ^ 2 + K) * t ^ 4)) ∧
      frameProjection W = (U + t • H) * (1 + t ^ 2 • (H.transpose * H))⁻¹ *
        (U + t • H).transpose ∧
      (IsFullSpark (U + t • H) → IsFullSpark W) := by
  obtain ⟨W, hW, hcost, hgram, htaylor, hproj, hspark⟩ :=
    exists_horizontal_polar_retraction_second_order U H t K hU hUH hK hsmall
  let r : Fin n → ℝ := fun i => rowNormSq W i - (rowNormSq U i +
    2 * t * (H * U.transpose) i i + t ^ 2 * horizontalQuadraticDiagonal U H i)
  have hK0 : 0 ≤ K := (sq_nonneg _).trans hK
  refine ⟨W, r, hW, hcost, ?_, ?_, ?_, hproj, hspark⟩
  · intro i
    have hA : 0 ≤ A := (rowNormSq_nonneg U i).trans (hUrow i)
    have hcombined : rowNormSq U i + t ^ 2 * rowNormSq H i ≤ 2 * A := by
      have h1 := mul_le_mul_of_nonneg_left (hHrow i) (sq_nonneg t)
      have h2 := mul_le_mul_of_nonneg_right ht hA
      linarith [hUrow i]
    apply (hgram i).trans
    have h1 := mul_le_mul_of_nonneg_left hcombined (show 0 ≤ 24 * t ^ 4 * K ^ 2 by positivity)
    have h2 := mul_le_mul_of_nonneg_left (hHrow i) (show 0 ≤ 2 * t ^ 4 * K by positivity)
    nlinarith
  · intro i
    dsimp only [r]
    ring
  · intro i
    apply (htaylor i).trans
    have h1 := mul_le_mul_of_nonneg_left (add_le_add (hUrow i) (hHrow i))
      (show 0 ≤ |t| ^ 3 * K by positivity)
    have h2 := mul_le_mul_of_nonneg_left (hUrow i) (show 0 ≤ t ^ 4 * K ^ 2 by positivity)
    have h3 := mul_le_mul_of_nonneg_left (hHrow i) (show 0 ≤ t ^ 4 * K by positivity)
    nlinarith

end Paulsen
