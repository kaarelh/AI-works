import Paulsen.DenseCore

/-!
# Dense projection entries survive small row perturbations

This finite counting estimate transfers a dense core from a seed Gram matrix
to its conditioned or normalized counterpart. It uses squared errors directly.
-/

namespace Paulsen

open scoped BigOperators

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

theorem sq_sub_ge_of_large_and_small (a b τ : ℝ)
    (ha : 4 * τ ≤ a ^ 2) (hb : b ^ 2 < τ) : τ ≤ (a - b) ^ 2 := by
  nlinarith [sq_nonneg (a - 2 * b)]

/-- Each lost large entry consumes at least τ of squared perturbation energy. -/
theorem lost_large_entries_energy_le (u v : ι → ℝ) (τ : ℝ) :
    τ * ((Finset.univ.filter (fun i => 4 * τ ≤ u i ^ 2) \
      Finset.univ.filter (fun i => τ ≤ v i ^ 2)).card : ℝ) ≤
      ∑ i, (u i - v i) ^ 2 := by
  classical
  let S := Finset.univ.filter (fun i => 4 * τ ≤ u i ^ 2) \
    Finset.univ.filter (fun i => τ ≤ v i ^ 2)
  have hlost : ∀ i ∈ S, τ ≤ (u i - v i) ^ 2 := by
    intro i hi
    obtain ⟨hu, hv⟩ := Finset.mem_sdiff.mp hi
    apply sq_sub_ge_of_large_and_small _ _ _ (Finset.mem_filter.mp hu).2
    simpa only [Finset.mem_filter, Finset.mem_univ, true_and, not_le] using hv
  calc
    _ = ∑ _i ∈ S, τ := by simp [S, nsmul_eq_mul, mul_comm]
    _ ≤ ∑ i ∈ S, (u i - v i) ^ 2 := Finset.sum_le_sum hlost
    _ ≤ ∑ i, (u i - v i) ^ 2 := Finset.sum_le_sum_of_subset_of_nonneg
      (Finset.subset_univ S) (fun i _ _ => sq_nonneg _)

/-- A row with at least 85% large entries retains at least 80% after a
perturbation with row energy at most nτ/20, at one quarter the squared threshold. -/
theorem dense_row_survives_perturbation (u v : ι → ℝ) (τ : ℝ) (hτ : 0 < τ)
    (hdense : 17 * Fintype.card ι ≤
      20 * (Finset.univ.filter (fun i => 4 * τ ≤ u i ^ 2)).card)
    (herror : (∑ i, (u i - v i) ^ 2) ≤ τ * (Fintype.card ι : ℝ) / 20) :
    4 * Fintype.card ι ≤ 5 * (Finset.univ.filter (fun i => τ ≤ v i ^ 2)).card := by
  classical
  let S := Finset.univ.filter (fun i => 4 * τ ≤ u i ^ 2)
  let T := Finset.univ.filter (fun i => τ ≤ v i ^ 2)
  have he := (lost_large_entries_energy_le u v τ).trans herror
  have hcardR : 20 * ((S \ T).card : ℝ) ≤ (Fintype.card ι : ℝ) := by
    change τ * ((S \ T).card : ℝ) ≤ τ * (Fintype.card ι : ℝ) / 20 at he
    nlinarith
  have hcard : 20 * (S \ T).card ≤ Fintype.card ι := by exact_mod_cast hcardR
  have hcover : S.card ≤ (S \ T).card + T.card := Finset.card_le_card_sdiff_add_card
  change 17 * Fintype.card ι ≤ 20 * S.card at hdense
  change 4 * Fintype.card ι ≤ 5 * T.card
  omega

/-- The same estimate in the graph-threshold convention γ/n. -/
theorem dense_neighbors_survive_perturbation [Nonempty ι]
    (A B : Matrix ι ι ℝ) (γ : ℝ) (hγ : 0 < γ) (i : ι)
    (hdense : 17 * Fintype.card ι ≤
      20 * (largeNeighbors (fun i j => (A i j) ^ 2) (4 * γ) i).card)
    (herror : (∑ j, (A i j - B i j) ^ 2) ≤ γ / 20) :
    4 * Fintype.card ι ≤
      5 * (largeNeighbors (fun i j => (B i j) ^ 2) γ i).card := by
  have hn : 0 < (Fintype.card ι : ℝ) := Nat.cast_pos.mpr Fintype.card_pos
  apply dense_row_survives_perturbation (A i) (B i) (γ / Fintype.card ι)
    (div_pos hγ hn)
  · simpa only [largeNeighbors, mul_div_assoc] using hdense
  · simpa only [div_mul_cancel₀ γ (ne_of_gt hn)] using herror

omit [DecidableEq ι] in
/-- The rows excluded by an energy cutoff have bounded cardinality. -/
theorem exceptional_rows_energy_le {κ : Type*} [Fintype κ]
    (A B : Matrix ι κ ℝ) (ρ : ℝ) :
    ρ * ((Finset.univ.filter (fun i => ρ < ∑ j, (A i j - B i j) ^ 2)).card : ℝ) ≤
      ∑ i, ∑ j, (A i j - B i j) ^ 2 := by
  classical
  let S := Finset.univ.filter (fun i => ρ < ∑ j, (A i j - B i j) ^ 2)
  calc
    _ = ∑ _i ∈ S, ρ := by simp [S, nsmul_eq_mul, mul_comm]
    _ ≤ ∑ i ∈ S, ∑ j, (A i j - B i j) ^ 2 :=
      Finset.sum_le_sum (fun i hi => (Finset.mem_filter.mp hi).2.le)
    _ ≤ ∑ i, ∑ j, (A i j - B i j) ^ 2 := Finset.sum_le_sum_of_subset_of_nonneg
      (Finset.subset_univ S) (fun i _ _ => Finset.sum_nonneg (fun j _ => sq_nonneg _))

omit [DecidableEq ι] in
/-- A uniform leverage upper bound turns the total perturbation energy
into a bound on the total leverage of excluded rows. -/
theorem exceptional_rows_leverage_le {κ : Type*} [Fintype κ]
    (A B : Matrix ι κ ℝ) (p : ι → ℝ) (ρ M : ℝ)
    (hρ : 0 < ρ) (hM : 0 ≤ M) (hp : ∀ i, p i ≤ M) :
    (∑ i ∈ Finset.univ.filter (fun i => ρ < ∑ j, (A i j - B i j) ^ 2), p i) ≤
      (M / ρ) * (∑ i, ∑ j, (A i j - B i j) ^ 2) := by
  classical
  let S := Finset.univ.filter (fun i => ρ < ∑ j, (A i j - B i j) ^ 2)
  have he := exceptional_rows_energy_le A B ρ
  have hcard : (S.card : ℝ) ≤ (∑ i, ∑ j, (A i j - B i j) ^ 2) / ρ := by
    apply (le_div_iff₀ hρ).mpr
    simpa only [mul_comm] using he
  calc
    _ ≤ ∑ _i ∈ S, M := Finset.sum_le_sum (fun i _ => hp i)
    _ = M * (S.card : ℝ) := by simp [nsmul_eq_mul, mul_comm]
    _ ≤ M * ((∑ i, ∑ j, (A i j - B i j) ^ 2) / ρ) :=
      mul_le_mul_of_nonneg_left hcard hM
    _ = _ := by ring

end Paulsen
