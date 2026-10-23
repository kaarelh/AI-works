import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlNormalize
import NeuralGeneralization.BatchTwoContinuousPairMomentsModel

/-! The auxiliary normalized channel and empirical moments are literal
measurable functions of the same physical neural weights. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel NetworkLayerSplit TowerNetwork BatchTwoContinuous.PairMoments

variable {d N r n : ℕ}

def physicalProjection (a : Fin N×Fin N→ℝ) (t : Fin N→ℝ) (i : Fin N) : ℝ :=
  ∑j,a (i,j)*t j

def normalizePhysicalProjection (a : Fin N×Fin N→ℝ) (t : Fin N→ℝ) (i : Fin N) : ℝ :=
  physicalProjection a t i/Real.sqrt ((∑k,physicalProjection a t k^2)/(N : ℝ))

@[fun_prop] theorem measurable_normalizePhysicalProjection :
    Measurable (fun p : (Fin N×Fin N→ℝ)×(Fin N→ℝ)=>normalizePhysicalProjection p.1 p.2) := by
  unfold normalizePhysicalProjection physicalProjection
  fun_prop

/-- `free k=true` propagates and normalizes the Gaussian auxiliary channel;
a controlled layer resets that channel to the constant one vector. -/
def auxiliaryChannel (free : ℕ→Bool) : (r : ℕ)→Weights d N r→Fin N→ℝ
  | 0,_=>fun _=>1
  | r+1,w=>if free r then
      normalizePhysicalProjection (lastMatrix w) (auxiliaryChannel free r (previousWeights w))
    else fun _=>1

@[fun_prop] theorem measurable_auxiliaryChannel (free : ℕ→Bool) (r : ℕ) :
    Measurable (auxiliaryChannel (d := d) (N := N) free r) := by
  induction r with
  | zero => exact measurable_const
  | succ r ih =>
    by_cases h : free r=true
    · simp only [auxiliaryChannel,h,if_true]
      exact measurable_normalizePhysicalProjection.comp
        (continuous_lastMatrix.measurable.prodMk (ih.comp continuous_previousWeights.measurable))
    · simp only [auxiliaryChannel,h,if_false]
      exact measurable_const

@[simp] theorem auxiliaryChannel_append (free : ℕ→Bool) (w : Weights d N r)
    (a : Fin N→Fin N→ℝ) :
    auxiliaryChannel free (r+1) (appendLayer w a)=
      if free r then normalizePhysicalProjection (fun ij=>a ij.1 ij.2) (auxiliaryChannel free r w)
      else fun _=>1 := by
  simp only [auxiliaryChannel,previousWeights_appendLayer,lastMatrix_appendLayer]

def empiricalSecond (w : Weights d N r) (x : BatchTwoContinuous.RealInput d) : ℝ :=
  (∑i,(BatchTwoContinuous.finalHidden Real.tanh w x i)^2)/(N : ℝ)

def empiricalPairing (t : Fin N→ℝ) (w : Weights d N r) (x : BatchTwoContinuous.RealInput d) : ℝ :=
  (∑i,t i*BatchTwoContinuous.finalHidden Real.tanh w x i)/(N : ℝ)

def empiricalMoments (free : ℕ→Bool) (s : Fin n→BatchTwoContinuous.RealInput d)
    (w : Weights d N r) : (Fin n→ℝ)×(Fin n→ℝ) :=
  (fun j=>empiricalSecond w (s j),fun j=>empiricalPairing (auxiliaryChannel free r w) w (s j))

@[fun_prop] theorem measurable_empiricalMoments (free : ℕ→Bool)
    (s : Fin n→BatchTwoContinuous.RealInput d) : Measurable (empiricalMoments (N := N) (r := r) free s) := by
  unfold empiricalMoments
  apply Measurable.prodMk
  · apply measurable_pi_lambda
    intro j
    unfold empiricalSecond
    apply Measurable.div_const
    apply Finset.measurable_sum
    intro i _
    exact (((BatchTwoContinuous.continuous_finalHidden_joint tanh_continuous i).comp
      (continuous_id.prodMk continuous_const)).measurable).pow_const 2
  · apply measurable_pi_lambda
    intro j
    unfold empiricalPairing
    apply Measurable.div_const
    apply Finset.measurable_sum
    intro i _
    exact ((measurable_pi_apply i).comp (measurable_auxiliaryChannel free r)).mul
      (((BatchTwoContinuous.continuous_finalHidden_joint tanh_continuous i).comp
        (continuous_id.prodMk continuous_const)).measurable)

theorem physicalProjection_standardized (hN : 0<N) (a : Fin N×Fin N→ℝ) (t : Fin N→ℝ) (i : Fin N) :
    rowLinear (fun j=>t j/Real.sqrt (N : ℝ)) (fun j=>Real.sqrt (N : ℝ)*a (i,j))=
      physicalProjection a t i := by
  have hs : Real.sqrt (N : ℝ)≠0 := ne_of_gt (Real.sqrt_pos.mpr (by exact_mod_cast hN))
  unfold rowLinear physicalProjection
  apply Finset.sum_congr rfl
  intro j _
  field_simp

 theorem normalizePhysicalProjection_standardized (hN : 0<N) (a : Fin N×Fin N→ℝ) (t : Fin N→ℝ) :
    normalizedRowProjection (fun j=>t j/Real.sqrt (N : ℝ))
      (fun i j=>Real.sqrt (N : ℝ)*a (i,j))=normalizePhysicalProjection a t := by
  funext i
  simp only [normalizedRowProjection,rowAverage,physicalProjection_standardized hN,normalizePhysicalProjection]

end NeuralGeneralization.BatchTwoContinuousDepthCritical
