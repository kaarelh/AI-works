import NeuralGeneralization.RobustLocalizedPosterior

/-! Equality with the manuscript's two-stage learner: condition the raw
Gaussian on the union support, then impose every training-margin constraint. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.RobustLocalized
open ConcreteModel RobustPosterior RobustStatistics
variable {d N r M m n : ℕ}

def supportEvent (B : Fin M → Set (Cube d)) (c ρ : ℝ)
    (V : Fin m → Cube d) : Set (Weights d N r) :=
  {w | ∃ j, empiricalLoss (exceptionLoss B) V j ≤ ρ ∧
    ∀ x,x ∉ B j → stableAt Real.tanh c w x}

lemma measurable_supportEvent (B : Fin M → Set (Cube d)) {c : ℝ} (hc : 0 < c)
    (ρ : ℝ) (V : Fin m → Cube d) :
    MeasurableSet (supportEvent (N := N) (r := r) B c ρ V) := by
  unfold supportEvent
  simp only [Set.setOf_exists]
  apply MeasurableSet.iUnion
  intro j
  apply MeasurableSet.inter (MeasurableSet.const _)
  change MeasurableSet {w : Weights d N r | ∀ x,x ∉ B j → stableAt Real.tanh c w x}
  simp only [Set.setOf_forall]
  exact MeasurableSet.iInter fun x => MeasurableSet.iInter fun _ =>
    (isClosed_stableAt tanh_continuous hc x).measurableSet

lemma posteriorEvent_eq_inter (B : Fin M → Set (Cube d)) (c ρ : ℝ)
    (f : BooleanFunction d) (V : Fin m → Cube d) (S : Fin n → Cube d) :
    posteriorEvent (N := N) (r := r) B c ρ f V S =
      supportEvent B c ρ V ∩ trainingMarginEvent Real.tanh f S := by
  ext w
  simp only [posteriorEvent,Set.mem_iUnion,witnessEvent,Set.mem_setOf_eq,
    Set.mem_inter_iff,supportEvent]
  constructor
  · rintro ⟨j,hfreq,hstable,htrain⟩
    exact ⟨⟨j,hfreq,hstable⟩,htrain⟩
  · rintro ⟨⟨j,hfreq,hstable⟩,htrain⟩
    exact ⟨j,hfreq,hstable,htrain⟩

/-- Exact equality of measures, not merely equality of their supports. -/
theorem posterior_eq_two_stage (B : Fin M → Set (Cube d)) {c : ℝ} (hc : 0 < c)
    (ρ σ : ℝ) (f : BooleanFunction d) (V : Fin m → Cube d) (S : Fin n → Cube d) :
    posterior (N := N) (r := r) B c ρ σ f V S =
      cond (cond (smallPrior d N r σ) (supportEvent B c ρ V))
        (trainingMarginEvent Real.tanh f S) := by
  rw [cond_cond_eq_cond_inter (measurable_supportEvent B hc ρ V)
    (measurable_trainingMarginEvent tanh_continuous f S)]
  exact congrArg (cond (smallPrior d N r σ)) (posteriorEvent_eq_inter B c ρ f V S)

end NeuralGeneralization.RobustLocalized
