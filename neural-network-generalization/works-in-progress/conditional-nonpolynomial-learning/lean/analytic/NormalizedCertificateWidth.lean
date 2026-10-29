import SharpMarginPathExtraction
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

lemma x_log_inverse_le_one {x : ℝ} (hx : 0<x) : -x*Real.log x≤1 := by
  have h := Real.log_le_sub_one_of_pos (show 0<x⁻¹ by positivity)
  rw [Real.log_inv] at h
  have hh := mul_le_mul_of_nonneg_left h hx.le
  have hi : x*x⁻¹=1 := mul_inv_cancel₀ hx.ne'
  nlinarith

lemma normalized_log_one_add {x G V : ℝ} (hx : 0<x) (hx1 : x≤1)
    (hG : 0≤G) (hV : x*G≤V) : x*Real.log (1+G)≤Real.log (1+V)+1 := by
  have hV0 : 0≤V := (mul_nonneg hx.le hG).trans hV
  have harg : 1+G≤(1+V)/x := by
    apply (le_div_iff₀ hx).mpr
    nlinarith
  have hlog := Real.log_le_log (show 0<1+G by positivity) harg
  rw [Real.log_div (by positivity) hx.ne'] at hlog
  have hm := mul_le_mul_of_nonneg_left hlog hx.le
  have hl0 : 0≤Real.log (1+V) := Real.log_nonneg (by linarith)
  have hh := mul_le_mul_of_nonneg_right hx1 hl0
  have hi := x_log_inverse_le_one hx
  nlinarith

/-- An explicit width envelope for the entropy certificate, uniform in the
physical scale. U controls normalized action, h controls inverse normalized
slack, and J bounds logarithmic inverse covariance precision. -/
def normalizedCertificateWidth (d r : ℕ) (U h J : ℝ) : ℝ :=
  1+(32*(r+1:ℕ)*(Fintype.card (Cube d × Cube d):ℝ)*h)^2+
  8*h*((r+1:ℕ)*(Fintype.card (Cube d × Cube d):ℝ)*(3+Real.log 5+Real.log (1+U)+J)+
    (Fintype.card (Cube d):ℝ)*Real.log (4*U*h))

lemma certificateWidth_normalized (d r : ℕ) {x A τ U h Δ J : ℝ}
    (hx : 0<x) (hx1 : x≤1) (hA : 0≤A) (hτ : 0<τ)
    (hU : x*(A+τ)≤U) (hh : 1≤x*τ*h)
    (hΔ : 0<Δ) (hΔ1 : Δ≤1) (hJ : Real.log (1/Δ)≤J) :
    certificateWidth d r A τ Δ≤normalizedCertificateWidth d r U h J := by
  have hAτ : 0<A+τ := by linarith
  have hU0 : 0<U := (mul_pos hx hAτ).trans_le hU
  have hh0 : 0<h := by nlinarith [mul_pos hx hτ]
  have hJ0 : 0≤J := (Real.log_nonneg ((one_le_div hΔ).mpr hΔ1)).trans hJ
  have hinvτ : 1/τ≤x*h := by apply (div_le_iff₀ hτ).mpr; nlinarith
  have hτh : 1/τ≤h := hinvτ.trans (by nlinarith)
  have hUh : 1≤U*h := by nlinarith [mul_le_mul_of_nonneg_right hU hh0.le]
  have hG : 0≤(A+τ)/Δ := by positivity
  have hGl := normalized_log_one_add hx hx1 hG
    (show x*((A+τ)/Δ)≤U/Δ by exact (mul_div_assoc x (A+τ) Δ).symm ▸ div_le_div_of_nonneg_right hU hΔ.le)
  have hVlog : Real.log (1+U/Δ)≤Real.log (1+U)+J := by
    have harg : 1+U/Δ≤(1+U)/Δ := by
      apply (le_div_iff₀ hΔ).mpr
      have hid : (U/Δ)*Δ=U := div_mul_cancel₀ U hΔ.ne'
      nlinarith
    have hl := Real.log_le_log (show 0<1+U/Δ by positivity) harg
    rw [Real.log_div (by positivity) hΔ.ne'] at hl
    rw [one_div,Real.log_inv] at hJ
    linarith
  have hmainlog : x*Real.log (1+(A+τ)/Δ)≤Real.log (1+U)+J+1 := by linarith
  let s := τ/(4*(A+τ))
  have hs := certificate_slack_bounds hA hτ
  have hs1 : s≤1 := by dsimp [s]; linarith [hs.2]
  have hsinv : s⁻¹≤4*U*h := by
    have hid : s⁻¹=4*(A+τ)/τ := by dsimp [s]; field_simp
    rw [hid]
    calc
      _ = 4*(A+τ)*(1/τ) := by ring
      _ ≤ 4*(A+τ)*(x*h) := mul_le_mul_of_nonneg_left hinvτ (by positivity)
      _ = 4*(x*(A+τ))*h := by ring
      _ ≤ _ := by nlinarith [mul_le_mul_of_nonneg_right hU hh0.le]
  have hsqrtinv : (Real.sqrt s)⁻¹≤s⁻¹ := by
    apply inv_anti₀ (show 0<s from hs.1)
    have hsq : s^2≤s := by nlinarith [hs.1]
    exact (Real.le_sqrt hs.1.le hs.1.le).mpr hsq
  have hslog : Real.log ((Real.sqrt s)⁻¹)≤Real.log (4*U*h) :=
    Real.log_le_log (by positivity) (hsqrtinv.trans hsinv)
  have hslog0 : 0≤Real.log ((Real.sqrt s)⁻¹) := by
    apply Real.log_nonneg
    exact (one_le_inv₀ (Real.sqrt_pos.mpr hs.1)).mpr (Real.sqrt_le_one.mpr hs1)
  have hlog5 : 0≤Real.log 5 := Real.log_nonneg (by norm_num)
  have hC0 := denseLogConstant_nonneg d r hG hs.1 hs1
  have hC : x*denseLogConstant d r ((A+τ)/Δ) s≤
      (r+1:ℕ)*(Fintype.card (Cube d × Cube d):ℝ)*(3+Real.log 5+Real.log (1+U)+J)+
        (Fintype.card (Cube d):ℝ)*Real.log (4*U*h) := by
    have hbase : x*(2+Real.log 5)≤2+Real.log 5 := mul_le_of_le_one_left (by positivity) hx1
    have hsr : x*Real.log ((Real.sqrt s)⁻¹)≤Real.log (4*U*h) :=
      (mul_le_of_le_one_left hslog0 hx1).trans hslog
    have hm1 := mul_le_mul_of_nonneg_left (add_le_add hbase hmainlog)
      (show 0≤(r+1:ℕ)*(Fintype.card (Cube d × Cube d):ℝ) by positivity)
    have hm2 := mul_le_mul_of_nonneg_left hsr
      (show 0≤(Fintype.card (Cube d):ℝ) by positivity)
    dsimp [denseLogConstant]
    nlinarith
  have hquad : (16*(r+1:ℕ)*(Fintype.card (Cube d × Cube d):ℝ)/(τ/2))^2≤
      (32*(r+1:ℕ)*(Fintype.card (Cube d × Cube d):ℝ)*h)^2 := by
    apply pow_le_pow_left₀ (by positivity)
    have hm := mul_le_mul_of_nonneg_left hτh
      (show 0≤32*(r+1:ℕ)*(Fintype.card (Cube d × Cube d):ℝ) by positivity)
    convert hm using 1 <;> ring
  have hlin : 4*denseLogConstant d r ((A+τ)/Δ) s/(τ/2)≤
      8*h*((r+1:ℕ)*(Fintype.card (Cube d × Cube d):ℝ)*(3+Real.log 5+Real.log (1+U)+J)+
        (Fintype.card (Cube d):ℝ)*Real.log (4*U*h)) := by
    have hm := mul_le_mul_of_nonneg_left hinvτ (show 0≤8*denseLogConstant d r ((A+τ)/Δ) s by positivity)
    have hn := mul_le_mul_of_nonneg_left hC (show 0≤8*h by positivity)
    have hid : 4*denseLogConstant d r ((A+τ)/Δ) s/(τ/2)=
      8*denseLogConstant d r ((A+τ)/Δ) s*(1/τ) := by ring
    rw [hid]
    nlinarith
  unfold certificateWidth denseWidthBudget normalizedCertificateWidth
  change 1+_+4*denseLogConstant d r ((A+τ)/Δ) s/(τ/2)≤_
  linarith

#print axioms certificateWidth_normalized
end ConditionalNonpolynomial.Analytic
