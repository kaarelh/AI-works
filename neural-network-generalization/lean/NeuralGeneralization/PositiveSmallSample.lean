import NeuralGeneralization.SmallSampleParity
import NeuralGeneralization.NetworkSubcriticalConfidence
import NeuralGeneralization.ParityModelBridge

/-! Actual neural posterior confidence in the small-sample regime from a
polynomial-energy global comparator. The argument covers every tied global
minimizer and applies the proved positive-subcritical rate law. -/
noncomputable section
open Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.PositiveSmallSample
open ConcreteModel WalshMarginMinimizers SmallSampleCutoff NetworkSubcriticalConfidence

/-- No sample coercivity or matrix-tail event is needed in this regime:
a polynomial-energy feasible global comparator already forces all posterior
minimizers to have parity error at least three eighths. -/
theorem eventually_confidence_liminf_of_polynomial_comparator
    (C : ℝ) (hC : 0 ≤ C) (m : ℕ) (a : ℝ) (ha : 0 < a) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℕ, (n : ℝ) ≤ Real.exp (logDimension d^3) →
      ∀ r : ℕ, ∀ s : Fin n → Cube d,
      (∃ c₀ ∈ globalTrainingMarginSet a (parity d) s,
        featureEnergy (walshCoefficients (arcsineProfile d (r+1))) c₀ ≤
          C*((d : ℝ)+1)^m*(1+(n : ℝ))) →
      ∀ γ : ℝ, 0 < γ → γ < 1 →
      (1/16 : ℝ) ≤ Filter.liminf (fun N => ConcreteModel.confidenceFailure (uniformLaw d) (parity d)
        (networkPosterior Real.tanh a (powerPrior d N r γ) (parity d) s)) atTop := by
  filter_upwards [eventually_margin_parity_error C hC m a ha (1/8) (by norm_num),
    eventually_ge_atTop 1] with d hd hd1 n hn r s hcomp γ hγ0 hγ1
  apply confidence_liminf_of_hard_global_minimizers (by omega) r hγ0 hγ1 ha (uniformLaw d) (parity d) s
  intro c hc hmin
  obtain ⟨c₀, hc₀, hE⟩ := hcomp
  rw [functionError_parity_eq]
  have henergy : finiteQuadratic (walshPrecisionKernel
      (walshCoefficients (arcsineProfile d (r+1)))) (walshExpansion c) ≤
      C*((d : ℝ)+1)^m*(1+(n : ℝ)) := by
    rw [walshPrecision_energy_expansion _ _ (fun S => (iterated_arcsine_coefficient_pos d r S).ne')]
    exact (hmin c₀ hc₀).trans hE
  have hh := hd (n : ℝ) (Nat.cast_nonneg _) hn r (walshExpansion c) hc.1 henergy
  norm_num at hh ⊢
  exact hh

end NeuralGeneralization.PositiveSmallSample
