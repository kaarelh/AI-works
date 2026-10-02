import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Data.Finset.Powerset
import Mathlib.Data.Fintype.Powerset
import Mathlib.Data.Nat.Choose.Cast
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith

/-!
# Finite-population second moments

The main lemma computes the second moment of a weighted sample from its exact
pairwise inclusion moments.  The probability space is a finite weighted sum;
no independence or concentration hypothesis is used.
-/

open scoped BigOperators

noncomputable section

namespace Paulsen

section SubsetCounts

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The exact number of samples containing one specified index. -/
theorem count_subsets_containing_one (q : ℕ) (hq : 1 ≤ q) (i : ι) :
    (((Finset.univ : Finset ι).powersetCard q).filter (fun s => i ∈ s)).card =
      (Fintype.card ι - 1).choose (q - 1) := by
  simpa using Finset.card_filter_powersetCard_subset
    ({i} : Finset ι) Finset.univ q (Finset.subset_univ _) (by simpa using hq)

/-- The exact number of samples containing two distinct specified indices. -/
theorem count_subsets_containing_pair (q : ℕ) (hq : 2 ≤ q)
    (i j : ι) (hij : i ≠ j) :
    (((Finset.univ : Finset ι).powersetCard q).filter
      (fun s => i ∈ s ∧ j ∈ s)).card =
      (Fintype.card ι - 2).choose (q - 2) := by
  simpa [Finset.insert_subset_iff, hij] using Finset.card_filter_powersetCard_subset
    ({i, j} : Finset ι) Finset.univ q (Finset.subset_univ _) (by simpa [hij] using hq)

/-- Dividing the one-index sample count by the total number of samples gives
the familiar inclusion probability `q / n`. -/
theorem choose_ratio_one (n q : ℕ) (hq : 1 ≤ q) (hqn : q ≤ n) :
    ((n - 1).choose (q - 1) : ℝ) / (n.choose q : ℝ) = (q : ℝ) / n := by
  have hn : (n : ℝ) ≠ 0 := by
    have hn' : 0 < n := lt_of_lt_of_le Nat.zero_lt_one (hq.trans hqn)
    exact_mod_cast hn'.ne'
  have hc : (n.choose q : ℝ) ≠ 0 := by
    exact_mod_cast (Nat.choose_pos hqn).ne'
  have h : (n.choose q : ℝ) * q = n * ((n - 1).choose (q - 1) : ℝ) := by
    exact_mod_cast (by simpa using (Nat.choose_mul (n := n) (k := q) (s := 1) hq))
  apply (div_eq_div_iff hc hn).2
  nlinarith [h]

/-- The two-index inclusion probability for sampling without replacement. -/
theorem choose_ratio_two (n q : ℕ) (hq : 2 ≤ q) (hqn : q ≤ n) :
    ((n - 2).choose (q - 2) : ℝ) / (n.choose q : ℝ) =
      (q : ℝ) * (q - 1) / ((n : ℝ) * (n - 1)) := by
  have hn' : (1 : ℝ) < n := by
    exact_mod_cast (lt_of_lt_of_le (by decide : 1 < 2) (hq.trans hqn))
  have hn : (n : ℝ) ≠ 0 := by linarith
  have hn1 : (n : ℝ) - 1 ≠ 0 := by linarith
  have hc : (n.choose q : ℝ) ≠ 0 := by
    exact_mod_cast (Nat.choose_pos hqn).ne'
  have h : (n.choose q : ℝ) * (q.choose 2 : ℝ) =
      (n.choose 2 : ℝ) * ((n - 2).choose (q - 2) : ℝ) := by
    exact_mod_cast (Nat.choose_mul (n := n) (k := q) (s := 2) hq)
  simp only [Nat.cast_choose_two] at h
  apply (div_eq_div_iff hc (mul_ne_zero hn hn1)).2
  nlinarith [h]

/-- Both moments of the actual uniform subset law, expressed as a finite sum. -/
theorem uniform_subset_pair_moment (q : ℕ) (hq : 2 ≤ q)
    (hqn : q ≤ Fintype.card ι) (i j : ι) :
    (∑ s ∈ (Finset.univ : Finset ι).powersetCard q,
      ((Fintype.card ι).choose q : ℝ)⁻¹ *
        (if i ∈ s then 1 else 0) * (if j ∈ s then 1 else 0)) =
      if i = j then (q : ℝ) / Fintype.card ι
      else (q : ℝ) * (q - 1) /
        ((Fintype.card ι : ℝ) * (Fintype.card ι - 1)) := by
  have hprod (s : Finset ι) :
      ((Fintype.card ι).choose q : ℝ)⁻¹ *
        (if i ∈ s then 1 else 0) * (if j ∈ s then 1 else 0) =
      ((Fintype.card ι).choose q : ℝ)⁻¹ *
        (if i ∈ s ∧ j ∈ s then 1 else 0) := by
    by_cases hi : i ∈ s <;> by_cases hj : j ∈ s <;> simp [hi, hj]
  simp_rw [hprod]
  rw [← Finset.mul_sum, Finset.sum_boole]
  by_cases hij : i = j
  · subst j
    simp only [and_self, if_true]
    rw [count_subsets_containing_one q (by omega) i]
    simpa [div_eq_mul_inv, mul_comm] using choose_ratio_one (Fintype.card ι) q (by omega) hqn
  · rw [count_subsets_containing_pair q hq i j hij, if_neg hij]
    simpa [div_eq_mul_inv, mul_comm] using choose_ratio_two (Fintype.card ι) q hq hqn

end SubsetCounts

variable {ι Ω E : Type*} [Fintype ι] [Fintype Ω] [DecidableEq ι]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E]

omit [Fintype Ω] [DecidableEq ι] in
/-- Centering makes the sum of all pairwise inner products vanish. -/
theorem centered_pair_sum (v : ι → E) (hcenter : ∑ i, v i = 0) :
    (∑ i, ∑ j, inner ℝ (v i) (v j)) = 0 := by
  calc
    (∑ i, ∑ j, inner ℝ (v i) (v j)) = inner ℝ (∑ i, v i) (∑ j, v j) := by
      simp only [sum_inner, inner_sum]
      rw [Finset.sum_comm]
    _ = 0 := by rw [hcenter]; simp

omit [Fintype Ω] in
/-- The off-diagonal inner products cancel the diagonal energy exactly. -/
theorem centered_offDiagonal_sum (v : ι → E) (hcenter : ∑ i, v i = 0) :
    (∑ i, ∑ j, if i = j then 0 else inner ℝ (v i) (v j)) =
      -(∑ i, ‖v i‖ ^ 2) := by
  have hsplit (i j : ι) : inner ℝ (v i) (v j) =
      (if i = j then inner ℝ (v i) (v i) else 0) +
      (if i = j then 0 else inner ℝ (v i) (v j)) := by
    split_ifs with h
    · subst j
      simp
    · simp
  have hrow (i : ι) : (∑ j, inner ℝ (v i) (v j)) =
      ‖v i‖ ^ 2 + ∑ j, if i = j then 0 else inner ℝ (v i) (v j) := by
    calc
      (∑ j, inner ℝ (v i) (v j)) =
          ∑ j, ((if i = j then inner ℝ (v i) (v i) else 0) +
            (if i = j then 0 else inner ℝ (v i) (v j))) := by
        apply Finset.sum_congr rfl
        intro j hj
        exact hsplit i j
      _ = _ := by
        rw [Finset.sum_add_distrib]
        simp
  have h := centered_pair_sum v hcenter
  simp_rw [hrow, Finset.sum_add_distrib] at h
  linarith

/-- Exact second moment from diagonal and off-diagonal inclusion moments.

For an actual probability law, `p ω` is its mass and `w ω i` is an inclusion
indicator.  The algebra also holds without imposing these interpretations. -/
theorem centered_weighted_second_moment
    (v : ι → E) (hcenter : ∑ i, v i = 0)
    (p : Ω → ℝ) (w : Ω → ι → ℝ) (α β : ℝ)
    (hmoment : ∀ i j, (∑ ω, p ω * w ω i * w ω j) =
      if i = j then α else β) :
    (∑ ω, p ω * ‖∑ i, w ω i • v i‖ ^ 2) =
      (α - β) * ∑ i, ‖v i‖ ^ 2 := by
  have hexpand (ω : Ω) : p ω * ‖∑ i, w ω i • v i‖ ^ 2 =
      ∑ i, ∑ j, (p ω * w ω i * w ω j) * inner ℝ (v i) (v j) := by
    rw [← real_inner_self_eq_norm_sq]
    simp_rw [sum_inner, inner_sum, real_inner_smul_left, real_inner_smul_right,
      Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i hi
    apply Finset.sum_congr rfl
    intro j hj
    ring
  have hsplit (i j : ι) :
      (if i = j then α else β) * inner ℝ (v i) (v j) =
      β * inner ℝ (v i) (v j) +
      (if i = j then (α - β) * inner ℝ (v i) (v i) else 0) := by
    split_ifs with h
    · subst j
      ring
    · ring
  calc
    (∑ ω, p ω * ‖∑ i, w ω i • v i‖ ^ 2) =
        ∑ i, ∑ j, (∑ ω, p ω * w ω i * w ω j) * inner ℝ (v i) (v j) := by
      simp_rw [hexpand, Finset.sum_mul]
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro i hi
      rw [Finset.sum_comm]
    _ = (∑ i, ∑ j, β * inner ℝ (v i) (v j)) +
        ∑ i, (α - β) * inner ℝ (v i) (v i) := by
      simp_rw [hmoment, hsplit, Finset.sum_add_distrib]
      simp
    _ = β * (∑ i, ∑ j, inner ℝ (v i) (v j)) +
        (α - β) * ∑ i, ‖v i‖ ^ 2 := by
      simp [Finset.mul_sum]
    _ = (α - β) * ∑ i, ‖v i‖ ^ 2 := by
      rw [centered_pair_sum v hcenter]
      ring

/-- The exact finite-population variance coefficient, once the two inclusion
moments of a uniformly chosen subset have been supplied.

The factor `n / q` corresponds to estimating the population *sum* by a
rescaled sample sum.  Thus the right side is `n(n-q)/(q(n-1))` times the
centered population energy. -/
theorem finite_population_variance_from_moments
    (v : ι → E) (hcenter : ∑ i, v i = 0)
    (p : Ω → ℝ) (w : Ω → ι → ℝ) (n q : ℝ)
    (hn : n ≠ 0) (hq : q ≠ 0) (hn1 : n - 1 ≠ 0)
    (hmoment : ∀ i j, (∑ ω, p ω * w ω i * w ω j) =
      if i = j then q / n else q * (q - 1) / (n * (n - 1))) :
    (∑ ω, p ω * ‖(n / q) • (∑ i, w ω i • v i)‖ ^ 2) =
      (n * (n - q) / (q * (n - 1))) * ∑ i, ‖v i‖ ^ 2 := by
  calc
    (∑ ω, p ω * ‖(n / q) • (∑ i, w ω i • v i)‖ ^ 2) =
        (n / q) ^ 2 * ∑ ω, p ω * ‖∑ i, w ω i • v i‖ ^ 2 := by
      simp_rw [norm_smul, mul_pow, Real.norm_eq_abs, sq_abs]
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro ω hω
      ring
    _ = (n * (n - q) / (q * (n - 1))) * ∑ i, ‖v i‖ ^ 2 := by
      rw [centered_weighted_second_moment v hcenter p w (q / n)
        (q * (q - 1) / (n * (n - 1))) hmoment]
      field_simp [hn, hq, hn1]
      ring

omit [Fintype Ω] in
/-- Exact variance of the uniform sample without replacement, with all
inclusion moments proved rather than assumed.  The vectors are centered and
the rescaled sample estimates their population sum (which is zero). -/
theorem uniform_subset_variance
    (v : ι → E) (hcenter : ∑ i, v i = 0)
    (q : ℕ) (hq : 2 ≤ q) (hqn : q ≤ Fintype.card ι) :
    (∑ s ∈ (Finset.univ : Finset ι).powersetCard q,
      ((Fintype.card ι).choose q : ℝ)⁻¹ *
        ‖((Fintype.card ι : ℝ) / q) • (∑ i ∈ s, v i)‖ ^ 2) =
      ((Fintype.card ι : ℝ) * (Fintype.card ι - q) /
        ((q : ℝ) * (Fintype.card ι - 1))) * ∑ i, ‖v i‖ ^ 2 := by
  let samples := (Finset.univ : Finset ι).powersetCard q
  let p : Finset ι → ℝ := fun s =>
    if s ∈ samples then ((Fintype.card ι).choose q : ℝ)⁻¹ else 0
  let w : Finset ι → ι → ℝ := fun s i => if i ∈ s then 1 else 0
  have hn' : (1 : ℝ) < Fintype.card ι := by
    exact_mod_cast (lt_of_lt_of_le (by decide : 1 < 2) (hq.trans hqn))
  have hn : (Fintype.card ι : ℝ) ≠ 0 := by linarith
  have hn1 : (Fintype.card ι : ℝ) - 1 ≠ 0 := by linarith
  have hq0 : (q : ℝ) ≠ 0 := by
    exact_mod_cast (lt_of_lt_of_le (by decide : 0 < 2) hq).ne'
  have hm (i j : ι) : (∑ s, p s * w s i * w s j) =
      if i = j then (q : ℝ) / Fintype.card ι
      else (q : ℝ) * (q - 1) /
        ((Fintype.card ι : ℝ) * (Fintype.card ι - 1)) := by
    simp only [p, w, ite_mul, zero_mul, Finset.sum_ite_mem_eq]
    exact uniform_subset_pair_moment q hq hqn i j
  have hsample (s : Finset ι) : (∑ i, w s i • v i) = ∑ i ∈ s, v i := by
    simp [w, ite_smul]
  have h := finite_population_variance_from_moments v hcenter p w
    (Fintype.card ι : ℝ) (q : ℝ) hn hq0 hn1 hm
  simpa only [hsample, p, ite_mul, zero_mul, Finset.sum_ite_mem_eq, samples] using h

omit [Fintype Ω] [DecidableEq ι] in
/-- Subtracting the arithmetic mean centers the population. -/
theorem sum_sub_population_mean (v : ι → E)
    (hn : (Fintype.card ι : ℝ) ≠ 0) :
    (∑ i, (v i - (Fintype.card ι : ℝ)⁻¹ • ∑ j, v j)) = 0 := by
  rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ,
    ← Nat.cast_smul_eq_nsmul ℝ, smul_smul, mul_inv_cancel₀ hn, one_smul, sub_self]

omit [Fintype Ω] in
/-- The full finite-population variance identity for arbitrary, uncentered
data.  It applies in particular to the rank-one matrices in the blocking
argument, when matrices carry their Frobenius inner product. -/
theorem uniform_subset_sum_variance (v : ι → E)
    (q : ℕ) (hq : 2 ≤ q) (hqn : q ≤ Fintype.card ι) :
    (∑ s ∈ (Finset.univ : Finset ι).powersetCard q,
      ((Fintype.card ι).choose q : ℝ)⁻¹ *
        ‖((Fintype.card ι : ℝ) / q) • (∑ i ∈ s, v i) - ∑ i, v i‖ ^ 2) =
      ((Fintype.card ι : ℝ) * (Fintype.card ι - q) /
        ((q : ℝ) * (Fintype.card ι - 1))) *
        ∑ i, ‖v i - (Fintype.card ι : ℝ)⁻¹ • ∑ j, v j‖ ^ 2 := by
  have hn : (Fintype.card ι : ℝ) ≠ 0 := by
    exact_mod_cast (lt_of_lt_of_le (by decide : 0 < 2) (hq.trans hqn)).ne'
  have hq0 : (q : ℝ) ≠ 0 := by
    exact_mod_cast (lt_of_lt_of_le (by decide : 0 < 2) hq).ne'
  have hfactor : ((Fintype.card ι : ℝ) / q) *
      ((q : ℝ) * (Fintype.card ι : ℝ)⁻¹) = 1 := by
    field_simp
  have hsample (s : Finset ι) (hs : s ∈ (Finset.univ : Finset ι).powersetCard q) :
      ((Fintype.card ι : ℝ) / q) •
        (∑ i ∈ s, (v i - (Fintype.card ι : ℝ)⁻¹ • ∑ j, v j)) =
      ((Fintype.card ι : ℝ) / q) • (∑ i ∈ s, v i) - ∑ i, v i := by
    have hcard : s.card = q := (Finset.mem_powersetCard.mp hs).2
    rw [Finset.sum_sub_distrib, Finset.sum_const, hcard,
      ← Nat.cast_smul_eq_nsmul ℝ, smul_sub, smul_smul, smul_smul,
      mul_assoc, hfactor, one_smul]
  have h := uniform_subset_variance
    (fun i => v i - (Fintype.card ι : ℝ)⁻¹ • ∑ j, v j)
    (sum_sub_population_mean v hn) q hq hqn
  rw [← h]
  apply Finset.sum_congr rfl
  intro s hs
  rw [hsample s hs]

end Paulsen
