import Paulsen.Linear.Core
import Paulsen.Linear.Balancing
import Paulsen.HugeSeedAssembly
import Paulsen.LeverageCore

/-!
# Barrier endpoint for the many-row seed

A Parseval frame whose rows outside a set `S` of small total leverage have
many heavy squared-Gram edges has barrier constant `O(1/γ + 1/a)`
(dense core with the explicit exceptional barrier `y = (3/(2a)) 1_S`), so
static balancing corrects its diagonal at linear cost.
-/

namespace Paulsen.Linear

open Paulsen
open scoped BigOperators

variable {ι : Type*} [Fintype ι] [DecidableEq ι]
set_option linter.unusedSectionVars false

/-- Counting form of the core condition, allowing `i` itself in the count. -/
theorem core_of_counts' {w : ι → ι → ℝ} (hw : ∀ i j, 0 ≤ w i j)
    {γ ϑ : ℝ} (hγ : 0 ≤ γ) (i : ι)
    (hcount : (1 / 2 + ϑ) * (Fintype.card ι : ℝ) ≤
      ((Finset.univ.filter (fun j => γ / (Fintype.card ι : ℝ) ≤ w i j)).card : ℝ)) :
    ∀ S : Finset ι, i ∉ S → Fintype.card ι ≤ 2 * S.card →
      ϑ * γ ≤ ∑ j ∈ S, w i j := by
  classical
  intro S _hiS hS
  set n : ℝ := (Fintype.card ι : ℝ) with hn
  set N := Finset.univ.filter (fun j => γ / n ≤ w i j) with hN
  have hn0 : 0 < n := by
    have : 0 < Fintype.card ι := Fintype.card_pos_iff.mpr ⟨i⟩
    rw [hn]; exact_mod_cast this
  have hunion : (N ∪ S).card ≤ Fintype.card ι := Finset.card_le_univ _
  have hinc := Finset.card_union_add_card_inter N S
  have hinterR : ((N.card : ℝ) + S.card) - n ≤ ((N ∩ S).card : ℝ) := by
    have h1 : ((N ∪ S).card : ℝ) ≤ n := by rw [hn]; exact_mod_cast hunion
    have h2 : ((N ∪ S).card : ℝ) + (N ∩ S).card = N.card + S.card := by exact_mod_cast hinc
    linarith
  have hSR : n ≤ 2 * (S.card : ℝ) := by rw [hn]; exact_mod_cast hS
  have hcnt : ϑ * n ≤ ((N ∩ S).card : ℝ) := by nlinarith
  have hlow : ((N ∩ S).card : ℝ) * (γ / n) ≤ ∑ j ∈ S, w i j := by
    calc ((N ∩ S).card : ℝ) * (γ / n) = ∑ j ∈ N ∩ S, γ / n := by
          rw [Finset.sum_const, nsmul_eq_mul]
      _ ≤ ∑ j ∈ N ∩ S, w i j := by
          apply Finset.sum_le_sum; intro j hj
          exact (Finset.mem_filter.mp (Finset.mem_inter.mp hj).1).2
      _ ≤ ∑ j ∈ S, w i j :=
          Finset.sum_le_sum_of_subset_of_nonneg Finset.inter_subset_right
            (fun j _ _ => hw i j)
  have : ϑ * γ = ϑ * n * (γ / n) := by field_simp
  rw [this]
  calc ϑ * n * (γ / n) ≤ ((N ∩ S).card : ℝ) * (γ / n) :=
        mul_le_mul_of_nonneg_right hcnt (by positivity)
    _ ≤ _ := hlow

/-- Barrier-constant form of the exceptional-set correction: dense core off
`S`, total leverage of `S` at most `1/4`. -/
theorem correction_of_exceptional_set_barrier {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (U : Frame n d) (ε γ : ℝ)
    (hU : IsParseval U) (hUn : IsNearlyEqualNorm ε U)
    (hε : 0 ≤ ε) (hγ : 0 < γ) (hγa : γ ≤ (d : ℝ) / n)
    (S : Finset (Fin n)) (htrace : (∑ i ∈ S, rowNormSq U i) ≤ 1 / 4)
    (hdense : ∀ i ∉ S, 4 * n ≤
      5 * (largeNeighbors (fun i j => (frameProjection U i j) ^ 2) γ i).card)
    (hsmall : 112 * ε * ((d : ℝ) / n) ≤ γ) :
    HasCorrection U (8 * ε * (d : ℝ)) := by
  classical
  have hn : 0 < n := lt_of_lt_of_le hd hdn
  letI : NeZero n := ⟨hn.ne'⟩
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  set a : ℝ := (d : ℝ) / n with ha
  have ha0 : 0 < a := by rw [ha]; exact div_pos (by exact_mod_cast hd) hnR
  have hε112 : ε ≤ 1 / 112 := by
    have : 112 * ε * a ≤ 1 * a := by linarith
    have := le_of_mul_le_mul_right this ha0
    linarith
  let w : Fin n → Fin n → ℝ := fun i j => (frameProjection U i j) ^ 2
  have hw : ∀ i j, 0 ≤ w i j := fun i j => sq_nonneg _
  have hsymm : ∀ i j, frameProjection U i j = frameProjection U j i := frameProjection_symm U
  have hproj : frameProjection U * frameProjection U = frameProjection U :=
    hU.frameProjection_idempotent
  have hentry : ∀ i j, w i j ≤ rowNormSq U i * rowNormSq U j := by
    intro i j
    have := projection_entry_sq_le_diagonal_mul (frameProjection U) hsymm hproj i j
    simpa only [w, frameProjection_diagonal] using this
  have hrow : ∀ i, (∑ j, w i j) = rowNormSq U i := hU.projection_row_squares
  have hp_lo : ∀ i, (1 - ε) * a ≤ rowNormSq U i := fun i => (hUn i).1
  have hp_hi : ∀ i, rowNormSq U i ≤ (1 + ε) * a := fun i => (hUn i).2
  have hp0 : ∀ i, 0 ≤ rowNormSq U i := fun i => rowNormSq_nonneg U i
  -- weight into S from any row is at most p_i / 4
  have hinto : ∀ i, (∑ j ∈ S, w i j) ≤ rowNormSq U i / 4 := by
    intro i
    calc (∑ j ∈ S, w i j) ≤ ∑ j ∈ S, rowNormSq U i * rowNormSq U j :=
          Finset.sum_le_sum (fun j _ => hentry i j)
      _ = rowNormSq U i * ∑ j ∈ S, rowNormSq U j := by rw [Finset.mul_sum]
      _ ≤ rowNormSq U i * (1 / 4) := mul_le_mul_of_nonneg_left htrace (hp0 i)
      _ = rowNormSq U i / 4 := by ring
  have hout : ∀ i, i ∈ S → 2 * a / 3 ≤
      ∑ j ∈ Finset.univ.filter (fun j => j ∉ S), w i j := by
    intro i _
    have hsplit := Finset.sum_filter_add_sum_filter_not Finset.univ (fun j => j ∈ S) (w i)
    rw [Finset.filter_mem_eq_inter, Finset.univ_inter, hrow i] at hsplit
    have h1 := hinto i
    have h2 := hp_lo i
    nlinarith
  have hin : ∀ i, i ∉ S → (∑ j ∈ S, w i j) ≤ a / 3 := by
    intro i _
    have h1 := hinto i
    have h2 := hp_hi i
    nlinarith
  obtain ⟨hy0, hyS, hyR, hyLap, hyF⟩ :=
    indicator_exceptional_barrier hw S (l := 2 * a / 3) (μ := a / 3) (by positivity) hout hin
  have hcore : ∀ i, i ∉ S → ∀ S' : Finset (Fin n), i ∉ S' →
      Fintype.card (Fin n) ≤ 2 * S'.card → (3 / 10) * γ ≤ ∑ j ∈ S', w i j := by
    intro i hi
    apply core_of_counts' hw hγ.le i
    have h := hdense i hi
    have hc : (4 : ℝ) * n ≤ 5 * ((largeNeighbors w γ i).card : ℝ) := by exact_mod_cast h
    simp only [Fintype.card_fin]
    unfold largeNeighbors at hc
    simp only [Fintype.card_fin] at hc
    linarith
  have hF : (0 : ℝ) ≤ (a / 3) / (2 * a / 3) := by positivity
  have hbar := core_barrier hw S (κ := 3 / 10 * γ) (by positivity) hF hcore _ hy0 hyS hyR hyLap hyF
  have hFv : (a / 3) / (2 * a / 3) = 1 / 2 := by field_simp
  have hRv : 1 / (2 * a / 3) = 3 / (2 * a) := by field_simp
  rw [hFv, hRv] at hbar
  set H : ℝ := (1 + 1 / 2) / (3 / 10 * γ) + 3 / (2 * a) with hH
  have hβH : ε * a * H ≤ 1 / 2 := by
    have e1 : ε * a * ((1 + 1 / 2) / (3 / 10 * γ)) = 5 * (ε * a) / γ := by
      field_simp; ring
    have e2 : ε * a * (3 / (2 * a)) = 3 / 2 * ε := by field_simp
    have e3 : 5 * (ε * a) / γ ≤ 5 / 112 := by
      rw [div_le_iff₀ hγ]; nlinarith
    rw [hH, mul_add, e1, e2]
    nlinarith
  have herror : ∀ i, |(d : ℝ) / (n : ℝ) - rowNormSq U i| ≤ ε * a := by
    intro i; rw [abs_sub_comm]; exact hUn.abs_error i
  have hcorr := balancing_cost_barrier hn hdn U hU (ε * a) H herror hbar
    (by positivity) hβH
  apply hcorr.mono
  have hs : (∑ i, |(d : ℝ) / (n : ℝ) - rowNormSq U i|) ≤ ∑ _i : Fin n, ε * a :=
    Finset.sum_le_sum (fun i _ => herror i)
  have hsum : (∑ _i : Fin n, ε * a) = ε * (d : ℝ) := by
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, ha]
    field_simp
  linarith

/-- Copy of `correction_of_dense_reference_gram_generic` with the barrier
endpoint. -/
theorem correction_of_dense_reference_gram_barrier {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (V : Frame n d) (A : Frame n n)
    (δ γ ρ B : ℝ) (hVn : IsEqualNorm V)
    (hVp : IsNearlyParseval δ V) (hδ0 : 0 ≤ δ) (hδhalf : δ ≤ 1 / 2)
    (hγ : 0 < γ) (hγa : γ ≤ (d : ℝ) / n) (hρ : 0 < ρ)
    (hdense : ∀ i, 17 * n ≤
      20 * (largeNeighbors (fun i j => (A i j) ^ 2) (4 * γ) i).card)
    (herror : sqDistance A (frameProjection V) ≤ B)
    (hrow : 12 * ((d : ℝ) / n) * δ ^ 2 + 2 * ρ ≤ γ / 20)
    (hleverage : (2 * ((d : ℝ) / n) / ρ) * B ≤ 1 / 4)
    (hsmall : 224 * δ * ((d : ℝ) / n) ≤ γ) :
    HasCorrection V (2 * δ ^ 2 * (d : ℝ) + 32 * δ * (d : ℝ)) := by
  classical
  have hn : 0 < n := lt_of_lt_of_le hd hdn
  letI : NeZero n := ⟨Nat.ne_of_gt hn⟩
  obtain ⟨U, hUp, hUn, hcost, hpolar⟩ :=
    exists_polar_normalization_row_gram V δ hδ0 hδhalf hVn hVp
  let S := Finset.univ.filter (fun i => ρ < rowNormSq (A - frameProjection V) i)
  have hupper (i : Fin n) : rowNormSq U i ≤ 2 * ((d : ℝ) / n) := by
    have hi := (hUn i).2
    have ha : 0 ≤ (d : ℝ) / n := by positivity
    nlinarith
  have htrace : (∑ i ∈ S, rowNormSq U i) ≤ 1 / 4 := by
    have he := exceptional_rows_leverage_le A (frameProjection V) (rowNormSq U) ρ
      (2 * ((d : ℝ) / n)) hρ (by positivity) hupper
    apply he.trans
    apply le_trans _ hleverage
    exact mul_le_mul_of_nonneg_left herror (by positivity)
  have hdenseU (i : Fin n) (hi : i ∉ S) : 4 * n ≤
      5 * (largeNeighbors (fun i j => (frameProjection U i j) ^ 2) γ i).card := by
    have hcut : rowNormSq (A - frameProjection V) i ≤ ρ := by
      simpa only [S, Finset.mem_filter, Finset.mem_univ, true_and, not_lt] using hi
    have hpol : rowNormSq (frameProjection V - frameProjection U) i ≤
        6 * ((d : ℝ) / n) * δ ^ 2 := by
      rw [rowNormSq_sub_comm]
      exact hpolar i
    have herr : (∑ j, (A i j - frameProjection U i j) ^ 2) ≤ γ / 20 := by
      have ht := rowNormSq_sub_triangle A (frameProjection V) (frameProjection U) i
      change rowNormSq (A - frameProjection U) i ≤ γ / 20
      linarith
    simpa only [Fintype.card_fin] using
      dense_neighbors_survive_perturbation A (frameProjection U) γ hγ i (by
        simpa only [Fintype.card_fin] using hdense i) herr
  have hcorr := correction_of_exceptional_set_barrier hd hdn U (2 * δ) γ
    hUp hUn (by positivity) hγ hγa S htrace hdenseU (by nlinarith)
  convert hcorr.transfer hcost using 1
  ring

end Paulsen.Linear
