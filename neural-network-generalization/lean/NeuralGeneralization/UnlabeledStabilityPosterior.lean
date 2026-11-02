import NeuralGeneralization.UnlabeledStabilityPool
import NeuralGeneralization.RobustPosteriorConditioning

/-! Simultaneous control of actual conditioned priors, not assumed posterior
entropy budgets. The conditioning event may be selected after the pool. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.UnlabeledStability
variable {W X : Type*} [MeasurableSpace W] [MeasurableSpace X]

/-- Any later conditioning event of mass at least exp(-K), lying in the
observed stability event, inherits the pool bound. -/
theorem conditioned_pool_coverage (G : Measure W) [IsProbabilityMeasure G]
    (D : Measure X) [IsProbabilityMeasure D] (stable : W → X → Prop)
    (hs : MeasurableSet {p : W × X | stable p.1 p.2})
    (m : ℕ) (hm : 0 < m) {δ : ℝ} (hδ : 0 < δ) :
    ∃ E : Set (Fin m → X), MeasurableSet E ∧
      1-δ ≤ (Measure.pi (fun _ : Fin m => D)).real E ∧
      ∀ s ∈ E, ∀ (F : Set W), MeasurableSet F → F ⊆ poolEvent stable s →
        ∀ K : ℝ, 0 ≤ K → Real.exp (-K) ≤ G.real F →
        IsProbabilityMeasure (cond G F) ∧
          (∫ w,instability D stable w ∂cond G F) ≤ (2/(m:ℝ))*(K+Real.log (1/δ)) := by
  obtain ⟨E,hE,hprob,huniform⟩ := uniform_pool_coverage G D stable hs m hm hδ
  refine ⟨E,hE,hprob,?_⟩
  intro s hse F hF hsub K hK hmass
  have hpos : 0 < G.real F := (Real.exp_pos _).trans_le hmass
  have hne : G F ≠ 0 := by
    intro hz
    simp only [Measure.real,hz,ENNReal.toReal_zero] at hpos
    exact (lt_irrefl 0) hpos
  letI : IsProbabilityMeasure (cond G F) := cond_isProbabilityMeasure hne
  have hKL := RobustPosterior.klDiv_cond_le_of_mass_lower G F hF hmass
  have hfin : klDiv (cond G F) G ≠ ∞ := ne_top_of_le_ne_top ENNReal.ofReal_ne_top hKL
  have hKLreal : (klDiv (cond G F) G).toReal ≤ K := by
    simpa only [ENNReal.toReal_ofReal hK] using ENNReal.toReal_mono ENNReal.ofReal_ne_top hKL
  have hbound := huniform s hse (cond G F) inferInstance hfin ((ae_cond_mem hF).mono (fun _ hw => hsub hw))
  refine ⟨inferInstance,hbound.trans ?_⟩
  exact mul_le_mul_of_nonneg_left (by linarith) (by positivity)

end NeuralGeneralization.UnlabeledStability
