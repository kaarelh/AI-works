import NeuralGeneralization.ModelLearning
import NeuralGeneralization.LearningBudget
import NeuralGeneralization.NetworkGaussianRate
import NeuralGeneralization.CapacityBound

/-!
# Strong-prior learning from concrete low-energy compression

The actual finite-dimensional Gaussian rate and actual finite network capacity
bound are used here, rather than postulated. The remaining hypothesis is a
width-reduction statement for concrete networks representing the low-energy
functions. In particular, no convergence or class-cardinality bound is an
assumption of this reduction.

To derive the main polynomial-complexity theorem one must supply this remaining
compression hypothesis with widths and coefficient bounds polynomial in target
complexity and input dimension, independently of the source width.
-/

noncomputable section

namespace NeuralGeneralization.ConcreteModel

open Filter MeasureTheory Classical
open scoped BigOperators Topology
attribute [local instance] Classical.propDecidable

/-- Actual Gaussian strong-prior learning, conditional only on concrete bounded
representatives for every low-energy function. The variance threshold precedes
`D`, `δ`, and `n`, and the logarithmic sample budget uses the proved explicit
parameter-capacity polynomial. -/
theorem concrete_strong_prior_learning_of_compression
    {d C N r : ℕ} (hd : 0 < d) {φ : ℝ → ℝ}
    (hφ : admissibleActivation φ) (f : BooleanFunction d)
    (hc : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N)
    (M B : ℕ)
    (hcompressed : ∀ g ∈ lowEnergyFunctions (N := N) (r := r) φ f,
      ∃ w : Weights d M r, w ∈ marginEvent φ (1 / 2) g ∧ boundedWeights B w)
    (ε : ℝ) (hε : 0 < ε) (hε1 : ε < 1) :
    ∃ σ₀ : ℝ, 0 < σ₀ ∧ ∀ σ : ℝ, 0 < σ → σ < σ₀ →
      ∀ D : InputLaw d, ∀ δ : ℝ, 0 < δ → ∀ n : ℕ,
        ((parameterCapacityExponent d M r B : ℝ) + Real.log (1 / δ)) /
          (ε / 2) ≤ (n : ℝ) →
        (∀ sample : Fin n → Cube d,
          0 < posteriorDenominator φ (1 / 2) (smallPrior d N r σ) f sample) ∧
        1 - δ ≤ sampleProbability D n (fun sample =>
          posteriorRisk D f (networkPosterior φ (1 / 2) (smallPrior d N r σ) f sample) ≤ ε ∧
          confidenceFailure D f (networkPosterior φ (1 / 2) (smallPrior d N r σ) f sample) ≤ 3 * ε) := by
  let A := lowEnergyFunctions (N := N) (r := r) φ f
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hc.1) hCN
  have hcontinuous := admissibleActivation_continuous hφ
  have hne := margin_witness_at_larger_width φ f hc hCN
  have htail := network_highEnergy_tail_ratio_tendsto_zero hd hN hcontinuous f hne
  have hpos : ∀ᶠ σ in 𝓝[>] (0 : ℝ),
      0 < functionMass φ (1 / 2) (smallPrior d N r σ) f := by
    filter_upwards [self_mem_nhdsWithin] with σ hσ
    exact small_functionMass_pos hd hcontinuous f hc hCN (show 0 < σ from hσ)
  have hcount : (A.card : ℝ) ≤ Real.exp (parameterCapacityExponent d M r B : ℝ) :=
    representedClass_card_le_exp A M r B φ hφ hcompressed
  obtain ⟨σ₀, hσ₀, hlearn⟩ := small_variance_network_learning_of_tail_ratio φ (1 / 2)
    (fun σ => smallPrior d N r σ) f A hpos htail ε hε hε1
  refine ⟨σ₀, hσ₀, ?_⟩
  intro σ hσ hσlt D δ hδ n hsize
  constructor
  · intro sample
    exact posteriorDenominator_pos φ (1 / 2) (smallPrior d N r σ) f sample
      (small_functionMass_pos hd hcontinuous f hc hCN hσ)
  · have hbudget : (parameterCapacityExponent d M r B : ℝ) + Real.log (1 / δ) ≤
        (n : ℝ) * (ε / 2) := (div_le_iff₀ (by linarith : 0 < ε / 2)).mp hsize
    have hfailure := NeuralGeneralization.exponential_sample_bound (A.card : ℝ)
      (parameterCapacityExponent d M r B : ℝ) (ε / 2) δ n hcount hδ hbudget
    exact hlearn σ hσ hσlt D δ n hfailure

end NeuralGeneralization.ConcreteModel
