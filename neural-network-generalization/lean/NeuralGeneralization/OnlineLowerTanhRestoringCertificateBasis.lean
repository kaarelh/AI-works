import Mathlib.RingTheory.Polynomial.Bernstein
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

/-! Elementary positivity for exact bivariate Bernstein certificates. -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerTanh

/-- A real Bernstein basis polynomial. -/
def restoringBernsteinBasis (n k : ℕ) (t : ℝ) : ℝ :=
  (n.choose k : ℝ) * t ^ k * (1 - t) ^ (n - k)

lemma restoringBernsteinBasis_nonneg (n k : ℕ) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    0 ≤ restoringBernsteinBasis n k t := by
  unfold restoringBernsteinBasis
  exact mul_nonneg (mul_nonneg (Nat.cast_nonneg _) (pow_nonneg ht0 _))
    (pow_nonneg (sub_nonneg.mpr ht1) _)

lemma restoringBernsteinBasis_sum (n : ℕ) (t : ℝ) :
    (∑ k ∈ Finset.range (n + 1), restoringBernsteinBasis n k t) = 1 := by
  have h := congrArg (Polynomial.eval t) (bernsteinPolynomial.sum ℝ n)
  simpa [restoringBernsteinBasis, bernsteinPolynomial, Polynomial.eval_finsetSum] using h

lemma restoringBernsteinBasis_exists_pos (n : ℕ) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    ∃ k ∈ Finset.range (n + 1), 0 < restoringBernsteinBasis n k t := by
  apply (Finset.sum_pos_iff_of_nonneg
    (fun k _ => restoringBernsteinBasis_nonneg n k ht0 ht1)).mp
  rw [restoringBernsteinBasis_sum]
  norm_num

/-- Evaluation of a rectangular array of Bernstein coefficients. -/
def restoringBernsteinValue (n m : ℕ) (c : ℕ → ℕ → ℝ) (s t : ℝ) : ℝ :=
  ∑ i ∈ Finset.range (n + 1), ∑ j ∈ Finset.range (m + 1),
    c i j * restoringBernsteinBasis n i s * restoringBernsteinBasis m j t

lemma restoringBernsteinValue_nonneg (n m : ℕ) (c : ℕ → ℕ → ℝ)
    {s t : ℝ} (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    (hc : ∀ i < n + 1, ∀ j < m + 1, 0 ≤ c i j) :
    0 ≤ restoringBernsteinValue n m c s t := by
  apply Finset.sum_nonneg
  intro i hi
  apply Finset.sum_nonneg
  intro j hj
  exact mul_nonneg
    (mul_nonneg (hc i (Finset.mem_range.mp hi) j (Finset.mem_range.mp hj))
      (restoringBernsteinBasis_nonneg n i hs0 hs1))
    (restoringBernsteinBasis_nonneg m j ht0 ht1)

lemma restoringBernsteinValue_pos (n m : ℕ) (c : ℕ → ℕ → ℝ)
    {s t : ℝ} (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    (hc : ∀ i < n + 1, ∀ j < m + 1, 0 < c i j) :
    0 < restoringBernsteinValue n m c s t := by
  obtain ⟨i, hi, hbi⟩ := restoringBernsteinBasis_exists_pos n hs0 hs1
  obtain ⟨j, hj, hbj⟩ := restoringBernsteinBasis_exists_pos m ht0 ht1
  apply Finset.sum_pos'
  · intro k hk
    apply Finset.sum_nonneg
    intro l hl
    exact mul_nonneg
      (mul_nonneg (hc k (Finset.mem_range.mp hk) l (Finset.mem_range.mp hl)).le
        (restoringBernsteinBasis_nonneg n k hs0 hs1))
      (restoringBernsteinBasis_nonneg m l ht0 ht1)
  · refine ⟨i, hi, Finset.sum_pos' ?_ ⟨j, hj, ?_⟩⟩
    · intro l hl
      exact mul_nonneg
        (mul_nonneg (hc i (Finset.mem_range.mp hi) l (Finset.mem_range.mp hl)).le hbi.le)
        (restoringBernsteinBasis_nonneg m l ht0 ht1)
    · exact mul_pos (mul_pos (hc i (Finset.mem_range.mp hi) j
        (Finset.mem_range.mp hj)) hbi) hbj

/-- The Bernstein monomial with the binomial coefficient absorbed into its weight. -/
def restoringBernsteinWeight (n k : ℕ) (t : ℝ) : ℝ :=
  t ^ k * (1 - t) ^ (n - k)

lemma restoringBernsteinWeight_nonneg (n k : ℕ) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    0 ≤ restoringBernsteinWeight n k t :=
  mul_nonneg (pow_nonneg ht0 _) (pow_nonneg (sub_nonneg.mpr ht1) _)

lemma restoringBernsteinWeight_exists_pos (n : ℕ) {t : ℝ}
    (ht1 : t ≤ 1) :
    ∃ k ∈ Finset.range (n + 1), 0 < restoringBernsteinWeight n k t := by
  by_cases ht : t < 1
  · refine ⟨0, by simp, ?_⟩
    simpa [restoringBernsteinWeight] using pow_pos (sub_pos.mpr ht) n
  · have he : t = 1 := le_antisymm ht1 (le_of_not_gt ht)
    exact ⟨n, by simp, by simp [restoringBernsteinWeight, he]⟩

/-- An unnormalized certificate whose coefficients absorb the binomial factors. -/
def restoringBernsteinWeightedValue (n m : ℕ) (c : ℕ → ℕ → ℝ) (s t : ℝ) : ℝ :=
  ∑ i ∈ Finset.range (n + 1), ∑ j ∈ Finset.range (m + 1),
    c i j * restoringBernsteinWeight n i s * restoringBernsteinWeight m j t

lemma restoringBernsteinWeightedSum_pos (n : ℕ) (c : ℕ → ℝ)
    {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    (hc : ∀ i < n + 1, 0 < c i) :
    0 < ∑ i ∈ Finset.range (n + 1), c i * restoringBernsteinWeight n i t := by
  obtain ⟨i, hi, hbi⟩ := restoringBernsteinWeight_exists_pos n ht1
  apply Finset.sum_pos'
  · intro j hj
    exact mul_nonneg (hc j (Finset.mem_range.mp hj)).le
      (restoringBernsteinWeight_nonneg n j ht0 ht1)
  · exact ⟨i, hi, mul_pos (hc i (Finset.mem_range.mp hi)) hbi⟩

lemma restoringBernsteinWeightedValue_pos (n m : ℕ) (c : ℕ → ℕ → ℝ)
    {s t : ℝ} (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    (hc : ∀ i < n + 1, ∀ j < m + 1, 0 < c i j) :
    0 < restoringBernsteinWeightedValue n m c s t := by
  obtain ⟨i, hi, hbi⟩ := restoringBernsteinWeight_exists_pos n hs1
  obtain ⟨j, hj, hbj⟩ := restoringBernsteinWeight_exists_pos m ht1
  apply Finset.sum_pos'
  · intro k hk
    apply Finset.sum_nonneg
    intro l hl
    exact mul_nonneg
      (mul_nonneg (hc k (Finset.mem_range.mp hk) l (Finset.mem_range.mp hl)).le
        (restoringBernsteinWeight_nonneg n k hs0 hs1))
      (restoringBernsteinWeight_nonneg m l ht0 ht1)
  · refine ⟨i, hi, Finset.sum_pos' ?_ ⟨j, hj, ?_⟩⟩
    · intro l hl
      exact mul_nonneg
        (mul_nonneg (hc i (Finset.mem_range.mp hi) l (Finset.mem_range.mp hl)).le hbi.le)
        (restoringBernsteinWeight_nonneg m l ht0 ht1)
    · exact mul_pos (mul_pos (hc i (Finset.mem_range.mp hi) j
        (Finset.mem_range.mp hj)) hbi) hbj

/-- Transfer a certificate on the unit square to a closed affine rectangle. -/
lemma restoringCertificate_affine (P : ℝ → ℝ → Prop) (a b c d : ℝ)
    (hab : a < b) (hcd : c < d)
    (h : ∀ s t : ℝ, 0 ≤ s → s ≤ 1 → 0 ≤ t → t ≤ 1 →
      P (a + (b - a) * s) (c + (d - c) * t))
    {q x : ℝ} (hq0 : a ≤ q) (hq1 : q ≤ b) (hx0 : c ≤ x) (hx1 : x ≤ d) :
    P q x := by
  have hab' : 0 < b - a := sub_pos.mpr hab
  have hcd' : 0 < d - c := sub_pos.mpr hcd
  have hs0 : 0 ≤ (q - a) / (b - a) := div_nonneg (sub_nonneg.mpr hq0) hab'.le
  have hs1 : (q - a) / (b - a) ≤ 1 := (div_le_one hab').mpr (by linarith)
  have ht0 : 0 ≤ (x - c) / (d - c) := div_nonneg (sub_nonneg.mpr hx0) hcd'.le
  have ht1 : (x - c) / (d - c) ≤ 1 := (div_le_one hcd').mpr (by linarith)
  have heq : a + (b - a) * ((q - a) / (b - a)) = q := by
    field_simp
    nlinarith
  have hex : c + (d - c) * ((x - c) / (d - c)) = x := by
    field_simp
    nlinarith
  simpa only [heq, hex] using h _ _ hs0 hs1 ht0 ht1

end NeuralGeneralization.OnlineLowerTanh
