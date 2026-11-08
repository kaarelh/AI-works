import NeuralGeneralization.OnlineLowerGeometryPhysicalVariance
import NeuralGeneralization.OnlineLowerGeometryReluFourier

/-! # From the analytic downward-space deficit to the rounding variance budget -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry
open OnlineLowerRelu

/-- The analytic deficit and the explicit calibrated observability bound
supply the physical variance input used by the exact minimum theorem. -/
theorem relu_variance_budget_of_downward_deficit {p m : ℕ}
    (size : Fin p → Bool → ℕ) (column : Fin p → Finset (Fin m))
    (hsize : ∀ i b, 0 < size i b)
    (C : WalshCodeMap (railDimension size) m)
    (hsupport : ∀ s, C.support s = generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s)
    (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m) (v : ClippingCube m)
    (hv : v ∉ H.carrier) (hcard : 2 ≤ (H.differenceAnnihilator v).card)
    (hw0 : 0 < w ∅) (hw : ∀ s, w ∅ ≤ w s)
    (hsum : 6 * w ∅ ≤ ∑ s, w s)
    (hcostsign : ∀ z, z ≠ cubeOne m → walshExpansion w z ≤ 0)
    (hdetect : ∀ i, logicalColumnPoint column i ∉ H.carrier)
    (F : ClippingCube (railDimension size) → ℝ) (B L K Bcap : ℝ)
    (hB : 0 ≤ B) (hL : 0 ≤ L) (hK : 0 ≤ K) (hcap : ∀ x, |F x| ≤ L)
    (hcal : ∀ x, cubeTranslation v (C.syndrome x) ∉ H.carrier →
      (1 : ℝ) / 2 ≤ (if C.syndrome x = cubeOne m then 1 else -1) * (C.base x * F x))
    (hcost : weightedWalshCost w (C.logicalProjection F) ≤ B)
    (hbudget : B ≤ Bcap)
    (hdownward : uniformCubeMean (fun x =>
      (F x - fourierProject (railDownwardSupports size column) F x) ^ 2) ≤
        K * B * (B - weightedWalshCost w (C.logicalProjection F))) :
    uniformCubeMean (fun x => (F x - C.project F x) ^ 2) ≤
      (8 * L / w ∅ + 5 * K * Bcap) *
        (reluDualDeficit w H v (C.logicalProjection F) B +
          reluCalibrationSlack w H v (C.logicalProjection F)) := by
  let D := reluDualDeficit w H v (C.logicalProjection F) B
  let S := reluCalibrationSlack w H v (C.logicalProjection F)
  let mass := weightedWalshCost w (C.logicalProjection F)
  have hdual := walsh_dual_bound w (C.logicalProjection F) (reluDualScore w H v) (fun s => by
    rw [reluDualScore, walshCoefficients_expansion]
    exact reluDual_coefficients_feasible w H v hw0.le hw hcard s)
  have hgap : B - mass ≤ D := by dsimp [D, reluDualDeficit, mass]; linarith
  have hD : 0 ≤ D := le_trans (sub_nonneg.mpr hcost) hgap
  obtain ⟨hanchor, hnegative⟩ := C.relu_projection_calibration_margins H v hv F hcal
  have hS : 0 ≤ S := reluCalibrationSlack_nonneg w H v hv (by omega) hw0.le
    hsum hcostsign (C.logicalProjection F) hanchor hnegative
  have hdown : uniformCubeMean (fun x =>
      (F x - fourierProject (railDownwardSupports size column) F x) ^ 2) ≤
        K * Bcap * D := by
    calc
      _ ≤ K * B * (B - mass) := hdownward
      _ ≤ K * B * D := mul_le_mul_of_nonneg_left hgap (mul_nonneg hK hB)
      _ ≤ _ := by
        have hh := mul_le_mul_of_nonneg_left hbudget (mul_nonneg hK hD)
        nlinarith
  have hvar := actual_rail_relu_variance size column hsize C hsupport w H v hv
    (by omega) hw0 hsum hcostsign hdetect F L hL hcap hcal
  change uniformCubeMean (fun x => (F x - C.project F x) ^ 2) ≤
    (8 * L / w ∅) * S + 5 * uniformCubeMean (fun x =>
      (F x - fourierProject (railDownwardSupports size column) F x) ^ 2) at hvar
  have hBcap : 0 ≤ Bcap := hB.trans hbudget
  have hcross1 : 0 ≤ (8 * L / w ∅) * D := by positivity
  have hcross2 : 0 ≤ (5 * K * Bcap) * S := by positivity
  change uniformCubeMean (fun x => (F x - C.project F x) ^ 2) ≤
    (8 * L / w ∅ + 5 * K * Bcap) * (D + S)
  nlinarith

end NeuralGeneralization.OnlineLowerGeometry
