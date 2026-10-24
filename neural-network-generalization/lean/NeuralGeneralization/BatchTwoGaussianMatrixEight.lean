import NeuralGeneralization.GaussianMatrixTail
import Mathlib.Analysis.Complex.ExponentialBounds

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped NNReal
namespace NeuralGeneralization.GaussianTail

theorem matrix_net_tail_eight_le_half (N : ℕ) (hN : 1 ≤ N) :
    2 * (9 : ℝ) ^ (N + N) * Real.exp (-8 * (N : ℝ)) ≤ 1 / 2 := by
  have h9 : (9 : ℝ) ≤ Real.exp 3 := by
    have he : (5/2 : ℝ)≤Real.exp 1 := by linarith only [Real.exp_one_gt_d9]
    have h := pow_le_pow_left₀ (by norm_num : (0 : ℝ)≤5/2) he 3
    rw [←Real.exp_nat_mul] at h
    norm_num at h
    linarith only [h]
  have hp : (9 : ℝ) ^ (N + N) ≤ Real.exp (6 * (N : ℝ)) := by
    have hh := pow_le_pow_left₀ (by norm_num : (0 : ℝ) ≤ 9) h9 (N + N)
    rw [← Real.exp_nat_mul] at hh
    convert hh using 1 <;> push_cast <;> congr 1 <;> ring
  have h2 : (2 : ℝ) ≤ Real.exp 1 := by linarith [Real.add_one_le_exp (1 : ℝ)]
  have h4 : (4 : ℝ) ≤ Real.exp 2 := by
    have hh := mul_le_mul h2 h2 (by norm_num : (0 : ℝ) ≤ 2) (Real.exp_pos 1).le
    rw [← Real.exp_add] at hh
    norm_num at hh ⊢
    exact hh
  have hsmall : Real.exp (-2 : ℝ) ≤ 1 / 4 := by
    rw [Real.exp_neg, ← one_div]
    exact one_div_le_one_div_of_le (by norm_num) h4
  have hNr : (1 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
  calc
    _ ≤ 2 * Real.exp (6 * (N : ℝ)) * Real.exp (-8 * (N : ℝ)) := by
      exact mul_le_mul_of_nonneg_right
        (mul_le_mul_of_nonneg_left hp (by norm_num)) (Real.exp_pos _).le
    _ = 2 * Real.exp (-2 * (N : ℝ)) := by
      rw [mul_assoc, ← Real.exp_add]
      congr 2
      ring
    _ ≤ 2 * Real.exp (-2 : ℝ) := by
      apply mul_le_mul_of_nonneg_left _ (by norm_num)
      apply Real.exp_le_exp.mpr
      linarith
    _ ≤ _ := by linarith

theorem gaussian_square_matrix_operator_tail_eight (N : ℕ) (hN : 1 ≤ N)
    (v : ℝ≥0) (hv : 0 < (v : ℝ)) :
    (Measure.pi fun _ : Fin N × Fin N => gaussianReal 0 v).real
      {z | 8 * Real.sqrt ((N : ℝ) * v) < ‖coordinateMatrixOperator z‖} ≤ 1 / 2 := by
  have h := gaussian_matrix_operator_tail (m := Fin N) (n := Fin N) v hv
    (4 * Real.sqrt ((N : ℝ) * v)) (by positivity)
  have hsq : (4 * Real.sqrt ((N : ℝ) * v)) ^ 2 / (2 * (v : ℝ)) = 8 * N := by
    rw [mul_pow, Real.sq_sqrt (by positivity)]
    field_simp
    ring
  have hexp : -(4 * Real.sqrt ((N : ℝ) * v)) ^ 2 / (2 * (v : ℝ)) = -8 * N := by
    rw [neg_div, hsq]
    ring
  have hscale : 2 * (4 * Real.sqrt ((N : ℝ) * v)) =
      8 * Real.sqrt ((N : ℝ) * v) := by ring
  simp only [Fintype.card_fin, hexp, hscale] at h
  exact h.trans (matrix_net_tail_eight_le_half N hN)

/-- The actual independent Gaussian matrix lies in the operator norm ball
with probability at least one half. -/
theorem gaussian_square_matrix_good_mass_eight (N : ℕ) (hN : 1 ≤ N)
    (v : ℝ≥0) (hv : 0 < (v : ℝ)) :
    (1 : ℝ) / 2 ≤ (Measure.pi fun _ : Fin N × Fin N => gaussianReal 0 v).real
      {z | ‖coordinateMatrixOperator z‖ ≤ 8 * Real.sqrt ((N : ℝ) * v)} := by
  let μ : Measure (Fin N × Fin N → ℝ) := Measure.pi fun _ => gaussianReal 0 v
  let R : ℝ := 8 * Real.sqrt ((N : ℝ) * v)
  have htail := gaussian_square_matrix_operator_tail_eight N hN v hv
  have hcover : {z | ‖coordinateMatrixOperator z‖ ≤ R} ∪
      {z : Fin N × Fin N → ℝ | R < ‖coordinateMatrixOperator z‖} = Set.univ := by
    ext z
    simp only [Set.mem_union, Set.mem_setOf_eq, Set.mem_univ, iff_true]
    exact le_or_gt _ _
  have hh := measureReal_union_le (μ := μ)
    {z | ‖coordinateMatrixOperator z‖ ≤ R} {z | R < ‖coordinateMatrixOperator z‖}
  rw [hcover, probReal_univ] at hh
  change μ.real {z | R < ‖coordinateMatrixOperator z‖} ≤ 1 / 2 at htail
  change 1 / 2 ≤ μ.real {z | ‖coordinateMatrixOperator z‖ ≤ R}
  linarith

#print axioms gaussian_square_matrix_good_mass_eight
end NeuralGeneralization.GaussianTail
