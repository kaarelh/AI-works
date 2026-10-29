import GaussianParityDetectorMean
import TanhWalshMeasure

/-! An explicit finite mixture of Gaussian mean shifts, followed by an actual
cube-symmetrization map. Its mean is exactly a parity with an inverse-polynomial
coefficient, and its second-moment diagonal is constant. This module proves the
actual probability-law and mean construction; its relative-entropy bound is a
separate obligation. -/

noncomputable section
open scoped BigOperators NNReal ENNReal
open MeasureTheory ProbabilityTheory NeuralGeneralization
open NeuralGeneralization.BatchTwoContinuousDepthCritical

namespace ConditionalNonpolynomial.Analytic

variable {d : ℕ}

instance paritySeedIndexMeasurableSpace (n : ℕ) : MeasurableSpace (Option (Fin n)) := ⊤

instance paritySeedIndexDiscreteMeasurableSpace (n : ℕ) :
    DiscreteMeasurableSpace (Option (Fin n)) := ⟨fun _ => trivial⟩

def cubeNoiseCoefficients (σ : ℝ) (x : ClippingCube d) : Option (Fin d) → ℝ
  | none => σ
  | some i => σ * cubeCoordinateSign (x i)

theorem cubeNoiseCoefficients_variance (σ : ℝ) (x : ClippingCube d) :
    (∑ i, cubeNoiseCoefficients σ x i ^ 2) = ((d : ℝ)+1)*σ^2 := by
  rw [Fintype.sum_option]
  simp only [cubeNoiseCoefficients, mul_pow, cubeCoordinateSign_sq, mul_one,
    Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  ring

def parityDetectorWeights (S : Finset (Fin d)) (j : ℕ) : Option (Fin d) → ℝ
  | none => (8*((S.card : ℝ)+1)) * ((S.card : ℝ) - 2*j - 1)
  | some i => if i ∈ S then -(8*((S.card : ℝ)+1)) else 0

def parityConstantWeights (S : Finset (Fin d)) : Option (Fin d) → ℝ
  | none => (8*((S.card : ℝ)+1)) * parityConstant S.card
  | some _ => 0

def parityMixtureShift (S : Finset (Fin d)) : Option (Fin S.card) → Option (Fin d) → ℝ
  | none => parityConstantWeights S
  | some j => fun i => (-1 : ℝ)^(j.val+1) * parityDetectorWeights S j.val i

def rowAffineValue (b : Option (Fin d) → ℝ) (x : ClippingCube d) : ℝ :=
  b none + ∑ i, b (some i)*cubeCoordinateSign (x i)

theorem rowAffineValue_detector (S : Finset (Fin d)) (j : ℕ) (x : ClippingCube d) :
    rowAffineValue (parityDetectorWeights S j) x =
      parityDetectorArgument S j (8*((S.card : ℝ)+1)) x := by
  classical
  simp only [rowAffineValue, parityDetectorWeights, ite_mul, zero_mul]
  rw [Fintype.sum_ite_mem, ← Finset.mul_sum]
  unfold parityDetectorArgument
  ring

theorem rowAffineValue_smul (b : Option (Fin d) → ℝ) (c : ℝ) (x : ClippingCube d) :
    rowAffineValue (fun i => c*b i) x = c * rowAffineValue b x := by
  simp only [rowAffineValue, mul_assoc, ← Finset.mul_sum]
  ring

theorem rowAffineValue_constant (S : Finset (Fin d)) (x : ClippingCube d) :
    rowAffineValue (parityConstantWeights S) x =
      (8*((S.card : ℝ)+1)) * parityConstant S.card := by
  simp [rowAffineValue, parityConstantWeights]

theorem tanhCubeFeature_affineNoise (b : Option (Fin d) → ℝ) (σ : ℝ)
    (z : Option (Fin d) → ℝ) (x : ClippingCube d) :
    tanhCubeFeature (fun i => b i + σ*z i) x =
      Real.tanh (rowAffineValue b x + ∑ i, cubeNoiseCoefficients σ x i * z i) := by
  unfold tanhCubeFeature rowAffineValue
  rw [Fintype.sum_option]
  simp only [cubeNoiseCoefficients, add_mul, Finset.sum_add_distrib]
  congr 1
  have hsum : (∑ i, σ*z (some i)*cubeCoordinateSign (x i)) =
      ∑ i, σ*cubeCoordinateSign (x i)*z (some i) := by
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [hsum]
  ring

def parityMixtureIndexLaw (S : Finset (Fin d)) : Measure (Option (Fin S.card)) :=
  (PMF.uniformOfFintype (Option (Fin S.card))).toMeasure

instance parityMixtureIndexLaw_probability (S : Finset (Fin d)) :
    IsProbabilityMeasure (parityMixtureIndexLaw S) := by
  unfold parityMixtureIndexLaw
  infer_instance

def parityGaussianSource (S : Finset (Fin d)) :
    Measure (Option (Fin S.card) × (Option (Fin d) → ℝ)) :=
  (parityMixtureIndexLaw S).prod (Measure.pi fun _ : Option (Fin d) => gaussianReal 0 1)

instance parityGaussianSource_probability (S : Finset (Fin d)) :
    IsProbabilityMeasure (parityGaussianSource S) := by
  unfold parityGaussianSource
  infer_instance

def parityGaussianShiftMap (S : Finset (Fin d)) (σ : ℝ)
    (p : Option (Fin S.card) × (Option (Fin d) → ℝ)) : Option (Fin d) → ℝ :=
  fun i => parityMixtureShift S p.1 i + σ*p.2 i

theorem measurable_parityGaussianShiftMap (S : Finset (Fin d)) (σ : ℝ) :
    Measurable (parityGaussianShiftMap S σ) := by
  apply measurable_pi_lambda
  intro i
  exact ((measurable_of_countable (fun j => parityMixtureShift S j i)).comp measurable_fst).add
    (measurable_const.mul ((measurable_pi_apply i).comp measurable_snd))

def parityGaussianMixtureLaw (S : Finset (Fin d)) (σ : ℝ) : Measure (Option (Fin d) → ℝ) :=
  (parityGaussianSource S).map (parityGaussianShiftMap S σ)

instance parityGaussianMixtureLaw_probability (S : Finset (Fin d)) (σ : ℝ) :
    IsProbabilityMeasure (parityGaussianMixtureLaw S σ) :=
  Measure.isProbabilityMeasure_map (measurable_parityGaussianShiftMap S σ).aemeasurable

theorem parityMixtureIndexLaw_integral (S : Finset (Fin d))
    (F : Option (Fin S.card) → ℝ) :
    (∫ j, F j ∂parityMixtureIndexLaw S) =
      (F none + ∑ j : Fin S.card, F (some j)) / ((S.card : ℝ)+1) := by
  unfold parityMixtureIndexLaw
  rw [PMF.integral_eq_sum]
  have hcard : (Fintype.card (Option (Fin S.card)) : ℝ≥0∞).toReal = (S.card : ℝ)+1 := by
    rw [ENNReal.toReal_natCast]
    simp
  simp only [PMF.uniformOfFintype_apply, ENNReal.toReal_inv, hcard, smul_eq_mul]
  rw [← Finset.mul_sum, Fintype.sum_option]
  ring

theorem gaussianRowMean_mul_neg_one_pow {I : Type*} [Fintype I]
    (c : I → ℝ) (m : ℝ) (n : ℕ) :
    gaussianRowMean c ((-1 : ℝ)^n*m) = (-1 : ℝ)^n*gaussianRowMean c m := by
  have hs : ((-1 : ℝ)^n)^2 = 1 := by
    rw [← pow_mul, Nat.mul_comm, pow_mul]
    norm_num
  rcases sq_eq_one_iff.mp hs with h | h <;>
    simp [h, gaussianRowMean_odd]

theorem parityGaussianMixtureLaw_mean (S : Finset (Fin d)) (σ : ℝ) (x : ClippingCube d) :
    (∫ w, tanhCubeFeature w x ∂parityGaussianMixtureLaw S σ) =
      parityGaussianMixtureMean S (cubeNoiseCoefficients σ) x := by
  have hmeas := (measurable_tanhCubeFeature x).comp (measurable_parityGaussianShiftMap S σ)
  have hint : Integrable
      (fun p => tanhCubeFeature (parityGaussianShiftMap S σ p) x)
      (parityGaussianSource S) :=
    Integrable.of_bound hmeas.aestronglyMeasurable 1
      (ae_of_all _ (fun p => tanhCubeFeature_abs_le_one _ _))
  rw [parityGaussianMixtureLaw,
    integral_map (measurable_parityGaussianShiftMap S σ).aemeasurable
      (measurable_tanhCubeFeature x).aestronglyMeasurable]
  change (∫ p, tanhCubeFeature (parityGaussianShiftMap S σ p) x
    ∂(parityMixtureIndexLaw S).prod (Measure.pi fun _ : Option (Fin d) => gaussianReal 0 1)) = _
  rw [integral_prod _ hint]
  have hrow (j : Option (Fin S.card)) :
      (∫ z, tanhCubeFeature (parityGaussianShiftMap S σ (j,z)) x
        ∂(Measure.pi fun _ : Option (Fin d) => gaussianReal 0 1)) =
      gaussianRowMean (cubeNoiseCoefficients σ x) (rowAffineValue (parityMixtureShift S j) x) := by
    unfold parityGaussianShiftMap
    simp_rw [tanhCubeFeature_affineNoise]
    rfl
  simp_rw [hrow]
  rw [parityMixtureIndexLaw_integral]
  simp only [parityMixtureShift, rowAffineValue_constant, rowAffineValue_smul,
    rowAffineValue_detector, gaussianRowMean_mul_neg_one_pow]
  rw [Fin.sum_univ_eq_sum_range (fun j : ℕ => (-1 : ℝ)^(j+1) *
    gaussianRowMean (cubeNoiseCoefficients σ x)
      (parityDetectorArgument S j (8*((S.card : ℝ)+1)) x))]
  rfl

def actualParitySeedLaw (S : Finset (Fin d)) (σ : ℝ) : Measure (Option (Fin d) → ℝ) :=
  symmetrizedTanhLaw S (parityGaussianMixtureLaw S σ)

instance actualParitySeedLaw_probability (S : Finset (Fin d)) (σ : ℝ) :
    IsProbabilityMeasure (actualParitySeedLaw S σ) := by
  unfold actualParitySeedLaw
  infer_instance

/-- Actual same-architecture Gaussian-shift/tanh seed, with exact parity mean.
The reference first-layer variance is σ²; for the original prior σ=t/sqrt(d),
the displayed variance premise holds whenever d≥1 and 0<t≤1. -/
theorem actualParitySeedLaw_mean_and_diagonal (S : Finset (Fin d)) (σ : ℝ)
    (hσ : ((d : ℝ)+1)*σ^2 ≤ 2) :
    ∃ c : ℝ, 1 / (2*((S.card : ℝ)+1)) ≤ c ∧
      (∀ x, (∫ w, tanhCubeFeature w x ∂actualParitySeedLaw S σ) = c*walshCharacter S x) ∧
      (∀ x y, (∫ w, tanhCubeFeature w x ^ 2 ∂actualParitySeedLaw S σ) =
        ∫ w, tanhCubeFeature w y ^ 2 ∂actualParitySeedLaw S σ) := by
  apply symmetrizedTanhLaw_parity_seed S (parityGaussianMixtureLaw S σ)
  intro x
  rw [parityGaussianMixtureLaw_mean]
  apply parityGaussianMixtureMean_margin
  intro y
  rwa [cubeNoiseCoefficients_variance]

theorem originalScale_noise_variance (hd : 1 ≤ d) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    ((d : ℝ)+1)*(t / Real.sqrt d)^2 ≤ 2 := by
  have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd
  have hd0 : (0 : ℝ) < d := by linarith
  have htSq : t^2 ≤ 1 := by nlinarith
  rw [div_pow, Real.sq_sqrt hd0.le]
  rw [← mul_div_assoc]
  apply (div_le_iff₀ hd0).mpr
  nlinarith

/-- A coarse polynomial norm budget is sufficient: only the logarithm of this
budget enters the eventual seed resource. -/
theorem parityDetectorWeights_normSq_le (S : Finset (Fin d)) (j : ℕ) (hj : j < S.card) :
    (∑ i, parityDetectorWeights S j i ^ 2) ≤ 128*((S.card : ℝ)+1)^4 := by
  classical
  have hjR : (j : ℝ)+1 ≤ S.card := by exact_mod_cast hj
  have hj0 : (0 : ℝ) ≤ j := Nat.cast_nonneg j
  have hk0 : (0 : ℝ) ≤ S.card := Nat.cast_nonneg S.card
  have hb : ((S.card : ℝ)-2*j-1)^2 ≤ ((S.card : ℝ)+1)^2 := by
    nlinarith
  have hshape : (S.card : ℝ)+((S.card : ℝ)-2*j-1)^2 ≤ 2*((S.card : ℝ)+1)^2 := by
    nlinarith [sq_nonneg (S.card : ℝ)]
  have hmul := mul_le_mul_of_nonneg_left hshape (sq_nonneg (8*((S.card : ℝ)+1)))
  rw [Fintype.sum_option]
  simp only [parityDetectorWeights, ite_pow, neg_sq, zero_pow (by decide : (2 : ℕ) ≠ 0)]
  rw [Fintype.sum_ite_mem]
  simp only [Finset.sum_const, nsmul_eq_mul, mul_pow]
  nlinarith only [hmul]

theorem parityConstantWeights_normSq_le (S : Finset (Fin d)) :
    (∑ i, parityConstantWeights S i ^ 2) ≤ 128*((S.card : ℝ)+1)^4 := by
  have hk0 : (0 : ℝ) ≤ S.card := Nat.cast_nonneg S.card
  rw [Fintype.sum_option]
  simp only [parityConstantWeights, zero_pow (by decide : (2 : ℕ) ≠ 0),
    Finset.sum_const_zero, add_zero]
  rcases parityConstant_zero_or_one S.card with h | h
  · rw [h, mul_zero, zero_pow (by decide : (2 : ℕ) ≠ 0)]
    positivity
  · rw [h, mul_one]
    nlinarith [sq_nonneg (S.card : ℝ), sq_nonneg ((S.card : ℝ)^2),
      mul_nonneg hk0 (sq_nonneg (S.card : ℝ))]

/-- Every actual Gaussian shift used by the finite seed mixture has polynomial
squared norm; this is the quantitative input to its Gaussian KL calculation. -/
theorem parityMixtureShift_normSq_le (S : Finset (Fin d)) (j : Option (Fin S.card)) :
    (∑ i, parityMixtureShift S j i ^ 2) ≤ 128*((d : ℝ)+1)^4 := by
  have hkNat : S.card ≤ d := by simpa using S.card_le_univ
  have hk : (S.card : ℝ) ≤ d := by exact_mod_cast hkNat
  have hk0 : (0 : ℝ) ≤ S.card := Nat.cast_nonneg S.card
  have hpow : ((S.card : ℝ)+1)^4 ≤ ((d : ℝ)+1)^4 :=
    pow_le_pow_left₀ (by positivity) (by linarith) 4
  have hlocal : (∑ i, parityMixtureShift S j i ^ 2) ≤ 128*((S.card : ℝ)+1)^4 := by
    cases j with
    | none => exact parityConstantWeights_normSq_le S
    | some j =>
      have hsign : ((-1 : ℝ)^(j.val+1))^2 = 1 := by
        rw [← pow_mul, Nat.mul_comm, pow_mul]
        norm_num
      simp only [parityMixtureShift, mul_pow, hsign, one_mul]
      exact parityDetectorWeights_normSq_le S j.val j.isLt
  exact hlocal.trans (by nlinarith)

end ConditionalNonpolynomial.Analytic

#print axioms ConditionalNonpolynomial.Analytic.parityGaussianMixtureLaw_mean
#print axioms ConditionalNonpolynomial.Analytic.actualParitySeedLaw_mean_and_diagonal
