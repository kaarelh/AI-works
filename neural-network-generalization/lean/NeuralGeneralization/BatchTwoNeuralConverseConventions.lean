import NeuralGeneralization.BatchTwoNeuralConversePrediction
import NeuralGeneralization.BatchTwoNeuralConversePriorLimit

/-! Sampling, majority decisions, and confidence failures for actual neural action. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical MeasureTheory
open ConcreteModel

variable {X : Type*} [Fintype X]

def labelMass (p : (X → Bool) → ℝ) (x : X) (y : Bool) : ℝ :=
  ∑ g, if g x=y then p g else 0

def confidenceError (f : X → Bool) (query : ℕ → X) (p : ℕ → (X → Bool) → ℝ)
    (θ : ℝ) (t : ℕ) : Bool := decide (labelMass (p t) (query t) (f (query t))≤θ)

theorem exists_correct_of_labelMass_pos (p : (X → Bool) → ℝ) (x : X) (y : Bool)
    (hm : 0<labelMass p x y) : ∃ g,p g≠0 ∧ g x=y := by
  by_contra! h
  have hz : labelMass p x y=0 := by
    unfold labelMass
    apply Finset.sum_eq_zero
    intro g _
    by_cases hg : g x=y
    · rw [if_pos hg]
      by_contra hp
      exact h g hp hg
    · exact if_neg hg
  linarith

theorem confidence_success (R : (X → Bool) → ℝ) (f : X → Bool) (query : ℕ → X)
    (p : ℕ → (X → Bool) → ℝ) (hp : ∀ t, IsMinimumMixture R f (observed query t) (p t))
    {θ : ℝ} (hθ : 0≤θ) : SuccessHasMinimizer R f query (confidenceError f query p θ) := by
  intro t he
  have hmass : θ<labelMass (p t) (query t) (f (query t)) := by
    simpa [confidenceError] using he
  obtain ⟨g,hpg,hcorrect⟩ := exists_correct_of_labelMass_pos _ _ _ (hθ.trans_lt hmass)
  exact ⟨g,(hp t).2.2 g hpg |>.1,(hp t).2.2 g hpg |>.2,hcorrect⟩

theorem labelMass_observed (R : (X → Bool) → ℝ) (f : X → Bool) (A : Finset X)
    (p : (X → Bool) → ℝ) (hp : IsMinimumMixture R f A p) (x : X) (hx : x∈A) :
    labelMass p x (f x)=1 := by
  rw [←hp.2.1]
  unfold labelMass
  apply Finset.sum_congr rfl
  intro g _
  by_cases hpg : p g=0
  · simp [hpg]
  · rw [if_pos ((hp.2.2 g hpg).1 x hx)]

theorem confidence_error_fresh (R : (X → Bool) → ℝ) (f : X → Bool) (query : ℕ → X)
    (p : ℕ → (X → Bool) → ℝ) (hp : ∀ t, IsMinimumMixture R f (observed query t) (p t))
    {θ : ℝ} (hθ : θ<1) (t : ℕ) (he : confidenceError f query p θ t=true) :
    query t ∉ observed query t := by
  intro hx
  have hm := labelMass_observed R f _ (p t) (hp t) _ hx
  have herr : labelMass (p t) (query t) (f (query t))≤θ := by simpa [confidenceError] using he
  linarith

theorem minimum_mixture_samples (R : (X → Bool) → ℝ) (f : X → Bool) (query : ℕ → X)
    (p : ℕ → (X → Bool) → ℝ) (hp : ∀ t, IsMinimumMixture R f (observed query t) (p t))
    (draw : ℕ → X → Bool) (hd : ∀ t,p t (draw t)≠0) : SamplesMinimizers R f query draw :=
  fun t => (hp t).2.2 (draw t) (hd t)

def binaryError (f : X → Bool) (query : ℕ → X) (predict : ℕ → Bool) (t : ℕ) : Bool :=
  decide (predict t≠f (query t))

def MajorityRule (query : ℕ → X) (p : ℕ → (X → Bool) → ℝ) (predict : ℕ → Bool) : Prop :=
  ∀ t,(1 : ℝ)/2≤labelMass (p t) (query t) (predict t)

theorem majority_success (R : (X → Bool) → ℝ) (f : X → Bool) (query : ℕ → X)
    (p : ℕ → (X → Bool) → ℝ) (hp : ∀ t, IsMinimumMixture R f (observed query t) (p t))
    (predict : ℕ → Bool) (hm : MajorityRule query p predict) :
    SuccessHasMinimizer R f query (binaryError f query predict) := by
  intro t he
  have hcorrect : predict t=f (query t) := by simpa [binaryError] using he
  have hmass : 0<labelMass (p t) (query t) (f (query t)) := by rw [←hcorrect]; linarith [hm t]
  obtain ⟨g,hpg,hg⟩ := exists_correct_of_labelMass_pos _ _ _ hmass
  exact ⟨g,(hp t).2.2 g hpg |>.1,(hp t).2.2 g hpg |>.2,hg⟩

/-- Literal expected mistakes of any minimum-action posterior sampler imply
an actual supported target implementation with the paper's K energy budget. -/
theorem expected_sampled_supported_energy {d : ℕ} (hd : 0<d) (r : ℕ) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) (f : BooleanFunction d)
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (query : Ω → ℕ → Cube d) (draw : Ω → ℕ → BooleanFunction d) (stop : Ω → ℕ)
    (hs : ∀ᵐ ω ∂μ, SamplesMinimizers (neuralSqrtAction r Λ U) f (query ω) (draw ω))
    (hcover : ∀ᵐ ω ∂μ, observed (query ω) (stop ω)=Finset.univ)
    (hmeas : AEStronglyMeasurable (fun ω => (errorCount (sampledError f (query ω) (draw ω)) (stop ω) : ℝ)) μ) :
    let m := ∫ ω, (errorCount (sampledError f (query ω) (draw ω)) (stop ω) : ℝ) ∂μ
    ∃ N : ℕ, 0<N ∧ ∃ w : Weights d N r, w ∈ functionSupport Λ U f ∧
      weightedSquaredNorm w<1+repairBudget d r U*(m+1)^2 := by
  have hm : 0≤∫ ω, (errorCount (sampledError f (query ω) (draw ω)) (stop ω) : ℝ) ∂μ :=
    integral_nonneg (fun _ => Nat.cast_nonneg _)
  exact exists_supported_energy_of_action_bound hd r hΛ hU f hm
    (expected_neural_sampled_action hd r hΛ hU f μ query draw stop hs hcover hmeas)

end
end NeuralGeneralization.BatchTwoNeuralConverse
