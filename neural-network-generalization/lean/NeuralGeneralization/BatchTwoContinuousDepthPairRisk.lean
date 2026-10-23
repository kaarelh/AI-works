import NeuralGeneralization.BatchTwoContinuousDepthSphere
import NeuralGeneralization.BatchTwoContinuousModel
import Mathlib.MeasureTheory.Integral.Prod

/-! Paired-input lower bounds for both posterior-sampled regression risk and
the strict confidence criterion, including arbitrary posterior mixtures. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous

theorem paired_strict_confidence_failure {Ω X : Type*}
    [MeasurableSpace Ω] [MeasurableSpace X]
    (ν : Measure Ω) [IsProbabilityMeasure ν]
    (left right : Ω → X) (hl : Measurable left) (hr : Measurable right)
    (q : X → ℝ) (hq : Measurable q) (θ : ℝ)
    (hpair : ∀ ω, q (left ω)+q (right ω) < 2*θ) :
    (1/2 : ℝ) ≤ (balancedPairLaw ν left right).real {x | q x < θ} := by
  let E : Set X := {x | q x < θ}
  have hE : MeasurableSet E := measurableSet_lt hq measurable_const
  have he : (left ⁻¹' E) ∪ (right ⁻¹' E) = univ := by
    ext ω
    simp only [mem_union,mem_preimage,mem_setOf_eq,mem_univ,iff_true,E]
    by_contra h
    push_neg at h
    linarith only [hpair ω,h.1,h.2]
  have hu := measureReal_union_le (μ := ν) (left ⁻¹' E) (right ⁻¹' E)
  rw [he,probReal_univ] at hu
  rw [balancedPairLaw_real ν left right hl hr E hE]
  linarith only [hu]

theorem correctProbability_bounds {N q : ℕ} (Q : Measure (Weights 2 N q))
    [IsProbabilityMeasure Q] (f : RealInput 2 → ℝ) (τ : ℝ) (x : RealInput 2) :
    0 ≤ correctProbability Real.tanh Q f τ x ∧ correctProbability Real.tanh Q f τ x ≤ 1 :=
  ⟨measureReal_nonneg,by
    unfold correctProbability
    exact (measureReal_mono (Set.subset_univ _)).trans_eq (probReal_univ (μ := Q))⟩

theorem correctProbability_integrable {N q : ℕ} (Q : Measure (Weights 2 N q))
    [IsProbabilityMeasure Q] (r : ℕ) (τ : ℝ) :
    Integrable (correctProbability Real.tanh Q (depthTarget r) τ) inputLaw := by
  apply Integrable.of_bound
    (measurable_correctProbability tanh_continuous Q (continuous_target r).measurable τ).aestronglyMeasurable 1
  exact Filter.Eventually.of_forall (fun x => by
    rw [Real.norm_eq_abs,abs_of_nonneg (correctProbability_bounds Q _ _ x).1]
    exact (correctProbability_bounds Q _ _ x).2)

theorem regression_risk_eq_one_sub_correct {N q : ℕ} (Q : Measure (Weights 2 N q))
    [IsProbabilityMeasure Q] (r : ℕ) (τ : ℝ) :
    risk Real.tanh inputLaw Q (depthTarget r) τ =
      1-∫ x, correctProbability Real.tanh Q (depthTarget r) τ x ∂inputLaw := by
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
  change ((inputLaw.prod Q) E).toReal = _
  rw [Measure.prod_apply hE,←integral_toReal (measurable_measure_prodMk_left hE).aemeasurable
    (Filter.Eventually.of_forall (fun x => measure_lt_top Q _))]
  change (∫ x, Q.real (Prod.mk x ⁻¹' E) ∂inputLaw)=_
  simp_rw [he]
  rw [integral_sub (integrable_const 1) (correctProbability_integrable Q r τ)]
  simp

theorem correct_probability_pair_sum {N q : ℕ}
    (Q : Measure (Weights 2 N q)) [IsProbabilityMeasure Q] (r : ℕ) {b : ℝ}
    (hpair : ∀ ω, Q.real {w | (1/2 : ℝ)≤
      |output Real.tanh w (sphereCoding ω)-output Real.tanh w (sphereCoding (flipCoordinate r ω))|}≤b)
    (ω : SignStream) :
    correctProbability Real.tanh Q (depthTarget r) (1/4) (sphereCoding ω)+
      correctProbability Real.tanh Q (depthTarget r) (1/4) (sphereCoding (flipCoordinate r ω))≤1+b := by
  let G : Set (Weights 2 N q) := {w |
    |output Real.tanh w (sphereCoding ω)-output Real.tanh w (sphereCoding (flipCoordinate r ω))|<1/2}
  have hb : Q.real Gᶜ≤b := by simpa only [G,compl_setOf,not_lt] using hpair ω
  apply posterior_pair_sum_le Q (output Real.tanh)
    (fun x => (continuous_output_weights tanh_continuous x).measurable)
    (depthTarget r) G hb _ _
  intro w hw
  apply incompatible_correct_outputs (sphereCoding_pair_target_gap r ω) (le_refl _)
  change _<1
  dsimp only [G,mem_setOf_eq] at hw
  linarith only [hw]

theorem paired_strict_output_change_barrier {N q : ℕ}
    (Q : Measure (Weights 2 N q)) [IsProbabilityMeasure Q] (r : ℕ) {b : ℝ} (hb : b<1/3)
    (hpair : ∀ ω, Q.real {w | (1/2 : ℝ)≤
      |output Real.tanh w (sphereCoding ω)-output Real.tanh w (sphereCoding (flipCoordinate r ω))|}≤b) :
    (1/2 : ℝ) ≤ inputLaw.real {x | correctProbability Real.tanh Q (depthTarget r) (1/4) x < 2/3} := by
  rw [←inputLaw_balanced_pair r]
  apply paired_strict_confidence_failure signLaw sphereCoding (sphereCoding ∘ flipCoordinate r)
    sphereCoding_measurable (sphereCoding_measurable.comp (flipCoordinate_measurable r))
    _ (measurable_correctProbability tanh_continuous Q (continuous_target r).measurable (1/4)) (2/3)
  intro ω
  have h := correct_probability_pair_sum Q r hpair ω
  change correctProbability Real.tanh Q (depthTarget r) (1/4) (sphereCoding ω)+
    correctProbability Real.tanh Q (depthTarget r) (1/4) (sphereCoding (flipCoordinate r ω)) < 2*(2/3 : ℝ)
  linarith only [h,hb]

theorem paired_gibbs_risk_lower {N q : ℕ}
    (Q : Measure (Weights 2 N q)) [IsProbabilityMeasure Q] (r : ℕ) {b : ℝ}
    (hpair : ∀ ω, Q.real {w | (1/2 : ℝ)≤
      |output Real.tanh w (sphereCoding ω)-output Real.tanh w (sphereCoding (flipCoordinate r ω))|}≤b) :
    (1-b)/2 ≤ risk Real.tanh inputLaw Q (depthTarget r) (1/4) := by
  let p := correctProbability Real.tanh Q (depthTarget r) (1/4)
  have hp : Measurable p := measurable_correctProbability tanh_continuous Q (continuous_target r).measurable (1/4)
  have hil : Integrable (p ∘ sphereCoding) signLaw := by
    apply Integrable.of_bound (hp.comp sphereCoding_measurable).aestronglyMeasurable 1
    exact Filter.Eventually.of_forall (fun ω => by
      change |correctProbability Real.tanh Q (depthTarget r) (1/4) _|≤1
      rw [abs_of_nonneg (correctProbability_bounds Q _ _ _).1]
      exact (correctProbability_bounds Q _ _ _).2)
  have hir : Integrable (p ∘ (sphereCoding ∘ flipCoordinate r)) signLaw := by
    apply Integrable.of_bound (hp.comp (sphereCoding_measurable.comp (flipCoordinate_measurable r))).aestronglyMeasurable 1
    exact Filter.Eventually.of_forall (fun ω => by
      change |correctProbability Real.tanh Q (depthTarget r) (1/4) _|≤1
      rw [abs_of_nonneg (correctProbability_bounds Q _ _ _).1]
      exact (correctProbability_bounds Q _ _ _).2)
  have hsum : (∫ ω, p (sphereCoding ω)+p (sphereCoding (flipCoordinate r ω)) ∂signLaw)≤1+b := by
    have h := integral_mono (hil.add hir) (integrable_const (1+b))
      (fun ω => correct_probability_pair_sum Q r hpair ω)
    simpa only [integral_const,probReal_univ,one_smul,Pi.add_apply,Function.comp_apply] using h
  have hl : (∫ ω, p (sphereCoding ω) ∂signLaw)=∫ x,p x ∂inputLaw := by
    rw [inputLaw,integral_map sphereCoding_measurable.aemeasurable hp.aestronglyMeasurable]
  have hr : (∫ ω, p (sphereCoding (flipCoordinate r ω)) ∂signLaw)=∫ x,p x ∂inputLaw := by
    rw [←sphereCoding_flip_law r,
      integral_map (sphereCoding_measurable.comp (flipCoordinate_measurable r)).aemeasurable hp.aestronglyMeasurable]
    rfl
  have hadd := integral_add hil hir
  simp only [Function.comp_apply] at hadd
  rw [hadd,hl,hr] at hsum
  rw [regression_risk_eq_one_sub_correct Q r (1/4)]
  change _≤1-∫ x,p x ∂inputLaw
  linarith only [hsum]

#print axioms paired_gibbs_risk_lower
#print axioms paired_strict_output_change_barrier
end NeuralGeneralization.BatchTwoContinuousDepthLower
