import Mathlib

/-!
Finite weighted-mean inequalities used in the Gaussian cosine mistake bound.
The application supplies positive precision entries, the stationary posterior
means on unseen coordinates, and the exact row sum. Gaussian integration,
convex concentration, and the finite-neural comparison are not formalized here.
-/
namespace IndependentResearch
open scoped BigOperators

/-- A stationary positive weighted sum bounds the smallest unseen coordinate. -/
theorem precision_partition_mean_bound {ι : Type*}
    (H U : Finset ι) (w μ : ι → ℝ) (a m : ℝ)
    (hwH : ∀ j ∈ H, 0 ≤ w j) (hwU : ∀ j ∈ U, 0 ≤ w j)
    (hH : ∀ j ∈ H, a ≤ μ j) (hU : ∀ j ∈ U, m ≤ μ j)
    (hstationary : (∑ j ∈ H, w j * μ j) + (∑ j ∈ U, w j * μ j) = 0) :
    a * (∑ j ∈ H, w j) + m * (∑ j ∈ U, w j) ≤ 0 := by
  have h1 : (∑ j ∈ H, w j * a) ≤ ∑ j ∈ H, w j * μ j :=
    Finset.sum_le_sum (fun j hj => mul_le_mul_of_nonneg_left (hH j hj) (hwH j hj))
  have h2 : (∑ j ∈ U, w j * m) ≤ ∑ j ∈ U, w j * μ j :=
    Finset.sum_le_sum (fun j hj => mul_le_mul_of_nonneg_left (hU j hj) (hwU j hj))
  simp_rw [← Finset.sum_mul] at h1 h2
  nlinarith

/-- Replacing the unseen row mass by its cardinality-times-largest-entry
upper bound gives the effective-precision row-sum mistake bound. -/
theorem precision_row_sum_mean_bound {a m q s b u : ℝ}
    (ha : 0 < a) (hs : 0 < s) (hq : s ≤ q)
    (hb : 0 < u * b) (hsbound : s ≤ u * b)
    (hstationary : a * (q - s) + m * s ≤ 0) :
    m ≤ -a * (q / (u * b) - 1) := by
  have hm : m ≤ 0 := by nlinarith
  have hproduct : (m - a) * (u * b) ≤ (m - a) * s :=
    mul_le_mul_of_nonpos_left hsbound (by linarith)
  apply (mul_le_mul_iff_of_pos_right hb).mp
  have hid : (-a * (q / (u * b) - 1)) * (u * b) = a * (u * b) - a * q := by
    calc
      (-a * (q / (u * b) - 1)) * (u * b) =
          -a * ((q / (u * b)) * (u * b) - u * b) := by ring
      _ = a * (u * b) - a * q := by rw [div_mul_cancel₀ _ (ne_of_gt hb)]; ring
  rw [hid]
  nlinarith

end IndependentResearch
