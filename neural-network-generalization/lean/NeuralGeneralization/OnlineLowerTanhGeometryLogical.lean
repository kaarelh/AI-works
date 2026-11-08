import NeuralGeneralization.OnlineLowerTanhGeometryMass

/-! # Calibrated rectangle geometry from explicit cost conditions

The only scalar inputs are inequalities for the actual finite weight
transform. Every dual, slack, mass and rectangle below is constructed
literally; no minimum-energy or rounding oracle is assumed.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

def rectangleLogicalDualCoefficients {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) : Finset (Fin m) → ℝ :=
  rectangleCommonDualCoefficients w (H.adjoinPoint u) v u

def rectangleLogicalDual {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) : ClippingCube m → ℝ :=
  walshExpansion (rectangleLogicalDualCoefficients w H v u)

def rectangleLogicalDeficit {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (g : ClippingCube m → ℝ) (B : ℝ) : ℝ :=
  fourierDualDeficit (rectangleLogicalDualCoefficients w H v u) g B

def rectangleLogicalSlack {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (g : ClippingCube m → ℝ) : ℝ :=
  rectangleCalibrationSlack (rectangleLogicalDual w H v u) H v u g

def rectangleLogicalErrorBudget {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (g : ClippingCube m → ℝ) (B : ℝ) : ℝ :=
  rectangleLogicalDeficit w H v u g B / rectangleWeightTransform w u +
    rectangleLogicalSlack w H v u g / rectangleCommonA w u

namespace RectangleCostConditions
variable {m : ℕ} {w : Finset (Fin m) → ℝ} {u : ClippingCube m}
    (h : RectangleCostConditions w u)
include h

lemma logical_dual_negative (H : CubeSubgroup m) (v : ClippingCube m)
    (hv : v ∉ (H.adjoinPoint u).carrier)
    (hE : 0 < ((H.adjoinPoint u).differenceAnnihilator v).card)
    (z : ClippingCube m) (hz : z ∈ rectangleNegativeObserved H v u) :
    rectangleLogicalDual w H v u z ≤ -rectangleCommonA w u := by
  exact rectangleDualScore_negative_observed w (H.adjoinPoint u) v u
    (rectangleCommonA w u) (rectangleCommonC w u) hv
    h.parameter_bounds.2.2.1.le hE z hz.2 hz.1.2 hz.1.1

lemma logical_deficit_nonneg (H : CubeSubgroup m) (v : ClippingCube m)
    (hE : 2 ≤ ((H.adjoinPoint u).differenceAnnihilator v).card)
    (g : ClippingCube m → ℝ) (B : ℝ) (hcost : weightedWalshCost w g ≤ B) :
    0 ≤ rectangleLogicalDeficit w H v u g B :=
  fourierDualDeficit_nonneg w (rectangleLogicalDualCoefficients w H v u) g B
    (h.coefficients_feasible (H.adjoinPoint u) v (H.point_mem_adjoinPoint u) hE) hcost

lemma logical_slack_nonneg (H : CubeSubgroup m) (v : ClippingCube m)
    (hu : u ∉ H.carrier) (hv : v ∉ (H.adjoinPoint u).carrier)
    (hE : 0 < ((H.adjoinPoint u).differenceAnnihilator v).card)
    (g : ClippingCube m → ℝ) (hanchor : (1 : ℝ) / 2 ≤ g (cubeOne m))
    (hnegative : ∀ z, cubeTranslation v z ∉ H.carrier → z ≠ cubeOne m →
      g z ≤ -(1 : ℝ) / 2) : 0 ≤ rectangleLogicalSlack w H v u g := by
  have hu0 : u ≠ cubeOne m := fun he => hu (he ▸ H.one_mem)
  exact rectangleCalibrationSlack_nonneg H v u (rectangleLogicalDual w H v u) g
    (rectangleCommonA w u) h.parameter_bounds.2.2.1.le
    (h.positive_anchor (H.adjoinPoint u) v hv hu0 hE)
    (h.logical_dual_negative H v hv hE) hanchor (fun z hz =>
      hnegative z (fun hh => hz.1.1 (H.subset_adjoinPoint u hh)) hz.2)

lemma logical_baseline_pairing (H : CubeSubgroup m) (v : ClippingCube m)
    (hu : u ∉ H.carrier) (hv : v ∉ (H.adjoinPoint u).carrier)
    (hE : 0 < ((H.adjoinPoint u).differenceAnnihilator v).card) :
    uniformCubeMean (fun z => rectangleLogicalDual w H v u z * reluReference z) =
      rectangleBaselineCost w u := by
  have hu0 : u ≠ cubeOne m := fun he => hu (he ▸ H.one_mem)
  have hmean : uniformCubeMean (rectangleLogicalDual w H v u) = -w ∅ := by
    have hh := walshCoefficients_expansion (rectangleLogicalDualCoefficients w H v u) ∅
    simpa only [walshCoefficients, walshCharacter, Finset.prod_empty, mul_one,
      rectangleLogicalDual, rectangleLogicalDualCoefficients,
      h.coefficient_empty] using hh
  have hanchor : rectangleLogicalDual w H v u (cubeOne m) =
      walshExpansion w (cubeOne m) - walshExpansion w u :=
    rectangleDualScore_anchor w (H.adjoinPoint u) v u (rectangleCommonA w u)
      (rectangleCommonC w u) hv hu0 hE h.parameter_bounds.2.2.2.2.2.2
  rw [reference_pairing_formula, hmean, hanchor]
  unfold rectangleBaselineCost
  ring

/-- The exact score decomposition for the canonical common dual. -/
theorem logical_calibrated_decomposition (H : CubeSubgroup m) (v : ClippingCube m)
    (hu : u ∉ H.carrier) (hv : v ∉ (H.adjoinPoint u).carrier)
    (hE : 0 < ((H.adjoinPoint u).differenceAnnihilator v).card)
    (horder : ∀ z, cubeTranslation v z ∈ H.carrier →
      0 ≤ rectangleWeightTransform w z ∧
        rectangleWeightTransform w z ≤ rectangleWeightTransform w (cubeTranslation u z))
    (g : ClippingCube m → ℝ) (B : ℝ) :
    B = rectangleBaselineCost w u + rectangleLogicalDeficit w H v u g B +
      rectangleLogicalSlack w H v u g +
        linearCost (rectangleEffectiveCost w u) (reluLiveMass H v g) := by
  have hu0 : u ≠ cubeOne m := fun he => hu (he ▸ H.one_mem)
  have hM : (Fintype.card (ClippingCube m) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  apply rectangle_calibrated_decomposition H v u hv g
    (rectangleLogicalDualCoefficients w H v u) (rectangleEffectiveCost w u) B
    (rectangleBaselineCost w u) (h.logical_baseline_pairing H v hu hv hE)
  · exact rectangleDualScore_at_shift w (H.adjoinPoint u) v u
      (rectangleCommonA w u) (rectangleCommonC w u) hv
      (H.point_mem_adjoinPoint u) hu0 hE h.parameter_bounds.2.2.2.2.2.2
  · intro z hz
    have hl := rectangleDualScore_live w (H.adjoinPoint u) v u
      (rectangleCommonA w u) (rectangleCommonC w u) hv
      (H.point_mem_adjoinPoint u) hE z (H.subset_adjoinPoint u hz)
      (horder z hz).1 (horder z hz).2
    simpa only [rectangleEffectiveCost, mul_div_cancel₀ _ hM, rectangleLogicalDualCoefficients,
      rectangleCommonDualCoefficients, rectangleDualScore] using hl
  · intro z hz
    exact rectangleDualScore_partner w (H.adjoinPoint u) v u
      (rectangleCommonA w u) (rectangleCommonC w u) hv
      (H.point_mem_adjoinPoint u) hE z (H.subset_adjoinPoint u hz)
      (horder z hz).1 (horder z hz).2

/-- Reconstruction bound for the same actual calibrated score. At zero
cost deficit and zero observed slack it gives literal rectangle equality. -/
theorem logical_reconstruction_bound (H : CubeSubgroup m) (v : ClippingCube m)
    (hu : u ∉ H.carrier) (hv : v ∉ (H.adjoinPoint u).carrier)
    (hE : 2 ≤ ((H.adjoinPoint u).differenceAnnihilator v).card)
    (hdensity : (1 : ℝ) / 2 ≤ uniformCubeMean (fun z =>
      if z ∈ rectangleNegativeObserved H v u then 1 else 0))
    (g : ClippingCube m → ℝ) (B : ℝ) (hcost : weightedWalshCost w g ≤ B)
    (hanchor : (1 : ℝ) / 2 ≤ g (cubeOne m))
    (hnegative : ∀ z, cubeTranslation v z ∉ H.carrier → z ≠ cubeOne m →
      g z ≤ -(1 : ℝ) / 2) :
    uniformCubeMean (fun z =>
      |g z - rectangleMassScore u (reluLiveMass H v g) z|) ≤
        6 * rectangleLogicalErrorBudget w H v u g B := by
  have hEpos : 0 < ((H.adjoinPoint u).differenceAnnihilator v).card := by omega
  have hu0 : u ≠ cubeOne m := fun hh => hu (hh ▸ H.one_mem)
  have ha := h.parameter_bounds.2.2.1
  have hD := h.logical_deficit_nonneg H v hE g B hcost
  have hS := h.logical_slack_nonneg H v hu hv hEpos g hanchor hnegative
  have hδ : 0 ≤ rectangleLogicalErrorBudget w H v u g B :=
    add_nonneg (div_nonneg hD h.distinguished_pos.le) (div_nonneg hS ha.le)
  have hneg : ∀ z, z ∈ rectangleNegativeObserved H v u → g z ≤ -(1 : ℝ) / 2 :=
    fun z hz => hnegative z (fun hh => hz.1.1 (H.subset_adjoinPoint u hh)) hz.2
  have hrem (z : ClippingCube m) : |invariantRemainder u g z| ≤
      rectangleLogicalDeficit w H v u g B / rectangleWeightTransform w u :=
    invariantRemainder_abs_le w (rectangleLogicalDualCoefficients w H v u) u g B
      (rectangleWeightTransform w u) h.distinguished_pos
      (h.coefficients_feasible (H.adjoinPoint u) v (H.point_mem_adjoinPoint u) hE)
      (h.invariant_coefficient_slack (H.adjoinPoint u) v hE) hcost z
  have hsym := rectangle_calibrated_anti_invariance H v u (rectangleLogicalDual w H v u) g
    (rectangleCommonA w u) (rectangleLogicalDeficit w H v u g B / rectangleWeightTransform w u)
    ha (h.positive_anchor (H.adjoinPoint u) v hv hu0 hEpos)
    (h.logical_dual_negative H v hv hEpos) hanchor hneg hdensity hrem
  have hobs : uniformCubeMean (rectangleObservedError H v u g) ≤
      rectangleLogicalSlack w H v u g / rectangleCommonA w u := by
    apply (le_div_iff₀ ha).mpr
    have hh := rectangle_calibration_deviation_bound H v u (rectangleLogicalDual w H v u)
      g (rectangleCommonA w u) (h.positive_anchor (H.adjoinPoint u) v hv hu0 hEpos)
      (h.logical_dual_negative H v hv hEpos) hanchor hneg
    change rectangleCommonA w u * uniformCubeMean (rectangleObservedError H v u g) ≤
      rectangleLogicalSlack w H v u g at hh
    nlinarith only [hh]
  exact rectangleMassScore_mean_error H v u hu hv g
    (rectangleLogicalErrorBudget w H v u g B)
    (rectangleLogicalSlack w H v u g / rectangleCommonA w u) hδ
    (le_add_of_nonneg_left (div_nonneg hD h.distinguished_pos.le)) hsym hobs

/-- Quantitative rounding for the actual calibrated score, derived from
cost feasibility and literal observed margins. -/
theorem logical_calibrated_rounding (H : CubeSubgroup m) (v : ClippingCube m)
    (hu : u ∉ H.carrier) (hv : v ∉ (H.adjoinPoint u).carrier)
    (hE : 2 ≤ ((H.adjoinPoint u).differenceAnnihilator v).card)
    (hdensity : (1 : ℝ) / 2 ≤ uniformCubeMean (fun z =>
      if z ∈ rectangleNegativeObserved H v u then 1 else 0))
    (g : ClippingCube m → ℝ) (B : ℝ) (hcost : weightedWalshCost w g ≤ B)
    (hanchor : (1 : ℝ) / 2 ≤ g (cubeOne m))
    (hnegative : ∀ z, cubeTranslation v z ∉ H.carrier → z ≠ cubeOne m →
      g z ≤ -(1 : ℝ) / 2)
    (e : Finset (Fin m)) (he : e ∈ H.differenceAnnihilator v)
    (heu : walshCharacter e u = -1)
    (live : ClippingCube m → Prop)
    (hremoved : ∀ z, ¬ live z → reluLiveMass H v g z ≤ 0) :
    ∃ q, IsLiveCandidate live q ∧
      l1Distance (reluLiveMass H v g) q ≤
        44 * Fintype.card (ClippingCube m) * rectangleLogicalErrorBudget w H v u g B +
          4 * ∑ z, fractionalPenalty (reluLiveMass H v g z) := by
  have hEpos : 0 < ((H.adjoinPoint u).differenceAnnihilator v).card := by omega
  have hu0 : u ≠ cubeOne m := fun hh => hu (hh ▸ H.one_mem)
  have ha := h.parameter_bounds.2.2.1
  have hD := h.logical_deficit_nonneg H v hE g B hcost
  have hS := h.logical_slack_nonneg H v hu hv hEpos g hanchor hnegative
  have hδ : 0 ≤ rectangleLogicalErrorBudget w H v u g B :=
    add_nonneg (div_nonneg hD h.distinguished_pos.le) (div_nonneg hS ha.le)
  have hneg : ∀ z, z ∈ rectangleNegativeObserved H v u → g z ≤ -(1 : ℝ) / 2 :=
    fun z hz => hnegative z (fun hh => hz.1.1 (H.subset_adjoinPoint u hh)) hz.2
  have hrem (z : ClippingCube m) : |invariantRemainder u g z| ≤
      rectangleLogicalDeficit w H v u g B / rectangleWeightTransform w u :=
    invariantRemainder_abs_le w (rectangleLogicalDualCoefficients w H v u) u g B
      (rectangleWeightTransform w u) h.distinguished_pos
      (h.coefficients_feasible (H.adjoinPoint u) v (H.point_mem_adjoinPoint u) hE)
      (h.invariant_coefficient_slack (H.adjoinPoint u) v hE) hcost z
  have hsym := rectangle_calibrated_anti_invariance H v u (rectangleLogicalDual w H v u) g
    (rectangleCommonA w u) (rectangleLogicalDeficit w H v u g B / rectangleWeightTransform w u)
    ha (h.positive_anchor (H.adjoinPoint u) v hv hu0 hEpos)
    (h.logical_dual_negative H v hv hEpos) hanchor hneg hdensity hrem
  have hobs : uniformCubeMean (rectangleObservedError H v u g) ≤
      rectangleLogicalSlack w H v u g / rectangleCommonA w u := by
    apply (le_div_iff₀ ha).mpr
    have hh := rectangle_calibration_deviation_bound H v u (rectangleLogicalDual w H v u)
      g (rectangleCommonA w u) (h.positive_anchor (H.adjoinPoint u) v hv hu0 hEpos)
      (h.logical_dual_negative H v hv hEpos) hanchor hneg
    change rectangleCommonA w u * uniformCubeMean (rectangleObservedError H v u g) ≤
      rectangleLogicalSlack w H v u g at hh
    nlinarith only [hh]
  have hcoef := saturated_coefficient_lower w (rectangleLogicalDualCoefficients w H v u)
    g B (w ∅) h.weight_pos h.weight_min
    (h.coefficients_feasible (H.adjoinPoint u) v (H.point_mem_adjoinPoint u) hE) hcost e
    (h.coefficient_odd (H.adjoinPoint u) v (H.point_mem_adjoinPoint u) e (by rw [heu]; norm_num))
  have hratio : rectangleLogicalDeficit w H v u g B / (2 * w ∅) ≤
      rectangleLogicalDeficit w H v u g B / rectangleWeightTransform w u := by
    apply div_le_div_of_nonneg_left hD h.distinguished_pos
    linarith [h.distinguished_small, h.weight_pos]
  apply rectangle_live_candidate_rounding H v u hu hv g
    (rectangleLogicalErrorBudget w H v u g B)
    (rectangleLogicalSlack w H v u g / rectangleCommonA w u) hδ
    (le_add_of_nonneg_left (div_nonneg hD h.distinguished_pos.le)) hsym hobs e he heu
  · change -2 * (_ + _) ≤ _
    change -rectangleLogicalDeficit w H v u g B / (2 * w ∅) ≤ _ at hcoef
    simp only [neg_div] at hcoef
    have hsdiv := div_nonneg hS ha.le
    have hddiv := div_nonneg hD h.distinguished_pos.le
    linarith
  · intro z hz
    have hp := H.coset_partner_not_mem u v z hu hz
    have hzu := (H.coset_mem_not_anchor_or_shift u v z hv hz).2
    exact hnegative (cubeTranslation u z) hp (fun hh => hzu ((cubeTranslation_eq_one_iff u z).mp hh))
  · exact hremoved

end RectangleCostConditions
end NeuralGeneralization.OnlineLowerGeometry
