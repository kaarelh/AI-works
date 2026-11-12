import NeuralGeneralization.BatchTwoOnlineActualIIDDraws
import NeuralGeneralization.BatchTwoOnlineBalancedSampled
import NeuralGeneralization.BatchTwoOnlineBalancedIID

/-! Complete infinite-IID sampled-mistake guarantees for the actual
merging-supported balanced-tanh Gaussian posterior, with an explicit balanced-tanh grid-entropy budget. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging BatchTwoOnlineTanhMerging BatchTwoOnline BatchTwoOnlineRaw SquaredSampling
variable {d C N r : ℕ}

def balancedMergingSetPosterior (noiseMargin globalMargin : Bool) (c0 σ : ℝ) (f : BooleanFunction d)
    (S : Finset (Fin (cubeSize d))) : Measure (Weights d N r) :=
  cond (smallPrior d N r σ) (balancedMergingSetEvent noiseMargin globalMargin c0 f S)

def balancedMergingTestError (f : BooleanFunction d) (w : Weights d N r) (j : Fin (cubeSize d)) : Prop :=
  labelReal (f (cubeEnumeration d j))*networkOutput Real.tanh w (cubeEnumeration d j) ≤ 1/4

lemma balanced_measurable_mergingTestError (f : BooleanFunction d) (j : Fin (cubeSize d)) :
    MeasurableSet {w : Weights d N r | balancedMergingTestError f w j} :=
  measurableSet_le ((continuous_networkOutput tanh_continuous (cubeEnumeration d j)).measurable.const_mul _) measurable_const

lemma balanced_mergingSetPosterior_probability (hd : 0 < d) (hC : 0 < C) (B : LayeredBooleanCircuit d C r)
    (hCN : C ≤ N) {c0 σ : ℝ} (hc0 : 0<c0) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (noiseMargin globalMargin : Bool) (S : Finset (Fin (cubeSize d))) :
    IsProbabilityMeasure (balancedMergingSetPosterior (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes S) := by
  have hp := balanced_posterior_event_pos hd hC hCN B hc0 hσ hscale noiseMargin globalMargin (cubeEnumeration d)
  have hs : balancedPosteriorEvent (N := N) (r := r) noiseMargin globalMargin c0 B.computes (cubeEnumeration d) ⊆
      balancedMergingSetEvent noiseMargin globalMargin c0 B.computes S := by
    intro w hw
    exact ⟨hw.1,fun j _ => hw.2 j⟩
  have hh := hp.trans_le (measureReal_mono hs)
  apply cond_isProbabilityMeasure
  intro hz
  simp only [measureReal_def,hz,ENNReal.toReal_zero] at hh
  exact (lt_irrefl 0) hh

/-- The expected total number of actual sampled margin mistakes over the
entire infinite IID stream has the same grid-entropy bound. -/
theorem balanced_merging_iid_sampled_expected (hd : 0 < d) (hC : 0 < C) (B : LayeredBooleanCircuit d C r)
    (hCN : C ≤ N) {c0 σ : ℝ} (hc0 : 0<c0) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) (noiseMargin globalMargin : Bool) :
    (∫⁻ query,∫⁻ draw,actualStreamTotal (balancedMergingTestError (N := N) (r := r) B.computes) query draw
      ∂setDrawLaw (balancedMergingSetPosterior noiseMargin globalMargin c0 σ B.computes) query ∂iidQueryLaw (Fin (cubeSize d))) ≤
      ENNReal.ofReal (2+2*(balancedMergingOnlineEntropy d C r c0+1)*(1+(d:ℝ))) := by
  letI : ∀ S,IsProbabilityMeasure (balancedMergingSetPosterior (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes S) :=
    balanced_mergingSetPosterior_probability hd hC B hCN hc0 hσ hscale noiseMargin globalMargin
  simp_rw [actual_stream_expectation _ _ (balanced_measurable_mergingTestError _)]
  exact balanced_merging_iid_expected hd hC B hCN hc0 hσ hscale noiseMargin globalMargin

/-- Exact high-probability total sampled mistakes under the query-then-draw
experiment. Neither the time horizon nor the learner width enters the bound. -/
theorem balanced_merging_iid_sampled_tail (hd : 0 < d) (hC : 0 < C) (B : LayeredBooleanCircuit d C r)
    (hCN : C ≤ N) {c0 σ δ : ℝ} (hc0 : 0<c0) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) (noiseMargin globalMargin : Bool)
    (hδ : 0 < δ) (hδ1 : δ < 1) :
    (∫⁻ query,setDrawLaw (balancedMergingSetPosterior (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes) query
      {draw | ENNReal.ofReal ((Real.exp 1-1)*(2+2*(balancedMergingOnlineEntropy d C r c0+
        Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ)) <
        actualStreamTotal (balancedMergingTestError B.computes) query draw} ∂iidQueryLaw (Fin (cubeSize d))) ≤
      ENNReal.ofReal δ := by
  let Q := balancedMergingSetPosterior (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes
  let err := balancedMergingTestError (N := N) (r := r) B.computes
  let U : ℝ := (Real.exp 1-1)*(2+2*(balancedMergingOnlineEntropy d C r c0+
    Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ)
  letI : ∀ S,IsProbabilityMeasure (Q S) := balanced_mergingSetPosterior_probability hd hC B hCN hc0 hσ hscale noiseMargin globalMargin
  have hm : (1:ℝ) ≤ cubeSize d := by exact_mod_cast (Fintype.card_pos : 0 < Fintype.card (Cube d))
  have hc : 0 ≤ balancedMergingOnlineEntropy d C r c0 := balancedMergingOnlineEntropy_nonneg d C r c0
  have hl : 0 ≤ Real.log (2*(cubeSize d:ℝ)/δ) := Real.log_nonneg ((one_le_div hδ).mpr (by nlinarith))
  have hl2 : 0 ≤ Real.log (2/δ) := Real.log_nonneg ((one_le_div hδ).mpr (by linarith))
  have he : 0 ≤ Real.exp 1-1 := by linarith [Real.add_one_le_exp (1:ℝ)]
  have hH := harmonicSum_nonneg (cubeSize d-1)
  have hU : 0 ≤ U := by dsimp [U]; positivity
  have hh := actual_iid_tail_le_permutation Q err (balanced_measurable_mergingTestError _) Fintype.card_pos
    (balanced_mergingSetRisk_repeated noiseMargin globalMargin hc0 σ B.computes) U hU
  apply hh.trans
  apply ENNReal.ofReal_le_ofReal
  have hp (π : Equiv.Perm (Fin (cubeSize d))) :
      (Measure.pi (fun i => balancedMergingPrefixPosterior (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes i π)).real
        {draw | U < actualErrorCount err π draw} =
      setPermutationSampledTail (fun S x => (Q S).real {w | err w x}) U π := by
    letI : ∀ i,IsProbabilityMeasure
        (balancedMergingPrefixPosterior (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes i π) :=
      fun i => balanced_mergingPrefix_probability hd hC B hCN hc0 hσ hscale noiseMargin globalMargin i π
    rw [actual_draw_tail_identity _ err (balanced_measurable_mergingTestError _) π U]
    change _ = setPermutationSampledTail (balancedMergingSetRisk (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes) U π
    simp only [setPermutationSampledTail,balanced_mergingSetRisk_permutation,balancedMergingRoundRisk,err,balancedMergingTestError]
  have hb := balanced_merging_online_sampled_tail hd hC B hCN hc0 hσ hscale noiseMargin globalMargin hδ hδ1
  change finiteMean (fun π => (Measure.pi (fun i =>
    balancedMergingPrefixPosterior (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes i π)).real
    {draw | U < actualErrorCount err π draw}) ≤ δ at hb
  simp_rw [hp] at hb
  exact hb

#print axioms balanced_merging_iid_sampled_tail
end NeuralGeneralization.BatchTwoOnlineBalanced
