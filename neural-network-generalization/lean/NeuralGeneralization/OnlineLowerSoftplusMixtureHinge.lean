import NeuralGeneralization.OnlineLowerReluWalshIntegral
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus

/-! A finite-interval positive hinge representation.  It applies in particular
to standard softplus, without introducing an auxiliary probability law. -/

noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerSoftplus

/-- The second derivative integrated against a hinge recovers the nonlinear
part of a twice differentiable scalar function. -/
theorem hinge_integral_representation
    (f g h : ℝ → ℝ) (hf : ∀ x, HasDerivAt f (g x) x)
    (hg : ∀ x, HasDerivAt g (h x) x) (hh : Continuous h)
    (a b t : ℝ) (hat : a ≤ t) (htb : t ≤ b) :
    (∫ s in a..b, max (t-s) 0 * h s) = f t-f a-g a*(t-a) := by
  have hc : Continuous (fun s : ℝ => max (t-s) 0*h s) :=
    ((continuous_const.sub continuous_id).max continuous_const).mul hh
  have hd (s : ℝ) : HasDerivAt (fun s => (t-s)*g s+f s) ((t-s)*h s) s := by
    convert (((hasDerivAt_const s t).sub (hasDerivAt_id s)).mul (hg s)).add (hf s) using 1 <;> first | rfl | (change (t-s)*h s = (0-1)*g s+(t-s)*h s+g s; ring)
  have hleft : (∫ s in a..t, max (t-s) 0*h s) = f t-f a-g a*(t-a) := by
    calc
      _ = ∫ s in a..t, (t-s)*h s := by
        apply intervalIntegral.integral_congr
        intro s hs
        rw [Set.uIcc_of_le hat] at hs
        dsimp only
        rw [max_eq_left (sub_nonneg.mpr hs.2)]
      _ = ((t-t)*g t+f t)-((t-a)*g a+f a) :=
        intervalIntegral.integral_eq_sub_of_hasDerivAt (fun s _ => hd s)
          (((continuous_const.sub continuous_id).mul hh).intervalIntegrable a t)
      _ = _ := by ring
  have hright : (∫ s in t..b, max (t-s) 0*h s) = 0 := by
    calc
      _ = ∫ s in t..b, (0 : ℝ) := by
        apply intervalIntegral.integral_congr
        intro s hs
        rw [Set.uIcc_of_le htb] at hs
        simp [max_eq_right (sub_nonpos.mpr hs.1)]
      _ = 0 := by simp
  rw [← intervalIntegral.integral_add_adjacent_intervals (hc.intervalIntegrable a t) (hc.intervalIntegrable t b),
    hleft, hright, add_zero]

/-- A nonnegative curvature whose slope stays in [0,1] has total mass at most one
on every finite interval. -/
theorem curvature_integral_le_one (g h : ℝ → ℝ)
    (hg : ∀ x, HasDerivAt g (h x) x) (hh : Continuous h)
    (hgl : ∀ x, 0 ≤ g x) (hgu : ∀ x, g x ≤ 1) (a b : ℝ) :
    (∫ s in a..b, h s) ≤ 1 := by
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun s _ => hg s) (hh.intervalIntegrable a b)]
  linarith [hgl a,hgu b]

end NeuralGeneralization.OnlineLowerSoftplus
