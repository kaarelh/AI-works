import UniformMarginPathWidth
import Mathlib.Tactic.GCongr
noncomputable section
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

lemma sqrt_two_le_add_one {U : ℝ} (hU : 0≤U) : Real.sqrt (2*U)≤U+1 := by
  nlinarith [Real.sq_sqrt (show 0≤2*U by positivity),Real.sqrt_nonneg (2*U),sq_nonneg (U-1)]

lemma normalizedRepairLog_polynomial (d r : ℕ) {U h Z : ℝ}
    (hZ : 2≤Z) (hU : 0<U) (hh : 0<h)
    (hUZ : U≤Z) (hhZ : h≤Z) (hHZ : (r+1:ℕ)≤Z)
    (hMZ : (Fintype.card (Cube d):ℝ)≤Z) :
    normalizedRepairLog d r U h≤56*Z^2 := by
  have hZ0 : 0≤Z := by linarith
  have hm : (0:ℝ)<Fintype.card (Cube d) := by exact_mod_cast Fintype.card_pos
  have hs := sqrt_two_le_add_one hU.le
  have hroot : Real.sqrt (2*U)≤2*Z := by linarith
  have hlH := Real.log_le_sub_one_of_pos (show (0:ℝ)<(r+1:ℕ)+1 by positivity)
  have hlr := Real.log_le_sub_one_of_pos (show 0<2+Real.sqrt (2*U) by positivity)
  have hlr' : Real.log (2+Real.sqrt (2*U))≤3*Z := by linarith
  have hl1 := Real.log_le_sub_one_of_pos (show 0<1+Real.sqrt (2*U) by positivity)
  have hlprod := Real.log_le_sub_one_of_pos (show 0<16*U*h by positivity)
  have hprod : U*h≤Z^2 := by
    calc
      _ ≤ Z*Z := mul_le_mul hUZ hhZ hh.le hZ0
      _ = _ := by ring
  have hlM := Real.log_le_sub_one_of_pos hm
  have hmH : (r+1:ℕ)*Real.log (2+Real.sqrt (2*U))≤3*Z^2 := by
    calc
      _ ≤ (r+1:ℕ)*(3*Z) := mul_le_mul_of_nonneg_left hlr' (by positivity)
      _ ≤ Z*(3*Z) := mul_le_mul_of_nonneg_right hHZ (by positivity)
      _ = _ := by ring
  unfold normalizedRepairLog
  nlinarith [sq_nonneg (Z-1)]

theorem normalizedMarginWidth_polynomial (d r : ℕ) {U h Z : ℝ}
    (hZ : 2≤Z) (hU : 0<U) (hh : 0<h)
    (hUZ : U≤Z) (hhZ : h≤Z) (hHZ : (r+1:ℕ)≤Z)
    (hMZ : (Fintype.card (Cube d):ℝ)≤Z) :
    normalizedCertificateWidth d r U h (normalizedRepairLog d r U h)≤Z^20 := by
  have hZ0 : 0≤Z := by linarith
  have hZ1 : 1≤Z := by linarith
  have hm : (0:ℝ)<Fintype.card (Cube d) := by exact_mod_cast Fintype.card_pos
  have hJ := normalizedRepairLog_polynomial d r hZ hU hh hUZ hhZ hHZ hMZ
  have hlog5 := Real.log_le_sub_one_of_pos (show (0:ℝ)<5 by norm_num)
  have hlU := Real.log_le_sub_one_of_pos (show 0<1+U by positivity)
  have hlog : 3+Real.log 5+Real.log (1+U)+normalizedRepairLog d r U h≤66*Z^2 := by
    nlinarith [sq_nonneg (Z-1)]
  have hlprod := Real.log_le_sub_one_of_pos (show 0<4*U*h by positivity)
  have hprod : U*h≤Z^2 := by
    calc
      _ ≤ Z*Z := mul_le_mul hUZ hhZ hh.le hZ0
      _ = _ := by ring
  have hlogprod : Real.log (4*U*h)≤4*Z^2 := by linarith
  have hbase : 32*(r+1:ℕ)*(Fintype.card (Cube d):ℝ)^2*h≤32*Z^4 := by
    calc
      _ ≤ 32*Z*Z^2*Z := by gcongr
      _ = _ := by ring
  have hquad : (32*(r+1:ℕ)*(Fintype.card (Cube d):ℝ)^2*h)^2≤1024*Z^8 := by
    nlinarith [pow_le_pow_left₀ (by positivity) hbase 2]
  have hinner1 : (r+1:ℕ)*(Fintype.card (Cube d):ℝ)^2*
      (3+Real.log 5+Real.log (1+U)+normalizedRepairLog d r U h)≤66*Z^5 := by
    calc
      _ ≤ (r+1:ℕ)*(Fintype.card (Cube d):ℝ)^2*(66*Z^2) :=
        mul_le_mul_of_nonneg_left hlog (by positivity)
      _ ≤ Z*Z^2*(66*Z^2) := by gcongr
      _ = _ := by ring
  have hinner2 : (Fintype.card (Cube d):ℝ)*Real.log (4*U*h)≤4*Z^3 := by
    calc
      _ ≤ (Fintype.card (Cube d):ℝ)*(4*Z^2) := mul_le_mul_of_nonneg_left hlogprod hm.le
      _ ≤ Z*(4*Z^2) := by gcongr
      _ = _ := by ring
  have hp35 : Z^3≤Z^5 := pow_le_pow_right₀ hZ1 (by omega)
  have hinner : (r+1:ℕ)*(Fintype.card (Cube d):ℝ)^2*
      (3+Real.log 5+Real.log (1+U)+normalizedRepairLog d r U h)+
        (Fintype.card (Cube d):ℝ)*Real.log (4*U*h)≤70*Z^5 := by linarith
  have hlin : 8*h*((r+1:ℕ)*(Fintype.card (Cube d):ℝ)^2*
      (3+Real.log 5+Real.log (1+U)+normalizedRepairLog d r U h)+
        (Fintype.card (Cube d):ℝ)*Real.log (4*U*h))≤560*Z^6 := by
    calc
      _ ≤ 8*h*(70*Z^5) := mul_le_mul_of_nonneg_left hinner (by positivity)
      _ ≤ 8*Z*(70*Z^5) := by gcongr
      _ = _ := by ring
  have hp68 : Z^6≤Z^8 := pow_le_pow_right₀ hZ1 (by omega)
  have hlow : (1585:ℝ)≤Z^12 := by
    have hp := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hZ 12
    norm_num at hp
    linarith
  have hfinal : 1+1024*Z^8+560*Z^6≤Z^20 := by
    have hpow : 1≤Z^8 := one_le_pow₀ hZ1
    have hh := mul_le_mul_of_nonneg_right hlow (show 0≤Z^8 by positivity)
    rw [←pow_add] at hh
    norm_num only [Nat.reduceAdd] at hh
    nlinarith
  unfold normalizedCertificateWidth
  simp only [Fintype.card_prod,Nat.cast_mul]
  change 1+(32*(r+1:ℕ)*((Fintype.card (Cube d):ℝ)*(Fintype.card (Cube d):ℝ))*h)^2+_≤_
  simp only [←pow_two]
  linarith

#print axioms normalizedMarginWidth_polynomial
end ConditionalNonpolynomial.Analytic
