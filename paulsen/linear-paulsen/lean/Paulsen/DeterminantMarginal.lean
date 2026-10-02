import Paulsen.CauchyBinet
import Paulsen.EmbeddingIncidence
import Paulsen.Definitions
import Mathlib.LinearAlgebra.Matrix.SchurComplement
import Mathlib.Algebra.BigOperators.Field

/-!
# Squared-minor marginals of a Parseval frame

Deleting one row replaces the identity Gram matrix by a rank-one update.
The determinant lemma and Cauchy--Binet then give the inclusion marginal,
without differentiating a determinant.
-/

namespace Paulsen

open scoped BigOperators

def zeroFrameRow {n d : ℕ} (W : Frame n d) (i : Fin n) : Frame n d :=
  fun k j => if k = i then 0 else W k j

theorem zeroFrameRow_gram {n d : ℕ} (W : Frame n d) (i : Fin n) :
    (zeroFrameRow W i).transpose * zeroFrameRow W i = W.transpose * W -
      Matrix.replicateCol Unit (W i) * Matrix.replicateRow Unit (W i) := by
  ext j k
  simp only [Matrix.mul_apply, Matrix.transpose_apply, Matrix.sub_apply,
    Matrix.replicateCol_apply, Matrix.replicateRow_apply, Fintype.sum_unique]
  unfold zeroFrameRow
  calc
    (∑ l : Fin n, (if l = i then 0 else W l j) * (if l = i then 0 else W l k)) =
        ∑ l : Fin n, (W l j * W l k - if l = i then W i j * W i k else 0) := by
      apply Finset.sum_congr rfl
      intro l _
      by_cases hl : l = i <;> simp [hl]
    _ = (∑ l : Fin n, W l j * W l k) - W i j * W i k := by
      rw [Finset.sum_sub_distrib]
      simp

/-- Deleting a row of a Parseval frame removes exactly its squared row
norm from the Gram determinant. -/
theorem det_zeroFrameRow_gram {n d : ℕ} (W : Frame n d)
    (hW : IsParseval W) (i : Fin n) :
    ((zeroFrameRow W i).transpose * zeroFrameRow W i).det = 1 - rowNormSq W i := by
  rw [zeroFrameRow_gram, hW, Matrix.det_one_sub_mul_comm, Matrix.det_unique]
  simp [Matrix.mul_apply, Matrix.replicateCol_apply, Matrix.replicateRow_apply,
    rowNormSq, pow_two]

theorem embeddingIncidence_eq_ite {n d : ℕ} (f : Fin d ↪ Fin n) (i : Fin n) :
    embeddingIncidence f i = if ∃ j, f j = i then 1 else 0 := by
  classical
  by_cases hi : ∃ j, f j = i
  · obtain ⟨j, rfl⟩ := hi
    simp [embeddingIncidence]
  · rw [if_neg hi]
    unfold embeddingIncidence
    apply Finset.sum_eq_zero
    intro j _
    rw [if_neg (fun hj => hi ⟨j, hj⟩)]

/-- A minor survives row deletion precisely when its tuple omits that row. -/
theorem row_minor_zeroFrameRow {n d : ℕ} (W : Frame n d)
    (f : Fin d ↪ Fin n) (i : Fin n) :
    ((zeroFrameRow W i).submatrix f id).det =
      if ∃ j, f j = i then 0 else (W.submatrix f id).det := by
  classical
  by_cases hi : ∃ j, f j = i
  · rw [if_pos hi]
    obtain ⟨j, hj⟩ := hi
    apply Matrix.det_eq_zero_of_row_eq_zero j
    intro k
    simp [Matrix.submatrix_apply, zeroFrameRow, hj]
  · rw [if_neg hi]
    congr 1
    ext j k
    have hj : f j ≠ i := fun hj => hi ⟨j, hj⟩
    simp [Matrix.submatrix_apply, zeroFrameRow, hj]

/-- Squared ordered minors of a Parseval frame have total mass `d!`. -/
theorem sum_sq_row_minor_of_parseval {n d : ℕ} (W : Frame n d)
    (hW : IsParseval W) :
    (∑ f : Fin d ↪ Fin n, (W.submatrix f id).det ^ 2) = (d.factorial : ℝ) := by
  have h := factorial_mul_gram_det_embeddings W
  rw [hW, Matrix.det_one, mul_one] at h
  simpa only [Fintype.card_fin] using h.symm

/-- The unnormalized inclusion marginal of squared ordered minors is
`d!` times the squared row norm. -/
theorem sum_incidence_sq_row_minor {n d : ℕ} (W : Frame n d)
    (hW : IsParseval W) (i : Fin n) :
    (∑ f : Fin d ↪ Fin n, embeddingIncidence f i * (W.submatrix f id).det ^ 2) =
      (d.factorial : ℝ) * rowNormSq W i := by
  have hsplit :
      (∑ f : Fin d ↪ Fin n, ((zeroFrameRow W i).submatrix f id).det ^ 2) =
        (∑ f : Fin d ↪ Fin n, (W.submatrix f id).det ^ 2) -
          ∑ f : Fin d ↪ Fin n, embeddingIncidence f i * (W.submatrix f id).det ^ 2 := by
    rw [← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl
    intro f _
    rw [row_minor_zeroFrameRow, embeddingIncidence_eq_ite]
    split_ifs <;> ring
  have h := factorial_mul_gram_det_embeddings (zeroFrameRow W i)
  rw [det_zeroFrameRow_gram W hW i, hsplit, sum_sq_row_minor_of_parseval W hW] at h
  simp only [Fintype.card_fin] at h
  nlinarith

/-- Squared row-minor weights on ordered injective tuples. -/
noncomputable def embeddingMinorWeight {n d : ℕ} (W : Frame n d)
    (f : Fin d ↪ Fin n) : ℝ :=
  (W.submatrix f id).det ^ 2 / (d.factorial : ℝ)

theorem embeddingMinorWeight_nonneg {n d : ℕ} (W : Frame n d)
    (f : Fin d ↪ Fin n) : 0 ≤ embeddingMinorWeight W f := by
  exact div_nonneg (sq_nonneg _) (Nat.cast_nonneg _)

theorem sum_embeddingMinorWeight {n d : ℕ} (W : Frame n d)
    (hW : IsParseval W) : (∑ f, embeddingMinorWeight W f) = 1 := by
  have hfact : (d.factorial : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.factorial_ne_zero d)
  unfold embeddingMinorWeight
  rw [← Finset.sum_div, sum_sq_row_minor_of_parseval W hW, div_self hfact]

/-- The inclusion marginal of the squared-minor probability distribution
is exactly the squared norm of the corresponding row. -/
theorem embeddingMinorWeight_marginal {n d : ℕ} (W : Frame n d)
    (hW : IsParseval W) (i : Fin n) :
    (∑ f : Fin d ↪ Fin n, embeddingIncidence f i * embeddingMinorWeight W f) =
      rowNormSq W i := by
  have hfact : (d.factorial : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.factorial_ne_zero d)
  unfold embeddingMinorWeight
  simp only [← mul_div_assoc, ← Finset.sum_div]
  rw [sum_incidence_sq_row_minor W hW i]
  exact mul_div_cancel_left₀ _ hfact

end Paulsen
