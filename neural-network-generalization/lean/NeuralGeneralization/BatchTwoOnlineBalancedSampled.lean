import NeuralGeneralization.BatchTwoOnlineActualDraws
import NeuralGeneralization.BatchTwoOnlineBalancedMain

/-! Sampled-mistake tail for the actual supported
signed tanh Gaussian learner, with the explicit grid-entropy resource budget. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging BatchTwoOnlineTanhMerging BatchTwoOnline BatchTwoOnlineRaw SquaredSampling
variable {d C r N : ℕ}

/-- Actual posterior parameter draws, with one fresh draw at each revealed
input. The measured event counts tested-margin errors and hence also controls
sign mistakes. Both global-margin conventions and every finite scale apply. -/
theorem balanced_merging_online_sampled_tail (hd : 0 < d) (hC : 0 < C) (B : LayeredBooleanCircuit d C r)
    (hCN : C ≤ N) {c0 σ δ : ℝ} (hc0 : 0<c0) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) (noiseMargin globalMargin : Bool)
    (hδ : 0 < δ) (hδ1 : δ < 1) :
    finiteMean (fun π => (Measure.pi (fun i =>
      balancedMergingPrefixPosterior (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes i π)).real
      {draw | (Real.exp 1-1)*(2+2*(balancedMergingOnlineEntropy d C r c0+
        Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ) <
        actualErrorCount (fun w j => labelReal (B.computes (cubeEnumeration d j))*
          networkOutput Real.tanh w (cubeEnumeration d j) ≤ 1/4) π draw}) ≤ δ := by
  classical
  have hm : (0:ℝ) < cubeSize d := by exact_mod_cast Fintype.card_pos
  have hm2 : (2:ℝ) ≤ cubeSize d := by exact_mod_cast cube_card_ge_two d hd
  have hε : 0 < (2:ℝ)/cubeSize d := by positivity
  have hε1 : (2:ℝ)/cubeSize d ≤ 1 := (div_le_one hm).mpr hm2
  let P := balancedMergingCoverProcess hd hC B hCN hc0 hσ hscale hε hε1 noiseMargin globalMargin
  have hcard := balancedMergingOnline_card d C r c0
  have hb := actual_posterior_draw_tail Fintype.card_pos P
    (balancedMergingPrefixPosterior (N := N) (r := r) noiseMargin globalMargin c0 σ B.computes)
    (balanced_mergingPrefix_probability hd hC B hCN hc0 hσ hscale noiseMargin globalMargin)
    (fun w j => labelReal (B.computes (cubeEnumeration d j))*networkOutput Real.tanh w (cubeEnumeration d j) ≤ 1/4)
    (fun j => measurableSet_le
      ((continuous_networkOutput tanh_continuous (cubeEnumeration d j)).measurable.const_mul _) measurable_const)
    (fun _ _ => rfl) (balancedMergingOnlineEntropy d C r c0) δ
    (balancedMergingOnlineEntropy_nonneg d C r c0) (by positivity) hδ hδ1 hcard
  have he : (cubeSize d:ℝ)*((2/(cubeSize d:ℝ))/2)=1 := by field_simp
  rw [he] at hb
  convert hb using 1 <;> congr 3 <;> ring

#print axioms balanced_merging_online_sampled_tail
end NeuralGeneralization.BatchTwoOnlineBalanced
