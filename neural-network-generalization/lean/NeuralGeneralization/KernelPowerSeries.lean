import NeuralGeneralization.KernelSpectrum
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Topology.Algebra.Ring.Real

/-!
# From nonnegative power series to biased-kernel eigenvalues

The finite power spectrum is proved in `KernelSpectrum`. This module
passes those exact bounds to a scalar function given as a convergent
power series on the finite biased-dot-product grid. Convergence and
coefficient signs are analytic inputs, not assumptions on the spectrum.
The arcsine power-series formula and its sharp asymptotics are not proved
here and must still be supplied before specializing to the neural kernel.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators Topology
open Filter

variable {d : ℕ}

theorem walshCoefficients_tendsto (P : ℕ → ClippingCube d → ℝ)
    (Q : ClippingCube d → ℝ)
    (h : ∀ x, Tendsto (fun n => P n x) atTop (𝓝 (Q x))) (S : Finset (Fin d)) :
    Tendsto (fun n => walshCoefficients (P n) S) atTop (𝓝 (walshCoefficients Q S)) := by
  unfold walshCoefficients uniformCubeMean
  apply Filter.Tendsto.div_const
  apply tendsto_finsetSum
  intro x hx
  exact Filter.Tendsto.mul_const _ (h x)

/-- Only convergence on the finite cube grid is required. -/
def BiasedGridPowerSeries (F : ℝ → ℝ) (c : ℕ → ℝ) : Prop :=
  ∀ x : ClippingCube d, Tendsto
    (fun N => ∑ m ∈ Finset.range N, c m *
      ((1 + ∑ i, cubeCoordinateSign (x i)) / (d + 1 : ℝ)) ^ m)
    atTop (𝓝 (biasedProfile F x))

theorem biasedDot_series_coefficient_nonneg (F : ℝ → ℝ) (c : ℕ → ℝ)
    (hc : ∀ m, 0 ≤ c m) (hseries : BiasedGridPowerSeries (d := d) F c)
    (S : Finset (Fin d)) : 0 ≤ walshCoefficients (biasedProfile F) S := by
  have hlim := walshCoefficients_tendsto
    (fun N => biasedProfile (fun t => ∑ m ∈ Finset.range N, c m * t ^ m))
    (biasedProfile F) hseries S
  apply ge_of_tendsto hlim
  exact Eventually.of_forall (fun N => biasedDot_polynomial_coefficient_nonneg
    (Finset.range N) c (fun m hm => hc m) S)

theorem biasedDot_series_coefficient_lower (F : ℝ → ℝ) (c : ℕ → ℝ)
    (hc : ∀ m, 0 ≤ c m) (hseries : BiasedGridPowerSeries (d := d) F c)
    (S : Finset (Fin d)) (n : ℕ) :
    c (d + n) / (d + 1 : ℝ) ^ (d + n) ≤ walshCoefficients (biasedProfile F) S := by
  have hlim := walshCoefficients_tendsto
    (fun N => biasedProfile (fun t => ∑ m ∈ Finset.range N, c m * t ^ m))
    (biasedProfile F) hseries S
  apply ge_of_tendsto hlim
  apply (eventually_ge_atTop (d + n + 1)).mono
  intro N hN
  exact biasedDot_polynomial_coefficient_lower (Finset.range N) c
    (fun m hm => hc m) S n (Finset.mem_range.mpr (by omega))

/-- Strict positivity follows from one positive power coefficient beyond
`d`, even when all even coefficients vanish. -/
theorem biasedDot_series_coefficient_pos (F : ℝ → ℝ) (c : ℕ → ℝ)
    (hc : ∀ m, 0 ≤ c m) (hseries : BiasedGridPowerSeries (d := d) F c)
    (n : ℕ) (hpos : 0 < c (d + n)) (S : Finset (Fin d)) :
    0 < walshCoefficients (biasedProfile F) S := by
  have hD : 0 < (d + 1 : ℝ) ^ (d + n) := by positivity
  exact (div_pos hpos hD).trans_le (biasedDot_series_coefficient_lower F c hc hseries S n)

end NeuralGeneralization
