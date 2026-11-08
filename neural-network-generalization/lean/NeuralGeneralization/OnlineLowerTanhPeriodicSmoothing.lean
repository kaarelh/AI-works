import NeuralGeneralization.OnlineLowerTanhPeriodicCurvature

/-! # Quantitative damping of the periodic response by residual energy

The damped coefficients are exactly those furnished by the residual saddle
integral. No probabilistic smoothing identity is assumed in these proofs.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

def smoothedCoefficient (a E : ℝ) (j : ℕ) : ℝ :=
  periodicCoefficient a j*Real.exp (-E*((2*(j:ℝ)+1)*periodicFrequency a)^2/2)
def smoothedResponse (a E b : ℝ) : ℝ :=
  ∑' j : ℕ, smoothedCoefficient a E j*Real.sin ((2*(j:ℝ)+1)*periodicFrequency a*b)
def smoothedMaximum (a E : ℝ) : ℝ := smoothedResponse a E a
def smoothedCenteredTerm (a E z : ℝ) (j : ℕ) : ℝ :=
  (-1:ℝ)^j*smoothedCoefficient a E j*Real.cos ((2*(j:ℝ)+1)*periodicFrequency a*z)
def smoothedSquareTail (a E : ℝ) : ℝ :=
  ∑' j : ℕ, smoothedCoefficient a E (j+1)*(2*(j:ℝ)+3)^2

lemma smoothedCoefficient_pos {a : ℝ} (ha : 0 < a) (E : ℝ) (j : ℕ) :
    0 < smoothedCoefficient a E j := mul_pos (periodicCoefficient_pos ha j) (Real.exp_pos _)

lemma smoothedCoefficient_le {a E : ℝ} (ha : 0 < a) (hE : 0 ≤ E) (j : ℕ) :
    smoothedCoefficient a E j ≤ periodicCoefficient a j := by
  apply mul_le_of_le_one_right (periodicCoefficient_pos ha j).le
  apply Real.exp_le_one_iff.mpr
  nlinarith [mul_nonneg hE (sq_nonneg ((2*(j:ℝ)+1)*periodicFrequency a))]

lemma smoothedCoefficient_le_first_damping {a E : ℝ} (ha : 0 < a) (hE : 0 ≤ E) (j : ℕ) :
    smoothedCoefficient a E j ≤ periodicCoefficient a j*Real.exp (-E*periodicFrequency a^2/2) := by
  apply mul_le_mul_of_nonneg_left _ (periodicCoefficient_pos ha j).le
  apply Real.exp_le_exp.mpr
  have hj : (1:ℝ) ≤ 2*(j:ℝ)+1 := by linarith [Nat.cast_nonneg (α := ℝ) j]
  have hw : 0 < periodicFrequency a := periodicFrequency_pos ha
  have hh : periodicFrequency a^2 ≤ ((2*(j:ℝ)+1)*periodicFrequency a)^2 := by
    nlinarith [mul_le_mul_of_nonneg_right hj hw.le]
  nlinarith [mul_le_mul_of_nonneg_left hh hE]

lemma smoothedCoefficient_summable {a E : ℝ} (ha : 0 < a) (hE : 0 ≤ E) :
    Summable (smoothedCoefficient a E) := by
  exact (periodicCoefficient_summable ha).of_nonneg_of_le
    (fun j => (smoothedCoefficient_pos ha E j).le) (smoothedCoefficient_le ha hE)

lemma smoothedSquareTail_summable {a E : ℝ} (ha : 0 < a) (hE : 0 ≤ E) :
    Summable (fun j : ℕ => smoothedCoefficient a E (j+1)*(2*(j:ℝ)+3)^2) := by
  exact (periodicSquareTail_summable ha).of_nonneg_of_le
    (fun j => mul_nonneg (smoothedCoefficient_pos ha E _).le (sq_nonneg _))
    (fun j => mul_le_mul_of_nonneg_right (smoothedCoefficient_le ha hE _) (sq_nonneg _))

lemma smoothedSquareTail_bound {a E : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) (hE : 0 ≤ E) :
    smoothedSquareTail a E ≤ (99/100)*smoothedCoefficient a E 0 := by
  have h := Summable.tsum_le_tsum (fun j : ℕ => by
    have hh := mul_le_mul_of_nonneg_right (smoothedCoefficient_le_first_damping ha hE (j+1))
      (sq_nonneg (2*(j:ℝ)+3))
    convert hh using 1 <;> ring)
    (smoothedSquareTail_summable ha hE)
    ((periodicSquareTail_summable ha).mul_right (Real.exp (-E*periodicFrequency a^2/2)))
  rw [(periodicSquareTail_summable ha).tsum_mul_right] at h
  have hh := mul_le_mul_of_nonneg_right (periodicSquareTail_bound ha ha2).2
    (Real.exp_pos (-E*periodicFrequency a^2/2)).le
  change smoothedSquareTail a E ≤ periodicSquareTail a*Real.exp (-E*periodicFrequency a^2/2) at h
  apply h.trans
  simpa [smoothedCoefficient, mul_assoc] using hh

lemma smoothedCenteredTerm_summable {a E : ℝ} (ha : 0 < a) (hE : 0 ≤ E) (z : ℝ) :
    Summable (smoothedCenteredTerm a E z) := by
  apply (smoothedCoefficient_summable ha hE).of_norm_bounded
  intro j
  simp only [smoothedCenteredTerm, Real.norm_eq_abs, abs_mul, abs_neg_one_pow,
    one_mul, abs_of_pos (smoothedCoefficient_pos ha E j)]
  simpa only [mul_one] using mul_le_mul_of_nonneg_left
    (Real.abs_cos_le_one ((2*(j:ℝ)+1)*periodicFrequency a*z)) (smoothedCoefficient_pos ha E j).le

lemma smoothedResponse_centered {a E : ℝ} (ha : 0 < a) (z : ℝ) :
    smoothedResponse a E (a+z) = ∑' j : ℕ, smoothedCenteredTerm a E z j := by
  unfold smoothedResponse
  apply tsum_congr
  intro j
  rw [periodic_shifted_sine ha.ne']
  unfold smoothedCenteredTerm
  ring

theorem smoothed_peak_deficit {a E : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) (hE : 0 ≤ E) (z : ℝ) :
    (smoothedCoefficient a E 0 / 100) * (1-Real.cos (periodicFrequency a*z)) ≤
      smoothedMaximum a E - smoothedResponse a E (a+z) := by
  have h0 := smoothedCenteredTerm_summable ha hE 0
  have hz := smoothedCenteredTerm_summable ha hE z
  have hd := h0.sub hz
  have htail := hd.comp_injective Nat.succ_injective
  have hnon : 0 ≤ 1-Real.cos (periodicFrequency a*z) := by linarith [Real.cos_le_one (periodicFrequency a*z)]
  have hpoint (j : ℕ) :
      -(smoothedCoefficient a E (j+1)*(2*(j : ℝ)+3)^2 * (1-Real.cos (periodicFrequency a*z))) ≤
        smoothedCenteredTerm a E 0 (j+1) - smoothedCenteredTerm a E z (j+1) := by
    have hcos : 0 ≤ 1-Real.cos ((2*(j : ℝ)+3)*periodicFrequency a*z) := by
      linarith [Real.cos_le_one ((2*(j : ℝ)+3)*periodicFrequency a*z)]
    have hb := one_sub_cos_nat_mul_le (2*j+3) (periodicFrequency a*z)
    have hangle : ((2*j+3 : ℕ) : ℝ)*(periodicFrequency a*z) =
        (2*(j : ℝ)+3)*periodicFrequency a*z := by push_cast; ring
    rw [hangle] at hb
    have hp := mul_le_mul_of_nonneg_left hb (smoothedCoefficient_pos ha E (j+1)).le
    have hsign : -1 ≤ (-1 : ℝ)^(j+1) := by
      have hh : |(-1 : ℝ)^(j+1)| = 1 := by simp
      exact (abs_le.mp (le_of_eq hh)).1
    have hmul := mul_le_mul_of_nonneg_right hsign
      (mul_nonneg (smoothedCoefficient_pos ha E (j+1)).le hcos)
    unfold smoothedCenteredTerm
    simp only [mul_zero, Real.cos_zero, mul_one, Nat.cast_add, Nat.cast_one]
    rw [show 2*((j : ℝ)+1)+1=2*(j : ℝ)+3 by ring]
    push_cast at hp
    nlinarith
  have hsum := Summable.tsum_le_tsum hpoint
    (((smoothedSquareTail_summable ha hE).mul_right (1-Real.cos (periodicFrequency a*z))).neg) htail
  rw [tsum_neg, (smoothedSquareTail_summable ha hE).tsum_mul_right] at hsum
  have hsplit := hd.tsum_eq_zero_add
  have htotal : smoothedMaximum a E-smoothedResponse a E (a+z) =
      smoothedCoefficient a E 0*(1-Real.cos (periodicFrequency a*z)) +
        ∑' j : ℕ, (smoothedCenteredTerm a E 0 (j+1)-smoothedCenteredTerm a E z (j+1)) := by
    have hF : smoothedMaximum a E = ∑' j : ℕ, smoothedCenteredTerm a E 0 j := by
      simpa only [smoothedMaximum, add_zero] using smoothedResponse_centered ha 0
    rw [hF, smoothedResponse_centered ha z, ← h0.tsum_sub hz, hsplit]
    simp only [smoothedCenteredTerm, pow_zero, Nat.cast_zero, mul_zero, zero_add,
      one_mul, Real.cos_zero, mul_one]
    ring
  rw [htotal]
  have hb := (smoothedSquareTail_bound ha ha2 hE)
  have hm := mul_le_mul_of_nonneg_right hb hnon
  change -(smoothedSquareTail a E*(1-Real.cos (periodicFrequency a*z))) ≤ _ at hsum
  nlinarith


lemma smoothedResponse_antiperiod {a E : ℝ} (ha : 0 < a) (b : ℝ) :
    smoothedResponse a E (b+2*a) = -smoothedResponse a E b := by
  have hterm (j : ℕ) :
      Real.sin ((2*(j:ℝ)+1)*periodicFrequency a*(b+2*a)) =
        -Real.sin ((2*(j:ℝ)+1)*periodicFrequency a*b) := by
    have he : (2*(j:ℝ)+1)*periodicFrequency a*(b+2*a) =
        (2*(j:ℝ)+1)*periodicFrequency a*b+(2*j+1:ℕ)*Real.pi := by
      have h := periodicFrequency_mul_gain ha.ne'
      push_cast
      nlinarith
    rw [he, Real.sin_add_nat_mul_pi]
    have ho : Odd (2*j+1) := ⟨j,rfl⟩
    rw [ho.neg_one_pow]
    ring
  simp only [smoothedResponse, hterm, mul_neg, tsum_neg]

lemma smoothedResponse_abs_le {a E : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) (hE : 0 ≤ E) (b : ℝ) :
    |smoothedResponse a E b| ≤ smoothedMaximum a E := by
  have hupper (y : ℝ) : smoothedResponse a E y ≤ smoothedMaximum a E := by
    have h := smoothed_peak_deficit ha ha2 hE (y-a)
    have hn := mul_nonneg (div_nonneg (smoothedCoefficient_pos ha E 0).le (by norm_num : (0:ℝ)≤100))
      (show 0 ≤ 1-Real.cos (periodicFrequency a*(y-a)) by linarith [Real.cos_le_one (periodicFrequency a*(y-a))])
    rw [show a+(y-a)=y by ring] at h
    linarith
  apply abs_le.mpr
  constructor
  · have h := hupper (b+2*a)
    rw [smoothedResponse_antiperiod ha] at h
    linarith
  · exact hupper b

lemma one_sub_exp_nat_mul_le (n : ℕ) {s : ℝ} (hs : 0 ≤ s) :
    1-Real.exp (-(n:ℝ)*s) ≤ (n:ℝ)*(1-Real.exp (-s)) := by
  have h := one_add_mul_le_pow (a := Real.exp (-s)-1)
    (by linarith [Real.exp_pos (-s)] : -2 ≤ Real.exp (-s)-1) n
  rw [add_sub_cancel, ← Real.exp_nat_mul] at h
  rw [show (n:ℝ)*(-s) = -(n:ℝ)*s by ring] at h
  linarith

lemma coefficient_damping_loss_le {a E : ℝ} (ha : 0 < a) (hE : 0 ≤ E) (j : ℕ) :
    periodicCoefficient a j-smoothedCoefficient a E j ≤
      periodicCoefficient a j*(2*(j:ℝ)+1)^2*(1-Real.exp (-E*periodicFrequency a^2/2)) := by
  have hh := one_sub_exp_nat_mul_le ((2*j+1)^2)
    (show 0 ≤ E*periodicFrequency a^2/2 by positivity)
  have he : -(((2*j+1)^2:ℕ):ℝ)*(E*periodicFrequency a^2/2) =
      -E*((2*(j:ℝ)+1)*periodicFrequency a)^2/2 := by push_cast; ring
  rw [he] at hh
  have hm := mul_le_mul_of_nonneg_left hh (periodicCoefficient_pos ha j).le
  push_cast at hm
  unfold smoothedCoefficient
  simp only [neg_mul, neg_div] at hm ⊢
  nlinarith

/-- Residual Gaussian energy causes an explicit loss, uniformly over all
external phases, without a finite-bias restriction. -/
theorem smoothedResponse_energy_deficit {a E : ℝ} (ha : 0 < a) (ha2 : a ≤ 2)
    (hE : 0 ≤ E) (b : ℝ) :
    periodicCoefficient a 0/100*(1-Real.exp (-E*periodicFrequency a^2/2)) ≤
      periodicFourierMaximum a-|smoothedResponse a E b| := by
  let D := 1-Real.exp (-E*periodicFrequency a^2/2)
  have hD : 0 ≤ D := by
    dsimp [D]
    have hh : Real.exp (-E*periodicFrequency a^2/2) ≤ 1 :=
      Real.exp_le_one_iff.mpr (by nlinarith [mul_nonneg hE (sq_nonneg (periodicFrequency a))])
    linarith
  have h0 := periodicCenteredTerm_summable ha 0
  have hE0 := smoothedCenteredTerm_summable ha hE 0
  have hd := h0.sub hE0
  have htail := hd.comp_injective Nat.succ_injective
  have hpoint (j : ℕ) :
      -(periodicCoefficient a (j+1)*(2*(j:ℝ)+3)^2*D) ≤
        periodicCenteredTerm a 0 (j+1)-smoothedCenteredTerm a E 0 (j+1) := by
    have hc := coefficient_damping_loss_le ha hE (j+1)
    have hnon : 0 ≤ periodicCoefficient a (j+1)-smoothedCoefficient a E (j+1) :=
      sub_nonneg.mpr (smoothedCoefficient_le ha hE _)
    have hsign : -1 ≤ (-1:ℝ)^(j+1) := (abs_le.mp (by simp : |(-1:ℝ)^(j+1)|≤1)).1
    have hm := mul_le_mul_of_nonneg_right hsign hnon
    simp only [periodicCenteredTerm, smoothedCenteredTerm, mul_zero, Real.cos_zero, mul_one]
    dsimp [D] at *
    push_cast at hc
    nlinarith
  have hsum := Summable.tsum_le_tsum hpoint
    (((periodicSquareTail_summable ha).mul_right D).neg) htail
  rw [tsum_neg, (periodicSquareTail_summable ha).tsum_mul_right] at hsum
  have hF : periodicFourierMaximum a = ∑' j : ℕ, periodicCenteredTerm a 0 j := by
    simpa only [periodicFourierMaximum, add_zero] using periodicFourierResponse_centered ha 0
  have hFE : smoothedMaximum a E = ∑' j : ℕ, smoothedCenteredTerm a E 0 j := by
    simpa only [smoothedMaximum, add_zero] using smoothedResponse_centered (E := E) ha 0
  have hsplit : periodicFourierMaximum a-smoothedMaximum a E =
      periodicCoefficient a 0*D+
        ∑' j : ℕ, (periodicCenteredTerm a 0 (j+1)-smoothedCenteredTerm a E 0 (j+1)) := by
    rw [hF,hFE,← h0.tsum_sub hE0,hd.tsum_eq_zero_add]
    simp [periodicCenteredTerm,smoothedCenteredTerm,smoothedCoefficient,D]
    <;> ring
  have hm := mul_le_mul_of_nonneg_right (periodicSquareTail_bound ha ha2).2 hD
  change -(periodicSquareTail a*D) ≤ _ at hsum
  have hb := smoothedResponse_abs_le ha ha2 hE b
  change periodicCoefficient a 0/100*D ≤ _
  linarith

end NeuralGeneralization.OnlineLowerTanh
