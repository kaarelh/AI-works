import NeuralGeneralization.GaussianZeroSmallSample
import NeuralGeneralization.NeuralPolynomialConditioningCost

/-! # Small-sample fixed-margin failure on the actual comparator event -/
noncomputable section
open Filter MeasureTheory ProbabilityTheory
open scoped BigOperators Topology
namespace NeuralGeneralization.GaussianZeroSmallSample
open ConcreteModel FieldPosteriorBridge GaussianFieldTilt GaussianSignPosteriorBridge
  LocalizedCubeBump GaussianZeroModelBridge

/-- With the polynomial denominator proved by the actual localized
comparator, only its explicit separation/cross-energy sample event remains.
The confidence is the exact posterior on Boolean functions. -/
theorem eventually_confidence_failure_of_comparator_event (k : ℕ) (a : ℝ) (ha : 0 < a) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℕ, (n:ℝ) ≤ Real.exp (SmallSampleCutoff.logDimension d^3) →
      ∀ R : ℕ, 0 < R → (n:ℝ)*(1/5:ℝ)^R < 1/20 →
      ∀ s : Fin n → ClippingCube d,
      (∀ i j, i ≠ j → 2*R ≤ hammingDist (s i) (s j)) →
      offDiagonalSum (fun x y => |pairEnergy (walshCoefficients (arcsineProfile d (k+1))) x y|) s ≤ 1 →
      (1:ℝ)/16 ≤ ConfidenceClipping.failure
        (correctConfidence (parity d) (posterior
          (NetworkGaussianFunctionLimit.gaussianFunctionMass d k a) (consistent (parity d) s))) (13/20) := by
  filter_upwards [eventually_confidence_failure k (conditioningPolyConstant k a)
      (conditioningPolyConstant_pos k a).le 5 a ha, eventually_ge_atTop 101]
    with d hd hd101 n hn R hR hsmall s hsep hcross
  let w := walshCoefficients (arcsineProfile d (k+1))
  let E := conditioningEvent (id : (ClippingCube d → ℝ) → ClippingCube d → ℝ) a (parity d) s
  have hE : MeasurableSet E := measurableSet_conditioningEvent id (fun x => measurable_pi_apply x) a (parity d) s
  have hEpos : fieldLaw (WalshGaussianEnergy.matrix w) E ≠ 0 :=
    conditioning_probability_ne_zero w (iterated_arcsine_coefficient_pos d k) ha.le (parity d) s
  have hmargin : ∀ z ∈ E, ∀ x, a ≤ |z x| := fun z hz x => (hz.1 x).le
  have hcost := neural_polynomial_conditioning_cost hd101 k R hR a ha.le s (parity d) hsep hsmall hcross
  have hcost' : Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix w)).real E) ≤
      conditioningPolyConstant k a*((d:ℝ)+1)^5*(1+(n:ℝ)) := by
    calc
      _ ≤ conditioningPolyConstant k a*((n:ℝ)+1)*((d:ℝ)+1)^5 := hcost
      _ = _ := by ring
  have hh := hd (n:ℝ) (Nat.cast_nonneg n) hn E hE hEpos hmargin hcost'
  change (1:ℝ)/16 ≤ ConfidenceClipping.failure
    (correctConfidence (parity d) (posterior (walshFunctionMass w a) (consistent (parity d) s))) (13/20)
  rw [buffered_failure_eq w ha.le s]
  exact hh

end NeuralGeneralization.GaussianZeroSmallSample
