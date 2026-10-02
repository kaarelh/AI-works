import Paulsen.TangentSeed
import Paulsen.Energy

/-!
# A contraction estimate for normalized tangent seeds

Radial normalization to a fixed sphere does not increase distance between
points outside that sphere. Applied row by row, this improves the elementary
factor-four squared-distance estimate to constant one.
-/

namespace Paulsen

open scoped BigOperators

theorem vectorNormSq_scaled_sub {d : ℕ} (u v : Fin d → ℝ) (s t : ℝ) :
    vectorNormSq (fun j => s * u j - t * v j) =
      s ^ 2 * vectorNormSq u + t ^ 2 * vectorNormSq v -
        2 * s * t * ∑ j, u j * v j := by
  simp only [vectorNormSq, Finset.mul_sum, ← Finset.sum_add_distrib,
    ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro j _
  ring

/-- Expanding two vectors of the same norm by factors at least one cannot
decrease their Euclidean distance. -/
theorem vectorNormSq_sub_le_scaled_sub {d : ℕ}
    (u v : Fin d → ℝ) (a s t : ℝ)
    (hu : vectorNormSq u = a) (hv : vectorNormSq v = a)
    (hs : 1 ≤ s) (ht : 1 ≤ t) :
    vectorNormSq (fun j => u j - v j) ≤
      vectorNormSq (fun j => s * u j - t * v j) := by
  have ha : 0 ≤ a := hu ▸ vectorNormSq_nonneg u
  have hdiff : vectorNormSq (fun j => u j - v j) =
      2 * a - 2 * ∑ j, u j * v j := by
    simpa [hu, hv, two_mul] using vectorNormSq_scaled_sub u v 1 1
  have hdot : 0 ≤ a - ∑ j, u j * v j := by
    have h := vectorNormSq_nonneg (fun j => u j - v j)
    rw [hdiff] at h
    linarith
  have hst : 0 ≤ s * t - 1 := by nlinarith
  rw [hdiff, vectorNormSq_scaled_sub, hu, hv]
  have h1 := mul_nonneg ha (sq_nonneg (s - t))
  have h2 := mul_nonneg hst hdot
  nlinarith

theorem tangent_sqrt_denominator_ge_one {n d : ℕ}
    (Z : Frame n d) (a t : ℝ) (ha : 0 < a) (i : Fin n) :
    1 ≤ Real.sqrt (1 + t ^ 2 * tangentRatio a Z i) := by
  have h := mul_nonneg (sq_nonneg t) (tangentRatio_nonneg a ha Z i)
  have hs := Real.sqrt_le_sqrt (show (1 : ℝ) ≤ 1 + t ^ 2 * tangentRatio a Z i by linarith)
  simpa using hs

/-- The map from tangent noise to the equal-row seed has Lipschitz constant
|t| in Frobenius norm, even for unbounded tangent rows. -/
theorem tangentSeed_sqDistance_le {n d : ℕ}
    (X Z Z' : Frame n d) (a t : ℝ) (ha : 0 < a)
    (hx : ∀ i, rowNormSq X i = a)
    (hz : ∀ i, rowDot X Z i = 0) (hz' : ∀ i, rowDot X Z' i = 0) :
    sqDistance (tangentSeed X Z a t) (tangentSeed X Z' a t) ≤
      t ^ 2 * sqDistance Z Z' := by
  unfold sqDistance
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  let s := Real.sqrt (1 + t ^ 2 * tangentRatio a Z i)
  let r := Real.sqrt (1 + t ^ 2 * tangentRatio a Z' i)
  have hs : 0 < s := Real.sqrt_pos.mpr (tangent_denominator_pos a t ha Z i)
  have hr : 0 < r := Real.sqrt_pos.mpr (tangent_denominator_pos a t ha Z' i)
  have hu : vectorNormSq (tangentSeed X Z a t i) = a :=
    tangentSeed_rowNormSq X Z a t ha i (hx i) (hz i)
  have hv : vectorNormSq (tangentSeed X Z' a t i) = a :=
    tangentSeed_rowNormSq X Z' a t ha i (hx i) (hz' i)
  have h := vectorNormSq_sub_le_scaled_sub
    (tangentSeed X Z a t i) (tangentSeed X Z' a t i) a s r hu hv
    (tangent_sqrt_denominator_ge_one Z a t ha i)
    (tangent_sqrt_denominator_ge_one Z' a t ha i)
  have hentry (j : Fin d) :
      s * tangentSeed X Z a t i j - r * tangentSeed X Z' a t i j =
        t * (Z i j - Z' i j) := by
    change s * ((X i j + t * Z i j) / s) -
      r * ((X i j + t * Z' i j) / r) = _
    field_simp
    ring
  simp_rw [hentry] at h
  simpa only [vectorNormSq, mul_pow, Finset.mul_sum] using h

@[simp] theorem tangentSeed_zero_noise {n d : ℕ} (X : Frame n d) (a t : ℝ) :
    tangentSeed X 0 a t = X := by
  ext i j
  simp [tangentSeed, tangentRatio, rowNormSq]

/-- The tangent seed itself costs at most t² times the total noise energy. -/
theorem tangentSeed_distance_from_input {n d : ℕ}
    (X Z : Frame n d) (a t : ℝ) (ha : 0 < a)
    (hx : ∀ i, rowNormSq X i = a) (hz : ∀ i, rowDot X Z i = 0) :
    sqDistance (tangentSeed X Z a t) X ≤ t ^ 2 * ∑ i, rowNormSq Z i := by
  simpa [sqDistance, rowNormSq] using
    tangentSeed_sqDistance_le X Z 0 a t ha hx hz (by simp [rowDot])

/-- Row normalization contracts every frame energy relative to the raw
perturbation. The denominator is always at least one. -/
theorem frameEnergy_tangentSeed_le_perturbed {n d : ℕ}
    (X Z : Frame n d) (a t : ℝ) (ha : 0 < a) (x : Fin d → ℝ) :
    frameEnergy (tangentSeed X Z a t) x ≤ frameEnergy (X + t • Z) x := by
  unfold frameEnergy
  apply Finset.sum_le_sum
  intro i _
  have hden := tangent_denominator_pos a t ha Z i
  have hge : 1 ≤ 1 + t ^ 2 * tangentRatio a Z i := by
    have h := mul_nonneg (sq_nonneg t) (tangentRatio_nonneg a ha Z i)
    linarith
  have heq : (∑ j, tangentSeed X Z a t i j * x j) =
      (∑ j, (X + t • Z) i j * x j) / Real.sqrt (1 + t ^ 2 * tangentRatio a Z i) := by
    simp only [tangentSeed, Matrix.of_apply, Matrix.add_apply, Matrix.smul_apply,
      smul_eq_mul, div_eq_mul_inv]
    rw [Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro j _
    ring
  rw [heq, div_pow, Real.sq_sqrt hden.le]
  apply (div_le_iff₀ hden).mpr
  exact le_mul_of_one_le_right (sq_nonneg _) hge

/-- A coarse operator bound for the independent tangent seed needs only
total noise energy; it does not require its normalized-row covariance. -/
theorem frameEnergy_tangentSeed_le {n d : ℕ}
    (X Z : Frame n d) (a t η : ℝ) (ha : 0 < a) (hX : IsNearlyParseval η X)
    (x : Fin d → ℝ) :
    frameEnergy (tangentSeed X Z a t) x ≤
      (2 * (1 + η) + 2 * t ^ 2 * ∑ i, rowNormSq Z i) * vectorNormSq x := by
  have hsum : frameEnergy (X + t • Z) x ≤
      2 * frameEnergy X x + 2 * t ^ 2 * frameEnergy Z x := by
    simp only [frameEnergy, Matrix.add_apply, Matrix.smul_apply, smul_eq_mul,
      add_mul, Finset.sum_add_distrib, mul_assoc, ← Finset.mul_sum]
    simp only [Finset.mul_sum, ← Finset.sum_add_distrib]
    apply Finset.sum_le_sum
    intro i _
    simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
    nlinarith [sq_nonneg ((∑ j, X i j * x j) - t * ∑ j, Z i j * x j)]
  have hZ := frameEnergy_le_total_energy Z x
  have hZt := mul_le_mul_of_nonneg_left hZ (show 0 ≤ 2 * t ^ 2 by positivity)
  apply (frameEnergy_tangentSeed_le_perturbed X Z a t ha x).trans (hsum.trans _)
  nlinarith [(hX x).2]

end Paulsen
