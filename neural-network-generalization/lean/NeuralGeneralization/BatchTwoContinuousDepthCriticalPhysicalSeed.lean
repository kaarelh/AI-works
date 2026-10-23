import NeuralGeneralization.BatchTwoContinuousDepthCriticalProductTransitions
import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlSeedMain

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel BatchTwoActivation RobustCompressionBlockMoments BatchTwoContinuous.PairMoments

variable {N n : ℕ}

theorem critical_first_row (hN : 0<N) (w : Weights 2 N 0)
    (x : BatchTwoContinuous.RealInput 2) (i : Fin N) :
    rowLinear (firstRowCoefficient x) (activationInputRows (1/Real.sqrt (N:ℝ)) w i)=
      ∑j,w (.inl (i,j))*BatchTwoContinuous.augmentedInput x j := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  have hs : Real.sqrt (N:ℝ)≠0 := (Real.sqrt_pos.mpr hn).ne'
  have h2 : Real.sqrt (2:ℝ)≠0 := by positivity
  unfold rowLinear firstRowCoefficient activationInputRows standardizedWeights whiten coordinateScale
  simp only [smallVariance,one_pow,mul_one,Real.sqrt_div (by positivity : (0:ℝ)≤N)]
  apply Finset.sum_congr rfl
  intro j _
  field_simp
  norm_num <;> ring

def physicalSeedEvent (free : ℕ→Bool) (s : Fin n→BatchTwoContinuous.RealInput 2)
    (labels : Fin n→Bool) (g : ℝ) : Set (Weights 2 N 0) :=
  {w | unitChannel free w ∧ ∀j,g<labelReal (labels j)*(empiricalMoments free s w).2 j}

theorem measurableSet_physicalSeedEvent (free : ℕ→Bool)
    (s : Fin n→BatchTwoContinuous.RealInput 2) (labels : Fin n→Bool) (g : ℝ) :
    MeasurableSet (physicalSeedEvent (N:=N) free s labels g) := by
  apply (measurableSet_unitChannel free).inter
  change MeasurableSet {w : Weights 2 N 0 | ∀j,g<labelReal (labels j)*(empiricalMoments free s w).2 j}
  simp only [Set.setOf_forall]
  apply MeasurableSet.iInter
  intro j
  exact measurableSet_lt measurable_const
    (measurable_const.mul ((measurable_pi_apply j).comp (measurable_empiricalMoments free s).snd))

theorem physical_seed_probability (hn : 0<n) (s : Fin n→BatchTwoContinuous.RealInput 2)
    {δ : ℝ} (hδ : 0<δ) (hδ1 : δ≤1) (hx : ∀i,∑j,s i j^2≤1)
    (hx0 : ∀i,|s i 0|≤1) (hsep : ∀i j,i≠j→δ≤|s i 0-s j 0|)
    (labels : Fin n→Bool) (free : ℕ→Bool)
    (hN : 2*(Fintype.card (Fin n×Bool)*seedDilution n δ)≤N)
    (hbudget : 4*(n:ℝ)≤(N:ℝ)*(dilutedSeedGain n δ)^2) :
    (1:ℝ)/2*Real.exp (-2*(N:ℝ)-4)≤
      (smallPrior 2 N 0 (1/Real.sqrt (N:ℝ))).real
        (physicalSeedEvent free s labels (dilutedSeedGain n δ)) := by
  have hNp : 0<N := by
    have hm : 0<Fintype.card (Fin n×Bool) := by simp;omega
    have hp := seedDilution_pos n δ
    nlinarith [Nat.mul_pos hm hp]
  let E : Set (Fin N→Fin 3→ℝ) := {w | ∀i,dilutedSeedGain n δ<labelReal (labels i)*
    rowAverage (fun z=>Real.tanh (rowLinear (firstRowCoefficient (s i)) z)) w}
  have hE : MeasurableSet E := by
    simp only [E,Set.setOf_forall]
    apply MeasurableSet.iInter
    intro i
    exact measurableSet_lt measurable_const (by unfold rowAverage rowLinear;fun_prop)
  have hh := diluted_seed_probability hn hδ hδ1 s hx hx0 hsep labels hN hbudget
  change (1:ℝ)/2*Real.exp (-2*(N:ℝ)-4)≤(Measure.pi fun _ : Fin N=>Measure.pi fun _ : Fin 3=>gaussianReal 0 1).real E at hh
  have hl := activationInputRows_law (r:=0) (by omega : 0<2) hNp
    (show 0<1/Real.sqrt (N:ℝ) by positivity)
  change (smallPrior 2 N 0 (1/Real.sqrt (N:ℝ))).map (activationInputRows (1/Real.sqrt (N:ℝ)))=
    (Measure.pi fun _ : Fin N=>Measure.pi fun _ : Fin 3=>gaussianReal 0 1) at hl
  rw [←hl,map_measureReal_apply (measurable_activationInputRows _) hE] at hh
  apply hh.trans
  apply measureReal_mono _ (measure_ne_top _ _)
  intro w hw
  refine ⟨initial_auxiliary_unit hNp free w,?_⟩
  intro j
  have he := hw j
  simpa only [rowAverage,critical_first_row hNp,empiricalMoments,empiricalPairing,
    auxiliaryChannel,one_mul,BatchTwoContinuous.finalHidden,BatchTwoContinuous.firstHidden,List.finRange_zero,List.foldl_nil] using he

end NeuralGeneralization.BatchTwoContinuousDepthCritical
