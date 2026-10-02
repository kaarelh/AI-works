import Paulsen.GaussianFourthMoment
import Mathlib.Analysis.Calculus.IteratedDeriv.Lemmas
import Mathlib.Analysis.Calculus.Deriv.Polynomial

/-!
# Gaussian integration by parts for polynomials

For polynomials, the identity follows directly from the scalar Gaussian MGF.
This avoids improper-integral boundary arguments and suffices for matrix moments.
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory NNReal

noncomputable section

namespace Paulsen

/-- The Gaussian MGF satisfies the first-order differential equation f′=t f. -/
theorem deriv_stdGaussian_mgf :
    deriv (fun t : ℝ => Real.exp (t ^ 2 / 2)) =
      fun t => t * Real.exp (t ^ 2 / 2) := by
  funext t
  have h := (((hasDerivAt_id' t).pow 2).div_const 2).exp
  convert! h.deriv using 1
  simp only [Pi.pow_apply]
  ring

/-- Differentiating t f(t) at zero keeps exactly one Leibniz term. -/
theorem iteratedDeriv_mul_id_zero (f : ℝ → ℝ) (n : ℕ)
    (hf : ContDiffAt ℝ n f 0) :
    iteratedDeriv n (fun t => t * f t) 0 =
      (n : ℝ) * iteratedDeriv (n - 1) f 0 := by
  rw [iteratedDeriv_fun_mul
    (show ContDiffAt ℝ n (fun t : ℝ => t) 0 by fun_prop) hf]
  simp only [iteratedDeriv_fun_id_zero, mul_ite, mul_one, mul_zero,
    ite_mul, zero_mul]
  by_cases hn : n = 0
  · simp [hn]
  · simp [Finset.sum_ite_eq', hn]

/-- The complete standard Gaussian moment recurrence, including the zero first
moment. This is the monomial integration-by-parts identity. -/
theorem integral_pow_succ_stdGaussian_real (n : ℕ) :
    (∫ x : ℝ, x ^ (n + 1) ∂gaussianReal 0 1) =
      (n : ℝ) * ∫ x : ℝ, x ^ (n - 1) ∂gaussianReal 0 1 := by
  have hmoment (m : ℕ) := iteratedDeriv_mgf_zero
    (X := id) (μ := gaussianReal 0 1) (by simp) m
  have hmgf : mgf id (gaussianReal 0 1) = fun t : ℝ => Real.exp (t ^ 2 / 2) := by
    simp [mgf_id_gaussianReal]
  simp only [hmgf, Pi.pow_apply, id_eq] at hmoment
  rw [← hmoment (n + 1), ← hmoment (n - 1), iteratedDeriv_succ', deriv_stdGaussian_mgf]
  exact iteratedDeriv_mul_id_zero _ n (by fun_prop)

/-- Every real polynomial is integrable under the standard Gaussian. -/
theorem integrable_polynomial_stdGaussian_real (p : Polynomial ℝ) :
    Integrable (fun x : ℝ => p.eval x) (gaussianReal 0 1) := by
  induction p using Polynomial.induction_on' with
  | add p q hp hq => simpa only [Polynomial.eval_add, Pi.add_apply] using! hp.add hq
  | monomial n a =>
    have hn := integrable_pow_of_mem_interior_integrableExpSet
      (X := id) (μ := gaussianReal 0 1) (by simp) n
    simpa only [Polynomial.eval_monomial, id_eq] using hn.const_mul a

/-- Gaussian integration by parts for polynomials, proved from the moment
recurrence rather than improper integration. -/
theorem integral_mul_polynomial_stdGaussian_real (p : Polynomial ℝ) :
    (∫ x : ℝ, x * p.eval x ∂gaussianReal 0 1) =
      ∫ x : ℝ, p.derivative.eval x ∂gaussianReal 0 1 := by
  induction p using Polynomial.induction_on' with
  | add p q hp hq =>
    have hip : Integrable (fun x : ℝ => x * p.eval x) (gaussianReal 0 1) := by
      convert! integrable_polynomial_stdGaussian_real (Polynomial.X * p) using 1
      ext x
      simp
    have hiq : Integrable (fun x : ℝ => x * q.eval x) (gaussianReal 0 1) := by
      convert! integrable_polynomial_stdGaussian_real (Polynomial.X * q) using 1
      ext x
      simp
    simp only [Polynomial.eval_add, mul_add, Polynomial.derivative_add]
    rw [integral_add hip hiq, integral_add
      (integrable_polynomial_stdGaussian_real p.derivative)
      (integrable_polynomial_stdGaussian_real q.derivative), hp, hq]
  | monomial n a =>
    simp only [Polynomial.eval_monomial, Polynomial.derivative_monomial]
    have hfun : (fun x : ℝ => x * (a * x ^ n)) = fun x => a * x ^ (n + 1) := by
      ext x
      rw [pow_succ]
      ring
    rw [hfun, integral_const_mul, integral_const_mul, integral_pow_succ_stdGaussian_real]
    ring

end Paulsen
