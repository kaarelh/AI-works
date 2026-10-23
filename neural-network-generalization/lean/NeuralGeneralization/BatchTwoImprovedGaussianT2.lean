import NeuralGeneralization.BatchTwoImprovedGaussianTruncation
import Mathlib.MeasureTheory.Measure.Decomposition.IntegralRNDeriv

/-! # Sharp scalar Gaussian transport, including conditional kernels

The theorem concerns every Borel probability law. The transport kernel is
jointly measurable, has the exact marginals, and its actual squared displacement
is bounded by twice the actual relative entropy.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter InformationTheory
open scoped Topology ENNReal ProbabilityTheory

namespace NeuralGeneralization.BatchTwoImprovedGaussianTransport
open BatchTwoImprovedQuantile BatchTwoImprovedDensityMeasure

/-- Scalar Gaussian T2 with no density regularity assumptions and with the
infinite-entropy case included. -/
theorem gaussian_quantile_cost_le_kl (P : Measure ℝ) [IsProbabilityMeasure P] :
    quantileQuadraticCost P (gaussianReal 0 1) ≤ 2 * klDiv P (gaussianReal 0 1) := by
  by_cases hK : klDiv P (gaussianReal 0 1) = ∞
  · simp [hK]
  obtain ⟨hac, hllr⟩ := klDiv_ne_top_iff.mp hK
  let μ := gaussianReal 0 1
  let ρ := fun x => (P.rnDeriv μ x).toReal
  have hm : Measurable ρ := (Measure.measurable_rnDeriv P μ).ennreal_toReal
  have hi : Integrable ρ μ := Measure.integrable_toReal_rnDeriv
  have hpos (x : ℝ) : 0 ≤ ρ x := ENNReal.toReal_nonneg
  have hmass : (∫ x, ρ x ∂μ) = 1 := by
    simpa using Measure.integral_toReal_rnDeriv hac
  have he : Integrable (fun x => ρ x*Real.log (ρ x)) μ :=
    (integrable_rnDeriv_mul_log_iff hac).mpr hllr
  have hP : densityLaw μ ρ = P := by
    rw [densityLaw, ← Measure.withDensity_rnDeriv_eq P μ hac]
    apply withDensity_congr_ae
    filter_upwards [Measure.rnDeriv_lt_top P μ] with x hx
    exact ENNReal.ofReal_toReal hx.ne
  have h := gaussian_density_cost_le_kl ρ hm hi hpos hmass he
  rw [hP] at h
  exact h

def scalarSquaredCost (p : ℝ × ℝ) : ℝ≥0∞ := ENNReal.ofReal ((p.1-p.2)^2)

@[fun_prop] theorem measurable_scalarSquaredCost : Measurable scalarSquaredCost := by
  unfold scalarSquaredCost
  fun_prop

variable {Θ : Type*} [MeasurableSpace Θ]

/-- A uniform sharp bound for the explicitly measurable conditional quantile
coupling. There is no implicit measurable-selection premise. -/
theorem quantileCouplingKernel_gaussian_cost_le (κ : Kernel Θ ℝ)
    [IsMarkovKernel κ] (θ : Θ) :
    (∫⁻ p, scalarSquaredCost p ∂quantileCouplingKernel κ
      (Kernel.const Θ (gaussianReal 0 1)) θ) ≤
      2 * klDiv (κ θ) (gaussianReal 0 1) := by
  rw [quantileCouplingKernel_apply, lintegral_map measurable_scalarSquaredCost
    ((measurable_quantile (κ θ)).prodMk (measurable_quantile _))]
  exact gaussian_quantile_cost_le_kl (κ θ)

end NeuralGeneralization.BatchTwoImprovedGaussianTransport
