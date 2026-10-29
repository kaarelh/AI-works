import PhysicalNormalizedCompression

/-! Explicit polynomial precision for the uniform physical compression. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic

lemma normalizedAnchorError_pow_eight {r : ℝ} (hr : 0≤r) (hr1 : r≤1) :
    normalizedAnchorError (r^8)≤64*r := by
  have hpow : r^8≤r^2 := pow_le_pow_of_le_one hr hr1 (by omega)
  have hs1 : Real.sqrt (r^8)=r^4 := by
    rw [show r^8=(r^4)^2 by ring,Real.sqrt_sq_eq_abs,abs_of_nonneg (by positivity)]
  have hs2 : Real.sqrt (r^4)=r^2 := by
    rw [show r^4=(r^2)^2 by ring,Real.sqrt_sq_eq_abs,abs_of_nonneg (sq_nonneg r)]
  have hm : gaussianAnchorModulus (r^8)≤536*r^2 := by
    unfold gaussianAnchorModulus
    rw [hs1,hs2]
    nlinarith
  have hs : (normalizedAnchorError (r^8))^2=2*gaussianAnchorModulus (r^8) := by
    unfold normalizedAnchorError
    rw [mul_pow,Real.sq_sqrt (by norm_num),Real.sq_sqrt (gaussianAnchorModulus_nonneg (by positivity))]
  nlinarith [normalizedAnchorError_nonneg (r^8)]

/-- Choosing an eighth power in inverse polynomial resources gives any desired
prediction precision. All resource dependence is explicit. -/
theorem physical_compression_error_precision {H : ℕ} {W G ε : ℝ}
    (hW : 0≤W) (hG : 0≤G) (hε : 0<ε) (hε1 : ε≤1) :
    W*((H:ℝ)*normalizedAnchorError
      ((ε/(64*((H:ℝ)+1)*(W+1)*(G+1)))^8)*G)≤ε := by
  let r := ε/(64*((H:ℝ)+1)*(W+1)*(G+1))
  have hden : 0<64*((H:ℝ)+1)*(W+1)*(G+1) := by positivity
  have hr : 0≤r := div_nonneg hε.le hden.le
  have hden1 : 1≤64*((H:ℝ)+1)*(W+1)*(G+1) := by
    have h1 : 1≤(H:ℝ)+1 := by linarith [Nat.cast_nonneg (α := ℝ) H]
    have h2 : 1≤W+1 := by linarith
    have h3 : 1≤G+1 := by linarith
    have hm := mul_le_mul h1 h2 zero_le_one (by positivity : 0≤(H:ℝ)+1)
    have hm' := mul_le_mul hm h3 zero_le_one (mul_nonneg (by positivity) (by linarith))
    nlinarith
  have hr1 : r≤1 := (div_le_one hden).mpr (hε1.trans hden1)
  have he := normalizedAnchorError_pow_eight hr hr1
  have hcoef : W*(H:ℝ)*G≤((H:ℝ)+1)*(W+1)*(G+1) := by
    have h1 := mul_le_mul (show (H:ℝ)≤(H:ℝ)+1 by linarith)
      (show W≤W+1 by linarith) hW (by positivity : 0≤(H:ℝ)+1)
    have h2 := mul_le_mul h1 (show G≤G+1 by linarith) hG (by positivity : 0≤((H:ℝ)+1)*(W+1))
    nlinarith only [h2]
  have heq : (64*((H:ℝ)+1)*(W+1)*(G+1))*r=ε := mul_div_cancel₀ ε hden.ne'
  have hb := mul_le_mul_of_nonneg_right hcoef (show 0≤64*r by positivity)
  have hh := mul_le_mul_of_nonneg_left he (show 0≤W*(H:ℝ)*G by positivity)
  change W*((H:ℝ)*normalizedAnchorError (r^8)*G)≤ε
  nlinarith only [hb,hh,heq]

#print axioms physical_compression_error_precision
end ConditionalNonpolynomial.Analytic
