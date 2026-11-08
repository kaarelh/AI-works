import Mathlib.Data.Rat.Cast.Order
import Mathlib.Tactic

/-! Certified rational ball arithmetic used by the concrete scalar certificate. -/
noncomputable section
namespace NeuralGeneralization.OnlineLowerTanh

structure RationalBall where
  center : ℚ
  radius : ℚ
  deriving DecidableEq

namespace RationalBall

def Contains (I : RationalBall) (x : ℝ) : Prop := |x-(I.center : ℝ)| ≤ (I.radius : ℝ)

def point (q : ℚ) : RationalBall := ⟨q,0⟩
def add (I J : RationalBall) : RationalBall := ⟨I.center+J.center,I.radius+J.radius⟩
def neg (I : RationalBall) : RationalBall := ⟨-I.center,I.radius⟩
def sub (I J : RationalBall) : RationalBall := add I (neg J)
def mul (I J : RationalBall) : RationalBall :=
  ⟨I.center*J.center, |I.center| *J.radius+|J.center| *I.radius+I.radius*J.radius⟩
def inv (I : RationalBall) : RationalBall :=
  ⟨I.center⁻¹,I.radius/(|I.center| *(|I.center|-I.radius))⟩
def div (I J : RationalBall) : RationalBall := mul I (inv J)
def pow (I : RationalBall) : ℕ → RationalBall
  | 0 => point 1
  | n+1 => mul (pow I n) I

theorem contains_point (q : ℚ) : (point q).Contains (q : ℝ) := by simp [Contains,point]

theorem radius_nonneg {I : RationalBall} {x : ℝ} (hx : I.Contains x) : 0 ≤ (I.radius : ℝ) :=
  (abs_nonneg _).trans hx

theorem contains_add {I J : RationalBall} {x y : ℝ} (hx : I.Contains x) (hy : J.Contains y) :
    (add I J).Contains (x+y) := by
  simp only [Contains,add,Rat.cast_add] at hx hy ⊢
  calc
    |x+y-((I.center : ℝ)+J.center)| = |(x-I.center)+(y-J.center)| := by congr 1; ring
    _ ≤ |x-I.center| +|y-J.center| := abs_add_le _ _
    _ ≤ _ := add_le_add hx hy

theorem contains_neg {I : RationalBall} {x : ℝ} (hx : I.Contains x) :
    (neg I).Contains (-x) := by
  change |-x-((-I.center : ℚ) : ℝ)| ≤ (I.radius : ℝ)
  rw [Rat.cast_neg, show -x - -(I.center : ℝ) = -(x-(I.center : ℝ)) by ring, abs_neg]
  exact hx

theorem contains_sub {I J : RationalBall} {x y : ℝ} (hx : I.Contains x) (hy : J.Contains y) :
    (sub I J).Contains (x-y) := by
  simpa only [sub, sub_eq_add_neg] using contains_add hx (contains_neg hy)

theorem contains_mul {I J : RationalBall} {x y : ℝ} (hx : I.Contains x) (hy : J.Contains y) :
    (mul I J).Contains (x*y) := by
  have hri := radius_nonneg hx
  have hrj := radius_nonneg hy
  simp only [Contains,mul,Rat.cast_add,Rat.cast_mul,Rat.cast_abs] at hx hy ⊢
  have hid : x*y-(I.center : ℝ)*J.center =
      (I.center : ℝ)*(y-J.center)+(J.center : ℝ)*(x-I.center)+(x-I.center)*(y-J.center) := by ring
  rw [hid]
  calc
    _ ≤ |(I.center : ℝ)*(y-J.center)+(J.center : ℝ)*(x-I.center)| +
        |(x-I.center)*(y-J.center)| := abs_add_le _ _
    _ ≤ |(I.center : ℝ)*(y-J.center)| +|(J.center : ℝ)*(x-I.center)| +
        |(x-I.center)*(y-J.center)| := add_le_add (abs_add_le _ _) le_rfl
    _ = |(I.center : ℝ)| *|y-J.center| +|(J.center : ℝ)| *|x-I.center| +
        |x-I.center| *|y-J.center| := by simp only [abs_mul]
    _ ≤ _ := add_le_add
      (add_le_add (mul_le_mul_of_nonneg_left hy (abs_nonneg _))
        (mul_le_mul_of_nonneg_left hx (abs_nonneg _)))
      (mul_le_mul hx hy (abs_nonneg _) hri)

theorem contains_inv {I : RationalBall} {x : ℝ} (hx : I.Contains x)
    (hgap : I.radius < |I.center|) : (inv I).Contains x⁻¹ := by
  have hr := radius_nonneg hx
  have hg : (I.radius : ℝ) < |(I.center : ℝ)| := by exact_mod_cast hgap
  have hc : 0 < |(I.center : ℝ)| := lt_of_le_of_lt hr hg
  have hlow : |(I.center : ℝ)|-(I.radius : ℝ) ≤ |x| := by
    have h := abs_sub_abs_le_abs_sub (I.center : ℝ) x
    rw [abs_sub_comm] at h
    exact sub_le_iff_le_add.mpr (by linarith [show |x-(I.center : ℝ)| ≤ (I.radius : ℝ) from hx])
  have hxpos : 0 < |x| := lt_of_lt_of_le (sub_pos.mpr hg) hlow
  have hxn : x ≠ 0 := abs_pos.mp hxpos
  have hcn : (I.center : ℝ) ≠ 0 := abs_pos.mp hc
  have heq : |x⁻¹-(I.center : ℝ)⁻¹| = |x-I.center|/(|x| *|(I.center : ℝ)|) := by
    rw [inv_sub_inv hxn hcn, abs_div, abs_mul, abs_sub_comm]
  simp only [Contains,inv,Rat.cast_inv,Rat.cast_div,Rat.cast_mul,Rat.cast_sub,Rat.cast_abs]
  rw [heq]
  calc
    |x-I.center|/(|x| *|(I.center : ℝ)|) ≤ (I.radius : ℝ)/(|x| *|(I.center : ℝ)|) :=
      div_le_div_of_nonneg_right hx (mul_nonneg hxpos.le hc.le)
    _ ≤ (I.radius : ℝ)/(|(I.center : ℝ)| *(|(I.center : ℝ)|-I.radius)) := by
      apply div_le_div_of_nonneg_left hr (mul_pos hc (sub_pos.mpr hg))
      nlinarith

theorem contains_div {I J : RationalBall} {x y : ℝ} (hx : I.Contains x) (hy : J.Contains y)
    (hgap : J.radius < |J.center|) : (div I J).Contains (x/y) := by
  simpa only [div, div_eq_mul_inv] using contains_mul hx (contains_inv hy hgap)

theorem contains_pow {I : RationalBall} {x : ℝ} (hx : I.Contains x) (n : ℕ) :
    (pow I n).Contains (x^n) := by
  induction n with
  | zero => simpa [pow] using contains_point 1
  | succ n ih => simpa [pow,pow_succ] using contains_mul ih hx

theorem contains_weaken {I J : RationalBall} {x : ℝ} (hx : I.Contains x)
    (h : |I.center-J.center| +I.radius ≤ J.radius) : J.Contains x := by
  have hh : |(I.center : ℝ)-J.center| +(I.radius : ℝ) ≤ J.radius := by exact_mod_cast h
  unfold Contains at hx ⊢
  calc
    |x-J.center| = |(x-I.center)+(I.center-J.center)| := by congr 1; ring
    _ ≤ |x-I.center| +|(I.center : ℝ)-(J.center : ℝ)| := abs_add_le _ _
    _ ≤ _ := by linarith

end RationalBall
end NeuralGeneralization.OnlineLowerTanh
