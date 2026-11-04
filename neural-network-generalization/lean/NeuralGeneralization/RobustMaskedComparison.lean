import NeuralGeneralization.RobustPredictionComparison

/-! A common finite event for exception-masked ramp losses, with the unchanged
training-margin likelihood also imposed at inputs inside the exceptions. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.RobustStatistics.PredictionComparison
open ConcreteModel RobustConfidence
variable {m u : ℝ} (rule : PredictionComparison m u)
variable {X H W : Type*}
  [Fintype X] [MeasurableSpace X] [MeasurableSingletonClass X]
  [Fintype H] [MeasurableSpace H] [MeasurableSingletonClass H]
  [MeasurableSpace W]

open Classical in
def maskedCandidateLoss (B : Set X) (f : X → Bool) (candidate : H → X → ℝ)
    (h : H) (x : X) : ℝ := if x ∈ B then 0 else rule.candidateLoss f candidate h x

lemma maskedCandidateLoss_bounds (B : Set X) (f : X → Bool) (candidate : H → X → ℝ)
    (h : H) (x : X) :
    0 ≤ rule.maskedCandidateLoss B f candidate h x ∧ rule.maskedCandidateLoss B f candidate h x ≤ 1 := by
  classical
  by_cases hx : x ∈ B
  · simp [maskedCandidateLoss,hx]
  · simpa [maskedCandidateLoss,candidateLoss,hx] using rule.loss_bounds (f x) (candidate h x)

/-- The population cost of an exceptional region is charged exactly once. -/
theorem masked_posterior_margin_risk_on_event
    (D : Measure X) [IsProbabilityMeasure D] (B : Set X)
    (f : X → Bool) (candidate : H → X → ℝ)
    {n : ℕ} (hn : 0 < n) {τ α β : ℝ} (hα : 0 ≤ α)
    (s : Fin n → X)
    (hs : s ∈ generalizationEvent D (rule.maskedCandidateLoss B f candidate) n τ)
    (Q Q' : Measure W) [IsProbabilityMeasure Q] [IsProbabilityMeasure Q']
    (Γ : Measure H) [IsProbabilityMeasure Γ]
    (z : W → X → ℝ) (hz : ∀ x,Measurable (fun w => z w x))
    (π : ∀ x,ProbabilityCoupling Q' Γ)
    (hfail : ∀ x, x ∉ B → (π x).joint.real
      (rule.failure (fun w => z w x) (fun h => candidate h x)) ≤ α)
    (htrain : ∀ i,Q'.real {w | labelReal (f (s i))*z w (s i) ≤ m} = 0)
    (hrestore : ∀ x,Q.real {w | labelReal (f x)*z w x ≤ u} ≤
      β+Q'.real {w | labelReal (f x)*z w x ≤ u}) :
    gibbsMarginRisk D Q (fun x => labelReal (f x)) z u ≤ D.real B+β+2*α+τ := by
  classical
  let risk := fun x => Q.real {w | labelReal (f x)*z w x ≤ u}
  let risk' := fun x => Q'.real {w | labelReal (f x)*z w x ≤ u}
  let mask : X → ℝ := B.indicator (fun _ => 1)
  have hh := risk_on_generalization_event D (rule.maskedCandidateLoss B f candidate) hn (α := α) (β := β) s hs Γ
    (fun x => risk x-mask x) (fun x => risk' x-mask x)
    (fun x => by dsimp [risk,risk']; linarith [hrestore x])
    (fun x => by
      by_cases hx : x ∈ B
      · simp only [maskedCandidateLoss,if_pos hx,integral_zero,add_zero,mask,Set.indicator_of_mem hx]
        have hu : risk' x ≤ 1 := measureReal_le_one
        linarith
      · simpa only [maskedCandidateLoss,candidateLoss,risk',if_neg hx,mask,Set.indicator_of_notMem hx,sub_zero] using
          rule.coupled_test Q' Γ (π x) (f x) (fun w => z w x) (fun h => candidate h x)
            (hz x) (measurable_of_finite _) (hfail x hx))
    (fun i => by
      by_cases hx : s i ∈ B
      · simpa only [maskedCandidateLoss,if_pos hx,integral_zero] using hα
      · simpa only [maskedCandidateLoss,candidateLoss,if_neg hx] using
          rule.coupled_training Q' Γ (π (s i)) (f (s i)) (fun w => z w (s i))
            (fun h => candidate h (s i)) (hz (s i)) (measurable_of_finite _)
            (htrain i) (hfail (s i) hx))
  rw [integral_sub (integrable_finite_domain D _) (integrable_finite_domain D _)] at hh
  have hm : (∫ x,mask x ∂D) = D.real B := integral_indicator_one ((Set.to_countable B).measurableSet)
  rw [hm] at hh
  change (∫ x,risk x ∂D) ≤ _
  linarith

end NeuralGeneralization.RobustStatistics.PredictionComparison
