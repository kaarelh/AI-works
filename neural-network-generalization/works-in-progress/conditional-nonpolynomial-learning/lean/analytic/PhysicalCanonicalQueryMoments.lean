import CanonicalQueryMoments
import PhysicalCanonicalProgramState
noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianFieldTilt NeuralGeneralization.GaussianAngularPrice
theorem PhysicalCanonicalProgramStep.queryMoments {d H : ℕ} {t : ℝ}
    {f : NeuralGeneralization.ConcreteModel.BooleanFunction d}
    {P : ControlledMarginPath d H t f} {S : Finset (NeuralGeneralization.ConcreteModel.Cube d)}
    {j : ℕ} {B C : CanonicalProgramState d}
    (hstep : PhysicalCanonicalProgramStep P S j B C)
    (x : NeuralGeneralization.ConcreteModel.Cube d) (i k : S ⊕ Unit) :
    inner ℝ (C.feature (anchorQueryIndex S x i)) (C.feature (anchorQueryIndex S x k))=
      ∫z,Real.tanh (z (anchorQueryIndex S x i))*Real.tanh (z (anchorQueryIndex S x k))
        ∂fieldAnchorReplacement (P.law j) (fieldLaw (scaledFeatureCoefficients t B.feature))
          (ConditionalAnalytic.maskCoordinates S) := by
  obtain ⟨L,hprob,hKL,hcost,hmap,hreplacement,e,he⟩ := hstep
  letI := hprob
  rw [he,he,e.inner_map_map]
  rw [canonicalGaussian_anchor_query_moments L hKL (fun x => t • B.feature x) S x i k]
  rw [← hreplacement]
  symm
  exact integral_map (fieldLinear _).continuous.measurable.aemeasurable (by fun_prop)

#print axioms PhysicalCanonicalProgramStep.queryMoments
end ConditionalNonpolynomial.Analytic
