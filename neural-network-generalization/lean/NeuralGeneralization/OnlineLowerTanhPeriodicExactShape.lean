import NeuralGeneralization.OnlineLowerTanhPeriodicExactLargeGain
import NeuralGeneralization.OnlineLowerTanhPeriodicExactSecond

/-! The manuscript's strict periodic shape at every positive gain. -/
noncomputable section
open scoped BigOperators
open Set Filter
namespace NeuralGeneralization.OnlineLowerTanh
open TanhDifferential

lemma periodicFourierDerivative_even (a b : ℝ) :
    periodicFourierDerivative a (-b)=periodicFourierDerivative a b := by
  unfold periodicFourierDerivative
  apply tsum_congr
  intro j
  rw [mul_neg,Real.cos_neg]

theorem periodic_derivative_pos_all_gain {a b : ℝ} (ha : 0<a)
    (hb : b∈Ioo (-a) a) : 0<periodicFourierDerivative a b := by
  by_cases ha2 : a≤2
  · exact periodic_derivative_pos_small_gain ha ha2 hb
  · have h2a : 2≤a := le_of_not_ge ha2
    by_cases hb0 : 0≤b
    · exact periodic_derivative_pos_large_gain_nonnegative h2a hb0 hb.2
    · rw [←periodicFourierDerivative_even a b]
      exact periodic_derivative_pos_large_gain_nonnegative h2a (by linarith) (by linarith [hb.1])

theorem periodic_peak_second_neg_large_gain {a : ℝ} (ha : 1≤a) :
    periodicFourierSecond a a<0 := by
  have ha0 : 0<a := by linarith
  let D : ℕ → ℝ := fun j => -tanhSecond (a+2*a*j)
  have hmono : Antitone D := antitone_nat_of_succ_le (fun j => by
    have h := tanhSecond_strictMonoOn
      (show 1≤a+2*a*(j:ℝ) by nlinarith [Nat.cast_nonneg (α:=ℝ) j])
      (show 1≤a+2*a*((j+1:ℕ):ℝ) by push_cast;nlinarith [Nat.cast_nonneg (α:=ℝ) j])
      (show a+2*a*(j:ℝ)<a+2*a*((j+1:ℕ):ℝ) by push_cast;nlinarith)
    dsimp [D]
    linarith)
  have hfirst : D 1<D 0 := by
    have h := tanhSecond_strictMonoOn ha (show 1≤a+2*a by linarith) (show a<a+2*a by linarith)
    simpa only [D,Nat.cast_one,Nat.cast_zero,mul_one,mul_zero,add_zero,neg_lt_neg_iff] using h
  have hs := (second_tanh_tail_summable ha0 a).neg
  have hs' : Summable (fun j : ℕ => (-1:ℝ)^j*D j) := by
    apply hs.congr
    intro j
    dsimp [D]
    ring
  have hl := hmono.alternating_series_le_tendsto hs'.hasSum.tendsto_sum_nat 1
  norm_num [Finset.sum_range_succ] at hl
  have hpos : 0<∑'j:ℕ,(-1:ℝ)^j*D j := by linarith
  have he : (∑'j:ℕ,(-1:ℝ)^j*D j) = -(∑'j:ℕ,(-1:ℝ)^j*tanhSecond (a+2*a*j)) := by
    rw [←tsum_neg]
    apply tsum_congr
    intro j
    dsimp [D]
    ring
  rw [he] at hpos
  rw [periodicFourierSecond_eq_real_paired ha0]
  have heq : (∑'j:ℕ,(-1:ℝ)^j*(tanhSecond (a+2*a*j)+tanhSecond (2*a-a+2*a*j))) =
      2*(∑'j:ℕ,(-1:ℝ)^j*tanhSecond (a+2*a*j)) := by
    rw [←(second_tanh_tail_summable ha0 a).tsum_mul_left]
    apply tsum_congr
    intro j
    rw [show 2*a-a=a by ring]
    ring
  rw [heq]
  linarith

/-- All three strict shape claims in the exact signed periodic maximum
 theorem, without a restriction to gains at most two. -/
theorem periodic_shape_all_gain {a : ℝ} (ha : 0<a) :
    (∀ b∈Ioo (-a) a, 0<periodicFourierDerivative a b) ∧
    periodicFourierDerivative a a=0 ∧ periodicFourierSecond a a<0 := by
  refine ⟨fun b hb=>periodic_derivative_pos_all_gain ha hb,?_,?_⟩
  · simpa using periodic_derivative_nat_peak ha 0
  · by_cases h : a≤2
    · exact (periodic_peak_second_neg_small_gain ha h).2
    · exact periodic_peak_second_neg_large_gain (by linarith)

end NeuralGeneralization.OnlineLowerTanh
