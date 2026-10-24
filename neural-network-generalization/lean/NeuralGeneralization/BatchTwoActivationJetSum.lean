import NeuralGeneralization.BatchTwoActivationJetAlgebra

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open FiniteDifferential TanhDifferential
namespace BoundedJet
variable {I J : Type*} [Fintype I] [Fintype J] {b₀ b₁ b₂ : ℝ}

def sumValue (F : J→BoundedJet I b₀ b₁ b₂) (w : J→ℝ) (z : I→ℝ) : ℝ := ∑k,w k*(F k).value z
def sumGrad (F : J→BoundedJet I b₀ b₁ b₂) (w : J→ℝ) (z : I→ℝ) (i : I) : ℝ := ∑k,w k*(F k).grad z i
def sumHess (F : J→BoundedJet I b₀ b₁ b₂) (w : J→ℝ) (z : I→ℝ) (i j : I) : ℝ := ∑k,w k*(F k).hess z i j

theorem sum_derivative (F : J→BoundedJet I b₀ b₁ b₂) (w : J→ℝ) (z : I→ℝ) :
    HasFDerivAt (sumValue F w) (gradientLinear (sumGrad F w z)) z := by
  have h := HasFDerivAt.sum (fun k (_:k∈Finset.univ)=>(F k).derivative z |>.const_mul (w k))
  have hf : sumValue F w=∑k,(fun y=>w k*(F k).value y) := by ext y; simp [sumValue]
  rw [hf]
  apply h.congr_fderiv
  ext v
  simp only [sumGrad,gradientLinear_apply,sum_apply,smul_apply,smul_eq_mul,Finset.sum_mul,Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i hi
  apply Finset.sum_congr rfl
  intro k hk
  ring

theorem sumGrad_derivative (F : J→BoundedJet I b₀ b₁ b₂) (w : J→ℝ) (z : I→ℝ) (i : I) :
    HasFDerivAt (fun y=>sumGrad F w y i) (gradientLinear (sumHess F w z i)) z := by
  have h := HasFDerivAt.sum (fun k (_:k∈Finset.univ)=>(F k).grad_derivative z i |>.const_mul (w k))
  have hf : (fun y=>sumGrad F w y i)=∑k,(fun y=>w k*(F k).grad y i) := by ext y; simp [sumGrad]
  rw [hf]
  apply h.congr_fderiv
  ext v
  simp only [sumHess,gradientLinear_apply,sum_apply,smul_apply,smul_eq_mul,Finset.sum_mul,Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j hj
  apply Finset.sum_congr rfl
  intro k hk
  ring

theorem sumGrad_bound (F : J→BoundedJet I b₀ b₁ b₂) (w : J→ℝ) (z : I→ℝ) :
    (∑i,|sumGrad F w z i|)≤(∑k,|w k|)*b₁ := by
  calc
    _ ≤ ∑i,∑k,|w k| *|(F k).grad z i| := Finset.sum_le_sum fun i _=>by
      simpa only [sumGrad,abs_mul] using Finset.abs_sum_le_sum_abs (fun k=>w k*(F k).grad z i) Finset.univ
    _ = ∑k,|w k| *(∑i,|(F k).grad z i|) := by rw [Finset.sum_comm]; simp [Finset.mul_sum]
    _ ≤ ∑k,|w k| *b₁ := Finset.sum_le_sum fun k _=>mul_le_mul_of_nonneg_left ((F k).grad_bound z) (abs_nonneg _)
    _ = _ := (Finset.sum_mul ..).symm

theorem sumHess_bound (F : J→BoundedJet I b₀ b₁ b₂) (w : J→ℝ) (z : I→ℝ) :
    (∑i,∑j,|sumHess F w z i j|)≤(∑k,|w k|)*b₂ := by
  calc
    _ ≤ ∑i,∑j,∑k,|w k| *|(F k).hess z i j| := Finset.sum_le_sum fun i _=>
      Finset.sum_le_sum fun j _=>by
        simpa only [sumHess,abs_mul] using Finset.abs_sum_le_sum_abs (fun k=>w k*(F k).hess z i j) Finset.univ
    _ = ∑k,|w k| *(∑i,∑j,|(F k).hess z i j|) := by
      simp_rw [Finset.sum_comm (f:=fun j k=>|w k| *|(F k).hess z _ j|)]
      rw [Finset.sum_comm]
      simp [Finset.mul_sum]
    _ ≤ ∑k,|w k| *b₂ := Finset.sum_le_sum fun k _=>mul_le_mul_of_nonneg_left ((F k).hess_bound z) (abs_nonneg _)
    _ = _ := (Finset.sum_mul ..).symm

def linearCombination (F : J→BoundedJet I b₀ b₁ b₂) (w : J→ℝ) {G : ℝ}
    (hw : (∑k,|w k|)≤G) (hb₀ : 0≤b₀) (hb₁ : 0≤b₁) (hb₂ : 0≤b₂) :
    BoundedJet I (G*b₀) (G*b₁) (G*b₂) where
  value := sumValue F w
  grad := sumGrad F w
  hess := sumHess F w
  derivative := sum_derivative F w
  grad_derivative := sumGrad_derivative F w
  hess_continuous := fun i j=>by
    have hh := fun k=>(F k).hess_continuous i j
    unfold sumHess
    fun_prop
  value_bound := fun z=>by
    calc
      _ ≤ ∑k,|w k| *|(F k).value z| := by
        simpa only [sumValue,abs_mul] using Finset.abs_sum_le_sum_abs (fun k=>w k*(F k).value z) Finset.univ
      _ ≤ ∑k,|w k| *b₀ := Finset.sum_le_sum (fun k _=>mul_le_mul_of_nonneg_left ((F k).value_bound z) (abs_nonneg _))
      _ = (∑k,|w k|)*b₀ := (Finset.sum_mul ..).symm
      _ ≤ _ := mul_le_mul_of_nonneg_right hw hb₀
  grad_bound := fun z=>(sumGrad_bound F w z).trans (mul_le_mul_of_nonneg_right hw hb₁)
  hess_bound := fun z=>(sumHess_bound F w z).trans (mul_le_mul_of_nonneg_right hw hb₂)

end BoundedJet
end NeuralGeneralization.BatchTwoActivation
