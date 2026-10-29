import GaussianSeedReference
import RareFourierSeed
import FiniteMixtureKL
import GaussianShiftKL

/-! Entropy of the actual Gaussian/Fourier seed measures. Component Gaussian KL
is the closed density-based theorem in GaussianShiftKL; mixtures use the actual
conditional-KL chain rule and data processing from FiniteMixtureKL. -/

noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal NNReal
open MeasureTheory ProbabilityTheory InformationTheory NeuralGeneralization

namespace ConditionalNonpolynomial.Analytic

section UniformMaps
variable {ι Ω Y : Type*} [Fintype ι] [Nonempty ι] [MeasurableSpace ι]
    [MeasurableSingletonClass ι] [MeasurableSpace Ω] [MeasurableSpace Y]

def uniformFiniteWeight (_i : ι) : ℝ := 1 / (Fintype.card ι : ℝ)

theorem uniformFiniteWeight_nonneg (i : ι) : 0 ≤ uniformFiniteWeight i := by
  unfold uniformFiniteWeight
  positivity

theorem uniformFiniteWeight_sum : (∑ i : ι, uniformFiniteWeight i) = 1 := by
  simp [uniformFiniteWeight, ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos :
    (0 : ℝ) < Fintype.card ι)]

theorem uniformMapProduct_eq_finiteMixture (μ : Measure Ω) [IsProbabilityMeasure μ]
    (F : ι × Ω → Y) (hF : Measurable F) :
    (((PMF.uniformOfFintype ι).toMeasure).prod μ).map F =
      finiteProbabilityMixture uniformFiniteWeight (fun i => μ.map (fun w => F (i,w))) := by
  ext E hE
  rw [Measure.map_apply hF hE, Measure.prod_apply (hE.preimage hF), lintegral_fintype]
  simp only [finiteProbabilityMixture, Measure.finsetSum_apply, Measure.smul_apply, smul_eq_mul]
  apply Finset.sum_congr rfl
  intro i _
  have hFi : Measurable (fun w : Ω => F (i,w)) := hF.comp measurable_prodMk_left
  rw [PMF.toMeasure_apply_singleton _ i (MeasurableSet.singleton i), PMF.uniformOfFintype_apply,
    Measure.map_apply hFi hE]
  have hw : ENNReal.ofReal (uniformFiniteWeight i) = (Fintype.card ι : ℝ≥0∞)⁻¹ := by
    rw [uniformFiniteWeight, ENNReal.ofReal_div_of_pos (Nat.cast_pos.mpr Fintype.card_pos)]
    simp
  rw [hw]
  exact mul_comm _ _

end UniformMaps

theorem finiteProbabilityMixture_klDiv_bound {ι Ω : Type*}
    [Fintype ι] [MeasurableSpace ι] [MeasurableSingletonClass ι] [StandardBorelSpace ι]
    [MeasurableSpace Ω] [StandardBorelSpace Ω] [Nonempty ι] [Nonempty Ω]
    (p : ι → ℝ) (μ : ι → Measure Ω) (G : Measure Ω)
    [∀ i, IsProbabilityMeasure (μ i)] [IsProbabilityMeasure G]
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1)
    (B : ℝ≥0∞) (hB : ∀ i, klDiv (μ i) G ≤ B) :
    klDiv (finiteProbabilityMixture p μ) G ≤ B := by
  apply (finiteProbabilityMixture_klDiv_reference_le p μ G hp hsum).trans
  calc
    (∑ i, ENNReal.ofReal (p i)*klDiv (μ i) G) ≤ ∑ i, ENNReal.ofReal (p i)*B :=
      Finset.sum_le_sum (fun i _ => mul_le_mul_left' (hB i) _)
    _ = B := by
      rw [← Finset.sum_mul, ← ENNReal.ofReal_sum_of_nonneg (fun i _ => hp i), hsum,
        ENNReal.ofReal_one, one_mul]

variable {d : ℕ}

def seedGaussianReference (σ : ℝ) : Measure (Option (Fin d) → ℝ) :=
  Measure.pi fun _ => gaussianReal 0 (NNReal.mk (σ^2) (sq_nonneg σ))

instance seedGaussianReference_probability (σ : ℝ) :
    IsProbabilityMeasure (seedGaussianReference (d := d) σ) := by
  unfold seedGaussianReference
  infer_instance

def seedEntropyBudget (d : ℕ) (σ : ℝ) : ℝ := 64*((d : ℝ)+1)^4/σ^2

theorem seedEntropyBudget_nonneg (d : ℕ) (σ : ℝ) : 0 ≤ seedEntropyBudget d σ := by
  unfold seedEntropyBudget
  positivity

theorem gaussianParityComponent_kl_bound (S : Finset (Fin d)) (j : Option (Fin S.card))
    (σ : ℝ) (hσ : σ ≠ 0) :
    klDiv ((Measure.pi fun _ : Option (Fin d) => gaussianReal 0 1).map
      (fun z i => parityMixtureShift S j i + σ*z i)) (seedGaussianReference σ) ≤
      ENNReal.ofReal (seedEntropyBudget d σ) := by
  rw [standardGaussian_affine_map]
  have hv : NNReal.mk (σ^2) (sq_nonneg σ) ≠ 0 := by
    intro h
    have hh := congrArg (fun q : ℝ≥0 => (q : ℝ)) h
    exact hσ (sq_eq_zero_iff.mp hh)
  have hfin := ConditionalAnalytic.gaussianMeanPi_kl_ne_top (parityMixtureShift S j) _ hv
  unfold seedGaussianReference
  rw [← ENNReal.ofReal_toReal hfin, ConditionalAnalytic.gaussianMeanPi_kl_toReal _ _ hv]
  apply ENNReal.ofReal_le_ofReal
  have hnorm := parityMixtureShift_normSq_le S j
  change (∑ i, parityMixtureShift S j i ^ 2)/(2*σ^2) ≤ 64*((d : ℝ)+1)^4/σ^2
  apply (div_le_iff₀ (by positivity : 0 < 2*σ^2)).mpr
  have he : 64*((d : ℝ)+1)^4/σ^2*(2*σ^2) = 128*((d : ℝ)+1)^4 := by
    field_simp
    ring
  rw [he]
  exact hnorm

theorem parityGaussianMixtureLaw_kl_bound (S : Finset (Fin d)) (σ : ℝ) (hσ : σ ≠ 0) :
    klDiv (parityGaussianMixtureLaw S σ) (seedGaussianReference σ) ≤
      ENNReal.ofReal (seedEntropyBudget d σ) := by
  rw [parityGaussianMixtureLaw, parityGaussianSource, parityMixtureIndexLaw,
    uniformMapProduct_eq_finiteMixture _ _ (measurable_parityGaussianShiftMap S σ)]
  haveI (j : Option (Fin S.card)) : IsProbabilityMeasure
      ((Measure.pi fun _ : Option (Fin d) => gaussianReal 0 1).map
        (fun z => parityGaussianShiftMap S σ (j,z))) :=
    Measure.isProbabilityMeasure_map
      ((measurable_parityGaussianShiftMap S σ).comp measurable_prodMk_left).aemeasurable
  apply finiteProbabilityMixture_klDiv_bound _ _ _ uniformFiniteWeight_nonneg
    uniformFiniteWeight_sum
  intro j
  exact gaussianParityComponent_kl_bound S j σ hσ

theorem symmetrizedTanhLaw_kl_le (S : Finset (Fin d))
    (μ : Measure (Option (Fin d) → ℝ)) [IsProbabilityMeasure μ] (σ : ℝ) :
    klDiv (symmetrizedTanhLaw S μ) (seedGaussianReference σ) ≤
      klDiv μ (seedGaussianReference σ) := by
  rw [symmetrizedTanhLaw, uniformCubeMeasure,
    uniformMapProduct_eq_finiteMixture _ _ (measurable_symmetrizedTanhWeights S)]
  have hm (u : ClippingCube d) : Measurable (symmetrizedTanhWeights S u) :=
    (measurable_symmetrizedTanhWeights S).comp measurable_prodMk_left
  haveI (u : ClippingCube d) : IsProbabilityMeasure (μ.map (symmetrizedTanhWeights S u)) :=
    Measure.isProbabilityMeasure_map (hm u).aemeasurable
  apply finiteProbabilityMixture_klDiv_bound _ _ _ uniformFiniteWeight_nonneg
    uniformFiniteWeight_sum
  intro u
  have h := NeuralGeneralization.RobustEntropy.klDiv_map_le μ (seedGaussianReference σ) (hm u)
  unfold seedGaussianReference at h
  rw [symmetrizedTanhWeights_gaussian_map] at h
  exact h

theorem actualParitySeedLaw_kl_bound (S : Finset (Fin d)) (σ : ℝ) (hσ : σ ≠ 0) :
    klDiv (actualParitySeedLaw S σ) (seedGaussianReference σ) ≤
      ENNReal.ofReal (seedEntropyBudget d σ) :=
  (symmetrizedTanhLaw_kl_le S (parityGaussianMixtureLaw S σ) σ).trans
    (parityGaussianMixtureLaw_kl_bound S σ hσ)

theorem signedTanhLaw_kl_le (a : ℝ) (μ : Measure (Option (Fin d) → ℝ))
    [IsProbabilityMeasure μ] (σ : ℝ) :
    klDiv (signedTanhLaw a μ) (seedGaussianReference σ) ≤ klDiv μ (seedGaussianReference σ) := by
  have h := NeuralGeneralization.RobustEntropy.klDiv_map_le μ (seedGaussianReference σ)
    (measurable_sign_weights a)
  unfold seedGaussianReference coefficientSign at h
  rw [signedTanhWeights_gaussian_map] at h
  exact h

/-- The actual exact Fourier seed has polynomial Gaussian KL, independent of
the number of nonzero Fourier coefficients. -/
theorem actualFourierSeedLaw_kl_bound (f : ClippingCube d → ℝ) (σ : ℝ)
    (hf : ∃ x, f x ≠ 0) (hσ0 : σ ≠ 0) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2) :
    klDiv (actualFourierSeedLaw f σ) (seedGaussianReference σ) ≤
      ENNReal.ofReal (seedEntropyBudget d σ) := by
  letI : MeasurableSpace (Finset (Fin d)) := ⊤
  letI : DiscreteMeasurableSpace (Finset (Fin d)) := ⟨fun _ => trivial⟩
  apply finiteProbabilityMixture_klDiv_bound _ _ _
    (fourierSeedWeights_nonneg f σ hf hσ) (fourierSeedWeights_sum f σ hf hσ)
  intro S
  exact (signedTanhLaw_kl_le _ _ σ).trans (actualParitySeedLaw_kl_bound S σ hσ0)

/-- The reference tagged law has exactly the original row-law marginal. -/
theorem rareSeedLaw_reference_snd (θ : ℝ) (μ : Measure (Option (Fin d) → ℝ))
    (hθ0 : 0 ≤ θ) (hθ1 : θ ≤ 1) : (rareSeedLaw θ μ μ).snd = μ := by
  ext E hE
  rw [Measure.snd_apply hE]
  have htag (b : Bool) : taggedRowLaw b μ (Prod.snd ⁻¹' E) = μ E := by
    rw [taggedRowLaw, Measure.map_apply (measurable_taggedRowMap b) (measurable_snd hE)]
    rfl
  simp only [rareSeedLaw, finiteProbabilityMixture, Measure.finsetSum_apply,
    Measure.smul_apply, smul_eq_mul, ite_self, htag]
  rw [← Finset.sum_mul, ← ENNReal.ofReal_sum_of_nonneg
    (fun b _ => rareTagWeight_nonneg θ hθ0 hθ1 b), rareTagWeight_sum,
    ENNReal.ofReal_one, one_mul]

/-- Rare tagging pays theta times the controlled row KL, with the raw row
distribution unchanged under the augmented reference law. -/
theorem rareSeedLaw_kl_le (θ : ℝ) (μ ν : Measure (Option (Fin d) → ℝ))
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν] (hθ0 : 0 ≤ θ) (hθ1 : θ ≤ 1) :
    klDiv (rareSeedLaw θ μ ν) (rareSeedLaw θ μ μ) ≤ ENNReal.ofReal θ * klDiv ν μ := by
  haveI (b : Bool) : IsProbabilityMeasure (if b then ν else μ) := by cases b <;> infer_instance
  have h := finiteProbabilityMixture_klDiv_le (rareTagWeight θ)
    (fun b => taggedRowLaw b (if b then ν else μ))
    (fun b => taggedRowLaw b (if b then μ else μ))
    (rareTagWeight_nonneg θ hθ0 hθ1) (rareTagWeight_sum θ)
  have htrue := NeuralGeneralization.RobustEntropy.klDiv_map_le ν μ
    (measurable_taggedRowMap (d := d) true)
  have heq : (∑ b : Bool, ENNReal.ofReal (rareTagWeight θ b) *
      klDiv (taggedRowLaw b (if b then ν else μ)) (taggedRowLaw b (if b then μ else μ))) =
      ENNReal.ofReal θ * klDiv (taggedRowLaw true ν) (taggedRowLaw true μ) := by
    simp [rareTagWeight, klDiv_self]
  rw [heq] at h
  exact h.trans (mul_le_mul_left' htrue _)

theorem rareFourierSeed_kl_bound (f : ClippingCube d → ℝ) (σ θ : ℝ)
    (hf : ∃ x, f x ≠ 0) (hσ0 : σ ≠ 0) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2)
    (hθ0 : 0 ≤ θ) (hθ1 : θ ≤ 1) :
    klDiv (rareSeedLaw θ (seedGaussianReference σ) (actualFourierSeedLaw f σ))
      (rareSeedLaw θ (seedGaussianReference σ) (seedGaussianReference σ)) ≤
      ENNReal.ofReal (θ * seedEntropyBudget d σ) := by
  letI := actualFourierSeedLaw_probability f σ hf hσ
  have h := (rareSeedLaw_kl_le θ (seedGaussianReference σ) (actualFourierSeedLaw f σ)
    hθ0 hθ1).trans (mul_le_mul_left' (actualFourierSeedLaw_kl_bound f σ hf hσ0 hσ) _)
  rw [← ENNReal.ofReal_mul hθ0] at h
  exact h

end ConditionalNonpolynomial.Analytic

#print axioms ConditionalNonpolynomial.Analytic.actualParitySeedLaw_kl_bound
#print axioms ConditionalNonpolynomial.Analytic.actualFourierSeedLaw_kl_bound
#print axioms ConditionalNonpolynomial.Analytic.rareFourierSeed_kl_bound
#print axioms ConditionalNonpolynomial.Analytic.rareSeedLaw_reference_snd
