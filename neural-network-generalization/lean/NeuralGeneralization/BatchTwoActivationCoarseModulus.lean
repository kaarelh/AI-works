import NeuralGeneralization.BatchTwoActivationOneStep

/-! A deliberately loose polynomial bound for the actual Gaussian Price
modulus. It is useful when iterating precision budgets at fixed depth. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoActivation

theorem boundedCovarianceModulus_nonneg {b₀ b₁ b₂ G : ℝ}
    (h₀ : 0≤b₀) (h₁ : 0≤b₁) (h₂ : 0≤b₂) (hG : 0≤G) :
    0≤boundedCovarianceModulus b₀ b₁ b₂ G := by
  unfold boundedCovarianceModulus
  positivity

theorem boundedCovarianceModulus_coarse {b₀ b₁ b₂ G Z : ℝ}
    (hZ : 1≤Z) (h₀ : 0≤b₀) (h₁ : 0≤b₁) (h₂ : 0≤b₂) (hG : 0≤G)
    (hb₀ : b₀≤Z) (hb₁ : b₁≤Z) (hb₂ : b₂≤Z) (hGZ : G≤Z) :
    boundedCovarianceModulus b₀ b₁ b₂ G≤32*Z^8 := by
  have hZ0 : 0≤Z := by linarith
  have h00 : b₀*b₀≤Z^2 := by nlinarith [mul_le_mul hb₀ hb₀ h₀ hZ0]
  have h10 : b₁*b₀≤Z^2 := by nlinarith [mul_le_mul hb₁ hb₀ h₀ hZ0]
  have h20 : b₂*b₀≤Z^2 := by nlinarith [mul_le_mul hb₂ hb₀ h₀ hZ0]
  have h11 : b₁*b₁≤Z^2 := by nlinarith [mul_le_mul hb₁ hb₁ h₁ hZ0]
  have h01 : b₀*b₁≤Z^2 := by nlinarith [mul_le_mul hb₀ hb₁ h₁ hZ0]
  have h02 : b₀*b₂≤Z^2 := by nlinarith [mul_le_mul hb₀ hb₂ h₂ hZ0]
  have hF₁ : b₁*b₀+b₀*b₁≤2*Z^2 := by linarith
  have hF₂ : b₂*b₀+2*b₁*b₁+b₀*b₂≤4*Z^2 := by nlinarith
  have hF₁0 : 0≤b₁*b₀+b₀*b₁ := by positivity
  have hF₂0 : 0≤b₂*b₀+2*b₁*b₁+b₀*b₂ := by positivity
  have hg1 : G*(b₁*b₀+b₀*b₁)≤Z*(2*Z^2) := mul_le_mul hGZ hF₁ hF₁0 hZ0
  have hg2 : G*(b₂*b₀+2*b₁*b₁+b₀*b₂)≤Z*(4*Z^2) := mul_le_mul hGZ hF₂ hF₂0 hZ0
  have hs : (G*(b₁*b₀+b₀*b₁))^2≤(Z*(2*Z^2))^2 :=
    pow_le_pow_left₀ (by positivity) hg1 2
  have ht1 : 2*(b₁*b₀+b₀*b₁)*(G*(b₁*b₀+b₀*b₁))≤2*(2*Z^2)*(Z*(2*Z^2)) := by
    gcongr
  have ht2 : 2*(b₀*b₀)*(G*(b₂*b₀+2*b₁*b₁+b₀*b₂)+(G*(b₁*b₀+b₀*b₁))^2)≤
      2*Z^2*(Z*(4*Z^2)+(Z*(2*Z^2))^2) := by
    exact mul_le_mul (mul_le_mul_of_nonneg_left h00 (by norm_num))
      (add_le_add hg2 hs) (by positivity) (by positivity)
  unfold boundedCovarianceModulus
  have hsum := add_le_add (add_le_add hF₂ ht1) ht2
  have he : 4*Z^2+2*(2*Z^2)*(Z*(2*Z^2))+2*Z^2*(Z*(4*Z^2)+(Z*(2*Z^2))^2)=
      4*Z^2+16*Z^5+8*Z^8 := by ring
  rw [he] at hsum
  have h28 := pow_le_pow_right₀ hZ (show 2≤8 by omega)
  have h58 := pow_le_pow_right₀ hZ (show 5≤8 by omega)
  nlinarith [pow_nonneg hZ0 8]

end NeuralGeneralization.BatchTwoActivation
