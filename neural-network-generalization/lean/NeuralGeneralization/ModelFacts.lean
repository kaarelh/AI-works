import NeuralGeneralization.FunctionPriorFacts
import NeuralGeneralization.Model
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.MeasureTheory.Measure.OpenPos

/-!
# Positivity of the actual Gaussian conditioning events

These results use the concrete network, the actual independent Gaussian law,
and the cloning construction. They do not assume an abstract positive target
mass. Every representable target has positive mass at every larger width, for
every finite real exponent, and at every positive small-prior scale.
-/

noncomputable section

open scoped BigOperators NNReal
open MeasureTheory ProbabilityTheory MeasureTheory.Measure

namespace NeuralGeneralization.ConcreteModel

theorem gaussianReal_openPos (m : ℝ) {v : ℝ≥0} (hv : v ≠ 0) :
    IsOpenPosMeasure (gaussianReal m v) :=
  (gaussianReal_absolutelyContinuous' m hv).isOpenPosMeasure

theorem productGaussian_openPos (d N r : ℕ) (v : WeightIndex d N r → ℝ)
    (hv : ∀ i, 0 < v i) : IsOpenPosMeasure (productGaussian d N r v) := by
  letI : ∀ i : WeightIndex d N r,
      IsOpenPosMeasure (gaussianReal 0 (v i).toNNReal) :=
    fun i => gaussianReal_openPos 0 (Real.toNNReal_pos.mpr (hv i)).ne'
  unfold productGaussian
  infer_instance

theorem powerVariance_pos {d N r : ℕ} (hd : 0 < d) (hN : 0 < N) (γ : ℝ)
    (i : WeightIndex d N r) : 0 < powerVariance d N r γ i := by
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  have hNR : (0 : ℝ) < N := Nat.cast_pos.mpr hN
  rcases i with ij | (sij | j)
  · exact div_pos (Real.rpow_pos_of_pos hNR _) hdR
  · exact Real.rpow_pos_of_pos hNR _
  · exact Real.rpow_pos_of_pos hNR _

theorem smallVariance_pos {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) (i : WeightIndex d N r) :
    0 < smallVariance d N r σ i := by
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  have hNR : (0 : ℝ) < N := Nat.cast_pos.mpr hN
  rcases i with ij | (sij | j)
  · exact mul_pos (div_pos hNR hdR) (pow_pos hσ 2)
  · exact pow_pos hσ 2
  · exact div_pos (pow_pos hσ 2) hNR

/-- In particular, no posterior denominator in the above-mean-field or
mean-field theorem is zero at a width at least target complexity. -/
theorem power_functionMass_pos {d C N r : ℕ} (hd : 0 < d) {φ : ℝ → ℝ}
    (hφ : Continuous φ) (f : BooleanFunction d)
    (hc : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N) (γ : ℝ) :
    0 < functionMass φ (1 / 2) (powerPrior d N r γ) f := by
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hc.1) hCN
  letI : IsOpenPosMeasure (powerPrior d N r γ) :=
    productGaussian_openPos d N r _ (powerVariance_pos hd hN γ)
  obtain ⟨w, hw⟩ := margin_witness_at_larger_width φ f hc hCN
  exact functionMass_pos_of_mem hφ (1 / 2) (powerPrior d N r γ) f w hw

theorem small_functionMass_pos {d C N r : ℕ} (hd : 0 < d) {φ : ℝ → ℝ}
    (hφ : Continuous φ) (f : BooleanFunction d)
    (hc : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N)
    {σ : ℝ} (hσ : 0 < σ) :
    0 < functionMass φ (1 / 2) (smallPrior d N r σ) f := by
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hc.1) hCN
  letI : IsOpenPosMeasure (smallPrior d N r σ) :=
    productGaussian_openPos d N r _ (smallVariance_pos hd hN hσ)
  obtain ⟨w, hw⟩ := margin_witness_at_larger_width φ f hc hCN
  exact functionMass_pos_of_mem hφ (1 / 2) (smallPrior d N r σ) f w hw

theorem power_posteriorDenominator_pos {d C N r n : ℕ} (hd : 0 < d)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (f : BooleanFunction d)
    (hc : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N) (γ : ℝ)
    (s : Fin n → Cube d) :
    0 < posteriorDenominator φ (1 / 2) (powerPrior d N r γ) f s :=
  posteriorDenominator_pos φ (1 / 2) (powerPrior d N r γ) f s
    (power_functionMass_pos hd hφ f hc hCN γ)

theorem small_posteriorDenominator_pos {d C N r n : ℕ} (hd : 0 < d)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (f : BooleanFunction d)
    (hc : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N)
    {σ : ℝ} (hσ : 0 < σ) (s : Fin n → Cube d) :
    0 < posteriorDenominator φ (1 / 2) (smallPrior d N r σ) f s :=
  posteriorDenominator_pos φ (1 / 2) (smallPrior d N r σ) f s
    (small_functionMass_pos hd hφ f hc hCN hσ)

/-- At every allowed power-prior width, the raw-mass posterior is exactly
Bayes conditioning of the globally margin-conditioned function prior. -/
theorem power_networkPosterior_eq_globalConditioned {d C N r n : ℕ}
    (hd : 0 < d) {φ : ℝ → ℝ} (hφ : Continuous φ) (f : BooleanFunction d)
    (hc : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N) (γ : ℝ)
    (s : Fin n → Cube d) :
    networkPosterior φ (1 / 2) (powerPrior d N r γ) f s =
      NeuralGeneralization.posterior
        (globalConditionedFunctionPrior φ (1 / 2) (powerPrior d N r γ))
        (consistent f s) :=
  networkPosterior_eq_globalConditioned φ (1 / 2) (powerPrior d N r γ) f s
    (globalMarginMass_pos_of_functionMass φ (1 / 2) (powerPrior d N r γ) f
      (power_functionMass_pos hd hφ f hc hCN γ)).ne'

/-- The same exact normalization identity for every positive small-prior
scale, with positivity supplied by the actual Gaussian law and cloning. -/
theorem small_networkPosterior_eq_globalConditioned {d C N r n : ℕ}
    (hd : 0 < d) {φ : ℝ → ℝ} (hφ : Continuous φ) (f : BooleanFunction d)
    (hc : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N)
    {σ : ℝ} (hσ : 0 < σ) (s : Fin n → Cube d) :
    networkPosterior φ (1 / 2) (smallPrior d N r σ) f s =
      NeuralGeneralization.posterior
        (globalConditionedFunctionPrior φ (1 / 2) (smallPrior d N r σ))
        (consistent f s) :=
  networkPosterior_eq_globalConditioned φ (1 / 2) (smallPrior d N r σ) f s
    (globalMarginMass_pos_of_functionMass φ (1 / 2) (smallPrior d N r σ) f
      (small_functionMass_pos hd hφ f hc hCN hσ)).ne'

end NeuralGeneralization.ConcreteModel
