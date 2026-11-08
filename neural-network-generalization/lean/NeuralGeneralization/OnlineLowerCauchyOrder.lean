import NeuralGeneralization.OnlineLowerAveragedCauchy
import Mathlib.Analysis.Complex.ExponentialBounds

noncomputable section
open scoped BigOperators
open Complex Real Metric Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma one_add_recip_pow_le_three (j:ℕ) (hj:0<j) :
    (1+1/(j:ℝ))^j≤3 := by
  have jp : 0<(j:ℝ) := by exact_mod_cast hj
  have he : 1+1/(j:ℝ)≤Real.exp (1/(j:ℝ)) := by
    simpa only [add_comm] using Real.add_one_le_exp (1/(j:ℝ))
  have hp := pow_le_pow_left₀ (by positivity : 0≤1+1/(j:ℝ)) he j
  rw [←Real.exp_nat_mul,mul_one_div_cancel jp.ne'] at hp
  exact hp.trans Real.exp_one_lt_three.le

lemma cauchy_order_radius_pos (u:ℝ) (hu:0<u) (j:ℕ) (hj:0<j) :
    0<u*(j:ℝ)/((j:ℝ)+1) := by positivity

lemma cauchy_order_radius_lt (u:ℝ) (hu:0<u) (j:ℕ) :
    u*(j:ℝ)/((j:ℝ)+1)<u := by
  apply (div_lt_iff₀ (by positivity : 0<(j:ℝ)+1)).mpr
  nlinarith

lemma cauchy_order_radius_factor (u:ℝ) (hu:0<u) (j:ℕ) (hj:0<j) :
    (u*(j:ℝ)/((j:ℝ)+1))⁻¹^j≤3/(u^j) := by
  have jp : 0<(j:ℝ) := by exact_mod_cast hj
  have he : (u*(j:ℝ)/((j:ℝ)+1))⁻¹=(1+1/(j:ℝ))/u := by
    field_simp
  rw [he,div_pow]
  exact div_le_div_of_nonneg_right (one_add_recip_pow_le_three j hj) (pow_nonneg hu.le j)

lemma cauchy_order_denominator (u:ℝ) (hu:0<u) (j:ℕ) :
    u^2/((j:ℝ)+1)≤u^2-(u*(j:ℝ)/((j:ℝ)+1))^2 := by
  have jp : 0<(j:ℝ)+1 := by positivity
  field_simp
  nlinarith [sq_nonneg u,Nat.cast_nonneg (α:=ℝ) j]

/-- The averaged boundary estimate costs only a linear factor in derivative order. -/
theorem quadraticRemainder_deriv_order_bound (f:ℂ→ℂ) (u K:ℝ)
    (hu:0<u) (hK:0≤K) (j:ℕ) (hj:0<j)
    (hf:DifferentiableOn ℂ f (closedBall (u:ℂ) (u*(j:ℝ)/((j:ℝ)+1))))
    (hbound:∀z∈sphere (u:ℂ) (u*(j:ℝ)/((j:ℝ)+1)), ‖f z‖≤K/‖z‖^2) :
    ‖iteratedDeriv j f (u:ℂ)‖ ≤ 6*K*(j:ℝ)*(j.factorial:ℝ)/(u^(j+2)) := by
  let r := u*(j:ℝ)/((j:ℝ)+1)
  have hr : 0<r := cauchy_order_radius_pos u hu j hj
  have hru : r<u := cauchy_order_radius_lt u hu j
  have hp : 0<u^2-r^2 := by nlinarith
  have hc:=quadraticRemainder_deriv_bound f u r K hr hru hf hbound j
  have hd := cauchy_order_denominator u hu j
  have hi : (j.factorial:ℝ)*K/(u^2-r^2) ≤
      (j.factorial:ℝ)*K/(u^2/((j:ℝ)+1)) :=
    div_le_div_of_nonneg_left (by positivity) (by positivity) hd
  have hj1 : (1:ℝ)≤j := by exact_mod_cast hj
  have hratio:=cauchy_order_radius_factor u hu j hj
  calc
    _ ≤ (j.factorial:ℝ)*K/(u^2-r^2)*r⁻¹^j := hc
    _ ≤ ((j.factorial:ℝ)*K/(u^2/((j:ℝ)+1)))*(3/u^j) :=
      mul_le_mul hi hratio (by positivity) (by positivity)
    _ = 3*K*((j:ℝ)+1)*(j.factorial:ℝ)/(u^(j+2)) := by
      rw [pow_add]
      field_simp
    _ = (3*K*(j.factorial:ℝ)/(u^(j+2)))*((j:ℝ)+1) := by ring
    _ ≤ (3*K*(j.factorial:ℝ)/(u^(j+2)))*(2*(j:ℝ)) :=
      mul_le_mul_of_nonneg_left (by linarith) (by positivity)
    _ = _ := by ring

end NeuralGeneralization.OnlineLowerTanh
