import NeuralGeneralization.RobustCompressionResidualClipping

/-! Residual activation clipping with an arbitrary squared coefficient budget.
This applies to the actual correlated Gaussian row, without independence. -/
noncomputable section
open scoped BigOperators
open MeasureTheory ProbabilityTheory Matrix
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open RobustGaussianGeometry RobustCompressionGaussian RobustCompressionResidualClipping
variable {m q : ℕ}

theorem sourceResidualKernel_activation_clipping_error_budget
    (D : Fin m → Fin q → ℝ)
    (hD : ∀ v : Fin q → ℝ, ∑ i, (Matrix.of D *ᵥ v) i ^ 2 ≤ ∑ j, v j ^ 2)
    (u : Fin m → ℝ) {R : ℝ} (hR : 0 ≤ R) (hu : ∑ j, u j ^ 2 ≤ R)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (b B : ℝ) (hB : 0 < B) :
    (∫ z, (φ (b + ∑ j, u j * z j) -
      φ (b + ∑ j, u j * gaussianClip B (z j))) ^ 2 ∂sourceResidualKernel D) ≤
        64 * R * (m : ℝ) / B ^ 2 := by
  let μ := sourceResidualKernel D
  let F : (Fin m → ℝ) → ℝ := fun z => (∑ j, u j * (z j - gaussianClip B (z j))) ^ 2
  let A : (Fin m → ℝ) → ℝ := fun z => (φ (b + ∑ j, u j * z j) -
      φ (b + ∑ j, u j * gaussianClip B (z j))) ^ 2
  let S : (Fin m → ℝ) → ℝ := fun z => ∑ j, (z j - gaussianClip B (z j)) ^ 2
  have hcoord (j : Fin m) : Integrable (fun z => (z j - gaussianClip B (z j)) ^ 2) μ := by
    have hi := gaussian_clip_error_integrable (1 - ∑ k, D j k ^ 2).toNNReal B hB
    rw [← sourceResidualKernel_coordinate_law D hD j] at hi
    exact (integrable_map_measure
      ((measurable_id.sub (measurable_gaussianClip B)).pow_const 2).aestronglyMeasurable
      (measurable_pi_apply j).aemeasurable).mp hi
  have hsum : Integrable S μ := integrable_finsetSum _ (fun j _ => hcoord j)
  have hFbound (z : Fin m → ℝ) : F z ≤ R*S z := by
    exact (Finset.sum_mul_sq_le_sq_mul_sq Finset.univ _ _).trans
      (mul_le_mul_of_nonneg_right hu (Finset.sum_nonneg (fun _ _ => sq_nonneg _)))
  have hmF : Measurable F := by dsimp [F, gaussianClip]; fun_prop
  have hFi : Integrable F μ := (hsum.const_mul R).mono' hmF.aestronglyMeasurable
    (Filter.Eventually.of_forall (fun z => by
      rw [Real.norm_eq_abs, abs_of_nonneg (sq_nonneg _)]
      exact hFbound z))
  have hAF (z : Fin m → ℝ) : A z ≤ F z := by
    have hl := hφ.dist_le_mul (b + ∑ j, u j * z j)
      (b + ∑ j, u j * gaussianClip B (z j))
    have heq : (b + ∑ j, u j * z j) - (b + ∑ j, u j * gaussianClip B (z j)) =
        ∑ j, u j * (z j - gaussianClip B (z j)) := by
      simp_rw [mul_sub, Finset.sum_sub_distrib]
      ring
    simp only [Real.dist_eq, NNReal.coe_one, one_mul, heq] at hl
    dsimp [A, F]
    exact sq_le_sq.mpr hl
  have hmA : Measurable A := by
    have hp := hφ.continuous.measurable
    dsimp [A, gaussianClip]
    fun_prop
  have hAi : Integrable A μ := hFi.mono' hmA.aestronglyMeasurable
    (Filter.Eventually.of_forall (fun z => by
      rw [Real.norm_eq_abs, abs_of_nonneg (sq_nonneg _)]
      exact hAF z))
  have hsumBound := correlated_clip_error_sum μ (fun j z => z j) (fun j => measurable_pi_apply j)
    (fun j => (1 - ∑ k, D j k ^ 2).toNNReal)
    (sourceResidualKernel_coordinate_law D hD)
    (sourceResidualKernel_coordinate_variance_le D) B hB
  change (∫ z, A z ∂μ) ≤ _
  calc
    _ ≤ ∫ z, F z ∂μ := integral_mono hAi hFi hAF
    _ ≤ ∫ z, R*S z ∂μ := integral_mono hFi (hsum.const_mul R) hFbound
    _ = R*(∫ z, S z ∂μ) := integral_const_mul _ _
    _ ≤ R*(64*(m : ℝ)/B^2) := mul_le_mul_of_nonneg_left hsumBound hR
    _ = _ := by ring

theorem sourceResidualKernel_activation_clipping_error_two
    (D : Fin m → Fin q → ℝ)
    (hD : ∀ v : Fin q → ℝ, ∑ i, (Matrix.of D *ᵥ v) i ^ 2 ≤ ∑ j, v j ^ 2)
    (u : Fin m → ℝ) (hu : ∑ j, u j ^ 2 ≤ 2)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (b B : ℝ) (hB : 0 < B) :
    (∫ z, (φ (b + ∑ j, u j * z j) -
      φ (b + ∑ j, u j * gaussianClip B (z j))) ^ 2 ∂sourceResidualKernel D) ≤
        128 * (m : ℝ) / B ^ 2 := by
  simpa only [show (64 : ℝ)*2=128 by norm_num] using
    sourceResidualKernel_activation_clipping_error_budget D hD u (by norm_num) hu φ hφ b B hB

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
