import Mathlib.Data.Nat.Log
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-! Explicit polynomial resource and depth-padding bounds for circuit families.
The cutoff is deliberately loose and is independent of the actual teacher
chosen at an input dimension. No asymptotic estimate is assumed. -/

namespace ConditionalNonpolynomial.FamilyResources

/-- Integer sample budgets remain polynomial in the original input dimension. -/
theorem resource_bound (d C r A₀ k D e : ℕ)
    (hS : d + C + (r + 2) + 1 ≤ D * (d + 2)^e) :
    d + (A₀ * (d + C + (r + 2) + 1)^k) + (r + 2) + 2 ≤
      ((A₀ + 2) * (D + 1)^(k + 1)) * (d + 2)^(e * (k + 1)) := by
  let S := d + C + (r + 2) + 1
  have hSpos : 1 ≤ S + 1 := by omega
  have hpower : S^k ≤ (S + 1)^(k + 1) := by
    exact (Nat.pow_le_pow_left (by omega : S ≤ S+1) k).trans
      (Nat.pow_le_pow_right (by omega) (by omega))
  have hlin : S + 1 ≤ (S + 1)^(k + 1) := by
    simpa only [pow_one] using
      (Nat.pow_le_pow_right (by omega : 0 < S+1) (by omega : 1 ≤ k+1))
  have hsum : d + A₀ * S^k + (r + 2) + 2 ≤ (A₀ + 2) * (S + 1)^(k + 1) := by
    have hmul := Nat.mul_le_mul_left A₀ hpower
    dsimp [S] at *
    nlinarith
  have hq : 1 ≤ (d + 2)^e := Nat.one_le_pow e (d + 2) (by omega)
  have hSp : S + 1 ≤ (D + 1) * (d + 2)^e := by
    dsimp [S]
    nlinarith
  calc
    _ = d + A₀ * S^k + (r + 2) + 2 := rfl
    _ ≤ (A₀ + 2) * (S + 1)^(k + 1) := hsum
    _ ≤ (A₀ + 2) * ((D + 1) * (d + 2)^e)^(k + 1) :=
      Nat.mul_le_mul_left _ (Nat.pow_le_pow_left hSp _)
    _ = _ := by rw [Nat.mul_pow, ← Nat.pow_mul]; ring

/-- A global logarithmic bound, including zero resource coefficients. -/
theorem polynomial_log2_bound (B m d R : ℕ)
    (hR : R ≤ B * (d + 2)^m) :
    Nat.log2 R ≤ (Nat.log2 B + 1 + 2*m) * Nat.log2 (d + 2) := by
  by_cases hzero : R = 0
  · simp [hzero]
  have hq : 0 < (d + 2)^m := Nat.pow_pos (by omega)
  have hB := Nat.lt_log2_self (n := B)
  have hbase : d + 2 ≤ 2^(Nat.log2 (d + 2)+1) := Nat.le_of_lt Nat.lt_log2_self
  have hexp : R < 2^(Nat.log2 B + 1 + (Nat.log2 (d + 2)+1)*m) := by
    calc
      R ≤ B*(d+2)^m := hR
      _ < 2^(Nat.log2 B+1)*(d+2)^m := Nat.mul_lt_mul_of_pos_right hB hq
      _ ≤ 2^(Nat.log2 B+1)*(2^(Nat.log2 (d+2)+1))^m :=
        Nat.mul_le_mul_left _ (Nat.pow_le_pow_left hbase m)
      _ = _ := by rw [← Nat.pow_mul, ← Nat.pow_add]
  have hlog : Nat.log2 R < Nat.log2 B+1+(Nat.log2 (d+2)+1)*m :=
    (Nat.log2_lt hzero).mpr hexp
  have hl : 1 ≤ Nat.log2 (d+2) := by
    rw [Nat.le_log2 (by omega)]
    omega
  have h₁ := Nat.mul_le_mul_left (Nat.log2 B+1) hl
  have h₂ := Nat.mul_le_mul_left m hl
  nlinarith

/-- Elementary exponential domination, with an explicit starting index. -/
theorem square_le_two_pow (q : ℕ) (hq : 4 ≤ q) : q^2 ≤ 2^q := by
  induction q, hq using Nat.le_induction with
  | base => norm_num
  | succ q hq ih =>
    rw [Nat.pow_succ 2 q]
    nlinarith

/-- A deliberately loose explicit cutoff for logarithmic depth padding. -/
theorem mul_log2_le (K d : ℕ) (hd : 2^(K+4) ≤ d) :
    K * Nat.log2 (d+2) ≤ d := by
  have hq : K+4 ≤ Nat.log2 (d+2) := by
    rw [Nat.le_log2 (by omega)]
    omega
  have hsq := square_le_two_pow (Nat.log2 (d+2)) (by omega)
  have hexp := Nat.log2_self_le (n := d+2) (by omega)
  have hmul := Nat.mul_le_mul_right (Nat.log2 (d+2)) hq
  nlinarith

/-- Uniform padding for every resource number below the same polynomial. -/
theorem polynomial_padding (P B m d R : ℕ)
    (hd : 2^(P*(Nat.log2 B+1+2*m)+4) ≤ d)
    (hR : R ≤ B * (d+2)^m) :
    P * Nat.log2 R ≤ d := by
  have hh := Nat.mul_le_mul_left P (polynomial_log2_bound B m d R hR)
  have hl := mul_log2_le (P*(Nat.log2 B+1+2*m)) d hd
  nlinarith

/-- Raising the resource to any fixed power preserves a polynomial bound. -/
theorem polynomial_power_bound (B m a d R : ℕ)
    (hR : R ≤ B * (d+2)^m) :
    R^a ≤ B^a * (d+2)^(m*a) := by
  have h := Nat.pow_le_pow_left hR a
  simpa only [Nat.mul_pow, ← Nat.pow_mul] using h

#print axioms resource_bound
#print axioms polynomial_log2_bound
#print axioms polynomial_padding
#print axioms polynomial_power_bound

end ConditionalNonpolynomial.FamilyResources
