import Paulsen.Linear.Balancing

/-!
# From a seed to an exact equal-norm Parseval frame

A `(Θ, t)`-seed for `X` is a Parseval frame `V` close to `X`, whose diagonal is
within `a t² / (2Θ)` of `a = d/n` and whose squared-Gram graph has barrier
constant at most `Θ / (a t²)`. Static balancing turns it into an equal-norm
Parseval frame at cost `O(Θ t² d)`.
-/

namespace Paulsen.Linear

open Paulsen
open scoped BigOperators

/-- The seed predicate. -/
structure IsSeed {n d : ℕ} (X V : Frame n d) (Θ t : ℝ) : Prop where
  parseval : IsParseval V
  dist : sqDistance X V ≤ Θ * t ^ 2 * (d : ℝ)
  barrier : FrameBarrierBound V (Θ / ((d : ℝ) / n * t ^ 2))
  diag : ∀ i, |(d : ℝ) / n - rowNormSq V i| ≤ (d : ℝ) / n * t ^ 2 / (2 * Θ)

/-- A seed yields an equal-norm Parseval frame within `4 Θ t² d`. -/
theorem IsSeed.hasCorrection {n d : ℕ} {X V : Frame n d} {Θ t : ℝ}
    (hd : 0 < d) (hdn : d ≤ n) (hΘ : 2 ≤ Θ) (ht : 0 < t)
    (hs : IsSeed X V Θ t) :
    HasCorrection X (4 * Θ * t ^ 2 * (d : ℝ)) := by
  have hn : 0 < n := lt_of_lt_of_le hd hdn
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hdR : (0 : ℝ) < d := by exact_mod_cast hd
  set a : ℝ := (d : ℝ) / n with ha
  have ha0 : 0 < a := by positivity
  have hΘ0 : 0 < Θ := by linarith
  set β : ℝ := a * t ^ 2 / (2 * Θ) with hβ
  have hβ0 : 0 ≤ β := by positivity
  have hsmall : β * (Θ / (a * t ^ 2)) ≤ 1 / 2 := by
    have : β * (Θ / (a * t ^ 2)) = 1 / 2 := by
      rw [hβ]; field_simp
    rw [this]
  obtain ⟨W, hW, hVW⟩ := balancing_cost_barrier hn hdn V hs.parseval β
    (Θ / (a * t ^ 2)) hs.diag hs.barrier hβ0 hsmall
  refine ⟨W, hW, ?_⟩
  have hsum : (∑ i, |(d : ℝ) / n - rowNormSq V i|) ≤ (n : ℝ) * β := by
    calc (∑ i, |(d : ℝ) / n - rowNormSq V i|) ≤ ∑ _i : Fin n, β :=
          Finset.sum_le_sum (fun i _ => hs.diag i)
      _ = (n : ℝ) * β := by simp
  have hnβ : (n : ℝ) * β = t ^ 2 * (d : ℝ) / (2 * Θ) := by
    rw [hβ, ha]; field_simp
  have htri := sqDistance_triangle X V W
  have hcost : sqDistance V W ≤ 8 * (t ^ 2 * (d : ℝ) / (2 * Θ)) := by
    rw [← hnβ]; linarith
  have h2 : 8 * (t ^ 2 * (d : ℝ) / (2 * Θ)) ≤ 2 * t ^ 2 * (d : ℝ) := by
    rw [show 8 * (t ^ 2 * (d : ℝ) / (2 * Θ)) = (4 / Θ) * (t ^ 2 * d) by field_simp; ring]
    have : 4 / Θ ≤ 2 := by rw [div_le_iff₀ hΘ0]; linarith
    nlinarith [mul_nonneg (sq_nonneg t) hdR.le]
  have hX := hs.dist
  nlinarith [mul_nonneg (sq_nonneg t) hdR.le]

end Paulsen.Linear
