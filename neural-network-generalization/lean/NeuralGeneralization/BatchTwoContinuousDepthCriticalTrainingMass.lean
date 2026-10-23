import NeuralGeneralization.BatchTwoContinuousDepthCriticalPhysicalSaturation
import NeuralGeneralization.BatchTwoContinuousDepthCriticalReadoutMass
import NeuralGeneralization.BatchTwoContinuousDepthCriticalTeacherBounds

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1800000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel NetworkLayerSplit TowerNetwork BatchTwoContinuous.PairMoments BatchTwoContinuousDepthLower

theorem phaseGain_squared_sum (H m : ℕ) :
    (∑k∈Finset.range (H+m+1),(phaseGain H m k)^2)=
      (m:ℝ)*robustAmplificationGain^2+saturationGain^2 := by
  rw [Finset.sum_range_succ,Finset.sum_range_add]
  have hzero : (∑k∈Finset.range H,(phaseGain H m k)^2)=0 := by
    apply Finset.sum_eq_zero
    intro k hk
    simp [phaseGain,Finset.mem_range.mp hk]
  have hblock : (∑k∈Finset.range m,(phaseGain H m (H+k))^2)=(m:ℝ)*robustAmplificationGain^2 := by
    calc
      _ = ∑_k∈Finset.range m,robustAmplificationGain^2 := by
        apply Finset.sum_congr rfl
        intro k hk
        have hk' := Finset.mem_range.mp hk
        simp [phaseGain,show ¬H+k<H by omega,show H+k<H+m by omega]
      _ = _ := by simp
  rw [hzero,hblock]
  simp [phaseGain,show ¬H+m<H by omega]

/-- Direct finite-width training mass for the complete physical path. -/
theorem critical_training_mass_of_schedule {n P H h : ℕ}
    (hn : 0<n) (hP : 0<P) (hH : H≤h)
    (s : Fin n→BatchTwoContinuous.RealInput 2) (labels : Fin n→Bool)
    (htarget : ∀i,|depthTarget h (s i)-(3/5)*labelReal (labels i)|≤1/10) :
    ∃ε : ℝ,0<ε ∧ ε≤4 ∧ ∀N : ℕ,
      2*(Fintype.card (Fin n×Bool)*P)≤N→
      P=seedDilution n (sampleSeparation n)→
      (∀i,∑j,s i j^2≤1)→(∀i,|s i 0|≤1)→
      (∀i j,i≠j→sampleSeparation n≤|s i 0-s j 0|)→
      4*(n:ℝ)≤(N:ℝ)*(seedSignal n P)^2→
      4*(64+2*(n:ℝ))≤(N:ℝ)*(ε/8)^2→
      4*(n:ℝ)≤(N:ℝ)*ε^2→
      2*(n:ℝ)*Real.exp (-(N:ℝ)*(1/200:ℝ)^2/2)≤1/4→
      Real.exp (-(N:ℝ)*(2+2*(amplificationCount (retainedSignal n P h):ℝ)*robustAmplificationGain^2+
        2*saturationGain^2+2*(3/5:ℝ)^2)-5*((H+amplificationCount (retainedSignal n P h)+1:ℕ):ℝ)-10)≤
      (smallPrior 2 N (H+amplificationCount (retainedSignal n P h)+1) (1/Real.sqrt (N:ℝ))).real
        (BatchTwoContinuous.trainingEvent Real.tanh (depthTarget h) (1/8) s) := by
  obtain ⟨ε,hε,hε4,hsat⟩ := phase_physical_saturates hn hP hH labels
  refine ⟨ε,hε,hε4,?_⟩
  intro N hN heq hx hx0 hsep hseed hfree hcontrol hread
  subst P
  let P := seedDilution n (sampleSeparation n)
  let m := amplificationCount (retainedSignal n P h)
  let r := H+m+1
  have hNp : 0<N := by
    have hm : 0<Fintype.card (Fin n×Bool) := by simp;omega
    have hp := seedDilution_pos n (sampleSeparation n)
    nlinarith [Nat.mul_pos hm hp]
  have hseed' : 4*(n:ℝ)≤(N:ℝ)*(dilutedSeedGain n (sampleSeparation n))^2 := hseed
  have hp := phasePrefix_probability hn H m r s (sampleSeparation_pos hn)
    ((sampleSeparation_le hn).trans (by norm_num)) hε hε4 hx hx0 hsep labels hN hseed' hfree hcontrol
  rw [phaseGain_squared_sum H m] at hp
  let A := phasePrefix (N:=N) H m s labels (seedSignal n P) ε r
  have hmass := smallPrior_readout_event_lower (1/Real.sqrt (N:ℝ)) A
    (BatchTwoContinuous.trainingEvent Real.tanh (depthTarget h) (1/8) s)
    (measurableSet_phasePrefix _ _ _ _ _ _ _) (BatchTwoContinuous.isOpen_trainingEvent tanh_continuous _ _ _).measurableSet
    (p:=Real.exp (-2*(N:ℝ)*(3/5:ℝ)^2-5)) (Real.exp_pos _).le (by
      intro w hw
      have ht := phasePrefix_unit hw
      have hs := hsat N hNp s w hw
      have hh := critical_physical_readout_probability hNp w s (auxiliaryChannel (phaseFree H) r w)
        ht (3/5) (by norm_num : (0:ℝ)<1/200) hread
      apply (half_exp_shift (-2*(N:ℝ)*(3/5:ℝ)^2)).trans (hh.trans _)
      apply measureReal_mono _ (measure_ne_top _ _)
      intro v hv i
      exact final_regression_error (labels i) (htarget i) (hs i) (hv i))
  have hh := (mul_le_mul_of_nonneg_right hp (Real.exp_pos (-2*(N:ℝ)*(3/5:ℝ)^2-5)).le).trans hmass
  rw [←Real.exp_add] at hh
  convert hh using 1
  congr 1
  dsimp [r,m,P]
  push_cast
  congr 1 <;> ring

end NeuralGeneralization.BatchTwoContinuousDepthCritical
