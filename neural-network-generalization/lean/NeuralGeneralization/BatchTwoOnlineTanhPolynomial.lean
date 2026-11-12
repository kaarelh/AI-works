import NeuralGeneralization.BatchTwoOnlineTanhEntropy
import NeuralGeneralization.BatchTwoOnlineTanhMain
import NeuralGeneralization.BatchTwoOnlineTanhLearning

/-! Joint polynomial-depth and quadratic-width budgets for the actual signed-tanh extension. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel BatchTwoMerging BatchTwoOnline BatchTwoOnlineRaw SquaredSampling

def tanhEntropyScale (d C r : ℕ) (c0 ε : ℝ) : ℝ :=
  10000000000+4100*(c0+1)+4*Real.log (C:ℝ)+(d:ℝ)+(r:ℝ)-Real.log (ε/4)

def tanhPolynomialEntropy (d C r : ℕ) (c0 ε : ℝ) : ℝ :=
  10000000000000000000000000000*(C:ℝ)^2*(tanhEntropyScale d C r c0 ε)^9

theorem tanh_grid_entropy_polynomial {d C r : ℕ} (hC : 0<C) {c0 ε : ℝ}
    (hc0 : 0<c0) (hε : 0<ε) (hε1 : ε≤1) :
    Real.log (Fintype.card (TanhMainGridCode d C r c0 ε):ℝ)≤tanhPolynomialEntropy d C r c0 ε := by
  have hlogC : 0≤Real.log (C:ℝ) := Real.log_nonneg (by exact_mod_cast hC)
  have hlogε : Real.log (ε/4)≤0 := Real.log_nonpos (by positivity) (by linarith)
  have hd : (0:ℝ)≤d := Nat.cast_nonneg _
  have hr : (0:ℝ)≤r := Nat.cast_nonneg _
  apply tanhMainGrid_log_card_le hC c0 hc0.le
  all_goals try {dsimp [tanhEntropyScale]; linarith}
  · exact hε
  · exact hε1

def tanhOnlineScale (d C r : ℕ) (c0 : ℝ) : ℝ :=
  10000000000+4100*(c0+1)+4*Real.log (C:ℝ)+2*(d:ℝ)+(r:ℝ)+2

def tanhMergingOnlineCapacity (d C r : ℕ) (c0 : ℝ) : ℝ :=
  10000000000000000000000000000*(C:ℝ)^2*(tanhOnlineScale d C r c0)^9

theorem tanh_online_scale_pos {d C r : ℕ} (hC : 0<C) {c0 : ℝ} (hc0 : 0<c0) :
    0<tanhOnlineScale d C r c0 := by
  have hl := Real.log_nonneg (show (1:ℝ)≤C by exact_mod_cast hC)
  unfold tanhOnlineScale
  positivity

theorem tanh_online_capacity_nonneg {d C r : ℕ} (hC : 0<C) {c0 : ℝ} (hc0 : 0<c0) :
    0≤tanhMergingOnlineCapacity d C r c0 := by
  have hs := (tanh_online_scale_pos (d:=d) (r:=r) hC hc0).le
  unfold tanhMergingOnlineCapacity
  positivity

theorem tanh_online_entropy_le {d C r : ℕ} (hd : 0<d) (hC : 0<C) {c0 : ℝ} (hc0 : 0<c0) :
    tanhMergingOnlineEntropy d C r c0≤tanhMergingOnlineCapacity d C r c0 := by
  have hm : (0:ℝ)<cubeSize d := by exact_mod_cast Fintype.card_pos
  have hm2 : (2:ℝ)≤cubeSize d := by exact_mod_cast cube_card_ge_two d hd
  have hε : 0<(2:ℝ)/cubeSize d := by positivity
  have hε1 : (2:ℝ)/cubeSize d≤1 := (div_le_one hm).mpr hm2
  have hlogm : Real.log (cubeSize d:ℝ)=(d:ℝ)*Real.log 2 := by
    rw [cubeSize,cube_card_eq]
    simp only [Nat.cast_pow,Nat.cast_ofNat,Real.log_pow]
  have hlogε : -Real.log (((2:ℝ)/cubeSize d)/4)≤(d:ℝ)+1 := by
    have he : (2/(cubeSize d:ℝ))/4=(2*(cubeSize d:ℝ))⁻¹ := by field_simp; ring
    rw [he,Real.log_inv,neg_neg,Real.log_mul (by norm_num) hm.ne',hlogm]
    have hl2 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
    have hh := mul_le_mul_of_nonneg_left hl2 (Nat.cast_nonneg d : (0:ℝ)≤d)
    linarith
  have hlC : 0≤Real.log (C:ℝ) := Real.log_nonneg (by exact_mod_cast hC)
  have hd0 : (0:ℝ)≤d := Nat.cast_nonneg _
  have hr0 : (0:ℝ)≤r := Nat.cast_nonneg _
  apply tanhMainGrid_log_card_le hC c0 hc0.le
  all_goals try {dsimp [tanhOnlineScale]; linarith}
  · exact hε
  · exact hε1

/-- Quadratic in Boolean teacher width up to logarithms; polynomial in input dimension,
hidden depth, and the optional noise-radius constant, uniformly over learner width and scale. -/
theorem tanh_merging_online_expected_polynomial {d C r N : ℕ} (hd : 0<d) (hC : 0<C)
    (B : LayeredBooleanCircuit d C r) (hCN : C≤N) {c0 σ : ℝ} (hc0 : 0<c0)
    (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool) :
    finiteMean (tanhMergingPermutationRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes)≤
      2+2*(tanhMergingOnlineCapacity d C r c0+1)*(1+(d:ℝ)) := by
  apply (tanh_merging_online_dimension_bound hd hC B hCN hc0 hσ hscale noiseMargin globalMargin).trans
  have hh := mul_le_mul_of_nonneg_right (tanh_online_entropy_le (r:=r) hd hC hc0)
    (show 0≤2*(1+(d:ℝ)) by positivity)
  linarith

theorem tanh_merging_online_high_probability_polynomial {d C r N : ℕ} (hd : 0<d) (hC : 0<C)
    (B : LayeredBooleanCircuit d C r) (hCN : C≤N) {c0 σ δ : ℝ} (hc0 : 0<c0)
    (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) (noiseMargin globalMargin : Bool)
    (hδ : 0<δ) (hδ1 : δ<1) :
    finiteEvent (fun π=>(Real.exp 1-1)*(2+2*(tanhMergingOnlineCapacity d C r c0+
      Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ)<
      tanhMergingPermutationRisk (N:=N) (r:=r) noiseMargin globalMargin c0 σ B.computes π)≤δ := by
  apply le_trans (finiteEvent_mono ?_) (tanh_merging_online_high_probability hd hC B hCN hc0 hσ hscale
    noiseMargin globalMargin hδ hδ1)
  intro π hπ
  apply lt_of_le_of_lt _ hπ
  have he : 0≤Real.exp 1-1 := by linarith [Real.add_one_le_exp (1:ℝ)]
  have hh := mul_le_mul_of_nonneg_right (tanh_online_entropy_le (r:=r) hd hC hc0)
    (show 0≤(Real.exp 1-1)*2*harmonicSum (cubeSize d-1) by positivity [harmonicSum_nonneg (cubeSize d-1)])
  linarith

end NeuralGeneralization.BatchTwoOnlineTanhMerging
