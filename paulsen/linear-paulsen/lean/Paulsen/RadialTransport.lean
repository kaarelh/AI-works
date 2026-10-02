import Paulsen.Transport
import Paulsen.Definitions
import Mathlib.Data.Finset.Max
import Mathlib.Data.Fintype.Fin
import Mathlib.Tactic.Choose

/-!
# The quadratic distance estimate for an existing radial correction

Positive ordered coordinate multipliers, followed by a positive multiplier
for each row, produce the single crossing used by `Transport.lean`.
The theorems below are conditional: they do not construct a radial correction.
-/

namespace Paulsen

open scoped BigOperators

/-- An increasing finite sequence crosses any fixed threshold at most once.
The cut may be zero or the length of the sequence. -/
theorem monotone_threshold_cut {d : ℕ} (f : Fin d → ℝ)
    (hf : Monotone f) (τ : ℝ) :
    ∃ c : ℕ, c ≤ d ∧
      (∀ i : Fin d, i.val < c → f i ≤ τ) ∧
      (∀ i : Fin d, c ≤ i.val → τ ≤ f i) := by
  classical
  let s : Finset (Fin d) := Finset.univ.filter (fun i => τ < f i)
  by_cases hs : s.Nonempty
  · let k : Fin d := s.min' hs
    have hk : k ∈ s := Finset.min'_mem s hs
    have hfk : τ < f k := (Finset.mem_filter.mp hk).2
    refine ⟨k.val, Nat.le_of_lt k.is_lt, ?_, ?_⟩
    · intro i hi
      by_contra hfi
      have his : i ∈ s := Finset.mem_filter.mpr
        ⟨Finset.mem_univ i, lt_of_not_ge hfi⟩
      have hki : k ≤ i := Finset.min'_le s i his
      exact (not_le_of_gt hi) hki
    · intro i hi
      exact le_trans (le_of_lt hfk) (hf hi)
  · refine ⟨d, le_rfl, ?_, ?_⟩
    · intro i _
      by_contra hfi
      exact hs ⟨i, Finset.mem_filter.mpr
        ⟨Finset.mem_univ i, lt_of_not_ge hfi⟩⟩
    · intro i hi
      exact False.elim ((not_le_of_gt i.is_lt) hi)

/-- A pointwise upper bound gives the corresponding upper bound on a prefix. -/
theorem initialSum_le_mul {d : ℕ} (a : Fin d → ℝ) (η : ℝ)
    (ha : ∀ i, a i ≤ η) (k : ℕ) (hk : k ≤ d) :
    initialSum a k ≤ (k : ℝ) * η := by
  calc
    initialSum a k ≤ ∑ i : Fin d, if i.val < k then η else 0 := by
      apply Finset.sum_le_sum
      intro i _
      split_ifs
      · exact ha i
      · exact le_rfl
    _ = (k : ℝ) * η := by
      rw [← Finset.sum_filter]
      simp [Fin.card_filter_val_lt, min_eq_right hk]

/-- Summing row prefixes is the same as taking a prefix of the column sums. -/
theorem sum_initialSum {m d : ℕ} (a : Fin m → Fin d → ℝ) (k : ℕ) :
    (∑ r : Fin m, initialSum (a r) k) =
      initialSum (fun i => ∑ r : Fin m, a r i) k := by
  unfold initialSum
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i _
  split_ifs <;> simp

/-- Nonnegative increasing radial factors give the same-sign and
single-crossing conditions for squared coordinates. -/
theorem radial_singleCrossing {d : ℕ} (x y f : Fin d → ℝ)
    (hf : Monotone f) (hf_nonneg : ∀ i, 0 ≤ f i)
    (hy : ∀ i, y i = x i * f i) :
    (∀ i, 0 ≤ x i * y i) ∧
      ∃ c : ℕ, c ≤ d ∧
        (∀ i, i.val < c → (y i) ^ 2 ≤ (x i) ^ 2) ∧
        (∀ i, c ≤ i.val → (x i) ^ 2 ≤ (y i) ^ 2) := by
  constructor
  · intro i
    rw [hy i]
    nlinarith [mul_nonneg (sq_nonneg (x i)) (hf_nonneg i)]
  · obtain ⟨c, hc, hleft, hright⟩ := monotone_threshold_cut f hf 1
    refine ⟨c, hc, ?_, ?_⟩
    · intro i hi
      rw [hy i, mul_pow]
      have hfi : (f i) ^ 2 ≤ 1 := by
        nlinarith [hleft i hi, hf_nonneg i]
      simpa using mul_le_mul_of_nonneg_left hfi (sq_nonneg (x i))
    · intro i hi
      rw [hy i, mul_pow]
      have hfi : 1 ≤ (f i) ^ 2 := by
        nlinarith [hright i hi]
      simpa using mul_le_mul_of_nonneg_left hfi (sq_nonneg (x i))

/-- A radial correction with ordered nonnegative coordinate factors has
squared distance at most `η * d * (d - 1)` whenever it preserves every row
mass and every column loses at most `η` squared mass. -/
theorem ordered_radial_transport_bound {m d : ℕ}
    (x y f : Fin m → Fin d → ℝ) (η : ℝ)
    (hf : ∀ r, Monotone (f r))
    (hf_nonneg : ∀ r i, 0 ≤ f r i)
    (hy : ∀ r i, y r i = x r i * f r i)
    (hmass : ∀ r,
      (∑ i : Fin d, (x r i) ^ 2) = ∑ i : Fin d, (y r i) ^ 2)
    (hcolumn : ∀ i : Fin d,
      (∑ r : Fin m, (x r i) ^ 2) - (∑ r : Fin m, (y r i) ^ 2) ≤ η) :
    (∑ r : Fin m, ∑ i : Fin d, (x r i - y r i) ^ 2) ≤
      η * (d : ℝ) * ((d : ℝ) - 1) := by
  classical
  have hcross := fun r => radial_singleCrossing (x r) (y r) (f r)
    (hf r) (hf_nonneg r) (hy r)
  choose c hc hleft hright using fun r => (hcross r).2
  apply summed_coordinate_transport_bound x y c η hc hmass
    (fun r => (hcross r).1) hleft hright
  intro k
  rw [sum_initialSum]
  apply initialSum_le_mul _ η _ k.val (Nat.le_of_lt k.is_lt)
  intro i
  simpa only [Finset.sum_sub_distrib] using hcolumn i

/-- The preceding estimate for a common ordered coordinate scaling and
nonnegative row multipliers. This states a bound on a supplied correction;
existence of that correction is a separate obligation. -/
theorem radial_transport_bound {m d : ℕ}
    (x y : Fin m → Fin d → ℝ) (w : Fin d → ℝ) (r : Fin m → ℝ) (η : ℝ)
    (hw : Monotone w) (hw_nonneg : ∀ i, 0 ≤ w i)
    (hr_nonneg : ∀ j, 0 ≤ r j)
    (hy : ∀ j i, y j i = x j i * (w i * r j))
    (hmass : ∀ j,
      (∑ i : Fin d, (x j i) ^ 2) = ∑ i : Fin d, (y j i) ^ 2)
    (hcolumn : ∀ i : Fin d,
      (∑ j : Fin m, (x j i) ^ 2) - (∑ j : Fin m, (y j i) ^ 2) ≤ η) :
    (∑ j : Fin m, ∑ i : Fin d, (x j i - y j i) ^ 2) ≤
      η * (d : ℝ) * ((d : ℝ) - 1) := by
  apply ordered_radial_transport_bound x y (fun j i => w i * r j) η
    (fun j i k hik => mul_le_mul_of_nonneg_right (hw hik) (hr_nonneg j))
    (fun j i => mul_nonneg (hw_nonneg i) (hr_nonneg j)) hy hmass hcolumn

/-- The quadratic-form definition of nearly Parseval bounds the squared
mass of each column, by testing the corresponding standard basis vector. -/
theorem IsNearlyParseval.columnNormSq_bounds {n d : ℕ}
    {U : Frame n d} {η : ℝ} (hU : IsNearlyParseval η U) (j : Fin d) :
    1 - η ≤ (∑ i : Fin n, U i j ^ 2) ∧
      (∑ i : Fin n, U i j ^ 2) ≤ 1 + η := by
  have h := hU (fun k => if k = j then 1 else 0)
  simpa [frameEnergy, vectorNormSq, mul_ite] using h

/-- A supplied ordered radial correction from an equal-norm nearly Parseval
frame to an equal-norm Parseval frame has the elementary quadratic bound.
The existence of the radial correction is not assumed implicitly: its
coordinate formula is an explicit hypothesis. -/
theorem radial_correction_quadratic_bound {n d : ℕ}
    (U W : Frame n d) (w : Fin d → ℝ) (r : Fin n → ℝ) (η : ℝ)
    (hU_norm : IsEqualNorm U) (hU_parseval : IsNearlyParseval η U)
    (hW : IsEqualNormParseval W)
    (hw : Monotone w) (hw_nonneg : ∀ j, 0 ≤ w j)
    (hr_nonneg : ∀ i, 0 ≤ r i)
    (hW_formula : ∀ i j, W i j = U i j * (w j * r i)) :
    sqDistance U W ≤ η * (d : ℝ) * ((d : ℝ) - 1) := by
  apply radial_transport_bound U W w r η hw hw_nonneg hr_nonneg hW_formula
  · intro i
    exact (hU_norm i).trans (hW.2 i).symm
  · intro j
    have hcolumnW : (∑ i : Fin n, W i j ^ 2) = 1 := by
      simpa [pow_two] using (isParseval_iff_gram W).mp hW.1 j j
    rw [hcolumnW]
    linarith [(hU_parseval.columnNormSq_bounds j).2]

end Paulsen
