import NeuralGeneralization.RobustMainAssembly

/-! # Fixed-degree scalar bounds for the target and readout truncation

These deliberately generous constants make every dependence on logical
width, depth, calibration, and target error explicit. They do not depend on
network width or Gaussian scale.
-/
noncomputable section
namespace NeuralGeneralization.RobustMainAssembly
open ConcreteModel

/-- A universal degree-seven bound on the actual constructive target cost. -/
theorem digitalMassPolynomial_le_base (d C r : ℕ) {c U : ℝ}
    (hU : 1 ≤ U) (hd : (d:ℝ)+1 ≤ U) (hC : (C:ℝ)+1 ≤ U)
    (hr : (r:ℝ)+1 ≤ U) (hc : 0 ≤ c) (hcU : c ≤ U) :
    digitalMassPolynomial d C r c ≤ 1000000000000*U^7 := by
  have hU0 : 0 ≤ U := by linarith
  have hd0 : (0:ℝ) ≤ d := Nat.cast_nonneg _
  have hC0 : (0:ℝ) ≤ C := Nat.cast_nonneg _
  have hr0 : (0:ℝ) ≤ r := Nat.cast_nonneg _
  have hdU : (d:ℝ) ≤ U := by linarith
  have hCU : (C:ℝ) ≤ U := by linarith
  have hrU : (r:ℝ) ≤ U := by linarith
  have hG : digitalGain C r ≤ 69632*U^2 := by
    unfold digitalGain digitalBulk
    calc
      4096*((C:ℝ)+1)*(16*((r:ℝ)+1)+1)
          ≤ 4096*U*(17*U) := by gcongr <;> linarith
      _ = _ := by ring
  have hA : digitalReadout C c ≤ 4100*U^2 := by
    unfold digitalReadout
    have hpow : 1 ≤ U^2 := one_le_pow₀ hU
    calc
      4+4096*c*((C:ℝ)+1) ≤ 4+4096*U*U := by gcongr
      _ ≤ 4100*U^2 := by nlinarith
  have hG0 : 0 ≤ digitalGain C r := (digitalGain_pos C r).le
  have hA0 : 0 ≤ digitalReadout C c := by unfold digitalReadout; positivity
  have h6 : U^6 ≤ U^7 := pow_le_pow_right₀ hU (by norm_num)
  have h5 : U^5 ≤ U^7 := pow_le_pow_right₀ hU (by norm_num)
  have h7 : 1 ≤ U^7 := one_le_pow₀ hU
  have hteach : digitalTeacherCost d C r c ≤
      (45*69632^2+4*4100^2)*U^7 := by
    unfold digitalTeacherCost
    calc
      _ ≤ 9*U*U*(69632*U^2)^2+
          36*U*U^2*(69632*U^2)^2+4*U^2*(4100*U^2)^2 := by gcongr
      _ = (9*69632^2+4*4100^2)*U^6+36*69632^2*U^7 := by ring
      _ ≤ _ := by nlinarith
  have hextra : ((d:ℝ)+2+(r:ℝ)*((C:ℝ)+1))*
      (1+8192*((d:ℝ)+1)*((C:ℝ)+1)^2) ≤ 24579*U^5 := by
    have h2 : U ≤ U^2 := by nlinarith
    have h3 : 1 ≤ U^3 := one_le_pow₀ hU
    have hleft : (d:ℝ)+2+(r:ℝ)*((C:ℝ)+1) ≤ 3*U^2 := by
      have hm : (r:ℝ)*((C:ℝ)+1) ≤ U*U := by gcongr
      nlinarith
    have hright : 1+8192*((d:ℝ)+1)*((C:ℝ)+1)^2 ≤ 8193*U^3 := by
      calc
        _ ≤ 1+8192*U*U^2 := by gcongr
        _ ≤ _ := by nlinarith
    calc
      _ ≤ (3*U^2)*(8193*U^3) := by gcongr
      _ = _ := by ring
  unfold digitalMassPolynomial
  nlinarith

/-- The logarithmic readout tail cost is absorbed by one reciprocal-error
coordinate, preserving a universal polynomial degree. -/
theorem mainReadoutCap_le_base (d C r : ℕ) {c ε U : ℝ}
    (hU : 1 ≤ U) (hd : (d:ℝ)+1 ≤ U) (hC : (C:ℝ)+1 ≤ U)
    (hr : (r:ℝ)+1 ≤ U) (hc : 0 ≤ c) (hcU : c ≤ U)
    (hε : 0 < ε) (hεU : ε⁻¹ ≤ U) :
    mainReadoutCap d C r c ε ≤ 10000000000000*U^7 := by
  have hD := digitalMassPolynomial_le_base d C r hU hd hC hr hc hcU
  have hlog : -Real.log (ε/12) ≤ 12*U := by
    have hh := Real.neg_inv_le_log (by positivity : 0 ≤ ε/12)
    have heq : (ε/12)⁻¹ = 12*ε⁻¹ := by field_simp
    rw [heq] at hh
    linarith
  have h17 : 1 ≤ U^7 := one_le_pow₀ hU
  have hU7 : U ≤ U^7 := by simpa using pow_le_pow_right₀ hU (show 1 ≤ 7 by omega)
  unfold mainReadoutCap
  nlinarith

end NeuralGeneralization.RobustMainAssembly
