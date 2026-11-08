import NeuralGeneralization.OnlineLowerTanhSinePowers
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Periodic

/-! # Uniform interval bounds for sine powers

The bound is uniform in the starting point of the interval and in the
natural exponent.  It is the finite-window input to parity localization.
-/
noncomputable section
open MeasureTheory Set intervalIntegral
namespace NeuralGeneralization.OnlineLowerTanh

theorem abs_sinePower_periodic (p : ℕ) :
    Function.Periodic (fun t : ℝ => |Real.sin t| ^ p) Real.pi := by
  intro t
  simp [Real.sin_add_pi]

theorem integral_abs_sinePower_period (p : ℕ) (t : ℝ) :
    (∫ x in t..t + Real.pi, |Real.sin x| ^ p) = sinePowerMass p := by
  rw [(abs_sinePower_periodic p).intervalIntegral_add_eq t 0]
  simp only [zero_add, sinePowerMass]
  apply integral_congr
  intro x hx
  rw [uIcc_of_le Real.pi_pos.le] at hx
  dsimp only
  rw [abs_of_nonneg (Real.sin_nonneg_of_mem_Icc hx)]

theorem integral_abs_sinePower_periods (p M : ℕ) (t : ℝ) :
    (∫ x in t..t + (M:ℝ)*Real.pi, |Real.sin x| ^ p) =
      (M:ℝ)*sinePowerMass p := by
  have h := (abs_sinePower_periodic p).intervalIntegral_add_zsmul_eq
    (M:ℤ) t (fun _ _ => (by fun_prop : Continuous (fun x : ℝ => |Real.sin x|^p)).intervalIntegrable _ _)
  simpa only [zsmul_eq_mul, Int.cast_natCast, integral_abs_sinePower_period] using h

/-- A compact range of nonzero frequencies gives a uniform periodic mass
bound on every unit interval. -/
theorem sinePower_unit_window (p M : ℕ) (a T : ℝ)
    (ha : 0 < a) (hM : a ≤ (M:ℝ)*Real.pi) :
    a * (∫ t in T..T+1, |Real.sin (a*t)|^p) ≤ (M:ℝ)*sinePowerMass p := by
  change a * (∫ t in T..T+1, (fun x : ℝ => |Real.sin x|^p) (a*t)) ≤ _
  rw [mul_integral_comp_mul_left (f := fun x : ℝ => |Real.sin x|^p) (a := T) (b := T+1) a]
  calc
    (∫ t in a*T..a*(T+1), |Real.sin t|^p) ≤
        ∫ t in a*T..a*T+(M:ℝ)*Real.pi, |Real.sin t|^p := by
      apply integral_mono_interval le_rfl (by nlinarith) (by nlinarith)
      · exact Filter.Eventually.of_forall (fun _ => pow_nonneg (abs_nonneg _) _)
      · exact (by fun_prop : Continuous (fun t : ℝ => |Real.sin t|^p)).intervalIntegrable _ _
    _ = (M:ℝ)*sinePowerMass p := integral_abs_sinePower_periods p M (a*T)

/-- Square-root-normalized unit-window bound, with an explicit compact-range
constant.  The degree need not be odd. -/
theorem sinePower_unit_window_sqrt (p M : ℕ) (a T b : ℝ)
    (hb : 0 < b) (hba : b ≤ a) (hM : a ≤ (M:ℝ)*Real.pi) :
    Real.sqrt (p:ℝ) * (∫ t in T..T+1, |Real.sin (a*t)|^p) ≤ (M:ℝ)*Real.pi/b := by
  have ha := lt_of_lt_of_le hb hba
  have hI : 0 ≤ ∫ t in T..T+1, |Real.sin (a*t)|^p := by
    apply integral_nonneg (by linarith)
    intro t _
    exact pow_nonneg (abs_nonneg _) _
  have hbound := sinePower_unit_window p M a T ha hM
  have hroot := Real.sqrt_nonneg (p:ℝ)
  have hnorm := sqrt_mul_sinePowerMass_le_pi p
  apply (le_div_iff₀ hb).mpr
  calc
    Real.sqrt (p:ℝ) * (∫ t in T..T+1, |Real.sin (a*t)|^p) * b ≤
        Real.sqrt (p:ℝ) * (a * (∫ t in T..T+1, |Real.sin (a*t)|^p)) := by
      nlinarith [mul_nonneg hroot hI]
    _ ≤ Real.sqrt (p:ℝ) * ((M:ℝ)*sinePowerMass p) :=
      mul_le_mul_of_nonneg_left hbound hroot
    _ = (M:ℝ)*(Real.sqrt (p:ℝ)*sinePowerMass p) := by ring
    _ ≤ (M:ℝ)*Real.pi := mul_le_mul_of_nonneg_left hnorm (Nat.cast_nonneg M)

end NeuralGeneralization.OnlineLowerTanh
