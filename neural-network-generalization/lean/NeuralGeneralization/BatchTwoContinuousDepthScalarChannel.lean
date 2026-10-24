import NeuralGeneralization.BatchTwoContinuousDepthTeacher
import NeuralGeneralization.BatchTwoNeuralConverseRelays

/-! A simple repeated scalar tanh channel for the strong-prior lower bound.
The inverse channel contracts all target labels in [-13/20,13/20]. -/
noncomputable section
open Set
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open BatchTwoNeuralConverse

def scalarChannel (t : ℝ) : ℝ := Real.tanh (2*t)
def inverseChannel (t : ℝ) : ℝ := Real.artanh t/2

theorem scalarChannel_inverse {t : ℝ} (ht : |t| ≤ 13/20) :
    scalarChannel (inverseChannel t)=t := by
  unfold scalarChannel inverseChannel
  rw [show 2*(Real.artanh t/2)=Real.artanh t by ring]
  exact Real.tanh_artanh ⟨by linarith [(abs_le.mp ht).1],by linarith [(abs_le.mp ht).2]⟩

theorem artanh_negation {t : ℝ} (ht : |t| < 1) : Real.artanh (-t) = -Real.artanh t := by
  have hi : Function.Injective Real.tanh := Function.LeftInverse.injective Real.artanh_tanh
  apply hi
  rw [Real.tanh_artanh (by constructor <;> linarith [(abs_lt.mp ht).1,(abs_lt.mp ht).2]),
    Real.tanh_neg,Real.tanh_artanh (abs_lt.mp ht)]

theorem inverseChannel_nonnegative_bound {t : ℝ} (h0 : 0 ≤ t) (ht : t ≤ 13/20) :
    0 ≤ inverseChannel t ∧ inverseChannel t ≤ (3/4)*t := by
  have hsq : Real.sqrt (1+((3/2)*t)^2) ≤ (3/2 : ℝ) := by
    apply Real.sqrt_le_iff.mpr
    constructor
    · norm_num
    · nlinarith
  have hp : 0 < Real.sqrt (1+((3/2)*t)^2) := Real.sqrt_pos.mpr (by positivity)
  have htanh : t ≤ Real.tanh ((3/2)*t) := by
    apply le_trans _ (tanh_lower_square_root (by positivity : 0 ≤ (3/2)*t))
    apply (le_div_iff₀ hp).mpr
    nlinarith
  have hi := Real.artanh_le_artanh (by linarith : -1 < t) (Real.tanh_lt_one ((3/2)*t)) htanh
  rw [Real.artanh_tanh] at hi
  unfold inverseChannel
  constructor
  · exact div_nonneg (Real.artanh_nonneg h0) (by norm_num)
  · linarith

theorem inverseChannel_bound {t : ℝ} (ht : |t| ≤ 13/20) :
    |inverseChannel t| ≤ (3/4)*|t| := by
  by_cases h0 : 0 ≤ t
  · have h := inverseChannel_nonnegative_bound h0 (by linarith [(abs_le.mp ht).2])
    rw [abs_of_nonneg h.1,abs_of_nonneg h0]
    exact h.2
  · have h := inverseChannel_nonnegative_bound (by linarith : 0 ≤ -t) (by linarith [(abs_le.mp ht).1])
    have he : inverseChannel (-t) = -inverseChannel t := by
      unfold inverseChannel
      rw [artanh_negation (ht.trans_lt (by norm_num))]
      ring
    rw [he] at h
    rw [abs_of_nonpos (by linarith : inverseChannel t ≤ 0),abs_of_neg (lt_of_not_ge h0)]
    linarith [h.2]

theorem inverseChannel_closed {t : ℝ} (ht : |t| ≤ 13/20) : |inverseChannel t| ≤ 13/20 := by
  have h:=inverseChannel_bound ht
  linarith [abs_nonneg t]

theorem inverseChannel_iterate_bound (m : ℕ) {t : ℝ} (ht : |t| ≤ 13/20) :
    |inverseChannel^[m] t| ≤ (3/4 : ℝ)^m*|t| := by
  induction m with
  | zero => simp
  | succ m ih =>
    have hc : |inverseChannel^[m] t| ≤ 13/20 := by
      have hp : (3/4 : ℝ)^m ≤ 1 := pow_le_one₀ (by norm_num) (by norm_num)
      nlinarith [abs_nonneg t]
    rw [Function.iterate_succ_apply']
    have h:=inverseChannel_bound hc
    rw [pow_succ]
    nlinarith

theorem scalarChannel_iterate_inverse (m : ℕ) {t : ℝ} (ht : |t| ≤ 13/20) :
    scalarChannel^[m] (inverseChannel^[m] t)=t := by
  induction m with
  | zero => rfl
  | succ m ih =>
    have hc : |inverseChannel^[m] t| ≤ 13/20 := by
      have h:=inverseChannel_iterate_bound m ht
      have hp : (3/4 : ℝ)^m ≤ 1 := pow_le_one₀ (by norm_num) (by norm_num)
      nlinarith [abs_nonneg t]
    rw [Function.iterate_succ_apply' inverseChannel,
      Function.iterate_succ_apply scalarChannel,scalarChannel_inverse hc,ih]

end NeuralGeneralization.BatchTwoContinuousDepthLower
