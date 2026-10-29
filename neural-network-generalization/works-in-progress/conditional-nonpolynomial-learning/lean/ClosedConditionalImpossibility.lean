import PhysicalSmallActionCapacity
import ActualFarStrongCapacity
import ActualLongNearcriticalCapacity
import FamilyCollapse

/-! The closed concrete main theorem. All analytic inputs to the public
finite reduction are proved for the literal Gaussian neural-network model. -/
noncomputable section
namespace ConditionalNonpolynomial

theorem uniformPathCircuitBound : Analytic.UniformPathCircuitBound :=
  Analytic.uniformPathCircuitBound_of_three_regimes
    Analytic.smallActionPathCapacity
    Analytic.actualLongNearcriticalPathCapacity
    Analytic.actualFarStrongPathCapacity

theorem analyticPosteriorCeiling : AnalyticPosteriorCeiling :=
  Analytic.analyticPosteriorCeiling_of_uniform_path_circuits uniformPathCircuitBound

/-- Assuming the stated nonuniform complexity-class separation, no prescribed
positive scale schedule in the full interval 0<t≤1 has the distribution-free,
all-width polynomial sample guarantee defined in NNBayesStatement. -/
theorem conditionalImpossibility : ConditionalImpossibility :=
  conditionalImpossibility_of_posteriorCeiling analyticPosteriorCeiling

/-- Every proposed polynomial has a concrete finite-dimensional, finite-width
counterexample, with the original strictly positive conditioning denominator. -/
theorem conditionalCounterexamples : ConditionalCounterexamples :=
  conditionalCounterexamples_of_posteriorCeiling analyticPosteriorCeiling

#print axioms uniformPathCircuitBound
#print axioms analyticPosteriorCeiling
#print axioms conditionalImpossibility
#print axioms conditionalCounterexamples
end ConditionalNonpolynomial
