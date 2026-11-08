import NeuralGeneralization.OnlineLowerGeometryOrder
import NeuralGeneralization.OnlineLowerTeacherModel

/-!
# The fiber permutation in the actual online protocol

This file specializes the complete finite permutation to the repository's
`InputOrder` and `observedPrefix`.  It proves the literal history at each
designated prediction, rather than using a surrogate list of logical
observations.
-/

noncomputable section
open scoped Classical

namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerGeometry

theorem observedPrefix_range_iff {d : ℕ} (π : InputOrder d)
    (j : Fin (Fintype.card (Cube d))) (x : Cube d) :
    (∃ k : Fin j.val, observedPrefix π j k = x) ↔ π.symm x < j := by
  constructor
  · rintro ⟨k, hk⟩
    have hposition : π.symm x = ⟨k.val, lt_trans k.isLt j.isLt⟩ := by
      rw [← hk]
      exact π.symm_apply_apply _
    rw [hposition]
    exact k.isLt
  · intro hx
    refine ⟨⟨(π.symm x).val, hx⟩, ?_⟩
    exact π.apply_symm_apply x

/-- A width- and scale-independent permutation with the exact physical
calibration prefix and ordered complete live fibers. -/
theorem exists_fiber_inputOrder {d T : ℕ}
    (fiber : Cube d → Option (Fin T)) (first : Fin T → Cube d)
    (hfirst : ∀ i, fiber (first i) = some i) :
    ∃ π : InputOrder d, ∀ i x,
      (∃ k : Fin (π.symm (first i)).val,
        observedPrefix π (π.symm (first i)) k = x) ↔
          fiber x = none ∨ ∃ j : Fin T, j < i ∧ fiber x = some j := by
  obtain ⟨π, hπ⟩ := exists_live_fiber_order fiber first hfirst
  refine ⟨π, ?_⟩
  intro i x
  rw [observedPrefix_range_iff]
  exact hπ i x

theorem observedPrefix_fits_fiberFlip_iff {d T : ℕ}
    (target : BooleanFunction d) (fiber : Cube d → Option (Fin T))
    (first : Fin T → Cube d) (hfirst : ∀ i, fiber (first i) = some i)
    (π : InputOrder d)
    (hπ : ∀ i x, π.symm x < π.symm (first i) ↔
      fiber x = none ∨ ∃ j : Fin T, j < i ∧ fiber x = some j)
    (i j : Fin T) :
    (∀ k : Fin (π.symm (first i)).val,
      fiberFlip target fiber j (observedPrefix π (π.symm (first i)) k) =
        target (observedPrefix π (π.symm (first i)) k)) ↔ i ≤ j := by
  rw [← fiberFlip_fits_prefix_iff target fiber first hfirst π hπ i j]
  constructor
  · intro hfit x hbefore
    obtain ⟨k, hk⟩ := (observedPrefix_range_iff π (π.symm (first i)) x).mpr hbefore
    simpa only [hk] using hfit k
  · intro hfit k
    apply hfit
    exact (observedPrefix_range_iff π (π.symm (first i)) _).mp ⟨k, rfl⟩

/-- The candidate chosen by the strict cost ordering is actually wrong
at the current physical input, which has not appeared in the prefix. -/
theorem fiberFlip_wrong_at_designated {d T : ℕ}
    (target : BooleanFunction d) (fiber : Cube d → Option (Fin T))
    (first : Fin T → Cube d) (hfirst : ∀ i, fiber (first i) = some i)
    (π : InputOrder d) (i : Fin T) :
    fiberFlip target fiber i (π (π.symm (first i))) ≠
      target (π (π.symm (first i))) := by
  rw [π.apply_symm_apply]
  intro h
  exact (fiberFlip_eq_target_iff target fiber i (first i)).mp h (hfirst i)

/-- The assembled deterministic protocol: exactly `T` designated rounds,
the literal observations of the model, and a wrong surviving comparator
at each one.  Energy separation remains a separate neural obligation. -/
theorem exists_ordered_fiber_protocol {d T : ℕ}
    (target : BooleanFunction d) (fiber : Cube d → Option (Fin T))
    (first : Fin T → Cube d) (hfirst : ∀ i, fiber (first i) = some i) :
    ∃ π : InputOrder d, ∃ J : Finset (Fin (Fintype.card (Cube d))),
      J.card = T ∧ ∀ i : Fin T,
        π.symm (first i) ∈ J ∧
        (∀ j : Fin T,
          (∀ k : Fin (π.symm (first i)).val,
            fiberFlip target fiber j (observedPrefix π (π.symm (first i)) k) =
              target (observedPrefix π (π.symm (first i)) k)) ↔ i ≤ j) ∧
        fiberFlip target fiber i (π (π.symm (first i))) ≠
          target (π (π.symm (first i))) := by
  obtain ⟨π, hπ⟩ := exists_live_fiber_order fiber first hfirst
  refine ⟨π, designatedRounds first π, designatedRounds_card fiber first hfirst π, ?_⟩
  intro i
  refine ⟨Finset.mem_image.mpr ⟨i, Finset.mem_univ i, rfl⟩, ?_, ?_⟩
  · intro j
    exact observedPrefix_fits_fiberFlip_iff target fiber first hfirst π hπ i j
  · exact fiberFlip_wrong_at_designated target fiber first hfirst π i

end NeuralGeneralization.OnlineLower
