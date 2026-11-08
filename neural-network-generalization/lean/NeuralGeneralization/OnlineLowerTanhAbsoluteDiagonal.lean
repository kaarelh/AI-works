import NeuralGeneralization.OnlineLowerTanhLaplaceAbsolute
import NeuralGeneralization.OnlineLowerTanhLaplace
import NeuralGeneralization.OnlineLowerTanhAbsoluteMoment

/-! # Diagonal comparison via the exact positive Laplace kernel -/
noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

theorem laplaceAbsSinePower_nonneg (p : ℕ) (c a : ℝ) :
    0 ≤ laplaceAbsSinePower p c a := by
  apply integral_nonneg
  intro t
  exact mul_nonneg (Real.exp_pos _).le (pow_nonneg (abs_nonneg _) _)

theorem laplace_abs_recurrence (p : ℕ) (hp : Odd p)
    (c a : ℝ) (hc : 0 < c) (ha : 0 < a) :
    (c^2+((p:ℝ)+2)^2*a^2)*laplaceAbsSinePower (p+2) c a =
      ((p:ℝ)+2)*((p:ℝ)+1)*a^2*laplaceAbsSinePower p c a := by
  rw [laplace_abs_eq_factor_signed (p+2) (hp.add_even (by decide : Even 2)) c a hc ha,
    laplace_abs_eq_factor_signed p hp c a hc ha]
  have h := sinePower_laplace_recurrence p a c hc
  change (c^2+((p+2:ℕ):ℝ)^2*a^2)*laplaceSinePower (p+2) c a =
      ((p+2:ℕ):ℝ)*((p+1:ℕ):ℝ)*a^2*laplaceSinePower p c a at h
  push_cast at h
  calc
    _ = ((1+Real.exp (-c*(Real.pi/a)))/(1-Real.exp (-c*(Real.pi/a)))) *
      ((c^2+((p:ℝ)+2)^2*a^2)*laplaceSinePower (p+2) c a) := by ring
    _ = _ := by rw [h]; ring

/-- Each two-step increase of an odd exponent loses at least the same
factor as its unweighted periodic sine mass. -/
theorem laplace_abs_step_le (p : ℕ) (hp : Odd p)
    (c a : ℝ) (hc : 0 < c) (ha : 0 < a) :
    laplaceAbsSinePower (p+2) c a ≤
      ((p:ℝ)+1)/((p:ℝ)+2)*laplaceAbsSinePower p c a := by
  have h := laplace_abs_recurrence p hp c a hc ha
  have hn := laplaceAbsSinePower_nonneg (p+2) c a
  have hfac : 0 < ((p:ℝ)+2)*a^2 := mul_pos (by positivity) (sq_pos_of_pos ha)
  have hlin : ((p:ℝ)+2)*laplaceAbsSinePower (p+2) c a ≤
      ((p:ℝ)+1)*laplaceAbsSinePower p c a := by
    apply (mul_le_mul_iff_right₀ hfac).mp
    nlinarith [mul_nonneg (sq_nonneg c) hn]
  rw [div_mul_eq_mul_div]
  exact (le_div_iff₀ (show 0 < (p:ℝ)+2 by positivity)).mpr (by nlinarith)

/-- Uniform normalized comparison down to the third sine power, before
integrating over the positive csch mixture. -/
theorem laplace_abs_odd_diagonal (k : ℕ) (c a : ℝ) (hc : 0 < c) (ha : 0 < a) :
    laplaceAbsSinePower (2*k+3) c a * sinePowerMass 3 ≤
      sinePowerMass (2*k+3) * laplaceAbsSinePower 3 c a := by
  induction k with
  | zero => simp [mul_comm]
  | succ k ih =>
    have hodd : Odd (2*k+3) := ⟨k+1,by omega⟩
    have hs := laplace_abs_step_le (2*k+3) hodd c a hc ha
    have hi := mul_le_mul_of_nonneg_left ih
      (show 0 ≤ (((2*k+3:ℕ):ℝ)+1)/(((2*k+3:ℕ):ℝ)+2) by positivity)
    have hm := mul_le_mul_of_nonneg_right hs (sinePowerMass_pos 3).le
    have he : 2*(k+1)+3 = (2*k+3)+2 := by omega
    rw [he,sinePowerMass_recurrence (2*k+3)]
    simpa only [mul_assoc] using hm.trans (by simpa only [mul_assoc] using hi)

end NeuralGeneralization.OnlineLowerTanh
