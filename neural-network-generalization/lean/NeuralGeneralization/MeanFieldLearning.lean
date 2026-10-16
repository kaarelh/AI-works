import NeuralGeneralization.MeanFieldLearningBudget
import NeuralGeneralization.ExponentialTailRatio
import NeuralGeneralization.AllWidthReduction
import NeuralGeneralization.Statements

/-!
# Final mean-field statistical assembly and polynomial envelope

This module converts the explicitly displayed aggregate tail of the actual
Gaussian function prior into the exact main statement. The aggregate tail
is the analytic input; every target-mass, sampling, confidence and polynomial
budget step is proved here using the concrete model.
-/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization
open ConcreteModel

namespace MeanFieldLearning
open MeanFieldBudgets MeanFieldLearningBudget

/-- Quantitative all-width learning once the actual relevant-class tail is
supplied. The sample budget is explicit and polynomial at fixed depth. -/
theorem learning_of_aggregate_tail (r : ℕ)
    (htail : ∀ d : ℕ, 1 ≤ d → ∀ K : ℕ, 8 ≤ K → ∀ N : ℕ,
      empiricalWidthThreshold d r K ≤ N →
      (∑ g ∈ Finset.univ \ MeanFieldFunctionClass.functions d r K,
        functionMass Real.tanh (1/2) (powerPrior d N r 1) g) ≤
        ((r : ℝ)+2)*Real.exp (-(N : ℝ)*(K : ℝ)/8))
    {d C : ℕ} (hd : 1 ≤ d) (f : BooleanFunction d)
    (hf : realizesAtComplexity (r := r) Real.tanh f C)
    (ε δ : ℝ) (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ)
    (n : ℕ)
    (hn : (6/ε)*((sampleBudget r d (C+⌈Real.log (1/ε)⌉₊) : ℝ)+
      Real.log (6/(ε*δ))) ≤ (n : ℝ)) :
    ∀ N : ℕ, C ≤ N →
      (∀ s : Fin n → Cube d,
        0 < posteriorDenominator Real.tanh (1/2) (powerPrior d N r 1) f s) ∧
      ∀ D : InputLaw d,
        1-δ ≤ sampleProbability D n (fun s =>
          posteriorRisk D f
            (networkPosterior Real.tanh (1/2) (powerPrior d N r 1) f s) ≤ ε/3 ∧
          ConcreteModel.confidenceFailure D f
            (networkPosterior Real.tanh (1/2) (powerPrior d N r 1) f s) ≤ ε) := by
  let t := Real.log (1/ε)
  let S := C+⌈t⌉₊
  let K := energyBudget r d S
  let T := widthThreshold r d S
  let P : ℝ := sampleBudget r d S
  let B : ℝ := cylinderPolynomialCoefficient r*
    (1+(d : ℝ)+C)^cylinderPolynomialDegree r
  have hK : 8 ≤ K := energyBudget_ge_eight r d S
  have hcap : (MeanFieldFunctionClass.capacity d r K : ℝ) ≤ P := by
    dsimp [K, P]
    exact_mod_cast sampleBudget_ge_capacity r d S
  have hsmall : B*(T : ℝ) ≤ P := sampleBudget_ge_actual_smallWidth r d C t
  apply all_width_learning_reduction (by omega) tanh_continuous f hf 1 T
    (MeanFieldFunctionClass.functions d r K) (MeanFieldFunctionClass.capacity d r K)
    (B*(T : ℝ)) P (MeanFieldFunctionClass.functions_card_le_exp d r K) hcap hsmall
    ε δ hε hε1 hδ _ _ n _
  · intro N hCN hTN
    have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
    have hh := htail d hd K hK N hTN
    have hmass := meanField_target_mass_polynomial (by omega) Real.tanh tanh_admissible f hf hCN
    apply exponential_tail_ratio_prefactor_le _ _ ((r : ℝ)+2) B
      ((K : ℝ)/8) (N : ℝ) (ε/6) _
      (by simpa only [B, neg_mul] using hmass)
      (by have hr : (0 : ℝ) ≤ r := Nat.cast_nonneg r; linarith)
      (by exact_mod_cast hN) (by linarith) (by linarith) _
    · have hid : -((K : ℝ)/8)*(N : ℝ) = -(N : ℝ)*(K : ℝ)/8 := by ring
      rw [hid]
      exact hh
    · have hid : ((r : ℝ)+2)/(ε/6) = 6*((r : ℝ)+2)/ε := by ring
      rw [hid]
      exact energyBudget_rate_gap r d C ε hε
  · intro N hCN hNT
    have hh := powerPrior_target_mass_below_threshold (by omega) Real.tanh tanh_admissible
      f hf hCN hNT.le (γ := 1) le_rfl
    simpa only [Real.rpow_one] using hh
  · have hid : (P+Real.log (1/(δ*(ε/6))))/(ε/6) =
        (6/ε)*(P+Real.log (6/(ε*δ))) := by
      have harg : 1/(δ*(ε/6)) = 6/(ε*δ) := by field_simp
      rw [harg]
      ring
    rw [hid]
    exact hn

/-- Exact polynomial-envelope main statement after inserting the actual
aggregate prior tail. This theorem has an explicit analytic premise and is
not itself recorded as the completed main proof. -/
theorem main_of_aggregate_tail
    (htail : ∀ r d : ℕ, 1 ≤ d → ∀ K : ℕ, 8 ≤ K → ∀ N : ℕ,
      empiricalWidthThreshold d r K ≤ N →
      (∑ g ∈ Finset.univ \ MeanFieldFunctionClass.functions d r K,
        functionMass Real.tanh (1/2) (powerPrior d N r 1) g) ≤
        ((r : ℝ)+2)*Real.exp (-(N : ℝ)*(K : ℝ)/8)) :
    MainStatements.MeanFieldGeneralization := by
  intro r
  obtain ⟨A,hA,m,hpoly⟩ := sampleBudget_real_envelope r
  refine ⟨A,hA,m,?_⟩
  intro d hd f C hc N hCN D ε δ hε hε1 hδ hδ1 n hn
  have ht : 0 ≤ Real.log (1/ε) :=
    Real.log_nonneg ((one_le_div hε).mpr hε1.le)
  have hbudget := hpoly d C (Real.log (1/ε)) ht
  have hsize : (6/ε)*((sampleBudget r d (C+⌈Real.log (1/ε)⌉₊) : ℝ)+
      Real.log (6/(ε*δ))) ≤ (n : ℝ) := by
    apply le_trans _ hn
    exact mul_le_mul_of_nonneg_left (add_le_add hbudget le_rfl) (by positivity)
  obtain ⟨hden,hprob⟩ := learning_of_aggregate_tail r (htail r) hd f hc.1
    ε δ hε hε1 hδ n hsize N hCN
  exact ⟨hden,hprob D⟩

end MeanFieldLearning
end NeuralGeneralization
