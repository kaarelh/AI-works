import NeuralGeneralization.OnlineLowerGeometryCore

/-!
# Rounding fractional logical completions

This module proves the finite `11 η + 4 V` rounding estimate used in the
tanh rectangle construction.  The inputs are the negative-mass bound,
the positive-mass bound, and the fractional variance.  No neural or
posterior conclusion is asserted without proving those inputs.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

def roundBit (p : ℝ) : ℝ := if (1 : ℝ) / 2 ≤ p then 1 else 0
def negativePart (p : ℝ) : ℝ := max (-p) 0
def positivePart (p : ℝ) : ℝ := max p 0
def overflowPart (p : ℝ) : ℝ := max (p - 1) 0
def fractionalPenalty (p : ℝ) : ℝ :=
  if 0 ≤ p ∧ p ≤ 1 then p * (1 - p) else 0

theorem roundBit_zero_or_one (p : ℝ) : roundBit p = 0 ∨ roundBit p = 1 := by
  unfold roundBit
  split_ifs <;> simp

theorem roundBit_nonneg (p : ℝ) : 0 ≤ roundBit p := by
  rcases roundBit_zero_or_one p with h | h
  · rw [h]
  · rw [h]
    norm_num

theorem roundBit_eq_zero_of_nonpos {p : ℝ} (hp : p ≤ 0) : roundBit p = 0 := by
  exact if_neg (by linarith)

theorem fractionalPenalty_nonneg (p : ℝ) : 0 ≤ fractionalPenalty p := by
  unfold fractionalPenalty
  split_ifs with h
  · exact mul_nonneg h.1 (by linarith [h.2])
  · rfl

/-- Pointwise nearest-bit rounding, including scores outside `[0,1]`. -/
theorem roundBit_error (p : ℝ) :
    |p - roundBit p| ≤ negativePart p + overflowPart p + 2 * fractionalPenalty p := by
  by_cases hneg : p < 0
  · have hhalf : ¬ (1 : ℝ) / 2 ≤ p := by linarith
    rw [roundBit, if_neg hhalf, sub_zero, abs_of_neg hneg]
    simp [negativePart, overflowPart, fractionalPenalty,
      not_le.mpr hneg,
      max_eq_left (by linarith : (0 : ℝ) ≤ -p),
      max_eq_right (by linarith : p - 1 ≤ 0)]
  · have hp : 0 ≤ p := le_of_not_gt hneg
    by_cases hone : p ≤ 1
    · have hnegative : negativePart p = 0 := max_eq_right (by linarith)
      have hoverflow : overflowPart p = 0 := max_eq_right (by linarith)
      have hfrac : fractionalPenalty p = p * (1 - p) := if_pos ⟨hp, hone⟩
      rw [hnegative, hoverflow, hfrac]
      by_cases hhalf : (1 : ℝ) / 2 ≤ p
      · rw [roundBit, if_pos hhalf, abs_of_nonpos (by linarith : p - 1 ≤ 0)]
        nlinarith [mul_nonneg (by linarith : 0 ≤ 2 * p - 1) (by linarith : 0 ≤ 1 - p)]
      · rw [roundBit, if_neg hhalf, sub_zero, abs_of_nonneg hp]
        nlinarith [mul_nonneg hp (by linarith : 0 ≤ 1 - 2 * p)]
    · have hhigh : 1 < p := lt_of_not_ge hone
      have hhalf : (1 : ℝ) / 2 ≤ p := by linarith
      rw [roundBit, if_pos hhalf, abs_of_nonneg (by linarith : 0 ≤ p - 1)]
      simp [negativePart, overflowPart, fractionalPenalty, hone,
        max_eq_right (by linarith : -p ≤ 0),
        max_eq_left (by linarith : 0 ≤ p - 1)]

variable {ι : Type*} [Fintype ι]

def l1Distance (p q : ι → ℝ) : ℝ := ∑ i, |p i - q i|

theorem l1Distance_nonneg (p q : ι → ℝ) : 0 ≤ l1Distance p q := by
  exact Finset.sum_nonneg fun i _ => abs_nonneg _

theorem l1Distance_triangle (p q r : ι → ℝ) :
    l1Distance p r ≤ l1Distance p q + l1Distance q r := by
  rw [l1Distance, l1Distance, l1Distance, ← Finset.sum_add_distrib]
  exact Finset.sum_le_sum fun i _ => abs_sub_le (p i) (q i) (r i)

/-- A bound on total positive mass controls the sum of all excesses over
one, with no factor depending on the number of coordinates. -/
theorem overflow_mass_le (p : ι → ℝ) (η : ℝ) (hη : 0 ≤ η)
    (hmass : (∑ i, positivePart (p i)) ≤ 1 + η) :
    (∑ i, overflowPart (p i)) ≤ η := by
  classical
  by_cases hex : ∃ i, 1 < p i
  · obtain ⟨i, hi⟩ := hex
    have hterm (j : ι) : overflowPart (p j) + (if j = i then 1 else 0) ≤
        positivePart (p j) := by
      by_cases hji : j = i
      · subst j
        simp only [if_true, overflowPart, positivePart,
          max_eq_left (by linarith : 0 ≤ p i - 1),
          max_eq_left (by linarith : 0 ≤ p i)]
        linarith
      · simp only [if_neg hji, add_zero, overflowPart, positivePart]
        exact max_le_max (by linarith) le_rfl
    have hsum := Finset.sum_le_sum fun j (_ : j ∈ Finset.univ) => hterm j
    simp only [Finset.sum_add_distrib, Finset.sum_ite_eq', Finset.mem_univ,
      if_true] at hsum
    linarith
  · have hzero : ∀ i, overflowPart (p i) = 0 := by
      intro i
      apply max_eq_right
      have := not_exists.mp hex i
      linarith
    simpa only [hzero, Finset.sum_const_zero] using hη

theorem nearest_bit_l1_bound (p : ι → ℝ) (η : ℝ) (hη : 0 ≤ η)
    (hneg : (∑ i, negativePart (p i)) ≤ η)
    (hpos : (∑ i, positivePart (p i)) ≤ 1 + 3 * η) :
    l1Distance p (fun i => roundBit (p i)) ≤
      4 * η + 2 * ∑ i, fractionalPenalty (p i) := by
  have hover := overflow_mass_le p (3 * η) (mul_nonneg (by norm_num) hη) hpos
  have hsum := Finset.sum_le_sum fun i (_ : i ∈ Finset.univ) => roundBit_error (p i)
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum] at hsum
  change (∑ i, |p i - roundBit (p i)|) ≤ _
  linarith

/-- The candidate vectors are zero and the unit vectors at allowed live
coordinates. -/
def IsLiveCandidate (live : ι → Prop) (q : ι → ℝ) : Prop :=
  q = (fun _ => 0) ∨ ∃ i, live i ∧ q = (fun j => if j = i then 1 else 0)

/-- Rounding a binary vector to zero or a live unit vector.  The error is
controlled by its distance from a vector with almost unit positive mass. -/
theorem binary_to_live_candidate (p b : ι → ℝ) (live : ι → Prop)
    (hb : ∀ i, b i = 0 ∨ b i = 1)
    (hlive : ∀ i, b i = 1 → live i)
    (η : ℝ) (hη : 0 ≤ η)
    (hpos : (∑ i, positivePart (p i)) ≤ 1 + η) :
    ∃ q, IsLiveCandidate live q ∧
      l1Distance p q ≤ 2 * l1Distance p b + η := by
  classical
  by_cases hex : ∃ i, b i = 1
  · obtain ⟨i, hi⟩ := hex
    let q : ι → ℝ := fun j => if j = i then 1 else 0
    have hbnonneg : ∀ j, 0 ≤ b j := by
      intro j
      rcases hb j with h | h
      · rw [h]
      · rw [h]
        norm_num
    have hdist : l1Distance b q = (∑ j, b j) - 1 := by
      have hterm (j : ι) : |b j - q j| = b j - (if j = i then 1 else 0) := by
        by_cases hji : j = i
        · subst j
          simp [q, hi]
        · simp [q, hji, abs_of_nonneg (hbnonneg j)]
      simp only [l1Distance, hterm, Finset.sum_sub_distrib,
        Finset.sum_ite_eq', Finset.mem_univ, if_true]
    have hmass : (∑ j, b j) ≤ (∑ j, positivePart (p j)) + l1Distance p b := by
      have hterm (j : ι) : b j ≤ positivePart (p j) + |p j - b j| := by
        have h₁ := le_abs_self (b j - p j)
        have h₂ : p j ≤ positivePart (p j) := le_max_left _ _
        rw [abs_sub_comm (b j) (p j)] at h₁
        linarith
      have hsum := Finset.sum_le_sum fun j (_ : j ∈ Finset.univ) => hterm j
      simpa only [Finset.sum_add_distrib, l1Distance] using hsum
    refine ⟨q, Or.inr ⟨i, hlive i hi, rfl⟩, ?_⟩
    have htri := l1Distance_triangle p b q
    rw [hdist] at htri
    linarith
  · have hbzero : b = (fun _ => 0) := by
      funext i
      rcases hb i with h | h
      · exact h
      · exact False.elim (hex ⟨i, h⟩)
    refine ⟨b, Or.inl hbzero, ?_⟩
    linarith [l1Distance_nonneg p b]

/-- The complete `11 η + 4 V` logical rounding bound.  Scores on removed
fibers cannot be selected because their shifted means are nonpositive. -/
theorem live_candidate_rounding (p : ι → ℝ) (live : ι → Prop)
    (η : ℝ) (hη : 0 ≤ η)
    (hneg : (∑ i, negativePart (p i)) ≤ η)
    (hpos : (∑ i, positivePart (p i)) ≤ 1 + 3 * η)
    (hremoved : ∀ i, ¬ live i → p i ≤ 0) :
    ∃ q, IsLiveCandidate live q ∧
      l1Distance p q ≤ 11 * η + 4 * ∑ i, fractionalPenalty (p i) := by
  have hnearest := nearest_bit_l1_bound p η hη hneg hpos
  have hlive : ∀ i, roundBit (p i) = 1 → live i := by
    intro i hi
    by_contra hnot
    have hz := roundBit_eq_zero_of_nonpos (hremoved i hnot)
    rw [hz] at hi
    norm_num at hi
  obtain ⟨q, hq, hbound⟩ := binary_to_live_candidate p
    (fun i => roundBit (p i)) live (fun i => roundBit_zero_or_one (p i))
    hlive (3 * η) (mul_nonneg (by norm_num) hη) hpos
  refine ⟨q, hq, ?_⟩
  linarith

end NeuralGeneralization.OnlineLowerGeometry
