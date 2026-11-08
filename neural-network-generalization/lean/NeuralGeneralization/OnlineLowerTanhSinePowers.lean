import Mathlib.Analysis.SpecialFunctions.Integrals.Basic
import Mathlib.Analysis.Real.Pi.Bounds
import Mathlib.Analysis.Real.Sqrt
import Mathlib.Tactic

/-! # Uniform mass bounds for powers of the sine

The exponent is an arbitrary natural number; the localization estimates
for even and odd selected degrees use the same scalar bound.
-/
noncomputable section
open scoped Real
open intervalIntegral
namespace NeuralGeneralization.OnlineLowerTanh

def sinePowerMass (p : ℕ) : ℝ := ∫ t : ℝ in 0..Real.pi, Real.sin t ^ p

theorem sinePowerMass_pos (p : ℕ) : 0 < sinePowerMass p := integral_sin_pow_pos p

theorem sinePowerMass_antitone : Antitone sinePowerMass := integral_sin_pow_antitone

@[simp] theorem sinePowerMass_zero : sinePowerMass 0 = Real.pi := by
  simp [sinePowerMass]

@[simp] theorem sinePowerMass_one : sinePowerMass 1 = 2 := by
  norm_num [sinePowerMass]

theorem sinePowerMass_recurrence (p : ℕ) :
    sinePowerMass (p+2) = ((p:ℝ)+1)/((p:ℝ)+2)*sinePowerMass p := by
  unfold sinePowerMass
  rw [integral_sin_pow]
  simp

/-- An elementary Wallis bound, proved directly from the two-step
integration-by-parts recurrence. -/
theorem sinePowerMass_square_bound (p : ℕ) :
    ((p:ℝ)+1)*sinePowerMass p ^ 2 ≤ Real.pi ^ 2 := by
  induction p using Nat.twoStepInduction with
  | zero => simp
  | one =>
    have hp := Real.pi_gt_three
    norm_num
    nlinarith
  | more p hp hp1 =>
    rw [sinePowerMass_recurrence]
    push_cast
    have hden : 0 < (p:ℝ)+2 := by positivity
    have hfactor : ((p:ℝ)+3)*(((p:ℝ)+1)/((p:ℝ)+2))^2 ≤ (p:ℝ)+1 := by
      have hn : ((p:ℝ)+3)*((p:ℝ)+1)^2 ≤ ((p:ℝ)+1)*((p:ℝ)+2)^2 := by
        nlinarith [Nat.cast_nonneg (α:=ℝ) p]
      rw [div_pow, ← mul_div_assoc]
      exact (div_le_iff₀ (sq_pos_of_pos hden)).mpr hn
    calc
      ((p:ℝ)+2+1)*(((p:ℝ)+1)/((p:ℝ)+2)*sinePowerMass p)^2 =
          (((p:ℝ)+3)*(((p:ℝ)+1)/((p:ℝ)+2))^2)*sinePowerMass p^2 := by ring
      _ ≤ ((p:ℝ)+1)*sinePowerMass p^2 := mul_le_mul_of_nonneg_right hfactor (sq_nonneg _)
      _ ≤ Real.pi^2 := hp

/-- Dimension-free square-root normalization of the periodic sine mass. -/
theorem sqrt_mul_sinePowerMass_le_pi (p : ℕ) :
    Real.sqrt (p:ℝ) * sinePowerMass p ≤ Real.pi := by
  have hs := sinePowerMass_square_bound p
  have he := Real.sq_sqrt (Nat.cast_nonneg (α:=ℝ) p)
  have hM := (sinePowerMass_pos p).le
  have hroot := Real.sqrt_nonneg (p:ℝ)
  have hp := Real.pi_pos
  nlinarith [sq_nonneg (sinePowerMass p),
    mul_nonneg hroot hM,
    show (Real.sqrt (p:ℝ)*sinePowerMass p)^2 = (p:ℝ)*sinePowerMass p^2 by
      rw [mul_pow,he]]

end NeuralGeneralization.OnlineLowerTanh
