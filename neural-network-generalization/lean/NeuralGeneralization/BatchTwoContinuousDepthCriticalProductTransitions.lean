import NeuralGeneralization.BatchTwoContinuousDepthCriticalProductStateBoundsFree
import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlMean
import NeuralGeneralization.BatchTwoActivationFullNetworkEventsLaw

/-! Uniform transition probabilities for measurable events of the actual
critical physical network. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel NetworkLayerSplit TowerNetwork BatchTwoContinuous.PairMoments BatchTwoActivation
variable {d N r n : ℕ}

def unitChannel (free : ℕ→Bool) (w : Weights d N r) : Prop :=
  (∑i,(auxiliaryChannel free r w i)^2)/(N : ℝ)=1

def freePhysicalStep (free : ℕ→Bool) (s : Fin n→BatchTwoContinuous.RealInput d)
    (ε : ℝ) (r : ℕ) : Set (Weights d N (r+1)) :=
  {w | unitChannel free w ∧ dist (empiricalMoments free s w)
    (freeMomentMap (empiricalMoments free s (previousWeights w)))<ε}

def controlledPhysicalStep (free : ℕ→Bool) (s : Fin n→BatchTwoContinuous.RealInput d)
    (a ε : ℝ) (r : ℕ) : Set (Weights d N (r+1)) :=
  {w | unitChannel free w ∧ ∀j,|(empiricalMoments free s w).2 j-
    shiftedMean ((empiricalMoments free s (previousWeights w)).1 j)
      (a*(empiricalMoments free s (previousWeights w)).2 j)|<ε}

theorem measurableSet_unitChannel (free : ℕ→Bool) :
    MeasurableSet {w : Weights d N r | unitChannel free w} := by
  unfold unitChannel
  apply MeasurableSet.preimage (measurableSet_singleton (1:ℝ))
  change Measurable (fun w : Weights d N r => (∑i,(auxiliaryChannel free r w i)^2)/(N:ℝ))
  apply Measurable.div_const
  exact Finset.measurable_sum _ (fun i _=>((measurable_pi_apply i).comp
    (measurable_auxiliaryChannel free r)).pow_const 2)

theorem measurableSet_freePhysicalStep (free : ℕ→Bool)
    (s : Fin n→BatchTwoContinuous.RealInput d) (ε : ℝ) (r : ℕ) :
    MeasurableSet (freePhysicalStep (N := N) free s ε r) := by
  apply (measurableSet_unitChannel free).inter
  change MeasurableSet {w : Weights d N (r+1) | dist (empiricalMoments free s w) (freeMomentMap (empiricalMoments free s (previousWeights w)))<ε}
  apply measurableSet_lt _ measurable_const
  exact (measurable_empiricalMoments free s).dist
    (freeMomentMap_continuous.measurable.comp ((measurable_empiricalMoments free s).comp
      continuous_previousWeights.measurable))

theorem measurableSet_controlledPhysicalStep (free : ℕ→Bool)
    (s : Fin n→BatchTwoContinuous.RealInput d) (a ε : ℝ) (r : ℕ) :
    MeasurableSet (controlledPhysicalStep (N := N) free s a ε r) := by
  apply (measurableSet_unitChannel free).inter
  change MeasurableSet {w : Weights d N (r+1) | ∀j, |(empiricalMoments free s w).2 j-shiftedMean ((empiricalMoments free s (previousWeights w)).1 j) (a*(empiricalMoments free s (previousWeights w)).2 j)|<ε}
  simp only [Set.setOf_forall]
  apply MeasurableSet.iInter
  intro j
  have hm:=measurable_empiricalMoments (N := N) (r := r) free s
  have hp:=hm.comp continuous_previousWeights.measurable
  apply measurableSet_lt _ measurable_const
  exact (((measurable_pi_apply j).comp (measurable_empiricalMoments free s).snd).sub
    (shiftedMean_continuous.measurable.comp
      (((measurable_pi_apply j).comp hp.fst).prodMk
        (measurable_const.mul ((measurable_pi_apply j).comp hp.snd))))).abs

theorem criticalMatrixRows_event (hN : 0<N) (E : Set (Fin N→Fin N→ℝ))
    (hE : MeasurableSet E) :
    (activationMatrixPrior N (1/Real.sqrt (N : ℝ))).real
      {a | (fun i j=>Real.sqrt (N : ℝ)*a (i,j))∈E}=
      (Measure.pi fun _ : Fin N=>Measure.pi fun _ : Fin N=>gaussianReal 0 1).real E := by
  have hn : (0 : ℝ)<N := by exact_mod_cast hN
  have hs : 0<1/Real.sqrt (N : ℝ) := by positivity
  have hh:=activationMatrixRows_law (N := N) hs
  have he : activationMatrixRows (1/Real.sqrt (N : ℝ))=
      fun a : Fin N×Fin N→ℝ=>fun i j=>Real.sqrt (N : ℝ)*a (i,j) := by
    funext a i j
    simp only [activationMatrixRows,div_div_eq_mul_div,mul_comm,div_one]
  rw [he] at hh
  change (activationMatrixPrior N (1/Real.sqrt (N:ℝ))).map (fun a i j=>Real.sqrt (N:ℝ)*a (i,j))= (Measure.pi fun _ : Fin N=>Measure.pi fun _ : Fin N=>gaussianReal 0 1) at hh
  rw [←hh,map_measureReal_apply (by fun_prop) hE]
  rfl

theorem freePhysicalStep_probability (hN : 0<N) (free : ℕ→Bool) (hf : free r=true)
    (s : Fin n→BatchTwoContinuous.RealInput d) (w : Weights d N r)
    (ht : unitChannel free w) {ε : ℝ} (hε : 0<ε) (hε4 : ε≤4)
    (hbudget : 4*(64+2*(n : ℝ))≤(N : ℝ)*(ε/8)^2) :
    (3 : ℝ)/4≤(activationMatrixPrior N (1/Real.sqrt (N : ℝ))).real
      {a | appendLayer w (fun i j=>a (i,j))∈freePhysicalStep free s ε r} := by
  let E:=freeRowEvent (fun j=>featureCoefficient w (s j))
    (channelCoefficient (auxiliaryChannel free r w)) (ε/8) N
  have hE:=measurableSet_freeRowEvent (fun j=>featureCoefficient w (s j))
    (channelCoefficient (auxiliaryChannel free r w)) (ε/8) N
  have hh:=freeRowEvent_probability (fun j=>featureCoefficient w (s j))
    (channelCoefficient (auxiliaryChannel free r w))
    (by rw [channelCoefficient_energy];exact ht) (show 0<ε/8 by positivity) hN
    (by simpa only [Fintype.card_fin] using hbudget)
  rw [←criticalMatrixRows_event hN E hE] at hh
  apply hh.trans
  apply measureReal_mono _ (measure_ne_top _ _)
  intro a ha
  obtain ⟨hu,hd⟩:=free_empirical_step hN free hf s w ht a (show 0<ε/8 by positivity)
    (by linarith : ε/8≤1/2) ha
  refine ⟨hu,?_⟩
  simp only [previousWeights_appendLayer]
  exact hd.trans (by linarith)

theorem controlledPhysicalStep_probability (hN : 0<N) (free : ℕ→Bool) (hf : free r=false)
    (s : Fin n→BatchTwoContinuous.RealInput d) (w : Weights d N r)
    (ht : unitChannel free w) (a : ℝ) {ε : ℝ} (hε : 0<ε)
    (hbudget : 4*(n : ℝ)≤(N : ℝ)*ε^2) :
    (1 : ℝ)/2*Real.exp (-2*(N : ℝ)*a^2-4)≤
      (activationMatrixPrior N (1/Real.sqrt (N : ℝ))).real
        {b | appendLayer w (fun i j=>b (i,j))∈controlledPhysicalStep free s a ε r} := by
  let E : Set (Fin N→Fin N→ℝ):={b | ∀j,|rowAverage
      (fun z=>Real.tanh (rowLinear (featureCoefficient w (s j)) z)) b-
      gaussianRowMean (featureCoefficient w (s j))
        (a*(∑i,channelCoefficient (auxiliaryChannel free r w) i*featureCoefficient w (s j) i))|<ε}
  have hE : MeasurableSet E := by
    simp only [E,Set.setOf_forall]
    apply MeasurableSet.iInter
    intro j
    apply measurableSet_lt _ measurable_const
    unfold rowAverage rowLinear
    fun_prop
  have hh:=amplification_matrix_probability (fun j=>featureCoefficient w (s j))
    (channelCoefficient (auxiliaryChannel free r w))
    (by rw [channelCoefficient_energy];exact ht) a hε hN
    (by simpa only [Fintype.card_fin] using hbudget)
  rw [←criticalMatrixRows_event hN E hE] at hh
  apply hh.trans
  apply measureReal_mono _ (measure_ne_top _ _)
  intro b hb
  refine ⟨controlled_auxiliary_unit hN free hf w _,?_⟩
  intro j
  have hj:=hb j
  simp only [rowAverage,real_finalHidden_append_standardized hN,coefficient_pairing,
    gaussianRowMean_eq_shiftedMean,featureCoefficient_energy] at hj
  simpa only [empiricalMoments,previousWeights_appendLayer,empiricalPairing,
    auxiliaryChannel_append,hf,Bool.false_eq_true,if_false,one_mul] using hj

end NeuralGeneralization.BatchTwoContinuousDepthCritical
