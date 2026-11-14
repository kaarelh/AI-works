import NeuralGeneralization.OnlineLowerReluFamilyParameters

/-! # The softplus output offset is absorbed with the same fixed physical rails -/
noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerSoftplus
open OnlineLower OnlineLowerGeometry OnlineLowerRelu OnlineLowerBernstein
namespace Family
open OnlineLowerRelu.Family

def varianceBudget (R k : ℕ) : ℝ :=
  16*(scoreScale R k*normalizedCap R k)/weight R k ∅+
    5*stabilityBudget R k*normalizedCap R k

lemma varianceBudget_le_twice (R k : ℕ) (hR : 0<R) :
    varianceBudget R k≤2*OnlineLowerRelu.Family.varianceBudget R k := by
  have hK : 0≤stabilityBudget R k := by unfold stabilityBudget; positivity
  have hB := (normalizedCap_pos R k hR).le
  have he : varianceBudget R k = 2*OnlineLowerRelu.Family.varianceBudget R k-
      5*stabilityBudget R k*normalizedCap R k := by
    unfold varianceBudget OnlineLowerRelu.Family.varianceBudget
    ring
  rw [he]
  nlinarith [mul_nonneg hK hB]

lemma relu_varianceBudget_le (R k : ℕ) (hR : 2 ≤ R) (heven : Even R) :
    OnlineLowerRelu.Family.varianceBudget R k ≤ varianceBudget R k := by
  have hterm : 0 ≤ 8*(scoreScale R k*normalizedCap R k)/weight R k ∅ :=
    div_nonneg (mul_nonneg (by norm_num) (mul_nonneg (scoreScale_pos R k (by omega)).le
      (normalizedCap_pos R k (by omega)).le)) (weight_pos R k hR heven ∅).le
  have he : varianceBudget R k = OnlineLowerRelu.Family.varianceBudget R k+
      8*(scoreScale R k*normalizedCap R k)/weight R k ∅ := by
    unfold varianceBudget OnlineLowerRelu.Family.varianceBudget
    ring
  rw [he]
  linarith

lemma exact_rounding_le_twice (R k : ℕ) (hR : 2≤R) (heven : Even R) :
    45*((Fintype.card (ClippingCube (logicalDim k)):ℝ)/(2*weight R k ∅))+
      6*((Fintype.card (ClippingCube (logicalDim k)):ℝ)*varianceBudget R k) ≤
        2*reluRoundingEnvelope R k := by
  have hb := varianceBudget_le_twice R k (by omega)
  have hM : (0:ℝ)≤Fintype.card (ClippingCube (logicalDim k)) := Nat.cast_nonneg _
  have ha : 0≤45*((Fintype.card (ClippingCube (logicalDim k)):ℝ)/(2*weight R k ∅)) :=
    mul_nonneg (by norm_num) (div_nonneg hM (mul_nonneg (by norm_num) (weight_pos R k hR heven ∅).le))
  have hm := mul_le_mul_of_nonneg_left hb hM
  have ho := OnlineLowerRelu.Family.exact_rounding_coefficient_bound R k hR heven
  nlinarith

lemma calibration_absorption_eventually (R : ℕ) (hR : 17≤R) (heven : Even R) :
    ∀ᶠ k:ℕ in atTop,tailBudget R k*
      (45*((Fintype.card (ClippingCube (logicalDim k)):ℝ)/(2*weight R k ∅))+
        6*((Fintype.card (ClippingCube (logicalDim k)):ℝ)*varianceBudget R k))<1 := by
  have hh := relu_prefix_rounding_eventually_small (R:ℝ) reluCostSlope
    (by exact_mod_cast hR) reluCostSlope_pos.le
  filter_upwards [hh] with k hk
  have hbound := mul_le_mul_of_nonneg_left (exact_rounding_le_twice R k (by omega) heven)
    (tailBudget_nonneg R k (by omega))
  change tailBudget R k*reluRoundingEnvelope R k<1/2 at hk
  nlinarith

lemma energyCap_ge_one (R k : ℕ) (hR : 2≤R) :
    1≤scoreScale R k*normalizedCap R k := by
  have hd : 1≤railDimension (size R k) := by
    apply Nat.succ_le_iff.mpr
    rw [physicalDimension_eq,pairDim_eq]
    positivity
  have hs : 1≤Real.sqrt (railDimension (size R k):ℝ) := Real.one_le_sqrt.mpr (by exact_mod_cast hd)
  have hp : (1:ℝ)≤pairDim k := by exact_mod_cast (show 1≤pairDim k by rw [pairDim_eq]; omega)
  have hr : (2:ℝ)≤R := by exact_mod_cast hR
  have hb : 10≤normalizedCap R k := by unfold normalizedCap; nlinarith
  unfold scoreScale
  nlinarith

end Family
end NeuralGeneralization.OnlineLowerSoftplus
