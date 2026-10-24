import NeuralGeneralization.BatchTwoContinuousDepthCriticalSeedMean
import NeuralGeneralization.BatchTwoNonGaussianSmallBallKernel

/-! Genuine shifted Gaussian layers amplify a signed feature mean at constant
quadratic cost per layer, followed by a constant-cost saturation layer. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open BatchTwoNonGaussian TanhDifferential

def amplificationConstant : ℝ := (1-(Real.tanh 3)^2)/2

theorem amplificationConstant_pos : 0<amplificationConstant := by
  have hs: (Real.tanh 3)^2<1 := (sq_lt_one_iff_abs_lt_one _).mpr (Real.abs_tanh_lt_one _)
  unfold amplificationConstant
  linarith

theorem tanhFirst_lower_three {u:ℝ} (hu:|u|≤3) : 1-(Real.tanh 3)^2≤tanhFirst u := by
  have hb := abs_le.mp hu
  have hlow:=tanh_monotone hb.1
  have hhigh:=tanh_monotone hb.2
  rw [Real.tanh_neg] at hlow
  have ha : |Real.tanh u|≤Real.tanh 3 := abs_le.mpr ⟨hlow,hhigh⟩
  have ht0 : 0≤Real.tanh 3 := (abs_nonneg _).trans ha
  have hs:=pow_le_pow_left₀ (abs_nonneg _) ha 2
  rw [sq_abs] at hs
  unfold tanhFirst
  linarith

theorem tanh_shift_increment {u m:ℝ} (hu:|u|≤2) (hm:0≤m) (hm1:m≤1) :
    (1-(Real.tanh 3)^2)*m≤Real.tanh (u+m)-Real.tanh u := by
  have hd (x:ℝ) (hx:x∈interior (Icc u (u+m))) : 1-(Real.tanh 3)^2≤deriv Real.tanh x := by
    have hi : x∈Icc u (u+m):=interior_subset hx
    rw [(hasDerivAt_tanh_first x).deriv]
    apply tanhFirst_lower_three
    have hh:=abs_le.mp hu
    apply abs_le.mpr
    constructor <;> linarith [hi.1,hi.2,hh.1,hh.2]
  have hh := (convex_Icc u (u+m)).mul_sub_le_image_sub_of_le_deriv continuous_tanh.continuousOn
    (fun x _=>(hasDerivAt_tanh_first x).differentiableAt.differentiableWithinAt) hd
    u (by constructor <;> linarith) (u+m) (by constructor <;> linarith) (by linarith)
  simpa only [add_sub_cancel_left] using hh

variable {I:Type*} [Fintype I]

theorem gaussianRowMean_monotone (c:I→ℝ) : Monotone (gaussianRowMean c) := by
  intro m n hmn
  apply integral_mono (gaussianRow_integrable c m) (gaussianRow_integrable c n)
  intro z
  exact tanh_monotone (by linarith)

theorem gaussian_row_central_mass (c:I→ℝ) (hc:∑i,c i^2≤1) :
    (1/2:ℝ)≤(Measure.pi fun _ : I=>gaussianReal 0 1).real {z:I→ℝ | |∑i,c i*z i|<2} := by
  let μ:=Measure.pi fun _ : I=>gaussianReal 0 1
  have ht:=GaussianTail.gaussian_linear_form_abs_tail (fun _ : I=>(1:NNReal)) c 1 2
    (by norm_num) (by norm_num) (by simpa using hc)
  have hexp : 2*Real.exp (-2)≤(1/2:ℝ) := by
    have he:=Real.add_one_le_exp (1:ℝ)
    have he2 : (4:ℝ)≤Real.exp 2 := by
      rw [show (2:ℝ)=1+1 by norm_num,Real.exp_add]
      nlinarith
    rw [Real.exp_neg]
    change 2/Real.exp 2≤(1/2:ℝ)
    apply (div_le_iff₀ (Real.exp_pos 2)).mpr
    linarith
  norm_num at ht
  have htail : μ.real {z:I→ℝ | 2≤|∑i,c i*z i|}≤1/2 := ht.trans hexp
  have hm : MeasurableSet {z:I→ℝ | 2≤|∑i,c i*z i|} := measurableSet_le measurable_const (by fun_prop)
  have he : {z:I→ℝ | |∑i,c i*z i|<2}={z:I→ℝ | 2≤|∑i,c i*z i|}ᶜ := by ext z;simp
  rw [he,probReal_compl_eq_one_sub hm]
  linarith

theorem gaussianRowMean_small_amplification (c:I→ℝ) (hc:∑i,c i^2≤1)
    {m:ℝ} (hm:0≤m) (hm1:m≤1) : amplificationConstant*m≤gaussianRowMean c m := by
  let E:Set (I→ℝ):={z | |∑i,c i*z i|<2}
  have hE:MeasurableSet E:=measurableSet_lt (by fun_prop) measurable_const
  have hpoint (z:I→ℝ) : E.indicator (fun _=> (1-(Real.tanh 3)^2)*m) z≤
      Real.tanh (m+∑i,c i*z i)-Real.tanh (∑i,c i*z i) := by
    by_cases hz:z∈E
    · rw [Set.indicator_of_mem hz]
      simpa only [add_comm] using tanh_shift_increment (le_of_lt hz) hm hm1
    · rw [Set.indicator_of_notMem hz]
      exact sub_nonneg.mpr (tanh_monotone (by linarith))
  have hi := (integrable_const (μ:=Measure.pi fun _ : I=>gaussianReal 0 1) ((1-(Real.tanh 3)^2)*m)).indicator hE
  have hd := (gaussianRow_integrable c m).sub (gaussianRow_integrable c 0)
  simp only [zero_add] at hd
  have hh:=integral_mono hi hd hpoint
  rw [integral_indicator hE,setIntegral_const,smul_eq_mul] at hh
  have he : (∫z:I→ℝ,Real.tanh (m+∑i,c i*z i)-Real.tanh (∑i,c i*z i) ∂(Measure.pi fun _ : I=>gaussianReal 0 1))=
      gaussianRowMean c m := by
    rw [integral_sub (gaussianRow_integrable c m) (by simpa only [zero_add] using gaussianRow_integrable c 0)]
    have hz : (∫z:I→ℝ,Real.tanh (∑i,c i*z i) ∂(Measure.pi fun _ : I=>gaussianReal 0 1))=0 := by simpa only [gaussianRowMean,zero_add] using gaussianRowMean_zero c
    rw [hz,sub_zero]
    rfl
  change (Measure.pi fun _ : I=>gaussianReal 0 1).real E*((1-(Real.tanh 3)^2)*m)≤(∫z:I→ℝ,Real.tanh (m+∑i,c i*z i)-Real.tanh (∑i,c i*z i) ∂(Measure.pi fun _ : I=>gaussianReal 0 1)) at hh
  rw [he] at hh
  have hmass:=gaussian_row_central_mass c hc
  have hcoef : 0≤(1-(Real.tanh 3)^2)*m := by
    have ha:=amplificationConstant_pos
    unfold amplificationConstant at ha
    exact mul_nonneg (by linarith) hm
  have hh' := mul_le_mul_of_nonneg_right hmass hcoef
  unfold amplificationConstant
  change (1/2:ℝ)*((1-(Real.tanh 3)^2)*m)≤_ at hh'
  linarith

theorem gaussianRowMean_amplification (c:I→ℝ) (hc:∑i,c i^2≤1) {m:ℝ} (hm:0≤m) :
    amplificationConstant*min m 1≤gaussianRowMean c m := by
  rcases le_total m 1 with h|h
  · rw [min_eq_left h]
    exact gaussianRowMean_small_amplification c hc hm h
  · rw [min_eq_right h]
    have hs:=gaussianRowMean_small_amplification c hc (m:=1) (by norm_num) le_rfl
    have hm':=gaussianRowMean_monotone c h
    linarith

end NeuralGeneralization.BatchTwoContinuousDepthCritical
