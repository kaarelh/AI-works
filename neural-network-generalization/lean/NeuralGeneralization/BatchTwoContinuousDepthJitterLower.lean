import NeuralGeneralization.BatchTwoContinuousDepthSmoothStrong

/-! A sharper lower endpoint shows the jittered teacher remains in the original
two label bands. The existing mean-field witness can therefore be reused verbatim. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Set Filter MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous

theorem expandingMap_sharp_left_endpoint : (3/4 : ℝ) < expandingMap (51/100) := by
  have hex : (199 : ℝ) < Real.exp (101/5) := by
    have h := Real.exp_le_exp.mpr (by norm_num : (20 : ℝ) ≤ 101/5)
    linarith [exp_twenty_gt]
  have ht : (99/100 : ℝ) < Real.tanh (101/10) := by
    rw [tanh_double_exp, lt_div_iff₀ (by positivity)]
    norm_num only at *
    linarith
  have hs := BatchTwoNonGaussian.abs_tanh_le_abs (1/10 : ℝ)
  have hs' : Real.tanh (1/10 : ℝ) ≤ 1/10 := by
    norm_num only [abs_of_pos (by norm_num : (0 : ℝ)<1/10)] at hs
    exact (le_abs_self _).trans hs
  unfold expandingMap
  norm_num only
  linarith

theorem positiveBranch_sharp_lower (y : BranchDomain) : (51/100 : ℝ) ≤ positiveBranch y := by
  have hex : ∃ t ∈ Icc (51/100 : ℝ) (13/20), expandingMap t = y := by
    apply intermediate_value_Icc' (by norm_num : (51/100 : ℝ) ≤ 13/20)
      continuous_expandingMap.continuousOn
    exact ⟨expandingMap_right_endpoint.le.trans y.property.1,
      y.property.2.trans expandingMap_sharp_left_endpoint.le⟩
  obtain ⟨t,ht,hty⟩ := hex
  have hd := (expandingMap_branch_distance (positiveBranch_mem y)
    (show t ∈ Icc (1/2 : ℝ) (13/20) from ⟨by linarith [ht.1],ht.2⟩)).1
  rw [expandingMap_positiveBranch, hty, sub_self, abs_zero] at hd
  have he : positiveBranch y = t := sub_eq_zero.mp (abs_eq_zero.mp (by
    linarith [abs_nonneg (positiveBranch y-t)]))
  exact he.symm ▸ ht.1

theorem coding_sharp_lower (ω : SignStream) : (51/100 : ℝ) ≤ |scalarCoding ω| := by
  change (51/100 : ℝ) ≤ |(coding ω).val|
  rw [coding_unfold]
  have hlo := positiveBranch_sharp_lower (coding (streamShift 1 ω))
  cases h : ω 0 <;> simp only [h, branch, Bool.false_eq_true, ↓reduceIte, abs_neg] <;>
    rw [abs_of_nonneg (by linarith)] <;> exact hlo

theorem jittered_label_lower (r : ℕ) (z : SignStream × Jitter r) :
    (1/2 : ℝ) ≤ |depthTarget r (jitteredCoding r z)| := by
  have he := jitter_target_error r (scalarCoding z.1) z.2
  have hb : (51/100 : ℝ) ≤ |expandingMap^[r] (scalarCoding z.1)| := by
    change (51/100 : ℝ) ≤ |expandingMap^[r] (coding z.1)|
    rw [expandingMap_iterate_coding]
    exact coding_sharp_lower _
  change (1/2 : ℝ) ≤ |expandingMap^[r] (scalarCoding z.1 + z.2.val)|
  have ht := abs_sub_le (expandingMap^[r] (scalarCoding z.1))
    (expandingMap^[r] (scalarCoding z.1 + z.2.val)) 0
  rw [abs_sub_comm (expandingMap^[r] (scalarCoding z.1))
    (expandingMap^[r] (scalarCoding z.1 + z.2.val))] at ht
  simp only [sub_zero] at ht
  linarith

theorem smoothInputLaw_label_lower (r : ℕ) :
    ∀ᵐ x ∂smoothInputLaw r, (1/2 : ℝ) ≤ |depthTarget r x| := by
  unfold depthTarget
  rw [smoothInputLaw, jitteredInputLaw,
    ae_map_iff (jitteredCoding_measurable r).aemeasurable
      (measurableSet_le measurable_const (continuous_target r).measurable.abs)]
  exact Eventually.of_forall (jittered_label_lower r)

end NeuralGeneralization.BatchTwoContinuousDepthLower

namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel BatchTwoContinuous BatchTwoContinuousDepthLower

theorem smooth_depthTarget_ae_center (h : ℕ) : ∀ᵐ x ∂smoothInputLaw h,
    |depthTarget h x-(3/5)*labelReal (targetLabel (depthTarget h x))|≤1/10 := by
  filter_upwards [smoothInputLaw_label_lower h,
    jitteredInputLaw_label_bound h (smoothJitterLaw h)] with x hx1 hx2
  exact targetLabel_center hx1 hx2

theorem smoothInputLaw_ae_unitBall (h : ℕ) : ∀ᵐ x ∂smoothInputLaw h,∑j,x j^2≤1 := by
  rw [smoothInputLaw, jitteredInputLaw,
    ae_map_iff (jitteredCoding_measurable h).aemeasurable (measurableSet_le (by fun_prop) measurable_const)]
  exact Eventually.of_forall fun z => (jitteredCoding_on_sphere h z).le

theorem smooth_iid_critical_sample_bounds (h n : ℕ) :
    ∀ᵐ s ∂(Measure.pi fun _ : Fin n => smoothInputLaw h),
      (∀i,∑j,s i j^2≤1) ∧
      (∀i,|depthTarget h (s i)-(3/5)*labelReal (targetLabel (depthTarget h (s i)))|≤1/10) := by
  have h1 : ∀ᵐ s ∂(Measure.pi fun _ : Fin n => smoothInputLaw h),∀i,∑j,s i j^2≤1 := by
    apply eventually_all.mpr
    intro i
    exact (Measure.tendsto_eval_ae_ae (μ:=fun _ : Fin n => smoothInputLaw h) (i:=i)).eventually
      (smoothInputLaw_ae_unitBall h)
  have h2 : ∀ᵐ s ∂(Measure.pi fun _ : Fin n => smoothInputLaw h),∀i,
      |depthTarget h (s i)-(3/5)*labelReal (targetLabel (depthTarget h (s i)))|≤1/10 := by
    apply eventually_all.mpr
    intro i
    exact (Measure.tendsto_eval_ae_ae (μ:=fun _ : Fin n => smoothInputLaw h) (i:=i)).eventually
      (smooth_depthTarget_ae_center h)
  exact h1.and h2

end NeuralGeneralization.BatchTwoContinuousDepthCritical
