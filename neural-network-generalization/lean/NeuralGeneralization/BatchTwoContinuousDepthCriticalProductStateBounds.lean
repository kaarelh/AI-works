import NeuralGeneralization.BatchTwoContinuousDepthCriticalProductState
import NeuralGeneralization.BatchTwoContinuousDepthCriticalPopulation
import NeuralGeneralization.BatchTwoContinuousFreeze

/-! Uniform bounds and exact standardized coefficients for the literal
physical network and its auxiliary channel. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel NetworkLayerSplit TowerNetwork BatchTwoContinuous.PairMoments
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
variable {d N r n:ℕ}

theorem real_finalHidden_tanh_bound (w:Weights d N r) (x:BatchTwoContinuous.RealInput d) (i:Fin N):
    |BatchTwoContinuous.finalHidden Real.tanh w x i|≤1:=by
  have hh:=TowerNetwork.finalHidden_tanh_abs_le_one (BatchTwoContinuous.freezeInput x w) (fun _=>false) i
  rwa [BatchTwoContinuous.finalHidden_freeze] at hh

theorem real_finalHidden_energy (w:Weights d N r) (x:BatchTwoContinuous.RealInput d):
    (∑i,(BatchTwoContinuous.finalHidden Real.tanh w x i)^2)≤(N:ℝ):=by
  have hh:=Finset.sum_le_sum (fun i (_:i∈Finset.univ)=>
    (sq_le_one_iff_abs_le_one _).mpr (real_finalHidden_tanh_bound w x i))
  simpa using hh

theorem empiricalSecond_bounds (hN:0<N) (w:Weights d N r) (x:BatchTwoContinuous.RealInput d):
    0≤empiricalSecond w x ∧ empiricalSecond w x≤1:=by
  have hn:(0:ℝ)<N:=by exact_mod_cast hN
  refine ⟨div_nonneg (Finset.sum_nonneg fun _ _=>sq_nonneg _) hn.le,?_⟩
  exact (div_le_one hn).mpr (real_finalHidden_energy w x)

theorem empiricalPairing_bound (hN:0<N) (t:Fin N→ℝ)
    (ht:(∑i,(t i)^2)/(N:ℝ)=1) (w:Weights d N r) (x:BatchTwoContinuous.RealInput d):
    |empiricalPairing t w x|≤1:=by
  have hn:(0:ℝ)<N:=by exact_mod_cast hN
  have hT:(∑i,(t i)^2)=(N:ℝ):=(div_eq_one_iff_eq hn.ne').mp ht
  have hc:=Finset.sum_mul_sq_le_sq_mul_sq Finset.univ t (BatchTwoContinuous.finalHidden Real.tanh w x)
  rw [hT] at hc
  have hh:=mul_le_mul_of_nonneg_left (real_finalHidden_energy w x) hn.le
  have hsum:|∑i,t i*BatchTwoContinuous.finalHidden Real.tanh w x i|≤(N:ℝ):=by
    have he:=sq_abs (∑i,t i*BatchTwoContinuous.finalHidden Real.tanh w x i)
    nlinarith [abs_nonneg (∑i,t i*BatchTwoContinuous.finalHidden Real.tanh w x i)]
  unfold empiricalPairing
  rw [abs_div,abs_of_pos hn]
  exact (div_le_one hn).mpr hsum

theorem empiricalMoments_mem (hN:0<N) (free:ℕ→Bool) (s:Fin n→BatchTwoContinuous.RealInput d)
    (w:Weights d N r) (ht:(∑i,(auxiliaryChannel free r w i)^2)/(N:ℝ)=1):
    empiricalMoments free s w∈momentBox (Fin n):=by
  refine ⟨⟨fun j=>(empiricalSecond_bounds hN w (s j)).1,
    fun j=>(empiricalSecond_bounds hN w (s j)).2⟩,⟨?_,?_⟩⟩
  · intro j
    exact (abs_le.mp (empiricalPairing_bound hN _ ht w (s j))).1
  · intro j
    exact (abs_le.mp (empiricalPairing_bound hN _ ht w (s j))).2

def featureCoefficient (w:Weights d N r) (x:BatchTwoContinuous.RealInput d):Fin N→ℝ:=
  fun i=>BatchTwoContinuous.finalHidden Real.tanh w x i/Real.sqrt (N:ℝ)

def channelCoefficient (t:Fin N→ℝ):Fin N→ℝ:=fun i=>t i/Real.sqrt (N:ℝ)

theorem featureCoefficient_energy (w:Weights d N r) (x:BatchTwoContinuous.RealInput d):
    (∑i,(featureCoefficient w x i)^2)=empiricalSecond w x:=by
  simp only [featureCoefficient,div_pow,Real.sq_sqrt (Nat.cast_nonneg N),←Finset.sum_div,empiricalSecond]

theorem channelCoefficient_energy (t:Fin N→ℝ):
    (∑i,(channelCoefficient t i)^2)=(∑i,(t i)^2)/(N:ℝ):=by
  simp only [channelCoefficient,div_pow,Real.sq_sqrt (Nat.cast_nonneg N),←Finset.sum_div]

theorem coefficient_pairing (t:Fin N→ℝ) (w:Weights d N r) (x:BatchTwoContinuous.RealInput d):
    (∑i,channelCoefficient t i*featureCoefficient w x i)=empiricalPairing t w x:=by
  simp only [channelCoefficient,featureCoefficient,div_mul_div_comm,←sq,
    Real.sq_sqrt (Nat.cast_nonneg N),←Finset.sum_div,empiricalPairing]

theorem coefficient_free_mean_bound (hN:0<N) (t:Fin N→ℝ)
    (ht:(∑i,(t i)^2)/(N:ℝ)=1) (w:Weights d N r) (x:BatchTwoContinuous.RealInput d):
    |(∑i,channelCoefficient t i*featureCoefficient w x i)*
      coolingDerivative (∑i,(featureCoefficient w x i)^2)|≤1:=by
  rw [coefficient_pairing,featureCoefficient_energy,abs_mul,
    abs_of_pos (coolingDerivative_pos _)]
  have hh:=empiricalPairing_bound hN t ht w x
  have hder:coolingDerivative (empiricalSecond w x)≤1:=by
    rw [coolingDerivative_eq]
    linarith [coolingSecondMoment_nonneg (empiricalSecond w x)]
  exact (mul_le_mul_of_nonneg_right hh (coolingDerivative_pos _).le).trans
    (by simpa only [one_mul] using hder)

theorem real_finalHidden_append_standardized (hN:0<N) (w:Weights d N r)
    (a:Fin N×Fin N→ℝ) (x:BatchTwoContinuous.RealInput d) (i:Fin N):
    Real.tanh (rowLinear (featureCoefficient w x) (fun j=>Real.sqrt (N:ℝ)*a (i,j)))=
      BatchTwoContinuous.finalHidden Real.tanh (appendLayer w (fun i j=>a (i,j))) x i:=by
  rw [finalHidden_append]
  congr 1
  exact physicalProjection_standardized hN a (BatchTwoContinuous.finalHidden Real.tanh w x) i

end NeuralGeneralization.BatchTwoContinuousDepthCritical
