import Paulsen.Paper.SampleAuxS4c

/-!
# Helpers for `ModerateSample`: assembling `lem:sample`

Union bounds, the Cauchy–Schwarz bound `|wᵀMw| ≤ ‖M‖_F ‖w‖²`, the expectation of the
quadratic form of `𝓛(Y)`, and the scalar budgets.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

/-- `|wᵀMw| ≤ ‖M‖_F ‖w‖²`. -/
theorem abs_matrixQuadratic_le_frob {m : Type*} [Fintype m] (M : Matrix m m ℝ) (w : m → ℝ) :
    |matrixQuadratic M w| ≤ Real.sqrt (frobSq M) * (w ⬝ᵥ w) := by
  have hcs := Real.sum_mul_le_sqrt_mul_sqrt (Finset.univ : Finset (m × m))
    (fun p => |M p.1 p.2|) (fun p => |w p.1 * w p.2|)
  have h1 : |matrixQuadratic M w| ≤ ∑ p : m × m, |M p.1 p.2| * |w p.1 * w p.2| := by
    unfold matrixQuadratic
    rw [← Finset.sum_product']
    refine (Finset.abs_sum_le_sum_abs _ _).trans (le_of_eq ?_)
    apply Finset.sum_congr rfl; intro p _
    rw [abs_mul, abs_mul, abs_mul]; ring
  have h2 : ∑ p : m × m, |M p.1 p.2| ^ 2 = frobSq M := by
    simp only [sq_abs, frobSq]; rw [← Finset.sum_product']; rfl
  have h3 : ∑ p : m × m, |w p.1 * w p.2| ^ 2 = (w ⬝ᵥ w) ^ 2 := by
    have e : ∀ p : m × m, |w p.1 * w p.2| ^ 2 = (w p.1 * w p.1) * (w p.2 * w p.2) := by
      intro p; rw [sq_abs]; ring
    simp_rw [e]
    simp only [dotProduct, pow_two, Finset.sum_mul, Finset.mul_sum]
    rw [← Finset.sum_product']
    apply Finset.sum_congr rfl; intro p _; ring
  have hww : 0 ≤ w ⬝ᵥ w := by
    simp only [dotProduct]; exact Finset.sum_nonneg fun _ _ => mul_self_nonneg _
  rw [h2, h3, Real.sqrt_sq hww] at hcs
  exact h1.trans hcs

/-- From `‖M‖_F² ≤ η²`. -/
theorem abs_matrixQuadratic_le_of_frobSq {m : Type*} [Fintype m] (M : Matrix m m ℝ)
    (w : m → ℝ) {η : ℝ} (hη : 0 ≤ η) (hM : frobSq M ≤ η ^ 2) :
    |matrixQuadratic M w| ≤ η * (w ⬝ᵥ w) := by
  have hww : 0 ≤ w ⬝ᵥ w := by
    simp only [dotProduct]; exact Finset.sum_nonneg fun _ _ => mul_self_nonneg _
  refine (abs_matrixQuadratic_le_frob M w).trans ?_
  apply mul_le_mul_of_nonneg_right _ hww
  calc Real.sqrt (frobSq M) ≤ Real.sqrt (η ^ 2) := Real.sqrt_le_sqrt hM
    _ = η := Real.sqrt_sq hη

/-- Entries of `𝓛(Y_Z)` are integrable. -/
theorem integrable_sqLaplacian_entry {n d : ℕ} (U : Frame n d) (ρ : ℝ) (a b : Fin n) :
    Integrable (fun g => sqLaplacian (tangentY U (moderateNoise U ρ g)) a b) (gaussAmb n d) := by
  simp only [sqLaplacian, Matrix.sum_apply]
  refine integrable_finsetSum _ fun i _ => integrable_finsetSum _ fun j _ => ?_
  by_cases h : i < j
  · simp only [h, if_true, Matrix.smul_apply, Matrix.vecMulVec_apply, smul_eq_mul]
    simp_rw [tangentY_moderateNoise_apply]
    exact ((memLp_sq_gaussianCoordinate (tangentF U ρ) (i, j)).integrable (by norm_num)).mul_const _
  · simp [h]

/-- `E xᵀ𝓛(Y)x = xᵀ(E𝓛(Y))x`. -/
theorem integral_matrixQuadratic_sqLaplacian {n d : ℕ} (U : Frame n d) (ρ : ℝ) (x : Fin n → ℝ) :
    ∫ g, matrixQuadratic (sqLaplacian (tangentY U (moderateNoise U ρ g))) x ∂gaussAmb n d =
      matrixQuadratic (Matrix.of fun a b => ∫ g, sqLaplacian (tangentY U (moderateNoise U ρ g)) a b
        ∂gaussAmb n d) x := by
  unfold matrixQuadratic
  rw [integral_finsetSum _ fun a _ => integrable_finsetSum _ fun b _ =>
    ((integrable_sqLaplacian_entry U ρ a b).const_mul (x a)).mul_const (x b)]
  apply Finset.sum_congr rfl; intro a _
  rw [integral_finsetSum _ fun b _ =>
    ((integrable_sqLaplacian_entry U ρ a b).const_mul (x a)).mul_const (x b)]
  apply Finset.sum_congr rfl; intro b _
  rw [integral_mul_const, integral_const_mul, Matrix.of_apply]

/-- A union budget: `2n e^{-b} ≤ 1/10` once `b ≥ log n + 200`. -/
theorem union_budget {n : ℕ} (hn : 0 < n) {b : ℝ} (hb : Real.log n + 200 ≤ b) :
    2 * (n : ℝ) * Real.exp (-b) ≤ 1 / 10 :=
  (Smooth.gaussian_row_union_failure_budget hn hb).trans (by norm_num)

/-- `μ(Sᶜ) ≥ 1 - μ(S)` for a probability measure (no measurability needed). -/
theorem measureReal_compl_ge {α : Type*} [MeasurableSpace α] (μ : Measure α)
    [IsProbabilityMeasure μ] (S : Set α) : 1 - μ.real S ≤ μ.real Sᶜ := by
  have h := measureReal_union_le (μ := μ) S Sᶜ
  rw [Set.union_compl_self, probReal_univ] at h
  linarith

end

end Paulsen.Paper
