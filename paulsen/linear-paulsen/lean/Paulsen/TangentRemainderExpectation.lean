import Paulsen.TangentRemainderBound
import Paulsen.GaussianRowMoments

/-! An explicit expectation and tail bound for the tangent remainder budget. -/

namespace Paulsen

open MeasureTheory ProbabilityTheory
open scoped BigOperators

noncomputable def tangentRemainderBudget {n d : ℕ} (Z : Frame n d) (a t : ℝ) : ℝ :=
  a * |t| ^ 3 * ((∑ i, tangentRatio a Z i) + ∑ i, (tangentRatio a Z i) ^ 2) +
    2 * a * t ^ 4 * ∑ i, (tangentRatio a Z i) ^ 2

theorem tangentRemainderBudget_nonneg {n d : ℕ} (Z : Frame n d)
    (a t : ℝ) (ha : 0 < a) : 0 ≤ tangentRemainderBudget Z a t := by
  have hsum : 0 ≤ ∑ i, tangentRatio a Z i :=
    Finset.sum_nonneg (fun i _ => tangentRatio_nonneg a ha Z i)
  unfold tangentRemainderBudget
  positivity

theorem tangentRemainder_le_budget {n d : ℕ} (X Z : Frame n d)
    (a t : ℝ) (ha : 0 < a) (hx : ∀ i, rowNormSq X i = a) (x : Fin d → ℝ) :
    |matrixQuadratic (tangentRemainder X Z a t) x| ≤
      tangentRemainderBudget Z a t * vectorNormSq x := by
  simpa only [tangentRemainderBudget, Finset.sum_add_distrib] using
    tangentRemainder_quadratic_bound X Z a t ha hx x

theorem integrable_tangentRemainderBudget_conditioned {n d : ℕ}
    (X : Frame n d) (hn : 0 < n) (hd : 0 < d) (t : ℝ) :
    Integrable (fun g : FrameVector n d => tangentRemainderBudget
      (frameOfVector (Matrix.toEuclideanLin (tangentNoiseFactor X) g)) ((d : ℝ) / n) t)
      (stdGaussian (FrameVector n d)) := by
  obtain ⟨h1, h2, _, _⟩ := tangentNoiseFactor_sum_moments X hn hd
  exact ((h1.add h2).const_mul _).add (h2.const_mul _)

/-- The nonlinear remainder budget has expectation at most
d(4|t|³+6t⁴), uniformly in the number of rows. -/
theorem integral_tangentRemainderBudget_conditioned_le {n d : ℕ}
    (X : Frame n d) (hn : 0 < n) (hd : 0 < d) (t : ℝ) :
    (∫ g : FrameVector n d, tangentRemainderBudget
      (frameOfVector (Matrix.toEuclideanLin (tangentNoiseFactor X) g)) ((d : ℝ) / n) t
      ∂stdGaussian (FrameVector n d)) ≤ (d : ℝ) * (4 * |t| ^ 3 + 6 * t ^ 4) := by
  obtain ⟨h1, h2, hb1, hb2⟩ := tangentNoiseFactor_sum_moments X hn hd
  have hnR : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.ne_of_gt hn)
  simp only [tangentRemainderBudget]
  erw [integral_add ((h1.add h2).const_mul (((d : ℝ) / n) * |t| ^ 3))
      (h2.const_mul (2 * ((d : ℝ) / n) * t ^ 4)),
    integral_const_mul, integral_const_mul, integral_add h1 h2]
  calc
    _ ≤ ((d : ℝ) / n) * |t| ^ 3 * ((n : ℝ) + 3 * n) +
        2 * ((d : ℝ) / n) * t ^ 4 * (3 * n) := by
      exact add_le_add (mul_le_mul_of_nonneg_left (add_le_add hb1 hb2) (by positivity))
        (mul_le_mul_of_nonneg_left hb2 (by positivity))
    _ = _ := by field_simp; ring

/-- Markov's inequality gives an explicit probability bound for this budget;
the deterministic bound controls every test vector on its complement. -/
theorem tangentRemainderBudget_conditioned_tail {n d : ℕ}
    (X : Frame n d) (hn : 0 < n) (hd : 0 < d) (t s : ℝ) (hs : 0 < s) :
    (stdGaussian (FrameVector n d)).real {g | s ≤ tangentRemainderBudget
      (frameOfVector (Matrix.toEuclideanLin (tangentNoiseFactor X) g)) ((d : ℝ) / n) t} ≤
      ((d : ℝ) * (4 * |t| ^ 3 + 6 * t ^ 4)) / s := by
  apply (le_div_iff₀ hs).mpr
  have h := mul_meas_ge_le_integral_of_nonneg
    (Filter.Eventually.of_forall (fun g => tangentRemainderBudget_nonneg _ _ t
      (div_pos (Nat.cast_pos.mpr hd) (Nat.cast_pos.mpr hn))))
    (integrable_tangentRemainderBudget_conditioned X hn hd t) s
  simpa only [mul_comm] using h.trans (integral_tangentRemainderBudget_conditioned_le X hn hd t)

end Paulsen
