import NeuralGeneralization.OnlineLowerGeometryRounding

/-!
# ReLU rounding to an actual live star

The finite step proves the `45 η + 6 V` estimate from the mass and
second-moment inequalities. Unlike rectangle rounding, its output is
always a live unit vector, including when every nearest bit is zero.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

theorem roundBit_quadratic_error (p : ℝ) :
    |p - roundBit p| ≤ p ^ 2 - p + 3 * fractionalPenalty p := by
  by_cases hp : p < 0
  · have hhalf : ¬ (1 : ℝ) / 2 ≤ p := by linarith
    rw [roundBit, if_neg hhalf, sub_zero, abs_of_neg hp]
    have hfrac : fractionalPenalty p = 0 := if_neg (by intro h; linarith [h.1])
    rw [hfrac]
    nlinarith [sq_nonneg p]
  · have hnonneg : 0 ≤ p := le_of_not_gt hp
    by_cases hhigh : p ≤ 1
    · rw [fractionalPenalty, if_pos ⟨hnonneg, hhigh⟩]
      by_cases hhalf : (1 : ℝ) / 2 ≤ p
      · rw [roundBit, if_pos hhalf, abs_of_nonpos (by linarith : p - 1 ≤ 0)]
        nlinarith [mul_nonneg (by linarith : 0 ≤ 2 * p - 1) (by linarith : 0 ≤ 1 - p)]
      · rw [roundBit, if_neg hhalf, sub_zero, abs_of_nonneg hnonneg]
        nlinarith [mul_nonneg hnonneg (by linarith : 0 ≤ 1 - 2 * p)]
    · have hgt : 1 < p := lt_of_not_ge hhigh
      have hhalf : (1 : ℝ) / 2 ≤ p := by linarith
      rw [roundBit, if_pos hhalf, abs_of_nonneg (by linarith : 0 ≤ p - 1)]
      have hfrac : fractionalPenalty p = 0 := if_neg (by intro h; exact hhigh h.2)
      rw [hfrac]
      nlinarith [sq_nonneg (p - 1)]

variable {ι : Type*} [Fintype ι]

theorem l1Distance_controls_sum (p q : ι → ℝ) :
    |(∑ i, p i) - ∑ i, q i| ≤ l1Distance p q := by
  rw [← Finset.sum_sub_distrib]
  exact Finset.abs_sum_le_sum_abs _ _

theorem binary_to_live_point (b : ι → ℝ) (live : ι → Prop)
    (hb : ∀ i, b i = 0 ∨ b i = 1)
    (hlive : ∀ i, b i = 1 → live i) (hexlive : ∃ i, live i) :
    ∃ i, live i ∧
      l1Distance b (fun j => if j = i then 1 else 0) = |(∑ j, b j) - 1| := by
  have hbnonneg (j : ι) : 0 ≤ b j := by
    rcases hb j with h | h <;> rw [h] <;> norm_num
  by_cases hex : ∃ i, b i = 1
  · obtain ⟨i, hi⟩ := hex
    refine ⟨i, hlive i hi, ?_⟩
    have hsum : 1 ≤ ∑ j, b j := by
      rw [← hi]
      exact Finset.single_le_sum (fun j _ => hbnonneg j) (Finset.mem_univ i)
    rw [abs_of_nonneg (by linarith : 0 ≤ (∑ j, b j) - 1)]
    have hterm (j : ι) : |b j - (if j = i then 1 else 0)| =
        b j - (if j = i then 1 else 0) := by
      by_cases hji : j = i
      · subst j
        simp [hi]
      · simp [hji, abs_of_nonneg (hbnonneg j)]
    simp only [l1Distance, hterm, Finset.sum_sub_distrib,
      Finset.sum_ite_eq', Finset.mem_univ, if_true]
  · obtain ⟨i, hi⟩ := hexlive
    have hz (j : ι) : b j = 0 := by
      rcases hb j with h | h
      · exact h
      · exact False.elim (hex ⟨j, h⟩)
    refine ⟨i, hi, ?_⟩
    simp [l1Distance, hz, abs_ite]

/-- A second-moment defect and almost unit total mass suffice for linear
rounding; removed fibers cannot be chosen. -/
theorem live_point_rounding_of_quadratic_bound (p : ι → ℝ) (live : ι → Prop)
    (η A : ℝ) (hmass : |(∑ i, p i) - 1| ≤ η)
    (hquadratic : (∑ i, ((p i) ^ 2 - p i)) ≤ A * η)
    (hremoved : ∀ i, ¬ live i → p i ≤ 0) (hexlive : ∃ i, live i) :
    ∃ i, live i ∧ l1Distance p (fun j => if j = i then 1 else 0) ≤
      (2 * A + 1) * η + 6 * ∑ j, fractionalPenalty (p j) := by
  let b : ι → ℝ := fun i => roundBit (p i)
  have hnear : l1Distance p b ≤ A * η + 3 * ∑ j, fractionalPenalty (p j) := by
    have h := Finset.sum_le_sum fun i (_ : i ∈ Finset.univ) => roundBit_quadratic_error (p i)
    simp only [Finset.sum_add_distrib, ← Finset.mul_sum] at h
    change (∑ i, |p i - roundBit (p i)|) ≤ _
    linarith
  have hlive (i : ι) (hi : b i = 1) : live i := by
    by_contra hnot
    have hz := roundBit_eq_zero_of_nonpos (hremoved i hnot)
    change roundBit (p i) = 1 at hi
    rw [hz] at hi
    norm_num at hi
  obtain ⟨i, hi, hdist⟩ := binary_to_live_point b live
    (fun j => roundBit_zero_or_one (p j)) hlive hexlive
  refine ⟨i, hi, ?_⟩
  have hmassb : |(∑ j, b j) - 1| ≤ l1Distance p b + η := by
    have htri := abs_sub_le (∑ j, b j) (∑ j, p j) 1
    have hsum := l1Distance_controls_sum p b
    rw [abs_sub_comm (∑ j, b j) (∑ j, p j)] at htri
    linarith
  have htri := l1Distance_triangle p b (fun j => if j = i then 1 else 0)
  rw [hdist] at htri
  nlinarith

theorem quadratic_bound_of_small_eta (p : ι → ℝ) (η : ℝ)
    (hη0 : 0 ≤ η) (hη1 : η ≤ 1)
    (hmass : |(∑ i, p i) - 1| ≤ η)
    (hl2 : (∑ i, (p i) ^ 2) ≤ (1 + η) ^ 2) :
    (∑ i, ((p i) ^ 2 - p i)) ≤ 4 * η := by
  have hlow := (abs_le.mp hmass).1
  rw [Finset.sum_sub_distrib]
  nlinarith [mul_nonneg hη0 (by linarith : 0 ≤ 1 - η)]

/-- The two quantitative second-moment regimes from ReLU calibration
give exactly the manuscript's uniform rounding constant. -/
theorem relu_live_point_rounding (p : ι → ℝ) (live : ι → Prop)
    (η : ℝ) (hη : 0 ≤ η) (hmass : |(∑ i, p i) - 1| ≤ η)
    (hsmall : η ≤ 1 → (∑ i, (p i) ^ 2) ≤ (1 + η) ^ 2)
    (hlarge : 1 < η → (∑ i, (p i) ^ 2) ≤ 21 * η)
    (hremoved : ∀ i, ¬ live i → p i ≤ 0) (hexlive : ∃ i, live i) :
    ∃ i, live i ∧ l1Distance p (fun j => if j = i then 1 else 0) ≤
      45 * η + 6 * ∑ j, fractionalPenalty (p j) := by
  have hquad : (∑ i, ((p i) ^ 2 - p i)) ≤ 22 * η := by
    by_cases hη1 : η ≤ 1
    · have h := quadratic_bound_of_small_eta p η hη hη1 hmass (hsmall hη1)
      linarith
    · have h := hlarge (lt_of_not_ge hη1)
      have hlow := (abs_le.mp hmass).1
      rw [Finset.sum_sub_distrib]
      linarith
  convert live_point_rounding_of_quadratic_bound p live η 22 hmass hquad hremoved hexlive using 1 <;> norm_num

end NeuralGeneralization.OnlineLowerGeometry
