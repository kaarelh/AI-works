import NeuralGeneralization.OnlineLowerTanhGeometryLogical
import NeuralGeneralization.OnlineLowerGeometryReluMinimum

/-! # Exact rectangle minimum classification by finite rounding

The cost on the live coset is truncated outside that coset, so the small
Fourier-tail envelope is used only where it has actually been proved.
-/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerGeometry

def rectangleLiveCost {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u z : ClippingCube m) : ℝ :=
  if cubeTranslation v z∈H.carrier then rectangleEffectiveCost w u z else 0

theorem rectangleLiveCost_pairing {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (g : ClippingCube m → ℝ) :
    linearCost (rectangleLiveCost w H v u) (reluLiveMass H v g)=
      linearCost (rectangleEffectiveCost w u) (reluLiveMass H v g) := by
  unfold linearCost
  apply Finset.sum_congr rfl
  intro z hz
  by_cases h : cubeTranslation v z∈H.carrier <;> simp [rectangleLiveCost,reluLiveMass,h]

theorem rectangleLiveCost_abs_bound {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (W : ℝ) (hW : 0≤W)
    (hbound : ∀z,cubeTranslation v z∈H.carrier → |rectangleEffectiveCost w u z|≤W)
    (z : ClippingCube m) : |rectangleLiveCost w H v u z|≤W := by
  by_cases hz : cubeTranslation v z∈H.carrier
  · simpa [rectangleLiveCost,hz] using hbound z hz
  · simpa [rectangleLiveCost,hz] using hW

/-- Generic strict minimum classification for a rounded live point. -/
theorem minimum_from_candidate_rounding {ι : Type*} [Fintype ι]
    (ν p : ι→ℝ) (live : ι→Prop) (i : ι) (B C₀ D S W K : ℝ)
    (hD : 0≤D) (hS : 0≤S) (hW : 0≤W) (hν : ∀j,|ν j|≤W)
    (hsmall : W*K<1) (hdecomp : B=C₀+D+S+linearCost ν p)
    (hround : ∃q,IsLiveCandidate live q ∧ l1Distance p q≤K*(D+S))
    (hnegative : ν i<0) (hstrict : ∀j,live j → i≠j → ν i<ν j) :
    C₀+ν i≤B ∧ (B≤C₀+ν i → D=0 ∧ S=0 ∧ p=(fun j=>if j=i then 1 else 0)) := by
  obtain ⟨hmin,huniq⟩ := negative_point_unique_candidate ν live i hnegative hstrict
  have hpoint : linearCost ν (fun j=>if j=i then 1 else 0)=ν i := by
    simp [linearCost,mul_ite]
  obtain ⟨q,hq,hqr⟩ := hround
  have hl := calibrated_cost_lower ν p q B C₀ D S W K hW hν hdecomp hqr
  have hm := hmin q hq
  rw [hpoint] at hm
  have hprod : 0≤(1-W*K)*(D+S) := mul_nonneg (by linarith) (add_nonneg hD hS)
  refine ⟨by linarith,?_⟩
  intro hupper
  exact unique_calibrated_minimum ν p (fun j=>if j=i then 1 else 0) live
    B C₀ D S W K hD hS hW hν hsmall hdecomp ⟨q,hq,hqr⟩ hmin huniq
    (by simpa only [hpoint] using hupper)

namespace RectangleCostConditions
variable {m : ℕ} {w : Finset (Fin m)→ℝ} {u : ClippingCube m}
    (h : RectangleCostConditions w u)
include h

/-- Actual logical calibration plus the physical fractional-variance
bound identifies the unique minimum and annihilates both deficits. -/
theorem logical_minimum (H : CubeSubgroup m) (v zstar : ClippingCube m)
    (hu : u∉H.carrier) (hv : v∉(H.adjoinPoint u).carrier)
    (hE : 2≤((H.adjoinPoint u).differenceAnnihilator v).card)
    (hdensity : (1:ℝ)/2≤uniformCubeMean (fun z=>if z∈rectangleNegativeObserved H v u then 1 else 0))
    (horder : ∀z,cubeTranslation v z∈H.carrier →
      0≤rectangleWeightTransform w z ∧ rectangleWeightTransform w z≤rectangleWeightTransform w (cubeTranslation u z))
    (g : ClippingCube m→ℝ) (B W b : ℝ)
    (hcost : weightedWalshCost w g≤B) (hanchor : (1:ℝ)/2≤g (cubeOne m))
    (hnegativecal : ∀z,cubeTranslation v z∉H.carrier → z≠cubeOne m → g z≤-(1:ℝ)/2)
    (e : Finset (Fin m)) (he : e∈H.differenceAnnihilator v) (heu : walshCharacter e u=-1)
    (live : ClippingCube m→Prop) (hremoved : ∀z,¬live z → reluLiveMass H v g z≤0)
    (hW : 0≤W) (hν : ∀z,|rectangleLiveCost w H v u z|≤W)
    (hnegative : rectangleLiveCost w H v u zstar<0)
    (hstrict : ∀z,live z → zstar≠z → rectangleLiveCost w H v u zstar<rectangleLiveCost w H v u z)
    (hvariance : (∑z,fractionalPenalty (reluLiveMass H v g z))≤
      b*(rectangleLogicalDeficit w H v u g B+rectangleLogicalSlack w H v u g))
    (hsmall : W*(44*Fintype.card (ClippingCube m)*
      (1/rectangleWeightTransform w u+1/rectangleCommonA w u)+4*b)<1) :
    rectangleBaselineCost w u+rectangleLiveCost w H v u zstar≤B ∧
      (B≤rectangleBaselineCost w u+rectangleLiveCost w H v u zstar →
        rectangleLogicalDeficit w H v u g B=0 ∧ rectangleLogicalSlack w H v u g=0 ∧
          reluLiveMass H v g=pointIndicator zstar) := by
  let D := rectangleLogicalDeficit w H v u g B
  let S := rectangleLogicalSlack w H v u g
  let α := 1/rectangleWeightTransform w u+1/rectangleCommonA w u
  let M : ℝ := Fintype.card (ClippingCube m)
  have hD : 0≤D := h.logical_deficit_nonneg H v hE g B hcost
  have hS : 0≤S := h.logical_slack_nonneg H v hu hv (by omega) g hanchor hnegativecal
  have ha := h.parameter_bounds.2.2.1
  have hδ : rectangleLogicalErrorBudget w H v u g B≤α*(D+S) := by
    have hcross1 := div_nonneg hD ha.le
    have hcross2 := div_nonneg hS h.distinguished_pos.le
    have hid : α*(D+S)=rectangleLogicalErrorBudget w H v u g B+
        D/rectangleCommonA w u+S/rectangleWeightTransform w u := by
      dsimp [α,D,S,rectangleLogicalErrorBudget]
      ring
    rw [hid]
    linarith
  obtain ⟨q,hq,hqr⟩ := h.logical_calibrated_rounding H v hu hv hE hdensity
    g B hcost hanchor hnegativecal e he heu live hremoved
  have hround : l1Distance (reluLiveMass H v g) q≤(44*M*α+4*b)*(D+S) := by
    have hh := mul_le_mul_of_nonneg_left hδ (show 0≤44*M by dsimp [M]; positivity)
    change l1Distance _ _≤44*M*_+4*∑z,fractionalPenalty (reluLiveMass H v g z) at hqr
    nlinarith
  have hdecomp := h.logical_calibrated_decomposition H v hu hv (by omega) horder g B
  rw [←rectangleLiveCost_pairing] at hdecomp
  have hmin := minimum_from_candidate_rounding (rectangleLiveCost w H v u) (reluLiveMass H v g)
    live zstar B (rectangleBaselineCost w u) D S W (44*M*α+4*b) hD hS hW hν hsmall
    hdecomp ⟨q,hq,hround⟩ hnegative hstrict
  refine ⟨hmin.1,?_⟩
  intro hupper
  obtain ⟨hDz,hSz,hp⟩ := hmin.2 hupper
  refine ⟨hDz,hSz,?_⟩
  funext z
  by_cases hz : z=zstar
  · simpa [OnlineLowerGeometry.pointIndicator,hz] using congrFun hp z
  · simpa [OnlineLowerGeometry.pointIndicator,hz] using congrFun hp z

end RectangleCostConditions
end NeuralGeneralization.OnlineLowerGeometry
