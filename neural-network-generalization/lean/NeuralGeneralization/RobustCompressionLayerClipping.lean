import NeuralGeneralization.RobustCompressionLayerGaussian
import NeuralGeneralization.RobustCompressionResidualClipping

/-!
# Clipping all actual Gaussian residual coefficient rows

The right law remains the independent product of the actual correlated row
laws. The estimate then transfers through the exact second marginal of the
full evaluated-field coupling.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Matrix
open scoped BigOperators NNReal
namespace NeuralGeneralization.RobustCompressionLayerGaussian
open RobustCompressionGaussian RobustGaussianGeometry RobustCompressionResidualClipping

variable {A : Type*} [MeasurableSpace A] {N m q : ℕ}

def clippedResidualEvaluation (b : Fin N → ℝ) (h : Fin m → ℝ) (t B : ℝ)
    (ξ : Fin N → Fin m → ℝ) : Fin N → ℝ :=
  fun i => b i + t / Real.sqrt (m : ℝ) * ∑ j, h j * gaussianClip B (ξ i j)

theorem residual_coefficients_normalized (h : Fin m → ℝ) (hh : ∀ j, |h j| ≤ 1)
    {t : ℝ} (ht : |t| ≤ 1) (hm : 0 < m) :
    (∑ j, (t / Real.sqrt (m : ℝ) * h j) ^ 2) ≤ 1 := by
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  have ht2 : t ^ 2 ≤ 1 := by nlinarith [sq_abs t, abs_nonneg t]
  have hsum : (∑ j, h j ^ 2) ≤ (m : ℝ) := by
    calc
      _ ≤ ∑ _j : Fin m, (1 : ℝ) := Finset.sum_le_sum (fun j _ => by
        nlinarith [hh j, sq_abs (h j), abs_nonneg (h j)])
      _ = _ := by simp
  simp_rw [mul_pow, ← Finset.mul_sum, div_pow, Real.sq_sqrt hm0.le]
  calc
    (t ^ 2 / (m : ℝ)) * ∑ j, h j ^ 2 ≤ (1 / (m : ℝ)) * (m : ℝ) :=
      mul_le_mul (div_le_div_of_nonneg_right ht2 hm0.le) hsum
        (Finset.sum_nonneg (fun _ _ => sq_nonneg _)) (by positivity)
    _ = 1 := by field_simp

theorem residualRows_activation_clipping_error
    (D : Fin m → Fin q → ℝ)
    (hD : ∀ u : Fin q → ℝ, ∑ i, (Matrix.of D *ᵥ u) i ^ 2 ≤ ∑ j, u j ^ 2)
    (b : Fin N → ℝ) (h : Fin m → ℝ) (hh : ∀ j, |h j| ≤ 1)
    {t B : ℝ} (ht : |t| ≤ 1) (hB : 0 < B) (hm : 0 < m)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hb : ∀ z, |φ z| ≤ 1) :
    (∫ ξ, ∑ i, (φ (residualEvaluation b h t ξ i) -
      φ (clippedResidualEvaluation b h t B ξ i)) ^ 2
      ∂Measure.pi (fun _ : Fin N => sourceResidualKernel D)) ≤
        64 * (N : ℝ) * m / B ^ 2 := by
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
    _ ≤ ∑ _i : Fin N, 64 * (m : ℝ) / B ^ 2 := by
      apply Finset.sum_le_sum
      intro i hi
      rw [integral_comp_eval (μ := fun _ : Fin N => sourceResidualKernel D)
        (i := i) (f := F i) (hFm i).aestronglyMeasurable]
      have hc := sourceResidualKernel_activation_clipping_error D hD
        (fun j => t / Real.sqrt (m : ℝ) * h j)
        (residual_coefficients_normalized h hh ht hm) φ hφ hb (b i) B hB
      simpa only [F, mul_assoc, ← Finset.mul_sum] using hc
    _ = _ := by simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      nsmul_eq_mul]; ring

namespace GaussianLayerParameters

def clippedFiniteObservable (p : GaussianLayerParameters A N m q) (B : ℝ) :
    A × (Fin N → Fin m → ℝ) → (Fin N → ℝ) :=
  fun z => clippedResidualEvaluation (p.finiteMean z.1) (p.sourceFeature z.1) p.scale B z.2

theorem clippedFiniteObservable_measurable (p : GaussianLayerParameters A N m q) (B : ℝ) :
    Measurable (p.clippedFiniteObservable B) := by
  have hb := p.finiteMean_measurable
  have hh := p.sourceFeature_measurable
  unfold clippedFiniteObservable clippedResidualEvaluation gaussianClip
  fun_prop

theorem fullCoupling_activation_clipping_error (p : GaussianLayerParameters A N m q)
    (hp : p.Contractive) (θ : A) (hh : ∀ j, |p.sourceFeature θ j| ≤ 1)
    (ht : |p.scale| ≤ 1) {B : ℝ} (hB : 0 < B) (hm : 0 < m)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hb : ∀ z, |φ z| ≤ 1) :
    (∫ z, ∑ i, (φ (p.finiteObservable (θ, z.2) i) -
      φ (p.clippedFiniteObservable B (θ, z.2) i)) ^ 2 ∂p.fullCoupling θ) ≤
        64 * (N : ℝ) * m / B ^ 2 := by
  have hc := residualRows_activation_clipping_error (p.sourceMatrix θ) (hp θ)
    (p.finiteMean θ) (p.sourceFeature θ) hh ht hB hm φ hφ hb
  rw [← p.fullCoupling_snd θ] at hc
  have hφm := hφ.continuous.measurable
  rw [integral_map measurable_snd.aemeasurable (by
    dsimp [residualEvaluation, clippedResidualEvaluation, gaussianClip]
    fun_prop)] at hc
  exact hc

end GaussianLayerParameters
end NeuralGeneralization.RobustCompressionLayerGaussian
