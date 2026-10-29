import ScalarPathScoreProgram
import PrescribedConditionalScore
import ScaledSplitRowChannel
import GaussianVarianceKL

/-! Finite programs with actual auxiliary-tagged scalar controls. Both the
critical reference entropy and the physical prior entropy are recorded. -/
noncomputable section
set_option maxHeartbeats 1600000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal BigOperators
namespace ConditionalNonpolynomial.Analytic

def taggedGaussianReference (t : ℝ) : Measure (ℝ×Bool) :=
  (gaussianReal 0 (t^2).toNNReal).prod scoreSignLaw

instance taggedGaussianReference_probability (t : ℝ) :
    IsProbabilityMeasure (taggedGaussianReference t) := by unfold taggedGaussianReference; infer_instance

lemma taggedGaussianReference_fst (t : ℝ) :
    (taggedGaussianReference t).map Prod.fst=gaussianReal 0 (t^2).toNNReal :=
  measurePreserving_fst.map_eq

lemma taggedGaussianReference_critical {t : ℝ} (ht : 0<t) :
    klDiv (taggedGaussianReference t) (taggedGaussianReference 1)≠∞ := by
  simp only [taggedGaussianReference,one_pow,Real.toNNReal_one,score_downgrade_kl]
  apply gaussian_variance_kl_ne_top
  exact ne_of_gt (Real.toNNReal_pos.mpr (sq_pos_of_pos ht))

inductive TaggedScalarPath (t : ℝ) : ℝ→ℝ→Type
  | stop {v r : ℝ} (hv : 0<v) (hr : 0≤r) : TaggedScalarPath t v r
  | step {v r v' r' : ℝ} (hv : 0<v) (hr : 0≤r)
      (Q : Measure (ℝ×Bool)) (hprob : IsProbabilityMeasure Q)
      (hKL : klDiv Q (taggedGaussianReference 1)≠∞)
      (hKLprior : klDiv Q (taggedGaussianReference t)≠∞)
      (b : (ℝ×Bool)→ℝ) (hb : Measurable b) (hbLp : MemLp b 2 Q)
      (hunit : (∫z,(b z)^2 ∂Q)=1) (B : ℝ) (hB : 1≤B) (hbound : ∀z,|b z|≤B)
      (hmoment : ∀f : Bool,scalarSourceMoment Q Prod.fst b
        (residualScale t (scalarBooleanState f v r))=scalarBooleanState f v' r')
      (tail : TaggedScalarPath t v' r') : TaggedScalarPath t v r

def TaggedScalarPath.length {t : ℝ} : {v r : ℝ}→TaggedScalarPath t v r→ℕ
  | _,_,.stop _ _=>0
  | _,_,.step _ _ _ _ _ _ _ _ _ _ _ _ _ _ tail=>tail.length+1

def TaggedScalarPath.terminal {t : ℝ} : {v r : ℝ}→TaggedScalarPath t v r→ℝ×ℝ
  | v,r,.stop _ _=>(v,r)
  | _,_,.step _ _ _ _ _ _ _ _ _ _ _ _ _ _ tail=>tail.terminal

def TaggedScalarPath.state {t : ℝ} : {v r : ℝ}→TaggedScalarPath t v r→ℕ→ℝ×ℝ
  | v,r,.stop _ _,_=>(v,r)
  | v,r,.step _ _ _ _ _ _ _ _ _ _ _ _ _ _ _,0=>(v,r)
  | _,_,.step _ _ _ _ _ _ _ _ _ _ _ _ _ _ tail,j+1=>tail.state j

def TaggedScalarPath.control {t : ℝ} : {v r : ℝ}→TaggedScalarPath t v r→ℕ→Measure (ℝ×Bool)
  | _,_,.stop _ _,_=>taggedGaussianReference t
  | _,_,.step _ _ Q _ _ _ _ _ _ _ _ _ _ _ _,0=>Q
  | _,_,.step _ _ _ _ _ _ _ _ _ _ _ _ _ _ tail,j+1=>tail.control j

def TaggedScalarPath.score {t : ℝ} : {v r : ℝ}→TaggedScalarPath t v r→ℕ→(ℝ×Bool)→ℝ
  | _,_,.stop _ _,_=>fun _=>1
  | _,_,.step _ _ _ _ _ _ b _ _ _ _ _ _ _ _,0=>b
  | _,_,.step _ _ _ _ _ _ _ _ _ _ _ _ _ _ tail,j+1=>tail.score j

def TaggedScalarPath.bound {t : ℝ} : {v r : ℝ}→TaggedScalarPath t v r→ℝ
  | _,_,.stop _ _=>1
  | _,_,.step _ _ _ _ _ _ _ _ _ _ B _ _ _ tail=>max B tail.bound

def TaggedScalarPath.priorHiddenCost {t : ℝ} : {v r : ℝ}→TaggedScalarPath t v r→ℝ
  | _,_,.stop _ _=>0
  | _,_,.step _ _ Q _ _ _ _ _ _ _ _ _ _ _ tail=>
      (klDiv Q (taggedGaussianReference t)).toReal+tail.priorHiddenCost

def TaggedScalarPath.cost {t v r : ℝ} (p : TaggedScalarPath t v r) : ℝ :=
  t^2*p.priorHiddenCost+1/(8*p.terminal.1)

lemma TaggedScalarPath.control_probability {t v r : ℝ} (p : TaggedScalarPath t v r) (j : ℕ) :
    IsProbabilityMeasure (p.control j) := by
  induction p generalizing j with
  | stop _ _ => exact inferInstanceAs (IsProbabilityMeasure (taggedGaussianReference t))
  | step _ _ Q hprob _ _ _ _ _ _ _ _ _ _ tail ih =>
      cases j with
      | zero => exact hprob
      | succ j => exact ih j

lemma TaggedScalarPath.control_criticalKL {t v r : ℝ} (ht : 0<t)
    (p : TaggedScalarPath t v r) (j : ℕ) :
    klDiv (p.control j) (taggedGaussianReference 1)≠∞ := by
  induction p generalizing j with
  | stop _ _ => exact taggedGaussianReference_critical ht
  | step _ _ _ _ hKL _ _ _ _ _ _ _ _ _ tail ih =>
      cases j with
      | zero => exact hKL
      | succ j => exact ih j

lemma TaggedScalarPath.control_priorKL {t v r : ℝ} (p : TaggedScalarPath t v r) (j : ℕ) :
    klDiv (p.control j) (taggedGaussianReference t)≠∞ := by
  induction p generalizing j with
  | stop _ _ => simp [control]
  | step _ _ _ _ _ hKL _ _ _ _ _ _ _ _ tail ih =>
      cases j with
      | zero => exact hKL
      | succ j => exact ih j

lemma TaggedScalarPath.score_measurable {t v r : ℝ} (p : TaggedScalarPath t v r) (j : ℕ) :
    Measurable (p.score j) := by
  induction p generalizing j with
  | stop _ _ => exact measurable_const
  | step _ _ _ _ _ _ _ hb _ _ _ _ _ _ tail ih =>
      cases j with
      | zero => exact hb
      | succ j => exact ih j

lemma TaggedScalarPath.score_memLp {t v r : ℝ} (p : TaggedScalarPath t v r) (j : ℕ) :
    MemLp (p.score j) 2 (p.control j) := by
  induction p generalizing j with
  | stop _ _ =>
      change MemLp (fun _ : ℝ×Bool=>(1:ℝ)) 2 (taggedGaussianReference t)
      exact memLp_const 1
  | step _ _ _ _ _ _ _ _ hb _ _ _ _ _ tail ih =>
      cases j with
      | zero => exact hb
      | succ j => exact ih j

lemma TaggedScalarPath.score_unit {t v r : ℝ} (p : TaggedScalarPath t v r) (j : ℕ) :
    (∫z,(p.score j z)^2 ∂p.control j)=1 := by
  induction p generalizing j with
  | stop _ _ => simp [score,control]
  | step _ _ _ _ _ _ _ _ _ hu _ _ _ _ tail ih =>
      cases j with
      | zero => exact hu
      | succ j => exact ih j

lemma TaggedScalarPath.bound_ge_one {t v r : ℝ} (p : TaggedScalarPath t v r) : 1≤p.bound := by
  cases p with
  | stop _ _ => exact le_rfl
  | step _ _ _ _ _ _ _ _ _ _ _ hB _ _ tail => exact hB.trans (le_max_left _ _)

lemma TaggedScalarPath.score_bound {t v r : ℝ} (p : TaggedScalarPath t v r) (j : ℕ) (z : ℝ×Bool) :
    |p.score j z|≤p.bound := by
  induction p generalizing j with
  | stop _ _ => simp [score,bound]
  | step _ _ _ _ _ _ _ _ _ _ _ _ hb _ tail ih =>
      cases j with
      | zero => exact (hb z).trans (le_max_left _ _)
      | succ j => exact (ih j).trans (le_max_right _ _)

lemma TaggedScalarPath.state_zero {t v r : ℝ} (p : TaggedScalarPath t v r) : p.state 0=(v,r) := by
  cases p <;> rfl

lemma TaggedScalarPath.state_terminal {t v r : ℝ} (p : TaggedScalarPath t v r) :
    p.state p.length=p.terminal := by
  induction p with
  | stop _ _ => rfl
  | step _ _ _ _ _ _ _ _ _ _ _ _ _ _ tail ih => exact ih

lemma TaggedScalarPath.state_pos {t v r : ℝ} (p : TaggedScalarPath t v r) (j : ℕ) :
    0<(p.state j).1 ∧ 0≤(p.state j).2 := by
  induction p generalizing j with
  | stop hv hr => exact ⟨hv,hr⟩
  | step hv hr _ _ _ _ _ _ _ _ _ _ _ _ tail ih =>
      cases j with
      | zero => exact ⟨hv,hr⟩
      | succ j => exact ih j

lemma TaggedScalarPath.state_transition {t v r : ℝ} (p : TaggedScalarPath t v r)
    (j : ℕ) (hj : j<p.length) (f : Bool) :
    scalarSourceMoment (p.control j) Prod.fst (p.score j)
      (residualScale t (scalarBooleanState f (p.state j).1 (p.state j).2))=
      scalarBooleanState f (p.state (j+1)).1 (p.state (j+1)).2 := by
  induction p generalizing j with
  | stop _ _ => simp [length] at hj
  | step _ _ _ _ _ _ _ _ _ _ _ _ _ hm tail ih =>
      cases j with
      | zero => simpa only [state,control,score,tail.state_zero] using hm f
      | succ j => exact ih j (by simpa [length] using hj)

def TaggedScalarPath.nominal {t v r : ℝ} (p : TaggedScalarPath t v r) (f : Bool) :
    ℕ→WithLp 2 (ℝ×ℝ)
  | 0=>scalarBooleanState f v r
  | j+1=>scalarSourceMoment (p.control j) Prod.fst (p.score j) (residualScale t (p.nominal f j))

lemma TaggedScalarPath.nominal_eq_state {t v r : ℝ} (p : TaggedScalarPath t v r)
    (f : Bool) (j : ℕ) (hj : j≤p.length) :
    p.nominal f j=scalarBooleanState f (p.state j).1 (p.state j).2 := by
  induction j with
  | zero => rw [p.state_zero]; rfl
  | succ j ih =>
      rw [nominal,ih (by omega)]
      exact p.state_transition j (by omega) f

lemma TaggedScalarPath.nominal_terminal {t v r : ℝ} (p : TaggedScalarPath t v r) (f : Bool) :
    p.nominal f p.length=canonicalCompletion (NeuralGeneralization.ConcreteModel.labelReal f*
      Real.sqrt p.terminal.1) (p.terminal.1+p.terminal.2) := by
  rw [p.nominal_eq_state f p.length le_rfl,p.state_terminal]
  have hp := p.state_pos p.length
  rw [p.state_terminal] at hp
  exact scalarBooleanState_canonical f hp.1.le hp.2

#print axioms TaggedScalarPath.nominal_terminal
#print axioms TaggedScalarPath.score_bound
end ConditionalNonpolynomial.Analytic
