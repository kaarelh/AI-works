import NeuralGeneralization.BatchTwoManuscriptLiteralLearning
import NeuralGeneralization.BatchTwoManuscriptTargetGrowth
import NeuralGeneralization.BatchTwoManuscriptResourceWidthGrowth

/-! The literal D_*/J sample allocation has C^6 log^13(2+C) growth. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
open Filter Asymptotics
namespace NeuralGeneralization.BatchTwoManuscriptLearning
open ConcreteModel BatchTwoMerging BatchTwoManuscriptTarget

def widthFamily (d L : ℕ) (c ε : ℝ) (hd : 0<d) (hL : 2≤L)
    (hc : 0<c) (hε : 0<ε) (hε1 : ε≤1) (C : ℕ) : Input :=
  literalCircuitInput d (max 1 C) L c ε hd hL (by omega) hc hε hε1

variable {d L : ℕ} {c ε : ℝ}
  (hd : 0<d) (hL : 2≤L) (hc : 0<c) (hε : 0<ε) (hε1 : ε≤1)

include hd hL hc hε hε1 in
theorem literal_cost_width_growth :
    WidthGrowth (fun C=>(widthFamily d L c ε hd hL hc hε hε1 C).targetCost) 1 2 := by
  exact (targetCost_width_growth d (L-2) hc.le).congr (by
    intro C hC
    simp only [widthFamily,literalCircuitInput,max_eq_right hC])

include hd hL hc hε hε1 in
theorem literal_readout_width_growth :
    WidthGrowth (fun C=>posteriorReadoutBound (widthFamily d L c ε hd hL hc hε hε1 C)) 1 2 := by
  have hh := ((literal_cost_width_growth hd hL hc hε hε1).add
    ((WidthGrowth.const (Real.log (4/ε))).mono (by omega) (by omega))).const_mul 8
  exact ((WidthGrowth.const 8).mono (by omega) (by omega) |>.max_growth hh).congr (by
    intro C _
    unfold posteriorReadoutBound discardedMass widthFamily literalCircuitInput
    congr 2
    congr 1
    field_simp)

include hd hL hc hε hε1 in
theorem literal_radiusSq_width_growth :
    WidthGrowth (fun C=>(compressionInput (widthFamily d L c ε hd hL hc hε hε1 C)).radius⁻¹^2) 1 2 := by
  let p := widthFamily d L c ε hd hL hc hε hε1
  have hQ := ((WidthGrowth.const 1).mono (by omega) (by omega)).add
    ((literal_readout_width_growth hd hL hc hε hε1).const_mul ((L:ℝ)-1))
  have hg := ((WidthGrowth.const 36).mono (by omega) (by omega)).add (hQ.const_mul (c⁻¹^2))
  apply hg.nonnegative_le (fun C _=>sq_nonneg _) _
  intro C _
  have hQ0 : 0≤1+((L:ℝ)-1)*posteriorReadoutBound (p C) := by
    have hl : (2:ℝ)≤L := by exact_mod_cast hL
    have hb := posteriorReadoutBound_ge_eight (p C)
    nlinarith [mul_nonneg (show 0≤(L:ℝ)-1 by linarith) (show 0≤posteriorReadoutBound (p C) by linarith)]
  change (min (1/6) (c/Real.sqrt (1+((L:ℝ)-1)*posteriorReadoutBound (p C))))⁻¹^2≤_
  rcases le_total (1/6:ℝ) (c/Real.sqrt (1+((L:ℝ)-1)*posteriorReadoutBound (p C))) with h|h
  · rw [min_eq_left h]
    norm_num
    exact mul_nonneg (inv_nonneg.mpr (sq_nonneg c)) hQ0
  · rw [min_eq_right h,inv_div,div_pow,Real.sq_sqrt hQ0]
    change (1+((L:ℝ)-1)*posteriorReadoutBound (p C))/c^2≤
      36+c⁻¹^2*(1+((L:ℝ)-1)*posteriorReadoutBound (p C))
    rw [div_eq_mul_inv,inv_pow]
    nlinarith

include hd hL hc hε hε1 in
theorem literal_entropy_width_growth :
    WidthGrowth (fun C=>entropy (widthFamily d L c ε hd hL hc hε hε1 C)) 6 13 := by
  apply BatchTwoManuscriptResources.gridEntropy_width_growth (d:=d) (L:=L)
    (p:=fun C=>compressionInput (widthFamily d L c ε hd hL hc hε hε1 C))
    (fun _=>rfl) (fun _=>rfl)
  · exact (WidthGrowth.const (12/ε)).congr (by
      intro C _
      dsimp [compressionInput,widthFamily,literalCircuitInput]
      field_simp)
  · exact (literal_cost_width_growth hd hL hc hε hε1).add
      ((WidthGrowth.const 1).mono (by omega) (by omega))
  · exact literal_radiusSq_width_growth hd hL hc hε hε1

include hd hL hc hε hε1 in
theorem literal_entropy_isBigO :
    (fun C=>entropy (widthFamily d L c ε hd hL hc hε hε1 C)) =O[atTop]
      (fun C=>(C:ℝ)^6*Real.log ((C:ℝ)+2)^13) :=
  (literal_entropy_width_growth hd hL hc hε hε1).isBigO

include hd hL hc hε hε1 in
theorem literal_sample_budget_isBigO (δ : ℝ) :
    (fun C=>16/ε*(entropy (widthFamily d L c ε hd hL hc hε hε1 C)+Real.log (1/δ))) =O[atTop]
      (fun C=>(C:ℝ)^6*Real.log ((C:ℝ)+2)^13) :=
  (((literal_entropy_width_growth hd hL hc hε hε1).add
    ((WidthGrowth.const (Real.log (1/δ))).mono (by omega) (by omega))).const_mul (16/ε)).isBigO

end NeuralGeneralization.BatchTwoManuscriptLearning
