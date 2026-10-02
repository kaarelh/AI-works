import Paulsen.Paper.Moderate

/-!
# Helpers for `ModerateSample`: linear functionals of Gaussian images

For a matrix `C` and coefficients `w`, the functional `g ↦ ∑_q w_q (C g)_q` is a continuous
linear functional of the standard Gaussian `g`; its second moment is `wᵀ C Cᵀ w`.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

section Generic

variable {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]
set_option linter.unusedSectionVars false

/-- The continuous linear functional `g ↦ ∑_q w_q (C g)_q`. -/
def linDual (C : Matrix ι κ ℝ) (w : ι → ℝ) : StrongDual ℝ (EuclideanSpace ℝ κ) :=
  innerSL ℝ (WithLp.toLp 2 (C.transpose *ᵥ w))

theorem linDual_apply (C : Matrix ι κ ℝ) (w : ι → ℝ) (g : EuclideanSpace ℝ κ) :
    linDual C w g = ∑ q, w q * Matrix.toEuclideanLin C g q := by
  simp only [linDual, innerSL_apply_apply, PiLp.inner_apply, Real.inner_apply,
    Matrix.toLpLin_apply, Matrix.mulVec, dotProduct, Matrix.transpose_apply]
  simp only [Finset.mul_sum, Finset.sum_mul]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro q _
  apply Finset.sum_congr rfl
  intro p _
  ring

theorem linDual_norm_sq (C : Matrix ι κ ℝ) (w : ι → ℝ) :
    ‖linDual C w‖ ^ 2 = matrixQuadratic (C * C.transpose) w := by
  rw [linDual, innerSL_apply_norm, EuclideanSpace.real_norm_sq_eq]
  simp only [matrixQuadratic, Matrix.mulVec, dotProduct, Matrix.transpose_apply,
    Matrix.mul_apply, pow_two, Finset.sum_mul, Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro q _
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro q' _
  apply Finset.sum_congr rfl
  intro p _
  ring

theorem integral_sq_linDual (C : Matrix ι κ ℝ) (w : ι → ℝ) :
    ∫ g, (∑ q, w q * Matrix.toEuclideanLin C g q) ^ 2 ∂stdGaussian (EuclideanSpace ℝ κ) =
      matrixQuadratic (C * C.transpose) w := by
  simp_rw [← linDual_apply]
  rw [integral_sq_dual_stdGaussian, linDual_norm_sq]

theorem memLp_sq_linDual (C : Matrix ι κ ℝ) (w : ι → ℝ) :
    MemLp (fun g => (∑ q, w q * Matrix.toEuclideanLin C g q) ^ 2) 2
      (stdGaussian (EuclideanSpace ℝ κ)) := by
  simp_rw [← linDual_apply]
  exact memLp_square_of_hasLaw (hasLaw_dual_stdGaussian (linDual C w))

theorem integrable_sq_linDual (C : Matrix ι κ ℝ) (w : ι → ℝ) :
    Integrable (fun g => (∑ q, w q * Matrix.toEuclideanLin C g q) ^ 2)
      (stdGaussian (EuclideanSpace ℝ κ)) :=
  (memLp_sq_linDual C w).integrable (by norm_num)

theorem integrable_linDual (C : Matrix ι κ ℝ) (w : ι → ℝ) :
    Integrable (fun g => ∑ q, w q * Matrix.toEuclideanLin C g q)
      (stdGaussian (EuclideanSpace ℝ κ)) := by
  simp_rw [← linDual_apply]
  exact IsGaussian.integrable_dual _ (linDual C w)

/-- `wᵀ C Cᵀ w ≤ ‖C‖² ‖w‖²`. -/
theorem matrixQuadratic_mul_transpose_le (C : Matrix ι κ ℝ) (w : ι → ℝ) :
    matrixQuadratic (C * C.transpose) w ≤ opNorm C ^ 2 * ∑ q, w q ^ 2 := by
  rw [← linDual_norm_sq, linDual, innerSL_apply_norm]
  have he : (WithLp.toLp 2 (C.transpose *ᵥ w) : EuclideanSpace ℝ κ) =
      Matrix.toEuclideanLin C.transpose (WithLp.toLp 2 w) := by
    simp [Matrix.toLpLin_apply]
  rw [he]
  have hle := (Matrix.toEuclideanLin C.transpose).toContinuousLinearMap.le_opNorm
    (WithLp.toLp 2 w)
  have ht : ‖(Matrix.toEuclideanLin C.transpose).toContinuousLinearMap‖ = opNorm C :=
    euclidean_operator_norm_transpose C
  rw [ht] at hle
  have hw : ‖(WithLp.toLp 2 w : EuclideanSpace ℝ ι)‖ ^ 2 = ∑ q, w q ^ 2 := by
    rw [EuclideanSpace.real_norm_sq_eq]
  calc
    ‖(Matrix.toEuclideanLin C.transpose) (WithLp.toLp 2 w)‖ ^ 2 ≤
        (opNorm C * ‖(WithLp.toLp 2 w : EuclideanSpace ℝ ι)‖) ^ 2 :=
      pow_le_pow_left₀ (norm_nonneg _) hle 2
    _ = _ := by rw [mul_pow, hw]

end Generic

end

end Paulsen.Paper
