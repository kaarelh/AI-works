import NeuralGeneralization.BatchTwoContinuousIteratedLimits
import NeuralGeneralization.BatchTwoContinuousDepthMinimizers

/-! Closed learning and failure endpoints for actual iterated Gaussian
posterior limits, on the existing measurable all-width sample events. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Filter Set
open scoped Topology
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel CompressionSampling BatchTwoSurvivalStatistics

/-- The bounded-teacher generalization event controls every actual iterated
weak limit, whose existence is also proved at every eligible width. -/
theorem bounded_teacher_iterated_limits {d C r K R : ℕ}
    (hd : 1  ≤  d) (hC : 1  ≤  C) (hK : 1  ≤  K) (hR : 1  ≤  R)
    (teacher : Weights d C r) {B : ℝ} (hB : 0  ≤  B) (hw : boundedWeights B teacher)
    (henergy : 2*teacherEnergyBound d C r B  ≤  (K : ℝ))
    (X : Set (RealInput d)) (hX : X.Nonempty) (hcompact : IsCompact X)
    (hball : ∀ x ∈ X, ∑ j, x j^2  ≤  1)
    (D : Measure (RealInput d)) [IsProbabilityMeasure D] (hDX : D Xᶜ = 0)
    {τ ε δ : ℝ} (hτ : 0 < τ) (hε : 0 < ε) (hδ : 0 < δ)
    (haccuracy : 1/(3*(R : ℝ))  ≤  τ/8)
    (n : ℕ) (hsize : (3/ε)*((coverEntropy d r K R : ℝ)+Real.log (1/δ))  ≤  (n : ℝ)) :
    ∃ G : Set (Fin n  →  RealInput d), MeasurableSet G  ∧
      1-δ  ≤  (iidSamples D n).real G  ∧  ∀ s ∈ G, ∀ N : ℕ, C  ≤  N  →
      (∃ Q : ProbabilityMeasure (Weights d N r),
        IsIteratedLimit Real.tanh (output Real.tanh teacher) s Q)  ∧
      (∀ Q : ProbabilityMeasure (Weights d N r),
        IsIteratedLimit Real.tanh (output Real.tanh teacher) s Q  →
        risk Real.tanh D (Q : Measure (Weights d N r)) (output Real.tanh teacher) τ  ≤  ε/3  ∧
        confidenceFailure Real.tanh D (Q : Measure (Weights d N r)) (output Real.tanh teacher) τ  ≤  ε) := by
  obtain ⟨G,hG,hprob,hg⟩ := bounded_teacher_exact_minimizers hd hC hK hR teacher hB hw
    henergy X hX hcompact hball D hDX hτ hε hδ haccuracy n hsize
  refine ⟨G,hG,hprob,?_⟩
  intro s hs N hCN
  have hm := hg s hs N hCN
  have hn : (exactInterpolants (N:=N) (r:=r) Real.tanh (output Real.tanh teacher) s).Nonempty :=
    hm.1.mono fun _ hw => hw.1
  refine ⟨iteratedLimit_exists (by omega) (by omega) tanh_continuous _ _ hn,?_⟩
  intro Q hQ
  exact hm.2.2 (Q : Measure (Weights d N r)) inferInstance
    (iteratedLimit_support_minimizers (by omega) (by omega) tanh_continuous _ _ hn Q hQ)

end NeuralGeneralization.BatchTwoContinuous
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous

/-- A single measurable event of probability at least 49/50 controls every
eligible width and every actual iterated posterior limit. Both regression
risk and failure of the one-half confidence level are at least one-half. -/
theorem iterated_limit_all_width_failure {r n : ℕ}
    (hr : max 6 interpolationDepthThreshold  ≤  r) (hn : 0<n)
    (hnr : (n:ℝ) ≤ Real.exp (((r:ℝ)+2)/100)) :
    ∃ G : Set (Fin n → RealInput 2), MeasurableSet G  ∧
      (49/50:ℝ) ≤ (Measure.pi (fun _ : Fin n => inputLaw)).real G  ∧
      ∀ s∈G, ∀ N : ℕ, interpolationWidth n ≤ N  →
        (∃ Q : ProbabilityMeasure (Weights 2 N (r+1)),
          IsIteratedLimit Real.tanh (depthTarget (r+2)) s Q)  ∧
        (∀ Q : ProbabilityMeasure (Weights 2 N (r+1)),
          IsIteratedLimit Real.tanh (depthTarget (r+2)) s Q  →
          (1/2:ℝ) ≤ risk Real.tanh inputLaw (Q : Measure (Weights 2 N (r+1))) (depthTarget (r+2)) (1/4)  ∧
          (1/2:ℝ) ≤ inputLaw.real {x |
            correctProbability Real.tanh (Q : Measure (Weights 2 N (r+1))) (depthTarget (r+2)) (1/4) x ≤ 1/2}) := by
  obtain ⟨G,hG,hprob,hg⟩ := exact_minimizer_all_width_event hr hn hnr
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

#print axioms iterated_limit_all_width_failure
#print axioms NeuralGeneralization.BatchTwoContinuous.bounded_teacher_iterated_limits
end NeuralGeneralization.BatchTwoContinuousDepthLower
