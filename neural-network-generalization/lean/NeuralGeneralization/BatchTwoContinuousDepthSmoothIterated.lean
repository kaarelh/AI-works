import NeuralGeneralization.BatchTwoContinuousIteratedMain
import NeuralGeneralization.BatchTwoContinuousDepthSmoothMinimizers

/-! Actual iterated posterior limits for the smooth circle law: existence
and failure at every allowed width on one measurable sample event. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Filter Set
open scoped Topology
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous

/-- A single measurable event of probability at least 49/50 controls every
eligible width and every actual iterated posterior limit. Both regression
risk and failure of the one-half confidence level are at least one-half. -/
theorem smooth_iterated_limit_all_width_failure {r n : ℕ}
    (hr : max 6 interpolationDepthThreshold  ≤  r) (hn : 0<n)
    (hnr : (n:ℝ) ≤ Real.exp (((r:ℝ)+2)/100)) :
    ∃ G : Set (Fin n → RealInput 2), MeasurableSet G  ∧
      (49/50:ℝ) ≤ (Measure.pi (fun _ : Fin n => (smoothInputLaw (r+2)))).real G  ∧
      ∀ s∈G, ∀ N : ℕ, interpolationWidth n ≤ N  →
        (∃ Q : ProbabilityMeasure (Weights 2 N (r+1)),
          IsIteratedLimit Real.tanh (depthTarget (r+2)) s Q)  ∧
        (∀ Q : ProbabilityMeasure (Weights 2 N (r+1)),
          IsIteratedLimit Real.tanh (depthTarget (r+2)) s Q  →
          (1/2:ℝ) ≤ risk Real.tanh (smoothInputLaw (r+2)) (Q : Measure (Weights 2 N (r+1))) (depthTarget (r+2)) (1/4)  ∧
          (1/2:ℝ) ≤ (smoothInputLaw (r+2)).real {x |
            correctProbability Real.tanh (Q : Measure (Weights 2 N (r+1))) (depthTarget (r+2)) (1/4) x ≤ 1/2}) := by
  obtain ⟨G,hG,hprob,hg⟩ := smooth_exact_minimizer_all_width_event hr hn hnr
  refine ⟨G,hG,hprob,?_⟩
  intro s hs N hN
  have hNpos : 0<N := by have := (interpolationWidth_ge hn).1; omega
  have hm := hg s hs N hN
  have hne : (exactInterpolants (N:=N) (r:=r+1) Real.tanh (depthTarget (r+2)) s).Nonempty :=
    hm.1.mono fun _ hw => hw.1
  refine ⟨iteratedLimit_exists (by norm_num) hNpos tanh_continuous _ _ hne,?_⟩
  intro Q hQ
  exact hm.2 (Q : Measure (Weights 2 N (r+1))) inferInstance
    (iteratedLimit_support_minimizers (by norm_num) hNpos tanh_continuous _ _ hne Q hQ)

#print axioms smooth_iterated_limit_all_width_failure
end NeuralGeneralization.BatchTwoContinuousDepthLower
