import Mathlib.LinearAlgebra.Matrix.PosDef
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.Star.Real
import Mathlib.Tactic.NoncommRing
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Paulsen.Graph

/-!
# Matrix inequalities underlying diagonal scaling

Only finite-dimensional, algebraic matrix statements are proved here.
-/

namespace Paulsen

open scoped BigOperators
open Matrix

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- A positive-definite real matrix lies above its inverse tangent plane:
`A⁻¹ - 2 I + A` is positive semidefinite. -/
theorem posDef_inverse_tangent_plane {A : Matrix ι ι ℝ} (hA : A.PosDef) :
    (A⁻¹ - (1 + 1) + A).PosSemidef := by
  have hdet : IsUnit A.det := (Matrix.isUnit_iff_isUnit_det A).mp hA.isUnit
  have hleft : A * A⁻¹ = 1 := Matrix.mul_nonsing_inv A hdet
  have hright : A⁻¹ * A = 1 := Matrix.nonsing_inv_mul A hdet
  have hherm : (A - 1).conjTranspose = A - 1 := by
    simp only [Matrix.conjTranspose_sub, hA.isHermitian.eq, Matrix.conjTranspose_one]
  have hpos := hA.inv.posSemidef.conjTranspose_mul_mul_same (A - 1)
  rw [hherm] at hpos
  have hid : (A - 1) * A⁻¹ * (A - 1) = A⁻¹ - (1 + 1) + A := by
    simp only [sub_mul, mul_sub, one_mul, mul_one, hleft, hright]
    noncomm_ring
  rwa [hid] at hpos

/-- The scaled inverse inequality, avoiding any formula for the inverse of a
scalar multiple. The scalar `c` need not be positive. -/
theorem posDef_scaled_inverse_tangent_plane {A : Matrix ι ι ℝ}
    (hA : A.PosDef) (c : ℝ) :
    ((c ^ 2) • A⁻¹ - (2 * c) • (1 : Matrix ι ι ℝ) + A).PosSemidef := by
  have hdet : IsUnit A.det := (Matrix.isUnit_iff_isUnit_det A).mp hA.isUnit
  have hleft : A * A⁻¹ = 1 := Matrix.mul_nonsing_inv A hdet
  have hright : A⁻¹ * A = 1 := Matrix.nonsing_inv_mul A hdet
  have hherm : (A - c • (1 : Matrix ι ι ℝ)).conjTranspose = A - c • 1 := by
    rw [Matrix.conjTranspose_sub, Matrix.conjTranspose_smul, hA.isHermitian.eq]
    simp
  have hpos := hA.inv.posSemidef.conjTranspose_mul_mul_same (A - c • 1)
  rw [hherm] at hpos
  have hid : (A - c • 1) * A⁻¹ * (A - c • 1) =
      (c ^ 2) • A⁻¹ - (2 * c) • (1 : Matrix ι ι ℝ) + A := by
    simp only [sub_mul, mul_sub, Matrix.smul_mul, Matrix.mul_smul, one_mul, mul_one,
      hleft, hright, smul_smul]
    ext i j
    simp only [Matrix.sub_apply, Matrix.add_apply, Matrix.smul_apply, smul_eq_mul]
    ring
  rwa [hid] at hpos

/-- The scaled inverse inequality tested on an arbitrary row vector, expressed
through the diagonal of a matrix sandwich. -/
theorem posDef_inverse_sandwich_diagonal
    {κ : Type*} [Fintype κ] [DecidableEq κ]
    {A : Matrix ι ι ℝ} (hA : A.PosDef)
    (U : Matrix κ ι ℝ) (c : ℝ) (i : κ) :
    2 * c * (U * U.transpose) i i ≤
      c ^ 2 * (U * A⁻¹ * U.transpose) i i + (U * A * U.transpose) i i := by
  have hp := ((posDef_scaled_inverse_tangent_plane hA c).mul_mul_conjTranspose_same U).diag_nonneg
    (i := i)
  simp only [Matrix.conjTranspose_eq_transpose_of_trivial, Matrix.mul_add, Matrix.mul_sub,
    Matrix.add_mul, Matrix.sub_mul, Matrix.mul_smul, Matrix.smul_mul, Matrix.mul_one,
    Matrix.add_apply, Matrix.sub_apply, Matrix.smul_apply, smul_eq_mul] at hp
  linarith

variable {κ : Type*} [Fintype κ] [DecidableEq κ]

/-- The Gram matrix after assigning positive squared row scales `z`. -/
noncomputable def weightedFrameGram (U : Matrix κ ι ℝ) (z : κ → ℝ) : Matrix ι ι ℝ :=
  U.transpose * Matrix.diagonal z * U

/-- The leverage score formula for a diagonally scaled subspace. -/
noncomputable def scaledLeverage (U : Matrix κ ι ℝ) (z : κ → ℝ) (i : κ) : ℝ :=
  z i * (U * (weightedFrameGram U z)⁻¹ * U.transpose) i i

theorem weightedFrameGram_posDef (U : Matrix κ ι ℝ) (z : κ → ℝ)
    (hU : U.transpose * U = 1) (hz : ∀ i, 0 < z i) :
    (weightedFrameGram U z).PosDef := by
  have hinj : Function.Injective U.mulVec := by
    intro x y hxy
    have h := congrArg (fun v => U.transpose *ᵥ v) hxy
    simpa only [Matrix.mulVec_mulVec, hU, Matrix.one_mulVec] using h
  have hp := (Matrix.PosDef.diagonal hz).conjTranspose_mul_mul_same hinj
  simpa only [Matrix.conjTranspose_eq_transpose_of_trivial, weightedFrameGram] using hp

omit [DecidableEq ι] in
theorem weightedFrameGram_sandwich_diagonal
    (U : Matrix κ ι ℝ) (z : κ → ℝ) (i : κ) :
    (U * weightedFrameGram U z * U.transpose) i i =
      ∑ j, ((U * U.transpose) i j) ^ 2 * z j := by
  have hmat : U * weightedFrameGram U z * U.transpose =
      (U * U.transpose) * Matrix.diagonal z * (U * U.transpose) := by
    simp only [weightedFrameGram, Matrix.mul_assoc]
  rw [hmat, Matrix.mul_apply]
  apply Finset.sum_congr rfl
  intro j _
  rw [Matrix.mul_diagonal]
  have hs : (U * U.transpose) j i = (U * U.transpose) i j := by
    have hm : (U * U.transpose).transpose = U * U.transpose := by
      simp only [Matrix.transpose_mul, Matrix.transpose_transpose]
    exact congrArg (fun M : Matrix κ κ ℝ => M i j) hm
  rw [hs]
  ring

theorem projectionLaplacian_mulVec_eq (P : Matrix κ κ ℝ) (z : κ → ℝ) (i : κ) :
    (projectionLaplacian P *ᵥ z) i =
      P i i * z i - ∑ j, (P i j) ^ 2 * z j := by
  simp [projectionLaplacian, Matrix.mulVec, dotProduct,
    Matrix.diagonal_apply, sub_mul, Finset.sum_sub_distrib]

/-- The first exact diagonal-scaling inequality. It is valid for any input
matrix whose weighted Gram matrix is positive definite. -/
theorem diagonal_scaling_first_inequality
    (U : Matrix κ ι ℝ) (z : κ → ℝ)
    (hG : (weightedFrameGram U z).PosDef) (i : κ) :
    (projectionLaplacian (U * U.transpose) *ᵥ z) i ≤
      z i * (scaledLeverage U z i - (U * U.transpose) i i) := by
  have hp := posDef_inverse_sandwich_diagonal hG U (z i) i
  rw [weightedFrameGram_sandwich_diagonal] at hp
  rw [projectionLaplacian_mulVec_eq]
  unfold scaledLeverage
  nlinarith

/-- In particular, a Parseval frame and strictly positive row scales satisfy
the first exact diagonal-scaling inequality. -/
theorem parseval_diagonal_scaling_first_inequality
    (U : Matrix κ ι ℝ) (z : κ → ℝ)
    (hU : U.transpose * U = 1) (hz : ∀ i, 0 < z i) (i : κ) :
    (projectionLaplacian (U * U.transpose) *ᵥ z) i ≤
      z i * (scaledLeverage U z i - (U * U.transpose) i i) := by
  exact diagonal_scaling_first_inequality U z (weightedFrameGram_posDef U z hU hz) i

/-- An upper bound on diagonal movement yields the Laplacian subsolution
inequality used by the finite median barrier. -/
theorem parseval_diagonal_scaling_subsolution
    (U : Matrix κ ι ℝ) (z : κ → ℝ) (β : ℝ)
    (hU : U.transpose * U = 1) (hz : ∀ i, 0 < z i)
    (herror : ∀ i, scaledLeverage U z i - (U * U.transpose) i i ≤ β) :
    ∀ i, (projectionLaplacian (U * U.transpose) *ᵥ z) i ≤ β * z i := by
  intro i
  calc
    (projectionLaplacian (U * U.transpose) *ᵥ z) i ≤
        z i * (scaledLeverage U z i - (U * U.transpose) i i) :=
      parseval_diagonal_scaling_first_inequality U z hU hz i
    _ ≤ z i * β := mul_le_mul_of_nonneg_left (herror i) (le_of_lt (hz i))
    _ = β * z i := mul_comm _ _

end Paulsen
