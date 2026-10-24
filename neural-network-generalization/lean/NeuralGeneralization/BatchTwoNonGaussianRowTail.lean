import NeuralGeneralization.BatchTwoNonGaussianComparison
import NeuralGeneralization.TiltedRowSampling

/-! Coordinate tails under the actual law and its bounded tilts. These bounds
follow from curvature directly; no concentration theorem is a model field. -/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoNonGaussian
open CompressionSampling

theorem product_coordinate_real {J : Type*} [Fintype J] (μ : Measure ℝ)
    [IsProbabilityMeasure μ] (j : J) {B : ℝ} :
    (Measure.pi fun _ : J => μ).real {w : J → ℝ | B ≤ |w j|} = μ.real {x | B ≤ |x|} := by
  have hs : MeasurableSet {x : ℝ | B ≤ |x|} := measurableSet_le measurable_const measurable_id.abs
  have h := Measure.map_apply (μ := Measure.pi fun _ : J => μ) (measurable_pi_apply j) hs
  rw [(measurePreserving_eval (fun _ : J => μ) j).map_eq] at h
  exact congrArg ENNReal.toReal h.symm

theorem scalar_tail (ν : CoordinateLaw) {B : ℝ} (hB : 0 ≤ B) :
    ν.law.real {x | B ≤ |x|} ≤
      2 * ν.comparisonFactor ν.lowerCurvature * Real.exp (-(ν.lowerCurvature * B ^ 2) / 2) := by
  let v : ℝ≥0 := (1 / ν.lowerCurvature).toNNReal
  have hmpos := ν.lowerCurvature_pos
  have hv : (v : ℝ) = 1 / ν.lowerCurvature := Real.coe_toNNReal _ (by positivity)
  have h := GaussianTail.gaussian_linear_form_abs_tail (fun _ : Unit => v)
    (fun _ => 1) (1 / ν.lowerCurvature) B (by positivity) hB (by simp [hv])
  simp only [Finset.univ_unique, Finset.sum_singleton, one_mul] at h
  have heq : -B ^ 2 / (2 * (1 / ν.lowerCurvature)) = -(ν.lowerCurvature * B ^ 2) / 2 := by
    field_simp
  rw [heq] at h
  have hm := ν.product_measure_gaussian_upper (I := Unit)
  have hp := hm {w : Unit → ℝ | B ≤ |w ()|}
  have htop : (ENNReal.ofReal (ν.comparisonFactor ν.lowerCurvature ^ Fintype.card Unit) •
      Measure.pi (fun _ : Unit => gaussianReal 0 v)) {w | B ≤ |w ()|} ≠ ⊤ := by
    rw [Measure.smul_apply, smul_eq_mul]
    exact ENNReal.mul_ne_top ENNReal.ofReal_ne_top (measure_ne_top _ _)
  have hr := ENNReal.toReal_mono htop hp
  simp only [Measure.smul_apply, smul_eq_mul, ENNReal.toReal_mul, Fintype.card_unique,
    pow_one, ENNReal.toReal_ofReal (ν.comparisonFactor_pos _ ν.lowerCurvature_pos).le] at hr
  change (Measure.pi fun _ : Unit => ν.law).real {w | B ≤ |w ()|} ≤
    ν.comparisonFactor ν.lowerCurvature *
      (Measure.pi fun _ : Unit => gaussianReal 0 v).real {w | B ≤ |w ()|} at hr
  rw [product_coordinate_real] at hr
  exact hr.trans ((mul_le_mul_of_nonneg_left h
    (ν.comparisonFactor_pos _ ν.lowerCurvature_pos).le).trans_eq (by ring))

variable {J : Type*} [Fintype J] [DecidableEq J]

theorem actual_coordinate_tail (ν : CoordinateLaw) (j : J) {B : ℝ} (hB : 0 ≤ B) :
    (Measure.pi fun _ : J => ν.law).real {w : J → ℝ | B ≤ |w j|} ≤
      2 * ν.comparisonFactor ν.lowerCurvature * Real.exp (-(ν.lowerCurvature * B ^ 2) / 2) := by
  rw [product_coordinate_real]
  exact scalar_tail ν hB

theorem actual_tilted_coordinate_tail (ν : CoordinateLaw)
    (V : (J → ℝ) → ℝ) (hV : Measurable V) {G : ℝ} (hbound : ∀ w, |V w| ≤ G)
    (j : J) {B : ℝ} (hB : 0 ≤ B) :
    ((Measure.pi fun _ : J => ν.law).tilted V).real {w : J → ℝ | B ≤ |w j|} ≤
      2 * ν.comparisonFactor ν.lowerCurvature * Real.exp (2 * G - ν.lowerCurvature * B ^ 2 / 2) := by
  apply (BoundedTilt.tilted_measureReal_le _ V hV hbound _).trans
  calc
    _ ≤ Real.exp (2 * G) *
        (2 * ν.comparisonFactor ν.lowerCurvature * Real.exp (-(ν.lowerCurvature * B ^ 2) / 2)) :=
      mul_le_mul_of_nonneg_left (actual_coordinate_tail ν j hB) (Real.exp_pos _).le
    _ = _ := by
      rw [Real.exp_sub, neg_div, Real.exp_neg]
      ring

theorem actual_sampled_coordinate_tail (ν : CoordinateLaw)
    (V : (J → ℝ) → ℝ) (hV : Measurable V) {G : ℝ} (hbound : ∀ w, |V w| ≤ G)
    (N : ℕ) {B : ℝ} (hB : 0 ≤ B) :
    (iidSamples ((Measure.pi fun _ : J => ν.law).tilted V) N).real
      {w : Fin N → J → ℝ | ∃ i j, B ≤ |w i j|} ≤
      2 * ν.comparisonFactor ν.lowerCurvature * (N : ℝ) * (Fintype.card J : ℝ) *
        Real.exp (2 * G - ν.lowerCurvature * B ^ 2 / 2) := by
  let μ := (Measure.pi fun _ : J => ν.law).tilted V
  letI : IsProbabilityMeasure μ := BoundedTilt.tilted_probability _ V hV hbound
  let E (e : Fin N × J) : Set (Fin N → J → ℝ) := {w | B ≤ |w e.1 e.2|}
  have hi (e : Fin N × J) : (iidSamples μ N).real (E e) =
      μ.real {w : J → ℝ | B ≤ |w e.2|} := by
    have hs : MeasurableSet {w : J → ℝ | B ≤ |w e.2|} :=
      measurableSet_le measurable_const ((measurable_pi_apply e.2).abs)
    have h := Measure.map_apply (μ := iidSamples μ N) (measurable_pi_apply e.1) hs
    rw [show (iidSamples μ N).map (fun w => w e.1) = μ from
      (measurePreserving_eval (fun _ : Fin N => μ) e.1).map_eq] at h
    exact congrArg ENNReal.toReal h.symm
  have heq : {w : Fin N → J → ℝ | ∃ i j, B ≤ |w i j|} = ⋃ e, E e := by
    ext w
    simp only [E, Set.mem_setOf_eq, Set.mem_iUnion, Prod.exists]
  change (iidSamples μ N).real _ ≤ _
  rw [heq]
  calc
    _ ≤ ∑ e, (iidSamples μ N).real (E e) := measureReal_iUnion_fintype_le E
    _ ≤ ∑ _e : Fin N × J, 2 * ν.comparisonFactor ν.lowerCurvature *
        Real.exp (2 * G - ν.lowerCurvature * B ^ 2 / 2) := by
      apply Finset.sum_le_sum
      intro e he
      rw [hi]
      exact actual_tilted_coordinate_tail ν V hV hbound e.2 hB
    _ = _ := by simp [Fintype.card_prod]; ring

end NeuralGeneralization.BatchTwoNonGaussian
