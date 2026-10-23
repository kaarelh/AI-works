import NeuralGeneralization.BatchTwoImprovedLearningPolynomial
import NeuralGeneralization.BatchTwoImprovedGlobalScales

/-! The same universal degree-46 bound with additional global margin conditioning. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoImprovedGlobalLearning
open ConcreteModel BatchTwoImprovedGlobalPosterior RobustConfidence BatchTwoImprovedLearning

theorem universal_polynomial_depth_learning:
    ∃A:ℝ,0<A ∧ ∀(d C r:ℕ),0<d→0<C→∀B:LayeredBooleanCircuit d C r,
      ∀c ε δ:ℝ,0<c→0<ε→ε≤1→0<δ→δ≤1→
      ∀D:Measure (Cube d),IsProbabilityMeasure D→∀n:ℕ,
      A*(problemSize d C r c ε δ)^46≤(n:ℝ)→
      ∃E:Set (Fin n→Cube d),MeasurableSet E ∧
        1-δ≤(CompressionSampling.iidSamples D n).real E ∧
        ∀sample∈E,∀N,C≤N→∀σ,0<σ→(N:ℝ)*σ^2≤1→
          0<(smallPrior d N r σ).real (robustPosteriorEvent Real.tanh c B.computes sample) ∧
          gibbsMarginRisk D (robustPosterior (N:=N) (r:=r) Real.tanh c σ B.computes sample)
            (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4)≤ε/3 ∧
          D.real {x|correctConfidence (robustPosterior (N:=N) (r:=r) Real.tanh c σ B.computes sample)
            (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) x≤(2/3:ℝ)}≤ε := by
  obtain ⟨A,hA,hbudget⟩:=BatchTwoImprovedLearning.universal_sample_budget
  refine ⟨A,hA,?_⟩
  intro d C r hd hC B c ε δ hc hε hε1 hδ hδ1 D hD n hn
  letI:IsProbabilityMeasure D:=hD
  obtain ⟨hn0,hb⟩:=hbudget d C r hC c ε δ hc hε hε1 hδ hδ1 n hn
  exact BatchTwoImprovedGlobalLearning.learning_scaled_variance hd hC B hc hε hε1 hδ D n hn0 hb

end NeuralGeneralization.BatchTwoImprovedGlobalLearning
