import NetworkKernelAdapter

noncomputable section
open MeasureTheory InformationTheory
open scoped BigOperators ENNReal InnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.GaussianFieldTilt

/-- A genuine population Gaussian path, in a fixed finite Hilbert space,
with the original strict half-margin convention. No circuit property is part
of this definition. -/
structure ControlledMarginPath (d H : ℕ) (t : ℝ) (f : BooleanFunction d) where
  scale_positive : 0<t
  scale_le_one : t≤1
  feature : ℕ → PairFeature (Cube d)
  law : ℕ → Measure (Cube d→ℝ)
  readout : EuclideanSpace ℝ (Cube d ⊕ Cube d)
  initial : ∀ x y,inner ℝ (feature 0 x) (feature 0 y)=
    inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)
  probability : ∀ j<H,IsProbabilityMeasure (law j)
  finiteKL : ∀ j<H,klDiv (law j) (fieldLaw (scaledFeatureCoefficients t (feature j)))≠∞
  recursion : ∀ j<H,∀ x y,inner ℝ (feature (j+1) x) (feature (j+1) y)=
    ∫z,Real.tanh (z x)*Real.tanh (z y) ∂law j
  margin : ∀x,(1:ℝ)/2<labelReal (f x)*inner ℝ readout (feature H x)

def ControlledMarginPath.action {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) : ℝ :=
  (∑j : Fin H,(klDiv (P.law j) (fieldLaw (scaledFeatureCoefficients t (P.feature j)))).toReal)+
    ‖P.readout‖^2/(2*t^2)

end ConditionalNonpolynomial.Analytic
