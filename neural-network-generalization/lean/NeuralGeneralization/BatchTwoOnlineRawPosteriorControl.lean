import NeuralGeneralization.BatchTwoOnlineRawHighProbability
import NeuralGeneralization.BatchTwoOnlineIIDMeasure
import NeuralGeneralization.BatchTwoMergingStatistics

/-! Posterior mixtures controlled by finite grid comparison losses. Only
zero empirical comparison losses are needed, which is the online invariant. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineRaw
open ConcreteModel BatchTwoMerging
variable {X H W : Type*} [MeasurableSpace X] [Fintype X] [MeasurableSingletonClass X]
  [Fintype H] [MeasurableSpace W]

theorem pointwise_risk_of_consistent_cover (D : Measure X) [IsProbabilityMeasure D]
    (f : X → Bool) (g : H → X → ℝ) {n : ℕ} (sample : Fin n → X)
    {τ : ℝ} (hs : ∀ c, (∀ i,comparisonLoss f g c (sample i)=0) →
      (∫ x,comparisonLoss f g c x ∂D) ≤ τ)
    (z : X → ℝ) (htrain : ∀ i, (1/2 : ℝ) < labelReal (f (sample i))*z (sample i))
    (hcover : ∃ c, ∀ x, |clippedScore (z x)-clippedScore (g c x)| ≤ 3/32) :
    (∫ x, (if labelReal (f x)*z x ≤ (1/4 : ℝ) then (1 : ℝ) else 0) ∂D) ≤ τ := by
  classical
  obtain ⟨c,hc⟩ := hcover
  have ht : ∀ i, comparisonLoss f g c (sample i) = 0 := by
    intro i
    have hh := clipped_training_transfer (f (sample i)) (z (sample i)) (g c (sample i))
      (htrain i) (hc (sample i))
    unfold comparisonLoss
    split_ifs <;> linarith
  have hcRisk := hs c ht
  apply le_trans _ hcRisk
  apply integral_mono (RobustStatistics.integrable_finite_domain D _)
    (RobustStatistics.integrable_finite_domain D _)
  intro x
  by_cases hz : labelReal (f x)*z x ≤ (1/4 : ℝ)
  · have hg := clipped_test_transfer (f x) (z x) (g c x) hz (hc x)
    simp only [comparisonLoss, if_pos hg]
    split_ifs <;> norm_num
  · simp only [if_neg hz]
    exact (comparisonLoss_bounds f g c x).1

/-- This statement directly controls arbitrary posterior mixtures. No
measurable choice of a compressed network is required. -/
theorem posterior_risk_of_consistent_cover (D : Measure X) [IsProbabilityMeasure D]
    (Q : Measure W) [IsProbabilityMeasure Q] (f : X → Bool) (g : H → X → ℝ)
    {n : ℕ} (sample : Fin n → X) {τ β : ℝ} (hτ : 0 ≤ τ)
    (hs : ∀ c, (∀ i,comparisonLoss f g c (sample i)=0) →
      (∫ x,comparisonLoss f g c x ∂D) ≤ τ)
    (z : W → X → ℝ) (hz : ∀ x, Measurable (fun w => z w x))
    (E : Set W) (hE : MeasurableSet E) (htail : Q.real E ≤ β)
    (hgood : ∀ᵐ w ∂Q, (∀ i, (1/2 : ℝ) < labelReal (f (sample i))*z w (sample i)) ∧
      (w ∉ E → ∃ c, ∀ x, |clippedScore (z w x)-clippedScore (g c x)| ≤ 3/32)) :
    RobustConfidence.gibbsMarginRisk D Q (fun x => labelReal (f x)) z (1/4) ≤ τ+β := by
  classical
  let risk : W → ℝ := fun w => ∫ x,
    (if labelReal (f x)*z w x ≤ (1/4 : ℝ) then (1 : ℝ) else 0) ∂D
  have hmeas (x : X) : MeasurableSet {w | labelReal (f x)*z w x ≤ (1/4 : ℝ)} :=
    measurableSet_le ((hz x).const_mul _) measurable_const
  have hi (x : X) : Integrable
      (fun w => if labelReal (f x)*z w x ≤ (1/4 : ℝ) then (1 : ℝ) else 0) Q :=
    (integrable_const 1).indicator (hmeas x)
  have hrisk : risk = fun w => ∑ x, D.real {x} *
      (if labelReal (f x)*z w x ≤ (1/4 : ℝ) then (1 : ℝ) else 0) := by
    funext w
    exact integral_fintype (RobustStatistics.integrable_finite_domain D _)
  have hirisk : Integrable risk Q := by
    rw [hrisk]
    exact integrable_finset_sum _ (fun x _ => (hi x).const_mul (D.real {x}))
  have hupper (w : W) : risk w ≤ 1 := by
    have h := integral_mono (RobustStatistics.integrable_finite_domain D
      (fun x => if labelReal (f x)*z w x ≤ (1/4 : ℝ) then (1 : ℝ) else 0))
      (integrable_const 1) (fun x => by split_ifs <;> norm_num)
    simpa [risk] using h
  have hpoint : ∀ᵐ w ∂Q, risk w ≤ τ + E.indicator (fun _ => (1 : ℝ)) w := by
    filter_upwards [hgood] with w hw
    by_cases he : w ∈ E
    · simp only [Set.indicator_of_mem he]
      linarith [hupper w]
    · simp only [Set.indicator_of_notMem he, add_zero]
      exact pointwise_risk_of_consistent_cover D f g sample hs (z w) hw.1 (hw.2 he)
  have hiE : Integrable (E.indicator (fun _ => (1 : ℝ))) Q :=
    (integrable_const 1).indicator hE
  have hbound := integral_mono_ae hirisk ((integrable_const τ).add hiE) hpoint
  simp only [Pi.add_apply] at hbound
  rw [integral_add (integrable_const τ) hiE, integral_const, probReal_univ,
    smul_eq_mul, one_mul] at hbound
  have hind : (∫ w, E.indicator (fun _ => (1 : ℝ)) w ∂Q) = Q.real E :=
    integral_indicator_one hE
  rw [hind] at hbound
  rw [RobustConfidence.gibbsMarginRisk_eq_iterated_indicator D Q _ z hz]
  exact hbound.trans (by linarith)

end NeuralGeneralization.BatchTwoOnlineRaw
