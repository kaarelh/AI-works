import NeuralGeneralization.BatchTwoManuscriptResources
import NeuralGeneralization.RobustCouplingTerminalPath

/-! The literal readout sample and energy budgets. The original-weight
marginal prevents query-message entropy from inflating the readout moment. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoManuscriptResources
open ConcreteModel RobustEntropy RobustCompressionInduction

theorem readoutEnergy_pos (p : Input) : 0<readoutEnergy p := by
  unfold readoutEnergy
  have := energy_pos p
  have := localFailure_pos p
  have := Real.log_pos (by norm_num : (1:ℝ)<2)
  positivity

theorem readout_sampling_allocation (p : Input) :
    (2:ℝ)^p.dimension*(2*Real.exp (-(bankSize p:ℝ)*(p.radius/16)^2/(2*readoutEnergy p)))≤localFailure p := by
  let A := (p.dimension:ℝ)*Real.log 2+Real.log (2/localFailure p)
  have hK := readoutEnergy_pos p
  have hr := p.radius_pos
  have hη := localFailure_pos p
  have hm := bankSize_readout_allocation p
  have hbudget : 512*readoutEnergy p*(A+1)≤(bankSize p:ℝ)*p.radius^2 := by
    have hm' := mul_le_mul_of_nonneg_right hm (sq_nonneg p.radius)
    change 512*readoutEnergy p*p.radius⁻¹^2*(A+1)*p.radius^2≤_ at hm'
    have heq : 512*readoutEnergy p*p.radius⁻¹^2*(A+1)*p.radius^2=512*readoutEnergy p*(A+1) := by
      field_simp
    rwa [heq] at hm'
  have he : -(bankSize p:ℝ)*(p.radius/16)^2/(2*readoutEnergy p)≤ -A := by
    apply (div_le_iff₀ (by positivity : 0<2*readoutEnergy p)).mpr
    nlinarith
  have hp : (2:ℝ)^p.dimension=Real.exp ((p.dimension:ℝ)*Real.log 2) := by
    rw [Real.exp_nat_mul,Real.exp_log (by norm_num : (0:ℝ)<2)]
  calc
    _≤(2:ℝ)^p.dimension*(2*Real.exp (-A)) := by
      gcongr
    _=localFailure p := by
      rw [hp]
      have hc : Real.exp ((p.dimension:ℝ)*Real.log 2)*Real.exp (-A)=localFailure p/2 := by
        rw [←Real.exp_add]
        have heq : (p.dimension:ℝ)*Real.log 2+-A= -Real.log (2/localFailure p) := by dsimp [A]; ring
        rw [heq,Real.exp_neg,Real.exp_log (div_pos (by norm_num) hη)]
        field_simp
      nlinarith

theorem readout_energy_allocation (p : Input) :
    (4*p.energy+2)/readoutEnergy p≤2*localFailure p := by
  have hl : (1:ℝ)/2≤Real.log 2 := by
    have hh := Real.one_sub_inv_le_log_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at hh
    exact hh
  have hK := energy_pos p
  have hη := localFailure_pos p
  unfold readoutEnergy
  have hn : 0<4*p.energy+2*Real.log 2 := by nlinarith
  apply (div_le_iff₀ (div_pos hn hη)).mpr
  field_simp
  nlinarith

theorem original_readout_abort (p : Input) {N : ℕ} (hN : 0<N) {t : ℝ}
    (ht : 0<t) (ht1 : t≤1)
    (Q : Measure (Weights p.dimension N (p.depth-2))) [IsProbabilityMeasure Q]
    (hQ : klDiv Q (smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ)))≤
      ENNReal.ofReal ((N:ℝ)*p.energy/t^2)) :
    Q.real {w | readoutEnergy p<ConcreteModel.readoutEnergy w}≤2*localFailure p := by
  have hs : 0<t/Real.sqrt (N:ℝ) := div_pos ht (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hN))
  have hscale : (N:ℝ)*(t/Real.sqrt (N:ℝ))^2≤1 := by
    rw [div_pow,Real.sq_sqrt (Nat.cast_nonneg N)]
    have hn : (N:ℝ)≠0 := (Nat.cast_pos.mpr hN).ne'
    field_simp
    nlinarith
  have hQ' : klDiv Q (smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ)))≤
      ENNReal.ofReal (p.energy/(t/Real.sqrt (N:ℝ))^2) := by
    convert hQ using 1
    congr 1
    rw [div_pow,Real.sq_sqrt (Nat.cast_nonneg N)]
    field_simp
  exact (RobustCompressionBlockMoments.readout_energy_abort_probability p.dimension_pos hN hs
    (energy_pos p).le hscale Q hQ' (readoutEnergy_pos p)).trans (readout_energy_allocation p)

end NeuralGeneralization.BatchTwoManuscriptResources
