import StatisticEntropyLift

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.RobustEntropy
variable {Ω Y : Type*} [MeasurableSpace Ω] [MeasurableSpace Y]
  [StandardBorelSpace Ω] [StandardBorelSpace Y] [Nonempty Ω] [Nonempty Y]

/-- Relative entropy between two genuine lifts through the same conditional
kernel is exactly the entropy between their prescribed statistic laws. -/
theorem statisticEntropyLift_relative_kl (μ : Measure Ω) [IsProbabilityMeasure μ]
    (F : Ω→Y) (hF : Measurable F) (ν ρ : Measure Y)
    [IsProbabilityMeasure ν] [IsProbabilityMeasure ρ]
    (hν : klDiv ν (μ.map F)≠∞) (hρ : klDiv ρ (μ.map F)≠∞) :
    klDiv (statisticEntropyLift μ F ν) (statisticEntropyLift μ F ρ)=klDiv ν ρ := by
  letI := statisticEntropyJoint_probability μ F ν
  letI := statisticEntropyJoint_probability μ F ρ
  letI := statisticEntropyLift_probability μ F ν
  letI := statisticEntropyLift_probability μ F ρ
  apply le_antisymm
  · have hd := klDiv_map_le (statisticEntropyJoint μ F ν) (statisticEntropyJoint μ F ρ) measurable_snd
    change klDiv (statisticEntropyLift μ F ν) (statisticEntropyLift μ F ρ)≤_ at hd
    have he := klDiv_compProd_left ν ρ (μ.map (anchorGraph F)).condKernel
    exact hd.trans (le_of_eq he)
  · have hd := klDiv_map_le (statisticEntropyLift μ F ν) (statisticEntropyLift μ F ρ) hF
    rwa [statisticEntropyLift_map μ hF ν hν,statisticEntropyLift_map μ hF ρ hρ] at hd

#print axioms statisticEntropyLift_relative_kl
end ConditionalNonpolynomial.Analytic
