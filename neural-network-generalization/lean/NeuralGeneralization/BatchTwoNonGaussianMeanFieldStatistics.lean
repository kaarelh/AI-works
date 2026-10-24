import NeuralGeneralization.BatchTwoNonGaussianMeanFieldAggregate
import NeuralGeneralization.BatchTwoNonGaussianStrongMain
import NeuralGeneralization.BatchTwoNonGaussianPolynomialGrowth
import NeuralGeneralization.AllWidthReduction
import NeuralGeneralization.ExponentialTailRatio

/-! Statistical splice for the original non-Gaussian mean-field posterior. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian.NonGaussianMeanField
open ConcreteModel
open Classical
attribute [local instance] Classical.propDecidable

theorem all_width_learning_reduction (ν : CoordinateLaw)
    {d C r : ℕ} (hd : 0 < d) {φ : ℝ → ℝ} (hφ : Continuous φ)
    (f : BooleanFunction d) (hc : realizesAtComplexity (r := r) φ f C)
    (T : ℕ) (A : Finset (BooleanFunction d)) (H B P : ℝ)
    (hcount : (A.card : ℝ) ≤ Real.exp H) (hH : H ≤ P) (hB : B ≤ P)
    (ε δ : ℝ) (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ)
    (hlarge : ∀ N : ℕ, C ≤ N → T ≤ N →
      (∑ g ∈ Finset.univ \ A, functionMass φ (1 / 2) (powerPrior ν d N r 1) g) /
        functionMass φ (1 / 2) (powerPrior ν d N r 1) f ≤ ε / 6)
    (hsmall : ∀ N : ℕ, C ≤ N → N < T →
      Real.exp (-B) ≤ functionMass φ (1 / 2) (powerPrior ν d N r 1) f)
    (n : ℕ)
    (hsize : (P + Real.log (1 / (δ * (ε / 6)))) / (ε / 6) ≤ (n : ℝ)) :
    ∀ N : ℕ, C ≤ N →
      (∀ sample : Fin n → Cube d,
        0 < posteriorDenominator φ (1 / 2) (powerPrior ν d N r 1) f sample) ∧
      ∀ D : InputLaw d,
        1 - δ ≤ sampleProbability D n (fun sample =>
          posteriorRisk D f (networkPosterior φ (1 / 2) (powerPrior ν d N r 1) f sample) ≤ ε / 3 ∧
          ConcreteModel.confidenceFailure D f (networkPosterior φ (1 / 2) (powerPrior ν d N r 1) f sample) ≤ ε) := by
  have ha : 0 < ε / 6 := by linarith
  have ha1 : ε / 6 ≤ 1 := by linarith
  have hbudget : P + Real.log (1 / (δ * (ε / 6))) ≤ (n : ℝ) * (ε / 6) :=
    (div_le_iff₀ ha).mp hsize
  intro N hCN
  have hN : 0 < N := (Nat.succ_le_iff.mp hc.1).trans_le hCN
  have hf : 0 < functionMass φ (1/2) (powerPrior ν d N r 1) f := by
    rw [powerPrior_eq_smallPrior_standardDeviation ν hd hN 1]
    exact smallMass_pos ν hd hφ f hc hCN (powerStandardDeviation_pos hN 1)
  constructor
  · intro sample
    exact posteriorDenominator_pos φ (1 / 2) (powerPrior ν d N r 1) f sample hf
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
      have h := network_finite_class_learning φ (1 / 2) (powerPrior ν d N r 1) D f hf A
        (ε / 6) (ε / 6) δ ha.le ha1 (hlarge N hCN hNT) n hcard
      simpa only [hhalf, hconfidence] using h
    · have hmass := hsmall N hCN (lt_of_not_ge hNT)
      have htarget : Real.exp (-(n : ℝ) * (ε / 6)) /
          (functionMass φ (1 / 2) (powerPrior ν d N r 1) f * (ε / 6)) ≤ δ :=
        target_mass_exponential_bound _ B (ε / 6) (ε / 6) δ n hmass ha hδ (by linarith)
      have h := network_target_mass_learning hφ (1 / 2) (by norm_num)
        (powerPrior ν d N r 1) D f hf (ε / 6) (ε / 6) δ ha.le ha1 ha n htarget
      simpa only [hhalf, hconfidence] using h


end NeuralGeneralization.BatchTwoNonGaussian.NonGaussianMeanField
