import NeuralGeneralization.BatchTwoNeuralConverseReconstruction
import NeuralGeneralization.BatchTwoNeuralConverseCounts
import NeuralGeneralization.BatchTwoNeuralConverseConditioning

/-! The polynomial-depth neural mistake converse, with all prediction conventions. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical MeasureTheory
open ConcreteModel
variable {d r : ℕ}

def mistakeConverseWidth (d r : ℕ) (Λ U m : ℝ) : ℕ :=
  converseWidth d r (1+repairBudget d r U*(m+1)^2) Λ

/-- The paper's pathwise main bound, including unrestricted ties. The generic
success condition is discharged for each literal convention below. -/
theorem polynomial_depth_mistake_converse (hd : 0<d) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) (f : BooleanFunction d) (query : ℕ → Cube d) (error : ℕ → Bool)
    (hsuccess : SuccessHasMinimizer (neuralSqrtAction r Λ U) f query error)
    (stop : ℕ) (hcover : observed query stop=Finset.univ) :
    realizesAtComplexity (r:=r) Real.tanh f
      (mistakeConverseWidth d r Λ U (errorCount error stop)) :=
  neural_action_reconstruction hd r hΛ hU f (Nat.cast_nonneg _)
    (neural_action_mistake_bound hd r hΛ hU f query error hsuccess stop hcover)

/-- Sampling any minimum-action sign function, with arbitrary tie probabilities. -/
theorem sampled_mistake_converse (hd : 0<d) {Λ U : ℝ} (hΛ : 1<Λ) (hU : 1<U)
    (f : BooleanFunction d) (query : ℕ → Cube d) (draw : ℕ → BooleanFunction d)
    (hs : SamplesMinimizers (neuralSqrtAction r Λ U) f query draw)
    (stop : ℕ) (hcover : observed query stop=Finset.univ) :
    realizesAtComplexity (r:=r) Real.tanh f
      (mistakeConverseWidth d r Λ U (errorCount (sampledError f query draw) stop)) :=
  polynomial_depth_mistake_converse hd hΛ hU f query _ (sampled_success _ _ _ _ hs) stop hcover

/-- Majority prediction from any minimum-action posterior mixture. -/
theorem majority_mistake_converse (hd : 0<d) {Λ U : ℝ} (hΛ : 1<Λ) (hU : 1<U)
    (f : BooleanFunction d) (query : ℕ → Cube d) (p : ℕ → BooleanFunction d → ℝ)
    (hp : ∀ t,IsMinimumMixture (neuralSqrtAction r Λ U) f (observed query t) (p t))
    (predict : ℕ → Bool) (hm : MajorityRule query p predict)
    (stop : ℕ) (hcover : observed query stop=Finset.univ) :
    realizesAtComplexity (r:=r) Real.tanh f
      (mistakeConverseWidth d r Λ U (errorCount (binaryError f query predict) stop)) :=
  polynomial_depth_mistake_converse hd hΛ hU f query _ (majority_success _ _ _ _ hp _ hm) stop hcover

/-- The correct label has posterior probability at most θ on a confidence failure. -/
theorem confidence_mistake_converse (hd : 0<d) {Λ U θ : ℝ} (hΛ : 1<Λ) (hU : 1<U)
    (hθ : 0≤θ) (f : BooleanFunction d) (query : ℕ → Cube d) (p : ℕ → BooleanFunction d → ℝ)
    (hp : ∀ t,IsMinimumMixture (neuralSqrtAction r Λ U) f (observed query t) (p t))
    (stop : ℕ) (hcover : observed query stop=Finset.univ) :
    realizesAtComplexity (r:=r) Real.tanh f
      (mistakeConverseWidth d r Λ U (errorCount (confidenceError f query p θ) stop)) :=
  polynomial_depth_mistake_converse hd hΛ hU f query _ (confidence_success _ _ _ _ hp hθ) stop hcover

/-- Expected literal errors over random/adaptive complete reveals. -/
theorem expected_polynomial_depth_mistake_converse (hd : 0<d) {Λ U : ℝ} (hΛ : 1<Λ) (hU : 1<U)
    (f : BooleanFunction d) {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (query : Ω → ℕ → Cube d)
    (error : Ω → ℕ → Bool) (stop : Ω → ℕ)
    (hs : ∀ᵐ ω ∂μ,SuccessHasMinimizer (neuralSqrtAction r Λ U) f (query ω) (error ω))
    (hfresh : ∀ᵐ ω ∂μ,ErrorsAreFresh (query ω) (error ω))
    (hcover : ∀ᵐ ω ∂μ,observed (query ω) (stop ω)=Finset.univ)
    (hmeas : AEStronglyMeasurable (fun ω => (errorCount (error ω) (stop ω):ℝ)) μ) :
    realizesAtComplexity (r:=r) Real.tanh f
      (mistakeConverseWidth d r Λ U (∫ ω,(errorCount (error ω) (stop ω):ℝ) ∂μ)) :=
  neural_action_reconstruction hd r hΛ hU f (integral_nonneg (fun _ => Nat.cast_nonneg _))
    (expected_neural_action hd r hΛ hU f μ query error stop hs hfresh hcover hmeas)

theorem expected_sampled_mistake_converse (hd : 0<d) {Λ U : ℝ} (hΛ : 1<Λ) (hU : 1<U)
    (f : BooleanFunction d) {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (query : Ω → ℕ → Cube d)
    (draw : Ω → ℕ → BooleanFunction d) (stop : Ω → ℕ)
    (hs : ∀ᵐ ω ∂μ,SamplesMinimizers (neuralSqrtAction r Λ U) f (query ω) (draw ω))
    (hcover : ∀ᵐ ω ∂μ,observed (query ω) (stop ω)=Finset.univ)
    (hmeas : AEStronglyMeasurable (fun ω => (errorCount (sampledError f (query ω) (draw ω)) (stop ω):ℝ)) μ) :
    realizesAtComplexity (r:=r) Real.tanh f
      (mistakeConverseWidth d r Λ U (∫ ω,(errorCount (sampledError f (query ω) (draw ω)) (stop ω):ℝ) ∂μ)) :=
  expected_polynomial_depth_mistake_converse hd hΛ hU f μ query _ stop
    (hs.mono (fun ω hω => sampled_success _ _ _ _ hω))
    (hs.mono (fun ω hω => sampled_error_fresh _ _ _ _ hω)) hcover hmeas

theorem expected_majority_mistake_converse (hd : 0<d) {Λ U : ℝ} (hΛ : 1<Λ) (hU : 1<U)
    (f : BooleanFunction d) {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (query : Ω → ℕ → Cube d)
    (p : Ω → ℕ → BooleanFunction d → ℝ) (predict : Ω → ℕ → Bool) (stop : Ω → ℕ)
    (hp : ∀ᵐ ω ∂μ,∀ t,IsMinimumMixture (neuralSqrtAction r Λ U) f (observed (query ω) t) (p ω t))
    (hm : ∀ᵐ ω ∂μ,MajorityRule (query ω) (p ω) (predict ω))
    (hcover : ∀ᵐ ω ∂μ,observed (query ω) (stop ω)=Finset.univ)
    (hmeas : AEStronglyMeasurable (fun ω => (errorCount (binaryError f (query ω) (predict ω)) (stop ω):ℝ)) μ) :
    realizesAtComplexity (r:=r) Real.tanh f
      (mistakeConverseWidth d r Λ U (∫ ω,(errorCount (binaryError f (query ω) (predict ω)) (stop ω):ℝ) ∂μ)) := by
  apply expected_polynomial_depth_mistake_converse hd hΛ hU f μ query _ stop _ _ hcover hmeas
  · filter_upwards [hp,hm] with ω hpω hmω
    exact majority_success _ _ _ _ hpω _ hmω
  · filter_upwards [hp,hm] with ω hpω hmω
    exact majority_error_fresh _ _ _ _ hpω _ hmω

theorem expected_confidence_mistake_converse (hd : 0<d) {Λ U θ : ℝ} (hΛ : 1<Λ) (hU : 1<U)
    (hθ : 0≤θ) (hθ1 : θ<1) (f : BooleanFunction d) {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (query : Ω → ℕ → Cube d)
    (p : Ω → ℕ → BooleanFunction d → ℝ) (stop : Ω → ℕ)
    (hp : ∀ᵐ ω ∂μ,∀ t,IsMinimumMixture (neuralSqrtAction r Λ U) f (observed (query ω) t) (p ω t))
    (hcover : ∀ᵐ ω ∂μ,observed (query ω) (stop ω)=Finset.univ)
    (hmeas : AEStronglyMeasurable (fun ω => (errorCount (confidenceError f (query ω) (p ω) θ) (stop ω):ℝ)) μ) :
    realizesAtComplexity (r:=r) Real.tanh f
      (mistakeConverseWidth d r Λ U (∫ ω,(errorCount (confidenceError f (query ω) (p ω) θ) (stop ω):ℝ) ∂μ)) :=
  expected_polynomial_depth_mistake_converse hd hΛ hU f μ query _ stop
    (hp.mono (fun ω hpω => confidence_success _ _ _ _ hpω hθ))
    (hp.mono (fun ω hpω => confidence_error_fresh _ _ _ _ hpω hθ1)) hcover hmeas

#print axioms polynomial_depth_mistake_converse
#print axioms expected_sampled_mistake_converse
#print axioms iterated_limit_minimum_mixture
#print axioms functionPosterior_eq_parameter_posterior

end
end NeuralGeneralization.BatchTwoNeuralConverse
