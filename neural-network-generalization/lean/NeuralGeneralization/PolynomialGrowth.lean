import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.Archimedean.Real.Basic
import Mathlib.Algebra.Order.Ring.Nat
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Lean.Elab.Tactic.Omega

/-!
# Elementary polynomial envelopes for explicit compression constants

This proves closure under the arithmetic used in the fixed-depth bounds.
It does not assert polynomial growth for any unproved width construction.
-/

namespace NeuralGeneralization

def PolynomialGrowth2 (f : ℕ → ℕ → ℕ) : Prop :=
  ∃ A m : ℕ, 0 < A ∧ ∀ d C, f d C ≤ A * (1 + d + C) ^ m

namespace PolynomialGrowth2

theorem const (k : ℕ) : PolynomialGrowth2 (fun _ _ => k) := by
  refine ⟨k + 1, 0, by omega, ?_⟩
  intro d C
  simp

theorem left : PolynomialGrowth2 (fun d _ => d) := by
  refine ⟨1, 1, by decide, ?_⟩
  intro d C
  simp
  omega

theorem right : PolynomialGrowth2 (fun _ C => C) := by
  refine ⟨1, 1, by decide, ?_⟩
  intro d C
  simp

theorem mono {f g : ℕ → ℕ → ℕ} (hg : PolynomialGrowth2 g)
    (hfg : ∀ d C, f d C ≤ g d C) : PolynomialGrowth2 f := by
  obtain ⟨A, m, hA, h⟩ := hg
  exact ⟨A, m, hA, fun d C => (hfg d C).trans (h d C)⟩

theorem add {f g : ℕ → ℕ → ℕ} (hf : PolynomialGrowth2 f) (hg : PolynomialGrowth2 g) :
    PolynomialGrowth2 (fun d C => f d C + g d C) := by
  obtain ⟨A, m, hA, hF⟩ := hf
  obtain ⟨B, n, hB, hG⟩ := hg
  refine ⟨A + B, m + n, by omega, ?_⟩
  intro d C
  have hx : 1 ≤ 1 + d + C := by omega
  have hm : (1 + d + C) ^ m ≤ (1 + d + C) ^ (m + n) :=
    Nat.pow_le_pow_right hx (by omega)
  have hn : (1 + d + C) ^ n ≤ (1 + d + C) ^ (m + n) :=
    Nat.pow_le_pow_right hx (by omega)
  calc
    _ ≤ A * (1 + d + C) ^ m + B * (1 + d + C) ^ n := Nat.add_le_add (hF d C) (hG d C)
    _ ≤ A * (1 + d + C) ^ (m + n) + B * (1 + d + C) ^ (m + n) :=
      Nat.add_le_add (Nat.mul_le_mul_left A hm) (Nat.mul_le_mul_left B hn)
    _ = _ := by ring

theorem mul {f g : ℕ → ℕ → ℕ} (hf : PolynomialGrowth2 f) (hg : PolynomialGrowth2 g) :
    PolynomialGrowth2 (fun d C => f d C * g d C) := by
  obtain ⟨A, m, hA, hF⟩ := hf
  obtain ⟨B, n, hB, hG⟩ := hg
  refine ⟨A * B, m + n, Nat.mul_pos hA hB, ?_⟩
  intro d C
  calc
    _ ≤ (A * (1 + d + C) ^ m) * (B * (1 + d + C) ^ n) :=
      Nat.mul_le_mul (hF d C) (hG d C)
    _ = _ := by rw [pow_add]; ring

theorem pow {f : ℕ → ℕ → ℕ} (hf : PolynomialGrowth2 f) (k : ℕ) :
    PolynomialGrowth2 (fun d C => f d C ^ k) := by
  obtain ⟨A, m, hA, hF⟩ := hf
  refine ⟨A ^ k, m * k, Nat.pow_pos hA, ?_⟩
  intro d C
  calc
    _ ≤ (A * (1 + d + C) ^ m) ^ k := Nat.pow_le_pow_left (hF d C) k
    _ = _ := by rw [mul_pow, ← pow_mul]

/-- Substituting a polynomially bounded complexity or energy budget preserves
polynomial growth in the original dimension and complexity. -/
theorem compositionRight {f g : ℕ → ℕ → ℕ}
    (hf : PolynomialGrowth2 f) (hg : PolynomialGrowth2 g) :
    PolynomialGrowth2 (fun d C => f d (g d C)) := by
  obtain ⟨A,m,_hA,hF⟩ := hf
  apply (((const A).mul ((((const 1).add left).add hg).pow m))).mono
  intro d C
  exact hF d (g d C)

/-- Converts the natural arithmetic bounds to the exact real envelope form
used by the main theorem statements at accuracy argument zero. -/
theorem real_envelope {f : ℕ → ℕ → ℕ} (hf : PolynomialGrowth2 f) :
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ, ∀ d C,
      (f d C : ℝ) ≤ A * (1 + (d : ℝ) + (C : ℝ)) ^ m := by
  obtain ⟨A, m, hA, hF⟩ := hf
  refine ⟨A, by exact_mod_cast hA, m, ?_⟩
  intro d C
  exact_mod_cast hF d C

/-- Integer rounding of a nonnegative real accuracy argument costs only a
fixed multiplicative coefficient in the real polynomial envelope. -/
theorem shifted_ceil_real_envelope {f : ℕ → ℕ → ℕ} (hf : PolynomialGrowth2 f) :
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ, ∀ d C (t : ℝ), 0 ≤ t →
      (f d (C + ⌈t⌉₊) : ℝ) ≤ A * (1 + (d : ℝ) + C + t) ^ m := by
  obtain ⟨A,m,hA,hF⟩ := hf
  refine ⟨(A : ℝ)*2^m, mul_pos (by exact_mod_cast hA) (by positivity), m, ?_⟩
  intro d C t ht
  have hh : (f d (C+⌈t⌉₊) : ℝ) ≤
      (A : ℝ)*(1+(d : ℝ)+(C : ℝ)+(⌈t⌉₊ : ℝ))^m := by
    have hnat : f d (C+⌈t⌉₊) ≤ A*(1+d+C+⌈t⌉₊)^m := by
      simpa only [Nat.add_assoc] using hF d (C+⌈t⌉₊)
    exact_mod_cast hnat
  have hbase : 1+(d : ℝ)+(C : ℝ)+(⌈t⌉₊ : ℝ) ≤
      2*(1+(d : ℝ)+C+t) := by
    have hceil := Nat.ceil_lt_add_one ht
    linarith [Nat.cast_nonneg d (α := ℝ), Nat.cast_nonneg C (α := ℝ)]
  have hbase0 : (0 : ℝ) ≤ 1+(d : ℝ)+(C : ℝ)+(⌈t⌉₊ : ℝ) := by positivity
  calc
    _ ≤ (A : ℝ)*(1+(d : ℝ)+(C : ℝ)+(⌈t⌉₊ : ℝ))^m := hh
    _ ≤ (A : ℝ)*(2*(1+(d : ℝ)+C+t))^m :=
      mul_le_mul_of_nonneg_left (pow_le_pow_left₀ hbase0 hbase m) (Nat.cast_nonneg A)
    _ = _ := by rw [mul_pow]; ring

end PolynomialGrowth2

end NeuralGeneralization
