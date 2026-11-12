import NeuralGeneralization.BatchTwoOnlineBalancedSets
import NeuralGeneralization.BatchTwoOnlineRawIID

/-! Infinite uniform IID input streams inherit the same polynomial cumulative
posterior-risk bounds. Repeated points have exactly zero tested-margin risk. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging BatchTwoOnlineTanhMerging BatchTwoOnline BatchTwoOnlineRaw SquaredSampling
variable {d C r N : ℕ}

theorem balanced_merging_iid_expected (hd : 0<d) (hC : 0<C) (B : LayeredBooleanCircuit d C r)
    (hCN : C ≤ N) {c0 σ : ℝ} (hc0 : 0<c0) (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool) :
    (∫⁻s,streamTotal (balancedMergingSetRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes) s
      ∂iidQueryLaw (Fin (cubeSize d)))≤
      ENNReal.ofReal (2+2*(balancedMergingOnlineEntropy d C r c0+1)*(1+(d:ℝ))) := by
  have hh:=iid_expected_streamTotal Fintype.card_pos
    (balancedMergingSetRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes)
    (balanced_mergingSetRisk_nonneg noiseMargin globalMargin c0 σ B.computes)
    (balanced_mergingSetRisk_repeated noiseMargin globalMargin hc0 σ B.computes)
  rw [balanced_setPermutationRisk_merging] at hh
  exact hh.trans (ENNReal.ofReal_le_ofReal (balanced_merging_online_dimension_bound hd hC B hCN hc0 hσ hscale noiseMargin globalMargin))

theorem balanced_merging_iid_high_probability (hd : 0<d) (hC : 0<C) (B : LayeredBooleanCircuit d C r)
    (hCN : C ≤ N) {c0 σ δ : ℝ} (hc0 : 0<c0) (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool)
    (hδ : 0<δ) (hδ1 : δ<1) :
    iidQueryLaw (Fin (cubeSize d)) {s | ENNReal.ofReal ((Real.exp 1-1)*
      (2+2*(balancedMergingOnlineEntropy d C r c0+Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+
      Real.log (2/δ))<streamTotal (balancedMergingSetRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes) s}≤
      ENNReal.ofReal δ := by
  let U:ℝ:=(Real.exp 1-1)*(2+2*(balancedMergingOnlineEntropy d C r c0+
    Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ)
  have hm:(1:ℝ)≤cubeSize d:=by exact_mod_cast (Fintype.card_pos : 0<Fintype.card (Cube d))
  have hc:0≤balancedMergingOnlineEntropy d C r c0:=balancedMergingOnlineEntropy_nonneg d C r c0
  have hl:0≤Real.log (2*(cubeSize d:ℝ)/δ):=Real.log_nonneg ((one_le_div hδ).mpr (by nlinarith))
  have hl2:0≤Real.log (2/δ):=Real.log_nonneg ((one_le_div hδ).mpr (by linarith))
  have he:0≤Real.exp 1-1:=by linarith [Real.add_one_le_exp (1:ℝ)]
  have hH:=harmonicSum_nonneg (cubeSize d-1)
  have hU:0≤U:=by dsimp [U];positivity
  have hh:=iid_streamTotal_tail Fintype.card_pos
    (balancedMergingSetRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes)
    (balanced_mergingSetRisk_nonneg noiseMargin globalMargin c0 σ B.computes)
    (balanced_mergingSetRisk_repeated noiseMargin globalMargin hc0 σ B.computes) U hU
  rw [balanced_setPermutationRisk_merging] at hh
  exact hh.trans (ENNReal.ofReal_le_ofReal (balanced_merging_online_high_probability hd hC B hCN hc0 hσ hscale noiseMargin globalMargin hδ hδ1))

end NeuralGeneralization.BatchTwoOnlineBalanced
