import NeuralGeneralization.TwoMarginComparison
import NeuralGeneralization.PointwiseRobustSupport

/-! The label-free two-margin support, its Borel measurability, and its
relation to the original clipped-score support. -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.TwoMarginTransport
open ConcreteModel
variable {d N r : ℕ}

/-- Both signs are quantified, so this is a label-free support predicate. -/
def atInput (φ : ℝ → ℝ) (c : ℝ) (w : Weights d N r) (x : Cube d) : Prop :=
  ∀ b : Bool,
    ((1/2:ℝ) ≤ labelReal b*networkOutput φ w x →
      ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ (robustRadius c w)^2 →
        7/16 ≤ labelReal b*noisyNetworkOutput φ w x η) ∧
    (labelReal b*networkOutput φ w x ≤ (1/4:ℝ) →
      ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ (robustRadius c w)^2 →
        labelReal b*noisyNetworkOutput φ w x η ≤ 5/16)

def support (φ : ℝ → ℝ) (c : ℝ) : Set (Weights d N r) :=
  {w | ∀ x,atInput φ c w x}

lemma all_noise_iff_unitBall {radius : ℝ} (hr : 0 < radius)
    (P : NetworkDisturbance N r → Prop) :
    (∀ η,noiseBudgetSq η ≤ radius^2 → P η) ↔
      ∀ η,noiseBudgetSq η ≤ 1 → P (scaleDisturbance radius η) := by
  constructor
  · intro h η hη
    apply h
    rw [noiseBudgetSq_scale]
    simpa only [mul_one] using mul_le_mul_of_nonneg_left hη (sq_nonneg radius)
  · intro h η hη
    let ζ := scaleDisturbance radius⁻¹ η
    have hζ : noiseBudgetSq ζ ≤ 1 := by
      dsimp [ζ]
      rw [noiseBudgetSq_scale]
      have hh := mul_le_mul_of_nonneg_left hη (sq_nonneg radius⁻¹)
      simpa [← mul_pow,hr.ne'] using hh
    have hh := h ζ hζ
    have hid : scaleDisturbance radius ζ = η := by
      dsimp [ζ]
      rw [scaleDisturbance_mul,mul_inv_cancel₀ hr.ne',scaleDisturbance_one]
    simpa only [hid] using hh

lemma continuous_scaledNoiseOutput {φ : ℝ → ℝ} (hφ : Continuous φ)
    (c : ℝ) (x : Cube d) (η : NetworkDisturbance N r) :
    Continuous (fun w : Weights d N r => noisyNetworkOutput φ w x (scaleDisturbance (robustRadius c w) η)) := by
  apply continuous_noisyNetworkOutput hφ x
  apply Continuous.prodMk
  · apply continuous_pi
    intro s
    apply continuous_pi
    intro i
    exact (continuous_robustRadius c).mul continuous_const
  · exact (continuous_robustRadius c).mul continuous_const

lemma measurable_atInput {φ : ℝ → ℝ} (hφ : Continuous φ) {c : ℝ} (hc : 0 < c)
    (x : Cube d) : MeasurableSet {w : Weights d N r | atInput φ c w x} := by
  let low (b : Bool) : Set (Weights d N r) :=
    {w | ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ 1 →
      (7/16:ℝ) ≤ labelReal b*noisyNetworkOutput φ w x (scaleDisturbance (robustRadius c w) η)}
  let high (b : Bool) : Set (Weights d N r) :=
    {w | ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ 1 →
      labelReal b*noisyNetworkOutput φ w x (scaleDisturbance (robustRadius c w) η) ≤ (5/16:ℝ)}
  have hlo (b : Bool) : IsClosed (low b) := by
    simp only [low,Set.setOf_forall]
    exact isClosed_iInter fun η => isClosed_iInter fun _ =>
      isClosed_le continuous_const ((continuous_scaledNoiseOutput hφ c x η).const_mul _)
  have hhi (b : Bool) : IsClosed (high b) := by
    simp only [high,Set.setOf_forall]
    exact isClosed_iInter fun η => isClosed_iInter fun _ =>
      isClosed_le ((continuous_scaledNoiseOutput hφ c x η).const_mul _) continuous_const
  have heq : {w : Weights d N r | atInput φ c w x} = ⋂ b : Bool,
      ({w | labelReal b*networkOutput φ w x < (1/2:ℝ)} ∪ low b) ∩
      ({w | (1/4:ℝ) < labelReal b*networkOutput φ w x} ∪ high b) := by
    ext w
    simp only [atInput,Set.mem_iInter,Set.mem_inter_iff,Set.mem_union,Set.mem_setOf_eq,low,high]
    simp only [all_noise_iff_unitBall (robustRadius_pos hc w)]
    simp only [imp_iff_not_or,not_le]
  rw [heq]
  exact MeasurableSet.iInter fun b =>
    ((measurableSet_lt ((continuous_networkOutput hφ x).measurable.const_mul _) measurable_const).union (hlo b).measurableSet).inter
    ((measurableSet_lt measurable_const ((continuous_networkOutput hφ x).measurable.const_mul _)).union (hhi b).measurableSet)

lemma measurable_support {φ : ℝ → ℝ} (hφ : Continuous φ) {c : ℝ} (hc : 0 < c) :
    MeasurableSet (support (d := d) (N := N) (r := r) φ c) := by
  simp only [support,Set.setOf_forall]
  exact MeasurableSet.iInter (measurable_atInput hφ hc)

/-- The original clipped condition implies both transport implications at
exactly the same radius, including equality at the triggering margins. -/
theorem of_clipped_atInput {φ : ℝ → ℝ} {c : ℝ} {w : Weights d N r} {x : Cube d}
    (hw : stableAt φ c w x) : atInput φ c w x := by
  intro b
  constructor
  · intro hz η hη
    have hclose := hw η hη
    have habs : |labelReal b*clippedScore (noisyNetworkOutput φ w x η)-
        labelReal b*clippedScore (networkOutput φ w x)| ≤ 1/16 := by
      simpa only [← mul_sub,abs_mul,abs_labelReal,one_mul] using hclose
    have hclip : labelReal b*clippedScore (networkOutput φ w x) = 1/2 := by
      rw [← signed_clippedScore]
      unfold clippedScore
      rw [min_eq_left hz,max_eq_right (by norm_num)]
    rw [← le_clippedScore_iff (by norm_num : -(1/2:ℝ)<7/16) (by norm_num),signed_clippedScore]
    have hh := abs_le.mp habs
    linarith
  · intro hz η hη
    have hclose := hw η hη
    have habs : |labelReal b*clippedScore (noisyNetworkOutput φ w x η)-
        labelReal b*clippedScore (networkOutput φ w x)| ≤ 1/16 := by
      simpa only [← mul_sub,abs_mul,abs_labelReal,one_mul] using hclose
    have hclip := RobustStatistics.signed_clippedScore_le_quarter b _ hz
    rw [← clippedScore_le_iff (by norm_num : -(1/2:ℝ)≤5/16) (by norm_num),signed_clippedScore]
    have hh := abs_le.mp habs
    linarith

theorem clipped_support_subset (φ : ℝ → ℝ) (c : ℝ) :
    robustEvent (d := d) (N := N) (r := r) φ c ⊆ support φ c :=
  fun _ hw x => of_clipped_atInput (hw x)

/-- Under global clean separation, the training-level implication for both
signs already implies the test-level implication. -/
theorem test_redundant_of_global_margin {z z' : ℝ} (hz : 1/2 < |z|)
    (htrain : ∀ b : Bool,(1/2:ℝ) ≤ labelReal b*z → 7/16 ≤ labelReal b*z') :
    ∀ b : Bool,labelReal b*z ≤ (1/4:ℝ) → labelReal b*z' ≤ 5/16 := by
  intro b hb
  cases b
  · simp only [labelReal_false,neg_one_mul] at hb ⊢
    have ht := htrain true
    simp only [labelReal_true,one_mul] at ht
    rcases lt_abs.mp hz with hpos | hneg
    · linarith [ht hpos.le]
    · linarith
  · simp only [labelReal_true,one_mul] at hb ⊢
    have ht := htrain false
    simp only [labelReal_false,neg_one_mul] at ht
    rcases lt_abs.mp hz with hpos | hneg
    · linarith
    · linarith [ht (by linarith)]

end NeuralGeneralization.TwoMarginTransport
