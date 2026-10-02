import Paulsen.DeterminantMarginal
import Paulsen.EmbeddingCoercivity
import Mathlib.Analysis.Matrix.Order

/-!
# From direct Cauchy--Binet minimization to radial frame scaling

Direct minimization of the Cauchy--Binet exponential sum supplies balanced
minor weights. Whitening uses the positive square root of the Gram matrix,
and its squared-minor distribution is precisely the minimizing tilt.
-/

namespace Paulsen

open scoped BigOperators MatrixOrder

/-- Every square minor obtained from distinct rows is nonsingular. -/
def IsFullSpark {n d : ℕ} (X : Frame n d) : Prop :=
  ∀ f : Fin d ↪ Fin n, (X.submatrix f id).det ≠ 0

theorem row_minor_diagonal_mul {n d : ℕ} (X : Frame n d)
    (w : Fin n → ℝ) (f : Fin d ↪ Fin n) :
    ((Matrix.diagonal w * X).submatrix f id).det =
      (∏ j : Fin d, w (f j)) * (X.submatrix f id).det := by
  convert Matrix.det_mul_column (fun j => w (f j)) (X.submatrix f id) using 1
  congr 1
  ext j k
  simp [Matrix.submatrix_apply, Matrix.diagonal_mul]

theorem IsFullSpark.diagonal_mul {n d : ℕ} {X : Frame n d}
    (hX : IsFullSpark X) (w : Fin n → ℝ) (hw : ∀ i, w i ≠ 0) :
    IsFullSpark (Matrix.diagonal w * X) := by
  intro f
  rw [row_minor_diagonal_mul]
  exact mul_ne_zero (Finset.prod_ne_zero_iff.mpr (fun j _ => hw (f j))) (hX f)

theorem IsFullSpark.gram_posDef {n d : ℕ} {X : Frame n d}
    (hX : IsFullSpark X) (hd : d ≤ n) : (X.transpose * X).PosDef := by
  have hpsd : (X.transpose * X).PosSemidef := by
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
      Matrix.posSemidef_conjTranspose_mul_self X
  apply hpsd.posDef_iff_det_ne_zero.mpr
  have hsum : 0 < ∑ f : Fin d ↪ Fin n, (X.submatrix f id).det ^ 2 := by
    apply Finset.sum_pos'
    · intro f _
      exact sq_nonneg _
    · exact ⟨Fin.castLEEmb hd, Finset.mem_univ _, sq_pos_of_ne_zero (hX _)⟩
  intro hdet
  have hcb := factorial_mul_gram_det_embeddings X
  rw [hdet, mul_zero] at hcb
  rw [← hcb] at hsum
  exact (lt_irrefl (0 : ℝ)) hsum

/-- A frame with positive-definite Gram matrix has a positive-definite
right multiplier making it Parseval. -/
theorem exists_posDef_right_whitening {n d : ℕ} (Y : Frame n d)
    (hG : (Y.transpose * Y).PosDef) :
    ∃ M : Matrix (Fin d) (Fin d) ℝ, M.PosDef ∧ IsParseval (Y * M) := by
  let G := Y.transpose * Y
  let H := CFC.sqrt G
  have hHpsd : H.PosSemidef := Matrix.nonneg_iff_posSemidef.mp (CFC.sqrt_nonneg G)
  have hHunit : IsUnit H := (CFC.isUnit_sqrt_iff G hG.posSemidef.nonneg).mpr hG.isUnit
  have hHpos : H.PosDef := hHpsd.posDef_iff_isUnit.mpr hHunit
  have hsq : H * H = G := by
    simpa only [pow_two] using CFC.sq_sqrt G hG.posSemidef.nonneg
  have hleft : H⁻¹ * H = 1 := Matrix.nonsing_inv_mul H
    ((Matrix.isUnit_iff_isUnit_det H).mp hHunit)
  have hright : H * H⁻¹ = 1 := Matrix.mul_nonsing_inv H
    ((Matrix.isUnit_iff_isUnit_det H).mp hHunit)
  have hsym : H⁻¹.transpose = H⁻¹ := by
    simpa only [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial]
      using hHpos.inv.isHermitian
  refine ⟨H⁻¹, hHpos.inv, ?_⟩
  change (Y * H⁻¹).transpose * (Y * H⁻¹) = 1
  rw [Matrix.transpose_mul, hsym]
  calc
    (H⁻¹ * Y.transpose) * (Y * H⁻¹) = H⁻¹ * G * H⁻¹ := by
      simp only [G, Matrix.mul_assoc]
    _ = (H⁻¹ * H) * (H * H⁻¹) := by rw [← hsq]; simp only [Matrix.mul_assoc]
    _ = 1 := by rw [hleft, hright, Matrix.one_mul]

theorem row_minor_diagonal_mul_right {n d : ℕ} (X : Frame n d)
    (w : Fin n → ℝ) (M : Matrix (Fin d) (Fin d) ℝ) (f : Fin d ↪ Fin n) :
    ((Matrix.diagonal w * X * M).submatrix f id).det =
      (∏ j : Fin d, w (f j)) * (X.submatrix f id).det * M.det := by
  have hsub : (Matrix.diagonal w * X * M).submatrix f id =
      (Matrix.diagonal w * X).submatrix f id * M := by
    ext j k
    simp [Matrix.mul_apply, Matrix.submatrix_apply]
  rw [hsub, Matrix.det_mul, row_minor_diagonal_mul]

/-- Squared minors acquire precisely the exponential tuple weight under
positive exponential row scaling and any common right transformation. -/
theorem sq_row_minor_exp_scaling {n d : ℕ} (X : Frame n d)
    (c : Fin n → ℝ) (M : Matrix (Fin d) (Fin d) ℝ) (f : Fin d ↪ Fin n) :
    ((Matrix.diagonal (fun i => Real.exp (c i / 2)) * X * M).submatrix f id).det ^ 2 =
      (X.submatrix f id).det ^ 2 * Real.exp (∑ j : Fin d, c (f j)) * M.det ^ 2 := by
  rw [row_minor_diagonal_mul_right]
  have hprod : (∏ j : Fin d, Real.exp (c (f j) / 2)) ^ 2 =
      Real.exp (∑ j : Fin d, c (f j)) := by
    rw [← Real.exp_sum, pow_two, ← Real.exp_add]
    congr 1
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro j _
    ring
  rw [mul_pow, mul_pow, hprod]
  ring

/-- Two normalized vectors proportional to the same vector coincide. -/
theorem normalized_common_factor_unique {ι : Type*} [Fintype ι]
    (a p q : ι → ℝ) (Z K : ℝ)
    (hp : ∀ i, p i = Z * a i) (hq : ∀ i, q i = K * a i)
    (hp_sum : (∑ i, p i) = 1) (hq_sum : (∑ i, q i) = 1) :
    ∀ i, p i = q i := by
  have hZ : Z * (∑ i, a i) = 1 := by
    simpa only [hp, ← Finset.mul_sum] using hp_sum
  have hK : K * (∑ i, a i) = 1 := by
    simpa only [hq, ← Finset.mul_sum] using hq_sum
  have ha : (∑ i, a i) ≠ 0 := by
    intro ha
    rw [ha, mul_zero] at hZ
    exact zero_ne_one hZ
  have hZK : Z = K := mul_right_cancel₀ ha (hZ.trans hK.symm)
  intro i
  rw [hp i, hq i, hZK]

/-- Every full-spark real frame with `d ≤ n` admits positive row scaling
followed by a positive-definite right whitening that is exactly equal-norm
and Parseval. The right multiplier is therefore invertible and symmetric. -/
theorem exists_fullSpark_radial_scaling {n d : ℕ} (hn : 0 < n) (hd : d ≤ n)
    (X : Frame n d) (hX : IsFullSpark X) :
    ∃ w : Fin n → ℝ, (∀ i, 0 < w i) ∧
      ∃ M : Matrix (Fin d) (Fin d) ℝ,
        M.PosDef ∧ IsEqualNormParseval (Matrix.diagonal w * X * M) := by
  let μ : (Fin d ↪ Fin n) → ℝ := fun f => (X.submatrix f id).det ^ 2
  have hμ : ∀ f, 0 < μ f := fun f => sq_pos_of_ne_zero (hX f)
  obtain ⟨ν, _hν_pos, hν_sum, hν_marginal, c₀, c, hc⟩ :=
    exists_balanced_embedding_tilt_coercive hn hd μ hμ
  let w : Fin n → ℝ := fun i => Real.exp (c i / 2)
  have hw : ∀ i, 0 < w i := fun i => Real.exp_pos _
  have hY : IsFullSpark (Matrix.diagonal w * X) :=
    hX.diagonal_mul w (fun i => ne_of_gt (hw i))
  obtain ⟨M, hM, hW_parseval⟩ := exists_posDef_right_whitening
    (Matrix.diagonal w * X) (hY.gram_posDef hd)
  let W : Frame n d := Matrix.diagonal w * X * M
  let a : (Fin d ↪ Fin n) → ℝ :=
    fun f => μ f * Real.exp (∑ j : Fin d, c (f j))
  have hν_factor : ∀ f, ν f = Real.exp (c₀ - 1) * a f := by
    intro f
    rw [hc f]
    rw [show c₀ + (∑ j : Fin d, c (f j)) - 1 =
      (c₀ - 1) + (∑ j : Fin d, c (f j)) by ring, Real.exp_add]
    dsimp [a]
    ring
  have hW_factor : ∀ f, embeddingMinorWeight W f =
      (M.det ^ 2 / (d.factorial : ℝ)) * a f := by
    intro f
    unfold embeddingMinorWeight
    change ((Matrix.diagonal (fun i => Real.exp (c i / 2)) * X * M).submatrix f id).det ^ 2 /
      (d.factorial : ℝ) = _
    rw [sq_row_minor_exp_scaling]
    dsimp [a, μ]
    ring
  have hweights : ∀ f, ν f = embeddingMinorWeight W f :=
    normalized_common_factor_unique a ν (embeddingMinorWeight W)
      (Real.exp (c₀ - 1)) (M.det ^ 2 / (d.factorial : ℝ))
      hν_factor hW_factor hν_sum (sum_embeddingMinorWeight W hW_parseval)
  refine ⟨w, hw, M, hM, hW_parseval, ?_⟩
  intro i
  rw [← embeddingMinorWeight_marginal W hW_parseval i]
  simpa only [← hweights] using hν_marginal i

end Paulsen
