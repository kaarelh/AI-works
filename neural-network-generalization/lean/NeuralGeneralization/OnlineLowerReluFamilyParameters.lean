import NeuralGeneralization.OnlineLowerGeometryReluMinimum
import NeuralGeneralization.OnlineLowerRoundingConstants
import NeuralGeneralization.OnlineLowerFamilyCostGeometry
import NeuralGeneralization.OnlineLowerReluConcreteStatement

/-! # All scalar and quantitative parameters of the concrete ReLU family -/

noncomputable section
open scoped BigOperators Topology
open Filter

namespace NeuralGeneralization.OnlineLowerRelu.Family
open OnlineLower OnlineLowerGeometry OnlineLowerBernstein

def stabilityBudget (R k : ℕ) : ℝ := 2 ^ 16 * (pairDim k : ℝ) ^ 2 * (R : ℝ) ^ 4

def scoreScale (R k : ℕ) : ℝ := 2 * Real.sqrt (railDimension (size R k) : ℝ)

def normalizedCap (R k : ℕ) : ℝ := 10 * (pairDim k : ℝ) * R

def varianceBudget (R k : ℕ) : ℝ :=
  8 * (scoreScale R k * normalizedCap R k) / weight R k ∅ +
    5 * stabilityBudget R k * normalizedCap R k

def tailBudget (R k : ℕ) : ℝ := reluPrefixEnvelope R reluCostSlope k

theorem scoreScale_pos (R k : ℕ) (hR : 0 < R) : 0 < scoreScale R k := by
  have hd : 0 < railDimension (size R k) := by rw [physicalDimension_eq]; positivity
  exact mul_pos (by norm_num) (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hd))

theorem scoreScale_le (R k : ℕ) (hR : 2 ≤ R) :
    scoreScale R k ≤ 4 * (pairDim k : ℝ) * R := by
  have hp : (1 : ℝ) ≤ pairDim k := by exact_mod_cast (show 1 ≤ pairDim k by rw [pairDim_eq]; omega)
  have hRr : (2 : ℝ) ≤ R := by exact_mod_cast hR
  apply rail_score_scale_bound (pairDim k) R (railDimension (size R k)) hp hRr
  · exact Nat.cast_nonneg _
  · rw [physicalDimension_eq]
    push_cast
    have hp0 : (0 : ℝ) ≤ pairDim k := Nat.cast_nonneg _
    nlinarith [mul_nonneg hp0 (by linarith : 0 ≤ (R : ℝ) - 2)]

theorem baseWeight_lower (R k : ℕ) (hR : 2 ≤ R) (heven : Even R) :
    (pairDim k : ℝ) * R ≤ weight R k ∅ := by
  have hh := (weight_card_bounds R k hR heven ∅).1
  rw [targetSupport_empty_card] at hh
  exact_mod_cast hh

theorem normalizedCap_pos (R k : ℕ) (hR : 0 < R) : 0 < normalizedCap R k := by
  have hp : (0 : ℝ) < pairDim k := by exact_mod_cast (show 0 < pairDim k by rw [pairDim_eq]; omega)
  unfold normalizedCap
  positivity

theorem normalizedCap_le_ten_weight (R k : ℕ) (hR : 2 ≤ R) (heven : Even R) :
    normalizedCap R k ≤ 10 * weight R k ∅ := by
  have hh := baseWeight_lower R k hR heven
  unfold normalizedCap
  linarith

theorem exact_rounding_coefficient_bound (R k : ℕ) (hR : 2 ≤ R) (heven : Even R) :
    45 * ((Fintype.card (ClippingCube (logicalDim k)) : ℝ) / (2 * weight R k ∅)) +
      6 * ((Fintype.card (ClippingCube (logicalDim k)) : ℝ) * varianceBudget R k) ≤
        reluRoundingEnvelope R k := by
  have hh := family_exact_rounding_coefficient_bound R k (by exact_mod_cast hR)
    (scoreScale R k) (stabilityBudget R k) (weight R k ∅)
    (scoreScale_pos R k (by omega)).le (scoreScale_le R k hR) (by rfl)
    (baseWeight_lower R k hR heven)
  have hM : (Fintype.card (ClippingCube (logicalDim k)) : ℝ) = 2 ^ logicalDim k := by simp [ClippingCube]
  rw [hM]
  dsimp only [varianceBudget, normalizedCap]
  convert hh using 1 <;> ring

theorem tailBudget_nonneg (R k : ℕ) (hR : 2 ≤ R) : 0 ≤ tailBudget R k := by
  have hp : (1 : ℝ) ≤ pairDim k := by exact_mod_cast (show 1 ≤ pairDim k by rw [pairDim_eq]; omega)
  have hRr : (2 : ℝ) ≤ R := by exact_mod_cast hR
  have hden : 0 ≤ (pairDim k : ℝ) * R - 1 := by nlinarith
  unfold tailBudget reluPrefixEnvelope
  exact mul_nonneg (div_nonneg (mul_nonneg (by norm_num) reluCostSlope_pos.le) hden)
    (pow_nonneg (div_nonneg (by norm_num) (by linarith)) _)

theorem masked_live_cost_bound (R k : ℕ) (hR : 2 ≤ R) (endpoint : Bool)
    (z : ClippingCube (logicalDim k)) :
    |reluLiveCost (weight R k) (calibrationSubgroup k) (referencePoint k endpoint) z| ≤
      tailBudget R k := by
  by_cases hz : cubeTranslation (referencePoint k endpoint) z ∈ (calibrationSubgroup k).carrier
  · simp only [reluLiveCost, if_pos hz]
    exact calibration_weightExpansion_abs_bound R k hR endpoint z hz
  · simp only [reluLiveCost, if_neg hz, abs_zero]
    exact tailBudget_nonneg R k hR

/-- The exact geometric rounding coefficient is absorbed for every
sufficiently large index, with the rail size fixed first. -/
theorem calibration_absorption_eventually (R : ℕ) (hR : 17 ≤ R) (heven : Even R) :
    ∀ᶠ k : ℕ in atTop, tailBudget R k *
      (45 * ((Fintype.card (ClippingCube (logicalDim k)) : ℝ) / (2 * weight R k ∅)) +
        6 * ((Fintype.card (ClippingCube (logicalDim k)) : ℝ) * varianceBudget R k)) < 1 := by
  have hh := relu_prefix_rounding_eventually_small (R : ℝ) reluCostSlope
    (by exact_mod_cast hR) reluCostSlope_pos.le
  filter_upwards [hh] with k hk
  have hbound := mul_le_mul_of_nonneg_left
    (exact_rounding_coefficient_bound R k (by omega) heven)
    (tailBudget_nonneg R k (by omega))
  change tailBudget R k * reluRoundingEnvelope R k < 1 / 2 at hk
  linarith

end NeuralGeneralization.OnlineLowerRelu.Family
