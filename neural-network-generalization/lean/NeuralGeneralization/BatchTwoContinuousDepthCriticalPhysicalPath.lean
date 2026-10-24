import NeuralGeneralization.BatchTwoContinuousDepthCriticalPhysicalSeed
import NeuralGeneralization.BatchTwoContinuousDepthCriticalProductPrefix
import NeuralGeneralization.BatchTwoContinuousDepthCriticalPhaseTracking

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel BatchTwoActivation NetworkLayerSplit TowerNetwork

variable {d N n : ℕ}

def phaseFree (H : ℕ) (k : ℕ) : Bool := decide (k<H)
def phaseGain (H m : ℕ) (k : ℕ) : ℝ := if k<H then 0 else
  if k<H+m then robustAmplificationGain else saturationGain

def phaseStep (H m : ℕ) (s : Fin n→BatchTwoContinuous.RealInput d) (ε : ℝ)
    (k : ℕ) : Set (Weights d N (k+1)) :=
  if k<H then freePhysicalStep (phaseFree H) s ε k else
    controlledPhysicalStep (phaseFree H) s (phaseGain H m k) ε k

def phasePrefix (H m : ℕ) (s : Fin n→BatchTwoContinuous.RealInput 2)
    (labels : Fin n→Bool) (g ε : ℝ) (r : ℕ) : Set (Weights 2 N r) :=
  certifiedPrefix (physicalSeedEvent (phaseFree H) s labels g) (phaseStep H m s ε) r

theorem measurableSet_phaseStep (H m : ℕ) (s : Fin n→BatchTwoContinuous.RealInput d)
    (ε : ℝ) (k : ℕ) : MeasurableSet (phaseStep (N:=N) H m s ε k) := by
  unfold phaseStep
  split_ifs
  · exact measurableSet_freePhysicalStep _ _ _ _
  · exact measurableSet_controlledPhysicalStep _ _ _ _ _

theorem measurableSet_phasePrefix (H m : ℕ) (s : Fin n→BatchTwoContinuous.RealInput 2)
    (labels : Fin n→Bool) (g ε : ℝ) (r : ℕ) : MeasurableSet (phasePrefix (N:=N) H m s labels g ε r) :=
  certifiedPrefix_measurable _ _ (measurableSet_physicalSeedEvent _ _ _ _) (measurableSet_phaseStep _ _ _ _) r

theorem phaseStep_unit {H m k : ℕ} {s : Fin n→BatchTwoContinuous.RealInput d} {ε : ℝ}
    {w : Weights d N (k+1)} (hw : w∈phaseStep H m s ε k) : unitChannel (phaseFree H) w := by
  unfold phaseStep at hw
  split_ifs at hw <;> exact hw.1

theorem phasePrefix_unit {H m r : ℕ} {s : Fin n→BatchTwoContinuous.RealInput 2}
    {labels : Fin n→Bool} {g ε : ℝ} {w : Weights 2 N r}
    (hw : w∈phasePrefix H m s labels g ε r) : unitChannel (phaseFree H) w := by
  cases r with
  | zero=>exact hw.1
  | succ r=>exact phaseStep_unit hw.2

theorem half_exp_shift (x : ℝ) : Real.exp (x-5)≤(1:ℝ)/2*Real.exp (x-4) := by
  have h2 : (2:ℝ)≤Real.exp 1 := by linarith [Real.add_one_le_exp (1:ℝ)]
  have hh := mul_le_mul_of_nonneg_left h2 (Real.exp_pos (x-5)).le
  rw [←Real.exp_add] at hh
  have he : x-5+1=x-4 := by ring
  rw [he] at hh
  linarith

theorem phasePrefix_probability (hn : 0<n) (H m r : ℕ)
    (s : Fin n→BatchTwoContinuous.RealInput 2) {δ ε : ℝ}
    (hδ : 0<δ) (hδ1 : δ≤1) (hε : 0<ε) (hε4 : ε≤4)
    (hx : ∀i,∑j,s i j^2≤1) (hx0 : ∀i,|s i 0|≤1)
    (hsep : ∀i j,i≠j→δ≤|s i 0-s j 0|) (labels : Fin n→Bool)
    (hN : 2*(Fintype.card (Fin n×Bool)*seedDilution n δ)≤N)
    (hseed : 4*(n:ℝ)≤(N:ℝ)*(dilutedSeedGain n δ)^2)
    (hfree : 4*(64+2*(n:ℝ))≤(N:ℝ)*(ε/8)^2)
    (hcontrol : 4*(n:ℝ)≤(N:ℝ)*ε^2) :
    Real.exp (-(N:ℝ)*(2+2*∑k∈Finset.range r,(phaseGain H m k)^2)-5*((r:ℝ)+1))≤
      (smallPrior 2 N r (1/Real.sqrt (N:ℝ))).real
        (phasePrefix H m s labels (dilutedSeedGain n δ) ε r) := by
  have hNp : 0<N := by
    have hm : 0<Fintype.card (Fin n×Bool) := by simp;omega
    have hp := seedDilution_pos n δ
    nlinarith [Nat.mul_pos hm hp]
  let A := phasePrefix (N:=N) H m s labels (dilutedSeedGain n δ) ε
  let p := fun k=>Real.exp (-2*(N:ℝ)*(phaseGain H m k)^2-5)
  have hmass := smallPrior_event_chain_lower (1/Real.sqrt (N:ℝ)) A
    (measurableSet_phasePrefix H m s labels _ ε) p (fun _=>(Real.exp_pos _).le)
    (a:=Real.exp (-2*(N:ℝ)-5)) (Real.exp_pos _).le
    ((half_exp_shift (-2*(N:ℝ))).trans
      (physical_seed_probability hn s hδ hδ1 hx hx0 hsep labels (phaseFree H) hN hseed))
    (by
      intro k w hw
      have hunit := phasePrefix_unit hw
      have hprev (a : Fin N×Fin N→ℝ) : previousWeights (appendLayer w (fun i j=>a (i,j)))=w :=
        previousWeights_appendLayer _ _
      have ht : p k≤(activationMatrixPrior N (1/Real.sqrt (N:ℝ))).real
          {a | appendLayer w (fun i j=>a (i,j))∈phaseStep H m s ε k} := by
        by_cases hk : k<H
        · have hp : p k≤3/4 := by
            change Real.exp (-2*(N:ℝ)*(phaseGain H m k)^2-5)≤3/4
            rw [phaseGain,if_pos hk]
            norm_num
            have he : Real.exp (-5:ℝ)≤1/6 := by
              rw [Real.exp_neg]
              rw [←one_div]
              apply one_div_le_one_div_of_le (by norm_num)
              linarith [Real.add_one_le_exp (5:ℝ)]
            linarith
          apply hp.trans
          simpa only [phaseStep,if_pos hk] using
            freePhysicalStep_probability hNp (phaseFree H) (by simp [phaseFree,hk]) s w hunit hε hε4 hfree
        · apply (half_exp_shift (-2*(N:ℝ)*(phaseGain H m k)^2)).trans
          simpa only [phaseStep,if_neg hk] using
            controlledPhysicalStep_probability hNp (phaseFree H) (by simp [phaseFree,hk]) s w hunit
              (phaseGain H m k) hε hcontrol
      apply ht.trans
      apply measureReal_mono _ (measure_ne_top _ _)
      intro a ha
      exact ⟨by simpa only [hprev,A,phasePrefix] using hw,ha⟩) r
  have heq : Real.exp (-2*(N:ℝ)-5)*(∏k∈Finset.range r,p k)=
      Real.exp (-(N:ℝ)*(2+2*∑k∈Finset.range r,(phaseGain H m k)^2)-5*((r:ℝ)+1)) := by
    rw [←Real.exp_sum,←Real.exp_add]
    congr 1
    simp only [p,Finset.sum_sub_distrib,Finset.sum_const,Finset.card_range,nsmul_eq_mul,
      ←Finset.mul_sum]
    ring
  rwa [heq] at hmass

end NeuralGeneralization.BatchTwoContinuousDepthCritical
