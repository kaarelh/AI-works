import Paulsen.Paper.SampleAuxNoise

/-!
# Helpers for `ModerateSample`: the correlated quadratic-form tail with explicit bounds

A packaging of `lem_gauss_a_correlated` (the paper's `lem:gauss`(a), constant `1/8`) with
upper bounds on the covariance and on the coefficient matrix.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

variable {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]
set_option linter.unusedSectionVars false

theorem opNorm_nonneg' (M : Matrix ι κ ℝ) : 0 ≤ opNorm M := norm_nonneg _

theorem eq_zero_of_opNorm_eq_zero (M : Matrix ι κ ℝ) (h : opNorm M = 0) : M = 0 := by
  have h1 : (Matrix.toEuclideanLin M).toContinuousLinearMap = 0 := norm_eq_zero.mp h
  have h2 : Matrix.toEuclideanLin M = 0 := by
    have := congrArg (fun T : EuclideanSpace ℝ κ →L[ℝ] EuclideanSpace ℝ ι =>
      (T : EuclideanSpace ℝ κ →ₗ[ℝ] EuclideanSpace ℝ ι)) h1
    simpa using this
  exact (Matrix.toEuclideanLin (𝕜 := ℝ) (m := ι) (n := κ)).injective (by simpa using h2)

omit [DecidableEq ι] [DecidableEq κ] in
theorem frobSq_nonneg (M : Matrix ι κ ℝ) : 0 ≤ frobSq M :=
  Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _

omit [DecidableEq ι] [DecidableEq κ] in
theorem eq_zero_of_frobSq_eq_zero (M : Matrix ι κ ℝ) (h : frobSq M = 0) : M = 0 := by
  ext i j
  have hi := (Finset.sum_eq_zero_iff_of_nonneg (fun i _ =>
    Finset.sum_nonneg fun j (_ : j ∈ Finset.univ) => sq_nonneg (M i j))).mp h i
    (Finset.mem_univ _)
  have hj := (Finset.sum_eq_zero_iff_of_nonneg (fun j (_ : j ∈ Finset.univ) =>
    sq_nonneg (M i j))).mp hi j (Finset.mem_univ _)
  simpa using hj

/-- `lem:gauss`(a), correlated form, with explicit bounds `‖CCᵀ‖ ≤ s`, `‖A‖_F² ≤ V`,
`‖A‖ ≤ B`. -/
theorem quad_tail_of_bounds (A : Matrix ι ι ℝ) (hA : A.IsHermitian) (C : Matrix ι κ ℝ)
    {s V B u : ℝ} (hs : 0 < s) (hu : 0 < u)
    (hC : opNorm (C * C.transpose) ≤ s) (hAF : frobSq A ≤ V) (hAop : opNorm A ≤ B) :
    (stdGaussian (EuclideanSpace ℝ κ)).real
        {g | u < |euclideanQuadratic A (Matrix.toEuclideanLin C g) -
          (C.transpose * A * C).trace|} ≤
      2 * Real.exp (-(1 / 8) * min (u ^ 2 / (s ^ 2 * V)) (u / (s * B))) := by
  obtain ⟨h1, h2, h3, h4⟩ := lem_gauss_a_correlated A hA C u
  by_cases hM : C.transpose * A * C = 0
  · have hempty : {g : EuclideanSpace ℝ κ | u < |euclideanQuadratic A (Matrix.toEuclideanLin C g) -
        (C.transpose * A * C).trace|} = ∅ := by
      ext g
      simp only [Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false, not_lt]
      rw [h1 g, hM]
      simp [euclideanQuadratic, hu.le]
    rw [hempty]
    simp only [measureReal_empty]
    positivity
  · have hF0 : 0 < frobSq (C.transpose * A * C) :=
      lt_of_le_of_ne (frobSq_nonneg _) (fun h => hM (eq_zero_of_frobSq_eq_zero _ h.symm))
    have hO0 : 0 < opNorm (C.transpose * A * C) :=
      lt_of_le_of_ne (opNorm_nonneg' _) (fun h => hM (eq_zero_of_opNorm_eq_zero _ h.symm))
    have hCn : 0 ≤ opNorm (C * C.transpose) := opNorm_nonneg' _
    have hF : frobSq (C.transpose * A * C) ≤ s ^ 2 * V := by
      calc _ ≤ opNorm (C * C.transpose) ^ 2 * frobSq A := h2
        _ ≤ s ^ 2 * V := mul_le_mul (pow_le_pow_left₀ hCn hC 2) hAF (frobSq_nonneg _)
          (by positivity)
    have hO : opNorm (C.transpose * A * C) ≤ s * B := by
      calc _ ≤ opNorm (C * C.transpose) * opNorm A := h3
        _ ≤ s * B := mul_le_mul hC hAop (opNorm_nonneg' _) hs.le
    apply h4.trans
    have hmin : min (u ^ 2 / (s ^ 2 * V)) (u / (s * B)) ≤
        min (u ^ 2 / frobSq (C.transpose * A * C)) (u / opNorm (C.transpose * A * C)) :=
      min_le_min (div_le_div_of_nonneg_left (by positivity) hF0 hF)
        (div_le_div_of_nonneg_left hu.le hO0 hO)
    exact mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr (by linarith)) (by norm_num)

end

end Paulsen.Paper
