import NeuralGeneralization.OnlineLowerTanhPeriodicExactRestoring
import NeuralGeneralization.OnlineLowerTanhPeriodicRestoringIntegral
import NeuralGeneralization.OnlineLowerTanhResidualBalanced

/-! The literal eighty-percent restoring-curvature conclusion for arbitrary
real random variables, with the paper's paired-tanh response and its ordinary
second derivative. No moment or finite-support assumption is imposed. -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.OnlineLowerTanh

theorem periodic_restoring_expectation_eighty {Ω : Type*} [MeasurableSpace Ω]
    {ν : Measure Ω} [IsProbabilityMeasure ν] {Z : Ω → ℝ} (hZ : Measurable Z)
    {a : ℝ} (ha1 : 1≤a) (ha2 : a≤2)
    (hmean : (4/5:ℝ)*periodicFourierMaximum a ≤
      ∫ x, periodicFourierResponse a (a+Z x) ∂ν) :
    let A := periodicFrequency a^2*restoringAmplitude (periodicRatio a)
    (∫ x, periodicFourierSecond a (a+Z x) ∂ν) ≤
      -(1/2:ℝ)*A*(1-restoringMu)*periodicFourierMaximum a ∧
    -(1/2:ℝ)*A*(1-restoringMu)*periodicFourierMaximum a < 0 := by
  have ha : 0<a := by linarith
  exact restoring_integral_eighty
    (periodicFourierResponse_integrable_comp (measurable_const.add hZ) ha)
    (periodicFourierSecond_integrable_comp (measurable_const.add hZ) ha)
    (periodicRestoringAmplitude_pos ha) restoringMu_lt_three_quarters
    (periodic_maximum_pos_all_gain ha)
    (fun x => periodic_restoring_pointwise_eighty ha1 ha2 (a+Z x)) hmean

/-- Both clauses of the manuscript's restoring-curvature lemma, for the
literal paired-tanh series and any measurable real random variable. -/
theorem pairedPeriodic_restoring_curvature_paper
    {Ω : Type*} [MeasurableSpace Ω] {ν : Measure Ω} [IsProbabilityMeasure ν]
    {a : ℝ} (ha1 : 1≤a) (ha2 : a≤2) :
    ∃ A μ : ℝ, 0<A ∧ 0<μ ∧ μ<3/4 ∧
      (∀ z : ℝ, deriv (deriv (fun y : ℝ => pairedPeriodicResponse a (a+y))) z ≤
        -A*(1-μ)*scalarF0 a+
          A*(1-μ/2)*(scalarF0 a-pairedPeriodicResponse a (a+z))) ∧
      (∀ Z : Ω → ℝ, Measurable Z →
        (4/5:ℝ)*scalarF0 a ≤ (∫ x, pairedPeriodicResponse a (a+Z x) ∂ν) →
        (∫ x, deriv (deriv (fun y : ℝ => pairedPeriodicResponse a (a+y))) (Z x) ∂ν) ≤
          -(1/2:ℝ)*A*(1-μ)*scalarF0 a ∧
        -(1/2:ℝ)*A*(1-μ)*scalarF0 a < 0) := by
  have ha : 0<a := by linarith
  refine ⟨periodicFrequency a^2*restoringAmplitude (periodicRatio a),restoringMu,
    periodicRestoringAmplitude_pos ha,restoringMu_pos,restoringMu_lt_three_quarters,?_,?_⟩
  · intro z
    rw [pairedPeriodicResponse_centered_second_deriv ha,
      ←periodicFourierResponse_eq_paired ha (a+z),←periodicFourierMaximum_eq_scalarF0 a ha]
    have h := periodic_restoring_pointwise_eighty ha1 ha2 (a+z)
    nlinarith
  · intro Z hZ hmean
    have hmean' : (4/5:ℝ)*periodicFourierMaximum a ≤
        ∫ x, periodicFourierResponse a (a+Z x) ∂ν := by
      simpa only [periodicFourierMaximum_eq_scalarF0 a ha,
        periodicFourierResponse_eq_paired ha] using hmean
    simpa only [pairedPeriodicResponse_centered_second_deriv ha,
      periodicFourierMaximum_eq_scalarF0 a ha] using
      periodic_restoring_expectation_eighty (ν:=ν) hZ ha1 ha2 hmean'

end NeuralGeneralization.OnlineLowerTanh
