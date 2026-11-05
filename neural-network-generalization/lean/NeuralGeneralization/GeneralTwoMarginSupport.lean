import NeuralGeneralization.GeneralTwoMarginComparison
import NeuralGeneralization.GeneralMarginTarget
import NeuralGeneralization.TwoMarginSupport
import NeuralGeneralization.PointwiseRobustSupport

/-! The label-free two-margin support, its Borel measurability, and its
relation to the original clipped-score support. -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.GeneralTwoMargin
open ConcreteModel
open TwoMarginTransport (all_noise_iff_unitBall continuous_scaledNoiseOutput)
variable {d C N r : ℕ} {m u θ : ℝ}

/-- Both signs are quantified, so this is a label-free support predicate. -/
def atInput (m u θ : ℝ) (φ : ℝ → ℝ) (c : ℝ) (w : Weights d N r) (x : Cube d) : Prop :=
  ∀ b : Bool,
    (m ≤ labelReal b*networkOutput φ w x →
      ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ (robustRadius c w)^2 →
        (m-θ) ≤ labelReal b*noisyNetworkOutput φ w x η) ∧
    (labelReal b*networkOutput φ w x ≤ u →
      ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ (robustRadius c w)^2 →
        labelReal b*noisyNetworkOutput φ w x η ≤ (u+θ))

def support (m u θ : ℝ) (φ : ℝ → ℝ) (c : ℝ) : Set (Weights d N r) :=
  {w | ∀ x,atInput m u θ φ c w x}

lemma measurable_atInput (m u θ : ℝ) {φ : ℝ → ℝ} (hφ : Continuous φ) {c : ℝ} (hc : 0 < c)
    (x : Cube d) : MeasurableSet {w : Weights d N r | atInput m u θ φ c w x} := by
  let low (b : Bool) : Set (Weights d N r) :=
    {w | ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ 1 →
      (m-θ) ≤ labelReal b*noisyNetworkOutput φ w x (scaleDisturbance (robustRadius c w) η)}
  let high (b : Bool) : Set (Weights d N r) :=
    {w | ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ 1 →
      labelReal b*noisyNetworkOutput φ w x (scaleDisturbance (robustRadius c w) η) ≤ (u+θ)}
  have hlo (b : Bool) : IsClosed (low b) := by
    simp only [low,Set.setOf_forall]
    exact isClosed_iInter fun η => isClosed_iInter fun _ =>
      isClosed_le continuous_const ((continuous_scaledNoiseOutput hφ c x η).const_mul _)
  have hhi (b : Bool) : IsClosed (high b) := by
    simp only [high,Set.setOf_forall]
    exact isClosed_iInter fun η => isClosed_iInter fun _ =>
      isClosed_le ((continuous_scaledNoiseOutput hφ c x η).const_mul _) continuous_const
  have heq : {w : Weights d N r | atInput m u θ φ c w x} = ⋂ b : Bool,
      ({w | labelReal b*networkOutput φ w x < m} ∪ low b) ∩
      ({w | u < labelReal b*networkOutput φ w x} ∪ high b) := by
    ext w
    simp only [atInput,Set.mem_iInter,Set.mem_inter_iff,Set.mem_union,Set.mem_setOf_eq,low,high]
    simp only [all_noise_iff_unitBall (robustRadius_pos hc w)]
    simp only [imp_iff_not_or,not_le]
  rw [heq]
  exact MeasurableSet.iInter fun b =>
    ((measurableSet_lt ((continuous_networkOutput hφ x).measurable.const_mul _) measurable_const).union (hlo b).measurableSet).inter
    ((measurableSet_lt measurable_const ((continuous_networkOutput hφ x).measurable.const_mul _)).union (hhi b).measurableSet)

lemma measurable_support (m u θ : ℝ) {φ : ℝ → ℝ} (hφ : Continuous φ) {c : ℝ} (hc : 0 < c) :
    MeasurableSet (support (d := d) (N := N) (r := r) m u θ φ c) := by
  simp only [support,Set.setOf_forall]
  exact MeasurableSet.iInter (measurable_atInput m u θ hφ hc)

/-- Every target-cylinder output has signed margin above m, so both transport
implications hold for both labels at every input and allowed disturbance. -/
lemma uniformNoisyMargin_subset (hp : Parameters m u θ) (c : ℝ) (f : BooleanFunction d) :
    GeneralMargin.uniformNoisyMargin (N := N) (r := r) m c f ⊆
      support m u θ Real.tanh c ∩ marginEvent Real.tanh m f := by
  intro w hw
  have hclean (x : Cube d) : m < labelReal (f x)*networkOutput Real.tanh w x := by
    have hh := hw x 0 (by simp only [noiseBudgetSq_zero]; positivity)
    simpa only [noisyNetworkOutput_zero] using hh
  have hm := hp.train_pos
  have hu := hp.test_nonneg
  have ht := hp.tolerance_nonneg
  have hum := hp.test_lt_train
  constructor
  · intro x b
    constructor
    · intro hz η hη
      have hc := hclean x
      have hn := hw x η hη
      cases b <;> cases hf : f x <;>
        simp only [hf,labelReal_false,labelReal_true,neg_one_mul,one_mul] at hc hn hz ⊢ <;> linarith
    · intro hz η hη
      have hc := hclean x
      have hn := hw x η hη
      cases b <;> cases hf : f x <;>
        simp only [hf,labelReal_false,labelReal_true,neg_one_mul,one_mul] at hc hn hz ⊢ <;> linarith
  · exact hclean

theorem target_mass (hp : Parameters m u θ) (hd : 0 < d) (B : LayeredBooleanCircuit d C r)
    (hCN : C ≤ N) {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) :
    Real.exp (-digitalMassPolynomial d C r (c+m+1)/σ^2) ≤
      (smallPrior d N r σ).real (support m u θ Real.tanh c ∩ marginEvent Real.tanh m B.computes) :=
  (GeneralMargin.uniform_noisy_margin_target_mass hp.train_pos.le hd B hCN hc hσ hscale).trans
    (measureReal_mono (uniformNoisyMargin_subset hp c B.computes))

end NeuralGeneralization.GeneralTwoMargin
