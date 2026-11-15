import NeuralGeneralization.OnlineLowerTanhInverseLaplaceBasics

/-! # Bromwich contour shifting with a quadratic analytic remainder -/
noncomputable section
open scoped Topology FourierTransform
open Filter Set MeasureTheory Complex
namespace NeuralGeneralization.OnlineLowerTanh.HalfPlaneQuadraticRemainder
variable {E : ℂ → ℂ} {a K : ℝ} (H : HalfPlaneQuadraticRemainder E a K)

include H

lemma constant_nonneg : 0 ≤ K := by
  let c := max (a+1) 1
  have hc : a<c := lt_of_lt_of_le (by linarith) (le_max_left _ _)
  have hc0 : 0<c := lt_of_lt_of_le zero_lt_one (le_max_right _ _)
  have h := H.bound (c:ℂ) (by simpa using hc)
  have hn : 0<‖(c:ℂ)‖^2 := pow_pos (norm_pos_iff.mpr (by exact_mod_cast hc0.ne')) _
  simpa using (le_div_iff₀ hn).1 ((norm_nonneg _).trans h)

def horizontal (c d t y : ℝ) : ℂ := ∫ x in c..d, H.vertical x t y

lemma norm_horizontal_le {c d : ℝ} (hc : a<c) (hcd : c≤d) (t y : ℝ) (hy : y≠0) :
    ‖H.horizontal c d t y‖ ≤
      K*Real.exp ((|c|+|d|)*|t|)*|d-c| / y^2 := by
  have hy2 : 0<y^2 := sq_pos_of_ne_zero hy
  unfold horizontal
  calc
    _ ≤ (K*Real.exp ((|c|+|d|)*|t|)/y^2)*|d-c| := by
      apply intervalIntegral.norm_integral_le_of_norm_le_const
      intro x hx
      have hx' : x∈Icc c d := by simpa only [uIcc_of_le hcd] using uIoc_subset_uIcc hx
      have hxc : a<x := hc.trans_le hx'.1
      have habs : |x| ≤ |c|+|d| := by
        rw [abs_le]
        constructor
        · have := neg_abs_le c; have := abs_nonneg d; linarith [hx'.1]
        · have := le_abs_self d; have := abs_nonneg c; linarith [hx'.2]
      have hxt : x*t ≤ (|c|+|d|)*|t| :=
        (le_abs_self _).trans (by rw [abs_mul]; gcongr)
      calc
        _ ≤ K*Real.exp (x*t)*(x^2+y^2)⁻¹ := H.norm_vertical_le hxc t y
        _ ≤ K*Real.exp ((|c|+|d|)*|t|)*(y^2)⁻¹ := by
          gcongr
          · exact mul_nonneg H.constant_nonneg (Real.exp_pos _).le
          · exact H.constant_nonneg
          · nlinarith [sq_nonneg x]
        _ = _ := by ring
    _ = _ := by ring

lemma tendsto_horizontal {c d : ℝ} (hc : a<c) (hcd : c≤d) (t : ℝ) :
    Tendsto (H.horizontal c d t) atTop (𝓝 0) := by
  rw [tendsto_zero_iff_norm_tendsto_zero]
  refine squeeze_zero' (g := fun y:ℝ=>K*Real.exp ((|c|+|d|)*|t|)*|d-c|/y^2)
    (Eventually.of_forall fun _=>norm_nonneg _) ?_ ?_
  · filter_upwards [eventually_gt_atTop (0:ℝ)] with y hy
    exact H.norm_horizontal_le hc hcd t y hy.ne'
  · have h := tendsto_inv_atTop_zero.comp ((tendsto_pow_atTop two_ne_zero):
        Tendsto (fun y:ℝ=>y^2) atTop atTop)
    simpa [div_eq_mul_inv] using h.const_mul (K*Real.exp ((|c|+|d|)*|t|)*|d-c|)

lemma tendsto_horizontal_neg {c d : ℝ} (hc : a<c) (hcd : c≤d) (t : ℝ) :
    Tendsto (fun y:ℝ=>H.horizontal c d t (-y)) atTop (𝓝 0) := by
  rw [tendsto_zero_iff_norm_tendsto_zero]
  refine squeeze_zero' (g := fun y:ℝ=>K*Real.exp ((|c|+|d|)*|t|)*|d-c|/y^2)
    (Eventually.of_forall fun _=>norm_nonneg _) ?_ ?_
  · filter_upwards [eventually_gt_atTop (0:ℝ)] with y hy
    simpa only [neg_sq] using H.norm_horizontal_le hc hcd t (-y) (neg_ne_zero.mpr hy.ne')
  · have h := tendsto_inv_atTop_zero.comp ((tendsto_pow_atTop two_ne_zero):
        Tendsto (fun y:ℝ=>y^2) atTop atTop)
    simpa [div_eq_mul_inv] using h.const_mul (K*Real.exp ((|c|+|d|)*|t|)*|d-c|)

lemma vertical_integral_eq_of_le {c d : ℝ} (hc : a<c) (hc0 : 0<c)
    (hcd : c≤d) (t : ℝ) :
    (∫ y:ℝ,H.vertical c t y) = ∫ y:ℝ,H.vertical d t y := by
  have hd := hc.trans_le hcd
  have hd0 := hc0.trans_le hcd
  have hrect (T:ℝ) :
      H.horizontal c d t (-T)-H.horizontal c d t T+
        I*(∫y in -T..T,H.vertical d t y)-I*(∫y in -T..T,H.vertical c t y)=0 := by
    have hf : DifferentiableOn ℂ (fun z=>E z*Complex.exp (z*t)) {z|a<z.re} :=
      H.holomorphic.mul (differentiable_id.mul_const (t:ℂ)).cexp.differentiableOn
    have hh := Complex.integral_boundary_rect_eq_zero_of_differentiableOn
      (fun z=>E z*Complex.exp (z*t)) ((c:ℂ)-T*I) ((d:ℂ)+T*I) (hf.mono (by
        intro z hz
        have hz' : z.re∈uIcc c d := by simpa using hz.1
        have hh : c≤z.re := (show z.re∈Icc c d by simpa only [uIcc_of_le hcd] using hz').1
        exact hc.trans_le hh))
    simpa [horizontal, vertical, smul_eq_mul] using hh
  have hlim := ((H.tendsto_horizontal_neg hc hcd t).sub (H.tendsto_horizontal hc hcd t)).add
    ((intervalIntegral_tendsto_integral (H.integrable_vertical hd hd0 t)
      tendsto_neg_atTop_atBot tendsto_id).const_mul I)
  have hlim := hlim.sub ((intervalIntegral_tendsto_integral (H.integrable_vertical hc hc0 t)
      tendsto_neg_atTop_atBot tendsto_id).const_mul I)
  have hzlim : Tendsto (fun T:ℝ=>H.horizontal c d t (-T)-H.horizontal c d t T+
      I*(∫y in -T..T,H.vertical d t y)-I*(∫y in -T..T,H.vertical c t y)) atTop (𝓝 0) := by
    simpa only [hrect] using (tendsto_const_nhds : Tendsto (fun _:ℝ=>(0:ℂ)) atTop (𝓝 0))
  have heq := tendsto_nhds_unique hlim hzlim
  simp only [sub_self, zero_add, sub_eq_zero] at heq
  exact (mul_left_cancel₀ Complex.I_ne_zero heq).symm

lemma bromwich_independent {c d : ℝ} (hc : a<c) (hc0 : 0<c)
    (hd : a<d) (hd0 : 0<d) (t : ℝ) : H.bromwich c t=H.bromwich d t := by
  unfold bromwich
  congr 1
  rcases le_total c d with hcd|hdc
  · exact H.vertical_integral_eq_of_le hc hc0 hcd t
  · exact (H.vertical_integral_eq_of_le hd hd0 hdc t).symm

end NeuralGeneralization.OnlineLowerTanh.HalfPlaneQuadraticRemainder
