import NeuralGeneralization.BatchTwoImprovedDensityMeasure
import Mathlib.Probability.ConditionalProbability

/-! # Conditioning and entropy under growing compact restrictions -/
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter InformationTheory
open scoped Topology ENNReal

namespace NeuralGeneralization.BatchTwoImprovedConditioning
open BatchTwoImprovedDensityMeasure

theorem integral_cond (μ : Measure ℝ) (s : Set ℝ) (f : ℝ → ℝ) :
    (∫ x, f x ∂cond μ s) = (∫ x in s, f x ∂μ) / μ.real s := by
  rw [ProbabilityTheory.cond, integral_smul_measure, ENNReal.toReal_inv]
  simp only [smul_eq_mul, Measure.real, div_eq_mul_inv, mul_comm]

theorem integrable_cond (μ : Measure ℝ) (s : Set ℝ) (hs : μ s ≠ 0)
    (f : ℝ → ℝ) (hi : Integrable f μ) : Integrable f (cond μ s) := by
  exact hi.restrict.smul_measure (ENNReal.inv_ne_top.mpr hs)

/-- Conditioning a density law updates its density by the exact ratio of the
two conditioning masses. -/
theorem cond_densityLaw (μ : Measure ℝ) [IsProbabilityMeasure μ]
    (ρ : ℝ → ℝ) (hm : Measurable ρ) (hi : Integrable ρ μ)
    (hpos : ∀ x, 0 ≤ ρ x) (hmass : ∫ x, ρ x ∂μ = 1)
    (s : Set ℝ) (hs : MeasurableSet s) (hμ : μ s ≠ 0)
    (hP : densityLaw μ ρ s ≠ 0) :
    cond (densityLaw μ ρ) s = densityLaw (cond μ s)
      (fun x => (μ.real s / (densityLaw μ ρ).real s) * ρ x) := by
  letI := densityLaw_probability μ ρ hi hpos hmass
  have hc : 0 ≤ μ.real s / (densityLaw μ ρ).real s := by positivity
  have hce : ENNReal.ofReal (μ.real s / (densityLaw μ ρ).real s) =
      μ s / densityLaw μ ρ s := by
    simp only [Measure.real]
    rw [ENNReal.ofReal_div_of_pos (ENNReal.toReal_pos hP (measure_ne_top _ _)),
      ENNReal.ofReal_toReal (measure_ne_top _ _),
      ENNReal.ofReal_toReal (measure_ne_top _ _)]
  change cond (densityLaw μ ρ) s = (cond μ s).withDensity _
  simp_rw [ENNReal.ofReal_mul hc]
  rw [ProbabilityTheory.cond, ProbabilityTheory.cond, withDensity_smul_measure]
  change _ = (μ s)⁻¹ • (μ.restrict s).withDensity
    (ENNReal.ofReal (μ.real s / (densityLaw μ ρ).real s) •
      (fun x => ENNReal.ofReal (ρ x)))
  rw [withDensity_smul _ hm.ennreal_ofReal, hce, smul_smul,
    ← restrict_withDensity hs]
  rw [ENNReal.div_eq_inv_mul, ← mul_assoc,
    mul_comm (μ s)⁻¹ (densityLaw μ ρ s)⁻¹,
    mul_assoc, ENNReal.inv_mul_cancel hμ (measure_ne_top μ s), mul_one]
  rfl

def exhaustion (n : ℕ) : Set ℝ := Ioc (-(n:ℝ)-1) ((n:ℝ)+1)

theorem exhaustion_mono : Monotone exhaustion := by
  intro n m hnm x hx
  have hnm' : (n:ℝ) ≤ m := Nat.cast_le.mpr hnm
  exact ⟨by dsimp [exhaustion] at *; linarith [hx.1],
    by dsimp [exhaustion] at *; linarith [hx.2]⟩

theorem exhaustion_union : (⋃ n, exhaustion n) = univ := by
  apply eq_univ_of_forall
  intro x
  obtain ⟨n, hn⟩ := exists_nat_gt |x|
  apply mem_iUnion.mpr
  refine ⟨n, ?_⟩
  dsimp [exhaustion]
  constructor <;> linarith [le_abs_self x, neg_abs_le x]

theorem integral_exhaustion_tendsto (μ : Measure ℝ) (f : ℝ → ℝ)
    (hi : Integrable f μ) :
    Tendsto (fun n => ∫ x in exhaustion n, f x ∂μ) atTop (𝓝 (∫ x, f x ∂μ)) := by
  have h := tendsto_setIntegral_of_monotone (μ := μ) (f := f)
    (fun _ => measurableSet_Ioc) exhaustion_mono
    (show IntegrableOn f (⋃ n, exhaustion n) μ by simpa [exhaustion_union] using hi)
  change Tendsto (fun n => ∫ x in exhaustion n, f x ∂μ) atTop
    (𝓝 (∫ x in ⋃ n, exhaustion n, f x ∂μ)) at h
  simpa only [exhaustion_union, Measure.restrict_univ] using h

theorem measureReal_exhaustion_tendsto (μ : Measure ℝ) [IsProbabilityMeasure μ] :
    Tendsto (fun n => μ.real (exhaustion n)) atTop (𝓝 1) := by
  simpa using integral_exhaustion_tendsto μ (fun _ => (1:ℝ)) (integrable_const 1)

/-- Entropy of two laws conditioned on the same set, with all normalization
terms retained explicitly. -/
theorem klDiv_cond_densityLaw (μ : Measure ℝ) [IsProbabilityMeasure μ]
    (ρ : ℝ → ℝ) (hm : Measurable ρ) (hi : Integrable ρ μ)
    (hpos : ∀ x, 0 ≤ ρ x) (hmass : ∫ x, ρ x ∂μ = 1)
    (he : Integrable (fun x => ρ x * Real.log (ρ x)) μ)
    (s : Set ℝ) (hs : MeasurableSet s) (hμ : μ s ≠ 0)
    (hP : densityLaw μ ρ s ≠ 0) :
    klDiv (cond (densityLaw μ ρ) s) (cond μ s) = ENNReal.ofReal
      ((∫ x in s, ρ x * Real.log (ρ x) ∂μ) / (densityLaw μ ρ).real s +
        Real.log (μ.real s / (densityLaw μ ρ).real s)) := by
  letI := densityLaw_probability μ ρ hi hpos hmass
  letI := cond_isProbabilityMeasure hμ
  let c := μ.real s / (densityLaw μ ρ).real s
  have hg : 0 < μ.real s := ENNReal.toReal_pos hμ (measure_ne_top _ _)
  have hp : 0 < (densityLaw μ ρ).real s := ENNReal.toReal_pos hP (measure_ne_top _ _)
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
      ← densityLaw_real_apply μ ρ hi hpos hs]
    dsimp [c]
    field_simp
  rw [cond_densityLaw μ ρ hm hi hpos hmass s hs hμ hP]
  change klDiv (densityLaw (cond μ s) (fun x => c*ρ x)) (cond μ s) = _
  rw [klDiv_densityLaw (cond μ s) (fun x => c*ρ x) (hm.const_mul c) hci
    (fun x => mul_nonneg hc.le (hpos x)) hcmass hcent]
  congr 1
  simp_rw [hpoint]
  rw [integral_add (hei.const_mul _) (hri.const_mul _), integral_const_mul,
    integral_const_mul, integral_cond, integral_cond,
    ← densityLaw_real_apply μ ρ hi hpos hs]
  dsimp [c]
  field_simp

theorem cdf_cond_exhaustion_tendsto (μ : Measure ℝ) [IsProbabilityMeasure μ]
    (k : ℕ) (hpos : ∀ n, μ (exhaustion (n+k)) ≠ 0) (z : ℝ) :
    Tendsto (fun n => cdf (cond μ (exhaustion (n+k))) z) atTop (𝓝 (cdf μ z)) := by
  letI (n : ℕ) := cond_isProbabilityMeasure (hpos n)
  let u : ℝ → ℝ := (Iic z).indicator (fun _ => 1)
  have hu : Integrable u μ := (integrable_const 1).indicator measurableSet_Iic
  have huInt (ν : Measure ℝ) [IsFiniteMeasure ν] : (∫ x, u x ∂ν) = ν.real (Iic z) := by
    simp [u, integral_indicator measurableSet_Iic]
  have hseq : Tendsto (fun n : ℕ => n+k) atTop atTop := tendsto_add_atTop_nat k
  have htop := (integral_exhaustion_tendsto μ u hu).comp hseq
  have hbottom := (measureReal_exhaustion_tendsto μ).comp hseq
  have hlim := htop.div hbottom (by norm_num : (1:ℝ) ≠ 0)
  simp only [div_one, huInt, ← cdf_eq_real] at hlim
  convert hlim using 1
  funext n
  rw [cdf_eq_real, ← huInt, integral_cond]
  simp only [Pi.div_apply, Function.comp_apply, huInt]

end NeuralGeneralization.BatchTwoImprovedConditioning
