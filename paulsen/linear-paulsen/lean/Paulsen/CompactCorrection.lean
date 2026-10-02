import Paulsen.Correction
import Paulsen.Projection
import Mathlib.Topology.Instances.Matrix
import Mathlib.Topology.Order.Compact
import Mathlib.Topology.Maps.Proper.Basic
import Mathlib.Topology.Instances.Real.Lemmas
import Mathlib.Topology.Algebra.Ring.Real

/-!
# Compactness of exact frames and closedness of correction bounds

This packages the limiting step without selecting convergent subsequences:
the possible exact corrections form a compact set, so projection of the
closed distance relation is closed.
-/

namespace Paulsen

theorem continuous_rowNormSq {n d : ℕ} (i : Fin n) :
    Continuous (fun U : Frame n d => rowNormSq U i) := by
  unfold rowNormSq
  fun_prop

theorem continuous_sqDistance {n d : ℕ} :
    Continuous (fun p : Frame n d × Frame n d => sqDistance p.1 p.2) := by
  unfold sqDistance
  fun_prop

theorem isClosed_equalNormParseval (n d : ℕ) :
    IsClosed {U : Frame n d | IsEqualNormParseval U} := by
  have hp : IsClosed {U : Frame n d | IsParseval U} :=
    isClosed_eq (by fun_prop)
      continuous_const
  have he : IsClosed {U : Frame n d | IsEqualNorm U} := by
    change IsClosed {U : Frame n d | ∀ i, rowNormSq U i = (d : ℝ) / n}
    have hh : {U : Frame n d | ∀ i, rowNormSq U i = (d : ℝ) / n} =
        ⋂ i, {U : Frame n d | rowNormSq U i = (d : ℝ) / n} := by ext U; simp
    rw [hh]
    exact isClosed_iInter fun i => isClosed_eq (continuous_rowNormSq i) continuous_const
  exact hp.inter he

theorem IsParseval.entry_abs_le_one {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (i : Fin n) (j : Fin d) : |U i j| ≤ 1 := by
  have hentry : U i j ^ 2 ≤ rowNormSq U i :=
    Finset.single_le_sum (fun k _ => sq_nonneg (U i k)) (Finset.mem_univ j)
  have hs : U i j ^ 2 ≤ 1 := hentry.trans (hU.leverage_le_one i)
  exact (sq_le_sq₀ (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1)).mp (by simpa using hs)

theorem isCompact_equalNormParseval (n d : ℕ) :
    IsCompact {U : Frame n d | IsEqualNormParseval U} := by
  apply (isCompact_Icc : IsCompact (Set.Icc (fun _ _ => (-1 : ℝ)) (fun _ _ => (1 : ℝ)))).of_isClosed_subset
    (isClosed_equalNormParseval n d)
  intro U hU
  constructor
  · intro i j
    exact (abs_le.mp (hU.1.entry_abs_le_one i j)).1
  · intro i j
    exact (abs_le.mp (hU.1.entry_abs_le_one i j)).2

set_option maxHeartbeats 1000000 in
/-- The relation between an input frame, a cost, and existence of an exact
correction is closed. This theorem does not assume that corrections exist. -/
theorem isClosed_hasCorrection (n d : ℕ) :
    IsClosed {p : Frame n d × ℝ | HasCorrection p.1 p.2} := by
  let K := {U : Frame n d | IsEqualNormParseval U}
  letI : CompactSpace K := isCompact_iff_compactSpace.mp (isCompact_equalNormParseval n d)
  let S : Set ((Frame n d × ℝ) × K) :=
    {p | sqDistance p.1.1 p.2.val ≤ p.1.2}
  have hS : IsClosed S := by
    change IsClosed {p : (Frame n d × ℝ) × K | sqDistance p.1.1 p.2.val ≤ p.1.2}
    apply isClosed_le
    · have h₁ : Continuous (fun p : (Frame n d × ℝ) × K => p.1.1) :=
        continuous_fst.comp continuous_fst
      have h₂ : Continuous (fun p : (Frame n d × ℝ) × K => p.2.val) :=
        continuous_subtype_val.comp continuous_snd
      exact (continuous_sqDistance (n := n) (d := d)).comp (h₁.prodMk h₂)
    · exact continuous_fst.snd
  have hproj := isClosedMap_fst_of_compactSpace S hS
  have heq : Prod.fst '' S = {p : Frame n d × ℝ | HasCorrection p.1 p.2} := by
    ext p
    constructor
    · rintro ⟨⟨p', W⟩, hW, hp⟩
      change p' = p at hp
      subst p'
      exact ⟨W.val, W.property, hW⟩
    · rintro ⟨W, hW, hdist⟩
      exact ⟨(p, ⟨W, hW⟩), hdist, rfl⟩
  rwa [heq] at hproj

set_option maxHeartbeats 1000000 in
/-- Correction bounds survive limits of both the frame and the cost. -/
theorem hasCorrection_of_tendsto {α : Type*} {l : Filter α} [Filter.NeBot l]
    {n d : ℕ} (U : α → Frame n d) (c : α → ℝ) (U₀ : Frame n d) (c₀ : ℝ)
    (hU : Filter.Tendsto U l (nhds U₀)) (hc : Filter.Tendsto c l (nhds c₀))
    (h : ∀ᶠ t in l, HasCorrection (U t) (c t)) : HasCorrection U₀ c₀ := by
  have ht : Filter.Tendsto (fun t => (U t, c t)) l (nhds (U₀, c₀)) := hU.prodMk_nhds hc
  exact IsClosed.mem_of_tendsto (X := Frame n d × ℝ) (x := (U₀, c₀))
    (f := fun t => (U t, c t)) (isClosed_hasCorrection n d) ht h

end Paulsen
