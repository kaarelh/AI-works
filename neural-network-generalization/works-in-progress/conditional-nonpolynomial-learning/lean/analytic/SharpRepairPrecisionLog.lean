import NormalizedCertificateWidth
noncomputable section
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

lemma sharpPathRepairEpsilon_le_one (d r : ℕ) {A τ U : ℝ}
    (hA : 0≤A) (hτ : 0<τ) : sharpPathRepairEpsilon d r A τ U≤1 := by
  have hm : (1:ℝ)≤Fintype.card (Cube d) := by exact_mod_cast Fintype.card_pos
  have hρ := pathRepairRho_bounds hA hτ
  have hpow : 1≤(1+(1+Real.sqrt (2*U)))^(r+1) := one_le_pow₀ (by linarith [Real.sqrt_nonneg (2*U)])
  have hden : 1≤((r+1:ℕ)+1)*(1+(1+Real.sqrt (2*U)))^(r+1)*(1+Real.sqrt (2*U)) := by
    have hn : (1:ℝ)≤(r+1:ℕ)+1 := by exact_mod_cast (show 1≤(r+1)+1 by omega)
    have hw : 1≤1+Real.sqrt (2*U) := by linarith [Real.sqrt_nonneg (2*U)]
    nlinarith [mul_le_mul hn hpow (by norm_num : (0:ℝ)≤1) (by positivity)]
  have hp : pathRepairRho A τ/
      (((r+1:ℕ)+1)*(1+(1+Real.sqrt (2*U)))^(r+1)*(1+Real.sqrt (2*U)))≤1 := by
    exact div_le_one_of_le₀ (by linarith [hρ.2]) (by positivity)
  unfold sharpPathRepairEpsilon repairPrecision
  apply div_le_one_of_le₀
  · exact hp.trans (one_le_pow₀ hm)
  · positivity

lemma sharpPathRepairEpsilon_log_inverse (d r : ℕ) {A τ U : ℝ}
    (hA : 0≤A) (hτ : 0<τ) :
    Real.log (1/sharpPathRepairEpsilon d r A τ U)=
      Real.log ((r+1:ℕ)+1)+(r+1:ℕ)*Real.log (2+Real.sqrt (2*U))+
      Real.log (1+Real.sqrt (2*U))+Real.log (1/pathRepairRho A τ)+
      4*Real.log (Fintype.card (Cube d):ℝ) := by
  have hm : (0:ℝ)<Fintype.card (Cube d) := by exact_mod_cast Fintype.card_pos
  have hρ := (pathRepairRho_bounds hA hτ).1
  have hprecision := repairPrecision_pos (r+1) (show 0≤1+Real.sqrt (2*U) by positivity)
    (Real.sqrt_nonneg (2*U)) hρ
  have hid : 1/sharpPathRepairEpsilon d r A τ U=
      (1/repairPrecision (r+1) (1+Real.sqrt (2*U)) (Real.sqrt (2*U)) (pathRepairRho A τ))*
        (Fintype.card (Cube d):ℝ)^4 := by
    unfold sharpPathRepairEpsilon
    field_simp
  rw [hid,Real.log_mul (by positivity) (by positivity),Real.log_pow,
    repairPrecision_log_inverse (r+1) (by positivity) (Real.sqrt_nonneg (2*U)) hρ]
  rw [one_div,Real.log_inv]
  rw [show 1+(1+Real.sqrt (2*U))=2+Real.sqrt (2*U) by ring]
  ring

lemma sharpPathRepairEpsilon_normalized_log (d r : ℕ) {x A τ U h : ℝ}
    (hx : 0<x) (hA : 0≤A) (hτ : 0<τ)
    (hU : x*(A+τ)≤U) (hh : 1≤x*τ*h) :
    Real.log (1/(sharpPathRepairEpsilon d r A τ U)^2)≤
      2*(Real.log ((r+1:ℕ)+1)+(r+1:ℕ)*Real.log (2+Real.sqrt (2*U))+
      Real.log (1+Real.sqrt (2*U))+Real.log (16*U*h)+
      4*Real.log (Fintype.card (Cube d):ℝ)) := by
  have hAτ : 0<A+τ := by linarith
  have hU0 : 0<U := (mul_pos hx hAτ).trans_le hU
  have hh0 : 0<h := by nlinarith [mul_pos hx hτ]
  have hi : 1/τ≤x*h := by apply (div_le_iff₀ hτ).mpr; nlinarith
  have hρ : 0<pathRepairRho A τ := (pathRepairRho_bounds hA hτ).1
  have harg : 1/pathRepairRho A τ≤16*U*h := by
    have hid : 1/pathRepairRho A τ=16*(A+τ)*(1/τ) := by unfold pathRepairRho; field_simp
    rw [hid]
    have h1 := mul_le_mul_of_nonneg_left hi (show 0≤16*(A+τ) by positivity)
    have h2 := mul_le_mul_of_nonneg_right hU hh0.le
    nlinarith
  have hl := Real.log_le_log (show 0<1/pathRepairRho A τ by positivity) harg
  have he := sharpPathRepairEpsilon_log_inverse d r (U:=U) hA hτ
  rw [one_div,Real.log_inv,Real.log_pow]
  rw [one_div,Real.log_inv] at he
  norm_num only [Nat.cast_ofNat] at *
  nlinarith

#print axioms sharpPathRepairEpsilon_normalized_log
end ConditionalNonpolynomial.Analytic
