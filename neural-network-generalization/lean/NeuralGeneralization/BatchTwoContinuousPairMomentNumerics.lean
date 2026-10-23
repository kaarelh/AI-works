import NeuralGeneralization.BatchTwoGaussianNormMoments
import Mathlib.Analysis.Complex.ExponentialBounds
import Mathlib.Algebra.Order.Floor.Ring

/-! Uniform inverse-variance moment choices for nearby-input Gaussian tails. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoContinuousDepthLower

theorem exp_six_fifths_le_four : Real.exp (6/5) ≤ 4 := by
  have hlow : (4 : ℝ)/5 ≤ Real.exp (-1/5) := by
    linarith only [Real.add_one_le_exp (-1/5)]
  have hmul := mul_le_mul_of_nonneg_right hlow (Real.exp_pos (1/5)).le
  have he : Real.exp (-1/5)*Real.exp (1/5)=1 := by rw [←Real.exp_add]; norm_num
  rw [he] at hmul
  have hsmall : Real.exp (1/5) ≤ 5/4 := by linarith only [hmul]
  calc
    _ = Real.exp 1*Real.exp (1/5) := by rw [←Real.exp_add]; congr 1; norm_num
    _ ≤ 3*(5/4) := mul_le_mul Real.exp_one_lt_three.le hsmall (Real.exp_pos _).le (by norm_num)
    _ ≤ 4 := by norm_num

theorem sixty_four_quarter_pow {H : ℕ} (hH : 60 ≤ H) :
    (64 : ℝ)*(1/4)^H ≤ Real.exp (-(11/10)*(H : ℝ)) := by
  have h64 : (64 : ℝ) ≤ Real.exp 6 := by
    have h := pow_le_pow_left₀ (by norm_num : (0 : ℝ)≤2) Real.exp_one_gt_two.le 6
    rw [←Real.exp_nat_mul] at h
    norm_num at h ⊢
    exact h
  have hquarter : (1/4 : ℝ) ≤ Real.exp (-6/5) := by
    rw [show (-6/5 : ℝ)=-(6/5) by ring,Real.exp_neg]
    simpa only [one_div] using one_div_le_one_div_of_le (Real.exp_pos (6/5)) exp_six_fifths_le_four
  have hpow := pow_le_pow_left₀ (by norm_num : (0 : ℝ)≤1/4) hquarter H
  rw [←Real.exp_nat_mul] at hpow
  calc
    _ ≤ Real.exp 6 * Real.exp ((H : ℝ)*(-6/5)) := by gcongr
    _ = Real.exp (6+(H : ℝ)*(-6/5)) := (Real.exp_add _ _).symm
    _ ≤ _ := Real.exp_le_exp.mpr (by
      have hHR : (60 : ℝ)≤H := by exact_mod_cast hH
      linarith only [hHR])

def pairMomentOrder (v : ℝ) : ℕ := ⌈v⁻¹⌉₊

theorem pairMomentOrder_pos {v : ℝ} (hv : 0 < v) : 0 < pairMomentOrder v :=
  Nat.ceil_pos.mpr (inv_pos.mpr hv)

theorem pairMomentOrder_bounds {v : ℝ} (hv : 0 < v) :
    1 ≤ v*(pairMomentOrder v : ℝ) ∧ v*(pairMomentOrder v : ℝ) ≤ 1+v := by
  have hlo := Nat.le_ceil v⁻¹
  have hhi := (Nat.ceil_lt_add_one (inv_nonneg.mpr hv.le)).le
  have hlo' := mul_le_mul_of_nonneg_left hlo hv.le
  have hhi' := mul_le_mul_of_nonneg_left hhi hv.le
  rw [mul_inv_cancel₀ hv.ne'] at hlo'
  have he : v*(v⁻¹+1)=1+v := by field_simp
  rw [he] at hhi'
  exact ⟨hlo',hhi'⟩

/-- The coefficient obtained from the actual paired-network moment theorem,
after Markov's inequality at output gap `1/2`. -/
theorem pair_moment_coefficient_bound {N H : ℕ} (hN : 0 < N) (hH : 60 ≤ H)
    {v Dsq : ℝ} (hv : 0 < v) (hNv : (N : ℝ)*v ≤ 1/16)
    (hD : 0 ≤ Dsq) (hDsmall : Dsq ≤ 9*(1/9)^H) :
    (2*Dsq*v*(1+2*(pairMomentOrder v : ℝ))*(v*(N+2*(pairMomentOrder v : ℝ)))^H)
        ^ pairMomentOrder v ≤ Real.exp (-(11/10)*(H : ℝ)/v) := by
  have hNR : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hvsmall : v ≤ 1/16 := by nlinarith only [hNR,hv,hNv]
  have hp := pairMomentOrder_bounds hv
  have hscalar : v*(1+2*(pairMomentOrder v : ℝ)) ≤ 9/4 := by nlinarith only [hp.2,hvsmall]
  have hmatrix : v*((N : ℝ)+2*(pairMomentOrder v : ℝ)) ≤ 9/4 := by nlinarith only [hp.2,hNv,hvsmall]
  have hbase : 2*Dsq*v*(1+2*(pairMomentOrder v : ℝ))*(v*((N : ℝ)+2*(pairMomentOrder v : ℝ)))^H ≤
      64*(1/4 : ℝ)^H := by
    calc
      _ = 2*Dsq*(v*(1+2*(pairMomentOrder v : ℝ)))*(v*((N : ℝ)+2*(pairMomentOrder v : ℝ)))^H := by ring
      _ ≤ 2*(9*(1/9 : ℝ)^H)*(9/4)*(9/4)^H := by gcongr
      _ = (81/2 : ℝ)*(1/4)^H := by
        rw [show (1/4 : ℝ)^H = (1/9)^H*(9/4)^H by rw [←mul_pow]; norm_num]
        ring
      _ ≤ _ := by gcongr <;> norm_num
  have hnonneg : 0 ≤ 2*Dsq*v*(1+2*(pairMomentOrder v : ℝ))*(v*((N : ℝ)+2*(pairMomentOrder v : ℝ)))^H := by positivity
  calc
    _ ≤ (Real.exp (-(11/10)*(H : ℝ))) ^ pairMomentOrder v :=
      pow_le_pow_left₀ hnonneg (hbase.trans (sixty_four_quarter_pow hH)) _
    _ = Real.exp (-(11/10)*(H : ℝ)*(pairMomentOrder v : ℝ)) := by
      rw [←Real.exp_nat_mul]
      congr 1
      ring
    _ ≤ _ := Real.exp_le_exp.mpr (by
      have horder : v⁻¹ ≤ (pairMomentOrder v : ℝ) := Nat.le_ceil _
      have h := mul_le_mul_of_nonneg_left horder (show 0 ≤ (11/10 : ℝ)*(H : ℝ) by positivity)
      simpa only [div_eq_mul_inv,neg_mul,neg_le_neg_iff] using neg_le_neg h)

#print axioms pair_moment_coefficient_bound
end NeuralGeneralization.BatchTwoContinuousDepthLower
