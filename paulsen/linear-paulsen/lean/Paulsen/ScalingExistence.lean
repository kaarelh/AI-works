import Paulsen.RadialExistence
import Paulsen.MedianBarrier
import Paulsen.Projection

/-!
# Exact balancing with a finite scaling barrier

Direct Cauchy--Binet minimization supplies exact balancing for full-spark frames. Its
right whitening disappears from the leverage formula, so the algebraic
median barrier bounds an existing scaling without analytic continuation.
-/

namespace Paulsen

open scoped BigOperators

/-- A square right multiplier making a rectangular matrix Parseval determines
the inverse Gram matrix. No separate invertibility assumption is needed. -/
theorem gram_inverse_of_parseval_right_mul {n d : ℕ}
    (Y : Frame n d) (M : Matrix (Fin d) (Fin d) ℝ)
    (hYM : IsParseval (Y * M)) :
    (Y.transpose * Y)⁻¹ = M * M.transpose := by
  apply Matrix.inv_eq_left_inv
  have h : (M.transpose * (Y.transpose * Y)) * M = 1 := by
    simpa only [IsParseval, Matrix.transpose_mul, Matrix.mul_assoc] using hYM
  have hc := mul_eq_one_comm.mpr h
  simpa only [Matrix.mul_assoc] using hc

/-- Right whitening identifies the Gram-inverse projection with the ordinary
projection of the whitened Parseval frame. -/
theorem columnSpaceProjection_eq_of_parseval_right_mul {n d : ℕ}
    (Y : Frame n d) (M : Matrix (Fin d) (Fin d) ℝ)
    (hYM : IsParseval (Y * M)) :
    columnSpaceProjection Y = frameProjection (Y * M) := by
  rw [columnSpaceProjection, gram_inverse_of_parseval_right_mul Y M hYM]
  simp only [frameProjection, Matrix.transpose_mul, Matrix.mul_assoc]

/-- Every full-spark frame can be balanced by positive squared row scales.
This is an existence theorem, with no target Paulsen bound as a hypothesis. -/
theorem exists_fullSpark_balanced_leverage {n d : ℕ}
    (hn : 0 < n) (hd : d ≤ n) (U : Frame n d) (hU : IsFullSpark U) :
    ∃ z : Fin n → ℝ, (∀ i, 0 < z i) ∧
      ∀ i, scaledLeverage U z i = (d : ℝ) / (n : ℝ) := by
  obtain ⟨r, hr, M, _hM, hW⟩ := exists_fullSpark_radial_scaling hn hd U hU
  refine ⟨fun i => r i ^ 2, fun i => sq_pos_of_pos (hr i), ?_⟩
  intro i
  rw [← rowScale_projection_diagonal,
    columnSpaceProjection_eq_of_parseval_right_mul (rowScale U r) M hW.1,
    frameProjection_diagonal]
  exact hW.2 i

/-- A full-spark Parseval frame admits exact balancing with a quantitative
ratio bound whenever its initial projection Laplacian has a bounded Poisson
solver and its diagonal error is sufficiently small. -/
theorem exists_fullSpark_balancing_ratio_bound {n d k : ℕ}
    (hn : 0 < n) (hd : d ≤ n) (U : Frame n d) (V : Frame n k)
    (hU_spark : IsFullSpark U) (hU : IsParseval U) (hV : IsParseval V)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (β K : ℝ)
    (herror : ∀ i, |(d : ℝ) / (n : ℝ) - (U * U.transpose) i i| ≤ β)
    (hsolve : BoundedPoissonSolvability (fun i j => ((U * U.transpose) i j) ^ 2) K)
    (hβ : 0 ≤ β) (hδ : 2 * β * K < 1) :
    ∃ z : Fin n → ℝ, (∀ i, 0 < z i) ∧
      (∀ i, scaledLeverage U z i = (d : ℝ) / (n : ℝ)) ∧
      ∀ i j, (1 - 2 * β * K) ^ 2 * z i ≤ z j := by
  letI : NeZero n := ⟨ne_of_gt hn⟩
  obtain ⟨z, hz, hbalance⟩ := exists_fullSpark_balanced_leverage hn hd U hU_spark
  refine ⟨z, hz, hbalance, ?_⟩
  apply diagonal_scaling_ratio_bound U V z β K hU hV hcomplete horth hz
    (fun i => ?_) hsolve hβ hδ
  rw [hbalance]
  exact herror i

/-- Logarithmic-coordinate version of exact full-spark balancing and its
oscillation bound. Existence follows from direct Cauchy--Binet minimization. -/
theorem exists_fullSpark_balancing_oscillation_bound {n d k : ℕ}
    (hn : 0 < n) (hd : d ≤ n) (U : Frame n d) (V : Frame n k)
    (hU_spark : IsFullSpark U) (hU : IsParseval U) (hV : IsParseval V)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (β K : ℝ)
    (herror : ∀ i, |(d : ℝ) / (n : ℝ) - (U * U.transpose) i i| ≤ β)
    (hsolve : BoundedPoissonSolvability (fun i j => ((U * U.transpose) i j) ^ 2) K)
    (hβ : 0 ≤ β) (hδ : 2 * β * K < 1) :
    ∃ s : Fin n → ℝ,
      (∀ i, scaledLeverage U (fun j => Real.exp (2 * s j)) i =
        (d : ℝ) / (n : ℝ)) ∧
      ∀ i j, s i - s j ≤ -Real.log (1 - 2 * β * K) := by
  letI : NeZero n := ⟨ne_of_gt hn⟩
  obtain ⟨z, hz, hbalance⟩ := exists_fullSpark_balanced_leverage hn hd U hU_spark
  let s : Fin n → ℝ := fun i => Real.log (z i) / 2
  have hscales : (fun i => Real.exp (2 * s i)) = z := by
    funext i
    dsimp only [s]
    rw [show 2 * (Real.log (z i) / 2) = Real.log (z i) by ring,
      Real.exp_log (hz i)]
  refine ⟨s, ?_, ?_⟩
  · simpa only [hscales] using hbalance
  · apply diagonal_scaling_oscillation_bound U V s β K hU hV hcomplete horth
      (fun i => ?_) hsolve hβ hδ
    rw [hscales, hbalance]
    exact herror i

end Paulsen
