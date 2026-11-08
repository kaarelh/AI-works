import NeuralGeneralization.OnlineLowerBernsteinLaplace
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Deriv
import Mathlib.Data.Nat.Factorial.Basic

/-! # Actual Laplace integrals of odd sine powers

This is a finite integration-by-parts calculation. It is used for the
positive balanced-tanh series and the absolute diagonal estimates.
-/

noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory Set Filter
open scoped Topology BigOperators

namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerBernstein

theorem laplaceIntegrable_of_bounded (c M : ℝ) (f : ℝ → ℝ)
    (hc : 0 < c) (hm : Measurable f) (hf : ∀ t, |f t| ≤ M) :
    LaplaceIntegrable c f := by
  have hi := (integrableOn_exp_mul_Ioi (show -c < 0 by linarith) 0).const_mul M
  apply hi.mono' ?_ ?_
  · exact ((Real.continuous_exp.comp (continuous_const.mul continuous_id)).measurable.mul hm).aestronglyMeasurable
  · filter_upwards [] with t
    rw [Real.norm_eq_abs, abs_mul, abs_of_pos (Real.exp_pos _)]
    simpa only [mul_comm] using mul_le_mul_of_nonneg_left (hf t) (Real.exp_pos (-c*t)).le

theorem laplace_boundary_zero_of_bounded (c M : ℝ) (f : ℝ → ℝ)
    (hc : 0 < c) (hf : ∀ t, |f t| ≤ M) :
    Tendsto (fun t => Real.exp (-c*t)*f t) atTop (𝓝 0) := by
  have hneg := Tendsto.const_mul_atTop_of_neg (show -c < 0 by linarith)
    (tendsto_id : Tendsto (fun t : ℝ => t) atTop atTop)
  have hlim : Tendsto (fun t : ℝ => M*Real.exp (-c*t)) atTop (𝓝 0) := by
    simpa using (Real.tendsto_exp_atBot.comp hneg).const_mul M
  apply squeeze_zero_norm' ?_ hlim
  filter_upwards [] with t
  rw [Real.norm_eq_abs, abs_mul, abs_of_pos (Real.exp_pos _)]
  simpa only [mul_comm] using mul_le_mul_of_nonneg_left (hf t) (Real.exp_pos (-c*t)).le

def sinePower (n : ℕ) (a t : ℝ) : ℝ := Real.sin (a*t)^n

def sinePowerFirst (n : ℕ) (a t : ℝ) : ℝ :=
  (n+2 : ℕ)*a*Real.sin (a*t)^(n+1)*Real.cos (a*t)

def sinePowerSecond (n : ℕ) (a t : ℝ) : ℝ :=
  ((n+2 : ℕ)*(n+1 : ℕ)*a^2)*sinePower n a t -
    (((n+2 : ℕ) : ℝ)^2*a^2)*sinePower (n+2) a t

theorem sinePower_abs_le (n : ℕ) (a t : ℝ) : |sinePower n a t| ≤ 1 := by
  simpa only [sinePower, abs_pow, one_pow] using
    pow_le_pow_left₀ (abs_nonneg (Real.sin (a*t))) (Real.abs_sin_le_one (a*t)) n

theorem sinePowerFirst_abs_le (n : ℕ) (a t : ℝ) :
    |sinePowerFirst n a t| ≤ |((n+2 : ℕ) : ℝ)*a| := by
  unfold sinePowerFirst
  rw [abs_mul, abs_mul]
  have hs := sinePower_abs_le (n+1) a t
  change |Real.sin (a*t)^(n+1)| ≤ 1 at hs
  have hc := Real.abs_cos_le_one (a*t)
  nlinarith [mul_le_mul hs hc (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1),
    abs_nonneg (((n+2 : ℕ) : ℝ)*a)]

theorem sinePowerSecond_abs_le (n : ℕ) (a t : ℝ) :
    |sinePowerSecond n a t| ≤
      |((n+2 : ℕ) : ℝ)*(n+1 : ℕ)*a^2| + |((n+2 : ℕ) : ℝ)^2*a^2| := by
  have hb (b : ℝ) (j : ℕ) : |b * sinePower j a t| ≤ |b| := by
    rw [abs_mul]
    exact (mul_le_mul_of_nonneg_left (sinePower_abs_le j a t) (abs_nonneg b)).trans_eq (mul_one _)
  unfold sinePowerSecond
  exact (abs_sub _ _).trans (add_le_add (hb _ n) (hb _ (n+2)))

theorem hasDerivAt_sinePower (n : ℕ) (a t : ℝ) :
    HasDerivAt (sinePower (n+2) a) (sinePowerFirst n a t) t := by
  have hp : n + 2 - 1 = n + 1 := by omega
  convert! ((((hasDerivAt_id t).const_mul a).sin).pow (n+2)) using 1 <;>
    simp only [sinePower, sinePowerFirst, id_eq, mul_one, hp] <;> ring

theorem hasDerivAt_sinePowerFirst (n : ℕ) (a t : ℝ) :
    HasDerivAt (sinePowerFirst n a) (sinePowerSecond n a t) t := by
  have hs := ((hasDerivAt_id t).const_mul a).sin
  have hc := ((hasDerivAt_id t).const_mul a).cos
  convert! (((hs.pow (n+1)).const_mul (((n+2 : ℕ) : ℝ)*a)).mul hc) using 1
  simp only [sinePowerFirst, sinePowerSecond, sinePower, id_eq, mul_one,
    Nat.add_sub_cancel, Nat.cast_add, Nat.cast_ofNat, Nat.cast_one]
  have htrig := Real.sin_sq_add_cos_sq (a*t)
  simp only [Pi.pow_apply, show n+2=n+1+1 by omega, pow_succ]
  nlinarith [congrArg (fun z : ℝ => (n+2)*(n+1)*a^2*Real.sin (a*t)^n*z) htrig]

theorem sinePower_laplaceIntegrable (n : ℕ) (a c : ℝ) (hc : 0 < c) :
    LaplaceIntegrable c (sinePower n a) :=
  laplaceIntegrable_of_bounded c 1 _ hc (by unfold sinePower; fun_prop)
    (sinePower_abs_le n a)

theorem sinePowerFirst_laplaceIntegrable (n : ℕ) (a c : ℝ) (hc : 0 < c) :
    LaplaceIntegrable c (sinePowerFirst n a) :=
  laplaceIntegrable_of_bounded c _ _ hc (by unfold sinePowerFirst; fun_prop)
    (sinePowerFirst_abs_le n a)

theorem sinePowerSecond_laplaceIntegrable (n : ℕ) (a c : ℝ) (hc : 0 < c) :
    LaplaceIntegrable c (sinePowerSecond n a) :=
  laplaceIntegrable_of_bounded c _ _ hc (by unfold sinePowerSecond sinePower; fun_prop)
    (sinePowerSecond_abs_le n a)

theorem sinePower_laplace_recurrence (n : ℕ) (a c : ℝ) (hc : 0 < c) :
    (c^2+((n+2 : ℕ) : ℝ)^2*a^2)*laplace c (sinePower (n+2) a) =
      ((n+2 : ℕ) : ℝ)*(n+1 : ℕ)*a^2*laplace c (sinePower n a) := by
  have h₁ := laplace_derivative c (sinePower (n+2) a) (sinePowerFirst n a)
    (fun t _ => hasDerivAt_sinePower n a t)
    (sinePower_laplaceIntegrable (n+2) a c hc) (sinePowerFirst_laplaceIntegrable n a c hc)
    (laplace_boundary_zero_of_bounded c 1 _ hc (sinePower_abs_le (n+2) a))
  have h₂ := laplace_derivative c (sinePowerFirst n a) (sinePowerSecond n a)
    (fun t _ => hasDerivAt_sinePowerFirst n a t)
    (sinePowerFirst_laplaceIntegrable n a c hc) (sinePowerSecond_laplaceIntegrable n a c hc)
    (laplace_boundary_zero_of_bounded c _ _ hc (sinePowerFirst_abs_le n a))
  have hlin := laplace_linear_combination c (((n+2 : ℕ) : ℝ)*(n+1 : ℕ)*a^2)
    (-(((n+2 : ℕ) : ℝ)^2*a^2)) (sinePower n a) (sinePower (n+2) a)
    (sinePower_laplaceIntegrable n a c hc) (sinePower_laplaceIntegrable (n+2) a c hc)
  have hlin' : laplace c (sinePowerSecond n a) =
      ((n+2 : ℕ) : ℝ)*(n+1 : ℕ)*a^2*laplace c (sinePower n a) -
      ((n+2 : ℕ) : ℝ)^2*a^2*laplace c (sinePower (n+2) a) := by
    change (laplace c (fun t => ((n+2 : ℕ) : ℝ)*(n+1 : ℕ)*a^2*sinePower n a t -
      ((n+2 : ℕ) : ℝ)^2*a^2*sinePower (n+2) a t)) = _
    simpa only [sub_eq_add_neg, neg_mul] using hlin
  have hz : sinePower (n+2) a 0 = 0 := by simp [sinePower]
  have hz' : sinePowerFirst n a 0 = 0 := by simp [sinePowerFirst]
  rw [hz, sub_zero] at h₁
  rw [hz', sub_zero, hlin', h₁] at h₂
  nlinarith

theorem laplace_sine_via_ibp (a c : ℝ) (hc : 0 < c) :
    laplace c (fun t => Real.sin (a*t)) = a/(c^2+a^2) := by
  have hs : LaplaceIntegrable c (fun t => Real.sin (a*t)) :=
    laplaceIntegrable_of_bounded c 1 _ hc (by fun_prop) (fun t => Real.abs_sin_le_one _)
  have hco : LaplaceIntegrable c (fun t => Real.cos (a*t)) :=
    laplaceIntegrable_of_bounded c 1 _ hc (by fun_prop) (fun t => Real.abs_cos_le_one _)
  have hsd (t : ℝ) : HasDerivAt (fun t => Real.sin (a*t)) (a*Real.cos (a*t)) t := by
    convert! ((hasDerivAt_id t).const_mul a).sin using 1 <;> simp only [id_eq, mul_one] <;> ring
  have hcd (t : ℝ) : HasDerivAt (fun t => Real.cos (a*t)) (-a*Real.sin (a*t)) t := by
    convert! ((hasDerivAt_id t).const_mul a).cos using 1 <;> simp only [id_eq, mul_one] <;> ring
  have h₁ := laplace_derivative c _ _ (fun t _ => hsd t)
    hs (by simpa only [LaplaceIntegrable, IntegrableOn, mul_left_comm] using hco.const_mul a)
    (laplace_boundary_zero_of_bounded c 1 _ hc (fun t => Real.abs_sin_le_one _))
  have h₂ := laplace_derivative c _ _ (fun t _ => hcd t)
    hco (by simpa only [LaplaceIntegrable, IntegrableOn, mul_left_comm] using hs.const_mul (-a))
    (laplace_boundary_zero_of_bounded c 1 _ hc (fun t => Real.abs_cos_le_one _))
  have hsc : laplace c (fun t => a*Real.cos (a*t)) = a*laplace c (fun t => Real.cos (a*t)) := by
    simp only [laplace, mul_left_comm (Real.exp _) a, integral_const_mul]
  have hcs : laplace c (fun t => -a*Real.sin (a*t)) = -a*laplace c (fun t => Real.sin (a*t)) := by
    simp only [laplace, mul_left_comm (Real.exp _) (-a), integral_const_mul]
  rw [hsc] at h₁
  rw [hcs] at h₂
  simp only [mul_zero, Real.sin_zero, Real.cos_zero, sub_zero] at h₁ h₂
  apply (eq_div_iff (by nlinarith [sq_nonneg a] : c^2+a^2 ≠ 0)).mpr
  nlinarith [congrArg (fun z : ℝ => c*z) h₁,
    congrArg (fun z : ℝ => a*z) h₂]

/-- Every odd signed sine-power Laplace integral is strictly positive. -/
theorem laplace_odd_sinePower_pos (r : ℕ) (a c : ℝ) (ha : 0 < a) (hc : 0 < c) :
    0 < laplace c (sinePower (2*r+1) a) := by
  induction r with
  | zero =>
      change 0 < laplace c (fun t => Real.sin (a*t)^1)
      simp_rw [pow_one]
      rw [laplace_sine_via_ibp a c hc]
      exact div_pos ha (by positivity)
  | succ r ih =>
      have hr := sinePower_laplace_recurrence (2*r+1) a c hc
      have hden : 0 < c^2 + ((2*r+1+2 : ℕ) : ℝ)^2*a^2 := by positivity
      have hnum : 0 < ((2*r+1+2 : ℕ) : ℝ)*(2*r+1+1 : ℕ)*a^2*
          laplace c (sinePower (2*r+1) a) := by positivity
      have hpos : 0 < laplace c (sinePower (2*r+1+2) a) := by
        exact pos_of_mul_pos_right (hr.symm ▸ hnum) hden.le
      simpa only [show 2*(r+1)+1=2*r+1+2 by omega] using hpos

/-- The positive product formula involves the actual improper integral. -/
theorem laplace_odd_sinePower_product (r : ℕ) (a c : ℝ) (hc : 0 < c) :
    laplace c (sinePower (2*r+1) a) =
      ((2*r+1).factorial : ℝ) * a^(2*r+1) /
        ∏ j ∈ Finset.range (r+1), (c^2 + ((2*j+1 : ℕ) : ℝ)^2*a^2) := by
  induction r with
  | zero =>
      change laplace c (fun t => Real.sin (a*t)^1) = _
      simpa using laplace_sine_via_ibp a c hc
  | succ r ih =>
      have hr := sinePower_laplace_recurrence (2*r+1) a c hc
      have hden : c^2 + ((2*(r+1)+1 : ℕ) : ℝ)^2*a^2 ≠ 0 := by positivity
      have hp : (∏ j ∈ Finset.range (r+1),
          (c^2 + ((2*j+1 : ℕ) : ℝ)^2*a^2)) ≠ 0 := by
        apply Finset.prod_ne_zero_iff.mpr
        intro j hj
        positivity
      rw [show 2*r+1+2=2*(r+1)+1 by omega, ih] at hr
      rw [Finset.prod_range_succ]
      apply (eq_div_iff (mul_ne_zero hp hden)).mpr
      have hf : ((2*(r+1)+1).factorial : ℝ) =
          (2*r+3 : ℝ)*(2*r+2 : ℝ)*((2*r+1).factorial : ℝ) := by
        rw [show 2*(r+1)+1=(2*r+1+1)+1 by omega,
          Nat.factorial_succ, Nat.factorial_succ]
        push_cast
        ring
      have hpow : a^(2*(r+1)+1) = a^(2*r+1)*a^2 := by
        rw [show 2*(r+1)+1=(2*r+1)+2 by omega, pow_add]
      rw [hf, hpow]
      have hr' := congrArg (fun z : ℝ => z *
        ∏ j ∈ Finset.range (r+1), (c^2 + ((2*j+1 : ℕ) : ℝ)^2*a^2)) hr
      simp only [mul_assoc, div_mul_cancel₀ _ hp] at hr'
      push_cast at hr' ⊢
      nlinarith

end NeuralGeneralization.OnlineLowerTanh
