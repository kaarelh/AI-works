import Mathlib.Topology.Order.Compact
import Mathlib.Topology.Algebra.Ring.Real
import Mathlib.Tactic.Linarith

/-!
# A strict output-space cost gap

Compactness converts the minimum-score classification into a positive gap
on correctly predicting scores.  Uniqueness of a parameter realization
is neither stated nor used.  Applying this lemma to neural networks still
requires the concrete compact score-pair constraints and the separately
proved atomic and calibration inequalities.
-/

noncomputable section
open scoped Classical

namespace NeuralGeneralization.OnlineLowerGeometry

/-- The correct closed region is uniformly separated in cost from the
minimum, including the case that this region is empty. -/
theorem compact_correct_cost_gap {X : Type*} [TopologicalSpace X]
    (K C : Set X) (cost : X → ℝ) (cstar : ℝ)
    (hK : IsCompact K) (hC : IsClosed C) (hcost : ContinuousOn cost K)
    (hmin : ∀ x ∈ K, cstar ≤ cost x)
    (hwrong : ∀ x ∈ K, cost x = cstar → x ∉ C) :
    ∃ δ : ℝ, 0 < δ ∧ ∀ x ∈ K, x ∈ C → cstar + δ ≤ cost x := by
  by_cases hne : (K ∩ C).Nonempty
  · obtain ⟨xmin, hxmin, hxmin_le⟩ :=
      (hK.inter_right hC).exists_isMinOn hne (hcost.mono Set.inter_subset_left)
    have hstrict : cstar < cost xmin := by
      refine lt_of_le_of_ne (hmin xmin hxmin.1) ?_
      intro heq
      exact hwrong xmin hxmin.1 heq.symm hxmin.2
    refine ⟨cost xmin - cstar, sub_pos.mpr hstrict, ?_⟩
    intro x hx hCx
    have h := hxmin_le ⟨hx, hCx⟩
    change cost xmin ≤ cost x at h
    linarith
  · refine ⟨1, by norm_num, ?_⟩
    intro x hx hCx
    exact False.elim (hne ⟨x, hx, hCx⟩)

/-- The specialization used in the manuscripts: a pair consists of its
cost and its entire finite-cube score.  Only the minimizing score must be
unique; no network parameterization occurs in the statement. -/
theorem compact_score_pair_gap {I : Type*}
    (K : Set (ℝ × (I → ℝ))) (cstar a label : ℝ) (Fstar : I → ℝ) (x : I)
    (hK : IsCompact K)
    (hmin : ∀ p ∈ K, cstar ≤ p.1)
    (hclass : ∀ p ∈ K, p.1 = cstar → p.2 = Fstar)
    (hwrong : label * Fstar x < a) :
    ∃ δ : ℝ, 0 < δ ∧ ∀ p ∈ K,
      a ≤ label * p.2 x → cstar + δ ≤ p.1 := by
  let C : Set (ℝ × (I → ℝ)) := {p | a ≤ label * p.2 x}
  have heval : Continuous (fun p : ℝ × (I → ℝ) => p.2 x) :=
    (continuous_apply x).comp continuous_snd
  have hcont : Continuous (fun p : ℝ × (I → ℝ) => label * p.2 x) :=
    continuous_const.mul heval
  have hC : IsClosed C := isClosed_le continuous_const hcont
  apply compact_correct_cost_gap K C Prod.fst cstar hK hC continuous_fst.continuousOn hmin
  intro p hp heq hcorrect
  have hscore := hclass p hp heq
  change a ≤ label * p.2 x at hcorrect
  rw [hscore] at hcorrect
  exact (not_le_of_gt hwrong) hcorrect

/-- A finite cost cap does not weaken the gap: larger-cost representations
are already separated by the cap itself. -/
theorem extend_capped_cost_gap {X : Type*}
    (feasible correct : X → Prop) (cost : X → ℝ)
    (cstar cap δ : ℝ) (hcap : cstar < cap) (hδ : 0 < δ)
    (hgap : ∀ x, feasible x → correct x → cost x ≤ cap → cstar + δ ≤ cost x) :
    ∃ ε : ℝ, 0 < ε ∧ ∀ x, feasible x → correct x → cstar + ε ≤ cost x := by
  refine ⟨min δ (cap - cstar), lt_min hδ (sub_pos.mpr hcap), ?_⟩
  intro x hx hc
  by_cases hbelow : cost x ≤ cap
  · have h := hgap x hx hc hbelow
    have hmin := min_le_left δ (cap - cstar)
    linarith
  · have hmin := min_le_right δ (cap - cstar)
    linarith

end NeuralGeneralization.OnlineLowerGeometry
