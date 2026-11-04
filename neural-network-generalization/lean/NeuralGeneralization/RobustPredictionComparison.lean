import NeuralGeneralization.RobustStatisticsMain

/-! Loss comparison for general training/test margins. The finite candidate
law is an actual marginal of a probability coupling; no predictor is selected. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory
namespace NeuralGeneralization.RobustStatistics
open ConcreteModel RobustConfidence

/-- A scalar relation sufficient for the two statistical comparisons. -/
structure PredictionComparison (m u : ℝ) where
  good : ℝ → ℝ → Prop
  measurable_good : MeasurableSet {p : ℝ × ℝ | good p.1 p.2}
  loss : Bool → ℝ → ℝ
  measurable_loss : ∀ b,Measurable (loss b)
  loss_bounds : ∀ b a,0 ≤ loss b a ∧ loss b a ≤ 1
  training : ∀ b z a,m < labelReal b*z → good z a → loss b a = 0
  test : ∀ b z a,labelReal b*z ≤ u → good z a → loss b a = 1

namespace PredictionComparison
variable {m u : ℝ} (rule : PredictionComparison m u)
variable {W H X : Type*} [MeasurableSpace W] [MeasurableSpace H]

def failure (z : W → ℝ) (a : H → ℝ) : Set (W × H) :=
  {p | ¬ rule.good (z p.1) (a p.2)}

lemma measurable_failure (z : W → ℝ) (a : H → ℝ)
    (hz : Measurable z) (ha : Measurable a) : MeasurableSet (rule.failure z a) :=
  rule.measurable_good.compl.preimage ((hz.comp measurable_fst).prodMk (ha.comp measurable_snd))

lemma coupled_training (Q : Measure W) (Γ : Measure H) (π : ProbabilityCoupling Q Γ)
    (b : Bool) (z : W → ℝ) (a : H → ℝ) (hz : Measurable z) (ha : Measurable a) {α : ℝ}
    (htrain : Q.real {w | labelReal b*z w ≤ m} = 0)
    (hfail : π.joint.real (rule.failure z a) ≤ α) :
    (∫ h,rule.loss b (a h) ∂Γ) ≤ α := by
  classical
  let E : Set W := {w | labelReal b*z w ≤ m}
  let F := rule.failure z a
  have hE : MeasurableSet E := measurableSet_le (hz.const_mul _) measurable_const
  have hF : MeasurableSet F := rule.measurable_failure z a hz ha
  have hp (p : W × H) : rule.loss b (a p.2) ≤
      E.indicator (fun _ => (1:ℝ)) p.1 + F.indicator (fun _ => (1:ℝ)) p := by
    have hb := rule.loss_bounds b (a p.2)
    by_cases he : p.1 ∈ E
    · by_cases hf : p ∈ F
      · simp only [Set.indicator_of_mem he,Set.indicator_of_mem hf]
        linarith [hb.2]
      · simp only [Set.indicator_of_mem he,Set.indicator_of_notMem hf,add_zero]
        exact hb.2
    · by_cases hf : p ∈ F
      · simp only [Set.indicator_of_notMem he,Set.indicator_of_mem hf,zero_add]
        exact hb.2
      · simp only [Set.indicator_of_notMem he,Set.indicator_of_notMem hf,add_zero]
        exact (rule.training b _ _ (lt_of_not_ge he) (not_not.mp hf)).le
  have hh := π.right_loss_le Q Γ E hE F hF _ ((rule.measurable_loss b).comp ha)
    (fun h => rule.loss_bounds b (a h)) hp
  rw [htrain,zero_add] at hh
  exact hh.trans hfail

lemma coupled_test (Q : Measure W) (Γ : Measure H) (π : ProbabilityCoupling Q Γ)
    (b : Bool) (z : W → ℝ) (a : H → ℝ) (hz : Measurable z) (ha : Measurable a) {α : ℝ}
    (hfail : π.joint.real (rule.failure z a) ≤ α) :
    Q.real {w | labelReal b*z w ≤ u} ≤ α+(∫ h,rule.loss b (a h) ∂Γ) := by
  classical
  let E : Set W := {w | labelReal b*z w ≤ u}
  let F := rule.failure z a
  have hE : MeasurableSet E := measurableSet_le (hz.const_mul _) measurable_const
  have hF : MeasurableSet F := rule.measurable_failure z a hz ha
  have hp (p : W × H) : E.indicator (fun _ => (1:ℝ)) p.1 ≤
      rule.loss b (a p.2)+F.indicator (fun _ => (1:ℝ)) p := by
    have hb := rule.loss_bounds b (a p.2)
    by_cases he : p.1 ∈ E
    · by_cases hf : p ∈ F
      · simp only [Set.indicator_of_mem he,Set.indicator_of_mem hf]
        linarith [hb.1]
      · simp only [Set.indicator_of_mem he,Set.indicator_of_notMem hf,add_zero]
        exact (rule.test b _ _ he (not_not.mp hf)).ge
    · by_cases hf : p ∈ F
      · simp only [Set.indicator_of_notMem he,Set.indicator_of_mem hf]
        linarith [hb.1]
      · simp only [Set.indicator_of_notMem he,Set.indicator_of_notMem hf,add_zero]
        exact hb.1
  have hh := π.left_event_le Q Γ E hE F hF _ ((rule.measurable_loss b).comp ha)
    (fun h => rule.loss_bounds b (a h)) hp
  dsimp only [E,F,Function.comp_def] at hh
  linarith

variable [Fintype X] [MeasurableSpace X] [MeasurableSingletonClass X]
  [Fintype H] [MeasurableSingletonClass H]

def candidateLoss (f : X → Bool) (candidate : H → X → ℝ) (h : H) (x : X) : ℝ :=
  rule.loss (f x) (candidate h x)

/-- General loss transfer; the original and retained posteriors can depend
on all observed data. Only the finite-class event is fixed in advance. -/
theorem posterior_margin_risk_on_event
    (D : Measure X) [IsProbabilityMeasure D] (f : X → Bool) (candidate : H → X → ℝ)
    {n : ℕ} (hn : 0 < n) {τ α β : ℝ} (s : Fin n → X)
    (hs : s ∈ generalizationEvent D (rule.candidateLoss f candidate) n τ)
    (Q Q' : Measure W) [IsProbabilityMeasure Q] [IsProbabilityMeasure Q']
    (Γ : Measure H) [IsProbabilityMeasure Γ]
    (z : W → X → ℝ) (hz : ∀ x,Measurable (fun w => z w x))
    (π : ∀ x,ProbabilityCoupling Q' Γ)
    (hfail : ∀ x,(π x).joint.real (rule.failure (fun w => z w x) (fun h => candidate h x)) ≤ α)
    (htrain : ∀ i,Q'.real {w | labelReal (f (s i))*z w (s i) ≤ m} = 0)
    (hrestore : ∀ x,Q.real {w | labelReal (f x)*z w x ≤ u} ≤
      β+Q'.real {w | labelReal (f x)*z w x ≤ u}) :
    gibbsMarginRisk D Q (fun x => labelReal (f x)) z u ≤ β+2*α+τ := by
  apply risk_on_generalization_event D (rule.candidateLoss f candidate) hn s hs Γ
    (fun x => Q.real {w | labelReal (f x)*z w x ≤ u})
    (fun x => Q'.real {w | labelReal (f x)*z w x ≤ u}) hrestore
  · intro x
    exact rule.coupled_test Q' Γ (π x) (f x) _ _ (hz x) (measurable_of_finite _) (hfail x)
  · intro i
    exact rule.coupled_training Q' Γ (π (s i)) (f (s i)) _ _
      (hz (s i)) (measurable_of_finite _) (htrain i) (hfail (s i))

end PredictionComparison
end NeuralGeneralization.RobustStatistics
