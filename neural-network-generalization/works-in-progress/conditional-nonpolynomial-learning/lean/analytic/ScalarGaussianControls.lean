import ScalarChannelFloor
import SteeringExactSteps

noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial.Analytic

/-- Every control in the finite path is an inflated centered Gaussian. -/
def ScalarChannelPath.GaussianControls {v r : ℝ} (p : ScalarChannelPath v r) : Prop :=
  ∀ j < p.length, ∃ ε : ℝ, 0 ≤ ε ∧ p.control j=steeringControl ε

theorem ScalarChannelPath.append_control_prefix {v r : ℝ} (p : ScalarChannelPath v r)
    (q : ScalarChannelPath p.terminal.1 p.terminal.2) (j : ℕ) (hj : j < p.length) :
    (p.append q).control j=p.control j := by
  induction p generalizing j with
  | stop hv hr => simp only [ScalarChannelPath.length,Nat.not_lt_zero] at hj
  | step hv hr Q hprob hfinite tail ih =>
    cases j with
    | zero => rfl
    | succ j => exact ih q j (by simpa only [ScalarChannelPath.length,Nat.succ_lt_succ_iff] using hj)

theorem ScalarChannelPath.append_control_suffix {v r : ℝ} (p : ScalarChannelPath v r)
    (q : ScalarChannelPath p.terminal.1 p.terminal.2) (j : ℕ) :
    (p.append q).control (p.length+j)=q.control j := by
  induction p with
  | stop hv hr => simp only [ScalarChannelPath.append,ScalarChannelPath.length,Nat.zero_add]
  | step hv hr Q hprob hfinite tail ih =>
    simp only [ScalarChannelPath.append,ScalarChannelPath.length,
      show tail.length+1+j=tail.length+j+1 by omega,ScalarChannelPath.control]
    exact ih q

theorem ScalarChannelPath.append_gaussianControls {v r : ℝ} (p : ScalarChannelPath v r)
    (q : ScalarChannelPath p.terminal.1 p.terminal.2)
    (hp : p.GaussianControls) (hq : q.GaussianControls) : (p.append q).GaussianControls := by
  intro j hj
  rw [p.append_length] at hj
  by_cases hpre : j < p.length
  · rw [p.append_control_prefix q j hpre]
    exact hp j hpre
  · have he : j=p.length+(j-p.length) := by omega
    rw [he,p.append_control_suffix]
    exact hq (j-p.length) (by omega)

theorem ScalarChannelPath.exists_append_gaussian {v r a b c : ℝ} (p : ScalarChannelPath v r)
    (q : ScalarChannelPath a b) (ht : p.terminal=(a,b))
    (hp : p.SignalFloor c) (hq : q.SignalFloor c)
    (hgp : p.GaussianControls) (hgq : q.GaussianControls) :
    ∃ s : ScalarChannelPath v r,
      s.length=p.length+q.length ∧ s.terminal=q.terminal ∧
      s.hiddenCost=p.hiddenCost+q.hiddenCost ∧ s.SignalFloor c ∧ s.GaussianControls := by
  have ha : p.terminal.1=a := congrArg Prod.fst ht
  have hb : p.terminal.2=b := congrArg Prod.snd ht
  subst a
  subst b
  exact ⟨p.append q,p.append_length q,p.append_terminal q,p.append_hiddenCost q,
    p.append_signalFloor q hp hq,p.append_gaussianControls q hgp hgq⟩

#print axioms ScalarChannelPath.exists_append_gaussian
end ConditionalNonpolynomial.Analytic
