import NeuralGeneralization.BatchTwoContinuousDepthPowerPosterior
import NeuralGeneralization.BatchTwoContinuousDepthPowerWidth
import NeuralGeneralization.BatchTwoContinuousPairTailDecay
import NeuralGeneralization.PowerPriorScaling

/-! The finite γ>1 depth lower bound for the actual unrestricted Gaussian
neural posterior. The width threshold is an explicit polynomial for every
fixed gap γ−1>0; the same sample event works at all admissible widths/scales. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open MeasureTheory ProbabilityTheory Set Filter
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPower
open ConcreteModel BatchTwoContinuous BatchTwoContinuousDepthLower

theorem finite_power_failure_on_sample_event {r n N : ℕ}
    (hr : max 59 sharpInterpolationDepthThreshold≤r) (hn : 0<n)
    (hnr : (n : ℝ)≤Real.exp (((r : ℝ)+2)/100)) {ζ σ : ℝ} (hζ : 0<ζ)
    (hN : widthThreshold (interpolationWidth n) r (1/8) ζ≤N)
    (hσ : 0<σ) (hscale : σ^2≤(N : ℝ)^(-(1+ζ)))
    (s : Fin n→RealInput 2) (hs : s∈powerInterpolationSamples r n) :
    0<(smallPrior 2 N (r+1) σ).real (trainingEvent Real.tanh (depthTarget (r+2)) (1/8) s) ∧
    (1/2 : ℝ)≤BatchTwoContinuous.confidenceFailure Real.tanh inputLaw
      (BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N (r+1) σ)
        (depthTarget (r+2)) (1/8) s) (depthTarget (r+2)) (1/4) := by
  obtain ⟨hMN,hNp,hscale',hσsmall,hcost⟩ := widthThreshold_properties (by norm_num) hζ hN hscale
  have hr59 : 59≤r := (le_max_left _ _).trans hr
  have hrr : (60 : ℝ)≤(r : ℝ)+1 := by exact_mod_cast (show 60≤r+1 by omega)
  have hden := sample_event_sharp_denominator ((le_max_right _ _).trans hr) hn hnr hMN s hs
    (by norm_num : (0 : ℝ)<1/8) hσ (hscale'.trans (by norm_num))
  refine ⟨(Real.exp_pos _).trans_le hden,?_⟩
  apply confidence_failure_from_pair_rate hσ hσsmall hrr (hcost.trans (by linarith)) s hden
  intro ω
  have ht := small_scale_paired_input_tail (r := r+1) hNp (by omega) hσ hscale' ω
  apply ht.trans
  apply Real.exp_le_exp.mpr
  apply div_le_div_of_nonneg_right _ (sq_nonneg σ)
  push_cast
  linarith

/-- One explicit measurable sample event has probability at least 49/50 and
forces the confidence-error lower bound simultaneously at all sufficiently
large widths and all stronger scales. -/
theorem finite_power_depth_lower_bound {r n : ℕ}
    (hr : max 59 sharpInterpolationDepthThreshold≤r) (hn : 0<n)
    (hnr : (n : ℝ)≤Real.exp (((r : ℝ)+2)/100)) {ζ : ℝ} (hζ : 0<ζ) :
    ∃ E : Set (Fin n→RealInput 2), MeasurableSet E ∧
      (49/50 : ℝ)≤(Measure.pi (fun _ : Fin n=>inputLaw)).real E ∧
      ∀ s∈E, ∀ N, widthThreshold (interpolationWidth n) r (1/8) ζ≤N →
      ∀ σ : ℝ, 0<σ → σ^2≤(N : ℝ)^(-(1+ζ)) →
        0<(smallPrior 2 N (r+1) σ).real (trainingEvent Real.tanh (depthTarget (r+2)) (1/8) s) ∧
        (1/2 : ℝ)≤BatchTwoContinuous.confidenceFailure Real.tanh inputLaw
          (BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N (r+1) σ)
            (depthTarget (r+2)) (1/8) s) (depthTarget (r+2)) (1/4) := by
  refine ⟨powerInterpolationSamples r n,powerInterpolationSamples_measurable r n,
    powerInterpolationSamples_probability hn r,?_⟩
  intro s hs N hN σ hσ hscale
  exact finite_power_failure_on_sample_event hr hn hnr hζ hN hσ hscale s hs

/-- The literal power-prior statement, uniform for all γ≥1+ζ. -/
theorem power_prior_depth_lower_bound {r n : ℕ}
    (hr : max 59 sharpInterpolationDepthThreshold≤r) (hn : 0<n)
    (hnr : (n : ℝ)≤Real.exp (((r : ℝ)+2)/100)) {ζ : ℝ} (hζ : 0<ζ) :
    ∃ E : Set (Fin n→RealInput 2), MeasurableSet E ∧
      (49/50 : ℝ)≤(Measure.pi (fun _ : Fin n=>inputLaw)).real E ∧
      ∀ s∈E, ∀ N, widthThreshold (interpolationWidth n) r (1/8) ζ≤N →
      ∀ γ : ℝ, 1+ζ≤γ →
        0<(powerPrior 2 N (r+1) γ).real (trainingEvent Real.tanh (depthTarget (r+2)) (1/8) s) ∧
        (1/2 : ℝ)≤BatchTwoContinuous.confidenceFailure Real.tanh inputLaw
          (BatchTwoContinuous.posterior Real.tanh (powerPrior 2 N (r+1) γ)
            (depthTarget (r+2)) (1/8) s) (depthTarget (r+2)) (1/4) := by
  obtain ⟨E,hE,hprob,hgood⟩ := finite_power_depth_lower_bound hr hn hnr hζ
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
