import NeuralGeneralization.BatchTwoContinuousSphereElementary
import NeuralGeneralization.BatchTwoContinuousSphereMoments

/-! Gaussian cone probabilities from one independent scalar coordinate. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoContinuousSphere
open GaussianConeRadial

theorem measurable_cons (n : ℕ) :
    Measurable (fun z : ℝ × (Fin n → ℝ) => (Fin.cons z.1 z.2 : Fin (n+1) → ℝ)) := by
  apply measurable_pi_lambda
  intro i
  refine Fin.cases ?_ (fun j => ?_) i
  · simpa only [Fin.cons_zero] using (measurable_fst : Measurable (fun z : ℝ × (Fin n → ℝ) => z.1))
  · simpa only [Fin.cons_succ, Function.comp_def] using ((measurable_pi_apply j).comp measurable_snd :
      Measurable (fun z : ℝ × (Fin n → ℝ) => z.2 j))

theorem coordinateGaussian_cons (n : ℕ) :
    ((gaussianReal 0 1).prod (coordinateGaussian n)).map
      (fun z : ℝ × (Fin n → ℝ) => (Fin.cons z.1 z.2 : Fin (n+1) → ℝ)) = coordinateGaussian (n+1) := by
  have hh := (measurePreserving_piFinSuccAbove
    (fun _ : Fin (n+1) => gaussianReal 0 1) 0).symm.map_eq
  have he : ((MeasurableEquiv.piFinSuccAbove (fun _ : Fin (n+1) => ℝ) 0).symm :
      ℝ × (Fin n → ℝ) → (Fin (n+1) → ℝ)) = fun z => Fin.cons z.1 z.2 := by
    funext z
    simp only [MeasurableEquiv.piFinSuccAbove_symm_apply, Fin.insertNthEquiv,
      Fin.insertNth_zero, cast_eq]
    rfl
  rw [he] at hh
  exact hh

theorem radius_cons {n : ℕ} (x : ℝ) (y : Fin n → ℝ) :
    radius (Fin.cons x y) = Real.sqrt (x^2+(radius y)^2) := by
  simp only [radius, squaredRadius, Fin.sum_univ_succ, Fin.cons_zero, Fin.cons_succ]
  rw [Real.sq_sqrt (by positivity)]

theorem gaussian_coordinate_band (n : ℕ) {s : ℝ} (hs : 0 ≤ s) (hs1 : s ≤ 2/3) :
    coordinateGaussian (n+1) {x | |x 0| ≤ s*radius x} ≤
      ENNReal.ofReal ((3/2)*s*Real.sqrt ((n:ℝ)+1)) := by
  have hset : MeasurableSet {x : Fin (n+1) → ℝ | |x 0| ≤ s*radius x} :=
    measurableSet_le ((measurable_pi_apply 0).abs) ((measurable_radius (n+1)).const_mul s)
  rw [← coordinateGaussian_cons n, Measure.map_apply (measurable_cons n) hset,
    Measure.prod_apply_symm ((measurable_cons n) hset)]
  calc
    _ ≤ ∫⁻ y : Fin n → ℝ, ENNReal.ofReal ((3/2)*s*radius y) ∂coordinateGaussian n := by
      apply lintegral_mono
      intro y
      apply le_trans (b := (gaussianReal 0 1) {x : ℝ | |x| ≤ (3/2)*s*radius y})
      · apply measure_mono
        intro x hx
        change |(Fin.cons x y : Fin (n+1) → ℝ) 0| ≤ s*radius (Fin.cons x y : Fin (n+1) → ℝ) at hx
        simp only [Fin.cons_zero, radius_cons] at hx
        exact normalized_coordinate_band (radius_nonneg y) hs hs1 hx
      · exact gaussian_abs_small_ball (mul_nonneg (by positivity) (radius_nonneg y))
    _ = ENNReal.ofReal ((3/2)*s*(∫ y, radius y ∂coordinateGaussian n)) := by
      rw [← ofReal_integral_eq_lintegral_ofReal ((integrable_radius n).const_mul ((3/2)*s))
        (Filter.Eventually.of_forall (fun y => mul_nonneg (by positivity) (radius_nonneg y))), integral_const_mul]
    _ ≤ _ := ENNReal.ofReal_le_ofReal
      (mul_le_mul_of_nonneg_left (integral_radius_le_sqrt_succ n) (by positivity))

end NeuralGeneralization.BatchTwoContinuousSphere
