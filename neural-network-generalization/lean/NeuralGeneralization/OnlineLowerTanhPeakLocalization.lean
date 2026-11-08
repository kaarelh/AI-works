import NeuralGeneralization.OnlineLowerTanhPeriodicMaximum
import NeuralGeneralization.OnlineLowerTanhPhase

/-! # Quantitative localization at the literal periodic bias peaks -/
noncomputable section
open scoped BigOperators Topology Classical
namespace NeuralGeneralization.OnlineLowerTanh

lemma phaseWave_le_one_sub_error (odd : Bool) (x : ℝ) :
    phaseWave odd x ≤ 1-(phaseError odd x)^2/2 := by
  rw [phaseWave_eq_cos_error]
  have habs : |Real.pi*phaseError odd x/2| ≤ Real.pi := by
    rw [abs_div, abs_mul, abs_of_pos Real.pi_pos, abs_of_pos (by norm_num : (0 : ℝ) < 2)]
    nlinarith [phaseError_abs_le_one odd x, Real.pi_pos]
  have hc := Real.cos_le_one_sub_mul_cos_sq habs
  convert hc using 1 <;> field_simp <;> ring

lemma periodic_signed_peak_deficit_first_harmonic {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) (b : ℝ) :
    (periodicCoefficient a 0 / 100) * (1-Real.sin (periodicFrequency a*b)) ≤
      periodicFourierMaximum a-periodicFourierResponse a b := by
  have hh := periodic_peak_deficit ha ha2 (b-a)
  have he : periodicFrequency a*(b-a) = periodicFrequency a*b-Real.pi/2 := by
    have hw := periodicFrequency_mul_gain ha.ne'
    nlinarith
  rw [he, Real.cos_sub, Real.cos_pi_div_two, Real.sin_pi_div_two] at hh
  simpa only [show a+(b-a)=b by ring, mul_zero, mul_one, zero_add] using hh

/-- Both signs of the response obey the same nearest-peak deficit. -/
theorem periodic_absolute_peak_deficit {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) (b : ℝ) :
    (periodicCoefficient a 0 / 100) * (1-|Real.sin (periodicFrequency a*b)|) ≤
      periodicFourierMaximum a-|periodicFourierResponse a b| := by
  have hc : 0 ≤ periodicCoefficient a 0 / 100 := by positivity [periodicCoefficient_pos ha 0]
  by_cases hF : 0 ≤ periodicFourierResponse a b
  · rw [abs_of_nonneg hF]
    exact (mul_le_mul_of_nonneg_left (by linarith [le_abs_self (Real.sin (periodicFrequency a*b))]) hc).trans
      (periodic_signed_peak_deficit_first_harmonic ha ha2 b)
  · have hh := periodic_signed_peak_deficit_first_harmonic ha ha2 (b+2*a)
    rw [periodicFourierResponse_antiperiod ha] at hh
    have he : periodicFrequency a*(b+2*a) = periodicFrequency a*b+Real.pi := by
      have hw := periodicFrequency_mul_gain ha.ne'
      nlinarith
    rw [he, Real.sin_add_pi] at hh
    rw [abs_of_neg (lt_of_not_ge hF)]
    exact (mul_le_mul_of_nonneg_left (by linarith [neg_le_abs (Real.sin (periodicFrequency a*b))]) hc).trans hh

/-- Ordinary distance to the nearest odd response lattice has an explicit
quadratic cost, uniformly before any asymptotic limiting argument. -/
theorem periodic_phase_error_deficit {a : ℝ} (ha : 0 < a) (ha2 : a ≤ 2) (b : ℝ) :
    (periodicCoefficient a 0 / 200) * (phaseError true (b/a))^2 ≤
      periodicFourierMaximum a-|periodicFourierResponse a b| := by
  have hw := phaseWave_le_one_sub_error true (b/a)
  have he : Real.pi*(b/a)/2 = periodicFrequency a*b := by unfold periodicFrequency; ring
  change |Real.sin (Real.pi*(b/a)/2)| ≤ 1-(phaseError true (b/a))^2/2 at hw
  rw [he] at hw
  have hc : 0 ≤ periodicCoefficient a 0 / 100 := by positivity [periodicCoefficient_pos ha 0]
  have hm := mul_le_mul_of_nonneg_left hw hc
  have hd := periodic_absolute_peak_deficit ha ha2 b
  nlinarith

def periodicPeakFloor : ℝ := (Real.pi/2)/Real.sinh (Real.pi^2/4)

lemma periodicPeakFloor_pos : 0 < periodicPeakFloor := by
  unfold periodicPeakFloor
  apply div_pos (by positivity)
  exact Real.sinh_pos_iff.mpr (by positivity)

lemma periodicCoefficient_zero_floor {a : ℝ} (ha : 1 ≤ a) (ha2 : a ≤ 2) :
    periodicPeakFloor ≤ periodicCoefficient a 0 := by
  have ha0 : 0 < a := by linarith
  have hden : 0 < Real.sinh (Real.pi^2/4) := Real.sinh_pos_iff.mpr (by positivity)
  have hdec : periodicDecay a ≤ Real.pi^2/4 := by
    unfold periodicDecay
    apply (div_le_iff₀ (by positivity : 0 < 4*a)).mpr
    nlinarith [sq_pos_of_pos Real.pi_pos]
  have hnum : Real.pi/2 ≤ Real.pi/a :=
    div_le_div_of_nonneg_left Real.pi_pos.le ha0 ha2
  unfold periodicPeakFloor periodicCoefficient
  simp only [Nat.cast_zero, mul_zero, zero_add, one_mul]
  exact div_le_div₀ (by positivity) hnum (Real.sinh_pos_iff.mpr (periodicDecay_pos ha0))
    (Real.sinh_le_sinh.mpr hdec)

/-- The nearest response peak is a literal odd integer, and its physical
squared distance is bounded by the response deficit. -/
theorem periodic_nearest_peak_distance {a : ℝ} (ha : 1 ≤ a) (ha2 : a ≤ 2) (b : ℝ) :
    Odd (phaseInteger true (b/a)) ∧
    (b-a*(phaseInteger true (b/a) : ℝ))^2 ≤
      (800/periodicPeakFloor)*(periodicFourierMaximum a-|periodicFourierResponse a b|) := by
  have ha0 : 0 < a := by linarith
  have hfloor := periodicCoefficient_zero_floor ha ha2
  have hdef := periodic_phase_error_deficit ha0 ha2 b
  have hsmall : periodicPeakFloor/200*(phaseError true (b/a))^2 ≤
      periodicFourierMaximum a-|periodicFourierResponse a b| :=
    (mul_le_mul_of_nonneg_right (div_le_div_of_nonneg_right hfloor (by norm_num)) (sq_nonneg _)).trans hdef
  have he : b-a*(phaseInteger true (b/a) : ℝ) = a*phaseError true (b/a) := by
    unfold phaseError
    field_simp
  refine ⟨phaseInteger_odd _, ?_⟩
  rw [he]
  rw [div_mul_eq_mul_div]
  apply (le_div_iff₀ periodicPeakFloor_pos).mpr
  have haSq : a^2 ≤ 4 := by nlinarith
  have hh := mul_le_mul_of_nonneg_right haSq (sq_nonneg (phaseError true (b/a)))
  have hf := mul_le_mul_of_nonneg_left hh periodicPeakFloor_pos.le
  nlinarith

lemma periodic_nearest_peak_index_bound {a b L : ℝ} (ha : 1 ≤ a)
    (hL : |b| ≤ L) : |(phaseInteger true (b/a) : ℝ)| ≤ L+1 := by
  have ha0 : 0 < a := by linarith
  have he : (phaseInteger true (b/a) : ℝ) = b/a-phaseError true (b/a) := by simp [phaseError]
  rw [he]
  have hquot : |b/a| ≤ L := by
    rw [abs_div, abs_of_pos ha0]
    apply (div_le_iff₀ ha0).mpr
    have hL0 : 0 ≤ L := (abs_nonneg b).trans hL
    nlinarith
  exact (abs_sub _ _).trans (by linarith [phaseError_abs_le_one true (b/a)])

end NeuralGeneralization.OnlineLowerTanh
