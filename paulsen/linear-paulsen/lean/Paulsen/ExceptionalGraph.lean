import Paulsen.SchurLaplacian

/-!
# A dense good core and a bounded exceptional set

The graph inverse estimate used by the nonlinear scaling barrier. This theorem
allows exceptional vertices; their contribution depends on their cardinality
and the global spectral gap, with no logarithm of the total number of vertices.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

variable {ι κ : Type*} [Fintype ι] [Fintype κ] [DecidableEq ι] [DecidableEq κ]

/-- After discarding at most one tenth of all vertices, two four-fifths-large
neighbor sets still share at least half of all vertices in the good core. -/
theorem dense_good_neighbor_intersection_half
    (w : Matrix (ι ⊕ κ) (ι ⊕ κ) ℝ) (γ : ℝ)
    (hsmall : 10 * Fintype.card κ ≤ Fintype.card (ι ⊕ κ))
    (hdense : ∀ i : ι, 4 * Fintype.card (ι ⊕ κ) ≤
      5 * (largeNeighbors w γ (Sum.inl i)).card) (i k : ι) :
    Fintype.card (ι ⊕ κ) ≤ 2 *
      ((largeNeighbors w γ (Sum.inl i) ∩ largeNeighbors w γ (Sum.inl k)).toLeft).card := by
  let S := largeNeighbors w γ (Sum.inl i)
  let T := largeNeighbors w γ (Sum.inl k)
  have hu : (S ∪ T).card ≤ Fintype.card (ι ⊕ κ) := Finset.card_le_univ _
  have hc := Finset.card_union_add_card_inter S T
  have hs := Finset.card_toLeft_add_card_toRight (u := S ∩ T)
  have hb : (S ∩ T).toRight.card ≤ Fintype.card κ := Finset.card_le_univ _
  have hi := hdense i
  have hk := hdense k
  change 4 * Fintype.card (ι ⊕ κ) ≤ 5 * S.card at hi
  change 4 * Fintype.card (ι ⊕ κ) ≤ 5 * T.card at hk
  change Fintype.card (ι ⊕ κ) ≤ 2 * (S ∩ T).toLeft.card
  omega

theorem dense_good_neighbors_overlap [Nonempty ι]
    (w : Matrix (ι ⊕ κ) (ι ⊕ κ) ℝ) (γ : ℝ)
    (hγ : 0 < γ) (hw : ∀ i j, 0 ≤ w i j)
    (hsmall : 10 * Fintype.card κ ≤ Fintype.card (ι ⊕ κ))
    (hdense : ∀ i : ι, 4 * Fintype.card (ι ⊕ κ) ≤
      5 * (largeNeighbors w γ (Sum.inl i)).card) (i k : ι) :
    γ / 2 ≤ ∑ j : ι, min (w (Sum.inl i) (Sum.inl j)) (w (Sum.inl k) (Sum.inl j)) := by
  let I := (largeNeighbors w γ (Sum.inl i) ∩ largeNeighbors w γ (Sum.inl k)).toLeft
  have hc : Fintype.card (ι ⊕ κ) ≤ 2 * I.card :=
    dense_good_neighbor_intersection_half w γ hsmall hdense i k
  have hcR : (Fintype.card (ι ⊕ κ) : ℝ) ≤ 2 * (I.card : ℝ) := by exact_mod_cast hc
  have hn : 0 < (Fintype.card (ι ⊕ κ) : ℝ) := Nat.cast_pos.mpr Fintype.card_pos
  have hfrac : (1 : ℝ) / 2 ≤ (I.card : ℝ) / (Fintype.card (ι ⊕ κ) : ℝ) := by
    apply (div_le_div_iff₀ (by norm_num : (0 : ℝ) < 2) hn).mpr
    nlinarith
  have hscaled : γ / 2 ≤ (I.card : ℝ) * (γ / (Fintype.card (ι ⊕ κ) : ℝ)) := by
    have h := mul_le_mul_of_nonneg_left hfrac (le_of_lt hγ)
    calc
      γ / 2 = γ * ((1 : ℝ) / 2) := by ring
      _ ≤ γ * ((I.card : ℝ) / (Fintype.card (ι ⊕ κ) : ℝ)) := h
      _ = (I.card : ℝ) * (γ / (Fintype.card (ι ⊕ κ) : ℝ)) := by ring
  calc
    γ / 2 ≤ (I.card : ℝ) * (γ / (Fintype.card (ι ⊕ κ) : ℝ)) := hscaled
    _ = ∑ j ∈ I, γ / (Fintype.card (ι ⊕ κ) : ℝ) := by simp [nsmul_eq_mul]
    _ ≤ ∑ j ∈ I, min (w (Sum.inl i) (Sum.inl j)) (w (Sum.inl k) (Sum.inl j)) := by
      apply Finset.sum_le_sum
      intro j hj
      have hj' : Sum.inl j ∈ largeNeighbors w γ (Sum.inl i) ∩
          largeNeighbors w γ (Sum.inl k) := Finset.mem_toLeft.mp hj
      exact le_min (Finset.mem_filter.mp (Finset.mem_inter.mp hj').1).2
        (Finset.mem_filter.mp (Finset.mem_inter.mp hj').2).2
    _ ≤ ∑ j, min (w (Sum.inl i) (Sum.inl j)) (w (Sum.inl k) (Sum.inl j)) := by
      apply Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ I)
      intro j _ _
      exact le_min (hw _ _) (hw _ _)

/-- A global gap plus a dense good core gives a bounded Poisson solver, with
an explicit constant independent of the total number of vertices. The factor
depending on the exceptional cardinality is intentionally not optimized. -/
theorem boundedPoisson_of_dense_core_and_gap [Nonempty ι]
    (w : Matrix (ι ⊕ κ) (ι ⊕ κ) ℝ) (γ gap : ℝ)
    (hγ : 0 < γ) (hgapPos : 0 < gap)
    (hw : ∀ i j, 0 ≤ w i j) (hsymm : ∀ i j, w i j = w j i)
    (hmass : ∀ i, (∑ j, w i j) ≤ 1)
    (hsmall : 10 * Fintype.card κ ≤ Fintype.card (ι ⊕ κ))
    (hdense : ∀ i : ι, 4 * Fintype.card (ι ⊕ κ) ≤
      5 * (largeNeighbors w γ (Sum.inl i)).card)
    (hgap : ∀ x : (ι ⊕ κ) → ℝ,
      gap * ((∑ i, x i ^ 2) - (∑ i, x i) ^ 2 / (Fintype.card (ι ⊕ κ) : ℝ)) ≤
        ∑ i, x i * (graphLaplacian w *ᵥ x) i) :
    BoundedPoissonSolvability w
      ((1 + (Fintype.card κ : ℝ)) * (4 / γ) + 2 * (Fintype.card κ : ℝ) / gap) := by
  have hn : 0 < (Fintype.card (ι ⊕ κ) : ℝ) := Nat.cast_pos.mpr Fintype.card_pos
  have hsmallR : 10 * (Fintype.card κ : ℝ) ≤ (Fintype.card (ι ⊕ κ) : ℝ) := by
    exact_mod_cast hsmall
  have hratio : (Fintype.card κ : ℝ) / (Fintype.card (ι ⊕ κ) : ℝ) ≤ 1 / 2 := by
    apply (div_le_iff₀ hn).mpr
    nlinarith [Nat.cast_nonneg (Fintype.card κ) (α := ℝ)]
  have hcoerce : ∀ x : κ → ℝ, (gap / 2) * (∑ i, x i ^ 2) ≤
      ∑ i, x i * ((graphLaplacian w).submatrix Sum.inr Sum.inr *ᵥ x) i := by
    intro x
    have hcoeff : gap / 2 ≤ gap * (1 -
        (Fintype.card κ : ℝ) / (Fintype.card (ι ⊕ κ) : ℝ)) := by
      nlinarith
    exact (mul_le_mul_of_nonneg_right hcoeff (Finset.sum_nonneg (fun i _ => sq_nonneg (x i)))).trans
      (killed_coercivity_of_gap (graphLaplacian w) gap (le_of_lt hgapPos) hgap x)
  have hsolve := boundedPoisson_of_coercive_exceptional_block w (γ / 2) (gap / 2)
    (div_pos hγ (by norm_num)) (div_pos hgapPos (by norm_num)) hw hsymm hmass hcoerce
    (dense_good_neighbors_overlap w γ hγ hw hsmall hdense)
  convert hsolve using 1
  ring

end Paulsen
