import TaggedPrescribedSequence
import ScalarGaussianControls

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.BatchTwoContinuousDepthCritical

def gaussianReplayResidual {v r : ℝ} (p : ScalarChannelPath v r) (t r0 : ℝ) : ℕ→ℝ
  | 0=>r0
  | j+1=>controlledSignal (p.control j) (p.state j).1 (t^2*gaussianReplayResidual p t r0 j)+
      controlledResidual (p.control j) (p.state j).1 (t^2*gaussianReplayResidual p t r0 j)-
      (p.state (j+1)).1

theorem gaussianReplayResidual_step {v r t r0 : ℝ} (p : ScalarChannelPath v r)
    (hG : p.GaussianControls) (ht : 0≤t) (ht1 : t≤1)
    (j : ℕ) (hj : j<p.length) (hr : 0≤gaussianReplayResidual p t r0 j)
    (hrr : gaussianReplayResidual p t r0 j≤(p.state j).2) :
    (p.state (j+1)).1≤controlledSignal (p.control j) (p.state j).1
      (t^2*gaussianReplayResidual p t r0 j) ∧
    0≤gaussianReplayResidual p t r0 (j+1) ∧
    gaussianReplayResidual p t r0 (j+1)≤(p.state (j+1)).2 := by
  obtain ⟨ε,hε,hcontrol⟩ := hG j hj
  have hstage := gaussian_stage_reuse (a:=(1+ε)*(p.state j).1)
    (mul_nonneg (by linarith) (p.state_pos j).1.le) hr hrr ht ht1
  rw [gaussianReplayResidual,p.state_transition j hj,hcontrol]
  simp only [Prod.fst,Prod.snd,controlledSignal_steeringControl hε (p.state_pos j).1.le,
    controlledResidual_steeringControl hε (p.state_pos j).1.le]
  rw [steeringSignal_add_residual (mul_nonneg (by linarith) (p.state_pos j).1.le)
    (mul_nonneg (sq_nonneg _) hr)]
  exact ⟨hstage.1,hstage.2.1,hstage.2.2.1⟩

theorem gaussianReplayResidual_bounds {v r t r0 : ℝ} (p : ScalarChannelPath v r)
    (hG : p.GaussianControls) (ht : 0≤t) (ht1 : t≤1) (hr0 : 0≤r0) (hr0le : r0≤r)
    (j : ℕ) (hj : j≤p.length) :
    0≤gaussianReplayResidual p t r0 j ∧ gaussianReplayResidual p t r0 j≤(p.state j).2 := by
  induction j with
  | zero=>simpa only [gaussianReplayResidual,p.state_zero] using And.intro hr0 hr0le
  | succ j ih=>
    have hb := ih (by omega)
    exact (gaussianReplayResidual_step p hG ht ht1 j (by omega) hb.1 hb.2).2

/-- Uniform physical-noise reuse of an actual finite Gaussian path, with
identical scalar controls and therefore identical critical entropy charges. -/
theorem exists_uniform_gaussian_replay {v r t r0 β : ℝ} (p : ScalarChannelPath v r)
    (hG : p.GaussianControls) (ht : 0<t) (ht1 : t≤1) (hr0 : 0≤r0) (hr0le : r0≤r)
    (hβ : 0<β) (hfloor : p.SignalFloor β) :
    ∃P : TaggedScalarPath t v r0,
      P.length=p.length ∧
      (∀j≤p.length,P.state j=((p.state j).1,gaussianReplayResidual p t r0 j)) ∧
      (∀j<p.length,P.control j=(p.control j).prod scoreSignLaw) ∧
      P.bound≤1/Real.sqrt β+1 ∧
      P.terminal.1=p.terminal.1 ∧ 0≤P.terminal.2 ∧ P.terminal.2≤p.terminal.2 := by
  let s := fun j=>((p.state j).1,gaussianReplayResidual p t r0 j)
  have hpos (j : ℕ) (hj : j≤p.length) : 0<(s j).1 ∧ 0≤(s j).2 :=
    ⟨(p.state_pos j).1,(gaussianReplayResidual_bounds p hG ht.le ht1 hr0 hr0le j hj).1⟩
  have hsignal (j : ℕ) (hj : j<p.length) :
      (s (j+1)).1≤controlledSignal (p.control j) (s j).1 (t^2*(s j).2) := by
    have hb := gaussianReplayResidual_bounds p hG ht.le ht1 hr0 hr0le j (by omega)
    exact (gaussianReplayResidual_step p hG ht.le ht1 j hj hb.1 hb.2).1
  have hex := exists_tagged_prescribed_sequence ht hβ p.length s
    p.control hpos hfloor (fun j _=>p.control_probability j) (fun j _=>p.control_finiteKL j)
    hsignal (fun _ _=>rfl)
  simp only [s,gaussianReplayResidual] at hex
  rw [p.state_zero] at hex
  obtain ⟨P,hlen,hstate,hcontrol,hB⟩ := hex
  have hterminal : P.terminal=s p.length := by rw [←P.state_terminal,hlen,hstate p.length le_rfl]
  have hb := gaussianReplayResidual_bounds p hG ht.le ht1 hr0 hr0le p.length le_rfl
  have ht1' : P.terminal.1=p.terminal.1 := by
    rw [hterminal]
    change (p.state p.length).1=p.terminal.1
    exact congrArg Prod.fst p.state_terminal
  have ht2' : 0≤P.terminal.2 ∧ P.terminal.2≤p.terminal.2 := by
    rw [hterminal]
    simpa only [s,p.state_terminal] using hb
  exact ⟨P,hlen,hstate,hcontrol,hB,ht1',ht2'.1,ht2'.2⟩

#print axioms exists_uniform_gaussian_replay
end ConditionalNonpolynomial.Analytic
