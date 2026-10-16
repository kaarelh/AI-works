import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Field
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Algebra.Order.BigOperators.Ring.Finset
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.SplitIfs

/-!
# Deterministic estimates used in reverse-order network compression

These are proved estimates for actual finite vectors/matrices, not an assumed
compression theorem. The random sampling/existence step is not formalized here.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.Compression

variable {ι κ : Type*} [Fintype ι] [Fintype κ]

/-- Delete entries whose absolute value exceeds the threshold. -/
def prune (τ : ℝ) (w : ι → ℝ) : ι → ℝ :=
  fun i => if |w i| ≤ τ then w i else 0

omit [Fintype ι] in
/-- Deleting coordinates does not increase their squared norm. -/
theorem prune_sq_le (τ : ℝ) (w : ι → ℝ) (i : ι) :
    prune τ w i ^ 2 ≤ w i ^ 2 := by
  unfold prune
  split_ifs
  · exact le_rfl
  · simpa using sq_nonneg (w i)

theorem prune_squaredSum_le (τ : ℝ) (w : ι → ℝ) :
    (∑ i, prune τ w i ^ 2) ≤ ∑ i, w i ^ 2 := by
  exact Finset.sum_le_sum (fun i _ => prune_sq_le τ w i)

/-- The zero-row case is exact and does not require division by a threshold. -/
theorem squaredSum_eq_zero_iff (w : ι → ℝ) :
    (∑ i, w i ^ 2) = 0 ↔ ∀ i, w i = 0 := by
  classical
  constructor
  · intro h i
    have hsum := (Finset.sum_eq_zero_iff_of_nonneg
      (fun j (_ : j ∈ (Finset.univ : Finset ι)) => sq_nonneg (w j))).1 h
    exact sq_eq_zero_iff.mp (hsum i (Finset.mem_univ i))
  · intro h
    simp [h]

theorem zero_row_pruning_exact (w h : ι → ℝ)
    (hw : (∑ i, w i ^ 2) = 0) (τ : ℝ) :
    (∑ i, w i * h i) - ∑ i, prune τ w i * h i = 0 := by
  have hz := (squaredSum_eq_zero_iff w).1 hw
  simp [prune, hz]

omit [Fintype ι] in
/-- Every retained coordinate is bounded by the actual threshold. -/
theorem abs_prune_le {τ : ℝ} (hτ : 0 ≤ τ) (w : ι → ℝ) (i : ι) :
    |prune τ w i| ≤ τ := by
  unfold prune
  split_ifs with h
  · exact h
  · simpa using hτ

omit [Fintype ι] in
/-- The key rowwise deletion estimate, for one coordinate. -/
theorem removed_mul_abs_le {τ : ℝ} (hτ : 0 < τ)
    (w h : ι → ℝ) (hh : ∀ i, |h i| ≤ 1) (i : ι) :
    |(w i - prune τ w i) * h i| ≤ w i ^ 2 / τ := by
  unfold prune
  split_ifs with hi
  · simp only [sub_self, zero_mul, abs_zero]
    positivity
  · have hi' : τ < |w i| := lt_of_not_ge hi
    have hs : |w i| * τ ≤ w i ^ 2 := by
      calc
        |w i| * τ ≤ |w i| * |w i| :=
          mul_le_mul_of_nonneg_left hi'.le (abs_nonneg (w i))
        _ = w i ^ 2 := by rw [← sq, sq_abs]
    simp only [sub_zero, abs_mul]
    calc
      |w i| * |h i| ≤ |w i| * 1 :=
        mul_le_mul_of_nonneg_left (hh i) (abs_nonneg (w i))
      _ = |w i| := mul_one _
      _ ≤ w i ^ 2 / τ := (le_div_iff₀ hτ).2 hs

/-- Row pruning changes a preactivation by at most squared row norm / threshold. -/
theorem prune_preactivation_error {τ : ℝ} (hτ : 0 < τ)
    (w h : ι → ℝ) (hh : ∀ i, |h i| ≤ 1) :
    |(∑ i, w i * h i) - ∑ i, prune τ w i * h i| ≤
      (∑ i, w i ^ 2) / τ := by
  have heq : (∑ i, w i * h i) - ∑ i, prune τ w i * h i =
      ∑ i, (w i - prune τ w i) * h i := by
    simp_rw [sub_mul]
    rw [Finset.sum_sub_distrib]
  rw [heq]
  calc
    |∑ i, (w i - prune τ w i) * h i| ≤
        ∑ i, |(w i - prune τ w i) * h i| :=
      Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, w i ^ 2 / τ :=
      Finset.sum_le_sum (fun i _ => removed_mul_abs_le hτ w h hh i)
    _ = (∑ i, w i ^ 2) / τ := (Finset.sum_div _ _ _).symm

/-- A bounded coordinatewise activation bounds every hidden vector's squared norm. -/
theorem bounded_activation_squaredSum (φ : ℝ → ℝ)
    (hφ : ∀ t, |φ t| ≤ 1) (v : ι → ℝ) :
    (∑ i, φ (v i) ^ 2) ≤ (Fintype.card ι : ℝ) := by
  calc
    (∑ i, φ (v i) ^ 2) ≤ ∑ _i : ι, (1 : ℝ) := by
      apply Finset.sum_le_sum
      intro i hi
      have hs := (sq_le_sq₀ (abs_nonneg (φ (v i))) (zero_le_one : (0 : ℝ) ≤ 1)).2
        (hφ (v i))
      simpa only [sq_abs, one_pow] using hs
    _ = _ := by simp

/-- Coordinatewise 1-Lipschitz activation contracts squared Euclidean distances. -/
theorem lipschitz_activation_squaredDistance (φ : ℝ → ℝ)
    (hφ : ∀ t s, |φ t - φ s| ≤ |t - s|) (u v : ι → ℝ) :
    (∑ i, (φ (u i) - φ (v i)) ^ 2) ≤ ∑ i, (u i - v i) ^ 2 := by
  apply Finset.sum_le_sum
  intro i hi
  have hs := (sq_le_sq₀ (abs_nonneg (φ (u i) - φ (v i)))
    (abs_nonneg (u i - v i))).2 (hφ (u i) (v i))
  simpa only [sq_abs] using hs

/-- The Frobenius bound on a matrix's action, in squared-coordinate form. -/
theorem matrix_action_squaredSum_le (A : κ → ι → ℝ) (v : ι → ℝ) :
    (∑ j, (∑ i, A j i * v i) ^ 2) ≤
      (∑ j, ∑ i, A j i ^ 2) * (∑ i, v i ^ 2) := by
  calc
    (∑ j, (∑ i, A j i * v i) ^ 2) ≤
        ∑ j, (∑ i, A j i ^ 2) * (∑ i, v i ^ 2) := by
      apply Finset.sum_le_sum
      intro j hj
      exact Finset.sum_mul_sq_le_sq_mul_sq _ _ _
    _ = _ := (Finset.sum_mul _ _ _).symm

/-- Changing a hidden vector propagates through an actual activated matrix
    with the squared Frobenius amplification factor. -/
theorem activated_matrix_squaredDistance_le (φ : ℝ → ℝ)
    (hφ : ∀ t s, |φ t - φ s| ≤ |t - s|)
    (A : κ → ι → ℝ) (u v : ι → ℝ) :
    (∑ j, (φ (∑ i, A j i * u i) - φ (∑ i, A j i * v i)) ^ 2) ≤
      (∑ j, ∑ i, A j i ^ 2) * (∑ i, (u i - v i) ^ 2) := by
  have hdiff (j : κ) : (∑ i, A j i * u i) - (∑ i, A j i * v i) =
      ∑ i, A j i * (u i - v i) := by
    simp_rw [mul_sub]
    rw [Finset.sum_sub_distrib]
  calc
    _ ≤ ∑ j, ((∑ i, A j i * u i) - (∑ i, A j i * v i)) ^ 2 :=
      lipschitz_activation_squaredDistance φ hφ _ _
    _ = ∑ j, (∑ i, A j i * (u i - v i)) ^ 2 := by simp_rw [hdiff]
    _ ≤ _ := matrix_action_squaredSum_le A (fun i => u i - v i)

/-- The corresponding final linear-readout estimate. -/
theorem readout_squaredDistance_le (w u v : ι → ℝ) :
    ((∑ i, w i * u i) - (∑ i, w i * v i)) ^ 2 ≤
      (∑ i, w i ^ 2) * (∑ i, (u i - v i) ^ 2) := by
  have hdiff : (∑ i, w i * u i) - (∑ i, w i * v i) =
      ∑ i, w i * (u i - v i) := by
    simp_rw [mul_sub]
    rw [Finset.sum_sub_distrib]
  rw [hdiff]
  exact Finset.sum_mul_sq_le_sq_mul_sq _ _ _

/-- One actual finite hidden layer. -/
def layer (φ : ℝ → ℝ) (A : ι → ι → ℝ) (v : ι → ℝ) : ι → ℝ :=
  fun j => φ (∑ i, A j i * v i)

def squaredDistance (u v : ι → ℝ) : ℝ := ∑ i, (u i - v i) ^ 2

def squaredFrobenius (A : ι → ι → ℝ) : ℝ := ∑ j, ∑ i, A j i ^ 2

/-- Composition of a finite list of actual hidden layers. -/
def propagate (φ : ℝ → ℝ) (As : List (ι → ι → ℝ)) (v : ι → ℝ) : ι → ℝ :=
  As.foldl (fun h A => layer φ A h) v

theorem frobenius_product_nonneg (As : List (ι → ι → ℝ)) :
    0 ≤ (As.map squaredFrobenius).prod := by
  induction As with
  | nil => simp
  | cons A As ih =>
    simp only [List.map_cons, List.prod_cons]
    exact mul_nonneg (by unfold squaredFrobenius; positivity) ih

/-- Exact downstream error propagation used in both truncation and sampling.
    The product contains actual Frobenius norms of the downstream matrices. -/
theorem propagate_squaredDistance_le (φ : ℝ → ℝ)
    (hφ : ∀ t s, |φ t - φ s| ≤ |t - s|)
    (As : List (ι → ι → ℝ)) (u v : ι → ℝ) :
    squaredDistance (propagate φ As u) (propagate φ As v) ≤
      (As.map squaredFrobenius).prod * squaredDistance u v := by
  induction As generalizing u v with
  | nil => simp [propagate]
  | cons A As ih =>
    change squaredDistance (propagate φ As (layer φ A u))
      (propagate φ As (layer φ A v)) ≤ _
    calc
      _ ≤ (As.map squaredFrobenius).prod *
          squaredDistance (layer φ A u) (layer φ A v) := ih _ _
      _ ≤ (As.map squaredFrobenius).prod *
          (squaredFrobenius A * squaredDistance u v) := by
        apply mul_le_mul_of_nonneg_left _ (frobenius_product_nonneg As)
        exact activated_matrix_squaredDistance_le φ hφ A u v
      _ = _ := by simp only [List.map_cons, List.prod_cons]; ring

/-- The paper's row threshold gives its claimed preactivation error,
    using an exact squared-row-norm certificate. -/
theorem normalized_pruning_error {t a : ℝ} (ht : 0 < t) (ha : 0 < a)
    (w h : ι → ℝ) (hh : ∀ i, |h i| ≤ 1)
    (ha_sq : ∑ i, w i ^ 2 = a ^ 2) :
    |(∑ i, w i * h i) - ∑ i, prune (2 * a / t) w i * h i| ≤ t * a / 2 := by
  have hτ : 0 < 2 * a / t := by positivity
  have hb := prune_preactivation_error hτ w h hh
  rw [ha_sq] at hb
  have heq : a ^ 2 / (2 * a / t) = t * a / 2 := by
    field_simp [ne_of_gt ha, ne_of_gt ht]
  rwa [heq] at hb


/-- Squaring rowwise absolute bounds and summing preserves their shared factor. -/
theorem squaredSum_le_of_abs_le (e a : ι → ℝ) {c : ℝ}
    (hc : 0 ≤ c) (ha : ∀ i, 0 ≤ a i) (he : ∀ i, |e i| ≤ c * a i) :
    (∑ i, e i ^ 2) ≤ c ^ 2 * ∑ i, a i ^ 2 := by
  calc
    _ ≤ ∑ i, (c * a i) ^ 2 := by
      apply Finset.sum_le_sum
      intro i hi
      exact (sq_abs (e i)).symm ▸
        ((sq_le_sq₀ (abs_nonneg _) (mul_nonneg hc (ha i))).2 (he i))
    _ = _ := by simp only [mul_pow, Finset.mul_sum]

end NeuralGeneralization.Compression
