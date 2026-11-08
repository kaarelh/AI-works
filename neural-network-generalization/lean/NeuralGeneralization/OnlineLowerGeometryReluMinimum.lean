import NeuralGeneralization.OnlineLowerGeometryReluFourier
import NeuralGeneralization.OnlineLowerGeometryReluRounding
import NeuralGeneralization.OnlineLowerGeometryPhysicalMinimum

/-! # Calibrated ReLU minimum classification for actual physical scores

The finite rounding theorem, explicit affine-coset dual, and actual
conditional projection identify the entire minimizing physical score.
Only the separately proved analytic cost/stability inequalities and the
scalar strict ordering are inputs to this geometric composition.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

private theorem linearCost_point {ι : Type*} [Fintype ι]
    (ν : ι → ℝ) (i : ι) : linearCost ν (fun j => if j = i then 1 else 0) = ν i := by
  simp [linearCost, mul_ite]

/-- A strictly cheapest negative live cost gives a unique point candidate;
the zero candidate is also ruled out by the strict negativity. -/
theorem negative_point_unique_candidate {ι : Type*} [Fintype ι]
    (ν : ι → ℝ) (live : ι → Prop) (i : ι)
    (hneg : ν i < 0) (hmin : ∀ j, live j → i ≠ j → ν i < ν j) :
    (∀ q, IsLiveCandidate live q →
      linearCost ν (fun j => if j = i then 1 else 0) ≤ linearCost ν q) ∧
    (∀ q, IsLiveCandidate live q →
      linearCost ν q = linearCost ν (fun j => if j = i then 1 else 0) →
        q = fun j => if j = i then 1 else 0) := by
  constructor
  · intro q hq
    rw [linearCost_point]
    rcases hq with rfl | ⟨j, hj, rfl⟩
    · simpa [linearCost] using hneg.le
    · rw [linearCost_point]
      by_cases hij : i = j
      · rw [hij]
      · exact (hmin j hj hij).le
  · intro q hq hcost
    rcases hq with rfl | ⟨j, hj, rfl⟩
    · rw [linearCost_point] at hcost
      have hz : linearCost ν (fun _ => 0) = 0 := by simp [linearCost]
      rw [hz] at hcost
      linarith
    · simp only [linearCost_point] at hcost
      have hij : i = j := by
        by_contra hij
        have := hmin j hj hij
        linarith
      rw [hij]

/-- ReLU's `45 η+6V` bound yields the same exact minimum classification
as the general calibrated-cost lemma, with its actual constants. -/
theorem relu_minimum_from_rounding {ι : Type*} [Fintype ι]
    (ν p : ι → ℝ) (live : ι → Prop) (i : ι)
    (B C₀ D S W η a b : ℝ)
    (hD : 0 ≤ D) (hS : 0 ≤ S) (hW : 0 ≤ W) (hη : 0 ≤ η)
    (hν : ∀ j, |ν j| ≤ W)
    (hsmall : W * (45 * a + 6 * b) < 1)
    (hdecomp : B = C₀ + D + S + linearCost ν p)
    (hmass : |(∑ j, p j) - 1| ≤ η)
    (hl2 : (∑ j, p j ^ 2) ≤ (1 + η) ^ 2)
    (hl2large : 1 < η → (∑ j, p j ^ 2) ≤ 21 * η)
    (hremoved : ∀ j, ¬ live j → p j ≤ 0) (hi : live i)
    (hηbound : η ≤ a * (D + S))
    (hvariance : (∑ j, fractionalPenalty (p j)) ≤ b * (D + S))
    (hnegative : ν i < 0) (hstrict : ∀ j, live j → i ≠ j → ν i < ν j) :
    C₀ + ν i ≤ B ∧
      (B ≤ C₀ + ν i → D = 0 ∧ S = 0 ∧ p = fun j => if j = i then 1 else 0) := by
  obtain ⟨j, hj, hdist⟩ := relu_live_point_rounding p live η hη hmass
    (fun _ => hl2) hl2large hremoved ⟨i, hi⟩
  have hround : l1Distance p (fun x => if x = j then 1 else 0) ≤
      (45 * a + 6 * b) * (D + S) := by nlinarith
  have hcandidate : IsLiveCandidate live (fun x => if x = j then 1 else 0) :=
    Or.inr ⟨j, hj, rfl⟩
  obtain ⟨hmin, huniq⟩ := negative_point_unique_candidate ν live i hnegative hstrict
  have hlower := calibrated_cost_lower ν p (fun x => if x = j then 1 else 0)
    B C₀ D S W (45 * a + 6 * b) hW hν hdecomp hround
  have hlowest := hmin _ hcandidate
  simp only [linearCost_point] at hlower hlowest
  have hprod : 0 ≤ (1 - W * (45 * a + 6 * b)) * (D + S) :=
    mul_nonneg (by linarith) (add_nonneg hD hS)
  refine ⟨by linarith, ?_⟩
  intro hupper
  exact unique_calibrated_minimum ν p (fun x => if x = i then 1 else 0) live
    B C₀ D S W (45 * a + 6 * b) hD hS hW hν hsmall hdecomp
    ⟨_, hcandidate, hround⟩ hmin huniq (by simpa only [linearCost_point] using hupper)

def reluLiveCost {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v z : ClippingCube m) : ℝ :=
  if cubeTranslation v z ∈ H.carrier then
    walshExpansion w z / Fintype.card (ClippingCube m) else 0

theorem reluLiveCost_pairing {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v : ClippingCube m) (g : ClippingCube m → ℝ) :
    linearCost (reluLiveCost w H v) (reluLiveMass H v g) =
      linearCost (fun z => walshExpansion w z / Fintype.card (ClippingCube m))
        (reluLiveMass H v g) := by
  unfold linearCost
  apply Finset.sum_congr rfl
  intro z _
  by_cases hz : cubeTranslation v z ∈ H.carrier <;> simp [reluLiveCost, reluLiveMass, hz]

namespace WalshCodeMap

variable {d m : ℕ} (C : WalshCodeMap d m)

theorem reluLiveMass_fractional_bound (H : CubeSubgroup m) (v : ClippingCube m)
    (F : ClippingCube d → ℝ) (hF : ∀ x, (1 : ℝ) / 2 ≤ |F x|) :
    (∑ z, fractionalPenalty (reluLiveMass H v (C.logicalProjection F) z)) ≤
      Fintype.card (ClippingCube m) *
        uniformCubeMean (fun x => (F x - C.project F x) ^ 2) := by
  calc
    _ ≤ ∑ z, fractionalPenalty (C.logicalProjection F z + 1 / 2) := by
      apply Finset.sum_le_sum
      intro z _
      by_cases hz : cubeTranslation v z ∈ H.carrier
      · simp [reluLiveMass, hz]
      · simp only [reluLiveMass, if_neg hz]
        simpa [fractionalPenalty] using fractionalPenalty_nonneg (C.logicalProjection F z + 1 / 2)
    _ ≤ _ := C.fractional_penalty_sum_le_variance F hF



/-- The full calibrated minimum statement for actual physical scores.
The variance inequality is the analytic stability input; all projection,
Fourier-mass, rounding, and equality arguments are proved here. -/
theorem relu_calibrated_score_minimum
    (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m) (v zstar : ClippingCube m)
    (live : ClippingCube m → Prop) (F : ClippingCube d → ℝ) (B W β : ℝ)
    (hv : v ∉ H.carrier) (hw0 : 0 < w ∅) (hw : ∀ s, w ∅ ≤ w s)
    (hcard : 2 ≤ (H.differenceAnnihilator v).card)
    (hsum : 6 * w ∅ ≤ ∑ s, w s)
    (hcostsign : ∀ z, z ≠ cubeOne m → walshExpansion w z ≤ 0)
    (hmargin : ∀ x, (1 : ℝ) / 2 ≤ |F x|)
    (hcal : ∀ x, cubeTranslation v (C.syndrome x) ∉ H.carrier →
      (1 : ℝ) / 2 ≤ (if C.syndrome x = cubeOne m then 1 else -1) * (C.base x * F x))
    (hcost : weightedWalshCost w (C.logicalProjection F) ≤ B)
    (hbudget : B / w ∅ ≤ 10)
    (hremoved : ∀ z, ¬ live z → reluLiveMass H v (C.logicalProjection F) z ≤ 0)
    (hzlive : live zstar) (hzcoset : cubeTranslation v zstar ∈ H.carrier)
    (hW : 0 ≤ W) (hν : ∀ z, |reluLiveCost w H v z| ≤ W)
    (hnegative : reluLiveCost w H v zstar < 0)
    (hstrict : ∀ z, live z → zstar ≠ z → reluLiveCost w H v zstar < reluLiveCost w H v z)
    (hvariance : uniformCubeMean (fun x => (F x - C.project F x) ^ 2) ≤
      β * (reluDualDeficit w H v (C.logicalProjection F) B +
        reluCalibrationSlack w H v (C.logicalProjection F)))
    (hsmall : W * (45 * ((Fintype.card (ClippingCube m) : ℝ) / (2 * w ∅)) +
      6 * ((Fintype.card (ClippingCube m) : ℝ) * β)) < 1) :
    reluCalibrationConstant w H v + reluLiveCost w H v zstar ≤ B ∧
      (B ≤ reluCalibrationConstant w H v + reluLiveCost w H v zstar →
        F = fun x => C.base x * reluStar zstar (C.syndrome x)) := by
  let g := C.logicalProjection F
  let p := reluLiveMass H v g
  let D := reluDualDeficit w H v g B
  let S := reluCalibrationSlack w H v g
  let M : ℝ := Fintype.card (ClippingCube m)
  let η := reluFourierEta w H v g B
  have hM : 0 ≤ M := Nat.cast_nonneg _
  have hcp : 0 < (H.differenceAnnihilator v).card := by omega
  obtain ⟨hanchor, hnegativecal⟩ := C.relu_projection_calibration_margins H v hv F hcal
  have hS : 0 ≤ S := reluCalibrationSlack_nonneg w H v hv hcp hw0.le
    hsum hcostsign g hanchor hnegativecal
  have hD : 0 ≤ D := by
    have hh := walsh_dual_bound w g (reluDualScore w H v) (fun s => by
      rw [reluDualScore, walshCoefficients_expansion]
      exact reluDual_coefficients_feasible w H v hw0.le hw hcard s)
    dsimp [D, reluDualDeficit]
    linarith
  obtain ⟨hη, hmass, hl2, hlarge⟩ := relu_live_mass_and_second_moment
    w H v g B hv hw0 hw hcard hsum hcostsign hanchor hnegativecal hcost hbudget
  have hηbound : η ≤ (M / (2 * w ∅)) * (D + S) := by
    dsimp [η, reluFourierEta, M, D, S]
    exact le_of_eq (by ring)
  have hV : (∑ z, fractionalPenalty (p z)) ≤ (M * β) * (D + S) := by
    have hh := C.reluLiveMass_fractional_bound H v F hmargin
    have hm := mul_le_mul_of_nonneg_left hvariance hM
    change (∑ z, fractionalPenalty (p z)) ≤ M *
      uniformCubeMean (fun x => (F x - C.project F x) ^ 2) at hh
    change M * uniformCubeMean (fun x => (F x - C.project F x) ^ 2) ≤ M * (β * (D + S)) at hm
    nlinarith [hh.trans hm]
  have hdecomp : B = reluCalibrationConstant w H v + D + S +
      linearCost (reluLiveCost w H v) p := by
    rw [reluLiveCost_pairing]
    have hh := relu_dual_calibrated_identity w H v hv hcp g
    dsimp [D, reluDualDeficit, S]
    linarith
  obtain ⟨hlower, hequal⟩ := relu_minimum_from_rounding (reluLiveCost w H v) p live zstar
    B (reluCalibrationConstant w H v) D S W η (M / (2 * w ∅)) (M * β)
    hD hS hW hη hν hsmall hdecomp hmass hl2 hlarge hremoved hzlive
    hηbound hV hnegative hstrict
  refine ⟨hlower, ?_⟩
  intro hupper
  obtain ⟨hDz, hSz, hp⟩ := hequal hupper
  apply C.relu_physical_score_of_zero_defects H v zstar hv hzcoset F (w ∅) hw0
  · have hh := relu_calibration_deviation_bound w H v hv hcp hw0.le
      hsum hcostsign g hanchor hnegativecal
    change _ ≤ S at hh
    simpa only [hSz] using hh
  · change uniformCubeMean (fun x => (F x - C.project F x) ^ 2) ≤ β * (D + S) at hvariance
    simpa only [hDz, hSz, add_zero, mul_zero] using hvariance
  · funext z
    have hh := congrFun hp z
    by_cases hz : z = zstar <;> simpa [p, g, pointIndicator, hz] using hh

end WalshCodeMap
end NeuralGeneralization.OnlineLowerGeometry
