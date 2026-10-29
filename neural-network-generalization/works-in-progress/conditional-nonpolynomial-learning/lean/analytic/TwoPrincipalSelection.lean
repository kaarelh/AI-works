import TwoPrincipalGeometry
import TwoBallEntropyGap
import Mathlib.Data.Finset.Max

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

theorem exists_two_principal_indices {I:Type*} [Fintype I] [DecidableEq I]
    (w:I→ℝ) (hcard:2≤Fintype.card I) :
    ∃i j:I,i≠j ∧ w j≤w i ∧ (∀k,w k≤w i) ∧ (∀k,k≠i→w k≤w j) := by
  have hn : (Finset.univ:Finset I).Nonempty := Finset.card_pos.mp (by
    simpa only [Finset.card_univ] using (show 0<Fintype.card I by omega))
  obtain ⟨i,hi,himax⟩ := Finset.exists_max_image Finset.univ w hn
  have hne : (Finset.univ.erase i).Nonempty := Finset.card_pos.mp (by
    rw [Finset.card_erase_of_mem hi,Finset.card_univ]
    omega)
  obtain ⟨j,hj,hjmax⟩ := Finset.exists_max_image (Finset.univ.erase i) w hne
  refine ⟨i,j,(Finset.mem_erase.mp hj).1.symm,himax j (Finset.mem_univ j),
    fun k=>himax k (Finset.mem_univ k),?_⟩
  intro k hk
  exact hjmax k (Finset.mem_erase.mpr ⟨hk,Finset.mem_univ k⟩)

#print axioms exists_two_principal_indices
end ConditionalNonpolynomial.Analytic
