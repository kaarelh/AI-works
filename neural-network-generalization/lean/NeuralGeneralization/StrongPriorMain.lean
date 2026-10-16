import NeuralGeneralization.ConcreteStrongPrior
import NeuralGeneralization.LowEnergyCapacity
import NeuralGeneralization.Statements

/-!
# The strong-prior main theorem

The energy slack, actual norm compression, explicit finite capacity, actual
Gaussian sign-event rates, and exact normalized Bayesian learning theorem
are assembled here. The final theorem has precisely the main-statement type;
there is no remaining analytic, compression, or posterior assumption.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators
open ConcreteModel CompressionSampling


namespace MainProofs

/-- Strong-prior paper, Theorem 2.2, in the concrete model and with the exact
quantifier order in the formal main statement. -/
theorem strongPrior : MainStatements.StrongPriorGeneralization := by
  intro r
  obtain ⟨A, hA, m, hpoly⟩ := (strongCapacity_polynomialGrowth r).real_envelope
  refine ⟨A, hA, m, ?_⟩
  intro φ hφ d hd f C hc N hCN ε hε hε1
  obtain ⟨σ₀, hσ₀, hlearn⟩ := concrete_strong_prior_learning_of_compression
    (Nat.succ_le_iff.mp hd) hφ f hc.1 hCN
    (strongCompressionWidth d r C) (strongCompressionWidth d r C)
    (lowEnergyFunctions_compressed hd hφ f hc.1 hCN) ε hε hε1
  refine ⟨σ₀, hσ₀, ?_⟩
  intro σ hσ hσlt D δ hδ hδ1 n hsize
  have hcap : (strongCapacity d r C : ℝ) ≤ MainStatements.polynomialEnvelope A m d C 0 := by
    simpa only [MainStatements.polynomialEnvelope, add_zero] using hpoly d C
  have hbudget : ((strongCapacity d r C : ℝ) + Real.log (1 / δ)) / (ε / 2) ≤ (n : ℝ) := by
    calc
      _ ≤ (MainStatements.polynomialEnvelope A m d C 0 + Real.log (1 / δ)) / (ε / 2) :=
        div_le_div_of_nonneg_right (add_le_add hcap le_rfl) (by linarith)
      _ = (2 / ε) * (MainStatements.polynomialEnvelope A m d C 0 + Real.log (1 / δ)) := by
        field_simp [ne_of_gt hε]
      _ ≤ _ := hsize
  obtain ⟨hdenom, hprob⟩ := hlearn σ hσ hσlt D δ hδ n hbudget
  refine ⟨hdenom, hprob.trans ?_⟩
  apply sampleProbability_mono
  intro sample hs
  exact hs.1

end MainProofs
end NeuralGeneralization
