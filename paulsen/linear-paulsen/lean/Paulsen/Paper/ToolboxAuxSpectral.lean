import Mathlib.Analysis.Matrix.HermitianFunctionalCalculus
import Paulsen.FrameAlignment
import Paulsen.GaussianMatrixTail

/-!
# Helper for `Paulsen.Paper.Toolbox`: explicit spectral decomposition of real symmetric
matrices and the continuous functional calculus.
-/

namespace Paulsen.Paper.ToolboxAux

open Matrix Paulsen
open scoped BigOperators

noncomputable section

variable {k : Type*} [Fintype k] [DecidableEq k]

/-- The real orthogonal eigenvector matrix of a symmetric matrix. -/
def eigQ {G : Matrix k k ℝ} (hG : G.IsHermitian) : Matrix k k ℝ :=
  (hG.eigenvectorUnitary : Matrix k k ℝ)

theorem eigQ_star {G : Matrix k k ℝ} (hG : G.IsHermitian) :
    (star (hG.eigenvectorUnitary : Matrix k k ℝ)) = (eigQ hG).transpose := by
  rw [Matrix.star_eq_conjTranspose, Matrix.conjTranspose_eq_transpose_of_trivial]; rfl

theorem eigQ_transpose_mul {G : Matrix k k ℝ} (hG : G.IsHermitian) :
    (eigQ hG).transpose * eigQ hG = 1 := by
  rw [← eigQ_star]; exact Unitary.coe_star_mul_self _

theorem eigQ_mul_transpose {G : Matrix k k ℝ} (hG : G.IsHermitian) :
    eigQ hG * (eigQ hG).transpose = 1 := by
  rw [← eigQ_star]; exact Unitary.coe_mul_star_self _

theorem eig_decomp {G : Matrix k k ℝ} (hG : G.IsHermitian) :
    G = eigQ hG * Matrix.diagonal hG.eigenvalues * (eigQ hG).transpose := by
  conv_lhs => rw [hG.spectral_theorem]
  rw [Unitary.conjStarAlgAut_apply, eigQ_star]
  simp only [RCLike.ofReal_real_eq_id, Function.id_comp]
  rfl

theorem cfc_decomp {G : Matrix k k ℝ} (hG : G.IsHermitian) (f : ℝ → ℝ) :
    cfc f G = eigQ hG * Matrix.diagonal (fun i => f (hG.eigenvalues i)) * (eigQ hG).transpose := by
  rw [hG.cfc_eq f, Matrix.IsHermitian.cfc, Unitary.conjStarAlgAut_apply, eigQ_star]
  simp only [RCLike.ofReal_real_eq_id, Function.id_comp]
  rfl

/-- The eigenvalue is the Rayleigh quotient at the (unit) eigenvector column. -/
theorem eigenvalue_eq_quadratic {G : Matrix k k ℝ} (hG : G.IsHermitian) (i : k) :
    hG.eigenvalues i = ∑ a, ∑ b, eigQ hG a i * G a b * eigQ hG b i := by
  have hdec := eig_decomp hG
  have hQ := eigQ_transpose_mul hG
  set Q := eigQ hG with hQdef
  set e := hG.eigenvalues with he
  clear_value Q e
  have h := congrArg (fun M => M i i) (show Q.transpose * G * Q =
      Matrix.diagonal e by
    rw [hdec]
    simp only [Matrix.mul_assoc, hQ, Matrix.mul_one]
    rw [← Matrix.mul_assoc, hQ, Matrix.one_mul])
  simp only [Matrix.diagonal_apply_eq] at h
  rw [← h]
  simp only [Matrix.mul_apply, Matrix.transpose_apply, Finset.sum_mul]
  rw [Finset.sum_comm]

theorem eigQ_col_norm {G : Matrix k k ℝ} (hG : G.IsHermitian) (i : k) :
    ∑ a, eigQ hG a i ^ 2 = 1 := by
  have h := congrArg (fun M => M i i) (eigQ_transpose_mul hG)
  simp only [Matrix.mul_apply, Matrix.transpose_apply, Matrix.one_apply_eq] at h
  simpa [pow_two] using h

end

end Paulsen.Paper.ToolboxAux
