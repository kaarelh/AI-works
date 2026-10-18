import NeuralGeneralization.RobustStatisticsCoupling
import NeuralGeneralization.RobustConfidence

/-!
# Statistical conclusion from one common compressed candidate law

The posterior measures here are actual measures on arbitrary parameter spaces.
The finite candidate class and its sample event are fixed before any posterior
index (in particular network width or Gaussian scale) is chosen.
-/

noncomputable section
open MeasureTheory
open scoped BigOperators

namespace NeuralGeneralization.RobustStatistics
open ConcreteModel RobustConfidence

variable {X H W : Type*}
  [Fintype X] [MeasurableSpace X] [MeasurableSingletonClass X]
  [Fintype H] [MeasurableSpace H] [MeasurableSingletonClass H]
  [MeasurableSpace W]

def candidateLoss (f : X → Bool) (candidate : H → X → ℝ) (h : H) (x : X) : ℝ :=
  marginRamp (labelReal (f x) * clippedScore (candidate h x))

theorem candidateLoss_bounds (f : X → Bool) (candidate : H → X → ℝ) (h : H) (x : X) :
    0 ≤ candidateLoss f candidate h x ∧ candidateLoss f candidate h x ≤ 1 :=
  marginRamp_bounds _

/-- The complete clipped prediction comparison and statistical argument.
The common candidate marginal `Γ` is crucial: only the coupling itself varies
with `x`.  The posterior may be an arbitrary mixture and depend on the sample.
-/
theorem posterior_margin_risk_on_event
    (D : Measure X) [IsProbabilityMeasure D]
    (f : X → Bool) (candidate : H → X → ℝ)
    {n : ℕ} (hn : 0 < n) {τ α β : ℝ}
    (s : Fin n → X)
    (hs : s ∈ generalizationEvent D (candidateLoss f candidate) n τ)
    (Q Q' : Measure W) [IsProbabilityMeasure Q] [IsProbabilityMeasure Q']
    (Γ : Measure H) [IsProbabilityMeasure Γ]
    (z : W → X → ℝ) (hz : ∀ x, Measurable (fun w => z w x))
    (π : ∀ x, ProbabilityCoupling Q' Γ)
    (hfail : ∀ x, (π x).joint.real (scoreFailure (fun w => z w x) (fun h => candidate h x)) ≤ α)
    (htrain : ∀ i, Q'.real {w | labelReal (f (s i)) * z w (s i) ≤ 1 / 2} = 0)
    (hrestore : ∀ x, Q.real {w | labelReal (f x) * z w x ≤ 1 / 4} ≤
      β + Q'.real {w | labelReal (f x) * z w x ≤ 1 / 4}) :
    gibbsMarginRisk D Q (fun x => labelReal (f x)) z (1 / 4) ≤ β + 2 * α + τ := by
  apply risk_on_generalization_event D (candidateLoss f candidate) hn s hs Γ
    (fun x => Q.real {w | labelReal (f x) * z w x ≤ 1 / 4})
    (fun x => Q'.real {w | labelReal (f x) * z w x ≤ 1 / 4}) hrestore
  · intro x
    exact coupled_test_error Q' Γ (π x) (f x) (fun w => z w x) (fun h => candidate h x)
      (hz x) (measurable_of_finite _) (hfail x)
  · intro i
    exact coupled_training_loss Q' Γ (π (s i)) (f (s i))
      (fun w => z w (s i)) (fun h => candidate h (s i))
      (hz (s i)) (measurable_of_finite _) (htrain i) (hfail (s i))

theorem posterior_confidence_on_event
    (D : Measure X) [IsProbabilityMeasure D]
    (f : X → Bool) (candidate : H → X → ℝ)
    {n : ℕ} (hn : 0 < n) {τ α β q : ℝ} (hq : q < 1)
    (s : Fin n → X)
    (hs : s ∈ generalizationEvent D (candidateLoss f candidate) n τ)
    (Q Q' : Measure W) [IsProbabilityMeasure Q] [IsProbabilityMeasure Q']
    (Γ : Measure H) [IsProbabilityMeasure Γ]
    (z : W → X → ℝ) (hz : ∀ x, Measurable (fun w => z w x))
    (π : ∀ x, ProbabilityCoupling Q' Γ)
    (hfail : ∀ x, (π x).joint.real (scoreFailure (fun w => z w x) (fun h => candidate h x)) ≤ α)
    (htrain : ∀ i, Q'.real {w | labelReal (f (s i)) * z w (s i) ≤ 1 / 2} = 0)
    (hrestore : ∀ x, Q.real {w | labelReal (f x) * z w x ≤ 1 / 4} ≤
      β + Q'.real {w | labelReal (f x) * z w x ≤ 1 / 4}) :
    D.real {x | correctConfidence Q (fun x => labelReal (f x)) z (1 / 4) x ≤ q} ≤
      (β + 2 * α + τ) / (1 - q) := by
  apply margin_confidence_bound D Q (fun x => labelReal (f x)) z hz (1 / 4) hq
  exact posterior_margin_risk_on_event D f candidate hn s hs Q Q' Γ z hz π hfail htrain hrestore

/-- The sample event used by the preceding two theorems is measurable and
has the stated probability. It contains no posterior, width, scale, or
coupling choice in its definition. -/
theorem common_sample_event_probability [Nonempty H]
    (D : Measure X) [IsProbabilityMeasure D]
    (f : X → Bool) (candidate : H → X → ℝ)
    (n : ℕ) (hn : 0 < n) {τ δ E : ℝ} (hτ : 0 ≤ τ) (hδ : 0 < δ)
    (hentropy : Real.log (Fintype.card H : ℝ) ≤ E)
    (hbudget : 2 * (E + Real.log (2 / δ)) ≤ (n : ℝ) * τ ^ 2) :
    MeasurableSet (generalizationEvent D (candidateLoss f candidate) n τ) ∧
      1 - δ ≤ (CompressionSampling.iidSamples D n).real
        (generalizationEvent D (candidateLoss f candidate) n τ) := by
  refine ⟨measurable_generalizationEvent D _ (fun h => measurable_of_finite _) n τ, ?_⟩
  exact finite_class_good_probability_log D _ (fun h => measurable_of_finite _)
    (candidateLoss_bounds f candidate) n hn hτ hδ hentropy hbudget

end NeuralGeneralization.RobustStatistics
