import NeuralGeneralization.BatchTwoImprovedGaussianTransportCompactGeneral
import NeuralGeneralization.BatchTwoImprovedConditioning
import Mathlib.Probability.Distributions.Gaussian.Real

/-! # Expanding compact restrictions of the standard Gaussian -/
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter InformationTheory
open scoped Topology ENNReal NNReal

namespace NeuralGeneralization.BatchTwoImprovedGaussianTransport
open PositiveCDFTransport BatchTwoImprovedIntervalDensity BatchTwoImprovedQuantile
open BatchTwoImprovedDensityApprox BatchTwoImprovedDensityMeasure
open BatchTwoImprovedConditioning

theorem gaussian_cond_interval {a b : ℝ} (hab : a < b) :
    cond (gaussianReal 0 1) (Ioc a b) = intervalDensity gaussianWeight a b := by
  let c : ℝ := (Real.sqrt (2*Real.pi))⁻¹
  have hc : 0 < c := by dsimp [c]; positivity
  have hm : 0 < mass gaussianWeight a b :=
    mass_pos continuous_gaussianWeight gaussianWeight_pos hab
  have hpdf (x : ℝ) : gaussianPDFReal 0 1 x = c*gaussianWeight x := by
    simp [gaussianPDFReal, gaussianWeight, c]
  have hmass : gaussianReal 0 1 (Ioc a b) =
      ENNReal.ofReal (c*mass gaussianWeight a b) := by
    rw [gaussianReal_apply_eq_integral 0 (by norm_num : (1:ℝ≥0) ≠ 0)]
    simp_rw [hpdf]
    rw [← intervalIntegral.integral_of_le hab.le, intervalIntegral.integral_const_mul]
    rfl
  rw [ProbabilityTheory.cond, hmass,
    gaussianReal_of_var_ne_zero 0 (by norm_num : (1:ℝ≥0) ≠ 0),
    restrict_withDensity measurableSet_Ioc,
    ← withDensity_smul _ (measurable_gaussianPDF 0 1)]
  unfold intervalDensity
  apply withDensity_congr_ae
  filter_upwards with x
  simp only [Pi.smul_apply, smul_eq_mul, gaussianPDF_def, hpdf]
  rw [← ENNReal.ofReal_inv_of_pos (mul_pos hc hm),
    ← ENNReal.ofReal_mul (inv_nonneg.mpr (mul_pos hc hm).le)]
  congr 1
  field_simp

theorem gaussian_interval_ne_zero {a b : ℝ} (hab : a < b) :
    gaussianReal 0 1 (Ioc a b) ≠ 0 := by
  have hpos : 0 < ∫ x in a..b, gaussianPDFReal 0 1 x :=
    mass_pos (by unfold gaussianPDFReal; fun_prop)
      (fun x => gaussianPDFReal_pos _ _ x (by norm_num)) hab
  rw [gaussianReal_apply_eq_integral 0 (by norm_num : (1:ℝ≥0) ≠ 0),
    ← intervalIntegral.integral_of_le hab.le]
  exact (ENNReal.ofReal_pos.mpr hpos).ne'

theorem compact_gaussian_cond_cost_le {a b : ℝ} (hab : a < b)
    (ρ : ℝ → ℝ) (hm : Measurable ρ) (hi : Integrable ρ (gaussianReal 0 1))
    (hpos : ∀ x, 0 ≤ ρ x) (hmass : ∫ x, ρ x ∂gaussianReal 0 1 = 1)
    (he : Integrable (fun x => ρ x * Real.log (ρ x)) (gaussianReal 0 1))
    (hP : densityLaw (gaussianReal 0 1) ρ (Ioc a b) ≠ 0) :
    quantileQuadraticCost (cond (densityLaw (gaussianReal 0 1) ρ) (Ioc a b))
      (cond (gaussianReal 0 1) (Ioc a b)) ≤
      2 * klDiv (cond (densityLaw (gaussianReal 0 1) ρ) (Ioc a b))
        (cond (gaussianReal 0 1) (Ioc a b)) := by
  let μ := gaussianReal 0 1
  let s := Ioc a b
  let P := densityLaw μ ρ
  letI := densityLaw_probability μ ρ hi hpos hmass
  have hμ : μ s ≠ 0 := gaussian_interval_ne_zero hab
  let c := μ.real s / P.real s
  have hg : 0 < μ.real s := ENNReal.toReal_pos hμ (measure_ne_top _ _)
  have hp : 0 < P.real s := ENNReal.toReal_pos hP (measure_ne_top _ _)
  have hc : 0 < c := div_pos hg hp
  have hri := integrable_cond μ s hμ ρ hi
  have hei := integrable_cond μ s hμ _ he
  have hpoint (x : ℝ) : (c*ρ x)*Real.log (c*ρ x) =
      c*(ρ x*Real.log (ρ x)) + (c*Real.log c)*ρ x := by
    by_cases hz : ρ x = 0
    · simp [hz]
    · rw [Real.log_mul hc.ne' hz]; ring
  have hci : Integrable (fun x => c*ρ x) (cond μ s) := hri.const_mul c
  have hcent : Integrable (fun x => c*ρ x*Real.log (c*ρ x)) (cond μ s) := by
    simp_rw [hpoint]
    exact (hei.const_mul c).add (hri.const_mul _)
  have hcmass : (∫ x, c*ρ x ∂cond μ s) = 1 := by
    rw [integral_const_mul, integral_cond,
      ← densityLaw_real_apply μ ρ hi hpos measurableSet_Ioc]
    change μ.real s / P.real s * (P.real s / μ.real s) = 1
    field_simp
  have hcond : cond μ s = intervalDensity gaussianWeight a b := gaussian_cond_interval hab
  rw [hcond] at hci hcent hcmass
  have h := compact_gaussian_density_cost_le_kl hab (fun x => c*ρ x)
    (hm.const_mul c) hci (fun x => mul_nonneg hc.le (hpos x)) hcmass hcent
  rw [← hcond] at h
  rw [← cond_densityLaw μ ρ hm hi hpos hmass s measurableSet_Ioc hμ hP] at h
  exact h

/-- The standard Gaussian T2 inequality for every measurable finite-entropy
density. The coupling is the explicit common-uniform quantile coupling. -/
theorem gaussian_density_cost_le_kl
    (ρ : ℝ → ℝ) (hm : Measurable ρ) (hi : Integrable ρ (gaussianReal 0 1))
    (hpos : ∀ x, 0 ≤ ρ x) (hmass : ∫ x, ρ x ∂gaussianReal 0 1 = 1)
    (he : Integrable (fun x => ρ x * Real.log (ρ x)) (gaussianReal 0 1)) :
    quantileQuadraticCost (densityLaw (gaussianReal 0 1) ρ) (gaussianReal 0 1) ≤
      2 * klDiv (densityLaw (gaussianReal 0 1) ρ) (gaussianReal 0 1) := by
  let μ := gaussianReal 0 1
  let P := densityLaw μ ρ
  letI := densityLaw_probability μ ρ hi hpos hmass
  have hppos := (measureReal_exhaustion_tendsto P).eventually (Ioi_mem_nhds (by norm_num : (0:ℝ) < 1))
  obtain ⟨k, hk⟩ := eventually_atTop.mp hppos
  have hPn (n : ℕ) : P (exhaustion (n+k)) ≠ 0 := by
    have h := hk (n+k) (Nat.le_add_left k n)
    exact fun heq => by simpa [Measure.real, heq] using h
  have hμn (n : ℕ) : μ (exhaustion (n+k)) ≠ 0 := by
    apply gaussian_interval_ne_zero
    linarith [Nat.cast_nonneg (α := ℝ) (n+k)]
  let Pn := fun n => cond P (exhaustion (n+k))
  let Qn := fun n => cond μ (exhaustion (n+k))
  letI (n : ℕ) : IsProbabilityMeasure (Pn n) := cond_isProbabilityMeasure (hPn n)
  letI (n : ℕ) : IsProbabilityMeasure (Qn n) := cond_isProbabilityMeasure (hμn n)
  have hseq : Tendsto (fun n : ℕ => n+k) atTop atTop := tendsto_add_atTop_nat k
  have hp := (measureReal_exhaustion_tendsto P).comp hseq
  have hg := (measureReal_exhaustion_tendsto μ).comp hseq
  have hj := (integral_exhaustion_tendsto μ _ he).comp hseq
  have hlog : Tendsto (fun n => Real.log (μ.real (exhaustion (n+k)) /
      P.real (exhaustion (n+k)))) atTop (𝓝 0) := by
    simpa using (hg.div hp (by norm_num : (1:ℝ) ≠ 0)).log (by norm_num)
  have hEnt : Tendsto (fun n =>
      (∫ x in exhaustion (n+k), ρ x*Real.log (ρ x) ∂μ) / P.real (exhaustion (n+k)) +
      Real.log (μ.real (exhaustion (n+k)) / P.real (exhaustion (n+k)))) atTop
      (𝓝 (∫ x, ρ x*Real.log (ρ x) ∂μ)) := by
    simpa only [div_one, add_zero, Function.comp_apply, Pi.div_apply, Pi.add_apply] using
      (hj.div hp (by norm_num : (1:ℝ) ≠ 0)).add hlog
  have hKL : Tendsto (fun n => 2 * klDiv (Pn n) (Qn n)) atTop
      (𝓝 (2 * klDiv P μ)) := by
    have hform (n : ℕ) := klDiv_cond_densityLaw μ ρ hm hi hpos hmass he
      (exhaustion (n+k)) measurableSet_Ioc (hμn n) (hPn n)
    have hlim := ENNReal.continuous_ofReal.tendsto _ |>.comp hEnt
    have hmult := (ENNReal.continuous_const_mul (a := 2) (by norm_num)).tendsto _ |>.comp hlim
    simp_rw [show klDiv P μ = ENNReal.ofReal (∫ x, ρ x*Real.log (ρ x) ∂μ) from
      klDiv_densityLaw μ ρ hm hi hpos hmass he]
    convert hmult using 1
    funext n
    rw [show klDiv (Pn n) (Qn n) = _ from hform n]
    rfl
  apply quantileQuadraticCost_le_of_cdf_limits Pn Qn P μ
    (cdf_cond_exhaustion_tendsto P k hPn)
    (cdf_cond_exhaustion_tendsto μ k hμn)
    (fun n => 2 * klDiv (Pn n) (Qn n)) (2 * klDiv P μ) hKL
  intro n
  exact compact_gaussian_cond_cost_le
    (by linarith [Nat.cast_nonneg (α := ℝ) (n+k)])
    ρ hm hi hpos hmass he (hPn n)

end NeuralGeneralization.BatchTwoImprovedGaussianTransport
