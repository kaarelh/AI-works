import GaussianParitySeedLaw
import FiniteProbabilityMixture

/-! Combining the explicit Gaussian parity laws into an actual exact Fourier
seed for any nonzero function on the Boolean cube. The entropy estimate is kept
separate; all probability laws and their means are constructed here. -/

noncomputable section
open scoped BigOperators
open MeasureTheory NeuralGeneralization

namespace ConditionalNonpolynomial.Analytic

variable {d : ℕ}

def paritySeedCoefficient (S : Finset (Fin d)) (σ : ℝ) : ℝ :=
  walshCoefficients (fun x => ∫ w, tanhCubeFeature w x ∂parityGaussianMixtureLaw S σ) S

theorem paritySeedCoefficient_lower (S : Finset (Fin d)) (σ : ℝ)
    (hσ : ((d : ℝ)+1)*σ^2 ≤ 2) :
    1 / (2*((S.card : ℝ)+1)) ≤ paritySeedCoefficient S σ := by
  apply walshCoefficients_lower_of_signed_margin
  intro x
  rw [parityGaussianMixtureLaw_mean]
  apply parityGaussianMixtureMean_margin
  intro y
  rwa [cubeNoiseCoefficients_variance]

theorem paritySeedCoefficient_pos (S : Finset (Fin d)) (σ : ℝ)
    (hσ : ((d : ℝ)+1)*σ^2 ≤ 2) : 0 < paritySeedCoefficient S σ :=
  lt_of_lt_of_le (by positivity) (paritySeedCoefficient_lower S σ hσ)

theorem actualParitySeedLaw_mean (S : Finset (Fin d)) (σ : ℝ) (x : ClippingCube d) :
    (∫ w, tanhCubeFeature w x ∂actualParitySeedLaw S σ) =
      paritySeedCoefficient S σ * walshCharacter S x :=
  symmetrizedTanhLaw_mean S (parityGaussianMixtureLaw S σ) x

def coefficientSign (a : ℝ) : ℝ := if a < 0 then -1 else 1

theorem coefficientSign_values (a : ℝ) : coefficientSign a = 1 ∨ coefficientSign a = -1 := by
  by_cases ha : a < 0 <;> simp [coefficientSign, ha]

theorem abs_mul_coefficientSign (a : ℝ) : |a| * coefficientSign a = a := by
  by_cases ha : a < 0
  · simp [coefficientSign, ha, abs_of_neg ha]
  · simp [coefficientSign, ha, abs_of_nonneg (le_of_not_gt ha)]

theorem tanhCubeFeature_sign_weights (a : ℝ) (w : Option (Fin d) → ℝ)
    (x : ClippingCube d) :
    tanhCubeFeature (fun i => coefficientSign a * w i) x =
      coefficientSign a * tanhCubeFeature w x := by
  change Real.tanh (rowAffineValue (fun i => coefficientSign a*w i) x) =
    coefficientSign a * Real.tanh (rowAffineValue w x)
  rw [rowAffineValue_smul]
  rcases coefficientSign_values a with h | h <;> simp [h, Real.tanh_neg]

def signedTanhLaw (a : ℝ) (μ : Measure (Option (Fin d) → ℝ)) :
    Measure (Option (Fin d) → ℝ) := μ.map (fun w i => coefficientSign a * w i)

theorem measurable_sign_weights (a : ℝ) :
    Measurable (fun w : Option (Fin d) → ℝ => fun i => coefficientSign a * w i) := by
  fun_prop

instance signedTanhLaw_probability (a : ℝ) (μ : Measure (Option (Fin d) → ℝ))
    [IsProbabilityMeasure μ] : IsProbabilityMeasure (signedTanhLaw a μ) :=
  Measure.isProbabilityMeasure_map (measurable_sign_weights a).aemeasurable

theorem signedTanhLaw_mean (a : ℝ) (μ : Measure (Option (Fin d) → ℝ))
    (x : ClippingCube d) :
    (∫ w, tanhCubeFeature w x ∂signedTanhLaw a μ) =
      coefficientSign a * ∫ w, tanhCubeFeature w x ∂μ := by
  rw [signedTanhLaw, integral_map (measurable_sign_weights a).aemeasurable
    (measurable_tanhCubeFeature x).aestronglyMeasurable]
  simp_rw [tanhCubeFeature_sign_weights]
  exact integral_const_mul _ _

theorem signedTanhLaw_secondMoment (a : ℝ) (μ : Measure (Option (Fin d) → ℝ))
    (x : ClippingCube d) :
    (∫ w, tanhCubeFeature w x ^ 2 ∂signedTanhLaw a μ) =
      ∫ w, tanhCubeFeature w x ^ 2 ∂μ := by
  rw [signedTanhLaw, integral_map (measurable_sign_weights a).aemeasurable
    ((measurable_tanhCubeFeature x).pow_const 2).aestronglyMeasurable]
  simp_rw [tanhCubeFeature_sign_weights, mul_pow]
  rcases coefficientSign_values a with h | h <;> simp [h]

theorem integrable_tanhCubeFeature_sq (μ : Measure (Option (Fin d) → ℝ))
    [IsProbabilityMeasure μ] (x : ClippingCube d) :
    Integrable (fun w => tanhCubeFeature w x ^ 2) μ := by
  apply Integrable.of_bound ((measurable_tanhCubeFeature x).pow_const 2).aestronglyMeasurable 1
  apply ae_of_all
  intro w
  rw [Real.norm_eq_abs, abs_of_nonneg (sq_nonneg _)]
  have h := pow_le_pow_left₀ (abs_nonneg _) (tanhCubeFeature_abs_le_one w x) 2
  simpa only [sq_abs, one_pow] using h

def fourierSeedNormalizer (f : ClippingCube d → ℝ) (σ : ℝ) : ℝ :=
  ∑ S : Finset (Fin d), |walshCoefficients f S| / paritySeedCoefficient S σ

theorem exists_walshCoefficient_ne_zero (f : ClippingCube d → ℝ)
    (hf : ∃ x, f x ≠ 0) : ∃ S : Finset (Fin d), walshCoefficients f S ≠ 0 := by
  by_contra h
  push Not at h
  obtain ⟨x, hx⟩ := hf
  have hinv := walshExpansion_coefficients f x
  simp [walshExpansion, h] at hinv
  exact hx hinv.symm

theorem fourierSeedNormalizer_pos (f : ClippingCube d → ℝ) (σ : ℝ)
    (hf : ∃ x, f x ≠ 0) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2) :
    0 < fourierSeedNormalizer f σ := by
  obtain ⟨S, hS⟩ := exists_walshCoefficient_ne_zero f hf
  have hpos : 0 < |walshCoefficients f S| / paritySeedCoefficient S σ :=
    div_pos (abs_pos.mpr hS) (paritySeedCoefficient_pos S σ hσ)
  exact hpos.trans_le (Finset.single_le_sum
    (fun T _ => div_nonneg (abs_nonneg _) (paritySeedCoefficient_pos T σ hσ).le)
    (Finset.mem_univ S))

theorem fourierSeedNormalizer_le (f : ClippingCube d → ℝ) (σ : ℝ)
    (hσ : ((d : ℝ)+1)*σ^2 ≤ 2) :
    fourierSeedNormalizer f σ ≤ 2*((d : ℝ)+1)*walshVariation f := by
  unfold fourierSeedNormalizer walshVariation
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro S _
  have hcardNat : S.card ≤ d := by simpa using S.card_le_univ
  have hcard : (S.card : ℝ) ≤ d := by exact_mod_cast hcardNat
  have hden : 0 < 2*((S.card : ℝ)+1) := by positivity
  have hlower := (div_le_iff₀ hden).mp (paritySeedCoefficient_lower S σ hσ)
  have hpos := paritySeedCoefficient_pos S σ hσ
  apply (div_le_iff₀ hpos).mpr
  have hmul : 1 ≤ 2*((d : ℝ)+1)*paritySeedCoefficient S σ := by nlinarith
  have hfinal := mul_le_mul_of_nonneg_left hmul (abs_nonneg (walshCoefficients f S))
  nlinarith only [hfinal]

def fourierSeedWeights (f : ClippingCube d → ℝ) (σ : ℝ) (S : Finset (Fin d)) : ℝ :=
  (|walshCoefficients f S| / paritySeedCoefficient S σ) / fourierSeedNormalizer f σ

theorem fourierSeedWeights_nonneg (f : ClippingCube d → ℝ) (σ : ℝ)
    (hf : ∃ x, f x ≠ 0) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2) (S : Finset (Fin d)) :
    0 ≤ fourierSeedWeights f σ S := by
  unfold fourierSeedWeights
  exact div_nonneg (div_nonneg (abs_nonneg _) (paritySeedCoefficient_pos S σ hσ).le)
    (fourierSeedNormalizer_pos f σ hf hσ).le

theorem fourierSeedWeights_sum (f : ClippingCube d → ℝ) (σ : ℝ)
    (hf : ∃ x, f x ≠ 0) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2) :
    (∑ S : Finset (Fin d), fourierSeedWeights f σ S) = 1 := by
  unfold fourierSeedWeights
  rw [← Finset.sum_div]
  change fourierSeedNormalizer f σ / fourierSeedNormalizer f σ = 1
  exact div_self (fourierSeedNormalizer_pos f σ hf hσ).ne'

def actualFourierSeedLaw (f : ClippingCube d → ℝ) (σ : ℝ) : Measure (Option (Fin d) → ℝ) :=
  finiteProbabilityMixture (fourierSeedWeights f σ)
    (fun S => signedTanhLaw (walshCoefficients f S) (actualParitySeedLaw S σ))

theorem actualFourierSeedLaw_probability (f : ClippingCube d → ℝ) (σ : ℝ)
    (hf : ∃ x, f x ≠ 0) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2) :
    IsProbabilityMeasure (actualFourierSeedLaw f σ) :=
  finiteProbabilityMixture_isProbability _ _ (fourierSeedWeights_nonneg f σ hf hσ)
    (fourierSeedWeights_sum f σ hf hσ)

theorem actualFourierSeedLaw_mean (f : ClippingCube d → ℝ) (σ : ℝ)
    (hf : ∃ x, f x ≠ 0) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2) (x : ClippingCube d) :
    (∫ w, tanhCubeFeature w x ∂actualFourierSeedLaw f σ) = f x / fourierSeedNormalizer f σ := by
  rw [actualFourierSeedLaw, finiteProbabilityMixture_integral _ _
    (fourierSeedWeights_nonneg f σ hf hσ) _ (fun _ => integrable_tanhCubeFeature _ x)]
  simp_rw [signedTanhLaw_mean, actualParitySeedLaw_mean]
  have hterm (S : Finset (Fin d)) : fourierSeedWeights f σ S *
      (coefficientSign (walshCoefficients f S) *
        (paritySeedCoefficient S σ * walshCharacter S x)) =
      (walshCoefficients f S * walshCharacter S x) / fourierSeedNormalizer f σ := by
    have hc := (paritySeedCoefficient_pos S σ hσ).ne'
    have hz := (fourierSeedNormalizer_pos f σ hf hσ).ne'
    unfold fourierSeedWeights
    field_simp
    rw [abs_mul_coefficientSign]
    ring
  simp_rw [hterm]
  rw [← Finset.sum_div]
  exact congrArg (fun z : ℝ => z / fourierSeedNormalizer f σ) (walshExpansion_coefficients f x)

theorem actualFourierSeedLaw_constant_diagonal (f : ClippingCube d → ℝ) (σ : ℝ)
    (hf : ∃ x, f x ≠ 0) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2) (x y : ClippingCube d) :
    (∫ w, tanhCubeFeature w x ^ 2 ∂actualFourierSeedLaw f σ) =
      ∫ w, tanhCubeFeature w y ^ 2 ∂actualFourierSeedLaw f σ := by
  rw [actualFourierSeedLaw, finiteProbabilityMixture_integral _ _
    (fourierSeedWeights_nonneg f σ hf hσ) _ (fun _ => integrable_tanhCubeFeature_sq _ x),
    finiteProbabilityMixture_integral _ _ (fourierSeedWeights_nonneg f σ hf hσ) _
      (fun _ => integrable_tanhCubeFeature_sq _ y)]
  apply Finset.sum_congr rfl
  intro S _
  rw [signedTanhLaw_secondMoment, signedTanhLaw_secondMoment]
  congr 1
  exact symmetrizedTanhLaw_constant_diagonal S (parityGaussianMixtureLaw S σ) x y

end ConditionalNonpolynomial.Analytic

#print axioms ConditionalNonpolynomial.Analytic.actualFourierSeedLaw_mean
#print axioms ConditionalNonpolynomial.Analytic.actualFourierSeedLaw_constant_diagonal
