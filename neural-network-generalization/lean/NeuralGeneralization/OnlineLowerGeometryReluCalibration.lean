import NeuralGeneralization.OnlineLowerGeometryProjection
import NeuralGeneralization.OnlineLowerGeometryReluStar
import NeuralGeneralization.OnlineLowerGeometryMinimum

/-!
# Exact ReLU calibration identity on physical scores

The cost decomposition is obtained from the literal affine-coset dual and
the actual conditional projection.  Its nonnegative deficit requires an
explicit weighted Fourier bound, which the analytic atom theorem must
supply.  No geometric lower bound is postulated here.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

def reluReference {m : ℕ} (z : ClippingCube m) : ℝ :=
  -(1 : ℝ) / 2 + pointIndicator (cubeOne m) z

def reluCalibrationConstant {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v : ClippingCube m) : ℝ :=
  uniformCubeMean (fun z => reluDualScore w H v z * reluReference z)

def reluLiveMass {m : ℕ} (H : CubeSubgroup m) (v : ClippingCube m)
    (g : ClippingCube m → ℝ) (z : ClippingCube m) : ℝ :=
  if cubeTranslation v z ∈ H.carrier then g z + 1 / 2 else 0

def reluCalibrationSlack {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v : ClippingCube m) (g : ClippingCube m → ℝ) : ℝ :=
  uniformCubeMean (fun z => if cubeTranslation v z ∈ H.carrier then 0
    else reluDualScore w H v z * (g z - reluReference z))

theorem cubeOne_not_in_coset {m : ℕ} (H : CubeSubgroup m)
    (v : ClippingCube m) (hv : v ∉ H.carrier) :
    cubeTranslation v (cubeOne m) ∉ H.carrier := by
  rw [cubeTranslation_comm, cubeTranslation_one]
  exact hv

theorem reluReference_on_coset {m : ℕ} (H : CubeSubgroup m)
    (v z : ClippingCube m) (hv : v ∉ H.carrier)
    (hz : cubeTranslation v z ∈ H.carrier) : reluReference z = -(1 : ℝ) / 2 := by
  have hzone : z ≠ cubeOne m := by
    intro h
    subst z
    exact cubeOne_not_in_coset H v hv hz
  simp [reluReference, pointIndicator, hzone]

theorem relu_dual_calibrated_identity {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v : ClippingCube m) (hv : v ∉ H.carrier)
    (hcard : 0 < (H.differenceAnnihilator v).card) (g : ClippingCube m → ℝ) :
    uniformCubeMean (fun z => reluDualScore w H v z * g z) =
      reluCalibrationConstant w H v + reluCalibrationSlack w H v g +
      linearCost (fun z => walshExpansion w z / Fintype.card (ClippingCube m))
        (reluLiveMass H v g) := by
  have hpoint (z : ClippingCube m) :
      reluDualScore w H v z * g z =
        reluDualScore w H v z * reluReference z +
        (if cubeTranslation v z ∈ H.carrier then 0
          else reluDualScore w H v z * (g z - reluReference z)) +
        walshExpansion w z * reluLiveMass H v g z := by
    by_cases hz : cubeTranslation v z ∈ H.carrier
    · rw [reluDual_on_coset w H v hv hcard z hz,
        reluReference_on_coset H v z hv hz]
      simp only [reluLiveMass, if_pos hz]
      ring
    · simp only [reluLiveMass, if_neg hz]
      ring
  unfold uniformCubeMean reluCalibrationConstant reluCalibrationSlack linearCost
  simp_rw [hpoint]
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib, add_div, add_div]
  congr 1
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro z _
  ring

/-- Correct margins on the calibrated fibers make the literal calibrated
slack nonnegative. The inverse-cost sign is a separate scalar theorem. -/
theorem reluCalibrationSlack_nonneg {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v : ClippingCube m) (hv : v ∉ H.carrier)
    (hcard : 0 < (H.differenceAnnihilator v).card) (hw0 : 0 ≤ w ∅)
    (hsum : 6 * w ∅ ≤ ∑ S, w S)
    (hcost : ∀ z, z ≠ cubeOne m → walshExpansion w z ≤ 0)
    (g : ClippingCube m → ℝ)
    (hanchor : (1 : ℝ) / 2 ≤ g (cubeOne m))
    (hnegative : ∀ z, cubeTranslation v z ∉ H.carrier → z ≠ cubeOne m →
      g z ≤ -(1 : ℝ) / 2) :
    0 ≤ reluCalibrationSlack w H v g := by
  apply div_nonneg _ (Nat.cast_nonneg _)
  apply Finset.sum_nonneg
  intro z _
  split_ifs with hz
  · exact le_rfl
  · by_cases hzone : z = cubeOne m
    · subst z
      have hdual := reluDual_anchor_calibration w H v hv hcard hsum
      have href : reluReference (cubeOne m) = (1 : ℝ) / 2 := by
        norm_num [reluReference, pointIndicator]
      rw [href]
      exact mul_nonneg (by linarith) (by linarith)
    · have hdual := reluDual_negative_calibration w H v hv hw0 hcard z hz (hcost z hzone)
      have href : reluReference z = -(1 : ℝ) / 2 := by
        simp [reluReference, pointIndicator, hzone]
      rw [href]
      exact mul_nonneg_of_nonpos_of_nonpos (by linarith) (by linarith [hnegative z hz hzone])

theorem reluStar_exact_cost {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v z : ClippingCube m) (hv : v ∉ H.carrier)
    (hz : cubeTranslation v z ∈ H.carrier)
    (hcard : 0 < (H.differenceAnnihilator v).card)
    (hM : 4 ≤ Fintype.card (ClippingCube m)) :
    weightedWalshCost w (reluStar z) = reluCalibrationConstant w H v +
      walshExpansion w z / Fintype.card (ClippingCube m) := by
  rw [← reluStar_dual_saturation w H v z hz hM]
  change uniformCubeMean (fun x => reluDualScore w H v x *
    (reluReference x + pointIndicator z x)) = _
  unfold uniformCubeMean reluCalibrationConstant
  simp only [mul_add, Finset.sum_add_distrib, add_div]
  congr 1
  simp only [pointIndicator, mul_ite, mul_one, mul_zero,
    Finset.sum_ite_eq', Finset.mem_univ, if_true]
  rw [reluDual_on_coset w H v hv hcard z hz]

/-- The calibrated dual has the quantitative sign needed to control the
actual off-coset logical deviation. -/
theorem relu_calibration_deviation_bound {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v : ClippingCube m) (hv : v ∉ H.carrier)
    (hcard : 0 < (H.differenceAnnihilator v).card) (hw0 : 0 ≤ w ∅)
    (hsum : 6 * w ∅ ≤ ∑ S, w S)
    (hcost : ∀ z, z ≠ cubeOne m → walshExpansion w z ≤ 0)
    (g : ClippingCube m → ℝ)
    (hanchor : (1 : ℝ) / 2 ≤ g (cubeOne m))
    (hnegative : ∀ z, cubeTranslation v z ∉ H.carrier → z ≠ cubeOne m →
      g z ≤ -(1 : ℝ) / 2) :
    2 * w ∅ * uniformCubeMean (fun z =>
      if cubeTranslation v z ∉ H.carrier then |g z - reluReference z| else 0) ≤
      reluCalibrationSlack w H v g := by
  have hpoint (z : ClippingCube m) :
      2 * w ∅ * (if cubeTranslation v z ∉ H.carrier then |g z - reluReference z| else 0) ≤
      (if cubeTranslation v z ∈ H.carrier then 0
        else reluDualScore w H v z * (g z - reluReference z)) := by
    by_cases hz : cubeTranslation v z ∈ H.carrier
    · simp [hz]
    · simp only [if_neg hz, if_pos hz]
      by_cases hzone : z = cubeOne m
      · subst z
        have hdual := reluDual_anchor_calibration w H v hv hcard hsum
        have href : reluReference (cubeOne m) = (1 : ℝ) / 2 := by
          norm_num [reluReference, pointIndicator]
        rw [href, abs_of_nonneg (by linarith)]
        exact mul_le_mul_of_nonneg_right hdual (by linarith)
      · have hdual := reluDual_negative_calibration w H v hv hw0 hcard z hz (hcost z hzone)
        have href : reluReference z = -(1 : ℝ) / 2 := by
          simp [reluReference, pointIndicator, hzone]
        rw [href, abs_of_nonpos (by linarith [hnegative z hz hzone])]
        nlinarith [mul_nonneg
          (by linarith : 0 ≤ -(2 * w ∅) - reluDualScore w H v z)
          (by linarith [hnegative z hz hzone] : 0 ≤ -(g z - -(1 : ℝ) / 2))]
  have hsum' := Finset.sum_le_sum fun z (_ : z ∈ Finset.univ) => hpoint z
  have hdiv := div_le_div_of_nonneg_right hsum'
    (Nat.cast_nonneg (Fintype.card (ClippingCube m)) :
      (0 : ℝ) ≤ Fintype.card (ClippingCube m))
  simpa only [← Finset.mul_sum, mul_div_assoc, uniformCubeMean,
    reluCalibrationSlack] using hdiv

theorem reluCalibrationConstant_formula {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v : ClippingCube m) (hv : v ∉ H.carrier)
    (hcard : 0 < (H.differenceAnnihilator v).card) :
    reluCalibrationConstant w H v =
      (∑ S, w S) / Fintype.card (ClippingCube m) + w ∅ / 2 -
        4 * w ∅ / Fintype.card (ClippingCube m) := by
  have hmean : uniformCubeMean (reluDualScore w H v) = -(w ∅) := by
    have h := walshCoefficients_expansion (reluDualCoefficients w H v) ∅
    change walshCoefficients (reluDualScore w H v) ∅ = _ at h
    simp only [walshCoefficients, walshCharacter, Finset.prod_empty,
      mul_one, reluDualCoefficients, if_true,
      if_neg (H.empty_not_differenceAnnihilator v), sub_zero] at h
    linarith
  have hone : reluDualScore w H v (cubeOne m) = (∑ S, w S) - 4 * w ∅ := by
    rw [reluDualScore_formula w H v hv hcard]
    have hvone : cubeTranslation v (cubeOne m) = v := by
      rw [cubeTranslation_comm, cubeTranslation_one]
    simp only [walshExpansion, walshCharacter_one, mul_one,
      CubeSubgroup.indicator, CubeSubgroup.cosetIndicator,
      if_pos H.one_mem, hvone, if_neg hv, mul_zero, add_zero]
    ring
  unfold reluCalibrationConstant reluReference uniformCubeMean
  simp only [mul_add, Finset.sum_add_distrib, add_div,
    pointIndicator, mul_ite, mul_one, mul_zero,
    Finset.sum_ite_eq', Finset.mem_univ, if_true]
  rw [← Finset.sum_mul, mul_div_right_comm, hone]
  change uniformCubeMean (reluDualScore w H v) * (-1 / 2) + _ = _
  rw [hmean]
  ring

namespace WalshCodeMap

variable {d m : ℕ} (C : WalshCodeMap d m)

theorem relu_projection_calibration_margins (H : CubeSubgroup m) (v : ClippingCube m)
    (hv : v ∉ H.carrier) (F : ClippingCube d → ℝ)
    (hcal : ∀ x, cubeTranslation v (C.syndrome x) ∉ H.carrier →
      (1 : ℝ) / 2 ≤ (if C.syndrome x = cubeOne m then 1 else -1) * (C.base x * F x)) :
    (1 : ℝ) / 2 ≤ C.logicalProjection F (cubeOne m) ∧
    ∀ z, cubeTranslation v z ∉ H.carrier → z ≠ cubeOne m →
      C.logicalProjection F z ≤ -(1 : ℝ) / 2 := by
  constructor
  · have h := C.logical_margin_of_fiber_margin F 1 (1 / 2) (cubeOne m) (by
      intro x hx
      have hnot : cubeTranslation v (C.syndrome x) ∉ H.carrier := by
        rw [hx]
        exact cubeOne_not_in_coset H v hv
      simpa only [hx, if_true] using hcal x hnot)
    simpa only [one_mul] using h
  · intro z hz hzone
    have h := C.logical_margin_of_fiber_margin F (-1) (1 / 2) z (by
      intro x hx
      have hnot : cubeTranslation v (C.syndrome x) ∉ H.carrier := by rwa [hx]
      simpa only [hx, if_neg hzone] using hcal x hnot)
    linarith

/-- The exact decomposition for the actual physical score. Its logical
coordinates are defined by conditional expectation, not free inputs. -/
theorem relu_physical_calibrated_decomposition
    (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m) (v : ClippingCube m)
    (hv : v ∉ H.carrier) (hcard : 0 < (H.differenceAnnihilator v).card)
    (F : ClippingCube d → ℝ) (B : ℝ) :
    B = reluCalibrationConstant w H v +
      (B - uniformCubeMean (fun x => C.base x * reluDualScore w H v (C.syndrome x) * F x)) +
      reluCalibrationSlack w H v (C.logicalProjection F) +
      linearCost (fun z => walshExpansion w z / Fintype.card (ClippingCube m))
        (reluLiveMass H v (C.logicalProjection F)) := by
  rw [C.physical_logical_pairing]
  rw [relu_dual_calibrated_identity w H v hv hcard]
  ring

theorem relu_physical_deficit_nonneg
    (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m) (v : ClippingCube m)
    (hw0 : 0 ≤ w ∅) (hw : ∀ S, w ∅ ≤ w S)
    (hcard : 2 ≤ (H.differenceAnnihilator v).card)
    (F : ClippingCube d → ℝ) (B : ℝ)
    (hcost : weightedWalshCost w (C.logicalProjection F) ≤ B) :
    0 ≤ B - uniformCubeMean (fun x =>
      C.base x * reluDualScore w H v (C.syndrome x) * F x) := by
  rw [C.physical_logical_pairing]
  have hdual := walsh_dual_bound w (C.logicalProjection F) (reluDualScore w H v)
    (fun S => by
      rw [reluDualScore, walshCoefficients_expansion]
      exact reluDual_coefficients_feasible w H v hw0 hw hcard S)
  linarith

end WalshCodeMap
end NeuralGeneralization.OnlineLowerGeometry
