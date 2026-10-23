import NeuralGeneralization.BatchTwoActivationPolynomialCapacity
import NeuralGeneralization.ModelLearning
import NeuralGeneralization.LearningBudget
import NeuralGeneralization.NetworkGaussianRate

/-!
# Strong-prior learning for zero-at-zero Lipschitz activations

This is a complete learning theorem for the actual Gaussian NN posterior,
including ReLU and any other globally Lipschitz activation vanishing at zero.
It uses the proved common energy-class capacity and the preexisting proved
Gaussian rate theorem. No compression, capacity, or convergence conclusion
appears as a hypothesis. The uniform finite-scale existential-polynomial
theorem is proved separately in `BatchTwoActivationUniformMain`. The
explicit capacity here is looser than the manuscript's optimized formula.
-/

noncomputable section
open scoped BigOperators Topology
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel Filter MeasureTheory

variable {d C N r : ℕ} {φ : ℝ→ℝ} {ℓ : ℝ}

theorem zeroLipschitzActivation_continuous (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ : 0≤ℓ) : Continuous φ := by
  apply (show LipschitzWith ⟨ℓ,hℓ⟩ φ from ?_).continuous
  apply LipschitzWith.of_dist_le_mul
  intro x y
  change |φ x-φ y|≤ℓ*|x-y|
  exact hφ.2 x y

def strongEnergyBudget (d r C : ℕ) : ℝ :=
  2*((d:ℝ)*(d+1)*C^2+(r+1)*C^4)+1

theorem strongEnergyBudget_ge_one (d r C : ℕ) : 1≤strongEnergyBudget d r C := by
  unfold strongEnergyBudget
  have h : 0≤(d:ℝ)*(d+1)*C^2+(r+1)*C^4 := by positivity
  linarith

theorem lowEnergyFunctions_subset_energyFunctions (φ : ℝ→ℝ) (f : BooleanFunction d)
    (hc : realizesAtComplexity (r := r) φ f C) (hCN : C≤N) :
    lowEnergyFunctions (N := N) (r := r) φ f ⊆
      energyFunctions d r φ (strongEnergyBudget d r C) := by
  classical
  intro g hg
  obtain ⟨w,hw,hcost⟩ := lowEnergyFunctions_polynomial_norm_witness φ f g hc hCN hg
  apply Finset.mem_filter.mpr
  refine ⟨Finset.mem_univ _, N, lt_of_lt_of_le (Nat.succ_le_iff.mp hc.1) hCN,
    w, hcost.le, ?_⟩
  intro x
  exact (hw x).le

/-- Actual Gaussian strong-prior learning at every width above the specified
teacher width. The variance threshold precedes the data distribution,
confidence level, and sample size. The displayed sample budget is an explicit
polynomial in `d,C` at fixed depth and activation Lipschitz constant. -/
theorem strong_prior_learning
    (hd : 1≤d) (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0<ℓ)
    (f : BooleanFunction d) (hc : realizesAtComplexity (r := r) φ f C) (hCN : C≤N)
    (ε : ℝ) (hε : 0<ε) (hε1 : ε<1) :
    ∃ σ₀ : ℝ, 0<σ₀ ∧ ∀ σ : ℝ, 0<σ → σ<σ₀ →
      ∀ D : InputLaw d, ∀ δ : ℝ, 0<δ → ∀ n : ℕ,
        (2/ε)*(activationLogCapacity d r ℓ (strongEnergyBudget d r C)+Real.log (1/δ))≤(n:ℝ) →
        (∀ sample : Fin n→Cube d,
          0<posteriorDenominator φ (1/2) (smallPrior d N r σ) f sample) ∧
        1-δ≤sampleProbability D n (fun sample =>
          posteriorRisk D f (networkPosterior φ (1/2) (smallPrior d N r σ) f sample)≤ε ∧
          ConcreteModel.confidenceFailure D f (networkPosterior φ (1/2) (smallPrior d N r σ) f sample)≤3*ε) := by
  classical
  let A := lowEnergyFunctions (N := N) (r := r) φ f
  have hN : 0<N := lt_of_lt_of_le (Nat.succ_le_iff.mp hc.1) hCN
  have hdp : 0<d := Nat.succ_le_iff.mp hd
  have hcontinuous := zeroLipschitzActivation_continuous hφ hℓ.le
  have hne := margin_witness_at_larger_width φ f hc hCN
  have htail := network_highEnergy_tail_ratio_tendsto_zero hdp hN hcontinuous f hne
  have hpos : ∀ᶠ σ in 𝓝[>] (0:ℝ),
      0<functionMass φ (1/2) (smallPrior d N r σ) f := by
    filter_upwards [self_mem_nhdsWithin] with σ hσ
    exact small_functionMass_pos hdp hcontinuous f hc hCN (show 0<σ from hσ)
  have hcount : (A.card:ℝ)≤Real.exp (activationLogCapacity d r ℓ (strongEnergyBudget d r C)) := by
    have hcard := Finset.card_le_card (lowEnergyFunctions_subset_energyFunctions φ f hc hCN)
    have hcard' : (A.card:ℝ)≤(energyFunctions d r φ (strongEnergyBudget d r C)).card := by
      exact_mod_cast hcard
    exact hcard'.trans (energyFunctions_card_le_exp hφ hℓ (strongEnergyBudget_ge_one d r C) hd)
  obtain ⟨σ₀,hσ₀,hlearn⟩ := small_variance_network_learning_of_tail_ratio φ (1/2)
    (fun σ => smallPrior d N r σ) f A hpos htail ε hε hε1
  refine ⟨σ₀,hσ₀,?_⟩
  intro σ hσ hσlt D δ hδ n hsize
  constructor
  · intro sample
    exact posteriorDenominator_pos φ (1/2) (smallPrior d N r σ) f sample
      (small_functionMass_pos hdp hcontinuous f hc hCN hσ)
  · have hb : activationLogCapacity d r ℓ (strongEnergyBudget d r C)+Real.log (1/δ)≤
        (n:ℝ)*(ε/2) := by
      have heq : (2/ε)*(activationLogCapacity d r ℓ (strongEnergyBudget d r C)+Real.log (1/δ)) =
          (activationLogCapacity d r ℓ (strongEnergyBudget d r C)+Real.log (1/δ))/(ε/2) := by
        field_simp
      rw [heq] at hsize
      exact (div_le_iff₀ (by linarith : 0<ε/2)).mp hsize
    have hfailure := NeuralGeneralization.exponential_sample_bound (A.card:ℝ)
      (activationLogCapacity d r ℓ (strongEnergyBudget d r C)) (ε/2) δ n hcount hδ hb
    exact hlearn σ hσ hσlt D δ n hfailure

end NeuralGeneralization.BatchTwoActivation
