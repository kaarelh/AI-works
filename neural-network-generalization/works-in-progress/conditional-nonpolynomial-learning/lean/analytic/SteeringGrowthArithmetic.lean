import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace ConditionalNonpolynomial.Analytic

theorem inflation_total_variance_bound {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hq : v+r ≤ 1/128) :
    (1+16*(v+r))*v+r ≤ (9/8:ℝ)*(v+r) := by
  have hq0 := add_nonneg hv hr
  have hvq : v ≤ v+r := by linarith
  have hm := mul_le_mul_of_nonneg_left hvq hq0
  have hsmall := mul_nonneg hq0 (sub_nonneg.mpr hq)
  nlinarith

theorem inflation_growth_lower_numeric {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hq : v+r ≤ 1/128) :
    v*(1+4*(v+r)) ≤ ((1+16*(v+r))*v) *
      (1-((1+16*(v+r))*v)-r)^2 := by
  let q := v+r
  let a := (1+16*q)*v
  have hq0 : 0 ≤ q := add_nonneg hv hr
  have ha : 0 ≤ a := by dsimp [a]; positivity
  have hu : a+r ≤ (9/8:ℝ)*q := inflation_total_variance_bound hv hr hq
  have hf : 0 ≤ 1+16*q := by positivity
  have hp := mul_le_mul_of_nonneg_left (show 1-(9/4:ℝ)*q ≤ 1-2*(a+r) by linarith) hf
  have hsmall : q^2 ≤ q/128 := by nlinarith [mul_nonneg hq0 (sub_nonneg.mpr hq)]
  have hfac : 1+4*q ≤ (1+16*q)*(1-2*(a+r)) := by nlinarith
  have hmul := mul_le_mul_of_nonneg_left hfac hv
  have hsq : 1-2*(a+r) ≤ (1-a-r)^2 := by nlinarith [sq_nonneg (a+r)]
  have hmul2 := mul_le_mul_of_nonneg_left hsq ha
  change v*(1+4*q) ≤ a*(1-a-r)^2
  calc
    _ ≤ v*((1+16*q)*(1-2*(a+r))) := hmul
    _ = a*(1-2*(a+r)) := by dsimp [a]; ring
    _ ≤ _ := hmul2

#print axioms inflation_growth_lower_numeric
end ConditionalNonpolynomial.Analytic
