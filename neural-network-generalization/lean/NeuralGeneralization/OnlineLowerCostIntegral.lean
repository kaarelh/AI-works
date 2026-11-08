import NeuralGeneralization.OnlineLowerCostPath
import NeuralGeneralization.OnlineLowerCostEnumerator
import Mathlib.MeasureTheory.Integral.Bochner.Basic

/-!
# Strict scalar-cost separation by a positive Bernstein integral

This module proves that the common pointwise path order survives integration
against any positive kernel on a nonzero measure space. The analytic task of
identifying the ReLU parity cost with a particular Bernstein integral is
separate; no cost-separation assumption is used here.
-/

noncomputable section

open MeasureTheory

namespace NeuralGeneralization.OnlineLower

theorem integral_strict_mono_of_ae_lt {α : Type*} [MeasurableSpace α]
    (μ : Measure α) (hμ : μ ≠ 0) {f g : α → ℝ}
    (hf : Integrable f μ) (hg : Integrable g μ)
    (hlt : ∀ᵐ t ∂μ, f t < g t) :
    (∫ t, f t ∂μ) < ∫ t, g t ∂μ := by
  have hle : f ≤ᵐ[μ] g := hlt.mono fun _ h => h.le
  have hi := integral_mono_ae hf hg hle
  have hne : (∫ t, f t ∂μ) ≠ ∫ t, g t ∂μ := by
    intro he
    have heq : f =ᵐ[μ] g := (integral_eq_iff_of_ae_le hf hg hle).mp he
    haveI : (ae μ).NeBot := ae_neBot.mpr hμ
    obtain ⟨t, ht, hlt'⟩ := (heq.and hlt).exists
    exact (ne_of_lt hlt') ht
  exact lt_of_le_of_ne hi hne

def integratedPathCost {α : Type*} [MeasurableSpace α]
    (μ : Measure α) (kernel x : α → ℝ) (k : ℕ) (endpoint base : ℝ)
    (digits : List Bool) : ℝ :=
  base - ∫ t, kernel t * pathBoundaryScalar (x t) k endpoint digits ∂μ

theorem integratedPathCost_strict {α : Type*} [MeasurableSpace α]
    (μ : Measure α) (hμ : μ ≠ 0) (kernel x : α → ℝ)
    (hk : ∀ᵐ t ∂μ, 0 < kernel t)
    (hx : ∀ᵐ t ∂μ, 0 < x t ∧ x t ≤ 1)
    (k : ℕ) (endpoint base : ℝ) {xs ys : List Bool}
    (hlex : digitLexLt xs ys)
    (hix : Integrable (fun t => kernel t * pathBoundaryScalar (x t) k endpoint xs) μ)
    (hiy : Integrable (fun t => kernel t * pathBoundaryScalar (x t) k endpoint ys) μ) :
    integratedPathCost μ kernel x k endpoint base ys <
      integratedPathCost μ kernel x k endpoint base xs := by
  have hpoint : ∀ᵐ t ∂μ,
      kernel t * pathBoundaryScalar (x t) k endpoint xs <
        kernel t * pathBoundaryScalar (x t) k endpoint ys := by
    filter_upwards [hk, hx] with t hkt hxt
    exact normalized_path_scalar_lt (x t) (kernel t) hxt.1 hxt.2 hkt k endpoint hlex
  have hint := integral_strict_mono_of_ae_lt μ hμ hix hiy hpoint
  unfold integratedPathCost
  linarith

theorem integratedPathCost_ne_of_ne {α : Type*} [MeasurableSpace α]
    (μ : Measure α) (hμ : μ ≠ 0) (kernel x : α → ℝ)
    (hk : ∀ᵐ t ∂μ, 0 < kernel t)
    (hx : ∀ᵐ t ∂μ, 0 < x t ∧ x t ≤ 1)
    (k : ℕ) (endpoint base : ℝ) {xs ys : List Bool}
    (hlen : xs.length = ys.length) (hne : xs ≠ ys)
    (hix : Integrable (fun t => kernel t * pathBoundaryScalar (x t) k endpoint xs) μ)
    (hiy : Integrable (fun t => kernel t * pathBoundaryScalar (x t) k endpoint ys) μ) :
    integratedPathCost μ kernel x k endpoint base xs ≠
      integratedPathCost μ kernel x k endpoint base ys := by
  rcases digitLexLt_or_reverse hlen hne with h | h
  · exact (integratedPathCost_strict μ hμ kernel x hk hx k endpoint base h hix hiy).ne'
  · exact (integratedPathCost_strict μ hμ kernel x hk hx k endpoint base h hiy hix).ne

/-- The same theorem for the literal edge-choice sum, including every transfer
normalization. The family has a common order before integrating. -/
def integratedEnumeratorCost {α : Type*} [MeasurableSpace α]
    (μ : Measure α) (kernel x : α → ℝ) (endpoint : Bool) (base : ℝ)
    (digits : List Bool) : ℝ :=
  base - ∫ t, kernel t * candidatePathEnumerator (x t) endpoint digits ∂μ

theorem integratedEnumeratorCost_strict {α : Type*} [MeasurableSpace α]
    (μ : Measure α) (hμ : μ ≠ 0) (kernel x : α → ℝ)
    (hk : ∀ᵐ t ∂μ, 0 < kernel t)
    (hx : ∀ᵐ t ∂μ, 0 < x t ∧ x t < 1)
    (endpoint : Bool) (base : ℝ) {xs ys : List Bool}
    (hlen : xs.length = ys.length) (hlex : digitLexLt xs ys)
    (hix : Integrable (fun t => kernel t * candidatePathEnumerator (x t) endpoint xs) μ)
    (hiy : Integrable (fun t => kernel t * candidatePathEnumerator (x t) endpoint ys) μ) :
    integratedEnumeratorCost μ kernel x endpoint base ys <
      integratedEnumeratorCost μ kernel x endpoint base xs := by
  have hpoint : ∀ᵐ t ∂μ,
      kernel t * candidatePathEnumerator (x t) endpoint xs <
        kernel t * candidatePathEnumerator (x t) endpoint ys := by
    filter_upwards [hk, hx] with t hkt hxt
    exact mul_lt_mul_of_pos_left
      (candidatePathEnumerator_lt (x t) hxt.1 hxt.2 endpoint hlen hlex) hkt
  have hint := integral_strict_mono_of_ae_lt μ hμ hix hiy hpoint
  unfold integratedEnumeratorCost
  linarith

theorem integratedEnumeratorCost_ne_of_ne {α : Type*} [MeasurableSpace α]
    (μ : Measure α) (hμ : μ ≠ 0) (kernel x : α → ℝ)
    (hk : ∀ᵐ t ∂μ, 0 < kernel t)
    (hx : ∀ᵐ t ∂μ, 0 < x t ∧ x t < 1)
    (endpoint : Bool) (base : ℝ) {xs ys : List Bool}
    (hlen : xs.length = ys.length) (hne : xs ≠ ys)
    (hix : Integrable (fun t => kernel t * candidatePathEnumerator (x t) endpoint xs) μ)
    (hiy : Integrable (fun t => kernel t * candidatePathEnumerator (x t) endpoint ys) μ) :
    integratedEnumeratorCost μ kernel x endpoint base xs ≠
      integratedEnumeratorCost μ kernel x endpoint base ys := by
  rcases digitLexLt_or_reverse hlen hne with h | h
  · exact (integratedEnumeratorCost_strict μ hμ kernel x hk hx endpoint base
      hlen h hix hiy).ne'
  · exact (integratedEnumeratorCost_strict μ hμ kernel x hk hx endpoint base
      hlen.symm h hiy hix).ne

end NeuralGeneralization.OnlineLower
