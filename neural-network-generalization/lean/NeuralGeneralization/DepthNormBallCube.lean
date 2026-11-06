import NeuralGeneralization.BatchTwoNeuralConversePointFeatures
import Mathlib.Algebra.BigOperators.Ring.Finset

/-! Hamming-summed tanh interpolation for the growing-depth norm-ball example. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.DepthNormBall
open Classical ConcreteModel BatchTwoNeuralConverse

lemma hammingShell_comm {q : ℕ} (x p : Cube q) : hammingShell x p = hammingShell p x := by
  simp only [hammingShell,ne_comm]

lemma hamming_weight_product {q : ℕ} (x p : Cube q) (u : ℝ) :
    u^(hammingShell x p) = ∏ i : Fin q, if p i ≠ x i then u else 1 := by
  rw [← Finset.prod_filter]
  simp [hammingShell]

lemma sum_hamming_weight {q : ℕ} (x : Cube q) (u : ℝ) :
    (∑ p : Cube q, u^(hammingShell x p)) = (1+u)^q := by
  simp_rw [hamming_weight_product]
  rw [← Fintype.prod_sum (fun (i : Fin q) (b : Bool) => if b ≠ x i then u else (1:ℝ))]
  have he (i : Fin q) : (∑ b : Bool, if b ≠ x i then u else 1) = 1+u := by
    cases x i <;> simp [Fintype.sum_bool,add_comm]
  simp_rw [he]
  simp

lemma sum_hamming_weight_erase {q : ℕ} (x : Cube q) (u : ℝ) :
    (∑ p ∈ Finset.univ.erase x, u^(hammingShell x p)) = (1+u)^q-1 := by
  have hs := Finset.sum_erase_add (s := Finset.univ) (f := fun p : Cube q => u^(hammingShell x p))
    (Finset.mem_univ x)
  rw [sum_hamming_weight] at hs
  have hz : hammingShell x x = 0 := (hammingShell_eq_zero x x).mpr rfl
  rw [hz,pow_zero] at hs
  linarith

/-- A small-binomial-increment estimate with the explicit constant two. -/
lemma one_add_pow_sub_one_le {q : ℕ} {u : ℝ} (hu : 0 ≤ u) (hqu : (q:ℝ)*u ≤ 1) :
    (1+u)^q-1 ≤ 2*(q:ℝ)*u := by
  have hp := pow_le_pow_left₀ (by positivity : 0 ≤ 1+u) (by simpa only [add_comm] using Real.add_one_le_exp u) q
  rw [← Real.exp_nat_mul] at hp
  have hnonneg : 0 ≤ (q:ℝ)*u := by positivity
  have he := Real.abs_exp_sub_one_le (by rwa [abs_of_nonneg hnonneg] : |(q:ℝ)*u| ≤ 1)
  rw [abs_of_nonneg hnonneg] at he
  have he' := (le_abs_self (Real.exp ((q:ℝ)*u)-1)).trans he
  linarith

def slope (q : ℕ) : ℝ := (1/2:ℝ)*Real.log (16*(q:ℝ))

def softCube {q : ℕ} (x p : Cube q) : ℝ :=
  (1+Real.tanh (slope q*(1-2*(hammingShell x p:ℝ))))/2

lemma slope_pos {q : ℕ} (hq : 0 < q) : 0 < slope q := by
  have hq1 : (1:ℝ) ≤ q := by exact_mod_cast hq
  exact mul_pos (by norm_num) (Real.log_pos (by linarith))

lemma slope_exp_neg {q : ℕ} (hq : 0 < q) :
    Real.exp (-2*slope q) = 1/(16*(q:ℝ)) := by
  unfold slope
  rw [show -2*((1/2:ℝ)*Real.log (16*(q:ℝ))) = -Real.log (16*(q:ℝ)) by ring,
    Real.exp_neg,Real.exp_log (by positivity)]
  simp only [one_div]

lemma slope_exp_pos {q : ℕ} (hq : 0 < q) :
    Real.exp (2*slope q) = 16*(q:ℝ) := by
  unfold slope
  rw [show 2*((1/2:ℝ)*Real.log (16*(q:ℝ))) = Real.log (16*(q:ℝ)) by ring,
    Real.exp_log (by positivity)]

lemma slope_exp_four {q : ℕ} (hq : 0 < q) :
    Real.exp (-4*slope q) = (1/(16*(q:ℝ)))^2 := by
  rw [show -4*slope q=(-2*slope q)+(-2*slope q) by ring,Real.exp_add,slope_exp_neg hq]
  ring

lemma softCube_diagonal {q : ℕ} (hq : 0 < q) (x : Cube q) :
    |softCube x x-1| ≤ 1/(16*(q:ℝ)) := by
  have hz : hammingShell x x = 0 := (hammingShell_eq_zero x x).mpr rfl
  simpa only [softCube,hz,Nat.cast_zero,mul_zero,sub_zero,mul_one,slope_exp_neg hq]
    using logistic_positive_error (A := slope q) (q := slope q) le_rfl

lemma softCube_bound {q : ℕ} (hq : 0 < q) (x p : Cube q) :
    |softCube x p| ≤ 16*(q:ℝ)*((1/(16*(q:ℝ)))^2)^(hammingShell x p) := by
  have he := logistic_negative_error (A := -(slope q*(1-2*(hammingShell x p:ℝ))))
    (q := slope q*(1-2*(hammingShell x p:ℝ))) (by linarith)
  have hid : -2*(-(slope q*(1-2*(hammingShell x p:ℝ)))) =
      2*slope q+(hammingShell x p:ℝ)*(-4*slope q) := by ring
  rw [hid,Real.exp_add,Real.exp_nat_mul,slope_exp_pos hq,slope_exp_four hq] at he
  exact he

/-- The paper's fixed slope yields a row error at most 3/16, strictly below 1/4. -/
theorem softCube_row_error {q : ℕ} (hq : 0 < q) (x : Cube q) :
    (∑ p : Cube q, |softCube x p-(if x=p then 1 else 0)|) ≤ 3/16 := by
  let e : ℝ := 1/(16*(q:ℝ))
  have hqR : (0:ℝ) < q := by exact_mod_cast hq
  have hq1 : (1:ℝ) ≤ q := by exact_mod_cast hq
  have he : 0 < e := by dsimp [e]; positivity
  have he1 : e ≤ 1/16 := by
    dsimp [e]
    exact one_div_le_one_div_of_le (by norm_num) (by nlinarith)
  have hqe : (q:ℝ)*e = 1/16 := by dsimp [e]; field_simp
  have hqu : (q:ℝ)*e^2 ≤ 1 := by nlinarith
  have hp := one_add_pow_sub_one_le (q := q) (sq_nonneg e) hqu
  have hs : (∑ p ∈ Finset.univ.erase x, |softCube x p-(if x=p then 1 else 0)|) ≤
      16*(q:ℝ)*((1+e^2)^q-1) := by
    rw [← sum_hamming_weight_erase x (e^2),Finset.mul_sum]
    apply Finset.sum_le_sum
    intro p hp
    have hpx : p ≠ x := (Finset.mem_erase.mp hp).1
    simp only [if_neg hpx.symm,sub_zero]
    exact softCube_bound hq x p
  have hsum := Finset.sum_erase_add (s := Finset.univ)
    (f := fun p : Cube q => |softCube x p-(if x=p then 1 else 0)|) (Finset.mem_univ x)
  have hd := softCube_diagonal hq x
  have hm := mul_le_mul_of_nonneg_left hp (by positivity : 0 ≤ 16*(q:ℝ))
  have hid : 16*(q:ℝ)*(2*(q:ℝ)*e^2)=1/8 := by
    dsimp [e]
    field_simp
    <;> ring
  rw [hid] at hm
  simp only [ite_true] at hsum
  change |softCube x x-1| ≤ e at hd
  linarith

lemma softCube_symmetric {q : ℕ} (x p : Cube q) : softCube x p = softCube p x := by
  simp only [softCube,hammingShell_comm x p]

end NeuralGeneralization.DepthNormBall
