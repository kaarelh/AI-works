import NeuralGeneralization.NetworkSpectralTail
import NeuralGeneralization.SpectralWidthThreshold
import NeuralGeneralization.PowerPriorTargetMass
import NeuralGeneralization.ExponentialTailRatio
import NeuralGeneralization.AllWidthReduction

/-!
# Actual above-mean-field learning at every admissible width

A single width threshold depending only on the fixed exponent joins the
proved Gaussian matrix tail, spectral compression, polynomial class count,
all-width target-cylinder mass, and the exact Bayesian sampling argument.
The only displayed premises below are explicit arithmetic bounds on the
energy, width and sample-size budgets.
-/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel

/-- Closed quantitative learning theorem for all actual network widths above
the target circuit complexity. The final polynomial-envelope theorem only
needs to choose arithmetic budgets satisfying these displayed inequalities. -/
theorem aboveMeanField_learning_quantitative (γ : ℝ) (hγ : 1 < γ) :
    ∃ N₀ : ℕ, ∀ {d C r : ℕ}, 1 ≤ d →
      ∀ (φ : ℝ → ℝ), admissibleActivation φ →
      ∀ (f : BooleanFunction d), realizesAtComplexity (r := r) φ f C →
      ∀ (K T m : ℕ), N₀ ≤ T → 8 * (d+1) ≤ K →
      (K : ℝ) ≤ (T : ℝ) ^ 2 → (spectralInverseRadius r K) ^ m ≤ T →
      2 ≤ (m : ℝ) * ((γ-1)/2) →
      ∀ ε δ : ℝ, 0 < ε → ε < 1 → 0 < δ →
      cylinderPolynomialCoefficient r * (1 + (d : ℝ) + C) ^ cylinderPolynomialDegree r +
        Real.log (4 * ((r : ℝ)+1) / ε) ≤ (K : ℝ) / 64 →
      ∀ P : ℝ, (spectralCapacity d r K : ℝ) ≤ P →
      cylinderPolynomialCoefficient r * (1 + (d : ℝ) + C) ^ cylinderPolynomialDegree r *
        (T : ℝ) ^ γ ≤ P →
      ∀ n : ℕ, (2/ε) * (P + Real.log (2/(ε*δ))) ≤ (n : ℝ) →
      ∀ N : ℕ, C ≤ N →
        (∀ sample : Fin n → Cube d,
          0 < posteriorDenominator φ (1/2) (powerPrior d N r γ) f sample) ∧
        ∀ D : InputLaw d,
          1-δ ≤ sampleProbability D n (fun sample =>
            posteriorRisk D f
              (networkPosterior φ (1/2) (powerPrior d N r γ) f sample) ≤ ε) := by
  obtain ⟨N₀,hN₀⟩ := Filter.eventually_atTop.mp
    (eventually_spectralFunctions_complement_mass_tail γ hγ)
  refine ⟨N₀, ?_⟩
  intro d C r hd φ hφ f hf K T m hT hK hKT hwidth hm ε δ hε hε1 hδ hgap P hcap hsmall n hn
  let B : ℝ := cylinderPolynomialCoefficient r *
    (1 + (d : ℝ) + C) ^ cylinderPolynomialDegree r
  apply all_width_risk_learning_reduction (by omega) (admissibleActivation_continuous hφ)
    f hf γ T (spectralFunctions d r K φ) (spectralCapacity d r K)
    (B * (T : ℝ) ^ γ) P (spectralFunctions_card_le_exp d r K φ hφ) hcap hsmall
    ε δ hε hε1 hδ _ _ n hn
  · intro N hCN hTN
    have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
    have hKN : (K : ℝ) ≤ (N : ℝ) ^ 2 := hKT.trans
      (pow_le_pow_left₀ (Nat.cast_nonneg T) (by exact_mod_cast hTN) 2)
    have ha := matrixTruncationScale_le_radius hN γ hγ r K m hm (hwidth.trans hTN)
    have htail := hN₀ N (hT.trans hTN) d r K hd hK hKN ha φ hφ
    have hmass := powerPrior_target_mass_polynomial (by omega) φ hφ f hf hCN hγ.le
    apply exponential_tail_ratio_prefactor_le _ _ (2 * ((r : ℝ)+1)) B
      ((K : ℝ)/64) ((N : ℝ)^γ) (ε/2) _ (by simpa only [B, neg_mul] using hmass)
      (by have hh : (0 : ℝ) ≤ r := Nat.cast_nonneg r; linarith)
      (one_le_width_power hN hγ.le) (by linarith) (by linarith) _
    · have hid : -((K : ℝ)/64) * (N : ℝ)^γ = -(K : ℝ) * (N : ℝ)^γ / 64 := by ring
      rw [hid]
      exact htail
    · have hlogarg : 2 * ((r : ℝ)+1) / (ε/2) = 4 * ((r : ℝ)+1) / ε := by ring
      simpa only [hlogarg] using hgap
  · intro N hCN hNT
    exact powerPrior_target_mass_below_threshold (by omega) φ hφ f hf hCN hNT.le hγ.le

end NeuralGeneralization.ConcreteModel
