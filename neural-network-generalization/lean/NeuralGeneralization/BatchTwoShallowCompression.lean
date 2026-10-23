import NeuralGeneralization.BatchTwoShallowMixture
import NeuralGeneralization.IIDHoeffding

/-! A common finite vote family and actual independent halfspace sampling.
Its size depends on the input dimension and approximation budget, and not
on the learner width or its first-layer coefficient sizes. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel CompressionSampling BoundedDual

def vote {d : ℕ} (B : ℝ) (m : ℕ) (a : Fin m → Halfspace d) (x : Cube d) : ℝ :=
  B * (∑ i, halfspaceValue (a i) x) / m

theorem abs_halfspaceValue {d : ℕ} (h : Halfspace d) (x : Cube d) :
    |halfspaceValue h x| = 1 := by
  classical
  unfold halfspaceValue
  split_ifs <;> norm_num

theorem vote_approximation_tail {d N : ℕ} {B : ℝ} (hB : 0 < B)
    (b : Fin N → Fin (d+1) → ℝ) (v : Fin N → ℝ) (hv : entryL1 v ≤ B)
    (m : ℕ) (hm : 0 < m) (x : Cube d) :
    (iidSamples (mixtureLaw hB b v hv) m).real
      {a | (1 : ℝ)/16 < |vote B m a x - ∑ i, v i * Real.tanh (dot (b i) (inputVector x))|} ≤
      2 * Real.exp (-(m : ℝ)/(512*B^2)) := by
  have hmR : 0 < (m : ℝ) := by exact_mod_cast hm
  let z := ∑ i, v i * Real.tanh (dot (b i) (inputVector x))
  have ht := iid_bounded_sum_tail (mixtureLaw hB b v hv) m (fun h => halfspaceValue h x)
    (measurable_of_finite _) (B := 1) (ε := (m : ℝ)/(16*B)) (by norm_num)
    (fun h => (abs_halfspaceValue h x).le) (by positivity)
  rw [mixtureLaw_mean] at ht
  have he : -((m : ℝ)/(16*B))^2 / (2*(m : ℝ)*(1 : ℝ)^2) =
      -(m : ℝ)/(512*B^2) := by field_simp; ring
  rw [he] at ht
  apply le_trans (measureReal_mono ?_) ht
  intro a ha
  have hid : vote B m a x - z =
      B/(m : ℝ) * ((∑ i, halfspaceValue (a i) x) - (m : ℝ)*z/B) := by
    unfold vote
    field_simp
  change (1 : ℝ)/16 < |vote B m a x-z| at ha
  rw [hid, abs_mul, abs_of_pos (div_pos hB hmR)] at ha
  have hma := mul_lt_mul_of_pos_right ha ((div_pos hmR hB))
  have hc : B/(m : ℝ) * ((m : ℝ)/B) = 1 := by field_simp
  have he' : B/(m : ℝ) * |((∑ i, halfspaceValue (a i) x) - (m : ℝ)*z/B)| * ((m : ℝ)/B) =
      |((∑ i, halfspaceValue (a i) x) - (m : ℝ)*z/B)| := by
    calc _ = (B/(m : ℝ)*((m : ℝ)/B)) * |((∑ i, halfspaceValue (a i) x) - (m : ℝ)*z/B)| := by ring
         _ = _ := by rw [hc, one_mul]
  rw [he'] at hma
  change (m : ℝ)/(16*B) ≤ |(∑ i, halfspaceValue (a i) x) - (m : ℝ)*(z/B)|
  convert hma.le using 1 <;> congr 1 <;> ring

theorem halfspace_log_card_bound (d : ℕ) :
    Real.log (Fintype.card (Halfspace d) : ℝ) ≤ (d+1)*(1+(d : ℝ)*Real.log 2) := by
  have hc : 0 < (Fintype.card (Halfspace d) : ℝ) := by exact_mod_cast Fintype.card_pos
  have hcount : (Fintype.card (Halfspace d) : ℝ) ≤ ((2 : ℝ)^d+1)^(d+1) := by
    exact_mod_cast halfspace_card_bound d
  have hp : (1 : ℝ) ≤ 2^d := one_le_pow₀ (by norm_num)
  have ha : (2 : ℝ)^d+1 ≤ 2*2^d := by linarith
  have hl := Real.log_le_log (by positivity : 0 < (2 : ℝ)^d+1) ha
  rw [Real.log_mul (by norm_num) (by positivity), Real.log_pow] at hl
  have hl2 : Real.log (2 : ℝ) ≤ 1 := by
    linarith [Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ)<2)]
  calc
    _ ≤ Real.log (((2 : ℝ)^d+1)^(d+1)) := Real.log_le_log hc hcount
    _ = (d+1 : ℕ)*Real.log ((2 : ℝ)^d+1) := Real.log_pow _ _
    _ ≤ _ := by push_cast; nlinarith

theorem vote_log_card_bound (d m : ℕ) :
    Real.log (Fintype.card (Fin m → Halfspace d) : ℝ) ≤
      (m : ℝ)*(d+1)*(1+(d : ℝ)*Real.log 2) := by
  rw [Fintype.card_fun, Fintype.card_fin, Nat.cast_pow, Real.log_pow]
  have hh := mul_le_mul_of_nonneg_left (halfspace_log_card_bound d) (Nat.cast_nonneg m : (0 : ℝ) ≤ m)
  simpa only [mul_assoc] using hh

end NeuralGeneralization.BatchTwoShallow
