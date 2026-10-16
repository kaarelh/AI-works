import NeuralGeneralization.AboveMeanFieldLearning
import NeuralGeneralization.AboveMeanFieldBudgetBounds
import NeuralGeneralization.Statements

/-!
# The above-mean-field main theorem at every admissible width

The actual all-width Gaussian cylinder, elementary Gaussian matrix witness
tail, network truncation, norm compression, finite capacity, and exact
posterior learning estimates are assembled with polynomial budgets. The
result has exactly the main statement's type, with no analytic premises.
-/

noncomputable section
namespace NeuralGeneralization
open ConcreteModel

namespace MainProofs

/-- For every fixed gamma greater than one, every width at least the target
complexity has the asserted width-independent polynomial sample bound. -/
theorem aboveMeanField : MainStatements.AboveMeanFieldGeneralization := by
  intro r γ hγ
  obtain ⟨N₀, hlearn⟩ := aboveMeanField_learning_quantitative γ hγ
  obtain ⟨mγ, hmγ⟩ := exists_truncation_polynomial_degree γ hγ
  let pγ : ℕ := ⌈γ⌉₊
  obtain ⟨A, hA, m, hpoly⟩ := aboveSampleBudget_real_envelope r N₀ mγ pγ
  refine ⟨A, hA, m, ?_⟩
  intro φ hφ d hd f C hc N hCN D ε δ hε hε1 hδ hδ1 n hsize
  let t := Real.log (1 / ε)
  let S := C + ⌈t⌉₊
  let K := aboveEnergyBudget r d S
  let T := aboveWidthThreshold r N₀ mγ d S
  let P := MainStatements.polynomialEnvelope A m d C t
  have ht : 0 ≤ t := Real.log_nonneg ((one_le_div hε).mpr hε1.le)
  have hP : (aboveSampleBudget r N₀ mγ pγ d S : ℝ) ≤ P := hpoly d C t ht
  have hcap : (spectralCapacity d r K : ℝ) ≤ P := by
    apply le_trans _ hP
    exact_mod_cast aboveSampleBudget_ge_capacity r N₀ mγ pγ d S
  have hsmall : cylinderPolynomialCoefficient r *
      (1 + (d : ℝ) + C) ^ cylinderPolynomialDegree r * (T : ℝ) ^ γ ≤ P :=
    (aboveSampleBudget_ge_actual_smallWidth r N₀ mγ pγ d C t γ (Nat.le_ceil γ)).trans hP
  obtain ⟨hdenom, hprob⟩ := hlearn hd φ hφ f hc.1 K T mγ
    (aboveWidthThreshold_ge_start r N₀ mγ d S)
    (aboveEnergyBudget_ge_first r d S)
    (aboveWidthThreshold_energy_sq r N₀ mγ d S)
    (aboveWidthThreshold_ge_truncation r N₀ mγ d S) hmγ ε δ hε hε1 hδ
    (aboveEnergyBudget_rate_gap r d C ε hε) P hcap hsmall n hsize N hCN
  exact ⟨hdenom, hprob D⟩

end MainProofs
end NeuralGeneralization
