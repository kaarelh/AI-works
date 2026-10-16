import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Analysis.Normed.Module.FiniteDimension
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

/-!
# Euclidean geometry of a matrix with independent coordinates

This file identifies the bilinear coefficients of the actual rectangular
matrix operator, including their squared sum. It contains no probabilistic
assumption about matrix norms.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators RealInnerProductSpace

variable {m n : Type*} [Fintype m] [Fintype n]

def coordinateMatrixOperator (z : m × n → ℝ) :
    EuclideanSpace ℝ n →L[ℝ] EuclideanSpace ℝ m := by
  classical
  exact (Matrix.toLpLin 2 2 (fun i j => z (i, j))).toContinuousLinearMap

theorem coordinateMatrixOperator_inner (z : m × n → ℝ)
    (x : EuclideanSpace ℝ n) (y : EuclideanSpace ℝ m) :
    ⟪coordinateMatrixOperator z x, y⟫ =
      ∑ ij : m × n, (y ij.1 * x ij.2) * z ij := by
  classical
  simp only [coordinateMatrixOperator, LinearMap.coe_toContinuousLinearMap',
    Matrix.toLpLin_apply, PiLp.inner_apply, RCLike.inner_apply,
    conj_trivial, Matrix.mulVec, dotProduct,
    Fintype.sum_prod_type]
  apply Finset.sum_congr rfl
  intro i hi
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j hj
  ring

theorem matrix_bilinear_coefficient_energy
    (x : EuclideanSpace ℝ n) (y : EuclideanSpace ℝ m) :
    (∑ ij : m × n, (y ij.1 * x ij.2) ^ 2) = ‖y‖ ^ 2 * ‖x‖ ^ 2 := by
  rw [← real_inner_self_eq_norm_sq, ← real_inner_self_eq_norm_sq]
  simp only [PiLp.inner_apply, RCLike.inner_apply, conj_trivial,
    Fintype.sum_prod_type, mul_pow]
  rw [Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro i hi
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j hj
  ring

theorem matrix_bilinear_coefficient_energy_le_one
    (x : EuclideanSpace ℝ n) (y : EuclideanSpace ℝ m)
    (hx : ‖x‖ ≤ 1) (hy : ‖y‖ ≤ 1) :
    (∑ ij : m × n, (y ij.1 * x ij.2) ^ 2) ≤ 1 := by
  rw [matrix_bilinear_coefficient_energy]
  have hx2 : ‖x‖ ^ 2 ≤ 1 := by nlinarith [norm_nonneg x]
  have hy2 : ‖y‖ ^ 2 ≤ 1 := by nlinarith [norm_nonneg y]
  calc
    _ ≤ 1 * 1 := mul_le_mul hy2 hx2 (sq_nonneg _) (by norm_num)
    _ = _ := by norm_num

end NeuralGeneralization
