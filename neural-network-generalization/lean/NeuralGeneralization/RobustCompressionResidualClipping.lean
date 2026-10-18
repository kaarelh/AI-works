import NeuralGeneralization.RobustCompressionReconstruction
import NeuralGeneralization.RobustGaussianGeometryScalar
import NeuralGeneralization.GaussianConeRadial

/-! # Actual residual-coordinate clipping in a reconstructed layer -/
noncomputable section
open MeasureTheory ProbabilityTheory Matrix
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.RobustCompressionResidualClipping
open RobustGaussianGeometry RobustCompressionGaussian

variable {m q : ℕ}

theorem sourceResidualKernel_coordinate_law (D : Fin m → Fin q → ℝ)
    (hD : ∀ v : Fin q → ℝ, ∑ i, (Matrix.of D *ᵥ v) i ^ 2 ≤ ∑ j, v j ^ 2)
    (i : Fin m) :
    (sourceResidualKernel D).map (fun z => z i) =
      gaussianReal 0 (1 - ∑ k, D i k ^ 2).toNNReal := by
  have h := sourceResidualKernel_scalar_law D hD (Pi.single i 1)
  simpa [sourceResidualVariance, Pi.single_apply, Finset.mul_sum, mul_ite, ite_mul] using h

theorem sourceResidualKernel_coordinate_variance_le (D : Fin m → Fin q → ℝ)
    (i : Fin m) : ((1 - ∑ k, D i k ^ 2).toNNReal : ℝ) ≤ 1 := by
  rw [Real.coe_toNNReal']
  exact max_le (sub_le_self _ (Finset.sum_nonneg (fun _ _ => sq_nonneg _))) (by norm_num)

/-- The actual residual coefficient law, not an independent-coordinate
substitute, has small clipping error against every bounded source vector. -/
theorem sourceResidualKernel_clipping_error (D : Fin m → Fin q → ℝ)
    (hD : ∀ v : Fin q → ℝ, ∑ i, (Matrix.of D *ᵥ v) i ^ 2 ≤ ∑ j, v j ^ 2)
    (h : Fin m → ℝ) (hh : ∀ j, |h j| ≤ 1) {t B : ℝ}
    (ht : |t| ≤ 1) (hB : 0 < B) (hm : 0 < m) :
    (∫ z, ((t / Real.sqrt (m : ℝ)) *
      ∑ j, h j * (z j - gaussianClip B (z j))) ^ 2 ∂sourceResidualKernel D) ≤
        64 * (m : ℝ) / B ^ 2 := by
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  have ht2 : t ^ 2 ≤ 1 := by nlinarith [sq_abs t, abs_nonneg t]
  have hsum : (∑ j, h j ^ 2) ≤ (m : ℝ) := by
    calc
      _ ≤ ∑ _j : Fin m, (1 : ℝ) := Finset.sum_le_sum (fun j _ => by
        nlinarith [hh j, sq_abs (h j), abs_nonneg (h j)])
      _ = _ := by simp
  have hu : (∑ j, (t / Real.sqrt (m : ℝ) * h j) ^ 2) ≤ 1 := by
    simp_rw [mul_pow, ← Finset.mul_sum, div_pow, Real.sq_sqrt hm0.le]
    calc
      (t ^ 2 / (m : ℝ)) * ∑ j, h j ^ 2 ≤ (1 / (m : ℝ)) * (m : ℝ) :=
        mul_le_mul (div_le_div_of_nonneg_right ht2 hm0.le) hsum
          (Finset.sum_nonneg (fun _ _ => sq_nonneg _)) (by positivity)
      _ = 1 := by field_simp
  have hb := correlated_clip_linear_error (sourceResidualKernel D)
    (fun i z => z i) (fun i => measurable_pi_apply i)
    (fun i => (1 - ∑ k, D i k ^ 2).toNNReal)
    (sourceResidualKernel_coordinate_law D hD)
    (sourceResidualKernel_coordinate_variance_le D) B hB
    (fun j => t / Real.sqrt (m : ℝ) * h j) hu
  simpa only [mul_assoc, ← Finset.mul_sum] using hb

/-- Bounded Lipschitz activations can only improve the residual clipping cost.
The comparison uses the same actual correlated Gaussian coefficient row. -/
theorem sourceResidualKernel_activation_clipping_error
    (D : Fin m → Fin q → ℝ)
    (hD : ∀ v : Fin q → ℝ, ∑ i, (Matrix.of D *ᵥ v) i ^ 2 ≤ ∑ j, v j ^ 2)
    (u : Fin m → ℝ) (hu : ∑ j, u j ^ 2 ≤ 1)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hb : ∀ z, |φ z| ≤ 1)
    (b B : ℝ) (hB : 0 < B) :
    (∫ z, (φ (b + ∑ j, u j * z j) -
      φ (b + ∑ j, u j * gaussianClip B (z j))) ^ 2 ∂sourceResidualKernel D) ≤
        64 * (m : ℝ) / B ^ 2 := by
  let μ := sourceResidualKernel D
  let F : (Fin m → ℝ) → ℝ := fun z => (∑ j, u j * (z j - gaussianClip B (z j))) ^ 2
  let A : (Fin m → ℝ) → ℝ := fun z => (φ (b + ∑ j, u j * z j) -
      φ (b + ∑ j, u j * gaussianClip B (z j))) ^ 2
  have hcoord (j : Fin m) : Integrable (fun z => (z j - gaussianClip B (z j)) ^ 2) μ := by
    have hi := gaussian_clip_error_integrable (1 - ∑ k, D j k ^ 2).toNNReal B hB
    rw [← sourceResidualKernel_coordinate_law D hD j] at hi
    exact (integrable_map_measure
      ((measurable_id.sub (measurable_gaussianClip B)).pow_const 2).aestronglyMeasurable
      (measurable_pi_apply j).aemeasurable).mp hi
  have hsum : Integrable (fun z => ∑ j, (z j - gaussianClip B (z j)) ^ 2) μ :=
    integrable_finsetSum _ (fun j _ => hcoord j)
  have hFbound (z : Fin m → ℝ) : F z ≤ ∑ j, (z j - gaussianClip B (z j)) ^ 2 := by
    calc
      _ ≤ (∑ j, u j ^ 2) * ∑ j, (z j - gaussianClip B (z j)) ^ 2 :=
        Finset.sum_mul_sq_le_sq_mul_sq Finset.univ _ _
      _ ≤ 1 * ∑ j, (z j - gaussianClip B (z j)) ^ 2 :=
        mul_le_mul_of_nonneg_right hu (Finset.sum_nonneg (fun _ _ => sq_nonneg _))
      _ = _ := one_mul _
  have hmF : Measurable F := by dsimp [F, gaussianClip]; fun_prop
  have hFi : Integrable F μ := hsum.mono' hmF.aestronglyMeasurable
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
    nlinarith [sq_abs (φ (b + ∑ j, u j * z j) -
      φ (b + ∑ j, u j * gaussianClip B (z j))), sq_abs (∑ j, u j * (z j - gaussianClip B (z j))),
      abs_nonneg (φ (b + ∑ j, u j * z j) - φ (b + ∑ j, u j * gaussianClip B (z j))),
      abs_nonneg (∑ j, u j * (z j - gaussianClip B (z j)))]
  have hmA : Measurable A := by
    have hp := hφ.continuous.measurable
    dsimp [A, gaussianClip]
    fun_prop
  have hAi : Integrable A μ := hFi.mono' hmA.aestronglyMeasurable
    (Filter.Eventually.of_forall (fun z => by
      rw [Real.norm_eq_abs, abs_of_nonneg (sq_nonneg _)]
      exact hAF z))
  exact (integral_mono hAi hFi hAF).trans
    (correlated_clip_linear_error μ (fun j z => z j) (fun j => measurable_pi_apply j)
      (fun j => (1 - ∑ k, D j k ^ 2).toNNReal)
      (sourceResidualKernel_coordinate_law D hD)
      (sourceResidualKernel_coordinate_variance_le D) B hB u hu)

end NeuralGeneralization.RobustCompressionResidualClipping
