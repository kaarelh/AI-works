import NeuralGeneralization.OnlineLowerCostActual
import NeuralGeneralization.OnlineLowerBernsteinCost

/-! # Unconditional scalar cost separation for the actual ReLU parity cost -/

noncomputable section
open MeasureTheory Set
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower

open OnlineLowerBernstein

theorem relu_path_cost_ne_of_ne (n₀ : ℝ) (hn₀ : 1 < n₀) (endpoint : Bool)
    {xs ys : List Bool} (hlen : xs.length = ys.length) (hlarge : 2 ≤ xs.length)
    (hne : xs ≠ ys) :
    fixedCandidateCost n₀ gammaCost endpoint xs ≠
      fixedCandidateCost n₀ gammaCost endpoint ys := by
  let μ : Measure ℝ := volume.restrict (Ioi 0)
  have hμ : μ ≠ 0 := by simp [μ]
  have hρ : ∀ᵐ t ∂μ, 0 < reluCostDensity t :=
    Filter.Eventually.of_forall reluCostDensity_pos
  have ht : ∀ᵐ t ∂μ, 0 < t := by
    exact ae_restrict_mem measurableSet_Ioi
  exact fixedCandidateCost_ne_of_ne μ hμ n₀ reluCostSlope reluCostIntercept
    gammaCost reluCostDensity hρ ht
    (fun n hn => reluCostDensity_laplaceIntegrable (lt_of_lt_of_le hn₀ hn))
    (fun n hn => gammaCost_bernstein (lt_of_lt_of_le hn₀ hn))
    endpoint hlen hlarge hne

def reluBinaryPathCost (n₀ : ℝ) (endpoint : Bool) (k : ℕ) (digits : Fin k → Bool) : ℝ :=
  fixedCandidateCost n₀ gammaCost endpoint (List.ofFn digits)

theorem reluBinaryPathCost_injective (n₀ : ℝ) (hn₀ : 1 < n₀) (endpoint : Bool)
    (k : ℕ) (hk : 2 ≤ k) : Function.Injective (reluBinaryPathCost n₀ endpoint k) := by
  intro xs ys he
  by_contra hne
  exact relu_path_cost_ne_of_ne n₀ hn₀ endpoint (by simp) (by simpa using hk)
    (fun h => hne (List.ofFn_injective h)) he

theorem reluBinaryPathCost_card (n₀ : ℝ) (hn₀ : 1 < n₀) (endpoint : Bool)
    (k : ℕ) (hk : 2 ≤ k) :
    (Finset.univ.image (reluBinaryPathCost n₀ endpoint k)).card = 2 ^ k := by
  classical
  rw [Finset.card_image_of_injective _ (reluBinaryPathCost_injective n₀ hn₀ endpoint k hk)]
  simp

end NeuralGeneralization.OnlineLower
