import NeuralGeneralization.BatchTwoContinuousDepthSmoothRisk
import NeuralGeneralization.BatchTwoContinuousDepthPowerMain

/-! The literal finite-power-prior lower bound for the smooth input law.
The same sample event, width polynomial and scale conditions are retained. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open MeasureTheory ProbabilityTheory Set Filter
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPower
open ConcreteModel BatchTwoContinuous BatchTwoContinuousDepthLower

theorem smooth_paired_output_change_barrier {N q : ℕ}
    (Q : Measure (Weights 2 N q)) [IsProbabilityMeasure Q] (r : ℕ)
    (hpair : ∀ z, Q.real {w | (12/25 : ℝ)≤
      |output Real.tanh w (jitteredCoding r z)-output Real.tanh w (jitteredCoding r (jitterFlip r z))|}≤1/3) :
    (1/2 : ℝ)≤BatchTwoContinuous.confidenceFailure Real.tanh (smoothInputLaw r) Q (depthTarget r) (1/4) := by
  unfold BatchTwoContinuous.confidenceFailure
  change (1/2 : ℝ) ≤ (jitteredInputLaw r (smoothJitterLaw r)).real _
  rw [← jitteredInputLaw_balanced_pair r (smoothJitterLaw r)]
  apply paired_confidence_failure (signLaw.prod (smoothJitterLaw r)) (jitteredCoding r)
    (jitteredCoding r ∘ jitterFlip r) (jitteredCoding_measurable r)
    ((jitteredCoding_measurable r).comp (jitterFlip_measurable r))
    _ (measurable_correctProbability tanh_continuous Q (continuous_target r).measurable (1/4)) (2/3)
  intro z
  have h := smooth_correct_probability_pair_sum Q r hpair z
  change _ ≤ 2*(2/3 : ℝ)
  norm_num only at *
  exact h

/-- Exact conditioning preserves the paired lower bound once the sharp prior
numerator beats the memorizer denominator by the displayed polynomial cost. -/
theorem smooth_confidence_failure_from_pair_rate {N r n : ℕ} {σ P : ℝ}
    (hσ : 0<σ) (hσsmall : σ^2≤1/16) (hr : 60≤(r : ℝ)+1)
    (hcost : (N : ℝ)*σ^2*P≤((r : ℝ)+1)/100)
    (s : Fin n→RealInput 2)
    (hden : Real.exp (-slowEnergyCeiling r/(2*σ^2)-(N : ℝ)*P)≤
      (ConcreteModel.smallPrior 2 N (r+1) σ).real (trainingEvent Real.tanh (depthTarget (r+2)) (1/8) s))
    (hnum : ∀ ω, (ConcreteModel.smallPrior 2 N (r+1) σ).real {w | (12/25 : ℝ)≤
      |output Real.tanh w (jitteredCoding (r+2) ω)-output Real.tanh w (jitteredCoding (r+2) (jitterFlip (r+2) ω))|}≤
        Real.exp (-(11/10)*((r : ℝ)+1)/σ^2)) :
    (1/2 : ℝ)≤BatchTwoContinuous.confidenceFailure Real.tanh (smoothInputLaw (r+2))
      (BatchTwoContinuous.posterior Real.tanh (ConcreteModel.smallPrior 2 N (r+1) σ)
        (depthTarget (r+2)) (1/8) s) (depthTarget (r+2)) (1/4) := by
  let μ := ConcreteModel.smallPrior 2 N (r+1) σ
  let V := trainingEvent (N := N) (r := r+1) Real.tanh (depthTarget (r+2)) (1/8) s
  have hpos : 0<μ.real V := (Real.exp_pos _).trans_le hden
  have hne : μ V≠0 := by intro hh; simp only [Measure.real,hh,ENNReal.toReal_zero] at hpos; exact hpos.false
  letI : IsProbabilityMeasure (BatchTwoContinuous.posterior Real.tanh μ (depthTarget (r+2)) (1/8) s) :=
    cond_isProbabilityMeasure hne
  apply smooth_paired_output_change_barrier _ (r+2)
  intro ω
  let U : Set (Weights 2 N (r+1)) := {w | (12/25 : ℝ)≤
    |output Real.tanh w (jitteredCoding (r+2) ω)-output Real.tanh w (jitteredCoding (r+2) (jitterFlip (r+2) ω))|}
  have hratio := RobustPosterior.cond_real_le_ratio μ V U
    (isOpen_trainingEvent tanh_lipschitzWith.continuous _ _ s).measurableSet
  apply hratio.trans
  have hbound : μ.real U/μ.real V ≤
      Real.exp (-(11/10)*((r : ℝ)+1)/σ^2)/Real.exp (-slowEnergyCeiling r/(2*σ^2)-(N : ℝ)*P) :=
    div_le_div₀ (Real.exp_nonneg _) (hnum ω) (Real.exp_pos _) hden
  apply hbound.trans
  rw [←Real.exp_sub]
  have hs : 0<σ^2 := sq_pos_of_pos hσ
  have hex : -(11/10)*((r : ℝ)+1)/σ^2-(-slowEnergyCeiling r/(2*σ^2)-(N : ℝ)*P)≤-2 := by
    have he : -(11/10)*((r : ℝ)+1)/σ^2-(-slowEnergyCeiling r/(2*σ^2)-(N : ℝ)*P)=
        (-(11/10)*((r : ℝ)+1)+slowEnergyCeiling r/2+(N : ℝ)*σ^2*P)/σ^2 := by field_simp; ring
    rw [he]
    apply (div_le_iff₀ hs).mpr
    unfold slowEnergyCeiling
    nlinarith
  have hfinal : Real.exp (-2 : ℝ)≤1/3 := by
    rw [Real.exp_neg]
    simpa only [one_div] using
      (one_div_le_one_div_of_le (by norm_num : (0 : ℝ)<3) (by linarith [Real.add_one_le_exp (2 : ℝ)] : (3 : ℝ)≤Real.exp 2))
  exact (Real.exp_le_exp.mpr hex).trans hfinal

theorem smooth_powerInterpolationSamples_probability {n : ℕ} (hn : 0<n) (r : ℕ) :
    (49/50 : ℝ)≤(Measure.pi (fun _ : Fin n => smoothInputLaw (r+2))).real
      (powerInterpolationSamples r n) := by
  have he : ∀ᵐ x ∂smoothInputLaw (r+2), ∑j,x j^2=1 :=
    (mem_ae_iff_prob_eq_one (measurableSet_eq_fun (by fun_prop) measurable_const)).mpr
      (smoothInputLaw_sphere (r+2))
  have hu : ∀ᵐ s ∂(Measure.pi (fun _ : Fin n => smoothInputLaw (r+2))), ∀i,∑j,s i j^2≤1 := by
    apply eventually_all.mpr
    intro i
    filter_upwards [(Measure.tendsto_eval_ae_ae
      (μ := fun _ : Fin n => smoothInputLaw (r+2)) (i := i)).eventually he] with s hs
    exact hs.le
  have heq : powerInterpolationSamples r n =ᵐ[Measure.pi (fun _ : Fin n => smoothInputLaw (r+2))]
      separatedSample n := by
    filter_upwards [smooth_iid_sample_bounds (r+2) n, hu] with s hs hsphere
    apply propext
    simp only [powerInterpolationSamples, slowInterpolationSamples, mem_inter_iff, mem_setOf_eq]
    exact ⟨fun h => h.1.1, fun h => ⟨⟨h,hs⟩,hsphere⟩⟩
  rw [measureReal_congr heq]
  exact jittered_separatedSample_probability (r+2) (smoothJitterLaw (r+2)) hn

theorem smooth_finite_power_failure_on_sample_event {r n N : ℕ}
    (hr : max 59 sharpInterpolationDepthThreshold≤r) (hn : 0<n)
    (hnr : (n : ℝ)≤Real.exp (((r : ℝ)+2)/100)) {ζ σ : ℝ} (hζ : 0<ζ)
    (hN : widthThreshold (interpolationWidth n) r (1/8) ζ≤N)
    (hσ : 0<σ) (hscale : σ^2≤(N : ℝ)^(-(1+ζ)))
    (s : Fin n→RealInput 2) (hs : s∈powerInterpolationSamples r n) :
    0<(smallPrior 2 N (r+1) σ).real (trainingEvent Real.tanh (depthTarget (r+2)) (1/8) s) ∧
    (1/2 : ℝ)≤BatchTwoContinuous.confidenceFailure Real.tanh (smoothInputLaw (r+2))
      (BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N (r+1) σ)
        (depthTarget (r+2)) (1/8) s) (depthTarget (r+2)) (1/4) := by
  obtain ⟨hMN,hNp,hscale',hσsmall,hcost⟩ := widthThreshold_properties (by norm_num) hζ hN hscale
  have hr59 : 59≤r := (le_max_left _ _).trans hr
  have hrr : (60 : ℝ)≤(r : ℝ)+1 := by exact_mod_cast (show 60≤r+1 by omega)
  have hden := sample_event_sharp_denominator ((le_max_right _ _).trans hr) hn hnr hMN s hs
    (by norm_num : (0 : ℝ)<1/8) hσ (hscale'.trans (by norm_num))
  refine ⟨(Real.exp_pos _).trans_le hden,?_⟩
  apply smooth_confidence_failure_from_pair_rate hσ hσsmall hrr (hcost.trans (by linarith)) s hden
  intro ω
  have ht := jittered_small_scale_pair_tail (r := r+1) hNp (by omega) hσ hscale' ω
  apply ht.trans
  apply Real.exp_le_exp.mpr
  apply div_le_div_of_nonneg_right _ (sq_nonneg σ)
  push_cast
  linarith

/-- One explicit measurable sample event has probability at least 49/50 and
forces the confidence-error lower bound simultaneously at all sufficiently
large widths and all stronger scales. -/
theorem smooth_finite_power_depth_lower_bound {r n : ℕ}
    (hr : max 59 sharpInterpolationDepthThreshold≤r) (hn : 0<n)
    (hnr : (n : ℝ)≤Real.exp (((r : ℝ)+2)/100)) {ζ : ℝ} (hζ : 0<ζ) :
    ∃ E : Set (Fin n→RealInput 2), MeasurableSet E ∧
      (49/50 : ℝ)≤(Measure.pi (fun _ : Fin n=>(smoothInputLaw (r+2)))).real E ∧
      ∀ s∈E, ∀ N, widthThreshold (interpolationWidth n) r (1/8) ζ≤N →
      ∀ σ : ℝ, 0<σ → σ^2≤(N : ℝ)^(-(1+ζ)) →
        0<(smallPrior 2 N (r+1) σ).real (trainingEvent Real.tanh (depthTarget (r+2)) (1/8) s) ∧
        (1/2 : ℝ)≤BatchTwoContinuous.confidenceFailure Real.tanh (smoothInputLaw (r+2))
          (BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N (r+1) σ)
            (depthTarget (r+2)) (1/8) s) (depthTarget (r+2)) (1/4) := by
  refine ⟨powerInterpolationSamples r n,powerInterpolationSamples_measurable r n,
    smooth_powerInterpolationSamples_probability hn r,?_⟩
  intro s hs N hN σ hσ hscale
  exact smooth_finite_power_failure_on_sample_event hr hn hnr hζ hN hσ hscale s hs

/-- The literal power-prior statement, uniform for all γ≥1+ζ. -/
theorem smooth_power_prior_depth_lower_bound {r n : ℕ}
    (hr : max 59 sharpInterpolationDepthThreshold≤r) (hn : 0<n)
    (hnr : (n : ℝ)≤Real.exp (((r : ℝ)+2)/100)) {ζ : ℝ} (hζ : 0<ζ) :
    ∃ E : Set (Fin n→RealInput 2), MeasurableSet E ∧
      (49/50 : ℝ)≤(Measure.pi (fun _ : Fin n=>(smoothInputLaw (r+2)))).real E ∧
      ∀ s∈E, ∀ N, widthThreshold (interpolationWidth n) r (1/8) ζ≤N →
      ∀ γ : ℝ, 1+ζ≤γ →
        0<(powerPrior 2 N (r+1) γ).real (trainingEvent Real.tanh (depthTarget (r+2)) (1/8) s) ∧
        (1/2 : ℝ)≤BatchTwoContinuous.confidenceFailure Real.tanh (smoothInputLaw (r+2))
          (BatchTwoContinuous.posterior Real.tanh (powerPrior 2 N (r+1) γ)
            (depthTarget (r+2)) (1/8) s) (depthTarget (r+2)) (1/4) := by
  obtain ⟨E,hE,hprob,hgood⟩ := smooth_finite_power_depth_lower_bound hr hn hnr hζ
  refine ⟨E,hE,hprob,?_⟩
  intro s hs N hN γ hγ
  have hMN : interpolationWidth n≤N := (le_max_left _ _).trans hN
  have hNp : 0<N := by have := (interpolationWidth_ge hn).1; omega
  have hN1 : (1 : ℝ)≤N := by exact_mod_cast hNp
  have hscale : powerStandardDeviation N γ^2≤(N : ℝ)^(-(1+ζ)) := by
    rw [powerStandardDeviation_sq hNp]
    exact Real.rpow_le_rpow_of_exponent_le hN1 (by linarith)
  have hh := hgood s hs N hN (powerStandardDeviation N γ) (powerStandardDeviation_pos hNp γ) hscale
  simpa only [powerPrior_eq_smallPrior_standardDeviation hNp γ] using hh

end NeuralGeneralization.BatchTwoContinuousDepthPower
