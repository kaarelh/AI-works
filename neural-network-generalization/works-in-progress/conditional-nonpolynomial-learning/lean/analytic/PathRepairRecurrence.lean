import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity

open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

/-- Accumulated feature error when every transported layer has gain at most A.
The additive defect may be independent of the previous error; this is the
form needed after joining the feature embeddings at each layer. -/
theorem repair_recurrence_constant (e : ℕ → ℝ) (A δ : ℝ) (H : ℕ)
    (hA : 0 ≤ A) (hδ : 0 ≤ δ) (hzero : e 0 ≤ 0)
    (hstep : ∀ j < H, e (j+1) ≤ A*e j+δ) :
    e H ≤ (H:ℝ)*δ*(1+A)^H := by
  induction H with
  | zero => simpa using hzero
  | succ H ih =>
    have hprev := ih (fun j hj => hstep j (by omega))
    have hpow : 1 ≤ (1+A)^H := one_le_pow₀ (by linarith)
    have hεδ : δ ≤ δ*(1+A)^H := by nlinarith
    have hmain := (hstep H (by omega)).trans
      (add_le_add (mul_le_mul_of_nonneg_left hprev hA) le_rfl)
    rw [Nat.cast_add, Nat.cast_one, pow_succ]
    nlinarith [mul_nonneg (show 0 ≤ (H:ℝ)*δ*(1+A)^H by positivity) hA]

/-- The sharper form keeps the sum of logarithmic gains rather than replacing
every layer by its worst gain. -/
theorem repair_recurrence_exponential (e w : ℕ → ℝ) (δ : ℝ) (H : ℕ)
    (hw : ∀ j < H, 0 ≤ w j) (hδ : 0 ≤ δ) (hzero : e 0 ≤ 0)
    (hstep : ∀ j < H, e (j+1) ≤ Real.exp (w j)*e j+δ) :
    e H ≤ (H:ℝ)*δ*Real.exp (∑ j ∈ Finset.range H, w j) := by
  induction H with
  | zero => simpa using hzero
  | succ H ih =>
    have hp := ih (fun j hj => hw j (by omega)) (fun j hj => hstep j (by omega))
    have hwH := hw H (by omega)
    have hs : 0 ≤ ∑ j ∈ Finset.range H, w j := Finset.sum_nonneg
      (fun j hj => hw j (by have := Finset.mem_range.mp hj; omega))
    have he : 1 ≤ Real.exp ((∑ j ∈ Finset.range H, w j)+w H) :=
      Real.one_le_exp (by positivity)
    have h := (hstep H (by omega)).trans
      (add_le_add (mul_le_mul_of_nonneg_left hp (Real.exp_pos (w H)).le) le_rfl)
    rw [Finset.sum_range_succ, Nat.cast_add, Nat.cast_one, Real.exp_add] at *
    nlinarith

/-- Explicit positive covariance-repair precision. Its logarithm is linear
in depth and in the logarithm of the worst amplification factor. -/
noncomputable def repairPrecision (H : ℕ) (A W ρ : ℝ) : ℝ :=
  ρ/((H+1)*(1+A)^H*(1+W))

lemma repairPrecision_pos (H : ℕ) {A W ρ : ℝ}
    (hA : 0 ≤ A) (hW : 0 ≤ W) (hρ : 0 < ρ) :
    0 < repairPrecision H A W ρ := by
  unfold repairPrecision
  positivity

theorem repaired_output_error (e : ℕ → ℝ) (H : ℕ) (A W ρ : ℝ)
    (hA : 0 ≤ A) (hW : 0 ≤ W) (hρ : 0 < ρ)
    (hzero : e 0 ≤ 0)
    (hstep : ∀ j < H, e (j+1) ≤ A*e j+repairPrecision H A W ρ) :
    W*e H ≤ ρ := by
  have hδ := (repairPrecision_pos H hA hW hρ).le
  have h := mul_le_mul_of_nonneg_left
    (repair_recurrence_constant e A _ H hA hδ hzero hstep) hW
  apply h.trans
  have hAp : 0 < 1+A := by linarith
  have hWp : 0 < 1+W := by linarith
  unfold repairPrecision
  field_simp
  nlinarith [mul_pos hρ hAp, mul_nonneg hW (Nat.cast_nonneg H)]

lemma repairPrecision_log_inverse (H : ℕ) {A W ρ : ℝ}
    (hA : 0 ≤ A) (hW : 0 ≤ W) (hρ : 0 < ρ) :
    Real.log (1/repairPrecision H A W ρ) =
      Real.log ((H:ℝ)+1) + (H:ℝ)*Real.log (1+A) + Real.log (1+W) - Real.log ρ := by
  have hAp : 0 < 1+A := by linarith
  have hWp : 0 < 1+W := by linarith
  have hHp : 0 < (H:ℝ)+1 := by positivity
  unfold repairPrecision
  rw [one_div_div, Real.log_div (by positivity) (ne_of_gt hρ),
    Real.log_mul (by positivity) (ne_of_gt hWp),
    Real.log_mul (ne_of_gt hHp) (by positivity), Real.log_pow]

end ConditionalNonpolynomial.Analytic
