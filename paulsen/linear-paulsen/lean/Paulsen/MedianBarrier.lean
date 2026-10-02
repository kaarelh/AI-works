import Paulsen.Scaling
import Paulsen.ComplementScaling
import Paulsen.FiniteMedian

/-!
# A finite Poisson formulation of the nonlinear median barrier

Bounded mean-zero Poisson solvability replaces the stochastic hitting-time
argument. Intermediate lemmas use a supplied median; the final matrix bounds
construct one using finite median existence.
-/

namespace Paulsen

open scoped BigOperators
open Matrix

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- An infinity-norm bound for solving mean-zero Poisson equations.
This is a hypothesis, not an assertion that every weighted graph has the bound. -/
def BoundedPoissonSolvability (w : ι → ι → ℝ) (K : ℝ) : Prop :=
  ∀ f : ι → ℝ, (∑ i, f i) = 0 → (∀ i, |f i| ≤ 1) →
    ∃ g : ι → ℝ, (∀ i, weightedLaplacian w g i = f i) ∧ (∀ i, |g i| ≤ K)

/-- The test forcing which equals one off a set and has total sum zero. -/
noncomputable def halfSetForcing (S : Finset ι) (i : ι) : ℝ :=
  1 - if i ∈ S then (Fintype.card ι : ℝ) / (S.card : ℝ) else 0

theorem halfSetForcing_eq_one {S : Finset ι} {i : ι} (hi : i ∉ S) :
    halfSetForcing S i = 1 := by
  simp [halfSetForcing, hi]

theorem halfSetForcing_sum (S : Finset ι) (hS : 0 < S.card) :
    (∑ i, halfSetForcing S i) = 0 := by
  have hnz : (S.card : ℝ) ≠ 0 := ne_of_gt (Nat.cast_pos.mpr hS)
  simp only [halfSetForcing, Finset.sum_sub_distrib, Finset.sum_const,
    Finset.card_univ, nsmul_eq_mul, mul_one, Finset.sum_ite_mem, Finset.univ_inter]
  rw [mul_comm (S.card : ℝ), div_mul_cancel₀ _ hnz, sub_self]

theorem halfSetForcing_abs_le_one [Nonempty ι] (S : Finset ι)
    (hhalf : Fintype.card ι ≤ 2 * S.card) :
    ∀ i, |halfSetForcing S i| ≤ 1 := by
  have hn : 0 < Fintype.card ι := Fintype.card_pos
  have hk : 0 < S.card := by omega
  have hkR : 0 < (S.card : ℝ) := Nat.cast_pos.mpr hk
  have hhalfR : (Fintype.card ι : ℝ) ≤ 2 * (S.card : ℝ) := by exact_mod_cast hhalf
  have hratio : (Fintype.card ι : ℝ) / (S.card : ℝ) ≤ 2 :=
    (div_le_iff₀ hkR).mpr hhalfR
  have hratio0 : 0 ≤ (Fintype.card ι : ℝ) / (S.card : ℝ) :=
    div_nonneg (Nat.cast_nonneg _) (le_of_lt hkR)
  intro i
  by_cases hi : i ∈ S
  · rw [halfSetForcing, if_pos hi, abs_le]
    constructor <;> linarith
  · simp [halfSetForcing, hi]

/-- A half-sized boundary set and bounded Poisson solvability give a uniform
multiplicative upper bound on any nonnegative Laplacian subsolution. -/
theorem poisson_subset_bound [Nonempty ι]
    {w : ι → ι → ℝ} {z : ι → ℝ} {β K m : ℝ}
    (hw : ∀ i j, 0 ≤ w i j) (hsolve : BoundedPoissonSolvability w K)
    (hβ : 0 ≤ β) (hδ : 2 * β * K < 1)
    (hz : ∀ i, 0 ≤ z i)
    (hsub : ∀ i, weightedLaplacian w z i ≤ β * z i)
    (S : Finset ι) (hhalf : Fintype.card ι ≤ 2 * S.card)
    (hboundary : ∀ i ∈ S, z i ≤ m) :
    ∀ i, (1 - 2 * β * K) * z i ≤ m := by
  classical
  have hn : 0 < Fintype.card ι := Fintype.card_pos
  have hk : 0 < S.card := by omega
  obtain ⟨g, hg, hgbound⟩ := hsolve (halfSetForcing S)
    (halfSetForcing_sum S hk) (halfSetForcing_abs_le_one S hhalf)
  obtain ⟨k, _, hkmax⟩ := Finset.exists_max_image Finset.univ z Finset.univ_nonempty
  have hmax : ∀ i, z i ≤ z k := fun i => hkmax i (Finset.mem_univ i)
  have hp : (1 - 2 * β * K) * z k ≤ m := by
    apply poisson_median_bound (S := (S : Set ι)) hw hβ (hz k) hmax
      (fun i => (abs_le.mp (hgbound i)).1) (fun i => (abs_le.mp (hgbound i)).2)
    · exact hboundary
    · intro i _
      exact hsub i
    · intro i hi
      rw [hg i, halfSetForcing_eq_one hi]
  intro i
  exact le_trans (mul_le_mul_of_nonneg_left (hmax i) (le_of_lt (sub_pos.mpr hδ))) hp

/-- The two median sides, derived from Poisson solvability and the two
Laplacian subsolution inequalities. -/
theorem positive_poisson_median_sandwich [Nonempty ι]
    {w : ι → ι → ℝ} {z : ι → ℝ} {β K m : ℝ}
    (hw : ∀ i j, 0 ≤ w i j) (hsolve : BoundedPoissonSolvability w K)
    (hβ : 0 ≤ β) (hδ : 2 * β * K < 1)
    (hz : ∀ i, 0 < z i) (hm : 0 < m)
    (hsub : ∀ i, weightedLaplacian w z i ≤ β * z i)
    (hrecip : ∀ i, weightedLaplacian w (fun j => (z j)⁻¹) i ≤ β * (z i)⁻¹)
    (hlow : Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => z i ≤ m)).card)
    (hhigh : Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => m ≤ z i)).card) :
    (∀ i, (1 - 2 * β * K) * z i ≤ m) ∧
      (∀ i, (1 - 2 * β * K) * m ≤ z i) := by
  classical
  constructor
  · apply poisson_subset_bound hw hsolve hβ hδ (fun i => le_of_lt (hz i)) hsub
      (Finset.univ.filter (fun i => z i ≤ m)) hlow
    intro i hi
    exact (Finset.mem_filter.mp hi).2
  · have hb : ∀ i, (1 - 2 * β * K) * (z i)⁻¹ ≤ m⁻¹ := by
      apply poisson_subset_bound hw hsolve hβ hδ
        (fun i => le_of_lt (inv_pos.mpr (hz i))) hrecip
        (Finset.univ.filter (fun i => m ≤ z i)) hhigh
      intro i hi
      exact inv_anti₀ hm (Finset.mem_filter.mp hi).2
    intro i
    have hdiv : (1 - 2 * β * K) / z i ≤ 1 / m := by
      simpa only [div_eq_mul_inv, one_mul] using hb i
    have hc := (div_le_div_iff₀ (hz i) hm).mp hdiv
    simpa only [one_mul] using hc

/-- Coordinate-ratio form of the positive median barrier. -/
theorem positive_poisson_median_barrier [Nonempty ι]
    {w : ι → ι → ℝ} {z : ι → ℝ} {β K m : ℝ}
    (hw : ∀ i j, 0 ≤ w i j) (hsolve : BoundedPoissonSolvability w K)
    (hβ : 0 ≤ β) (hδ : 2 * β * K < 1)
    (hz : ∀ i, 0 < z i) (hm : 0 < m)
    (hsub : ∀ i, weightedLaplacian w z i ≤ β * z i)
    (hrecip : ∀ i, weightedLaplacian w (fun j => (z j)⁻¹) i ≤ β * (z i)⁻¹)
    (hlow : Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => z i ≤ m)).card)
    (hhigh : Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => m ≤ z i)).card) :
    ∀ i j, (1 - 2 * β * K) ^ 2 * z i ≤ z j := by
  obtain ⟨hu, hl⟩ := positive_poisson_median_sandwich hw hsolve hβ hδ hz hm
    hsub hrecip hlow hhigh
  intro i j
  exact median_sandwich hδ (hu i) (hl j)

/-- Exponential-coordinate form of the finite Poisson median barrier. -/
theorem exponential_poisson_median_barrier [Nonempty ι]
    {w : ι → ι → ℝ} {s : ι → ℝ} {β K m : ℝ}
    (hw : ∀ i j, 0 ≤ w i j) (hsolve : BoundedPoissonSolvability w K)
    (hβ : 0 ≤ β) (hδ : 2 * β * K < 1) (hm : 0 < m)
    (hsub : ∀ i, weightedLaplacian w (fun j => Real.exp (2 * s j)) i ≤
      β * Real.exp (2 * s i))
    (hrecip : ∀ i, weightedLaplacian w (fun j => (Real.exp (2 * s j))⁻¹) i ≤
      β * (Real.exp (2 * s i))⁻¹)
    (hlow : Fintype.card ι ≤
      2 * (Finset.univ.filter (fun i => Real.exp (2 * s i) ≤ m)).card)
    (hhigh : Fintype.card ι ≤
      2 * (Finset.univ.filter (fun i => m ≤ Real.exp (2 * s i))).card) :
    ∀ i j, s i - s j ≤ -Real.log (1 - 2 * β * K) := by
  obtain ⟨hu, hl⟩ := positive_poisson_median_sandwich hw hsolve hβ hδ
    (fun i => Real.exp_pos (2 * s i)) hm hsub hrecip hlow hhigh
  exact pairwise_exp_median_barrier hδ hu hl

variable {κ ν : Type*} [Fintype κ] [DecidableEq κ] [Fintype ν] [DecidableEq ν]

/-- Agreement between the matrix projection Laplacian and the finite weighted
Laplacian used in the maximum principle. -/
theorem parseval_laplacian_apply_eq_weighted
    (U : Matrix ι κ ℝ) (hU : U.transpose * U = 1) (f : ι → ℝ) (i : ι) :
    (projectionLaplacian (U * U.transpose) *ᵥ f) i =
      weightedLaplacian (fun j k => ((U * U.transpose) j k) ^ 2) f i := by
  have hsymm : ∀ j k, (U * U.transpose) j k = (U * U.transpose) k j := by
    intro j k
    have ht : (U * U.transpose).transpose = U * U.transpose := by
      simp only [Matrix.transpose_mul, Matrix.transpose_transpose]
    exact congrArg (fun M : Matrix ι ι ℝ => M k j) ht
  have hproj : (U * U.transpose) * (U * U.transpose) = U * U.transpose := by
    calc
      (U * U.transpose) * (U * U.transpose) = U * (U.transpose * U) * U.transpose := by
        simp only [Matrix.mul_assoc]
      _ = U * U.transpose := by rw [hU, Matrix.mul_one]
  rw [projectionLaplacian_mulVec_eq]
  unfold weightedLaplacian
  simp_rw [mul_sub]
  rw [Finset.sum_sub_distrib, ← Finset.sum_mul,
    projection_row_squares (U * U.transpose) hsymm hproj i]

/-- The full algebraic median barrier for a diagonally scaled subspace,
conditional only on a bounded Poisson solver and a supplied median. -/
theorem diagonal_scaling_positive_median_barrier [Nonempty ι]
    (U : Matrix ι κ ℝ) (V : Matrix ι ν ℝ) (z : ι → ℝ) (β K m : ℝ)
    (hU : U.transpose * U = 1) (hV : V.transpose * V = 1)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (hz : ∀ i, 0 < z i)
    (herror : ∀ i, |scaledLeverage U z i - (U * U.transpose) i i| ≤ β)
    (hsolve : BoundedPoissonSolvability (fun j k => ((U * U.transpose) j k) ^ 2) K)
    (hβ : 0 ≤ β) (hδ : 2 * β * K < 1) (hm : 0 < m)
    (hlow : Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => z i ≤ m)).card)
    (hhigh : Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => m ≤ z i)).card) :
    ∀ i j, (1 - 2 * β * K) ^ 2 * z i ≤ z j := by
  have htwo := diagonal_scaling_two_subsolutions U V z β hU hV hcomplete horth hz herror
  apply positive_poisson_median_barrier (fun j k => sq_nonneg _) hsolve hβ hδ hz hm
    ?_ ?_ hlow hhigh
  · intro i
    rw [← parseval_laplacian_apply_eq_weighted U hU z i]
    exact (htwo i).1
  · intro i
    rw [← parseval_laplacian_apply_eq_weighted U hU (fun j => (z j)⁻¹) i]
    exact (htwo i).2

/-- Scaling coordinates have uniformly bounded oscillation when the diagonal
movement times the initial Green bound is small. -/
theorem diagonal_scaling_exponential_median_barrier [Nonempty ι]
    (U : Matrix ι κ ℝ) (V : Matrix ι ν ℝ) (s : ι → ℝ) (β K m : ℝ)
    (hU : U.transpose * U = 1) (hV : V.transpose * V = 1)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0)
    (herror : ∀ i, |scaledLeverage U (fun j => Real.exp (2 * s j)) i -
      (U * U.transpose) i i| ≤ β)
    (hsolve : BoundedPoissonSolvability (fun j k => ((U * U.transpose) j k) ^ 2) K)
    (hβ : 0 ≤ β) (hδ : 2 * β * K < 1) (hm : 0 < m)
    (hlow : Fintype.card ι ≤
      2 * (Finset.univ.filter (fun i => Real.exp (2 * s i) ≤ m)).card)
    (hhigh : Fintype.card ι ≤
      2 * (Finset.univ.filter (fun i => m ≤ Real.exp (2 * s i))).card) :
    ∀ i j, s i - s j ≤ -Real.log (1 - 2 * β * K) := by
  have htwo := diagonal_scaling_two_subsolutions U V (fun j => Real.exp (2 * s j)) β
    hU hV hcomplete horth (fun j => Real.exp_pos _) herror
  apply exponential_poisson_median_barrier (fun j k => sq_nonneg _) hsolve hβ hδ hm
    ?_ ?_ hlow hhigh
  · intro i
    rw [← parseval_laplacian_apply_eq_weighted U hU (fun j => Real.exp (2 * s j)) i]
    exact (htwo i).1
  · intro i
    rw [← parseval_laplacian_apply_eq_weighted U hU (fun j => (Real.exp (2 * s j))⁻¹) i]
    exact (htwo i).2

/-- The positive-coordinate matrix barrier with the median constructed
internally from the finite family. -/
theorem diagonal_scaling_ratio_bound [Nonempty ι]
    (U : Matrix ι κ ℝ) (V : Matrix ι ν ℝ) (z : ι → ℝ) (β K : ℝ)
    (hU : U.transpose * U = 1) (hV : V.transpose * V = 1)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (hz : ∀ i, 0 < z i)
    (herror : ∀ i, |scaledLeverage U z i - (U * U.transpose) i i| ≤ β)
    (hsolve : BoundedPoissonSolvability (fun j k => ((U * U.transpose) j k) ^ 2) K)
    (hβ : 0 ≤ β) (hδ : 2 * β * K < 1) :
    ∀ i j, (1 - 2 * β * K) ^ 2 * z i ≤ z j := by
  obtain ⟨m, hm, hlow, hhigh⟩ := exists_positive_finite_median z hz
  exact diagonal_scaling_positive_median_barrier U V z β K m hU hV hcomplete horth
    hz herror hsolve hβ hδ hm hlow hhigh

/-- The complete finite a priori oscillation bound: no supplied median,
stochastic process, or analytic continuation is assumed. -/
theorem diagonal_scaling_oscillation_bound [Nonempty ι]
    (U : Matrix ι κ ℝ) (V : Matrix ι ν ℝ) (s : ι → ℝ) (β K : ℝ)
    (hU : U.transpose * U = 1) (hV : V.transpose * V = 1)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0)
    (herror : ∀ i, |scaledLeverage U (fun j => Real.exp (2 * s j)) i -
      (U * U.transpose) i i| ≤ β)
    (hsolve : BoundedPoissonSolvability (fun j k => ((U * U.transpose) j k) ^ 2) K)
    (hβ : 0 ≤ β) (hδ : 2 * β * K < 1) :
    ∀ i j, s i - s j ≤ -Real.log (1 - 2 * β * K) := by
  obtain ⟨m, hm, hlow, hhigh⟩ := exists_positive_finite_median
    (fun i => Real.exp (2 * s i)) (fun i => Real.exp_pos _)
  exact diagonal_scaling_exponential_median_barrier U V s β K m hU hV hcomplete horth
    herror hsolve hβ hδ hm hlow hhigh

end Paulsen
