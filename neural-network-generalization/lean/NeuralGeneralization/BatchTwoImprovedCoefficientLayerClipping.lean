import NeuralGeneralization.BatchTwoImprovedCoefficientClipping
import NeuralGeneralization.RobustCompressionLayerClipping

/-! Weighted-energy clipping for all actual Gaussian residual rows and the
actual joint coupling. No coordinatewise source-feature bound is required. -/
noncomputable section
open MeasureTheory ProbabilityTheory Matrix
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open RobustCompressionGaussian RobustGaussianGeometry RobustCompressionResidualClipping
open RobustCompressionLayerGaussian
variable {A : Type*} [MeasurableSpace A] {N m q : ℕ}

theorem residualRows_activation_clipping_error_two
    (D : Fin m → Fin q → ℝ)
    (hD : ∀ u : Fin q → ℝ, ∑ i, (Matrix.of D *ᵥ u) i ^ 2 ≤ ∑ j, u j ^ 2)
    (b : Fin N → ℝ) (h : Fin m → ℝ)
    {t B : ℝ} (hu : ∑ j, (t / Real.sqrt (m : ℝ) * h j) ^ 2 ≤ 2) (hB : 0 < B)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hb : ∀ z, |φ z| ≤ 1) :
    (∫ ξ, ∑ i, (φ (residualEvaluation b h t ξ i) -
      φ (clippedResidualEvaluation b h t B ξ i)) ^ 2
      ∂Measure.pi (fun _ : Fin N => sourceResidualKernel D)) ≤
        128 * (N : ℝ) * m / B ^ 2 := by
  let F : Fin N → (Fin m → ℝ) → ℝ := fun i z =>
    (φ (b i + t / Real.sqrt (m : ℝ) * ∑ j, h j * z j) -
      φ (b i + t / Real.sqrt (m : ℝ) * ∑ j, h j * gaussianClip B (z j))) ^ 2
  have hφm := hφ.continuous.measurable
  have hFm (i : Fin N) : Measurable (F i) := by dsimp [F, gaussianClip]; fun_prop
  have hFi (i : Fin N) : Integrable (F i) (sourceResidualKernel D) := by
    apply (integrable_const (4 : ℝ)).mono' (hFm i).aestronglyMeasurable
    exact Filter.Eventually.of_forall fun z => by
      rw [Real.norm_of_nonneg (sq_nonneg _)]
      have h1 := abs_le.mp (hb (b i + t / Real.sqrt (m : ℝ) * ∑ j, h j * z j))
      have h2 := abs_le.mp (hb (b i + t / Real.sqrt (m : ℝ) * ∑ j, h j * gaussianClip B (z j)))
      nlinarith
  change (∫ ξ, ∑ i, F i (ξ i) ∂Measure.pi (fun _ : Fin N => sourceResidualKernel D)) ≤ _
  rw [integral_finsetSum Finset.univ (fun i _ =>
    integrable_comp_eval (μ := fun _ : Fin N => sourceResidualKernel D) (i := i) (hFi i))]
  calc
    _ ≤ ∑ _i : Fin N, 128 * (m : ℝ) / B ^ 2 := by
      apply Finset.sum_le_sum
      intro i hi
      rw [integral_comp_eval (μ := fun _ : Fin N => sourceResidualKernel D)
        (i := i) (f := F i) (hFm i).aestronglyMeasurable]
      have hc := sourceResidualKernel_activation_clipping_error_two D hD
        (fun j => t / Real.sqrt (m : ℝ) * h j)
        hu φ hφ (b i) B hB
      simpa only [F, mul_assoc, ← Finset.mul_sum] using hc
    _ = _ := by simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      nsmul_eq_mul]; ring


theorem fullCoupling_activation_clipping_error_two (p : GaussianLayerParameters A N m q)
    (hp : p.Contractive) (θ : A)
    (hu : ∑ j, (p.scale / Real.sqrt (m : ℝ) * p.sourceFeature θ j) ^ 2 ≤ 2)
    {B : ℝ} (hB : 0 < B)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hb : ∀ z, |φ z| ≤ 1) :
    (∫ z, ∑ i, (φ (p.finiteObservable (θ, z.2) i) -
      φ (p.clippedFiniteObservable B (θ, z.2) i)) ^ 2 ∂p.fullCoupling θ) ≤
        128 * (N : ℝ) * m / B ^ 2 := by
  have hc := residualRows_activation_clipping_error_two (p.sourceMatrix θ) (hp θ)
    (p.finiteMean θ) (p.sourceFeature θ) hu hB φ hφ hb
  rw [← p.fullCoupling_snd θ] at hc
  have hφm := hφ.continuous.measurable
  rw [integral_map measurable_snd.aemeasurable (by
    dsimp [residualEvaluation, clippedResidualEvaluation, gaussianClip]
    fun_prop)] at hc
  exact hc


end NeuralGeneralization.BatchTwoImprovedWeightedSampling
