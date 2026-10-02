import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.Data.Fintype.Perm
import Mathlib.Data.Fintype.Pi
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring

/-!
# Rectangular determinant expansion and ordered Cauchy--Binet

The intermediate indices are ordered tuples, with repeated choices allowed.
This avoids choosing an ordering on subsets of row indices.
-/

namespace Paulsen

open scoped BigOperators

/-- Expand the determinant of a rectangular product by multilinearity in
the rows. Each term chooses one row of `B` for every row of `A * B`. -/
theorem det_mul_rectangular_expansion {ι κ R : Type*}
    [Fintype ι] [DecidableEq ι] [Fintype κ] [CommRing R]
    (A : Matrix ι κ R) (B : Matrix κ ι R) :
    (A * B).det = ∑ f : ι → κ,
      (∏ i, A i (f i)) * (B.submatrix f id).det := by
  classical
  calc
    (A * B).det = Matrix.det (fun i => ∑ k, A i k • B k) := by
      congr 1
      ext i j
      simp [Matrix.mul_apply, Finset.sum_apply, smul_eq_mul]
    _ = ∑ f : ι → κ, Matrix.det (fun i => A i (f i) • B (f i)) := by
      exact (Matrix.detRowAlternating.toMultilinearMap.map_sum
        (fun i k => A i k • B k))
    _ = ∑ f : ι → κ, (∏ i, A i (f i)) * (B.submatrix f id).det := by
      apply Finset.sum_congr rfl
      intro f _
      exact Matrix.det_mul_column (fun i => A i (f i)) (B.submatrix f id)

/-- Permuting the positions of an ordered tuple is a bijection of all tuples. -/
def tuplePermEquiv {ι κ : Type*} (σ : Equiv.Perm ι) : (ι → κ) ≃ (ι → κ) where
  toFun f := f ∘ σ
  invFun f := f ∘ σ.symm
  left_inv f := by funext i; simp
  right_inv f := by funext i; simp

/-- Reindex the row expansion by any permutation of tuple positions. -/
theorem det_mul_rectangular_expansion_permuted {ι κ R : Type*}
    [Fintype ι] [DecidableEq ι] [Fintype κ] [CommRing R]
    (A : Matrix ι κ R) (B : Matrix κ ι R) (σ : Equiv.Perm ι) :
    (A * B).det = ∑ f : ι → κ,
      ((Equiv.Perm.sign σ : ℤ) : R) * (∏ i, A i (f (σ i))) *
        (B.submatrix f id).det := by
  classical
  rw [det_mul_rectangular_expansion]
  rw [← (tuplePermEquiv (κ := κ) σ).sum_comp
    (fun f : ι → κ => (∏ i, A i (f i)) * (B.submatrix f id).det)]
  apply Finset.sum_congr rfl
  intro f _
  change (∏ i, A i (f (σ i))) * (B.submatrix (f ∘ σ) id).det = _
  have hsub : B.submatrix (f ∘ σ) id = (B.submatrix f id).submatrix σ id := rfl
  rw [hsub, Matrix.det_permute]
  ring

/-- Ordered-tuple Cauchy--Binet over any commutative ring. The factorial
accounts for every ordering of a set of distinct intermediate indices. -/
theorem factorial_mul_det_mul {ι κ R : Type*}
    [Fintype ι] [DecidableEq ι] [Fintype κ] [CommRing R]
    (A : Matrix ι κ R) (B : Matrix κ ι R) :
    ((Fintype.card ι).factorial : R) * (A * B).det =
      ∑ f : ι → κ, (A.submatrix id f).det * (B.submatrix f id).det := by
  classical
  calc
    ((Fintype.card ι).factorial : R) * (A * B).det =
        ∑ _σ : Equiv.Perm ι, (A * B).det := by
      simp [Fintype.card_perm]
    _ = ∑ σ : Equiv.Perm ι, ∑ f : ι → κ,
        ((Equiv.Perm.sign σ : ℤ) : R) * (∏ i, A i (f (σ i))) *
          (B.submatrix f id).det := by
      apply Finset.sum_congr rfl
      intro σ _
      exact det_mul_rectangular_expansion_permuted A B σ
    _ = ∑ f : ι → κ,
        (∑ σ : Equiv.Perm ι,
          ((Equiv.Perm.sign σ : ℤ) : R) * (∏ i, A i (f (σ i)))) *
            (B.submatrix f id).det := by
      rw [Finset.sum_comm]
      simp only [Finset.sum_mul]
    _ = ∑ f : ι → κ, (A.submatrix id f).det * (B.submatrix f id).det := by
      apply Finset.sum_congr rfl
      intro f _
      have hdet : (A.submatrix id f).det =
          ∑ σ : Equiv.Perm ι,
            ((Equiv.Perm.sign σ : ℤ) : R) * (∏ i, A i (f (σ i))) := by
        simpa only [Matrix.det_transpose, Matrix.transpose_apply,
          Matrix.submatrix_apply, id_eq] using Matrix.det_apply' (A.submatrix id f).transpose
      rw [hdet]

/-- The Gram determinant is the sum of squared ordered row minors,
with each unordered minor counted `d!` times. -/
theorem factorial_mul_gram_det {ι κ R : Type*}
    [Fintype ι] [DecidableEq ι] [Fintype κ] [CommRing R]
    (X : Matrix κ ι R) :
    ((Fintype.card ι).factorial : R) * (X.transpose * X).det =
      ∑ f : ι → κ, (X.submatrix f id).det ^ 2 := by
  rw [factorial_mul_det_mul]
  apply Finset.sum_congr rfl
  intro f _
  rw [← Matrix.transpose_submatrix, Matrix.det_transpose, pow_two]

/-- Ordered row minors with a repeated row vanish. -/
theorem row_minor_det_zero_of_not_injective {ι κ R : Type*}
    [Fintype ι] [DecidableEq ι] [CommRing R]
    (X : Matrix κ ι R) (f : ι → κ) (hf : ¬ Function.Injective f) :
    (X.submatrix f id).det = 0 := by
  obtain ⟨i, j, hij, hne⟩ := Function.not_injective_iff.mp hf
  apply Matrix.det_zero_of_row_eq hne
  funext k
  exact congrArg (fun r => X r k) hij

/-- Repeated rows contribute zero, so only injective ordered tuples remain. -/
theorem factorial_mul_gram_det_injective {ι κ R : Type*}
    [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ] [CommRing R]
    (X : Matrix κ ι R) :
    ((Fintype.card ι).factorial : R) * (X.transpose * X).det =
      ∑ f : ι → κ with Function.Injective f, (X.submatrix f id).det ^ 2 := by
  classical
  rw [factorial_mul_gram_det]
  refine (Finset.sum_subset (Finset.filter_subset _ _) ?_).symm
  intro f _ hf
  have hnot : ¬ Function.Injective f := by
    simpa only [Finset.mem_filter_univ] using hf
  rw [row_minor_det_zero_of_not_injective X f hnot]
  simp

/-- The ordered injective sum can equivalently be indexed by embeddings. -/
theorem factorial_mul_gram_det_embeddings {ι κ R : Type*}
    [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ] [CommRing R]
    (X : Matrix κ ι R) :
    ((Fintype.card ι).factorial : R) * (X.transpose * X).det =
      ∑ f : ι ↪ κ, (X.submatrix f id).det ^ 2 := by
  classical
  rw [factorial_mul_gram_det_injective, ← Finset.sum_subtype_eq_sum_filter]
  simpa [Equiv.subtypeInjectiveEquivEmbedding] using
    (Equiv.subtypeInjectiveEquivEmbedding ι κ).sum_comp
    (fun f : ι ↪ κ => (X.submatrix f id).det ^ 2)

/-- The requested ordered-tuple Cauchy--Binet formula for real Gram matrices. -/
theorem gram_det_eq_ordered_sum {n d : ℕ} (X : Matrix (Fin n) (Fin d) ℝ) :
    (X.transpose * X).det = (1 / (d.factorial : ℝ)) *
      ∑ f : Fin d → Fin n, (X.submatrix f id).det ^ 2 := by
  have hfact : (d.factorial : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.factorial_ne_zero d)
  have h := factorial_mul_gram_det X
  simp only [Fintype.card_fin] at h
  rw [← h]
  field_simp

end Paulsen
