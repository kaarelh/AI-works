import NeuralGeneralization.KernelEnergy
import Mathlib.RingTheory.Binomial
import Mathlib.Data.Nat.Choose.Central

/-! Exact positive coefficients of the arcsine derivative and antiderivative. -/

noncomputable section

namespace NeuralGeneralization

/-- The coefficient of `x^(2n)` in `(1-x^2)^(-1/2)`. -/
def arcsineDerivativeCoefficient (n : ℕ) : ℝ := Ring.multichoose (1 / 2 : ℝ) n

/-- The coefficient of `x^(2n+1)` in `Real.arcsin x`. -/
def arcsineCoefficient (n : ℕ) : ℝ := arcsineDerivativeCoefficient n / (2 * n + 1 : ℝ)

theorem arcsineDerivativeCoefficient_pos (n : ℕ) : 0 < arcsineDerivativeCoefficient n := by
  have h := Ring.factorial_nsmul_multichoose_eq_ascPochhammer (1 / 2 : ℝ) n
  rw [Polynomial.ascPochhammer_smeval_eq_eval, nsmul_eq_mul] at h
  have hp := ascPochhammer_pos n (1 / 2 : ℝ) (by norm_num)
  rw [← h] at hp
  unfold arcsineDerivativeCoefficient
  exact pos_of_mul_pos_right hp (Nat.cast_nonneg _)

theorem arcsineCoefficient_pos (n : ℕ) : 0 < arcsineCoefficient n := by
  unfold arcsineCoefficient
  exact div_pos (arcsineDerivativeCoefficient_pos n) (by positivity)

theorem arcsineDerivativeCoefficient_recurrence (n : ℕ) :
    (n + 1 : ℝ) * arcsineDerivativeCoefficient (n + 1) =
      (n + 1 / 2 : ℝ) * arcsineDerivativeCoefficient n := by
  have heq (m : ℕ) : (m.factorial : ℝ) * arcsineDerivativeCoefficient m =
      (ascPochhammer ℝ m).eval (1 / 2 : ℝ) := by
    simpa only [arcsineDerivativeCoefficient, nsmul_eq_mul,
      Polynomial.ascPochhammer_smeval_eq_eval] using
      Ring.factorial_nsmul_multichoose_eq_ascPochhammer (1 / 2 : ℝ) m
  apply mul_left_cancel₀ (show (n.factorial : ℝ) ≠ 0 by exact_mod_cast Nat.factorial_ne_zero n)
  calc
    (n.factorial : ℝ) * ((n + 1 : ℝ) * arcsineDerivativeCoefficient (n + 1)) =
        ((n + 1).factorial : ℝ) * arcsineDerivativeCoefficient (n + 1) := by
      rw [Nat.factorial_succ, Nat.cast_mul, Nat.cast_add, Nat.cast_one]
      ring
    _ = (ascPochhammer ℝ (n + 1)).eval (1 / 2 : ℝ) := heq _
    _ = (ascPochhammer ℝ n).eval (1 / 2 : ℝ) * (1 / 2 + n : ℝ) := by
      rw [ascPochhammer_succ_right, Polynomial.eval_mul, Polynomial.eval_add,
        Polynomial.eval_X, Polynomial.eval_natCast]
    _ = (n.factorial : ℝ) * ((n + 1 / 2 : ℝ) * arcsineDerivativeCoefficient n) := by
      rw [← heq]
      ring

/-- The familiar exact central-binomial coefficient formula. -/
theorem arcsineDerivativeCoefficient_eq_centralBinom (n : ℕ) :
    arcsineDerivativeCoefficient n = (Nat.centralBinom n : ℝ) / 4 ^ n := by
  induction n with
  | zero => simp [arcsineDerivativeCoefficient]
  | succ n ih =>
    have hfour : (4 : ℝ) ^ n ≠ 0 := pow_ne_zero n (by norm_num)
    have hrec : (n + 1 : ℝ) * (Nat.centralBinom (n + 1) : ℝ) =
        2 * (2 * n + 1 : ℝ) * Nat.centralBinom n := by
      exact_mod_cast Nat.succ_mul_centralBinom_succ n
    apply (eq_div_iff (pow_ne_zero (n + 1) (by norm_num : (4 : ℝ) ≠ 0))).mpr
    apply mul_left_cancel₀ (show (n + 1 : ℝ) ≠ 0 by positivity)
    calc
      (n + 1 : ℝ) * (arcsineDerivativeCoefficient (n + 1) * (4 : ℝ) ^ (n + 1)) =
          ((n + 1 : ℝ) * arcsineDerivativeCoefficient (n + 1)) * (4 ^ n * 4) := by
        rw [pow_succ]
        ring
      _ = ((n + 1 / 2 : ℝ) * (Nat.centralBinom n / (4 : ℝ) ^ n)) * (4 ^ n * 4) := by
        rw [arcsineDerivativeCoefficient_recurrence, ih]
      _ = (n + 1 : ℝ) * Nat.centralBinom (n + 1) := by
        rw [hrec]
        field_simp [hfour]
        ring

theorem arcsineCoefficient_eq_centralBinom (n : ℕ) :
    arcsineCoefficient n = (Nat.centralBinom n : ℝ) / ((4 : ℝ) ^ n * (2 * n + 1 : ℝ)) := by
  rw [arcsineCoefficient, arcsineDerivativeCoefficient_eq_centralBinom, div_div]

theorem arcsineDerivativeCoefficient_square_recurrence (n : ℕ) :
    (n + 1 : ℝ) ^ 2 * arcsineDerivativeCoefficient (n + 1) ^ 2 =
      (n + 1 / 2 : ℝ) ^ 2 * arcsineDerivativeCoefficient n ^ 2 := by
  have h := congrArg (fun t : ℝ => t ^ 2) (arcsineDerivativeCoefficient_recurrence n)
  nlinarith only [h]

/-- Elementary upper Wallis bound, proved solely from the recurrence. -/
theorem arcsineDerivativeCoefficient_square_upper (n : ℕ) :
    (3 * n + 1 : ℝ) * arcsineDerivativeCoefficient n ^ 2 ≤ 1 := by
  induction n with
  | zero => simp [arcsineDerivativeCoefficient]
  | succ n ih =>
    have hN : 0 < (n + 1 : ℝ) ^ 2 := by positivity
    have hf : (3 * (n + 1) + 1 : ℝ) * (n + 1 / 2 : ℝ) ^ 2 ≤
        (n + 1 : ℝ) ^ 2 * (3 * n + 1 : ℝ) := by
      nlinarith [show (0 : ℝ) ≤ n from Nat.cast_nonneg n]
    apply (mul_le_mul_iff_right₀ hN).mp
    simp only [Nat.cast_add, Nat.cast_one]
    calc
      (n + 1 : ℝ) ^ 2 * ((3 * (n + 1) + 1 : ℝ) * arcsineDerivativeCoefficient (n + 1) ^ 2) =
          (3 * (n + 1) + 1 : ℝ) *
            ((n + 1 : ℝ) ^ 2 * arcsineDerivativeCoefficient (n + 1) ^ 2) := by ring
      _ = ((3 * (n + 1) + 1 : ℝ) * (n + 1 / 2 : ℝ) ^ 2) *
          arcsineDerivativeCoefficient n ^ 2 := by
        rw [arcsineDerivativeCoefficient_square_recurrence]
        ring
      _ ≤ ((n + 1 : ℝ) ^ 2 * (3 * n + 1 : ℝ)) * arcsineDerivativeCoefficient n ^ 2 :=
        mul_le_mul_of_nonneg_right hf (sq_nonneg _)
      _ = (n + 1 : ℝ) ^ 2 * ((3 * n + 1 : ℝ) * arcsineDerivativeCoefficient n ^ 2) := by ring
      _ ≤ (n + 1 : ℝ) ^ 2 * 1 := mul_le_mul_of_nonneg_left ih hN.le

/-- Elementary lower Wallis bound, with the first nonzero index as base. -/
theorem arcsineDerivativeCoefficient_square_lower (n : ℕ) :
    1 ≤ (4 * (n + 1) : ℝ) * arcsineDerivativeCoefficient (n + 1) ^ 2 := by
  induction n with
  | zero => norm_num [arcsineDerivativeCoefficient, Ring.multichoose_one_right]
  | succ n ih =>
    have hN : 0 < (n + 1 + 1 : ℝ) ^ 2 := by positivity
    have hf : (n + 1 + 1 : ℝ) ^ 2 * (4 * (n + 1) : ℝ) ≤
        (4 * (n + 1 + 1) : ℝ) * (n + 1 + 1 / 2 : ℝ) ^ 2 := by
      nlinarith [show (0 : ℝ) ≤ n from Nat.cast_nonneg n]
    apply (mul_le_mul_iff_right₀ hN).mp
    simp only [Nat.cast_add, Nat.cast_one]
    calc
      (n + 1 + 1 : ℝ) ^ 2 * 1 ≤
          (n + 1 + 1 : ℝ) ^ 2 * ((4 * (n + 1) : ℝ) * arcsineDerivativeCoefficient (n + 1) ^ 2) :=
        mul_le_mul_of_nonneg_left ih hN.le
      _ = ((n + 1 + 1 : ℝ) ^ 2 * (4 * (n + 1) : ℝ)) *
          arcsineDerivativeCoefficient (n + 1) ^ 2 := by ring
      _ ≤ ((4 * (n + 1 + 1) : ℝ) * (n + 1 + 1 / 2 : ℝ) ^ 2) *
          arcsineDerivativeCoefficient (n + 1) ^ 2 := mul_le_mul_of_nonneg_right hf (sq_nonneg _)
      _ = (4 * (n + 1 + 1) : ℝ) *
          ((n + 1 + 1 : ℝ) ^ 2 * arcsineDerivativeCoefficient ((n + 1) + 1) ^ 2) := by
        have hr := arcsineDerivativeCoefficient_square_recurrence (n + 1)
        simp only [Nat.cast_add, Nat.cast_one] at hr
        rw [hr]
        ring
      _ = (n + 1 + 1 : ℝ) ^ 2 *
          ((4 * (n + 1 + 1) : ℝ) * arcsineDerivativeCoefficient ((n + 1) + 1) ^ 2) := by ring

/-- Sharp order `n^(-3/2)` for the actual first-layer power coefficients,
expressed without square roots or asymptotic notation. -/
theorem arcsineCoefficient_cubic_square_bounds (n : ℕ) :
    (1 / 2 : ℝ) ≤ (2 * n + 1 : ℝ) ^ 3 * arcsineCoefficient n ^ 2 ∧
      (2 * n + 1 : ℝ) ^ 3 * arcsineCoefficient n ^ 2 ≤ 1 := by
  have hidentity : (2 * n + 1 : ℝ) ^ 3 * arcsineCoefficient n ^ 2 =
      (2 * n + 1 : ℝ) * arcsineDerivativeCoefficient n ^ 2 := by
    unfold arcsineCoefficient
    field_simp
  rw [hidentity]
  constructor
  · cases n with
    | zero => norm_num [arcsineDerivativeCoefficient]
    | succ n =>
      have h := arcsineDerivativeCoefficient_square_lower n
      have hsq := sq_nonneg (arcsineDerivativeCoefficient (n + 1))
      simp only [Nat.cast_add, Nat.cast_one]
      nlinarith
  · have h := arcsineDerivativeCoefficient_square_upper n
    have hsq := sq_nonneg (arcsineDerivativeCoefficient n)
    have hn : 0 ≤ (n : ℝ) * arcsineDerivativeCoefficient n ^ 2 :=
      mul_nonneg (Nat.cast_nonneg n) hsq
    linarith

end NeuralGeneralization
