import NeuralGeneralization.OnlineLowerFamilyRetainedStability
import NeuralGeneralization.OnlineLowerReluFamilyParameters
import NeuralGeneralization.OnlineLowerNetworkActivation

/-! # Unconditional network Fourier control for the concrete ReLU family -/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu.Family
open OnlineLower OnlineLowerGeometry ConcreteModel


/-- Actual shallow-network bounds for the explicit ReLU lower-bound family.
All neuron analytic hypotheses are discharged by the full and retained rail
atom theorems; the budget is the model's weighted Gaussian energy. -/
theorem network_bounds (R k : ℕ) (hR : 36 ≤ R) (heven : Even R)
    (N : ℕ) (hN : 0 < N) (net : Weights (railDimension (size R k)) N 0) :
    weightedWalshCost (weight R k)
      ((physicalCode R k (by omega)).logicalProjection
        (networkOutput (fun z : ℝ => max 0 z) net)) ≤ networkVariationBudget net ∧
    uniformCubeMean (fun x =>
      (networkOutput (fun z : ℝ => max 0 z) net x -
        fourierProject (railDownwardSupports (size R k) (column k))
          (networkOutput (fun z : ℝ => max 0 z) net) x) ^ 2) ≤
      stabilityBudget R k * networkVariationBudget net *
        (networkVariationBudget net - weightedWalshCost (weight R k)
          ((physicalCode R k (by omega)).logicalProjection
            (networkOutput (fun z : ℝ => max 0 z) net))) := by
  have hd : 0 < railDimension (size R k) := by
    rw [physicalDimension_eq, pairDim_eq]
    positivity
  have hK : 0 ≤ stabilityBudget R k := by
    unfold stabilityBudget
    positivity
  have h := actual_network_fourier_deficit hd hN (targetSupport R k) (weight R k)
    (fun s => (weight_pos R k (by omega) heven s).le)
    (railDownwardSupports (size R k) (column k)) (fun z : ℝ => max 0 z) net
    (stabilityBudget R k) hK
    (actual_row_retained_norm R k hR heven net)
    (fun j => by simpa only [stabilityBudget] using
      actual_row_retained_stability R k hR heven net j)
  have hcost : retainedFourierMass (targetSupport R k) (weight R k)
      (networkOutput (fun z : ℝ => max 0 z) net) =
      weightedWalshCost (weight R k)
        ((physicalCode R k (by omega)).logicalProjection
          (networkOutput (fun z : ℝ => max 0 z) net)) :=
    retainedFourierMass_eq_logicalCost (physicalCode R k (by omega)) (weight R k) _
  simpa only [hcost] using h

end NeuralGeneralization.OnlineLowerRelu.Family
