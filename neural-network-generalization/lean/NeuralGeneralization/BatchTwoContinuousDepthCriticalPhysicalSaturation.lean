import NeuralGeneralization.BatchTwoContinuousDepthCriticalPhysicalPath

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel NetworkLayerSplit TowerNetwork

variable {n P H h : ℕ}

theorem phase_physical_saturates (hn : 0<n) (hP : 0<P) (hH : H≤h)
    (labels : Fin n→Bool) :
    ∃ε : ℝ,0<ε ∧ ε≤4 ∧ ∀N : ℕ,0<N→∀s : Fin n→BatchTwoContinuous.RealInput 2,
      ∀w : Weights 2 N (H+amplificationCount (retainedSignal n P h)+1),
      w∈phasePrefix H (amplificationCount (retainedSignal n P h)) s labels (seedSignal n P) ε
        (H+amplificationCount (retainedSignal n P h)+1) →
      ∀i,|(empiricalMoments (phaseFree H) s w).2 i-labelReal (labels i)|<1/50 := by
  obtain ⟨ε₀,hε₀,hphase⟩ := phase_sequence_saturates hn hP hH labels
  let ε := min ε₀ 1
  have hε : 0<ε := lt_min hε₀ (by norm_num)
  have hεle : ε≤ε₀ := min_le_left _ _
  have hε1 : ε≤1 := min_le_right _ _
  refine ⟨ε,hε,by linarith,?_⟩
  intro N hN s w hw
  let m := amplificationCount (retainedSignal n P h)
  let r := H+m+1
  let path := fun k=>empiricalMoments (phaseFree H) s (networkPrefix w k)
  let c := fun k i=>featureCoefficient (networkPrefix w (H+k)) (s i)
  have hprefix (k : ℕ) (hk : k≤r) :
      networkPrefix w k∈phasePrefix H m s labels (seedSignal n P) ε k :=
    certifiedPrefix_prefix _ _ w hw hk
  have hunit (k : ℕ) (hk : k≤r) : unitChannel (phaseFree H) (networkPrefix w k) :=
    phasePrefix_unit (hprefix k hk)
  have hs (k : ℕ) (hk : k≤H) : path k∈momentBox (Fin n) :=
    empiricalMoments_mem hN _ s _ (hunit k (by dsimp [r];omega))
  have hseed : ∀i,seedSignal n P≤labelReal (labels i)*(path 0).2 i := by
    have hh := certifiedPrefix_seed _ _ w hw
    exact fun i=>(hh.2 i).le
  have hstep (k : ℕ) (hk : k<H) : dist (path (k+1)) (freeMomentMap (path k))<ε₀ := by
    have ht := certifiedPrefix_step _ _ w hw (show k<r by dsimp [r];omega)
    change networkPrefix w (k+1)∈phaseStep H m s ε k at ht
    rw [phaseStep,if_pos hk] at ht
    have hh := ht.2
    rw [networkPrefix_previous_succ w (show k<r by dsimp [r];omega)] at hh
    exact hh.trans_le hεle
  have hc (k : ℕ) (_ : k≤m) (i : Fin n) : ∑j,c k i j^2≤1 := by
    rw [show (∑j,c k i j^2)=empiricalSecond (networkPrefix w (H+k)) (s i) from featureCoefficient_energy _ _]
    exact (empiricalSecond_bounds hN _ _).2
  have hamp (k : ℕ) (hk : k<m) (i : Fin n) :
      |(path (H+k+1)).2 i-gaussianRowMean (c k i)
        (robustAmplificationGain*(path (H+k)).2 i)|<ε₀ := by
    have ht := certifiedPrefix_step _ _ w hw (show H+k<r by dsimp [r];omega)
    change networkPrefix w (H+k+1)∈phaseStep H m s ε (H+k) at ht
    rw [phaseStep,if_neg (by omega : ¬H+k<H)] at ht
    have hh := ht.2 i
    rw [networkPrefix_previous_succ w (show H+k<r by dsimp [r];omega)] at hh
    simp only [phaseGain,if_neg (by omega : ¬H+k<H),if_pos (by omega : H+k<H+m)] at hh
    rw [gaussianRowMean_eq_shiftedMean,featureCoefficient_energy]
    exact hh.trans_le hεle
  have hsat (i : Fin n) :
      |(path (H+m+1)).2 i-gaussianRowMean (c m i)
        (saturationGain*(path (H+m)).2 i)|<ε₀ := by
    have ht := certifiedPrefix_step _ _ w hw (show H+m<r by dsimp [r];omega)
    change networkPrefix w (H+m+1)∈phaseStep H m s ε (H+m) at ht
    rw [phaseStep,if_neg (by omega : ¬H+m<H)] at ht
    have hh := ht.2 i
    rw [networkPrefix_previous_succ w (show H+m<r by dsimp [r];omega)] at hh
    simp only [phaseGain,if_neg (by omega : ¬H+m<H),if_neg (by omega : ¬H+m<H+m)] at hh
    rw [gaussianRowMean_eq_shiftedMean,featureCoefficient_energy]
    exact hh.trans_le hεle
  have hh := hphase path c hs hseed hstep hc hamp hsat
  simpa only [path,m,networkPrefix_self] using hh

end NeuralGeneralization.BatchTwoContinuousDepthCritical
