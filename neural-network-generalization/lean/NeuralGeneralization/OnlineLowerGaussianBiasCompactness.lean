import Mathlib.Analysis.Complex.ExponentialBounds
import Mathlib.Tactic

/-! The quantitative Gaussian envelope forces every maximizing bias into
one fixed compact interval. No tail-regime split is needed. -/
noncomputable section
namespace NeuralGeneralization.OnlineLowerTanh

/-- An arbitrary real bias obeying the leading Gaussian comparison is
uniformly bounded once the degree exceeds the explicit constant threshold. -/
theorem gaussian_bias_compact (n a A α K B:ℝ)
    (hn:0<n) (ha:0<a) (ha2:a≤2) (hα:0<α) (hA:α≤A) (hK:0≤K)
    (hthreshold:4*K≤n*α)
    (hcompare:A-K/n≤Real.exp (-(B^2/(2*a^2*n)))*(A+K*|B|/n)+K/n) :
    |B|≤1+64*K/α := by
  let z:=B^2/(2*a^2*n)
  have hz:0≤z := by dsimp [z]; positivity
  have hzid:z*(2*a^2*n)=B^2 := by dsimp [z]; field_simp
  have hexp:z≤Real.exp z-1 := by linarith [Real.add_one_le_exp z]
  have hecancel:Real.exp (-z)*Real.exp z=1 := by rw [←Real.exp_add]; simp
  have hbase:n*A-2*K≤Real.exp (-z)*(n*A+K*|B|) := by
    have hh:=mul_le_mul_of_nonneg_right hcompare hn.le
    have hn0:n≠0 := hn.ne'
    field_simp [hn0] at hh
    rw [show -(B^2/(n*2*a^2))=-(B^2/(2*a^2*n)) by ring] at hh
    dsimp [z]
    nlinarith
  have hbase':(n*A-2*K)*Real.exp z≤n*A+K*|B| := by
    have hh:=mul_le_mul_of_nonneg_right hbase (Real.exp_pos z).le
    calc
      _ ≤ (Real.exp (-z)*(n*A+K*|B|))*Real.exp z := hh
      _ = _ := by rw [mul_right_comm,hecancel,one_mul]
  have hcoef:0≤n*A-2*K := by nlinarith [mul_le_mul_of_nonneg_left hA hn.le]
  have hquad:(n*A-2*K)*z≤K*|B|+2*K := by
    have hh:=mul_le_mul_of_nonneg_left hexp hcoef
    nlinarith
  have hsmall:n*α/2≤n*A-2*K := by nlinarith [mul_le_mul_of_nonneg_left hA hn.le]
  have hquad':n*α*z≤2*K*|B|+4*K := by
    have hh:=mul_le_mul_of_nonneg_right hsmall hz
    nlinarith
  have haSq:a^2≤4 := by nlinarith
  have hzlow:B^2≤8*n*z := by
    have hh:=mul_le_mul_of_nonneg_right haSq (mul_nonneg hn.le hz)
    nlinarith [hzid]
  have hfinal:α*B^2≤16*K*|B|+32*K := by
    have hh:=mul_le_mul_of_nonneg_left hzlow hα.le
    nlinarith [hquad']
  by_contra hnot
  have hB:1+64*K/α < |B| := lt_of_not_ge hnot
  have hfrac:0≤64*K/α := by positivity
  have hB1:1 < |B| := by linarith
  have hmul:α+64*K<α*|B| := by
    have hh:=mul_lt_mul_of_pos_right hB hα
    field_simp [hα.ne'] at hh
    nlinarith
  have hstrict:64*K*|B|<α*B^2 := by
    have hh:=mul_lt_mul_of_pos_right (show 64*K<α*|B| by linarith) (lt_trans (by norm_num) hB1)
    nlinarith [sq_abs B]
  have hKabs:K≤K*|B| := by nlinarith [mul_le_mul_of_nonneg_left hB1.le hK]
  nlinarith [mul_nonneg hK (abs_nonneg B)]

end NeuralGeneralization.OnlineLowerTanh
