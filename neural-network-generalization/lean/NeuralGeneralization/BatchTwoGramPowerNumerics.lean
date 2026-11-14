import NeuralGeneralization.BatchTwoGramPowerTail

/-! Numerical optimization of the polynomial potential to the manuscript's
conservative matrix-Chernoff constant. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
namespace NeuralGeneralization.BatchTwoGramPower

theorem gram_exponent_coefficient {d : ℝ} (hd : 1≤d) :
    1/(16*(d+1))≤3/(8*(2*d+1))-d/(4*d*(2*d+1)-1) := by
  have hd0 : 0<d := by linarith
  have hden : 0<4*d*(2*d+1)-1 := by nlinarith
  have hden2 : 0<2*d+1 := by positivity
  have hden3 : 0<d+1 := by positivity
  have hdn : d*(d*2+1)*4-1≠0 := by nlinarith
  have he : 3/(8*(2*d+1))-d/(4*d*(2*d+1)-1)-1/(16*(d+1))=
      (8*d^2-5)/(16*(d+1)*(2*d+1)*(4*d*(2*d+1)-1)) := by
    field_simp [hdn,ne_of_gt hden,ne_of_gt hden2,ne_of_gt hden3]
    ring_nf
    field_simp [show -1+d*4+d^2*8≠0 by nlinarith]
    <;> ring
  have hn : 0≤8*d^2-5 := by nlinarith [sq_nonneg (d-1)]
  have hh := div_nonneg hn (show 0≤16*(d+1)*(2*d+1)*(4*d*(2*d+1)-1) by positivity)
  rw [←he] at hh
  linarith

theorem gram_power_ratio_exp {d : ℝ} (hd : 1≤d) (n k : ℕ)
    (hk : (k:ℝ)=(n:ℝ)*d) :
    (1-3/(8*(2*d+1)))^n/(1-1/(4*d*(2*d+1)))^k≤
      Real.exp (-(n:ℝ)/(16*(d+1))) := by
  have hd0 : 0<d := by linarith
  have hxden : 1<4*d*(2*d+1) := by nlinarith
  have hyden : 3<8*(2*d+1) := by linarith
  have hx : 0<1-1/(4*d*(2*d+1)) := by
    have := (div_lt_one (by positivity : 0<4*d*(2*d+1))).mpr hxden
    linarith
  have hy : 0<1-3/(8*(2*d+1)) := by
    have := (div_lt_one (by positivity : 0<8*(2*d+1))).mpr hyden
    linarith
  have hlogy : Real.log (1-3/(8*(2*d+1)))≤ -3/(8*(2*d+1)) := by
    convert Real.log_le_sub_one_of_pos hy using 1 <;> ring
  have hlogx : -Real.log (1-1/(4*d*(2*d+1)))≤1/(4*d*(2*d+1)-1) := by
    have hh := Real.one_sub_inv_le_log_of_pos hx
    have hdn : d*(d*2+1)*4-1≠0 := by nlinarith
    have he : (1-1/(4*d*(2*d+1)))⁻¹-1=1/(4*d*(2*d+1)-1) := by
      field_simp [hdn,ne_of_gt (sub_pos.mpr hxden),ne_of_gt hd0,ne_of_gt (show 0<2*d+1 by positivity)]
      <;> ring_nf
      field_simp [show -1+d*4+d^2*8≠0 by nlinarith]
      <;> ring
    linarith
  have hlog : Real.log ((1-3/(8*(2*d+1)))^n/(1-1/(4*d*(2*d+1)))^k)≤
      -(n:ℝ)/(16*(d+1)) := by
    rw [Real.log_div (ne_of_gt (pow_pos hy _)) (ne_of_gt (pow_pos hx _)),
      Real.log_pow,Real.log_pow,hk]
    have h1 := mul_le_mul_of_nonneg_left hlogy (Nat.cast_nonneg n)
    have h2 := mul_le_mul_of_nonneg_left hlogx (show 0≤(n:ℝ)*d by positivity)
    have h3 := mul_le_mul_of_nonneg_left (gram_exponent_coefficient hd) (Nat.cast_nonneg n)
    ring_nf at h1 h2 h3 ⊢
    linarith only [h1,h2,h3]
  simpa only [Real.exp_log (div_pos (pow_pos hy _) (pow_pos hx _))] using Real.exp_le_exp.mpr hlog

end NeuralGeneralization.BatchTwoGramPower
