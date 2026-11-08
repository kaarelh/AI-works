import NeuralGeneralization.OnlineLowerGeometryReluCalibration
import NeuralGeneralization.OnlineLowerGeometryRailDefect
import NeuralGeneralization.OnlineLowerGeometryIndependentCoset

/-!
# Physical variance from actual calibration and the analytic support error

All finite projection, calibration, and observability steps are proved
here. The analytic input is explicitly the squared error outside the
downward Fourier space, to be supplied by the neural atom stability
theorem. It is not identified with the desired online conclusion.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

theorem uniformCubeMean_mono {d : ℕ} (F G : ClippingCube d → ℝ)
    (h : ∀ x, F x ≤ G x) : uniformCubeMean F ≤ uniformCubeMean G :=
  div_le_div_of_nonneg_right (Finset.sum_le_sum fun x _ => h x) (Nat.cast_nonneg _)

theorem uniformCubeMean_mul {d : ℕ} (c : ℝ) (F : ClippingCube d → ℝ) :
    uniformCubeMean (fun x => c * F x) = c * uniformCubeMean F := by
  unfold uniformCubeMean
  rw [← Finset.mul_sum, mul_div_assoc]

theorem uniformCubeMean_eq_weighted_sum {d : ℕ} (F : ClippingCube d → ℝ) :
    uniformCubeMean F = ∑ x, (1 / Fintype.card (ClippingCube d) : ℝ) * F x := by
  rw [← Finset.mul_sum]
  unfold uniformCubeMean
  ring

theorem uniform_observability_variance_bound {d : ℕ}
    (R A E : ClippingCube d → ℝ) (O : Set (ClippingCube d))
    (hsplit : ∀ x, R x = A x + E x)
    (horth : uniformCubeMean (fun x => A x * E x) = 0)
    (hobs : uniformCubeMean (fun x => (A x) ^ 2) ≤
      2 * uniformCubeMean (fun x => if x ∈ O then (A x) ^ 2 else 0)) :
    uniformCubeMean (fun x => (R x) ^ 2) ≤
      4 * uniformCubeMean (fun x => if x ∈ O then (R x) ^ 2 else 0) +
      5 * uniformCubeMean (fun x => (E x) ^ 2) := by
  simp_rw [uniformCubeMean_eq_weighted_sum] at horth hobs ⊢
  have hμ : (0 : ℝ) ≤ 1 / Fintype.card (ClippingCube d) :=
    div_nonneg (by norm_num) (Nat.cast_nonneg _)
  have h := orthogonal_observability_variance_bound
    (fun _ : ClippingCube d => (1 / Fintype.card (ClippingCube d) : ℝ))
    R A E O (fun _ => hμ) hsplit horth
    (by simpa only [mul_ite, mul_zero] using hobs)
  simpa only [mul_ite, mul_zero] using h

namespace WalshCodeMap

variable {d m : ℕ} (C : WalshCodeMap d m)

/-- The observed physical squared residual is controlled by the literal
dual calibration slack. -/
theorem relu_observed_variance_bound (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v : ClippingCube m) (hv : v ∉ H.carrier)
    (hcard : 0 < (H.differenceAnnihilator v).card) (hw0 : 0 < w ∅)
    (hsum : 6 * w ∅ ≤ ∑ S, w S)
    (hcost : ∀ z, z ≠ cubeOne m → walshExpansion w z ≤ 0)
    (F : ClippingCube d → ℝ) (L : ℝ) (hL : 0 ≤ L) (hcap : ∀ x, |F x| ≤ L)
    (hcal : ∀ x, cubeTranslation v (C.syndrome x) ∉ H.carrier →
      (1 : ℝ) / 2 ≤ (if C.syndrome x = cubeOne m then 1 else -1) * (C.base x * F x)) :
    uniformCubeMean (fun x => if cubeTranslation v (C.syndrome x) ∉ H.carrier then
      (F x - C.project F x) ^ 2 else 0) ≤
      (2 * L / w ∅) * reluCalibrationSlack w H v (C.logicalProjection F) := by
  obtain ⟨hanchor, hnegative⟩ := C.relu_projection_calibration_margins H v hv F hcal
  let J : Set (ClippingCube m) := {z | cubeTranslation v z ∈ H.carrier}
  let dev := fun z => if cubeTranslation v z ∉ H.carrier then
    |C.logicalProjection F z - reluReference z| else 0
  have hpoint (z : ClippingCube m) :
      (if z ∉ J then C.fiberMean (fun x => (F x - C.project F x) ^ 2) z else 0) ≤
        4 * L * dev z := by
    by_cases hz : z ∉ J
    · have hz' : cubeTranslation v z ∉ H.carrier := hz
      simp only [if_pos hz, dev, if_pos hz']
      by_cases hzone : z = cubeOne m
      · subst z
        have hb := C.observed_fiber_squared_residual F 1 (1 / 2) L (cubeOne m)
          (by norm_num) hL hcap (by
            intro x hx
            have hnot : cubeTranslation v (C.syndrome x) ∉ H.carrier := by rwa [hx]
            simpa only [hx, if_true] using hcal x hnot)
        have href : reluReference (cubeOne m) = (1 : ℝ) / 2 := by
          norm_num [reluReference, pointIndicator]
        rw [href, abs_of_nonneg (by linarith)]
        simpa only [one_mul, fiberMean] using hb
      · have hb := C.observed_fiber_squared_residual F (-1) (1 / 2) L z
          (by norm_num) hL hcap (by
            intro x hx
            have hnot : cubeTranslation v (C.syndrome x) ∉ H.carrier := by rwa [hx]
            simpa only [hx, if_neg hzone] using hcal x hnot)
        have href : reluReference z = -(1 : ℝ) / 2 := by
          simp [reluReference, pointIndicator, hzone]
        rw [href, abs_of_nonpos (by linarith [hnegative z hz' hzone])]
        change (∑ x, C.fiberWeight z x * (F x - C.project F x) ^ 2) ≤ _
        nlinarith
    · have hz' : ¬ cubeTranslation v z ∉ H.carrier := hz
      simp only [if_neg hz, dev, if_neg hz', mul_zero]
      exact le_rfl
  have hobs := uniformCubeMean_mono _ _ hpoint
  rw [uniformCubeMean_mul] at hobs
  have heq : uniformCubeMean (fun z => if z ∉ J then
      C.fiberMean (fun x => (F x - C.project F x) ^ 2) z else 0) =
      uniformCubeMean (fun x => if cubeTranslation v (C.syndrome x) ∉ H.carrier then
        (F x - C.project F x) ^ 2 else 0) := by
    calc
      _ = uniformCubeMean (fun z => C.fiberMean (fun x => if C.syndrome x ∉ J then
          (F x - C.project F x) ^ 2 else 0) z) := by
        congr 1
        funext z
        convert (C.fiberMean_restrict (fun x => (F x - C.project F x) ^ 2) J z).symm using 1 <;> congr
        funext x
        congr
      _ = _ := by
        convert (C.mean_fiber_mean (fun x => if C.syndrome x ∉ J then
          (F x - C.project F x) ^ 2 else 0)) using 1 <;> congr
  rw [heq] at hobs
  have hdev := relu_calibration_deviation_bound w H v hv hcard hw0.le hsum hcost
    (C.logicalProjection F) hanchor hnegative
  change 2 * w ∅ * uniformCubeMean dev ≤ _ at hdev
  have h1 := mul_le_mul_of_nonneg_left hobs hw0.le
  have h2 := mul_le_mul_of_nonneg_left hdev (by linarith : 0 ≤ 2 * L)
  have hM : (2 * L / w ∅) * reluCalibrationSlack w H v (C.logicalProjection F) =
      (2 * L * reluCalibrationSlack w H v (C.logicalProjection F)) / w ∅ := by ring
  rw [hM]
  apply (le_div_iff₀ hw0).mpr
  nlinarith

end WalshCodeMap

open OnlineLowerRelu

set_option maxHeartbeats 1000000 in

/-- The full finite physical variance estimate, with only the analytic
downward-space residual left on the right. Its coefficient five is the
orthogonal residual calculation, not an assumed stability estimate. -/
theorem actual_rail_relu_variance {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (hsize : ∀ i b, 0 < size i b)
    (C : WalshCodeMap (railDimension size) m)
    (hsupport : ∀ s, C.support s = generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s)
    (w : Finset (Fin m) → ℝ) (H : CubeSubgroup m) (v : ClippingCube m)
    (hv : v ∉ H.carrier) (hcard : 0 < (H.differenceAnnihilator v).card)
    (hw0 : 0 < w ∅) (hsum : 6 * w ∅ ≤ ∑ S, w S)
    (hcost : ∀ z, z ≠ cubeOne m → walshExpansion w z ≤ 0)
    (hdetect : ∀ i, logicalColumnPoint column i ∉ H.carrier)
    (F : ClippingCube (railDimension size) → ℝ) (L : ℝ)
    (hL : 0 ≤ L) (hcap : ∀ x, |F x| ≤ L)
    (hcal : ∀ x, cubeTranslation v (C.syndrome x) ∉ H.carrier →
      (1 : ℝ) / 2 ≤ (if C.syndrome x = cubeOne m then 1 else -1) * (C.base x * F x)) :
    uniformCubeMean (fun x => (F x - C.project F x) ^ 2) ≤
      (8 * L / w ∅) * reluCalibrationSlack w H v (C.logicalProjection F) +
      5 * uniformCubeMean (fun x =>
        (F x - fourierProject (railDownwardSupports size column) F x) ^ 2) := by
  let PD := fourierProject (railDownwardSupports size column) F
  let J : Set (ClippingCube m) := {z | cubeTranslation v z ∈ H.carrier}
  let O : Set (ClippingCube (railDimension size)) := {x | C.syndrome x ∉ J}
  have hcodes : C.supports = railCodeSupports size column := by
    unfold WalshCodeMap.supports railCodeSupports
    congr 1
    funext s
    exact hsupport s
  have hsub : C.supports ⊆ railDownwardSupports size column := by
    rw [hcodes]
    exact railCodeSupports_subset_downward size column
  have horth : uniformCubeMean (fun x => (PD x - C.project F x) * (F x - PD x)) = 0 := by
    rw [C.project_eq_fourierProject]
    exact fourierProject_residual_orthogonal C.supports (railDownwardSupports size column) hsub F
  have hobs := actual_rail_observability size column hsize C hsupport F J
    (fun i z hz => H.coset_independent v (logicalColumnPoint column i) (hdetect i) z hz)
  have hvar := uniform_observability_variance_bound
    (fun x => F x - C.project F x) (fun x => PD x - C.project F x)
    (fun x => F x - PD x) O (fun x => by ring) horth
    (by
      convert hobs using 1 <;> congr
      funext x
      congr)
  have hcalobs := C.relu_observed_variance_bound w H v hv hcard hw0 hsum hcost F L hL hcap hcal
  let Q := uniformCubeMean (fun x => if cubeTranslation v (C.syndrome x) ∉ H.carrier then
    (F x - C.project F x) ^ 2 else 0)
  let E2 := uniformCubeMean (fun x => (F x - PD x) ^ 2)
  have hvarQ : uniformCubeMean (fun x => (F x - C.project F x) ^ 2) ≤ 4 * Q + 5 * E2 := by
    convert hvar using 1 <;> congr
    dsimp only [Q]
    congr 1
    funext x
    congr
  have hcalQ : Q ≤ (2 * L / w ∅) * reluCalibrationSlack w H v (C.logicalProjection F) := by
    convert hcalobs using 1 <;> congr
  have hmul := mul_le_mul_of_nonneg_left hcalQ (by norm_num : (0 : ℝ) ≤ 4)
  have hfinal := add_le_add_right hmul (5 * E2)
  have hcoef : 4 * ((2 * L / w ∅) * reluCalibrationSlack w H v (C.logicalProjection F)) =
      (8 * L / w ∅) * reluCalibrationSlack w H v (C.logicalProjection F) := by ring
  rw [hcoef] at hfinal
  apply hvarQ.trans
  simpa only [add_comm] using hfinal

end NeuralGeneralization.OnlineLowerGeometry
