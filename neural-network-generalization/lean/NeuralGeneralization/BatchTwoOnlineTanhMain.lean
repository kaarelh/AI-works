import NeuralGeneralization.BatchTwoOnlineTanhProcess
import NeuralGeneralization.BatchTwoOnlineRawGeneral
import NeuralGeneralization.BatchTwoOnlinePolynomial

/-! Uniform-permutation mistake bounds for the literal signed-tanh posterior. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel BatchTwoMerging BatchTwoOnline BatchTwoOnlineRaw SquaredSampling
variable {d C r N : ℕ}

def tanhMergingPermutationRisk (noiseMargin globalMargin : Bool) (c0 σ : ℝ) (f : BooleanFunction d)
    (π : Equiv.Perm (Fin (cubeSize d))) : ℝ :=
  ∑i,tanhMergingRoundRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ f i π

def tanhMergingOnlineEntropy (d C r : ℕ) (c0 : ℝ) : ℝ :=
  Real.log (Fintype.card (TanhMainGridCode d C r c0 (2/(cubeSize d:ℝ))):ℝ)

theorem tanhMergingOnlineEntropy_nonneg (d C r : ℕ) (c0 : ℝ) :
    0≤tanhMergingOnlineEntropy d C r c0 := by
  classical
  letI : Nonempty (TanhMainGridCode d C r c0 (2/(cubeSize d:ℝ))) := ⟨fun _=>⟨0,by simp⟩⟩
  apply Real.log_nonneg
  exact_mod_cast Fintype.card_pos

theorem tanhMergingOnline_card (d C r : ℕ) (c0 : ℝ) :
    ((Finset.univ : Finset (TanhMainGridCode d C r c0 (2/(cubeSize d:ℝ)))).card:ℝ)≤
      Real.exp (tanhMergingOnlineEntropy d C r c0) := by
  classical
  letI : Nonempty (TanhMainGridCode d C r c0 (2/(cubeSize d:ℝ))) := ⟨fun _=>⟨0,by simp⟩⟩
  simp only [Finset.card_univ,tanhMergingOnlineEntropy]
  exact (Real.exp_log (by exact_mod_cast Fintype.card_pos)).symm.le

theorem tanh_merging_online_expected (hd : 0<d) (hC : 0<C) (B : LayeredBooleanCircuit d C r)
    (hCN : C≤N) {c0 σ : ℝ} (hc0 : 0<c0) (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    (noiseMargin globalMargin : Bool) :
    finiteMean (tanhMergingPermutationRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes)≤
      2+2*(tanhMergingOnlineEntropy d C r c0+1)*harmonicSum (cubeSize d-1) := by
  classical
  have hm : (0:ℝ)<cubeSize d := by exact_mod_cast Fintype.card_pos
  have hm2 : (2:ℝ)≤cubeSize d := by exact_mod_cast cube_card_ge_two d hd
  have hε : 0<(2:ℝ)/cubeSize d := by positivity
  have hε1 : (2:ℝ)/cubeSize d≤1 := (div_le_one hm).mpr hm2
  let P := tanhMergingCoverProcess hd hC B hCN hc0 hσ hscale hε hε1 noiseMargin globalMargin
  have hb := expected_total_general Fintype.card_pos P (tanhMergingOnlineEntropy d C r c0)
    (tanhMergingOnlineEntropy_nonneg d C r c0) (by positivity) (tanhMergingOnline_card d C r c0)
  have he : (cubeSize d:ℝ)*((2/(cubeSize d:ℝ))/2)=1 := by field_simp
  rw [he] at hb
  change finiteMean (tanhMergingPermutationRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes)≤_ at hb
  linarith

theorem tanh_merging_online_dimension_bound (hd : 0<d) (hC : 0<C) (B : LayeredBooleanCircuit d C r)
    (hCN : C≤N) {c0 σ : ℝ} (hc0 : 0<c0) (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    (noiseMargin globalMargin : Bool) :
    finiteMean (tanhMergingPermutationRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes)≤
      2+2*(tanhMergingOnlineEntropy d C r c0+1)*(1+(d:ℝ)) := by
  apply (tanh_merging_online_expected hd hC B hCN hc0 hσ hscale noiseMargin globalMargin).trans
  have hcoef : 0≤2*(tanhMergingOnlineEntropy d C r c0+1) := by
    linarith [tanhMergingOnlineEntropy_nonneg d C r c0]
  simpa only [add_comm] using add_le_add_left
    (mul_le_mul_of_nonneg_left (cube_harmonic_le_dimension d hd) hcoef) 2

theorem tanh_merging_online_high_probability (hd : 0<d) (hC : 0<C) (B : LayeredBooleanCircuit d C r)
    (hCN : C≤N) {c0 σ δ : ℝ} (hc0 : 0<c0) (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    (noiseMargin globalMargin : Bool) (hδ : 0<δ) (hδ1 : δ<1) :
    finiteEvent (fun π=>(Real.exp 1-1)*(2+2*(tanhMergingOnlineEntropy d C r c0+
      Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ)<
      tanhMergingPermutationRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes π)≤δ := by
  classical
  have hm : (0:ℝ)<cubeSize d := by exact_mod_cast Fintype.card_pos
  have hm2 : (2:ℝ)≤cubeSize d := by exact_mod_cast cube_card_ge_two d hd
  have hε : 0<(2:ℝ)/cubeSize d := by positivity
  have hε1 : (2:ℝ)/cubeSize d≤1 := (div_le_one hm).mpr hm2
  let P := tanhMergingCoverProcess hd hC B hCN hc0 hσ hscale hε hε1 noiseMargin globalMargin
  have hb := total_high_probability_general Fintype.card_pos P (tanhMergingOnlineEntropy d C r c0) δ
    (tanhMergingOnlineEntropy_nonneg d C r c0) (by positivity) hδ hδ1 (tanhMergingOnline_card d C r c0)
  have he : (cubeSize d:ℝ)*((2/(cubeSize d:ℝ))/2)=1 := by field_simp
  rw [he] at hb
  change finiteEvent (fun π=>(Real.exp 1-1)*(1+2*(tanhMergingOnlineEntropy d C r c0+
    Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1)+1)+Real.log (2/δ)<
    tanhMergingPermutationRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes π)≤δ at hb
  convert hb using 1 <;> congr 2 <;> ring

end NeuralGeneralization.BatchTwoOnlineTanhMerging
