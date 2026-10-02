import Paulsen.Paper.Toolbox

/-!
# Helper for `Paulsen.Paper.Intro`: the trace argument of `rem:optimal`.

With `E` a projection (the principal block of `XXᵀ`), `A = W₁W₁ᵀ` and `B = W₁W₂ᵀ` the
principal and off-diagonal blocks of `WWᵀ` (`W₁ᵀW₁ + W₂ᵀW₂ = I`), and `Δ = E - A`:
`tr(A - A²) = ‖B‖_F²`, `tr(EΔ) ≥ tr Δ`, hence
`‖Δ‖² + 2‖B‖² ≤ S` forces `tr Δ ≤ S`.
-/

namespace Paulsen.Paper.IntroAux

open Matrix
open scoped BigOperators

noncomputable section

theorem frob_eq_trace {m D : ℕ} (M : Matrix (Fin m) (Fin D) ℝ) :
    ∑ i, ∑ j, M i j ^ 2 = (M * M.transpose).trace := by
  simp only [Matrix.trace, Matrix.diag_apply, Matrix.mul_apply, Matrix.transpose_apply, pow_two]

/-- The trace argument of `rem:optimal`. -/
theorem optimal_core {m m' D : ℕ} (E : Matrix (Fin m) (Fin m) ℝ) (hEs : E.transpose = E)
    (hEE : E * E = E) (W₁ : Matrix (Fin m) (Fin D) ℝ) (W₂ : Matrix (Fin m') (Fin D) ℝ)
    (hW : W₁.transpose * W₁ + W₂.transpose * W₂ = 1) (S : ℝ)
    (hS : ∑ i, ∑ j, (E i j - (W₁ * W₁.transpose) i j) ^ 2 +
      2 * ∑ i, ∑ j, (W₁ * W₂.transpose) i j ^ 2 ≤ S) :
    E.trace - (W₁ * W₁.transpose).trace ≤ S := by
  set A := W₁ * W₁.transpose with hAdef
  have hAs : A.transpose = A := by
    rw [hAdef, Matrix.transpose_mul, Matrix.transpose_transpose]
  have hδ : ∑ i, ∑ j, (E i j - A i j) ^ 2 =
      E.trace - 2 * (E * A).trace + (A * A).trace := by
    have h := frob_eq_trace (E - A)
    simp only [Matrix.sub_apply] at h
    rw [h, Matrix.transpose_sub, hEs, hAs, Matrix.sub_mul, Matrix.mul_sub, Matrix.mul_sub,
      Matrix.trace_sub, Matrix.trace_sub, Matrix.trace_sub, hEE, Matrix.trace_mul_comm A E]
    ring
  have hβ : ∑ i, ∑ j, (W₁ * W₂.transpose) i j ^ 2 = A.trace - (A * A).trace := by
    rw [frob_eq_trace, Matrix.transpose_mul, Matrix.transpose_transpose]
    have hW2 : W₂.transpose * W₂ = 1 - W₁.transpose * W₁ := by rw [← hW]; abel
    calc (W₁ * W₂.transpose * (W₂ * W₁.transpose)).trace
        = (W₁ * (W₂.transpose * W₂) * W₁.transpose).trace := by simp only [Matrix.mul_assoc]
      _ = _ := by
        rw [hW2, Matrix.mul_sub, Matrix.sub_mul, Matrix.trace_sub, Matrix.mul_one, hAdef]
        simp only [Matrix.mul_assoc]
  have hpsd : (E * A).trace ≤ A.trace := by
    have hP : (1 - E).transpose * (1 - E) = 1 - E := by
      rw [Matrix.transpose_sub, Matrix.transpose_one, hEs, Matrix.sub_mul, Matrix.mul_sub,
        Matrix.mul_sub, Matrix.one_mul, Matrix.mul_one, Matrix.one_mul, hEE]
      abel
    have h0 : 0 ≤ ∑ i, ∑ j, (((1 : Matrix (Fin m) (Fin m) ℝ) - E) * W₁) i j ^ 2 :=
      Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => sq_nonneg _
    rw [frob_eq_trace, Matrix.transpose_mul, Matrix.trace_mul_comm, Matrix.mul_assoc,
      ← Matrix.mul_assoc (1 - E).transpose, hP, ← Matrix.mul_assoc, Matrix.trace_mul_comm,
      ← Matrix.mul_assoc, Matrix.mul_sub, Matrix.mul_one, Matrix.trace_sub] at h0
    rw [hAdef, Matrix.trace_mul_comm E]
    linarith
  have h1 : 0 ≤ ∑ i, ∑ j, (E i j - A i j) ^ 2 :=
    Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => sq_nonneg _
  have h2 : 0 ≤ ∑ i, ∑ j, (W₁ * W₂.transpose) i j ^ 2 :=
    Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => sq_nonneg _
  rw [hδ] at h1 hS
  rw [hβ] at h2 hS
  linarith

end

end Paulsen.Paper.IntroAux
