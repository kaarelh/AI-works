import NeuralGeneralization.BatchTwoImprovedIntervalDensity
import NeuralGeneralization.BatchTwoImprovedQuantileLimits

/-! # Compact Gaussian transport with literal probability measures and KL

The scalar inequality is now stated for the actual measurable quantile
coupling and Mathlib's Kullback--Leibler divergence. Thus it can be used with
the lower-semicontinuity theorem to pass to nonsmooth and unbounded laws.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter InformationTheory
open scoped Topology ENNReal

namespace NeuralGeneralization.BatchTwoImprovedGaussianTransport
open PositiveCDFTransport BatchTwoImprovedIntervalDensity BatchTwoImprovedQuantile

/-- On a common uniform seed, the analytic CDF transport sends the actual
source quantile exactly to the actual target quantile. -/
theorem interval_transport_quantiles {f g : ℝ → ℝ} {a b u : ℝ}
    (hf : Continuous f) (hfpos : ∀ x, 0 < f x)
    (hg : Continuous g) (hgpos : ∀ x, 0 < g x) (hab : a < b)
    (hu : u ∈ Ioo (0 : ℝ) 1) :
    transport hg hgpos hab f
      (BatchTwoImprovedQuantile.quantile (intervalDensity f a b) u) =
      BatchTwoImprovedQuantile.quantile (intervalDensity g a b) u := by
  rw [quantile_intervalDensity hf hfpos hab hu,
    quantile_intervalDensity hg hgpos hab hu]
  unfold transport
  rw [cdf_quantile hf hfpos hab ⟨hu.1.le, hu.2.le⟩]

/-- Integral formula for the actual quantile-coupling cost. -/
theorem interval_quantile_cost {f g : ℝ → ℝ} {a b : ℝ}
    (hf : Continuous f) (hfpos : ∀ x, 0 < f x)
    (hg : Continuous g) (hgpos : ∀ x, 0 < g x) (hab : a < b) :
    quantileQuadraticCost (intervalDensity g a b) (intervalDensity f a b) =
      ENNReal.ofReal (∫ x in a..b, (f x / mass f a b) *
        (transport hg hgpos hab f x - x)^2) := by
  letI := intervalDensity_probability hf hfpos hab
  letI := intervalDensity_probability hg hgpos hab
  let T := transport hg hgpos hab f
  have hT := continuous_transport hf hg hgpos hab
  have hc : Continuous (fun x => (T x - x)^2) := (hT.sub continuous_id).pow 2
  have hi := integrable_intervalDensity hf hfpos hab hc
  rw [← integral_intervalDensity hf hfpos hab,
    ofReal_integral_eq_lintegral_ofReal hi (Eventually.of_forall (fun _ => sq_nonneg _))]
  conv_rhs => rw [← quantile_pushforward (intervalDensity f a b)]
  rw [lintegral_map hc.measurable.ennreal_ofReal (measurable_quantile _)]
  unfold quantileQuadraticCost
  apply lintegral_congr_ae
  have hmem : ∀ᵐ u ∂uniformSeed, u ∈ Ioo (0 : ℝ) 1 :=
    ae_restrict_mem measurableSet_Ioo
  filter_upwards [hmem] with u hu
  dsimp only [T]
  rw [interval_transport_quantiles hf hfpos hg hgpos hab hu]

/-- Exact scalar T2 for compact Gaussian reference measures and every strictly
positive continuous target density. There is no transport or entropy estimate
among the premises. The left side is the explicit measurable coupling cost,
and the right side is the actual measure-theoretic KL divergence. -/
theorem compact_gaussian_quantile_cost_le_kl {g : ℝ → ℝ} {a b : ℝ}
    (hg : Continuous g) (hgpos : ∀ x, 0 < g x) (hab : a < b) :
    quantileQuadraticCost (intervalDensity g a b) (intervalDensity gaussianWeight a b) ≤
      2 * klDiv (intervalDensity g a b) (intervalDensity gaussianWeight a b) := by
  rw [interval_quantile_cost continuous_gaussianWeight gaussianWeight_pos hg hgpos hab,
    klDiv_intervalDensity continuous_gaussianWeight gaussianWeight_pos hg hgpos hab]
  have h := ENNReal.ofReal_le_ofReal (compact_gaussian_transport_entropy hg hgpos hab)
  rw [ENNReal.ofReal_mul (by norm_num : (0 : ℝ) ≤ 2)] at h
  norm_num only [ENNReal.ofReal_ofNat] at h
  exact h

end NeuralGeneralization.BatchTwoImprovedGaussianTransport
