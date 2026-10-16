import NeuralGeneralization.GaussianWalshMeanTail
import NeuralGeneralization.ConfidenceClipping

/-! Deterministic negative-exponent endpoint for the actual Gaussian sign
posterior. All posterior, confidence, mean-energy and residual-variance
hypotheses are discharged. The remaining hypotheses are explicit spectral
and sampled-head size bounds. -/
noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators NNReal RealInnerProductSpace
namespace NeuralGeneralization.GaussianParityConfidence
open Classical
attribute [local instance] Classical.propDecidable
open GaussianSignCone GaussianSignRegression GaussianPosteriorFeatures GaussianWalshMeanTail
open GaussianWalshResidual GaussianResidualIndependence GaussianSignConfidence
variable {d : ℕ} {J : Type*} [Fintype J]

def signedFeature (w : Finset (Fin d) → ℝ) (x : ClippingCube d) : Finset (Fin d) → ℝ :=
  fun S => fullParity x * (Real.sqrt (w S) * walshCharacter S x)

def confidence (w : Finset (Fin d) → ℝ) (A : J → Finset (Fin d) → ℝ)
    (x : ClippingCube d) : ℝ :=
  (GaussianConditionalLogCDF.conditionedOutput A (signedFeature w x)).real (Set.Ioi 0)

def meanField (w : Finset (Fin d) → ℝ) (A : J → Finset (Fin d) → ℝ)
    (x : ClippingCube d) : ℝ := walshExpansion (posteriorCoefficients A w) x

theorem signedFeature_variance (w : Finset (Fin d) → ℝ) (A : J → Finset (Fin d) → ℝ)
    (x : ClippingCube d) :
    GaussianSignConfidence.variance A (signedFeature w x) =
      residualVariance (observationSpan A) (featureVector w x) := by
  apply signed_variance_eq
  rcases fullParity_sign x with h | h <;> rw [h] <;> norm_num

theorem signedFeature_mean (w : Finset (Fin d) → ℝ) (A : J → Finset (Fin d) → ℝ)
    (hprob : (Measure.pi (fun _ : Finset (Fin d) => gaussianReal 0 1)) (signCone A) ≠ 0)
    (x : ClippingCube d) :
    (∫ z, GaussianSignCDF.linear (signedFeature w x) z
      ∂cond (GaussianCoordinateIntegration.law (Finset (Fin d))) (signCone A)) =
        fullParity x * meanField w A x := by
  have heq (z : Finset (Fin d) → ℝ) : GaussianSignCDF.linear (signedFeature w x) z =
      fullParity x * ∑ S, Real.sqrt (w S) * z S * walshCharacter S x := by
    unfold GaussianSignCDF.linear signedFeature
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro S hS
    ring
  simp_rw [heq]
  rw [integral_const_mul]
  exact congrArg (fun t => fullParity x * t) (posterior_mean_eq w A hprob x)

theorem fraction_eq_filter_card (V : Set (ClippingCube d)) :
    ConfidenceClipping.fraction V =
      ((Finset.univ.filter (fun x => x ∈ V)).card : ℝ) / Fintype.card (ClippingCube d) := by
  classical
  unfold ConfidenceClipping.fraction uniformCubeMean
  congr 1
  rw [← Finset.sum_filter]
  simp

/-- Actual Gaussian sign-posterior confidence failure, under explicit
spectral tail and head-size budgets. The actual observation matrix may be
singular, and observations may repeat. -/
theorem failure_lower_of_spectral_budgets {u : ℕ} (hd : 0 < d)
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (A : J → Finset (Fin d) → ℝ)
    (hprob : (Measure.pi (fun _ : Finset (Fin d) => gaussianReal 0 1)) (signCone A) ≠ 0)
    (H : Finset (Finset (Fin d))) (hdegree : ∀ S ∈ H, S.card ≤ u)
    (ell b : ℝ) (hell : 0 ≤ ell) (hb : 0 < b)
    (hmax : ∀ S ∈ Finset.univ \ H, w S ≤ ell)
    (htau : 0 < ∑ S ∈ Finset.univ \ H, w S)
    (hmargin : 2 * b ≤ Real.sqrt (Real.pi * (∑ S ∈ Finset.univ \ H, w S)) *
      (Real.exp (-1) - 7 / 20))
    (hvariance : 2 * Fintype.card J * ell / (∑ S ∈ Finset.univ \ H, w S) ≤ 1 / 32)
    (htail : Fintype.card J * ell ≤ b ^ 2 / 32)
    (hhead : (u : ℝ) ^ 2 * uniformCubeMean (fun x =>
      walshExpansion (maskCoefficients H (posteriorCoefficients A w)) x ^ 2) ≤
        (b * (d : ℝ)) ^ 2 / 64) :
    (3 : ℝ) / 8 ≤ ConfidenceClipping.failure (confidence w A) (13 / 20) := by
  classical
  let T := Finset.univ \ H
  let tau : ℝ := ∑ S ∈ T, w S
  let V : Set (ClippingCube d) :=
    {x | residualVariance (observationSpan A) (featureVector w x) < tau / 2}
  have hdeg : ∀ S, maskCoefficients H (posteriorCoefficients A w) S ≠ 0 → S.card ≤ u := by
    intro S hS
    by_cases h : S ∈ H
    · exact hdegree S h
    · exact False.elim (hS (by simp [maskCoefficients, h]))
  apply ConfidenceClipping.failure_lower_of_mean_approximation hd
    (maskCoefficients H (posteriorCoefficients A w)) hdeg
    (confidence w A) (meanField w A) (13 / 20) b hb V _ _ _ hhead
  · intro x hq hx
    have hvar : tau / 2 ≤ residualVariance (observationSpan A) (featureVector w x) :=
      le_of_not_gt hx
    have hv : 0 < GaussianSignConfidence.variance A (signedFeature w x) := by
      rw [signedFeature_variance]
      exact (half_pos htau).trans_le hvar
    have hm := buffered_confidence_mean_margin A (signedFeature w x) hprob hv hq
    rw [signedFeature_variance, signedFeature_mean w A hprob x] at hm
    have hs : Real.pi * tau ≤ 2 * Real.pi *
        residualVariance (observationSpan A) (featureVector w x) := by
      have hp := Real.pi_pos
      nlinarith
    have hl := mul_le_mul_of_nonneg_right (Real.sqrt_le_sqrt hs)
      buffered_confidence_constant_pos.le
    exact hmargin.trans (hl.trans hm.le)
  · rw [fraction_eq_filter_card]
    exact (small_variance_fraction_le w (fun S => (hw S).le) T ell hell hmax htau A).trans hvariance
  · have heq (x : ClippingCube d) :
        meanField w A x - walshExpansion (maskCoefficients H (posteriorCoefficients A w)) x =
          walshExpansion (maskCoefficients T (posteriorCoefficients A w)) x := by
      have hh := featureField_decomposition (fun S x => walshCharacter S x)
        (posteriorCoefficients A w) H x
      change meanField w A x = walshExpansion (maskCoefficients H (posteriorCoefficients A w)) x +
        walshExpansion (maskCoefficients T (posteriorCoefficients A w)) x at hh
      linarith
    simp_rw [heq]
    exact (posterior_tail_mean_square_le w hw A hprob T ell hell hmax).trans htail

end NeuralGeneralization.GaussianParityConfidence
