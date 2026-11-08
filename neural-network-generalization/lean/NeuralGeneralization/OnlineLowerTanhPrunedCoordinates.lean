import NeuralGeneralization.OnlineLowerTanhPrunedBulk
import NeuralGeneralization.OnlineLowerTanhCodeSupport

/-! # Literal finite coordinate arrays for a pruned lattice bulk -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

/-- The original integer label, now viewed as an element of the retained
finite alphabet. -/
def prunedAlphabetLabel {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (ε : ℝ) (S : Finset ℕ) (i : Fin (prunedLatticeIndices q d ε S).card) : S :=
  ⟨q (((prunedLatticeIndices q d ε S).equivFin.symm i).val),
    (Finset.mem_filter.mp (((prunedLatticeIndices q d ε S).equivFin.symm i).property)).2.1⟩

lemma pruned_residual_abs_le {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (ε : ℝ) (S : Finset ℕ) (i : Fin (prunedLatticeIndices q d ε S).card) :
    |subsetWeights (prunedLatticeIndices q d ε S) d i| ≤ ε :=
  (Finset.mem_filter.mp (((prunedLatticeIndices q d ε S).equivFin.symm i).property)).2.2

lemma pruned_residual_energy_le {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (ε : ℝ) (S : Finset ℕ) :
    (∑ i,(subsetWeights (prunedLatticeIndices q d ε S) d i)^2) ≤ ∑ i,(d i)^2 := by
  simp only [subsetWeights]
  rw [subset_sum_reindex (prunedLatticeIndices q d ε S) (fun i => (d i)^2)]
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
    (fun i _ _ => sq_nonneg (d i))

lemma pruned_label_count {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (ε : ℝ) (S : Finset ℕ) (j : S) :
    (n:ℝ)⁻¹*((Finset.univ.filter (fun i => prunedAlphabetLabel q d ε S i=j)).card:ℝ) =
      prunedEmpiricalMass q d ε j.val := by
  have he (i : Fin (prunedLatticeIndices q d ε S).card) :
      prunedAlphabetLabel q d ε S i=j ↔
        q (((prunedLatticeIndices q d ε S).equivFin.symm i).val)=j.val := by
    exact Subtype.ext_iff
  simp_rw [he]
  have hsum : ((Finset.univ.filter (fun i : Fin (prunedLatticeIndices q d ε S).card =>
      q (((prunedLatticeIndices q d ε S).equivFin.symm i).val)=j.val)).card:ℝ)=
      ∑ i : Fin (prunedLatticeIndices q d ε S).card,
        if q (((prunedLatticeIndices q d ε S).equivFin.symm i).val)=j.val then (1:ℝ) else 0 := by simp
  rw [hsum,subset_sum_reindex (prunedLatticeIndices q d ε S) (fun i => if q i=j.val then (1:ℝ) else 0)]
  unfold prunedEmpiricalMass
  congr 1
  rw [prunedLatticeIndices,Finset.sum_filter]
  apply Finset.sum_congr rfl
  intro i _
  by_cases hq : q i=j.val
  · simp [hq,j.property]
  · simp [hq]

lemma pruned_label_variance {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (ε : ℝ) (S : Finset ℕ) :
    (∑ i,((prunedAlphabetLabel q d ε S i).val:ℝ)^2)=
      ∑ i ∈ prunedLatticeIndices q d ε S,(q i:ℝ)^2 :=
  by simpa only [prunedAlphabetLabel] using subset_sum_reindex (prunedLatticeIndices q d ε S) (fun i => (q i:ℝ)^2)

lemma pruned_decomposition {n : ℕ} (q : Fin n → ℕ) (u : Fin n → ℝ)
    (a ε : ℝ) (S : Finset ℕ)
    (i : Fin (prunedLatticeIndices q (fun i => |u i|-a*(q i:ℝ)) ε S).card) :
    subsetWeights (prunedLatticeIndices q (fun i => |u i|-a*(q i:ℝ)) ε S) (fun i => |u i|) i =
      a*((prunedAlphabetLabel q (fun i => |u i|-a*(q i:ℝ)) ε S i).val:ℝ)+
      subsetWeights (prunedLatticeIndices q (fun i => |u i|-a*(q i:ℝ)) ε S)
        (fun i => |u i|-a*(q i:ℝ)) i := by
  simp only [subsetWeights,prunedAlphabetLabel]
  ring

lemma pruned_normalized_decomposition {n : ℕ} (q : Fin n → ℕ) (u : Fin n → ℝ)
    (a ε : ℝ) (S : Finset ℕ) (g : ℕ) (hdiv : ∀ j ∈ S,g∣j)
    (i : Fin (prunedLatticeIndices q (fun i => |u i|-a*(q i:ℝ)) ε S).card) :
    subsetWeights (prunedLatticeIndices q (fun i => |u i|-a*(q i:ℝ)) ε S) (fun i => |u i|) i =
      (a*g)*(((prunedAlphabetLabel q (fun i => |u i|-a*(q i:ℝ)) ε S i).val/g:ℕ):ℝ)+
      subsetWeights (prunedLatticeIndices q (fun i => |u i|-a*(q i:ℝ)) ε S)
        (fun i => |u i|-a*(q i:ℝ)) i := by
  rw [pruned_decomposition]
  congr 1
  let j := prunedAlphabetLabel q (fun i => |u i|-a*(q i:ℝ)) ε S i
  have hj : g*(j.val/g)=j.val := Nat.mul_div_cancel' (hdiv j.val j.property)
  have hjR : (g:ℝ)*(j.val/g:ℕ)=j.val := by exact_mod_cast hj
  change a*(j.val:ℝ)=(a*g)*(j.val/g:ℕ)
  rw [←hjR]
  ring

lemma pruned_refit_decomposition {n : ℕ} (q : Fin n → ℕ) (u : Fin n → ℝ)
    (a ε : ℝ) (S : Finset ℕ) (g : ℕ) (hdiv : ∀ j ∈ S,g∣j) :
    let P := prunedLatticeIndices q (fun i => |u i|-a*(q i:ℝ)) ε S
    let q' : Fin P.card → ℕ := fun i => (prunedAlphabetLabel q (fun i => |u i|-a*(q i:ℝ)) ε S i).val/g
    let d' := subsetWeights P (fun i => |u i|-a*(q i:ℝ))
    subsetWeights P (fun i => |u i|)=
      fun i => (a*g+latticeRefitSlope q' d')*(q' i:ℝ)+latticeRefitResidual q' d' i := by
  dsimp only
  funext i
  rw [pruned_normalized_decomposition q u a ε S g hdiv i]
  unfold latticeRefitResidual
  ring

end NeuralGeneralization.OnlineLowerTanh
