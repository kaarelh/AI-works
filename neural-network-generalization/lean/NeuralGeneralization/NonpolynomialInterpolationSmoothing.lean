import NeuralGeneralization.NonpolynomialInterpolationMoments
import Mathlib.Analysis.Calculus.BumpFunction.SmoothApprox
import Mathlib.Analysis.SpecificLimits.Basic

/-! Smoothing preserves every affine-translate relation. A single nonzero
moment fixes a degree bound for all the smooth approximations, hence for the
original continuous function. No differentiability of the activation is assumed. -/
noncomputable section
open scoped BigOperators Topology ContDiff Convolution
open Filter MeasureTheory ContinuousLinearMap
namespace NeuralGeneralization.NonpolynomialInterpolation

/-- Normalized smooth kernels with support radii tending to zero. -/
def smoothingBump (n : ℕ) : ContDiffBump (0 : ℝ) :=
  ⟨(1 / (n + 1 : ℝ)) / 2, 1 / (n + 1 : ℝ), by positivity,
    half_lt_self (by positivity)⟩

def smooth (f : ℝ → ℝ) (n : ℕ) : ℝ → ℝ :=
  (smoothingBump n).normed volume ⋆[lsmul ℝ ℝ, volume] f

theorem smooth_contDiff {f : ℝ → ℝ} (hf : Continuous f) (n : ℕ) :
    ContDiff ℝ ∞ (smooth f n) :=
  (smoothingBump n).hasCompactSupport_normed.contDiff_convolution_left _
    (smoothingBump n).contDiff_normed hf.locallyIntegrable

theorem smooth_tendsto {f : ℝ → ℝ} (hf : Continuous f) (x : ℝ) :
    Tendsto (fun n => smooth f n x) atTop (𝓝 (f x)) :=
  ContDiffBump.convolution_tendsto_right_of_continuous
    (show Tendsto (fun n => (smoothingBump n).rOut) atTop (𝓝 0) from
      tendsto_one_div_add_atTop_nhds_zero_nat) hf x

/-- Convolution in the translation variable preserves the whole relation,
with the same coefficients and input nodes. -/
theorem smooth_relation {ι : Type*} [Fintype ι] {f : ℝ → ℝ}
    (hf : Continuous f) {t c : ι → ℝ}
    (hrel : ∀ s b, ∑ i, c i * f (s * t i + b) = 0)
    (n : ℕ) (s b : ℝ) : ∑ i, c i * smooth f n (s * t i + b) = 0 := by
  let K := (smoothingBump n).normed volume
  have hi (i : ι) : Integrable (fun u => K u * f (s * t i + b - u)) := by
    simpa only [ConvolutionExistsAt, lsmul_apply, smul_eq_mul] using
      (smoothingBump n).hasCompactSupport_normed.convolutionExists_left_of_continuous_right
        (L := lsmul ℝ ℝ) (smoothingBump n).continuous_normed.locallyIntegrable hf
        (s * t i + b)
  change ∑ i, c i * ∫ u, K u * f (s * t i + b - u) = 0
  simp_rw [← integral_const_mul]
  rw [← integral_finsetSum Finset.univ (fun i _ => (hi i).const_mul (c i))]
  have hz (u : ℝ) : ∑ i, c i * (K u * f (s * t i + b - u)) = 0 := by
    calc
      _ = K u * ∑ i, c i * f (s * t i + (b - u)) := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro i _
        rw [show s * t i + b - u = s * t i + (b - u) by ring]
        ring
      _ = 0 := by rw [hrel, mul_zero]
  simp_rw [hz, integral_zero]

/-- A continuous function with one nontrivial relation among all its affine
translates must itself be polynomial. -/
theorem polynomial_of_relation {ι : Type*} [Fintype ι] {f : ℝ → ℝ}
    (hf : Continuous f) {t c : ι → ℝ} (ht : Function.Injective t) (hc : c ≠ 0)
    (hrel : ∀ s b, ∑ i, c i * f (s * t i + b) = 0) :
    ∃ p : Polynomial ℝ, ∀ x, f x = p.eval x := by
  obtain ⟨k, hk⟩ := exists_nonzero_moment ht hc
  apply mem_powerSpan_polynomial (n := k)
  apply mem_powerSpan_of_tendsto (f := smooth f) (l := atTop)
  · exact Eventually.of_forall fun n => smooth_relation_powerSpan
      (smooth_contDiff hf n) hk (smooth_relation hf hrel n)
  · exact smooth_tendsto hf

/-- Nonpolynomial means unequal to every real polynomial as a function. -/
def Nonpolynomial (f : ℝ → ℝ) : Prop :=
  ¬ ∃ p : Polynomial ℝ, ∀ x, f x = p.eval x

theorem relation_coefficients_zero {ι : Type*} [Fintype ι] {f : ℝ → ℝ}
    (hf : Continuous f) (hn : Nonpolynomial f) {t c : ι → ℝ}
    (ht : Function.Injective t)
    (hrel : ∀ s b, ∑ i, c i * f (s * t i + b) = 0) : c = 0 := by
  by_contra hc
  exact hn (polynomial_of_relation hf ht hc hrel)

end NeuralGeneralization.NonpolynomialInterpolation
