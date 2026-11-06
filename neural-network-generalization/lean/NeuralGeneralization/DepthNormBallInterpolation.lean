import NeuralGeneralization.DepthNormBallCube
import Mathlib.Analysis.SpecialFunctions.Artanh

/-! Exact Boolean interpolation with uniformly bounded inverse coefficients. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.DepthNormBall
open Classical ConcreteModel BatchTwoNeuralConverse

/-- The actual inverse coefficients have the manuscript's uniform 4/3 bound. -/
theorem exists_cube_coefficients {q : ℕ} (hq : 0 < q) (f : BooleanFunction q) :
    ∃ v : Cube q → ℝ, (∀ p, |v p| ≤ 4/3) ∧
      ∀ x, (∑ p, v p*softCube x p) = labelReal (f x) := by
  let A : Cube q → Cube q → ℝ := fun x p => (if x=p then 1 else 0)-softCube x p
  have hr (x : Cube q) : (∑ p, |A x p|) ≤ 1/4 := by
    have hh := softCube_row_error hq x
    simp only [A,abs_sub_comm]
    linarith
  have hc (p : Cube q) : (∑ x, |A x p|) ≤ 1/2 := by
    have he : (∑ x, |A x p|) = ∑ x, |A p x| := by
      apply Finset.sum_congr rfl
      intro x _
      simp only [A,softCube_symmetric x p,eq_comm]
    rw [he]
    linarith [hr p]
  obtain ⟨v,hv,_⟩ := exists_neumann_solution A (fun x => labelReal (f x)) hc
  have he (i : Cube q) : |applyMatrix A v i| ≤ (1/4:ℝ)*‖v‖ := by
    calc
      _ ≤ ∑ j, |A i j*v j| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ j, |A i j| *‖v‖ := by
        apply Finset.sum_le_sum
        intro j _
        rw [abs_mul]
        exact mul_le_mul_of_nonneg_left (by simpa only [Real.norm_eq_abs] using norm_le_pi_norm v j) (abs_nonneg _)
      _ = (∑ j, |A i j|)*‖v‖ := (Finset.sum_mul _ _ _).symm
      _ ≤ _ := mul_le_mul_of_nonneg_right (hr i) (norm_nonneg _)
  have hvn : ‖v‖ ≤ 1+(1/4:ℝ)*‖v‖ := by
    apply (pi_norm_le_iff_of_nonneg (by positivity)).mpr
    intro i
    rw [Real.norm_eq_abs,hv i]
    have hf : |labelReal (f i)|=1 := by cases f i <;> norm_num [labelReal]
    exact (abs_add_le _ _).trans (by rw [hf]; linarith [he i])
  refine ⟨v,fun p => ?_,fun x => ?_⟩
  · have hh : |v p| ≤ ‖v‖ := by simpa only [Real.norm_eq_abs] using norm_le_pi_norm v p
    linarith
  · have hh := hv x
    have hA : applyMatrix A v x = v x-∑ p, softCube x p*v p := by
      simp [A,applyMatrix,sub_mul,Finset.sum_sub_distrib]
    rw [hA] at hh
    simp_rw [mul_comm (v _)]
    linarith

lemma artanh_le_three_mul {t : ℝ} (ht : 0 ≤ t) (ht1 : t ≤ 3/4) :
    Real.artanh t ≤ 3*t := by
  have hplus : 0 < 1+t := by positivity
  have hminus : 0 < 1-t := by linarith
  have hp := Real.log_le_sub_one_of_pos hplus
  have hm := Real.log_le_sub_one_of_pos (inv_pos.mpr hminus)
  rw [Real.log_inv] at hm
  have hi : (1-t)⁻¹-1 ≤ 4*t := by
    have he : (1-t)⁻¹-1=t/(1-t) := by field_simp; ring
    rw [he]
    apply (div_le_iff₀ hminus).mpr
    nlinarith
  rw [Real.artanh_eq_half_log (by constructor <;> linarith),Real.log_div hplus.ne' hminus.ne']
  linarith

lemma tanh_artanh_label {t : ℝ} (ht : 0 ≤ t) (ht1 : t < 1) (b : Bool) :
    Real.tanh (Real.artanh t*labelReal b) = t*labelReal b := by
  have h := Real.tanh_artanh (x := t) (by constructor <;> linarith)
  cases b <;> simp [labelReal,h]

/-- The coefficients for the one active neuron in layer two. -/
def bumpCoefficient {q : ℕ} (v : Cube q → ℝ) (t : ℝ) (p : Cube q) : ℝ :=
  Real.artanh t*v p/2

def constantCoefficient {q : ℕ} (v : Cube q → ℝ) (t : ℝ) : ℝ :=
  (∑ p, bumpCoefficient v t p)/((Fintype.card (Cube q):ℝ)*Real.tanh 1)

lemma second_preactivation {q : ℕ} (v : Cube q → ℝ) (t : ℝ)
    (f : BooleanFunction q) (hv : ∀ x, (∑ p, v p*softCube x p) = labelReal (f x)) (x : Cube q) :
    (∑ p, bumpCoefficient v t p*Real.tanh (slope q*(1-2*(hammingShell x p:ℝ))))+
      (Fintype.card (Cube q):ℝ)*constantCoefficient v t*Real.tanh 1 = Real.artanh t*labelReal (f x) := by
  have hM : (Fintype.card (Cube q):ℝ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  have hb : Real.tanh 1 ≠ 0 := ne_of_gt (lt_of_lt_of_le (by norm_num) tanh_one_ge_half)
  have hc : (Fintype.card (Cube q):ℝ)*constantCoefficient v t*Real.tanh 1 = ∑ p,bumpCoefficient v t p := by
    unfold constantCoefficient
    field_simp
  rw [hc,← Finset.sum_add_distrib,← hv x,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro p _
  unfold bumpCoefficient softCube
  ring

end NeuralGeneralization.DepthNormBall
