import NeuralGeneralization.BatchTwoContinuousDepthSmoothStrong
import NeuralGeneralization.BatchTwoContinuousDepthJitterTail
import NeuralGeneralization.BatchTwoContinuousDepthPairRisk

/-! Literal regression risk and confidence bounds for arbitrary mixtures
under the smooth law, with the correct reduced pair threshold .48. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous

theorem smoothCoding_flip_law (r : ℕ) :
    (signLaw.prod (smoothJitterLaw r)).map (jitteredCoding r ∘ jitterFlip r) = smoothInputLaw r := by
  rw [← Measure.map_map (jitteredCoding_measurable r) (jitterFlip_measurable r), jitterFlip_preserves]
  rfl

theorem smooth_correctProbability_integrable {N q : ℕ} (Q : Measure (Weights 2 N q))
    [IsProbabilityMeasure Q] (r : ℕ) (τ : ℝ) :
    Integrable (correctProbability Real.tanh Q (depthTarget r) τ) (smoothInputLaw r) := by
  apply Integrable.of_bound
    (measurable_correctProbability tanh_continuous Q (continuous_target r).measurable τ).aestronglyMeasurable 1
  exact Filter.Eventually.of_forall (fun x => by
    rw [Real.norm_eq_abs,abs_of_nonneg (correctProbability_bounds Q _ _ x).1]
    exact (correctProbability_bounds Q _ _ x).2)

theorem smooth_regression_risk_eq_one_sub_correct {N q : ℕ} (Q : Measure (Weights 2 N q))
    [IsProbabilityMeasure Q] (r : ℕ) (τ : ℝ) :
    risk Real.tanh (smoothInputLaw r) Q (depthTarget r) τ =
      1-∫ x, correctProbability Real.tanh Q (depthTarget r) τ x ∂(smoothInputLaw r) := by
  let E := jointErrorEvent (N := N) (r := q) Real.tanh (depthTarget r) τ
  have hE : MeasurableSet E := measurable_jointErrorEvent tanh_continuous (continuous_target r).measurable τ
  have he : ∀ x, Q.real (Prod.mk x ⁻¹' E)=1-correctProbability Real.tanh Q (depthTarget r) τ x := by
    intro x
    have h := probReal_compl_eq_one_sub (μ := Q) (measurable_prodMk_left (x := x) hE)
    have hc : (Prod.mk x ⁻¹' E)ᶜ = {w | |output Real.tanh w x-depthTarget r x|≤τ} := by
      ext w
      simp only [E,jointErrorEvent,mem_compl_iff,mem_preimage,mem_setOf_eq,not_lt]
    rw [hc] at h
    change correctProbability Real.tanh Q (depthTarget r) τ x = 1-Q.real (Prod.mk x ⁻¹' E) at h
    linarith only [h]
  change (((smoothInputLaw r).prod Q) E).toReal = _
  rw [Measure.prod_apply hE,←integral_toReal (measurable_measure_prodMk_left hE).aemeasurable
    (Filter.Eventually.of_forall (fun x => measure_lt_top Q _))]
  change (∫ x, Q.real (Prod.mk x ⁻¹' E) ∂(smoothInputLaw r))=_
  simp_rw [he]
  rw [integral_sub (integrable_const 1) (smooth_correctProbability_integrable Q r τ)]
  simp

theorem smooth_correct_probability_pair_sum {N q : ℕ}
    (Q : Measure (Weights 2 N q)) [IsProbabilityMeasure Q] (r : ℕ) {b : ℝ}
    (hpair : ∀ ω, Q.real {w | (12/25 : ℝ)≤
      |output Real.tanh w ((jitteredCoding r) ω)-output Real.tanh w ((jitteredCoding r) (jitterFlip r ω))|}≤b)
    (ω : SignStream × Jitter r) :
    correctProbability Real.tanh Q (depthTarget r) (1/4) ((jitteredCoding r) ω)+
      correctProbability Real.tanh Q (depthTarget r) (1/4) ((jitteredCoding r) (jitterFlip r ω))≤1+b := by
  let G : Set (Weights 2 N q) := {w |
    |output Real.tanh w ((jitteredCoding r) ω)-output Real.tanh w ((jitteredCoding r) (jitterFlip r ω))|<12/25}
  have hb : Q.real Gᶜ≤b := by simpa only [G,compl_setOf,not_lt] using hpair ω
  apply posterior_pair_sum_le Q (output Real.tanh)
    (fun x => (continuous_output_weights tanh_continuous x).measurable)
    (depthTarget r) G hb _ _
  intro w hw
  exact jittered_incompatible_correct_outputs (jittered_pair_target_gap r ω) hw

theorem smooth_paired_strict_output_change_barrier {N q : ℕ}
    (Q : Measure (Weights 2 N q)) [IsProbabilityMeasure Q] (r : ℕ) {b : ℝ} (hb : b<1/3)
    (hpair : ∀ ω, Q.real {w | (12/25 : ℝ)≤
      |output Real.tanh w ((jitteredCoding r) ω)-output Real.tanh w ((jitteredCoding r) (jitterFlip r ω))|}≤b) :
    (1/2 : ℝ) ≤ (smoothInputLaw r).real {x | correctProbability Real.tanh Q (depthTarget r) (1/4) x < 2/3} := by
  change (1/2 : ℝ) ≤ (jitteredInputLaw r (smoothJitterLaw r)).real _
  rw [← jitteredInputLaw_balanced_pair r (smoothJitterLaw r)]
  apply paired_strict_confidence_failure (signLaw.prod (smoothJitterLaw r)) (jitteredCoding r) ((jitteredCoding r) ∘ jitterFlip r)
    (jitteredCoding_measurable r) ((jitteredCoding_measurable r).comp (jitterFlip_measurable r))
    _ (measurable_correctProbability tanh_continuous Q (continuous_target r).measurable (1/4)) (2/3)
  intro ω
  have h := smooth_correct_probability_pair_sum Q r hpair ω
  change correctProbability Real.tanh Q (depthTarget r) (1/4) ((jitteredCoding r) ω)+
    correctProbability Real.tanh Q (depthTarget r) (1/4) ((jitteredCoding r) (jitterFlip r ω)) < 2*(2/3 : ℝ)
  linarith only [h,hb]

theorem smooth_paired_gibbs_risk_lower {N q : ℕ}
    (Q : Measure (Weights 2 N q)) [IsProbabilityMeasure Q] (r : ℕ) {b : ℝ}
    (hpair : ∀ ω, Q.real {w | (12/25 : ℝ)≤
      |output Real.tanh w ((jitteredCoding r) ω)-output Real.tanh w ((jitteredCoding r) (jitterFlip r ω))|}≤b) :
    (1-b)/2 ≤ risk Real.tanh (smoothInputLaw r) Q (depthTarget r) (1/4) := by
  let p := correctProbability Real.tanh Q (depthTarget r) (1/4)
  have hp : Measurable p := measurable_correctProbability tanh_continuous Q (continuous_target r).measurable (1/4)
  have hil : Integrable (p ∘ (jitteredCoding r)) (signLaw.prod (smoothJitterLaw r)) := by
    apply Integrable.of_bound (hp.comp (jitteredCoding_measurable r)).aestronglyMeasurable 1
    exact Filter.Eventually.of_forall (fun ω => by
      change |correctProbability Real.tanh Q (depthTarget r) (1/4) _|≤1
      rw [abs_of_nonneg (correctProbability_bounds Q _ _ _).1]
      exact (correctProbability_bounds Q _ _ _).2)
  have hir : Integrable (p ∘ ((jitteredCoding r) ∘ jitterFlip r)) (signLaw.prod (smoothJitterLaw r)) := by
    apply Integrable.of_bound (hp.comp ((jitteredCoding_measurable r).comp (jitterFlip_measurable r))).aestronglyMeasurable 1
    exact Filter.Eventually.of_forall (fun ω => by
      change |correctProbability Real.tanh Q (depthTarget r) (1/4) _|≤1
      rw [abs_of_nonneg (correctProbability_bounds Q _ _ _).1]
      exact (correctProbability_bounds Q _ _ _).2)
  have hsum : (∫ ω, p ((jitteredCoding r) ω)+p ((jitteredCoding r) (jitterFlip r ω)) ∂(signLaw.prod (smoothJitterLaw r)))≤1+b := by
    have h := integral_mono (hil.add hir) (integrable_const (1+b))
      (fun ω => smooth_correct_probability_pair_sum Q r hpair ω)
    simpa only [integral_const,probReal_univ,one_smul,Pi.add_apply,Function.comp_apply] using h
  have hl : (∫ ω, p ((jitteredCoding r) ω) ∂(signLaw.prod (smoothJitterLaw r)))=∫ x,p x ∂(smoothInputLaw r) := by
    rw [smoothInputLaw, jitteredInputLaw,integral_map (jitteredCoding_measurable r).aemeasurable hp.aestronglyMeasurable]
  have hr : (∫ ω, p ((jitteredCoding r) (jitterFlip r ω)) ∂(signLaw.prod (smoothJitterLaw r)))=∫ x,p x ∂(smoothInputLaw r) := by
    rw [←smoothCoding_flip_law r,
      integral_map ((jitteredCoding_measurable r).comp (jitterFlip_measurable r)).aemeasurable hp.aestronglyMeasurable]
    rfl
  have hadd := integral_add hil hir
  simp only [Function.comp_apply] at hadd
  rw [hadd,hl,hr] at hsum
  rw [smooth_regression_risk_eq_one_sub_correct Q r (1/4)]
  change _≤1-∫ x,p x ∂(smoothInputLaw r)
  linarith only [hsum]

end NeuralGeneralization.BatchTwoContinuousDepthLower
