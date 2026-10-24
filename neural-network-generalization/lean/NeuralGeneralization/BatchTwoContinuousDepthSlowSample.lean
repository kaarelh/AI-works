import NeuralGeneralization.BatchTwoContinuousDepthSlowMemorizer
import NeuralGeneralization.BatchTwoContinuousDepthSharpDecay
import NeuralGeneralization.BatchTwoContinuousDepthStrongMain

/-! A common sample event of probability at least49/50 supports the efficient
interpolator at every admissible finite width. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous

def slowInterpolationSamples (r n : ℕ) : Set (Fin n→RealInput 2) := separatedSample n ∩
  {s | (∀i,|s i 0|≤1) ∧ (∀i,|depthTarget (r+2) (s i)|≤13/20)}

theorem slowInterpolationSamples_measurable (r n : ℕ) : MeasurableSet (slowInterpolationSamples r n) := by
  apply (separatedSample_measurable n).inter
  apply MeasurableSet.inter
  · have hh : MeasurableSet (⋂i : Fin n,{s : Fin n→RealInput 2 | |s i 0|≤1}) :=
      MeasurableSet.iInter (fun i=>measurableSet_le (by fun_prop) measurable_const)
    convert hh using 1
    ext s
    simp only [Set.mem_iInter,Set.mem_setOf_eq]
    rfl
  · have hh : MeasurableSet (⋂i : Fin n,{s : Fin n→RealInput 2 | |depthTarget (r+2) (s i)|≤13/20}) :=
      MeasurableSet.iInter (fun i=>measurableSet_le
        ((continuous_target (r+2)).comp (continuous_apply i)).abs.measurable measurable_const)
    convert hh using 1
    ext s
    simp only [Set.mem_iInter,Set.mem_setOf_eq]
    rfl

theorem slowInterpolationSamples_probability {n : ℕ} (hn : 0<n) (r : ℕ) :
    (49/50:ℝ)≤(Measure.pi (fun _ : Fin n=>inputLaw)).real (slowInterpolationSamples r n) := by
  have he : slowInterpolationSamples r n =ᵐ[Measure.pi (fun _ : Fin n=>inputLaw)] separatedSample n := by
    filter_upwards [iid_sample_bounds (r+2) n] with s hs
    apply propext
    change (s∈separatedSample n ∧ ((∀i,|s i 0|≤1) ∧ (∀i,|depthTarget (r+2) (s i)|≤13/20))) ↔ s∈separatedSample n
    exact and_iff_left hs
  rw [measureReal_congr he]
  exact separatedSample_probability hn

theorem slow_memorizer_on_sample_event {r n N : ℕ} (hr : sharpInterpolationDepthThreshold≤r)
    (hn : 0<n) (hnr : (n:ℝ)≤Real.exp (((r:ℝ)+2)/100)) (hN : interpolationWidth n≤N)
    (s : Fin n→RealInput 2) (hs : s∈slowInterpolationSamples r n) :
    ∃w : Weights 2 N (r+1), (∀i,output Real.tanh w (s i)=depthTarget (r+2) (s i)) ∧
      weightedSquaredNorm w≤(49/25)*(r:ℝ)+5 ∧
      (N:ℝ)*(∑i,(w (Sum.inr (Sum.inr i)))^2)=1 := by
  have hwidth:=interpolationWidth_ge hn
  exact exists_slow_channel_memorizer hn hN hwidth.1 (sampleSeparation_pos hn)
    ((sampleSeparation_le hn).trans (by norm_num)) s (fun i=>depthTarget (r+2) (s i))
    hs.2.1 hs.2.2 hs.1 hwidth.2 (sharp_interpolation_channel_energy_small hn hr hnr)

#print axioms slow_memorizer_on_sample_event
#print axioms slowInterpolationSamples_probability
end NeuralGeneralization.BatchTwoContinuousDepthLower
