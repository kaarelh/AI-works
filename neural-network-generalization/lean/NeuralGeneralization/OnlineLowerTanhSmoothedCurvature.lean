import NeuralGeneralization.OnlineLowerTanhResidualSecondSeries

/-! # Restoring curvature survives residual Gaussian smoothing -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

lemma smoothedSecondMoment_zero (a b : ℝ) :
    -smoothedSecondMoment a 0 b = periodicFourierSecond a b := by
  unfold smoothedSecondMoment smoothedCoefficient periodicFourierSecond residualPeak
  simp only [zero_mul,zero_div,neg_zero,Real.exp_zero,mul_one]
  rw [← tsum_neg]
  apply tsum_congr
  intro j
  ring

/-- The original higher-harmonic curvature bound also controls the damped
Fourier response, since damping only decreases positive coefficients. -/
theorem smoothed_restoring_pointwise {a E : ℝ} (ha : 0 < a) (ha2 : a ≤ 2)
    (hE : 0 ≤ E) (b : ℝ) :
    -smoothedSecondMoment a E b ≤ -periodicFrequency a^2*smoothedResponse a E b +
      (89/100)*periodicFrequency a^2*periodicCoefficient a 0 := by
  let w := fun j : ℕ => smoothedCoefficient a E j*periodicFrequency a^2 *
    (1-(2*(j:ℝ)+1)^2)*Real.sin ((2*(j:ℝ)+1)*periodicFrequency a*b)
  have hw : Summable w := by
    have h := (smoothedSecondMoment_summable ha hE b).neg.add
      ((smoothed_sine_summable ha hE b).mul_left (periodicFrequency a^2))
    apply h.congr
    intro j
    dsimp [w]
    unfold residualPeak
    ring
  have hsum : -smoothedSecondMoment a E b + periodicFrequency a^2*smoothedResponse a E b = ∑' j, w j := by
    unfold smoothedSecondMoment smoothedResponse
    rw [← tsum_neg,← (smoothed_sine_summable ha hE b).tsum_mul_left,
      ← (smoothedSecondMoment_summable ha hE b).neg.tsum_add
        ((smoothed_sine_summable ha hE b).mul_left (periodicFrequency a^2))]
    apply tsum_congr
    intro j
    dsimp [w]
    unfold residualPeak
    ring
  have hpoint (j : ℕ) : w (j+1) ≤ periodicFrequency a^2 *
      (periodicCoefficient a (j+1)*((2*(j:ℝ)+3)^2-1)) := by
    have hk : 0 ≤ (2*(j:ℝ)+3)^2-1 := by nlinarith [Nat.cast_nonneg (α:=ℝ) j]
    have h := mul_le_mul_of_nonneg_left
      (neg_le_neg (Real.neg_one_le_sin ((2*(j:ℝ)+3)*periodicFrequency a*b)))
      (mul_nonneg (sq_nonneg (periodicFrequency a)) (mul_nonneg (smoothedCoefficient_pos ha E (j+1)).le hk))
    have hc := mul_le_mul_of_nonneg_right (smoothedCoefficient_le ha hE (j+1))
      (mul_nonneg (sq_nonneg (periodicFrequency a)) hk)
    dsimp [w]
    push_cast
    rw [show 2*((j:ℝ)+1)+1=2*(j:ℝ)+3 by ring]
    nlinarith
  have hb := Summable.tsum_le_tsum hpoint (hw.comp_injective Nat.succ_injective)
    ((periodicCurvatureTail_summable ha).mul_left (periodicFrequency a^2))
  rw [(periodicCurvatureTail_summable ha).tsum_mul_left] at hb
  have hsplit := hw.tsum_eq_zero_add
  have hz : w 0=0 := by simp [w]
  rw [hz,zero_add] at hsplit
  rw [← hsplit,← hsum] at hb
  have hc := mul_le_mul_of_nonneg_left (periodicCurvatureTail_bound ha ha2) (sq_nonneg (periodicFrequency a))
  change _ ≤ periodicFrequency a^2*periodicCurvatureTail a at hb
  nlinarith

/-- Even after Gaussian smoothing and arbitrary finite phase mixing,
retaining 99 percent of the unsmoothed maximum forces negative curvature. -/
theorem smoothed_restoring_average {ι : Type*} [Fintype ι]
    {a E : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) (hE : 0 ≤ E) (p phase : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i=1)
    (hnear : (99/100)*periodicFourierMaximum a ≤ ∑ i, p i*smoothedResponse a E (phase i)) :
    (∑ i, p i*(-smoothedSecondMoment a E (phase i))) ≤
      -(1/1000)*periodicFrequency a^2*periodicCoefficient a 0 := by
  have h := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) =>
    mul_le_mul_of_nonneg_left (smoothed_restoring_pointwise ha ha2 hE (phase i)) (hp i))
  have he : (∑ i, p i*(-periodicFrequency a^2*smoothedResponse a E (phase i)+
      (89/100)*periodicFrequency a^2*periodicCoefficient a 0)) =
      -periodicFrequency a^2*(∑ i, p i*smoothedResponse a E (phase i))+
        (89/100)*periodicFrequency a^2*periodicCoefficient a 0 := by
    simp_rw [mul_add,Finset.sum_add_distrib]
    rw [show (∑ i, p i*((89/100)*periodicFrequency a^2*periodicCoefficient a 0)) =
      ((89/100)*periodicFrequency a^2*periodicCoefficient a 0)*(∑ i, p i) by
        rw [Finset.mul_sum]; apply Finset.sum_congr rfl; intro i _; ring,hsum]
    rw [Finset.mul_sum]
    simp only [mul_one]
    congr 1
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [he] at h
  have hF := periodicFourierMaximum_lower ha ha2
  have hnear' : (891/1000)*periodicCoefficient a 0 ≤ ∑ i, p i*smoothedResponse a E (phase i) := by linarith
  have hm := mul_le_mul_of_nonneg_left hnear' (sq_nonneg (periodicFrequency a))
  nlinarith

lemma smoothedResponse_neg (a E b : ℝ) : smoothedResponse a E (-b) = -smoothedResponse a E b := by
  simp only [smoothedResponse,mul_neg,Real.sin_neg,tsum_neg]

lemma smoothedSecondMoment_neg (a E b : ℝ) : smoothedSecondMoment a E (-b) = -smoothedSecondMoment a E b := by
  simp only [smoothedSecondMoment,mul_neg,Real.sin_neg,tsum_neg]

lemma smoothed_restoring_absolute {a E : ℝ} (ha : 0 < a) (ha2 : a ≤ 2)
    (hE : 0 ≤ E) (b : ℝ) :
    |-smoothedSecondMoment a E b+periodicFrequency a^2*smoothedResponse a E b| ≤
      (89/100)*periodicFrequency a^2*periodicCoefficient a 0 := by
  have hp := smoothed_restoring_pointwise ha ha2 hE b
  have hn := smoothed_restoring_pointwise ha ha2 hE (-b)
  rw [smoothedResponse_neg,smoothedSecondMoment_neg] at hn
  exact abs_le.mpr ⟨by linarith,by linarith⟩

lemma smoothed_restoring_pointwise_signed {a E σ : ℝ} (ha : 0 < a) (ha2 : a ≤ 2)
    (hE : 0 ≤ E) (hσ : |σ| ≤ 1) (b : ℝ) :
    σ*(-smoothedSecondMoment a E b) ≤ -periodicFrequency a^2*(σ*smoothedResponse a E b)+
      (89/100)*periodicFrequency a^2*periodicCoefficient a 0 := by
  have hh := smoothed_restoring_absolute ha ha2 hE b
  have hm := mul_le_of_le_one_left
    (abs_nonneg (-smoothedSecondMoment a E b+periodicFrequency a^2*smoothedResponse a E b)) hσ
  have hp := le_abs_self (σ*(-smoothedSecondMoment a E b+periodicFrequency a^2*smoothedResponse a E b))
  rw [abs_mul] at hp
  nlinarith

theorem smoothed_restoring_average_signed {ι : Type*} [Fintype ι]
    {a E σ : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) (hE : 0 ≤ E) (hσ : |σ| ≤ 1) (p phase : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i,p i ≤ 1)
    (hnear : (99/100)*periodicFourierMaximum a ≤ ∑ i,p i*(σ*smoothedResponse a E (phase i))) :
    (∑ i,p i*(σ*(-smoothedSecondMoment a E (phase i)))) ≤
      -(1/1000)*periodicFrequency a^2*periodicCoefficient a 0 := by
  have h := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) =>
    mul_le_mul_of_nonneg_left (smoothed_restoring_pointwise_signed ha ha2 hE hσ (phase i)) (hp i))
  have he : (∑ i,p i*(-periodicFrequency a^2*(σ*smoothedResponse a E (phase i))+
      (89/100)*periodicFrequency a^2*periodicCoefficient a 0)) =
      -periodicFrequency a^2*(∑ i,p i*(σ*smoothedResponse a E (phase i)))+
        ((89/100)*periodicFrequency a^2*periodicCoefficient a 0)*(∑ i,p i) := by
    simp_rw [mul_add,Finset.sum_add_distrib]
    rw [Finset.mul_sum,Finset.mul_sum]
    congr 1 <;> apply Finset.sum_congr rfl <;> intro i _ <;> ring
  rw [he] at h
  have hC := mul_le_mul_of_nonneg_left hsum
    (show 0 ≤ (89/100)*periodicFrequency a^2*periodicCoefficient a 0 by positivity [periodicCoefficient_pos ha 0])
  have hF := periodicFourierMaximum_lower ha ha2
  have hnear' : (891/1000)*periodicCoefficient a 0 ≤ ∑ i,p i*(σ*smoothedResponse a E (phase i)) := by linarith
  have hm := mul_le_mul_of_nonneg_left hnear' (sq_nonneg (periodicFrequency a))
  nlinarith

theorem smoothed_restoring_average_signs {ι : Type*} [Fintype ι]
    {a E : ℝ} (σ : ι → ℝ) (ha : 0 < a) (ha2 : a ≤ 2) (hE : 0 ≤ E) (hσ : ∀ i, |σ i| ≤ 1) (p phase : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i,p i ≤ 1)
    (hnear : (99/100)*periodicFourierMaximum a ≤ ∑ i,p i*(σ i*smoothedResponse a E (phase i))) :
    (∑ i,p i*(σ i*(-smoothedSecondMoment a E (phase i)))) ≤
      -(1/1000)*periodicFrequency a^2*periodicCoefficient a 0 := by
  have h := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) =>
    mul_le_mul_of_nonneg_left (smoothed_restoring_pointwise_signed ha ha2 hE (hσ i) (phase i)) (hp i))
  have he : (∑ i,p i*(-periodicFrequency a^2*(σ i*smoothedResponse a E (phase i))+
      (89/100)*periodicFrequency a^2*periodicCoefficient a 0)) =
      -periodicFrequency a^2*(∑ i,p i*(σ i*smoothedResponse a E (phase i)))+
        ((89/100)*periodicFrequency a^2*periodicCoefficient a 0)*(∑ i,p i) := by
    simp_rw [mul_add,Finset.sum_add_distrib]
    rw [Finset.mul_sum,Finset.mul_sum]
    congr 1 <;> apply Finset.sum_congr rfl <;> intro i _ <;> ring
  rw [he] at h
  have hC := mul_le_mul_of_nonneg_left hsum
    (show 0 ≤ (89/100)*periodicFrequency a^2*periodicCoefficient a 0 by positivity [periodicCoefficient_pos ha 0])
  have hF := periodicFourierMaximum_lower ha ha2
  have hnear' : (891/1000)*periodicCoefficient a 0 ≤ ∑ i,p i*(σ i*smoothedResponse a E (phase i)) := by linarith
  have hm := mul_le_mul_of_nonneg_left hnear' (sq_nonneg (periodicFrequency a))
  nlinarith

end NeuralGeneralization.OnlineLowerTanh
