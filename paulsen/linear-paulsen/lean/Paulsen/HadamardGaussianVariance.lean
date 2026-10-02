import Paulsen.GaussianMatrixTail

/-!
# Variance after entrywise multiplication of a Gaussian matrix

Covariance domination for the vectorized Gaussian controls the variance matrix
of its entrywise product with a fixed matrix. The loss is the largest column
energy of that fixed matrix, not its total Frobenius energy.
-/

namespace Paulsen
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory
noncomputable section

variable {κ : Type*} [Fintype κ] [DecidableEq κ]

def hadamardSeriesCoefficients {n : ℕ} (Y : Matrix (Fin n) (Fin n) ℝ)
    (C : Matrix (Fin n × Fin n) κ ℝ) (s : κ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => Y i j * C (i,j) s

theorem hadamardSeries_row_energy_le {n : ℕ}
    (Y : Matrix (Fin n) (Fin n) ℝ) (C : Matrix (Fin n × Fin n) κ ℝ)
    {v : ℝ} (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ v)
    (x : Fin n → ℝ) (i : Fin n) :
    (∑ s, ((hadamardSeriesCoefficients Y C s *ᵥ x) i) ^ 2) ≤
      v * ∑ j, (Y i j * x j) ^ 2 := by
  let z : EuclideanSpace ℝ (Fin n × Fin n) :=
    WithLp.toLp 2 (fun p => if p.1 = i then Y p.1 p.2 * x p.2 else 0)
  have hnorm := (Matrix.toEuclideanLin C.transpose).toContinuousLinearMap.le_opNorm z
  have hs := pow_le_pow_left₀ (norm_nonneg _) hnorm 2
  rw [mul_pow, euclidean_operator_norm_transpose] at hs
  have hs' := hs.trans (mul_le_mul_of_nonneg_right hC (sq_nonneg ‖z‖))
  simpa [EuclideanSpace.real_norm_sq_eq, z, Matrix.toLpLin_apply,
    Matrix.mulVec, dotProduct, Fintype.sum_prod_type, hadamardSeriesCoefficients,
    mul_assoc, mul_left_comm, mul_comm] using hs'

theorem hadamardSeries_energy_le {n : ℕ}
    (Y : Matrix (Fin n) (Fin n) ℝ) (C : Matrix (Fin n × Fin n) κ ℝ)
    {v R : ℝ} (hv : 0 ≤ v)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ v)
    (hR : ∀ j, (∑ i, Y i j ^ 2) ≤ R) (x : Fin n → ℝ) :
    (∑ s, ∑ i, ((hadamardSeriesCoefficients Y C s *ᵥ x) i) ^ 2) ≤
      (v * R) * ∑ j, x j ^ 2 := by
  rw [Finset.sum_comm]
  calc
    _ ≤ ∑ i, v * ∑ j, (Y i j * x j) ^ 2 :=
      Finset.sum_le_sum fun i _ => hadamardSeries_row_energy_le Y C hC x i
    _ = v * ∑ j, (∑ i, Y i j ^ 2) * x j ^ 2 := by
      rw [← Finset.mul_sum, Finset.sum_comm]
      simp only [mul_pow, Finset.sum_mul]
    _ ≤ v * ∑ j, R * x j ^ 2 := mul_le_mul_of_nonneg_left
      (Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_right (hR j) (sq_nonneg _)) hv
    _ = _ := by rw [← Finset.mul_sum]; ring

theorem hadamardSeries_variance_domination {n : ℕ}
    (Y : Matrix (Fin n) (Fin n) ℝ) (C : Matrix (Fin n × Fin n) κ ℝ)
    {v R : ℝ} (hv : 0 ≤ v) (hR0 : 0 ≤ R)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ v)
    (hR : ∀ j, (∑ i, Y i j ^ 2) ≤ R) :
    ((v * R) • (1 : Matrix (Fin n) (Fin n) ℝ) -
      ∑ s, (hadamardSeriesCoefficients Y C s).transpose * hadamardSeriesCoefficients Y C s).PosSemidef := by
  let A := hadamardSeriesCoefficients Y C
  have hpsd : (∑ s, (A s).transpose * A s).PosSemidef := by
    apply Matrix.posSemidef_sum
    intro s _
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
      Matrix.posSemidef_conjTranspose_mul_self (A s)
  apply Matrix.posSemidef_iff_dotProduct_mulVec.mpr
  refine ⟨((Matrix.PosSemidef.one.smul (mul_nonneg hv hR0)).isHermitian).sub hpsd.isHermitian, ?_⟩
  intro x
  have he := hadamardSeries_energy_le Y C hv hC hR x
  have hquad : x ⬝ᵥ ((∑ s, (A s).transpose * A s) *ᵥ x) =
      ∑ s, ∑ i, ((A s *ᵥ x) i) ^ 2 := by
    rw [Matrix.sum_mulVec]
    simp_rw [← Matrix.mulVec_mulVec]
    rw [dotProduct_sum]
    apply Finset.sum_congr rfl
    intro s _
    rw [dotProduct_mulVec, Matrix.vecMul_transpose]
    simp only [dotProduct, ← sq]
  simp only [star_trivial, Matrix.sub_mulVec, dotProduct_sub,
    Matrix.smul_mulVec, Matrix.one_mulVec, dotProduct_smul, smul_eq_mul]
  rw [hquad]
  simpa only [dotProduct, ← sq, sub_nonneg] using he

/-- A covariance-controlled symmetric Gaussian matrix remains a matrix series
with variance at most vR after entrywise multiplication by Y. -/
theorem hadamardSeries_expected_operator_norm_le {n : ℕ} (hn : 0 < n)
    (Y : Matrix (Fin n) (Fin n) ℝ) (C : Matrix (Fin n × Fin n) κ ℝ)
    (hY : Y.IsSymm) (hCs : ∀ s i j, C (i,j) s = C (j,i) s)
    {v R : ℝ} (hv : 0 < v) (hR0 : 0 < R)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ v)
    (hR : ∀ j, (∑ i, Y i j ^ 2) ≤ R) :
    (∫ x : κ → ℝ,
      ‖(Matrix.toEuclideanLin (gaussianMatrixSeries (hadamardSeriesCoefficients Y C) x)).toContinuousLinearMap‖
      ∂(Measure.pi fun _ : κ => gaussianReal 0 1)) ≤
      2 * Real.sqrt (2 * Real.exp 1 * (v * R) * (Real.log (n : ℝ) + 2)) := by
  letI : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn
  have hsym (s : κ) : (hadamardSeriesCoefficients Y C s).transpose = hadamardSeriesCoefficients Y C s := by
    ext i j
    simp only [Matrix.transpose_apply, hadamardSeriesCoefficients, Matrix.of_apply]
    rw [hY.apply, hCs s j i]
  have hA (s : κ) : (hadamardSeriesCoefficients Y C s).IsHermitian := by
    simpa only [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial] using hsym s
  have hvar := hadamardSeries_variance_domination Y C hv.le hR0.le hC hR
  simp only [hsym, ← pow_two] at hvar
  simpa only [Fintype.card_fin] using
    gaussianMatrixSeries_expected_operator_norm_log_bound
      (hadamardSeriesCoefficients Y C) hA (v * R) (mul_pos hv hR0) hvar

end
end Paulsen
