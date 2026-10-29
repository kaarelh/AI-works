import ScalarChannelFloor
import ConditionalMeanScore

/-! Actual bounded-score channel programs associated with finite scalar paths.
Outside the finite path, the score is the unit constant and the nominal state
continues by its actual population moment recursion. -/
noncomputable section
set_option maxHeartbeats 1500000
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

def scalarBooleanState (f : Bool) (v r : ℝ) : WithLp 2 (ℝ×ℝ) :=
  WithLp.toLp 2 (labelReal f*Real.sqrt v,Real.sqrt r)

theorem scalarBooleanState_canonical (f : Bool) {v r : ℝ} (hv : 0≤v) (hr : 0≤r) :
    scalarBooleanState f v r=canonicalCompletion (labelReal f*Real.sqrt v) (v+r) := by
  have hs : ‖labelReal f*Real.sqrt v‖^2=v := by
    rw [Real.norm_eq_abs,sq_abs,mul_pow,Real.sq_sqrt hv]
    cases f <;> simp
  unfold canonicalCompletion scalarBooleanState
  rw [hs,add_sub_cancel_left,max_eq_right hr]

def ScalarChannelPath.score {v r : ℝ} (p : ScalarChannelPath v r) (j : ℕ) : ℝ→ℝ :=
  if j<p.length then normalizedConditionalScore (p.control j) (p.state j).1 (p.state j).2
  else fun _=>1

lemma ScalarChannelPath.next_signal_pos {v r : ℝ} (p : ScalarChannelPath v r)
    (j : ℕ) (hj : j<p.length) :
    0<controlledSignal (p.control j) (p.state j).1 (p.state j).2 := by
  have h := (p.state_pos (j+1)).1
  rw [p.state_transition j hj] at h
  exact h

lemma ScalarChannelPath.score_measurable {v r : ℝ} (p : ScalarChannelPath v r) (j : ℕ) :
    Measurable (p.score j) := by
  unfold score
  split_ifs
  · exact normalizedConditionalScore_measurable _ _ _
  · exact measurable_const

lemma ScalarChannelPath.score_memLp {v r : ℝ} (p : ScalarChannelPath v r) (j : ℕ) :
    MemLp (p.score j) 2 (p.control j) := by
  letI := p.control_probability j
  unfold score
  split_ifs with hj
  · exact normalizedConditionalScore_memLp _ _ _ (p.next_signal_pos j hj)
  · exact memLp_const 1

lemma ScalarChannelPath.score_unit {v r : ℝ} (p : ScalarChannelPath v r) (j : ℕ) :
    (∫z,(p.score j z)^2 ∂p.control j)=1 := by
  letI := p.control_probability j
  unfold score
  split_ifs with hj
  · exact normalizedConditionalScore_unit _ _ _ (p.next_signal_pos j hj)
  · simp

lemma ScalarChannelPath.score_bound {v r β : ℝ} (p : ScalarChannelPath v r)
    (hβ : 0<β) (hfloor : p.SignalFloor β) (j : ℕ) (z : ℝ) :
    |p.score j z|≤max 1 (1/Real.sqrt β) := by
  unfold score
  split_ifs with hj
  · have hS := p.next_signal_pos j hj
    apply (normalizedConditionalScore_bound _ _ _ hS z).trans
    apply le_trans _ (le_max_right _ _)
    apply one_div_le_one_div_of_le (Real.sqrt_pos.mpr hβ)
    apply Real.sqrt_le_sqrt
    have hh := hfloor (j+1) (by omega)
    rw [p.state_transition j hj] at hh
    exact hh
  · simpa using le_max_left (1:ℝ) (1/Real.sqrt β)

def ScalarChannelPath.nominal {v r : ℝ} (p : ScalarChannelPath v r) (f : Bool) :
    ℕ→WithLp 2 (ℝ×ℝ)
  | 0=>scalarBooleanState f v r
  | j+1=>scalarSourceMoment (p.control j) id (p.score j) (p.nominal f j)

@[simp] lemma ScalarChannelPath.nominal_zero {v r : ℝ} (p : ScalarChannelPath v r) (f : Bool) :
    p.nominal f 0=scalarBooleanState f v r := rfl

@[simp] lemma ScalarChannelPath.nominal_succ {v r : ℝ} (p : ScalarChannelPath v r) (f : Bool) (j : ℕ) :
    p.nominal f (j+1)=scalarSourceMoment (p.control j) id (p.score j) (p.nominal f j) := rfl

/-- The globally defined moment recursion exactly tracks the path during every
stage actually used by the finite network. -/
theorem ScalarChannelPath.nominal_eq_state {v r : ℝ} (p : ScalarChannelPath v r)
    (f : Bool) (j : ℕ) (hj : j≤p.length) :
    p.nominal f j=scalarBooleanState f (p.state j).1 (p.state j).2 := by
  induction j with
  | zero => rw [p.state_zero]; rfl
  | succ j ih =>
      letI := p.control_probability j
      have hj' : j<p.length := by omega
      rw [p.nominal_succ,ih (by omega)]
      have hscore : p.score j=normalizedConditionalScore (p.control j) (p.state j).1 (p.state j).2 :=
        if_pos hj'
      rw [hscore,p.state_transition j hj']
      exact scalarSourceMoment_normalizedConditionalScore _ _ _ (p.state_pos j).2
        (p.next_signal_pos j hj') f

theorem ScalarChannelPath.nominal_terminal {v r : ℝ} (p : ScalarChannelPath v r) (f : Bool) :
    p.nominal f p.length=canonicalCompletion (labelReal f*Real.sqrt p.terminal.1)
      (p.terminal.1+p.terminal.2) := by
  rw [p.nominal_eq_state f p.length le_rfl,p.state_terminal]
  have h := p.state_pos p.length
  rw [p.state_terminal] at h
  exact scalarBooleanState_canonical f h.1.le h.2

#print axioms ScalarChannelPath.nominal_terminal
#print axioms ScalarChannelPath.score_bound
end ConditionalNonpolynomial.Analytic
