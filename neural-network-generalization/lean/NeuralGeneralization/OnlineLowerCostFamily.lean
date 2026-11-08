import NeuralGeneralization.OnlineLowerCostIntegral
import Mathlib.Data.List.OfFn
import Mathlib.Data.Fintype.BigOperators

/-!+# Exponentially many distinct integrated path costs

This is an explicit binary family, not an assumed collection of separated
costs. The only analytic inputs are positivity and integrability of the
common kernel representing the scalar weight.
-/

noncomputable section
open MeasureTheory

namespace NeuralGeneralization.OnlineLower

def binaryPathCost {α : Type*} [MeasurableSpace α]
    (μ : Measure α) (kernel x : α → ℝ) (endpoint : Bool) (base : ℝ)
    (k : ℕ) (digits : Fin k → Bool) : ℝ :=
  integratedEnumeratorCost μ kernel x endpoint base (List.ofFn digits)

theorem binaryPathCost_injective {α : Type*} [MeasurableSpace α]
    (μ : Measure α) (hμ : μ ≠ 0) (kernel x : α → ℝ)
    (hk : ∀ᵐ t ∂μ, 0 < kernel t)
    (hx : ∀ᵐ t ∂μ, 0 < x t ∧ x t < 1)
    (endpoint : Bool) (base : ℝ) (k : ℕ)
    (hint : ∀ digits : Fin k → Bool,
      Integrable (fun t => kernel t *
        candidatePathEnumerator (x t) endpoint (List.ofFn digits)) μ) :
    Function.Injective (binaryPathCost μ kernel x endpoint base k) := by
  intro ds es he
  by_contra hne
  have hlist : List.ofFn ds ≠ List.ofFn es := fun h => hne (List.ofFn_injective h)
  exact integratedEnumeratorCost_ne_of_ne μ hμ kernel x hk hx endpoint base
    (by simp) hlist (hint ds) (hint es) he

theorem binaryPathCost_card {α : Type*} [MeasurableSpace α]
    (μ : Measure α) (hμ : μ ≠ 0) (kernel x : α → ℝ)
    (hk : ∀ᵐ t ∂μ, 0 < kernel t)
    (hx : ∀ᵐ t ∂μ, 0 < x t ∧ x t < 1)
    (endpoint : Bool) (base : ℝ) (k : ℕ)
    (hint : ∀ digits : Fin k → Bool,
      Integrable (fun t => kernel t *
        candidatePathEnumerator (x t) endpoint (List.ofFn digits)) μ) :
    (Finset.univ.image (binaryPathCost μ kernel x endpoint base k)).card = 2 ^ k := by
  classical
  rw [Finset.card_image_of_injective _
    (binaryPathCost_injective μ hμ kernel x hk hx endpoint base k hint)]
  simp

end NeuralGeneralization.OnlineLower
