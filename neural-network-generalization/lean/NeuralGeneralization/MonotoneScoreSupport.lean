import NeuralGeneralization.MonotoneScoreTransform
import NeuralGeneralization.RobustTargetNoisyMargin

/-! Measurable transformed-score support and the unchanged constructive
Gaussian target-mass lower bound for every admissible transform. -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.ScoreTransform
open ConcreteModel
variable {d C N r : ℕ} {F : ℝ → ℝ}

def atInput (F : ℝ → ℝ) (φ : ℝ → ℝ) (c : ℝ) (w : Weights d N r) (x : Cube d) : Prop :=
  ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ (robustRadius c w)^2 →
    |F (noisyNetworkOutput φ w x η)-F (networkOutput φ w x)| ≤ gap F/4

def support (F : ℝ → ℝ) (φ : ℝ → ℝ) (c : ℝ) : Set (Weights d N r) :=
  {w | ∀ x,atInput F φ c w x}

lemma isClosed_atInput (hF : Admissible F) {φ : ℝ → ℝ} (hφ : Continuous φ) {c : ℝ} (hc : 0 < c)
    (x : Cube d) : IsClosed {w : Weights d N r | atInput F φ c w x} := by
  have heq : {w : Weights d N r | atInput F φ c w x} =
      {w | ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ 1 →
        |F (noisyNetworkOutput φ w x (scaleDisturbance (robustRadius c w) η))-
          F (networkOutput φ w x)| ≤ gap F/4} := by
    ext w
    exact TwoMarginTransport.all_noise_iff_unitBall (robustRadius_pos hc w) _
  rw [heq]
  simp only [Set.setOf_forall]
  exact isClosed_iInter fun η => isClosed_iInter fun _ =>
    isClosed_le (((hF.continuous.comp
      (TwoMarginTransport.continuous_scaledNoiseOutput hφ c x η)).sub
      (hF.continuous.comp (continuous_networkOutput hφ x))).abs) continuous_const

lemma measurable_support (hF : Admissible F) {φ : ℝ → ℝ} (hφ : Continuous φ) {c : ℝ} (hc : 0 < c) :
    MeasurableSet (support (d := d) (N := N) (r := r) F φ c) := by
  simp only [support,Set.setOf_forall]
  exact MeasurableSet.iInter fun x => (isClosed_atInput hF hφ hc x).measurableSet

/-- The original cylinder makes every transformed score exactly equal to
its clean value: both clean and noisy raw outputs are already saturated. -/
lemma uniformNoisyMargin_subset (hF : Admissible F) (c : ℝ) (f : BooleanFunction d) :
    uniformNoisyMargin (N := N) (r := r) c f ⊆
      support F Real.tanh c ∩ marginEvent Real.tanh (1/2) f := by
  intro w hw
  have hclean (x : Cube d) : 1 < labelReal (f x)*networkOutput Real.tanh w x := by
    have hh := hw x 0 (by simp only [noiseBudgetSq_zero]; positivity)
    simpa only [noisyNetworkOutput_zero] using hh
  constructor
  · intro x η hη
    have hc : labelReal (f x)*F (networkOutput Real.tanh w x) = F (1/2) := by
      rw [← hF.signed]
      exact hF.saturated _ (by linarith [hclean x])
    have hn : labelReal (f x)*F (noisyNetworkOutput Real.tanh w x η) = F (1/2) := by
      rw [← hF.signed]
      exact hF.saturated _ (by linarith [hw x η hη])
    have heq : F (noisyNetworkOutput Real.tanh w x η) = F (networkOutput Real.tanh w x) := by
      cases hb : f x <;> simp only [hb,labelReal_false,labelReal_true,neg_one_mul,one_mul] at hc hn <;> linarith
    rw [heq,sub_self,abs_zero]
    exact div_nonneg hF.gap_pos.le (by norm_num)
  · intro x
    linarith [hclean x]

theorem target_mass (hF : Admissible F) (hd : 0 < d) (B : LayeredBooleanCircuit d C r)
    (hCN : C ≤ N) {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) :
    Real.exp (-digitalMassPolynomial d C r c/σ^2) ≤
      (smallPrior d N r σ).real (support F Real.tanh c ∩ marginEvent Real.tanh (1/2) B.computes) :=
  (uniform_noisy_margin_target_mass hd B hCN hc hσ hscale).trans
    (measureReal_mono (uniformNoisyMargin_subset hF c B.computes))

end NeuralGeneralization.ScoreTransform
