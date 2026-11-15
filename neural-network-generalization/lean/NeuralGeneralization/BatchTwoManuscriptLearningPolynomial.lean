import NeuralGeneralization.BatchTwoManuscriptLiteralLearning
import NeuralGeneralization.BatchTwoManuscriptTargetGrowth
import NeuralGeneralization.BatchTwoManuscriptGridPolynomial

/-! Universal degree 46 for the literal D_*/J sufficient sample formula. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
namespace NeuralGeneralization.BatchTwoManuscriptLearning
open ConcreteModel BatchTwoManuscriptTarget

theorem literal_parameters_global {d C L : ℕ} {c ε S : ℝ}
    (hd : 0<d) (hL : 2≤L) (hC : 0<C) (hc : 0<c) (hε : 0<ε) (hε1 : ε≤1)
    (hS : 2≤S) (hdS : (d:ℝ)≤S) (hCS : (C:ℝ)≤S) (hLS : (L:ℝ)≤S)
    (hcS : c≤S) (hci : c⁻¹≤S) (hεS : ε⁻¹≤S) :
    BatchTwoManuscriptResources.PolynomialHypotheses 1000000000000 100000000 12
      (compressionInput (literalCircuitInput d C L c ε hd hL hC hc hε hε1)) S := by
  let p := literalCircuitInput d C L c ε hd hL hC hc hε hε1
  have hS1 : 1≤S := by linarith
  have hS0 : 0≤S := by linarith
  have hS3 : 1≤S^3 := one_le_pow₀ hS1
  have hS13 : S≤S^3 := by simpa using pow_le_pow_right₀ hS1 (show 1≤3 by omega)
  have hcost := targetCost_budget hC hc.le hS1 hdS hCS
    ((show ((L-2:ℕ):ℝ)≤L by exact_mod_cast Nat.sub_le L 2).trans hLS) hcS
  have hlog : Real.log (4/ε)≤4*S := by
    have hh := Real.log_le_sub_one_of_pos (show 0<4/ε by positivity)
    have hi := mul_le_mul_of_nonneg_left hεS (show (0:ℝ)≤4 by norm_num)
    rw [←div_eq_mul_inv] at hi
    linarith
  have hB : posteriorReadoutBound p≤1000000000000*S^3 := by
    change max 8 (8*(targetCost d C (L-2) c+Real.log (1/(ε/4))))≤_
    have hid : 1/(ε/4)=4/ε := by field_simp
    rw [hid]
    apply max_le <;> nlinarith
  have hB0 := (by norm_num : (0:ℝ)≤8).trans (posteriorReadoutBound_ge_eight p)
  have hl : (2:ℝ)≤L := by exact_mod_cast hL
  have hQ0 : 0≤1+((L:ℝ)-1)*posteriorReadoutBound p :=
    by nlinarith [mul_nonneg (show 0≤(L:ℝ)-1 by linarith) hB0]
  have hQ : 1+((L:ℝ)-1)*posteriorReadoutBound p≤(10000000*S^2)^2 := by
    have hm := mul_le_mul (show (L:ℝ)-1≤S by linarith) hB hB0 hS0
    have hs4 : 1≤S^4 := one_le_pow₀ hS1
    nlinarith
  have hsqrt : Real.sqrt (1+((L:ℝ)-1)*posteriorReadoutBound p)≤10000000*S^2 :=
    Real.sqrt_le_iff.mpr ⟨by positivity,hQ⟩
  have hquot : Real.sqrt (1+((L:ℝ)-1)*posteriorReadoutBound p)/c≤10000000*S^3 := by
    rw [div_eq_mul_inv]
    exact (mul_le_mul hsqrt hci (inv_nonneg.mpr hc.le) (by positivity)).trans_eq (by ring)
  refine ⟨hS,hdS,hLS,?_,?_,?_⟩
  · change targetCost d C (L-2) c+1≤_
    nlinarith
  · change (min (1/6) (c/Real.sqrt (1+((L:ℝ)-1)*posteriorReadoutBound p)))⁻¹≤_
    rcases le_total (1/6:ℝ) (c/Real.sqrt (1+((L:ℝ)-1)*posteriorReadoutBound p)) with h|h
    · rw [min_eq_left h]
      norm_num
      nlinarith
    · rw [min_eq_right h,inv_div]
      nlinarith
  · change (ε/12)⁻¹≤12*S
    rw [inv_div]
    simpa only [div_eq_mul_inv] using mul_le_mul_of_nonneg_left hεS (show (0:ℝ)≤12 by norm_num)

theorem literal_entropy_global_polynomial :
    ∃A : ℝ,0<A ∧ ∀(d C L : ℕ) (c ε S : ℝ)
      (hd : 0<d) (hL : 2≤L) (hC : 0<C) (hc : 0<c) (hε : 0<ε) (hε1 : ε≤1),
      2≤S→(d:ℝ)≤S→(C:ℝ)≤S→(L:ℝ)≤S→c≤S→c⁻¹≤S→ε⁻¹≤S→
      entropy (literalCircuitInput d C L c ε hd hL hC hc hε hε1)≤A*S^45 := by
  obtain ⟨A,hA,hg⟩ := BatchTwoManuscriptResources.gridEntropy_polynomial
    (show (0:ℝ)<1000000000000 by norm_num) (show (0:ℝ)<100000000 by norm_num) (show (0:ℝ)<12 by norm_num)
  refine ⟨A,hA,?_⟩
  intro d C L c ε S hd hL hC hc hε hε1 hS hdS hCS hLS hcS hci hεS
  exact (le_abs_self _).trans (hg _ _ (literal_parameters_global hd hL hC hc hε hε1 hS hdS hCS hLS hcS hci hεS))

def literalProblemSize (d C L : ℕ) (c ε δ : ℝ) : ℝ :=
  2+(d:ℝ)+L+C+c+c⁻¹+ε⁻¹+Real.log (1/δ)

theorem literalProblemSize_bounds (d C L : ℕ) {c ε δ : ℝ}
    (hc : 0<c) (hε : 0<ε) (hδ : 0<δ) (hδ1 : δ≤1) :
    let S:=literalProblemSize d C L c ε δ
    2≤S ∧ (d:ℝ)≤S ∧ (C:ℝ)≤S ∧ (L:ℝ)≤S ∧ c≤S ∧ c⁻¹≤S ∧ ε⁻¹≤S ∧ Real.log (1/δ)≤S := by
  have hci := inv_nonneg.mpr hc.le
  have hei := inv_nonneg.mpr hε.le
  have hl := Real.log_nonneg ((le_div_iff₀ hδ).mpr (by linarith : 1*δ≤1))
  have hd := Nat.cast_nonneg (α:=ℝ) d
  have hC := Nat.cast_nonneg (α:=ℝ) C
  have hL := Nat.cast_nonneg (α:=ℝ) L
  dsimp [literalProblemSize]
  refine ⟨?_,?_,?_,?_,?_,?_,?_,?_⟩ <;> linarith

theorem literal_sample_budget_degree46 :
    ∃A : ℝ,0<A ∧ ∀(d C L : ℕ) (c ε δ : ℝ)
      (hd : 0<d) (hL : 2≤L) (hC : 0<C) (hc : 0<c) (hε : 0<ε) (hε1 : ε≤1),
      0<δ→δ≤1→16/ε*(entropy (literalCircuitInput d C L c ε hd hL hC hc hε hε1)+Real.log (1/δ))≤
        A*(literalProblemSize d C L c ε δ)^46 := by
  obtain ⟨K,hK,hent⟩ := literal_entropy_global_polynomial
  refine ⟨16*(K+1),by positivity,?_⟩
  intro d C L c ε δ hd hL hC hc hε hε1 hδ hδ1
  obtain ⟨hS,hdS,hCS,hLS,hcS,hci,hεS,hδS⟩ := literalProblemSize_bounds d C L hc hε hδ hδ1
  let S := literalProblemSize d C L c ε δ
  have hS0 : 0≤S := by dsimp [S]; linarith
  have hS1 : 1≤S := by dsimp [S]; linarith
  have he := hent d C L c ε S hd hL hC hc hε hε1 hS hdS hCS hLS hcS hci hεS
  have hS45 : S≤S^45 := by simpa using pow_le_pow_right₀ hS1 (show 1≤45 by omega)
  have hsum : entropy (literalCircuitInput d C L c ε hd hL hC hc hε hε1)+Real.log (1/δ)≤(K+1)*S^45 := by
    nlinarith
  have hm := mul_le_mul hεS hsum (by
    have hh := BatchTwoManuscriptResources.gridLogFactor_nonneg
      (compressionInput (literalCircuitInput d C L c ε hd hL hC hc hε hε1))
    have hj : 0≤entropy (literalCircuitInput d C L c ε hd hL hC hc hε hε1) := by
      exact mul_nonneg (Nat.cast_nonneg _) hh
    have hl := Real.log_nonneg ((le_div_iff₀ hδ).mpr (by linarith : 1*δ≤1))
    linarith) hS0
  have hh := mul_le_mul_of_nonneg_left hm (show (0:ℝ)≤16 by norm_num)
  change _≤16*(K+1)*S^46
  rw [div_eq_mul_inv]
  nlinarith only [hh]

end NeuralGeneralization.BatchTwoManuscriptLearning
