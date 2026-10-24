import NeuralGeneralization.BatchTwoOnlineMergingProcess
import NeuralGeneralization.BatchTwoOnlineRawGeneral
import NeuralGeneralization.BatchTwoOnlinePolynomial

/-! A depth-polynomial cumulative tested-margin guarantee for the literal
merging-restricted ReLU posterior, at every width and finite scale. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineRaw
open ConcreteModel BatchTwoMerging BatchTwoOnline SquaredSampling

variable {d C r N : ℕ}

def mergingPermutationRisk (globalMargin : Bool) (σ : ℝ) (f : BooleanFunction d)
    (π : Equiv.Perm (Fin (cubeSize d))) : ℝ :=
  ∑i,mergingRoundRisk (N:=N) (r:=r) globalMargin σ f i π

def mergingOnlineCapacity (d C r : ℕ) : ℝ :=
  1000000000000000000000000*(C:ℝ)^2*(5+2*(d:ℝ)+r)^9

theorem merging_online_grid_capacity (hd : 0<d) (hC : 0<C) (hp : C≤2^r+1) :
    Real.log (Fintype.card (MainGridCode d C r (2/(cubeSize d : ℝ))):ℝ)≤mergingOnlineCapacity d C r := by
  let S : ℝ := 5+2*(d:ℝ)+r
  have hd0 : (0:ℝ)≤d := Nat.cast_nonneg _
  have hr0 : (0:ℝ)≤r := Nat.cast_nonneg _
  have hm : (0:ℝ)<cubeSize d := by exact_mod_cast Fintype.card_pos
  have hm2 : (2:ℝ)≤cubeSize d := by exact_mod_cast cube_card_ge_two d hd
  have hε : 0<(2:ℝ)/cubeSize d := by positivity
  have hε1 : (2:ℝ)/cubeSize d≤1 := (div_le_one hm).mpr hm2
  have hlogm : Real.log (cubeSize d : ℝ)=(d:ℝ)*Real.log 2 := by
    rw [cubeSize,cube_card_eq]
    simp only [Nat.cast_pow,Nat.cast_ofNat,Real.log_pow]
  have hl2 : Real.log 2≤1 := by have hh:=Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2);norm_num at hh;exact hh
  have hlogε : -Real.log (((2:ℝ)/cubeSize d)/4)≤S := by
    have he : (2/(cubeSize d : ℝ))/4=(2*(cubeSize d : ℝ))⁻¹ := by field_simp;ring
    rw [he,Real.log_inv,neg_neg,Real.log_mul (by norm_num) hm.ne',hlogm]
    have hh:=mul_le_mul_of_nonneg_left hl2 hd0
    dsimp only [S]
    linarith
  exact mainGrid_log_card_le (S:=S) hC (by dsimp only [S];linarith)
    (by dsimp only [S];linarith)
    (by dsimp only [S];linarith)
    ((pruned_log_width hC hp).trans (by dsimp only [S];linarith))
    hlogε hε hε1

/-- Every Boolean teacher width C, every learner width N≥C, every Nσ²≤1,
and either choice of optional global margin conditioning. The displayed
capacity is exactly quadratic in C and polynomial in input dimension and depth. -/
theorem merging_online_expected (hd : 0<d) (hC : 0<C) (B : LayeredNorCircuit d C r)
    (hCN : C≤N) {σ : ℝ} (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) (globalMargin : Bool) :
    finiteMean (mergingPermutationRisk (N:=N) (r:=r) globalMargin σ B.computes)≤
      2+2*(mergingOnlineCapacity d C r+1)*harmonicSum (cubeSize d-1) := by
  classical
  obtain ⟨C',B',hCp,hCC,hprune,hf⟩:=B.exists_same_depth_pruning
  have hm : (0:ℝ)<cubeSize d := by exact_mod_cast Fintype.card_pos
  have hm2 : (2:ℝ)≤cubeSize d := by exact_mod_cast cube_card_ge_two d hd
  have hε : 0<(2:ℝ)/cubeSize d := by positivity
  have hε1 : (2:ℝ)/cubeSize d≤1 := (div_le_one hm).mpr hm2
  let P:=mergingCoverProcess hd hCp B' (hCC.trans hCN) hσ hscale hε hε1 globalMargin
  have hcap : Real.log (Fintype.card (MainGridCode d C' r (2/(cubeSize d : ℝ))):ℝ)≤mergingOnlineCapacity d C r := by
    apply (merging_online_grid_capacity hd hCp hprune).trans
    unfold mergingOnlineCapacity
    gcongr
  have hcard : ((Finset.univ : Finset (MainGridCode d C' r (2/(cubeSize d : ℝ)))).card:ℝ)≤
      Real.exp (mergingOnlineCapacity d C r) := by
    simp only [Finset.card_univ]
    by_cases hz : Fintype.card (MainGridCode d C' r (2/(cubeSize d : ℝ)))=0
    · simp only [hz,Nat.cast_zero]
      exact (Real.exp_pos _).le
    · exact (Real.exp_log (by exact_mod_cast Nat.pos_of_ne_zero hz : (0:ℝ)<Fintype.card
        (MainGridCode d C' r (2/(cubeSize d : ℝ))))).symm.le.trans (Real.exp_le_exp.mpr hcap)
  have hb:=expected_total_general Fintype.card_pos P (mergingOnlineCapacity d C r)
    (by unfold mergingOnlineCapacity;positivity) (by positivity) hcard
  have he : (cubeSize d : ℝ)*((2/(cubeSize d : ℝ))/2)=1 := by field_simp
  rw [he] at hb
  change finiteMean (mergingPermutationRisk (N:=N) (r:=r) globalMargin σ B'.computes) ≤ _ at hb
  rw [hf] at hb
  linarith

theorem merging_online_expected_polynomial (hd : 0<d) (hC : 0<C) (B : LayeredNorCircuit d C r)
    (hCN : C≤N) {σ : ℝ} (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) (globalMargin : Bool) :
    finiteMean (mergingPermutationRisk (N:=N) (r:=r) globalMargin σ B.computes)≤
      2+2*(mergingOnlineCapacity d C r+1)*(1+(d:ℝ)) := by
  apply (merging_online_expected hd hC B hCN hσ hscale globalMargin).trans
  have hcoef : 0≤2*(mergingOnlineCapacity d C r+1) := by unfold mergingOnlineCapacity;positivity
  simpa only [add_comm] using add_le_add_left (mul_le_mul_of_nonneg_left (cube_harmonic_le_dimension d hd) hcoef) 2

theorem merging_online_high_probability (hd : 0<d) (hC : 0<C) (B : LayeredNorCircuit d C r)
    (hCN : C≤N) {σ δ : ℝ} (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) (globalMargin : Bool)
    (hδ : 0<δ) (hδ1 : δ<1) :
    finiteEvent (fun π => (Real.exp 1-1)*(2+2*(mergingOnlineCapacity d C r+
      Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ)<
      mergingPermutationRisk (N:=N) (r:=r) globalMargin σ B.computes π)≤δ := by
  classical
  obtain ⟨C',B',hCp,hCC,hprune,hf⟩:=B.exists_same_depth_pruning
  have hm : (0:ℝ)<cubeSize d := by exact_mod_cast Fintype.card_pos
  have hm2 : (2:ℝ)≤cubeSize d := by exact_mod_cast cube_card_ge_two d hd
  have hε : 0<(2:ℝ)/cubeSize d := by positivity
  have hε1 : (2:ℝ)/cubeSize d≤1 := (div_le_one hm).mpr hm2
  let P:=mergingCoverProcess hd hCp B' (hCC.trans hCN) hσ hscale hε hε1 globalMargin
  have hcap : Real.log (Fintype.card (MainGridCode d C' r (2/(cubeSize d : ℝ))):ℝ)≤mergingOnlineCapacity d C r := by
    apply (merging_online_grid_capacity hd hCp hprune).trans
    unfold mergingOnlineCapacity
    gcongr
  have hcard : ((Finset.univ : Finset (MainGridCode d C' r (2/(cubeSize d : ℝ)))).card:ℝ)≤
      Real.exp (mergingOnlineCapacity d C r) := by
    simp only [Finset.card_univ]
    by_cases hz : Fintype.card (MainGridCode d C' r (2/(cubeSize d : ℝ)))=0
    · simp only [hz,Nat.cast_zero]
      exact (Real.exp_pos _).le
    · exact (Real.exp_log (by exact_mod_cast Nat.pos_of_ne_zero hz : (0:ℝ)<Fintype.card
        (MainGridCode d C' r (2/(cubeSize d : ℝ))))).symm.le.trans (Real.exp_le_exp.mpr hcap)
  have hb:=total_high_probability_general Fintype.card_pos P (mergingOnlineCapacity d C r) δ
    (by unfold mergingOnlineCapacity;positivity) (by positivity) hδ hδ1 hcard
  have he : (cubeSize d : ℝ)*((2/(cubeSize d : ℝ))/2)=1 := by field_simp
  rw [he] at hb
  change finiteEvent (fun π => (Real.exp 1-1)*(1+2*(mergingOnlineCapacity d C r+
      Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1)+1)+Real.log (2/δ)<
      mergingPermutationRisk (N:=N) (r:=r) globalMargin σ B'.computes π)≤δ at hb
  rw [hf] at hb
  convert hb using 1 <;> congr 2 <;> ring

end NeuralGeneralization.BatchTwoOnlineRaw
