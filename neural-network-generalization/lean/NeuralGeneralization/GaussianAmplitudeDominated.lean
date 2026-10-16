import NeuralGeneralization.GaussianAmplitudeNoise
import NeuralGeneralization.DominatedMeasureLift

/-! # Gaussian amplitude under dominated observation conditioning -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianAmplitude

theorem normalized_smallMeanCount
    {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (H : Ω → ι → ℝ)
    (hH : Measurable H) (a σ t : ℝ)
    (hσ : 0 < σ) (ht : 0 ≤ t) (ha : σ/2 ≤ a)
    (κ : Measure (Ω × (ι → ℝ))) [IsFiniteMeasure κ]
    (hκ : κ ≤ (μ.prod (Measure.pi fun _i : ι => gaussianReal 0 1)).restrict
      {x | ∀ i, a < |H x.1 i+σ*x.2 i|})
    (hκpos : κ Set.univ ≠ 0) :
    (∫ x, smallMeanCount (a+σ*t) (H x.1) ∂cond κ Set.univ) ≤
      Real.log (1/κ.real Set.univ)/smallBall t := by
  let ν := Measure.pi fun _i : ι => gaussianReal 0 1
  let E : Set (Ω × (ι → ℝ)) := {x | ∀ i, a < |H x.1 i+σ*x.2 i|}
  have hE : MeasurableSet E := by
    have heq : E = ⋂ i, {x | a < |H x.1 i+σ*x.2 i|} := by ext x; simp [E]
    rw [heq]
    apply MeasurableSet.iInter
    intro i
    exact measurableSet_lt measurable_const
      (((measurable_pi_apply i).comp (hH.comp measurable_fst)).add
        (measurable_const.mul ((measurable_pi_apply i).comp measurable_snd))).abs
  have hκbase : κ ≤ μ.prod ν := hκ.trans Measure.restrict_le_self
  have hQ := (integrable_smallMeanCount (μ.prod ν) (fun x => H x.1)
    (hH.comp measurable_fst) (a+σ*t)).mono_measure hκbase
  have hXbase := integrable_exp_smallMeanCount (μ.prod ν) (fun x => H x.1)
    (hH.comp measurable_fst) (a+σ*t) (smallBall t) (smallBall_pos ht).le
  have hm := restricted_count_exponential_moment μ H hH a σ t hσ ht ha E hE
    (fun _ hx => hx)
  have hmκ : (∫ x, Real.exp (smallBall t*smallMeanCount (a+σ*t) (H x.1)) ∂κ) ≤ 1 :=
    (integral_mono_measure hκ
      (Filter.Eventually.of_forall fun _ => (Real.exp_pos _).le) hXbase.restrict).trans hm
  have hh := finite_normalized_expectation_le_of_exponential_moment κ
    (fun x => smallMeanCount (a+σ*t) (H x.1)) (smallBall t) 0 (smallBall_pos ht)
    hQ (hXbase.mono_measure hκbase) hκpos (by simpa only [Real.exp_zero] using hmκ)
  simpa only [zero_add] using hh

theorem normalized_noise_energy
    {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (κ : Measure (Ω × (ι → ℝ))) [IsFiniteMeasure κ]
    (hκ : κ ≤ μ.prod (Measure.pi fun _i : ι => gaussianReal 0 1))
    (hκpos : κ Set.univ ≠ 0) :
    (∫ x, ∑ i, x.2 i^2 ∂cond κ Set.univ) ≤
      2*(Fintype.card ι : ℝ)+4*Real.log (1/κ.real Set.univ) := by
  let ν := Measure.pi fun _i : ι => gaussianReal 0 1
  let Q : (ι → ℝ) → ℝ := fun z => ∑ i, (z i^2-1)
  have he : Integrable (fun z => Real.exp ((1/4:ℝ)*Q z)) ν := by
    simpa only [NNReal.coe_one, one_mul] using
      GaussianTail.integrable_exp_sum_centered_gaussian_squares
        (fun _i : ι => (1:ℝ≥0)) (fun _i => (1:ℝ)) (1/4) (by intro i; norm_num)
  have he' : Integrable (fun z => Real.exp (-(1/4:ℝ)*Q z)) ν := by
    simpa only [NNReal.coe_one, one_mul] using
      GaussianTail.integrable_exp_sum_centered_gaussian_squares
        (fun _i : ι => (1:ℝ≥0)) (fun _i => (1:ℝ)) (-(1/4)) (by intro i; norm_num)
  have hQ : Integrable Q ν := by
    simpa only [pow_one] using integrable_pow_of_integrable_exp_mul
      (by norm_num : (1/4:ℝ) ≠ 0) he he' 1
  have hm : (∫ z, Real.exp ((1/4:ℝ)*Q z) ∂ν) ≤ Real.exp ((Fintype.card ι : ℝ)/4) := by
    have hh := GaussianTail.mgf_sum_centered_gaussian_squares_le
      (fun _i : ι => (1:ℝ≥0)) (fun _i => (1:ℝ)) (1/4) (by intro i; norm_num)
    norm_num [mgf, Q, ν] at hh ⊢
    simpa only [div_eq_mul_inv, one_mul, mul_comm] using hh
  have hmprod : (∫ x : Ω × (ι → ℝ), Real.exp ((1/4:ℝ)*Q x.2) ∂μ.prod ν) ≤
      Real.exp ((Fintype.card ι : ℝ)/4) := by
    rw [integral_prod _ (he.comp_snd μ)]
    simpa using hm
  have hmκ := (integral_mono_measure hκ
    (Filter.Eventually.of_forall fun _ => (Real.exp_pos _).le) (he.comp_snd μ)).trans hmprod
  have hc := finite_normalized_expectation_le_of_exponential_moment κ
    (fun x => Q x.2) (1/4) ((Fintype.card ι : ℝ)/4) (by norm_num)
    ((hQ.comp_snd μ).mono_measure hκ) ((he.comp_snd μ).mono_measure hκ) hκpos hmκ
  letI : IsProbabilityMeasure (cond κ Set.univ) := cond_isProbabilityMeasure hκpos
  have hQE : Integrable (fun x : Ω × (ι → ℝ) => Q x.2) (cond κ Set.univ) :=
    ((hQ.comp_snd μ).mono_measure hκ).restrict.smul_measure (ENNReal.inv_ne_top.mpr hκpos)
  have hid : (fun x : Ω × (ι → ℝ) => ∑ i, x.2 i^2) =
      fun x => Q x.2+(Fintype.card ι : ℝ) := by
    funext x
    simp [Q, Finset.sum_sub_distrib]
  rw [hid, integral_add hQE (integrable_const _)]
  simp only [integral_const, probReal_univ, one_smul]
  linarith

/-- Arbitrary extra conditioning is represented by a submeasure of the Gaussian
noise product, not by an independence assumption on the extra information. -/
theorem normalized_small_output_count
    {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (H : Ω → ι → ℝ)
    (hH : Measurable H) (a σ t : ℝ)
    (hσ : 0 < σ) (ht : 0 ≤ t) (ha : σ/2 ≤ a)
    (κ : Measure (Ω × (ι → ℝ))) [IsFiniteMeasure κ]
    (hκ : κ ≤ (μ.prod (Measure.pi fun _i : ι => gaussianReal 0 1)).restrict
      {x | ∀ i, a < |H x.1 i+σ*x.2 i|})
    (hκpos : κ Set.univ ≠ 0) :
    (∫ x, smallMeanCount ((a+σ*t)/2) (fun i => H x.1 i+σ*x.2 i) ∂cond κ Set.univ) ≤
      Real.log (1/κ.real Set.univ)/smallBall t +
      (4*σ^2/(a+σ*t)^2)*(2*(Fintype.card ι : ℝ)+4*Real.log (1/κ.real Set.univ)) := by
  let ν := Measure.pi fun _i : ι => gaussianReal 0 1
  let ρ := cond κ Set.univ
  letI : IsProbabilityMeasure ρ := cond_isProbabilityMeasure hκpos
  have hκbase : κ ≤ μ.prod ν := hκ.trans Measure.restrict_le_self
  have hb : 0 < a+σ*t := by nlinarith
  have hmap : Measurable (fun x : Ω × (ι → ℝ) => fun i => H x.1 i+σ*x.2 i) := by
    apply measurable_pi_lambda
    intro i
    exact ((measurable_pi_apply i).comp (hH.comp measurable_fst)).add
      (measurable_const.mul ((measurable_pi_apply i).comp measurable_snd))
  have hleft := integrable_smallMeanCount ρ _ hmap ((a+σ*t)/2)
  have hmeans := integrable_smallMeanCount ρ (fun x => H x.1)
    (hH.comp measurable_fst) (a+σ*t)
  have hnoise : Integrable (fun x : Ω × (ι → ℝ) => ∑ i, x.2 i^2) ρ :=
    ((integrable_noise_energy μ).mono_measure hκbase).restrict.smul_measure
      (ENNReal.inv_ne_top.mpr hκpos)
  have hright := hmeans.add (hnoise.const_mul (4*σ^2/(a+σ*t)^2))
  have hmono := integral_mono hleft hright (fun x =>
    small_output_count_le (H x.1) x.2 (a+σ*t) σ hb)
  simp only [Pi.add_apply] at hmono
  rw [integral_add hmeans (hnoise.const_mul _), integral_const_mul] at hmono
  have hm := normalized_smallMeanCount μ H hH a σ t hσ ht ha κ hκ hκpos
  have hn := normalized_noise_energy μ κ hκbase hκpos
  have hc : 0 ≤ 4*σ^2/(a+σ*t)^2 := by positivity
  exact hmono.trans (add_le_add hm (mul_le_mul_of_nonneg_left hn hc))

end NeuralGeneralization.GaussianAmplitude
