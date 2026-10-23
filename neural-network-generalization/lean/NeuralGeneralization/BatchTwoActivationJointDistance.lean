import NeuralGeneralization.BatchTwoActivationTailAtoms
import Mathlib.MeasureTheory.Constructions.BorelSpace.Order

/-!
# Joint measurability of the actual Gaussian residual budget

The coefficient matrix of a layer depends on previous layers. Measurability
for each fixed matrix therefore does not suffice. Positive box thresholds
give a strict feasible point, so the distance to the varying box body is
upper semicontinuous jointly in the matrix and source vector.
-/

noncomputable section
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation

variable {I : Type*} [Fintype I] {n : ℕ}

theorem linearBox_infDist_lt_iff (a : I → Fin n → ℝ) {B : ℝ} (hB : 0 < B)
    (x : EuclideanSpace ℝ (Fin n)) (r : ℝ) :
    Metric.infDist x (linearBoxBody a B) < r ↔
      ∃ u : EuclideanSpace ℝ (Fin n), (∀ i, |linearObservation a u i| < B) ∧
        dist x u < r := by
  constructor
  · intro h
    obtain ⟨u, hu, hxu⟩ := (Metric.infDist_lt_iff
      (linearBoxBody_nonempty a hB.le)).mp h
    let t := min (1 / 2 : ℝ) ((r - dist x u) / (2 * (‖u‖ + 1)))
    have ht : 0 < t := lt_min (by norm_num) (div_pos (sub_pos.mpr hxu) (by positivity))
    have ht1 : t ≤ 1 / 2 := min_le_left _ _
    have htn : t * (2 * (‖u‖ + 1)) ≤ r - dist x u :=
      (le_div_iff₀ (by positivity)).mp (min_le_right _ _)
    have htu : t * ‖u‖ < r - dist x u := by nlinarith [norm_nonneg u]
    refine ⟨(1-t) • u, ?_, ?_⟩
    · intro i
      rw [linearObservation_smul, abs_mul, abs_of_nonneg (by linarith)]
      have hh := mul_le_mul_of_nonneg_left (hu i) (show 0 ≤ 1-t by linarith)
      nlinarith
    · have he : dist u ((1-t) • u) = t * ‖u‖ := by
        rw [dist_eq_norm, show u-(1-t) • u=t • u by module,
          norm_smul, Real.norm_eq_abs, abs_of_pos ht]
      have hh := dist_triangle x u ((1-t) • u)
      rw [he] at hh
      linarith
  · rintro ⟨u, hu, hxu⟩
    have hm : u ∈ linearBoxBody a B := fun i => (hu i).le
    exact (Metric.infDist_le_dist_of_mem hm).trans_lt hxu

theorem linearBox_distance_upperSemicontinuous {B : ℝ} (hB : 0 < B) :
    UpperSemicontinuous (fun p : (I → Fin n → ℝ) × EuclideanSpace ℝ (Fin n) =>
      Metric.infDist p.2 (linearBoxBody p.1 B)) := by
  rw [upperSemicontinuous_iff_isOpen_preimage]
  intro r
  have he : (fun p : (I → Fin n → ℝ) × EuclideanSpace ℝ (Fin n) =>
      Metric.infDist p.2 (linearBoxBody p.1 B)) ⁻¹' Iio r =
      ⋃ u : EuclideanSpace ℝ (Fin n),
        {p | (∀ i, |linearObservation p.1 u i| < B) ∧ dist p.2 u < r} := by
    ext p
    simp only [mem_preimage, mem_Iio, mem_iUnion, mem_setOf_eq,
      linearBox_infDist_lt_iff _ hB]
  rw [he]
  apply isOpen_iUnion
  intro u
  have ha : IsOpen {p : (I → Fin n → ℝ) × EuclideanSpace ℝ (Fin n) |
      ∀ i, |linearObservation p.1 u i| < B} := by
    have hh : {p : (I → Fin n → ℝ) × EuclideanSpace ℝ (Fin n) |
        ∀ i, |linearObservation p.1 u i| < B} =
        ⋂ i, {p | |linearObservation p.1 u i| < B} := by ext p; simp
    rw [hh]
    apply isOpen_iInter_of_finite
    intro i
    apply isOpen_lt _ continuous_const
    unfold linearObservation
    fun_prop
  exact ha.inter (isOpen_lt (continuous_snd.dist continuous_const) continuous_const)

theorem linearBox_distance_joint_measurable {B : ℝ} (hB : 0 < B) :
    Measurable (fun p : (I → Fin n → ℝ) × EuclideanSpace ℝ (Fin n) =>
      Metric.infDist p.2 (linearBoxBody p.1 B)) :=
  (linearBox_distance_upperSemicontinuous hB).measurable

theorem gaussianBulkThreshold_pos {M : ℝ} (hM : 0 < M) :
    0 < gaussianBulkThreshold I M := by
  apply Real.sqrt_pos.mpr
  apply mul_pos (mul_pos (by norm_num) hM)
  apply Real.log_pos
  have := Nat.cast_nonneg (Fintype.card I) (α := ℝ)
  linarith

theorem gaussianResidualSource_norm_joint_measurable {M : ℝ} (hM : 0 < M) :
    Measurable (fun p : (I → Fin n → ℝ) × (Fin n → ℝ) =>
      ‖gaussianResidualSource p.1 M p.2‖) := by
  have he : (fun p : (I → Fin n → ℝ) × (Fin n → ℝ) =>
      ‖gaussianResidualSource p.1 M p.2‖) =
      (fun p : (I → Fin n → ℝ) × EuclideanSpace ℝ (Fin n) =>
        Metric.infDist p.2 (linearBoxBody p.1 (gaussianBulkThreshold I M))) ∘
        (fun p => (p.1, WithLp.toLp 2 p.2)) := by
    funext p
    exact convexProjection_distance _ _ _ _ _
  rw [he]
  exact (linearBox_distance_joint_measurable (gaussianBulkThreshold_pos hM)).comp
    (measurable_fst.prodMk ((PiLp.continuous_toLp 2 _).measurable.comp measurable_snd))

end NeuralGeneralization.BatchTwoActivation
