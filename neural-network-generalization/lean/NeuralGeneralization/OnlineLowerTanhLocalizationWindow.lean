import NeuralGeneralization.OnlineLowerTanhSineWindow
import Mathlib.Tactic

/-! # Sine-power window bounds uniform over every nonnegative frequency -/

noncomputable section
open MeasureTheory Set intervalIntegral
namespace NeuralGeneralization.OnlineLowerTanh

/-- The frequency is unrestricted: the constant grows only linearly with
where the unit interval starts. This is used for the entire transversal
product, including arbitrarily large individual incoming coordinates. -/
theorem sinePower_unit_window_uniform (p : ℕ) (a T : ℝ) (ha : 0 ≤ a) (hT : 0 ≤ T) :
    Real.sqrt (p:ℝ)*(∫ t in T..T+1, |Real.sin (a*t)|^p) ≤
      (1+2*Real.pi)*(T+1) := by
  by_cases hp : p=0
  · subst p
    simp
    positivity
  have hp1 : 1 ≤ p := Nat.one_le_iff_ne_zero.mpr hp
  have hpR : (1:ℝ) ≤ p := by exact_mod_cast hp1
  have hroot0 := Real.sqrt_nonneg (p:ℝ)
  have hroot_sq := Real.sq_sqrt (show 0 ≤ (p:ℝ) by positivity)
  have hroot_le : Real.sqrt (p:ℝ) ≤ (p:ℝ) := by nlinarith
  have hpPow : (p:ℝ) ≤ (2:ℝ)^p := by exact_mod_cast (Nat.lt_two_pow_self (n := p)).le
  have hIp : IntervalIntegrable (fun t : ℝ => |Real.sin (a*t)|^p) volume T (T+1) :=
    (by fun_prop : Continuous (fun t : ℝ => |Real.sin (a*t)|^p)).intervalIntegrable _ _
  by_cases hsmall : a*(T+1) ≤ 1/2
  · have hI : (∫ t in T..T+1, |Real.sin (a*t)|^p) ≤ (1/2:ℝ)^p := by
      have hm := integral_mono_on (by linarith : T ≤ T+1) hIp
        (intervalIntegrable_const : IntervalIntegrable (fun _ : ℝ => (1/2:ℝ)^p) volume T (T+1))
        (fun t ht => by
          have hat : 0 ≤ a*t := mul_nonneg ha (hT.trans ht.1)
          have hsin : |Real.sin (a*t)| ≤ 1/2 := by
            apply Real.abs_sin_le_abs.trans
            rw [abs_of_nonneg hat]
            nlinarith [mul_le_mul_of_nonneg_left ht.2 ha]
          exact pow_le_pow_left₀ (abs_nonneg _) hsin p)
      simpa using hm
    have hnorm : Real.sqrt (p:ℝ)*(∫ t in T..T+1, |Real.sin (a*t)|^p) ≤ 1 := by
      calc
        _ ≤ Real.sqrt (p:ℝ)*(1/2:ℝ)^p := mul_le_mul_of_nonneg_left hI hroot0
        _ ≤ (2:ℝ)^p*(1/2:ℝ)^p :=
          mul_le_mul_of_nonneg_right (hroot_le.trans hpPow) (by positivity)
        _ = 1 := by rw [← mul_pow]; norm_num
    apply hnorm.trans
    nlinarith [Real.pi_pos]
  · have halarge : 1/2 < a*(T+1) := lt_of_not_ge hsmall
    have hapos : 0 < a := by nlinarith
    let M : ℕ := ⌊a/Real.pi⌋₊+1
    have hMlo : a ≤ (M:ℝ)*Real.pi := by
      have hf := Nat.lt_floor_add_one (a/Real.pi)
      dsimp [M]
      push_cast
      have hh := (div_lt_iff₀ Real.pi_pos).mp hf
      linarith
    have hMhi : (M:ℝ)*Real.pi ≤ a+Real.pi := by
      have hf := Nat.floor_le (show 0 ≤ a/Real.pi by positivity)
      dsimp [M]
      push_cast
      have hh := mul_le_mul_of_nonneg_right hf Real.pi_pos.le
      have he : a/Real.pi*Real.pi=a := div_mul_cancel₀ a Real.pi_ne_zero
      rw [he] at hh
      linarith
    have hi := sinePower_unit_window_sqrt p M a T a hapos le_rfl hMlo
    apply hi.trans
    apply (div_le_iff₀ hapos).mpr
    have hprod : 2*Real.pi*(1/2) ≤ 2*Real.pi*(a*(T+1)) :=
      mul_le_mul_of_nonneg_left halarge.le (by positivity)
    nlinarith [mul_nonneg ha hT]

end NeuralGeneralization.OnlineLowerTanh
