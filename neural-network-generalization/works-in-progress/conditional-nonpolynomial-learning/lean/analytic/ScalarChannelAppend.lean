import ScalarChannelPath

noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial.Analytic

theorem ScalarChannelPath.append_cost {v r : ℝ} (p : ScalarChannelPath v r)
    (q : ScalarChannelPath p.terminal.1 p.terminal.2) :
    (p.append q).cost=p.hiddenCost+q.cost := by
  rw [ScalarChannelPath.cost,p.append_hiddenCost,p.append_terminal,ScalarChannelPath.cost]
  ring

theorem ScalarChannelPath.exists_append {v r a b : ℝ} (p : ScalarChannelPath v r)
    (q : ScalarChannelPath a b) (ht : p.terminal=(a,b)) :
    ∃ s : ScalarChannelPath v r,
      s.length=p.length+q.length ∧ s.terminal=q.terminal ∧
      s.hiddenCost=p.hiddenCost+q.hiddenCost ∧ s.cost=p.hiddenCost+q.cost := by
  have ha : p.terminal.1=a := congrArg Prod.fst ht
  have hb : p.terminal.2=b := congrArg Prod.snd ht
  subst a
  subst b
  exact ⟨p.append q,p.append_length q,p.append_terminal q,p.append_hiddenCost q,p.append_cost q⟩

theorem ScalarChannelPath.terminal_of_state {v r : ℝ} (p : ScalarChannelPath v r)
    {H : ℕ} (hlen : p.length=H) {s : ℝ×ℝ} (hstate : p.state H=s) : p.terminal=s := by
  rw [← p.state_terminal,hlen,hstate]

end ConditionalNonpolynomial.Analytic
