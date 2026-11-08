import NeuralGeneralization.OnlineLowerTanhGeometryFourier
import NeuralGeneralization.OnlineLowerTanhGeometryCommonDual
import NeuralGeneralization.OnlineLowerTanhGeometryCoset
import NeuralGeneralization.OnlineLowerTanhGeometryRectangle
import NeuralGeneralization.OnlineLowerTanhGeometrySymmetry
import NeuralGeneralization.OnlineLowerGeometryReluCalibration

/-! # Exact rectangle calibration on the actual logical cube -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

def rectangleObserved {m : ℕ} (H : CubeSubgroup m) (v u : ClippingCube m) :
    Set (ClippingCube m) :=
  {z | cubeTranslation v z ∉ (H.adjoinPoint u).carrier ∧ z ≠ u}

def rectangleNegativeObserved {m : ℕ} (H : CubeSubgroup m) (v u : ClippingCube m) :
    Set (ClippingCube m) :=
  {z | z ∈ rectangleObserved H v u ∧ z ≠ cubeOne m}

def rectangleCalibrationSlack {m : ℕ} (dual : ClippingCube m → ℝ)
    (H : CubeSubgroup m) (v u : ClippingCube m) (g : ClippingCube m → ℝ) : ℝ :=
  uniformCubeMean (fun z => if z ∈ rectangleObserved H v u then
    dual z * (g z - reluReference z) else 0)

theorem coset_translation_mem_iff {m : ℕ} (H : CubeSubgroup m)
    (u v z : ClippingCube m) (hu : u ∈ H.carrier) :
    cubeTranslation v (cubeTranslation u z) ∈ H.carrier ↔ cubeTranslation v z ∈ H.carrier := by
  rw [cubeTranslation_swap v u z, H.translate_mem_iff u hu]

theorem cubeTranslation_eq_one_iff {m : ℕ} (u z : ClippingCube m) :
    cubeTranslation u z = cubeOne m ↔ z = u := by
  constructor
  · intro h
    have hh := congrArg (cubeTranslation u) h
    simpa only [cubeTranslation_involutive, cubeTranslation_comm u (cubeOne m),
      cubeTranslation_one] using hh
  · rintro rfl
    exact cubeTranslation_self _

theorem cubeTranslation_eq_point_iff {m : ℕ} (u z : ClippingCube m) :
    cubeTranslation u z = u ↔ z = cubeOne m := by
  constructor
  · intro h
    have hh := congrArg (cubeTranslation u) h
    simpa only [cubeTranslation_involutive, cubeTranslation_self] using hh
  · rintro rfl
    rw [cubeTranslation_comm, cubeTranslation_one]

theorem rectangleNegativeObserved_invariant {m : ℕ} (H : CubeSubgroup m)
    (v u z : ClippingCube m) :
    cubeTranslation u z ∈ rectangleNegativeObserved H v u ↔
      z ∈ rectangleNegativeObserved H v u := by
  change ((_ ∉ _ ∧ _ ≠ _) ∧ _ ≠ _) ↔ ((_ ∉ _ ∧ _ ≠ _) ∧ _ ≠ _)
  simp only [coset_translation_mem_iff (H.adjoinPoint u) u v z (H.point_mem_adjoinPoint u),
    ne_eq, cubeTranslation_eq_point_iff, cubeTranslation_eq_one_iff]
  constructor <;> rintro ⟨⟨hA, hB⟩, hC⟩ <;> exact ⟨⟨hA, hC⟩, hB⟩

theorem live_not_observed {m : ℕ} (H : CubeSubgroup m) (v u z : ClippingCube m)
    (hz : cubeTranslation v z ∈ H.carrier) : z ∉ rectangleObserved H v u := by
  intro ho
  exact ho.1 (H.subset_adjoinPoint u hz)

/-- Pointwise partition of every calibrated pairing into its observed
slack and the actual live-fiber masses. -/
theorem rectangle_pairing_partition {m : ℕ} (H : CubeSubgroup m) (v u : ClippingCube m)
    (hv : v ∉ (H.adjoinPoint u).carrier) (g dual ν : ClippingCube m → ℝ)
    (hshift : dual u = 0)
    (hlive : ∀ z, cubeTranslation v z ∈ H.carrier →
      dual z = Fintype.card (ClippingCube m) * ν z)
    (hpartner : ∀ z, cubeTranslation v z ∈ H.carrier → dual (cubeTranslation u z) = 0)
    (z : ClippingCube m) :
    dual z * (g z - reluReference z) =
      (if z ∈ rectangleObserved H v u then dual z * (g z - reluReference z) else 0) +
        Fintype.card (ClippingCube m) * (ν z * reluLiveMass H v g z) := by
  by_cases hz : cubeTranslation v z ∈ H.carrier
  · have hnot := live_not_observed H v u z hz
    have hz0 := (H.coset_mem_not_anchor_or_shift u v z hv hz).1
    simp only [if_neg hnot, zero_add, reluLiveMass, if_pos hz,
      reluReference, pointIndicator, if_neg hz0, add_zero]
    rw [hlive z hz]
    ring
  · simp only [reluLiveMass, if_neg hz, mul_zero, add_zero]
    by_cases ho : z ∈ rectangleObserved H v u
    · rw [if_pos ho]
    · rw [if_neg ho]
      have hzero : dual z = 0 := by
        by_cases hzu : z = u
        · simpa only [hzu] using hshift
        · have hmem : cubeTranslation v z ∈ (H.adjoinPoint u).carrier := by
            by_contra hnot
            exact ho ⟨hnot, hzu⟩
          have hp := (H.coset_mem_adjoinPoint u v z).mp hmem
          have hh := hpartner (cubeTranslation u z) (hp.resolve_left hz)
          simpa only [cubeTranslation_involutive] using hh
      rw [hzero, zero_mul]

theorem reference_pairing_formula {m : ℕ} (dual : ClippingCube m → ℝ) :
    uniformCubeMean (fun z => dual z * reluReference z) =
      -(1 : ℝ) / 2 * uniformCubeMean dual +
        dual (cubeOne m) / Fintype.card (ClippingCube m) := by
  unfold reluReference uniformCubeMean
  simp only [mul_add, Finset.sum_add_distrib, add_div, pointIndicator,
    mul_ite, mul_one, mul_zero, Finset.sum_ite_eq', Finset.mem_univ, if_true]
  rw [← Finset.sum_mul]
  ring

/-- The exact calibrated cost identity, with every omitted-fiber term
cancelled by the proved pointwise dual values. -/
theorem rectangle_calibrated_decomposition {m : ℕ} (H : CubeSubgroup m) (v u : ClippingCube m)
    (hv : v ∉ (H.adjoinPoint u).carrier) (g : ClippingCube m → ℝ)
    (dual : Finset (Fin m) → ℝ) (ν : ClippingCube m → ℝ) (B C₀ : ℝ)
    (hbase : uniformCubeMean (fun z => walshExpansion dual z * reluReference z) = C₀)
    (hshift : walshExpansion dual u = 0)
    (hlive : ∀ z, cubeTranslation v z ∈ H.carrier →
      walshExpansion dual z = Fintype.card (ClippingCube m) * ν z)
    (hpartner : ∀ z, cubeTranslation v z ∈ H.carrier →
      walshExpansion dual (cubeTranslation u z) = 0) :
    B = C₀ + fourierDualDeficit dual g B +
      rectangleCalibrationSlack (walshExpansion dual) H v u g + linearCost ν (reluLiveMass H v g) := by
  have hM : (Fintype.card (ClippingCube m) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  have hpoint (z : ClippingCube m) :=
    rectangle_pairing_partition H v u hv g (walshExpansion dual) ν hshift hlive hpartner z
  have hpair : uniformCubeMean (fun z => walshExpansion dual z * g z) =
      C₀ + rectangleCalibrationSlack (walshExpansion dual) H v u g +
        linearCost ν (reluLiveMass H v g) := by
    calc
      _ = uniformCubeMean (fun z => walshExpansion dual z * reluReference z) +
          uniformCubeMean (fun z => walshExpansion dual z * (g z - reluReference z)) := by
        unfold uniformCubeMean
        rw [← add_div, ← Finset.sum_add_distrib]
        congr 1
        apply Finset.sum_congr rfl
        intro z _
        ring
      _ = _ := by
        rw [hbase]
        rw [show (fun z => walshExpansion dual z * (g z - reluReference z)) =
          (fun z => (if z ∈ rectangleObserved H v u then
            walshExpansion dual z * (g z - reluReference z) else 0) +
            Fintype.card (ClippingCube m) * (ν z * reluLiveMass H v g z)) from funext hpoint]
        unfold rectangleCalibrationSlack linearCost uniformCubeMean
        rw [Finset.sum_add_distrib, add_div, ← Finset.mul_sum]
        field_simp
        <;> ring
  unfold fourierDualDeficit
  linarith

/-- The observed signed margin and the literal dual signs control the
mean absolute calibration error. -/
theorem rectangle_calibration_deviation_bound {m : ℕ} (H : CubeSubgroup m)
    (v u : ClippingCube m) (dual g : ClippingCube m → ℝ) (a : ℝ)
    (hdualAnchor : a ≤ dual (cubeOne m))
    (hdualNegative : ∀ z, z ∈ rectangleNegativeObserved H v u → dual z ≤ -a)
    (hanchor : (1 : ℝ) / 2 ≤ g (cubeOne m))
    (hnegative : ∀ z, z ∈ rectangleNegativeObserved H v u → g z ≤ -(1 : ℝ) / 2) :
    a * uniformCubeMean (fun z => if z ∈ rectangleObserved H v u then
      |g z - reluReference z| else 0) ≤ rectangleCalibrationSlack dual H v u g := by
  have hpoint (z : ClippingCube m) :
      a * (if z ∈ rectangleObserved H v u then |g z - reluReference z| else 0) ≤
        (if z ∈ rectangleObserved H v u then dual z * (g z - reluReference z) else 0) := by
    by_cases hz : z ∈ rectangleObserved H v u
    · simp only [if_pos hz]
      by_cases hz0 : z = cubeOne m
      · subst z
        have href : reluReference (cubeOne m) = (1 : ℝ) / 2 := by
          norm_num [reluReference, pointIndicator]
        rw [href, abs_of_nonneg (by linarith)]
        exact mul_le_mul_of_nonneg_right hdualAnchor (by linarith)
      · have hn : z ∈ rectangleNegativeObserved H v u := ⟨hz, hz0⟩
        have hd := hdualNegative z hn
        have hg := hnegative z hn
        have href : reluReference z = -(1 : ℝ) / 2 := by
          simp [reluReference, pointIndicator, hz0]
        rw [href, abs_of_nonpos (by linarith)]
        nlinarith [mul_nonneg (by linarith : 0 ≤ -a - dual z)
          (by linarith : 0 ≤ -(g z + 1 / 2))]
    · simp only [if_neg hz, mul_zero, le_refl]
  have hmean := uniformCubeMean_mono _ _ hpoint
  rw [uniformCubeMean_mul] at hmean
  exact hmean

theorem rectangleCalibrationSlack_nonneg {m : ℕ} (H : CubeSubgroup m)
    (v u : ClippingCube m) (dual g : ClippingCube m → ℝ) (a : ℝ)
    (ha : 0 ≤ a) (hdualAnchor : a ≤ dual (cubeOne m))
    (hdualNegative : ∀ z, z ∈ rectangleNegativeObserved H v u → dual z ≤ -a)
    (hanchor : (1 : ℝ) / 2 ≤ g (cubeOne m))
    (hnegative : ∀ z, z ∈ rectangleNegativeObserved H v u → g z ≤ -(1 : ℝ) / 2) :
    0 ≤ rectangleCalibrationSlack dual H v u g := by
  have hbound := rectangle_calibration_deviation_bound H v u dual g a
    hdualAnchor hdualNegative hanchor hnegative
  have hmean : 0 ≤ uniformCubeMean (fun z => if z ∈ rectangleObserved H v u then
      |g z - reluReference z| else 0) := by
    apply div_nonneg _ (Nat.cast_nonneg _)
    exact Finset.sum_nonneg fun z _ => by split_ifs <;> positivity
  exact le_trans (mul_nonneg ha hmean) hbound

/-- The negative observed region inherits the same absolute-error budget. -/
theorem rectangle_negative_observed_deviation {m : ℕ} (H : CubeSubgroup m)
    (v u : ClippingCube m) (dual g : ClippingCube m → ℝ) (a : ℝ)
    (ha : 0 < a) (hdualAnchor : a ≤ dual (cubeOne m))
    (hdualNegative : ∀ z, z ∈ rectangleNegativeObserved H v u → dual z ≤ -a)
    (hanchor : (1 : ℝ) / 2 ≤ g (cubeOne m))
    (hnegative : ∀ z, z ∈ rectangleNegativeObserved H v u → g z ≤ -(1 : ℝ) / 2) :
    uniformCubeMean (fun z => if z ∈ rectangleNegativeObserved H v u then
      |g z + 1 / 2| else 0) ≤ rectangleCalibrationSlack dual H v u g / a := by
  have hsub : uniformCubeMean (fun z => if z ∈ rectangleNegativeObserved H v u then
      |g z + 1 / 2| else 0) ≤ uniformCubeMean (fun z =>
      if z ∈ rectangleObserved H v u then |g z - reluReference z| else 0) := by
    apply uniformCubeMean_mono
    intro z
    by_cases hz : z ∈ rectangleNegativeObserved H v u
    · simp only [if_pos hz, if_pos hz.1]
      simp only [reluReference, pointIndicator, if_neg hz.2, add_zero]
      ring_nf
      exact le_rfl
    · simp only [if_neg hz]
      split_ifs <;> positivity
  have hb := rectangle_calibration_deviation_bound H v u dual g a
    hdualAnchor hdualNegative hanchor hnegative
  exact le_trans hsub ((le_div_iff₀ ha).mpr (by nlinarith only [hb]))

/-- This anti-invariance estimate follows from actual Fourier slack and
actual calibrated margins; it is not an added geometric hypothesis. -/
theorem rectangle_calibrated_anti_invariance {m : ℕ} (H : CubeSubgroup m)
    (v u : ClippingCube m) (dual g : ClippingCube m → ℝ) (a ε : ℝ)
    (ha : 0 < a) (hdualAnchor : a ≤ dual (cubeOne m))
    (hdualNegative : ∀ z, z ∈ rectangleNegativeObserved H v u → dual z ≤ -a)
    (hanchor : (1 : ℝ) / 2 ≤ g (cubeOne m))
    (hnegative : ∀ z, z ∈ rectangleNegativeObserved H v u → g z ≤ -(1 : ℝ) / 2)
    (hdensity : (1 : ℝ) / 2 ≤ uniformCubeMean (fun z =>
      if z ∈ rectangleNegativeObserved H v u then 1 else 0))
    (hrem : ∀ z, |invariantRemainder u g z| ≤ ε) (z : ClippingCube m) :
    |g z + g (cubeTranslation u z) + 1| ≤
      4 * (ε + rectangleCalibrationSlack dual H v u g / a) := by
  have hs := rectangleCalibrationSlack_nonneg H v u dual g a ha.le
    hdualAnchor hdualNegative hanchor hnegative
  exact rectangle_anti_invariance_bound u g (rectangleNegativeObserved H v u)
    ε (rectangleCalibrationSlack dual H v u g / a) (div_nonneg hs ha.le)
    (rectangleNegativeObserved_invariant H v u) hdensity hrem
    (rectangle_negative_observed_deviation H v u dual g a ha hdualAnchor
      hdualNegative hanchor hnegative) z

end NeuralGeneralization.OnlineLowerGeometry
