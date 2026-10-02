import Paulsen.GaussianMvPolynomial
import Mathlib.LinearAlgebra.Matrix.Trace

/-!
# Polynomial matrices for Gaussian matrix series
-/

open scoped BigOperators

noncomputable section

namespace Paulsen

variable {τ ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Entrywise partial differentiation of a polynomial matrix. -/
def matrixPDeriv (j : τ) :
    Matrix ι ι (MvPolynomial τ ℝ) →ₗ[ℝ] Matrix ι ι (MvPolynomial τ ℝ) :=
  (MvPolynomial.pderiv j).toLinearMap.mapMatrix

omit [Fintype ι] [DecidableEq ι] in
@[simp]
theorem matrixPDeriv_apply (j : τ) (P : Matrix ι ι (MvPolynomial τ ℝ)) (i k : ι) :
    matrixPDeriv j P i k = MvPolynomial.pderiv j (P i k) := rfl

omit [DecidableEq ι] in
theorem matrixPDeriv_mul (j : τ) (P Q : Matrix ι ι (MvPolynomial τ ℝ)) :
    matrixPDeriv j (P * Q) = matrixPDeriv j P * Q + P * matrixPDeriv j Q := by
  ext i k
  simp only [matrixPDeriv_apply, Matrix.mul_apply, map_sum,
    MvPolynomial.pderiv_mul, Matrix.add_apply, Finset.sum_add_distrib]

omit [Fintype ι] in
@[simp]
theorem matrixPDeriv_one (j : τ) :
    matrixPDeriv j (1 : Matrix ι ι (MvPolynomial τ ℝ)) = 0 := by
  ext i k
  by_cases hik : i = k <;> simp [hik]

/-- The noncommutative Leibniz expansion, proved algebraically. -/
theorem matrixPDeriv_pow (j : τ) (P : Matrix ι ι (MvPolynomial τ ℝ)) (n : ℕ) :
    matrixPDeriv j (P ^ n) =
      ∑ k ∈ Finset.range n, P ^ k * matrixPDeriv j P * P ^ (n - 1 - k) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [pow_succ', matrixPDeriv_mul, ih, Matrix.mul_sum, Finset.sum_range_succ']
    simp only [pow_zero, Matrix.one_mul, Nat.add_sub_cancel, Nat.sub_zero]
    rw [add_comm]
    congr 1
    apply Finset.sum_congr rfl
    intro k hk
    rw [pow_succ']
    simp only [Matrix.mul_assoc, Nat.sub_sub, Nat.add_comm]

omit [DecidableEq ι] in
theorem pderiv_trace (j : τ) (P : Matrix ι ι (MvPolynomial τ ℝ)) :
    MvPolynomial.pderiv j P.trace = (matrixPDeriv j P).trace := by
  simp only [Matrix.trace, Matrix.diag_apply, map_sum, matrixPDeriv_apply]

def constPolynomialMatrix (A : Matrix ι ι ℝ) : Matrix ι ι (MvPolynomial τ ℝ) :=
  A.map MvPolynomial.C

omit [Fintype ι] [DecidableEq ι] in
@[simp]
theorem matrixPDeriv_const (j : τ) (A : Matrix ι ι ℝ) :
    matrixPDeriv j (constPolynomialMatrix A) = 0 := by
  ext i k
  simp [constPolynomialMatrix]

variable [Fintype τ] [DecidableEq τ]

def polynomialMatrixSeries (A : τ → Matrix ι ι ℝ) : Matrix ι ι (MvPolynomial τ ℝ) :=
  fun i k => ∑ j, MvPolynomial.C (A j i k) * MvPolynomial.X j

def gaussianMatrixSeries (A : τ → Matrix ι ι ℝ) (x : τ → ℝ) : Matrix ι ι ℝ :=
  ∑ j, x j • A j

omit [Fintype τ] [DecidableEq τ] in
@[simp]
theorem eval_constPolynomialMatrix (A : Matrix ι ι ℝ) (x : τ → ℝ) :
    (MvPolynomial.eval x).mapMatrix (constPolynomialMatrix A) = A := by
  ext i k
  simp [constPolynomialMatrix]

omit [DecidableEq τ] in
@[simp]
theorem eval_polynomialMatrixSeries (A : τ → Matrix ι ι ℝ) (x : τ → ℝ) :
    (MvPolynomial.eval x).mapMatrix (polynomialMatrixSeries A) = gaussianMatrixSeries A x := by
  ext i k
  simp [polynomialMatrixSeries, gaussianMatrixSeries, Matrix.sum_apply, mul_comm]

omit [Fintype ι] [DecidableEq ι] in
@[simp]
theorem matrixPDeriv_series (A : τ → Matrix ι ι ℝ) (j : τ) :
    matrixPDeriv j (polynomialMatrixSeries A) = constPolynomialMatrix (A j) := by
  ext i k
  simp [polynomialMatrixSeries, constPolynomialMatrix, MvPolynomial.pderiv_X, Pi.single_apply]

/-- Partial differentiation of the trace polynomial yields precisely the
noncommutative expression needed in the moment recurrence. -/
theorem pderiv_trace_const_mul_series_pow (A : τ → Matrix ι ι ℝ) (j : τ) (n : ℕ) :
    MvPolynomial.pderiv j
      (constPolynomialMatrix (A j) * polynomialMatrixSeries A ^ n).trace =
      ∑ k ∈ Finset.range n,
        (constPolynomialMatrix (A j) * polynomialMatrixSeries A ^ k *
          constPolynomialMatrix (A j) * polynomialMatrixSeries A ^ (n - 1 - k)).trace := by
  rw [pderiv_trace, matrixPDeriv_mul, matrixPDeriv_const, Matrix.zero_mul, zero_add,
    matrixPDeriv_pow, matrixPDeriv_series, Matrix.mul_sum, Matrix.trace_sum]
  apply Finset.sum_congr rfl
  intro k hk
  simp only [Matrix.mul_assoc]

omit [Fintype τ] [DecidableEq τ] in
/-- Evaluation commutes with matrix trace. -/
theorem eval_trace_polynomialMatrix (x : τ → ℝ) (P : Matrix ι ι (MvPolynomial τ ℝ)) :
    MvPolynomial.eval x P.trace = ((MvPolynomial.eval x).mapMatrix P).trace :=
  AddMonoidHom.map_trace _ _

end Paulsen
