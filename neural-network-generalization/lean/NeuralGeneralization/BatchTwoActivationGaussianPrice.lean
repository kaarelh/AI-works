import NeuralGeneralization.BatchTwoActivationBoundedJet
import NeuralGeneralization.BoundedTilt
import NeuralGeneralization.TanhGaussianPrice

/-! Polynomial covariance stability of actual bounded-feature Gaussian tilts.
The observable may depend on all Gaussian coordinates, as the global cutoff
in the unbounded-activation proof does. Singular covariances are allowed. -/
noncomputable section
set_option maxHeartbeats 800000
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoActivation
open FiniteDifferential GaussianAngularFields GaussianAngularPrice GaussianPriceBounds
open TanhDifferential
variable {I J K : Type*} [Fintype I] [Fintype J] [Fintype K]

def angularBoundedTilt (A : I→J→ℝ) (B : I→K→ℝ)
    (F V : (I→ℝ)→ℝ) (θ : ℝ) : ℝ :=
  (∫z,F (angularField A B θ z)*Real.exp (V (angularField A B θ z)) ∂standardLaw (J⊕K))/
    (∫z,Real.exp (V (angularField A B θ z)) ∂standardLaw (J⊕K))

theorem angularBoundedTilt_derivative (A : I→J→ℝ) (B : I→K→ℝ)
    {F₀ F₁ F₂ V₀ V₁ V₂ e : ℝ}
    (F : BoundedJet I F₀ F₁ F₂) (V : BoundedJet I V₀ V₁ V₂)
    (hF₀ : 0≤F₀) (hF₁ : 0≤F₁) (hF₂ : 0≤F₂)
    (hV₁ : 0≤V₁) (hV₂ : 0≤V₂) (he : 0≤e)
    (hCov : ∀i j, |gram B i j-gram A i j|≤e) (θ : ℝ) :
    ∃d, HasDerivAt (angularBoundedTilt A B F.value V.value) d θ ∧
      |d|≤e*(F₂+2*F₁*V₁+2*F₀*(V₂+V₁^2))/2 := by
  let W := fun z=>Real.exp (V.value z)
  let Z := fun t=>∫z,W (angularField A B t z) ∂standardLaw (J⊕K)
  let M := fun t=>∫z,F.value (angularField A B t z)*W (angularField A B t z) ∂standardLaw (J⊕K)
  let cZ := V₂+V₁^2
  let cM := F₂+2*F₁*V₁+F₀*(V₂+V₁^2)
  have hcZ : 0≤cZ := by dsimp [cZ]; positivity
  have hcM : 0≤cM := by dsimp [cM]; positivity
  have hWbound (z) : W z≤Real.exp V₀ := Real.exp_le_exp.mpr ((le_abs_self _).trans (V.value_bound z))
  have hWpos (z) : 0<W z := Real.exp_pos _
  have hWabs (z) : |W z|≤Real.exp V₀ := by rw [abs_of_pos (hWpos z)]; exact hWbound z
  have hVWmeas (t) : Measurable (fun z=>V.value (angularField A B t z)) :=
    V.continuous.measurable.comp (continuous_angularField A B t).measurable
  have hWint (t) : Integrable (fun z=>W (angularField A B t z)) (standardLaw (J⊕K)) :=
    BoundedTilt.integrable_exp_of_bounded (standardLaw (J⊕K)) _ (hVWmeas t) (fun z=>V.value_bound _)
  have hZpos (t) : 0<Z t :=
    BoundedTilt.partition_pos (standardLaw (J⊕K)) _ (hVWmeas t) (fun z=>V.value_bound _)
  have hFWbound (z) : |F.value z*W z|≤F₀*Real.exp V₀ := by
    rw [abs_mul,abs_of_pos (hWpos z)]
    exact mul_le_mul (F.value_bound z) (hWbound z) (hWpos z).le hF₀
  have hFWint (t) : Integrable (fun z=>F.value (angularField A B t z)*W (angularField A B t z))
      (standardLaw (J⊕K)) :=
    GaussianProductStein.integrable_of_bounded (fun _ : J⊕K => (1:ℝ≥0)) _
      ((F.continuous.measurable.comp (continuous_angularField A B t).measurable).mul (hVWmeas t).exp)
      _ (fun z=>hFWbound _)
  have hMval (t) : |M t|≤F₀*Z t := by
    calc
      _ ≤ ∫z,|F.value (angularField A B t z)*W (angularField A B t z)| ∂standardLaw (J⊕K) :=
        abs_integral_le_integral_abs
      _ ≤ ∫z,F₀*W (angularField A B t z) ∂standardLaw (J⊕K) := by
        apply integral_mono_ae (hFWint t).abs ((hWint t).const_mul F₀)
        exact ae_of_all _ (fun z=>by
          dsimp only
          rw [abs_mul,abs_of_pos (hWpos _)]
          exact mul_le_mul_of_nonneg_right (F.value_bound _) (hWpos _).le)
      _ = _ := integral_const_mul _ _
  have hHZ (z) : (∑i,∑j,|expHessian V.value V.grad V.hess z i j|)≤cZ*W z :=
    V.exp_hessian_bound hV₁ z
  have hHM (z) : (∑i,∑j,|weightedHessian F.value F.grad F.hess V.value V.grad V.hess z i j|)≤cM*W z :=
    F.weighted_hessian_bound V hF₀ hF₁ hV₁ z
  obtain ⟨dz,hdz,hdzb⟩ := exists_derivative_bound A B W
    (expGradient V.value V.grad) (expHessian V.value V.grad V.hess) W
    (hasFDerivAt_expValue _ _ V.derivative)
    (hasFDerivAt_expGradient _ _ _ V.derivative V.grad_derivative)
    (fun i j=>(continuous_expHessian _ _ _ V.continuous V.grad_continuous V.hess_continuous i j).measurable)
    (Real.exp V₀) (Real.exp V₀*V₁) (cZ*Real.exp V₀) (by positivity)
    hWabs (V.exp_gradient_bound hV₁)
    (fun z i j=>(TanhGaussianPrice.entry_abs_le_double_sum _ i j).trans
      ((hHZ z).trans (mul_le_mul_of_nonneg_left (hWbound z) hcZ)))
    he hcZ hCov (fun z=>(hWpos z).le) hHZ θ (hWint θ)
  obtain ⟨dm,hdm,hdmb⟩ := exists_derivative_bound A B (fun z=>F.value z*W z)
    (weightedGradient F.value F.grad V.value V.grad)
    (weightedHessian F.value F.grad F.hess V.value V.grad V.hess) W
    (hasFDerivAt_weightedValue _ _ _ _ F.derivative V.derivative)
    (hasFDerivAt_weightedGradient _ _ _ _ _ _ F.derivative F.grad_derivative V.derivative V.grad_derivative)
    (fun i j=>(continuous_weightedHessian _ _ _ _ _ _ F.continuous F.grad_continuous F.hess_continuous
      V.continuous V.grad_continuous V.hess_continuous i j).measurable)
    (F₀*Real.exp V₀) (Real.exp V₀*(F₁+F₀*V₁)) (cM*Real.exp V₀) (by positivity)
    hFWbound (F.weighted_gradient_bound V hF₀ hF₁ hV₁)
    (fun z i j=>(TanhGaussianPrice.entry_abs_le_double_sum _ i j).trans
      ((hHM z).trans (mul_le_mul_of_nonneg_left (hWbound z) hcM)))
    he hcM hCov (fun z=>(hWpos z).le) hHM θ (hWint θ)
  obtain ⟨q,hq,hqb⟩ := bounded_quotient_derivative (M:=M) (Z:=Z) hdm hdz
    (hZpos θ) (hMval θ) hF₀ he hcM hcZ hdmb hdzb
  refine ⟨q,hq,hqb.trans_eq ?_⟩
  dsimp [cM,cZ]
  ring

/-- The polynomial covariance modulus. Its factor is deliberately loose;
the important cancellation removes exp(V₀) from the conclusion entirely. -/
theorem angularBoundedTilt_stability (A : I→J→ℝ) (B : I→K→ℝ)
    {F₀ F₁ F₂ V₀ V₁ V₂ e : ℝ}
    (F : BoundedJet I F₀ F₁ F₂) (V : BoundedJet I V₀ V₁ V₂)
    (hF₀ : 0≤F₀) (hF₁ : 0≤F₁) (hF₂ : 0≤F₂)
    (hV₁ : 0≤V₁) (hV₂ : 0≤V₂) (he : 0≤e)
    (hCov : ∀i j, |gram B i j-gram A i j|≤e) :
    |angularBoundedTilt A B F.value V.value (Real.pi/2)-angularBoundedTilt A B F.value V.value 0|≤
      e*(F₂+2*F₁*V₁+2*F₀*(V₂+V₁^2)) := by
  let f := angularBoundedTilt A B F.value V.value
  have hd (t) := angularBoundedTilt_derivative A B F V hF₀ hF₁ hF₂ hV₁ hV₂ he hCov t
  have hdiff (t) : DifferentiableAt ℝ f t := (hd t).choose_spec.1.differentiableAt
  have hderiv (t) : ‖deriv f t‖≤e*(F₂+2*F₁*V₁+2*F₀*(V₂+V₁^2))/2 := by
    obtain ⟨d,hdd,hb⟩ := hd t
    rw [hdd.deriv,Real.norm_eq_abs]
    exact hb
  have hπ : 0≤Real.pi/2 := by positivity
  have hmv := norm_image_sub_le_of_norm_deriv_le_segment'
    (a:=(0:ℝ)) (b:=Real.pi/2) (fun t _=>(hdiff t).hasDerivAt.hasDerivWithinAt)
    (fun t _=>hderiv t) (Real.pi/2) ⟨hπ,le_rfl⟩
  rw [Real.norm_eq_abs,sub_zero] at hmv
  have hπb : Real.pi/2≤2 := by linarith [Real.pi_lt_four]
  have hcoef : 0≤e*(F₂+2*F₁*V₁+2*F₀*(V₂+V₁^2))/2 := by positivity
  have hmul := mul_le_mul_of_nonneg_left hπb hcoef
  linarith

end NeuralGeneralization.BatchTwoActivation
