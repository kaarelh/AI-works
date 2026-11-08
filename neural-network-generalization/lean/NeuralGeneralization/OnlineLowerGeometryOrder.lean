import Mathlib.Data.Fintype.Sort
import Mathlib.Data.Prod.Lex
import Mathlib.Tactic.Linarith
import Lean.Elab.Tactic.Omega

/-!
# A complete adversarial order of calibrated fibers

The construction enumerates the entire finite input set exactly once.
All calibration inputs appear first.  Each remaining fiber is then
revealed in its prescribed order, with a specified input first.  The
permutation depends only on this finite data, not on learner width or
Gaussian scale.
-/

noncomputable section
open scoped Classical

namespace NeuralGeneralization.OnlineLowerGeometry

variable {X : Type*}

/-- Sorting an injectively tie-broken priority gives a complete permutation
which respects every strict priority comparison. -/
theorem exists_priority_order [Fintype X] (priority : X → ℕ) :
    ∃ π : Fin (Fintype.card X) ≃ X,
      ∀ x y, priority x < priority y → π.symm x < π.symm y := by
  let index : X ≃ Fin (Fintype.card X) := Fintype.equivFin X
  let key : X → ℕ ×ₗ Fin (Fintype.card X) := fun x => toLex (priority x, index x)
  have hkey : Function.Injective key := by
    intro x y h
    apply index.injective
    exact congrArg (fun z : ℕ ×ₗ Fin (Fintype.card X) => (ofLex z).2) h
  letI : LinearOrder X := LinearOrder.lift' key hkey
  let e : Fin (Fintype.card X) ≃o X := monoEquivOfFin X rfl
  refine ⟨e.toEquiv, ?_⟩
  intro x y hxy
  have hxy' : x < y := Prod.Lex.left (index x) (index y) hxy
  exact e.symm.strictMono hxy'

/-- `none` marks a calibration input; `some i` marks live fiber `i`. -/
def fiberPriority {T : ℕ} (fiber : X → Option (Fin T)) (first : Fin T → X)
    (x : X) : ℕ :=
  match fiber x with
  | none => 0
  | some i => if x = first i then 2 * i.val + 1 else 2 * i.val + 2

theorem fiberPriority_first {T : ℕ} (fiber : X → Option (Fin T))
    (first : Fin T → X) (hfirst : ∀ i, fiber (first i) = some i) (i : Fin T) :
    fiberPriority fiber first (first i) = 2 * i.val + 1 := by
  simp [fiberPriority, hfirst i]

/-- The priority comparison with the first point of fiber `i` is exactly
the calibration region together with the already completed fibers. -/
theorem fiberPriority_lt_first_iff {T : ℕ} (fiber : X → Option (Fin T))
    (first : Fin T → X) (hfirst : ∀ i, fiber (first i) = some i)
    (i : Fin T) (x : X) :
    fiberPriority fiber first x < fiberPriority fiber first (first i) ↔
      fiber x = none ∨ ∃ j : Fin T, j < i ∧ fiber x = some j := by
  rw [fiberPriority_first fiber first hfirst i]
  cases hx : fiber x with
  | none => simp [fiberPriority, hx]
  | some j =>
    simp only [fiberPriority, hx, Option.some.injEq, reduceCtorEq, false_or]
    by_cases hfirstx : x = first j
    · rw [if_pos hfirstx]
      constructor
      · intro h
        exact ⟨j, by omega, rfl⟩
      · rintro ⟨k, hk, hjk⟩
        subst k
        omega
    · rw [if_neg hfirstx]
      constructor
      · intro h
        exact ⟨j, by omega, rfl⟩
      · rintro ⟨k, hk, hjk⟩
        subst k
        omega

/-- Exact first-hit ordering.  In particular no point of the current or
any later live fiber has been observed at its designated prediction. -/
theorem exists_live_fiber_order [Fintype X] {T : ℕ} (fiber : X → Option (Fin T))
    (first : Fin T → X) (hfirst : ∀ i, fiber (first i) = some i) :
    ∃ π : Fin (Fintype.card X) ≃ X,
      ∀ i x, π.symm x < π.symm (first i) ↔
        fiber x = none ∨ ∃ j : Fin T, j < i ∧ fiber x = some j := by
  obtain ⟨π, hπ⟩ := exists_priority_order (fiberPriority fiber first)
  refine ⟨π, ?_⟩
  intro i x
  constructor
  · intro hbefore
    by_contra hnot
    have hnotlt : ¬ fiberPriority fiber first x < fiberPriority fiber first (first i) := by
      exact fun h => hnot ((fiberPriority_lt_first_iff fiber first hfirst i x).mp h)
    have hle : fiberPriority fiber first (first i) ≤ fiberPriority fiber first x :=
      le_of_not_gt hnotlt
    rw [fiberPriority_first fiber first hfirst i] at hle
    by_cases heq : x = first i
    · subst x
      exact (lt_irrefl _) hbefore
    · have hstrict : fiberPriority fiber first (first i) < fiberPriority fiber first x := by
        rw [fiberPriority_first fiber first hfirst i]
        cases hx : fiber x with
        | none => simp [fiberPriority, hx] at hle
        | some j =>
          simp only [fiberPriority, hx] at hle ⊢
          by_cases hxfirst : x = first j
          · rw [if_pos hxfirst] at hle ⊢
            have hji : j ≠ i := by
              intro hji
              apply heq
              simpa only [hji] using hxfirst
            have hval : j.val ≠ i.val := fun h => hji (Fin.ext h)
            omega
          · rw [if_neg hxfirst] at hle ⊢
            omega
      exact (not_lt_of_gt hbefore) (hπ (first i) x hstrict)
  · intro h
    exact hπ x (first i) ((fiberPriority_lt_first_iff fiber first hfirst i x).mpr h)

theorem first_injective {T : ℕ} (fiber : X → Option (Fin T))
    (first : Fin T → X) (hfirst : ∀ i, fiber (first i) = some i) :
    Function.Injective first := by
  intro i j h
  have h' := congrArg fiber h
  rw [hfirst i, hfirst j] at h'
  exact Option.some.inj h'

/-- Every first hit has a distinct position in the complete permutation. -/
theorem designated_positions_injective [Fintype X] {T : ℕ} (fiber : X → Option (Fin T))
    (first : Fin T → X) (hfirst : ∀ i, fiber (first i) = some i)
    (π : Fin (Fintype.card X) ≃ X) :
    Function.Injective (fun i => π.symm (first i)) :=
  π.symm.injective.comp (first_injective fiber first hfirst)

def designatedRounds [Fintype X] {T : ℕ}
    (first : Fin T → X) (π : Fin (Fintype.card X) ≃ X) :
    Finset (Fin (Fintype.card X)) := Finset.univ.image (fun i => π.symm (first i))

theorem designatedRounds_card [Fintype X] {T : ℕ}
    (fiber : X → Option (Fin T)) (first : Fin T → X)
    (hfirst : ∀ i, fiber (first i) = some i)
    (π : Fin (Fintype.card X) ≃ X) :
    (designatedRounds first π).card = T := by
  rw [designatedRounds, Finset.card_image_of_injective _
    (designated_positions_injective fiber first hfirst π),
    Finset.card_univ, Fintype.card_fin]

theorem designated_positions_strictMono [Fintype X] {T : ℕ}
    (fiber : X → Option (Fin T)) (first : Fin T → X)
    (hfirst : ∀ i, fiber (first i) = some i)
    (π : Fin (Fintype.card X) ≃ X)
    (hπ : ∀ i x, π.symm x < π.symm (first i) ↔
      fiber x = none ∨ ∃ j : Fin T, j < i ∧ fiber x = some j) :
    StrictMono (fun i => π.symm (first i)) := by
  intro i j hij
  exact (hπ j (first i)).mpr (Or.inr ⟨i, hij, hfirst i⟩)

/-- The sign pattern of either a ReLU star or a tanh rectangle: it differs
from the teacher precisely on its exceptional logical fiber. -/
def fiberFlip {T : ℕ} (target : X → Bool) (fiber : X → Option (Fin T))
    (j : Fin T) (x : X) : Bool := if fiber x = some j then !(target x) else target x

theorem fiberFlip_eq_target_iff {T : ℕ} (target : X → Bool)
    (fiber : X → Option (Fin T)) (j : Fin T) (x : X) :
    fiberFlip target fiber j x = target x ↔ fiber x ≠ some j := by
  by_cases h : fiber x = some j
  · cases ht : target x <;> simp [fiberFlip, h, ht]
  · simp [fiberFlip, h]

/-- Candidate `j` fits the exact earlier observations at stage `i` iff
its exceptional fiber has not yet been revealed. -/
theorem fiberFlip_fits_prefix_iff [Fintype X] {T : ℕ} (target : X → Bool)
    (fiber : X → Option (Fin T)) (first : Fin T → X)
    (hfirst : ∀ i, fiber (first i) = some i)
    (π : Fin (Fintype.card X) ≃ X)
    (hπ : ∀ i x, π.symm x < π.symm (first i) ↔
      fiber x = none ∨ ∃ j : Fin T, j < i ∧ fiber x = some j)
    (i j : Fin T) :
    (∀ x, π.symm x < π.symm (first i) → fiberFlip target fiber j x = target x) ↔ i ≤ j := by
  constructor
  · intro hfit
    by_contra hnot
    have hji : j < i := lt_of_not_ge hnot
    have hbefore := (hπ i (first j)).mpr (Or.inr ⟨j, hji, hfirst j⟩)
    have hneq := (fiberFlip_eq_target_iff target fiber j (first j)).mp (hfit _ hbefore)
    exact hneq (hfirst j)
  · intro hij x hbefore
    apply (fiberFlip_eq_target_iff target fiber j x).mpr
    rcases (hπ i x).mp hbefore with hx | ⟨k, hki, hx⟩
    · simp [hx]
    · intro hbad
      have hkj : k = j := Option.some.inj (hx.symm.trans hbad)
      subst k
      exact (not_lt_of_ge hij) hki

/-- Sorting candidate costs once before learning makes candidate `i` the
unique cheapest surviving fiber flip at stage `i`.  No learner width or
Gaussian scale enters the permutation. -/
theorem unique_cheapest_surviving_flip [Fintype X] {T : ℕ}
    {β : Type*} [LinearOrder β] (cost : Fin T → β) (hcost : StrictMono cost)
    (target : X → Bool) (fiber : X → Option (Fin T)) (first : Fin T → X)
    (hfirst : ∀ i, fiber (first i) = some i)
    (π : Fin (Fintype.card X) ≃ X)
    (hπ : ∀ i x, π.symm x < π.symm (first i) ↔
      fiber x = none ∨ ∃ j : Fin T, j < i ∧ fiber x = some j)
    (i j : Fin T) :
    ((∀ x, π.symm x < π.symm (first i) → fiberFlip target fiber j x = target x) ∧
      cost j ≤ cost i) ↔ j = i := by
  rw [fiberFlip_fits_prefix_iff target fiber first hfirst π hπ i j]
  constructor
  · rintro ⟨hij, hjiCost⟩
    by_contra hne
    have hlt : i < j := lt_of_le_of_ne hij (Ne.symm hne)
    exact (not_lt_of_ge hjiCost) (hcost hlt)
  · rintro rfl
    exact ⟨le_rfl, le_rfl⟩

end NeuralGeneralization.OnlineLowerGeometry
