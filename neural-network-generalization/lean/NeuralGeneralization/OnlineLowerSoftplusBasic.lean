import Mathlib.Analysis.SpecialFunctions.Log.Deriv
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Analysis.Convex.Deriv

/-! # The literal standard softplus and its elementary quantitative bounds -/
noncomputable section
open scoped Topology
open Filter
namespace NeuralGeneralization.OnlineLowerSoftplus

def softplus (x : ℝ) : ℝ := Real.log (1 + Real.exp x)
def sigmoid (x : ℝ) : ℝ := Real.exp x / (1 + Real.exp x)
def curvature (x : ℝ) : ℝ := Real.exp x / (1 + Real.exp x)^2

lemma hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (sigmoid x) x := by
  change HasDerivAt (fun y => Real.log (1 + Real.exp y)) (Real.exp x / (1 + Real.exp x)) x
  exact ((Real.hasDerivAt_exp x).const_add 1).log (by positivity : 1 + Real.exp x ≠ 0)

lemma hasDerivAt_sigmoid (x : ℝ) : HasDerivAt sigmoid (curvature x) x := by
  have h := (Real.hasDerivAt_exp x).div ((Real.hasDerivAt_exp x).const_add 1)
    (by positivity : 1 + Real.exp x ≠ 0)
  have he : (Real.exp x * (1 + Real.exp x) - Real.exp x * Real.exp x) = Real.exp x := by ring
  rw [he] at h
  exact h

lemma continuous_softplus : Continuous softplus :=
  Differentiable.continuous (fun x => (hasDerivAt_softplus x).differentiableAt)
lemma continuous_sigmoid : Continuous sigmoid :=
  Differentiable.continuous (fun x => (hasDerivAt_sigmoid x).differentiableAt)
lemma continuous_curvature : Continuous curvature := by
  unfold curvature
  exact Real.continuous_exp.div ((continuous_const.add Real.continuous_exp).pow 2)
    (fun x => by positivity)

lemma sigmoid_nonneg (x : ℝ) : 0 ≤ sigmoid x := by unfold sigmoid; positivity
lemma sigmoid_le_one (x : ℝ) : sigmoid x ≤ 1 := by
  unfold sigmoid
  apply (div_le_one (by positivity : 0 < 1 + Real.exp x)).mpr
  linarith
lemma curvature_nonneg (x : ℝ) : 0 ≤ curvature x := by unfold curvature; positivity
lemma curvature_pos (x : ℝ) : 0 < curvature x := by unfold curvature; positivity

lemma softplus_lipschitz : LipschitzWith 1 softplus := by
  apply lipschitzWith_of_nnnorm_deriv_le (fun x => (hasDerivAt_softplus x).differentiableAt)
  intro x
  rw [(hasDerivAt_softplus x).deriv]
  change |sigmoid x| ≤ 1
  rw [abs_of_nonneg (sigmoid_nonneg x)]
  exact sigmoid_le_one x

lemma softplus_abs_sub_le (x y : ℝ) : |softplus x - softplus y| ≤ |x-y| := by
  simpa only [Real.dist_eq, NNReal.coe_one, one_mul] using softplus_lipschitz.dist_le_mul x y

lemma sigmoid_monotone : Monotone sigmoid :=
  monotone_of_deriv_nonneg (fun x => (hasDerivAt_sigmoid x).differentiableAt)
    (fun x => by rw [(hasDerivAt_sigmoid x).deriv]; exact curvature_nonneg x)

lemma softplus_convex : ConvexOn ℝ Set.univ softplus := by
  apply Monotone.convexOn_univ_of_deriv (fun x => (hasDerivAt_softplus x).differentiableAt)
  simpa only [(funext (fun x => (hasDerivAt_softplus x).deriv))] using sigmoid_monotone

@[simp] lemma softplus_zero : softplus 0 = Real.log 2 := by simp [softplus]; norm_num
lemma softplus_nonneg (x : ℝ) : 0 ≤ softplus x := by
  apply Real.log_nonneg
  have := Real.exp_pos x
  linarith

lemma softplus_neg_identity (x : ℝ) : softplus x = x + softplus (-x) := by
  have hx : Real.exp x ≠ 0 := (Real.exp_pos x).ne'
  have he : 1 + Real.exp x = Real.exp x * (1 + Real.exp (-x)) := by
    rw [mul_add, mul_one, ← Real.exp_add]
    simp [add_comm]
  unfold softplus
  rw [he, Real.log_mul hx (by positivity), Real.log_exp]

lemma softplus_relu_error (x : ℝ) :
    0 ≤ softplus x - max 0 x ∧ softplus x - max 0 x ≤ Real.log 2 := by
  have hb (t : ℝ) (ht : t ≤ 0) : softplus t ≤ Real.log 2 := by
    apply Real.log_le_log (by positivity)
    have he := Real.exp_le_exp.mpr ht
    rw [Real.exp_zero] at he
    linarith
  by_cases hx : 0 ≤ x
  · rw [max_eq_right hx, softplus_neg_identity x]
    have hh := softplus_nonneg (-x)
    have hh' := hb (-x) (by linarith)
    constructor <;> linarith
  · rw [max_eq_left (le_of_not_ge hx)]
    simpa using And.intro (softplus_nonneg x) (hb x (le_of_not_ge hx))

lemma softplus_growth (x : ℝ) : |softplus x| ≤ |x| + Real.log 2 := by
  rw [abs_of_nonneg (softplus_nonneg x)]
  have hh := (softplus_relu_error x).2
  have hm : max 0 x ≤ |x| := max_le (abs_nonneg x) (le_abs_self x)
  linarith

lemma scaled_softplus_relu_error (A x : ℝ) (hA : 0 < A) :
    |softplus (A*x)/A - max 0 x| ≤ Real.log 2 / A := by
  have hm : max 0 (A*x) = A * max 0 x := by
    rw [mul_max_of_nonneg _ _ hA.le, mul_zero]
  have hh := softplus_relu_error (A*x)
  have he : softplus (A*x)/A-max 0 x = (softplus (A*x)-max 0 (A*x))/A := by
    rw [hm]; field_simp
  rw [he, abs_div, abs_of_nonneg hh.1, abs_of_pos hA]
  exact div_le_div_of_nonneg_right hh.2 hA.le

end NeuralGeneralization.OnlineLowerSoftplus
