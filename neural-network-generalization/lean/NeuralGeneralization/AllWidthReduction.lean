import NeuralGeneralization.LearningBudget
import NeuralGeneralization.ModelLearning
import NeuralGeneralization.ModelFacts

/-!
# The statistical splice covering every width

The finite relevant-class route handles widths above a threshold; the target-
mass route handles all smaller admissible widths. This module proves that the
two quantitative inputs yield one sample bound for every width at least a
realizing target complexity. It uses the actual product-Gaussian network prior.

The aggregate tail, target-mass, and class-count bounds are explicit hypotheses;
this module does not claim to prove the analytic estimates that supply them.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable


namespace ConcreteModel

/-- The complete finite statistical step that joins the two width ranges.
The resulting budget is independent of `N`. The main analytic obligations of
the above-mean-field and mean-field papers are exactly the class/count/mass
premises displayed here. -/
theorem all_width_learning_reduction
    {d C r : ℕ} (hd : 0 < d) {φ : ℝ → ℝ} (hφ : Continuous φ)
    (f : BooleanFunction d) (hc : realizesAtComplexity (r := r) φ f C)
    (γ : ℝ) (T : ℕ) (A : Finset (BooleanFunction d)) (H B P : ℝ)
    (hcount : (A.card : ℝ) ≤ Real.exp H) (hH : H ≤ P) (hB : B ≤ P)
    (ε δ : ℝ) (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ)
    (hlarge : ∀ N : ℕ, C ≤ N → T ≤ N →
      (∑ g ∈ Finset.univ \ A, functionMass φ (1 / 2) (powerPrior d N r γ) g) /
        functionMass φ (1 / 2) (powerPrior d N r γ) f ≤ ε / 6)
    (hsmall : ∀ N : ℕ, C ≤ N → N < T →
      Real.exp (-B) ≤ functionMass φ (1 / 2) (powerPrior d N r γ) f)
    (n : ℕ)
    (hsize : (P + Real.log (1 / (δ * (ε / 6)))) / (ε / 6) ≤ (n : ℝ)) :
    ∀ N : ℕ, C ≤ N →
      (∀ sample : Fin n → Cube d,
        0 < posteriorDenominator φ (1 / 2) (powerPrior d N r γ) f sample) ∧
      ∀ D : InputLaw d,
        1 - δ ≤ sampleProbability D n (fun sample =>
          posteriorRisk D f (networkPosterior φ (1 / 2) (powerPrior d N r γ) f sample) ≤ ε / 3 ∧
          confidenceFailure D f (networkPosterior φ (1 / 2) (powerPrior d N r γ) f sample) ≤ ε) := by
  have ha : 0 < ε / 6 := by linarith
  have ha1 : ε / 6 ≤ 1 := by linarith
  have hbudget : P + Real.log (1 / (δ * (ε / 6))) ≤ (n : ℝ) * (ε / 6) :=
    (div_le_iff₀ ha).mp hsize
  intro N hCN
  have hf := power_functionMass_pos hd hφ f hc hCN γ
  constructor
  · intro sample
    exact posteriorDenominator_pos φ (1 / 2) (powerPrior d N r γ) f sample hf
  · intro D
    have hhalf : ε / 6 + ε / 6 = ε / 3 := by ring
    have hconfidence : 3 * (ε / 3) = ε := by ring
    by_cases hNT : T ≤ N
    · have hcard : (A.card : ℝ) * Real.exp (-(n : ℝ) * (ε / 6)) ≤ δ := by
        have hx := exponential_sample_bound (A.card : ℝ) H (ε / 6)
          (δ * (ε / 6)) n hcount (mul_pos hδ ha) (by linarith)
        have hy : δ * (ε / 6) ≤ δ := by
          nlinarith [mul_nonneg hδ.le (sub_nonneg.mpr ha1)]
        exact le_trans hx hy
      have h := network_finite_class_learning φ (1 / 2) (powerPrior d N r γ) D f hf A
        (ε / 6) (ε / 6) δ ha.le ha1 (hlarge N hCN hNT) n hcard
      simpa only [hhalf, hconfidence] using h
    · have hmass := hsmall N hCN (lt_of_not_ge hNT)
      have htarget : Real.exp (-(n : ℝ) * (ε / 6)) /
          (functionMass φ (1 / 2) (powerPrior d N r γ) f * (ε / 6)) ≤ δ :=
        target_mass_exponential_bound _ B (ε / 6) (ε / 6) δ n hmass ha hδ (by linarith)
      have h := network_target_mass_learning hφ (1 / 2) (by norm_num)
        (powerPrior d N r γ) D f hf (ε / 6) (ε / 6) δ ha.le ha1 ha n htarget
      simpa only [hhalf, hconfidence] using h

/-- The risk-only statistical splice, retaining the `2/ε` sample factor.
All widths below `T` use actual target mass, and all larger widths use the
actual aggregate mass outside a finite relevant class. -/
theorem all_width_risk_learning_reduction
    {d C r : ℕ} (hd : 0 < d) {φ : ℝ → ℝ} (hφ : Continuous φ)
    (f : BooleanFunction d) (hc : realizesAtComplexity (r := r) φ f C)
    (γ : ℝ) (T : ℕ) (A : Finset (BooleanFunction d)) (H B P : ℝ)
    (hcount : (A.card : ℝ) ≤ Real.exp H) (hH : H ≤ P) (hB : B ≤ P)
    (ε δ : ℝ) (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ)
    (hlarge : ∀ N : ℕ, C ≤ N → T ≤ N →
      (∑ g ∈ Finset.univ \ A, functionMass φ (1 / 2) (powerPrior d N r γ) g) /
        functionMass φ (1 / 2) (powerPrior d N r γ) f ≤ ε / 2)
    (hsmall : ∀ N : ℕ, C ≤ N → N < T →
      Real.exp (-B) ≤ functionMass φ (1 / 2) (powerPrior d N r γ) f)
    (n : ℕ)
    (hsize : (2 / ε) * (P + Real.log (2 / (ε * δ))) ≤ (n : ℝ)) :
    ∀ N : ℕ, C ≤ N →
      (∀ sample : Fin n → Cube d,
        0 < posteriorDenominator φ (1 / 2) (powerPrior d N r γ) f sample) ∧
      ∀ D : InputLaw d,
        1 - δ ≤ sampleProbability D n (fun sample =>
          posteriorRisk D f (networkPosterior φ (1 / 2) (powerPrior d N r γ) f sample) ≤ ε) := by
  have ha : 0 < ε / 2 := by linarith
  have ha1 : ε / 2 ≤ 1 := by linarith
  have hlogarg : 2 / (ε * δ) = 1 / (δ * (ε / 2)) := by
    field_simp
  have hbudget : P + Real.log (1 / (δ * (ε / 2))) ≤ (n : ℝ) * (ε / 2) := by
    have hh := mul_le_mul_of_nonneg_right hsize ha.le
    rw [hlogarg] at hh
    have heq : (2 / ε) * (P + Real.log (1 / (δ * (ε / 2)))) * (ε / 2) =
        P + Real.log (1 / (δ * (ε / 2))) := by field_simp [ne_of_gt hε]
    rwa [heq] at hh
  intro N hCN
  have hf := power_functionMass_pos hd hφ f hc hCN γ
  constructor
  · intro sample
    exact posteriorDenominator_pos φ (1 / 2) (powerPrior d N r γ) f sample hf
  · intro D
    have hhalf : ε / 2 + ε / 2 = ε := by ring
    by_cases hNT : T ≤ N
    · have hcard : (A.card : ℝ) * Real.exp (-(n : ℝ) * (ε / 2)) ≤ δ := by
        have hx := exponential_sample_bound (A.card : ℝ) H (ε / 2)
          (δ * (ε / 2)) n hcount (mul_pos hδ ha) (by linarith)
        have hy : δ * (ε / 2) ≤ δ := by
          nlinarith [mul_nonneg hδ.le (sub_nonneg.mpr ha1)]
        exact hx.trans hy
      have hh := network_finite_class_learning φ (1 / 2) (powerPrior d N r γ) D f hf A
        (ε / 2) (ε / 2) δ ha.le ha1 (hlarge N hCN hNT) n hcard
      apply hh.trans
      apply sampleProbability_mono
      intro sample hs
      simpa only [hhalf] using hs.1
    · have hmass := hsmall N hCN (lt_of_not_ge hNT)
      have htarget : Real.exp (-(n : ℝ) * (ε / 2)) /
          (functionMass φ (1 / 2) (powerPrior d N r γ) f * (ε / 2)) ≤ δ :=
        target_mass_exponential_bound _ B (ε / 2) (ε / 2) δ n hmass ha hδ (by linarith)
      have hh := network_target_mass_learning hφ (1 / 2) (by norm_num)
        (powerPrior d N r γ) D f hf (ε / 2) (ε / 2) δ ha.le ha1 ha n htarget
      apply hh.trans
      apply sampleProbability_mono
      intro sample hs
      simpa only [hhalf] using hs.1

end ConcreteModel
end NeuralGeneralization
