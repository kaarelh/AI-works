import UniformStableScalarLift
import TaggedPrescribedSequence

noncomputable section
set_option maxHeartbeats 1200000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

theorem uniformLiftedScalarState_floor {q t δ : ℝ} (p : ScalarPath q) (hinc : p.Increasing)
    (ht : 0≤t) (ht1 : t≤1) (hδ : 0≤δ) (hδ1 : δ<1)
    (hsmall : 4*(p.length:ℝ)*δ≤1) (j : ℕ) (hj : j≤p.length) :
    q/2≤(uniformLiftedScalarState p t δ j).1 := by
  have hlo := uniformLiftedScalarState_relative_lower p ht ht1 hδ hδ1 j hj
  have hq := p.state_floor hinc j
  have hpos := p.state_pos 0
  rw [p.state_zero] at hpos
  have hjreal : (j:ℝ)≤p.length := by exact_mod_cast hj
  have hm := mul_le_mul_of_nonneg_right hjreal hδ
  have hfactor : (1/2:ℝ)≤1-2*(j:ℝ)*δ := by nlinarith
  have hh := mul_le_mul hfactor hq hpos.le (by linarith : 0≤1-2*(j:ℝ)*δ)
  linarith

/-- Arbitrary critical scalar controls can be reused with physical residual
noise t²r. The path has the same controls, while its readout loss and score bound
are uniform over 0<t≤1. -/
theorem exists_uniform_stable_replay {q t δ : ℝ} (p : ScalarPath q) (hinc : p.Increasing)
    (ht : 0<t) (ht1 : t≤1) (hδ : 0≤δ) (hδ1 : δ<1)
    (hsmall : 4*(p.length:ℝ)*δ≤1) :
    ∃P : TaggedScalarPath t q δ,
      P.length=p.length ∧ (∀j≤p.length,P.state j=uniformLiftedScalarState p t δ j) ∧
      (∀j<p.length,P.control j=(p.control j).prod scoreSignLaw) ∧
      P.bound≤1/Real.sqrt (q/2)+1 ∧
      1/(8*P.terminal.1)≤(1+4*(p.length:ℝ)*δ)/(8*p.state p.length) := by
  have hq : 0<q := by simpa only [p.state_zero] using p.state_pos 0
  have hpos (j : ℕ) (hj : j≤p.length) :
      0<(uniformLiftedScalarState p t δ j).1 ∧ 0≤(uniformLiftedScalarState p t δ j).2 := by
    have hh := uniformLiftedScalarState_bounds p ht.le ht1 hδ hδ1 j hj
    exact ⟨hh.1,hh.2.2.2.1⟩
  obtain ⟨P,hlen,hstate,hcontrol,hB⟩ := exists_tagged_prescribed_sequence ht (by positivity : 0<q/2)
    p.length (uniformLiftedScalarState p t δ) p.control hpos
    (uniformLiftedScalarState_floor p hinc ht.le ht1 hδ hδ1 hsmall)
    (fun j _=>p.control_probability j) (fun j _=>p.control_finiteKL j)
    (fun _ _=>le_rfl) (fun j _=>by simp only [uniformLiftedScalarState,add_sub_cancel_left])
  have hterminal : P.terminal=uniformLiftedScalarState p t δ p.length := by
    rw [←P.state_terminal,hlen,hstate p.length le_rfl]
  refine ⟨P,hlen,hstate,hcontrol,hB,?_⟩
  rw [hterminal]
  exact uniformLiftedScalarState_readout p ht.le ht1 hδ hδ1 hsmall

#print axioms exists_uniform_stable_replay
end ConditionalNonpolynomial.Analytic
