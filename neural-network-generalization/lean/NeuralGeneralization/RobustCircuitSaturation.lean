import NeuralGeneralization.RobustModel
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring

/-! # A global finite-perturbation saturation bound for tanh

The deliberately polynomial bound avoids depth-dependent exponential
constants. No infinitesimal or bounded-noise hypothesis is used.
-/
noncomputable section
namespace NeuralGeneralization.ConcreteModel

theorem one_sub_tanh_eq (q : ℝ) :
    1 - Real.tanh q = 2 / (Real.exp (2 * q) + 1) := by
  rw [Real.tanh_eq]
  have hp : 0 < Real.exp q := Real.exp_pos q
  have hn : 0 < Real.exp (-q) := Real.exp_pos (-q)
  have hmul : Real.exp q * Real.exp (-q) = 1 := by rw [← Real.exp_add]; simp
  have hdouble : Real.exp (2*q) = (Real.exp q)^2 := by
    rw [show 2*q=q+q by ring, Real.exp_add, pow_two]
  rw [hdouble]
  field_simp
  nlinarith

theorem tanh_positive_saturation {q : ℝ} (hq : 0 < q) :
    |Real.tanh q - 1| ≤ 1 / q := by
  have ht : Real.tanh q ≤ 1 := (le_abs_self _).trans (Real.abs_tanh_lt_one q).le
  rw [abs_of_nonpos (by linarith), neg_sub, one_sub_tanh_eq]
  apply (div_le_div_iff₀ (by positivity : 0 < Real.exp (2*q)+1) hq).mpr
  have hh := Real.add_one_le_exp (2*q)
  linarith

/-- Large disturbances are controlled by boundedness, while small ones remain
in the saturated region. -/
theorem tanh_global_secant_positive {A q u : ℝ}
    (hA : 0 < A) (hq : A / 2 ≤ q) :
    |Real.tanh (q + u) - 1| ≤ 4 / A + 8 * |u| / A := by
  by_cases hu : |u| ≤ A / 4
  · have hp : A/4 ≤ q+u := by
      have := (abs_le.mp hu).1
      linarith
    have hp0 : 0 < q+u := lt_of_lt_of_le (by positivity) hp
    have hh := tanh_positive_saturation hp0
    have hdiv : 1/(q+u) ≤ 4/A := by
      apply (div_le_div_iff₀ hp0 hA).mpr
      linarith
    have hnonneg : 0 ≤ 8*|u|/A := by positivity
    linarith
  · have hu' : A/4 ≤ |u| := le_of_lt (lt_of_not_ge hu)
    have hh : |Real.tanh (q+u)-1| ≤ 2 := by
      calc
        _ ≤ |Real.tanh (q+u)| + |(1:ℝ)| := abs_sub _ _
        _ ≤ 2 := by have := (Real.abs_tanh_lt_one (q+u)).le; norm_num at *; linarith
    have hbig : 2 ≤ 8*|u|/A := by
      apply (le_div_iff₀ hA).mpr
      linarith
    have hnonneg : 0 ≤ 4/A := by positivity
    linarith

/-- The signed global secant estimate used in each Boolean gate. -/
theorem tanh_global_secant (b : Bool) {A q u : ℝ}
    (hA : 0 < A) (hq : A / 2 ≤ labelReal b * q) :
    |Real.tanh (q + u) - labelReal b| ≤ 4 / A + 8 * |u| / A := by
  cases b
  · simp only [labelReal_false, neg_one_mul] at hq ⊢
    have hh := tanh_global_secant_positive (u := -u) hA hq
    rw [show -q + -u = -(q+u) by ring, Real.tanh_neg, abs_neg] at hh
    rw [show -Real.tanh (q+u)-1 = -(Real.tanh (q+u)+1) by ring, abs_neg] at hh
    simpa only [sub_neg_eq_add] using hh
  · simpa only [labelReal_true, one_mul] using tanh_global_secant_positive (u := u) hA
      (by simpa only [labelReal_true, one_mul] using hq)

end NeuralGeneralization.ConcreteModel
