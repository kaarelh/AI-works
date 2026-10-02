import Paulsen.Definitions
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.FieldSimp

/-!
# Exact algebra of a normalized tangent seed

These are deterministic identities.  No Gaussian distribution, concentration
bound, or existence of a suitable tangent vector is assumed or asserted.
-/

open scoped BigOperators

noncomputable section

namespace Paulsen

/-- The inner product of corresponding rows of two real frames. -/
def rowDot {n d : ℕ} (X Z : Frame n d) (i : Fin n) : ℝ :=
  ∑ j, X i j * Z i j

/-- The squared row noise norm, relative to the target row norm. -/
def tangentRatio {n d : ℕ} (a : ℝ) (Z : Frame n d) (i : Fin n) : ℝ :=
  rowNormSq Z i / a

/-- Normalize each perturbed row to its original squared norm `a`.
The denominator equals `sqrt (a + t² ‖zᵢ‖²) / sqrt a` when `a > 0`. -/
def tangentSeed {n d : ℕ} (X Z : Frame n d) (a t : ℝ) : Frame n d :=
  Matrix.of fun i j => (X i j + t * Z i j) /
    Real.sqrt (1 + t ^ 2 * tangentRatio a Z i)

theorem tangentRatio_nonneg {n d : ℕ} (a : ℝ) (ha : 0 < a)
    (Z : Frame n d) (i : Fin n) : 0 ≤ tangentRatio a Z i := by
  exact div_nonneg (rowNormSq_nonneg Z i) ha.le

theorem tangent_denominator_pos {n d : ℕ} (a t : ℝ) (ha : 0 < a)
    (Z : Frame n d) (i : Fin n) : 0 < 1 + t ^ 2 * tangentRatio a Z i := by
  have h := mul_nonneg (sq_nonneg t) (tangentRatio_nonneg a ha Z i)
  linarith

/-- Agreement with `sqrt a (xᵢ + t zᵢ) / sqrt (a + t² ‖zᵢ‖²)`. -/
theorem tangentSeed_original_formula {n d : ℕ} (X Z : Frame n d)
    (a t : ℝ) (ha : 0 < a) (i : Fin n) (j : Fin d) :
    tangentSeed X Z a t i j =
      Real.sqrt a * (X i j + t * Z i j) /
        Real.sqrt (a + t ^ 2 * rowNormSq Z i) := by
  have harg : 1 + t ^ 2 * tangentRatio a Z i =
      (a + t ^ 2 * rowNormSq Z i) / a := by
    unfold tangentRatio
    field_simp
  unfold tangentSeed
  simp only [Matrix.of_apply]
  rw [harg, Real.sqrt_div' _ ha.le, div_div_eq_mul_div]
  ring

theorem tangent_row_norm_expansion {n d : ℕ}
    (X Z : Frame n d) (t : ℝ) (i : Fin n) :
    (∑ j, (X i j + t * Z i j) ^ 2) =
      rowNormSq X i + 2 * t * rowDot X Z i + t ^ 2 * rowNormSq Z i := by
  unfold rowNormSq rowDot
  simp only [Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro j hj
  ring

/-- Individual row tangency makes the normalization exact. -/
theorem tangentSeed_rowNormSq {n d : ℕ} (X Z : Frame n d)
    (a t : ℝ) (ha : 0 < a) (i : Fin n)
    (hx : rowNormSq X i = a) (htangent : rowDot X Z i = 0) :
    rowNormSq (tangentSeed X Z a t) i = a := by
  have hden := tangent_denominator_pos a t ha Z i
  have hnum : (∑ j, (X i j + t * Z i j) ^ 2) =
      a * (1 + t ^ 2 * tangentRatio a Z i) := by
    rw [tangent_row_norm_expansion, hx, htangent]
    unfold tangentRatio
    field_simp
    ring
  unfold rowNormSq tangentSeed
  simp only [Matrix.of_apply, div_pow]
  simp only [div_eq_mul_inv, ← Finset.sum_mul]
  rw [Real.sq_sqrt hden.le, hnum, ← div_eq_mul_inv]
  exact mul_div_cancel_right₀ a hden.ne'

/-- If `a=d/n`, the tangent seed is exactly equal norm. -/
theorem tangentSeed_isEqualNorm {n d : ℕ} (X Z : Frame n d)
    (t : ℝ) (ha : 0 < (d : ℝ) / n)
    (hx : IsEqualNorm X) (htangent : ∀ i, rowDot X Z i = 0) :
    IsEqualNorm (tangentSeed X Z ((d : ℝ) / n) t) := by
  intro i
  exact tangentSeed_rowNormSq X Z _ t ha i (hx i) (htangent i)

/-- Removing the square root gives an exact rational row covariance. -/
theorem tangentSeed_entry_product {n d : ℕ} (X Z : Frame n d)
    (a t : ℝ) (ha : 0 < a) (i : Fin n) (j k : Fin d) :
    tangentSeed X Z a t i j * tangentSeed X Z a t i k =
      ((X i j + t * Z i j) * (X i k + t * Z i k)) /
        (1 + t ^ 2 * tangentRatio a Z i) := by
  unfold tangentSeed
  simp only [Matrix.of_apply]
  rw [div_mul_div_comm, ← pow_two,
    Real.sq_sqrt (tangent_denominator_pos a t ha Z i).le]

/-- The exact cubic/quartic remainder identity for one row covariance entry. -/
theorem tangent_covariance_scalar_expansion (x y z w r t : ℝ)
    (hden : 1 + t ^ 2 * r ≠ 0) :
    (x + t * z) * (y + t * w) / (1 + t ^ 2 * r) =
      x * y + t * (x * w + z * y) + t ^ 2 * (z * w - r * x * y) -
      t ^ 3 * (r / (1 + t ^ 2 * r)) * (x * w + z * y) -
      t ^ 4 * (r / (1 + t ^ 2 * r)) * (z * w - r * x * y) := by
  field_simp
  ring

/-- The quadratic ambient error `ZᵀZ - Σᵢ rᵢ xᵢxᵢᵀ`. -/
def tangentQuadratic {n d : ℕ} (X Z : Frame n d) (a : ℝ) : Matrix (Fin d) (Fin d) ℝ :=
  Matrix.of fun j k => ∑ i, (Z i j * Z i k - tangentRatio a Z i * X i j * X i k)

/-- The exact remainder, with its stabilizing row denominators retained. -/
def tangentRemainder {n d : ℕ} (X Z : Frame n d) (a t : ℝ) : Matrix (Fin d) (Fin d) ℝ :=
  Matrix.of fun j k =>
    -(t ^ 3) * ∑ i, (tangentRatio a Z i / (1 + t ^ 2 * tangentRatio a Z i)) *
      (X i j * Z i k + Z i j * X i k) -
    t ^ 4 * ∑ i, (tangentRatio a Z i / (1 + t ^ 2 * tangentRatio a Z i)) *
      (Z i j * Z i k - tangentRatio a Z i * X i j * X i k)

/-- The frame operator expansion after cancellation of the global linear term.
The individual row tangency is needed for equal row norms, but this operator
identity itself only needs the displayed global tangent constraint. -/
theorem tangentSeed_frameOperator_expansion {n d : ℕ} (X Z : Frame n d)
    (a t : ℝ) (ha : 0 < a)
    (hglobal : X.transpose * Z + Z.transpose * X = 0) :
    (tangentSeed X Z a t).transpose * tangentSeed X Z a t =
      X.transpose * X + t ^ 2 • tangentQuadratic X Z a + tangentRemainder X Z a t := by
  ext j k
  have hlinear := congrArg (fun M : Matrix (Fin d) (Fin d) ℝ => M j k) hglobal
  simp only [Matrix.add_apply, Matrix.mul_apply, Matrix.transpose_apply,
    Matrix.zero_apply] at hlinear
  have hlinear' : (∑ i, (X i j * Z i k + Z i j * X i k)) = 0 := by
    simpa only [Finset.sum_add_distrib] using hlinear
  simp only [Matrix.add_apply, Matrix.mul_apply, Matrix.transpose_apply,
    Matrix.smul_apply, smul_eq_mul, tangentQuadratic, tangentRemainder, Matrix.of_apply]
  simp_rw [tangentSeed_entry_product X Z a t ha,
    tangent_covariance_scalar_expansion _ _ _ _ _ _
      (tangent_denominator_pos a t ha Z _).ne']
  simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib,
    mul_assoc, ← Finset.mul_sum, hlinear', mul_zero, add_zero]
  ring

end Paulsen
