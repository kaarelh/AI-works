import Mathlib.Analysis.MeanInequalitiesPow
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic

/-! # Finite even-power comparisons for the actual tanh code sine factors -/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

lemma pow_midpoint_le (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) (n : ℕ) :
    ((a+b)/2)^n ≤ (a^n+b^n)/2 := by
  have h := Real.pow_arith_mean_le_arith_mean_pow (Finset.univ : Finset Bool)
    (fun _ => (1/2:ℝ)) (fun t => if t then a else b)
    (by intro _ _; norm_num) (by norm_num [Fintype.sum_bool])
    (by intro t _; cases t <;> simp only [Bool.false_eq_true,if_false,if_true]; exact hb; exact ha) n
  norm_num [Fintype.sum_bool] at h
  convert h using 1 <;> ring

lemma rpow_midpoint_le (a b q : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) (hq : 1 ≤ q) :
    ((a+b)/2)^q ≤ (a^q+b^q)/2 := by
  have h := Real.rpow_arith_mean_le_arith_mean_rpow (Finset.univ : Finset Bool)
    (fun _ => (1/2:ℝ)) (fun t => if t then a else b)
    (by intro _ _; norm_num) (by norm_num [Fintype.sum_bool])
    (by intro t _; cases t <;> simp only [Bool.false_eq_true,if_false,if_true]; exact hb; exact ha) hq
  norm_num [Fintype.sum_bool] at h
  convert h using 1 <;> ring

/-- Clarkson's two-point lower inequality for any positive even degree. -/
theorem even_power_clarkson (R : ℕ) (hR : Even R) (hR2 : 2 ≤ R) (a b : ℝ) :
    |a|^R+|b|^R ≤ (|a+b|^R+|a-b|^R)/2 := by
  obtain ⟨q,hq⟩ := hR
  have hRq : R=2*q := by omega
  have hqpos : q ≠ 0 := by omega
  rw [hRq]
  have hlow := pow_add_pow_le (sq_nonneg a) (sq_nonneg b) hqpos
  have hmid := pow_midpoint_le ((a+b)^2) ((a-b)^2) (sq_nonneg _) (sq_nonneg _) q
  have hid : ((a+b)^2+(a-b)^2)/2 = a^2+b^2 := by ring
  rw [hid] at hmid
  have hh := hlow.trans hmid
  simpa only [pow_mul,sq_abs] using hh

/-- A balanced pair factor is controlled by the two sum/difference
frequencies. This is the comparison before integrating over frequency. -/
theorem sine_pair_clarkson (R : ℕ) (hR : Even R) (hR2 : 2 ≤ R) (a b t : ℝ) :
    |Real.sin (a*t)|^R*|Real.cos (b*t)|^R+
      |Real.cos (a*t)|^R*|Real.sin (b*t)|^R ≤
        (|Real.sin ((a+b)*t)|^R+|Real.sin ((a-b)*t)|^R)/2 := by
  have h := even_power_clarkson R hR hR2
    (Real.sin (a*t)*Real.cos (b*t)) (Real.cos (a*t)*Real.sin (b*t))
  rw [abs_mul,abs_mul,mul_pow,mul_pow] at h
  have hp : Real.sin (a*t)*Real.cos (b*t)+Real.cos (a*t)*Real.sin (b*t) =
      Real.sin ((a+b)*t) := by rw [add_mul,Real.sin_add]
  have hm : Real.sin (a*t)*Real.cos (b*t)-Real.cos (a*t)*Real.sin (b*t) =
      Real.sin ((a-b)*t) := by rw [sub_mul,Real.sin_sub]
  rwa [hp,hm] at h

/-- The two competing orientation factors for one pair sum to at most one
before any even-power or integral estimate. -/
theorem sine_cosine_pair_le_one (a b : ℝ) :
    |Real.sin a| *|Real.cos b|+|Real.cos a| *|Real.sin b| ≤ 1 := by
  have ha := Real.sin_sq_add_cos_sq a
  have hb := Real.sin_sq_add_cos_sq b
  have hs : (|Real.sin a| *|Real.cos b|+|Real.cos a| *|Real.sin b|)^2 +
      (|Real.sin a| *|Real.sin b|-|Real.cos a| *|Real.cos b|)^2 = 1 := by
    calc
      _ = (|Real.sin a|^2+|Real.cos a|^2)*(|Real.sin b|^2+|Real.cos b|^2) := by ring
      _ = 1 := by simp only [sq_abs,ha,hb]; norm_num
  nlinarith [sq_nonneg (|Real.sin a| *|Real.sin b|-|Real.cos a| *|Real.cos b|),
    mul_nonneg (abs_nonneg (Real.sin a)) (abs_nonneg (Real.cos b)),
    mul_nonneg (abs_nonneg (Real.cos a)) (abs_nonneg (Real.sin b))]

end NeuralGeneralization.OnlineLowerTanh
