import SteeringScalarLift

/-! Finite paths of actual scalar control laws with the Gaussian conditional
mean and residual recursions built into the type. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped NNReal ENNReal BigOperators
namespace ConditionalNonpolynomial.Analytic

inductive ScalarChannelPath : ℝ → ℝ → Type
  | stop {v r : ℝ} (hv : 0 < v) (hr : 0 ≤ r) : ScalarChannelPath v r
  | step {v r : ℝ} (hv : 0 < v) (hr : 0 ≤ r) (Q : Measure ℝ)
      (hprob : IsProbabilityMeasure Q) (hfinite : klDiv Q (gaussianReal 0 1) ≠ ∞)
      (tail : ScalarChannelPath (controlledSignal Q v r) (controlledResidual Q v r)) :
      ScalarChannelPath v r

def ScalarChannelPath.length : {v r : ℝ} → ScalarChannelPath v r → ℕ
  | _,_, .stop _ _ => 0
  | _,_, .step _ _ _ _ _ tail => tail.length+1

def ScalarChannelPath.terminal : {v r : ℝ} → ScalarChannelPath v r → ℝ×ℝ
  | v,r, .stop _ _ => (v,r)
  | _,_, .step _ _ _ _ _ tail => tail.terminal

def ScalarChannelPath.state : {v r : ℝ} → ScalarChannelPath v r → ℕ → ℝ×ℝ
  | v,r, .stop _ _, _ => (v,r)
  | v,r, .step _ _ _ _ _ _, 0 => (v,r)
  | _,_, .step _ _ _ _ _ tail, n+1 => tail.state n

def ScalarChannelPath.control : {v r : ℝ} → ScalarChannelPath v r → ℕ → Measure ℝ
  | _,_, .stop _ _, _ => gaussianReal 0 1
  | _,_, .step _ _ Q _ _ _, 0 => Q
  | _,_, .step _ _ _ _ _ tail, n+1 => tail.control n

def ScalarChannelPath.hiddenCost : {v r : ℝ} → ScalarChannelPath v r → ℝ
  | _,_, .stop _ _ => 0
  | _,_, .step _ _ Q _ _ tail => (klDiv Q (gaussianReal 0 1)).toReal+tail.hiddenCost

def ScalarChannelPath.cost {v r : ℝ} (p : ScalarChannelPath v r) : ℝ :=
  p.hiddenCost+1/(8*p.terminal.1)

theorem ScalarChannelPath.state_zero {v r : ℝ} (p : ScalarChannelPath v r) : p.state 0=(v,r) := by
  cases p <;> rfl

theorem ScalarChannelPath.state_terminal {v r : ℝ} (p : ScalarChannelPath v r) :
    p.state p.length=p.terminal := by
  induction p with
  | stop _ _ => rfl
  | step _ _ _ _ _ tail ih => exact ih

theorem ScalarChannelPath.state_pos {v r : ℝ} (p : ScalarChannelPath v r) (n : ℕ) :
    0 < (p.state n).1 ∧ 0 ≤ (p.state n).2 := by
  induction p generalizing n with
  | stop hv hr => exact ⟨hv,hr⟩
  | step hv hr _ _ _ tail ih =>
    cases n with
    | zero => exact ⟨hv,hr⟩
    | succ n => exact ih n

theorem ScalarChannelPath.control_probability {v r : ℝ} (p : ScalarChannelPath v r) (n : ℕ) :
    IsProbabilityMeasure (p.control n) := by
  induction p generalizing n with
  | stop _ _ => exact inferInstanceAs (IsProbabilityMeasure (gaussianReal 0 1))
  | step _ _ _ hprob _ tail ih =>
    cases n with
    | zero => exact hprob
    | succ n => exact ih n

theorem ScalarChannelPath.control_finiteKL {v r : ℝ} (p : ScalarChannelPath v r) (n : ℕ) :
    klDiv (p.control n) (gaussianReal 0 1) ≠ ∞ := by
  induction p generalizing n with
  | stop _ _ => simp [ScalarChannelPath.control]
  | step _ _ _ _ hfinite tail ih =>
    cases n with
    | zero => exact hfinite
    | succ n => exact ih n

theorem ScalarChannelPath.state_transition {v r : ℝ} (p : ScalarChannelPath v r)
    (n : ℕ) (hn : n < p.length) :
    p.state (n+1) =
      (controlledSignal (p.control n) (p.state n).1 (p.state n).2,
       controlledResidual (p.control n) (p.state n).1 (p.state n).2) := by
  induction p generalizing n with
  | stop _ _ => simp [ScalarChannelPath.length] at hn
  | step _ _ Q _ _ tail ih =>
    cases n with
    | zero => exact tail.state_zero
    | succ n => exact ih n (by simpa [ScalarChannelPath.length] using hn)

def ScalarChannelPath.append {v r : ℝ} (p : ScalarChannelPath v r)
    (q : ScalarChannelPath p.terminal.1 p.terminal.2) : ScalarChannelPath v r :=
  match p with
  | .stop _ _ => q
  | .step hv hr Q hprob hfinite tail => .step hv hr Q hprob hfinite (tail.append q)

theorem ScalarChannelPath.append_length {v r : ℝ} (p : ScalarChannelPath v r)
    (q : ScalarChannelPath p.terminal.1 p.terminal.2) :
    (p.append q).length=p.length+q.length := by
  induction p with
  | stop _ _ => simp [append,length]
  | step _ _ _ _ _ tail ih =>
    simp only [append,length,ih]
    omega

theorem ScalarChannelPath.append_terminal {v r : ℝ} (p : ScalarChannelPath v r)
    (q : ScalarChannelPath p.terminal.1 p.terminal.2) : (p.append q).terminal=q.terminal := by
  induction p with
  | stop _ _ => rfl
  | step _ _ _ _ _ tail ih => exact ih q

theorem ScalarChannelPath.append_hiddenCost {v r : ℝ} (p : ScalarChannelPath v r)
    (q : ScalarChannelPath p.terminal.1 p.terminal.2) :
    (p.append q).hiddenCost=p.hiddenCost+q.hiddenCost := by
  induction p with
  | stop _ _ => simp [append,hiddenCost]
  | step _ _ _ _ _ tail ih =>
    simp only [append,hiddenCost,ih]
    ring

theorem ScalarChannelPath.hiddenCost_eq_sum {v r : ℝ} (p : ScalarChannelPath v r) :
    p.hiddenCost=∑ j ∈ Finset.range p.length,(klDiv (p.control j) (gaussianReal 0 1)).toReal := by
  induction p with
  | stop _ _ => simp [hiddenCost,length]
  | step _ _ _ _ _ tail ih =>
    simp only [hiddenCost,length,Finset.sum_range_succ',control,ih]
    ring

#print axioms ScalarChannelPath.append_hiddenCost
#print axioms ScalarChannelPath.state_transition
end ConditionalNonpolynomial.Analytic
