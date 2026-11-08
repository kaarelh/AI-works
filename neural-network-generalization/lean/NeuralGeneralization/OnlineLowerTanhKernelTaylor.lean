import NeuralGeneralization.OnlineLowerTanhResidualParameters
import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Analysis.Complex.ExponentialBounds

/-! # Uniform Taylor bounds for the actual csch kernel on sine cells -/

noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology Classical
open Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

/-- First derivative of the literal kernel used in the residual cell integrals. -/
def residualKernelFirst (t : ℝ) : ℝ :=
  -(Real.pi / 2) * (Real.cosh (Real.pi*t/2) / Real.sinh (Real.pi*t/2)^2)

/-- The second derivative is positive on the positive half-line. -/
def residualKernelSecond (t : ℝ) : ℝ :=
  (Real.pi / 2)^2 * ((Real.cosh (Real.pi*t/2)^2 + 1) / Real.sinh (Real.pi*t/2)^3)

lemma residualKernel_hasDerivAt {t : ℝ} (ht : 0 < t) :
    HasDerivAt (residualDerivativeKernel 0) (residualKernelFirst t) t := by
  have hs : Real.sinh (Real.pi*t/2) ≠ 0 := (Real.sinh_pos_iff.mpr (by positivity)).ne'
  have hi : HasDerivAt (fun x : ℝ => Real.pi*x/2) (Real.pi/2) t := by
    convert ((hasDerivAt_id t).const_mul Real.pi).div_const 2 using 1 <;> first | rfl | ring
  have hh := (hasDerivAt_const t (1 : ℝ)).div hi.sinh hs
  change HasDerivAt (fun x : ℝ => 1 / Real.sinh (Real.pi*x/2)) _ t
  convert hh using 1 <;> first | rfl | (dsimp only [residualKernelFirst]; ring)

lemma residualKernelFirst_hasDerivAt {t : ℝ} (ht : 0 < t) :
    HasDerivAt residualKernelFirst (residualKernelSecond t) t := by
  have hs : Real.sinh (Real.pi*t/2) ≠ 0 := (Real.sinh_pos_iff.mpr (by positivity)).ne'
  have hi : HasDerivAt (fun x : ℝ => Real.pi*x/2) (Real.pi/2) t := by
    convert ((hasDerivAt_id t).const_mul Real.pi).div_const 2 using 1 <;> first | rfl | ring
  have hh := (hi.cosh.div (hi.sinh.pow 2) (pow_ne_zero 2 hs)).const_mul (-(Real.pi/2))
  change HasDerivAt (fun x : ℝ => -(Real.pi/2) *
    (Real.cosh (Real.pi*x/2) / Real.sinh (Real.pi*x/2)^2)) _ t
  convert hh using 1 <;> try rfl
  dsimp only [residualKernelSecond, Pi.pow_apply]
  norm_num only [Nat.cast_ofNat, Nat.reduceSub, pow_one]
  field_simp
  have hid := Real.cosh_sq_sub_sinh_sq (Real.pi*t/2)
  nlinarith

lemma sinh_quarter_exp_lower {x : ℝ} (hx : (1 : ℝ)/2 ≤ x) :
    Real.exp x / 4 ≤ Real.sinh x := by
  have htw : (2 : ℝ) ≤ Real.exp (2*x) :=
    Real.exp_one_gt_two.le.trans (Real.exp_le_exp.mpr (by linarith))
  have hex : 0 < Real.exp x := Real.exp_pos x
  have hprod : Real.exp (-x) * Real.exp x = 1 := by rw [← Real.exp_add]; simp
  have hsq : Real.exp (2*x) = Real.exp x * Real.exp x := by rw [two_mul, Real.exp_add]
  rw [hsq] at htw
  rw [Real.sinh_eq]
  have hsmall : Real.exp (-x) ≤ Real.exp x / 2 := by nlinarith
  linarith

lemma cosh_le_exp_nonneg {x : ℝ} (hx : 0 ≤ x) : Real.cosh x ≤ Real.exp x := by
  rw [Real.cosh_eq]
  have hh := Real.exp_le_exp.mpr (show -x ≤ x by linarith)
  linarith

lemma sinh_reciprocal_bound {x : ℝ} (hx : (1 : ℝ)/2 ≤ x) :
    1 / Real.sinh x ≤ 4 * Real.exp (-x) := by
  have hs : 0 < Real.sinh x := Real.sinh_pos_iff.mpr (by linarith)
  apply (div_le_iff₀ hs).mpr
  have hh := mul_le_mul_of_nonneg_right (sinh_quarter_exp_lower hx)
    (show 0 ≤ 4*Real.exp (-x) by positivity)
  have he : Real.exp x * Real.exp (-x) = 1 := by rw [← Real.exp_add]; simp
  nlinarith

lemma coth_le_four {x : ℝ} (hx : (1 : ℝ)/2 ≤ x) :
    Real.cosh x / Real.sinh x ≤ 4 := by
  have hs : 0 < Real.sinh x := Real.sinh_pos_iff.mpr (by linarith)
  apply (div_le_iff₀ hs).mpr
  have hh := sinh_quarter_exp_lower hx
  have hc := cosh_le_exp_nonneg (show 0 ≤ x by linarith)
  linarith

lemma kernel_cutoff_argument {t : ℝ} (ht : Real.pi/8 ≤ t) :
    0 < t ∧ (1 : ℝ)/2 ≤ Real.pi*t/2 ∧ t ≤ Real.pi*t/2 := by
  have hp := Real.pi_gt_three
  have ht0 : 0 < t := lt_of_lt_of_le (by positivity) ht
  have hmul := mul_le_mul_of_nonneg_left ht Real.pi_pos.le
  refine ⟨ht0, ?_, ?_⟩ <;> nlinarith

/-- Explicit pointwise bounds, uniform away from the singular endpoint. -/
theorem residualKernel_cutoff_bounds {t : ℝ} (ht : Real.pi/8 ≤ t) :
    |residualDerivativeKernel 0 t| ≤ 4 * Real.exp (-t) ∧
    |residualKernelFirst t| ≤ 32 * Real.exp (-t) ∧
    |residualKernelSecond t| ≤ 512 * Real.exp (-t) := by
  obtain ⟨ht0, hx, htx⟩ := kernel_cutoff_argument ht
  let x := Real.pi*t/2
  have hx0 : 0 < x := by dsimp [x]; positivity
  have hs : 0 < Real.sinh x := Real.sinh_pos_iff.mpr hx0
  have hc : 0 < Real.cosh x := Real.cosh_pos x
  have hK : 0 ≤ 1 / Real.sinh x := by positivity
  have hC : 0 ≤ Real.cosh x / Real.sinh x := by positivity
  have hKbound := sinh_reciprocal_bound hx
  have hCbound := coth_le_four hx
  have he : Real.exp (-x) ≤ Real.exp (-t) := Real.exp_le_exp.mpr (by dsimp [x]; linarith)
  have he1 : Real.exp (-x) ≤ 1 := by simpa using Real.exp_le_exp.mpr (show -x ≤ 0 by linarith)
  have hK4 : 1 / Real.sinh x ≤ 4 := le_trans hKbound (by nlinarith)
  have hpi : 0 ≤ Real.pi/2 ∧ Real.pi/2 ≤ 2 := ⟨by positivity, by linarith [Real.pi_lt_four]⟩
  have hfirst : residualKernelFirst t = -(Real.pi/2) * (Real.cosh x / Real.sinh x) *
      (1 / Real.sinh x) := by dsimp [residualKernelFirst, x]; ring
  have hsecond : residualKernelSecond t = (Real.pi/2)^2 *
      ((Real.cosh x / Real.sinh x)^2 + (1 / Real.sinh x)^2) *
      (1 / Real.sinh x) := by dsimp [residualKernelSecond, x]; ring
  have hsum : (Real.cosh x / Real.sinh x)^2 + (1 / Real.sinh x)^2 ≤ 32 := by
    nlinarith
  have hsecondNonneg : 0 ≤ residualKernelSecond t := by rw [hsecond]; positivity
  have hfirstNonpos : residualKernelFirst t ≤ 0 := by
    rw [hfirst]
    exact mul_nonpos_of_nonpos_of_nonneg
      (mul_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr hpi.1) hC) hK
  refine ⟨?_, ?_, ?_⟩
  · change |1 / Real.sinh x| ≤ _
    rw [abs_of_nonneg hK]
    exact hKbound.trans (by nlinarith)
  · rw [abs_of_nonpos hfirstNonpos, hfirst]
    calc
      _ = (Real.pi/2) * (Real.cosh x / Real.sinh x) * (1 / Real.sinh x) := by ring
      _ ≤ 2 * 4 * (4 * Real.exp (-x)) := by
        gcongr
        exact hpi.2
      _ ≤ 32 * Real.exp (-t) := by nlinarith
  · rw [abs_of_nonneg hsecondNonneg, hsecond]
    calc
      _ ≤ 4 * 32 * (4 * Real.exp (-x)) := by
        gcongr
        nlinarith
      _ ≤ 512 * Real.exp (-t) := by nlinarith


/-- A convenient second-order remainder bound from two applications of the
one-dimensional mean value inequality. The constant is deliberately unoptimized. -/
lemma second_derivative_remainder_bound
    (f f' f'' : ℝ → ℝ) (c y B : ℝ) (hB : 0 ≤ B)
    (hf : ∀ z ∈ uIcc c y, HasDerivAt f (f' z) z)
    (hf' : ∀ z ∈ uIcc c y, HasDerivAt f' (f'' z) z)
    (hbound : ∀ z ∈ uIcc c y, |f'' z| ≤ B) :
    |f y - f c - f' c * (y-c)| ≤ B * (y-c)^2 := by
  have hderiv (z : ℝ) (hz : z ∈ uIcc c y) :
      |f' z - f' c| ≤ B * |z-c| := by
    simpa only [Real.norm_eq_abs] using
      Convex.norm_image_sub_le_of_norm_hasDerivWithin_le
        (fun w hw => (hf' w hw).hasDerivWithinAt)
        (fun w hw => by simpa only [Real.norm_eq_abs] using hbound w hw)
        (convex_uIcc c y) (left_mem_uIcc : c ∈ uIcc c y) hz
  let F := fun z => f z - f c - f' c * (z-c)
  have hF (z : ℝ) (hz : z ∈ uIcc c y) :
      HasDerivWithinAt F (f' z - f' c) (uIcc c y) z := by
    have hh := ((hf z hz).sub_const (f c)).sub
      (((hasDerivAt_id z).sub_const c).const_mul (f' c))
    convert hh.hasDerivWithinAt using 1 <;> first | rfl | simp [F]
  have hFB (z : ℝ) (hz : z ∈ uIcc c y) : ‖f' z - f' c‖ ≤ B * |y-c| := by
    rw [Real.norm_eq_abs]
    exact (hderiv z hz).trans (mul_le_mul_of_nonneg_left (abs_sub_left_of_mem_uIcc hz) hB)
  have hh := Convex.norm_image_sub_le_of_norm_hasDerivWithin_le hF hFB
    (convex_uIcc c y) (left_mem_uIcc : c ∈ uIcc c y) (right_mem_uIcc : y ∈ uIcc c y)
  simpa [F, Real.norm_eq_abs, mul_assoc, ← sq, sq_abs] using hh

lemma residualPeak_cell_lower {a x : ℝ} (ha : 1 ≤ a) (ha2 : a ≤ 2)
    (l : ℕ) (hx : |x| ≤ Real.pi/(2*a)) :
    (l : ℝ) ≤ residualPeak a l + x := by
  have ha0 : 0 < a := by linarith
  have hleft := (abs_le.mp hx).1
  have hid : residualPeak a l - Real.pi/(2*a) = (l : ℝ)*Real.pi/a := by
    unfold residualPeak periodicFrequency
    field_simp
    <;> ring
  have hl : (l : ℝ) ≤ (l : ℝ)*Real.pi/a := by
    apply (le_div_iff₀ ha0).mpr
    have hl0 : (0 : ℝ) ≤ l := by positivity
    nlinarith [Real.pi_gt_three]
  linarith

/-- The cutoff kernel and both derivatives have a summable envelope over
all physical sine cells, uniformly in the spacing in `[1,2]`. -/
theorem residualKernel_cell_bounds {a x : ℝ} (ha : 1 ≤ a) (ha2 : a ≤ 2)
    (l : ℕ) (hx : |x| ≤ Real.pi/(2*a))
    (hcut : Real.pi/8 ≤ residualPeak a l+x) :
    |residualDerivativeKernel 0 (residualPeak a l+x)| ≤ 4 * Real.exp (-(l : ℝ)) ∧
    |residualKernelFirst (residualPeak a l+x)| ≤ 32 * Real.exp (-(l : ℝ)) ∧
    |residualKernelSecond (residualPeak a l+x)| ≤ 512 * Real.exp (-(l : ℝ)) := by
  obtain ⟨h0, h1, h2⟩ := residualKernel_cutoff_bounds hcut
  have he := Real.exp_le_exp.mpr (neg_le_neg (residualPeak_cell_lower ha ha2 l hx))
  exact ⟨h0.trans (by nlinarith), h1.trans (by nlinarith), h2.trans (by nlinarith)⟩

lemma residualPeak_above_cutoff {a : ℝ} (ha : 1 ≤ a) (ha2 : a ≤ 2) (l : ℕ) :
    Real.pi/8 ≤ residualPeak a l := by
  have hh := residualPeak_lower (show 0 < a by linarith) ha2 l
  have hp := Real.pi_pos
  norm_num at hh
  linarith

/-- The actual csch kernel has a uniform quadratic remainder after its
constant and linear terms are removed on every cutoff sine cell. -/
theorem residualKernel_cell_taylor {a x : ℝ} (ha : 1 ≤ a) (ha2 : a ≤ 2)
    (l : ℕ) (hx : |x| ≤ Real.pi/(2*a))
    (hcut : Real.pi/8 ≤ residualPeak a l+x) :
    |residualDerivativeKernel 0 (residualPeak a l+x) -
      residualDerivativeKernel 0 (residualPeak a l) - residualKernelFirst (residualPeak a l)*x| ≤
        512 * Real.exp (-(l : ℝ)) * x^2 := by
  have hc := residualPeak_above_cutoff ha ha2 l
  have hseg (z : ℝ) (hz : z ∈ uIcc (residualPeak a l) (residualPeak a l+x)) :
      Real.pi/8 ≤ z ∧ |z-residualPeak a l| ≤ Real.pi/(2*a) := by
    constructor
    · exact le_trans (le_min hc hcut) hz.1
    · exact (abs_sub_left_of_mem_uIcc hz).trans (by simpa using hx)
  have ht (z : ℝ) (hz : z ∈ uIcc (residualPeak a l) (residualPeak a l+x)) : 0 < z :=
    lt_of_lt_of_le (by positivity : (0 : ℝ) < Real.pi/8) (hseg z hz).1
  have hbound (z : ℝ) (hz : z ∈ uIcc (residualPeak a l) (residualPeak a l+x)) :
      |residualKernelSecond z| ≤ 512 * Real.exp (-(l : ℝ)) := by
    have hh := (residualKernel_cell_bounds ha ha2 l (hseg z hz).2
      (by simpa using (hseg z hz).1)).2.2
    simpa using hh
  have hh := second_derivative_remainder_bound (residualDerivativeKernel 0)
    residualKernelFirst residualKernelSecond (residualPeak a l) (residualPeak a l+x)
    (512*Real.exp (-(l : ℝ))) (by positivity)
    (fun z hz => residualKernel_hasDerivAt (ht z hz))
    (fun z hz => residualKernelFirst_hasDerivAt (ht z hz)) hbound
  simpa only [add_sub_cancel_left] using hh


lemma residualKernel_center_bounds {a : ℝ} (ha : 1 ≤ a) (ha2 : a ≤ 2) (l : ℕ) :
    |residualDerivativeKernel 0 (residualPeak a l)| ≤ 4 * Real.exp (-(l : ℝ)) ∧
    |residualKernelFirst (residualPeak a l)| ≤ 32 * Real.exp (-(l : ℝ)) ∧
    |residualKernelSecond (residualPeak a l)| ≤ 512 * Real.exp (-(l : ℝ)) := by
  have ha0 : 0 < a := by linarith
  simpa only [add_zero] using residualKernel_cell_bounds (x := 0) ha ha2 l
    (by simp; positivity) (by simpa using residualPeak_above_cutoff ha ha2 l)

lemma residualKernel_envelope_summable (C : ℝ) :
    Summable (fun l : ℕ => C * Real.exp (-(l : ℝ))) := by
  have hh := Real.summable_exp_nat_mul_iff.mpr (show (-1 : ℝ) < 0 by norm_num)
  simpa only [mul_neg_one] using hh.mul_left C

/-- The singular endpoint is harmless for a positive sine power: after
removing one sine factor, the entire cutoff interval is exponentially small. -/
lemma residualKernel_small_interval_pointwise {a t : ℝ} (ha : 1 ≤ a) (ha2 : a ≤ 2)
    (ht : 0 < t) (htcut : t ≤ Real.pi/8) (n : ℕ) :
    |Real.sin (a*t)^(n+1) / Real.sinh (Real.pi*t/2)| ≤
      (4/Real.pi) * (Real.pi/4)^n := by
  have ha0 : 0 < a := by linarith
  have hs : 0 < Real.sinh (Real.pi*t/2) := Real.sinh_pos_iff.mpr (by positivity)
  have hl : Real.pi*t/2 ≤ Real.sinh (Real.pi*t/2) :=
    Real.self_le_sinh_iff.mpr (by positivity)
  have htK : t / Real.sinh (Real.pi*t/2) ≤ 2/Real.pi := by
    apply (div_le_iff₀ hs).mpr
    have hh := mul_le_mul_of_nonneg_left hl (show 0 ≤ 2/Real.pi by positivity)
    have hid : (2/Real.pi)*(Real.pi*t/2) = t := by field_simp
    rw [hid] at hh
    exact hh
  have hsin : |Real.sin (a*t)| ≤ a*t := by
    simpa only [abs_of_pos (mul_pos ha0 ht)] using (Real.abs_sin_le_abs (x := a*t))
  have hat : a*t ≤ Real.pi/4 := by nlinarith
  rw [abs_div, abs_pow, abs_of_pos hs]
  calc
    _ ≤ (a*t)^(n+1) / Real.sinh (Real.pi*t/2) :=
      div_le_div_of_nonneg_right (pow_le_pow_left₀ (abs_nonneg _) hsin _) hs.le
    _ = a * (a*t)^n * (t / Real.sinh (Real.pi*t/2)) := by rw [pow_succ]; ring
    _ ≤ 2 * (Real.pi/4)^n * (2/Real.pi) := by
      gcongr
    _ = _ := by ring

lemma residualKernel_small_interval_integral {a : ℝ} (ha : 1 ≤ a) (ha2 : a ≤ 2)
    (n : ℕ) :
    |∫ t in (0 : ℝ)..(Real.pi/8),
        Real.sin (a*t)^(n+1) / Real.sinh (Real.pi*t/2)| ≤
      (1/2 : ℝ) * (Real.pi/4)^n := by
  have hnorm := intervalIntegral.norm_integral_le_of_norm_le_const
    (a := (0 : ℝ)) (b := Real.pi/8)
    (f := fun t => Real.sin (a*t)^(n+1) / Real.sinh (Real.pi*t/2))
    (C := (4/Real.pi)*(Real.pi/4)^n) (fun t ht => by
      rw [Set.uIoc_of_le (show (0 : ℝ) ≤ Real.pi/8 by positivity)] at ht
      simpa only [Real.norm_eq_abs] using residualKernel_small_interval_pointwise ha ha2 ht.1 ht.2 n)
  rw [Real.norm_eq_abs, sub_zero, abs_of_pos (show 0 < Real.pi/8 by positivity)] at hnorm
  have hid : (4/Real.pi)*(Real.pi/4)^n*(Real.pi/8) = (1/2 : ℝ)*(Real.pi/4)^n := by
    field_simp
    <;> ring
  simpa only [hid] using hnorm

end NeuralGeneralization.OnlineLowerTanh
