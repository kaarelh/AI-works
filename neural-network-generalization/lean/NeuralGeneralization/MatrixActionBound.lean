import NeuralGeneralization.MatrixEnergyWitness

/-! # Exact conversion from Euclidean operator norm to coordinate action -/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators

lemma matrixOperator_apply {N : ℕ} (M : Fin N × Fin N → ℝ)
    (x : EuclideanN N) (i : Fin N) :
    matrixOperator M x i = ∑ j, M (i, j) * x j := rfl

lemma matrixOperator_sub {N : ℕ} (M H : Fin N × Fin N → ℝ) :
    matrixOperator (fun ij => M ij - H ij) = matrixOperator M - matrixOperator H := by
  apply ContinuousLinearMap.ext
  intro x
  apply PiLp.ext
  intro i
  simp only [matrixOperator_apply, sub_mul, Finset.sum_sub_distrib,
    sub_apply, PiLp.sub_apply]

/-- The operator bound in the low-rank dichotomy implies the exact coordinate
squared-action estimate used in network error propagation. -/
theorem matrix_action_bound_of_operator_norm {N : ℕ}
    (M : Fin N × Fin N → ℝ) (B : ℝ) (_hB : 0 ≤ B)
    (hM : ‖matrixOperator M‖ ≤ B) (x : Fin N → ℝ) :
    (∑ i, (∑ j, M (i, j) * x j) ^ 2) ≤ B ^ 2 * ∑ j, x j ^ 2 := by
  let z : EuclideanN N := WithLp.toLp 2 x
  have hh : ‖matrixOperator M z‖ ≤ B * ‖z‖ :=
    (matrixOperator M |>.le_opNorm z).trans
      (mul_le_mul_of_nonneg_right hM (norm_nonneg z))
  have hsq := mul_self_le_mul_self (norm_nonneg (matrixOperator M z)) hh
  simpa only [← pow_two, mul_pow, EuclideanSpace.real_norm_sq_eq,
    matrixOperator_apply, z, WithLp.ofLp_toLp] using hsq

lemma matrix_residual_action_bound {N : ℕ}
    (M H : Fin N × Fin N → ℝ) (a : ℝ) (ha : 0 ≤ a)
    (hres : ‖matrixOperator M - matrixOperator H‖ ≤ a) (x : Fin N → ℝ) :
    (∑ i, (∑ j, (M (i, j) - H (i, j)) * x j) ^ 2) ≤ a ^ 2 * ∑ j, x j ^ 2 := by
  exact matrix_action_bound_of_operator_norm (fun ij => M ij - H ij) a ha
    (by simpa only [matrixOperator_sub] using hres) x

end NeuralGeneralization
