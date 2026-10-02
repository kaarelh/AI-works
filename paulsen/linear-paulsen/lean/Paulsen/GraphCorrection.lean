import Paulsen.BoundedScaling
import Paulsen.LeverageCore

/-!
# Direct correction criteria from the initial projection graph

These statements join the proved graph estimates to the static balancing
theorem. They require explicit hypotheses on a Parseval frame;
the probabilistic construction of such frames is a separate obligation.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

variable {ι κ : Type*} [Fintype ι] [Fintype κ] [DecidableEq ι] [DecidableEq κ]

omit [DecidableEq ι] [DecidableEq κ] in
theorem weightedLaplacian_comp_equiv (e : κ ≃ ι) (w : ι → ι → ℝ)
    (g : ι → ℝ) (i : κ) :
    weightedLaplacian (fun a b => w (e a) (e b)) (fun a => g (e a)) i =
      weightedLaplacian w g (e i) := by
  exact e.sum_comp (fun j => w (e i) j * (g (e i) - g j))

omit [DecidableEq ι] [DecidableEq κ] in
/-- Bounded Poisson solvability is unchanged by a relabeling of vertices. -/
theorem BoundedPoissonSolvability.comp_equiv {w : ι → ι → ℝ} {K : ℝ}
    (h : BoundedPoissonSolvability w K) (e : κ ≃ ι) :
    BoundedPoissonSolvability (fun a b => w (e a) (e b)) K := by
  intro f hf hfn
  have hf' : (∑ i, f (e.symm i)) = 0 := by rw [e.symm.sum_comp]; exact hf
  obtain ⟨g, hg, hgn⟩ := h (fun i => f (e.symm i)) hf' (fun i => hfn _)
  refine ⟨fun i => g (e i), ?_, fun i => hgn _⟩
  intro i
  rw [weightedLaplacian_comp_equiv]
  simpa using hg (e i)

omit [DecidableEq ι] [DecidableEq κ] in
theorem boundedPoisson_comp_equiv_iff (e : κ ≃ ι) (w : ι → ι → ℝ) (K : ℝ) :
    BoundedPoissonSolvability (fun a b => w (e a) (e b)) K ↔
      BoundedPoissonSolvability w K := by
  constructor
  · intro h
    simpa only [Equiv.apply_symm_apply] using h.comp_equiv e.symm
  · exact fun h => h.comp_equiv e

/-- Every row having many sufficiently large projection entries gives the
linear Paulsen cost as soon as its diagonal error is small enough. -/
theorem sharp_correction_of_dense_neighbors {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (U : Frame n d) (ε γ : ℝ)
    (hU : IsParseval U)
    (hequal : IsNearlyEqualNorm ε U) (hε : 0 ≤ ε) (hγ : 0 < γ)
    (hdense : ∀ i, 4 * n ≤
      5 * (largeNeighbors (fun i j => (frameProjection U i j) ^ 2) γ i).card)
    (hsmall : 16 * ε * ((d : ℝ) / n) ≤ γ) :
    HasCorrection U (8 * ε * (d : ℝ)) := by
  have hn : 0 < n := lt_of_lt_of_le hd hdn
  letI : NeZero n := ⟨Nat.ne_of_gt hn⟩
  have hsolve := boundedPoisson_of_dense_neighbors
    (fun i j => (frameProjection U i j) ^ 2) γ hγ
    (fun i j => sq_nonneg _) (fun i j => by rw [frameProjection_symm U i j])
    (fun i => by rw [hU.projection_row_squares]; exact hU.leverage_le_one i)
    (by simpa only [Fintype.card_fin] using hdense)
  apply sharp_correction_of_poisson hd hdn U ε (4 / γ)
    hU hequal hε hsolve
  apply (le_div_iff₀ (by norm_num : (0 : ℝ) < 2)).mpr
  have hdiv : (16 * ε * ((d : ℝ) / n)) / γ ≤ 1 :=
    (div_le_one hγ).mpr hsmall
  calc
    _ = (16 * ε * ((d : ℝ) / n)) / γ := by ring
    _ ≤ 1 := hdiv

/-- Relabeling the rows allows the small-exceptional-leverage graph theorem
to apply to an actual frame, with no graph-solvability assumption remaining. -/
theorem sharp_correction_of_small_exceptional_leverage
    [Nonempty ι] {n d : ℕ} (e : (ι ⊕ κ) ≃ Fin n)
    (hd : 0 < d) (hdn : d ≤ n) (U : Frame n d) (ε γ : ℝ)
    (hU : IsParseval U)
    (hequal : IsNearlyEqualNorm ε U) (hε : 0 ≤ ε)
    (hγ : 0 < γ) (hγa : γ ≤ (d : ℝ) / n)
    (htrace : (∑ j : κ, rowNormSq U (e (Sum.inr j))) ≤ 1 / 4)
    (hbad : 10 * Fintype.card κ ≤ n)
    (hdense : ∀ i : ι, 4 * n ≤ 5 *
      (largeNeighbors (fun a b => (frameProjection U (e a) (e b)) ^ 2)
        γ (Sum.inl i)).card)
    (hsmall : 112 * ε * ((d : ℝ) / n) ≤ γ) :
    HasCorrection U (8 * ε * (d : ℝ)) := by
  let a : ℝ := (d : ℝ) / n
  let P := (frameProjection U).submatrix e e
  have ha : 0 < a := div_pos (Nat.cast_pos.mpr hd)
    (Nat.cast_pos.mpr (lt_of_lt_of_le hd hdn))
  have hcard : Fintype.card (ι ⊕ κ) = n := by
    simpa using Fintype.card_congr e
  have hsymm : ∀ i j, P i j = P j i :=
    fun i j => frameProjection_symm U (e i) (e j)
  have hproj : P * P = P := by
    dsimp [P]
    rw [Matrix.submatrix_mul_equiv, hU.frameProjection_idempotent]
  have hlower : ∀ i, a / 2 ≤ P i i := by
    intro i
    change a / 2 ≤ frameProjection U (e i) (e i)
    rw [frameProjection_diagonal]
    have hi := (hequal (e i)).1
    change (1 - ε) * a ≤ _ at hi
    nlinarith
  have hupper : ∀ i, P i i ≤ 2 * a := by
    intro i
    change frameProjection U (e i) (e i) ≤ 2 * a
    rw [frameProjection_diagonal]
    have hi := (hequal (e i)).2
    change _ ≤ (1 + ε) * a at hi
    nlinarith
  have hsolve := boundedPoisson_of_small_exceptional_leverage_uniform P a γ
    ha hγ hγa hsymm hproj hlower hupper
    (by simpa only [P, Matrix.submatrix_apply, frameProjection_diagonal] using htrace)
    (by simpa only [hcard] using hbad)
    (by simpa only [hcard, P, Matrix.submatrix_apply] using hdense)
  have hsolve' : BoundedPoissonSolvability
      (fun i j => (frameProjection U i j) ^ 2) (28 / γ) :=
    (boundedPoisson_comp_equiv_iff e _ _).mp hsolve
  apply sharp_correction_of_poisson hd hdn U ε (28 / γ)
    hU hequal hε hsolve'
  apply (le_div_iff₀ (by norm_num : (0 : ℝ) < 2)).mpr
  have hdiv : (112 * ε * ((d : ℝ) / n)) / γ ≤ 1 :=
    (div_le_one hγ).mpr hsmall
  calc
    _ = (112 * ε * ((d : ℝ) / n)) / γ := by ring
    _ ≤ 1 := hdiv

/-- The complementary criterion used by the moderate-row seed: a dense
good core, a bounded exceptional set, and a global spectral gap. -/
theorem sharp_correction_of_dense_core_and_gap
    [Nonempty ι] {n d : ℕ} (e : (ι ⊕ κ) ≃ Fin n)
    (hd : 0 < d) (hdn : d ≤ n) (U : Frame n d) (ε γ gap : ℝ)
    (hU : IsParseval U)
    (hequal : IsNearlyEqualNorm ε U) (hε : 0 ≤ ε)
    (hγ : 0 < γ) (hgapPos : 0 < gap)
    (hbad : 10 * Fintype.card κ ≤ n)
    (hdense : ∀ i : ι, 4 * n ≤ 5 *
      (largeNeighbors (fun a b => (frameProjection U (e a) (e b)) ^ 2)
        γ (Sum.inl i)).card)
    (hgap : ∀ x : (ι ⊕ κ) → ℝ,
      gap * ((∑ i, x i ^ 2) - (∑ i, x i) ^ 2 / (n : ℝ)) ≤
        ∑ i, x i * (graphLaplacian
          (fun a b => (frameProjection U (e a) (e b)) ^ 2) *ᵥ x) i)
    (hsmall : 2 * (ε * ((d : ℝ) / n)) *
      ((1 + (Fintype.card κ : ℝ)) * (4 / γ) + 2 * (Fintype.card κ : ℝ) / gap) ≤ 1 / 2) :
    HasCorrection U (8 * ε * (d : ℝ)) := by
  have hcard : Fintype.card (ι ⊕ κ) = n := by
    simpa using Fintype.card_congr e
  have hmass : ∀ i : ι ⊕ κ, (∑ j, (frameProjection U (e i) (e j)) ^ 2) ≤ 1 := by
    intro i
    rw [e.sum_comp (fun j => (frameProjection U (e i) j) ^ 2), hU.projection_row_squares]
    exact hU.leverage_le_one _
  have hsolve := boundedPoisson_of_dense_core_and_gap
    (fun a b => (frameProjection U (e a) (e b)) ^ 2) γ gap hγ hgapPos
    (fun i j => sq_nonneg _) (fun i j => by rw [frameProjection_symm U (e i) (e j)])
    hmass (by simpa only [hcard] using hbad)
    (by simpa only [hcard] using hdense) (by simpa only [hcard] using hgap)
  exact sharp_correction_of_poisson hd hdn U ε _ hU hequal hε
    ((boundedPoisson_comp_equiv_iff e _ _).mp hsolve) hsmall

/-- Compatibility form; the full-spark assumption is unused. -/
theorem fullSpark_sharp_correction_of_dense_neighbors {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (U : Frame n d) (ε γ : ℝ)
    (_hU_spark : IsFullSpark U) (hU : IsParseval U)
    (hequal : IsNearlyEqualNorm ε U) (hε : 0 ≤ ε) (hγ : 0 < γ)
    (hdense : ∀ i, 4 * n ≤
      5 * (largeNeighbors (fun i j => (frameProjection U i j) ^ 2) γ i).card)
    (hsmall : 16 * ε * ((d : ℝ) / n) ≤ γ) :
    HasCorrection U (8 * ε * (d : ℝ)) := by
  exact sharp_correction_of_dense_neighbors hd hdn U ε γ hU hequal hε hγ hdense hsmall

/-- Compatibility form; the full-spark assumption is unused. -/
theorem fullSpark_sharp_correction_of_small_exceptional_leverage
    [Nonempty ι] {n d : ℕ} (e : (ι ⊕ κ) ≃ Fin n)
    (hd : 0 < d) (hdn : d ≤ n) (U : Frame n d) (ε γ : ℝ)
    (_hU_spark : IsFullSpark U) (hU : IsParseval U)
    (hequal : IsNearlyEqualNorm ε U) (hε : 0 ≤ ε)
    (hγ : 0 < γ) (hγa : γ ≤ (d : ℝ) / n)
    (htrace : (∑ j : κ, rowNormSq U (e (Sum.inr j))) ≤ 1 / 4)
    (hbad : 10 * Fintype.card κ ≤ n)
    (hdense : ∀ i : ι, 4 * n ≤ 5 *
      (largeNeighbors (fun a b => (frameProjection U (e a) (e b)) ^ 2)
        γ (Sum.inl i)).card)
    (hsmall : 112 * ε * ((d : ℝ) / n) ≤ γ) :
    HasCorrection U (8 * ε * (d : ℝ)) := by
  exact sharp_correction_of_small_exceptional_leverage e hd hdn U ε γ hU hequal hε hγ hγa htrace hbad hdense hsmall

/-- Compatibility form; the full-spark assumption is unused. -/
theorem fullSpark_sharp_correction_of_dense_core_and_gap
    [Nonempty ι] {n d : ℕ} (e : (ι ⊕ κ) ≃ Fin n)
    (hd : 0 < d) (hdn : d ≤ n) (U : Frame n d) (ε γ gap : ℝ)
    (_hU_spark : IsFullSpark U) (hU : IsParseval U)
    (hequal : IsNearlyEqualNorm ε U) (hε : 0 ≤ ε)
    (hγ : 0 < γ) (hgapPos : 0 < gap)
    (hbad : 10 * Fintype.card κ ≤ n)
    (hdense : ∀ i : ι, 4 * n ≤ 5 *
      (largeNeighbors (fun a b => (frameProjection U (e a) (e b)) ^ 2)
        γ (Sum.inl i)).card)
    (hgap : ∀ x : (ι ⊕ κ) → ℝ,
      gap * ((∑ i, x i ^ 2) - (∑ i, x i) ^ 2 / (n : ℝ)) ≤
        ∑ i, x i * (graphLaplacian
          (fun a b => (frameProjection U (e a) (e b)) ^ 2) *ᵥ x) i)
    (hsmall : 2 * (ε * ((d : ℝ) / n)) *
      ((1 + (Fintype.card κ : ℝ)) * (4 / γ) + 2 * (Fintype.card κ : ℝ) / gap) ≤ 1 / 2) :
    HasCorrection U (8 * ε * (d : ℝ)) := by
  exact sharp_correction_of_dense_core_and_gap e hd hdn U ε γ gap hU hequal hε hγ hgapPos hbad hdense hgap hsmall

end Paulsen
