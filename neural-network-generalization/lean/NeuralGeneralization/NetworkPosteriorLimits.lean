import NeuralGeneralization.PosteriorContinuity
import NeuralGeneralization.ModelLearning

/-! # Exact transfer from sign-event mass limits to neural posterior confidence -/

noncomputable section
open Filter MeasureTheory
open scoped Topology BigOperators

namespace NeuralGeneralization.ConcreteModel

theorem networkPosterior_tendsto_of_functionMass {d r n : ℕ}
    (φ : ℝ → ℝ) (a : ℝ) (μ : (N : ℕ) → Measure (Weights d N r))
    (w₀ : BooleanFunction d → ℝ) (f : BooleanFunction d) (sample : Fin n → Cube d)
    (hlimit : ∀ g, Tendsto (fun N => functionMass φ a (μ N) g) atTop (𝓝 (w₀ g)))
    (hden : 0 < NeuralGeneralization.normalizer w₀ (consistent f sample)) (g : BooleanFunction d) :
    Tendsto (fun N => networkPosterior φ a (μ N) f sample g) atTop
      (𝓝 (NeuralGeneralization.posterior w₀ (consistent f sample) g)) := by
  classical
  exact NeuralGeneralization.posterior_tendsto
    (fun N => functionMass φ a (μ N)) w₀ (consistent f sample) hlimit hden.ne' g

theorem eventual_network_denominator_pos_of_functionMass {d r n : ℕ}
    (φ : ℝ → ℝ) (a : ℝ) (μ : (N : ℕ) → Measure (Weights d N r))
    (w₀ : BooleanFunction d → ℝ) (f : BooleanFunction d) (sample : Fin n → Cube d)
    (hlimit : ∀ g, Tendsto (fun N => functionMass φ a (μ N) g) atTop (𝓝 (w₀ g)))
    (hden : 0 < NeuralGeneralization.normalizer w₀ (consistent f sample)) :
    ∀ᶠ N in atTop, 0 < posteriorDenominator φ a (μ N) f sample := by
  classical
  exact NeuralGeneralization.eventually_normalizer_pos
    (fun N => functionMass φ a (μ N)) w₀ (consistent f sample) hlimit hden

/-- A limiting confidence bound with any strict buffer below two thirds
transfers to the actual finite-width posterior under the all-input margin
conditioning. The Gaussian/event-mass limit itself is a separate obligation. -/
theorem network_confidence_liminf_of_functionMass {d r n : ℕ}
    (φ : ℝ → ℝ) (a : ℝ) (μ : (N : ℕ) → Measure (Weights d N r))
    (w₀ : BooleanFunction d → ℝ) (f : BooleanFunction d) (sample : Fin n → Cube d)
    (hlimit : ∀ g, Tendsto (fun N => functionMass φ a (μ N) g) atTop (𝓝 (w₀ g)))
    (hden : 0 < NeuralGeneralization.normalizer w₀ (consistent f sample))
    (D : InputLaw d) (b : ℝ) (hb : b < 2 / 3) :
    (∑ x, if correctConfidence f (NeuralGeneralization.posterior w₀ (consistent f sample)) x ≤ b
      then D.mass x else 0) ≤
      Filter.liminf (fun N => confidenceFailure D f (networkPosterior φ a (μ N) f sample)) atTop := by
  classical
  exact NeuralGeneralization.buffered_confidence_liminf_lower
    (fun N => networkPosterior φ a (μ N) f sample)
    (NeuralGeneralization.posterior w₀ (consistent f sample)) D.mass (fun g x => g x) f
    (networkPosterior_tendsto_of_functionMass φ a μ w₀ f sample hlimit hden)
    D.nonneg D.sum_one b hb

end NeuralGeneralization.ConcreteModel
