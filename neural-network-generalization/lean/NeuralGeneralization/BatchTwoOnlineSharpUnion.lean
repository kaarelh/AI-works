import Mathlib.Analysis.Complex.ExponentialBounds
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.GCongr
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum

/-! The literal retained-row union budget in the online-mistake paper. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoOnline

theorem sharp_retained_union_bound {d L u : ℕ} (hd : 1 ≤ d) (hL : 2 ≤ L)
    {ρ : ℝ} (hρ : 0 < ρ) (hρsmall : ρ ≤ 1/24)
    (huLower : 256*(ρ⁻¹)^4*((d : ℝ)+Real.log ((L : ℝ)/ρ)) ≤ u)
    (huUpper : (u : ℝ) ≤ 256*(ρ⁻¹)^4*((d : ℝ)+Real.log ((L : ℝ)/ρ))+1) :
    (((L : ℝ)-2)*u+1)*2^d*2*Real.exp (-(ρ^4*(u : ℝ))/32) ≤ 1/4 := by
  let ell := Real.log ((L : ℝ)/ρ)
  have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd
  have hLR : (2 : ℝ) ≤ L := by exact_mod_cast hL
  have hratio : (48 : ℝ) ≤ (L : ℝ)/ρ := by
    apply (le_div_iff₀ hρ).mpr
    nlinarith only [hρsmall,hLR]
  have hell : (3 : ℝ) ≤ ell := by
    apply (Real.le_log_iff_exp_le (by positivity : (0 : ℝ)<(L : ℝ)/ρ)).mpr
    have h := pow_le_pow_left₀ (Real.exp_pos 1).le Real.exp_one_lt_three.le 3
    rw [←Real.exp_nat_mul] at h
    norm_num at h
    exact h.trans (by linarith only [hratio])
  have hellExp : Real.exp ell = (L : ℝ)/ρ := Real.exp_log (by positivity)
  have hinv : (1 : ℝ) ≤ ρ⁻¹ := by
    apply (one_le_inv₀ hρ).mpr
    linarith only [hρsmall]
  have hinvExp : ρ⁻¹ ≤ Real.exp ell := by
    rw [hellExp,div_eq_mul_inv]
    nlinarith only [hLR,inv_pos.mpr hρ]
  have hLex : (L : ℝ) ≤ Real.exp ell := by
    rw [hellExp]
    apply (le_div_iff₀ hρ).mpr
    nlinarith only [hLR,hρsmall]
  have hA : 1 ≤ 256*(ρ⁻¹)^4*((d : ℝ)+ell) := by
    have hpow : (1 : ℝ) ≤ (ρ⁻¹)^4 := one_le_pow₀ hinv
    nlinarith only [hpow,hdR,hell]
  have huOne : (1 : ℝ) ≤ u := hA.trans huLower
  have hu2 : (u : ℝ) ≤ 512*(ρ⁻¹)^4*((d : ℝ)+ell) := by
    dsimp only [ell] at hA ⊢
    linarith only [huUpper,hA]
  have h2exp : (2 : ℝ) ≤ Real.exp 1 := by linarith only [Real.add_one_le_exp 1]
  have h512 : (512 : ℝ) ≤ Real.exp 9 := by
    have h := pow_le_pow_left₀ (by norm_num : (0 : ℝ)≤2) h2exp 9
    rw [←Real.exp_nat_mul] at h
    norm_num at h ⊢
    exact h
  have huExp : (u : ℝ) ≤ Real.exp (9+(d : ℝ)+5*ell) := by
    have hi : (ρ⁻¹)^4 ≤ Real.exp (4*ell) := by
      have h := pow_le_pow_left₀ (inv_pos.mpr hρ).le hinvExp 4
      simpa only [←Real.exp_nat_mul,Nat.cast_ofNat] using h
    have hsum : (d : ℝ)+ell ≤ Real.exp ((d : ℝ)+ell) := by
      linarith only [Real.add_one_le_exp ((d : ℝ)+ell)]
    calc
      _ ≤ 512*(ρ⁻¹)^4*((d : ℝ)+ell) := hu2
      _ ≤ Real.exp 9 * Real.exp (4*ell) * Real.exp ((d : ℝ)+ell) := by gcongr
      _ = _ := by rw [←Real.exp_add,←Real.exp_add]; congr 1; ring
  have hdExp : (2 : ℝ)^d ≤ Real.exp d := by
    have h := pow_le_pow_left₀ (by norm_num : (0 : ℝ)≤2) h2exp d
    simpa only [←Real.exp_nat_mul,mul_one] using h
  have h8Exp : (8 : ℝ) ≤ Real.exp 3 := by
    have h := pow_le_pow_left₀ (by norm_num : (0 : ℝ)≤2) h2exp 3
    rw [←Real.exp_nat_mul] at h
    norm_num at h ⊢
    exact h
  have hrate : 8*((d : ℝ)+ell) ≤ ρ^4*(u : ℝ)/32 := by
    have h := mul_le_mul_of_nonneg_left huLower (pow_nonneg hρ.le 4)
    have hid : ρ^4*(256*(ρ⁻¹)^4*((d : ℝ)+ell))=256*((d : ℝ)+ell) := by
      field_simp
    change ρ^4*(256*(ρ⁻¹)^4*((d : ℝ)+ell)) ≤ ρ^4*u at h
    rw [hid] at h
    linarith only [h]
  have hpre : (((L : ℝ)-2)*u+1) ≤ (L : ℝ)*u := by nlinarith only [huOne]
  have hall : 8*(L : ℝ)*u*2^d*Real.exp (-(ρ^4*(u : ℝ))/32) ≤ 1 := by
    calc
      _ ≤ Real.exp 3*Real.exp ell*Real.exp (9+(d : ℝ)+5*ell)*Real.exp d*
          Real.exp (-(ρ^4*(u : ℝ))/32) := by gcongr
      _ = Real.exp (12+2*(d : ℝ)+6*ell-ρ^4*(u : ℝ)/32) := by
        rw [←Real.exp_add,←Real.exp_add,←Real.exp_add,←Real.exp_add]
        congr 1
        ring
      _ ≤ 1 := Real.exp_le_one_iff.mpr (by linarith only [hrate,hdR,hell])
  have hfinal := mul_le_mul_of_nonneg_right
    (mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right hpre
      (pow_nonneg (by norm_num : (0 : ℝ)≤2) d)) (by norm_num : (0 : ℝ)≤2))
    (Real.exp_pos (-(ρ^4*(u : ℝ))/32)).le
  nlinarith only [hall,hfinal]

#print axioms sharp_retained_union_bound
end NeuralGeneralization.BatchTwoOnline
