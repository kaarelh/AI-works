import SteeringScalarLift
import ScaledSplitRowChannel
import UniformPrescribedSteering
import ScalarPathScoreProgram
import ScalarIncreasingPath

noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

def uniformLiftedScalarState {q : ℝ} (p : ScalarPath q) (t δ : ℝ) : ℕ → ℝ × ℝ
  | 0 => (q,δ)
  | j+1 => (controlledSignal (p.control j) (uniformLiftedScalarState p t δ j).1 (t^2*(uniformLiftedScalarState p t δ j).2),
      controlledResidual (p.control j) (uniformLiftedScalarState p t δ j).1 (t^2*(uniformLiftedScalarState p t δ j).2))

theorem uniformLiftedScalarState_bounds {q t δ : ℝ} (p : ScalarPath q)
    (ht : 0≤t) (ht1 : t≤1) (hδ : 0 ≤ δ) (hδ1 : δ < 1) (j : ℕ) (hj : j ≤ p.length) :
    0 < (uniformLiftedScalarState p t δ j).1 ∧
    (uniformLiftedScalarState p t δ j).1 ≤ p.state j ∧
    (1-δ)^(2*j)*p.state j ≤ (uniformLiftedScalarState p t δ j).1 ∧
    0 ≤ (uniformLiftedScalarState p t δ j).2 ∧ (uniformLiftedScalarState p t δ j).2 ≤ δ := by
  induction j with
  | zero =>
    simpa only [uniformLiftedScalarState,ScalarPath.state_zero,Nat.mul_zero,pow_zero,one_mul] using
      And.intro (p.state_pos 0) ⟨le_refl q,le_refl q,hδ,le_refl δ⟩
  | succ j ih =>
    have hjlt : j < p.length := by omega
    have hb := ih (by omega)
    letI := p.control_probability j
    have hnoise : 0≤t^2*(uniformLiftedScalarState p t δ j).2 := mul_nonneg (sq_nonneg _) hb.2.2.2.1
    have hnoiseLe : t^2*(uniformLiftedScalarState p t δ j).2≤(uniformLiftedScalarState p t δ j).2 := by
      have hh := mul_le_mul_of_nonneg_right (show t^2≤1 by nlinarith) hb.2.2.2.1
      simpa only [one_mul] using hh
    have hnoiseδ := hnoiseLe.trans hb.2.2.2.2
    have hn := controlledSignal_bounds (p.control j) hb.1.le (p.state_pos j) hb.2.1
      hnoise (hnoiseδ.trans hδ1.le)
    rw [p.state_transition j hjlt] at hn
    have hr := controlledResidual_bounds (p.control j) hnoise (uniformLiftedScalarState p t δ j).1
    have hfac : (1-δ)^2 ≤ (1-(t^2*(uniformLiftedScalarState p t δ j).2))^2 :=
      pow_le_pow_left₀ (by linarith) (by linarith) 2
    have hratio : (1-δ)^(2*j) ≤ (uniformLiftedScalarState p t δ j).1/p.state j :=
      (le_div_iff₀ (p.state_pos j)).mpr hb.2.2.1
    have hprod := mul_le_mul hfac hratio (by positivity)
      (sq_nonneg (1-(t^2*(uniformLiftedScalarState p t δ j).2)))
    have hprod' := mul_le_mul_of_nonneg_right hprod (p.state_pos (j+1)).le
    have he : (1-δ)^2*(1-δ)^(2*j)=(1-δ)^(2*(j+1)) := by
      rw [show 2*(j+1)=2*j+2 by omega,pow_add]
      ring
    rw [he] at hprod'
    have hlo := hprod'.trans hn.1
    have hpos : 0 < (1-δ)^(2*(j+1))*p.state (j+1) :=
      mul_pos (pow_pos (by linarith) _) (p.state_pos (j+1))
    exact ⟨hpos.trans_le hlo,hn.2,hlo,hr.1,hr.2.trans hnoiseδ⟩

theorem uniformLiftedScalarState_relative_lower {q t δ : ℝ} (p : ScalarPath q)
    (ht : 0≤t) (ht1 : t≤1) (hδ : 0 ≤ δ) (hδ1 : δ < 1) (j : ℕ) (hj : j ≤ p.length) :
    (1-2*(j : ℝ)*δ)*p.state j ≤ (uniformLiftedScalarState p t δ j).1 := by
  have hh := one_add_mul_le_pow (show -2 ≤ -δ by linarith) (2*j)
  have he : 1+(2*j : ℕ)*(-δ)=1-2*(j : ℝ)*δ := by push_cast; ring
  rw [he,show 1+(-δ)=1-δ by ring] at hh
  exact (mul_le_mul_of_nonneg_right hh (p.state_pos j).le).trans
    (uniformLiftedScalarState_bounds p ht ht1 hδ hδ1 j hj).2.2.1

theorem uniformLiftedScalarState_readout {q t δ : ℝ} (p : ScalarPath q)
    (ht : 0≤t) (ht1 : t≤1) (hδ : 0 ≤ δ) (hδ1 : δ < 1) (hsmall : 4*(p.length : ℝ)*δ ≤ 1) :
    1/(8*(uniformLiftedScalarState p t δ p.length).1) ≤
      (1+4*(p.length : ℝ)*δ)/(8*p.state p.length) := by
  have hb := uniformLiftedScalarState_bounds p ht ht1 hδ hδ1 p.length le_rfl
  have hlo := uniformLiftedScalarState_relative_lower p ht ht1 hδ hδ1 p.length le_rfl
  have hlen : 0 ≤ (p.length : ℝ) := Nat.cast_nonneg _
  have ht : 0 ≤ 2*(p.length : ℝ)*δ := by positivity
  have ht1 : 2*(p.length : ℝ)*δ ≤ 1/2 := by linarith
  have hm := mul_nonneg ht (show 0 ≤ 1-2*(2*(p.length : ℝ)*δ) by linarith)
  have hfac : 1 ≤ (1+4*(p.length : ℝ)*δ)*(1-2*(p.length : ℝ)*δ) := by nlinarith
  have hq := mul_le_mul_of_nonneg_right hfac (p.state_pos p.length).le
  have hscaled := mul_le_mul_of_nonneg_left hlo (show 0 ≤ 1+4*(p.length : ℝ)*δ by positivity)
  apply (div_le_div_iff₀ (mul_pos (by norm_num) hb.1)
    (mul_pos (by norm_num) (p.state_pos p.length))).mpr
  nlinarith

theorem uniformLiftedScalarState_moment {q t δ : ℝ} (p : ScalarPath q)
    (ht : 0≤t) (ht1 : t≤1) (hδ : 0≤δ) (hδ1 : δ<1) (j : ℕ) (hj : j<p.length) (f : Bool) :
    scalarSourceMoment ((p.control j).prod scoreSignLaw) Prod.fst
      (prescribedConditionalScore (p.control j) (uniformLiftedScalarState p t δ j).1
        (t^2*(uniformLiftedScalarState p t δ j).2) (uniformLiftedScalarState p t δ (j+1)).1)
      (residualScale t (scalarBooleanState f (uniformLiftedScalarState p t δ j).1
        (uniformLiftedScalarState p t δ j).2))=
      scalarBooleanState f (uniformLiftedScalarState p t δ (j+1)).1
        (uniformLiftedScalarState p t δ (j+1)).2 := by
  letI := p.control_probability j
  have hb := uniformLiftedScalarState_bounds p ht ht1 hδ hδ1 j (by omega)
  have hn := uniformLiftedScalarState_bounds p ht ht1 hδ hδ1 (j+1) (by omega)
  have hh := uniform_prescribed_score_channel (p.control j) ht hb.2.2.2.1 hn.1 (le_refl _) f
  simpa only [uniformLiftedScalarState,add_sub_cancel_left] using hh

#print axioms uniformLiftedScalarState_moment
#print axioms uniformLiftedScalarState_bounds
#print axioms uniformLiftedScalarState_readout
end ConditionalNonpolynomial.Analytic
