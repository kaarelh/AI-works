import NeuralGeneralization.OnlineLowerTanhPeriodicMaximum

/-! # Elementary restoring curvature under arbitrary finite phase averaging -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

theorem periodic_weighted_tail_le {a : ℝ} (ha : 0 < a) (w : ℕ → ℝ)
    (hw : ∀ j, 0 ≤ w j)
    (hs : Summable (fun j => periodicCoefficient a (j+1)*w j))
    (hg : Summable (fun j => w j*periodicRatio a^(j+1))) :
    (∑' j, periodicCoefficient a (j+1)*w j) ≤
      periodicCoefficient a 0 * ∑' j, w j*periodicRatio a^(j+1) := by
  have h := Summable.tsum_le_tsum (fun j => by
    have hh := mul_le_mul_of_nonneg_right (periodicCoefficient_le_geometric ha (j+1)) (hw j)
    calc
      _ ≤ (periodicCoefficient a 0*periodicRatio a^(j+1))*w j := hh
      _ = periodicCoefficient a 0*(w j*periodicRatio a^(j+1)) := by ring)
    hs (hg.mul_left (periodicCoefficient a 0))
  rwa [hg.tsum_mul_left] at h

theorem periodicCoefficient_tail_summable {a : ℝ} (ha : 0 < a) :
    Summable (fun j : ℕ => periodicCoefficient a (j+1)) := by
  convert (periodicCoefficient_summable ha).comp_injective Nat.succ_injective using 1 <;> rfl

theorem periodicCoefficient_tail_bound {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) :
    (∑' j : ℕ, periodicCoefficient a (j+1)) ≤ periodicCoefficient a 0 / 10 := by
  have hq := periodicRatio_bound ha ha2
  have hq1 : |periodicRatio a| < 1 := by rw [abs_of_pos hq.1]; linarith
  have hg : Summable (fun j : ℕ => periodicRatio a^(j+1)) := by
    convert (summable_geometric_of_abs_lt_one hq1).comp_injective Nat.succ_injective using 1 <;> rfl
  have h := periodic_weighted_tail_le ha (fun _ => 1) (fun _ => by norm_num)
    (by simpa only [mul_one] using periodicCoefficient_tail_summable ha)
    (by simpa only [one_mul] using hg)
  simp only [one_mul, mul_one] at h
  have hb := mul_le_mul_of_nonneg_left (geometric_tail_bound hq.1.le hq.2.le)
    (periodicCoefficient_pos ha 0).le
  exact h.trans (by simpa only [mul_one_div] using hb)

theorem periodicFourierMaximum_lower {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) :
    (9/10)*periodicCoefficient a 0 ≤ periodicFourierMaximum a := by
  have hs := periodicCenteredTerm_summable ha 0
  have htail : -(∑' j : ℕ, periodicCoefficient a (j+1)) ≤
      ∑' j : ℕ, periodicCenteredTerm a 0 (j+1) := by
    rw [← tsum_neg]
    apply Summable.tsum_le_tsum _ (periodicCoefficient_tail_summable ha).neg
      (hs.comp_injective Nat.succ_injective)
    intro j
    have hsign : -1 ≤ (-1 : ℝ)^(j+1) := by
      exact (abs_le.mp (show |(-1 : ℝ)^(j+1)| ≤ 1 by simp)).1
    have h := mul_le_mul_of_nonneg_right hsign (periodicCoefficient_pos ha (j+1)).le
    simpa [periodicCenteredTerm] using h
  have hF : periodicFourierMaximum a = periodicCoefficient a 0 +
      ∑' j : ℕ, periodicCenteredTerm a 0 (j+1) := by
    have hc := periodicFourierResponse_centered ha 0
    simp only [add_zero] at hc
    rw [periodicFourierMaximum, hc, hs.tsum_eq_zero_add]
    simp [periodicCenteredTerm]
  rw [hF]
  have hb := periodicCoefficient_tail_bound ha ha2
  linarith

def periodicCurvatureTail (a : ℝ) : ℝ :=
  ∑' j : ℕ, periodicCoefficient a (j+1)*((2*(j : ℝ)+3)^2-1)

theorem periodicCurvatureTail_summable {a : ℝ} (ha : 0 < a) :
    Summable (fun j : ℕ => periodicCoefficient a (j+1)*((2*(j : ℝ)+3)^2-1)) := by
  have h := (periodicSquareTail_summable ha).sub (periodicCoefficient_tail_summable ha)
  apply h.congr
  intro j
  ring

theorem periodicCurvatureTail_bound {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) :
    periodicCurvatureTail a ≤ (89/100)*periodicCoefficient a 0 := by
  have hq := periodicRatio_bound ha ha2
  have hq1 : |periodicRatio a| < 1 := by rw [abs_of_pos hq.1]; linarith
  have h := periodic_weighted_tail_le ha (fun j => (2*(j : ℝ)+3)^2-1)
    (fun j => by nlinarith [Nat.cast_nonneg (α := ℝ) j])
    (periodicCurvatureTail_summable ha) (summable_excess_square_geometric hq1)
  have hb := mul_le_mul_of_nonneg_left (excess_square_tail_bound hq.1.le hq.2.le)
    (periodicCoefficient_pos ha 0).le
  exact h.trans (by simpa only [mul_comm] using hb)

theorem periodic_second_summable {a : ℝ} (ha : 0 < a) (b : ℝ) :
    Summable (fun j : ℕ => -(periodicCoefficient a j*((2*(j : ℝ)+1)*periodicFrequency a)^2) *
      Real.sin ((2*(j : ℝ)+1)*periodicFrequency a*b)) := by
  apply ((periodicCoefficient_square_summable ha).mul_right (periodicFrequency a^2)).of_norm_bounded
  intro j
  rw [Real.norm_eq_abs, abs_mul, abs_neg,
    abs_of_nonneg (mul_nonneg (periodicCoefficient_pos ha j).le (sq_nonneg _))]
  have h := mul_le_mul_of_nonneg_left (Real.abs_sin_le_one ((2*(j : ℝ)+1)*periodicFrequency a*b))
    (mul_nonneg (periodicCoefficient_pos ha j).le (sq_nonneg ((2*(j : ℝ)+1)*periodicFrequency a)))
  simpa only [mul_one, mul_pow, mul_assoc] using h

/-- The restoring force differs from a single sinusoid by a uniformly
controlled higher-harmonic remainder. -/
theorem periodic_restoring_pointwise {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) (b : ℝ) :
    periodicFourierSecond a b ≤ -periodicFrequency a^2*periodicFourierResponse a b +
      (89/100)*periodicFrequency a^2*periodicCoefficient a 0 := by
  let w := fun j : ℕ => periodicCoefficient a j*periodicFrequency a^2 *
    (1-(2*(j : ℝ)+1)^2)*Real.sin ((2*(j : ℝ)+1)*periodicFrequency a*b)
  have hw : Summable w := by
    have h := (periodic_second_summable ha b).add ((periodic_sine_summable ha b).mul_left (periodicFrequency a^2))
    apply h.congr
    intro j
    dsimp [w]
    ring
  have hsum : periodicFourierSecond a b + periodicFrequency a^2*periodicFourierResponse a b = ∑' j, w j := by
    unfold periodicFourierSecond periodicFourierResponse
    rw [← (periodic_sine_summable ha b).tsum_mul_left, ← (periodic_second_summable ha b).tsum_add ((periodic_sine_summable ha b).mul_left (periodicFrequency a^2))]
    apply tsum_congr
    intro j
    dsimp [w]
    ring
  have hpoint (j : ℕ) : w (j+1) ≤ periodicFrequency a^2 *
      (periodicCoefficient a (j+1)*((2*(j : ℝ)+3)^2-1)) := by
    have hk : 0 ≤ (2*(j : ℝ)+3)^2-1 := by nlinarith [Nat.cast_nonneg (α := ℝ) j]
    have h := mul_le_mul_of_nonneg_left (neg_le_neg (Real.neg_one_le_sin ((2*(j : ℝ)+3)*periodicFrequency a*b)))
      (mul_nonneg (sq_nonneg (periodicFrequency a)) (mul_nonneg (periodicCoefficient_pos ha (j+1)).le hk))
    dsimp [w]
    push_cast
    rw [show 2*((j : ℝ)+1)+1=2*(j : ℝ)+3 by ring]
    nlinarith
  have hb := Summable.tsum_le_tsum hpoint (hw.comp_injective Nat.succ_injective)
    ((periodicCurvatureTail_summable ha).mul_left (periodicFrequency a^2))
  rw [(periodicCurvatureTail_summable ha).tsum_mul_left] at hb
  have hsplit := hw.tsum_eq_zero_add
  have hz : w 0 = 0 := by simp [w]
  rw [hz, zero_add] at hsplit
  rw [← hsplit, ← hsum] at hb
  have hc := mul_le_mul_of_nonneg_left (periodicCurvatureTail_bound ha ha2) (sq_nonneg (periodicFrequency a))
  change _ ≤ periodicFrequency a^2*periodicCurvatureTail a at hb
  nlinarith

/-- Any finite probability mixture retaining 99 percent of the periodic
maximum has strictly negative averaged curvature. -/
theorem periodic_restoring_average {ι : Type*} [Fintype ι]
    {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) (p phase : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1)
    (hnear : (99/100)*periodicFourierMaximum a ≤ ∑ i, p i*periodicFourierResponse a (phase i)) :
    (∑ i, p i*periodicFourierSecond a (phase i)) ≤
      -(1/1000)*periodicFrequency a^2*periodicCoefficient a 0 := by
  have h := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) =>
    mul_le_mul_of_nonneg_left (periodic_restoring_pointwise ha ha2 (phase i)) (hp i))
  have he : (∑ i, p i * (-periodicFrequency a^2*periodicFourierResponse a (phase i) +
      (89/100)*periodicFrequency a^2*periodicCoefficient a 0)) =
      -periodicFrequency a^2*(∑ i, p i*periodicFourierResponse a (phase i)) +
        (89/100)*periodicFrequency a^2*periodicCoefficient a 0 := by
    simp_rw [mul_add, Finset.sum_add_distrib]
    rw [show (∑ i, p i * ((89/100)*periodicFrequency a^2*periodicCoefficient a 0)) =
      ((89/100)*periodicFrequency a^2*periodicCoefficient a 0)*(∑ i, p i) by rw [Finset.mul_sum]; apply Finset.sum_congr rfl; intro i _; ring, hsum]
    rw [Finset.mul_sum]
    simp only [mul_one]
    congr 1
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [he] at h
  have hF := periodicFourierMaximum_lower ha ha2
  have hnear' : (891/1000)*periodicCoefficient a 0 ≤ ∑ i, p i*periodicFourierResponse a (phase i) := by linarith
  have hm := mul_le_mul_of_nonneg_left hnear' (sq_nonneg (periodicFrequency a))
  nlinarith

end NeuralGeneralization.OnlineLowerTanh
