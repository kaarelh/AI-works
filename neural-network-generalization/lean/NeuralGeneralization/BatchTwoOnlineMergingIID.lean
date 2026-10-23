import NeuralGeneralization.BatchTwoOnlineMergingSets
import NeuralGeneralization.BatchTwoOnlineRawIID

/-! Infinite uniform IID input streams inherit the same polynomial cumulative
posterior-risk bounds. Repeated points have exactly zero tested-margin risk. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoOnlineRaw
open ConcreteModel BatchTwoMerging BatchTwoOnline SquaredSampling
variable {d C r N : ℕ}

theorem merging_iid_expected (hd : 0<d) (hC : 0<C) (B : LayeredNorCircuit d C r)
    (hCN : C≤N) {σ : ℝ} (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) (globalMargin : Bool) :
    (∫⁻s,streamTotal (mergingSetRisk (N:=N) (r:=r) globalMargin σ B.computes) s
      ∂iidQueryLaw (Fin (cubeSize d)))≤
      ENNReal.ofReal (2+2*(mergingOnlineCapacity d C r+1)*(1+(d:ℝ))) := by
  have hh:=iid_expected_streamTotal Fintype.card_pos
    (mergingSetRisk (N:=N) (r:=r) globalMargin σ B.computes)
    (mergingSetRisk_nonneg globalMargin σ B.computes)
    (mergingSetRisk_repeated globalMargin σ B.computes)
  rw [setPermutationRisk_merging] at hh
  exact hh.trans (ENNReal.ofReal_le_ofReal (merging_online_expected_polynomial hd hC B hCN hσ hscale globalMargin))

theorem merging_iid_high_probability (hd : 0<d) (hC : 0<C) (B : LayeredNorCircuit d C r)
    (hCN : C≤N) {σ δ : ℝ} (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) (globalMargin : Bool)
    (hδ : 0<δ) (hδ1 : δ<1) :
    iidQueryLaw (Fin (cubeSize d)) {s | ENNReal.ofReal ((Real.exp 1-1)*
      (2+2*(mergingOnlineCapacity d C r+Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+
      Real.log (2/δ))<streamTotal (mergingSetRisk (N:=N) (r:=r) globalMargin σ B.computes) s}≤
      ENNReal.ofReal δ := by
  let U:ℝ:=(Real.exp 1-1)*(2+2*(mergingOnlineCapacity d C r+
    Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ)
  have hm:(1:ℝ)≤cubeSize d:=by exact_mod_cast (Fintype.card_pos : 0<Fintype.card (Cube d))
  have hc:0≤mergingOnlineCapacity d C r:=by unfold mergingOnlineCapacity;positivity
  have hl:0≤Real.log (2*(cubeSize d:ℝ)/δ):=Real.log_nonneg ((one_le_div hδ).mpr (by nlinarith))
  have hl2:0≤Real.log (2/δ):=Real.log_nonneg ((one_le_div hδ).mpr (by linarith))
  have he:0≤Real.exp 1-1:=by linarith [Real.add_one_le_exp (1:ℝ)]
  have hH:=harmonicSum_nonneg (cubeSize d-1)
  have hU:0≤U:=by dsimp [U];positivity
  have hh:=iid_streamTotal_tail Fintype.card_pos
    (mergingSetRisk (N:=N) (r:=r) globalMargin σ B.computes)
    (mergingSetRisk_nonneg globalMargin σ B.computes)
    (mergingSetRisk_repeated globalMargin σ B.computes) U hU
  rw [setPermutationRisk_merging] at hh
  exact hh.trans (ENNReal.ofReal_le_ofReal (merging_online_high_probability hd hC B hCN hσ hscale globalMargin hδ hδ1))

end NeuralGeneralization.BatchTwoOnlineRaw
