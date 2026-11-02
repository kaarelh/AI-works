import NeuralGeneralization.RobustStatisticsMain
import NeuralGeneralization.UnlabeledStabilityPool

/-! Loss transfer with the instability of the actual posterior charged at
fresh inputs, while training locations have verified stability. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.UnlabeledStability

lemma instability_integral_swap {W X : Type*} [MeasurableSpace W] [MeasurableSpace X]
    (Q : Measure W) [IsProbabilityMeasure Q] (D : Measure X) [IsProbabilityMeasure D]
    (stable : W → X → Prop) (hs : MeasurableSet {p : W × X | stable p.1 p.2}) :
    (∫ x,Q.real {w | ¬ stable w x} ∂D) = ∫ w,instability D stable w ∂Q := by
  let F : W × X → ℝ := {p | ¬ stable p.1 p.2}.indicator (fun _ => 1)
  have hm : Measurable F := measurable_const.indicator hs.compl
  have hi : Integrable F (Q.prod D) := by
    apply Integrable.of_bound hm.aestronglyMeasurable 1
    exact Filter.Eventually.of_forall (fun p => by by_cases hp : stable p.1 p.2 <;> simp [F,hp])
  have hleft (w : W) : (∫ x,F (w,x) ∂D) = instability D stable w := by
    exact integral_indicator_one (hs.compl.preimage (measurable_const.prodMk measurable_id))
  have hright (x : X) : (∫ w,F (w,x) ∂Q) = Q.real {w | ¬ stable w x} := by
    exact integral_indicator_one (hs.compl.preimage (measurable_id.prodMk measurable_const))
  have hh := integral_integral_swap (f := fun w x => F (w,x)) hi
  simpa only [hleft,hright] using hh.symm

end NeuralGeneralization.UnlabeledStability
namespace NeuralGeneralization.RobustStatistics
open ConcreteModel RobustConfidence
variable {X H W : Type*}
  [Fintype X] [MeasurableSpace X] [MeasurableSingletonClass X]
  [Fintype H] [MeasurableSpace H] [MeasurableSingletonClass H]
  [MeasurableSpace W]

/-- The same finite candidate event tolerates input-dependent test failures. -/
theorem pointwise_posterior_margin_risk_on_event
    (D : Measure X) [IsProbabilityMeasure D] (f : X → Bool) (candidate : H → X → ℝ)
    {n : ℕ} (hn : 0 < n) {τ α β : ℝ} (s : Fin n → X)
    (hs : s ∈ generalizationEvent D (candidateLoss f candidate) n τ)
    (Q Q' : Measure W) [IsProbabilityMeasure Q] [IsProbabilityMeasure Q']
    (Γ : Measure H) [IsProbabilityMeasure Γ]
    (z : W → X → ℝ) (hz : ∀ x,Measurable (fun w => z w x))
    (π : ∀ x,ProbabilityCoupling Q' Γ) (bad : X → ℝ)
    (hfail : ∀ x,(π x).joint.real (scoreFailure (fun w => z w x) (fun h => candidate h x)) ≤ α+2*bad x)
    (htrainfail : ∀ i,(π (s i)).joint.real
      (scoreFailure (fun w => z w (s i)) (fun h => candidate h (s i))) ≤ α)
    (htrain : ∀ i,Q'.real {w | labelReal (f (s i))*z w (s i) ≤ 1/2} = 0)
    (hrestore : ∀ x,Q.real {w | labelReal (f x)*z w x ≤ 1/4} ≤
      β+Q'.real {w | labelReal (f x)*z w x ≤ 1/4}) :
    gibbsMarginRisk D Q (fun x => labelReal (f x)) z (1/4) ≤
      β+2*α+τ+2*(∫ x,bad x ∂D) := by
  let risk := fun x => Q.real {w | labelReal (f x)*z w x ≤ 1/4}
  let risk' := fun x => Q'.real {w | labelReal (f x)*z w x ≤ 1/4}
  have hh := risk_on_generalization_event D (candidateLoss f candidate) hn s hs Γ
    (fun x => risk x-2*bad x) (fun x => risk' x-2*bad x)
    (fun x => by dsimp [risk,risk']; linarith [hrestore x])
    (fun x => by
      have ht := coupled_test_error Q' Γ (π x) (f x) (fun w => z w x)
        (fun h => candidate h x) (hz x) (measurable_of_finite _) (hfail x)
      dsimp [risk',candidateLoss]
      linarith)
    (fun i => coupled_training_loss Q' Γ (π (s i)) (f (s i))
      (fun w => z w (s i)) (fun h => candidate h (s i))
      (hz (s i)) (measurable_of_finite _) (htrain i) (htrainfail i))
  rw [integral_sub (integrable_finite_domain D _) ((integrable_finite_domain D bad).const_mul 2),
    integral_const_mul] at hh
  change (∫ x,risk x ∂D) ≤ _
  linarith

end NeuralGeneralization.RobustStatistics
