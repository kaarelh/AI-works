import ScalarChannelAppend

noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial.Analytic

theorem ScalarChannelPath.append_state_prefix {v r : ℝ} (p : ScalarChannelPath v r)
    (q : ScalarChannelPath p.terminal.1 p.terminal.2) (j : ℕ) (hj : j ≤ p.length) :
    (p.append q).state j=p.state j := by
  induction p generalizing j with
  | stop hv hr =>
    have hj0 : j=0 := by simpa only [ScalarChannelPath.length,Nat.le_zero] using hj
    subst j
    exact q.state_zero
  | step hv hr Q hprob hfinite tail ih =>
    cases j with
    | zero => rfl
    | succ j => exact ih q j (by simpa only [ScalarChannelPath.length,Nat.succ_le_succ_iff] using hj)

theorem ScalarChannelPath.append_state_suffix {v r : ℝ} (p : ScalarChannelPath v r)
    (q : ScalarChannelPath p.terminal.1 p.terminal.2) (j : ℕ) :
    (p.append q).state (p.length+j)=q.state j := by
  induction p with
  | stop hv hr => simp only [ScalarChannelPath.append,ScalarChannelPath.length,Nat.zero_add]
  | step hv hr Q hprob hfinite tail ih =>
    simp only [ScalarChannelPath.append,ScalarChannelPath.length,
      show tail.length+1+j=tail.length+j+1 by omega,ScalarChannelPath.state]
    exact ih q

def ScalarChannelPath.SignalFloor {v r : ℝ} (p : ScalarChannelPath v r) (b : ℝ) : Prop :=
  ∀ j ≤ p.length,b ≤ (p.state j).1

theorem ScalarChannelPath.append_signalFloor {v r b : ℝ} (p : ScalarChannelPath v r)
    (q : ScalarChannelPath p.terminal.1 p.terminal.2)
    (hp : p.SignalFloor b) (hq : q.SignalFloor b) : (p.append q).SignalFloor b := by
  intro j hj
  rw [p.append_length] at hj
  by_cases hpre : j ≤ p.length
  · rw [p.append_state_prefix q j hpre]
    exact hp j hpre
  · have hlen : p.length ≤ j := by omega
    have he : j=p.length+(j-p.length) := by omega
    rw [he,p.append_state_suffix]
    exact hq (j-p.length) (by omega)

theorem ScalarChannelPath.exists_append_floor {v r a b c : ℝ} (p : ScalarChannelPath v r)
    (q : ScalarChannelPath a b) (ht : p.terminal=(a,b))
    (hp : p.SignalFloor c) (hq : q.SignalFloor c) :
    ∃ s : ScalarChannelPath v r,
      s.length=p.length+q.length ∧ s.terminal=q.terminal ∧
      s.hiddenCost=p.hiddenCost+q.hiddenCost ∧ s.cost=p.hiddenCost+q.cost ∧ s.SignalFloor c := by
  have ha : p.terminal.1=a := congrArg Prod.fst ht
  have hb : p.terminal.2=b := congrArg Prod.snd ht
  subst a
  subst b
  exact ⟨p.append q,p.append_length q,p.append_terminal q,p.append_hiddenCost q,p.append_cost q,
    p.append_signalFloor q hp hq⟩

#print axioms ScalarChannelPath.exists_append_floor
end ConditionalNonpolynomial.Analytic
