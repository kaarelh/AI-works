import Mathlib.Analysis.InnerProductSpace.Orthonormal
import Mathlib.Order.Lattice.Nat
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

/-!
# Maximal orthogonal families under an energy budget

This deterministic lemma replaces a singular-value ordering: a maximal finite
family whose captured energy is at most `K` either controls the residual or
any further energetic orthogonal direction crosses the budget. Cardinality is
bounded by the dimension, so maximality is attained without an infinite choice
or a spectral decomposition.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators RealInnerProductSpace

variable {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [NormedAddCommGroup F] [InnerProductSpace ℝ F]

/-- An explicit finite orthonormal set. -/
def orthonormalFinset (s : Finset E) : Prop :=
  (∀ v ∈ s, ‖v‖ = 1) ∧ ∀ v ∈ s, ∀ w ∈ s, v ≠ w → ⟪v, w⟫ = 0

lemma orthonormalFinset_iff (s : Finset E) :
    orthonormalFinset s ↔ Orthonormal ℝ (fun v : s => (v : E)) := by
  constructor
  · rintro ⟨hn, hi⟩
    refine ⟨fun v => hn v v.property, ?_⟩
    intro v w hvw
    exact hi v v.property w w.property (fun h => hvw (Subtype.ext h))
  · rintro ⟨hn, hi⟩
    refine ⟨fun v hv => hn ⟨v, hv⟩, ?_⟩
    intro v hv w hw hvw
    exact hi (i := ⟨v, hv⟩) (j := ⟨w, hw⟩) (fun h => hvw (congrArg Subtype.val h))

lemma orthonormalFinset_card_le [FiniteDimensional ℝ E]
    (s : Finset E) (hs : orthonormalFinset s) :
    s.card ≤ Module.finrank ℝ E := by
  simpa using ((orthonormalFinset_iff s).mp hs).linearIndependent.fintype_card_le_finrank

lemma orthonormalFinset_insert [DecidableEq E] (s : Finset E) (hs : orthonormalFinset s)
    (v : E) (hv : ‖v‖ = 1) (hortho : ∀ w ∈ s, ⟪v, w⟫ = 0) :
    orthonormalFinset (insert v s) := by
  classical
  constructor
  · intro w hw
    rcases Finset.mem_insert.mp hw with rfl | hw
    · exact hv
    · exact hs.1 w hw
  · intro x hx y hy hxy
    rcases Finset.mem_insert.mp hx with hxv | hxS
    · subst x
      rcases Finset.mem_insert.mp hy with rfl | hy
      · exact (hxy rfl).elim
      · exact hortho y hy
    · rcases Finset.mem_insert.mp hy with hyv | hyS
      · subst y
        rw [real_inner_comm]
        exact hortho x hxS
      · exact hs.2 x hxS y hyS hxy

/-- Energy captured in finitely many orthonormal input directions. -/
def capturedEnergy (A : E →L[ℝ] F) (s : Finset E) : ℝ := ∑ v ∈ s, ‖A v‖ ^ 2

lemma capturedEnergy_nonneg (A : E →L[ℝ] F) (s : Finset E) :
    0 ≤ capturedEnergy A s := Finset.sum_nonneg (fun _ _ => sq_nonneg _)

/-- A maximal energy-budget family exists. Every additional orthogonal unit
vector with image norm above `a` necessarily crosses the budget. -/
theorem exists_maximal_energy_family [FiniteDimensional ℝ E]
    (A : E →L[ℝ] F) (a K : ℝ) (hK : 0 ≤ K) :
    ∃ s : Finset E,
      orthonormalFinset s ∧
      (∀ v ∈ s, a < ‖A v‖) ∧
      capturedEnergy A s ≤ K ∧
      s.card ≤ Module.finrank ℝ E ∧
      ∀ v : E, ‖v‖ = 1 → (∀ w ∈ s, ⟪v, w⟫ = 0) → a < ‖A v‖ →
        K < capturedEnergy A s + ‖A v‖ ^ 2 := by
  classical
  let P : Finset E → Prop := fun s =>
    orthonormalFinset s ∧ (∀ v ∈ s, a < ‖A v‖) ∧ capturedEnergy A s ≤ K
  let cards : Set ℕ := {n | ∃ s : Finset E, P s ∧ s.card = n}
  have hne : cards.Nonempty := by
    refine ⟨0, ∅, ?_, rfl⟩
    simpa [P, orthonormalFinset, capturedEnergy] using hK
  have hbdd : BddAbove cards := by
    refine ⟨Module.finrank ℝ E, ?_⟩
    rintro n ⟨s, hs, rfl⟩
    exact orthonormalFinset_card_le s hs.1
  obtain ⟨s, hs, hcard⟩ := Nat.sSup_mem hne hbdd
  refine ⟨s, hs.1, hs.2.1, hs.2.2, orthonormalFinset_card_le s hs.1, ?_⟩
  intro v hv hortho hlarge
  by_contra hcross
  have hnot : v ∉ s := by
    intro hvs
    have hh := hortho v hvs
    simp [hv] at hh
  have hins : P (insert v s) := by
    refine ⟨orthonormalFinset_insert s hs.1 v hv hortho, ?_, ?_⟩
    · intro w hw
      rcases Finset.mem_insert.mp hw with rfl | hw
      · exact hlarge
      · exact hs.2.1 w hw
    · simpa [capturedEnergy, Finset.sum_insert hnot, add_comm] using le_of_not_gt hcross
  have hmem : (insert v s).card ∈ cards := ⟨insert v s, hins, rfl⟩
  have hle := le_csSup hbdd hmem
  rw [Finset.card_insert_of_notMem hnot, ← hcard] at hle
  omega

/-- The pre-crossing family uses at most `K/a²` directions. This bound is
independent of the ambient dimension. -/
theorem energy_family_card_bound (A : E →L[ℝ] F) (s : Finset E)
    {a K : ℝ} (ha : 0 ≤ a) (hlarge : ∀ v ∈ s, a < ‖A v‖)
    (henergy : capturedEnergy A s ≤ K) : (s.card : ℝ) * a ^ 2 ≤ K := by
  calc
    _ = ∑ v ∈ s, a ^ 2 := by simp
    _ ≤ capturedEnergy A s := Finset.sum_le_sum (fun v hv => by
      have h := hlarge v hv
      nlinarith [norm_nonneg (A v)])
    _ ≤ K := henergy

end NeuralGeneralization
