import NeuralGeneralization.GaussianLinear
import NeuralGeneralization.TanhScalarJet
import NeuralGeneralization.TanhSaturation
import NeuralGeneralization.BatchTwoNonGaussianEvenSmallBall

/-! Quantitative saturation of actual first-layer Gaussian feature means.
This supports a low-cost mean seed without any inverse covariance assumption. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open GaussianProductStein BatchTwoNonGaussian
variable {I : Type*} [Fintype I]

def gaussianRowMean (c : I→ℝ) (m : ℝ) : ℝ :=
  ∫ z:I→ℝ,Real.tanh (m+∑i,c i*z i) ∂(Measure.pi fun _ : I=>gaussianReal 0 1)

theorem gaussianRow_integrable (c:I→ℝ) (m:ℝ) :
    Integrable (fun z:I→ℝ=>Real.tanh (m+∑i,c i*z i)) (Measure.pi fun _ : I=>gaussianReal 0 1) := by
  apply Integrable.of_bound (show Continuous (fun z:I→ℝ=>Real.tanh (m+∑i,c i*z i)) by fun_prop).measurable.aestronglyMeasurable 1
  exact ae_of_all _ (fun _=>(Real.abs_tanh_lt_one _).le)

theorem gaussianRowMean_le_one (c:I→ℝ) (m:ℝ) : gaussianRowMean c m≤1 := by
  have hh := integral_mono (gaussianRow_integrable c m) (integrable_const (1:ℝ))
    (fun z => (le_abs_self _).trans (Real.abs_tanh_lt_one _).le)
  simpa [gaussianRowMean] using hh

theorem tanh_saturation_bound (x:ℝ) : 1-Real.tanh x≤2*Real.exp (-2*x) := by
  rw [TanhSaturation.tanh_exp_formula]
  have hh := div_le_div_of_nonneg_left (by norm_num : (0:ℝ)≤2) (Real.exp_pos (2*x))
    (show Real.exp (2*x)≤Real.exp (2*x)+1 by linarith)
  have he : 2/Real.exp (2*x)=2*Real.exp (-2*x) := by rw [show -2*x=-(2*x) by ring,Real.exp_neg];ring
  rw [he] at hh
  linarith

theorem gaussianRowMean_saturation (c:I→ℝ) (m:ℝ) (hc:∑i,c i^2≤1) :
    |gaussianRowMean c m-1|≤2*Real.exp (-2*m+2) := by
  have hexp := GaussianTail.integrable_exp_gaussian_linear_form (fun _ : I=>(1:NNReal)) c (-2)
  have hleft := (integrable_const (1:ℝ)).sub (gaussianRow_integrable c m)
  have hright : Integrable (fun z:I→ℝ=>2*Real.exp (-2*m)*Real.exp (-2*∑i,c i*z i))
      (Measure.pi fun _ : I=>gaussianReal 0 1) := hexp.const_mul _
  have hh := integral_mono hleft hright (fun z=>by
    have h:=tanh_saturation_bound (m+∑i,c i*z i)
    have he : 2*Real.exp (-2*(m+∑i,c i*z i))=
      2*Real.exp (-2*m)*Real.exp (-2*∑i,c i*z i) := by
      rw [mul_assoc,←Real.exp_add]
      congr 2
      ring
    rwa [he] at h)
  change (∫ z:I→ℝ,1-Real.tanh (m+∑i,c i*z i) ∂(Measure.pi fun _ : I=>gaussianReal 0 1))≤_ at hh
  rw [integral_sub (integrable_const _) (gaussianRow_integrable c m),integral_const_mul] at hh
  simp only [integral_const,probReal_univ,smul_eq_mul,mul_one] at hh
  have hm : (∫ z:I→ℝ,Real.exp (-2*∑i,c i*z i) ∂(Measure.pi fun _ : I=>gaussianReal 0 1))=
      Real.exp (2*∑i,c i^2) := by
    change mgf (fun z:I→ℝ=>∑i,c i*z i) (Measure.pi fun _ : I=>gaussianReal 0 1) (-2)=_
    rw [GaussianTail.mgf_gaussian_linear_form]
    simp only [NNReal.coe_one,mul_one]
    congr 1
    ring
  rw [hm] at hh
  have hbound := mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr (show 2*(∑i,c i^2)≤2 by linarith))
    (show 0≤2*Real.exp (-2*m) by positivity)
  have hexpEq : 2*Real.exp (-2*m)*Real.exp 2=2*Real.exp (-2*m+2) := by rw [mul_assoc,←Real.exp_add]
  rw [hexpEq] at hbound
  rw [abs_of_nonpos (sub_nonpos.mpr (gaussianRowMean_le_one c m))]
  unfold gaussianRowMean
  linarith

theorem gaussianRowMean_odd (c:I→ℝ) (m:ℝ) : gaussianRowMean c (-m)= -gaussianRowMean c m := by
  have hmp : MeasurePreserving (MeasurableEquiv.neg (I→ℝ)) (Measure.pi fun _ : I=>gaussianReal 0 1) (Measure.pi fun _ : I=>gaussianReal 0 1) := product_neg_preserving standardGaussian I
  have hp := hmp.integral_comp' (fun z:I→ℝ=>Real.tanh (-m+∑i,c i*z i))
  have he (z:I→ℝ) : Real.tanh (-m+∑i,c i*(-z) i)= -Real.tanh (m+∑i,c i*z i) := by
    simp only [Pi.neg_apply,mul_neg,Finset.sum_neg_distrib,←neg_add,Real.tanh_neg]
  simpa only [MeasurableEquiv.neg_apply,standardGaussian_law,he,integral_neg,gaussianRowMean] using hp.symm

theorem gaussianRowMean_zero (c:I→ℝ) : gaussianRowMean c 0=0 := by
  have hh := gaussianRowMean_odd c 0
  simp only [neg_zero] at hh
  linarith

end NeuralGeneralization.BatchTwoContinuousDepthCritical
