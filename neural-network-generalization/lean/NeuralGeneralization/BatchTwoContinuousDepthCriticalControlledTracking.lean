import NeuralGeneralization.BatchTwoContinuousDepthCriticalPopulation

/-! Robust signal amplification and final saturation for actual empirical
layer means. These estimates are uniform over their unconstrained variances. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel

variable {I:Type*} [Fintype I]

theorem gaussianRowMean_bool (c:I→ℝ) (m:ℝ) (y:Bool) :
    gaussianRowMean c (labelReal y*m)=labelReal y*gaussianRowMean c m := by
  cases y <;> simp only [labelReal_false,labelReal_true,neg_one_mul,one_mul,gaussianRowMean_odd]

theorem signed_amplification_with_error (c:I→ℝ) (hc:∑i,c i^2≤1) (y:Bool)
    {b v ε:ℝ} (hb:0≤labelReal y*b)
    (herr:|v-gaussianRowMean c (robustAmplificationGain*b)|≤ε) :
    amplificationConstant*min (robustAmplificationGain*(labelReal y*b)) 1-ε≤labelReal y*v := by
  have hm:=gaussianRowMean_amplification c hc (mul_nonneg robustAmplificationGain_pos.le hb)
  have he:gaussianRowMean c (robustAmplificationGain*(labelReal y*b))=
      labelReal y*gaussianRowMean c (robustAmplificationGain*b) := by
    rw [show robustAmplificationGain*(labelReal y*b)=labelReal y*(robustAmplificationGain*b) by ring,
      gaussianRowMean_bool]
  rw [he] at hm
  have hh:|labelReal y*(v-gaussianRowMean c (robustAmplificationGain*b))|≤ε := by
    simpa only [abs_mul,abs_labelReal,one_mul] using herr
  have hl: -ε≤labelReal y*(v-gaussianRowMean c (robustAmplificationGain*b)) := (abs_le.mp hh).1
  nlinarith

/-- The same fixed row tolerance works throughout the amplification block. -/
theorem robust_amplification_perturbed {u ε:ℝ} (hu:0<u) (hu1:u≤1)
    (hεu:ε≤u) (hεC:ε≤amplificationConstant/2) (b:ℕ→ℝ) (hb0:u≤b 0)
    (hstep:∀k,k<amplificationCount u→
      amplificationConstant*min (robustAmplificationGain*b k) 1-ε≤b (k+1)) :
    amplificationConstant/2≤b (amplificationCount u) := by
  have hind : ∀k,k≤amplificationCount u→min ((2:ℝ)^k*u) (amplificationConstant/2)≤b k := by
    intro k
    induction k with
    | zero=>intro _;simpa only [pow_zero,one_mul] using (min_le_left u (amplificationConstant/2)).trans hb0
    | succ k ih=>
      intro hk
      have hi:=ih (by omega)
      have hu2:u≤(2:ℝ)^k*u := by
        have hp:1≤(2:ℝ)^k := one_le_pow₀ (by norm_num)
        nlinarith
      have hbase:min u (amplificationConstant/2)≤b k := (min_le_min hu2 le_rfl).trans hi
      have hnext:=robust_amplification_step (lt_min hu (by linarith [amplificationConstant_pos]))
        hbase (le_min hεu hεC) hεC (hstep k (by omega))
      have hh:min (2*min ((2:ℝ)^k*u) (amplificationConstant/2)) (amplificationConstant/2)≤
          min (2*b k) (amplificationConstant/2):=
        min_le_min (mul_le_mul_of_nonneg_left hi (by norm_num : (0:ℝ)≤2)) le_rfl
      have he:min (2*min ((2:ℝ)^k*u) (amplificationConstant/2)) (amplificationConstant/2)=
          min ((2:ℝ)^(k+1)*u) (amplificationConstant/2) := by
        rw [mul_min_of_nonneg _ _ (by norm_num : (0:ℝ)≤2),pow_succ]
        rw [min_assoc,min_eq_right (show amplificationConstant/2≤2*(amplificationConstant/2) by linarith [amplificationConstant_pos])]
        congr 1
        ring
      rw [he] at hh
      exact hh.trans hnext
  have hh:=hind (amplificationCount u) le_rfl
  have hp:=amplificationCount_power hu hu1
  have hc:=amplificationConstant_le_half
  rwa [min_eq_right (by linarith)] at hh

theorem saturationGain_pos : 0<saturationGain := by
  unfold saturationGain
  apply div_pos _ amplificationConstant_pos
  have hl:0<Real.log 200:=Real.log_pos (by norm_num)
  linarith

theorem saturation_population_error (c:I→ℝ) (hc:∑i,c i^2≤1) (y:Bool)
    {b:ℝ} (hb:amplificationConstant/2≤labelReal y*b) :
    |gaussianRowMean c (saturationGain*b)-labelReal y|≤1/100 := by
  have hm:=gaussianRowMean_saturation c (saturationGain*(labelReal y*b)) hc
  have hB:saturationGain*amplificationConstant=2+Real.log 200 := by
    unfold saturationGain
    field_simp [ne_of_gt amplificationConstant_pos]
  have hmul:=mul_le_mul_of_nonneg_left hb saturationGain_pos.le
  have he: -2*(saturationGain*(labelReal y*b))+2≤-Real.log 200 := by nlinarith
  have hx:=Real.exp_le_exp.mpr he
  have hexp:Real.exp (-Real.log 200)=(1:ℝ)/200 := by
    rw [Real.exp_neg,Real.exp_log (by norm_num : (0:ℝ)<200)]
    norm_num
  rw [hexp] at hx
  have hl:|gaussianRowMean c (saturationGain*(labelReal y*b))-1|≤1/100 := by linarith
  have hsign:gaussianRowMean c (saturationGain*(labelReal y*b))=
      labelReal y*gaussianRowMean c (saturationGain*b) := by
    rw [show saturationGain*(labelReal y*b)=labelReal y*(saturationGain*b) by ring,gaussianRowMean_bool]
  rw [hsign] at hl
  cases y
  · simp only [labelReal_false,neg_one_mul] at hl ⊢
    have he: -gaussianRowMean c (saturationGain*b)-1=-(gaussianRowMean c (saturationGain*b)-(-1)):=by ring
    rwa [he,abs_neg] at hl
  · simpa only [labelReal_true,one_mul] using hl

theorem saturation_empirical_error (c:I→ℝ) (hc:∑i,c i^2≤1) (y:Bool)
    {b v:ℝ} (hb:amplificationConstant/2≤labelReal y*b)
    (herr:|v-gaussianRowMean c (saturationGain*b)|<1/100) :
    |v-labelReal y|<1/50 := by
  have hs:=saturation_population_error c hc y hb
  have ht:=abs_sub_le v (gaussianRowMean c (saturationGain*b)) (labelReal y)
  linarith

theorem final_regression_error (y:Bool) {v z target:ℝ}
    (htarget:|target-(3/5)*labelReal y|≤1/10)
    (hmean:|v-labelReal y|<1/50) (hout:|z-(3/5)*v|<1/200) :
    |z-target|<1/8 := by
  have hm:|(3/5)*v-(3/5)*labelReal y|<(3:ℝ)/250 := by
    rw [←mul_sub,abs_mul,abs_of_pos (by norm_num : (0:ℝ)<3/5)]
    nlinarith
  have ht:=abs_sub_le z ((3/5)*v) target
  have ht':=abs_sub_le ((3/5)*v) ((3/5)*labelReal y) target
  rw [abs_sub_comm target] at htarget
  linarith

end NeuralGeneralization.BatchTwoContinuousDepthCritical
