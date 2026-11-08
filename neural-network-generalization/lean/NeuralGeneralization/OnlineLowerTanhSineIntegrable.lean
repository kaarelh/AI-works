import NeuralGeneralization.Activation
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds
import Mathlib.Tactic

noncomputable section
open scoped Topology
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma sinh_exp_lower (s:ℝ) (hs:0≤s) : s/2*Real.exp (s/2) ≤ Real.sinh s := by
  have hh := Real.self_le_sinh_iff.mpr (show 0≤s/2 by positivity)
  have hc : Real.exp (s/2)/2≤Real.cosh (s/2) := by
    rw [Real.cosh_eq]
    linarith [Real.exp_pos (-(s/2))]
  have h1 := mul_le_mul_of_nonneg_left hc hs
  have h2 := mul_le_mul_of_nonneg_right hh (Real.cosh_pos (s/2)).le
  have hid : Real.sinh s=2*Real.sinh (s/2)*Real.cosh (s/2) := by
    conv_lhs => rw [show s=2*(s/2) by ring]
    rw [Real.sinh_two_mul]
  rw [hid]
  nlinarith

lemma sine_sinh_bound (a b t:ℝ) (hb:0<b) (ht:0<t) :
    |Real.sin (a*t)/Real.sinh (b*t)| ≤ (2*|a|/b)*Real.exp (-(b/2)*t) := by
  have hs : 0<Real.sinh (b*t) := Real.sinh_pos_iff.mpr (mul_pos hb ht)
  rw [abs_div,abs_of_pos hs]
  have hsin : |Real.sin (a*t)|≤|a| *t := by
    simpa [abs_mul,abs_of_pos ht] using (Real.abs_sin_le_abs (x:=a*t))
  have hlow := sinh_exp_lower (b*t) (mul_pos hb ht).le
  have hm := mul_le_mul_of_nonneg_right hlow
    (show 0≤(2*|a|/b)*Real.exp (-(b/2)*t) by positivity)
  have he : Real.exp (b*t/2)*Real.exp (-(b/2)*t)=1 := by
    rw [←Real.exp_add]; convert! Real.exp_zero using 1 <;> ring
  have hh : (b*t/2*Real.exp (b*t/2))*((2*|a|/b)*Real.exp (-(b/2)*t))=|a| *t := by
    calc
      _ = (b*t/2)*(2*|a|/b)*(Real.exp (b*t/2)*Real.exp (-(b/2)*t)) := by ring
      _ = _ := by rw [he]; field_simp
  rw [hh] at hm
  exact (div_le_iff₀ hs).mpr (hsin.trans (by simpa [mul_comm] using hm))

lemma sine_sinh_integrable (a b:ℝ) (hb:0<b) :
    IntegrableOn (fun t:ℝ => Real.sin (a*t)/Real.sinh (b*t)) (Ioi 0) := by
  have hh := (integrableOn_exp_mul_Ioi (show -(b/2)<0 by linarith) 0).const_mul (2*|a|/b)
  apply hh.mono'
  · exact ((Real.measurable_sin.comp (by fun_prop)).div
      (Real.continuous_sinh.measurable.comp (by fun_prop))).aestronglyMeasurable
  · filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    simpa only [Real.norm_eq_abs] using sine_sinh_bound a b t hb ht

lemma tanh_sine_integrable (a:ℝ) :
    IntegrableOn (fun t:ℝ => Real.sin (a*t)/Real.sinh (Real.pi*t/2)) (Ioi 0) := by
  simpa only [div_mul_eq_mul_div] using sine_sinh_integrable a (Real.pi/2) (by positivity)

end NeuralGeneralization.OnlineLowerTanh
