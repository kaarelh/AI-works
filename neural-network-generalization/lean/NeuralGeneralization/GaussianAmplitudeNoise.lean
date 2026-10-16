import NeuralGeneralization.GaussianAmplitudeSurvival

/-! # Noise energy and amplitude after globally conditioning Gaussian noise -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianAmplitude

/-- The actual standard Gaussian noise energy is integrable on the joint space. -/
lemma integrable_noise_energy {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι]
    (μ : Measure Ω) [IsProbabilityMeasure μ] :
    Integrable (fun x : Ω × (ι → ℝ) => ∑ i, x.2 i^2)
      (μ.prod (Measure.pi fun _i : ι => gaussianReal 0 1)) := by
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
  have hsum : Integrable (fun z => Q z+(Fintype.card ι : ℝ)) ν :=
    hQ.add (integrable_const _)
  have hid : (fun z : ι → ℝ => ∑ i, z i^2) =
      fun z => Q z+(Fintype.card ι : ℝ) := by
    funext z
    simp [Q, Finset.sum_sub_distrib]
  rw [← hid] at hsum
  exact hsum.comp_snd μ

/-- Gaussian noise still has a controlled quadratic moment under an arbitrary
event on the joint product space. The event may also constrain other randomness. -/
theorem conditional_noise_energy
    {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (E : Set (Ω × (ι → ℝ)))
    (hE : (μ.prod (Measure.pi fun _i : ι => gaussianReal 0 1)) E ≠ 0) :
    (∫ x, ∑ i, x.2 i ^ 2 ∂cond (μ.prod (Measure.pi fun _i : ι => gaussianReal 0 1)) E) ≤
      2*(Fintype.card ι : ℝ)+
        4*Real.log (1/(μ.prod (Measure.pi fun _i : ι => gaussianReal 0 1)).real E) := by
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
  have hc := conditional_expectation_le_of_exponential_moment (μ.prod ν)
    (fun x => Q x.2) (1/4) ((Fintype.card ι : ℝ)/4) (by norm_num)
    (hQ.comp_snd μ) (he.comp_snd μ) hmprod E hE
  letI : IsProbabilityMeasure (cond (μ.prod ν) E) := cond_isProbabilityMeasure hE
  have hQE : Integrable (fun x : Ω × (ι → ℝ) => Q x.2) (cond (μ.prod ν) E) :=
    (hQ.comp_snd μ).restrict.smul_measure (ENNReal.inv_ne_top.mpr hE)
  have hid : (fun x : Ω × (ι → ℝ) => ∑ i, x.2 i^2) =
      fun x => Q x.2+(Fintype.card ι : ℝ) := by
    funext x
    simp [Q, Finset.sum_sub_distrib]
  rw [hid, integral_add hQE (integrable_const _)]
  simp only [integral_const, probReal_univ, one_smul]
  change _ ≤ _+4*Real.log (1/(μ.prod ν).real E)
  linarith

/-- A pointwise comparison: a small final output has either a small residual
mean or a sufficiently large Gaussian-noise coordinate. -/
theorem small_output_count_le {ι : Type*} [Fintype ι]
    (h z : ι → ℝ) (b σ : ℝ) (hb : 0 < b) :
    smallMeanCount (b/2) (fun i => h i+σ*z i) ≤
      smallMeanCount b h+(4*σ^2/b^2)*(∑ i, z i^2) := by
  unfold smallMeanCount
  rw [Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro i hi
  by_cases ho : |h i+σ*z i| ≤ b/2
  · rw [if_pos ho]
    by_cases hh : |h i| ≤ b
    · rw [if_pos hh]
      have hp : 0 ≤ (4*σ^2/b^2)*z i^2 := by positivity
      linarith
    · rw [if_neg hh]
      have hh' : b < |h i| := lt_of_not_ge hh
      have ht : |h i| ≤ |h i+σ*z i|+|σ*z i| := by
        have := abs_add_le (h i+σ*z i) (-σ*z i)
        simpa using this
      have hnoise : b/2 < |σ*z i| := by linarith
      have hsq : b^2/4 ≤ σ^2*z i^2 := by
        have := sq_le_sq₀ (by positivity : 0 ≤ b/2) (abs_nonneg (σ*z i))
        have hs := this.mpr hnoise.le
        nlinarith [sq_abs (σ*z i)]
      have hb2 : 0 < b^2 := sq_pos_of_pos hb
      have hd : (4*σ^2/b^2)*z i^2 = (4*σ^2*z i^2)/b^2 := by ring
      rw [zero_add, hd]
      exact (le_div_iff₀ hb2).mpr (by nlinarith)
  · rw [if_neg ho]
    have hp : 0 ≤ (4*σ^2/b^2)*z i^2 := by positivity
    split <;> linarith


/-- A finite-dimensional amplitude bound after any positive-probability global
fixed-margin conditioning. The residual law is arbitrary, while the added
coordinate noise is an actual independent standard Gaussian product. -/
theorem conditional_small_output_count
    {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (H : Ω → ι → ℝ)
    (hH : Measurable H) (a σ t : ℝ)
    (hσ : 0 < σ) (ht : 0 ≤ t) (ha : σ/2 ≤ a)
    (E : Set (Ω × (ι → ℝ))) (hE : MeasurableSet E)
    (hEpos : (μ.prod (Measure.pi fun _i : ι => gaussianReal 0 1)) E ≠ 0)
    (hmargin : ∀ x ∈ E, ∀ i, a < |H x.1 i+σ*x.2 i|) :
    (∫ x, smallMeanCount ((a+σ*t)/2) (fun i => H x.1 i+σ*x.2 i)
      ∂cond (μ.prod (Measure.pi fun _i : ι => gaussianReal 0 1)) E) ≤
      Real.log (1/(μ.prod (Measure.pi fun _i : ι => gaussianReal 0 1)).real E)/smallBall t +
      (4*σ^2/(a+σ*t)^2)*(2*(Fintype.card ι : ℝ)+
        4*Real.log (1/(μ.prod (Measure.pi fun _i : ι => gaussianReal 0 1)).real E)) := by
  let ν := Measure.pi fun _i : ι => gaussianReal 0 1
  let ρ := cond (μ.prod ν) E
  letI : IsProbabilityMeasure ρ := cond_isProbabilityMeasure hEpos
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
    (integrable_noise_energy μ).restrict.smul_measure (ENNReal.inv_ne_top.mpr hEpos)
  have hright := hmeans.add (hnoise.const_mul (4*σ^2/(a+σ*t)^2))
  have hmono := integral_mono hleft hright (fun x =>
    small_output_count_le (H x.1) x.2 (a+σ*t) σ hb)
  simp only [Pi.add_apply] at hmono
  rw [integral_add hmeans (hnoise.const_mul _), integral_const_mul] at hmono
  have hm := conditional_smallMeanCount μ H hH a σ t hσ ht ha E hE hEpos hmargin
  have hn := conditional_noise_energy μ E hEpos
  have hc : 0 ≤ 4*σ^2/(a+σ*t)^2 := by positivity
  exact hmono.trans (add_le_add hm (mul_le_mul_of_nonneg_left hn hc))

end NeuralGeneralization.GaussianAmplitude
