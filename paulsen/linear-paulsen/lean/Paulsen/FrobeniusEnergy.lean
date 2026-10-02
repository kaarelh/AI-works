import Paulsen.SamplingFrames

/-!
# Frobenius covariance error and frame energy

Pair a Gram-matrix error with the rank-one matrix xxᵀ and apply
Cauchy-Schwarz. The resulting near-Parseval error has no dimension loss.
-/

namespace Paulsen

open scoped BigOperators

/-- The Frobenius norm of xxᵀ is exactly the squared Euclidean norm of x. -/
theorem vector_outer_norm {d : ℕ} (x : Fin d → ℝ) :
    ‖(WithLp.toLp 2 (fun p : Fin d × Fin d => x p.1 * x p.2) :
      EuclideanSpace ℝ (Fin d × Fin d))‖ = vectorNormSq x := by
  let X : Frame 1 d := Matrix.of (fun _ j => x j)
  have h := rowOuterVector_norm_sq X 0
  change ‖(WithLp.toLp 2 (fun p : Fin d × Fin d => x p.1 * x p.2) :
      EuclideanSpace ℝ (Fin d × Fin d))‖ ^ 2 = (vectorNormSq x) ^ 2 at h
  exact (sq_eq_sq₀ (norm_nonneg _) (vectorNormSq_nonneg x)).mp h

/-- A Frobenius bound on the Gram error controls the error of every frame energy. -/
theorem frameEnergy_sub_le_of_gram_frobenius {n m d : ℕ}
    (X : Frame n d) (Y : Frame m d)
    (E : EuclideanSpace ℝ (Fin d × Fin d))
    (hE : ∀ j k, E (j, k) = (Y.transpose * Y) j k - (X.transpose * X) j k)
    (x : Fin d → ℝ) :
    |frameEnergy Y x - frameEnergy X x| ≤ ‖E‖ * vectorNormSq x := by
  let xx : EuclideanSpace ℝ (Fin d × Fin d) :=
    WithLp.toLp 2 (fun p => x p.1 * x p.2)
  have heq : frameEnergy Y x - frameEnergy X x = inner ℝ E xx := by
    rw [frameEnergy_eq_sum_gram, frameEnergy_eq_sum_gram]
    simp only [PiLp.inner_apply, Real.inner_apply, xx,
      Fintype.sum_prod_type, hE, Matrix.mul_apply, Matrix.transpose_apply]
    simp only [sub_mul, Finset.sum_sub_distrib]
    congr 1 <;> apply Finset.sum_congr rfl <;> intro j _ <;>
      apply Finset.sum_congr rfl <;> intro k _ <;> ring
  rw [heq]
  have h := abs_real_inner_le_norm E xx
  rw [show ‖xx‖ = vectorNormSq x from vector_outer_norm x] at h
  exact h

/-- Near-Parseval inequalities are stable under a Frobenius Gram perturbation,
with the norm of the perturbation added directly to the error parameter. -/
theorem IsNearlyParseval.of_gram_frobenius {n m d : ℕ}
    {X : Frame n d} {η : ℝ} (hX : IsNearlyParseval η X) (Y : Frame m d)
    (E : EuclideanSpace ℝ (Fin d × Fin d))
    (hE : ∀ j k, E (j, k) = (Y.transpose * Y) j k - (X.transpose * X) j k) :
    IsNearlyParseval (η + ‖E‖) Y := by
  intro x
  have herr := frameEnergy_sub_le_of_gram_frobenius X Y E hE x
  obtain ⟨hl, hu⟩ := abs_le.mp herr
  obtain ⟨hXl, hXu⟩ := hX x
  constructor <;> nlinarith

end Paulsen
