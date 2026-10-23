import NeuralGeneralization.BatchTwoContinuousDepthCriticalProductStateBoundsFree
import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlReadout
import NeuralGeneralization.BatchTwoContinuousPairMomentsSplit

/-! The actual critical readout law and its finite-width controlled event,
for the original physical network rather than a standardized surrogate. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel NetworkReadout NetworkLayerSplit TowerNetwork BatchTwoContinuous.PairMoments
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
variable {d N r n:ℕ}

def criticalReadoutStandardize (v:Fin N→ℝ):Fin N→ℝ:=fun i=>(N:ℝ)*v i

@[fun_prop] theorem measurable_criticalReadoutStandardize:
    Measurable (criticalReadoutStandardize (N:=N)):=by unfold criticalReadoutStandardize;fun_prop

theorem criticalReadoutStandardize_law (hN:0<N):
    (smallReadoutPrior N (1/Real.sqrt (N:ℝ))).map criticalReadoutStandardize=
      Measure.pi (fun _ : Fin N=>gaussianReal 0 1):=by
  have hn:(0:ℝ)<N:=by exact_mod_cast hN
  unfold smallReadoutPrior criticalReadoutStandardize
  rw [Measure.pi_map_pi (f:=fun (_:Fin N) (z:ℝ)=>(N:ℝ)*z)
    (fun _=>(show Measurable (fun z:ℝ=>(N:ℝ)*z) by fun_prop).aemeasurable)]
  congr 1
  funext i
  rw [gaussianReal_map_const_mul,mul_zero]
  congr 1
  apply NNReal.coe_injective
  simp only [NNReal.coe_mul,NNReal.coe_mk,NNReal.coe_one,
    Real.coe_toNNReal _ (show 0≤(1/Real.sqrt (N:ℝ))^2/(N:ℝ) by positivity)]
  rw [div_pow,Real.sq_sqrt hn.le]
  field_simp

theorem real_finalHidden_withReadout (w:Weights d N r) (v:Fin N→ℝ)
    (x:BatchTwoContinuous.RealInput d):
    BatchTwoContinuous.finalHidden Real.tanh (withReadout w v) x=
      BatchTwoContinuous.finalHidden Real.tanh w x:=rfl

theorem criticalReadoutStandardize_output (hN:0<N) (w:Weights d N r) (v:Fin N→ℝ)
    (x:BatchTwoContinuous.RealInput d):
    (∑i,criticalReadoutStandardize v i*BatchTwoContinuous.finalHidden Real.tanh w x i)/(N:ℝ)=
      BatchTwoContinuous.output Real.tanh (withReadout w v) x:=by
  simp only [criticalReadoutStandardize,mul_assoc,←Finset.mul_sum,
    BatchTwoContinuous.output,real_finalHidden_withReadout,withReadout]
  exact mul_div_cancel_left₀ _ (by exact_mod_cast Nat.ne_of_gt hN)

/-- With a fixed actual hidden network and RMS-one auxiliary channel, the
independent physical critical readout has the asserted exponential event mass. -/
theorem critical_physical_readout_probability (hN:0<N) (w:Weights d N r)
    (s:Fin n→BatchTwoContinuous.RealInput d) (T:Fin N→ℝ)
    (hT:(∑i,T i^2)/(N:ℝ)=1) (a:ℝ) {ε:ℝ} (hε:0<ε)
    (hbudget:2*(n:ℝ)*Real.exp (-(N:ℝ)*ε^2/2)≤1/4):
    (1:ℝ)/2*Real.exp (-2*(N:ℝ)*a^2-4)≤
      (smallReadoutPrior N (1/Real.sqrt (N:ℝ))).real
        {v|∀j,|BatchTwoContinuous.output Real.tanh (withReadout w v) (s j)-
          a*empiricalPairing T w (s j)|<ε}:=by
  let H:Fin n→Fin N→ℝ:=fun j=>BatchTwoContinuous.finalHidden Real.tanh w (s j)
  have hT':(∑i,T i^2)=(N:ℝ):=(div_eq_one_iff_eq (by exact_mod_cast Nat.ne_of_gt hN)).mp hT
  have hh:=critical_readout_control_probability hN H T (fun j=>real_finalHidden_energy w (s j))
    hT' a hε (by simpa only [Fintype.card_fin] using hbudget)
  let B:Set (Fin N→ℝ):={z|∀j,|(∑i,z i*H j i)/(N:ℝ)-a*((∑i,T i*H j i)/(N:ℝ))|<ε}
  have hB:MeasurableSet B:=by
    simp only [B,Set.setOf_forall]
    apply MeasurableSet.iInter
    intro j
    exact measurableSet_lt (by fun_prop) measurable_const
  change (1:ℝ)/2*Real.exp (-2*(N:ℝ)*a^2-4)≤
    (Measure.pi fun _ : Fin N=>gaussianReal 0 1).real B at hh
  rw [←criticalReadoutStandardize_law hN] at hh
  have hm:((smallReadoutPrior N (1/Real.sqrt (N:ℝ))).map criticalReadoutStandardize).real B=
      (smallReadoutPrior N (1/Real.sqrt (N:ℝ))).real (criticalReadoutStandardize⁻¹' B):=
    congrArg ENNReal.toReal (Measure.map_apply measurable_criticalReadoutStandardize hB)
  rw [hm] at hh
  have he:criticalReadoutStandardize⁻¹' B=
      {v:Fin N→ℝ|∀j,|BatchTwoContinuous.output Real.tanh (withReadout w v) (s j)-
        a*empiricalPairing T w (s j)|<ε}:=by
    ext v
    simp only [B,H,Set.mem_preimage,Set.mem_setOf_eq,criticalReadoutStandardize_output hN,empiricalPairing]
  rwa [he] at hh

theorem critical_assembled_readout_probability (hN:0<N) (h:HiddenIndex d N r→ℝ)
    (s:Fin n→BatchTwoContinuous.RealInput d) (T:Fin N→ℝ)
    (hT:(∑i,T i^2)/(N:ℝ)=1) (a:ℝ) {ε:ℝ} (hε:0<ε)
    (hbudget:2*(n:ℝ)*Real.exp (-(N:ℝ)*ε^2/2)≤1/4):
    (1:ℝ)/2*Real.exp (-2*(N:ℝ)*a^2-4)≤
      (smallReadoutPrior N (1/Real.sqrt (N:ℝ))).real
        {v|∀j,|BatchTwoContinuous.output Real.tanh (assemble h v) (s j)-
          a*empiricalPairing T (assemble h 0) (s j)|<ε}:=by
  have he (v:Fin N→ℝ):withReadout (assemble h 0) v=assemble h v:=by
    funext i
    rcases i with ij|(sij|k) <;> rfl
  simpa only [he] using critical_physical_readout_probability hN (assemble h 0) s T hT a hε hbudget

end NeuralGeneralization.BatchTwoContinuousDepthCritical
