import NeuralGeneralization.BatchTwoImprovedLearningWidthGrowth
import NeuralGeneralization.BatchTwoImprovedGlobalScales

/-! The same fixed-depth width exponent with additional global-margin conditioning. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoImprovedGlobalLearning
open ConcreteModel BatchTwoImprovedGlobalPosterior RobustConfidence RobustStatistics
open BatchTwoImprovedLearning
set_option maxHeartbeats 600000
set_option backward.isDefEq.respectTransparency false

/-- An explicit all-width learning theorem.  The constant depends on fixed input
dimension, depth, support radius and desired accuracy, but not on circuit width,
learner width, prior strength, failure probability or input distribution. -/
theorem all_width_six_thirteen_learning {d r:ℕ} (hd:0<d) {c ε:ℝ}
    (hc:0<c) (hε:0<ε) (hε1:ε≤1):
    ∃A:ℝ,0<A ∧ ∀C:ℕ,0<C→∀B:LayeredBooleanCircuit d C r,
      ∀δ:ℝ,0<δ→∀D:Measure (Cube d),IsProbabilityMeasure D→∀n:ℕ,0<n→
      A*(C:ℝ)^6*(1+Real.log C)^13+200*Real.log (1/δ)≤(n:ℝ)*ε→
      ∃E:Set (Fin n→Cube d),MeasurableSet E ∧
        1-δ≤(CompressionSampling.iidSamples D n).real E ∧
        ∀sample∈E,∀N,C≤N→∀σ,0<σ→(N:ℝ)*σ^2≤1→
          0<(smallPrior d N r σ).real
            (robustPosteriorEvent Real.tanh c B.computes sample) ∧
          gibbsMarginRisk D
            (robustPosterior (N:=N) (r:=r) Real.tanh c σ B.computes sample)
            (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4)≤ε/3 ∧
          D.real {x|correctConfidence
            (robustPosterior (N:=N) (r:=r) Real.tanh c σ B.computes sample)
            (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) x≤(2/3:ℝ)}≤ε := by
  obtain ⟨a,ha,hbound⟩:=entropy_width_growth d r hc hε hε1
  refine ⟨200*a,by positivity,?_⟩
  intro C hC B δ hδ D hD n hn hbudget
  letI:IsProbabilityMeasure D:=hD
  apply learning_scaled_variance hd hC B hc hε hε1 hδ D n hn
  have hh:entropy d C r c ε≤a*(C:ℝ)^6*(1+Real.log C)^13:=
    (le_abs_self _).trans (hbound C (by omega))
  nlinarith only [hh,hbudget]

end NeuralGeneralization.BatchTwoImprovedGlobalLearning
