import NeuralGeneralization.BatchTwoNonGaussianLinearTail
import NeuralGeneralization.GaussianMatrixTail

/-! Actual non-Gaussian operator concentration, with a dimension-independent
law constant, derived from independent-coordinate moments and finite nets. -/

noncomputable section
open MeasureTheory
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoNonGaussian
open GaussianTail
variable {m n : Type*} [Fintype m] [Fintype n]

theorem actual_matrix_bilinear_tail (ν : CoordinateLaw)
    (x : EuclideanSpace ℝ n) (y : EuclideanSpace ℝ m)
    (hx : ‖x‖ ≤ 1) (hy : ‖y‖ ≤ 1) (u : ℝ) (hu : 0 ≤ u) :
    (Measure.pi fun _ : m × n => ν.law).real
      {z | u ≤ |⟪coordinateMatrixOperator z x, y⟫|} ≤
      2 * Real.exp (-u ^ 2 / (2 * subGaussianVariance ν)) := by
  simp_rw [coordinateMatrixOperator_inner]
  apply actual_linear_abs_tail ν (fun ij : m × n => y ij.1 * x ij.2)
    (subGaussianVariance ν) u (subGaussianVariance_pos ν) hu
  exact (mul_le_mul_of_nonneg_left
    (matrix_bilinear_coefficient_energy_le_one x y hx hy)
    (subGaussianVariance_pos ν).le).trans_eq (mul_one _)

theorem actual_matrix_operator_tail (ν : CoordinateLaw) (u : ℝ) (hu : 0 ≤ u) :
    (Measure.pi fun _ : m × n => ν.law).real
      {z | 2 * u < ‖coordinateMatrixOperator z‖} ≤
      2 * (9 : ℝ) ^ (Fintype.card m + Fintype.card n) *
        Real.exp (-u ^ 2 / (2 * subGaussianVariance ν)) := by
  classical
  obtain ⟨s, hscard, hsunit, hscover⟩ := exists_quarter_net
    (EuclideanSpace.basisFun n ℝ).toBasis.addHaar
  obtain ⟨t, htcard, htunit, htcover⟩ := exists_quarter_net
    (EuclideanSpace.basisFun m ℝ).toBasis.addHaar
  simp only [finrank_euclideanSpace] at hscard htcard
  let μ : Measure (m × n → ℝ) := Measure.pi fun _ => ν.law
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
      operator_tail_le_quarter_net_sum μ s t hsunit hscover htcover coordinateMatrixOperator u hu
    _ ≤ ∑ _xy ∈ s ×ˢ t, 2 * Real.exp (-u ^ 2 / (2 * subGaussianVariance ν)) := by
      apply Finset.sum_le_sum
      intro xy hxy
      obtain ⟨hx, hy⟩ := Finset.mem_product.mp hxy
      exact actual_matrix_bilinear_tail ν xy.1 xy.2 (hsunit _ hx) (htunit _ hy) u hu
    _ = ((s ×ˢ t).card : ℝ) * (2 * Real.exp (-u ^ 2 / (2 * subGaussianVariance ν))) := by
      rw [Finset.sum_const, nsmul_eq_mul]
    _ ≤ _ := by
      have hh := mul_le_mul_of_nonneg_right hcount
        (by positivity : 0 ≤ 2 * Real.exp (-u ^ 2 / (2 * subGaussianVariance ν)))
      nlinarith

end NeuralGeneralization.BatchTwoNonGaussian
