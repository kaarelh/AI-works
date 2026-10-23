import NeuralGeneralization.BatchTwoActivationGaussianPrice
import NeuralGeneralization.BatchTwoActivationJetSum
import NeuralGeneralization.GaussianFieldTilt

/-! Actual Gaussian-law endpoints and bounded-feature covariance stability. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open FiniteDifferential GaussianAngularFields GaussianAngularPrice GaussianFieldTilt
variable {I J K : Type*} [Fintype I] [Fintype J] [Fintype K] [DecidableEq I]

def boundedFieldMoment (A : I→J→ℝ) (F V : (I→ℝ)→ℝ) : ℝ :=
  ∫z,F z ∂(fieldLaw A).tilted V

theorem boundedFieldMoment_ratio (A : I→J→ℝ) (F V : (I→ℝ)→ℝ)
    (hF : Measurable F) (hV : Measurable V) :
    boundedFieldMoment A F V=
      (∫z,F (fieldLinear A z)*Real.exp (V (fieldLinear A z)) ∂standardLaw J)/
      (∫z,Real.exp (V (fieldLinear A z)) ∂standardLaw J) := by
  rw [boundedFieldMoment,integral_tilted]
  simp only [smul_eq_mul]
  have he (x : I→ℝ) : (Real.exp (V x)/(∫z,Real.exp (V z) ∂fieldLaw A))*F x=
      (F x*Real.exp (V x))/(∫z,Real.exp (V z) ∂fieldLaw A) := by ring
  simp_rw [he]
  rw [integral_div,integral_fieldLaw A (fun z=>F z*Real.exp (V z)) (by fun_prop),
    integral_fieldLaw A (fun z=>Real.exp (V z)) hV.exp]

theorem angularBoundedTilt_zero (A : I→J→ℝ) (B : I→K→ℝ) (F V : (I→ℝ)→ℝ)
    (hF : Measurable F) (hV : Measurable V) :
    angularBoundedTilt A B F V 0=boundedFieldMoment A F V := by
  rw [angularBoundedTilt,boundedFieldMoment_ratio A F V hF hV]
  congr 1
  · exact integral_angularField_zero A B (fun z=>F z*Real.exp (V z))
  · exact integral_angularField_zero A B (fun z=>Real.exp (V z))

theorem angularBoundedTilt_pi_div_two (A : I→J→ℝ) (B : I→K→ℝ) (F V : (I→ℝ)→ℝ)
    (hF : Measurable F) (hV : Measurable V) :
    angularBoundedTilt A B F V (Real.pi/2)=boundedFieldMoment B F V := by
  rw [angularBoundedTilt,boundedFieldMoment_ratio B F V hF hV]
  congr 1
  · exact integral_angularField_pi_div_two A B (fun z=>F z*Real.exp (V z))
  · exact integral_angularField_pi_div_two A B (fun z=>Real.exp (V z))

theorem boundedFieldMoment_stability (A : I→J→ℝ) (B : I→K→ℝ)
    {F₀ F₁ F₂ V₀ V₁ V₂ e : ℝ}
    (F : BoundedJet I F₀ F₁ F₂) (V : BoundedJet I V₀ V₁ V₂)
    (hF₀ : 0≤F₀) (hF₁ : 0≤F₁) (hF₂ : 0≤F₂)
    (hV₁ : 0≤V₁) (hV₂ : 0≤V₂) (he : 0≤e)
    (hCov : ∀i j,|gram B i j-gram A i j|≤e) :
    |boundedFieldMoment B F.value V.value-boundedFieldMoment A F.value V.value|≤
      e*(F₂+2*F₁*V₁+2*F₀*(V₂+V₁^2)) := by
  have h := angularBoundedTilt_stability A B F V hF₀ hF₁ hF₂ hV₁ hV₂ he hCov
  rwa [angularBoundedTilt_zero A B _ _ F.continuous.measurable V.continuous.measurable,
    angularBoundedTilt_pi_div_two A B _ _ F.continuous.measurable V.continuous.measurable] at h

def featureQuadratic (b : I→(I→ℝ)→ℝ) (Γ : I×I→ℝ) (z : I→ℝ) : ℝ :=
  ∑p,Γ p*(b p.1 z*b p.2 z)

def boundedFeatureCovariance (A : I→J→ℝ) (b : I→(I→ℝ)→ℝ) (Γ : I×I→ℝ) (p q : I) : ℝ :=
  boundedFieldMoment A (fun z=>b p z*b q z) (featureQuadratic b Γ)

/-- Polynomial stability for a whole-vector bounded feature map, not only
coordinatewise tanh observables. All measures and derivatives are concrete. -/
theorem boundedFeatureCovariance_stability (A : I→J→ℝ) (B : I→K→ℝ)
    {b₀ b₁ b₂ G e : ℝ} (b : I→BoundedJet I b₀ b₁ b₂) (Γ : I×I→ℝ)
    (hb₀ : 0≤b₀) (hb₁ : 0≤b₁) (hb₂ : 0≤b₂) (hG : 0≤G) (he : 0≤e)
    (hΓ : (∑p,|Γ p|)≤G) (hCov : ∀i j,|gram B i j-gram A i j|≤e) (p q : I) :
    let F₀ := b₀*b₀
    let F₁ := b₁*b₀+b₀*b₁
    let F₂ := b₂*b₀+2*b₁*b₁+b₀*b₂
    |boundedFeatureCovariance B (fun i=>(b i).value) Γ p q-
      boundedFeatureCovariance A (fun i=>(b i).value) Γ p q|≤
      e*(F₂+2*F₁*(G*F₁)+2*F₀*(G*F₂+(G*F₁)^2)) := by
  dsimp only
  let F : I×I→BoundedJet I (b₀*b₀) (b₁*b₀+b₀*b₁) (b₂*b₀+2*b₁*b₁+b₀*b₂) :=
    fun k=>(b k.1).mul (b k.2) hb₀ hb₁ hb₂ hb₀
  let V := BoundedJet.linearCombination F Γ hΓ (by positivity) (by positivity) (by positivity)
  exact boundedFieldMoment_stability A B (F (p,q)) V
    (by positivity) (by positivity) (by positivity) (by positivity) (by positivity) he hCov

end NeuralGeneralization.BatchTwoActivation
