import Mathlib.Data.Finset.Max
import Mathlib.Data.Fintype.Card
import Mathlib.Data.Real.Basic
import Lean.Elab.Tactic.Omega

/-!
# Medians of finite families, with repeated values allowed

A median is selected from the family itself. The proof chooses the least value
whose lower level set contains at least half of the indices, rather than sorting
distinct values and losing multiplicities.
-/

namespace Paulsen

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- Every nonempty finite real family has a median among its coordinates. -/
theorem finite_median_index (z : ι → ℝ) :
    ∃ k : ι,
      Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => z i ≤ z k)).card ∧
      Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => z k ≤ z i)).card := by
  classical
  let lower : ι → Finset ι := fun k => Finset.univ.filter (fun i => z i ≤ z k)
  let good : Finset ι := Finset.univ.filter (fun k => Fintype.card ι ≤ 2 * (lower k).card)
  have hn : 0 < Fintype.card ι := Fintype.card_pos
  obtain ⟨kmax, _, hkmax⟩ := Finset.exists_max_image Finset.univ z Finset.univ_nonempty
  have hmax : ∀ i, z i ≤ z kmax := fun i => hkmax i (Finset.mem_univ i)
  have hlowerMax : lower kmax = Finset.univ := by
    ext i
    simp [lower, hmax i]
  have hgood : good.Nonempty := by
    refine ⟨kmax, ?_⟩
    simp only [good, Finset.mem_filter, Finset.mem_univ, true_and, hlowerMax, Finset.card_univ]
    omega
  obtain ⟨k, hkgood, hkmin⟩ := Finset.exists_min_image good z hgood
  have hklower : Fintype.card ι ≤ 2 * (lower k).card := (Finset.mem_filter.mp hkgood).2
  let strictLower : Finset ι := Finset.univ.filter (fun i => z i < z k)
  have hstrict : 2 * strictLower.card < Fintype.card ι := by
    by_contra hnot
    have hlarge : Fintype.card ι ≤ 2 * strictLower.card := by omega
    have hnonempty : strictLower.Nonempty := Finset.card_pos.mp (by omega)
    obtain ⟨j, hj, hjmax⟩ := Finset.exists_max_image strictLower z hnonempty
    have hjlt : z j < z k := (Finset.mem_filter.mp hj).2
    have heq : lower j = strictLower := by
      ext i
      simp only [lower, strictLower, Finset.mem_filter, Finset.mem_univ, true_and]
      constructor
      · intro hi
        exact lt_of_le_of_lt hi hjlt
      · intro hi
        exact hjmax i (Finset.mem_filter.mpr ⟨Finset.mem_univ i, hi⟩)
    have hjgood : j ∈ good := by
      simp only [good, Finset.mem_filter, Finset.mem_univ, true_and]
      rw [heq]
      exact hlarge
    exact (not_lt_of_ge (hkmin j hjgood)) hjlt
  have hpartition : strictLower.card +
      (Finset.univ.filter (fun i => z k ≤ z i)).card = Fintype.card ι := by
    simpa only [strictLower, not_lt, Finset.card_univ] using
      (Finset.card_filter_add_card_filter_not (s := (Finset.univ : Finset ι))
        (fun i => z i < z k))
  refine ⟨k, hklower, ?_⟩
  omega

/-- A positive finite family admits a positive median with both half-cardinality
properties, including when several coordinates coincide. -/
theorem exists_positive_finite_median (z : ι → ℝ) (hz : ∀ i, 0 < z i) :
    ∃ m : ℝ, 0 < m ∧
      Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => z i ≤ m)).card ∧
      Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => m ≤ z i)).card := by
  obtain ⟨k, hlower, hupper⟩ := finite_median_index z
  exact ⟨z k, hz k, hlower, hupper⟩

end Paulsen
