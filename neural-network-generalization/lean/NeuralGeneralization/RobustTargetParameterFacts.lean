import NeuralGeneralization.RobustTargetParameters

/-! # Verified numerical choices for the robust digital teacher -/
noncomputable section
namespace NeuralGeneralization.ConcreteModel

theorem digitalError_le_one (C : ℕ) : digitalError C ≤ 1 :=
  (digitalError_le C).trans (by norm_num)

theorem digitalReadout_ge_four (C : ℕ) {c : ℝ} (hc : 0 ≤ c) :
    4 ≤ digitalReadout C c := by
  unfold digitalReadout
  have h : 0 ≤ 4096*c*((C:ℝ)+1) := by positivity
  linarith

theorem digitalRadius_le_error (d C : ℕ) :
    digitalCylinderRadius d C ≤ digitalError C := by
  unfold digitalCylinderRadius
  apply (div_le_iff₀ (by positivity : 0 < 64*((d:ℝ)+1)*((C:ℝ)+1))).mpr
  have hden : (1:ℝ) ≤ 64*((d:ℝ)+1)*((C:ℝ)+1) := by
    have hd := Nat.cast_nonneg (α := ℝ) d
    have hC := Nat.cast_nonneg (α := ℝ) C
    nlinarith [mul_nonneg hd hC]
  simpa only [mul_one] using mul_le_mul_of_nonneg_left hden (digitalError_pos C).le

theorem digitalRadius_le_one (d C : ℕ) : digitalCylinderRadius d C ≤ 1 :=
  (digitalRadius_le_error d C).trans (digitalError_le_one C)

theorem digitalRadius_le_half_readout (d C : ℕ) {c : ℝ} (hc : 0 ≤ c) :
    digitalCylinderRadius d C ≤ digitalReadout C c / 2 := by
  linarith [digitalRadius_le_one d C, digitalReadout_ge_four C hc]

theorem digitalGain_ge_64 (C r : ℕ) : 64 ≤ digitalGain C r := by
  unfold digitalGain
  have hC := Nat.cast_nonneg (α := ℝ) C
  have hb := digitalBulk_nonneg r
  nlinarith [mul_nonneg hC hb]

theorem digitalGain_mul_error (C r : ℕ) :
    digitalGain C r * digitalError C = 64*(digitalBulk r+1) := by
  unfold digitalGain digitalError
  field_simp
  ring

theorem digitalGain_error_ge_32 (C r : ℕ) : 32 ≤ digitalGain C r * digitalError C := by
  rw [digitalGain_mul_error]
  linarith [digitalBulk_nonneg r]

theorem digitalGain_bulk_bound (C r : ℕ) : 64*digitalBulk r ≤ digitalGain C r := by
  unfold digitalGain
  have hC := Nat.cast_nonneg (α := ℝ) C
  have hb := digitalBulk_nonneg r
  nlinarith [mul_nonneg hC hb]

theorem digitalRadius_mul_dimension (d C : ℕ) :
    ((d:ℝ)+1)*digitalCylinderRadius d C ≤ digitalError C := by
  unfold digitalCylinderRadius
  have hcancel : ((d:ℝ)+1)*(digitalError C/(64*((d:ℝ)+1)*((C:ℝ)+1))) =
      digitalError C/(64*((C:ℝ)+1)) := by field_simp
  rw [hcancel]
  apply (div_le_iff₀ (by positivity : (0:ℝ)<64*((C:ℝ)+1))).mpr
  have hC := Nat.cast_nonneg (α := ℝ) C
  nlinarith [(digitalError_pos C).le, mul_nonneg hC (digitalError_pos C).le]

theorem digitalRadius_input_bound (d C r : ℕ) :
    ((d:ℝ)+1)*digitalCylinderRadius d C ≤ digitalGain C r/2 := by
  linarith [digitalRadius_mul_dimension d C, digitalError_le_one C, digitalGain_ge_64 C r]

theorem digitalRadius_mul_width (d C : ℕ) :
    digitalCylinderRadius d C*((C:ℝ)+1) ≤ digitalError C := by
  unfold digitalCylinderRadius
  have hcancel : (digitalError C/(64*((d:ℝ)+1)*((C:ℝ)+1)))*((C:ℝ)+1) =
      digitalError C/(64*((d:ℝ)+1)) := by field_simp
  rw [hcancel]
  apply (div_le_iff₀ (by positivity : (0:ℝ)<64*((d:ℝ)+1))).mpr
  have hd := Nat.cast_nonneg (α := ℝ) d
  nlinarith [(digitalError_pos C).le, mul_nonneg hd (digitalError_pos C).le]

theorem digitalRadius_sq_width (d C : ℕ) :
    (digitalCylinderRadius d C)^2*((C:ℝ)+1) ≤ (digitalError C)^2 := by
  have hh := mul_le_mul (digitalRadius_mul_width d C) (digitalRadius_le_error d C)
    (digitalCylinderRadius_pos d C).le (digitalError_pos C).le
  nlinarith

theorem digital_group_error (C : ℕ) :
    2*(C:ℝ)*(digitalError C)^2 ≤ (1/16:ℝ)^2 := by
  have he : digitalError C*((C:ℝ)+1) = 1/64 := by unfold digitalError; field_simp
  have he0 := (digitalError_pos C).le
  have he1 := digitalError_le C
  have hC := Nat.cast_nonneg (α := ℝ) C
  have hce : (C:ℝ)*digitalError C ≤ 1/64 := by nlinarith
  have hh := mul_le_mul hce he1 he0 (by norm_num : (0:ℝ)≤1/64)
  nlinarith

theorem digital_first_contraction (C r : ℕ) :
    3*((4/digitalGain C r)^2+(digitalNoise C)^2) ≤ (digitalError C)^2 := by
  have hA := digitalGain_pos C r
  have hAe := digitalGain_error_ge_32 C r
  have h4 : 4/digitalGain C r ≤ digitalError C/8 := by
    apply (div_le_iff₀ hA).mpr
    nlinarith
  have hepos := digitalError_pos C
  have hsq := (sq_le_sq₀ (by positivity : 0≤4/digitalGain C r)
    (by positivity : 0≤digitalError C/8)).mpr h4
  unfold digitalNoise
  nlinarith [sq_nonneg (digitalError C)]

theorem digital_internal_contraction (d C r : ℕ) :
    3*((4/digitalGain C r)^2+(8/digitalGain C r)^2*
      (4*(digitalCylinderRadius d C)^2*((C:ℝ)+1)*(1+(digitalError C)^2)+
        2*(digitalBulk r)^2*(digitalError C)^2)+(digitalNoise C)^2)
      ≤ (digitalError C)^2 := by
  apply digital_contraction_of_bounds
  · exact (digitalError_pos C).le
  · exact digitalError_le_one C
  · exact (digitalNoise_pos C).le
  · exact le_rfl
  · exact digitalGain_ge_64 C r
  · exact digitalGain_error_ge_32 C r
  · exact digitalBulk_nonneg r
  · exact digitalGain_bulk_bound C r
  · positivity
  · exact digitalRadius_sq_width d C

theorem digital_noisy_readout_margin (d C : ℕ) {c : ℝ} (hc : 0 ≤ c) :
    1 < 15*digitalReadout C c/16 - 2*digitalCylinderRadius d C - digitalNoise C := by
  have he := digitalError_le C
  have hr := digitalRadius_le_error d C
  have ha := digitalReadout_ge_four C hc
  unfold digitalNoise
  linarith

theorem digital_calibration_bound (C : ℕ) {c : ℝ} (hc : 0 ≤ c) :
    2*c ≤ digitalNoise C*digitalReadout C c := by
  unfold digitalNoise digitalError digitalReadout
  have hC : 0 < (C:ℝ)+1 := by positivity
  field_simp
  nlinarith [mul_nonneg hc (Nat.cast_nonneg (α := ℝ) C)]

theorem digitalRadius_inv (d C : ℕ) :
    (digitalCylinderRadius d C)⁻¹ = 4096*((d:ℝ)+1)*((C:ℝ)+1)^2 := by
  unfold digitalCylinderRadius digitalError
  field_simp
  ring

end NeuralGeneralization.ConcreteModel
