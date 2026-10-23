import NeuralGeneralization.BatchTwoActivationPolynomialSampling
import NeuralGeneralization.BatchTwoActivationLayerEvents

/-! An explicit polynomial width threshold for the dual exceptional event. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoActivation

theorem log_covariance_observables_le {m x : ℝ} (hm : 1≤m)
    (hlog : Real.log (2*m)≤x) : Real.log (2*m^2+1)≤2*x := by
  have hp : 0<2*m^2+1 := by positivity
  have hh : 2*m^2+1≤(2*m)^2 := by nlinarith
  have hl := Real.log_le_log hp hh
  rw [Real.log_pow] at hl
  norm_num only [Nat.cast_ofNat] at hl
  linarith

theorem polynomial_dual_width {m x N q K : ℝ} (hm : 1≤m) (hx : 128≤x)
    (hlog : Real.log (2*m)≤x) (hN : x^84≤N) (hK : 1≤K) (hq : 4*K≤q) :
    x^80*Real.log (2*m^2+1)-N*(q-((x^4)*(x^32))^2/(2*x^80))≤-N*K := by
  have hx0 : 0<x := by linarith
  have hx1 : 1≤x := by linarith
  have hN0 : 0≤N := (pow_nonneg hx0.le 84).trans hN
  have he : ((x^4)*(x^32))^2/(2*x^80)=1/(2*x^8) := by field_simp <;> ring
  rw [he]
  have hsmall : 1/(2*x^8)≤1/2 := by
    exact one_div_le_one_div_of_le (by norm_num) (by nlinarith [one_le_pow₀ hx1 (n:=8)])
  have hlog' := log_covariance_observables_le hm hlog
  have hsum : x^80*Real.log (2*m^2+1)≤2*x^81 := by
    have hh := mul_le_mul_of_nonneg_left hlog' (pow_nonneg hx0.le 80)
    nlinarith
  have hpower : 2*x^81≤x^84 :=
    power_coefficient_enlarge hx1 (by linarith) (by omega)
  have hsumN : x^80*Real.log (2*m^2+1)≤N := hsum.trans (hpower.trans hN)
  have hrate : K+1≤q-1/(2*x^8) := by linarith
  have hmul := mul_le_mul_of_nonneg_left hrate hN0
  nlinarith

end NeuralGeneralization.BatchTwoActivation
