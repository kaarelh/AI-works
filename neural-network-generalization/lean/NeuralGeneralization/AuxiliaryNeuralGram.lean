import NeuralGeneralization.ElementaryTailGram
import NeuralGeneralization.WalshGaussianLaw
import NeuralGeneralization.GaussianAmplitudeFinite

/-!
# The actual auxiliary neural Gram matrix and population counting

The Frobenius bound is sufficient for the smaller independent auxiliary
sample used in the Gaussian-endpoint amplitude argument. This does not
claim the sharper Gram estimate required at the adaptive main cutoff.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization

lemma finiteQuadratic_sub_diagonal {I : Type*} [Fintype I] [DecidableEq I]
    (A : I → I → ℝ) (v : ℝ) (b : I → ℝ) :
    finiteQuadratic (fun i j => A i j-(if i=j then v else 0)) b =
      finiteQuadratic A b-v*(∑ i, b i^2) := by
  unfold finiteQuadratic
  simp only [mul_sub, sub_mul, Finset.sum_sub_distrib]
  congr 1
  have hpoint (i : I) : (∑ j, b i*(if i=j then v else 0)*b j) = v*b i^2 := by
    rw [Finset.sum_eq_single i]
    · simp; ring
    · intro j _ hji
      simp [Ne.symm hji]
    · simp
  simp_rw [hpoint]
  exact (Finset.mul_sum Finset.univ (fun i => b i^2) v).symm

lemma matrix_floor_of_quadratic {I : Type*} [Fintype I] [DecidableEq I]
    (A : I → I → ℝ) (hsym : ∀ i j, A i j=A j i) (v : ℝ)
    (hQ : ∀ b : I → ℝ, v*(∑ i, b i^2) ≤ finiteQuadratic A b) :
    Matrix.PosSemidef (fun i j => A i j-(if i=j then v else 0)) := by
  apply Matrix.PosSemidef.of_dotProduct_mulVec_nonneg
  · ext i j
    simp only [Matrix.conjTranspose_apply, star_trivial]
    rw [hsym j i]
    by_cases hij : i=j
    · subst j; rfl
    · simp [hij, Ne.symm hij]
  · intro b
    have h := sub_nonneg.mpr (hQ b)
    rw [← finiteQuadratic_sub_diagonal] at h
    simpa only [finiteQuadratic, dotProduct, Matrix.mulVec, Pi.star_apply,
      star_trivial, Finset.mul_sum, mul_assoc] using h

theorem arcsineTailQuadratic_le_full {I : Type*} [Fintype I]
    (d k r : ℕ) (s : I → ClippingCube d) (b : I → ℝ) :
    finiteQuadratic (fun i j => arcsineTailCovariance d k r (s i) (s j)) b ≤
      finiteQuadratic (fun i j => arcsineCovariance d k (s i) (s j)) b := by
  classical
  simp only [arcsineCovariance_walsh, arcsineTailCovariance, walshKernel]
  rw [featureKernel_quadratic, featureKernel_quadratic]
  apply Finset.sum_le_sum
  intro S _
  apply mul_le_mul_of_nonneg_right _ (sq_nonneg _)
  split_ifs
  · exact le_refl _
  · exact arcsineProfile_coefficient_nonneg d k S

/-- A relative half-trace tail event gives a genuine positive-semidefinite
floor for the full selected covariance. -/
theorem arcsineGram_floor_of_tail_event (d k r n : ℕ) (s : Fin n → ClippingCube d)
    (hQ : ∀ b : Fin n → ℝ,
      |finiteQuadratic (fun i j => arcsineTailCovariance d k r (s i) (s j)) b-
        walshSpectralTail (arcsineProfile d k) r*(∑ i, b i^2)| ≤
      ((1:ℝ)/2)*walshSpectralTail (arcsineProfile d k) r*(∑ i, b i^2)) :
    Matrix.PosSemidef (fun i j => arcsineCovariance d k (s i) (s j)-
      (if i=j then walshSpectralTail (arcsineProfile d k) r/2 else 0)) := by
  apply matrix_floor_of_quadratic
  · intro i j
    simp only [arcsineCovariance_walsh]
    exact walshKernel_symm _ _ _
  · intro b
    have h := (abs_le.mp (hQ b)).1
    have hfull := arcsineTailQuadratic_le_full d k r s b
    linarith

/-- All sample sizes are included; the useful auxiliary range is where
`4*n²/choose(d,r)` is small. Repeated points are included in the law. -/
theorem arcsineGram_floor_probability (d k r n : ℕ) (hr : r ≤ d) :
    1-4*(n:ℝ)^2/d.choose r ≤
      ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n (fun s =>
        Matrix.PosSemidef (fun i j => arcsineCovariance d (k+1) (s i) (s j)-
          (if i=j then walshSpectralTail (arcsineProfile d (k+1)) r/2 else 0))) := by
  have h := arcsineTailGram_quadratic_probability d k r n hr ((1:ℝ)/2) (by norm_num)
  have heq : (n:ℝ)^2/(((1:ℝ)/2)^2*d.choose r) = 4*(n:ℝ)^2/d.choose r := by ring
  rw [heq] at h
  apply h.trans
  rw [← uniformCubeSample_measure_eq_probability, ← uniformCubeSample_measure_eq_probability]
  exact measureReal_mono (fun s hs => arcsineGram_floor_of_tail_event d (k+1) r n s hs)

/-- The covariance-floor event in the exact matrix convention used by the
finite Gaussian amplitude theorem. -/
theorem arcsineFeatureGram_floor_of_tail_event (d k r n : ℕ) (hr : r ≤ d)
    (s : Fin n → ClippingCube d)
    (hQ : ∀ b : Fin n → ℝ,
      |finiteQuadratic (fun i j => arcsineTailCovariance d (k+1) r (s i) (s j)) b-
        walshSpectralTail (arcsineProfile d (k+1)) r*(∑ i, b i^2)| ≤
      ((1:ℝ)/2)*walshSpectralTail (arcsineProfile d (k+1)) r*(∑ i, b i^2)) :
    Matrix.PosSemidef (fun i j => GaussianAngularPrice.gram
      (fun i S => WalshGaussianLaw.features (walshCoefficients (arcsineProfile d (k+1))) S (s i)) i j-
        (if i=j then (Real.sqrt (walshSpectralTail (arcsineProfile d (k+1)) r/2))^2 else 0)) := by
  have h := arcsineGram_floor_of_tail_event d (k+1) r n s hQ
  have hg (i j : Fin n) : GaussianAngularPrice.gram
      (fun i S => WalshGaussianLaw.features (walshCoefficients (arcsineProfile d (k+1))) S (s i)) i j =
      arcsineCovariance d (k+1) (s i) (s j) := by
    change GaussianReadout.gram
      (WalshGaussianLaw.features (walshCoefficients (arcsineProfile d (k+1)))) (s i) (s j) = _
    rw [WalshGaussianLaw.gram_features _ (fun S => arcsineProfile_coefficient_nonneg d (k+1) S),
      arcsineCovariance_walsh]
  have hτ : 0 ≤ walshSpectralTail (arcsineProfile d (k+1)) r/2 :=
    div_nonneg (arcsineSpectralTail_pos d k r hr).le (by norm_num)
  simpa only [hg, Real.sq_sqrt hτ] using h

/-- Expected selected count is exactly sample size times population
fraction, for each fixed output field. -/
theorem uniformCubeSample_smallMeanCount (d n : ℕ) (b : ℝ) (z : ClippingCube d → ℝ) :
    (∫ s, GaussianAmplitude.smallMeanCount b (z ∘ s)
      ∂CompressionSampling.iidSamples (uniformCubeMeasure d) n) =
      (n:ℝ)*uniformCubeMean (fun x => if |z x| ≤ b then 1 else 0) := by
  classical
  unfold GaussianAmplitude.smallMeanCount
  rw [integral_finsetSum Finset.univ (fun _ _ => Integrable.of_finite)]
  have hi (i : Fin n) : (∫ s : Fin n → ClippingCube d, if |(z ∘ s) i| ≤ b then (1:ℝ) else 0
      ∂CompressionSampling.iidSamples (uniformCubeMeasure d) n) =
      uniformCubeMean (fun x => if |z x| ≤ b then 1 else 0) := by
    change (∫ s : Fin n → ClippingCube d, if |z (s i)| ≤ b then (1:ℝ) else 0
      ∂Measure.pi (fun _ : Fin n => uniformCubeMeasure d)) = _
    rw [integral_comp_eval (μ := fun _ : Fin n => uniformCubeMeasure d) (i := i)
      (f := fun x => if |z x| ≤ b then (1:ℝ) else 0)
      (measurable_of_finite _).aestronglyMeasurable]
    exact uniformCubeMeasure_integral _ _
  simp only [hi, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]

end NeuralGeneralization
