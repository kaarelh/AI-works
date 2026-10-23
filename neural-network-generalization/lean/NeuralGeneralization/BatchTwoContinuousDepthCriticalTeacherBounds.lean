import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlledTracking
import NeuralGeneralization.BatchTwoContinuousDepthSphere

/-! The actual Cantor teacher outputs lie close to the two saturation targets
±3/5, and its input samples meet the seed's unit-ball hypotheses almost surely. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory Filter
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel BatchTwoContinuous BatchTwoContinuousDepthLower

noncomputable def targetLabel (t:ℝ) : Bool := decide (0≤t)

theorem targetLabel_center {t:ℝ} (hlo:(1:ℝ)/2≤|t|) (hhi:|t|≤13/20) :
    |t-(3/5)*labelReal (targetLabel t)|≤1/10 := by
  by_cases ht:0≤t
  · simp only [targetLabel,ht,decide_true,labelReal_true,mul_one]
    rw [abs_of_nonneg ht] at hlo hhi
    exact abs_le.mpr ⟨by linarith,by linarith⟩
  · simp only [targetLabel,ht,decide_false,labelReal_false,mul_neg_one,sub_neg_eq_add]
    rw [abs_of_nonpos (le_of_not_ge ht)] at hlo hhi
    exact abs_le.mpr ⟨by linarith,by linarith⟩

theorem depthTarget_coded_lower (h:ℕ) (ω:SignStream) :
    (1:ℝ)/2≤|depthTarget h (sphereCoding ω)| := by
  change (1:ℝ)/2≤|expandingMap^[h] (coding ω)|
  rw [expandingMap_iterate_coding]
  exact (coding_range _).1

theorem depthTarget_ae_lower (h:ℕ) : ∀ᵐx ∂inputLaw,(1:ℝ)/2≤|depthTarget h x| := by
  unfold depthTarget
  rw [inputLaw,ae_map_iff sphereCoding_measurable.aemeasurable
    (measurableSet_le measurable_const (continuous_target h).measurable.abs)]
  exact Filter.Eventually.of_forall (depthTarget_coded_lower h)

theorem depthTarget_ae_center (h:ℕ) : ∀ᵐx ∂inputLaw,
    |depthTarget h x-(3/5)*labelReal (targetLabel (depthTarget h x))|≤1/10 := by
  filter_upwards [depthTarget_ae_lower h,depthTarget_ae_bound h] with x hx1 hx2
  exact targetLabel_center hx1 hx2

theorem inputLaw_ae_unitBall : ∀ᵐx ∂inputLaw,∑j,x j^2≤1 := by
  rw [inputLaw,ae_map_iff sphereCoding_measurable.aemeasurable (measurableSet_le (by fun_prop) measurable_const)]
  apply Filter.Eventually.of_forall
  intro ω
  exact (sphereArc_on_sphere ((coding_range ω).2.trans (by norm_num))).le

theorem iid_critical_sample_bounds (h n:ℕ) :
    ∀ᵐs ∂(Measure.pi fun _ : Fin n=>inputLaw),
      (∀i,∑j,s i j^2≤1) ∧
      (∀i,|depthTarget h (s i)-(3/5)*labelReal (targetLabel (depthTarget h (s i)))|≤1/10) := by
  have h1:∀ᵐs ∂(Measure.pi fun _ : Fin n=>inputLaw),∀i,∑j,s i j^2≤1 := by
    apply eventually_all.mpr
    intro i
    exact (Measure.tendsto_eval_ae_ae (μ:=fun _ : Fin n=>inputLaw) (i:=i)).eventually inputLaw_ae_unitBall
  have h2:∀ᵐs ∂(Measure.pi fun _ : Fin n=>inputLaw),∀i,
      |depthTarget h (s i)-(3/5)*labelReal (targetLabel (depthTarget h (s i)))|≤1/10 := by
    apply eventually_all.mpr
    intro i
    exact (Measure.tendsto_eval_ae_ae (μ:=fun _ : Fin n=>inputLaw) (i:=i)).eventually (depthTarget_ae_center h)
  exact h1.and h2

end NeuralGeneralization.BatchTwoContinuousDepthCritical
