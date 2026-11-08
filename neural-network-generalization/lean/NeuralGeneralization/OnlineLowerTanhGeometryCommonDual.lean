import NeuralGeneralization.OnlineLowerTanhGeometryDualValues

/-!
# The canonical rectangle dual from explicit scalar cost inequalities

`RectangleCostConditions` contains only inequalities for the actual finite
weight transform. It does not postulate a dual, a score minimum, physical
calibration, or a neural norm theorem. The scalar tanh construction must
establish these conditions before this module is applied.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

def rectangleWeightTransform {m : ℕ} (w : Finset (Fin m) → ℝ) (z : ClippingCube m) : ℝ :=
  walshExpansion w z / Fintype.card (ClippingCube m)

structure RectangleCostConditions {m : ℕ} (w : Finset (Fin m) → ℝ)
    (u : ClippingCube m) : Prop where
  card_ge : 64 ≤ Fintype.card (ClippingCube m)
  weight_pos : 0 < w ∅
  weight_min : ∀ s, w ∅ ≤ w s
  distinguished_pos : 0 < rectangleWeightTransform w u
  distinguished_small : rectangleWeightTransform w u ≤ w ∅ / 16
  paired_small : rectanglePairedTotal w u ≤ rectangleWeightTransform w u / 4
  distinguished_scale : 16 * w ∅ ≤ walshExpansion w u

def rectangleCommonH {m : ℕ} (w : Finset (Fin m) → ℝ) (u : ClippingCube m) : ℝ :=
  commonDualH ((Fintype.card (ClippingCube m) : ℝ) / 2) (w ∅)
    (rectangleWeightTransform w u) (rectanglePairedTotal w u)

def rectangleCommonA {m : ℕ} (w : Finset (Fin m) → ℝ) (u : ClippingCube m) : ℝ :=
  commonDualA ((Fintype.card (ClippingCube m) : ℝ) / 2) (w ∅)
    (rectangleCommonH w u) (rectanglePairedTotal w u)

def rectangleCommonC {m : ℕ} (w : Finset (Fin m) → ℝ) (u : ClippingCube m) : ℝ :=
  commonDualC ((Fintype.card (ClippingCube m) : ℝ) / 2)
    (rectangleCommonH w u) (rectanglePairedTotal w u)

def rectangleCommonDualCoefficients {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) : Finset (Fin m) → ℝ :=
  rectangleDualCoefficients w H v u (rectanglePairedCost w u)
    (rectangleCommonA w u) (rectangleCommonC w u)

def rectangleCommonDual {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) : ClippingCube m → ℝ :=
  walshExpansion (rectangleCommonDualCoefficients w H v u)

namespace RectangleCostConditions
variable {m : ℕ} {w : Finset (Fin m) → ℝ} {u : ClippingCube m}
    (h : RectangleCostConditions w u)
include h

theorem parameter_bounds :
    7 * w ∅ / 4 ≤ rectangleCommonA w u ∧ rectangleCommonA w u ≤ 2 * w ∅ ∧
      0 < rectangleCommonA w u ∧
      rectangleCommonA w u + rectangleCommonC w u + 2 * rectanglePairedTotal w u = 2 * w ∅ ∧
      rectangleCommonC w u + 2 * rectanglePairedTotal w u ≤ w ∅ / 4 ∧
      rectangleWeightTransform w u ≤ rectangleCommonC w u - 2 * rectanglePairedTotal w u ∧
      rectangleCommonC w u * ((Fintype.card (ClippingCube m) : ℝ) / 2) +
        2 * rectangleCommonA w u = walshExpansion w u := by
  have hM : (Fintype.card (ClippingCube m) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  have hs : 16 * w ∅ ≤ (Fintype.card (ClippingCube m) : ℝ) * rectangleWeightTransform w u := by
    simpa only [rectangleWeightTransform, mul_div_cancel₀ _ hM] using h.distinguished_scale
  have hp := rectangle_parameter_bounds (Fintype.card (ClippingCube m)) (w ∅)
    (rectangleWeightTransform w u) (rectanglePairedTotal w u)
    (by exact_mod_cast h.card_ge) h.weight_pos h.distinguished_pos h.distinguished_small
    (rectanglePairedTotal_nonneg w u) h.paired_small hs
  simpa only [rectangleCommonA, rectangleCommonC, rectangleCommonH,
    rectangleWeightTransform, mul_div_cancel₀ _ hM] using hp

theorem coefficients_feasible (H : CubeSubgroup m) (v : ClippingCube m)
    (hu : u ∈ H.carrier) (hE : 2 ≤ (H.differenceAnnihilator v).card)
    (s : Finset (Fin m)) : |rectangleCommonDualCoefficients w H v u s| ≤ w s := by
  obtain ⟨_, _, ha, htotal, hb, hlower, _⟩ := h.parameter_bounds
  exact rectangleDual_coefficients_feasible w H v u (rectanglePairedCost w u)
    (rectangleCommonA w u) (rectangleCommonC w u) (rectanglePairedTotal w u)
    (rectangleWeightTransform w u) hu (rectanglePairedCost_nonneg w u)
    (rectanglePairedCost_invariant w u) (rectanglePairedCost_sum w u)
    h.weight_pos.le h.weight_min ha.le h.distinguished_pos.le htotal hb hlower
    h.distinguished_small hE s

theorem invariant_coefficient_slack (H : CubeSubgroup m) (v : ClippingCube m)
    (hE : 2 ≤ (H.differenceAnnihilator v).card)
    (s : Finset (Fin m)) (hs : s ≠ ∅) (heven : walshCharacter s u = 1) :
    rectangleWeightTransform w u ≤ w s - |rectangleCommonDualCoefficients w H v u s| := by
  obtain ⟨_, _, ha, htotal, hb, hlower, _⟩ := h.parameter_bounds
  obtain ⟨hlo, hhi⟩ := rectangleDual_coefficient_even_slack w H v u (rectanglePairedCost w u)
    (rectangleCommonA w u) (rectangleCommonC w u) (rectanglePairedTotal w u)
    (rectangleWeightTransform w u) (rectanglePairedCost_nonneg w u)
    (rectanglePairedCost_sum w u) h.weight_min ha.le htotal hb hlower
    h.distinguished_small hE s hs heven
  change rectangleWeightTransform w u ≤ w s + rectangleCommonDualCoefficients w H v u s at hhi
  by_cases hc : 0 ≤ rectangleCommonDualCoefficients w H v u s
  · rw [abs_of_nonneg hc]
    exact hlo
  · rw [abs_of_neg (lt_of_not_ge hc)]
    linarith

theorem coefficient_empty (H : CubeSubgroup m) (v : ClippingCube m) :
    rectangleCommonDualCoefficients w H v u ∅ = -w ∅ := by
  obtain ⟨_, _, _, htotal, _, _, _⟩ := h.parameter_bounds
  exact rectangleDual_coefficient_empty w H v u (rectanglePairedCost w u)
    (rectangleCommonA w u) (rectangleCommonC w u) (rectanglePairedTotal w u)
    (rectanglePairedCost_sum w u) htotal

theorem coefficient_odd (H : CubeSubgroup m) (v : ClippingCube m) (hu : u ∈ H.carrier)
    (s : Finset (Fin m)) (hs : walshCharacter s u ≠ 1) :
    rectangleCommonDualCoefficients w H v u s = w s :=
  rectangleDual_coefficient_odd w H v u (rectanglePairedCost w u)
    (rectangleCommonA w u) (rectangleCommonC w u) hu
    (rectanglePairedCost_invariant w u) s hs

theorem positive_anchor (H : CubeSubgroup m) (v : ClippingCube m)
    (hv : v ∉ H.carrier) (hu0 : u ≠ cubeOne m)
    (hE : 0 < (H.differenceAnnihilator v).card) :
    rectangleCommonA w u ≤ rectangleCommonDual w H v u (cubeOne m) := by
  obtain ⟨_, ha, _, _, _, _, hcancel⟩ := h.parameter_bounds
  exact rectangleDualScore_positive_anchor w H v u (rectangleCommonA w u) (rectangleCommonC w u)
    hv hu0 hE hcancel ((by norm_num : (4 : ℕ) ≤ 64).trans h.card_ge)
    h.weight_pos.le h.weight_min ha h.distinguished_small

end RectangleCostConditions
end NeuralGeneralization.OnlineLowerGeometry
