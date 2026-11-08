import NeuralGeneralization.OnlineLowerTanhGeometryMinimum
import NeuralGeneralization.OnlineLowerTanhGeometryTarget
import NeuralGeneralization.OnlineLowerGeometryPhysicalMinimum

/-! # Unique physical rectangle score at the calibrated minimum -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry
namespace WalshCodeMap
variable {d m : ℕ} (C : WalshCodeMap d m)

lemma rectangle_physical_score_of_zero_defects (H : CubeSubgroup m)
    (v u zstar : ClippingCube m) (F : ClippingCube d → ℝ)
    (herror : uniformCubeMean (fun z => |C.logicalProjection F z -
      rectangleMassScore u (reluLiveMass H v (C.logicalProjection F)) z|) ≤ 0)
    (hvariance : uniformCubeMean (fun x => (F x - C.project F x)^2) ≤ 0)
    (hp : reluLiveMass H v (C.logicalProjection F) = pointIndicator zstar) :
    F = fun x => C.base x * rectangleScore u zstar (C.syndrome x) := by
  have hmeanerror : uniformCubeMean (fun z => |C.logicalProjection F z -
      rectangleMassScore u (reluLiveMass H v (C.logicalProjection F)) z|) = 0 := by
    apply le_antisymm herror
    exact div_nonneg (Finset.sum_nonneg fun z _ => abs_nonneg _) (Nat.cast_nonneg _)
  have hg (z : ClippingCube m) : C.logicalProjection F z = rectangleScore u zstar z := by
    have hh := uniform_nonnegative_mean_zero _ (fun z => abs_nonneg _) hmeanerror z
    have heq := sub_eq_zero.mp (abs_eq_zero.mp hh)
    rw [hp, rectangleMassScore_pointIndicator] at heq
    exact heq
  have hmeanvar : uniformCubeMean (fun x => (F x - C.project F x)^2) = 0 := by
    apply le_antisymm hvariance
    exact div_nonneg (Finset.sum_nonneg fun x _ => sq_nonneg _) (Nat.cast_nonneg _)
  have hres := uniform_square_mean_zero _ hmeanvar
  funext x
  have hx := sub_eq_zero.mp (congrFun hres x)
  rw [hx, project, hg]

/-- Minimum classification for the actual physical score. The variance
hypothesis is explicitly the analytic stability input, while all logical
calibration, Fourier rounding and physical equality steps are proved. -/
theorem rectangle_calibrated_score_minimum (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u zstar : ClippingCube m) (hw : RectangleCostConditions w u)
    (hu : u ∉ H.carrier) (hv : v ∉ (H.adjoinPoint u).carrier)
    (hE : 2 ≤ ((H.adjoinPoint u).differenceAnnihilator v).card)
    (hdensity : (1 : ℝ) / 2 ≤ uniformCubeMean (fun z =>
      if z ∈ rectangleNegativeObserved H v u then 1 else 0))
    (horder : ∀ z, cubeTranslation v z ∈ H.carrier →
      0 ≤ rectangleWeightTransform w z ∧ rectangleWeightTransform w z ≤ rectangleWeightTransform w (cubeTranslation u z))
    (F : ClippingCube d → ℝ) (B W β : ℝ)
    (hmargin : ∀ x, (1 : ℝ) / 2 ≤ |F x|)
    (hcal : ∀ x, cubeTranslation v (C.syndrome x) ∉ H.carrier →
      (1 : ℝ) / 2 ≤ (if C.syndrome x = cubeOne m then 1 else -1) * (C.base x * F x))
    (hcost : weightedWalshCost w (C.logicalProjection F) ≤ B)
    (e : Finset (Fin m)) (he : e ∈ H.differenceAnnihilator v) (heu : walshCharacter e u = -1)
    (live : ClippingCube m → Prop)
    (hremoved : ∀ z, ¬ live z → reluLiveMass H v (C.logicalProjection F) z ≤ 0)
    (hW : 0 ≤ W) (hν : ∀ z, |rectangleLiveCost w H v u z| ≤ W)
    (hnegative : rectangleLiveCost w H v u zstar < 0)
    (hstrict : ∀ z, live z → zstar ≠ z → rectangleLiveCost w H v u zstar < rectangleLiveCost w H v u z)
    (hvariance : uniformCubeMean (fun x => (F x - C.project F x)^2) ≤
      β * (rectangleLogicalDeficit w H v u (C.logicalProjection F) B +
        rectangleLogicalSlack w H v u (C.logicalProjection F)))
    (hsmall : W * (44 * Fintype.card (ClippingCube m) *
      (1 / rectangleWeightTransform w u + 1 / rectangleCommonA w u) +
        4 * (Fintype.card (ClippingCube m) * β)) < 1) :
    rectangleBaselineCost w u + rectangleLiveCost w H v u zstar ≤ B ∧
      (B ≤ rectangleBaselineCost w u + rectangleLiveCost w H v u zstar →
        F = fun x => C.base x * rectangleScore u zstar (C.syndrome x)) := by
  have hvH : v ∉ H.carrier := fun hh => hv (H.subset_adjoinPoint u hh)
  obtain ⟨hanchor, hnegativecal⟩ := C.relu_projection_calibration_margins H v hvH F hcal
  have hfrac := C.reluLiveMass_fractional_bound H v F hmargin
  have hM : (0 : ℝ) ≤ Fintype.card (ClippingCube m) := Nat.cast_nonneg _
  have hV : (∑ z, fractionalPenalty (reluLiveMass H v (C.logicalProjection F) z)) ≤
      (Fintype.card (ClippingCube m) * β) *
        (rectangleLogicalDeficit w H v u (C.logicalProjection F) B +
          rectangleLogicalSlack w H v u (C.logicalProjection F)) := by
    have hh := mul_le_mul_of_nonneg_left hvariance hM
    nlinarith only [hfrac, hh]
  obtain ⟨hlower, hequal⟩ := hw.logical_minimum H v zstar hu hv hE hdensity horder
    (C.logicalProjection F) B W (Fintype.card (ClippingCube m) * β) hcost hanchor hnegativecal
    e he heu live hremoved hW hν hnegative hstrict hV hsmall
  refine ⟨hlower, ?_⟩
  intro hupper
  obtain ⟨hD, hS, hp⟩ := hequal hupper
  apply C.rectangle_physical_score_of_zero_defects H v u zstar F
  · have hh := hw.logical_reconstruction_bound H v hu hv hE hdensity
      (C.logicalProjection F) B hcost hanchor hnegativecal
    simpa only [rectangleLogicalErrorBudget, hD, hS, zero_div, add_zero, mul_zero] using hh
  · simpa only [hD, hS, add_zero, mul_zero] using hvariance
  · exact hp

end WalshCodeMap
end NeuralGeneralization.OnlineLowerGeometry
