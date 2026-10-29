import GaussianStatisticLiftCoordinates
import GaussianRowSpanCoordinates

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal NNReal BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt
variable {I X : Type*} [Fintype I] [Fintype X] [DecidableEq I] [DecidableEq X]

/-- For an arbitrary finite linear statistic, including singular ones, the
matching centered Gaussian of its actual entropy-minimal lift is itself
entropy-minimal. The orthogonal geometry is constructed, not assumed. -/
theorem matchingGaussian_linearStatistic_minimal
    (R : Measure (I→ℝ)) [IsProbabilityMeasure R] (hR : klDiv R (standardLaw I)≠∞)
    (A : X→I→ℝ)
    (hminimal : R=statisticEntropyLift (standardLaw I) (fieldLinear A) (R.map (fieldLinear A))) :
    matchingGaussian R=statisticEntropyLift (standardLaw I) (fieldLinear A)
      ((matchingGaussian R).map (fieldLinear A)) := by
  let K := gaussianRowSpan A
  obtain ⟨D,hD⟩ := exists_rowSpan_extractor A
  apply matchingGaussian_minimal_linearStatistic R hR A hminimal
    (subspaceSplitMatrix K) (subspaceJoinMatrix K)
    (funext (subspaceJoin_split K)) (subspaceSplitMatrix_standard K)
    (fieldLinear (rowSpanDecoderMatrix A)) (fieldLinear _).continuous.measurable
    (fieldLinear D) (fieldLinear D).continuous.measurable
  · intro z
    change fieldLinear A z=fieldLinear (rowSpanDecoderMatrix A)
      (fieldLinear (fun j i=>subspaceSplitMatrix K (.inl j) i) z)
    rw [subspaceSplitMatrix_left]
    exact (fieldLinear_rowSpan_decode A z).symm
  · intro z
    change fieldLinear (fun j i=>subspaceSplitMatrix K (.inl j) i) z=fieldLinear D (fieldLinear A z)
    rw [subspaceSplitMatrix_left]
    exact (hD z).symm

/-- Genuine minimal linear-statistic completion cannot increase the
non-Gaussian entropy, even when source and completion dimensions differ. -/
theorem nonGaussianKL_linearStatistic_completion
    {J : Type*} [Fintype J] [DecidableEq J]
    (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q] (R : Measure (J→ℝ)) [IsProbabilityMeasure R]
    (hQ : klDiv Q (standardLaw I)≠∞) (hR : klDiv R (standardLaw J)≠∞)
    (A : X→I→ℝ) (B : X→J→ℝ)
    (hmap : Q.map (fieldLinear A)=R.map (fieldLinear B))
    (hminimal : R=statisticEntropyLift (standardLaw J) (fieldLinear B) (R.map (fieldLinear B))) :
    klDiv R (matchingGaussian R)≤klDiv Q (matchingGaussian Q) :=
  nonGaussianKL_statistic_transfer Q R hQ hR A B hmap hminimal
    (matchingGaussian_linearStatistic_minimal R hR B hminimal)

#print axioms matchingGaussian_linearStatistic_minimal
#print axioms nonGaussianKL_linearStatistic_completion
end ConditionalNonpolynomial.Analytic
