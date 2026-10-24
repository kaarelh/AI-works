import NeuralGeneralization.BatchTwoNeuralConverseModel
import Mathlib.Analysis.SpecialFunctions.Arsinh
import Mathlib.Algebra.Order.Field.Power

/-! Contractive tanh relays with only linear loss of inverse squared amplitude. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
open ConcreteModel

theorem tanh_lower_square_root {y : ℝ} (hy : 0 ≤ y) :
    y/Real.sqrt (1+y^2) ≤ Real.tanh y := by
  have hs : Real.arsinh y ≤ y := by
    rw [← Real.sinh_le_sinh, Real.sinh_arsinh]
    exact Real.self_le_sinh_iff.mpr hy
  simpa only [Real.tanh_arsinh] using tanh_monotone hs

theorem tanh_positive {y : ℝ} (hy : 0 < y) : 0 < Real.tanh y :=
  (div_pos hy (Real.sqrt_pos.mpr (by positivity))).trans_le (tanh_lower_square_root hy.le)

theorem tanh_inv_square {y : ℝ} (hy : 0 < y) :
    1/(Real.tanh y)^2 ≤ 1+1/y^2 := by
  have hden : 0 < 1+y^2 := by positivity
  have hsqrt := Real.sq_sqrt hden.le
  have hratio : 0 < y/Real.sqrt (1+y^2) := div_pos hy (Real.sqrt_pos.mpr hden)
  have hsquare := pow_le_pow_left₀ hratio.le (tanh_lower_square_root hy.le) 2
  calc
    _ ≤ 1/(y/Real.sqrt (1+y^2))^2 :=
      one_div_le_one_div_of_le (sq_pos_of_pos hratio) hsquare
    _ = _ := by rw [div_pow, hsqrt]; field_simp; ring

def relayFactor (H : ℕ) : ℝ := 1-1/(2*(H : ℝ))

theorem relayFactor_bounds {H : ℕ} (hH : 0 < H) : 0 < relayFactor H ∧ relayFactor H < 1 := by
  have hHr : (1 : ℝ) ≤ H := by exact_mod_cast hH
  have hden : 0 < 2*(H : ℝ) := by positivity
  have hfrac : 1/(2*(H : ℝ)) ≤ 1/2 :=
    one_div_le_one_div_of_le (by norm_num) (by linarith)
  have hpos := one_div_pos.mpr hden
  unfold relayFactor
  constructor <;> linarith

theorem relayFactor_power_lower {H n : ℕ} (hH : 0 < H) (hn : n ≤ H) :
    (1 : ℝ)/2 ≤ relayFactor H ^ n := by
  have hHr : (0 : ℝ) < H := by exact_mod_cast hH
  have hb := relayFactor_bounds hH
  have hbase : (-2 : ℝ) ≤ -(1/(2*(H : ℝ))) := by
    have hp := hb.1
    unfold relayFactor at hp
    linarith
  have hbern := one_add_mul_le_pow hbase H
  have hleft : 1+(H : ℝ)*(-(1/(2*(H : ℝ)))) = 1/2 := by field_simp [hHr.ne']; norm_num
  rw [hleft] at hbern
  have hp : relayFactor H ^ H ≤ relayFactor H ^ n := pow_le_pow_of_le_one hb.1.le hb.2.le hn
  have hb' : (1 : ℝ)/2 ≤ relayFactor H^H := by
    simpa only [relayFactor, sub_eq_add_neg] using hbern
  exact hb'.trans hp

def relayAmplitude (H : ℕ) : ℕ → ℝ
  | 0 => Real.tanh (1/8)
  | n+1 => Real.tanh (relayFactor H*relayAmplitude H n)

theorem relayAmplitude_pos {H : ℕ} (hH : 0 < H) (n : ℕ) : 0 < relayAmplitude H n := by
  induction n with
  | zero => exact tanh_positive (by norm_num)
  | succ n ih => exact tanh_positive (mul_pos (relayFactor_bounds hH).1 ih)

theorem relayAmplitude_scaled_inverse {H : ℕ} (hH : 0 < H) (n : ℕ) :
    (relayFactor H ^ n)^2/(relayAmplitude H n)^2 ≤ 65+n := by
  induction n with
  | zero =>
      have h := tanh_inv_square (by norm_num : (0 : ℝ) < 1/8)
      norm_num [relayAmplitude] at h ⊢
      exact h
  | succ n ih =>
      have hb := relayFactor_bounds hH
      have ha := relayAmplitude_pos hH n
      have h := tanh_inv_square (mul_pos hb.1 ha)
      have hm := mul_le_mul_of_nonneg_left h (sq_nonneg (relayFactor H^(n+1)))
      have hid : (relayFactor H^(n+1))^2*(1+1/(relayFactor H*relayAmplitude H n)^2) =
          (relayFactor H^(n+1))^2+(relayFactor H^n)^2/(relayAmplitude H n)^2 := by
        rw [pow_succ]
        field_simp [hb.1.ne', ha.ne']
        ring
      rw [hid] at hm
      have hp : (relayFactor H^(n+1))^2 ≤ 1 := by
        exact pow_le_one₀ (pow_nonneg hb.1.le _) (pow_le_one₀ hb.1.le hb.2.le)
      change (relayFactor H^(n+1))^2/(Real.tanh (relayFactor H*relayAmplitude H n))^2 ≤ _
      have he : (relayFactor H^(n+1))^2*(1/(Real.tanh (relayFactor H*relayAmplitude H n))^2) =
          (relayFactor H^(n+1))^2/(Real.tanh (relayFactor H*relayAmplitude H n))^2 := by ring
      rw [he] at hm
      push_cast
      linarith

theorem relayAmplitude_inverse_bound {H n : ℕ} (hH : 0 < H) (hn : n ≤ H) :
    1/(relayAmplitude H n)^2 ≤ 4*(65+H : ℝ) := by
  have hs := relayAmplitude_scaled_inverse hH n
  have hb := relayFactor_power_lower hH hn
  have ha := relayAmplitude_pos hH n
  have hnR : (n : ℝ) ≤ H := by exact_mod_cast hn
  have hpow : (1 : ℝ)/4 ≤ (relayFactor H^n)^2 := by nlinarith
  have hdiv := div_le_div_of_nonneg_right hpow (sq_nonneg (relayAmplitude H n))
  have hden : 0 < (relayAmplitude H n)^2 := sq_pos_of_pos ha
  have hineq := (div_le_iff₀ hden).mp (hdiv.trans hs)
  apply (div_le_iff₀ hden).mpr
  nlinarith [sq_nonneg (relayAmplitude H n)]

end
end NeuralGeneralization.BatchTwoNeuralConverse
