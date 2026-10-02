import Paulsen.Linear.Barrier

/-!
# Barriers from a dense core with exceptional vertices

If every vertex outside an exceptional set `B` sends weight at least `κ` into
every half-set, and `B` carries an auxiliary barrier `y` for the Dirichlet
problem on `B`, then the explicit function `(λ₀ + y) · 1_{Sᶜ}` is an
`S`-barrier for every half-set `S`.
-/

namespace Paulsen.Linear

open scoped BigOperators
open Paulsen

variable {ι : Type*} [Fintype ι] [DecidableEq ι]
set_option linter.unusedSectionVars false

/-- The dense-core barrier lemma. -/
theorem core_barrier {w : ι → ι → ℝ} (hw : ∀ i j, 0 ≤ w i j)
    (B : Finset ι) {κ R F : ℝ} (hκ : 0 < κ) (hF : 0 ≤ F)
    (hcore : ∀ i, i ∉ B → ∀ S : Finset ι, i ∉ S →
      Fintype.card ι ≤ 2 * S.card → κ ≤ ∑ j ∈ S, w i j)
    (y : ι → ℝ) (hy0 : ∀ j, 0 ≤ y j) (hyB : ∀ j, j ∉ B → y j = 0)
    (hyR : ∀ j, y j ≤ R)
    (hyLap : ∀ i, i ∈ B → 1 ≤ weightedLaplacian w y i)
    (hyF : ∀ i, i ∉ B → ∑ j, w i j * y j ≤ F) :
    HasBarrierBound w ((1 + F) / κ + R) := by
  classical
  intro S _hS
  set l₀ : ℝ := (1 + F) / κ with hl₀
  have hl₀0 : 0 ≤ l₀ := by positivity
  have hl₀κ : l₀ * κ = 1 + F := by rw [hl₀]; field_simp
  let ψ : ι → ℝ := fun j => if j ∈ S then 0 else l₀ + y j
  have hψle : ∀ j, ψ j ≤ l₀ + y j := by
    intro j; dsimp only [ψ]; split_ifs
    · linarith [hy0 j]
    · exact le_rfl
  refine ⟨ψ, ⟨?_, ?_⟩, ?_⟩
  · intro j; dsimp only [ψ]; split_ifs
    · exact le_rfl
    · linarith [hy0 j]
  · intro i hiS
    have hψi : ψ i = l₀ + y i := by simp [ψ, hiS]
    by_cases hiB : i ∈ B
    · -- exceptional vertex: compare with the Laplacian of `y`
      refine (hyLap i hiB).trans ?_
      unfold weightedLaplacian
      apply Finset.sum_le_sum
      intro j _
      apply mul_le_mul_of_nonneg_left _ (hw i j)
      rw [hψi]; linarith [hψle j]
    · -- core vertex
      have hyi : y i = 0 := hyB i hiB
      have hterm : ∀ j, w i j * ((if j ∈ S then l₀ else 0) - y j) ≤
          w i j * (ψ i - ψ j) := by
        intro j
        apply mul_le_mul_of_nonneg_left _ (hw i j)
        rw [hψi, hyi]
        dsimp only [ψ]
        split_ifs <;> linarith [hy0 j]
      have hsum := Finset.sum_le_sum (fun j (_ : j ∈ Finset.univ) => hterm j)
      have hsplit : ∑ j, w i j * ((if j ∈ S then l₀ else 0) - y j) =
          l₀ * ∑ j ∈ S, w i j - ∑ j, w i j * y j := by
        simp_rw [mul_sub, Finset.sum_sub_distrib, mul_ite, mul_zero]
        rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.mul_sum]
        congr 1
        apply Finset.sum_congr rfl; intro j _; ring
      have hκS := hcore i hiB S hiS _hS
      have hlow : l₀ * κ ≤ l₀ * ∑ j ∈ S, w i j := mul_le_mul_of_nonneg_left hκS hl₀0
      have := hyF i hiB
      unfold weightedLaplacian
      linarith
  · intro j
    exact (hψle j).trans (by linarith [hyR j])

/-- Counting form of the core condition: many heavy neighbours. -/
theorem core_of_counts {w : ι → ι → ℝ} (hw : ∀ i j, 0 ≤ w i j)
    {γ ϑ : ℝ} (hγ : 0 ≤ γ) (i : ι)
    (hcount : (1 / 2 + ϑ) * (Fintype.card ι : ℝ) ≤
      ((Finset.univ.filter (fun j => j ≠ i ∧ γ / (Fintype.card ι : ℝ) ≤ w i j)).card : ℝ)) :
    ∀ S : Finset ι, i ∉ S → Fintype.card ι ≤ 2 * S.card →
      ϑ * γ ≤ ∑ j ∈ S, w i j := by
  classical
  intro S hiS hS
  set n : ℝ := (Fintype.card ι : ℝ) with hn
  set N := Finset.univ.filter (fun j => j ≠ i ∧ γ / n ≤ w i j) with hN
  have hn0 : 0 < n := by
    have : 0 < Fintype.card ι := Fintype.card_pos_iff.mpr ⟨i⟩
    rw [hn]; exact_mod_cast this
  -- both N and S avoid i, so |N ∩ S| ≥ |N| + |S| - (n - 1)
  have hunion : (N ∪ S).card ≤ Fintype.card ι - 1 := by
    have hsub : N ∪ S ⊆ Finset.univ.erase i := by
      intro j hj
      rw [Finset.mem_erase]
      refine ⟨?_, Finset.mem_univ _⟩
      rcases Finset.mem_union.mp hj with h | h
      · exact (Finset.mem_filter.mp h).2.1
      · rintro rfl; exact hiS h
    have := Finset.card_le_card hsub
    rwa [Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ] at this
  have hinc := Finset.card_union_add_card_inter N S
  have hcardpos : 1 ≤ Fintype.card ι := Fintype.card_pos_iff.mpr ⟨i⟩
  have hinterR : ((N.card : ℝ) + S.card) - (n - 1) ≤ ((N ∩ S).card : ℝ) := by
    have h1 : ((N ∪ S).card : ℝ) ≤ n - 1 := by
      have : ((Fintype.card ι - 1 : ℕ) : ℝ) = n - 1 := by
        rw [Nat.cast_sub hcardpos]; simp [hn]
      rw [← this]; exact_mod_cast hunion
    have h2 : ((N ∪ S).card : ℝ) + (N ∩ S).card = N.card + S.card := by exact_mod_cast hinc
    linarith
  have hSR : n ≤ 2 * (S.card : ℝ) := by rw [hn]; exact_mod_cast hS
  have hcnt : ϑ * n ≤ ((N ∩ S).card : ℝ) := by
    have := hcount
    nlinarith
  -- every element of N ∩ S has weight at least γ / n
  have hlow : ((N ∩ S).card : ℝ) * (γ / n) ≤ ∑ j ∈ S, w i j := by
    calc ((N ∩ S).card : ℝ) * (γ / n) = ∑ j ∈ N ∩ S, γ / n := by
          rw [Finset.sum_const, nsmul_eq_mul]
      _ ≤ ∑ j ∈ N ∩ S, w i j := by
          apply Finset.sum_le_sum; intro j hj
          exact (Finset.mem_filter.mp (Finset.mem_inter.mp hj).1).2.2
      _ ≤ ∑ j ∈ S, w i j :=
          Finset.sum_le_sum_of_subset_of_nonneg Finset.inter_subset_right
            (fun j _ _ => hw i j)
  have : ϑ * γ = ϑ * n * (γ / n) := by field_simp
  rw [this]
  calc ϑ * n * (γ / n) ≤ ((N ∩ S).card : ℝ) * (γ / n) :=
        mul_le_mul_of_nonneg_right hcnt (by positivity)
    _ ≤ _ := hlow

/-- Explicit exceptional barrier: a constant multiple of the indicator of `B`,
when every exceptional vertex sends weight at least `λ` out of `B`. -/
theorem indicator_exceptional_barrier {w : ι → ι → ℝ} (hw : ∀ i j, 0 ≤ w i j)
    (B : Finset ι) {l μ : ℝ} (hl : 0 < l)
    (hout : ∀ i, i ∈ B → l ≤ ∑ j ∈ Finset.univ.filter (fun j => j ∉ B), w i j)
    (hin : ∀ i, i ∉ B → ∑ j ∈ B, w i j ≤ μ) :
    let y : ι → ℝ := fun j => if j ∈ B then 1 / l else 0
    (∀ j, 0 ≤ y j) ∧ (∀ j, j ∉ B → y j = 0) ∧ (∀ j, y j ≤ 1 / l) ∧
      (∀ i, i ∈ B → 1 ≤ weightedLaplacian w y i) ∧
      (∀ i, i ∉ B → ∑ j, w i j * y j ≤ μ / l) := by
  classical
  intro y
  have hl' : 0 < 1 / l := by positivity
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · intro j; dsimp only [y]; split_ifs <;> linarith
  · intro j hj; simp [y, hj]
  · intro j; dsimp only [y]; split_ifs <;> linarith
  · intro i hi
    have hlap : weightedLaplacian w y i =
        (1 / l) * ∑ j ∈ Finset.univ.filter (fun j => j ∉ B), w i j := by
      unfold weightedLaplacian
      rw [Finset.mul_sum, Finset.sum_filter]
      apply Finset.sum_congr rfl; intro j _
      by_cases hj : j ∈ B <;> simp [y, hi, hj] <;> ring
    rw [hlap]
    have := hout i hi
    rw [div_mul_eq_mul_div, one_mul, le_div_iff₀ hl, one_mul]
    exact this
  · intro i hi
    have hs : ∑ j, w i j * y j = (∑ j ∈ B, w i j) * (1 / l) := by
      rw [Finset.sum_mul]
      rw [← Finset.sum_filter_add_sum_filter_not Finset.univ (fun j => j ∈ B)]
      have h2 : ∑ j ∈ Finset.univ.filter (fun j => j ∉ B), w i j * y j = 0 := by
        apply Finset.sum_eq_zero; intro j hj
        simp [y, (Finset.mem_filter.mp hj).2]
      rw [h2, add_zero, Finset.filter_mem_eq_inter, Finset.univ_inter]
      apply Finset.sum_congr rfl; intro j hj; simp [y, hj]
    rw [hs]
    have := hin i hi
    rw [div_eq_mul_one_div μ l]
    exact mul_le_mul_of_nonneg_right this hl'.le

end Paulsen.Linear
