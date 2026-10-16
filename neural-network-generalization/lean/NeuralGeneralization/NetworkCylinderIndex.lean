import NeuralGeneralization.Network
import Mathlib.Tactic.Ring

/-!
# Constrained and free coordinates of a network cylinder

Input and readout coordinates are constrained. In each internal row, exactly
the columns in `J` are constrained; the other columns form the free directions.
All cardinalities and equivalences refer to the actual network weight index.
-/

noncomputable section
namespace NeuralGeneralization.ConcreteModel

/-- Coordinates constrained in a Gaussian network cylinder. -/
def constrainedIndex {d N r : ℕ} (J : Finset (Fin N)) : WeightIndex d N r → Prop
  | Sum.inl _ => True
  | Sum.inr (Sum.inl (_, _, j)) => j ∈ J
  | Sum.inr (Sum.inr _) => True

instance decidableConstrainedIndex {d N r : ℕ} (J : Finset (Fin N)) :
    DecidablePred (constrainedIndex (d := d) (r := r) J) := by
  intro q
  cases q with
  | inl q => exact isTrue True.intro
  | inr q =>
    cases q with
    | inl q => exact inferInstanceAs (Decidable (q.2.2 ∈ J))
    | inr q => exact isTrue True.intro

@[simp] theorem constrainedIndex_input {d N r : ℕ} (J : Finset (Fin N))
    (i : Fin N) (j : Fin (d + 1)) :
    constrainedIndex (r := r) J (Sum.inl (i, j)) := True.intro

@[simp] theorem constrainedIndex_internal {d N r : ℕ} (J : Finset (Fin N))
    (s : Fin r) (i j : Fin N) :
    constrainedIndex (d := d) J (Sum.inr (Sum.inl (s, i, j))) ↔ j ∈ J := Iff.rfl

@[simp] theorem constrainedIndex_readout {d N r : ℕ} (J : Finset (Fin N))
    (i : Fin N) : constrainedIndex (d := d) (r := r) J (Sum.inr (Sum.inr i)) := True.intro

/-- The constrained subtype is exactly the input block, selected internal
columns, and readout block. -/
def constrainedIndexEquiv {d N r : ℕ} (J : Finset (Fin N)) :
    {q : WeightIndex d N r // constrainedIndex J q} ≃
      (Fin N × Fin (d + 1)) ⊕ (((Fin r × Fin N) × {j : Fin N // j ∈ J}) ⊕ Fin N) where
  toFun q := by
    rcases q with ⟨q, hq⟩
    rcases q with q | q
    · exact Sum.inl q
    · rcases q with ⟨s, i, j⟩ | i
      · exact Sum.inr (Sum.inl ((s, i), ⟨j, hq⟩))
      · exact Sum.inr (Sum.inr i)
  invFun q := by
    rcases q with q | q
    · exact ⟨Sum.inl q, True.intro⟩
    · rcases q with ⟨⟨s, i⟩, ⟨j, hj⟩⟩ | i
      · exact ⟨Sum.inr (Sum.inl (s, i, j)), hj⟩
      · exact ⟨Sum.inr (Sum.inr i), True.intro⟩
  left_inv q := by
    rcases q with ⟨q, hq⟩
    rcases q with q | q
    · rfl
    · rcases q with ⟨s, i, j⟩ | i <;> rfl
  right_inv q := by
    rcases q with q | q
    · rfl
    · rcases q with ⟨⟨s, i⟩, ⟨j, hj⟩⟩ | i <;> rfl

/-- Exact number of constrained network coordinates. -/
theorem card_constrainedIndex {d N r : ℕ} (J : Finset (Fin N)) :
    Fintype.card {q : WeightIndex d N r // constrainedIndex J q} =
      N * (d + 2 + r * J.card) := by
  rw [Fintype.card_congr (constrainedIndexEquiv (d := d) (r := r) J)]
  simp only [Fintype.card_sum, Fintype.card_prod, Fintype.card_fin, Fintype.card_coe]
  ring

/-- Free coordinates are exactly the internal row index and an unselected column. -/
def freeIndexEquiv {d N r : ℕ} (J : Finset (Fin N)) :
    {q : WeightIndex d N r // ¬constrainedIndex J q} ≃
      ((Fin r × Fin N) × {j : Fin N // j ∉ J}) where
  toFun q := by
    rcases q with ⟨q, hq⟩
    rcases q with q | q
    · exact False.elim (hq True.intro)
    · rcases q with ⟨s, i, j⟩ | i
      · exact ((s, i), ⟨j, hq⟩)
      · exact False.elim (hq True.intro)
  invFun q :=
    ⟨Sum.inr (Sum.inl (q.1.1, q.1.2, q.2.1)), q.2.2⟩
  left_inv q := by
    rcases q with ⟨q, hq⟩
    rcases q with q | q
    · exact False.elim (hq True.intro)
    · rcases q with ⟨s, i, j⟩ | i
      · rfl
      · exact False.elim (hq True.intro)
  right_inv q := by
    rcases q with ⟨⟨s, i⟩, ⟨j, hj⟩⟩
    rfl

@[simp] theorem freeIndexEquiv_symm_coe {d N r : ℕ} (J : Finset (Fin N))
    (s : Fin r) (i : Fin N) (j : {j : Fin N // j ∉ J}) :
    ((freeIndexEquiv (d := d) J).symm ((s, i), j) : WeightIndex d N r) =
      Sum.inr (Sum.inl (s, i, j.1)) := rfl

/-- Number of free coordinates, retaining the free-column subtype explicitly. -/
theorem card_freeIndex {d N r : ℕ} (J : Finset (Fin N)) :
    Fintype.card {q : WeightIndex d N r // ¬constrainedIndex J q} =
      r * N * Fintype.card {j : Fin N // j ∉ J} := by
  rw [Fintype.card_congr (freeIndexEquiv (d := d) (r := r) J)]
  simp only [Fintype.card_prod, Fintype.card_fin]

end NeuralGeneralization.ConcreteModel
