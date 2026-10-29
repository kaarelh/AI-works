import ScalarChannelTotalLaw

/-! Logarithmic occupation bounds for actual signal-plus-residual scalar
channel paths, derived from their literal moment recursion and Mathlib KL. -/
noncomputable section
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal
namespace ConditionalNonpolynomial.Analytic

def ScalarChannelPath.totalState {v r : ℝ} (p : ScalarChannelPath v r) (j : ℕ) : ℝ :=
  (p.state j).1+(p.state j).2

def ScalarChannelPath.totalControl {v r : ℝ} (p : ScalarChannelPath v r) (j : ℕ) : Measure ℝ :=
  channelTotalLaw (p.control j) (p.state j).1 (p.state j).2

lemma ScalarChannelPath.totalState_pos {v r : ℝ} (p : ScalarChannelPath v r) (j : ℕ) :
    0<p.totalState j := add_pos_of_pos_of_nonneg (p.state_pos j).1 (p.state_pos j).2

lemma ScalarChannelPath.totalState_le_one {v r : ℝ} (p : ScalarChannelPath v r)
    (hinit : v+r≤1) (j : ℕ) : p.totalState j≤1 := by
  induction p generalizing j with
  | stop _ _ => exact hinit
  | @step v r hv hr Q hprob hfinite tail ih =>
      letI := hprob
      cases j with
      | zero => exact hinit
      | succ j => exact ih (controlledTotal_le_one Q v r) j

lemma ScalarChannelPath.totalControl_probability {v r : ℝ} (p : ScalarChannelPath v r) (j : ℕ) :
    IsProbabilityMeasure (p.totalControl j) := by
  letI := p.control_probability j
  exact inferInstanceAs (IsProbabilityMeasure (channelTotalLaw (p.control j) (p.state j).1 (p.state j).2))

lemma ScalarChannelPath.totalControl_entropy {v r : ℝ} (p : ScalarChannelPath v r) (j : ℕ) :
    klDiv (p.totalControl j) (gaussianReal 0 1)≤klDiv (p.control j) (gaussianReal 0 1) := by
  letI := p.control_probability j
  exact channelTotalLaw_entropy (p.control j) (p.state_pos j).1 (p.state_pos j).2

lemma ScalarChannelPath.totalControl_finite {v r : ℝ} (p : ScalarChannelPath v r) (j : ℕ) :
    klDiv (p.totalControl j) (gaussianReal 0 1)≠∞ :=
  ne_of_lt (lt_of_le_of_lt (p.totalControl_entropy j) (lt_top_iff_ne_top.mpr (p.control_finiteKL j)))

lemma ScalarChannelPath.totalState_transition {v r : ℝ} (p : ScalarChannelPath v r)
    (j : ℕ) (hj : j<p.length) :
    p.totalState (j+1)=scalarTransition (p.totalState j) (p.totalControl j) := by
  letI := p.control_probability j
  unfold totalState totalControl
  rw [p.state_transition j hj,channelTotalLaw_transition (p.control j) (p.state_pos j).1 (p.state_pos j).2]

lemma ScalarChannelPath.total_readout_le {v r : ℝ} (p : ScalarChannelPath v r) :
    1/(8*p.totalState p.length)≤1/(8*p.terminal.1) := by
  have hv := (p.state_pos p.length).1
  have hr := (p.state_pos p.length).2
  rw [p.state_terminal] at hv hr
  unfold totalState
  rw [p.state_terminal]
  apply one_div_le_one_div_of_le (by positivity)
  nlinarith

/-- Actual scalar-channel controls have logarithmic square-root entropy
whenever their total action lies within epsilon of the critical baseline. -/
theorem ScalarChannelPath.sqrt_entropy_bound {v r ε : ℝ} (p : ScalarChannelPath v r)
    (hinit : v+r≤1) (hε : 0≤ε) (hnear : p.cost≤scalarBaseline.toReal+ε) :
    (∑j ∈ Finset.range p.length,Real.sqrt ((klDiv (p.control j) (gaussianReal 0 1)).toReal))≤
      Real.sqrt (526337*(p.length:ℝ)*ε+526336)+
      ((Nat.log2 (p.length+1)+1:ℕ):ℝ)*dyadicBlockConstant 526336 := by
  apply controlled_path_sqrt_entropy p.length p.totalState p.totalState
    (fun j=>(klDiv (p.control j) (gaussianReal 0 1)).toReal) p.totalControl hε
    (fun j _=>p.totalState_pos j) (fun j _=>p.totalState_le_one hinit j)
    (fun j _=>(p.totalState_pos j).le) (fun _ _=>le_rfl)
    (fun j _=>p.totalControl_probability j) (fun j _=>p.totalControl_finite j)
    (fun j _=>ENNReal.toReal_mono (p.control_finiteKL j) (p.totalControl_entropy j))
    (fun j hj=>(p.totalState_transition j hj).le) p.total_readout_le
  rw [←p.hiddenCost_eq_sum]
  exact hnear

theorem ScalarChannelPath.variance_occupation_bound {v r ε : ℝ} (p : ScalarChannelPath v r)
    (hinit : v+r≤1) (hε : 0≤ε) (hnear : p.cost≤scalarBaseline.toReal+ε) :
    (driftDissipation/2)*(∑j ∈ Finset.range p.length,p.totalState j)≤
      ((driftDissipation/2)*varianceEntropyConstant+3)*
        (Real.sqrt (526337*(p.length:ℝ)*ε+526336)+
          ((Nat.log2 (p.length+1)+1:ℕ):ℝ)*dyadicBlockConstant 526336)+
      Real.log (8*(257+ε)) := by
  apply controlled_path_variance_sum p.length p.totalState p.totalState
    (fun j=>(klDiv (p.control j) (gaussianReal 0 1)).toReal) p.totalControl hε
    (fun j _=>p.totalState_pos j) (fun j _=>p.totalState_le_one hinit j)
    (fun j _=>(p.totalState_pos j).le) (fun _ _=>le_rfl)
    (fun j _=>p.totalControl_probability j) (fun j _=>p.totalControl_finite j)
    (fun j _=>ENNReal.toReal_mono (p.control_finiteKL j) (p.totalControl_entropy j))
    (fun j hj=>(p.totalState_transition j hj).le) p.total_readout_le
  rw [←p.hiddenCost_eq_sum]
  exact hnear

#print axioms ScalarChannelPath.sqrt_entropy_bound
#print axioms ScalarChannelPath.variance_occupation_bound
end ConditionalNonpolynomial.Analytic
