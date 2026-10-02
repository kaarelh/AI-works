import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Data.Finset.Max
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-!
# Deterministic scalar ingredients of the Paulsen scaling barrier

This file contains only proved auxiliary statements. It does not assert the
matrix scaling theorem or the Paulsen theorem.
-/

namespace Paulsen

/-- The scalar inequality underlying `A⁻¹ ≥ 2I - A` for positive definite `A`. -/
theorem inverse_ge_two_sub {x : ℝ} (hx : 0 < x) : 2 - x ≤ x⁻¹ := by
  rw [inv_eq_one_div, le_div_iff₀ hx]
  nlinarith [sq_nonneg (x - 1)]

/-- The two median inequalities combine without any probabilistic assumptions. -/
theorem median_sandwich {δ zMax zMin m : ℝ} (hδ : δ < 1)
    (hupper : (1 - δ) * zMax ≤ m)
    (hlower : (1 - δ) * m ≤ zMin) :
    (1 - δ) ^ 2 * zMax ≤ zMin := by
  have hr : 0 ≤ 1 - δ := le_of_lt (sub_pos.mpr hδ)
  calc
    (1 - δ) ^ 2 * zMax = (1 - δ) * ((1 - δ) * zMax) := by ring
    _ ≤ (1 - δ) * m := mul_le_mul_of_nonneg_left hupper hr
    _ ≤ zMin := hlower

/-- Exponential coordinates turn the median sandwich into an oscillation bound. -/
theorem exp_median_barrier {δ m s t : ℝ} (hδ : δ < 1)
    (hupper : (1 - δ) * Real.exp (2 * s) ≤ m)
    (hlower : (1 - δ) * m ≤ Real.exp (2 * t)) :
    s - t ≤ -Real.log (1 - δ) := by
  have hr : 0 < 1 - δ := sub_pos.mpr hδ
  have hsand := median_sandwich hδ hupper hlower
  have hlog := Real.log_le_log
    (mul_pos (sq_pos_of_pos hr) (Real.exp_pos (2 * s))) hsand
  rw [Real.log_mul (ne_of_gt (sq_pos_of_pos hr)) (Real.exp_ne_zero (2 * s)),
    Real.log_pow, Real.log_exp, Real.log_exp] at hlog
  norm_num at hlog
  linarith

/-- A common median controls every ordered pair of scaling coordinates. -/
theorem pairwise_exp_median_barrier {ι : Type*} {δ m : ℝ} {s : ι → ℝ}
    (hδ : δ < 1)
    (hupper : ∀ i, (1 - δ) * Real.exp (2 * s i) ≤ m)
    (hlower : ∀ i, (1 - δ) * m ≤ Real.exp (2 * s i)) :
    ∀ i j, s i - s j ≤ -Real.log (1 - δ) := by
  intro i j
  exact exp_median_barrier hδ (hupper i) (hlower j)

/-- The weighted finite Laplacian, with no symmetry assumption needed below. -/
def weightedLaplacian {ι : Type*} [Fintype ι]
    (w : ι → ι → ℝ) (f : ι → ℝ) (i : ι) : ℝ :=
  ∑ j, w i j * (f i - f j)

theorem weightedLaplacian_nonneg_at_max {ι : Type*} [Fintype ι]
    {w : ι → ι → ℝ} {f : ι → ℝ} {i : ι}
    (hw : ∀ j, 0 ≤ w i j) (hf : ∀ j, f j ≤ f i) :
    0 ≤ weightedLaplacian w f i := by
  exact Finset.sum_nonneg fun j _ => mul_nonneg (hw j) (sub_nonneg.mpr (hf j))

theorem weightedLaplacian_affine_sub {ι : Type*} [Fintype ι]
    (w : ι → ι → ℝ) (f h : ι → ℝ) (c a : ℝ) (i : ι) :
    weightedLaplacian w (fun j => f j - a - c * h j) i =
      weightedLaplacian w f i - c * weightedLaplacian w h i := by
  unfold weightedLaplacian
  rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem weightedLaplacian_add_const {ι : Type*} [Fintype ι]
    (w : ι → ι → ℝ) (f : ι → ℝ) (c : ℝ) (i : ι) :
    weightedLaplacian w (fun j => f j + c) i = weightedLaplacian w f i := by
  unfold weightedLaplacian
  apply Finset.sum_congr rfl
  intro j _
  congr 1
  ring

/-- Strict finite maximum principle. Symmetry and connectedness are unnecessary. -/
theorem weightedLaplacian_strict_maximum_principle
    {ι : Type*} [Fintype ι] [Nonempty ι]
    {w : ι → ι → ℝ} {f : ι → ℝ} {S : Set ι} {a : ℝ}
    (hw : ∀ i j, 0 ≤ w i j)
    (hboundary : ∀ i ∈ S, f i ≤ a)
    (hinterior : ∀ i ∉ S, weightedLaplacian w f i < 0) :
    ∀ i, f i ≤ a := by
  classical
  obtain ⟨k, _, hk⟩ :=
    Finset.exists_max_image Finset.univ f Finset.univ_nonempty
  have hmax : ∀ j, f j ≤ f k := fun j => hk j (Finset.mem_univ j)
  have hka : f k ≤ a := by
    by_contra hnot
    have hkS : k ∉ S := fun h => hnot (hboundary k h)
    have hn := weightedLaplacian_nonneg_at_max (hw k) hmax
    exact (not_lt_of_ge hn) (hinterior k hkS)
  intro i
  exact le_trans (hmax i) hka

/-- A nonnegative strict supersolution upgrades the strict maximum principle. -/
theorem weightedLaplacian_maximum_principle
    {ι : Type*} [Fintype ι] [Nonempty ι]
    {w : ι → ι → ℝ} {f h : ι → ℝ} {S : Set ι}
    (hw : ∀ i j, 0 ≤ w i j)
    (hh : ∀ i, 0 ≤ h i)
    (hboundary : ∀ i ∈ S, f i ≤ 0)
    (hinterior : ∀ i ∉ S, weightedLaplacian w f i ≤ 0)
    (hsuper : ∀ i ∉ S, 1 ≤ weightedLaplacian w h i) :
    ∀ i, f i ≤ 0 := by
  intro i
  by_contra hnot
  have hfi : 0 < f i := lt_of_not_ge hnot
  have hden : 0 < h i + 1 := by linarith [hh i]
  let ε : ℝ := f i / (h i + 1)
  have hε : 0 < ε := div_pos hfi hden
  have hcancel : ε * (h i + 1) = f i := by
    dsimp [ε]
    exact div_mul_cancel₀ _ (ne_of_gt hden)
  have hperturb : ∀ j, f j - ε * h j ≤ 0 := by
    apply weightedLaplacian_strict_maximum_principle hw
    · intro j hj
      have hm := mul_nonneg (le_of_lt hε) (hh j)
      linarith [hboundary j hj]
    · intro j hj
      have heq := weightedLaplacian_affine_sub w f h ε 0 j
      simp only [sub_zero] at heq
      rw [heq]
      have hprod := mul_le_mul_of_nonneg_left (hsuper j hj) (le_of_lt hε)
      nlinarith [hinterior j hj]
  have hp := hperturb i
  nlinarith

/-- Finite supersolution comparison underlying the median barrier. -/
theorem weightedLaplacian_supersolution_bound
    {ι : Type*} [Fintype ι] [Nonempty ι]
    {w : ι → ι → ℝ} {z h : ι → ℝ} {S : Set ι}
    {β M m H : ℝ}
    (hw : ∀ i j, 0 ≤ w i j)
    (hβ : 0 ≤ β) (hM : 0 ≤ M)
    (hz : ∀ i, z i ≤ M)
    (hh : ∀ i, 0 ≤ h i) (hH : ∀ i, h i ≤ H)
    (hboundary : ∀ i ∈ S, z i ≤ m)
    (hinterior : ∀ i ∉ S, weightedLaplacian w z i ≤ β * z i)
    (hsuper : ∀ i ∉ S, 1 ≤ weightedLaplacian w h i) :
    ∀ i, z i ≤ m + β * M * H := by
  have hβM : 0 ≤ β * M := mul_nonneg hβ hM
  have hcomp : ∀ i, z i - m - (β * M) * h i ≤ 0 := by
    apply weightedLaplacian_maximum_principle hw hh
    · intro i hi
      have hp := mul_nonneg hβM (hh i)
      linarith [hboundary i hi]
    · intro i hi
      rw [weightedLaplacian_affine_sub]
      have hzM := mul_le_mul_of_nonneg_left (hz i) hβ
      have hs := mul_le_mul_of_nonneg_left (hsuper i hi) hβM
      nlinarith [hinterior i hi]
    · exact hsuper
  intro i
  have hp := mul_le_mul_of_nonneg_left (hH i) hβM
  linarith [hcomp i]

/-- A bounded global Poisson solution gives the median inequality directly.

This replaces the hitting-time/Dynkin step: `g + K` is a nonnegative
supersolution bounded by `2 * K`, and it need not vanish on the boundary.
-/
theorem poisson_median_bound
    {ι : Type*} [Fintype ι] [Nonempty ι]
    {w : ι → ι → ℝ} {z g : ι → ℝ} {S : Set ι}
    {β K m : ℝ} {k : ι}
    (hw : ∀ i j, 0 ≤ w i j)
    (hβ : 0 ≤ β) (hzk : 0 ≤ z k)
    (hmax : ∀ i, z i ≤ z k)
    (hgLower : ∀ i, -K ≤ g i) (hgUpper : ∀ i, g i ≤ K)
    (hboundary : ∀ i ∈ S, z i ≤ m)
    (hinterior : ∀ i ∉ S, weightedLaplacian w z i ≤ β * z i)
    (hpoisson : ∀ i ∉ S, 1 ≤ weightedLaplacian w g i) :
    (1 - 2 * β * K) * z k ≤ m := by
  have hh : ∀ i, 0 ≤ g i + K := by
    intro i
    linarith [hgLower i]
  have hH : ∀ i, g i + K ≤ 2 * K := by
    intro i
    linarith [hgUpper i]
  have hsuper : ∀ i ∉ S, 1 ≤ weightedLaplacian w (fun j => g j + K) i := by
    intro i hi
    rw [weightedLaplacian_add_const]
    exact hpoisson i hi
  have hb := weightedLaplacian_supersolution_bound hw hβ hzk hmax hh hH
    hboundary hinterior hsuper k
  nlinarith

end Paulsen
