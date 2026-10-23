import NeuralGeneralization.BatchTwoActivationLayerCertificate
import NeuralGeneralization.BatchTwoActivationCovarianceSampling

/-! Actual finite Gaussian-source realization of the bounded bulk. The
selected neurons use the original activation; the whole-vector cutoff is
absorbed in their covariance coefficients. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open FiniteDifferential GaussianAngularFields GaussianFieldTilt
variable {I J : Type*} [Fintype I] [Nonempty I] [DecidableEq I] [Fintype J] [DecidableEq J]

theorem boundedFieldMoment_source (A : I → J → ℝ) (F V : (I → ℝ) → ℝ)
    (hF : Measurable F) (hV : Measurable V) :
    boundedFieldMoment A F V =
      ∫z,F (fieldLinear A z) ∂(standardLaw J).tilted (fun z => V (fieldLinear A z)) := by
  rw [boundedFieldMoment_ratio A F V hF hV,integral_tilted]
  simp only [smul_eq_mul]
  have he (z : J → ℝ) :
      (Real.exp (V (fieldLinear A z))/(∫z,Real.exp (V (fieldLinear A z)) ∂standardLaw J))*
        F (fieldLinear A z) =
      (F (fieldLinear A z)*Real.exp (V (fieldLinear A z)))/
        (∫z,Real.exp (V (fieldLinear A z)) ∂standardLaw J) := by ring
  simp_rw [he]
  rw [integral_div]

theorem bounded_expectation_difference {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (F G : Ω → ℝ)
    (hF : Measurable F) (hG : Measurable G) {B C D : ℝ}
    (hb : ∀z,|F z|≤B) (hc : ∀z,|G z|≤C) (he : ∀z,|F z-G z|≤D) :
    |(∫z,F z ∂μ)-(∫z,G z ∂μ)|≤D := by
  have hf : Integrable F μ := (integrable_const B).mono' hF.aestronglyMeasurable
    (ae_of_all _ (fun z => by simpa only [Real.norm_eq_abs] using hb z))
  have hg : Integrable G μ := (integrable_const C).mono' hG.aestronglyMeasurable
    (ae_of_all _ (fun z => by simpa only [Real.norm_eq_abs] using hc z))
  rw [←integral_sub hf hg]
  have hh := norm_integral_le_of_norm_le_const (μ := μ) (f := fun z => F z-G z) (C := D)
    (ae_of_all _ (fun z => by simpa only [Real.norm_eq_abs] using he z))
  simpa only [Real.norm_eq_abs,probReal_univ,mul_one] using hh

theorem featureQuadratic_bound (b : I → (I → ℝ) → ℝ) (Γ : I×I → ℝ)
    {B G : ℝ} (hB : 0≤B) (hb : ∀i z,|b i z|≤B) (hΓ : (∑p,|Γ p|)≤G) (z : I → ℝ) :
    |featureQuadratic b Γ z|≤G*B^2 := by
  unfold featureQuadratic
  calc
    _ ≤ ∑p,|Γ p*(b p.1 z*b p.2 z)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑p,|Γ p| * B^2 := by
      apply Finset.sum_le_sum
      intro p hp
      rw [abs_mul,abs_mul,pow_two]
      exact mul_le_mul_of_nonneg_left
        (mul_le_mul (hb p.1 z) (hb p.2 z) (abs_nonneg _) hB) (abs_nonneg _)
    _ = (∑p,|Γ p|) * B^2 := by rw [Finset.sum_mul]
    _ ≤ _ := mul_le_mul_of_nonneg_right hΓ (sq_nonneg B)

theorem actualCutoffFeature_continuous {φ : ℝ → ℝ} {ℓ a T : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0≤ℓ) (ha : 0<a) (p : I) :
    Continuous (actualCutoffFeature φ a T p) := by
  have hr : Continuous (smoothCutoff (I:=I) a T) :=
    continuous_iff_continuousAt.mpr (fun z => (smoothCutoff_derivative ha.ne' T z).continuousAt)
  apply hr.mul
  exact (real_lipschitz_continuous hℓ hφ.2).comp (continuous_apply p)

theorem exists_bounded_cutoff_rows (A : I → J → ℝ) {φ : ℝ → ℝ} {ℓ a T : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0<ℓ) (ha : 0<a) (hT : 0<T)
    {b₀ b₁ b₂ D G ε R : ℝ} (b : I → BoundedJet I b₀ b₁ b₂) (hb₀ : 0≤b₀)
    (Γ : I×I → ℝ) (hΓ : (∑p,|Γ p|)≤G)
    (happrox : ∀p q z, |(b p).value z*(b q).value z-
      actualCutoffFeature φ a T p z*actualCutoffFeature φ a T q z|≤D)
    {s : ℕ} (hs : 0<s) (hε : 0≤ε) (hR : 0≤R)
    (hbudget : 2*(Fintype.card I:ℝ)^2*Real.exp (-(s:ℝ)*(ε/(4*ℓ*T)^2)^2/2)+
      2*(s:ℝ)*(Fintype.card J:ℝ)*Real.exp (2*(G*b₀^2)-R^2/2)<1) :
    ∃w : Fin s → J → ℝ, (∀j k,|w j k|<R) ∧ ∀p q,
      |(∑j,(smoothCutoff a T (fieldLinear A (w j)))^2*
        φ (fieldLinear A (w j) p)*φ (fieldLinear A (w j) q))/(s:ℝ)-
        boundedFeatureCovariance A (fun i => (b i).value) Γ p q|<ε+D := by
  let V : (J→ℝ) → ℝ := fun z => featureQuadratic (fun i => (b i).value) Γ (fieldLinear A z)
  have hpot : Measurable (featureQuadratic (fun i => (b i).value) Γ) := by
    unfold featureQuadratic
    apply Finset.measurable_sum
    intro p hp
    exact measurable_const.mul ((b p.1).continuous.measurable.mul (b p.2).continuous.measurable)
  have hV : Measurable V := hpot.comp (fieldLinear A).continuous.measurable
  have hVb : ∀z,|V z|≤G*b₀^2 := fun z =>
    featureQuadratic_bound (fun i => (b i).value) Γ hb₀ (fun i => (b i).value_bound) hΓ _
  let H : (J→ℝ) → I → ℝ := fun z i => actualCutoffFeature φ a T i (fieldLinear A z)
  have hH : ∀i,Measurable (fun z => H z i) := fun i =>
    (actualCutoffFeature_continuous hφ hℓ.le ha i).measurable.comp (fieldLinear A).continuous.measurable
  have hHb : ∀z i,|H z i|≤4*ℓ*T := fun z i => actualCutoffFeature_bound hℓ.le ha hT hφ i _
  obtain ⟨w,hw,hcov⟩ := exists_bounded_source_covariance_sample V hV hVb H hH
    (by positivity : 0<4*ℓ*T) hHb hs hε hR hbudget
  letI : IsProbabilityMeasure ((standardLaw J).tilted V) :=
    BoundedTilt.tilted_probability (standardLaw J) V hV hVb
  refine ⟨w,hw,?_⟩
  intro p q
  have hdiff : |covarianceMean ((standardLaw J).tilted V) H p q-
      boundedFeatureCovariance A (fun i => (b i).value) Γ p q|≤D := by
    rw [boundedFeatureCovariance,boundedFieldMoment_source A
      (fun z => (b p).value z*(b q).value z) (featureQuadratic (fun i => (b i).value) Γ)
      ((b p).continuous.measurable.mul (b q).continuous.measurable)
      hpot]
    apply bounded_expectation_difference ((standardLaw J).tilted V)
      (fun z => H z p*H z q) (fun z => (b p).value (fieldLinear A z)*(b q).value (fieldLinear A z))
      ((hH p).mul (hH q))
      (((b p).continuous.measurable.comp (fieldLinear A).continuous.measurable).mul
        ((b q).continuous.measurable.comp (fieldLinear A).continuous.measurable))
    · intro z
      rw [abs_mul]
      exact mul_le_mul (hHb z p) (hHb z q) (abs_nonneg _) (by positivity)
    · intro z
      rw [abs_mul]
      exact mul_le_mul ((b p).value_bound _) ((b q).value_bound _) (abs_nonneg _) hb₀
    · intro z
      rw [abs_sub_comm]
      exact happrox p q _
  have htri := abs_sub_le (empiricalCovariance H w p q)
    (covarianceMean ((standardLaw J).tilted V) H p q)
    (boundedFeatureCovariance A (fun i => (b i).value) Γ p q)
  have hsamp := hcov p q
  have hfinal : |empiricalCovariance H w p q-
      boundedFeatureCovariance A (fun i => (b i).value) Γ p q|<ε+D := by
    change |empiricalCovariance H w p q-covarianceMean ((standardLaw J).tilted V) H p q|<ε at hsamp
    linarith
  have he : empiricalCovariance H w p q =
      (∑j,(smoothCutoff a T (fieldLinear A (w j)))^2*
        φ (fieldLinear A (w j) p)*φ (fieldLinear A (w j) q))/(s:ℝ) := by
    unfold empiricalCovariance H actualCutoffFeature
    congr 1
    apply Finset.sum_congr rfl
    intro j hj
    ring
  rwa [he] at hfinal

end NeuralGeneralization.BatchTwoActivation
