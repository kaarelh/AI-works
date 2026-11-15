import NeuralGeneralization.OnlineLowerTanhCostSigns

/-!
# The optimized tanh cost expansion as one unconditional paper endpoint

The analytic branch, its identification with the literal optimized balanced
cost, the positive coefficients and the derivative estimates are already
proved in the imported development. This module assembles all clauses of the
paper's optimized-cost-expansion theorem without a caller-supplied branch or
analytic certificate. The bounds share one threshold and one error constant.
-/

noncomputable section
open Complex Set
namespace NeuralGeneralization.OnlineLowerTanh

/-- The paper's holomorphic cost interpolation, uniform quadratic remainder,
exact odd-degree values, and second-derivative expansion, with positive
linear and reciprocal-degree coefficients. -/
theorem optimized_cost_expansion_paper :
    let w : ℂ → ℂ := holomorphicOptimizedCost actualGainBranch
    ∃ T K : ℝ, 2 ≤ T ∧ 0 < K ∧
      0 < optimizedCostSlope ∧ 0 < optimizedCostCurvature ∧
      DifferentiableOn ℂ w {z : ℂ | 0 < z.re ∧ T < ‖z‖} ∧
      (∀ z : ℂ, 0 < z.re → T < ‖z‖ →
        ‖w z - ((optimizedCostSlope : ℂ) * z +
          (optimizedCostIntercept : ℂ) + (optimizedCostCurvature : ℂ) / z)‖ ≤
            K / ‖z‖ ^ 2) ∧
      (∀ r : ℕ, T < (2 * r + 1 : ℕ) → w (2 * r + 1 : ℕ) = (balancedCost r : ℂ)) ∧
      (∀ u : ℝ, 3 * T < u →
        |iteratedDeriv 2 (fun x : ℝ => (w x).re) u -
          2 * optimizedCostCurvature / u ^ 3| ≤ 24 * K / u ^ 4) := by
  dsimp only
  obtain ⟨T₀, K₀, hT₀, hK₀, hb₀, ha₀, he₀⟩ :=
    holomorphicOptimizedCost_uniform_expansion actualGainBranch
  obtain ⟨T₁, K₁, hT₁, hK₁, _, ha₁, he₁⟩ :=
    optimizedCostRemainder_all_derivative_bounds actualGainBranch
  refine ⟨max T₀ T₁, max K₀ K₁, hT₀.trans (le_max_left _ _),
    hK₀.trans_le (le_max_left _ _), optimizedCostSlope_pos,
    optimizedCostCurvature_pos, ?_, ?_, ?_, ?_⟩
  · exact ha₀.mono (fun z hz => ⟨hz.1, (le_max_left _ _).trans_lt hz.2⟩)
  · intro z hz hnorm
    exact (he₀ z hz ((le_max_left _ _).trans_lt hnorm)).trans
      (div_le_div_of_nonneg_right (le_max_left _ _) (sq_nonneg _))
  · intro r hr
    exact holomorphicOptimizedCost_odd actualGainBranch r
      ((hb₀.trans (le_max_left _ _)).trans_lt hr)
  · intro u hu
    have hu₁ : (2 + 1 : ℕ) * T₁ < u := by
      have hle := le_max_right T₀ T₁
      norm_num
      linarith
    have h := optimizedRealCost_derivative_error actualGainBranch T₁ K₁ hT₁ ha₁
      2 (by norm_num) u hu₁ (he₁ 2 (by norm_num) u hu₁)
    have hh : |iteratedDeriv 2 (optimizedRealCost actualGainBranch) u -
        2 * optimizedCostCurvature / u ^ 3| ≤ 24 * K₁ / u ^ 4 := by
      convert h using 1 <;> norm_num <;> ring_nf
    exact hh.trans (div_le_div_of_nonneg_right
      (mul_le_mul_of_nonneg_left (le_max_right K₀ K₁) (by norm_num)) (by positivity))

/-- The real odd-degree expansion of the actual optimized balanced costs,
with an explicit uniform error bound rather than an unspecified asymptotic. -/
theorem balanced_cost_expansion_paper :
    ∃ T K : ℝ, 2 ≤ T ∧ 0 < K ∧
      0 < optimizedCostCurvature ∧ ∀ r : ℕ, T < (2 * r + 1 : ℕ) →
        |balancedCost r - (optimizedCostSlope * (2 * r + 1 : ℕ) +
          optimizedCostIntercept + optimizedCostCurvature / (2 * r + 1 : ℕ))| ≤
            K / (2 * r + 1 : ℕ) ^ 2 := by
  obtain ⟨T, K, hT, hK, _, hC, _, he, hodd, _⟩ := optimized_cost_expansion_paper
  refine ⟨T, K, hT, hK, hC, ?_⟩
  intro r hr
  have hn : (0 : ℝ) < (2 * r + 1 : ℕ) := by positivity
  have hnorm : ‖((2 * r + 1 : ℕ) : ℂ)‖ = ((2 * r + 1 : ℕ) : ℝ) := by
    rw [Complex.norm_natCast]
  have h := he ((2 * r + 1 : ℕ) : ℂ) (by simpa using hn) (by rw [hnorm]; exact hr)
  rw [hodd r hr] at h
  have hc : (balancedCost r : ℂ) -
      ((optimizedCostSlope : ℂ) * (2 * r + 1 : ℕ) +
        (optimizedCostIntercept : ℂ) + (optimizedCostCurvature : ℂ) / (2 * r + 1 : ℕ)) =
      ((balancedCost r - (optimizedCostSlope * (2 * r + 1 : ℕ) +
        optimizedCostIntercept + optimizedCostCurvature / (2 * r + 1 : ℕ)) : ℝ) : ℂ) := by
    push_cast
    rfl
  simpa only [hc, Complex.norm_real, Real.norm_eq_abs, hnorm] using h

end NeuralGeneralization.OnlineLowerTanh
