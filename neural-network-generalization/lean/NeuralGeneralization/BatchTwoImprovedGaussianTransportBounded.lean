import NeuralGeneralization.BatchTwoImprovedGaussianTransportMeasure
import NeuralGeneralization.BatchTwoImprovedDensityApprox
import NeuralGeneralization.BatchTwoImprovedDensityMeasure
import Mathlib.Analysis.SpecificLimits.Basic

/-! # Compact Gaussian transport for bounded measurable densities

Positive continuous approximation is constructed in L1 and entropy. Its
probability laws converge through their actual CDFs; the explicit quantile
coupling cost passes to the limit by Fatou.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter InformationTheory
open scoped Topology ENNReal

namespace NeuralGeneralization.BatchTwoImprovedGaussianTransport
open PositiveCDFTransport BatchTwoImprovedIntervalDensity BatchTwoImprovedQuantile
open BatchTwoImprovedDensityApprox BatchTwoImprovedDensityMeasure

/-- Multiplication of an interval density by a continuous normalized density
has exactly the expected ordinary Lebesgue density. -/
theorem densityLaw_intervalDensity_mul {f h : ℝ → ℝ} {a b : ℝ}
    (hf : Continuous f) (hfpos : ∀ x, 0 < f x)
    (hh : Continuous h) (hhpos : ∀ x, 0 < h x) (hab : a < b)
    (hmass : ∫ x, h x ∂intervalDensity f a b = 1) :
    densityLaw (intervalDensity f a b) h =
      intervalDensity (fun x => f x*h x) a b := by
  have hF := mass_pos hf hfpos hab
  have hM : mass (fun x => f x*h x) a b = mass f a b := by
    rw [integral_intervalDensity hf hfpos hab] at hmass
    have heq : (fun x => (f x / mass f a b)*h x) =
        (fun x => (f x*h x)/mass f a b) := by funext x; ring
    rw [heq, intervalIntegral.integral_div] at hmass
    exact (div_eq_one_iff_eq hF.ne').mp hmass
  unfold densityLaw intervalDensity
  rw [← withDensity_mul _ ((hf.measurable.div_const _).ennreal_ofReal)
    hh.measurable.ennreal_ofReal]
  apply withDensity_congr_ae
  filter_upwards with x
  simp only [Pi.mul_apply]
  rw [← ENNReal.ofReal_mul (div_pos (hfpos x) hF).le, hM]
  congr 1
  ring

/-- T2 for every measurable density bounded above and bounded away from zero
relative to the compact Gaussian law. The density need not be continuous. -/
theorem compact_gaussian_bounded_density_cost_le_kl {a b lo hi : ℝ}
    (hab : a < b) (hlo : 0 < lo) (hlohi : lo ≤ hi)
    (ρ : ℝ → ℝ) (hρm : Measurable ρ)
    (hρi : Integrable ρ (intervalDensity gaussianWeight a b))
    (hρb : ∀ x, ρ x ∈ Icc lo hi)
    (hρmass : ∫ x, ρ x ∂intervalDensity gaussianWeight a b = 1) :
    quantileQuadraticCost (densityLaw (intervalDensity gaussianWeight a b) ρ)
      (intervalDensity gaussianWeight a b) ≤
      2 * klDiv (densityLaw (intervalDensity gaussianWeight a b) ρ)
        (intervalDensity gaussianWeight a b) := by
  let μ := intervalDensity gaussianWeight a b
  letI : IsProbabilityMeasure μ :=
    intervalDensity_probability continuous_gaussianWeight gaussianWeight_pos hab
  let e := fun n : ℕ => (1 / ((n:ℝ)+1))/2
  have hepos (n : ℕ) : 0 < e n := by dsimp [e]; positivity
  have hesmall (n : ℕ) : e n ≤ 1/2 := by
    have h := one_div_le_one_div_of_le (by norm_num : (0:ℝ) < 1)
      (show (1:ℝ) ≤ (n:ℝ)+1 by linarith [Nat.cast_nonneg (α := ℝ) n])
    dsimp [e]
    simpa only [div_one] using div_le_div_of_nonneg_right h (by norm_num : (0:ℝ) ≤ 2)
  have hezero : Tendsto e atTop (𝓝 0) := by
    simpa only [zero_div] using
      (tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)).div_const 2
  have hex (n : ℕ) := exists_continuous_normalized_approx μ ρ hρi hρmass
    hlo hlohi (Eventually.of_forall hρb) (hepos n) (hesmall n)
  choose h hc hb hInt hMass hL1 hEntropy using hex
  have hpos (n : ℕ) (x : ℝ) : 0 < h n x :=
    (by positivity : (0:ℝ) < lo/2).trans_le (hb n x).1
  let P := fun n => densityLaw μ (h n)
  let Q := densityLaw μ ρ
  have hρpos (x : ℝ) : 0 ≤ ρ x := (hlo.trans_le (hρb x).1).le
  letI (n : ℕ) : IsProbabilityMeasure (P n) :=
    densityLaw_probability μ (h n) (hInt n) (fun x => (hpos n x).le) (hMass n)
  letI : IsProbabilityMeasure Q := densityLaw_probability μ ρ hρi hρpos hρmass
  have hρent := integrable_mul_log_of_bounds μ ρ hρi.aestronglyMeasurable
    hlo (Eventually.of_forall hρb)
  have hEntInt (n : ℕ) := integrable_mul_log_of_bounds μ (h n) (hInt n).aestronglyMeasurable
    (by positivity : (0:ℝ) < lo/2) (Eventually.of_forall (hb n))
  have hL1zero : Tendsto (fun n => ∫ x, |h n x-ρ x| ∂μ) atTop (𝓝 0) := by
    apply squeeze_zero (fun n => integral_nonneg (fun _ => abs_nonneg _)) hL1
    simpa only [mul_zero] using hezero.const_mul 2
  have hJzero : Tendsto (fun n => ∫ x, h n x * Real.log (h n x) ∂μ) atTop
      (𝓝 (∫ x, ρ x * Real.log (ρ x) ∂μ)) := by
    let C := 2 * (|Real.log (lo/2)| + |Real.log (2*hi)| + 1)
    have hB : Tendsto (fun n => C*e n) atTop (𝓝 0) := by
      simpa only [mul_zero] using hezero.const_mul C
    apply Metric.tendsto_nhds.mpr
    intro ε hε
    filter_upwards [hB.eventually (Iio_mem_nhds hε)] with n hn
    rw [Real.dist_eq, ← integral_sub (hEntInt n) hρent]
    have hnorm := norm_integral_le_integral_norm
      (f := fun x => h n x*Real.log (h n x)-ρ x*Real.log (ρ x)) (μ := μ)
    simp only [Real.norm_eq_abs] at hnorm
    exact (hnorm.trans (hEntropy n)).trans_lt hn
  have hCDF : ∀ z, Tendsto (fun n => cdf (P n) z) atTop (𝓝 (cdf Q z)) :=
    cdf_densityLaw_tendsto_of_l1 μ h ρ hInt hρi
      (fun n x => (hpos n x).le) hρpos hMass hρmass hL1zero
  have hKL : Tendsto (fun n => 2 * klDiv (P n) μ) atTop (𝓝 (2 * klDiv Q μ)) := by
    have hne (n : ℕ) : klDiv (P n) μ =
        ENNReal.ofReal (∫ x, h n x*Real.log (h n x) ∂μ) :=
      klDiv_densityLaw μ (h n) (hc n).measurable (hInt n)
        (fun x => (hpos n x).le) (hMass n) (hEntInt n)
    have hqe : klDiv Q μ = ENNReal.ofReal (∫ x, ρ x*Real.log (ρ x) ∂μ) :=
      klDiv_densityLaw μ ρ hρm hρi hρpos hρmass hρent
    simp_rw [hne, hqe]
    exact (ENNReal.continuous_const_mul (a := 2) (by norm_num)).tendsto _ |>.comp
      (ENNReal.continuous_ofReal.tendsto _ |>.comp hJzero)
  apply quantileQuadraticCost_le_of_cdf_limits P (fun _ => μ) Q μ
    hCDF (fun _ => tendsto_const_nhds) (fun n => 2 * klDiv (P n) μ)
    (2 * klDiv Q μ) hKL
  intro n
  have hPeq : P n = intervalDensity (fun x => gaussianWeight x*h n x) a b :=
    densityLaw_intervalDensity_mul continuous_gaussianWeight gaussianWeight_pos
      (hc n) (hpos n) hab (hMass n)
  rw [hPeq]
  exact compact_gaussian_quantile_cost_le_kl
    (continuous_gaussianWeight.mul (hc n))
    (fun x => mul_pos (gaussianWeight_pos x) (hpos n x)) hab

end NeuralGeneralization.BatchTwoImprovedGaussianTransport
