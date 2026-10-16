import Mathlib.Probability.Distributions.Gaussian.Real
import Mathlib.MeasureTheory.Constructions.Pi
import Mathlib.Analysis.Complex.Trigonometric
import Mathlib.Data.List.FinRange
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import NeuralGeneralization.FunctionPrior

/-!
# The finite neural-network model used by the four manuscripts

This file defines the actual finite product Gaussian model. It does not replace
the Gaussian function masses by abstract weights. `internalLayers = r` means
depth `L = r + 2`: there is one input-to-hidden matrix, `r` hidden-to-hidden
matrices, and one linear readout. The sole bias is the constant input coordinate.

The four research claims are stated, but not proved, in `Statements.lean`.
-/

noncomputable section

open scoped BigOperators
open MeasureTheory ProbabilityTheory

namespace NeuralGeneralization.ConcreteModel

/-- Variances, not standard deviations, for the width-exponent model. -/
def powerVariance (d N r : ℕ) (γ : ℝ) : WeightIndex d N r → ℝ
  | Sum.inl _ => (N : ℝ) ^ (1 - γ) / d
  | Sum.inr (Sum.inl _) => (N : ℝ) ^ (-γ)
  | Sum.inr (Sum.inr _) => (N : ℝ) ^ (-γ - 1)

/-- Variances for the fixed-width small-variance limit. -/
def smallVariance (d N r : ℕ) (σ : ℝ) : WeightIndex d N r → ℝ
  | Sum.inl _ => (N : ℝ) / d * σ ^ 2
  | Sum.inr (Sum.inl _) => σ ^ 2
  | Sum.inr (Sum.inr _) => σ ^ 2 / N

/-- Independent centered real Gaussians on every actual network weight. -/
def productGaussian (d N r : ℕ) (v : WeightIndex d N r → ℝ) :
    Measure (Weights d N r) :=
  Measure.pi (fun i => gaussianReal 0 (v i).toNNReal)

def powerPrior (d N r : ℕ) (γ : ℝ) : Measure (Weights d N r) :=
  productGaussian d N r (powerVariance d N r γ)

def smallPrior (d N r : ℕ) (σ : ℝ) : Measure (Weights d N r) :=
  productGaussian d N r (smallVariance d N r σ)

instance productGaussian_probability (d N r : ℕ) (v : WeightIndex d N r → ℝ) :
    IsProbabilityMeasure (productGaussian d N r v) := by
  unfold productGaussian
  infer_instance

instance powerPrior_probability (d N r : ℕ) (γ : ℝ) :
    IsProbabilityMeasure (powerPrior d N r γ) := by
  unfold powerPrior
  infer_instance

instance smallPrior_probability (d N r : ℕ) (σ : ℝ) :
    IsProbabilityMeasure (smallPrior d N r σ) := by
  unfold smallPrior
  infer_instance


end NeuralGeneralization.ConcreteModel
