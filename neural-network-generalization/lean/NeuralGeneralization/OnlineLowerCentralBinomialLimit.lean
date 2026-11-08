import NeuralGeneralization.OnlineLowerCentralBinomialWallis

noncomputable section
open scoped Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh

lemma scaled_oddParityKappa_eq_sqrt_wallis (r:ℕ) :
    Real.sqrt (2*(r:ℝ)+1)*oddParityKappa r=Real.sqrt ((Real.Wallis.W r)⁻¹) := by
  have hk:=oddParityKappa_pos r
  have hW:=Real.Wallis.W_pos r
  have hi:=wallis_kappa_identity r
  have hs: (Real.sqrt (2*(r:ℝ)+1)*oddParityKappa r)^2=(Real.Wallis.W r)⁻¹ := by
    rw [mul_pow,Real.sq_sqrt (by positivity)]
    rw [inv_eq_one_div]
    apply (eq_div_iff hW.ne').mpr
    nlinarith
  rw [←hs,Real.sqrt_sq (by positivity)]

/-- The actual normalized odd central-binomial coefficient tends to the
Gaussian density constant; no asymptotic coefficient is assumed. -/
theorem scaled_oddParityKappa_tendsto :
    Tendsto (fun r:ℕ=>Real.sqrt (2*(r:ℝ)+1)*oddParityKappa r) atTop
      (𝓝 (Real.sqrt (2/Real.pi))) := by
  have ht:=Real.continuous_sqrt.tendsto ((Real.pi/2)⁻¹) |>.comp
    (Real.Wallis.tendsto_W_nhds_pi_div_two.inv₀ (by positivity))
  simpa only [Function.comp_def,scaled_oddParityKappa_eq_sqrt_wallis,inv_div,inv_inv] using ht

end NeuralGeneralization.OnlineLowerTanh
