import SmoothedTanhBounds

noncomputable section
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.BatchTwoContinuousDepthCritical
open NeuralGeneralization.BatchTwoNonGaussian

theorem tanh_square_mono_abs {y z : ℝ} (hyz : |y| ≤ |z|) :
    (Real.tanh y)^2 ≤ (Real.tanh z)^2 := by
  have hs (w : ℝ) : (Real.tanh |w|)^2=(Real.tanh w)^2 := by
    rcases le_total 0 w with hw | hw
    · rw [abs_of_nonneg hw]
    · rw [abs_of_nonpos hw,Real.tanh_neg,neg_sq]
  have h0 : 0 ≤ Real.tanh |y| := by
    simpa only [Real.tanh_zero] using tanh_monotone (abs_nonneg y)
  have hm := pow_le_pow_left₀ h0 (tanh_monotone hyz) 2
  simpa only [hs] using hm

theorem tanh_symmetric_antitone_noise {x y z : ℝ} (hx : 0 ≤ x)
    (hyz : (Real.tanh y)^2 ≤ (Real.tanh z)^2) :
    (Real.tanh (x+z)+Real.tanh (x-z))/2 ≤
      (Real.tanh (x+y)+Real.tanh (x-y))/2 := by
  let u := Real.tanh x
  let v := (Real.tanh y)^2
  let w := (Real.tanh z)^2
  let sy := (Real.tanh (x+y)+Real.tanh (x-y))/2
  let sz := (Real.tanh (x+z)+Real.tanh (x-z))/2
  have hu0 : 0 ≤ u := by simpa only [Real.tanh_zero] using tanh_monotone hx
  have hu1 : u^2 < 1 := (sq_lt_one_iff_abs_lt_one _).mpr (Real.abs_tanh_lt_one x)
  have hv1 : v < 1 := (sq_lt_one_iff_abs_lt_one _).mpr (Real.abs_tanh_lt_one y)
  have hw1 : w < 1 := (sq_lt_one_iff_abs_lt_one _).mpr (Real.abs_tanh_lt_one z)
  have hv0 : 0 ≤ v := sq_nonneg _
  have hw0 : 0 ≤ w := sq_nonneg _
  have hdv : 0 < 1-u^2*v := by nlinarith [mul_le_mul_of_nonneg_right hu1.le hv0]
  have hdw : 0 < 1-u^2*w := by nlinarith [mul_le_mul_of_nonneg_right hu1.le hw0]
  have hv : sy*(1-u^2*v)=u*(1-v) := by
    dsimp [sy,u,v]
    nlinarith only [tanh_symmetric_identity x y]
  have hw : sz*(1-u^2*w)=u*(1-w) := by
    dsimp [sz,u,w]
    nlinarith only [tanh_symmetric_identity x z]
  have he : (sy-sz)*(1-u^2*v)*(1-u^2*w)=u*(1-u^2)*(w-v) := by
    linear_combination (1-u^2*w)*hv-(1-u^2*v)*hw
  have hn : 0 ≤ u*(1-u^2)*(w-v) :=
    mul_nonneg (mul_nonneg hu0 (sub_nonneg.mpr hu1.le)) (sub_nonneg.mpr hyz)
  rw [← he,mul_assoc] at hn
  have hh := (mul_nonneg_iff_of_pos_right (mul_pos hdv hdw)).mp hn
  exact sub_nonneg.mp hh

/-- Gaussian smoothing decreases the positive smoothed tanh mean. The proof
uses symmetric pointwise averages, so no heat-equation theorem is assumed. -/
theorem shiftedMean_antitone_noise {r s x : ℝ} (hr : 0 ≤ r) (hrs : r ≤ s) (hx : 0 ≤ x) :
    shiftedMean s x ≤ shiftedMean r x := by
  let F : ℝ → ℝ → ℝ := fun a z =>
    (Real.tanh (x+Real.sqrt a*z)+Real.tanh (x-Real.sqrt a*z))/2
  have hI (a : ℝ) : Integrable (F a) (gaussianReal 0 1) := by
    apply Integrable.of_bound (by unfold F; fun_prop) 1
    filter_upwards [] with z
    dsimp [F]
    rw [abs_div]
    have ht := abs_add_le (Real.tanh (x+Real.sqrt a*z)) (Real.tanh (x-Real.sqrt a*z))
    norm_num
    linarith [(Real.abs_tanh_lt_one (x+Real.sqrt a*z)).le,
      (Real.abs_tanh_lt_one (x-Real.sqrt a*z)).le]
  rw [shiftedMean_symmetric_integral,shiftedMean_symmetric_integral]
  apply integral_mono (hI s) (hI r)
  intro z
  apply tanh_symmetric_antitone_noise hx
  apply tanh_square_mono_abs
  rw [abs_mul,abs_mul,abs_of_nonneg (Real.sqrt_nonneg r),abs_of_nonneg (Real.sqrt_nonneg s)]
  exact mul_le_mul_of_nonneg_right (Real.sqrt_le_sqrt hrs) (abs_nonneg z)

theorem shiftedMean_square_antitone_noise {r s : ℝ} (hr : 0 ≤ r) (hrs : r ≤ s) (x : ℝ) :
    (shiftedMean s x)^2 ≤ (shiftedMean r x)^2 := by
  rcases le_total 0 x with hx | hx
  · exact pow_le_pow_left₀ (shiftedMean_nonneg hx s) (shiftedMean_antitone_noise hr hrs hx) 2
  · have hh := pow_le_pow_left₀ (shiftedMean_nonneg (show 0 ≤ -x by linarith) s)
      (shiftedMean_antitone_noise hr hrs (show 0 ≤ -x by linarith)) 2
    simpa only [shiftedMean_odd,neg_sq] using hh

#print axioms shiftedMean_square_antitone_noise
end ConditionalNonpolynomial.Analytic
