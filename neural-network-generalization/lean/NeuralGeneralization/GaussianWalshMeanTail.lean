import NeuralGeneralization.GaussianWalshResidual

/-! The actual Gaussian sign-posterior mean has small Fourier tail. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.GaussianWalshMeanTail
open GaussianSignCone GaussianPosteriorFeatures
variable {d : ℕ} {J : Type*} [Fintype J]

/-- Population Fourier-tail energy of the actual posterior mean is at most
sample count times the largest retained eigenvalue. -/
theorem posterior_tail_mean_square_le
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (A : J → Finset (Fin d) → ℝ)
    (hprob : (Measure.pi (fun _ : Finset (Fin d) => gaussianReal 0 1)) (signCone A) ≠ 0)
    (T : Finset (Finset (Fin d))) (ell : ℝ) (hell : 0 ≤ ell)
    (hmax : ∀ S ∈ T, w S ≤ ell) :
    uniformCubeMean (fun x => walshExpansion (maskCoefficients T (posteriorCoefficients A w)) x ^ 2)
      ≤ Fintype.card J * ell := by
  calc
    _ ≤ ell * featureEnergy w (posteriorCoefficients A w) :=
      walsh_tail_population_square_le w _ hw T ell hell hmax
    _ ≤ ell * Fintype.card J := mul_le_mul_of_nonneg_left
      (posterior_feature_energy_le_sample_count w (fun S => (hw S).le) A hprob) hell
    _ = _ := mul_comm _ _

/-- The full mean field is the actual conditional expectation of the Walsh
Gaussian field, with the displayed Fourier coefficients. -/
theorem posterior_mean_eq
    (w : Finset (Fin d) → ℝ) (A : J → Finset (Fin d) → ℝ)
    (hprob : (Measure.pi (fun _ : Finset (Fin d) => gaussianReal 0 1)) (signCone A) ≠ 0)
    (x : ClippingCube d) :
    (∫ z, (∑ S, Real.sqrt (w S) * z S * walshCharacter S x)
      ∂cond (Measure.pi (fun _ : Finset (Fin d) => gaussianReal 0 1)) (signCone A)) =
        walshExpansion (posteriorCoefficients A w) x :=
  mean_eq_featureField (fun S x => walshCharacter S x) w A hprob x

/-- Signed prediction rows have the same residual variance for labels of
unit magnitude, as required by the confidence-margin conversion. -/
theorem signed_variance_eq
    (A : J → Finset (Fin d) → ℝ) (w : Finset (Fin d) → ℝ)
    (x : ClippingCube d) (y : ℝ) (hy : y ^ 2 = 1) :
    GaussianSignConfidence.variance A (fun S => y * (Real.sqrt (w S) * walshCharacter S x)) =
      GaussianResidualIndependence.residualVariance (GaussianSignRegression.observationSpan A)
        (GaussianWalshResidual.featureVector w x) := by
  have heq : WithLp.toLp 2 (fun S => y * (Real.sqrt (w S) * walshCharacter S x)) =
      y • GaussianWalshResidual.featureVector w x := by
    ext S
    rfl
  unfold GaussianSignConfidence.variance GaussianResidualIndependence.residualVariance
  rw [heq, map_smul, norm_smul, mul_pow, Real.norm_eq_abs, sq_abs, hy, one_mul]

end NeuralGeneralization.GaussianWalshMeanTail
