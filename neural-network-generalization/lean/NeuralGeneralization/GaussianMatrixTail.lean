import NeuralGeneralization.GaussianLinear
import NeuralGeneralization.GaussianMatrixGeometry
import NeuralGeneralization.GaussianMatrixConstants
import NeuralGeneralization.OperatorNetMeasure
import NeuralGeneralization.EuclideanNet

/-!
# A rectangular Gaussian operator norm tail

Independent scalar Gaussian moments and two finite volume-packing nets give
the actual matrix tail. This is the free-direction bound used in a cloning
cylinder; no Gaussian concentration theorem is postulated.
-/

noncomputable section

open MeasureTheory ProbabilityTheory
open scoped BigOperators RealInnerProductSpace NNReal

namespace NeuralGeneralization.GaussianTail

variable {m n : Type*} [Fintype m] [Fintype n]

theorem gaussian_matrix_bilinear_tail (v : ℝ≥0) (hv : 0 < (v : ℝ))
    (x : EuclideanSpace ℝ n) (y : EuclideanSpace ℝ m)
    (hx : ‖x‖ ≤ 1) (hy : ‖y‖ ≤ 1) (u : ℝ) (hu : 0 ≤ u) :
    (Measure.pi fun _ : m × n => gaussianReal 0 v).real
      {z | u ≤ |⟪coordinateMatrixOperator z x, y⟫|} ≤
      2 * Real.exp (-u ^ 2 / (2 * (v : ℝ))) := by
  simp_rw [coordinateMatrixOperator_inner]
  apply gaussian_linear_form_abs_tail (fun _ => v)
    (fun ij : m × n => y ij.1 * x ij.2) (v : ℝ) u hv hu
  rw [← Finset.sum_mul]
  exact (mul_le_mul_of_nonneg_right
    (matrix_bilinear_coefficient_energy_le_one x y hx hy) hv.le).trans_eq (one_mul _)

/-- The dimensions enter only through `9^(rows+columns)`, not through a
coordinate-grid entropy with an extra logarithm of dimension. -/
theorem gaussian_matrix_operator_tail (v : ℝ≥0) (hv : 0 < (v : ℝ))
    (u : ℝ) (hu : 0 ≤ u) :
    (Measure.pi fun _ : m × n => gaussianReal 0 v).real
      {z | 2 * u < ‖coordinateMatrixOperator z‖} ≤
      2 * (9 : ℝ) ^ (Fintype.card m + Fintype.card n) *
        Real.exp (-u ^ 2 / (2 * (v : ℝ))) := by
  classical
  obtain ⟨s, hscard, hsunit, hscover⟩ := exists_quarter_net
    (EuclideanSpace.basisFun n ℝ).toBasis.addHaar
  obtain ⟨t, htcard, htunit, htcover⟩ := exists_quarter_net
    (EuclideanSpace.basisFun m ℝ).toBasis.addHaar
  simp only [finrank_euclideanSpace] at hscard htcard
  let μ : Measure (m × n → ℝ) := Measure.pi fun _ => gaussianReal 0 v
  let event : EuclideanSpace ℝ n × EuclideanSpace ℝ m → Set (m × n → ℝ) :=
    fun xy => {z | u ≤ |⟪coordinateMatrixOperator z xy.1, xy.2⟫|}
  have hcount : ((s ×ˢ t).card : ℝ) ≤ (9 : ℝ) ^ (Fintype.card m + Fintype.card n) := by
    have hc : (s ×ˢ t).card ≤ 9 ^ (Fintype.card m + Fintype.card n) := by
      rw [Finset.card_product]
      calc
        _ ≤ 9 ^ Fintype.card n * 9 ^ Fintype.card m := Nat.mul_le_mul hscard htcard
        _ = _ := by rw [← pow_add, Nat.add_comm]
    exact_mod_cast hc
  calc
    _ ≤ ∑ xy ∈ s ×ˢ t, μ.real (event xy) :=
      operator_tail_le_quarter_net_sum μ s t hsunit hscover htcover
        coordinateMatrixOperator u hu
    _ ≤ ∑ _xy ∈ s ×ˢ t, 2 * Real.exp (-u ^ 2 / (2 * (v : ℝ))) := by
      apply Finset.sum_le_sum
      intro xy hxy
      obtain ⟨hx, hy⟩ := Finset.mem_product.mp hxy
      exact gaussian_matrix_bilinear_tail v hv xy.1 xy.2
        (hsunit _ hx) (htunit _ hy) u hu
    _ = ((s ×ˢ t).card : ℝ) * (2 * Real.exp (-u ^ 2 / (2 * (v : ℝ)))) := by
      rw [Finset.sum_const, nsmul_eq_mul]
    _ ≤ _ := by
      have hh := mul_le_mul_of_nonneg_right hcount
        (by positivity : 0 ≤ 2 * Real.exp (-u ^ 2 / (2 * (v : ℝ))))
      nlinarith

/-- A dimension-uniform positive-probability bound at the natural square
matrix scale. The deliberately generous constant avoids any sharp-norm
asymptotic theorem. -/
theorem gaussian_square_matrix_operator_tail (N : ℕ) (hN : 1 ≤ N)
    (v : ℝ≥0) (hv : 0 < (v : ℝ)) :
    (Measure.pi fun _ : Fin N × Fin N => gaussianReal 0 v).real
      {z | 16 * Real.sqrt ((N : ℝ) * v) < ‖coordinateMatrixOperator z‖} ≤ 1 / 2 := by
  have h := gaussian_matrix_operator_tail (m := Fin N) (n := Fin N) v hv
    (8 * Real.sqrt ((N : ℝ) * v)) (by positivity)
  have hsq : (8 * Real.sqrt ((N : ℝ) * v)) ^ 2 / (2 * (v : ℝ)) = 32 * N := by
    rw [mul_pow, Real.sq_sqrt (by positivity)]
    field_simp
    ring
  have hexp : -(8 * Real.sqrt ((N : ℝ) * v)) ^ 2 / (2 * (v : ℝ)) = -32 * N := by
    rw [neg_div, hsq]
    ring
  have hscale : 2 * (8 * Real.sqrt ((N : ℝ) * v)) =
      16 * Real.sqrt ((N : ℝ) * v) := by ring
  simp only [Fintype.card_fin, hexp, hscale] at h
  exact h.trans (matrix_net_tail_le_half N hN)

/-- The actual independent Gaussian matrix lies in the operator norm ball
with probability at least one half. -/
theorem gaussian_square_matrix_good_mass (N : ℕ) (hN : 1 ≤ N)
    (v : ℝ≥0) (hv : 0 < (v : ℝ)) :
    (1 : ℝ) / 2 ≤ (Measure.pi fun _ : Fin N × Fin N => gaussianReal 0 v).real
      {z | ‖coordinateMatrixOperator z‖ ≤ 16 * Real.sqrt ((N : ℝ) * v)} := by
  let μ : Measure (Fin N × Fin N → ℝ) := Measure.pi fun _ => gaussianReal 0 v
  let R : ℝ := 16 * Real.sqrt ((N : ℝ) * v)
  have htail := gaussian_square_matrix_operator_tail N hN v hv
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

end NeuralGeneralization.GaussianTail
