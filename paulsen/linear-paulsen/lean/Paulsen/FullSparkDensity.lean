import Paulsen.RadialExistence
import Mathlib.LinearAlgebra.Vandermonde
import Mathlib.LinearAlgebra.Matrix.Charpoly.Coeff
import Mathlib.Analysis.Polynomial.Basic
import Mathlib.Topology.Instances.Matrix

/-!
# Full-spark approximation

Perturbing along a fixed Vandermonde frame makes every maximal row minor
nonsingular outside a finite set of scalar parameters. Characteristic
polynomials supply the finite-exception argument without multivariate
polynomial geometry.
-/

namespace Paulsen

open Filter
open scoped Topology

/-- A concrete full-spark real frame in any rectangular size. -/
def vandermondeFrame (n d : ℕ) : Frame n d :=
  fun i j => (i.val : ℝ) ^ j.val

theorem vandermondeFrame_fullSpark (n d : ℕ) : IsFullSpark (vandermondeFrame n d) := by
  intro f
  change (Matrix.vandermonde (fun j : Fin d => ((f j).val : ℝ))).det ≠ 0
  apply Matrix.det_vandermonde_ne_zero_iff.mpr
  intro i j hij
  apply f.injective
  apply Fin.ext
  change ((f i).val : ℝ) = ((f j).val : ℝ) at hij
  exact Nat.cast_injective hij

/-- The determinant of a matrix pencil is a nonzero characteristic polynomial
times the determinant of its nonsingular leading coefficient. -/
theorem det_matrix_pencil {d : ℕ} (A V : Matrix (Fin d) (Fin d) ℝ)
    (hV : V.det ≠ 0) (t : ℝ) :
    (A + t • V).det = V.det * (-(V⁻¹ * A)).charpoly.eval t := by
  have hi : V * V⁻¹ = 1 := Matrix.mul_nonsing_inv V (isUnit_iff_ne_zero.mpr hV)
  rw [Matrix.eval_charpoly, ← Matrix.det_mul]
  congr 1
  have hscalar : Matrix.scalar (Fin d) t = t • (1 : Matrix (Fin d) (Fin d) ℝ) := by
    ext i j
    simp [Matrix.scalar_apply, Matrix.diagonal_apply, Matrix.one_apply, mul_ite]
  rw [hscalar, sub_neg_eq_add, Matrix.mul_add, Matrix.mul_smul, Matrix.mul_one,
    ← Matrix.mul_assoc, hi, Matrix.one_mul, add_comm]

theorem eventually_det_matrix_pencil_ne_zero {d : ℕ}
    (A V : Matrix (Fin d) (Fin d) ℝ) (hV : V.det ≠ 0) :
    ∀ᶠ t : ℝ in cofinite, (A + t • V).det ≠ 0 := by
  have hpoly := Polynomial.eventually_cofinite_not_isRoot
    (Matrix.charpoly_monic (-(V⁻¹ * A))).ne_zero
  filter_upwards [hpoly] with t ht
  rw [det_matrix_pencil A V hV]
  exact mul_ne_zero hV ht

/-- Only finitely many parameters can fail the full-spark condition. -/
theorem eventually_fullSpark_pencil {n d : ℕ} (X V : Frame n d) (hV : IsFullSpark V) :
    ∀ᶠ t : ℝ in cofinite, IsFullSpark (X + t • V) := by
  apply eventually_all.mpr
  intro f
  exact eventually_det_matrix_pencil_ne_zero (X.submatrix f id) (V.submatrix f id) (hV f)

/-- Full-spark real frames are dense, including near degenerate input frames. -/
theorem dense_fullSpark (n d : ℕ) : Dense {X : Frame n d | IsFullSpark X} := by
  intro X
  let V := vandermondeFrame n d
  have hc : Continuous (fun t : ℝ => X + t • V) := by fun_prop
  have ht : Tendsto (fun t : ℝ => X + t • V) (𝓝[≠] (0 : ℝ)) (𝓝 X) := by
    simpa using (hc.tendsto (0 : ℝ)).mono_left nhdsWithin_le_nhds
  apply mem_closure_of_tendsto ht
  exact (eventually_fullSpark_pencil X V (vandermondeFrame_fullSpark n d)).filter_mono
    (nhdsNE_le_cofinite 0)

end Paulsen
