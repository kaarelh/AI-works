import IndependentControlEntropy

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal
namespace ConditionalNonpolynomial.Analytic

theorem fin_coordinate_control_kl (N : ℕ) (Q P : Fin N→Measure ℝ)
    [∀i,IsProbabilityMeasure (Q i)] [∀i,IsProbabilityMeasure (P i)] :
    klDiv (Measure.pi Q) (Measure.pi P)=∑i,klDiv (Q i) (P i) := by
  induction N with
  | zero =>
      rw [Measure.pi_of_empty _ (Fin.elim0),Measure.pi_of_empty _ (Fin.elim0),klDiv_self]
      simp
  | succ N ih =>
      let e := MeasurableEquiv.piFinSuccAbove (fun _ : Fin (N+1)=>ℝ) 0
      have hQ := (measurePreserving_piFinSuccAbove Q 0).map_eq
      have hP := (measurePreserving_piFinSuccAbove P 0).map_eq
      have h := control_kl_measurableEquiv (Measure.pi Q) (Measure.pi P) e
      rw [hQ,hP,product_control_kl] at h
      have ht := ih (fun i=>Q i.succ) (fun i=>P i.succ)
      simpa only [Fin.succAbove_zero,Fin.sum_univ_succ,ht] using h.symm

theorem coordinate_control_kl {I : Type*} [Fintype I] (Q P : I→Measure ℝ)
    [∀i,IsProbabilityMeasure (Q i)] [∀i,IsProbabilityMeasure (P i)] :
    klDiv (Measure.pi Q) (Measure.pi P)=∑i,klDiv (Q i) (P i) := by
  classical
  let e : Fin (Fintype.card I)≃I := (Fintype.equivFin I).symm
  let E := MeasurableEquiv.piCongrLeft (fun _ : I=>ℝ) e
  have hQ := (measurePreserving_piCongrLeft Q e).map_eq
  have hP := (measurePreserving_piCongrLeft P e).map_eq
  have h := control_kl_measurableEquiv (Measure.pi (fun i=>Q (e i)))
    (Measure.pi (fun i=>P (e i))) E
  rw [hQ,hP,fin_coordinate_control_kl] at h
  exact h.trans (e.sum_comp (fun i=>klDiv (Q i) (P i)))

#print axioms coordinate_control_kl
end ConditionalNonpolynomial.Analytic
