import NeuralGeneralization.ExponentialHessian
import NeuralGeneralization.GaussianPriceBounds

/-! Actual twice differentiable bounded observables with entrywise derivative
sum bounds. These analytic hypotheses are used only in intermediate Price
lemmas; the learner's activation is not assumed differentiable. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open FiniteDifferential TanhDifferential

structure BoundedJet (I : Type*) [Fintype I] (b₀ b₁ b₂ : ℝ) where
  value : (I→ℝ)→ℝ
  grad : (I→ℝ)→I→ℝ
  hess : (I→ℝ)→I→I→ℝ
  derivative : ∀z, HasFDerivAt value (gradientLinear (grad z)) z
  grad_derivative : ∀z i, HasFDerivAt (fun y=>grad y i) (gradientLinear (hess z i)) z
  hess_continuous : ∀i j, Continuous (fun z=>hess z i j)
  value_bound : ∀z, |value z|≤b₀
  grad_bound : ∀z, (∑i,|grad z i|)≤b₁
  hess_bound : ∀z, (∑i,∑j,|hess z i j|)≤b₂

namespace BoundedJet
variable {I : Type*} [Fintype I] {b₀ b₁ b₂ c₀ c₁ c₂ : ℝ}

theorem continuous (F : BoundedJet I b₀ b₁ b₂) : Continuous F.value :=
  continuous_iff_continuousAt.mpr (fun z=>(F.derivative z).continuousAt)

theorem grad_continuous (F : BoundedJet I b₀ b₁ b₂) (i : I) :
    Continuous (fun z=>F.grad z i) :=
  continuous_iff_continuousAt.mpr (fun z=>(F.grad_derivative z i).continuousAt)

theorem grad_entry_bound (F : BoundedJet I b₀ b₁ b₂) (z : I→ℝ) (i : I) :
    |F.grad z i|≤b₁ :=
  (Finset.single_le_sum (fun j _=>abs_nonneg (F.grad z j)) (Finset.mem_univ i)).trans (F.grad_bound z)

theorem hess_entry_bound (F : BoundedJet I b₀ b₁ b₂) (z : I→ℝ) (i j : I) :
    |F.hess z i j|≤b₂ := by
  calc
    _ ≤ ∑k,|F.hess z i k| := Finset.single_le_sum (fun k _=>abs_nonneg _) (Finset.mem_univ j)
    _ ≤ ∑k,∑l,|F.hess z k l| := Finset.single_le_sum (f := fun k=>∑l,|F.hess z k l|)
      (fun k _=>Finset.sum_nonneg (fun l _=>abs_nonneg _)) (Finset.mem_univ i)
    _ ≤ _ := F.hess_bound z

theorem exp_gradient_bound (V : BoundedJet I c₀ c₁ c₂) (hc₁ : 0≤c₁)
    (z : I→ℝ) (i : I) :
    |expGradient V.value V.grad z i|≤Real.exp c₀*c₁ := by
  unfold expGradient
  rw [abs_mul,Real.abs_exp]
  exact mul_le_mul (Real.exp_le_exp.mpr ((le_abs_self _).trans (V.value_bound z)))
    (V.grad_entry_bound z i) (abs_nonneg _) (Real.exp_nonneg _)

theorem exp_hessian_bound (V : BoundedJet I c₀ c₁ c₂) (hc₁ : 0≤c₁)
    (z : I→ℝ) :
    (∑i,∑j,|expHessian V.value V.grad V.hess z i j|)≤
      (c₂+c₁^2)*Real.exp (V.value z) := by
  have hs := (sq_le_sq₀ (Finset.sum_nonneg fun i _=>abs_nonneg _) hc₁).2 (V.grad_bound z)
  have hh := add_le_add (V.hess_bound z) hs
  exact (expHessian_l1_le _ _ _ z).trans
    (by simpa only [mul_comm] using mul_le_mul_of_nonneg_left hh (Real.exp_nonneg _))

theorem weighted_gradient_bound (F : BoundedJet I b₀ b₁ b₂)
    (V : BoundedJet I c₀ c₁ c₂) (hb₀ : 0≤b₀) (hb₁ : 0≤b₁) (hc₁ : 0≤c₁)
    (z : I→ℝ) (i : I) :
    |weightedGradient F.value F.grad V.value V.grad z i|≤Real.exp c₀*(b₁+b₀*c₁) := by
  have hsum : (∑j,|F.grad z j|)+|F.value z| *(∑j,|V.grad z j|)≤b₁+b₀*c₁ :=
    add_le_add (F.grad_bound z) (mul_le_mul (F.value_bound z) (V.grad_bound z)
      (Finset.sum_nonneg fun j _=>abs_nonneg _) hb₀)
  calc
    _ ≤ ∑j,|weightedGradient F.value F.grad V.value V.grad z j| :=
      Finset.single_le_sum (fun j _=>abs_nonneg _) (Finset.mem_univ i)
    _ ≤ _ := weightedGradient_l1_le _ _ _ _ z
    _ ≤ _ := mul_le_mul (Real.exp_le_exp.mpr ((le_abs_self _).trans (V.value_bound z)))
      hsum (by positivity) (Real.exp_nonneg _)

theorem weighted_hessian_bound (F : BoundedJet I b₀ b₁ b₂)
    (V : BoundedJet I c₀ c₁ c₂) (hb₀ : 0≤b₀) (hb₁ : 0≤b₁) (hc₁ : 0≤c₁)
    (z : I→ℝ) :
    (∑i,∑j,|weightedHessian F.value F.grad F.hess V.value V.grad V.hess z i j|)≤
      (b₂+2*b₁*c₁+b₀*(c₂+c₁^2))*Real.exp (V.value z) := by
  have hs := (sq_le_sq₀ (Finset.sum_nonneg fun i _=>abs_nonneg _) hc₁).2 (V.grad_bound z)
  have hinner := add_le_add (V.hess_bound z) hs
  have hprod := mul_le_mul (F.value_bound z) hinner (by positivity) hb₀
  have hcross := mul_le_mul (F.grad_bound z) (V.grad_bound z)
    (Finset.sum_nonneg fun j _=>abs_nonneg _) hb₁
  apply (weightedHessian_l1_le _ _ _ _ _ _ z).trans
  rw [mul_comm]
  apply mul_le_mul_of_nonneg_right _ (Real.exp_nonneg _)
  linarith [F.hess_bound z]

end BoundedJet

/-- Cancellation uses the pointwise observable bound and the positive
partition, so no inverse-partition exponential enters the result. -/
theorem bounded_quotient_derivative {M Z : ℝ→ℝ} {θ dm dz e cM cZ F₀ : ℝ}
    (hM : HasDerivAt M dm θ) (hZ : HasDerivAt Z dz θ)
    (hpos : 0<Z θ) (hval : |M θ|≤F₀*Z θ)
    (hF₀ : 0≤F₀) (he : 0≤e) (hcM : 0≤cM) (hcZ : 0≤cZ)
    (hdm : |dm|≤e*cM/2*Z θ) (hdz : |dz|≤e*cZ/2*Z θ) :
    ∃q, HasDerivAt (fun t=>M t/Z t) q θ ∧ |q|≤e*(cM+F₀*cZ)/2 := by
  refine ⟨(dm*Z θ-M θ*dz)/Z θ^2,hM.div hZ hpos.ne',?_⟩
  rw [abs_div,abs_of_pos (sq_pos_of_pos hpos)]
  apply (div_le_iff₀ (sq_pos_of_pos hpos)).2
  calc
    _ ≤ |dm*Z θ|+|M θ*dz| := abs_sub _ _
    _ = |dm| *Z θ+|M θ| *|dz| := by rw [abs_mul,abs_of_pos hpos,abs_mul]
    _ ≤ (e*cM/2*Z θ)*Z θ+(F₀*Z θ)*(e*cZ/2*Z θ) :=
      add_le_add (mul_le_mul_of_nonneg_right hdm hpos.le)
        (mul_le_mul hval hdz (abs_nonneg _) (mul_nonneg hF₀ hpos.le))
    _ = _ := by ring

end NeuralGeneralization.BatchTwoActivation
