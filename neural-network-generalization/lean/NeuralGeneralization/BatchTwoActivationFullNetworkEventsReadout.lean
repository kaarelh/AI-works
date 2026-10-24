import NeuralGeneralization.BatchTwoActivationFullNetworkEventsModel
import NeuralGeneralization.RobustReadoutTruncation

/-! The actual physical readout has the same width-exponential tail as the
hidden reconstruction events throughout the sub-mean-field variance range. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

theorem activationReadout_bad_tail {d N r K : ℕ} (hd : 0<d) (hN : 0<N) (hK : 1≤K)
    {σ : ℝ} (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) :
    (smallPrior d N r σ).real {w | 8*(K:ℝ)<readoutEnergy w}≤Real.exp (-(N:ℝ)*(K:ℝ)) := by
  have hKR : (1:ℝ)≤K := by exact_mod_cast hK
  have ht:=RobustPosterior.smallPrior_readout_tail (r:=r) hd hN hσ
    (B:=8*(K:ℝ)) (by nlinarith)
  apply ht.trans (Real.exp_le_exp.mpr ?_)
  apply (div_le_iff₀ (show 0<4*σ^2 by positivity)).mpr
  nlinarith [mul_le_mul_of_nonneg_right hscale (show 0≤4*(K:ℝ) by positivity)]

end NeuralGeneralization.BatchTwoActivation
