import Mathlib

/-!
Deterministic duality and induction-step inequalities for signed Fourier
completion. These lemmas do not formalize the complete dimension induction,
the neural realization, or any posterior limit. The companion exact-integer
checker constructs the finite Walsh certificates independently.
-/

namespace IndependentResearch
open scoped BigOperators

/-- A nonnegative combination of the observed inequalities bounds its
contribution to the objective. No positivity of the signed masses is used. -/
theorem observed_dual_contribution {ι κ : Type*} [Fintype ι] [Fintype κ]
    (H : ι → κ → ℝ) (m : κ → ℝ) (lam : ι → ℝ)
    (hlam : ∀ u, 0 ≤ lam u)
    (hobs : ∀ u, 1 + ∑ s, H u s * m s ≤ 0) :
    ∑ s, (∑ u, lam u * H u s) * m s ≤ -(∑ u, lam u) := by
  calc
    ∑ s, (∑ u, lam u * H u s) * m s =
        ∑ u, lam u * (∑ s, H u s * m s) := by
      simp_rw [Finset.sum_mul, Finset.mul_sum, mul_assoc]
      exact Finset.sum_comm
    _ ≤ ∑ u, -(lam u) := by
      apply Finset.sum_le_sum
      intro u _
      have h := mul_le_mul_of_nonneg_left (show (∑ s, H u s * m s) ≤ -1 by
        linarith [hobs u]) (hlam u)
      simpa using h
    _ = -(∑ u, lam u) := by simp

/-- The cube support function is the sum of absolute coefficients. -/
theorem cube_linear_upper {κ : Type*} [Fintype κ]
    (r m : κ → ℝ) (hbox : ∀ s, |m s| ≤ 1) :
    ∑ s, r s * m s ≤ ∑ s, |r s| := by
  apply Finset.sum_le_sum
  intro s _
  calc
    r s * m s ≤ |r s * m s| := le_abs_self _
    _ = |r s| * |m s| := abs_mul _ _
    _ ≤ |r s| * 1 := mul_le_mul_of_nonneg_left (hbox s) (abs_nonneg _)
    _ = |r s| := mul_one _

/-- An exact certificate theorem for any finite observation matrix. -/
theorem finite_completion_dual_bound {ι κ : Type*} [Fintype ι] [Fintype κ]
    (H : ι → κ → ℝ) (c m : κ → ℝ) (lam : ι → ℝ)
    (hlam : ∀ u, 0 ≤ lam u)
    (hobs : ∀ u, 1 + ∑ s, H u s * m s ≤ 0)
    (hbox : ∀ s, |m s| ≤ 1) :
    ∑ s, c s * m s ≤
      (∑ s, |c s - ∑ u, lam u * H u s|) - ∑ u, lam u := by
  have hc := cube_linear_upper (fun s => c s - ∑ u, lam u * H u s) m hbox
  have ho := observed_dual_contribution H m lam hlam hobs
  have he : (∑ s, (c s - ∑ u, lam u * H u s) * m s) +
      (∑ s, (∑ u, lam u * H u s) * m s) = ∑ s, c s * m s := by
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro s _
    ring
  linarith

/-- Equality of the proposed vertex and the dual value proves optimality. -/
theorem finite_completion_vertex_optimal {ι κ : Type*} [Fintype ι] [Fintype κ]
    (H : ι → κ → ℝ) (c m e : κ → ℝ) (lam : ι → ℝ)
    (hlam : ∀ u, 0 ≤ lam u)
    (hobs : ∀ u, 1 + ∑ s, H u s * m s ≤ 0)
    (hbox : ∀ s, |m s| ≤ 1)
    (heobs : ∀ u, 1 + ∑ s, H u s * e s = 0)
    (hres : ∀ s, (c s - ∑ u, lam u * H u s) * e s =
                    |c s - ∑ u, lam u * H u s|) :
    ∑ s, c s * m s ≤ ∑ s, c s * e s := by
  have hb := finite_completion_dual_bound H c m lam hlam hobs hbox
  have he : (∑ s, c s * e s) =
      (∑ s, |c s - ∑ u, lam u * H u s|) - ∑ u, lam u := by
    have ho : (∑ s, (∑ u, lam u * H u s) * e s) = -(∑ u, lam u) := by
      calc
        _ = ∑ u, lam u * (∑ s, H u s * e s) := by
          simp_rw [Finset.sum_mul, Finset.mul_sum, mul_assoc]
          exact Finset.sum_comm
        _ = ∑ u, -(lam u) := by
          apply Finset.sum_congr rfl
          intro u _
          have hx : (∑ s, H u s * e s) = -1 := by linarith [heobs u]
          simp [hx]
        _ = _ := by simp
    calc
      _ = (∑ s, (c s - ∑ u, lam u * H u s) * e s) +
          ∑ s, (∑ u, lam u * H u s) * e s := by
        rw [← Finset.sum_add_distrib]
        apply Finset.sum_congr rfl
        intro s _
        ring
      _ = _ := by simp_rw [hres]; rw [ho]; ring
  linarith

/-- The two possible lower-dimensional coefficients in the first-half step. -/
theorem first_half_pair_bound (a b x y eps : ℝ)
    (hab : b ≤ a) (hx : x ≤ 1) (hy : -1 ≤ y)
    (heps : eps = 1 ∨ eps = -1) :
    a*x + b*y ≤
      2 * (if eps = 1 then b else a) * ((x+y)/2) + (a-b) := by
  rcases heps with hp | hn
  · subst eps
    simp only [ite_true]
    nlinarith [mul_nonneg (sub_nonneg.mpr hab) (sub_nonneg.mpr hx)]
  · subst eps
    norm_num
    nlinarith [mul_nonneg (sub_nonneg.mpr hab) (show 0 ≤ y+1 by linarith)]

/-- An average reaches a cube endpoint only when both entries reach it. -/
theorem average_endpoint_forces_both (x y eps : ℝ)
    (hx : |x| ≤ 1) (hy : |y| ≤ 1)
    (heps : eps = 1 ∨ eps = -1) (havg : (x+y)/2 = eps) :
    x = eps ∧ y = eps := by
  have hxl := (abs_le.mp hx).1
  have hxu := (abs_le.mp hx).2
  have hyl := (abs_le.mp hy).1
  have hyu := (abs_le.mp hy).2
  rcases heps with hp | hn
  · subst eps
    constructor <;> linarith
  · subst eps
    constructor <;> linarith

/-- Pair subtraction preserves the half-ratio coefficient hypothesis. -/
theorem half_ratio_under_pair_subtraction (a b c d : ℝ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (hab : b ≤ a/2) (hbc : c ≤ b/2) (hcd : d ≤ c/2) :
    0 < a-b ∧ 0 < c-d ∧ c-d ≤ (a-b)/2 := by
  constructor
  · linarith
  constructor <;> linarith

/-- Selecting either endpoint of each coefficient pair also preserves it. -/
theorem half_ratio_under_pair_selection (a b c d u v : ℝ)
    (hbc : c ≤ b/2) (hu : b ≤ u) (hv : v ≤ c) :
    v ≤ u/2 := by
  linarith

end IndependentResearch
