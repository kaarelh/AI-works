import Paulsen.Linear.BlockBarrier
import Paulsen.Linear.Balancing
import Paulsen.DenseCore
import Mathlib.Algebra.Order.Chebyshev

/-!
# Barrier constant of the moderate seed graph

A dense core off a bounded exceptional set `B`, together with a mean-zero gap
for the projection Laplacian, bounds the barrier constant. The mean-zero gap
gives a gap on functions supported on `B` (subtract the mean; the Laplacian
kills constants), hence an exceptional barrier on `B` by `block_barrier`, and
`core_barrier` assembles the global barrier.
-/

namespace Paulsen.Linear

open Matrix Paulsen
open scoped BigOperators

noncomputable section

theorem matrixQuadratic_eq_sum_weightedLaplacian {n d : ℕ} {W : Frame n d}
    (hW : IsParseval W) (x : Fin n → ℝ) :
    matrixQuadratic (projectionLaplacian (frameProjection W)) x =
      ∑ i, x i * weightedLaplacian (fun i j => (frameProjection W i j) ^ 2) x i := by
  apply Finset.sum_congr rfl
  intro i _
  have h : (projectionLaplacian (frameProjection W) *ᵥ x) i =
      weightedLaplacian (fun j k => (frameProjection W j k) ^ 2) x i :=
    parseval_laplacian_apply_eq_weighted W hW x i
  rw [← h]
  simp only [Matrix.mulVec, dotProduct, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem parseval_laplacian_shift {n d : ℕ} {W : Frame n d} (hW : IsParseval W)
    (x : Fin n → ℝ) (c : ℝ) :
    matrixQuadratic (projectionLaplacian (frameProjection W)) (fun i => x i - c) =
      matrixQuadratic (projectionLaplacian (frameProjection W)) x := by
  rw [hW.laplacian_energy, hW.laplacian_energy]
  simp only [sub_sub_sub_cancel_right]

/-- A mean-zero gap gives a gap on every block of at most a tenth of the vertices. -/
theorem block_gap_of_mean_zero_gap {n d : ℕ} {W : Frame n d} (hW : IsParseval W)
    (hn : 0 < n) (B : Finset (Fin n)) (hB : 10 * B.card ≤ n) {l : ℝ} (hl : 0 ≤ l)
    (hgap : ∀ x : Fin n → ℝ, (∑ i, x i) = 0 →
      l * vectorNormSq x ≤ matrixQuadratic (projectionLaplacian (frameProjection W)) x)
    (x : Fin n → ℝ) (hx : ∀ j, j ∉ B → x j = 0) :
    (9 * l / 10) * ∑ i, x i ^ 2 ≤
      ∑ i, x i * weightedLaplacian (fun i j => (frameProjection W i j) ^ 2) x i := by
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  set c : ℝ := (∑ i, x i) / n with hc
  have hy : (∑ i, (x i - c)) = 0 := by
    rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      nsmul_eq_mul, hc]
    field_simp
    ring
  have hg := hgap (fun i => x i - c) hy
  rw [parseval_laplacian_shift hW, matrixQuadratic_eq_sum_weightedLaplacian hW] at hg
  -- the norm of the centred vector
  have hnorm : vectorNormSq (fun i => x i - c) = (∑ i, x i ^ 2) - (∑ i, x i) ^ 2 / n := by
    unfold vectorNormSq
    simp only [sub_sq, Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_const,
      Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, ← Finset.sum_mul, ← Finset.mul_sum, hc]
    field_simp
    ring
  have hsumB : (∑ i, x i) = ∑ i ∈ B, x i := by
    rw [← Finset.sum_subset (Finset.subset_univ B)]
    intro j _ hj; exact hx j hj
  have hsqB : (∑ i ∈ B, x i) ^ 2 ≤ (B.card : ℝ) * ∑ i ∈ B, x i ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  have hsq2 : (∑ i ∈ B, x i ^ 2) ≤ ∑ i, x i ^ 2 :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ B) (fun i _ _ => sq_nonneg _)
  have hBR : 10 * (B.card : ℝ) ≤ n := by exact_mod_cast hB
  have hS0 : 0 ≤ ∑ i, x i ^ 2 := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  have hfrac : (∑ i, x i) ^ 2 / n ≤ (1 / 10) * ∑ i, x i ^ 2 := by
    rw [div_le_iff₀ hnR, hsumB]
    have h1 := mul_le_mul_of_nonneg_left hsq2 (Nat.cast_nonneg B.card : (0 : ℝ) ≤ B.card)
    nlinarith
  rw [hnorm] at hg
  have h2 := mul_le_mul_of_nonneg_left hfrac hl
  nlinarith

/-- The barrier constant of a Parseval frame with a dense core off `B` and a
mean-zero spectral gap. -/
theorem frameBarrier_of_core_and_gap {n d : ℕ} {W : Frame n d} (hW : IsParseval W)
    (hn : 10 ≤ n) (B : Finset (Fin n)) (hB : 10 * B.card ≤ n) {γ l : ℝ}
    (hγ : 0 < γ) (hl : 0 < l)
    (hdense : ∀ i ∉ B, 4 * n ≤ 5 * (largeNeighbors
      (fun i j => (frameProjection W i j) ^ 2) γ i).card)
    (hgap : ∀ x : Fin n → ℝ, (∑ i, x i) = 0 →
      l * vectorNormSq x ≤ matrixQuadratic (projectionLaplacian (frameProjection W)) x) :
    FrameBarrierBound W ((1 + (B.card : ℝ)) / (γ / 5) + (B.card : ℝ) / (9 * l / 10)) := by
  classical
  have hn0 : 0 < n := by omega
  haveI : Nonempty (Fin n) := ⟨⟨0, hn0⟩⟩
  set w : Fin n → Fin n → ℝ := fun i j => (frameProjection W i j) ^ 2 with hwdef
  have hw : ∀ i j, 0 ≤ w i j := fun i j => sq_nonneg _
  have hsymm : ∀ i j, w i j = w j i := by
    intro i j; simp only [hwdef, frameProjection_symm W i j]
  have hl' : 0 < 9 * l / 10 := by positivity
  obtain ⟨y, hy0, hyB, hyR, hyLap, hyF⟩ := block_barrier hw hsymm B hl'
    (fun x hx => block_gap_of_mean_zero_gap hW hn0 B hB hl.le hgap x hx)
  have hcore : ∀ i, i ∉ B → ∀ S : Finset (Fin n), i ∉ S →
      Fintype.card (Fin n) ≤ 2 * S.card → (1 / 5) * γ ≤ ∑ j ∈ S, w i j := by
    intro i hi
    apply core_of_counts hw hγ.le i
    have hsub : (largeNeighbors w γ i).erase i ⊆
        Finset.univ.filter (fun j => j ≠ i ∧ γ / (Fintype.card (Fin n) : ℝ) ≤ w i j) := by
      intro j hj
      rw [Finset.mem_erase] at hj
      rw [Finset.mem_filter]
      refine ⟨Finset.mem_univ _, hj.1, ?_⟩
      have := hj.2
      unfold largeNeighbors at this
      exact (Finset.mem_filter.mp this).2
    have hc1 := Finset.card_le_card hsub
    have hc2 := Finset.pred_card_le_card_erase (s := largeNeighbors w γ i) (a := i)
    have hd := hdense i hi
    have hnat : 7 * n ≤ 10 * (Finset.univ.filter (fun j => j ≠ i ∧
        γ / (Fintype.card (Fin n) : ℝ) ≤ w i j)).card := by omega
    have hR : (7 : ℝ) * n ≤ 10 * ((Finset.univ.filter (fun j => j ≠ i ∧
        γ / (Fintype.card (Fin n) : ℝ) ≤ w i j)).card : ℝ) := by exact_mod_cast hnat
    simp only [Fintype.card_fin] at hR ⊢
    linarith
  have hκ : 0 < (1 / 5) * γ := by positivity
  have hbar := core_barrier hw B hκ (Nat.cast_nonneg B.card) hcore y hy0 hyB hyR hyLap hyF
  unfold FrameBarrierBound
  convert hbar using 2
  ring

end

end Paulsen.Linear
