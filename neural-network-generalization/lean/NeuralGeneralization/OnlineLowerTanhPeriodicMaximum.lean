import NeuralGeneralization.OnlineLowerTanhPeriodicSeries

/-! # Elementary exact maxima for the actual periodic Fourier response -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

def periodicSquareTail (a : ℝ) : ℝ :=
  ∑' j : ℕ, periodicCoefficient a (j+1) * (2*(j : ℝ)+3)^2

theorem periodicSquareTail_summable {a : ℝ} (ha : 0 < a) :
    Summable (fun j : ℕ => periodicCoefficient a (j+1) * (2*(j : ℝ)+3)^2) := by
  have h := (periodicCoefficient_square_summable ha).comp_injective Nat.succ_injective
  apply h.congr
  intro j
  simp only [Function.comp_apply, Nat.succ_eq_add_one, Nat.cast_add, Nat.cast_one]
  ring

theorem periodicSquareTail_bound {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) :
    0 ≤ periodicSquareTail a ∧ periodicSquareTail a ≤ (99/100)*periodicCoefficient a 0 := by
  constructor
  · exact tsum_nonneg (fun j => mul_nonneg (periodicCoefficient_pos ha _).le (sq_nonneg _))
  · have hq := periodicRatio_bound ha ha2
    have hq1 : |periodicRatio a| < 1 := by rw [abs_of_pos hq.1]; linarith
    have ht := Summable.tsum_le_tsum (fun j : ℕ => by
      have h := mul_le_mul_of_nonneg_right (periodicCoefficient_le_geometric ha (j+1))
        (sq_nonneg (2*(j : ℝ)+3))
      calc
        periodicCoefficient a (j+1)*(2*(j : ℝ)+3)^2 ≤
          (periodicCoefficient a 0*periodicRatio a^(j+1))*(2*(j : ℝ)+3)^2 := h
        _ = periodicCoefficient a 0*((2*(j : ℝ)+3)^2*periodicRatio a^(j+1)) := by ring)
      (periodicSquareTail_summable ha)
      ((summable_odd_square_geometric hq1).mul_left (periodicCoefficient a 0))
    rw [(summable_odd_square_geometric hq1).tsum_mul_left] at ht
    have hb := mul_le_mul_of_nonneg_left (odd_square_tail_bound hq.1.le hq.2.le)
      (periodicCoefficient_pos ha 0).le
    exact ht.trans (by simpa only [mul_comm] using hb)

theorem periodicFrequency_mul_gain {a : ℝ} (ha : a ≠ 0) : periodicFrequency a*a = Real.pi/2 := by
  unfold periodicFrequency
  field_simp

theorem periodic_shifted_sine {a : ℝ} (ha : a ≠ 0) (j : ℕ) (z : ℝ) :
    Real.sin ((2*(j : ℝ)+1)*periodicFrequency a*(a+z)) =
      (-1 : ℝ)^j * Real.cos ((2*(j : ℝ)+1)*periodicFrequency a*z) := by
  have he : (2*(j : ℝ)+1)*periodicFrequency a*(a+z) =
      (j : ℝ)*Real.pi + (Real.pi/2+(2*(j : ℝ)+1)*periodicFrequency a*z) := by
    have h := periodicFrequency_mul_gain ha
    nlinarith
  rw [he, Real.sin_add, Real.sin_nat_mul_pi, Real.cos_nat_mul_pi]
  simp [Real.sin_add]

def periodicCenteredTerm (a z : ℝ) (j : ℕ) : ℝ :=
  (-1 : ℝ)^j * periodicCoefficient a j * Real.cos ((2*(j : ℝ)+1)*periodicFrequency a*z)

theorem periodicCenteredTerm_summable {a : ℝ} (ha : 0 < a) (z : ℝ) :
    Summable (periodicCenteredTerm a z) := by
  apply (periodicCoefficient_summable ha).of_norm_bounded
  intro j
  simp only [periodicCenteredTerm, Real.norm_eq_abs, abs_mul, abs_neg_one_pow,
    one_mul, abs_of_pos (periodicCoefficient_pos ha j)]
  simpa only [mul_one] using mul_le_mul_of_nonneg_left (Real.abs_cos_le_one _) (periodicCoefficient_pos ha j).le

theorem periodicFourierResponse_centered {a : ℝ} (ha : 0 < a) (z : ℝ) :
    periodicFourierResponse a (a+z) = ∑' j : ℕ, periodicCenteredTerm a z j := by
  unfold periodicFourierResponse
  apply tsum_congr
  intro j
  rw [periodic_shifted_sine ha.ne']
  unfold periodicCenteredTerm
  ring

/-- Uniform first-harmonic quadratic phase control, stated before replacing
the trigonometric distance by ordinary distance to the lattice of maxima. -/
theorem periodic_peak_deficit {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) (z : ℝ) :
    (periodicCoefficient a 0 / 100) * (1-Real.cos (periodicFrequency a*z)) ≤
      periodicFourierMaximum a - periodicFourierResponse a (a+z) := by
  have h0 := periodicCenteredTerm_summable ha 0
  have hz := periodicCenteredTerm_summable ha z
  have hd := h0.sub hz
  have htail := hd.comp_injective Nat.succ_injective
  have hnon : 0 ≤ 1-Real.cos (periodicFrequency a*z) := by linarith [Real.cos_le_one (periodicFrequency a*z)]
  have hpoint (j : ℕ) :
      -(periodicCoefficient a (j+1)*(2*(j : ℝ)+3)^2 * (1-Real.cos (periodicFrequency a*z))) ≤
        periodicCenteredTerm a 0 (j+1) - periodicCenteredTerm a z (j+1) := by
    have hcos : 0 ≤ 1-Real.cos ((2*(j : ℝ)+3)*periodicFrequency a*z) := by
      linarith [Real.cos_le_one ((2*(j : ℝ)+3)*periodicFrequency a*z)]
    have hb := one_sub_cos_nat_mul_le (2*j+3) (periodicFrequency a*z)
    have hangle : ((2*j+3 : ℕ) : ℝ)*(periodicFrequency a*z) =
        (2*(j : ℝ)+3)*periodicFrequency a*z := by push_cast; ring
    rw [hangle] at hb
    have hp := mul_le_mul_of_nonneg_left hb (periodicCoefficient_pos ha (j+1)).le
    have hsign : -1 ≤ (-1 : ℝ)^(j+1) := by
      have hh : |(-1 : ℝ)^(j+1)| = 1 := by simp
      exact (abs_le.mp (le_of_eq hh)).1
    have hmul := mul_le_mul_of_nonneg_right hsign
      (mul_nonneg (periodicCoefficient_pos ha (j+1)).le hcos)
    unfold periodicCenteredTerm
    simp only [mul_zero, Real.cos_zero, mul_one, Nat.cast_add, Nat.cast_one]
    rw [show 2*((j : ℝ)+1)+1=2*(j : ℝ)+3 by ring]
    push_cast at hp
    nlinarith
  have hsum := Summable.tsum_le_tsum hpoint
    (((periodicSquareTail_summable ha).mul_right (1-Real.cos (periodicFrequency a*z))).neg) htail
  rw [tsum_neg, (periodicSquareTail_summable ha).tsum_mul_right] at hsum
  have hsplit := hd.tsum_eq_zero_add
  have htotal : periodicFourierMaximum a-periodicFourierResponse a (a+z) =
      periodicCoefficient a 0*(1-Real.cos (periodicFrequency a*z)) +
        ∑' j : ℕ, (periodicCenteredTerm a 0 (j+1)-periodicCenteredTerm a z (j+1)) := by
    have hF : periodicFourierMaximum a = ∑' j : ℕ, periodicCenteredTerm a 0 j := by
      simpa only [periodicFourierMaximum, add_zero] using periodicFourierResponse_centered ha 0
    rw [hF, periodicFourierResponse_centered ha z, ← h0.tsum_sub hz, hsplit]
    simp only [periodicCenteredTerm, pow_zero, Nat.cast_zero, mul_zero, zero_add,
      one_mul, Real.cos_zero, mul_one]
    ring
  rw [htotal]
  have hb := (periodicSquareTail_bound ha ha2).2
  have hm := mul_le_mul_of_nonneg_right hb hnon
  change -(periodicSquareTail a*(1-Real.cos (periodicFrequency a*z))) ≤ _ at hsum
  nlinarith

theorem periodicFourierResponse_zero (a : ℝ) : periodicFourierResponse a 0 = 0 := by
  simp [periodicFourierResponse]

theorem periodicFourierResponse_odd (a b : ℝ) :
    periodicFourierResponse a (-b) = -periodicFourierResponse a b := by
  simp only [periodicFourierResponse, mul_neg, Real.sin_neg, tsum_neg]

theorem periodicFourierResponse_antiperiod {a : ℝ} (ha : 0 < a) (b : ℝ) :
    periodicFourierResponse a (b+2*a) = -periodicFourierResponse a b := by
  have hterm (j : ℕ) :
      Real.sin ((2*(j : ℝ)+1)*periodicFrequency a*(b+2*a)) =
        -Real.sin ((2*(j : ℝ)+1)*periodicFrequency a*b) := by
    have he : (2*(j : ℝ)+1)*periodicFrequency a*(b+2*a) =
        (2*(j : ℝ)+1)*periodicFrequency a*b + (2*j+1 : ℕ)*Real.pi := by
      have h := periodicFrequency_mul_gain ha.ne'
      push_cast
      nlinarith
    rw [he, Real.sin_add_nat_mul_pi]
    have ho : Odd (2*j+1) := ⟨j,rfl⟩
    rw [ho.neg_one_pow]
    ring
  simp only [periodicFourierResponse, hterm, mul_neg, tsum_neg]

/-- Exact global absolute maximum of the actual convergent Fourier series,
for every positive gain at most two. -/
theorem periodicFourierResponse_abs_le {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) (b : ℝ) :
    |periodicFourierResponse a b| ≤ periodicFourierMaximum a := by
  have hupper (y : ℝ) : periodicFourierResponse a y ≤ periodicFourierMaximum a := by
    have h := periodic_peak_deficit ha ha2 (y-a)
    have hn := mul_nonneg (div_nonneg (periodicCoefficient_pos ha 0).le (show (0 : ℝ) ≤ 100 by norm_num))
      (show 0 ≤ 1-Real.cos (periodicFrequency a*(y-a)) by linarith [Real.cos_le_one (periodicFrequency a*(y-a))])
    rw [show a+(y-a)=y by ring] at h
    linarith
  apply abs_le.mpr
  constructor
  · have h := hupper (b+2*a)
    rw [periodicFourierResponse_antiperiod ha] at h
    linarith
  · exact hupper b

theorem periodicFourierMaximum_pos {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) :
    0 < periodicFourierMaximum a := by
  have h := periodic_peak_deficit ha ha2 a
  rw [periodicFrequency_mul_gain ha.ne', Real.cos_pi_div_two,
    show a+a = 0+2*a by ring, periodicFourierResponse_antiperiod ha 0,
    periodicFourierResponse_zero] at h
  have hp := periodicCoefficient_pos ha 0
  linarith

end NeuralGeneralization.OnlineLowerTanh
