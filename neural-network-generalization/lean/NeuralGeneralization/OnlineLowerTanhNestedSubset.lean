import NeuralGeneralization.OnlineLowerTanhConditioningMixture

/-! # Literal coordinates for nested selected physical subsets -/
noncomputable section
open scoped BigOperators Topology Classical
namespace NeuralGeneralization.OnlineLowerTanh

/-- The indices of `A` viewed in the canonical coordinate order of `B`. -/
def nestedInside {N : ℕ} (B A : Finset (Fin N)) : Finset (Fin B.card) :=
  Finset.univ.filter (fun k => (B.equivFin.symm k).val ∈ A)

@[simp] lemma mem_nestedInside {N : ℕ} (B A : Finset (Fin N)) (k : Fin B.card) :
    k ∈ nestedInside B A ↔ (B.equivFin.symm k).val ∈ A := by
  simp [nestedInside]

/-- The literal subset elements, with their actual physical coordinate retained. -/
def nestedSubsetSubtypeEquiv {N : ℕ} {A B : Finset (Fin N)} (hAB : A ⊆ B) :
    A ≃ nestedInside B A where
  toFun x := ⟨B.equivFin ⟨x.val, hAB x.property⟩, by simp⟩
  invFun k := ⟨(B.equivFin.symm k.val).val, (mem_nestedInside B A k.val).mp k.property⟩
  left_inv x := by apply Subtype.ext; simp
  right_inv k := by apply Subtype.ext; simp

/-- The induced finite coordinate equivalence, with no choice of an abstract
same-cardinality permutation. -/
def nestedSubsetFinEquiv {N : ℕ} {A B : Finset (Fin N)} (hAB : A ⊆ B) :
    Fin A.card ≃ Fin (nestedInside B A).card :=
  A.equivFin.symm.trans ((nestedSubsetSubtypeEquiv hAB).trans (nestedInside B A).equivFin)

lemma nestedInside_card {N : ℕ} {A B : Finset (Fin N)} (hAB : A ⊆ B) :
    (nestedInside B A).card = A.card := by
  have hh := Fintype.card_congr (nestedSubsetFinEquiv hAB)
  simpa only [Fintype.card_fin] using hh.symm

/-- Restricting the actual weights in two stages recovers the one-stage
restriction through the explicit coordinate equivalence. -/
lemma nested_subsetWeights_reindex {N : ℕ} {A B : Finset (Fin N)}
    (hAB : A ⊆ B) (u : Fin N → ℝ) :
    (fun i => subsetWeights (nestedInside B A) (subsetWeights B u)
      (nestedSubsetFinEquiv hAB i)) = subsetWeights A u := by
  funext i
  simp [subsetWeights, nestedSubsetFinEquiv, nestedSubsetSubtypeEquiv]

lemma nested_parityCorrelation {N : ℕ} {A B : Finset (Fin N)}
    (hAB : A ⊆ B) (u : Fin N → ℝ) (b : ℝ) :
    parityCorrelation (subsetWeights A u) b =
      parityCorrelation (subsetWeights (nestedInside B A) (subsetWeights B u)) b := by
  rw [← nested_subsetWeights_reindex hAB u, parityCorrelation_equiv]

lemma nested_parityBiasSecond {N : ℕ} {A B : Finset (Fin N)}
    (hAB : A ⊆ B) (u : Fin N → ℝ) (b : ℝ) :
    parityBiasSecond (subsetWeights A u) b =
      parityBiasSecond (subsetWeights (nestedInside B A) (subsetWeights B u)) b := by
  rw [← nested_subsetWeights_reindex hAB u, parityBiasSecond_equiv]

lemma nested_incomingEnergy {N : ℕ} {A B : Finset (Fin N)}
    (hAB : A ⊆ B) (u : Fin N → ℝ) :
    incomingEnergy (subsetWeights A u) =
      incomingEnergy (subsetWeights (nestedInside B A) (subsetWeights B u)) := by
  rw [← nested_subsetWeights_reindex hAB u, incomingEnergy_equiv]

/-- The coordinates outside the nested selection are a subset of the original
outside coordinates, so their incoming squared energy cannot increase. -/
lemma nested_outside_energy_le {N : ℕ} {A B : Finset (Fin N)}
    (hAB : A ⊆ B) (u : Fin N → ℝ) :
    incomingEnergy (subsetWeights (nestedInside B A)ᶜ (subsetWeights B u)) ≤
      incomingEnergy (subsetWeights Aᶜ u) := by
  have hB : incomingEnergy (subsetWeights B u) ≤ incomingEnergy u := by
    rw [incomingEnergy_subsetWeights]
    exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ B) (fun x _ _ => sq_nonneg (u x))
  have hpart := incomingEnergy_partition (nestedInside B A) (subsetWeights B u)
  have hfull := incomingEnergy_partition A u
  rw [← nested_incomingEnergy hAB u] at hpart
  linarith

lemma nested_outside_sum_sq_le {N : ℕ} {A B : Finset (Fin N)}
    (hAB : A ⊆ B) (u : Fin N → ℝ) :
    (∑ k ∈ (nestedInside B A)ᶜ,(subsetWeights B u k)^2) ≤ ∑ i ∈ Aᶜ,(u i)^2 := by
  simpa only [incomingEnergy_subsetWeights] using nested_outside_energy_le hAB u

end NeuralGeneralization.OnlineLowerTanh
