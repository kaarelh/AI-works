import NeuralGeneralization.FiniteParameterGrid
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Algebra.Order.BigOperators.Ring.Finset
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Tactic.Ring

/-!
# A finite grid for low-rank matrix witnesses

A rank-`R` factorization has `R(2N+1)` scalar parameters. Rounding each
bounded parameter on a concrete grid approximates its actual matrix in
squared Frobenius norm. No singular-value decomposition or matrix entropy
estimate is assumed here.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.LowRankGrid

open ParameterGrid

abbrev FactorIndex (N R : ℕ) := Fin R ⊕ ((Fin N × Fin R) ⊕ (Fin N × Fin R))

def factorMatrix {N R : ℕ} (p : FactorIndex N R → ℝ) : Fin N × Fin N → ℝ :=
  fun ij => ∑ l : Fin R,
    p (.inl l) * p (.inr (.inl (ij.1, l))) * p (.inr (.inr (ij.2, l)))

def squaredSum {ι : Type*} [Fintype ι] (z : ι → ℝ) : ℝ := ∑ i, z i ^ 2

theorem factorIndex_card (N R : ℕ) : Fintype.card (FactorIndex N R) = R * (2 * N + 1) := by
  simp only [FactorIndex, Fintype.card_sum, Fintype.card_prod, Fintype.card_fin]
  ring

theorem triple_product_stability (a b c a' b' c' δ : ℝ) (hδ : 0 ≤ δ)
    (_ha : |a| ≤ 1) (hb : |b| ≤ 1) (hc : |c| ≤ 1)
    (ha' : |a'| ≤ 1) (hb' : |b'| ≤ 1)
    (hda : |a - a'| ≤ δ) (hdb : |b - b'| ≤ δ) (hdc : |c - c'| ≤ δ) :
    |a * b * c - a' * b' * c'| ≤ 3 * δ := by
  have h1 : |(a - a') * b * c| ≤ δ := by
    rw [abs_mul, abs_mul]
    calc
      _ ≤ δ * 1 * 1 :=
        mul_le_mul (mul_le_mul hda hb (abs_nonneg _) hδ) hc (abs_nonneg _) (by positivity)
      _ = _ := by ring
  have h2 : |a' * (b - b') * c| ≤ δ := by
    rw [abs_mul, abs_mul]
    calc
      _ ≤ 1 * δ * 1 :=
        mul_le_mul (mul_le_mul ha' hdb (abs_nonneg _) (by norm_num)) hc
          (abs_nonneg _) (by positivity)
      _ = _ := by ring
  have h3 : |a' * b' * (c - c')| ≤ δ := by
    rw [abs_mul, abs_mul]
    calc
      _ ≤ 1 * 1 * δ :=
        mul_le_mul (mul_le_mul ha' hb' (abs_nonneg _) (by norm_num)) hdc
          (abs_nonneg _) (by norm_num)
      _ = _ := by ring
  have heq : a * b * c - a' * b' * c' =
      (a - a') * b * c + a' * (b - b') * c + a' * b' * (c - c') := by ring
  rw [heq]
  linarith [abs_add_le ((a - a') * b * c) (a' * (b - b') * c),
    abs_add_le ((a - a') * b * c + a' * (b - b') * c) (a' * b' * (c - c'))]

theorem factorMatrix_stability {N R : ℕ} (p q : FactorIndex N R → ℝ)
    (hp : ∀ i, |p i| ≤ 1) (hq : ∀ i, |q i| ≤ 1)
    (δ : ℝ) (hδ : 0 ≤ δ) (hclose : ∀ i, |p i - q i| ≤ δ)
    (ij : Fin N × Fin N) :
    |factorMatrix p ij - factorMatrix q ij| ≤ 3 * R * δ := by
  unfold factorMatrix
  rw [← Finset.sum_sub_distrib]
  calc
    _ ≤ ∑ l : Fin R, |p (.inl l) * p (.inr (.inl (ij.1, l))) * p (.inr (.inr (ij.2, l))) -
        q (.inl l) * q (.inr (.inl (ij.1, l))) * q (.inr (.inr (ij.2, l)))| :=
      Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _l : Fin R, 3 * δ := by
      apply Finset.sum_le_sum
      intro l hl
      exact triple_product_stability _ _ _ _ _ _ δ hδ
        (hp _) (hp _) (hp _) (hq _) (hq _) (hclose _) (hclose _) (hclose _)
    _ = _ := by simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]; ring

theorem squaredSum_nonneg {ι : Type*} [Fintype ι] (z : ι → ℝ) : 0 ≤ squaredSum z :=
  Finset.sum_nonneg (fun _ _ => sq_nonneg _)

theorem squaredSum_le_of_abs_le {ι : Type*} [Fintype ι] (z : ι → ℝ)
    (a : ℝ) (ha : 0 ≤ a) (hz : ∀ i, |z i| ≤ a) :
    squaredSum z ≤ Fintype.card ι * a ^ 2 := by
  calc
    _ ≤ ∑ _i : ι, a ^ 2 := by
      apply Finset.sum_le_sum
      intro i hi
      simpa only [sq_abs] using (sq_le_sq₀ (abs_nonneg _) ha).mpr (hz i)
    _ = _ := by simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

theorem squaredSum_perturbation {ι : Type*} [Fintype ι] (p q : ι → ℝ) :
    squaredSum q ≤ 2 * squaredSum p + 2 * squaredSum (fun i => p i - q i) := by
  unfold squaredSum
  rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro i hi
  nlinarith [sq_nonneg (2 * p i - q i)]

def gridMesh (N : ℕ) : ℕ := 6 * N ^ 3

theorem grid_error {N R : ℕ} (hN : 0 < N) (hR : R ≤ N)
    (p : FactorIndex N R → ℝ) (hp : ∀ i, |p i| ≤ 1)
    (q : FactorIndex N R → GridInt (gridMesh N))
    (hclose : ∀ i, |p i - decode (gridMesh N) q i| ≤ 1 / (gridMesh N : ℝ)) :
    squaredSum (fun ij => factorMatrix p ij - factorMatrix (decode (gridMesh N) q) ij) ≤
      1 / (4 * (N : ℝ) ^ 2) := by
  have hn : (0 : ℝ) < N := by exact_mod_cast hN
  have hr : (R : ℝ) ≤ N := by exact_mod_cast hR
  have ht : 0 < gridMesh N := by unfold gridMesh; positivity
  have hbound : 3 * (R : ℝ) * (1 / (gridMesh N : ℝ)) ≤ 1 / (2 * (N : ℝ) ^ 2) := by
    have hmul := mul_le_mul_of_nonneg_right
      (mul_le_mul_of_nonneg_left hr (by norm_num : (0 : ℝ) ≤ 3))
      (by positivity : 0 ≤ 1 / (gridMesh N : ℝ))
    calc
      _ ≤ 3 * (N : ℝ) * (1 / (gridMesh N : ℝ)) := hmul
      _ = _ := by unfold gridMesh; push_cast; field_simp; ring
  have he := squaredSum_le_of_abs_le
    (fun ij => factorMatrix p ij - factorMatrix (decode (gridMesh N) q) ij)
    (1 / (2 * (N : ℝ) ^ 2)) (by positivity)
    (fun ij => (factorMatrix_stability p (decode (gridMesh N) q) hp
      (decode_abs_le_one _ ht q) _ (by positivity) hclose ij).trans hbound)
  simp only [Fintype.card_prod, Fintype.card_fin, Nat.cast_mul] at he
  refine he.trans_eq ?_
  field_simp
  ring

/-- Discard grid matrices with squared norm greater than four. Every actual
unit-norm witness still has an approximant in this concrete finite set. -/
def candidates (N R : ℕ) : Finset (Fin N × Fin N → ℝ) := by
  classical
  exact ((Finset.univ : Finset (FactorIndex N R → GridInt (gridMesh N))).image
    (fun q => factorMatrix (decode (gridMesh N) q))).filter (fun z => squaredSum z ≤ 4)

theorem candidates_card (N R : ℕ) :
    (candidates N R).card ≤ (2 * gridMesh N + 1) ^ (R * (2 * N + 1)) := by
  classical
  unfold candidates
  calc
    _ ≤ ((Finset.univ : Finset (FactorIndex N R → GridInt (gridMesh N))).image
        (fun q => factorMatrix (decode (gridMesh N) q))).card := Finset.card_filter_le _ _
    _ ≤ (Finset.univ : Finset (FactorIndex N R → GridInt (gridMesh N))).card :=
      Finset.card_image_le
    _ = _ := by
      rw [Finset.card_univ, Fintype.card_fun, gridInt_card, factorIndex_card]

theorem candidates_squaredSum_le (N R : ℕ) (z : Fin N × Fin N → ℝ)
    (hz : z ∈ candidates N R) : squaredSum z ≤ 4 := by
  classical
  exact (Finset.mem_filter.mp hz).2

/-- A complete explicit finite covering of all bounded rank-factor witnesses
of squared Frobenius norm at most one. -/
theorem exists_candidate_close {N R : ℕ} (hN : 0 < N) (hR : R ≤ N)
    (p : FactorIndex N R → ℝ) (hp : ∀ i, |p i| ≤ 1)
    (henergy : squaredSum (factorMatrix p) ≤ 1) :
    ∃ z ∈ candidates N R,
      squaredSum (fun ij => factorMatrix p ij - z ij) ≤ 1 / (4 * (N : ℝ) ^ 2) := by
  classical
  have ht : 0 < gridMesh N := by unfold gridMesh; positivity
  obtain ⟨q, hq⟩ := exists_close_grid (gridMesh N) ht p hp
  have he := grid_error hN hR p hp q hq
  have hn : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hn2 : (1 : ℝ) ≤ (N : ℝ) ^ 2 := by nlinarith
  have hinv : 1 / (4 * (N : ℝ) ^ 2) ≤ (1 / 4 : ℝ) :=
    one_div_le_one_div_of_le (by norm_num) (by nlinarith)
  have hsmall : squaredSum (factorMatrix (decode (gridMesh N) q)) ≤ 4 := by
    have hh := squaredSum_perturbation (factorMatrix p) (factorMatrix (decode (gridMesh N) q))
    linarith
  refine ⟨factorMatrix (decode (gridMesh N) q), ?_, he⟩
  apply Finset.mem_filter.mpr
  refine ⟨?_, hsmall⟩
  exact Finset.mem_image.mpr ⟨q, Finset.mem_univ q, rfl⟩

end NeuralGeneralization.LowRankGrid
