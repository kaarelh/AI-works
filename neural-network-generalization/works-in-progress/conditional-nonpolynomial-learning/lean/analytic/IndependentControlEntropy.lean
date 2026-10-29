import ProductControlEntropy
import Mathlib.MeasureTheory.Constructions.Pi

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace ConditionalNonpolynomial.Analytic

/-- A bijective measurable reparameterization preserves the actual relative entropy. -/
theorem control_kl_measurableEquiv {Ω Ξ : Type*}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] [StandardBorelSpace Ω] [StandardBorelSpace Ξ]
    [Nonempty Ω] (Q P : Measure Ω) [IsProbabilityMeasure Q] [IsProbabilityMeasure P]
    (e : Ω≃ᵐΞ) : klDiv (Q.map e) (P.map e)=klDiv Q P := by
  haveI : Nonempty Ξ := ⟨e (Classical.choice (inferInstance : Nonempty Ω))⟩
  haveI : IsProbabilityMeasure (Q.map e) := Measure.isProbabilityMeasure_map e.measurable.aemeasurable
  haveI : IsProbabilityMeasure (P.map e) := Measure.isProbabilityMeasure_map e.measurable.aemeasurable
  apply le_antisymm
  · exact NeuralGeneralization.RobustEntropy.klDiv_map_le Q P e.measurable
  · have h := NeuralGeneralization.RobustEntropy.klDiv_map_le (Q.map e) (P.map e) e.symm.measurable
    simpa only [Measure.map_map e.symm.measurable e.measurable,
      MeasurableEquiv.symm_comp_self,Measure.map_id] using h

/-- The entropy of N independent control variables is exactly N times the
single-control entropy, including before finiteness has been established. -/
theorem iid_control_kl {Ω : Type*} [MeasurableSpace Ω] [StandardBorelSpace Ω] [Nonempty Ω]
    (Q P : Measure Ω) [IsProbabilityMeasure Q] [IsProbabilityMeasure P] (N : ℕ) :
    klDiv (Measure.pi (fun _ : Fin N=>Q)) (Measure.pi (fun _ : Fin N=>P))=
      N*klDiv Q P := by
  induction N with
  | zero =>
      rw [Measure.pi_of_empty _ (Fin.elim0),Measure.pi_of_empty _ (Fin.elim0),klDiv_self]
      simp
  | succ N ih =>
      let e := MeasurableEquiv.piFinSuccAbove (fun _ : Fin (N+1)=>Ω) 0
      have hQ := (measurePreserving_piFinSuccAbove (fun _ : Fin (N+1)=>Q) 0).map_eq
      have hP := (measurePreserving_piFinSuccAbove (fun _ : Fin (N+1)=>P) 0).map_eq
      have h := control_kl_measurableEquiv
        (Measure.pi (fun _ : Fin (N+1)=>Q)) (Measure.pi (fun _ : Fin (N+1)=>P)) e
      rw [hQ,hP,product_control_kl,ih] at h
      rw [←h,Nat.cast_add,Nat.cast_one,add_mul,one_mul,add_comm]

end ConditionalNonpolynomial.Analytic
