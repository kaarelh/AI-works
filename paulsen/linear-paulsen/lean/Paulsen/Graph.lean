import Mathlib.LinearAlgebra.Matrix.PosDef
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum

/-!
# Projection Laplacians

Elementary finite-dimensional identities used by the Paulsen proof.  These
statements do not assume any scaling, probability, or analytic existence result.
-/

open scoped BigOperators

noncomputable section

namespace Paulsen

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The Laplacian associated with a matrix of edge weights. -/
def graphLaplacian (w : Matrix ι ι ℝ) : Matrix ι ι ℝ :=
  Matrix.diagonal (fun i => ∑ j, w i j) - w

/-- The projection Laplacian `Diag(diag P) - P ∘ P`. -/
def projectionLaplacian (P : Matrix ι ι ℝ) : Matrix ι ι ℝ :=
  Matrix.diagonal (fun i => P i i) - Matrix.of (fun i j => (P i j) ^ 2)

/-- A real matrix quadratic form, written as finite sums. -/
def matrixQuadratic (M : Matrix ι ι ℝ) (x : ι → ℝ) : ℝ :=
  ∑ i, ∑ j, x i * M i j * x j

/-- The energy of a weighted graph.  The factor `1/2` removes double counting. -/
def graphEnergy (w : Matrix ι ι ℝ) (x : ι → ℝ) : ℝ :=
  (1 / 2 : ℝ) * ∑ i, ∑ j, w i j * (x i - x j) ^ 2

omit [DecidableEq ι] in
theorem matrixQuadratic_sub (M N : Matrix ι ι ℝ) (x : ι → ℝ) :
    matrixQuadratic (M - N) x = matrixQuadratic M x - matrixQuadratic N x := by
  simp [matrixQuadratic, mul_sub, sub_mul, Finset.sum_sub_distrib]

theorem matrixQuadratic_diagonal (d : ι → ℝ) (x : ι → ℝ) :
    matrixQuadratic (Matrix.diagonal d) x = ∑ i, d i * (x i) ^ 2 := by
  unfold matrixQuadratic
  apply Finset.sum_congr rfl
  intro i hi
  rw [Finset.sum_eq_single i]
  · simp only [Matrix.diagonal_apply_eq]
    ring
  · intro j hj hji
    simp [Ne.symm hji]
  · intro h
    exact (h (Finset.mem_univ i)).elim

/-- Symmetric graph weights give the usual sum-of-squared-differences formula. -/
theorem graphLaplacian_quadratic (w : Matrix ι ι ℝ)
    (hsymm : ∀ i j, w i j = w j i) (x : ι → ℝ) :
    matrixQuadratic (graphLaplacian w) x = graphEnergy w x := by
  have hswap : (∑ i, ∑ j, w i j * (x j) ^ 2) =
      ∑ i, ∑ j, w i j * (x i) ^ 2 := by
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro i hi
    apply Finset.sum_congr rfl
    intro j hj
    rw [hsymm j i]
  have hexpand : (∑ i, ∑ j, w i j * (x i - x j) ^ 2) =
      (∑ i, ∑ j, w i j * (x i) ^ 2) +
      (∑ i, ∑ j, w i j * (x j) ^ 2) -
      2 * (∑ i, ∑ j, x i * w i j * x j) := by
    calc
      (∑ i, ∑ j, w i j * (x i - x j) ^ 2) =
          ∑ i, ∑ j, (w i j * (x i) ^ 2 + w i j * (x j) ^ 2 -
            2 * (x i * w i j * x j)) := by
        apply Finset.sum_congr rfl
        intro i hi
        apply Finset.sum_congr rfl
        intro j hj
        ring
      _ = _ := by
        simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.mul_sum]
  rw [graphLaplacian, matrixQuadratic_sub, matrixQuadratic_diagonal]
  unfold graphEnergy matrixQuadratic
  simp only [Finset.sum_mul]
  rw [hexpand, hswap]
  ring

omit [DecidableEq ι] in
theorem graphEnergy_nonneg (w : Matrix ι ι ℝ)
    (hweights : ∀ i j, 0 ≤ w i j) (x : ι → ℝ) :
    0 ≤ graphEnergy w x := by
  unfold graphEnergy
  apply mul_nonneg (by norm_num)
  apply Finset.sum_nonneg
  intro i hi
  apply Finset.sum_nonneg
  intro j hj
  exact mul_nonneg (hweights i j) (sq_nonneg (x i - x j))

theorem graphLaplacian_quadratic_nonneg (w : Matrix ι ι ℝ)
    (hsymm : ∀ i j, w i j = w j i)
    (hweights : ∀ i j, 0 ≤ w i j) (x : ι → ℝ) :
    0 ≤ matrixQuadratic (graphLaplacian w) x := by
  rw [graphLaplacian_quadratic w hsymm]
  exact graphEnergy_nonneg w hweights x

/-- Nonnegative symmetric weights give a positive semidefinite matrix,
in mathlib's standard matrix definition. -/
theorem graphLaplacian_posSemidef (w : Matrix ι ι ℝ)
    (hsymm : ∀ i j, w i j = w j i)
    (hweights : ∀ i j, 0 ≤ w i j) :
    (graphLaplacian w).PosSemidef := by
  apply Matrix.PosSemidef.of_dotProduct_mulVec_nonneg
  · apply Matrix.isHermitian_iff_isSymm.mpr
    apply Matrix.IsSymm.sub (Matrix.isSymm_diagonal _)
    unfold Matrix.IsSymm
    ext i j
    exact hsymm j i
  · intro x
    simpa [matrixQuadratic, dotProduct, Matrix.mulVec, Finset.mul_sum, mul_assoc] using
      graphLaplacian_quadratic_nonneg w hsymm hweights x

/-- Constant vectors are in the kernel, without a symmetry assumption. -/
theorem graphLaplacian_mulVec_const (w : Matrix ι ι ℝ) (c : ℝ) :
    Matrix.mulVec (graphLaplacian w) (fun _ => c) = 0 := by
  ext i
  simp [graphLaplacian, Matrix.mulVec, Matrix.diagonal_apply, dotProduct, sub_mul,
    Finset.sum_sub_distrib, Finset.sum_mul]

omit [DecidableEq ι] in
/-- Symmetric idempotence identifies each row sum of squared entries. -/
theorem projection_row_squares (P : Matrix ι ι ℝ)
    (hsymm : ∀ i j, P i j = P j i) (hproj : P * P = P) (i : ι) :
    (∑ j, (P i j) ^ 2) = P i i := by
  have hi := congrArg (fun M : Matrix ι ι ℝ => M i i) hproj
  rw [Matrix.mul_apply] at hi
  calc
    (∑ j, (P i j) ^ 2) = ∑ j, P i j * P j i := by
      apply Finset.sum_congr rfl
      intro j hj
      rw [← hsymm i j]
      ring
    _ = P i i := hi

theorem projectionLaplacian_eq_graph (P : Matrix ι ι ℝ)
    (hsymm : ∀ i j, P i j = P j i) (hproj : P * P = P) :
    projectionLaplacian P = graphLaplacian (fun i j => (P i j) ^ 2) := by
  unfold graphLaplacian
  simp_rw [projection_row_squares P hsymm hproj]
  rfl

/-- The central quadratic-form identity for a real orthogonal projection. -/
theorem projectionLaplacian_quadratic (P : Matrix ι ι ℝ)
    (hsymm : ∀ i j, P i j = P j i) (hproj : P * P = P) (x : ι → ℝ) :
    matrixQuadratic (projectionLaplacian P) x =
      (1 / 2 : ℝ) * ∑ i, ∑ j, (P i j) ^ 2 * (x i - x j) ^ 2 := by
  rw [projectionLaplacian_eq_graph P hsymm hproj]
  exact graphLaplacian_quadratic _ (by
    intro i j
    rw [hsymm i j]) x

theorem projectionLaplacian_quadratic_nonneg (P : Matrix ι ι ℝ)
    (hsymm : ∀ i j, P i j = P j i) (hproj : P * P = P) (x : ι → ℝ) :
    0 ≤ matrixQuadratic (projectionLaplacian P) x := by
  rw [projectionLaplacian_eq_graph P hsymm hproj]
  exact graphLaplacian_quadratic_nonneg _ (by
    intro i j
    rw [hsymm i j]) (by
    intro i j
    exact sq_nonneg (P i j)) x

theorem projectionLaplacian_posSemidef (P : Matrix ι ι ℝ)
    (hsymm : ∀ i j, P i j = P j i) (hproj : P * P = P) :
    (projectionLaplacian P).PosSemidef := by
  rw [projectionLaplacian_eq_graph P hsymm hproj]
  apply graphLaplacian_posSemidef
  · intro i j
    rw [hsymm i j]
  · intro i j
    exact sq_nonneg (P i j)

omit [Fintype ι] in
/-- Complementation leaves the projection Laplacian unchanged.
This algebraic identity holds for every real square matrix. -/
theorem projectionLaplacian_complement (P : Matrix ι ι ℝ) :
    projectionLaplacian (1 - P) = projectionLaplacian P := by
  ext i j
  by_cases hij : i = j
  · subst j
    simp only [projectionLaplacian, Matrix.sub_apply, Matrix.diagonal_apply_eq,
      Matrix.of_apply, Matrix.one_apply_eq]
    ring
  · simp [projectionLaplacian, Matrix.one_apply, hij]

end Paulsen
