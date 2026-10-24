import NeuralGeneralization.Model
import Mathlib.Analysis.Calculus.ContDiff.Deriv

/-!
# The actual coordinate laws of the non-Gaussian-prior paper

These hypotheses describe the density itself.  In particular no concentration,
translation inequality, or learning conclusion is a field of `CoordinateLaw`.
The second moment formulation is equivalent to variance one once evenness has
given zero mean.  The network indices and forward map are the existing concrete
ones; `r` internal matrices means total depth `r + 2`.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open NeuralGeneralization.ConcreteModel

namespace NeuralGeneralization.BatchTwoNonGaussian

/-- The paper's fixed, even, variance-one scalar density with two-sided curvature. -/
structure CoordinateLaw where
  law : Measure ℝ
  probability : IsProbabilityMeasure law
  potential : ℝ → ℝ
  smooth : ContDiff ℝ 2 potential
  even : Function.Even potential
  normalizer : ℝ
  normalizer_pos : 0 < normalizer
  density_eq : law = volume.withDensity
    (fun x => ENNReal.ofReal (Real.exp (-potential x) / normalizer))
  lowerCurvature : ℝ
  upperCurvature : ℝ
  lowerCurvature_pos : 0 < lowerCurvature
  curvature_lower : ∀ x, lowerCurvature ≤ deriv (deriv potential) x
  curvature_upper : ∀ x, deriv (deriv potential) x ≤ upperCurvature
  square_integrable : Integrable (fun x : ℝ => x ^ 2) law
  square_integral : (∫ x : ℝ, x ^ 2 ∂law) = 1

attribute [instance] CoordinateLaw.probability

namespace CoordinateLaw

theorem upperCurvature_pos (ν : CoordinateLaw) : 0 < ν.upperCurvature :=
  ν.lowerCurvature_pos.trans_le ((ν.curvature_lower 0).trans (ν.curvature_upper 0))

theorem differentiable (ν : CoordinateLaw) : Differentiable ℝ ν.potential :=
  ν.smooth.differentiable (by norm_num)

theorem differentiable_deriv (ν : CoordinateLaw) : Differentiable ℝ (deriv ν.potential) :=
  ν.smooth.differentiable_deriv_two

theorem hasDerivAt_potential (ν : CoordinateLaw) (x : ℝ) :
    HasDerivAt ν.potential (deriv ν.potential x) x :=
  (ν.differentiable x).hasDerivAt

theorem hasDerivAt_deriv (ν : CoordinateLaw) (x : ℝ) :
    HasDerivAt (deriv ν.potential) (deriv (deriv ν.potential) x) x :=
  (ν.differentiable_deriv x).hasDerivAt

theorem deriv_odd (ν : CoordinateLaw) (x : ℝ) :
    deriv ν.potential (-x) = -deriv ν.potential x := by
  have h := (ν.hasDerivAt_potential (-x)).comp x (hasDerivAt_neg x)
  change HasDerivAt (fun y => ν.potential (-y)) _ x at h
  have heq : (fun y => ν.potential (-y)) = ν.potential := funext ν.even
  rw [heq] at h
  have hu := h.unique (ν.hasDerivAt_potential x)
  nlinarith

@[simp] theorem deriv_zero (ν : CoordinateLaw) : deriv ν.potential 0 = 0 := by
  have h := ν.deriv_odd 0
  simp only [neg_zero] at h
  linarith

end CoordinateLaw

/-- Independent copies of the specified non-Gaussian law, scaled on actual weights. -/
def productPrior (ν : CoordinateLaw) (d N r : ℕ)
    (scale : WeightIndex d N r → ℝ) : Measure (Weights d N r) :=
  Measure.pi (fun i => ν.law.map (fun x => scale i * x))

instance productPrior_probability (ν : CoordinateLaw) (d N r : ℕ)
    (scale : WeightIndex d N r → ℝ) :
    IsProbabilityMeasure (productPrior ν d N r scale) := by
  unfold productPrior
  have (i : WeightIndex d N r) :
      IsProbabilityMeasure (ν.law.map (fun x => scale i * x)) :=
    Measure.isProbabilityMeasure_map (by fun_prop)
  infer_instance

def smallScale (d N r : ℕ) (σ : ℝ) : WeightIndex d N r → ℝ
  | Sum.inl _ => σ * Real.sqrt ((N : ℝ) / d)
  | Sum.inr (Sum.inl _) => σ
  | Sum.inr (Sum.inr _) => σ / Real.sqrt N

def powerScale (d N r : ℕ) (γ : ℝ) : WeightIndex d N r → ℝ
  | Sum.inl _ => (N : ℝ) ^ ((1 - γ) / 2) / Real.sqrt d
  | Sum.inr (Sum.inl _) => (N : ℝ) ^ (-γ / 2)
  | Sum.inr (Sum.inr _) => (N : ℝ) ^ (-(γ + 1) / 2)

def smallPrior (ν : CoordinateLaw) (d N r : ℕ) (σ : ℝ) : Measure (Weights d N r) :=
  productPrior ν d N r (smallScale d N r σ)

def powerPrior (ν : CoordinateLaw) (d N r : ℕ) (γ : ℝ) : Measure (Weights d N r) :=
  productPrior ν d N r (powerScale d N r γ)

instance smallPrior_probability (ν : CoordinateLaw) (d N r : ℕ) (σ : ℝ) :
    IsProbabilityMeasure (smallPrior ν d N r σ) := by
  unfold smallPrior
  infer_instance

instance powerPrior_probability (ν : CoordinateLaw) (d N r : ℕ) (γ : ℝ) :
    IsProbabilityMeasure (powerPrior ν d N r γ) := by
  unfold powerPrior
  infer_instance

end NeuralGeneralization.BatchTwoNonGaussian
