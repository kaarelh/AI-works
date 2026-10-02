import Paulsen.Paper.ToolboxAuxScaled
import Mathlib.Analysis.Calculus.LocalExtr.Basic
import Mathlib.Analysis.Convex.Segment

/-!
# Helper for `Paulsen.Paper.Toolbox`: elementary facts for the proof of `thm:balancing`
(first-order conditions on a box, finite extrema, the centred energy estimate).
-/

namespace Paulsen.Paper.ToolboxAux

open Matrix Paulsen
open scoped BigOperators

noncomputable section

/-- First-order conditions for a minimiser over the box `[0,T]^n`, given the gradient. -/
theorem box_kkt {n : ℕ} (Φ : (Fin n → ℝ) → ℝ) (g : Fin n → ℝ) (s : Fin n → ℝ) {T : ℝ}
    (hderiv : HasFDerivAt Φ (∑ i, g i • (ContinuousLinearMap.proj i : (Fin n → ℝ) →L[ℝ] ℝ)) s)
    (hs : s ∈ Set.Icc (0 : Fin n → ℝ) (fun _ => T))
    (hmin : IsMinOn Φ (Set.Icc (0 : Fin n → ℝ) (fun _ => T)) s) :
    (∀ i, 0 < s i → g i ≤ 0) ∧ (∀ i, s i < T → 0 ≤ g i) := by
  have hdir (i : Fin n) (a : ℝ) (ha : a ∈ Set.Icc (0 : ℝ) T) : 0 ≤ g i * (a - s i) := by
    have hy : Function.update s i a ∈ Set.Icc (0 : Fin n → ℝ) (fun _ => T) := by
      constructor <;> intro j <;> by_cases hj : j = i
      · subst j; simpa using ha.1
      · simpa [Function.update_of_ne hj] using hs.1 j
      · subst j; simpa using ha.2
      · simpa [Function.update_of_ne hj] using hs.2 j
    have hh := hmin.localize.hasFDerivWithinAt_nonneg hderiv.hasFDerivWithinAt
      (sub_mem_posTangentConeAt_of_segment_subset
        ((convex_Icc (0 : Fin n → ℝ) (fun _ => T)).segment_subset hs hy))
    have he : (∑ j, g j • (ContinuousLinearMap.proj j : (Fin n → ℝ) →L[ℝ] ℝ))
        (Function.update s i a - s) = g i * (a - s i) := by
      simp only [FunLike.coe_sum, Finset.sum_apply, FunLike.coe_smul,
        Pi.smul_apply, ContinuousLinearMap.proj_apply, Pi.sub_apply, smul_eq_mul]
      rw [Finset.sum_eq_single i]
      · simp
      · intro j _ hji
        simp [Function.update_of_ne hji]
      · simp
    rwa [he] at hh
  have hTi : ∀ i, 0 ≤ T := fun i => le_trans (hs.1 i) (hs.2 i)
  constructor
  · intro i hi
    have hh := hdir i 0 ⟨le_rfl, hTi i⟩
    nlinarith
  · intro i hi
    have hh := hdir i T ⟨hTi i, le_rfl⟩
    nlinarith

/-! ### Finite extrema -/

section Extrema

variable {n : ℕ}

theorem le_sup_fin (x : Fin n → ℝ) (i : Fin n) : x i ≤ ⨆ j, x j :=
  le_ciSup (Finite.bddAbove_range x) i

theorem inf_le_fin (x : Fin n → ℝ) (i : Fin n) : (⨅ j, x j) ≤ x i :=
  ciInf_le (Finite.bddBelow_range x) i

theorem sup_attained (hn : 0 < n) (x : Fin n → ℝ) : ∃ k, x k = ⨆ j, x j := by
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  exact exists_eq_ciSup_of_finite

theorem inf_attained (hn : 0 < n) (x : Fin n → ℝ) : ∃ k, x k = ⨅ j, x j := by
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  exact exists_eq_ciInf_of_finite

theorem inf_pos_fin (hn : 0 < n) (x : Fin n → ℝ) (hx : ∀ i, 0 < x i) : 0 < ⨅ j, x j := by
  obtain ⟨k, hk⟩ := inf_attained hn x
  rw [← hk]; exact hx k

/-- The centred estimate `∑ aᵢ fᵢ = ∑ (aᵢ - c) fᵢ ≤ ½ osc(a) ‖f‖₁` for `∑ f = 0`. -/
theorem centred_sum_le (a f : Fin n → ℝ) :
    ∑ i, (a i - ((⨆ j, a j) + ⨅ j, a j) / 2) * f i ≤
      1 / 2 * ((⨆ j, a j) - ⨅ j, a j) * ∑ i, |f i| := by
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum; intro i _
  have h1 := le_sup_fin a i
  have h2 := inf_le_fin a i
  have hab : |a i - ((⨆ j, a j) + ⨅ j, a j) / 2| ≤ 1 / 2 * ((⨆ j, a j) - ⨅ j, a j) := by
    rw [abs_le]; constructor <;> linarith
  calc (a i - ((⨆ j, a j) + ⨅ j, a j) / 2) * f i
      ≤ |(a i - ((⨆ j, a j) + ⨅ j, a j) / 2) * f i| := le_abs_self _
    _ = |a i - ((⨆ j, a j) + ⨅ j, a j) / 2| * |f i| := abs_mul _ _
    _ ≤ _ := mul_le_mul_of_nonneg_right hab (abs_nonneg _)

theorem sum_centre (a f : Fin n → ℝ) (hf : ∑ i, f i = 0) (c : ℝ) :
    ∑ i, a i * f i = ∑ i, (a i - c) * f i := by
  have : ∑ i, (a i - c) * f i = ∑ i, a i * f i - c * ∑ i, f i := by
    rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl; intro i _; ring
  rw [this, hf]; ring

end Extrema

/-- `(z_i - z_j)² ≥ 4 m² (w_i - w_j)²` for `z = w²`, `w ≥ m > 0`. -/
theorem sq_diff_sq_ge (wi wj m : ℝ) (hm : 0 ≤ m) (hi : m ≤ wi) (hj : m ≤ wj) :
    4 * m ^ 2 * (wi - wj) ^ 2 ≤ (wi ^ 2 - wj ^ 2) ^ 2 := by
  have h : (wi ^ 2 - wj ^ 2) ^ 2 = (wi + wj) ^ 2 * (wi - wj) ^ 2 := by ring
  rw [h]
  apply mul_le_mul_of_nonneg_right _ (sq_nonneg _)
  nlinarith

end

end Paulsen.Paper.ToolboxAux
