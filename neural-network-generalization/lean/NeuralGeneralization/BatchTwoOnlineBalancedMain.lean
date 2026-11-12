import NeuralGeneralization.BatchTwoOnlineBalancedProcess
import NeuralGeneralization.BatchTwoOnlineRawGeneral
import NeuralGeneralization.BatchTwoOnlinePolynomial

/-! Uniform-permutation mistake bounds for the literal balanced-tanh posterior. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging BatchTwoOnlineTanhMerging BatchTwoOnline BatchTwoOnlineRaw SquaredSampling
variable {d C r N : ℕ}

def balancedMergingPermutationRisk (noiseMargin globalMargin : Bool) (c0 σ : ℝ) (f : BooleanFunction d)
    (π : Equiv.Perm (Fin (cubeSize d))) : ℝ :=
  ∑i,balancedMergingRoundRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ f i π

def balancedMergingOnlineEntropy (d C r : ℕ) (c0 : ℝ) : ℝ :=
  Real.log (Fintype.card (BalancedMainGridCode d C r c0 (2/(cubeSize d:ℝ))):ℝ)

theorem balancedMergingOnlineEntropy_nonneg (d C r : ℕ) (c0 : ℝ) :
    0≤balancedMergingOnlineEntropy d C r c0 := by
  classical
  letI : Nonempty (BalancedMainGridCode d C r c0 (2/(cubeSize d:ℝ))) := ⟨fun _=>⟨0,by simp⟩⟩
  apply Real.log_nonneg
  exact_mod_cast Fintype.card_pos

theorem balancedMergingOnline_card (d C r : ℕ) (c0 : ℝ) :
    ((Finset.univ : Finset (BalancedMainGridCode d C r c0 (2/(cubeSize d:ℝ)))).card:ℝ)≤
      Real.exp (balancedMergingOnlineEntropy d C r c0) := by
  classical
  letI : Nonempty (BalancedMainGridCode d C r c0 (2/(cubeSize d:ℝ))) := ⟨fun _=>⟨0,by simp⟩⟩
  simp only [Finset.card_univ,balancedMergingOnlineEntropy]
  exact (Real.exp_log (by exact_mod_cast Fintype.card_pos)).symm.le

theorem balanced_merging_online_expected (hd : 0<d) (hC : 0<C) (B : LayeredBooleanCircuit d C r)
    (hCN : C≤N) {c0 σ : ℝ} (hc0 : 0<c0) (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    (noiseMargin globalMargin : Bool) :
    finiteMean (balancedMergingPermutationRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes)≤
      2+2*(balancedMergingOnlineEntropy d C r c0+1)*harmonicSum (cubeSize d-1) := by
  classical
  have hm : (0:ℝ)<cubeSize d := by exact_mod_cast Fintype.card_pos
  have hm2 : (2:ℝ)≤cubeSize d := by exact_mod_cast cube_card_ge_two d hd
  have hε : 0<(2:ℝ)/cubeSize d := by positivity
  have hε1 : (2:ℝ)/cubeSize d≤1 := (div_le_one hm).mpr hm2
  let P := balancedMergingCoverProcess hd hC B hCN hc0 hσ hscale hε hε1 noiseMargin globalMargin
  have hb := expected_total_general Fintype.card_pos P (balancedMergingOnlineEntropy d C r c0)
    (balancedMergingOnlineEntropy_nonneg d C r c0) (by positivity) (balancedMergingOnline_card d C r c0)
  have he : (cubeSize d:ℝ)*((2/(cubeSize d:ℝ))/2)=1 := by field_simp
  rw [he] at hb
  change finiteMean (balancedMergingPermutationRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes)≤_ at hb
  linarith

theorem balanced_merging_online_dimension_bound (hd : 0<d) (hC : 0<C) (B : LayeredBooleanCircuit d C r)
    (hCN : C≤N) {c0 σ : ℝ} (hc0 : 0<c0) (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    (noiseMargin globalMargin : Bool) :
    finiteMean (balancedMergingPermutationRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes)≤
      2+2*(balancedMergingOnlineEntropy d C r c0+1)*(1+(d:ℝ)) := by
  apply (balanced_merging_online_expected hd hC B hCN hc0 hσ hscale noiseMargin globalMargin).trans
  have hcoef : 0≤2*(balancedMergingOnlineEntropy d C r c0+1) := by
    linarith [balancedMergingOnlineEntropy_nonneg d C r c0]
  simpa only [add_comm] using add_le_add_left
    (mul_le_mul_of_nonneg_left (cube_harmonic_le_dimension d hd) hcoef) 2

theorem balanced_merging_online_high_probability (hd : 0<d) (hC : 0<C) (B : LayeredBooleanCircuit d C r)
    (hCN : C≤N) {c0 σ δ : ℝ} (hc0 : 0<c0) (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    (noiseMargin globalMargin : Bool) (hδ : 0<δ) (hδ1 : δ<1) :
    finiteEvent (fun π=>(Real.exp 1-1)*(2+2*(balancedMergingOnlineEntropy d C r c0+
      Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ)<
      balancedMergingPermutationRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes π)≤δ := by
  classical
  have hm : (0:ℝ)<cubeSize d := by exact_mod_cast Fintype.card_pos
  have hm2 : (2:ℝ)≤cubeSize d := by exact_mod_cast cube_card_ge_two d hd
  have hε : 0<(2:ℝ)/cubeSize d := by positivity
  have hε1 : (2:ℝ)/cubeSize d≤1 := (div_le_one hm).mpr hm2
  let P := balancedMergingCoverProcess hd hC B hCN hc0 hσ hscale hε hε1 noiseMargin globalMargin
  have hb := total_high_probability_general Fintype.card_pos P (balancedMergingOnlineEntropy d C r c0) δ
    (balancedMergingOnlineEntropy_nonneg d C r c0) (by positivity) hδ hδ1 (balancedMergingOnline_card d C r c0)
  have he : (cubeSize d:ℝ)*((2/(cubeSize d:ℝ))/2)=1 := by field_simp
  rw [he] at hb
  change finiteEvent (fun π=>(Real.exp 1-1)*(1+2*(balancedMergingOnlineEntropy d C r c0+
    Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1)+1)+Real.log (2/δ)<
    balancedMergingPermutationRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes π)≤δ at hb
  convert hb using 1 <;> congr 2 <;> ring

end NeuralGeneralization.BatchTwoOnlineBalanced
