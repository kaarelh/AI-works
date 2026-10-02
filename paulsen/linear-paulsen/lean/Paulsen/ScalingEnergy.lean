import Paulsen.MatrixScaling
import Paulsen.Projection

/-!
# Direct scaling energy from the diagonal error

Multiplying Lz ≤ zδ by z bounds the Dirichlet energy by the total diagonal
error. Together with bounded scale ratios, this replaces Hessian comparison
and energy integration along a balancing path.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

theorem matrixQuadratic_eq_sum_mulVec {ι : Type*} [Fintype ι] [DecidableEq ι]
    (A : Matrix ι ι ℝ) (z : ι → ℝ) :
    matrixQuadratic A z = ∑ i, z i * (A *ᵥ z) i := by
  simp only [matrixQuadratic, Matrix.mulVec, dotProduct, Finset.mul_sum, mul_assoc]

/-- No spectral gap is needed for this algebraic energy estimate. -/
theorem matrix_energy_le_total_error {ι : Type*} [Fintype ι] [DecidableEq ι]
    (A : Matrix ι ι ℝ) (z δ : ι → ℝ) (Z : ℝ)
    (hz : ∀ i, 0 ≤ z i) (hZ : ∀ i, z i ≤ Z)
    (hsub : ∀ i, (A *ᵥ z) i ≤ z i * δ i) :
    matrixQuadratic A z ≤ Z ^ 2 * ∑ i, |δ i| := by
  rw [matrixQuadratic_eq_sum_mulVec, Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  calc
    z i * (A *ᵥ z) i ≤ z i * (z i * δ i) :=
      mul_le_mul_of_nonneg_left (hsub i) (hz i)
    _ = z i ^ 2 * δ i := by ring
    _ ≤ z i ^ 2 * |δ i| := mul_le_mul_of_nonneg_left (le_abs_self _) (sq_nonneg _)
    _ ≤ Z ^ 2 * |δ i| := mul_le_mul_of_nonneg_right
      (pow_le_pow_left₀ (hz i) (hZ i) 2) (abs_nonneg _)

theorem square_difference_controls_difference (x y m : ℝ)
    (hm : 0 ≤ m) (hx : m ≤ x) (hy : m ≤ y) :
    4 * m ^ 2 * (x - y) ^ 2 ≤ (x ^ 2 - y ^ 2) ^ 2 := by
  have hsum : 2 * m ≤ x + y := by linarith
  have hsq := pow_le_pow_left₀ (show 0 ≤ 2 * m by positivity) hsum 2
  have h := mul_le_mul_of_nonneg_right hsq (sq_nonneg (x - y))
  nlinarith only [h]

theorem graphEnergy_le_squared_coordinates {ι : Type*} [Fintype ι] [DecidableEq ι]
    (a : Matrix ι ι ℝ) (w : ι → ℝ) (m : ℝ)
    (ha : ∀ i j, 0 ≤ a i j) (hm : 0 ≤ m) (hw : ∀ i, m ≤ w i) :
    4 * m ^ 2 * graphEnergy a w ≤ graphEnergy a (fun i => w i ^ 2) := by
  have hterm (i j : ι) :
      4 * m ^ 2 * (a i j * (w i - w j) ^ 2) ≤
        a i j * (w i ^ 2 - w j ^ 2) ^ 2 := by
    have h := mul_le_mul_of_nonneg_left
      (square_difference_controls_difference (w i) (w j) m hm (hw i) (hw j)) (ha i j)
    nlinarith only [h]
  have hsum := Finset.sum_le_sum (fun i (_ : i ∈ (Finset.univ : Finset ι)) =>
    Finset.sum_le_sum (fun j (_ : j ∈ (Finset.univ : Finset ι)) => hterm i j))
  simp only [← Finset.mul_sum] at hsum
  unfold graphEnergy
  linarith

/-- Bounded positive scaling weights control their Dirichlet energy directly
by the ℓ¹ change in leverage scores. -/
theorem diagonal_scaling_energy_le_total_error {n d : ℕ}
    (U : Frame n d) (w : Fin n → ℝ) (m Z : ℝ)
    (hU : IsParseval U) (hm : 0 < m) (hw : ∀ i, m ≤ w i)
    (hZ : ∀ i, w i ^ 2 ≤ Z) :
    matrixQuadratic (projectionLaplacian (frameProjection U)) w ≤
      (Z ^ 2 / (4 * m ^ 2)) *
        ∑ i, |scaledLeverage U (fun j => w j ^ 2) i - rowNormSq U i| := by
  let z : Fin n → ℝ := fun i => w i ^ 2
  have hz : ∀ i, 0 < z i := fun i => sq_pos_of_pos (hm.trans_le (hw i))
  have hE := matrix_energy_le_total_error
    (projectionLaplacian (frameProjection U)) z
    (fun i => scaledLeverage U z i - rowNormSq U i) Z
    (fun i => (hz i).le) hZ (fun i => by
      have h := parseval_diagonal_scaling_first_inequality U z hU hz i
      change (projectionLaplacian (frameProjection U) *ᵥ z) i ≤
        z i * (scaledLeverage U z i - frameProjection U i i) at h
      rwa [frameProjection_diagonal] at h)
  have hcomp := graphEnergy_le_squared_coordinates
    (Matrix.of (fun i j => frameProjection U i j ^ 2)) w m
    (fun _ _ => sq_nonneg _) hm.le hw
  have henergy (f : Fin n → ℝ) :
      matrixQuadratic (projectionLaplacian (frameProjection U)) f =
        graphEnergy (Matrix.of (fun i j => frameProjection U i j ^ 2)) f :=
    hU.laplacian_energy f
  rw [← henergy w, ← henergy (fun i => w i ^ 2)] at hcomp
  have hb : 4 * m ^ 2 * matrixQuadratic (projectionLaplacian (frameProjection U)) w ≤
      Z ^ 2 * ∑ i, |scaledLeverage U z i - rowNormSq U i| := hcomp.trans hE
  have hden : 0 < 4 * m ^ 2 := by positivity
  have hb' : matrixQuadratic (projectionLaplacian (frameProjection U)) w ≤
      (Z ^ 2 * ∑ i, |scaledLeverage U z i - rowNormSq U i|) / (4 * m ^ 2) :=
    (le_div_iff₀ hden).mpr (by simpa only [mul_comm] using hb)
  convert hb' using 1; ring

end Paulsen
