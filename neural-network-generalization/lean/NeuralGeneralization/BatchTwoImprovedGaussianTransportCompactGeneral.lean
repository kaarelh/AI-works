import NeuralGeneralization.BatchTwoImprovedGaussianTransportBounded
import NeuralGeneralization.BatchTwoImprovedDensityTruncation

/-! # Compact Gaussian transport for every finite-entropy density

The positive lower and upper bounds are removed using explicit normalized
clipping, with actual L1 and entropy convergence. This is not a theorem
conditional on the desired transport inequality.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter InformationTheory
open scoped Topology ENNReal

namespace NeuralGeneralization.BatchTwoImprovedGaussianTransport
open BatchTwoImprovedIntervalDensity BatchTwoImprovedQuantile
open BatchTwoImprovedDensityApprox BatchTwoImprovedDensityMeasure

/-- The compact Gaussian T2 inequality for an arbitrary measurable density of
finite entropy, including unbounded densities and densities which vanish. -/
theorem compact_gaussian_density_cost_le_kl {a b : ℝ} (hab : a < b)
    (ρ : ℝ → ℝ) (hm : Measurable ρ)
    (hi : Integrable ρ (intervalDensity gaussianWeight a b))
    (hpos : ∀ x, 0 ≤ ρ x)
    (hmass : ∫ x, ρ x ∂intervalDensity gaussianWeight a b = 1)
    (hent : Integrable (fun x => ρ x * Real.log (ρ x))
      (intervalDensity gaussianWeight a b)) :
    quantileQuadraticCost (densityLaw (intervalDensity gaussianWeight a b) ρ)
      (intervalDensity gaussianWeight a b) ≤
      2 * klDiv (densityLaw (intervalDensity gaussianWeight a b) ρ)
        (intervalDensity gaussianWeight a b) := by
  let μ := intervalDensity gaussianWeight a b
  letI : IsProbabilityMeasure μ :=
    intervalDensity_probability continuous_gaussianWeight gaussianWeight_pos hab
  let f := normalizedDensityClip μ ρ
  have hfprop := normalizedDensityClip_properties μ ρ hi hpos
  have hfi (n : ℕ) : Integrable (f n) μ := (hfprop n).1
  have hfmass (n : ℕ) : (∫ x, f n x ∂μ) = 1 := (hfprop n).2.1
  have hfpos (n : ℕ) (x : ℝ) : 0 ≤ f n x := by
    exact (div_pos (densityClip_pos n _) (densityClip_mass_pos μ ρ hi hpos n)).le
  have hfm (n : ℕ) : Measurable (f n) :=
    ((continuous_densityClip n).measurable.comp hm).div_const _
  have hfent (n : ℕ) : Integrable (fun x => f n x*Real.log (f n x)) μ := by
    obtain ⟨lo, up, hlo, _, hbnd⟩ := (hfprop n).2.2
    exact integrable_mul_log_of_bounds μ (f n) (hfi n).aestronglyMeasurable
      hlo (Eventually.of_forall hbnd)
  let P := fun n => densityLaw μ (f n)
  let Q := densityLaw μ ρ
  letI (n : ℕ) : IsProbabilityMeasure (P n) :=
    densityLaw_probability μ (f n) (hfi n) (hfpos n) (hfmass n)
  letI : IsProbabilityMeasure Q := densityLaw_probability μ ρ hi hpos hmass
  have hCDF : ∀ x, Tendsto (fun n => cdf (P n) x) atTop (𝓝 (cdf Q x)) :=
    cdf_densityLaw_tendsto_of_l1 μ f ρ hfi hi hfpos hpos hfmass hmass
      (normalizedDensityClip_l1_tendsto μ ρ hi hpos hmass)
  have hKL : Tendsto (fun n => 2 * klDiv (P n) μ) atTop (𝓝 (2 * klDiv Q μ)) := by
    have hne (n : ℕ) : klDiv (P n) μ = ENNReal.ofReal
        (∫ x, f n x*Real.log (f n x) ∂μ) :=
      klDiv_densityLaw μ (f n) (hfm n) (hfi n) (hfpos n) (hfmass n) (hfent n)
    have hqe : klDiv Q μ = ENNReal.ofReal (∫ x, ρ x*Real.log (ρ x) ∂μ) :=
      klDiv_densityLaw μ ρ hm hi hpos hmass hent
    simp_rw [hne, hqe]
    exact (ENNReal.continuous_const_mul (a := 2) (by norm_num)).tendsto _ |>.comp
      (ENNReal.continuous_ofReal.tendsto _ |>.comp
        (normalizedDensityClip_entropy_tendsto μ ρ hi hpos hmass hent))
  apply quantileQuadraticCost_le_of_cdf_limits P (fun _ => μ) Q μ hCDF
    (fun _ => tendsto_const_nhds) (fun n => 2 * klDiv (P n) μ)
    (2 * klDiv Q μ) hKL
  intro n
  obtain ⟨lo, up, hlo, hloup, hbnd⟩ := (hfprop n).2.2
  exact compact_gaussian_bounded_density_cost_le_kl hab hlo hloup (f n)
    (hfm n) (hfi n) hbnd (hfmass n)

end NeuralGeneralization.BatchTwoImprovedGaussianTransport
