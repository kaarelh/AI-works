import NeuralGeneralization.BatchTwoMergingPaddedBasis

/-! # Averaging is an orthogonal contraction, with exact preservation of populations -/
noncomputable section
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open Classical
attribute [local instance] Classical.propDecidable

def partitionOfMap {N : ℕ} {I : Type*} [Fintype I] (g : Fin N → I) : PopulationPartition N := by
  classical
  let q := Fintype.card (Set.range g)
  have hq : q ≤ N := by simpa [q] using Fintype.card_range_le g
  let e := Fintype.equivFin (Set.range g)
  refine ⟨⟨⟨q,Nat.lt_succ_of_le hq⟩,fun i => e ⟨g i,⟨i,rfl⟩⟩⟩,?_⟩
  intro a
  obtain ⟨i,hi⟩ := (e.symm a).property
  refine ⟨i,?_⟩
  change e ⟨g i,⟨i,rfl⟩⟩ = a
  have he : (⟨g i,⟨i,rfl⟩⟩ : Set.range g) = e.symm a := Subtype.ext hi
  rw [he,e.apply_symm_apply]

theorem populationCount_partitionOfMap {N : ℕ} {I : Type*} [Fintype I] (g : Fin N → I) :
    populationCount (partitionOfMap g) = Fintype.card (Set.range g) := rfl

theorem populationCount_partitionOfMap_le {N : ℕ} {I : Type*} [Fintype I] (g : Fin N → I) :
    populationCount (partitionOfMap g) ≤ Fintype.card I := by
  rw [populationCount_partitionOfMap]
  exact Fintype.card_subtype_le _

theorem populationLabel_partitionOfMap_eq_iff {N : ℕ} {I : Type*} [Fintype I]
    (g : Fin N → I) (i j : Fin N) :
    populationLabel (partitionOfMap g) i = populationLabel (partitionOfMap g) j ↔ g i=g j := by
  classical
  change (Fintype.equivFin (Set.range g)) ⟨g i,⟨i,rfl⟩⟩ =
    (Fintype.equivFin (Set.range g)) ⟨g j,⟨j,rfl⟩⟩ ↔ _
  rw [Equiv.apply_eq_iff_eq, Subtype.mk.injEq]

theorem populationAverage_eq_of_fibre_constant {N : ℕ} (p : PopulationPartition N)
    (h : Fin N → ℝ) (hh : ∀ i j, populationLabel p i=populationLabel p j → h i=h j) :
    populationAverage p h = h := by
  funext i
  unfold populationAverage
  calc
    _ = ∑ j, populationProjection p i j*h i := by
      apply Finset.sum_congr rfl
      intro j _
      by_cases he : populationLabel p i=populationLabel p j
      · rw [hh i j he]
      · simp [populationProjection,he]
    _ = h i := by rw [← Finset.sum_mul,populationProjection_row_sum,one_mul]

theorem populationAverage_self_adjoint {N : ℕ} (p : PopulationPartition N)
    (h g : Fin N → ℝ) :
    (∑ i, populationAverage p h i*g i) = ∑ i,h i*populationAverage p g i := by
  simp only [populationAverage, Finset.sum_mul, Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  rw [populationProjection_symm p j i]
  ring

theorem populationAverage_squaredSum_le {N : ℕ} (p : PopulationPartition N)
    (h : Fin N → ℝ) : (∑ i,populationAverage p h i^2) ≤ ∑ i,h i^2 := by
  have he : (∑ i,populationAverage p h i^2) = ∑ i,h i*populationAverage p h i := by
    simpa only [pow_two,populationAverage_idempotent] using
      populationAverage_self_adjoint p h (populationAverage p h)
  have hc := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ h (populationAverage p h)
  rw [← he] at hc
  have hn : 0 ≤ ∑ i,populationAverage p h i^2 := Finset.sum_nonneg fun i _ => sq_nonneg _
  have hh : 0 ≤ ∑ i,h i^2 := Finset.sum_nonneg fun i _ => sq_nonneg _
  nlinarith

theorem projection_left_squaredSum_le {N : ℕ} (p : PopulationPartition N)
    (A : Matrix (Fin N) (Fin N) ℝ) :
    (∑ i,∑ j,(Matrix.of (populationProjection p)*A) i j^2) ≤ ∑ i,∑ j,A i j^2 := by
  rw [Finset.sum_comm,Finset.sum_comm (f := fun i j => A i j^2)]
  apply Finset.sum_le_sum
  intro j _
  exact populationAverage_squaredSum_le p (fun i => A i j)

theorem projection_right_squaredSum_le {N : ℕ} (p : PopulationPartition N)
    (A : Matrix (Fin N) (Fin N) ℝ) :
    (∑ i,∑ j,(A*Matrix.of (populationProjection p)) i j^2) ≤ ∑ i,∑ j,A i j^2 := by
  apply Finset.sum_le_sum
  intro i _
  have he : (fun j => (A*Matrix.of (populationProjection p)) i j) =
      populationAverage p (A i) := by
    funext j
    simp only [Matrix.mul_apply,Matrix.of_apply,populationAverage]
    apply Finset.sum_congr rfl
    intro k _
    rw [populationProjection_symm p k j]
    ring
  simpa only [← he] using populationAverage_squaredSum_le p (A i)

end NeuralGeneralization.BatchTwoMerging
