import NeuralGeneralization.BatchTwoRelativeStatistics
import NeuralGeneralization.RobustStatisticsMain

/-! Relative finite-class statistics for a common score-compression coupling.
The inverse accuracy cost is linear, including for posterior mixtures. -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.BatchTwoImprovedLearning
open ConcreteModel RobustConfidence RobustStatistics
variable {X H W:Type*}
  [Fintype X] [MeasurableSpace X] [MeasurableSingletonClass X]
  [Fintype H] [MeasurableSpace H] [MeasurableSingletonClass H]
  [MeasurableSpace W]

theorem posterior_margin_risk_on_relative_event
    (D:Measure X) [IsProbabilityMeasure D]
    (f:X→Bool) (candidate:H→X→ℝ)
    {n:ℕ} (hn:0<n) {τ α β:ℝ}
    (s:Fin n→X)
    (hs:s∈BatchTwoRelativeStatistics.generalizationEvent D (candidateLoss f candidate) n τ)
    (Q Q':Measure W) [IsProbabilityMeasure Q] [IsProbabilityMeasure Q']
    (Γ:Measure H) [IsProbabilityMeasure Γ]
    (z:W→X→ℝ) (hz:∀x,Measurable (fun w=>z w x))
    (π:∀x,ProbabilityCoupling Q' Γ)
    (hfail:∀x,(π x).joint.real (scoreFailure (fun w=>z w x) (fun h=>candidate h x))≤α)
    (htrain:∀i,Q'.real {w|labelReal (f (s i))*z w (s i)≤1/2}=0)
    (hrestore:∀x,Q.real {w|labelReal (f x)*z w x≤1/4}≤
      β+Q'.real {w|labelReal (f x)*z w x≤1/4}):
    gibbsMarginRisk D Q (fun x=>labelReal (f x)) z (1/4)≤β+3*α+τ := by
  apply BatchTwoRelativeStatistics.risk_on_generalization_event D (candidateLoss f candidate) hn s hs Γ
    (fun x=>Q.real {w|labelReal (f x)*z w x≤1/4})
    (fun x=>Q'.real {w|labelReal (f x)*z w x≤1/4}) hrestore
  · intro x
    exact coupled_test_error Q' Γ (π x) (f x) (fun w=>z w x) (fun h=>candidate h x)
      (hz x) (measurable_of_finite _) (hfail x)
  · intro i
    exact coupled_training_loss Q' Γ (π (s i)) (f (s i))
      (fun w=>z w (s i)) (fun h=>candidate h (s i))
      (hz (s i)) (measurable_of_finite _) (htrain i) (hfail (s i))

end NeuralGeneralization.BatchTwoImprovedLearning
