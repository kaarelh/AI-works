import NeuralGeneralization.BatchTwoNeuralConverseActualAction

/-! Literal sampled prediction errors for minimum-action neural learning. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical MeasureTheory
open ConcreteModel

variable {X : Type*} [Fintype X]

def SamplesMinimizers (R : (X → Bool) → ℝ) (f : X → Bool) (query : ℕ → X)
    (draw : ℕ → X → Bool) : Prop :=
  ∀ t, Fits (draw t) f (observed query t) ∧ R (draw t)=minAction R f (observed query t)

def sampledError (f : X → Bool) (query : ℕ → X) (draw : ℕ → X → Bool) (t : ℕ) : Bool :=
  decide (draw t (query t) ≠ f (query t))

theorem sampled_success (R : (X → Bool) → ℝ) (f : X → Bool) (query : ℕ → X)
    (draw : ℕ → X → Bool) (hs : SamplesMinimizers R f query draw) :
    SuccessHasMinimizer R f query (sampledError f query draw) := by
  intro t he
  refine ⟨draw t,(hs t).1,(hs t).2,?_⟩
  simpa [sampledError] using he

theorem sampled_error_fresh (R : (X → Bool) → ℝ) (f : X → Bool) (query : ℕ → X)
    (draw : ℕ → X → Bool) (hs : SamplesMinimizers R f query draw) (t : ℕ)
    (he : sampledError f query draw t=true) : query t ∉ observed query t := by
  intro hx
  have hf := (hs t).1 (query t) hx
  simp [sampledError,hf] at he

theorem sampled_count_le_observed (R : (X → Bool) → ℝ) (f : X → Bool) (query : ℕ → X)
    (draw : ℕ → X → Bool) (hs : SamplesMinimizers R f query draw) (t : ℕ) :
    errorCount (sampledError f query draw) t≤(observed query t).card := by
  induction t with
  | zero => simp
  | succ t ih =>
    rw [errorCount_succ,observed_succ]
    cases he : sampledError f query draw t with
    | false => simpa only [Bool.false_eq_true,↓reduceIte,add_zero] using
        ih.trans (Finset.card_le_card (Finset.subset_insert _ _))
    | true =>
      rw [Finset.card_insert_of_notMem (sampled_error_fresh R f query draw hs t he)]
      simpa using Nat.add_le_add_right ih 1

theorem sampled_count_le_card (R : (X → Bool) → ℝ) (f : X → Bool) (query : ℕ → X)
    (draw : ℕ → X → Bool) (hs : SamplesMinimizers R f query draw) (t : ℕ) :
    errorCount (sampledError f query draw) t≤Fintype.card X :=
  (sampled_count_le_observed R f query draw hs t).trans (Finset.card_le_univ _)

theorem sampled_count_integrable {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (R : (X → Bool) → ℝ) (f : X → Bool)
    (query : Ω → ℕ → X) (draw : Ω → ℕ → X → Bool) (stop : Ω → ℕ)
    (hs : ∀ᵐ ω ∂μ, SamplesMinimizers R f (query ω) (draw ω))
    (hmeas : AEStronglyMeasurable (fun ω => (errorCount (sampledError f (query ω) (draw ω)) (stop ω) : ℝ)) μ) :
    Integrable (fun ω => (errorCount (sampledError f (query ω) (draw ω)) (stop ω) : ℝ)) μ := by
  apply (integrable_const (Fintype.card X : ℝ)).mono' hmeas
  filter_upwards [hs] with ω hω
  rw [Real.norm_eq_abs,abs_of_nonneg (Nat.cast_nonneg _)]
  exact_mod_cast sampled_count_le_card R f (query ω) (draw ω) hω (stop ω)

/-- Expected literal sampled mistakes bound actual neural minimum energy.
The posterior may choose any mixture of tied minimum-action functions. -/
theorem expected_neural_sampled_action {d : ℕ} (hd : 0<d) (r : ℕ) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) (f : BooleanFunction d)
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (query : Ω → ℕ → Cube d) (draw : Ω → ℕ → BooleanFunction d) (stop : Ω → ℕ)
    (hs : ∀ᵐ ω ∂μ, SamplesMinimizers (neuralSqrtAction r Λ U) f (query ω) (draw ω))
    (hcover : ∀ᵐ ω ∂μ, observed (query ω) (stop ω)=Finset.univ)
    (hmeas : AEStronglyMeasurable (fun ω => (errorCount (sampledError f (query ω) (draw ω)) (stop ω) : ℝ)) μ) :
    neuralSqrtAction r Λ U f≤Real.sqrt (repairBudget d r U)*
      ((∫ ω, (errorCount (sampledError f (query ω) (draw ω)) (stop ω) : ℝ) ∂μ)+1) := by
  have hrep : ∀ g a y, neuralSqrtAction r Λ U (Function.update g a y)≤
      neuralSqrtAction r Λ U g+Real.sqrt (repairBudget d r U) :=
    neuralSqrtAction_repair hd r hΛ hU
  have h := expected_action_bound (X := Cube d) μ (neuralSqrtAction (d := d) r Λ U) f query
    (fun ω => sampledError f (query ω) (draw ω)) stop
    (b := Real.sqrt (repairBudget d r U)) (a₀ := Real.sqrt (repairBudget d r U))
    (by
      intro g a y
      have hh := hrep g a y
      have hdec : (fun (a b : Cube d) => Fintype.decidablePiFintype a b) =
          (fun (a b : Cube d) => Classical.propDecidable (a=b)) := Subsingleton.elim _ _
      rw [hdec] at hh
      exact hh)
    (hs.mono (fun ω hω => sampled_success _ f (query ω) (draw ω) hω)) hcover
    (neuralSqrtAction_initial_le r hΛ hU f)
    (sampled_count_integrable μ _ f query draw stop hs hmeas)
  nlinarith

theorem exists_supported_energy_of_action_bound {d : ℕ} (hd : 0<d) (r : ℕ) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) (f : BooleanFunction d) {m : ℝ} (hm : 0≤m)
    (hbound : neuralSqrtAction r Λ U f≤Real.sqrt (repairBudget d r U)*(m+1)) :
    ∃ N : ℕ, 0<N ∧ ∃ w : Weights d N r, w ∈ functionSupport Λ U f ∧
      weightedSquaredNorm w<1+repairBudget d r U*(m+1)^2 := by
  have hP := repairBudget_pos d r U
  have hK : 0<1+repairBudget d r U*(m+1)^2 := by positivity
  have hroot : Real.sqrt (repairBudget d r U)*(m+1)<Real.sqrt (1+repairBudget d r U*(m+1)^2) := by
    have h1 := Real.sq_sqrt hP.le
    have h2 := Real.sq_sqrt hK.le
    have hn := Real.sqrt_nonneg (repairBudget d r U)
    have hk := Real.sqrt_nonneg (1+repairBudget d r U*(m+1)^2)
    nlinarith [sq_nonneg (m+1)]
  obtain ⟨c,hc,hlt⟩ := (csInf_lt_iff (sqrtCosts_bddBelow r Λ U f)
    (sqrtCosts_nonempty hd r hΛ hU f)).mp (hbound.trans_lt hroot)
  obtain ⟨N,hN,w,hw,rfl⟩ := hc
  refine ⟨N,hN,w,hw,?_⟩
  have h1 := Real.sq_sqrt (weightedSquaredNorm_nonneg w)
  have h2 := Real.sq_sqrt hK.le
  nlinarith [Real.sqrt_nonneg (weightedSquaredNorm w)]

end
end NeuralGeneralization.BatchTwoNeuralConverse
