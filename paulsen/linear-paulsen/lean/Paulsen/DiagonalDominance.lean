import Paulsen.KilledLaplacian

/-!
# A quantitative maximum principle for killed graph matrices

A matrix with nonpositive off-diagonal entries and row sums at least a positive
number has a positive inverse with dimension-independent row-sum bounds.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

theorem nonneg_of_zMatrix_row_lower
    (D : Matrix ι ι ℝ) (r : ℝ) (hr : 0 < r)
    (hoff : ∀ i j, i ≠ j → D i j ≤ 0)
    (hrows : ∀ i, r ≤ ∑ j, D i j)
    (x : ι → ℝ) (hx : ∀ i, 0 ≤ (D *ᵥ x) i) :
    ∀ i, 0 ≤ x i := by
  intro i
  by_contra hi
  have hxi : x i < 0 := lt_of_not_ge hi
  obtain ⟨k, _, hk⟩ := Finset.exists_min_image Finset.univ x
    (Finset.univ_nonempty_iff.mpr ⟨i⟩)
  have hmin : ∀ j, x k ≤ x j := fun j => hk j (Finset.mem_univ j)
  have hxk : x k < 0 := lt_of_le_of_lt (hmin i) hxi
  have hterm : ∀ j, D k j * x j ≤ D k j * x k := by
    intro j
    by_cases hkj : k = j
    · subst j
      rfl
    · exact mul_le_mul_of_nonpos_left (hmin j) (hoff k j hkj)
  have hsum := Finset.sum_le_sum (fun j (_ : j ∈ (Finset.univ : Finset ι)) => hterm j)
  rw [← Finset.sum_mul] at hsum
  have hrow := mul_le_mul_of_nonpos_right (hrows k) (le_of_lt hxk)
  have hneg : r * x k < 0 := mul_neg_of_pos_of_neg hr hxk
  have hnonneg := hx k
  change 0 ≤ ∑ j, D k j * x j at hnonneg
  linarith

/-- Invertibility and inverse positivity from the maximum principle alone. -/
theorem zMatrix_row_lower_inverse
    (D : Matrix ι ι ℝ) (r : ℝ) (hr : 0 < r)
    (hoff : ∀ i j, i ≠ j → D i j ≤ 0)
    (hrows : ∀ i, r ≤ ∑ j, D i j) :
    D * D⁻¹ = 1 ∧ D⁻¹ * D = 1 ∧ (∀ i j, 0 ≤ D⁻¹ i j) := by
  have hker : ∀ x : ι → ℝ, D *ᵥ x = 0 → x = 0 := by
    intro x hx
    have hxpos := nonneg_of_zMatrix_row_lower D r hr hoff hrows x
      (fun i => by simp [hx])
    have hxneg := nonneg_of_zMatrix_row_lower D r hr hoff hrows (-x)
      (fun i => by simp [Matrix.mulVec_neg, hx])
    ext i
    have hi := hxneg i
    simp only [Pi.neg_apply] at hi
    change x i = 0
    exact le_antisymm (by linarith) (hxpos i)
  have hinj : Function.Injective D.mulVec := by
    intro x y hxy
    have hzero : D *ᵥ (x - y) = 0 := by rw [Matrix.mulVec_sub, hxy, sub_self]
    exact sub_eq_zero.mp (hker (x - y) hzero)
  have hu := Matrix.mulVec_injective_iff_isUnit.mp hinj
  have hdet := (Matrix.isUnit_iff_isUnit_det D).mp hu
  have hDR := Matrix.mul_nonsing_inv D hdet
  have hRD := Matrix.nonsing_inv_mul D hdet
  refine ⟨hDR, hRD, ?_⟩
  intro i j
  let x : ι → ℝ := fun k => D⁻¹ k j
  have hx : ∀ k, 0 ≤ (D *ᵥ x) k := by
    intro k
    change 0 ≤ (D * D⁻¹) k j
    rw [hDR]
    simp only [Matrix.one_apply]
    split_ifs <;> norm_num
  exact nonneg_of_zMatrix_row_lower D r hr hoff hrows x hx i

/-- The killed inverse has row sums at most the reciprocal boundary mass. -/
theorem zMatrix_inverse_row_bound
    (D : Matrix ι ι ℝ) (r : ℝ) (hr : 0 < r)
    (hoff : ∀ i j, i ≠ j → D i j ≤ 0)
    (hrows : ∀ i, r ≤ ∑ j, D i j) (i : ι) :
    (∑ j, |D⁻¹ i j|) ≤ 1 / r := by
  obtain ⟨hDR, _, hRn⟩ := zMatrix_row_lower_inverse D r hr hoff hrows
  let x := D⁻¹ *ᵥ (fun _ => (1 : ℝ))
  have hDx : D *ᵥ x = fun _ => (1 : ℝ) := by
    dsimp only [x]
    rw [Matrix.mulVec_mulVec, hDR, Matrix.one_mulVec]
  let y : ι → ℝ := (fun _ => 1 / r) - x
  have hDy : ∀ k, 0 ≤ (D *ᵥ y) k := by
    intro k
    change 0 ≤ (D *ᵥ ((fun _ => 1 / r) - x)) k
    rw [Matrix.mulVec_sub, hDx]
    change 0 ≤ (∑ j, D k j * (1 / r)) - 1
    rw [← Finset.sum_mul]
    have h' : 1 ≤ (∑ j, D k j) / r :=
      (le_div_iff₀ hr).mpr (by simpa only [one_mul] using hrows k)
    simpa only [div_eq_mul_inv, one_mul, sub_nonneg] using h'
  have hy := nonneg_of_zMatrix_row_lower D r hr hoff hrows y hDy i
  have hxi : x i ≤ 1 / r := by
    change 0 ≤ 1 / r - x i at hy
    linarith
  simpa only [x, Matrix.mulVec, dotProduct, mul_one,
    abs_of_nonneg (hRn i _)] using hxi

end Paulsen
