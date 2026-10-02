import Paulsen.Definitions
import Mathlib.Topology.Instances.Matrix
import Mathlib.Topology.Order.OrderClosed
import Mathlib.Topology.Algebra.Ring.Real
import Mathlib.Algebra.BigOperators.Field
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.FunProp
import Mathlib.Tactic.FieldSimp

/-!
# Stability of nearly Parseval inequalities

Entrywise continuity of the Gram matrix gives a uniform quadratic-form
estimate. This handles perturbations without continuity of eigenvalues.
-/

namespace Paulsen

open Filter
open scoped BigOperators Topology

/-- Uniform entrywise control of two Gram matrices controls every frame
energy, with the elementary dimension factor. -/
theorem frameEnergy_sub_le_of_gram_entries {n d : ℕ}
    (X Y : Frame n d) (τ : ℝ) (hτ : 0 ≤ τ)
    (hgram : ∀ j k : Fin d,
      |(∑ i, Y i j * Y i k) - ∑ i, X i j * X i k| ≤ τ)
    (x : Fin d → ℝ) :
    |frameEnergy Y x - frameEnergy X x| ≤ τ * (d : ℝ) * vectorNormSq x := by
  have hid : frameEnergy Y x - frameEnergy X x =
      ∑ j, ∑ k, ((∑ i, Y i j * Y i k) - ∑ i, X i j * X i k) * x j * x k := by
    simp only [frameEnergy_eq_sum_gram, Finset.sum_sub_distrib, sub_mul]
  rw [hid]
  calc
    |∑ j, ∑ k, ((∑ i, Y i j * Y i k) - ∑ i, X i j * X i k) * x j * x k| ≤
        ∑ j, ∑ k, τ * (x j ^ 2 + x k ^ 2) / 2 := by
      apply le_trans (Finset.abs_sum_le_sum_abs _ _)
      apply Finset.sum_le_sum
      intro j _
      apply le_trans (Finset.abs_sum_le_sum_abs _ _)
      apply Finset.sum_le_sum
      intro k _
      rw [abs_mul, abs_mul]
      have hp : |x j| * |x k| ≤ (x j ^ 2 + x k ^ 2) / 2 := by
        nlinarith [sq_nonneg (|x j| - |x k|), sq_abs (x j), sq_abs (x k)]
      calc
        |(∑ i, Y i j * Y i k) - ∑ i, X i j * X i k| * |x j| * |x k| ≤
            τ * (|x j| * |x k|) := by
          nlinarith [mul_le_mul_of_nonneg_right (hgram j k)
            (mul_nonneg (abs_nonneg (x j)) (abs_nonneg (x k)))]
        _ ≤ τ * (x j ^ 2 + x k ^ 2) / 2 := by
          nlinarith [mul_le_mul_of_nonneg_left hp hτ]
    _ = τ * (d : ℝ) * vectorNormSq x := by
      simp only [mul_add, add_div, Finset.sum_add_distrib,
        ← Finset.sum_div, ← Finset.mul_sum, Finset.sum_const,
        Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, vectorNormSq]
      ring

/-- Increasing the allowed error makes nearly Parseval inequalities stable
under sufficiently small perturbations. -/
theorem IsNearlyParseval.eventually_near {n d : ℕ} {η η' : ℝ}
    {X : Frame n d} (hX : IsNearlyParseval η X) (hη : η < η') :
    ∀ᶠ Y : Frame n d in 𝓝 X, IsNearlyParseval η' Y := by
  let τ := (η' - η) / ((d : ℝ) + 1)
  have hd : 0 < (d : ℝ) + 1 := by positivity
  have hτ : 0 < τ := div_pos (sub_pos.mpr hη) hd
  have hgram : ∀ᶠ Y : Frame n d in 𝓝 X, ∀ j k : Fin d,
      |(∑ i, Y i j * Y i k) - ∑ i, X i j * X i k| ≤ τ := by
    apply eventually_all.mpr
    intro j
    apply eventually_all.mpr
    intro k
    have hc : Continuous (fun Y : Frame n d =>
        |(∑ i, Y i j * Y i k) - ∑ i, X i j * X i k|) := by fun_prop
    have ht : Tendsto (fun Y : Frame n d =>
        |(∑ i, Y i j * Y i k) - ∑ i, X i j * X i k|) (𝓝 X) (𝓝 0) := by
      simpa using hc.tendsto X
    exact (ht.eventually_lt_const hτ).mono fun _ h => le_of_lt h
  filter_upwards [hgram] with Y hY
  intro x
  have hdist := frameEnergy_sub_le_of_gram_entries X Y τ (le_of_lt hτ) hY x
  have hscale : τ * (d : ℝ) ≤ η' - η := by
    have heq : τ * ((d : ℝ) + 1) = η' - η := by
      dsimp only [τ]
      exact div_mul_cancel₀ _ (ne_of_gt hd)
    nlinarith
  have hb := mul_le_mul_of_nonneg_right hscale (vectorNormSq_nonneg x)
  obtain ⟨hlo, hhi⟩ := abs_le.mp (hdist.trans hb)
  obtain ⟨hXlo, hXhi⟩ := hX x
  constructor <;> nlinarith

/-- Filter formulation of nearly Parseval stability, suitable for generic
approximating families and sequences. -/
theorem IsNearlyParseval.eventually_of_tendsto {n d : ℕ} {η η' : ℝ}
    {X : Frame n d} (hX : IsNearlyParseval η X) (hη : η < η')
    {α : Type*} {l : Filter α} {F : α → Frame n d}
    (hF : Tendsto F l (𝓝 X)) :
    ∀ᶠ a in l, IsNearlyParseval η' (F a) :=
  hF.eventually (hX.eventually_near hη)

end Paulsen
