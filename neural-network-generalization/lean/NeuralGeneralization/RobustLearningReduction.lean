import NeuralGeneralization.RobustPosterior
import NeuralGeneralization.RobustStatisticsMain

/-!
# Concrete posterior learning from the compressed score couplings

This is a reduction, not the final compression theorem.  Its premises isolate
the two remaining constructive inputs: the robust target-cylinder mass and
one fixed finite candidate class with a common candidate marginal at every
input.  Gaussian truncation, conditioning, comparison, concentration, and
confidence are proved rather than assumed.
-/

noncomputable section
open MeasureTheory ProbabilityTheory

namespace NeuralGeneralization.RobustStatistics
open ConcreteModel RobustPosterior RobustConfidence

variable {d N r n : ℕ} {H : Type*}
  [Fintype H] [MeasurableSpace H] [MeasurableSingletonClass H]

theorem robust_network_learning_from_score_couplings
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hd : 0 < d) (hN : 0 < N)
    (input : Measure (Cube d)) [IsProbabilityMeasure input]
    (f : BooleanFunction d) (candidate : H → Cube d → ℝ)
    (sample : Fin n → Cube d) (hn : 0 < n)
    {c σ D B β α τ : ℝ} (hc : 0 < c) (hσ : 0 < σ)
    (hscale : (N : ℝ) * σ ^ 2 ≤ 1)
    (hβ : 0 < β) (hβhalf : β ≤ 1 / 2) (hB : 8 ≤ B)
    (hbudget : 4 * (D - Real.log β) ≤ B)
    (htarget : Real.exp (-D / σ ^ 2) ≤ (smallPrior d N r σ).real
      (robustEvent φ c ∩ marginEvent φ (1 / 2) f))
    (hs : sample ∈ generalizationEvent input (candidateLoss f candidate) n τ)
    (Γ : Measure H) [IsProbabilityMeasure Γ]
    (π : ∀ x : Cube d, ProbabilityCoupling
      (retainedPosterior (N := N) (r := r) φ c σ B f sample) Γ)
    (hfail : ∀ x, (π x).joint.real
      (scoreFailure (fun w => networkOutput φ w x) (fun h => candidate h x)) ≤ α) :
    gibbsMarginRisk input (robustPosterior (N := N) (r := r) φ c σ f sample)
      (fun x => labelReal (f x)) (networkOutput φ) (1 / 4) ≤ β + 2 * α + τ := by
  have hN1 : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hσ1 : σ ^ 2 ≤ 1 := by nlinarith [sq_nonneg σ]
  have htail := robustPosterior_readout_tail hφ hd hN hc hσ hscale hβ
    (by linarith) hB hbudget f sample htarget
  letI := robustPosterior_isProbability φ c σ f sample htarget
  letI := retainedPosterior_isProbability hφ hc hσ hσ1 hβhalf f sample htarget htail
  apply posterior_margin_risk_on_event input f candidate hn sample hs
    (robustPosterior φ c σ f sample) (retainedPosterior φ c σ B f sample) Γ
    (networkOutput φ) (fun x => (continuous_networkOutput hφ x).measurable) π hfail
  · intro i
    exact retained_training_null hφ hc σ B f sample i
  · intro x
    exact robustPosterior_restore hφ hc (by linarith) f sample htarget htail _

theorem robust_network_confidence_from_score_couplings
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hd : 0 < d) (hN : 0 < N)
    (input : Measure (Cube d)) [IsProbabilityMeasure input]
    (f : BooleanFunction d) (candidate : H → Cube d → ℝ)
    (sample : Fin n → Cube d) (hn : 0 < n)
    {c σ D B β α τ q : ℝ} (hc : 0 < c) (hσ : 0 < σ)
    (hscale : (N : ℝ) * σ ^ 2 ≤ 1)
    (hβ : 0 < β) (hβhalf : β ≤ 1 / 2) (hB : 8 ≤ B)
    (hbudget : 4 * (D - Real.log β) ≤ B) (hq : q < 1)
    (htarget : Real.exp (-D / σ ^ 2) ≤ (smallPrior d N r σ).real
      (robustEvent φ c ∩ marginEvent φ (1 / 2) f))
    (hs : sample ∈ generalizationEvent input (candidateLoss f candidate) n τ)
    (Γ : Measure H) [IsProbabilityMeasure Γ]
    (π : ∀ x : Cube d, ProbabilityCoupling
      (retainedPosterior (N := N) (r := r) φ c σ B f sample) Γ)
    (hfail : ∀ x, (π x).joint.real
      (scoreFailure (fun w => networkOutput φ w x) (fun h => candidate h x)) ≤ α) :
    input.real {x | correctConfidence (robustPosterior (N := N) (r := r) φ c σ f sample)
      (fun x => labelReal (f x)) (networkOutput φ) (1 / 4) x ≤ q} ≤
      (β + 2 * α + τ) / (1 - q) := by
  letI := robustPosterior_isProbability φ c σ f sample htarget
  apply margin_confidence_bound input _ _ _ (fun x => (continuous_networkOutput hφ x).measurable)
    (1 / 4) hq
  exact robust_network_learning_from_score_couplings hφ hd hN input f candidate sample hn
    hc hσ hscale hβ hβhalf hB hbudget htarget hs Γ π hfail

end NeuralGeneralization.RobustStatistics
