import Paulsen.BoundedScaling

/-!
# Barriers and the median maximum principle

An `S`-barrier for a weighted Laplacian is a nonnegative function whose
Laplacian is at least one off `S`. A weighted graph has barrier constant at most
`H` when every set containing at least half of the vertices has a barrier with
sup norm at most `H`. This is the half-set hitting time of the associated
continuous-time random walk; we never use that interpretation.
-/

namespace Paulsen.Linear

open scoped BigOperators
open Paulsen

variable {ι : Type*} [Fintype ι] [DecidableEq ι]
set_option linter.unusedSectionVars false

/-- `ψ` is an `S`-barrier for the weights `w`. -/
def IsBarrier (w : ι → ι → ℝ) (S : Finset ι) (ψ : ι → ℝ) : Prop :=
  (∀ i, 0 ≤ ψ i) ∧ ∀ i, i ∉ S → 1 ≤ weightedLaplacian w ψ i

/-- The barrier constant of `w` is at most `H`. -/
def HasBarrierBound (w : ι → ι → ℝ) (H : ℝ) : Prop :=
  ∀ S : Finset ι, Fintype.card ι ≤ 2 * S.card →
    ∃ ψ : ι → ℝ, IsBarrier w S ψ ∧ ∀ i, ψ i ≤ H

theorem HasBarrierBound.mono {w : ι → ι → ℝ} {H H' : ℝ}
    (h : HasBarrierBound w H) (hH : H ≤ H') : HasBarrierBound w H' := by
  intro S hS
  obtain ⟨ψ, hψ, hψH⟩ := h S hS
  exact ⟨ψ, hψ, fun i => (hψH i).trans hH⟩

theorem weightedLaplacian_sub_const_sub_smul (w : ι → ι → ℝ) (z ψ : ι → ℝ)
    (m c : ℝ) (i : ι) :
    weightedLaplacian w (fun j => z j - m - c * ψ j) i =
      weightedLaplacian w z i - c * weightedLaplacian w ψ i := by
  unfold weightedLaplacian
  rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro j _
  ring

/-- The barrier maximum principle: a nonnegative subsolution off a half-set `S`
is controlled multiplicatively by its maximum on `S`. -/
theorem barrier_subset_bound [Nonempty ι]
    {w : ι → ι → ℝ} {z : ι → ℝ} {β H m : ℝ}
    (hw : ∀ i j, 0 ≤ w i j) (hbar : HasBarrierBound w H)
    (hβ : 0 ≤ β) (hδ : β * H < 1)
    (hz : ∀ i, 0 ≤ z i)
    (S : Finset ι)
    (hsub : ∀ i, i ∉ S → weightedLaplacian w z i ≤ β * z i)
    (hhalf : Fintype.card ι ≤ 2 * S.card)
    (hboundary : ∀ i ∈ S, z i ≤ m) :
    ∀ i, (1 - β * H) * z i ≤ m := by
  classical
  obtain ⟨ψ, ⟨hψ0, hψ1⟩, hψH⟩ := hbar S hhalf
  obtain ⟨k, _, hkmax⟩ := Finset.exists_max_image Finset.univ z Finset.univ_nonempty
  have hmax : ∀ i, z i ≤ z k := fun i => hkmax i (Finset.mem_univ i)
  set M := z k with hMdef
  have hM0 : 0 ≤ M := hz k
  have hH0 : 0 ≤ H := (hψ0 k).trans (hψH k)
  -- for every η > 0, M ≤ m + β M H + η H
  have hkey : ∀ η : ℝ, 0 < η → M ≤ m + β * M * H + η * H := by
    intro η hη
    let c : ℝ := β * M + η
    have hc : 0 < c := by positivity
    let v : ι → ℝ := fun j => z j - m - c * ψ j
    obtain ⟨i₀, _, hi₀⟩ := Finset.exists_max_image Finset.univ v Finset.univ_nonempty
    have hvmax : ∀ j, v j ≤ v i₀ := fun j => hi₀ j (Finset.mem_univ j)
    have hi₀S : i₀ ∈ S := by
      by_contra hnot
      have hlap0 : 0 ≤ weightedLaplacian w v i₀ :=
        weightedLaplacian_nonneg_at_max (fun j => hw i₀ j) hvmax
      have hlap : weightedLaplacian w v i₀ =
          weightedLaplacian w z i₀ - c * weightedLaplacian w ψ i₀ :=
        weightedLaplacian_sub_const_sub_smul w z ψ m c i₀
      have h1 := hsub i₀ hnot
      have h2 := hψ1 i₀ hnot
      have h3 : β * z i₀ ≤ β * M := mul_le_mul_of_nonneg_left (hmax i₀) hβ
      have h4 : c * 1 ≤ c * weightedLaplacian w ψ i₀ := mul_le_mul_of_nonneg_left h2 hc.le
      have : weightedLaplacian w v i₀ < 0 := by
        rw [hlap]; dsimp only [c] at h4 ⊢; nlinarith
      linarith
    have hv0 : v i₀ ≤ 0 := by
      have := hboundary i₀ hi₀S
      have hψi := hψ0 i₀
      dsimp only [v]
      nlinarith [mul_nonneg hc.le hψi]
    have hvk : v k ≤ 0 := (hvmax k).trans hv0
    dsimp only [v] at hvk
    have hψk : c * ψ k ≤ c * H := mul_le_mul_of_nonneg_left (hψH k) hc.le
    dsimp only [c] at hψk
    nlinarith
  have hfinal : M ≤ m + β * M * H := by
    apply le_of_forall_pos_le_add
    intro ε hε
    have := hkey (ε / (H + 1)) (by positivity)
    have hle : ε / (H + 1) * H ≤ ε := by
      rw [div_mul_eq_mul_div, div_le_iff₀ (by positivity)]
      nlinarith
    linarith
  intro i
  have h1 : 0 ≤ 1 - β * H := by linarith
  have := mul_le_mul_of_nonneg_left (hmax i) h1
  nlinarith

/-- Both sides of the median barrier. -/
theorem barrier_median_sandwich [Nonempty ι]
    {w : ι → ι → ℝ} {z : ι → ℝ} {β H m : ℝ}
    (hw : ∀ i j, 0 ≤ w i j) (hbar : HasBarrierBound w H)
    (hβ : 0 ≤ β) (hδ : β * H < 1)
    (hz : ∀ i, 0 < z i) (hm : 0 < m)
    (hsub : ∀ i, m < z i → weightedLaplacian w z i ≤ β * z i)
    (hrecip : ∀ i, z i < m → weightedLaplacian w (fun j => (z j)⁻¹) i ≤ β * (z i)⁻¹)
    (hlow : Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => z i ≤ m)).card)
    (hhigh : Fintype.card ι ≤ 2 * (Finset.univ.filter (fun i => m ≤ z i)).card) :
    (∀ i, (1 - β * H) * z i ≤ m) ∧ (∀ i, (1 - β * H) * m ≤ z i) := by
  classical
  constructor
  · apply barrier_subset_bound hw hbar hβ hδ (fun i => le_of_lt (hz i))
      (Finset.univ.filter (fun i => z i ≤ m)) ?_ hlow
    · intro i hi
      exact (Finset.mem_filter.mp hi).2
    · intro i hi
      exact hsub i (lt_of_not_ge (by simpa using hi))
  · have hb : ∀ i, (1 - β * H) * (z i)⁻¹ ≤ m⁻¹ := by
      apply barrier_subset_bound hw hbar hβ hδ
        (fun i => le_of_lt (inv_pos.mpr (hz i)))
        (Finset.univ.filter (fun i => m ≤ z i)) ?_ hhigh
      · intro i hi
        exact inv_anti₀ hm (Finset.mem_filter.mp hi).2
      · intro i hi
        exact hrecip i (lt_of_not_ge (by simpa using hi))
    intro i
    have hdiv : (1 - β * H) / z i ≤ 1 / m := by
      simpa only [div_eq_mul_inv, one_mul] using hb i
    have hc := (div_le_div_iff₀ (hz i) hm).mp hdiv
    simpa only [one_mul] using hc

/-- Exponential-coordinate form of the median barrier. -/
theorem exponential_barrier_median [Nonempty ι]
    {w : ι → ι → ℝ} {s : ι → ℝ} {β H m : ℝ}
    (hw : ∀ i j, 0 ≤ w i j) (hbar : HasBarrierBound w H)
    (hβ : 0 ≤ β) (hδ : β * H < 1) (hm : 0 < m)
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
    ∀ i j, s i - s j ≤ -Real.log (1 - β * H) := by
  obtain ⟨hu, hl⟩ := barrier_median_sandwich hw hbar hβ hδ
    (fun i => Real.exp_pos (2 * s i)) hm hsub hrecip hlow hhigh
  exact pairwise_exp_median_barrier hδ hu hl

end Paulsen.Linear
