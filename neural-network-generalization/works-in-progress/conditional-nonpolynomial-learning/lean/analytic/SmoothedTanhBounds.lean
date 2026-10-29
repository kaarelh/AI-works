import ShiftedMeanGeometry
import Mathlib.Tactic.LinearCombination

noncomputable section
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.BatchTwoContinuousDepthCritical

theorem tanh_add_mul (x y : ℝ) :
    Real.tanh (x+y)*(1+Real.tanh x*Real.tanh y)=Real.tanh x+Real.tanh y := by
  simp only [Real.tanh_eq_sinh_div_cosh]
  have hx := (Real.cosh_pos x).ne'
  have hy := (Real.cosh_pos y).ne'
  have hxy := (Real.cosh_pos (x+y)).ne'
  field_simp
  rw [Real.sinh_add,Real.cosh_add]
  ring

theorem tanh_symmetric_identity (x y : ℝ) :
    (Real.tanh (x+y)+Real.tanh (x-y))*(1-(Real.tanh x)^2*(Real.tanh y)^2)=
      2*Real.tanh x*(1-(Real.tanh y)^2) := by
  have hp := tanh_add_mul x y
  have hm := tanh_add_mul x (-y)
  simp only [Real.tanh_neg,←sub_eq_add_neg,mul_neg] at hm
  linear_combination (1-Real.tanh x*Real.tanh y)*hp +
    (1+Real.tanh x*Real.tanh y)*hm

theorem tanh_symmetric_bounds {x : ℝ} (hx : 0 ≤ x) (y : ℝ) :
    Real.tanh x*(1-(Real.tanh y)^2) ≤ (Real.tanh (x+y)+Real.tanh (x-y))/2 ∧
      (Real.tanh (x+y)+Real.tanh (x-y))/2 ≤ Real.tanh x := by
  have hu0 : 0 ≤ Real.tanh x := by
    simpa only [Real.tanh_zero] using NeuralGeneralization.BatchTwoNonGaussian.tanh_monotone hx
  have hu1 : (Real.tanh x)^2 < 1 := (sq_lt_one_iff_abs_lt_one _).mpr (Real.abs_tanh_lt_one x)
  have hv1 : (Real.tanh y)^2 < 1 := (sq_lt_one_iff_abs_lt_one _).mpr (Real.abs_tanh_lt_one y)
  have hprod0 : 0 ≤ (Real.tanh x)^2*(Real.tanh y)^2 := mul_nonneg (sq_nonneg _) (sq_nonneg _)
  have hprod1 : (Real.tanh x)^2*(Real.tanh y)^2 < 1 :=
    (mul_le_mul_of_nonneg_right hu1.le (sq_nonneg _)).trans_lt (by simpa using hv1)
  have he := tanh_symmetric_identity x y
  let s := (Real.tanh (x+y)+Real.tanh (x-y))/2
  have hs : 0 ≤ s := by
    have hnum := mul_nonneg hu0 (sub_nonneg.mpr hv1.le)
    dsimp [s]
    nlinarith
  have hsp := mul_nonneg hs hprod0
  have hgap := mul_nonneg (mul_nonneg hu0 (sq_nonneg (Real.tanh y))) (sub_nonneg.mpr hu1.le)
  constructor
  · change Real.tanh x*(1-(Real.tanh y)^2) ≤ s
    dsimp [s] at *
    nlinarith
  · change s ≤ Real.tanh x
    have hden : 0 < 1-(Real.tanh x)^2*(Real.tanh y)^2 := by linarith
    apply (mul_le_mul_iff_left₀ hden).mp
    dsimp [s]
    nlinarith

theorem shiftedMean_symmetric_integral (r x : ℝ) :
    shiftedMean r x = ∫ z, (Real.tanh (x+Real.sqrt r*z)+
      Real.tanh (x-Real.sqrt r*z))/2 ∂gaussianReal 0 1 := by
  have hmp : MeasurePreserving (MeasurableEquiv.neg ℝ)
      (gaussianReal 0 1) (gaussianReal 0 1) := by
    refine ⟨by fun_prop, ?_⟩
    simpa only [MeasurableEquiv.neg_apply,neg_zero] using
      (gaussianReal_map_neg (μ := (0 : ℝ)) (v := (1 : NNReal)))
  have hm := hmp.integral_comp' (fun z : ℝ => Real.tanh (x+Real.sqrt r*z))
  simp only [MeasurableEquiv.neg_apply,mul_neg,←sub_eq_add_neg] at hm
  have hi : Integrable (fun z : ℝ => Real.tanh (x-Real.sqrt r*z)) (gaussianReal 0 1) := by
    apply Integrable.of_bound (by fun_prop) 1
    filter_upwards [] with z
    exact (Real.abs_tanh_lt_one _).le
  rw [integral_div,integral_add (shifted_tanh_integrable r x) hi,hm]
  unfold shiftedMean
  ring

theorem shiftedMean_tanh_bounds {r x : ℝ} (hr : 0 ≤ r) (hx : 0 ≤ x) :
    (1-r)*Real.tanh x ≤ shiftedMean r x ∧ shiftedMean r x ≤ Real.tanh x := by
  have hi : Integrable (fun z : ℝ => (Real.tanh (x+Real.sqrt r*z)+
      Real.tanh (x-Real.sqrt r*z))/2) (gaussianReal 0 1) := by
    apply Integrable.of_bound (by fun_prop) 1
    filter_upwards [] with z
    have ht := abs_add_le (Real.tanh (x+Real.sqrt r*z)) (Real.tanh (x-Real.sqrt r*z))
    rw [Real.norm_eq_abs,abs_div]
    norm_num
    linarith [(Real.abs_tanh_lt_one (x+Real.sqrt r*z)).le,
      (Real.abs_tanh_lt_one (x-Real.sqrt r*z)).le]
  have hlo := integral_mono
    (((integrable_const (1:ℝ)).sub (cooling_second_integrable r)).const_mul (Real.tanh x))
    hi (fun z => (tanh_symmetric_bounds hx (Real.sqrt r*z)).1)
  have hhi := integral_mono hi (integrable_const (Real.tanh x))
    (fun z => (tanh_symmetric_bounds hx (Real.sqrt r*z)).2)
  have hu0 : 0 ≤ Real.tanh x := by
    simpa only [Real.tanh_zero] using NeuralGeneralization.BatchTwoNonGaussian.tanh_monotone hx
  rw [integral_const_mul] at hlo
  simp only [Pi.sub_apply] at hlo
  rw [integral_sub (integrable_const _) (cooling_second_integrable r)] at hlo
  simp only [integral_const,probReal_univ,smul_eq_mul,one_mul] at hlo hhi
  rw [← shiftedMean_symmetric_integral] at hlo hhi
  refine ⟨?_,hhi⟩
  have hq := mul_le_mul_of_nonneg_left (coolingSecondMoment_le r hr) hu0
  change Real.tanh x*(1-coolingSecondMoment r) ≤ shiftedMean r x at hlo
  nlinarith

#print axioms shiftedMean_tanh_bounds
end ConditionalNonpolynomial.Analytic
