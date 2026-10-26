import FiniteReductionBoosting

noncomputable section
set_option linter.unusedSectionVars false
open scoped BigOperators
namespace ConditionalNonpolynomial

variable {X I : Type*} [Fintype X] [Fintype I]

lemma weightedError_nonneg (f g : X → Bool) (D : X → ℝ)
    (hD : ∀ x, 0 ≤ D x) : 0 ≤ weightedError f g D := by
  classical
  unfold weightedError
  exact Finset.sum_nonneg (fun x _ => by split_ifs <;> simp_all)

/-- Extract one weak predictor from a posterior with at least5/6 mass in a
specified class and average classification risk at most3/8. This is a finite
weighted-sum argument; the class-mass premise is explicit. -/
theorem posterior_extract_weak (f : X → Bool) (g : I → (X → Bool))
    (p : I → ℝ) (D : X → ℝ) (H : I → Prop) [DecidablePred H]
    (hp : ∀ i, 0 ≤ p i) (hD : ∀ x, 0 ≤ D x)
    (hmass : (5/6:ℝ) ≤ ∑ i, if H i then p i else 0)
    (hrisk : (∑ i, p i * weightedError f (g i) D) ≤ (3/8:ℝ)) :
    ∃ i, H i ∧ weightedError f (g i) D ≤ (9/20:ℝ) := by
  classical
  by_contra hall
  have hbad : ∀ i, H i → (9/20:ℝ) < weightedError f (g i) D := by
    intro i hi
    exact lt_of_not_ge (fun h => hall ⟨i,hi,h⟩)
  have hpos : 0 < ∑ i, if H i then p i else 0 := lt_of_lt_of_le (by norm_num) hmass
  have hpos' : (∑ i : I, (0:ℝ)) < ∑ i, if H i then p i else 0 := by simpa using hpos
  obtain ⟨i, hi, hpi⟩ := Finset.exists_lt_of_sum_lt hpos' 
  have hHi : H i := by
    by_contra hn
    simp [hn] at hpi
  have hpi' : 0 < p i := by simpa [hHi] using hpi
  have hlt : (∑ i, (9/20:ℝ) * (if H i then p i else 0)) <
      ∑ i, p i * weightedError f (g i) D := by
    apply Finset.sum_lt_sum
    · intro j hj
      by_cases hHj : H j
      · simp only [if_pos hHj]
        have := mul_le_mul_of_nonneg_left (le_of_lt (hbad j hHj)) (hp j)
        simpa [mul_comm] using this
      · simp only [if_neg hHj, mul_zero]
        exact mul_nonneg (hp j) (weightedError_nonneg f (g j) D hD)
    · exact ⟨i, hi, by simpa [hHi, mul_comm] using
        mul_lt_mul_of_pos_left (hbad i hHi) hpi'⟩
  rw [← Finset.mul_sum] at hlt
  have hlow := mul_le_mul_of_nonneg_left hmass (by norm_num : (0:ℝ) ≤ 9/20)
  norm_num at hlow
  linarith

/-- Pointwise posterior classification error. -/
def pointError (f : X → Bool) (g : I → (X → Bool)) (p : I → ℝ) (x : X) : ℝ :=
  ∑ i, p i * if g i x = f x then 0 else 1

/-- Confidence-failure mass: wrong-label probability at least1/3. Under
normalization this is exactly correct-label probability at most2/3. -/
def confidenceFailureMass (f : X → Bool) (g : I → (X → Bool))
    (p : I → ℝ) (D : X → ℝ) : ℝ :=
  ∑ x, if (1/3:ℝ) ≤ pointError f g p x then D x else 0

lemma pointError_le_one (f : X → Bool) (g : I → (X → Bool))
    (p : I → ℝ) (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1) (x : X) :
    pointError f g p x ≤ 1 := by
  unfold pointError
  calc
    _ ≤ ∑ i, p i := by
      apply Finset.sum_le_sum
      intro i hi
      by_cases he : g i x = f x <;> simp [he, hp i]
    _ = 1 := hsum

lemma posteriorRisk_eq (f : X → Bool) (g : I → (X → Bool))
    (p : I → ℝ) (D : X → ℝ) :
    (∑ i, p i * weightedError f (g i) D) = ∑ x, D x * pointError f g p x := by
  classical
  simp only [weightedError, pointError, Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro x hx
  apply Finset.sum_congr rfl
  intro i hi
  by_cases he : g i x = f x <;> simp [he, mul_comm]

/-- The numerical confidence-risk transfer at the fixed tolerance1/16. -/
theorem risk_le_three_eighths (f : X → Bool) (g : I → (X → Bool))
    (p : I → ℝ) (D : X → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hpsum : ∑ i, p i = 1)
    (hD : ∀ x, 0 ≤ D x) (hDsum : ∑ x, D x = 1)
    (hfailure : confidenceFailureMass f g p D ≤ (1/16:ℝ)) :
    (∑ i, p i * weightedError f (g i) D) ≤ (3/8:ℝ) := by
  classical
  rw [posteriorRisk_eq]
  have hpoint (x : X) : D x * pointError f g p x ≤
      (1/3:ℝ) * D x + (2/3:ℝ) *
        (if (1/3:ℝ) ≤ pointError f g p x then D x else 0) := by
    by_cases he : (1/3:ℝ) ≤ pointError f g p x
    · simp only [if_pos he]
      have hle := mul_le_mul_of_nonneg_left (pointError_le_one f g p hp hpsum x) (hD x)
      linarith
    · simp only [if_neg he, mul_zero, add_zero]
      have hle := mul_le_mul_of_nonneg_left (le_of_lt (lt_of_not_ge he)) (hD x)
      simpa [mul_comm] using hle
  have hsum := Finset.sum_le_sum (fun x (_ : x ∈ Finset.univ) => hpoint x)
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum, hDsum, mul_one] at hsum
  change (∑ x, D x * pointError f g p x) ≤
    1/3 + 2/3 * confidenceFailureMass f g p D at hsum
  linarith

#print axioms posterior_extract_weak
#print axioms risk_le_three_eighths
end ConditionalNonpolynomial
