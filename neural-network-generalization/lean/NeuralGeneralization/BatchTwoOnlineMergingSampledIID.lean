import NeuralGeneralization.BatchTwoOnlineActualIIDDraws
import NeuralGeneralization.BatchTwoOnlineMergingSampled
import NeuralGeneralization.BatchTwoOnlineMergingIID

/-! Complete infinite-IID sampled-mistake guarantees for the actual
merging-supported ReLU Gaussian posterior, with the original constants. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnlineRaw
open ConcreteModel BatchTwoMerging BatchTwoOnline SquaredSampling
variable {d C N r : ℕ}

def mergingSetPosterior (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d)
    (S : Finset (Fin (cubeSize d))) : Measure (Weights d N r) :=
  cond (smallPrior d N r σ) (mergingSetEvent globalMargin f S)

def mergingTestError (f : BooleanFunction d) (w : Weights d N r) (j : Fin (cubeSize d)) : Prop :=
  labelReal (f (cubeEnumeration d j))*networkOutput relu w (cubeEnumeration d j) ≤ 1/4

lemma measurable_mergingTestError (f : BooleanFunction d) (j : Fin (cubeSize d)) :
    MeasurableSet {w : Weights d N r | mergingTestError f w j} :=
  measurableSet_le ((continuous_networkOutput continuous_relu (cubeEnumeration d j)).measurable.const_mul _) measurable_const

lemma mergingSetPosterior_probability (hd : 0 < d) (hC : 0 < C) (B : LayeredNorCircuit d C r)
    (hCN : C ≤ N) {σ : ℝ} (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (globalMargin : Bool) (S : Finset (Fin (cubeSize d))) :
    IsProbabilityMeasure (mergingSetPosterior (N := N) (r := r) globalMargin σ B.computes S) := by
  have hp := posterior_event_pos relu globalMargin σ B.computes (cubeEnumeration d)
    (merging_target_mass_all_widths hd hC hCN B hσ hscale)
  have hs : posteriorEvent (N := N) (r := r) relu globalMargin B.computes (cubeEnumeration d) ⊆
      mergingSetEvent globalMargin B.computes S := by
    intro w hw
    exact ⟨hw.1,fun j _ => hw.2 j⟩
  have hh := hp.trans_le (measureReal_mono hs)
  apply cond_isProbabilityMeasure
  intro hz
  simp only [measureReal_def,hz,ENNReal.toReal_zero] at hh
  exact (lt_irrefl 0) hh

/-- The expected total number of actual sampled margin mistakes over the
entire infinite IID stream has the same depth-polynomial bound. -/
theorem merging_iid_sampled_expected (hd : 0 < d) (hC : 0 < C) (B : LayeredNorCircuit d C r)
    (hCN : C ≤ N) {σ : ℝ} (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) (globalMargin : Bool) :
    (∫⁻ query,∫⁻ draw,actualStreamTotal (mergingTestError (N := N) (r := r) B.computes) query draw
      ∂setDrawLaw (mergingSetPosterior globalMargin σ B.computes) query ∂iidQueryLaw (Fin (cubeSize d))) ≤
      ENNReal.ofReal (2+2*(mergingOnlineCapacity d C r+1)*(1+(d:ℝ))) := by
  letI : ∀ S,IsProbabilityMeasure (mergingSetPosterior (N := N) (r := r) globalMargin σ B.computes S) :=
    mergingSetPosterior_probability hd hC B hCN hσ hscale globalMargin
  simp_rw [actual_stream_expectation _ _ (measurable_mergingTestError _)]
  exact merging_iid_expected hd hC B hCN hσ hscale globalMargin

/-- Exact high-probability total sampled mistakes under the query-then-draw
experiment. Neither the time horizon nor the learner width enters the bound. -/
theorem merging_iid_sampled_tail (hd : 0 < d) (hC : 0 < C) (B : LayeredNorCircuit d C r)
    (hCN : C ≤ N) {σ δ : ℝ} (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) (globalMargin : Bool)
    (hδ : 0 < δ) (hδ1 : δ < 1) :
    (∫⁻ query,setDrawLaw (mergingSetPosterior (N := N) (r := r) globalMargin σ B.computes) query
      {draw | ENNReal.ofReal ((Real.exp 1-1)*(2+2*(mergingOnlineCapacity d C r+
        Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ)) <
        actualStreamTotal (mergingTestError B.computes) query draw} ∂iidQueryLaw (Fin (cubeSize d))) ≤
      ENNReal.ofReal δ := by
  let Q := mergingSetPosterior (N := N) (r := r) globalMargin σ B.computes
  let err := mergingTestError (N := N) (r := r) B.computes
  let U : ℝ := (Real.exp 1-1)*(2+2*(mergingOnlineCapacity d C r+
    Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ)
  letI : ∀ S,IsProbabilityMeasure (Q S) := mergingSetPosterior_probability hd hC B hCN hσ hscale globalMargin
  have hm : (1:ℝ) ≤ cubeSize d := by exact_mod_cast (Fintype.card_pos : 0 < Fintype.card (Cube d))
  have hc : 0 ≤ mergingOnlineCapacity d C r := by unfold mergingOnlineCapacity; positivity
  have hl : 0 ≤ Real.log (2*(cubeSize d:ℝ)/δ) := Real.log_nonneg ((one_le_div hδ).mpr (by nlinarith))
  have hl2 : 0 ≤ Real.log (2/δ) := Real.log_nonneg ((one_le_div hδ).mpr (by linarith))
  have he : 0 ≤ Real.exp 1-1 := by linarith [Real.add_one_le_exp (1:ℝ)]
  have hH := harmonicSum_nonneg (cubeSize d-1)
  have hU : 0 ≤ U := by dsimp [U]; positivity
  have hh := actual_iid_tail_le_permutation Q err (measurable_mergingTestError _) Fintype.card_pos
    (mergingSetRisk_repeated globalMargin σ B.computes) U hU
  apply hh.trans
  apply ENNReal.ofReal_le_ofReal
  have hp (π : Equiv.Perm (Fin (cubeSize d))) :
      (Measure.pi (fun i => mergingPrefixPosterior (N := N) (r := r) globalMargin σ B.computes i π)).real
        {draw | U < actualErrorCount err π draw} =
      setPermutationSampledTail (fun S x => (Q S).real {w | err w x}) U π := by
    letI : ∀ i,IsProbabilityMeasure
        (mergingPrefixPosterior (N := N) (r := r) globalMargin σ B.computes i π) :=
      fun i => mergingPrefix_probability hd hC B hCN hσ hscale globalMargin i π
    rw [actual_draw_tail_identity _ err (measurable_mergingTestError _) π U]
    change _ = setPermutationSampledTail (mergingSetRisk (N := N) (r := r) globalMargin σ B.computes) U π
    simp only [setPermutationSampledTail,mergingSetRisk_permutation,mergingRoundRisk,err,mergingTestError]
  have hb := merging_online_sampled_tail hd hC B hCN hσ hscale globalMargin hδ hδ1
  change finiteMean (fun π => (Measure.pi (fun i =>
    mergingPrefixPosterior (N := N) (r := r) globalMargin σ B.computes i π)).real
    {draw | U < actualErrorCount err π draw}) ≤ δ at hb
  simp_rw [hp] at hb
  exact hb

#print axioms merging_iid_sampled_tail
end NeuralGeneralization.BatchTwoOnlineRaw
