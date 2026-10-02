import Paulsen.MedianBarrier

/-! Median barriers requiring the differential inequalities only off the median half-sets. -/
namespace Paulsen
open scoped BigOperators
variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- A half-sized boundary set and bounded Poisson solvability give a uniform
multiplicative upper bound on any nonnegative Laplacian subsolution. -/
theorem poisson_subset_bound_restricted [Nonempty ι]
    {w : ι → ι → ℝ} {z : ι → ℝ} {β K m : ℝ}
    (hw : ∀ i j, 0 ≤ w i j) (hsolve : BoundedPoissonSolvability w K)
    (hβ : 0 ≤ β) (hδ : 2 * β * K < 1)
    (hz : ∀ i, 0 ≤ z i)
    (S : Finset ι)
    (hsub : ∀ i, i ∉ S → weightedLaplacian w z i ≤ β * z i)
    (hhalf : Fintype.card ι ≤ 2 * S.card)
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
    · intro i hi
      exact hsub i hi
    · intro i hi
      rw [hg i, halfSetForcing_eq_one hi]
  intro i
  exact le_trans (mul_le_mul_of_nonneg_left (hmax i) (le_of_lt (sub_pos.mpr hδ))) hp

/-- The two median sides, derived from Poisson solvability and the two
Laplacian subsolution inequalities. -/
theorem positive_poisson_median_sandwich_restricted [Nonempty ι]
    {w : ι → ι → ℝ} {z : ι → ℝ} {β K m : ℝ}
    (hw : ∀ i j, 0 ≤ w i j) (hsolve : BoundedPoissonSolvability w K)
    (hβ : 0 ≤ β) (hδ : 2 * β * K < 1)
    (hz : ∀ i, 0 < z i) (hm : 0 < m)
    (hsub : ∀ i, m < z i → weightedLaplacian w z i ≤ β * z i)
    (hrecip : ∀ i, z i < m → weightedLaplacian w (fun j => (z j)⁻¹) i ≤ β * (z i)⁻¹)
    (hlow : Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => z i ≤ m)).card)
    (hhigh : Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => m ≤ z i)).card) :
    (∀ i, (1 - 2 * β * K) * z i ≤ m) ∧
      (∀ i, (1 - 2 * β * K) * m ≤ z i) := by
  classical
  constructor
  · apply poisson_subset_bound_restricted hw hsolve hβ hδ (fun i => le_of_lt (hz i))
      (Finset.univ.filter (fun i => z i ≤ m)) ?_ hlow
    · intro i hi
      exact (Finset.mem_filter.mp hi).2
    · intro i hi
      exact hsub i (lt_of_not_ge (by simpa using hi))
  · have hb : ∀ i, (1 - 2 * β * K) * (z i)⁻¹ ≤ m⁻¹ := by
      apply poisson_subset_bound_restricted hw hsolve hβ hδ
        (fun i => le_of_lt (inv_pos.mpr (hz i)))
        (Finset.univ.filter (fun i => m ≤ z i)) ?_ hhigh
      · intro i hi
        exact inv_anti₀ hm (Finset.mem_filter.mp hi).2
      · intro i hi
        exact hrecip i (lt_of_not_ge (by simpa using hi))
    intro i
    have hdiv : (1 - 2 * β * K) / z i ≤ 1 / m := by
      simpa only [div_eq_mul_inv, one_mul] using hb i
    have hc := (div_le_div_iff₀ (hz i) hm).mp hdiv
    simpa only [one_mul] using hc

/-- Coordinate-ratio form of the positive median barrier. -/
theorem positive_poisson_median_barrier_restricted [Nonempty ι]
    {w : ι → ι → ℝ} {z : ι → ℝ} {β K m : ℝ}
    (hw : ∀ i j, 0 ≤ w i j) (hsolve : BoundedPoissonSolvability w K)
    (hβ : 0 ≤ β) (hδ : 2 * β * K < 1)
    (hz : ∀ i, 0 < z i) (hm : 0 < m)
    (hsub : ∀ i, m < z i → weightedLaplacian w z i ≤ β * z i)
    (hrecip : ∀ i, z i < m → weightedLaplacian w (fun j => (z j)⁻¹) i ≤ β * (z i)⁻¹)
    (hlow : Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => z i ≤ m)).card)
    (hhigh : Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => m ≤ z i)).card) :
    ∀ i j, (1 - 2 * β * K) ^ 2 * z i ≤ z j := by
  obtain ⟨hu, hl⟩ := positive_poisson_median_sandwich_restricted hw hsolve hβ hδ hz hm
    hsub hrecip hlow hhigh
  intro i j
  exact median_sandwich hδ (hu i) (hl j)

/-- Exponential-coordinate form of the finite Poisson median barrier. -/
theorem exponential_poisson_median_barrier_restricted [Nonempty ι]
    {w : ι → ι → ℝ} {s : ι → ℝ} {β K m : ℝ}
    (hw : ∀ i j, 0 ≤ w i j) (hsolve : BoundedPoissonSolvability w K)
    (hβ : 0 ≤ β) (hδ : 2 * β * K < 1) (hm : 0 < m)
    (hsub : ∀ i, m < Real.exp (2 * s i) →
      weightedLaplacian w (fun j => Real.exp (2 * s j)) i ≤
      β * Real.exp (2 * s i))
    (hrecip : ∀ i, Real.exp (2 * s i) < m →
      weightedLaplacian w (fun j => (Real.exp (2 * s j))⁻¹) i ≤
      β * (Real.exp (2 * s i))⁻¹)
    (hlow : Fintype.card ι ≤
      2 * (Finset.univ.filter (fun i => Real.exp (2 * s i) ≤ m)).card)
    (hhigh : Fintype.card ι ≤
      2 * (Finset.univ.filter (fun i => m ≤ Real.exp (2 * s i))).card) :
    ∀ i j, s i - s j ≤ -Real.log (1 - 2 * β * K) := by
  obtain ⟨hu, hl⟩ := positive_poisson_median_sandwich_restricted hw hsolve hβ hδ
    (fun i => Real.exp_pos (2 * s i)) hm hsub hrecip hlow hhigh
  exact pairwise_exp_median_barrier hδ hu hl


end Paulsen
