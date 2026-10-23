import NeuralGeneralization.BatchTwoNeuralConverseConventions

/-! Actual error counts for all three prediction conventions. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical MeasureTheory
open ConcreteModel
variable {X : Type*} [Fintype X]

def ErrorsAreFresh (query : ℕ → X) (error : ℕ → Bool) : Prop :=
  ∀ t,error t=true → query t∉observed query t

theorem fresh_count_le_observed (query : ℕ → X) (error : ℕ → Bool)
    (hfresh : ErrorsAreFresh query error) (t : ℕ) : errorCount error t≤(observed query t).card := by
  induction t with
  | zero => simp
  | succ t ih =>
    rw [errorCount_succ,observed_succ]
    cases he : error t with
    | false => simpa only [Bool.false_eq_true,↓reduceIte,add_zero] using
        ih.trans (Finset.card_le_card (Finset.subset_insert _ _))
    | true =>
      rw [Finset.card_insert_of_notMem (hfresh t he)]
      simpa using Nat.add_le_add_right ih 1

theorem fresh_count_le_card (query : ℕ → X) (error : ℕ → Bool)
    (hfresh : ErrorsAreFresh query error) (t : ℕ) : errorCount error t≤Fintype.card X :=
  (fresh_count_le_observed query error hfresh t).trans (Finset.card_le_univ _)

theorem fresh_count_integrable {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (query : Ω → ℕ → X)
    (error : Ω → ℕ → Bool) (stop : Ω → ℕ)
    (hfresh : ∀ᵐ ω ∂μ,ErrorsAreFresh (query ω) (error ω))
    (hmeas : AEStronglyMeasurable (fun ω => (errorCount (error ω) (stop ω):ℝ)) μ) :
    Integrable (fun ω => (errorCount (error ω) (stop ω):ℝ)) μ := by
  apply (integrable_const (Fintype.card X:ℝ)).mono' hmeas
  filter_upwards [hfresh] with ω hω
  rw [Real.norm_eq_abs,abs_of_nonneg (Nat.cast_nonneg _)]
  exact_mod_cast fresh_count_le_card (query ω) (error ω) hω (stop ω)

theorem labelMass_wrong_observed (R : (X → Bool) → ℝ) (f : X → Bool) (A : Finset X)
    (p : (X → Bool) → ℝ) (hp : IsMinimumMixture R f A p) (x : X) (hx : x∈A)
    (y : Bool) (hy : y≠f x) : labelMass p x y=0 := by
  unfold labelMass
  apply Finset.sum_eq_zero
  intro g _
  by_cases hpg : p g=0
  · simp [hpg]
  · have hg := (hp.2.2 g hpg).1 x hx
    rw [if_neg (by intro he; exact hy (he.symm.trans hg))]

theorem majority_error_fresh (R : (X → Bool) → ℝ) (f : X → Bool) (query : ℕ → X)
    (p : ℕ → (X → Bool) → ℝ) (hp : ∀ t, IsMinimumMixture R f (observed query t) (p t))
    (predict : ℕ → Bool) (hm : MajorityRule query p predict) :
    ErrorsAreFresh query (binaryError f query predict) := by
  intro t ht hx
  have hy : predict t≠f (query t) := by simpa [binaryError] using ht
  have hz := labelMass_wrong_observed R f _ (p t) (hp t) _ hx (predict t) hy
  have hb := hm t
  linarith

theorem expected_neural_action {d : ℕ} (hd : 0<d) (r : ℕ) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) (f : BooleanFunction d)
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (query : Ω → ℕ → Cube d) (error : Ω → ℕ → Bool) (stop : Ω → ℕ)
    (hs : ∀ᵐ ω ∂μ, SuccessHasMinimizer (neuralSqrtAction r Λ U) f (query ω) (error ω))
    (hfresh : ∀ᵐ ω ∂μ,ErrorsAreFresh (query ω) (error ω))
    (hcover : ∀ᵐ ω ∂μ, observed (query ω) (stop ω)=Finset.univ)
    (hmeas : AEStronglyMeasurable (fun ω => (errorCount (error ω) (stop ω):ℝ)) μ) :
    neuralSqrtAction r Λ U f≤Real.sqrt (repairBudget d r U)*
      ((∫ ω,(errorCount (error ω) (stop ω):ℝ) ∂μ)+1) := by
  have hb := expected_action_bound (X:=Cube d) μ (neuralSqrtAction r Λ U) f query error stop
    (b:=Real.sqrt (repairBudget d r U)) (a₀:=Real.sqrt (repairBudget d r U))
    (fun g a y => by
      have hh := neuralSqrtAction_repair hd r hΛ hU g a y
      have hdec : (fun (a b : Cube d) => Fintype.decidablePiFintype a b)=
          (fun (a b : Cube d) => Classical.propDecidable (a=b)) := Subsingleton.elim _ _
      rw [hdec] at hh
      exact hh)
    hs hcover (neuralSqrtAction_initial_le r hΛ hU f)
    (fresh_count_integrable μ query error stop hfresh hmeas)
  nlinarith

end
end NeuralGeneralization.BatchTwoNeuralConverse
