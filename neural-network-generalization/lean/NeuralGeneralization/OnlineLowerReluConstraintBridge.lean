import NeuralGeneralization.OnlineLowerGeometryReluClosed
import NeuralGeneralization.OnlineLowerGeometryReluVarianceBudget
import NeuralGeneralization.OnlineLowerNetworkActivation

/-! # Actual neural outputs satisfy the closed calibrated constraints -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerRelu OnlineLowerGeometry

/-- The whole-network analytic cost and downward deficit, together with
literal observed margins, place the actual cost/output pair in the closed
set used by the compactness argument. No minimum-score conclusion is an
assumption of this bridge. -/
theorem actual_relu_mem_score_constraints {p m N : ℕ}
    (size : Fin p → Bool → ℕ) (column : Fin p → Finset (Fin m))
    (hsize : ∀ i b, 0 < size i b) (hd : 0 < railDimension size) (hN : 0 < N)
    (C : WalshCodeMap (railDimension size) m)
    (hsupport : ∀ s, C.support s = generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s)
    (weight : Finset (Fin m) → ℝ) (H : CubeSubgroup m) (v : ClippingCube m)
    (live : ClippingCube m → Prop)
    (hv : v ∉ H.carrier) (hcard : 2 ≤ (H.differenceAnnihilator v).card)
    (hw0 : 0 < weight ∅) (hw : ∀ s, weight ∅ ≤ weight s)
    (hsum : 6 * weight ∅ ≤ ∑ s, weight s)
    (hcostsign : ∀ z, z ≠ cubeOne m → walshExpansion weight z ≤ 0)
    (hdetect : ∀ i, logicalColumnPoint column i ∉ H.carrier)
    (net : Weights (railDimension size) N 0) (K Bcap : ℝ)
    (hK : 0 ≤ K) (hBcap : 0 ≤ Bcap) (hBcap10 : Bcap ≤ 10 * weight ∅)
    (hmargin : ∀ x, (1 : ℝ) / 2 ≤ |networkOutput (fun t => max 0 t) net x|)
    (hcal : ∀ x, cubeTranslation v (C.syndrome x) ∉ H.carrier →
      (1 : ℝ) / 2 ≤ (if C.syndrome x = cubeOne m then 1 else -1) *
        (C.base x * networkOutput (fun t => max 0 t) net x))
    (hremoved : ∀ z, ¬ live z →
      reluLiveMass H v (C.logicalProjection (networkOutput (fun t => max 0 t) net)) z ≤ 0)
    (hcap : weightedSquaredNorm net ≤ (2 * Real.sqrt (railDimension size : ℝ)) * Bcap)
    (hcost : weightedWalshCost weight (C.logicalProjection (networkOutput (fun t => max 0 t) net)) ≤
      networkVariationBudget net)
    (hdownward : uniformCubeMean (fun x =>
      (networkOutput (fun t => max 0 t) net x - fourierProject (railDownwardSupports size column)
        (networkOutput (fun t => max 0 t) net) x) ^ 2) ≤
      K * networkVariationBudget net *
        (networkVariationBudget net - weightedWalshCost weight
          (C.logicalProjection (networkOutput (fun t => max 0 t) net)))) :
    (weightedSquaredNorm net, networkOutput (fun t => max 0 t) net) ∈
      C.reluScoreConstraints weight H v live (2 * Real.sqrt (railDimension size : ℝ))
        (8 * ((2 * Real.sqrt (railDimension size : ℝ)) * Bcap) / weight ∅ + 5 * K * Bcap) := by
  let scale : ℝ := 2 * Real.sqrt (railDimension size : ℝ)
  have hscale : 0 < scale := mul_pos (by norm_num) (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hd))
  have hB : 0 ≤ networkVariationBudget net :=
    div_nonneg (weightedSquaredNorm_nonneg net) hscale.le
  have hbudget : networkVariationBudget net ≤ Bcap := by
    apply (div_le_iff₀ hscale).mpr
    simpa only [mul_comm] using hcap
  have hL : 0 ≤ scale * Bcap := mul_nonneg hscale.le hBcap
  have hscore : ∀ x, |networkOutput (fun t => max 0 t) net x| ≤ scale * Bcap := by
    intro x
    exact (networkOutput_abs_le_weightedSquaredNorm hd hN (fun t => max 0 t)
      (fun t => by rw [abs_of_nonneg (le_max_left _ _)]; exact max_le (abs_nonneg _) (le_abs_self _))
      net x).trans hcap
  have hvariance := relu_variance_budget_of_downward_deficit size column hsize C hsupport
    weight H v hv hcard hw0 hw hsum hcostsign hdetect
    (networkOutput (fun t => max 0 t) net) (networkVariationBudget net) (scale * Bcap) K Bcap
    hB hL hK hscore hcal hcost hbudget hdownward
  refine ⟨hmargin, hcal, hcost, ?_, hremoved, hvariance⟩
  apply (div_le_iff₀ hw0).mpr
  exact hbudget.trans hBcap10

end NeuralGeneralization.OnlineLower
