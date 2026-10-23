import NeuralGeneralization.BatchTwoContinuousPairMomentsOutput

/-! Explicit high-moment probability bound for actual paired output increments. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuous.PairMoments
open ConcreteModel

variable {d N r : ℕ} {σ η : ℝ}

theorem output_pair_tail (hd : 0<d) (hN : 0<N) (hσ : 0<σ) (hη : 0<η)
    (x y : RealInput d) (p : ℕ) (hp : 0<p) :
    (smallPrior d N r σ).real {w | η≤|output Real.tanh w x-output Real.tanh w y|}≤
      (outputPairMomentBase d N r p σ x y/η^2)^p := by
  have hh:=output_pair_moment (r:=r) hd hN hσ x y p hp
  have hm:=mul_meas_ge_le_integral_of_nonneg (μ:=smallPrior d N r σ)
    (Filter.Eventually.of_forall (fun w=>show 0≤|output Real.tanh w x-output Real.tanh w y|^(2*p) by positivity))
    hh.1 (η^(2*p))
  have hset : {w : Weights d N r | η≤|output Real.tanh w x-output Real.tanh w y|}⊆
      {w | η^(2*p)≤|output Real.tanh w x-output Real.tanh w y|^(2*p)} := by
    intro w hw
    exact pow_le_pow_left₀ hη.le hw (2*p)
  have hbound: η^(2*p)*(smallPrior d N r σ).real
      {w | η≤|output Real.tanh w x-output Real.tanh w y|}≤(outputPairMomentBase d N r p σ x y)^p :=
    (mul_le_mul_of_nonneg_left (measureReal_mono hset) (pow_nonneg hη.le _)).trans (hm.trans hh.2)
  have hdiv: (smallPrior d N r σ).real {w | η≤|output Real.tanh w x-output Real.tanh w y|}≤
      (outputPairMomentBase d N r p σ x y)^p/η^(2*p) := by
    apply (le_div_iff₀ (pow_pos hη _)).mpr
    simpa only [mul_comm] using hbound
  simpa only [div_pow,pow_mul] using hdiv

end NeuralGeneralization.BatchTwoContinuous.PairMoments
