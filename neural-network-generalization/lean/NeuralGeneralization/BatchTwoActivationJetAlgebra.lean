import NeuralGeneralization.BatchTwoActivationBoundedJet

/-! Closure of actual bounded C² observables under products and finite linear
combinations, with entrywise derivative-sum bounds. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open FiniteDifferential TanhDifferential
namespace BoundedJet
variable {I : Type*} [Fintype I] {b₀ b₁ b₂ c₀ c₁ c₂ : ℝ}

def productGrad (F : BoundedJet I b₀ b₁ b₂) (G : BoundedJet I c₀ c₁ c₂)
    (z : I→ℝ) (i : I) : ℝ := F.grad z i*G.value z+F.value z*G.grad z i

def productHess (F : BoundedJet I b₀ b₁ b₂) (G : BoundedJet I c₀ c₁ c₂)
    (z : I→ℝ) (i j : I) : ℝ :=
  F.hess z i j*G.value z+F.grad z i*G.grad z j+
    F.grad z j*G.grad z i+F.value z*G.hess z i j

theorem product_derivative (F : BoundedJet I b₀ b₁ b₂) (G : BoundedJet I c₀ c₁ c₂)
    (z : I→ℝ) : HasFDerivAt (fun y=>F.value y*G.value y)
      (gradientLinear (productGrad F G z)) z := by
  apply ((F.derivative z).mul (G.derivative z)).congr_fderiv
  ext v
  simp only [add_apply,smul_apply,smul_eq_mul,gradientLinear_apply,productGrad]
  simp_rw [Finset.mul_sum,add_mul,←Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i hi
  ring

theorem productGrad_derivative (F : BoundedJet I b₀ b₁ b₂) (G : BoundedJet I c₀ c₁ c₂)
    (z : I→ℝ) (i : I) : HasFDerivAt (fun y=>productGrad F G y i)
      (gradientLinear (productHess F G z i)) z := by
  apply (((F.grad_derivative z i).mul (G.derivative z)).add
    ((F.derivative z).mul (G.grad_derivative z i))).congr_fderiv
  ext v
  simp only [add_apply,smul_apply,smul_eq_mul,gradientLinear_apply,productHess]
  simp_rw [Finset.mul_sum,add_mul,←Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro j hj
  ring

theorem productGrad_sum (F : BoundedJet I b₀ b₁ b₂) (G : BoundedJet I c₀ c₁ c₂)
    (hb₀ : 0≤b₀) (hb₁ : 0≤b₁) (hc₀ : 0≤c₀) (z : I→ℝ) :
    (∑i,|productGrad F G z i|)≤b₁*c₀+b₀*c₁ := by
  calc
    _ ≤ ∑i,(|F.grad z i| *|G.value z|+|F.value z| *|G.grad z i|) := by
      apply Finset.sum_le_sum
      intro i hi
      simpa only [productGrad,abs_mul] using abs_add_le (F.grad z i*G.value z) (F.value z*G.grad z i)
    _ = (∑i,|F.grad z i|)*|G.value z|+|F.value z| *(∑i,|G.grad z i|) := by
      simp [Finset.sum_add_distrib,←Finset.sum_mul,←Finset.mul_sum]
    _ ≤ _ := add_le_add
      (mul_le_mul (F.grad_bound z) (G.value_bound z) (abs_nonneg _) hb₁)
      (mul_le_mul (F.value_bound z) (G.grad_bound z) (by positivity) hb₀)

theorem productHess_sum (F : BoundedJet I b₀ b₁ b₂) (G : BoundedJet I c₀ c₁ c₂)
    (hb₀ : 0≤b₀) (hb₁ : 0≤b₁) (hb₂ : 0≤b₂) (hc₀ : 0≤c₀) (z : I→ℝ) :
    (∑i,∑j,|productHess F G z i j|)≤b₂*c₀+2*b₁*c₁+b₀*c₂ := by
  have hcross := mul_le_mul (F.grad_bound z) (G.grad_bound z) (by positivity) hb₁
  calc
    _ ≤ ∑i,∑j,(|F.hess z i j| *|G.value z|+|F.grad z i| *|G.grad z j|+
        |F.grad z j| *|G.grad z i|+|F.value z| *|G.hess z i j|) := by
      apply Finset.sum_le_sum
      intro i hi
      apply Finset.sum_le_sum
      intro j hj
      have h₁ := abs_add_le (F.hess z i j*G.value z) (F.grad z i*G.grad z j)
      have h₂ := abs_add_le (F.hess z i j*G.value z+F.grad z i*G.grad z j) (F.grad z j*G.grad z i)
      have h₃ := abs_add_le (F.hess z i j*G.value z+F.grad z i*G.grad z j+F.grad z j*G.grad z i)
        (F.value z*G.hess z i j)
      simp only [abs_mul] at h₁ h₂ h₃
      unfold productHess
      linarith
    _ = (∑i,∑j,|F.hess z i j|)*|G.value z|+
        2*((∑i,|F.grad z i|)*(∑j,|G.grad z j|))+
        |F.value z| *(∑i,∑j,|G.hess z i j|) := by
      simp_rw [Finset.sum_add_distrib,←Finset.mul_sum,←Finset.sum_mul]
      rw [←Finset.mul_sum]
      ring
    _ ≤ _ := by
      have hfirst := mul_le_mul (F.hess_bound z) (G.value_bound z) (abs_nonneg _) hb₂
      have hlast := mul_le_mul (F.value_bound z) (G.hess_bound z) (by positivity) hb₀
      nlinarith

def mul (F : BoundedJet I b₀ b₁ b₂) (G : BoundedJet I c₀ c₁ c₂)
    (hb₀ : 0≤b₀) (hb₁ : 0≤b₁) (hb₂ : 0≤b₂) (hc₀ : 0≤c₀) :
    BoundedJet I (b₀*c₀) (b₁*c₀+b₀*c₁) (b₂*c₀+2*b₁*c₁+b₀*c₂) where
  value := fun z=>F.value z*G.value z
  grad := productGrad F G
  hess := productHess F G
  derivative := product_derivative F G
  grad_derivative := productGrad_derivative F G
  hess_continuous := fun i j=>by
    have hf := F.continuous
    have hg := G.continuous
    have hf₁ := F.grad_continuous
    have hg₁ := G.grad_continuous
    have hf₂ := F.hess_continuous
    have hg₂ := G.hess_continuous
    unfold productHess
    fun_prop
  value_bound := fun z=>by
    rw [abs_mul]
    exact mul_le_mul (F.value_bound z) (G.value_bound z) (abs_nonneg _) hb₀
  grad_bound := productGrad_sum F G hb₀ hb₁ hc₀
  hess_bound := productHess_sum F G hb₀ hb₁ hb₂ hc₀

end BoundedJet
end NeuralGeneralization.BatchTwoActivation
