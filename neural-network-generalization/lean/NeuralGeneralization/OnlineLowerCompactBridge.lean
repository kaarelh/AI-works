import NeuralGeneralization.OnlineLowerScoreBound
import NeuralGeneralization.OnlineLowerGeometryCompact

/-!
# A uniform actual-neural cost gap from closed score constraints

The deterministic code argument produces closed constraints on cost and the
entire finite-cube score and classifies every minimum-cost score. This module
combines those inputs with the concrete width-independent score box. The
result applies to all actual neural parameters at all positive widths.
It is a compactness reduction, not an assumed online construction.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower
open ConcreteModel

/-- Closed global-margin and revealed-label constraints used for lower bounds.
The Gaussian posterior itself still uses the original strict constraints. -/
def ClosedOnlineFeasible {d n N : ℕ} (φ : ℝ → ℝ)
    (f : BooleanFunction d) (sample : Fin n → Cube d) (w : Weights d N 0) : Prop :=
  (∀ x, (1 / 2 : ℝ) ≤ |networkOutput φ w x|) ∧
    ∀ i, (1 / 2 : ℝ) ≤ labelReal (f (sample i)) * networkOutput φ w (sample i)

/-- Closed score-pair constraints and unique minimum output imply a uniform
positive cost separation from every correctly predicting feasible network. -/
theorem uniform_neural_cost_gap_of_closed_constraints
    {d n : ℕ} (hd : 0 < d) (φ : ℝ → ℝ) (hφ : ∀ t, |φ t| ≤ |t|)
    (f : BooleanFunction d) (sample : Fin n → Cube d) (x : Cube d)
    (constraints : Set (ℝ × (Cube d → ℝ))) (hclosed : IsClosed constraints)
    (cstar cap : ℝ) (hcap : cstar < cap) (Fstar : Cube d → ℝ)
    (hactual : ∀ N : ℕ, 0 < N → ∀ w : Weights d N 0,
      ClosedOnlineFeasible φ f sample w → weightedSquaredNorm w ≤ cap →
        (weightedSquaredNorm w, networkOutput φ w) ∈ constraints)
    (hmin : ∀ p ∈ scorePairBox d cap ∩ constraints, cstar ≤ p.1)
    (hclass : ∀ p ∈ scorePairBox d cap ∩ constraints, p.1 = cstar → p.2 = Fstar)
    (hwrong : labelReal (f x) * Fstar x < (1 / 2 : ℝ)) :
    ∃ δ : ℝ, 0 < δ ∧ ∀ N : ℕ, 0 < N → ∀ w : Weights d N 0,
      ClosedOnlineFeasible φ f sample w →
      (1 / 2 : ℝ) ≤ labelReal (f x) * networkOutput φ w x →
        cstar + δ ≤ weightedSquaredNorm w := by
  have hcompact : IsCompact (scorePairBox d cap ∩ constraints) :=
    (isCompact_scorePairBox d cap).inter_right hclosed
  obtain ⟨δ, hδ, hgap⟩ := OnlineLowerGeometry.compact_score_pair_gap
    (scorePairBox d cap ∩ constraints) cstar (1 / 2) (labelReal (f x)) Fstar x
    hcompact hmin hclass hwrong
  refine ⟨min δ (cap - cstar), lt_min hδ (sub_pos.mpr hcap), ?_⟩
  intro N hN w hw hcorrect
  by_cases hbelow : weightedSquaredNorm w ≤ cap
  · have hp : (weightedSquaredNorm w, networkOutput φ w) ∈
        scorePairBox d cap ∩ constraints :=
      ⟨actual_score_pair_mem_box hd hN φ hφ w cap hbelow,
        hactual N hN w hw hbelow⟩
    have h := hgap _ hp hcorrect
    have hm := min_le_left δ (cap - cstar)
    linarith
  · have hm := min_le_right δ (cap - cstar)
    linarith

end NeuralGeneralization.OnlineLower
