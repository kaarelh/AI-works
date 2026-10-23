import NeuralGeneralization.BatchTwoImprovedLearningParameters
import NeuralGeneralization.BatchTwoImprovedTargetBudget

/-! Universal resource envelopes for the actual learning parameters. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoImprovedLearning
open ConcreteModel

theorem readoutBound_global {d C r:ℕ} (hC:0<C) {c ε S:ℝ}
    (hc:0<c) (hε:0<ε) (hε1:ε≤1) (hS:2≤S)
    (hd:(d:ℝ)≤S) (hCS:(C:ℝ)≤S) (hr:(r:ℝ)+2≤S)
    (hcS:c≤S) (hεS:ε⁻¹≤S):
    readoutBound d C r c ε≤(100000000000:ℝ)*S^3 := by
  have hS1:1≤S:=by linarith
  have hT:=improvedTargetCost_budget hC hc.le hS1 hd hCS (by linarith) hcS
  have hlog:-Real.log (ε/100)≤100*S := by
    have he:-Real.log (ε/100)=Real.log (100/ε):=by rw [←Real.log_inv];congr 1;field_simp
    rw [he]
    have hh:=Real.log_le_sub_one_of_pos (show 0<100/ε by positivity)
    have hinv:100/ε≤100*S:=by simpa only [div_eq_mul_inv] using mul_le_mul_of_nonneg_left hεS (by norm_num : (0:ℝ)≤100)
    linarith
  have h13:1≤S^3:=one_le_pow₀ hS1
  have hS3:S≤S^3:=by simpa using pow_le_pow_right₀ hS1 (show 1≤3 by omega)
  unfold readoutBound
  nlinarith

theorem parameters_global {d C r:ℕ} (hC:0<C) {c ε S:ℝ}
    (hc:0<c) (hε:0<ε) (hε1:ε≤1) (hS:2≤S)
    (hd:(d:ℝ)≤S) (hCS:(C:ℝ)≤S) (hr:(r:ℝ)+2≤S)
    (hcS:c≤S) (hci:c⁻¹≤S) (hεS:ε⁻¹≤S):
    let p:=parameters d C r c ε
    (p.dimension:ℝ)≤S ∧ (p.depth:ℝ)≤S ∧
      (p.energy:ℝ)≤100000000000*S^3 ∧
      (p.inverseRadius:ℝ)≤10000000*S^3 ∧
      (p.inverseFailure:ℝ)≤101*S := by
  have hS1:1≤S:=by linarith
  have hS0:0≤S:=by linarith
  have hS3:1≤S^3:=one_le_pow₀ hS1
  have hT:=improvedTargetCost_budget hC hc.le hS1 hd hCS (by linarith) hcS
  have hT0:=improvedTargetCost_nonneg d r hC c
  have hcap:=readoutBound_global hC hc hε hε1 hS hd hCS hr hcS hεS
  have hcap0:0≤ readoutBound d C r c ε:=(show (0:ℝ)≤8 by norm_num).trans
    (readoutBound_ge_eight (d:=d) (r:=r) hC c hε hε1)
  have henergy:(⌈improvedTargetCost d C r c+1⌉₊:ℝ)≤100000000000*S^3:=by
    have hh:=Nat.ceil_lt_add_one (show 0≤ improvedTargetCost d C r c+1 by linarith)
    nlinarith
  have hradicand:1+((r:ℝ)+1)*readoutBound d C r c ε≤(1000000*S^2)^2:=by
    have hm:=mul_le_mul (show (r:ℝ)+1≤S by linarith) hcap hcap0 hS0
    have hs4:1≤S^4:=one_le_pow₀ hS1
    nlinarith [show S*(100000000000*S^3)=100000000000*S^4 by ring]
  have hsqrt:Real.sqrt (1+((r:ℝ)+1)*readoutBound d C r c ε)≤1000000*S^2 := by
    apply (Real.sqrt_le_iff).mpr
    exact ⟨by positivity,hradicand⟩
  have hquot:Real.sqrt (1+((r:ℝ)+1)*readoutBound d C r c ε)/c≤1000000*S^3:=by
    rw [div_eq_mul_inv]
    have hh:=mul_le_mul hsqrt hci (inv_nonneg.mpr hc.le) (by positivity : 0≤1000000*S^2)
    exact hh.trans_eq (by ring)
  have hmax:max 6 (Real.sqrt (1+((r:ℝ)+1)*readoutBound d C r c ε)/c)≤1000000*S^3:=
    max_le (by nlinarith) hquot
  have hradius:(⌈max 6 (Real.sqrt (1+((r:ℝ)+1)*readoutBound d C r c ε)/c)⌉₊:ℝ)≤10000000*S^3:=by
    have hh:=Nat.ceil_lt_add_one (show 0≤max 6 (Real.sqrt (1+((r:ℝ)+1)*readoutBound d C r c ε)/c) from
      (show (0:ℝ)≤6 by norm_num).trans (le_max_left _ _))
    nlinarith
  have hfailure:(⌈100/ε⌉₊:ℝ)≤101*S:=by
    have hh:=Nat.ceil_lt_add_one (show 0≤100/ε by positivity)
    have hm:=mul_le_mul_of_nonneg_left hεS (show (0:ℝ)≤100 by norm_num)
    rw [←div_eq_mul_inv] at hm
    linarith
  exact ⟨hd,by simpa only [parameters,Nat.cast_add,Nat.cast_ofNat] using hr,henergy,hradius,hfailure⟩

end NeuralGeneralization.BatchTwoImprovedLearning
