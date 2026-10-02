import Paulsen.PolarGram
import Paulsen.TangentRemainderBound

/-!
# Quantitative polar retraction of horizontal perturbations

The rowwise remainder retains the leverage scale. It is sufficient for
transferring graph expansion to the retracted Parseval frame.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

theorem exists_polar_normalization_rowwise_with_multiplier {n d : ℕ}
    (X : Frame n d) (δ : ℝ) (hδ0 : 0 ≤ δ) (hδhalf : δ ≤ 1 / 2)
    (hX : IsNearlyParseval δ X) :
    ∃ W : Frame n d, IsParseval W ∧ sqDistance X W ≤ δ ^ 2 * (d : ℝ) ∧
      (∀ i, rowNormSq (frameProjection W - frameProjection X) i ≤
        6 * rowNormSq X i * δ ^ 2) ∧ (IsFullSpark X → IsFullSpark W) ∧
      ∃ M : Matrix (Fin d) (Fin d) ℝ, W = X * M := by
  obtain ⟨R, hRR, hRtR, v, _hmono, hv, hGR⟩ :=
    exists_ordered_posDef_diagonalization (X.transpose * X) (hX.gram_posDef (by linarith))
  let Y := X * R
  have hYgram : Y.transpose * Y = Matrix.diagonal v := by
    change (X * R).transpose * (X * R) = _
    rw [Matrix.transpose_mul]
    calc
      R.transpose * X.transpose * (X * R) = R.transpose * ((X.transpose * X) * R) := by
        simp only [Matrix.mul_assoc]
      _ = Matrix.diagonal v := by rw [hGR, ← Matrix.mul_assoc, hRtR, Matrix.one_mul]
  have hYcol : ∀ j, (∑ i, Y i j ^ 2) = v j := by
    intro j
    have hj := congrArg (fun M : Matrix (Fin d) (Fin d) ℝ => M j j) hYgram
    simpa only [Matrix.mul_apply, Matrix.transpose_apply, Matrix.diagonal_apply_eq,
      pow_two] using hj
  have hYnear : IsNearlyParseval δ Y := hX.mul_orthogonal R hRtR
  have hvbounds : ∀ j, 1 - δ ≤ v j ∧ v j ≤ 1 + δ := by
    intro j
    simpa only [hYcol] using hYnear.columnNormSq_bounds j
  let V := Y * Matrix.diagonal (fun j => 1 / Real.sqrt (v j))
  have hV : IsParseval V := diagonal_gram_normalization_parseval Y v hv hYgram
  have hcost : sqDistance Y V ≤ δ ^ 2 * (d : ℝ) := by
    rw [diagonal_gram_normalization_distance Y v hv hYgram]
    calc
      _ ≤ ∑ _j : Fin d, δ ^ 2 := Finset.sum_le_sum (fun j _ =>
        sqrt_sub_one_sq_le (le_of_lt (hv j)) hδ0 (hvbounds j).1 (hvbounds j).2)
      _ = _ := by simp [nsmul_eq_mul, mul_comm]
  refine ⟨V * R.transpose, hV.mul_orthogonal R.transpose
    (by simpa only [Matrix.transpose_transpose] using hRR), ?_, ?_, ?_, ?_⟩
  · have hrecover : Y * R.transpose = X := by
      dsimp only [Y]
      rw [Matrix.mul_assoc, hRR, Matrix.mul_one]
    have hdist := sqDistance_mul_orthogonal Y V R.transpose
      (by simpa only [Matrix.transpose_transpose] using hRtR)
    rw [hrecover] at hdist
    rwa [hdist]
  · intro i
    have hi := diagonal_gram_normalization_projection_row_bound Y v δ hv hδ0 hδhalf
      (fun j => (hvbounds j).1) (fun j => (hvbounds j).2) hYnear i
    rw [frameProjection_mul_orthogonal V R.transpose
      (by simpa only [Matrix.transpose_transpose] using hRtR),
      ← frameProjection_mul_orthogonal X R hRR]
    simpa only [Y, rowNormSq_mul_orthogonal X R hRR] using hi
  · intro hXs
    have hRdet : R.det ≠ 0 := Matrix.det_ne_zero_of_right_inverse hRR
    apply IsFullSpark.mul_of_det_ne_zero _ R.transpose (by simpa using hRdet)
    apply IsFullSpark.mul_of_det_ne_zero (hXs.mul_of_det_ne_zero R hRdet)
    rw [Matrix.det_diagonal]
    exact Finset.prod_ne_zero_iff.mpr fun j _ => one_div_ne_zero
      (Real.sqrt_ne_zero'.mpr (hv j))


  · refine ⟨R * Matrix.diagonal (fun j => 1 / Real.sqrt (v j)) * R.transpose, ?_⟩
    simp only [V, Y, Matrix.mul_assoc]

theorem exists_polar_normalization_rowwise {n d : ℕ}
    (X : Frame n d) (δ : ℝ) (hδ0 : 0 ≤ δ) (hδhalf : δ ≤ 1 / 2)
    (hX : IsNearlyParseval δ X) :
    ∃ W : Frame n d, IsParseval W ∧ sqDistance X W ≤ δ ^ 2 * (d : ℝ) ∧
      (∀ i, rowNormSq (frameProjection W - frameProjection X) i ≤
        6 * rowNormSq X i * δ ^ 2) ∧ (IsFullSpark X → IsFullSpark W) := by
  obtain ⟨W, hW, hcost, hrows, hspark, _⟩ :=
    exists_polar_normalization_rowwise_with_multiplier X δ hδ0 hδhalf hX
  exact ⟨W, hW, hcost, hrows, hspark⟩

theorem frameEnergy_le_operator_norm_sq {n d : ℕ} (H : Frame n d) (x : Fin d → ℝ) :
    frameEnergy H x ≤ ‖(Matrix.toEuclideanLin H).toContinuousLinearMap‖ ^ 2 * vectorNormSq x := by
  have h := (Matrix.toEuclideanLin H).toContinuousLinearMap.le_opNorm (WithLp.toLp 2 x)
  have hs := pow_le_pow_left₀ (norm_nonneg _) h 2
  simpa only [mul_pow, EuclideanSpace.real_norm_sq_eq, Matrix.toLpLin_apply,
    LinearMap.coe_toContinuousLinearMap', WithLp.ofLp_toLp, frameEnergy, vectorNormSq,
    Matrix.mulVec, dotProduct] using hs

theorem gram_horizontal_perturbation {n d : ℕ} (U H : Frame n d) (t : ℝ)
    (hU : IsParseval U) (hUH : U.transpose * H = 0) :
    (U + t • H).transpose * (U + t • H) = 1 + t ^ 2 • (H.transpose * H) := by
  have hHU : H.transpose * U = 0 := by
    simpa only [Matrix.transpose_mul, Matrix.transpose_transpose, Matrix.transpose_zero] using
      congrArg Matrix.transpose hUH
  change U.transpose * U = 1 at hU
  simp only [Matrix.transpose_add, Matrix.transpose_smul, Matrix.add_mul, Matrix.mul_add,
    Matrix.mul_smul, Matrix.smul_mul, smul_smul, hU, hUH, hHU, smul_zero,
    add_zero, zero_add, pow_two]

theorem frameEnergy_horizontal_perturbation {n d : ℕ} (U H : Frame n d) (t : ℝ)
    (hU : IsParseval U) (hUH : U.transpose * H = 0) (x : Fin d → ℝ) :
    frameEnergy (U + t • H) x = vectorNormSq x + t ^ 2 * frameEnergy H x := by
  rw [frameEnergy_eq_matrixQuadratic, gram_horizontal_perturbation U H t hU hUH,
    matrixQuadratic_add, matrixQuadratic_smul, ← frameEnergy_eq_matrixQuadratic]
  congr 1
  simp [matrixQuadratic, Matrix.one_apply, vectorNormSq, pow_two]

theorem horizontal_perturbation_nearlyParseval {n d : ℕ} (U H : Frame n d) (t K : ℝ)
    (hU : IsParseval U) (hUH : U.transpose * H = 0)
    (hK : ‖(Matrix.toEuclideanLin H).toContinuousLinearMap‖ ^ 2 ≤ K) :
    IsNearlyParseval (t ^ 2 * K) (U + t • H) := by
  have hK0 : 0 ≤ K := (sq_nonneg _).trans hK
  intro x
  rw [frameEnergy_horizontal_perturbation U H t hU hUH x]
  have he := (frameEnergy_le_operator_norm_sq H x).trans
    (mul_le_mul_of_nonneg_right hK (vectorNormSq_nonneg x))
  have het := mul_le_mul_of_nonneg_left he (sq_nonneg t)
  constructor
  · nlinarith [mul_nonneg (sq_nonneg t) (frameEnergy_nonneg H x),
      mul_nonneg (mul_nonneg (sq_nonneg t) hK0) (vectorNormSq_nonneg x)]
  · nlinarith

theorem rowNormSq_add_le_two {n d : ℕ} (A B : Frame n d) (i : Fin n) :
    rowNormSq (A + B) i ≤ 2 * rowNormSq A i + 2 * rowNormSq B i := by
  simp only [rowNormSq, Matrix.add_apply, Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro j _
  nlinarith [sq_nonneg (A i j - B i j)]

theorem rowNormSq_smul {n d : ℕ} (A : Frame n d) (t : ℝ) (i : Fin n) :
    rowNormSq (t • A) i = t ^ 2 * rowNormSq A i := by
  simp [rowNormSq, mul_pow, Finset.mul_sum]

theorem frameProjection_add_smul {n d : ℕ} (U H : Frame n d) (t : ℝ) :
    frameProjection (U + t • H) = frameProjection U +
      t • (H * U.transpose + U * H.transpose) + t ^ 2 • frameProjection H := by
  simp only [frameProjection, Matrix.transpose_add, Matrix.transpose_smul, Matrix.add_mul,
    Matrix.mul_add, Matrix.mul_smul, Matrix.smul_mul, smul_smul, smul_add, pow_two]
  abel

theorem sqDistance_add_smul {n d : ℕ} (U H : Frame n d) (t : ℝ) :
    sqDistance U (U + t • H) = t ^ 2 * ∑ i, rowNormSq H i := by
  simp only [sqDistance, Matrix.add_apply, Matrix.smul_apply, smul_eq_mul,
    sub_add_cancel_left, neg_sq, mul_pow, rowNormSq, Finset.mul_sum]

/-- Retraction of a horizontal perturbation has fourth-order Gram error in
each row. The estimate retains the row energy, rather than losing a factor
equal to the number of rows. -/
theorem exists_horizontal_polar_retraction_with_multiplier {n d : ℕ}
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
      (IsFullSpark (U + t • H) → IsFullSpark W) ∧
      ∃ M : Matrix (Fin d) (Fin d) ℝ, W = (U + t • H) * M := by
  have hK0 : 0 ≤ K := (sq_nonneg _).trans hK
  have hδ0 : 0 ≤ t ^ 2 * K := mul_nonneg (sq_nonneg t) hK0
  have hXp := horizontal_perturbation_nearlyParseval U H t K hU hUH hK
  obtain ⟨W, hW, hcost, hrows, hspark, hfactor⟩ :=
    exists_polar_normalization_rowwise_with_multiplier (U + t • H) (t ^ 2 * K) hδ0 hsmall hXp
  refine ⟨W, hW, ?_, ?_, hspark, hfactor⟩
  · have hc := sqDistance_triangle U (U + t • H) W
    rw [sqDistance_add_smul] at hc
    nlinarith [hcost]
  · intro i
    have heq : frameProjection W - frameProjection U -
        t • (H * U.transpose + U * H.transpose) =
        (frameProjection W - frameProjection (U + t • H)) + t ^ 2 • frameProjection H := by
      rw [frameProjection_add_smul]
      abel
    rw [heq]
    have hraw := rowNormSq_add_le_two U (t • H) i
    rw [rowNormSq_smul] at hraw
    have hHH : rowNormSq (frameProjection H) i ≤ K * rowNormSq H i := by
      have hh := rowNormSq_mul_le H H.transpose i
      rw [euclidean_operator_norm_transpose] at hh
      exact hh.trans (mul_le_mul_of_nonneg_right hK (rowNormSq_nonneg H i))
    have hrow := hrows i
    have htri := rowNormSq_add_le_two (frameProjection W - frameProjection (U + t • H))
      (t ^ 2 • frameProjection H) i
    rw [rowNormSq_smul] at htri
    have hscale₁ := mul_le_mul_of_nonneg_left hraw (show 0 ≤ 6 * (t ^ 2 * K) ^ 2 by positivity)
    have hscale₂ := mul_le_mul_of_nonneg_left hHH (sq_nonneg (t ^ 2))
    nlinarith

theorem exists_horizontal_polar_retraction {n d : ℕ}
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
      (IsFullSpark (U + t • H) → IsFullSpark W) := by
  obtain ⟨W, hW, hcost, hrows, hspark, _⟩ :=
    exists_horizontal_polar_retraction_with_multiplier U H t K hU hUH hK hsmall
  exact ⟨W, hW, hcost, hrows, hspark⟩

/-- Uniform leverage-scale row bounds give a uniform fourth-order remainder. -/
theorem exists_horizontal_polar_retraction_uniform {n d : ℕ}
    (U H : Frame n d) (t K A : ℝ) (hU : IsParseval U)
    (hUH : U.transpose * H = 0)
    (hK : ‖(Matrix.toEuclideanLin H).toContinuousLinearMap‖ ^ 2 ≤ K)
    (hsmall : t ^ 2 * K ≤ 1 / 2) (ht : t ^ 2 ≤ 1)
    (hUrow : ∀ i, rowNormSq U i ≤ A) (hHrow : ∀ i, rowNormSq H i ≤ A) :
    ∃ W : Frame n d, IsParseval W ∧
      sqDistance U W ≤ 2 * t ^ 2 * (∑ i, rowNormSq H i) + 2 * t ^ 4 * K ^ 2 * (d : ℝ) ∧
      (∀ i, rowNormSq (frameProjection W - frameProjection U -
        t • (H * U.transpose + U * H.transpose)) i ≤ (48 * K ^ 2 + 2 * K) * A * t ^ 4) ∧
      (IsFullSpark (U + t • H) → IsFullSpark W) := by
  obtain ⟨W, hW, hcost, hrow, hspark⟩ := exists_horizontal_polar_retraction U H t K hU hUH hK hsmall
  refine ⟨W, hW, hcost, ?_, hspark⟩
  intro i
  have hK0 : 0 ≤ K := (sq_nonneg _).trans hK
  have hA : 0 ≤ A := (rowNormSq_nonneg U i).trans (hUrow i)
  have hcombined : rowNormSq U i + t ^ 2 * rowNormSq H i ≤ 2 * A := by
    have h1 := mul_le_mul_of_nonneg_left (hHrow i) (sq_nonneg t)
    have h2 := mul_le_mul_of_nonneg_right ht hA
    linarith [hUrow i]
  apply (hrow i).trans
  have h1 := mul_le_mul_of_nonneg_left hcombined (show 0 ≤ 24 * t ^ 4 * K ^ 2 by positivity)
  have h2 := mul_le_mul_of_nonneg_left (hHrow i) (show 0 ≤ 2 * t ^ 4 * K by positivity)
  nlinarith

end Paulsen
