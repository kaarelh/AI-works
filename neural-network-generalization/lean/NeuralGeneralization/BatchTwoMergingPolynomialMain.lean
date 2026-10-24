import NeuralGeneralization.BatchTwoMergingEntropy
import NeuralGeneralization.BatchTwoMergingPruning
import NeuralGeneralization.PowerPriorScaling

/-! The literal C² S⁹ learning corollary for the actual ReLU posterior. -/
noncomputable section
open scoped BigOperators
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

def totalResource (d r : ℕ) (ε : ℝ) : ℝ := 2+d+(r+2)+Real.log (4/ε)
def quadraticConstant : ℝ := 10000000000000000000000000

theorem pruned_log_width {C r : ℕ} (hC : 0<C) (hp : C≤2^r+1) :
    Real.log (C:ℝ)≤(r:ℝ)+1 := by
  have hpow : (2:ℕ)^r+1≤2^(r+1) := by
    have hh : 1≤(2:ℕ)^r := one_le_pow₀ (by norm_num)
    rw [pow_succ]
    omega
  have hbound : (C:ℝ)≤(2:ℝ)^(r+1) := by exact_mod_cast hp.trans hpow
  have hl := Real.log_le_log (by exact_mod_cast hC : (0:ℝ)<C) hbound
  rw [Real.log_pow] at hl
  have hl2 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
  have hm := mul_le_mul_of_nonneg_left hl2 (by positivity : (0:ℝ)≤r+1)
  push_cast at hl
  linarith

/-- Universal constant, polynomial in depth and exactly quadratic in Boolean
teacher width. The common sample event works for every N≥C and Nσ²≤1. -/
theorem quadratic_polynomial_depth_relu {d C r n : ℕ} (hd : 0<d) (hC : 0<C)
    (B : LayeredNorCircuit d C r) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    {ε δ : ℝ} (hε : 0<ε) (hε1 : ε<1) (hδ : 0<δ) (hδ1 : δ<1)
    (hn : quadraticConstant/ε*((C:ℝ)^2*(totalResource d r ε)^9+Real.log (1/δ))≤(n:ℝ)) :
    ∃A : Set (Fin n→Cube d), MeasurableSet A ∧
      1-δ≤(CompressionSampling.iidSamples D n).real A ∧
      ∀sample∈A,∀N,C≤N→∀σ,0<σ→(N:ℝ)*σ^2≤1→∀globalMargin : Bool,
        0<(smallPrior d N r σ).real (posteriorEvent relu globalMargin B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (posterior (N:=N) (r:=r) relu globalMargin σ B.computes sample)
          (fun x=>labelReal (B.computes x)) (fun w x=>networkOutput relu w x) (1/4)≤ε := by
  obtain ⟨C',B',hCp,hCC,hprune,hf⟩ := B.exists_same_depth_pruning
  let S := totalResource d r ε
  have hlε : 0≤Real.log (4/ε) := Real.log_nonneg ((one_le_div hε).mpr (by linarith))
  have hlδ : 0<Real.log (1/δ) := Real.log_pos ((one_lt_div hδ).mpr hδ1)
  have hd0 : (0:ℝ)≤d := Nat.cast_nonneg _
  have hr0 : (0:ℝ)≤r := Nat.cast_nonneg _
  have hS : 2≤S := by dsimp [S,totalResource]; linarith
  have hdS : (d:ℝ)+2≤S := by dsimp [S,totalResource]; linarith
  have hrS : (r:ℝ)+2≤S := by dsimp [S,totalResource]; linarith
  have hlogC : Real.log (C':ℝ)≤2*S := (pruned_log_width hCp hprune).trans (by linarith)
  have hlogε : -Real.log (ε/4)≤S := by
    have he : -Real.log (ε/4)=Real.log (4/ε) := by
      rw [Real.log_div hε.ne' (by norm_num),Real.log_div (by norm_num) hε.ne']
      ring
    rw [he]
    dsimp [S,totalResource]
    linarith
  have hent := mainGrid_log_card_le hCp hS hdS hrS hlogC hlogε hε hε1.le
  have hCCr : (C':ℝ)≤C := by exact_mod_cast hCC
  have hC2 : (C':ℝ)^2≤(C:ℝ)^2 := pow_le_pow_left₀ (Nat.cast_nonneg _) hCCr 2
  have hS0 : 0≤S := by linarith
  have hent' : Real.log (Fintype.card (MainGridCode d C' r ε):ℝ)≤
      1000000000000000000000000*(C:ℝ)^2*S^9 := by
    have hh := mul_le_mul_of_nonneg_right hC2 (pow_nonneg hS0 9)
    nlinarith
  have hpositive : 0<quadraticConstant/ε*((C:ℝ)^2*S^9+Real.log (1/δ)) := by
    unfold quadraticConstant
    positivity
  have hn0 : 0<n := by exact_mod_cast (hpositive.trans_le hn)
  have hbudget : 2*(Real.log (Fintype.card (MainGridCode d C' r ε):ℝ)+Real.log (1/δ))≤
      (n:ℝ)*(ε/2) := by
    have hh := mul_le_mul_of_nonneg_right hn hε.le
    have he : (quadraticConstant/ε*((C:ℝ)^2*S^9+Real.log (1/δ)))*ε=
        quadraticConstant*((C:ℝ)^2*S^9+Real.log (1/δ)) := by field_simp
    change (quadraticConstant/ε*((C:ℝ)^2*S^9+Real.log (1/δ)))*ε≤(n:ℝ)*ε at hh
    rw [he] at hh
    unfold quadraticConstant at hh
    nlinarith [mul_nonneg (sq_nonneg (C:ℝ)) (pow_nonneg hS0 9)]
  obtain ⟨A,hA,hprob,hgood⟩ := all_width_all_scale_relu_learning hd hCp B' D
    hε hε1.le hδ n hn0 hbudget
  refine ⟨A,hA,hprob,?_⟩
  intro sample hsample N hCN σ hσ hscale globalMargin
  simpa only [hf] using hgood sample hsample N (hCC.trans hCN) σ hσ hscale globalMargin

/-- The literal mean-field-or-stronger power scaling, including γ=1. -/
theorem quadratic_polynomial_depth_relu_power {d C r n : ℕ} (hd : 0<d) (hC : 0<C)
    (B : LayeredNorCircuit d C r) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    {ε δ : ℝ} (hε : 0<ε) (hε1 : ε<1) (hδ : 0<δ) (hδ1 : δ<1)
    (hn : quadraticConstant/ε*((C:ℝ)^2*(totalResource d r ε)^9+Real.log (1/δ))≤(n:ℝ)) :
    ∃A : Set (Fin n→Cube d), MeasurableSet A ∧
      1-δ≤(CompressionSampling.iidSamples D n).real A ∧
      ∀sample∈A,∀N,C≤N→∀γ:ℝ,1≤γ→∀globalMargin : Bool,
        0<(powerPrior d N r γ).real (posteriorEvent relu globalMargin B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (posterior (N:=N) (r:=r) relu globalMargin (powerStandardDeviation N γ)
            B.computes sample)
          (fun x=>labelReal (B.computes x)) (fun w x=>networkOutput relu w x) (1/4)≤ε := by
  obtain ⟨A,hA,hprob,hgood⟩ := quadratic_polynomial_depth_relu hd hC B D hε hε1 hδ hδ1 hn
  refine ⟨A,hA,hprob,?_⟩
  intro sample hsample N hCN γ hγ globalMargin
  have hN : 0<N := hC.trans_le hCN
  have hh := hgood sample hsample N hCN (powerStandardDeviation N γ)
    (powerStandardDeviation_pos hN γ) (width_mul_powerStandardDeviation_sq_le_one hN hγ)
    globalMargin
  simpa only [powerPrior_eq_smallPrior_standardDeviation hN γ] using hh

/-- The paper's literal t/√N standard deviation, simultaneously for 0<t≤1. -/
theorem quadratic_polynomial_depth_relu_meanfield {d C r n : ℕ} (hd : 0<d) (hC : 0<C)
    (B : LayeredNorCircuit d C r) (D : Measure (Cube d)) [IsProbabilityMeasure D]
    {ε δ : ℝ} (hε : 0<ε) (hε1 : ε<1) (hδ : 0<δ) (hδ1 : δ<1)
    (hn : quadraticConstant/ε*((C:ℝ)^2*(totalResource d r ε)^9+Real.log (1/δ))≤(n:ℝ)) :
    ∃A : Set (Fin n→Cube d), MeasurableSet A ∧
      1-δ≤(CompressionSampling.iidSamples D n).real A ∧
      ∀sample∈A,∀N,C≤N→∀t:ℝ,0<t→t≤1→∀globalMargin : Bool,
        0<(smallPrior d N r (t/Real.sqrt (N:ℝ))).real
          (posteriorEvent relu globalMargin B.computes sample) ∧
        RobustConfidence.gibbsMarginRisk D
          (posterior (N:=N) (r:=r) relu globalMargin (t/Real.sqrt (N:ℝ)) B.computes sample)
          (fun x=>labelReal (B.computes x)) (fun w x=>networkOutput relu w x) (1/4)≤ε := by
  obtain ⟨A,hA,hprob,hgood⟩ := quadratic_polynomial_depth_relu hd hC B D hε hε1 hδ hδ1 hn
  refine ⟨A,hA,hprob,?_⟩
  intro sample hsample N hCN t ht ht1 globalMargin
  have hN : 0<N := hC.trans_le hCN
  have hNr : (0:ℝ)<N := by exact_mod_cast hN
  have hs : 0<Real.sqrt (N:ℝ) := Real.sqrt_pos.mpr hNr
  apply hgood sample hsample N hCN (t/Real.sqrt (N:ℝ)) (div_pos ht hs) _ globalMargin
  rw [div_pow,Real.sq_sqrt hNr.le,mul_div_cancel₀ _ hNr.ne']
  nlinarith

end NeuralGeneralization.BatchTwoMerging
