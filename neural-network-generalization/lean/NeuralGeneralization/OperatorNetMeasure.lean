import NeuralGeneralization.OperatorNet
import Mathlib.MeasureTheory.Measure.Real

/-!
# Operator tail reduced to a finite union of scalar events

This is a measure inequality for the actual operator-valued random variable;
the scalar probabilities on its right are not replaced by assumed tails.
-/

noncomputable section

namespace NeuralGeneralization

open MeasureTheory
open scoped RealInnerProductSpace BigOperators

variable {Ω E F : Type*} [MeasurableSpace Ω]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [NormedAddCommGroup F] [InnerProductSpace ℝ F]

theorem operator_tail_le_quarter_net_sum (μ : Measure Ω) [IsFiniteMeasure μ]
    (s : Finset E) (t : Finset F)
    (hsunit : ∀ x ∈ s, ‖x‖ ≤ 1)
    (hscover : ∀ x : E, ‖x‖ ≤ 1 → ∃ y ∈ s, dist x y ≤ (1 / 4 : ℝ))
    (htcover : ∀ x : F, ‖x‖ ≤ 1 → ∃ y ∈ t, dist x y ≤ (1 / 4 : ℝ))
    (A : Ω → E →L[ℝ] F) (u : ℝ) (hu : 0 ≤ u) :
    μ.real {z | 2 * u < ‖A z‖} ≤
      ∑ xy ∈ s ×ˢ t, μ.real {z | u ≤ |⟪A z xy.1, xy.2⟫|} := by
  classical
  let event : E × F → Set Ω := fun xy => {z | u ≤ |⟪A z xy.1, xy.2⟫|}
  have hsubset : {z | 2 * u < ‖A z‖} ⊆ ⋃ xy ∈ s ×ˢ t, event xy := by
    intro z hz
    by_contra hnot
    have hnet : ∀ x ∈ s, ∀ y ∈ t, |⟪A z x, y⟫| ≤ u := by
      intro x hx y hy
      by_contra hn
      apply hnot
      apply Set.mem_iUnion₂.mpr
      exact ⟨(x, y), Finset.mem_product.mpr ⟨hx, hy⟩, le_of_lt (lt_of_not_ge hn)⟩
    exact (not_le_of_gt hz)
      (operator_norm_le_two_of_quarter_nets s t hsunit hscover htcover (A z) u hu hnet)
  exact (measureReal_mono hsubset (measure_ne_top μ _)).trans
    (measureReal_biUnion_finset_le _ _)

end NeuralGeneralization
