import NeuralGeneralization.BatchTwoOnlineActualIIDDraws
import NeuralGeneralization.BatchTwoOnlineTanhSampled
import NeuralGeneralization.BatchTwoOnlineTanhIID

/-! Complete infinite-IID sampled-mistake guarantees for the actual
merging-supported signed-tanh Gaussian posterior, with an explicit signed-tanh grid-entropy budget. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel BatchTwoMerging BatchTwoOnline BatchTwoOnlineRaw SquaredSampling
variable {d C N r : ℕ}

def tanhMergingSetPosterior (noiseMargin globalMargin : Bool) (c0 σ : ℝ) (f : BooleanFunction d)
    (S : Finset (Fin (cubeSize d))) : Measure (Weights d N r) :=
  cond (smallPrior d N r σ) (tanhMergingSetEvent noiseMargin globalMargin c0 f S)

def tanhMergingTestError (f : BooleanFunction d) (w : Weights d N r) (j : Fin (cubeSize d)) : Prop :=
  labelReal (f (cubeEnumeration d j))*networkOutput Real.tanh w (cubeEnumeration d j) ≤ 1/4

lemma tanh_measurable_mergingTestError (f : BooleanFunction d) (j : Fin (cubeSize d)) :
    MeasurableSet {w : Weights d N r | tanhMergingTestError f w j} :=
  measurableSet_le ((continuous_networkOutput tanh_continuous (cubeEnumeration d j)).measurable.const_mul _) measurable_const

lemma tanh_mergingSetPosterior_probability (hd : 0 < d) (hC : 0 < C) (B : LayeredBooleanCircuit d C r)
    (hCN : C ≤ N) {c0 σ : ℝ} (hc0 : 0<c0) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (noiseMargin globalMargin : Bool) (S : Finset (Fin (cubeSize d))) :
    IsProbabilityMeasure (tanhMergingSetPosterior (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes S) := by
  have hp := tanh_posterior_event_pos hd hC hCN B hc0 hσ hscale noiseMargin globalMargin (cubeEnumeration d)
  have hs : tanhPosteriorEvent (N := N) (r := r) noiseMargin globalMargin c0 B.computes (cubeEnumeration d) ⊆
      tanhMergingSetEvent noiseMargin globalMargin c0 B.computes S := by
    intro w hw
    exact ⟨hw.1,fun j _ => hw.2 j⟩
  have hh := hp.trans_le (measureReal_mono hs)
  apply cond_isProbabilityMeasure
  intro hz
  simp only [measureReal_def,hz,ENNReal.toReal_zero] at hh
  exact (lt_irrefl 0) hh

/-- The expected total number of actual sampled margin mistakes over the
entire infinite IID stream has the same grid-entropy bound. -/
theorem tanh_merging_iid_sampled_expected (hd : 0 < d) (hC : 0 < C) (B : LayeredBooleanCircuit d C r)
    (hCN : C ≤ N) {c0 σ : ℝ} (hc0 : 0<c0) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) (noiseMargin globalMargin : Bool) :
    (∫⁻ query,∫⁻ draw,actualStreamTotal (tanhMergingTestError (N := N) (r := r) B.computes) query draw
      ∂setDrawLaw (tanhMergingSetPosterior noiseMargin globalMargin c0 σ B.computes) query ∂iidQueryLaw (Fin (cubeSize d))) ≤
      ENNReal.ofReal (2+2*(tanhMergingOnlineEntropy d C r c0+1)*(1+(d:ℝ))) := by
  letI : ∀ S,IsProbabilityMeasure (tanhMergingSetPosterior (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes S) :=
    tanh_mergingSetPosterior_probability hd hC B hCN hc0 hσ hscale noiseMargin globalMargin
  simp_rw [actual_stream_expectation _ _ (tanh_measurable_mergingTestError _)]
  exact tanh_merging_iid_expected hd hC B hCN hc0 hσ hscale noiseMargin globalMargin

/-- Exact high-probability total sampled mistakes under the query-then-draw
experiment. Neither the time horizon nor the learner width enters the bound. -/
theorem tanh_merging_iid_sampled_tail (hd : 0 < d) (hC : 0 < C) (B : LayeredBooleanCircuit d C r)
    (hCN : C ≤ N) {c0 σ δ : ℝ} (hc0 : 0<c0) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) (noiseMargin globalMargin : Bool)
    (hδ : 0 < δ) (hδ1 : δ < 1) :
    (∫⁻ query,setDrawLaw (tanhMergingSetPosterior (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes) query
      {draw | ENNReal.ofReal ((Real.exp 1-1)*(2+2*(tanhMergingOnlineEntropy d C r c0+
        Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ)) <
        actualStreamTotal (tanhMergingTestError B.computes) query draw} ∂iidQueryLaw (Fin (cubeSize d))) ≤
      ENNReal.ofReal δ := by
  let Q := tanhMergingSetPosterior (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes
  let err := tanhMergingTestError (N := N) (r := r) B.computes
  let U : ℝ := (Real.exp 1-1)*(2+2*(tanhMergingOnlineEntropy d C r c0+
    Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ)
  letI : ∀ S,IsProbabilityMeasure (Q S) := tanh_mergingSetPosterior_probability hd hC B hCN hc0 hσ hscale noiseMargin globalMargin
  have hm : (1:ℝ) ≤ cubeSize d := by exact_mod_cast (Fintype.card_pos : 0 < Fintype.card (Cube d))
  have hc : 0 ≤ tanhMergingOnlineEntropy d C r c0 := tanhMergingOnlineEntropy_nonneg d C r c0
  have hl : 0 ≤ Real.log (2*(cubeSize d:ℝ)/δ) := Real.log_nonneg ((one_le_div hδ).mpr (by nlinarith))
  have hl2 : 0 ≤ Real.log (2/δ) := Real.log_nonneg ((one_le_div hδ).mpr (by linarith))
  have he : 0 ≤ Real.exp 1-1 := by linarith [Real.add_one_le_exp (1:ℝ)]
  have hH := harmonicSum_nonneg (cubeSize d-1)
  have hU : 0 ≤ U := by dsimp [U]; positivity
  have hh := actual_iid_tail_le_permutation Q err (tanh_measurable_mergingTestError _) Fintype.card_pos
    (tanh_mergingSetRisk_repeated noiseMargin globalMargin hc0 σ B.computes) U hU
  apply hh.trans
  apply ENNReal.ofReal_le_ofReal
  have hp (π : Equiv.Perm (Fin (cubeSize d))) :
      (Measure.pi (fun i => tanhMergingPrefixPosterior (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes i π)).real
        {draw | U < actualErrorCount err π draw} =
      setPermutationSampledTail (fun S x => (Q S).real {w | err w x}) U π := by
    letI : ∀ i,IsProbabilityMeasure
        (tanhMergingPrefixPosterior (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes i π) :=
      fun i => tanh_mergingPrefix_probability hd hC B hCN hc0 hσ hscale noiseMargin globalMargin i π
    rw [actual_draw_tail_identity _ err (tanh_measurable_mergingTestError _) π U]
    change _ = setPermutationSampledTail (tanhMergingSetRisk (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes) U π
    simp only [setPermutationSampledTail,tanh_mergingSetRisk_permutation,tanhMergingRoundRisk,err,tanhMergingTestError]
  have hb := tanh_merging_online_sampled_tail hd hC B hCN hc0 hσ hscale noiseMargin globalMargin hδ hδ1
  change finiteMean (fun π => (Measure.pi (fun i =>
    tanhMergingPrefixPosterior (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes i π)).real
    {draw | U < actualErrorCount err π draw}) ≤ δ at hb
  simp_rw [hp] at hb
  exact hb

#print axioms tanh_merging_iid_sampled_tail
end NeuralGeneralization.BatchTwoOnlineTanhMerging
