import NeuralGeneralization.BatchTwoContinuousDepthScalarChannel
import NeuralGeneralization.BatchTwoContinuousDepthBranches

/-! An energy-efficient expanding scalar channel. Its gain 7/5 has squared
cost 49/25 per hidden layer while its inverse contracts by 6/7 on the entire
target range. -/
noncomputable section
set_option maxHeartbeats 2000000
namespace NeuralGeneralization.BatchTwoContinuousDepthLower

def slowChannel (t : ℝ) : ℝ := Real.tanh ((7/5)*t)
def inverseSlowChannel (t : ℝ) : ℝ := (5/7)*Real.artanh t

theorem artanh_six_fifths {t : ℝ} (h0 : 0≤t) (ht : t≤13/20) :
    Real.artanh t≤(6/5)*t := by
  have he:=Real.sum_le_exp_of_nonneg (by positivity : 0≤(12/5)*t) 7
  norm_num [Finset.sum_range_succ] at he
  have hp (k : ℕ) : t^(k+2)≤t^2*(13/20:ℝ)^k := by
    have hh:=mul_le_mul_of_nonneg_right (pow_le_pow_left₀ h0 ht k) (sq_nonneg t)
    simpa only [pow_add,pow_two,mul_comm] using hh
  have h2 : t^2≤(13/20)*t := by nlinarith
  have hP : 1+t≤(1-t)*(1+12/5*t+((12/5)*t)^2/2+((12/5)*t)^3/6+
      ((12/5)*t)^4/24+((12/5)*t)^5/120+((12/5)*t)^6/720) := by
    nlinarith [hp 1,hp 2,hp 3,hp 4,hp 5]
  have he' := mul_le_mul_of_nonneg_left he (by linarith : 0≤1-t)
  have hexp : 1+t≤(1-t)*Real.exp ((12/5)*t) := by nlinarith
  have hh : t≤Real.tanh ((6/5)*t) := by
    rw [tanh_double_exp]
    have hden : 0<Real.exp (2*((6/5)*t))+1:=by positivity
    apply (le_div_iff₀ hden).mpr
    rw [show 2*((6/5)*t)=(12/5)*t by ring]
    nlinarith
  have h:=Real.artanh_le_artanh (by linarith : -1<t) (Real.tanh_lt_one ((6/5)*t)) hh
  simpa only [Real.artanh_tanh] using h

theorem slowChannel_inverse {t : ℝ} (ht : |t|≤13/20) : slowChannel (inverseSlowChannel t)=t := by
  unfold slowChannel inverseSlowChannel
  rw [show (7/5)*((5/7)*Real.artanh t)=Real.artanh t by ring]
  exact Real.tanh_artanh ⟨by linarith [(abs_le.mp ht).1],by linarith [(abs_le.mp ht).2]⟩

theorem inverseSlowChannel_bound {t : ℝ} (ht : |t|≤13/20) :
    |inverseSlowChannel t|≤(6/7)*|t| := by
  by_cases h0 : 0≤t
  · have hn:=Real.artanh_nonneg h0
    have hb:=artanh_six_fifths h0 ((abs_le.mp ht).2)
    unfold inverseSlowChannel
    rw [abs_of_nonneg (by positivity),abs_of_nonneg h0]
    linarith
  · have hneg : 0≤-t:=by linarith
    have hn:=Real.artanh_nonneg hneg
    have hb:=artanh_six_fifths hneg (by linarith [(abs_le.mp ht).1])
    rw [artanh_negation (ht.trans_lt (by norm_num))] at hn hb
    unfold inverseSlowChannel
    rw [abs_of_nonpos (by nlinarith),abs_of_neg (lt_of_not_ge h0)]
    linarith

theorem inverseSlowChannel_iterate_bound (m : ℕ) {t : ℝ} (ht : |t|≤13/20) :
    |inverseSlowChannel^[m] t|≤(6/7:ℝ)^m*|t| := by
  induction m with
  | zero=>simp
  | succ m ih=>
    have hc : |inverseSlowChannel^[m] t|≤13/20 := by
      have hp : (6/7:ℝ)^m≤1:=pow_le_one₀ (by norm_num) (by norm_num)
      nlinarith [abs_nonneg t]
    rw [Function.iterate_succ_apply']
    have hb:=inverseSlowChannel_bound hc
    rw [pow_succ]
    nlinarith

theorem slowChannel_iterate_inverse (m : ℕ) {t : ℝ} (ht : |t|≤13/20) :
    slowChannel^[m] (inverseSlowChannel^[m] t)=t := by
  induction m with
  | zero=>rfl
  | succ m ih=>
    have hc : |inverseSlowChannel^[m] t|≤13/20 := by
      have hb:=inverseSlowChannel_iterate_bound m ht
      have hp : (6/7:ℝ)^m≤1:=pow_le_one₀ (by norm_num) (by norm_num)
      nlinarith [abs_nonneg t]
    rw [Function.iterate_succ_apply' inverseSlowChannel,Function.iterate_succ_apply slowChannel,
      slowChannel_inverse hc,ih]

end NeuralGeneralization.BatchTwoContinuousDepthLower
