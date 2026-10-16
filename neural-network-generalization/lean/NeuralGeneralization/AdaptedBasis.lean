import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.LinearAlgebra.Dimension.Constructions

/-!
# An orthonormal basis adapted to a subspace

Every subspace of a finite Euclidean space is spanned by exactly its dimension
many members of an ambient orthonormal basis. The proof extends a genuine
orthonormal basis of the subspace and identifies the constrained coordinates.
-/

noncomputable section
open Module Submodule
namespace NeuralGeneralization.AdaptedBasis

/-- An ambient orthonormal basis with a coordinate subset spanning `S`, whose
cardinality is exactly the dimension of `S`. -/
theorem exists_adapted_orthonormalBasis (N : ℕ)
    (S : Submodule ℝ (EuclideanSpace ℝ (Fin N))) :
    ∃ (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
      (J : Finset (Fin N)), J.card = finrank ℝ S ∧
        S = Submodule.span ℝ (b '' (J : Set (Fin N))) := by
  classical
  let cS := stdOrthonormalBasis ℝ S
  let c : Fin (finrank ℝ S) → EuclideanSpace ℝ (Fin N) :=
    fun j => (cS j : EuclideanSpace ℝ (Fin N))
  have hc : Orthonormal ℝ c := cS.orthonormal.comp_linearIsometry S.subtypeₗᵢ
  obtain ⟨u, b₀, hu, hb₀⟩ := hc.toSubtypeRange.exists_orthonormalBasis_extension
  have hcard : Fintype.card u = N := by
    simpa only [finrank_euclideanSpace_fin] using
      (Module.finrank_eq_card_basis b₀.toBasis).symm
  let e : u ≃ Fin N := (Fintype.equivFin u).trans (finCongr hcard)
  let b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)) := b₀.reindex e
  let J : Finset (Fin N) := Finset.univ.filter fun j => b j ∈ S
  have hspan_c : Submodule.span ℝ (Set.range c) = S := by
    change Submodule.span ℝ (Set.range (S.subtype ∘ cS)) = S
    rw [Set.range_comp, Submodule.span_image]
    have hs : Submodule.span ℝ (Set.range cS) = ⊤ := cS.toBasis.span_eq
    rw [hs, Submodule.map_subtype_top]
  have hcle (j : Fin (finrank ℝ S)) :
      c j ∈ Submodule.span ℝ (b '' (J : Set (Fin N))) := by
    have hj : c j ∈ u := hu (Set.mem_range_self j)
    let k : u := ⟨c j, hj⟩
    have hbk : b (e k) = c j := by
      dsimp [b]
      rw [OrthonormalBasis.reindex_apply, Equiv.symm_apply_apply, hb₀]
    apply Submodule.subset_span
    refine ⟨e k, ?_, hbk⟩
    simp only [J, Finset.mem_coe, Finset.mem_filter, Finset.mem_univ, true_and]
    rw [hbk]
    exact (cS j).property
  have hspan : S = Submodule.span ℝ (b '' (J : Set (Fin N))) := by
    apply le_antisymm
    · rw [← hspan_c]
      apply Submodule.span_le.mpr
      rintro x ⟨j, rfl⟩
      exact hcle j
    · apply Submodule.span_le.mpr
      rintro x ⟨j, hj, rfl⟩
      exact (Finset.mem_filter.mp hj).2
  have hli : LinearIndependent ℝ (fun j : J => b j) :=
    b.orthonormal.linearIndependent.comp (fun j : J => (j : Fin N)) Subtype.val_injective
  have hrange : Set.range (fun j : J => b j) = b '' (J : Set (Fin N)) := by
    ext x
    constructor
    · rintro ⟨j, rfl⟩
      exact ⟨j, j.property, rfl⟩
    · rintro ⟨j, hj, rfl⟩
      exact ⟨⟨j, hj⟩, rfl⟩
  have hdim := finrank_span_eq_card hli
  rw [hrange, ← hspan] at hdim
  refine ⟨b, J, ?_, hspan⟩
  simpa only [Fintype.card_coe] using hdim.symm

end NeuralGeneralization.AdaptedBasis
