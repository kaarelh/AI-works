import NeuralGeneralization.BatchTwoContinuousDepthTeacher
import Mathlib.Analysis.Complex.ExponentialBounds
import Mathlib.Analysis.Calculus.Deriv.MeanValue
import Mathlib.Topology.Order.IntermediateValue

/-! The two actual inverse branches of the explicit tanh expanding map.
All endpoint and derivative inequalities are proved for that map. -/
noncomputable section
open Set
open scoped NNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel

theorem exp_three_bounds : (15 : ℝ) < Real.exp 3 ∧ Real.exp 3 < 21 := by
  have hl : (5/2 : ℝ) < Real.exp 1 := by linarith [Real.exp_one_gt_d9]
  have hu : Real.exp 1 < (11/4 : ℝ) := by linarith [Real.exp_one_lt_d9]
  have hpow1 := pow_lt_pow_left₀ hl (by norm_num : (0 : ℝ) ≤ 5/2) (by norm_num : (3 : ℕ) ≠ 0)
  have hpow2 := pow_lt_pow_left₀ hu (Real.exp_pos 1).le (by norm_num : (3 : ℕ) ≠ 0)
  have he : Real.exp 3 = (Real.exp 1)^3 := by
    simpa only [Nat.cast_ofNat,mul_one] using Real.exp_nat_mul (1 : ℝ) 3
  norm_num only at hpow1 hpow2
  constructor <;> rw [he] <;> linarith

theorem exp_twenty_gt : (4000 : ℝ) < Real.exp 20 := by
  have hpow := pow_lt_pow_left₀ Real.exp_one_gt_two (by norm_num : (0 : ℝ) ≤ 2)
    (by norm_num : (20 : ℕ) ≠ 0)
  have he : Real.exp 20 = (Real.exp 1)^20 := by
    simpa only [Nat.cast_ofNat,mul_one] using Real.exp_nat_mul (1 : ℝ) 20
  norm_num only at hpow
  rw [he]
  linarith

theorem tanh_double_exp (x : ℝ) :
    Real.tanh x = (Real.exp (2*x)-1)/(Real.exp (2*x)+1) := by
  rw [Real.tanh_eq,Real.exp_neg,show 2*x=x+x by ring,Real.exp_add]
  have hx := (Real.exp_pos x).ne'
  field_simp
  <;> ring

theorem tanh_three_half_gt : (7/8 : ℝ) < Real.tanh (3/2) := by
  rw [tanh_double_exp]
  norm_num only at *
  rw [lt_div_iff₀ (by positivity)]
  nlinarith [exp_three_bounds.1]

theorem tanh_ten_gt : (7/8 : ℝ) < Real.tanh 10 := by
  rw [tanh_double_exp]
  norm_num only
  rw [lt_div_iff₀ (by positivity)]
  linarith [exp_twenty_gt]

theorem cosh_three_half_sq_lt : (Real.cosh (3/2))^2 < (6 : ℝ) := by
  have he : Real.exp (-3) ≤ 1 := Real.exp_le_one_iff.mpr (by norm_num)
  have hc : Real.cosh 3 < 11 := by
    rw [Real.cosh_eq]
    linarith [exp_three_bounds.2]
  have ht := Real.cosh_two_mul (3/2 : ℝ)
  norm_num at ht
  nlinarith [Real.cosh_sq_sub_sinh_sq (3/2)]

theorem cosh_ten_sq_gt : (1000 : ℝ) < (Real.cosh 10)^2 := by
  have hc : (2000 : ℝ) < Real.cosh 20 := by
    rw [Real.cosh_eq]
    linarith [exp_twenty_gt,Real.exp_pos (-20)]
  have ht := Real.cosh_two_mul (10 : ℝ)
  norm_num at ht
  nlinarith [Real.cosh_sq_sub_sinh_sq 10]

theorem expandingMap_even (t : ℝ) : expandingMap (-t) = expandingMap t := by
  unfold expandingMap
  rw [show 10*(-t+1/2)=-(10*(t-1/2)) by ring,
    show 10*(-t-1/2)=-(10*(t+1/2)) by ring,
    Real.tanh_neg,Real.tanh_neg]
  ring

theorem expandingMap_left_endpoint : (3/4 : ℝ) < expandingMap (1/2) := by
  unfold expandingMap
  norm_num only
  rw [Real.tanh_zero]
  linarith [tanh_ten_gt]

theorem expandingMap_right_endpoint : expandingMap (13/20) < (-3/4 : ℝ) := by
  unfold expandingMap
  norm_num only
  linarith [tanh_three_half_gt,Real.tanh_lt_one (23/2)]

def expandingDerivative (t : ℝ) : ℝ :=
  20*(1/(Real.cosh (10*(t+1/2)))^2-1/(Real.cosh (10*(t-1/2)))^2)

theorem hasDerivAt_expandingMap (t : ℝ) :
    HasDerivAt expandingMap (expandingDerivative t) t := by
  have h1 := (hasDerivAt_tanh (10*(t+1/2))).comp t
    (((hasDerivAt_id t).add_const (1/2)).const_mul 10)
  have h2 := (hasDerivAt_tanh (10*(t-1/2))).comp t
    (((hasDerivAt_id t).sub_const (1/2)).const_mul 10)
  have h := ((h1.sub h2).const_mul 2).sub_const 1
  simp only [mul_one] at h
  change HasDerivAt expandingMap
    (2*(1 / (Real.cosh (10*(t+1/2)))^2*10 - 1 / (Real.cosh (10*(t-1/2)))^2*10)) t at h
  convert h using 1 <;> unfold expandingDerivative <;> ring

/-- On the positive branch, the map has slope in [-20,-3]. -/
theorem expandingDerivative_bounds {t : ℝ} (ht : t ∈ Icc (1/2) (13/20)) :
    (-20 : ℝ) ≤ expandingDerivative t ∧ expandingDerivative t ≤ -3 := by
  have hsmall : (Real.cosh (10*(t-1/2)))^2 < 6 := by
    have hcosh : Real.cosh (10*(t-1/2)) ≤ Real.cosh (3/2) :=
      Real.cosh_le_cosh.mpr (by rw [abs_of_nonneg (by linarith [ht.1]),abs_of_pos (by norm_num)]; linarith [ht.2])
    nlinarith [Real.cosh_pos (10*(t-1/2)),Real.cosh_pos (3/2),cosh_three_half_sq_lt]
  have hlarge : 1000 < (Real.cosh (10*(t+1/2)))^2 := by
    have hcosh : Real.cosh 10 ≤ Real.cosh (10*(t+1/2)) :=
      Real.cosh_le_cosh.mpr (by rw [abs_of_pos (by norm_num),abs_of_nonneg (by linarith [ht.1])]; linarith [ht.1])
    nlinarith [Real.cosh_pos 10,Real.cosh_pos (10*(t+1/2)),cosh_ten_sq_gt]
  have hspos : 0 < (Real.cosh (10*(t-1/2)))^2 := sq_pos_of_pos (Real.cosh_pos _)
  have hlpos : 0 < (Real.cosh (10*(t+1/2)))^2 := sq_pos_of_pos (Real.cosh_pos _)
  have hsone : 1 ≤ (Real.cosh (10*(t-1/2)))^2 := by
    nlinarith [Real.one_le_cosh (10*(t-1/2))]
  have hslo : (1/6 : ℝ) < 1/(Real.cosh (10*(t-1/2)))^2 := by
    rw [lt_div_iff₀ hspos]; linarith
  have hshi : 1/(Real.cosh (10*(t-1/2)))^2 ≤ 1 := (div_le_one hspos).mpr hsone
  have hllo : 0 ≤ 1/(Real.cosh (10*(t+1/2)))^2 := by positivity
  have hlhi : 1/(Real.cosh (10*(t+1/2)))^2 < (1/1000 : ℝ) := by
    rw [div_lt_iff₀ hlpos]; linarith
  unfold expandingDerivative
  constructor <;> linarith

/-- The original expanding branch is quantitatively injective in both directions. -/
theorem expandingMap_branch_distance {s t : ℝ}
    (hs : s ∈ Icc (1/2) (13/20)) (ht : t ∈ Icc (1/2) (13/20)) :
    3*|s-t| ≤ |expandingMap s-expandingMap t| ∧
    |expandingMap s-expandingMap t| ≤ 20*|s-t| := by
  wlog hst : s ≤ t generalizing s t
  · have h := this ht hs (le_of_not_ge hst)
    simpa only [abs_sub_comm] using h
  obtain hst | rfl := lt_or_eq_of_le hst
  · obtain ⟨c,hc,he⟩ := exists_hasDerivAt_eq_slope expandingMap expandingDerivative hst
      continuous_expandingMap.continuousOn (fun x _ => hasDerivAt_expandingMap x)
    have hd := expandingDerivative_bounds (t := c) ⟨hs.1.trans hc.1.le,hc.2.le.trans ht.2⟩
    have he' : expandingMap t-expandingMap s = expandingDerivative c*(t-s) :=
      (eq_div_iff (sub_ne_zero.mpr hst.ne')).mp he |>.symm
    have hlo : 3*(t-s) ≤ expandingMap s-expandingMap t := by nlinarith
    have hhi : expandingMap s-expandingMap t ≤ 20*(t-s) := by nlinarith
    rw [abs_of_nonpos (sub_nonpos.mpr hst.le),
      abs_of_nonneg (by nlinarith : 0 ≤ expandingMap s-expandingMap t)]
    constructor <;> linarith
  · simp

/-- A chosen positive inverse branch exists on the entire closed target interval. -/
theorem positiveBranch_exists (y : ℝ) (hy : y ∈ Icc (-3/4) (3/4)) :
    ∃ t ∈ Icc (1/2) (13/20), expandingMap t = y := by
  apply intermediate_value_Icc' (by norm_num : (1/2 : ℝ) ≤ 13/20)
    continuous_expandingMap.continuousOn
  exact ⟨expandingMap_right_endpoint.le.trans hy.1,hy.2.trans expandingMap_left_endpoint.le⟩

abbrev BranchDomain := Icc (-3/4 : ℝ) (3/4)

def positiveBranch (y : BranchDomain) : ℝ :=
  Classical.choose (positiveBranch_exists y y.property)

theorem positiveBranch_mem (y : BranchDomain) : positiveBranch y ∈ Icc (1/2) (13/20) :=
  (Classical.choose_spec (positiveBranch_exists y y.property)).1

theorem expandingMap_positiveBranch (y : BranchDomain) : expandingMap (positiveBranch y) = y :=
  (Classical.choose_spec (positiveBranch_exists y y.property)).2

def branch (b : Bool) (y : BranchDomain) : BranchDomain :=
  if b then ⟨positiveBranch y, by have h:=positiveBranch_mem y; constructor <;> linarith [h.1,h.2]⟩
  else ⟨-positiveBranch y, by have h:=positiveBranch_mem y; constructor <;> linarith [h.1,h.2]⟩

theorem expandingMap_branch (b : Bool) (y : BranchDomain) :
    expandingMap (branch b y) = y := by
  cases b <;> simp only [branch,Bool.false_eq_true,↓reduceIte,expandingMap_even,expandingMap_positiveBranch]

theorem branch_distance (b : Bool) (s t : BranchDomain) :
    (1/20 : ℝ)*|s.val-t.val| ≤ |(branch b s).val-(branch b t).val| ∧
    |(branch b s).val-(branch b t).val| ≤ (1/3 : ℝ)*|s.val-t.val| := by
  have h := expandingMap_branch_distance (positiveBranch_mem s) (positiveBranch_mem t)
  rw [expandingMap_positiveBranch,expandingMap_positiveBranch] at h
  have h' : (1/20 : ℝ)*|s.val-t.val| ≤ |positiveBranch s-positiveBranch t| ∧
      |positiveBranch s-positiveBranch t| ≤ (1/3 : ℝ)*|s.val-t.val| := by constructor <;> linarith [h.1,h.2]
  cases b
  · simpa only [branch,Bool.false_eq_true,↓reduceIte,neg_sub_neg,abs_sub_comm] using h'
  · exact h'

theorem branch_gap (s t : BranchDomain) :
    1 ≤ |(branch true s).val-(branch false t).val| := by
  have hs := positiveBranch_mem s
  have ht := positiveBranch_mem t
  simp only [branch,↓reduceIte,Bool.false_eq_true,sub_neg_eq_add]
  rw [abs_of_nonneg (by linarith [hs.1,ht.1])]
  linarith [hs.1,ht.1]

theorem branch_lipschitz (b : Bool) : LipschitzWith (1/3) (branch b) := by
  apply LipschitzWith.of_dist_le_mul
  intro s t
  simpa only [Subtype.dist_eq,Real.dist_eq,NNReal.coe_div,NNReal.coe_one,NNReal.coe_ofNat]
    using (branch_distance b s t).2

end NeuralGeneralization.BatchTwoContinuousDepthLower
