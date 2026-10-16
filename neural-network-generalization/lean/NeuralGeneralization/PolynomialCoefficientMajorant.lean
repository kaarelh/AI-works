import Mathlib.Algebra.Polynomial.Eval.Defs
import Mathlib.Algebra.Polynomial.Coeff
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum

/-! Positive coefficient majorants give coefficient bounds by evaluation
on the positive real axis; no complex-analytic coefficient estimate is used. -/

noncomputable section
namespace NeuralGeneralization.PolynomialMajorant
open Polynomial
open scoped BigOperators

def AbsCoeffLe (P Q : ℝ[X]) : Prop := ∀ j, |P.coeff j| ≤ Q.coeff j

theorem AbsCoeffLe.nonneg {P Q : ℝ[X]} (h : AbsCoeffLe P Q) (j : ℕ) : 0 ≤ Q.coeff j :=
  (abs_nonneg _).trans (h j)

theorem AbsCoeffLe.mul {P Q R S : ℝ[X]} (hP : AbsCoeffLe P Q) (hR : AbsCoeffLe R S) :
    AbsCoeffLe (P*R) (Q*S) := by
  intro j
  rw [coeff_mul, coeff_mul]
  apply (Finset.abs_sum_le_sum_abs _ _).trans
  apply Finset.sum_le_sum
  intro ij hij
  rw [abs_mul]
  exact mul_le_mul (hP ij.1) (hR ij.2) (abs_nonneg _) (hP.nonneg _)

theorem AbsCoeffLe.pow {P Q : ℝ[X]} (h : AbsCoeffLe P Q) (n : ℕ) : AbsCoeffLe (P^n) (Q^n) := by
  induction n with
  | zero => intro j; simp only [pow_zero, coeff_one]; split_ifs <;> norm_num
  | succ n ih => simpa only [pow_succ] using ih.mul h

theorem sub_pow_majorant (k : ℕ) : AbsCoeffLe (1-X^k : ℝ[X]) (1+X^k) := by
  intro j
  simp only [coeff_sub, coeff_add, coeff_one, coeff_X_pow]
  split_ifs <;> norm_num

theorem add_pow_majorant (k : ℕ) : AbsCoeffLe (1+X^k : ℝ[X]) (1+X^k) := by
  intro j
  simp only [coeff_add, coeff_one, coeff_X_pow]
  split_ifs <;> norm_num

theorem coeff_mul_pow_le_eval (P : ℝ[X]) (hP : ∀ j, 0 ≤ P.coeff j) (t : ℝ) (ht : 0 ≤ t) (j : ℕ) :
    P.coeff j*t^j ≤ P.eval t := by
  rw [eval_eq_sum, sum]
  by_cases hj : j ∈ P.support
  · exact Finset.single_le_sum (fun k _ => mul_nonneg (hP k) (pow_nonneg ht k)) hj
  · have hz : P.coeff j=0 := notMem_support_iff.mp hj
    rw [hz, zero_mul]
    exact Finset.sum_nonneg (fun k _ => mul_nonneg (hP k) (pow_nonneg ht k))

theorem AbsCoeffLe.coeff_mul_pow_le_eval {P Q : ℝ[X]} (h : AbsCoeffLe P Q)
    (t : ℝ) (ht : 0 ≤ t) (j : ℕ) : |P.coeff j| *t^j ≤ Q.eval t :=
  (mul_le_mul_of_nonneg_right (h j) (pow_nonneg ht j)).trans
    (PolynomialMajorant.coeff_mul_pow_le_eval Q h.nonneg t ht j)

def pairedPolynomial (b r s : ℕ) : ℝ[X] := (1-X^2)^b*(1-X)^r*(1+X)^s

theorem paired_polynomial_bound (b r s j : ℕ) (t : ℝ) (ht : 0 ≤ t) :
    |(pairedPolynomial b r s).coeff j| *t^j ≤ (1+t^2)^b*(1+t)^(r+s) := by
  have hlin : AbsCoeffLe (1-X : ℝ[X]) (1+X) := by simpa using sub_pow_majorant 1
  have hplus : AbsCoeffLe (1+X : ℝ[X]) (1+X) := by simpa using add_pow_majorant 1
  have h := (((sub_pow_majorant 2).pow b).mul (hlin.pow r)).mul (hplus.pow s)
  have he := h.coeff_mul_pow_le_eval t ht j
  simpa only [pairedPolynomial, eval_mul, eval_pow, eval_add, eval_one, eval_X, pow_add,
    mul_assoc] using he

end NeuralGeneralization.PolynomialMajorant
