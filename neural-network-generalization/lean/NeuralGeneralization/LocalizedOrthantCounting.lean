import NeuralGeneralization.LocalizedFamilyCounting

/-! The uncovered region of finitely many fixed-center neighborhoods is an
upper orthant in their distance vector. The VC bound is proved by assigning
a distinct separating coordinate to each point in a shattered set. -/
noncomputable section
open Classical
namespace NeuralGeneralization.RobustLocalized
open ConcreteModel
variable {X : Type*} [Fintype X] [DecidableEq X] {m : ℕ}

/-- All strict upper-orthant patterns, with arbitrary real thresholds. -/
def orthantPatterns (u : X → Fin m → ℝ) : Finset (Finset X) :=
  Finset.univ.filter fun A => ∃ t : Fin m → ℝ,∀ x,x ∈ A ↔ ∀ j,t j < u x j

lemma orthant_shattered_card (u : X → Fin m → ℝ) (S : Finset X)
    (hS : (orthantPatterns u).Shatters S) : S.card ≤ m := by
  have hsep (x : S) : ∃ j : Fin m,∀ y : S,y ≠ x → u x j < u y j := by
    obtain ⟨P,hP,hSP⟩ := hS (Finset.erase_subset x.val S)
    obtain ⟨t,ht⟩ := (Finset.mem_filter.mp hP).2
    have hnot : x.val ∉ P := by
      intro hx
      have hh : x.val ∈ S ∩ P := Finset.mem_inter.mpr ⟨x.property,hx⟩
      rw [hSP] at hh
      exact Finset.notMem_erase _ _ hh
    have hn : ¬ ∀ j,t j < u x j := by simpa only [← ht] using hnot
    obtain ⟨j,hj⟩ := not_forall.mp hn
    refine ⟨j,fun y hy => ?_⟩
    have hxy : y.val ≠ x.val := fun h => hy (Subtype.ext h)
    have hyP : y.val ∈ P := by
      have hh : y.val ∈ S.erase x.val := Finset.mem_erase.mpr ⟨hxy,y.property⟩
      rw [← hSP] at hh
      exact (Finset.mem_inter.mp hh).2
    exact (le_of_not_gt hj).trans_lt ((ht y.val).mp hyP j)
  choose j hj using hsep
  have hinj : Function.Injective j := by
    intro x y hxy
    by_contra hne
    have hx := hj x y (Ne.symm hne)
    have hy := hj y x hne
    rw [hxy] at hx
    exact (lt_irrefl _) (hx.trans hy)
  simpa only [Fintype.card_coe,Fintype.card_fin] using Fintype.card_le_of_injective j hinj

theorem orthant_vcDim (u : X → Fin m → ℝ) : (orthantPatterns u).vcDim ≤ m := by
  unfold Finset.vcDim
  exact Finset.sup_le fun S hS => orthant_shattered_card u S (Finset.mem_shatterer.mp hS)

theorem orthant_card (u : X → Fin m → ℝ) :
    (orthantPatterns u).card ≤ (Fintype.card X+1)^m :=
  family_card_le_vc_power _ (orthant_vcDim u)

/-- Fixed pilot centers, arbitrary fixed distance functions, and independently
chosen radii all belong to the same family. No metric axiom is needed. -/
theorem uncovered_neighborhood_mem (distances : X → Fin m → ℝ) (radii : Fin m → ℝ) :
    (Finset.univ.filter fun x => ¬ ∃ j,distances x j ≤ radii j) ∈ orthantPatterns distances := by
  apply Finset.mem_filter.mpr
  refine ⟨Finset.mem_univ _,radii,?_⟩
  intro x
  simp only [Finset.mem_filter,Finset.mem_univ,true_and,not_exists,not_le]

theorem cube_orthant_log_card {d : ℕ} (distances : Cube d → Fin m → ℝ) :
    Real.log ((orthantPatterns distances).card:ℝ) ≤ (m:ℝ)*((d:ℝ)+1)*Real.log 2 :=
  cube_family_log_card _ (orthant_vcDim distances)

end NeuralGeneralization.RobustLocalized
