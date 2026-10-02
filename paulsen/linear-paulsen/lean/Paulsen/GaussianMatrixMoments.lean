import Paulsen.GaussianMatrixSeries
import Paulsen.MatrixPolynomial

/-!
# Gaussian matrix trace moments

The integration-by-parts identity is applied to actual polynomial traces; the
moment recurrence is derived rather than supplied as a hypothesis.
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory NNReal

noncomputable section

namespace Paulsen

variable {τ ι : Type*} [Fintype τ] [DecidableEq τ] [Fintype ι] [DecidableEq ι]

omit [DecidableEq τ] in
/-- Every polynomial matrix trace is integrable under the product Gaussian law. -/
theorem integrable_eval_trace_polynomialMatrix (P : Matrix ι ι (MvPolynomial τ ℝ)) :
    Integrable (fun x : τ → ℝ => ((MvPolynomial.eval x).mapMatrix P).trace)
      (Measure.pi fun _ : τ => gaussianReal 0 1) := by
  simpa only [eval_trace_polynomialMatrix] using
    integrable_mvPolynomial_stdGaussian_real P.trace

omit [DecidableEq τ] in
theorem integrable_trace_gaussianMatrixSeries_pow (A : τ → Matrix ι ι ℝ) (n : ℕ) :
    Integrable (fun x : τ → ℝ => (gaussianMatrixSeries A x ^ n).trace)
      (Measure.pi fun _ : τ => gaussianReal 0 1) := by
  simpa only [map_pow, eval_polynomialMatrixSeries] using
    integrable_eval_trace_polynomialMatrix (polynomialMatrixSeries A ^ n)

omit [DecidableEq τ] in
theorem integrable_trace_gaussianMatrixSeries_mixed
    (A : τ → Matrix ι ι ℝ) (B C : Matrix ι ι ℝ) (k l : ℕ) :
    Integrable (fun x : τ → ℝ =>
      (B * gaussianMatrixSeries A x ^ k * C * gaussianMatrixSeries A x ^ l).trace)
      (Measure.pi fun _ : τ => gaussianReal 0 1) := by
  convert! integrable_eval_trace_polynomialMatrix
      (constPolynomialMatrix B * polynomialMatrixSeries A ^ k *
        constPolynomialMatrix C * polynomialMatrixSeries A ^ l) using 1
  ext x
  simp only [map_pow, map_mul, eval_constPolynomialMatrix, eval_polynomialMatrixSeries]

/-- An exact coordinate integration-by-parts identity for the matrix trace. -/
theorem integral_coordinate_mul_trace_gaussianMatrixSeries_pow
    (A : τ → Matrix ι ι ℝ) (j : τ) (n : ℕ) :
    (∫ x : τ → ℝ, x j * (A j * gaussianMatrixSeries A x ^ n).trace
      ∂(Measure.pi fun _ : τ => gaussianReal 0 1)) =
      ∑ k ∈ Finset.range n,
        ∫ x : τ → ℝ,
          (A j * gaussianMatrixSeries A x ^ k * A j *
            gaussianMatrixSeries A x ^ (n - 1 - k)).trace
          ∂(Measure.pi fun _ : τ => gaussianReal 0 1) := by
  have h := integral_mul_mvPolynomial_stdGaussian_real
    (constPolynomialMatrix (A j) * polynomialMatrixSeries A ^ n).trace j
  rw [pderiv_trace_const_mul_series_pow] at h
  simp only [map_sum, eval_trace_polynomialMatrix, map_mul, map_pow,
    eval_constPolynomialMatrix, eval_polynomialMatrixSeries] at h
  rw [h]
  exact integral_finsetSum _ (fun k _ =>
    integrable_trace_gaussianMatrixSeries_mixed A (A j) (A j) k (n - 1 - k))

/-- Exact Gaussian matrix moment recurrence, before using symmetry or bounds. -/
theorem integral_trace_gaussianMatrixSeries_pow_succ
    (A : τ → Matrix ι ι ℝ) (n : ℕ) :
    (∫ x : τ → ℝ, (gaussianMatrixSeries A x ^ (n + 1)).trace
      ∂(Measure.pi fun _ : τ => gaussianReal 0 1)) =
      ∑ j, ∑ k ∈ Finset.range n,
        ∫ x : τ → ℝ,
          (A j * gaussianMatrixSeries A x ^ k * A j *
            gaussianMatrixSeries A x ^ (n - 1 - k)).trace
          ∂(Measure.pi fun _ : τ => gaussianReal 0 1) := by
  have hpoint (x : τ → ℝ) : (gaussianMatrixSeries A x ^ (n + 1)).trace =
      ∑ j, x j * (A j * gaussianMatrixSeries A x ^ n).trace := by
    rw [pow_succ']
    conv_lhs => arg 1; lhs; unfold gaussianMatrixSeries
    rw [Matrix.sum_mul, Matrix.trace_sum]
    apply Finset.sum_congr rfl
    intro j hj
    rw [Matrix.smul_mul, Matrix.trace_smul, smul_eq_mul]
  simp_rw [hpoint]
  have hint (j : τ) : Integrable (fun x : τ → ℝ =>
      x j * (A j * gaussianMatrixSeries A x ^ n).trace)
      (Measure.pi fun _ : τ => gaussianReal 0 1) := by
    have h := integrable_mvPolynomial_stdGaussian_real
      (MvPolynomial.X j * (constPolynomialMatrix (A j) * polynomialMatrixSeries A ^ n).trace)
    simpa only [map_mul, MvPolynomial.eval_X, eval_trace_polynomialMatrix,
      map_pow, eval_constPolynomialMatrix, eval_polynomialMatrixSeries] using h
  rw [integral_finsetSum _ (fun j _ => hint j)]
  apply Finset.sum_congr rfl
  intro j hj
  exact integral_coordinate_mul_trace_gaussianMatrixSeries_pow A j n

omit [DecidableEq τ] [Fintype ι] [DecidableEq ι] in
theorem isHermitian_gaussianMatrixSeries (A : τ → Matrix ι ι ℝ)
    (hA : ∀ j, (A j).IsHermitian) (x : τ → ℝ) :
    (gaussianMatrixSeries A x).IsHermitian := by
  unfold Matrix.IsHermitian gaussianMatrixSeries
  simp only [Matrix.conjTranspose_sum, Matrix.conjTranspose_smul,
    star_trivial, (hA _).eq]

/-- The genuine matrix-moment recurrence, with its dimension-free variance
factor, derived from the exact integration-by-parts identity. -/
theorem integral_trace_gaussianMatrixSeries_even_recurrence
    (A : τ → Matrix ι ι ℝ) (hA : ∀ j, (A j).IsHermitian) (v : ℝ)
    (hvar : (v • (1 : Matrix ι ι ℝ) - ∑ j, A j ^ 2).PosSemidef) (p : ℕ) :
    (∫ x : τ → ℝ, (gaussianMatrixSeries A x ^ (2 * (p + 1))).trace
      ∂(Measure.pi fun _ : τ => gaussianReal 0 1)) ≤
      (2 * (p : ℝ) + 1) * v *
        ∫ x : τ → ℝ, (gaussianMatrixSeries A x ^ (2 * p)).trace
          ∂(Measure.pi fun _ : τ => gaussianReal 0 1) := by
  have hexp : 2 * (p + 1) = (2 * p + 1) + 1 := by omega
  rw [hexp, integral_trace_gaussianMatrixSeries_pow_succ, Finset.sum_comm]
  have hterm (k : ℕ) (hk : k ∈ Finset.range (2 * p + 1)) :
      (∑ j, ∫ x : τ → ℝ,
        (A j * gaussianMatrixSeries A x ^ k * A j *
          gaussianMatrixSeries A x ^ (2 * p + 1 - 1 - k)).trace
        ∂(Measure.pi fun _ : τ => gaussianReal 0 1)) ≤
        v * ∫ x : τ → ℝ, (gaussianMatrixSeries A x ^ (2 * p)).trace
          ∂(Measure.pi fun _ : τ => gaussianReal 0 1) := by
    have hint (j : τ) := integrable_trace_gaussianMatrixSeries_mixed A (A j) (A j)
      k (2 * p + 1 - 1 - k)
    rw [← integral_finsetSum _ (fun j _ => hint j), ← integral_const_mul]
    apply integral_mono (integrable_finsetSum _ (fun j _ => hint j))
      ((integrable_trace_gaussianMatrixSeries_pow A (2 * p)).const_mul v)
    intro x
    calc
      _ ≤ ∑ j, |(A j * gaussianMatrixSeries A x ^ k * A j *
          gaussianMatrixSeries A x ^ (2 * p + 1 - 1 - k)).trace| :=
        Finset.sum_le_sum (fun j _ => le_abs_self _)
      _ ≤ _ := sum_abs_trace_mixed_powers_le A hA _ (isHermitian_gaussianMatrixSeries A hA x)
        v hvar k (2 * p + 1 - 1 - k) p (by have := Finset.mem_range.mp hk; omega)
  calc
    _ ≤ ∑ k ∈ Finset.range (2 * p + 1),
        v * ∫ x : τ → ℝ, (gaussianMatrixSeries A x ^ (2 * p)).trace
          ∂(Measure.pi fun _ : τ => gaussianReal 0 1) := Finset.sum_le_sum hterm
    _ = _ := by simp only [Finset.sum_const, Finset.card_range, nsmul_eq_mul,
      Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat, Nat.cast_one]; ring

/-- Matrix Gaussian trace moments, with the exact odd-factor product. -/
theorem integral_trace_gaussianMatrixSeries_even_bound
    (A : τ → Matrix ι ι ℝ) (hA : ∀ j, (A j).IsHermitian) (v : ℝ) (hv : 0 ≤ v)
    (hvar : (v • (1 : Matrix ι ι ℝ) - ∑ j, A j ^ 2).PosSemidef) (p : ℕ) :
    (∫ x : τ → ℝ, (gaussianMatrixSeries A x ^ (2 * p)).trace
      ∂(Measure.pi fun _ : τ => gaussianReal 0 1)) ≤
      (Fintype.card ι : ℝ) * (∏ k ∈ Finset.range p, (2 * (k : ℝ) + 1)) * v ^ p := by
  induction p with
  | zero => simp [Matrix.trace_one]
  | succ p ih =>
    calc
      _ ≤ (2 * (p : ℝ) + 1) * v *
          ∫ x : τ → ℝ, (gaussianMatrixSeries A x ^ (2 * p)).trace
            ∂(Measure.pi fun _ : τ => gaussianReal 0 1) :=
        integral_trace_gaussianMatrixSeries_even_recurrence A hA v hvar p
      _ ≤ (2 * (p : ℝ) + 1) * v *
          ((Fintype.card ι : ℝ) * (∏ k ∈ Finset.range p, (2 * (k : ℝ) + 1)) * v ^ p) :=
        mul_le_mul_of_nonneg_left ih (by positivity)
      _ = _ := by rw [Finset.prod_range_succ, pow_succ]; ring

/-- The odd-factor product is at most (2p)^p. -/
theorem odd_factor_prod_le (p : ℕ) :
    (∏ k ∈ Finset.range p, (2 * (k : ℝ) + 1)) ≤ (2 * (p : ℝ)) ^ p := by
  calc
    _ ≤ ∏ _k ∈ Finset.range p, (2 * (p : ℝ)) := by
      apply Finset.prod_le_prod
      · intro k hk; positivity
      · intro k hk
        have hkp : k + 1 ≤ p := Nat.succ_le_iff.2 (Finset.mem_range.mp hk)
        have hreal : (k : ℝ) + 1 ≤ (p : ℝ) := by exact_mod_cast hkp
        linarith
    _ = _ := by simp

/-- A convenient numerical form of the Gaussian matrix moment estimate. -/
theorem integral_trace_gaussianMatrixSeries_even_bound_simple
    (A : τ → Matrix ι ι ℝ) (hA : ∀ j, (A j).IsHermitian) (v : ℝ) (hv : 0 ≤ v)
    (hvar : (v • (1 : Matrix ι ι ℝ) - ∑ j, A j ^ 2).PosSemidef) (p : ℕ) :
    (∫ x : τ → ℝ, (gaussianMatrixSeries A x ^ (2 * p)).trace
      ∂(Measure.pi fun _ : τ => gaussianReal 0 1)) ≤
      (Fintype.card ι : ℝ) * (2 * (p : ℝ) * v) ^ p := by
  calc
    _ ≤ (Fintype.card ι : ℝ) * (∏ k ∈ Finset.range p, (2 * (k : ℝ) + 1)) * v ^ p :=
      integral_trace_gaussianMatrixSeries_even_bound A hA v hv hvar p
    _ ≤ (Fintype.card ι : ℝ) * (2 * (p : ℝ)) ^ p * v ^ p := by
      gcongr
      exact odd_factor_prod_le p
    _ = _ := by rw [mul_pow]; ring

/-- Matrix trace moments in terms of the usual variance-operator norm. -/
theorem integral_trace_gaussianMatrixSeries_even_bound_operator_norm
    (A : τ → Matrix ι ι ℝ) (hA : ∀ j, (A j).IsHermitian) (p : ℕ) :
    (∫ x : τ → ℝ, (gaussianMatrixSeries A x ^ (2 * p)).trace
      ∂(Measure.pi fun _ : τ => gaussianReal 0 1)) ≤
      (Fintype.card ι : ℝ) *
        (2 * (p : ℝ) * ‖(Matrix.toEuclideanLin (∑ j, A j ^ 2)).toContinuousLinearMap‖) ^ p := by
  have hS : (∑ j, A j ^ 2).IsHermitian := by
    unfold Matrix.IsHermitian
    simp only [Matrix.conjTranspose_sum, ((hA _).pow 2).eq]
  exact integral_trace_gaussianMatrixSeries_even_bound_simple A hA _ (norm_nonneg _)
    (posSemidef_scalar_sub_of_operator_norm _ hS _ le_rfl) p

end Paulsen
