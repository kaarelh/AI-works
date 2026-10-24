import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.SpecialFunctions.ExpDeriv

/-! A dimension-free exponential potential for Hilbert-valued sums.
The extra coordinate of length one makes the norm smooth at the origin;
the proof only needs elementary norm and exponential inequalities. -/
noncomputable section
open scoped RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoHilbert
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

def radialNorm (x : E) : ℝ := Real.sqrt (1 + ‖x‖ ^ 2)
def potential (x : E) : ℝ := Real.exp (radialNorm x)

theorem radialNorm_ge_one (x : E) : 1 ≤ radialNorm x := by
  simpa only [radialNorm, Real.sqrt_one] using
    Real.sqrt_le_sqrt (show (1 : ℝ) ≤ 1 + ‖x‖ ^ 2 by nlinarith only [sq_nonneg ‖x‖])

theorem radialNorm_pos (x : E) : 0 < radialNorm x :=
  lt_of_lt_of_le (by norm_num) (radialNorm_ge_one x)

theorem radialNorm_sq (x : E) : radialNorm x ^ 2 = 1 + ‖x‖ ^ 2 :=
  Real.sq_sqrt (by positivity)

theorem norm_le_radialNorm (x : E) : ‖x‖ ≤ radialNorm x := by
  nlinarith only [radialNorm_sq x, radialNorm_pos x, norm_nonneg x]

theorem radialNorm_add_le (x y : E) : radialNorm (x+y) ≤ radialNorm x + ‖y‖ := by
  have hs : ‖x+y‖ ^ 2 ≤ (‖x‖ + ‖y‖) ^ 2 :=
    pow_le_pow_left₀ (norm_nonneg _) (norm_add_le x y) 2
  have hm := mul_le_mul_of_nonneg_right (norm_le_radialNorm x) (norm_nonneg y)
  nlinarith only [radialNorm_sq (x+y), radialNorm_sq x, radialNorm_pos x,
    radialNorm_pos (x+y), norm_nonneg y, hs, hm]

theorem radialNorm_increment_abs (x y : E) :
    |radialNorm (x+y)-radialNorm x| ≤ ‖y‖ := by
  have h1 := radialNorm_add_le x y
  have h2 := radialNorm_add_le (x+y) (-y)
  simp only [add_neg_cancel_right, norm_neg] at h2
  exact abs_le.mpr ⟨by linarith only [h2], by linarith only [h1]⟩

theorem radialNorm_increment_tangent (x y : E) :
    radialNorm (x+y)-radialNorm x ≤
      inner ℝ x y / radialNorm x + ‖y‖^2/2 := by
  have hx := radialNorm_sq x
  have hxy := radialNorm_sq (x+y)
  rw [norm_add_sq_real] at hxy
  have hr := radialNorm_ge_one x
  have hs := sq_nonneg (radialNorm (x+y)-radialNorm x)
  have hmul := mul_le_mul_of_nonneg_right hr (sq_nonneg ‖y‖)
  apply (mul_le_mul_iff_left₀ (radialNorm_pos x)).mp
  have hdiv : (inner ℝ x y / radialNorm x + ‖y‖^2/2)*radialNorm x =
      inner ℝ x y + ‖y‖^2/2*radialNorm x := by
    rw [add_mul, div_mul_cancel₀ _ (radialNorm_pos x).ne']
  rw [hdiv]
  nlinarith only [hx,hxy,hs,hmul]

theorem potential_add_le (x y : E) (hy : ‖y‖ ≤ 1) :
    potential (x+y) ≤ potential x +
      potential x / radialNorm x * inner ℝ x y +
      (3/2 : ℝ)*potential x*‖y‖^2 := by
  let u := radialNorm (x+y)-radialNorm x
  have hu : |u| ≤ ‖y‖ := radialNorm_increment_abs x y
  have hexp := (le_abs_self (Real.exp u-1-u)).trans
    (Real.abs_exp_sub_one_sub_id_le (hu.trans hy))
  have hsq : u^2 ≤ ‖y‖^2 := by
    nlinarith only [sq_abs u, mul_self_le_mul_self (abs_nonneg u) hu]
  have ht := radialNorm_increment_tangent x y
  change u ≤ _ at ht
  have hb : Real.exp u ≤ 1 + inner ℝ x y/radialNorm x + (3/2 : ℝ)*‖y‖^2 := by
    linarith only [hexp,hsq,ht]
  have hm := mul_le_mul_of_nonneg_left hb (Real.exp_nonneg (radialNorm x))
  have he : potential (x+y) = Real.exp (radialNorm x) * Real.exp u := by
    unfold potential
    rw [← Real.exp_add]
    congr 1
    dsimp [u]
    ring
  rw [he]
  calc
    _ ≤ Real.exp (radialNorm x)*(1+inner ℝ x y/radialNorm x+(3/2 : ℝ)*‖y‖^2) := hm
    _ = _ := by unfold potential; ring

@[simp] theorem potential_zero : potential (0 : E) = Real.exp 1 := by
  simp [potential,radialNorm]

theorem potential_pos (x : E) : 0 < potential x := Real.exp_pos _

theorem exp_norm_le_potential (x : E) : Real.exp ‖x‖ ≤ potential x :=
  Real.exp_le_exp.mpr (norm_le_radialNorm x)

end NeuralGeneralization.BatchTwoHilbert
