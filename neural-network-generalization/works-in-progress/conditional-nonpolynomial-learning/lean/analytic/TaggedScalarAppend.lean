import TaggedScalarPath

noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

def TaggedScalarPath.append {t v r : ℝ} (p : TaggedScalarPath t v r)
    (q : TaggedScalarPath t p.terminal.1 p.terminal.2) : TaggedScalarPath t v r :=
  match p with
  | .stop _ _=>q
  | .step hv hr Q hp hK hP b hb hL hU B hB hbound hmoment tail=>
      .step hv hr Q hp hK hP b hb hL hU B hB hbound hmoment (tail.append q)

lemma TaggedScalarPath.append_length {t v r : ℝ} (p : TaggedScalarPath t v r)
    (q : TaggedScalarPath t p.terminal.1 p.terminal.2) :
    (p.append q).length=p.length+q.length := by
  induction p with
  | stop _ _ => simp [append,length]
  | step _ _ _ _ _ _ _ _ _ _ _ _ _ _ tail ih =>
      simp only [append,length,ih]
      omega

lemma TaggedScalarPath.append_terminal {t v r : ℝ} (p : TaggedScalarPath t v r)
    (q : TaggedScalarPath t p.terminal.1 p.terminal.2) :
    (p.append q).terminal=q.terminal := by
  induction p with
  | stop _ _ => rfl
  | step _ _ _ _ _ _ _ _ _ _ _ _ _ _ tail ih => exact ih q

lemma TaggedScalarPath.append_priorHiddenCost {t v r : ℝ} (p : TaggedScalarPath t v r)
    (q : TaggedScalarPath t p.terminal.1 p.terminal.2) :
    (p.append q).priorHiddenCost=p.priorHiddenCost+q.priorHiddenCost := by
  induction p with
  | stop _ _ => simp [append,priorHiddenCost]
  | step _ _ _ _ _ _ _ _ _ _ _ _ _ _ tail ih =>
      simp only [append,priorHiddenCost,ih]
      ring

lemma TaggedScalarPath.append_cost {t v r : ℝ} (p : TaggedScalarPath t v r)
    (q : TaggedScalarPath t p.terminal.1 p.terminal.2) :
    (p.append q).cost=t^2*p.priorHiddenCost+q.cost := by
  rw [cost,p.append_priorHiddenCost,p.append_terminal,cost]
  ring

lemma TaggedScalarPath.append_bound {t v r : ℝ} (p : TaggedScalarPath t v r)
    (q : TaggedScalarPath t p.terminal.1 p.terminal.2) :
    (p.append q).bound=max p.bound q.bound := by
  induction p with
  | stop _ _ => simp only [append,bound,max_eq_right q.bound_ge_one]
  | step _ _ _ _ _ _ _ _ _ _ _ _ _ _ tail ih =>
      simp only [append,bound,ih,max_assoc]

lemma TaggedScalarPath.priorHiddenCost_eq_sum {t v r : ℝ} (p : TaggedScalarPath t v r) :
    p.priorHiddenCost=∑j : Fin p.length,(klDiv (p.control j) (taggedGaussianReference t)).toReal := by
  induction p with
  | stop _ _ => simp [priorHiddenCost,length]
  | step _ _ _ _ _ _ _ _ _ _ _ _ _ _ tail ih =>
      simp only [priorHiddenCost,length,Fin.sum_univ_succ,control,ih,Fin.val_zero,Fin.val_succ]


lemma TaggedScalarPath.append_control_prefix {t v r : ℝ} (p : TaggedScalarPath t v r)
    (q : TaggedScalarPath t p.terminal.1 p.terminal.2) (j : ℕ) (hj : j<p.length) :
    (p.append q).control j=p.control j := by
  induction p generalizing j with
  | stop _ _ => simp [length] at hj
  | step _ _ _ _ _ _ _ _ _ _ _ _ _ _ tail ih =>
      cases j with
      | zero => rfl
      | succ j => exact ih q j (by simpa [length] using hj)

lemma TaggedScalarPath.append_control_suffix {t v r : ℝ} (p : TaggedScalarPath t v r)
    (q : TaggedScalarPath t p.terminal.1 p.terminal.2) (j : ℕ) :
    (p.append q).control (p.length+j)=q.control j := by
  induction p with
  | stop _ _ => simp [append,length]
  | step _ _ _ _ _ _ _ _ _ _ _ _ _ _ tail ih =>
      simp only [append,length,show tail.length+1+j=tail.length+j+1 by omega,control]
      exact ih q

lemma TaggedScalarPath.append_state_prefix {t v r : ℝ} (p : TaggedScalarPath t v r)
    (q : TaggedScalarPath t p.terminal.1 p.terminal.2) (j : ℕ) (hj : j≤p.length) :
    (p.append q).state j=p.state j := by
  induction p generalizing j with
  | stop _ _ =>
      have hj0 : j=0 := by simpa [length] using hj
      subst j
      exact q.state_zero
  | step _ _ _ _ _ _ _ _ _ _ _ _ _ _ tail ih =>
      cases j with
      | zero => rfl
      | succ j => exact ih q j (by simpa [length] using hj)

lemma TaggedScalarPath.append_state_suffix {t v r : ℝ} (p : TaggedScalarPath t v r)
    (q : TaggedScalarPath t p.terminal.1 p.terminal.2) (j : ℕ) :
    (p.append q).state (p.length+j)=q.state j := by
  induction p with
  | stop _ _ => simp [append,length]
  | step _ _ _ _ _ _ _ _ _ _ _ _ _ _ tail ih =>
      simp only [append,length,show tail.length+1+j=tail.length+j+1 by omega,state]
      exact ih q

lemma TaggedScalarPath.exists_append {t v r a b : ℝ} (p : TaggedScalarPath t v r)
    (q : TaggedScalarPath t a b) (ht : p.terminal=(a,b)) :
    ∃s : TaggedScalarPath t v r,
      s.length=p.length+q.length ∧ s.terminal=q.terminal ∧
      s.bound=max p.bound q.bound ∧ s.priorHiddenCost=p.priorHiddenCost+q.priorHiddenCost ∧
      s.cost=t^2*p.priorHiddenCost+q.cost ∧
      (∀j<p.length,s.control j=p.control j) ∧
      (∀j,s.control (p.length+j)=q.control j) ∧
      (∀j≤p.length,s.state j=p.state j) ∧
      (∀j,s.state (p.length+j)=q.state j) := by
  have ha : p.terminal.1=a := congrArg Prod.fst ht
  have hb : p.terminal.2=b := congrArg Prod.snd ht
  subst a
  subst b
  exact ⟨p.append q,p.append_length q,p.append_terminal q,p.append_bound q,
    p.append_priorHiddenCost q,p.append_cost q,p.append_control_prefix q,p.append_control_suffix q,
    p.append_state_prefix q,p.append_state_suffix q⟩

#print axioms TaggedScalarPath.append_cost
#print axioms TaggedScalarPath.priorHiddenCost_eq_sum
#print axioms TaggedScalarPath.exists_append
end ConditionalNonpolynomial.Analytic
