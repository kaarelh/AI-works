import NeuralGeneralization.BatchTwoShallowTarget
import NeuralGeneralization.RobustReadoutTruncation

/-! The actual hard-margin likelihood, raw/restricted Gaussian posterior, and
the width-independent posterior readout tail. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel RobustPosterior

def trainingEvent {d N n : ℕ} (f : BooleanFunction d) (sample : Fin n → Cube d) : Set (Weights d N 0) :=
  {w | ∀ i, (1 : ℝ)/2 < labelReal (f (sample i))*networkOutput Real.tanh w (sample i)}

def conditioningEvent {d N n : ℕ} (c : ℝ) (robust global : Bool)
    (f : BooleanFunction d) (sample : Fin n → Cube d) : Set (Weights d N 0) :=
  priorSupport d N c robust global ∩ trainingEvent f sample

def posterior {d N n : ℕ} (σ c : ℝ) (robust global : Bool)
    (f : BooleanFunction d) (sample : Fin n → Cube d) : Measure (Weights d N 0) :=
  cond (smallPrior d N 0 σ) (conditioningEvent c robust global f sample)

theorem measurable_trainingEvent {d N n : ℕ} (f : BooleanFunction d) (sample : Fin n → Cube d) :
    MeasurableSet (trainingEvent (N := N) f sample) := by
  unfold trainingEvent
  simp only [Set.setOf_forall]
  apply MeasurableSet.iInter
  intro i
  exact measurableSet_lt measurable_const
    ((continuous_networkOutput tanh_continuous (sample i)).measurable.const_mul _)

theorem measurable_conditioningEvent {d N n : ℕ} {c : ℝ} (hc : 0 < c)
    (robust global : Bool) (f : BooleanFunction d) (sample : Fin n → Cube d) :
    MeasurableSet (conditioningEvent (N := N) c robust global f sample) :=
  (measurable_priorSupport d N hc robust global).inter (measurable_trainingEvent f sample)

theorem conditioning_mass {d C N n : ℕ} (hd : 0 < d) (hC : 0 < C) (hCN : C ≤ N)
    (w : Weights d C 0) (f : BooleanFunction d) (hw : w ∈ marginEvent Real.tanh (1/2) f)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N : ℝ)*σ^2 ≤ 1)
    (robust global : Bool) (sample : Fin n → Cube d) :
    Real.exp (-targetCost (targetScale c robust) w/σ^2) ≤
      (smallPrior d N 0 σ).real (conditioningEvent c robust global f sample) := by
  apply (shallow_target_mass hd hC hCN w f hw hc hσ hscale robust global).trans
  refine measureReal_mono ?_ (measure_ne_top _ _)
  intro u hu
  exact ⟨hu.1, fun i => hu.2 (sample i)⟩

def readoutBoundSq {d C : ℕ} (s ε : ℝ) (w : Weights d C 0) : ℝ :=
  8*(targetCost s w+Real.log (4/ε))

def readoutBound {d C : ℕ} (s ε : ℝ) (w : Weights d C 0) : ℝ := Real.sqrt (readoutBoundSq s ε w)

theorem readoutBoundSq_gt_eight {d C : ℕ} {s ε : ℝ}
    (hs : 0 ≤ s) (hε : 0 < ε) (hε1 : ε < 1) (w : Weights d C 0) :
    8 < readoutBoundSq s ε w := by
  have hratio : 1 ≤ 4/ε := (le_div_iff₀ hε).mpr (by linarith)
  have hl := Real.log_nonneg hratio
  have hcost := targetCost_gt_one hs w
  unfold readoutBoundSq
  linarith

theorem readoutBound_pos {d C : ℕ} {s ε : ℝ}
    (hs : 0 ≤ s) (hε : 0 < ε) (hε1 : ε < 1) (w : Weights d C 0) :
    0 < readoutBound s ε w := Real.sqrt_pos.mpr (by linarith [readoutBoundSq_gt_eight hs hε hε1 w])

theorem readoutBound_sq {d C : ℕ} {s ε : ℝ}
    (hs : 0 ≤ s) (hε : 0 < ε) (hε1 : ε < 1) (w : Weights d C 0) :
    (readoutBound s ε w)^2=readoutBoundSq s ε w :=
  Real.sq_sqrt (by linarith [readoutBoundSq_gt_eight hs hε hε1 w])

theorem posterior_readout_tail {d C N n : ℕ} (hd : 0 < d) (hC : 0 < C) (hCN : C ≤ N)
    (w : Weights d C 0) (f : BooleanFunction d) (hw : w ∈ marginEvent Real.tanh (1/2) f)
    {c σ ε : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N : ℝ)*σ^2 ≤ 1)
    (hε : 0 < ε) (hε1 : ε < 1) (robust global : Bool) (sample : Fin n → Cube d) :
    (posterior σ c robust global f sample).real
      {u : Weights d N 0 | (readoutBound (targetScale c robust) ε w)^2 < readoutEnergy u} ≤ ε/4 := by
  let s := targetScale c robust
  have hs : 0 ≤ s := by dsimp [s,targetScale]; cases robust <;> simp <;> linarith
  have hN : 0 < N := hC.trans_le hCN
  have hN1 : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hσ2 : 0 < σ^2 := sq_pos_of_pos hσ
  have hσ1 : σ^2 ≤ 1 := by nlinarith
  have hR := readoutBoundSq_gt_eight hs hε hε1 w
  have ht := smallPrior_readout_tail (r := 0) hd hN hσ
    (B := readoutBoundSq s ε w) (by nlinarith)
  have hm := conditioning_mass hd hC hCN w f hw hc hσ hscale robust global sample
  have hlog : Real.log (ε/4) = -Real.log (4/ε) := by
    rw [Real.log_div hε.ne' (by norm_num), Real.log_div (by norm_num) hε.ne']
    ring
  have hb : 4*(targetCost s w-Real.log (ε/4)) ≤ readoutBoundSq s ε w := by
    rw [hlog]
    unfold readoutBoundSq at *
    linarith
  have hh := conditional_tail_of_exponential_bounds (smallPrior d N 0 σ)
    (conditioningEvent c robust global f sample)
    {u | readoutBoundSq s ε w < readoutEnergy u}
    (measurable_conditioningEvent hc robust global f sample)
    hσ2 hσ1 (by positivity : 0 < ε/4) (by linarith : ε/4 ≤ 1) hm ht hb
  change (posterior σ c robust global f sample).real
    {u : Weights d N 0 | (readoutBound s ε w)^2 < readoutEnergy u} ≤ ε/4
  rw [readoutBound_sq hs hε hε1]
  exact hh

end NeuralGeneralization.BatchTwoShallow
