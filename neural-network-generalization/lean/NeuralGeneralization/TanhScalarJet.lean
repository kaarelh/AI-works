import NeuralGeneralization.Activation
import Mathlib.Analysis.Calculus.Deriv.Comp
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith

/-! The actual tanh function, its first two derivatives, and global bounds. -/

noncomputable section
namespace NeuralGeneralization.TanhDifferential

def tanhFirst (x : ℝ) : ℝ := 1 - Real.tanh x ^ 2

def tanhSecond (x : ℝ) : ℝ := -2 * Real.tanh x * tanhFirst x

theorem hasDerivAt_tanh_first (x : ℝ) : HasDerivAt Real.tanh (tanhFirst x) x := by
  have he : 1 / Real.cosh x ^ 2 = tanhFirst x := by
    unfold tanhFirst
    rw [Real.tanh_eq_sinh_div_cosh]
    have hc : Real.cosh x ≠ 0 := (Real.cosh_pos x).ne'
    field_simp
    nlinarith [Real.cosh_sq_sub_sinh_sq x]
  rw [← he]
  exact ConcreteModel.hasDerivAt_tanh x

theorem hasDerivAt_tanhFirst (x : ℝ) : HasDerivAt tanhFirst (tanhSecond x) x := by
  have h := ((hasDerivAt_tanh_first x).pow 2).const_sub 1
  have hd : -(2 * Real.tanh x ^ (2 - 1) * tanhFirst x) = tanhSecond x := by
    simp only [tanhSecond, Nat.reduceSub, pow_one]
    ring
  change HasDerivAt tanhFirst (-(2 * Real.tanh x ^ (2 - 1) * tanhFirst x)) x at h
  rwa [hd] at h

theorem tanhFirst_nonneg (x : ℝ) : 0 ≤ tanhFirst x := by
  have h := (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one x).le
  exact sub_nonneg.mpr h

theorem abs_tanhFirst_le_one (x : ℝ) : |tanhFirst x| ≤ 1 := by
  rw [abs_of_nonneg (tanhFirst_nonneg x)]
  unfold tanhFirst
  nlinarith [sq_nonneg (Real.tanh x)]

theorem abs_tanhSecond_le_two (x : ℝ) : |tanhSecond x| ≤ 2 := by
  have ht := (Real.abs_tanh_lt_one x).le
  have hf := abs_tanhFirst_le_one x
  have hprod := mul_le_mul ht hf (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1)
  unfold tanhSecond
  rw [abs_mul, abs_mul]
  norm_num
  nlinarith

@[fun_prop] theorem continuous_tanh : Continuous Real.tanh :=
  continuous_iff_continuousAt.mpr fun x => (hasDerivAt_tanh_first x).continuousAt

@[fun_prop] theorem continuous_tanhFirst : Continuous tanhFirst :=
  continuous_iff_continuousAt.mpr fun x => (hasDerivAt_tanhFirst x).continuousAt

@[fun_prop] theorem continuous_tanhSecond : Continuous tanhSecond := by
  unfold tanhSecond
  fun_prop

end NeuralGeneralization.TanhDifferential
