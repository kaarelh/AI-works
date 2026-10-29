import UniformMarginWidthPolynomial
import AnalyticCeiling
import Mathlib.Data.Nat.Log
noncomputable section
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

lemma real_log_le_twice_log2 {R : ℕ} (hR : 2≤R) :
    Real.log (R:ℝ)≤2*(Nat.log2 R:ℝ) := by
  have hR0 : (0:ℝ)<R := by exact_mod_cast (show 0<R by omega)
  have hk : 1≤Nat.log2 R := by rw [Nat.le_log2 (by omega)]; simpa using hR
  have hkR : (1:ℝ)≤Nat.log2 R := by exact_mod_cast hk
  have hpow : (R:ℝ)≤(2:ℝ)^(Nat.log2 R+1) := by
    exact_mod_cast (Nat.le_of_lt (Nat.lt_log2_self (n:=R)))
  have hl := Real.log_le_log hR0 hpow
  rw [Real.log_pow] at hl
  have h2 := Real.log_le_sub_one_of_pos (show (0:ℝ)<2 by norm_num)
  have hm := mul_le_mul_of_nonneg_left h2 (show (0:ℝ)≤(Nat.log2 R+1:ℕ) by positivity)
  push_cast at hl hm
  linarith

lemma padding_real_log {R r P : ℕ} {K : ℝ} (hR : 2≤R) (hK : 0≤K)
    (hP : 2*K+2≤(P:ℝ)) (hpad : P*Nat.log2 R≤r+2) :
    K*Real.log (R:ℝ)≤(r:ℝ) := by
  have hk : 1≤Nat.log2 R := by rw [Nat.le_log2 (by omega)]; simpa using hR
  have hkR : (1:ℝ)≤Nat.log2 R := by exact_mod_cast hk
  have hpadR : (P:ℝ)*(Nat.log2 R:ℝ)≤(r:ℝ)+2 := by exact_mod_cast hpad
  have hl := mul_le_mul_of_nonneg_left (real_log_le_twice_log2 hR) hK
  have hp := mul_le_mul_of_nonneg_right hP (show (0:ℝ)≤Nat.log2 R by positivity)
  nlinarith

lemma normalizedMarginWidth_power (d r p : ℕ) {R U h : ℝ}
    (hR : 2≤R) (hp : 1≤p) (hU : 0<U) (hh : 0<h)
    (hUp : U≤R^p) (hhp : h≤R^p) (hHp : (r+1:ℕ)≤R^p) :
    normalizedCertificateWidth d r U h (normalizedRepairLog d r U h)≤
      (2:ℝ)^(20*d)*R^(20*p) := by
  have hR0 : 0≤R := by linarith
  have hR1 : 1≤R := by linarith
  have hRp : R≤R^p := by simpa only [pow_one] using pow_le_pow_right₀ hR1 hp
  have hM : (Fintype.card (Cube d):ℝ)=(2:ℝ)^d := by simp [Cube]
  have hM1 : (1:ℝ)≤Fintype.card (Cube d) := by exact_mod_cast Fintype.card_pos
  have hm0 : (0:ℝ)≤Fintype.card (Cube d) := by positivity
  have hRp1 : 1≤R^p := one_le_pow₀ hR1
  have hZlow : R^p≤(Fintype.card (Cube d):ℝ)*R^p := by nlinarith
  have hZ2 : 2≤(Fintype.card (Cube d):ℝ)*R^p := by linarith
  have hMZ : (Fintype.card (Cube d):ℝ)≤(Fintype.card (Cube d):ℝ)*R^p := by nlinarith
  have hw := normalizedMarginWidth_polynomial d r hZ2 hU hh
    (hUp.trans hZlow) (hhp.trans hZlow) (hHp.trans hZlow) hMZ
  convert hw using 1
  rw [mul_pow,hM,←pow_mul,←pow_mul]
  simp only [Nat.mul_comm]

#print axioms real_log_le_twice_log2
#print axioms normalizedMarginWidth_power
end ConditionalNonpolynomial.Analytic
