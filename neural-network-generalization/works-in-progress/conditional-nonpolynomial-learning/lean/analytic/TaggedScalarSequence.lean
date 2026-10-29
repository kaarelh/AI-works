import TaggedScalarAppend

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace ConditionalNonpolynomial.Analytic

theorem TaggedScalarPath.exists_of_sequence (t : ℝ) (H : ℕ) (s : ℕ→ℝ×ℝ)
    (Q : ℕ→Measure (ℝ×Bool)) (b : ℕ→(ℝ×Bool)→ℝ) (B : ℝ) (hB : 1≤B)
    (hpos : ∀j≤H,0<(s j).1 ∧ 0≤(s j).2)
    (hprob : ∀j<H,IsProbabilityMeasure (Q j))
    (hfinite : ∀j<H,klDiv (Q j) (taggedGaussianReference 1)≠∞)
    (hprior : ∀j<H,klDiv (Q j) (taggedGaussianReference t)≠∞)
    (hb : ∀j<H,Measurable (b j)) (hbLp : ∀j<H,MemLp (b j) 2 (Q j))
    (hunit : ∀j<H,(∫z,(b j z)^2 ∂Q j)=1)
    (hbound : ∀j<H,∀z,|b j z|≤B)
    (hstep : ∀j<H,∀f : Bool,scalarSourceMoment (Q j) Prod.fst (b j)
      (residualScale t (scalarBooleanState f (s j).1 (s j).2))=
      scalarBooleanState f (s (j+1)).1 (s (j+1)).2) :
    ∃p : TaggedScalarPath t (s 0).1 (s 0).2,
      p.length=H ∧ (∀j≤H,p.state j=s j) ∧ (∀j<H,p.control j=Q j) ∧
      (∀j<H,p.score j=b j) ∧ p.bound≤B := by
  induction H generalizing s Q b with
  | zero =>
      refine ⟨.stop (hpos 0 le_rfl).1 (hpos 0 le_rfl).2,rfl,?_,?_,?_,hB⟩
      · intro j hj
        have : j=0 := by omega
        subst j
        exact Prod.eta (s 0)
      · intro j hj; omega
      · intro j hj; omega
  | succ H ih =>
      obtain ⟨tail,hlen,hstate,hcontrol,hscore,hBtail⟩ :=
        ih (fun j=>s (j+1)) (fun j=>Q (j+1)) (fun j=>b (j+1))
          (fun j hj=>hpos (j+1) (by omega)) (fun j hj=>hprob (j+1) (by omega))
          (fun j hj=>hfinite (j+1) (by omega)) (fun j hj=>hprior (j+1) (by omega))
          (fun j hj=>hb (j+1) (by omega)) (fun j hj=>hbLp (j+1) (by omega))
          (fun j hj=>hunit (j+1) (by omega)) (fun j hj=>hbound (j+1) (by omega))
          (fun j hj=>hstep (j+1) (by omega))
      refine ⟨.step (hpos 0 (by omega)).1 (hpos 0 (by omega)).2 (Q 0)
        (hprob 0 (by omega)) (hfinite 0 (by omega)) (hprior 0 (by omega)) (b 0)
        (hb 0 (by omega)) (hbLp 0 (by omega)) (hunit 0 (by omega)) B hB
        (hbound 0 (by omega)) (hstep 0 (by omega)) tail,?_,?_,?_,?_,?_⟩
      · change tail.length+1=H+1
        rw [hlen]
      · intro j hj
        cases j with
        | zero => exact Prod.eta (s 0)
        | succ j => exact hstate j (by omega)
      · intro j hj
        cases j with
        | zero => rfl
        | succ j => exact hcontrol j (by omega)
      · intro j hj
        cases j with
        | zero => rfl
        | succ j => exact hscore j (by omega)
      · exact max_le le_rfl hBtail

#print axioms TaggedScalarPath.exists_of_sequence
end ConditionalNonpolynomial.Analytic
