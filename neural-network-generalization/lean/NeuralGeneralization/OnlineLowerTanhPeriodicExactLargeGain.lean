import NeuralGeneralization.OnlineLowerTanhPeriodicExactRealDerivative
import NeuralGeneralization.OnlineLowerTanhPeriodicExactSmallGain
import Mathlib.Analysis.Complex.ExponentialBounds

/-! Strict monotonicity of the periodic response beyond the Fourier-dominated
range, from decreasing real-space sech-squared differences. -/
noncomputable section
set_option maxHeartbeats 800000
open scoped BigOperators
open Set Filter
namespace NeuralGeneralization.OnlineLowerTanh
open TanhDifferential

lemma tanhFirst_strict_pos (x : ℝ) : 0<tanhFirst x := by
  have h := Real.abs_tanh_lt_one x
  unfold tanhFirst
  nlinarith [sq_abs (Real.tanh x),abs_nonneg (Real.tanh x)]

lemma tanhSecond_hasDerivAt_exact (x : ℝ) :
    HasDerivAt tanhSecond (2*tanhFirst x*(3*Real.tanh x^2-1)) x := by
  have h := (((hasDerivAt_tanh_first x).const_mul (-2)).mul (hasDerivAt_tanhFirst x))
  convert h using 1 <;> first | rfl | (unfold tanhSecond tanhFirst;ring)

lemma tanhSecond_strictMonoOn : StrictMonoOn tanhSecond (Ici (1:ℝ)) := by
  apply strictMonoOn_of_hasDerivWithinAt_pos (convex_Ici _) continuous_tanhSecond.continuousOn
    (fun x _ => (tanhSecond_hasDerivAt_exact x).hasDerivWithinAt)
  intro x hx
  have hx1 : 1≤x := interior_subset hx
  have htx := scalar_tanh_monotone hx1
  have ht := tanh_one_gt_three_quarters
  have hfac : 0<3*Real.tanh x^2-1 := by nlinarith
  exact mul_pos (mul_pos (by norm_num) (tanhFirst_strict_pos x)) hfac

lemma tanhFirst_difference_strictAntiOn {h : ℝ} (hh : 0<h) :
    StrictAntiOn (fun x : ℝ => tanhFirst x-tanhFirst (x+h)) (Ici (1:ℝ)) := by
  apply strictAntiOn_of_hasDerivWithinAt_neg (convex_Ici _)
    ((continuous_tanhFirst.sub (continuous_tanhFirst.comp (continuous_id.add_const h))).continuousOn)
    (f':=fun x => tanhSecond x-tanhSecond (x+h))
  · intro x hx
    simpa only [mul_one] using ((hasDerivAt_tanhFirst x).sub
      ((hasDerivAt_tanhFirst (x+h)).comp x ((hasDerivAt_id x).add_const h))).hasDerivWithinAt (s:=interior (Ici (1:ℝ)))
  · intro x hx
    have hx1 : 1≤x := interior_subset hx
    have ht := tanhSecond_strictMonoOn hx1 (show 1≤x+h by linarith) (show x<x+h by linarith)
    linarith

lemma tanhFirst_lower_central {b : ℝ} (hb0 : 0≤b) (hb1 : b≤1) : (1:ℝ)/4<tanhFirst b := by
  have he1 := Real.exp_one_lt_three
  have hepos := Real.exp_pos 1
  have he2 : Real.exp 2 < 9 := by
    rw [show (2:ℝ)=1+1 by norm_num,Real.exp_add]
    nlinarith
  have ht1 : Real.tanh 1 < (4:ℝ)/5 := by
    rw [TanhSaturation.tanh_exp_formula]
    have he := Real.exp_pos (2*(1:ℝ))
    norm_num at *
    have hdiv : (1:ℝ)/5 < 2/(Real.exp 2+1) := (lt_div_iff₀ (by positivity)).mpr (by linarith)
    linarith
  have ht0 : 0≤Real.tanh b := by simpa using scalar_tanh_monotone hb0
  have htupper := (scalar_tanh_monotone hb1).trans_lt ht1
  unfold tanhFirst
  nlinarith

lemma tanhFirst_le_four_49 {x : ℝ} (hx : 2≤x) : tanhFirst x ≤ (4:ℝ)/49 := by
  have he2 := exp_neg_two_le_seventh 1 (by norm_num)
  norm_num at he2
  have he4 : Real.exp (-4) ≤ (1:ℝ)/49 := by
    have hid : Real.exp (-4)=Real.exp (-2)*Real.exp (-2) := by rw [←Real.exp_add];norm_num
    rw [hid]
    nlinarith [Real.exp_pos (-2)]
  have hxexp : Real.exp (-2*x)≤Real.exp (-4) := Real.exp_le_exp.mpr (by linarith)
  have h := tanhFirst_exp_tail x
  linarith

theorem periodic_derivative_pos_large_gain_nonnegative {a b : ℝ} (ha : 2≤a)
    (hb0 : 0≤b) (hba : b<a) : 0<periodicFourierDerivative a b := by
  let D : ℕ → ℝ := fun j => tanhFirst (b+2*a*j)-tanhFirst (2*a-b+2*a*j)
  have ha0 : 0<a := by linarith
  have hh : 0<2*(a-b) := by linarith
  have hdec := tanhFirst_difference_strictAntiOn hh
  have hstrict (j : ℕ) (hj : 1≤b+2*a*j) : D (j+1)<D j := by
    have h := hdec hj (show 1≤b+2*a*((j+1:ℕ):ℝ) by push_cast;nlinarith [Nat.cast_nonneg (α:=ℝ) j])
      (show b+2*a*(j:ℝ)<b+2*a*((j+1:ℕ):ℝ) by push_cast;nlinarith)
    dsimp [D]
    convert h using 1 <;> congr 1 <;> ring
  have hfirst : D 1<D 0 := by
    by_cases hb1 : 1≤b
    · exact hstrict 0 (by simpa using hb1)
    · have hb1' : b≤1 := le_of_not_ge hb1
      have hlow := tanhFirst_lower_central hb0 hb1'
      have htail1 := tanhFirst_le_four_49 (x:=2*a-b) (by linarith)
      have htail2 := tanhFirst_le_four_49 (x:=b+2*a) (by linarith)
      have hlast := tanhFirst_nonneg (4*a-b)
      dsimp [D]
      norm_num
      have he : 2*a-b+2*a=4*a-b := by ring
      rw [he]
      linarith
  have hmono : Antitone D := antitone_nat_of_succ_le (fun j => by
    rcases Nat.eq_zero_or_pos j with rfl|hj
    · exact hfirst.le
    · apply (hstrict j _).le
      have hjR:(1:ℝ)≤j := by exact_mod_cast hj
      nlinarith)
  have hs : Summable (fun j : ℕ => (-1:ℝ)^j*D j) := by
    apply ((first_tanh_tail_summable ha0 b).sub (first_tanh_tail_summable ha0 (2*a-b))).congr
    intro j
    dsimp [D]
    ring
  have hl := hmono.alternating_series_le_tendsto hs.hasSum.tendsto_sum_nat 1
  norm_num [Finset.sum_range_succ] at hl
  rw [periodicFourierDerivative_eq_real_paired ha0]
  change 0<∑'j,(-1:ℝ)^j*D j
  linarith

end NeuralGeneralization.OnlineLowerTanh
