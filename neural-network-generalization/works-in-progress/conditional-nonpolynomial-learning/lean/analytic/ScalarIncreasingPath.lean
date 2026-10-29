import ScalarBaselineBridge
import ScalarPathEntropy

/-! Actual finite scalar paths can be made strictly increasing without raising
their entropy-plus-readout cost. Concrete indexed states and controls expose the
path for the quantitative shortness argument and later stable channel lift. -/

noncomputable section
set_option maxHeartbeats 2000000
open scoped BigOperators ENNReal NNReal
open MeasureTheory ProbabilityTheory InformationTheory

namespace ConditionalNonpolynomial.Analytic

def ScalarPath.length : {q : ℝ} → ScalarPath q → ℕ
  | _, .stop _ => 0
  | _, .step _ _ _ _ tail => tail.length+1

def ScalarPath.Increasing : {q : ℝ} → ScalarPath q → Prop
  | _, .stop _ => True
  | q, .step _ Q _ _ tail => q < scalarTransition q Q ∧ tail.Increasing

def ScalarPath.state : {q : ℝ} → ScalarPath q → ℕ → ℝ
  | q, .stop _, _ => q
  | q, .step _ _ _ _ _, 0 => q
  | _, .step _ _ _ _ tail, n+1 => tail.state n

def ScalarPath.control : {q : ℝ} → ScalarPath q → ℕ → Measure ℝ
  | _, .stop _, _ => gaussianReal 0 1
  | _, .step _ Q _ _ _, 0 => Q
  | _, .step _ _ _ _ tail, n+1 => tail.control n

def ScalarPath.charge {q : ℝ} (p : ScalarPath q) (n : ℕ) : ℝ :=
  (klDiv (p.control n) (gaussianReal 0 1)).toReal

theorem ScalarPath.state_zero {q : ℝ} (p : ScalarPath q) : p.state 0 = q := by
  cases p <;> rfl

theorem ScalarPath.state_pos {q : ℝ} (p : ScalarPath q) (n : ℕ) : 0 < p.state n := by
  induction p generalizing n with
  | stop hq => exact hq
  | step hq Q hprob hfinite tail ih =>
    cases n with
    | zero => exact hq
    | succ n => exact ih n

theorem ScalarPath.state_le_one {q : ℝ} (p : ScalarPath q) (hq : q ≤ 1) (n : ℕ) :
    p.state n ≤ 1 := by
  induction p generalizing n with
  | stop _ => exact hq
  | step hpos Q hprob hfinite tail ih =>
    cases n with
    | zero => exact hq
    | succ n =>
      letI := hprob
      exact ih (scalarTransition_le_one _ Q) n

theorem ScalarPath.state_floor {q : ℝ} (p : ScalarPath q) (hinc : p.Increasing) (n : ℕ) :
    q ≤ p.state n := by
  induction p generalizing n with
  | stop _ => exact le_rfl
  | step hpos Q hprob hfinite tail ih =>
    cases n with
    | zero => exact le_rfl
    | succ n => exact hinc.1.le.trans (ih hinc.2 n)

theorem ScalarPath.control_probability {q : ℝ} (p : ScalarPath q) (n : ℕ) :
    IsProbabilityMeasure (p.control n) := by
  induction p generalizing n with
  | stop _ => change IsProbabilityMeasure (gaussianReal 0 1); infer_instance
  | step _ Q hprob _ tail ih =>
    cases n with
    | zero => exact hprob
    | succ n => exact ih n

theorem ScalarPath.control_finiteKL {q : ℝ} (p : ScalarPath q) (n : ℕ) :
    klDiv (p.control n) (gaussianReal 0 1) ≠ ∞ := by
  induction p generalizing n with
  | stop _ => simp [ScalarPath.control, klDiv_self]
  | step _ Q _ hfinite tail ih =>
    cases n with
    | zero => exact hfinite
    | succ n => exact ih n

theorem ScalarPath.state_transition {q : ℝ} (p : ScalarPath q) (n : ℕ)
    (hn : n < p.length) : scalarTransition (p.state n) (p.control n) = p.state (n+1) := by
  induction p generalizing n with
  | stop _ => simp [ScalarPath.length] at hn
  | step _ Q _ _ tail ih =>
    cases n with
    | zero => exact (tail.state_zero).symm
    | succ n =>
      exact ih n (by simpa [ScalarPath.length] using hn)

theorem ScalarPath.cost_eq_sum {q : ℝ} (p : ScalarPath q) :
    p.cost = (∑ j ∈ Finset.range p.length, p.charge j) + 1/(8*p.state p.length) := by
  induction p with
  | stop _ => simp [ScalarPath.cost, ScalarPath.length, ScalarPath.state]
  | step _ Q _ _ tail ih =>
    simp only [ScalarPath.cost, ScalarPath.length, Finset.sum_range_succ',
      ScalarPath.charge, ScalarPath.control, ScalarPath.state]
    change (klDiv Q (gaussianReal 0 1)).toReal + tail.cost = _
    rw [ih]
    simp only [ScalarPath.charge]
    ring

/-- Replay controls at a larger initial state, dropping any nonincreasing step.
All retained measures and their actual KL charges are unchanged. -/
theorem ScalarPath.increasing_lift {a : ℝ} (p : ScalarPath a) {b : ℝ} (hab : a ≤ b) :
    ∃ p' : ScalarPath b, p'.Increasing ∧ p'.cost ≤ p.cost := by
  induction p generalizing b with
  | stop ha =>
    refine ⟨.stop (ha.trans_le hab), trivial, ?_⟩
    exact one_div_le_one_div_of_le (by positivity) (by linarith)
  | @step a ha Q hprob hfinite tail ih =>
    letI := hprob
    have htrans := scalarTransition_mono Q ha.le hab
    by_cases hgrow : b < scalarTransition b Q
    · obtain ⟨tail', hinc, hcost⟩ := ih htrans
      refine ⟨.step (ha.trans_le hab) Q hprob hfinite tail', ⟨hgrow,hinc⟩, ?_⟩
      change (klDiv Q (gaussianReal 0 1)).toReal + tail'.cost ≤
        (klDiv Q (gaussianReal 0 1)).toReal + tail.cost
      linarith
    · have hnext : scalarTransition a Q ≤ b := htrans.trans (le_of_not_gt hgrow)
      obtain ⟨p', hinc, hcost⟩ := ih hnext
      refine ⟨p', hinc, ?_⟩
      change p'.cost ≤ (klDiv Q (gaussianReal 0 1)).toReal + tail.cost
      linarith [ENNReal.toReal_nonneg (a := klDiv Q (gaussianReal 0 1))]

theorem exists_increasing_nearOptimal_scalarPath {q ε : ℝ} (hq : 0 < q) (hε : 0 < ε) :
    ∃ p : ScalarPath q, p.Increasing ∧ p.cost < scalarValue q + ε := by
  obtain ⟨a, ⟨p, rfl⟩, hcost⟩ := exists_lt_of_csInf_lt (scalarCosts_nonempty hq)
    (show sInf (scalarCosts q) < scalarValue q + ε by change scalarValue q < _; linarith)
  obtain ⟨p', hinc, hcost'⟩ := p.increasing_lift le_rfl
  exact ⟨p', hinc, hcost'.trans_lt hcost⟩

/-- The actual prefix estimate for a near-optimal increasing path. -/
theorem ScalarPath.nearOptimal_prefix {q ε : ℝ} (p : ScalarPath q)
    (hnear : p.cost ≤ scalarBaseline.toReal + ε) :
    ∀ i ≤ p.length, (∑ j ∈ Finset.range i, p.charge j) ≤ ε + 526336*p.state i := by
  apply controlled_path_prefix_bound p.length p.state p.state p.charge p.control
    (fun j _ => p.state_pos j) (fun j _ => (p.state_pos j).le) (fun _ _ => le_rfl)
    (fun j _ => p.control_probability j) (fun j _ => p.control_finiteKL j)
    (fun _ _ => le_rfl) (fun j hj => (p.state_transition j hj).symm.le) le_rfl
  rwa [← p.cost_eq_sum]

end ConditionalNonpolynomial.Analytic

#print axioms ConditionalNonpolynomial.Analytic.exists_increasing_nearOptimal_scalarPath
#print axioms ConditionalNonpolynomial.Analytic.ScalarPath.nearOptimal_prefix
