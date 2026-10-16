import Mathlib.Topology.Algebra.InfiniteSum.Real
import Mathlib.Topology.Order.LeftRightNhds
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Algebra.Order.BigOperators.Group.Finset

/-!
# Endpoint convergence of a nonnegative power series

No summability at the endpoint is assumed. Finite partial sums are bounded by
the endpoint limit, which proves summability; the opposite inequality follows
by bounding every interior series by its endpoint coefficient sum.
-/

noncomputable section

namespace NeuralGeneralization

open Filter
open scoped BigOperators Topology

/-- An interior nonnegative power series extends to its finite left limit at
one. The natural exponents may be arbitrary, covering both ordinary and odd
power series. Endpoint summability is a conclusion. -/
theorem hasSum_nonnegative_powerSeries_endpoint
    (a : ℕ → ℝ) (e : ℕ → ℕ) (F : ℝ → ℝ)
    (ha : ∀ n, 0 ≤ a n)
    (hseries : ∀ x : ℝ, 0 ≤ x → x < 1 →
      HasSum (fun n => a n * x ^ e n) (F x))
    (hlimit : Tendsto F (𝓝[<] (1 : ℝ)) (𝓝 (F 1))) :
    HasSum a (F 1) := by
  have hinside : ∀ᶠ x in 𝓝[<] (1 : ℝ), 0 ≤ x ∧ x < 1 := by
    apply mem_nhdsLT_iff_exists_Ioo_subset.mpr
    exact ⟨0, (show (0 : ℝ) < 1 from zero_lt_one), fun _ hx => ⟨hx.1.le, hx.2⟩⟩
  have hpartial : ∀ s : Finset ℕ, ∑ n ∈ s, a n ≤ F 1 := by
    intro s
    have hlim : Tendsto (fun x : ℝ => ∑ n ∈ s, a n * x ^ e n)
        (𝓝[<] (1 : ℝ)) (𝓝 (∑ n ∈ s, a n)) := by
      simpa using ((continuous_finsetSum s (fun n _ =>
        continuous_const.mul (continuous_id.pow (e n)))).tendsto (1 : ℝ)).mono_left
          nhdsWithin_le_nhds
    apply le_of_tendsto_of_tendsto hlim hlimit
    filter_upwards [hinside] with x hx
    have hh := (hseries x hx.1 hx.2).summable.sum_le_tsum s
      (fun n _ => mul_nonneg (ha n) (pow_nonneg hx.1 _))
    rwa [(hseries x hx.1 hx.2).tsum_eq] at hh
  have hsum : Summable a := summable_of_sum_le ha hpartial
  have hupper : (∑' n, a n) ≤ F 1 := hsum.tsum_le_of_sum_le hpartial
  have hlower : F 1 ≤ ∑' n, a n := by
    apply le_of_tendsto hlimit
    filter_upwards [hinside] with x hx
    rw [← (hseries x hx.1 hx.2).tsum_eq]
    exact (hseries x hx.1 hx.2).summable.tsum_le_tsum
      (fun n => by
        have hp : x ^ e n ≤ 1 := pow_le_one₀ hx.1 hx.2.le
        simpa using mul_le_mul_of_nonneg_left hp (ha n)) hsum
  exact (le_antisymm hupper hlower) ▸ hsum.hasSum

end NeuralGeneralization
