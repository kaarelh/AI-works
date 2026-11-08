import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Algebra.Order.Archimedean.Real.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity.Basic
import Mathlib.Tactic.NormNum

/-! Elementary real bounds translating quadratic/logarithmic resource
estimates into the advertised square-root mistake exponents. -/

noncomputable section

namespace NeuralGeneralization.OnlineLower

theorem sqrt_quadratic_width (K k : ℕ) :
    ((K * k ^ 2 : ℕ) : ℝ) ^ (1 / 2 : ℝ) = Real.sqrt (K : ℝ) * (k : ℝ) := by
  rw [← Real.sqrt_eq_rpow, Nat.cast_mul, Nat.cast_pow,
    Real.sqrt_mul (Nat.cast_nonneg K), Real.sqrt_sq_eq_abs,
    abs_of_nonneg (Nat.cast_nonneg k)]

/-- Rounding the teacher width up costs only a constant factor. The logarithm
of the rounded width is at least the logarithm of the construction index. -/
theorem rounded_quadratic_log_width_bounds (K k : ℕ)
    (hKR : (1 : ℝ) ≤ K) (hkone : (1 : ℝ) ≤ k)
    (hlog : (1 : ℝ) ≤ Real.log k) :
    let A := (K : ℝ) * (k : ℝ) ^ 2 * Real.log k ^ 2
    let C := ⌈A⌉₊
    (k : ℝ) ≤ (C : ℝ) ∧ (C : ℝ) ≤ 2 * A ∧
      (C : ℝ) ^ (1 / 2 : ℝ) / Real.log (C + 2 : ℝ) ≤
        Real.sqrt (2 * (K : ℝ)) * (k : ℝ) := by
  dsimp only
  let A := (K : ℝ) * (k : ℝ) ^ 2 * Real.log k ^ 2
  let C := ⌈A⌉₊
  let R := Real.sqrt (2 * (K : ℝ))
  have hkpos : (0 : ℝ) < k := by linarith
  have hlogpos : 0 < Real.log k := by linarith
  have hkA : (k : ℝ) ≤ A := by
    have hkpow : (k : ℝ) ≤ (k : ℝ) ^ 2 := by nlinarith
    have hlpow : (1 : ℝ) ≤ Real.log k ^ 2 := by nlinarith
    have h1 := mul_le_mul_of_nonneg_right hKR (sq_nonneg (k : ℝ))
    have h2 := mul_le_mul_of_nonneg_left hlpow
      (mul_nonneg (Nat.cast_nonneg K) (sq_nonneg (k : ℝ)))
    dsimp [A]
    nlinarith
  have hA : 0 ≤ A := (le_of_lt hkpos).trans hkA
  have hlower : (k : ℝ) ≤ (C : ℝ) := hkA.trans (Nat.le_ceil A)
  have hupper : (C : ℝ) ≤ 2 * A := by
    have hceil := Nat.ceil_lt_add_one hA
    have hAone : 1 ≤ A := hkone.trans hkA
    dsimp [C]
    linarith
  refine ⟨hlower, hupper, ?_⟩
  have hR : 0 ≤ R := Real.sqrt_nonneg _
  have hRsq : R ^ 2 = 2 * (K : ℝ) := Real.sq_sqrt (by positivity)
  have htarget : (R * (k : ℝ) * Real.log k) ^ 2 = 2 * A := by
    dsimp [A]
    simp only [mul_pow]
    rw [hRsq]
    ring
  have hsqrt : Real.sqrt (C : ℝ) ≤ R * (k : ℝ) * Real.log k := by
    apply (sq_le_sq₀ (Real.sqrt_nonneg _) (by positivity)).mp
    rw [Real.sq_sqrt (Nat.cast_nonneg _), htarget]
    exact hupper
  have hlogC : Real.log k ≤ Real.log (C + 2 : ℝ) :=
    Real.log_le_log hkpos (by linarith)
  have hlogCpos : 0 < Real.log (C + 2 : ℝ) := hlogpos.trans_le hlogC
  rw [← Real.sqrt_eq_rpow]
  calc
    _ ≤ (R * (k : ℝ) * Real.log k) / Real.log (C + 2 : ℝ) :=
      div_le_div_of_nonneg_right hsqrt hlogCpos.le
    _ ≤ (R * (k : ℝ) * Real.log k) / Real.log k :=
      div_le_div_of_nonneg_left (by positivity) hlogpos hlogC
    _ = R * (k : ℝ) := mul_div_cancel_right₀ _ (ne_of_gt hlogpos)

end NeuralGeneralization.OnlineLower
