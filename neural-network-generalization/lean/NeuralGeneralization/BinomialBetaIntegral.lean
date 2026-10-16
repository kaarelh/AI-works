import Mathlib.Analysis.SpecialFunctions.Integrals.Basic
import Mathlib.Data.Nat.Choose.Basic

/-! # The elementary integer beta integral for localized bump coefficients -/
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization

theorem integral_pow_mul_one_sub_pow (m n : ℕ) :
    (∫ x in (0:ℝ)..1, x^m*(1-x)^n) =
      (m.factorial : ℝ)*n.factorial/(m+n+1).factorial := by
  induction n generalizing m with
  | zero =>
    simp only [pow_zero, mul_one, Nat.factorial_zero, Nat.cast_one, mul_one, Nat.add_zero]
    rw [integral_pow]
    simp only [one_pow, zero_pow (Nat.succ_ne_zero _), sub_zero, Nat.factorial_succ,
      Nat.cast_mul, Nat.cast_add, Nat.cast_one]
    field_simp [show (m.factorial : ℝ) ≠ 0 by exact_mod_cast m.factorial_ne_zero]
  | succ n ih =>
    have hder (x : ℝ) : HasDerivAt (fun x : ℝ => x^(m+1)*(1-x)^(n+1))
        ((m+1)*x^m*(1-x)^(n+1)-(n+1)*x^(m+1)*(1-x)^n) x := by
      convert! ((hasDerivAt_pow (m+1) x).mul
        (((hasDerivAt_const x (1:ℝ)).sub (hasDerivAt_id x)).pow (n+1))) using 1 <;> norm_num <;> ring
    have hFTC := intervalIntegral.integral_eq_sub_of_hasDerivAt (a:=(0:ℝ)) (b:=1)
      (fun x _ => hder x)
      ((by fun_prop : Continuous (fun x : ℝ =>
        (m+1)*x^m*(1-x)^(n+1)-(n+1)*x^(m+1)*(1-x)^n)).intervalIntegrable _ _)
    rw [intervalIntegral.integral_sub
      ((by fun_prop : Continuous (fun x : ℝ => (m+1)*x^m*(1-x)^(n+1))).intervalIntegrable _ _)
      ((by fun_prop : Continuous (fun x : ℝ => (n+1)*x^(m+1)*(1-x)^n)).intervalIntegrable _ _)] at hFTC
    simp only [mul_assoc, intervalIntegral.integral_const_mul] at hFTC
    norm_num only [one_pow, sub_self, zero_pow (Nat.succ_ne_zero _), mul_zero,
      zero_pow (Nat.succ_ne_zero _), zero_mul, zero_sub, sub_zero, sub_self] at hFTC
    rw [ih (m+1)] at hFTC
    have hmp : (m+1:ℝ) ≠ 0 := by positivity
    have hfact : ((m+n+2).factorial : ℝ) ≠ 0 := by exact_mod_cast (m+n+2).factorial_ne_zero
    have hid : m+1+n+1 = m+n+2 := by omega
    rw [hid, Nat.factorial_succ, Nat.cast_mul, Nat.cast_add, Nat.cast_one] at hFTC
    change (∫ x in (0:ℝ)..1, x^m*(1-x)^(n+1)) = _
    rw [show m+(n+1)+1 = m+n+2 by omega, Nat.factorial_succ n, Nat.cast_mul,
      Nat.cast_add, Nat.cast_one]
    apply (mul_left_cancel₀ hmp)
    field_simp at hFTC ⊢
    nlinarith

/-- Every Bernstein basis polynomial has the same integral. -/
theorem binomial_beta_integral {d j : ℕ} (hj : j ≤ d) :
    (d.choose j : ℝ)*(∫ p in (0:ℝ)..1, p^j*(1-p)^(d-j)) = 1/(d+1:ℝ) := by
  rw [integral_pow_mul_one_sub_pow, Nat.add_sub_of_le hj]
  have hcomb : (d.choose j : ℝ)*j.factorial*(d-j).factorial = d.factorial := by
    exact_mod_cast Nat.choose_mul_factorial_mul_factorial hj
  rw [← mul_div_assoc, ← mul_assoc, hcomb, Nat.factorial_succ,
    Nat.cast_mul, Nat.cast_add, Nat.cast_one]
  field_simp [show (d.factorial : ℝ) ≠ 0 by exact_mod_cast d.factorial_ne_zero]

end NeuralGeneralization
