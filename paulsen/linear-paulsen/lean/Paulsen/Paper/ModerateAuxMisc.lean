import Paulsen.Paper.ModerateAuxGauss
import Paulsen.Paper.ModerateAuxDrift

/-!
# Helpers for `Paulsen.Paper.Moderate`: miscellaneous generic facts

Polarisation (a symmetric matrix is determined by its quadratic form), a two-block
Cauchy–Schwarz inequality, and `frobSq = ‖vec‖²`.
-/

namespace Paulsen.Paper.ModerateAux

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

theorem mq_single {ι : Type*} [Fintype ι] [DecidableEq ι] (A : Matrix ι ι ℝ) (a : ι) :
    matrixQuadratic A (Pi.single a 1) = A a a := by
  simp [matrixQuadratic, Pi.single_apply]

theorem mq_single_add {ι : Type*} [Fintype ι] [DecidableEq ι] (A : Matrix ι ι ℝ) (a b : ι) :
    matrixQuadratic A (Pi.single a 1 + Pi.single b 1) = A a a + A a b + A b a + A b b := by
  simp only [matrixQuadratic, Pi.add_apply, add_mul, mul_add, Finset.sum_add_distrib]
  simp [Pi.single_apply]
  ring

/-- A symmetric real matrix is determined by its quadratic form. -/
theorem eq_of_quadratic_eq {ι : Type*} [Fintype ι] [DecidableEq ι] (A B : Matrix ι ι ℝ)
    (hA : A.transpose = A) (hB : B.transpose = B)
    (h : ∀ x, matrixQuadratic A x = matrixQuadratic B x) : A = B := by
  ext a b
  have h1 := h (Pi.single a 1)
  have h2 := h (Pi.single b 1)
  have h3 := h (Pi.single a 1 + Pi.single b 1)
  rw [mq_single, mq_single] at h1 h2
  rw [mq_single_add, mq_single_add] at h3
  have hA' : A b a = A a b := by
    have := congrArg (fun M : Matrix ι ι ℝ => M a b) hA; simpa using this
  have hB' : B b a = B a b := by
    have := congrArg (fun M : Matrix ι ι ℝ => M a b) hB; simpa using this
  linarith

/-- `|⟨a,b⟩ - ⟨c,e⟩| ≤ √(‖a‖²+‖c‖²) √(‖b‖²+‖e‖²)`. -/
theorem abs_sub_sum_mul_le {κ₁ κ₂ : Type*} [Fintype κ₁] [Fintype κ₂] (a b : κ₁ → ℝ)
    (c e : κ₂ → ℝ) :
    |∑ k, a k * b k - ∑ k, c k * e k| ≤
      Real.sqrt (∑ k, a k ^ 2 + ∑ k, c k ^ 2) * Real.sqrt (∑ k, b k ^ 2 + ∑ k, e k ^ 2) := by
  set s₁ := ∑ k, a k * b k
  set s₂ := ∑ k, c k * e k
  set P₁ := ∑ k, a k ^ 2
  set Q₁ := ∑ k, b k ^ 2
  set P₂ := ∑ k, c k ^ 2
  set Q₂ := ∑ k, e k ^ 2
  have h1 : s₁ ^ 2 ≤ P₁ * Q₁ := Finset.sum_mul_sq_le_sq_mul_sq _ _ _
  have h2 : s₂ ^ 2 ≤ P₂ * Q₂ := Finset.sum_mul_sq_le_sq_mul_sq _ _ _
  have hP₁ : 0 ≤ P₁ := by positivity
  have hP₂ : 0 ≤ P₂ := by positivity
  have hQ₁ : 0 ≤ Q₁ := by positivity
  have hQ₂ : 0 ≤ Q₂ := by positivity
  have h3 : (s₁ * s₂) ^ 2 ≤ (P₁ * Q₂) * (P₂ * Q₁) := by
    rw [mul_pow]
    calc s₁ ^ 2 * s₂ ^ 2 ≤ (P₁ * Q₁) * (P₂ * Q₂) :=
          mul_le_mul h1 h2 (sq_nonneg _) (mul_nonneg hP₁ hQ₁)
      _ = _ := by ring
  have h4 : 2 * |s₁ * s₂| ≤ P₁ * Q₂ + P₂ * Q₁ := by
    have hu : 0 ≤ P₁ * Q₂ := mul_nonneg hP₁ hQ₂
    have hv : 0 ≤ P₂ * Q₁ := mul_nonneg hP₂ hQ₁
    have hsq : (2 * |s₁ * s₂|) ^ 2 ≤ (P₁ * Q₂ + P₂ * Q₁) ^ 2 := by
      rw [mul_pow, sq_abs]
      nlinarith [sq_nonneg (P₁ * Q₂ - P₂ * Q₁)]
    exact (sq_le_sq₀ (by positivity) (by positivity)).mp hsq
  have h5 : (s₁ - s₂) ^ 2 ≤ (P₁ + P₂) * (Q₁ + Q₂) := by
    have : -(s₁ * s₂) ≤ |s₁ * s₂| := neg_le_abs _
    nlinarith
  rw [← Real.sqrt_mul (add_nonneg hP₁ hP₂)]
  exact Real.abs_le_sqrt h5

theorem frobSq_eq_nfv {n d : ℕ} (H : Frame n d) : frobSq H = ‖normalFrobVector H‖ ^ 2 :=
  (Linear.normalFrobVector_norm_sq_eq_sum H).symm

theorem sqrt_frobSq_eq {n d : ℕ} (H : Frame n d) :
    Real.sqrt (frobSq H) = ‖normalFrobVector H‖ := by
  rw [frobSq_eq_nfv, Real.sqrt_sq (norm_nonneg _)]

theorem sum_rowNormSq_eq {n d : ℕ} {U : Frame n d} (hU : IsParseval U) :
    ∑ i, rowNormSq U i = (d : ℝ) := by
  have h : (frameProjection U).trace = (d : ℝ) := by
    rw [frameProjection, Matrix.trace_mul_comm, hU]; simp
  rw [← h, Matrix.trace]
  simp [frameProjection_diagonal]

end

end Paulsen.Paper.ModerateAux
