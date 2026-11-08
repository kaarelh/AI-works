import NeuralGeneralization.ParityNetworkShallow
import NeuralGeneralization.OnlineLowerTeacher

/-! # Quantitative tanh interpolation on the Boolean count grid

The slope is an explicit parameter. Exponential saturation allows slope
m to approximate every parity in a polynomial-dimensional family while
keeping all incoming coefficients bounded by O(m d).
-/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel OnlineLower

 theorem tanh_positive_saturation (x : ℝ) :
    |Real.tanh x - 1| ≤ 2 * Real.exp (-2*x) := by
  have he : 0 < Real.exp (2*x) := Real.exp_pos _
  rw [TanhSaturation.tanh_exp_formula]
  rw [show 1 - 2/(Real.exp (2*x)+1) - 1 = -(2/(Real.exp (2*x)+1)) by ring,
    abs_neg, abs_of_nonneg (by positivity)]
  calc
    2/(Real.exp (2*x)+1) ≤ 2/Real.exp (2*x) :=
      div_le_div_of_nonneg_left (by norm_num) he (by linarith)
    _ = _ := by rw [show -2*x = -(2*x) by ring, Real.exp_neg]; ring

theorem soft_grid_step_error_exp {A : ℝ} (hA : 0 ≤ A) (t j : ℕ) :
    |Real.tanh (A*((t:ℝ)-j-1/2)) - ParityNetwork.gridStep t j| ≤ 2*Real.exp (-A) := by
  by_cases h : j < t
  · have hcast : (j:ℝ)+1 ≤ t := by exact_mod_cast h
    have hex : -2*(A*((t:ℝ)-j-1/2)) ≤ -A := by nlinarith
    have hs := (tanh_positive_saturation (A*((t:ℝ)-j-1/2))).trans
      (mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr hex) (by norm_num : (0:ℝ)≤2))
    simpa [ParityNetwork.gridStep,h] using hs
  · have hcast : (t:ℝ) ≤ j := by exact_mod_cast (Nat.le_of_not_gt h)
    have hh := tanh_positive_saturation (-(A*((t:ℝ)-j-1/2)))
    have heq : -Real.tanh (A*((t:ℝ)-j-1/2))-1 =
        -(Real.tanh (A*((t:ℝ)-j-1/2))+1) := by ring
    rw [Real.tanh_neg, heq, abs_neg] at hh
    have hex : -2*(-(A*((t:ℝ)-j-1/2))) ≤ -A := by nlinarith
    have hs := hh.trans
      (mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr hex) (by norm_num : (0:ℝ)≤2))
    simpa [ParityNetwork.gridStep,h] using hs

def gridInterpolant (A : ℝ) (y : ℕ → ℝ) (d : ℕ) (t : ℝ) : ℝ :=
  (y 0+y d)/2 + ∑ j ∈ Finset.range d,
    ((y (j+1)-y j)/2)*Real.tanh (A*(t-j-1/2))

theorem gridInterpolant_error (A : ℝ) (hA : 0 ≤ A) (y : ℕ → ℝ)
    (hy : ∀ j, |y j| ≤ 1) {d t : ℕ} (ht : t ≤ d) :
    |gridInterpolant A y d t - y t| ≤ 2*(d:ℝ)*Real.exp (-A) := by
  have hcoeff (j : ℕ) : |(y (j+1)-y j)/2| ≤ 1 := by
    rw [abs_div, abs_of_pos (show (0:ℝ)<2 by norm_num)]
    exact (div_le_one (by norm_num)).mpr
      ((abs_sub _ _).trans (by linarith [hy (j+1),hy j]))
  have heq : gridInterpolant A y d t-y t =
      ∑ j ∈ Finset.range d, ((y (j+1)-y j)/2)*
        (Real.tanh (A*((t:ℝ)-j-1/2))-ParityNetwork.gridStep t j) := by
    rw [← ParityNetwork.grid_interpolation y ht]
    simp only [gridInterpolant, mul_sub, Finset.sum_sub_distrib]
    ring
  rw [heq]
  calc
    _ ≤ ∑ j ∈ Finset.range d, |((y (j+1)-y j)/2)*
        (Real.tanh (A*((t:ℝ)-j-1/2))-ParityNetwork.gridStep t j)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _j ∈ Finset.range d, 2*Real.exp (-A) := by
      apply Finset.sum_le_sum
      intro j hj
      rw [abs_mul]
      exact (mul_le_mul (hcoeff j) (soft_grid_step_error_exp hA t j)
        (abs_nonneg _) (by norm_num)).trans_eq (one_mul _)
    _ = _ := by simp; ring

abbrev TeacherNeuron (d m : ℕ) := Fin (m+1) × Fin (d+1)
def teacherWidth (d m : ℕ) : ℕ := (m+1)*(d+1)
def teacherIndex (d m : ℕ) : Fin (teacherWidth d m) ≃ TeacherNeuron d m :=
  (Fintype.equivOfCardEq (α := TeacherNeuron d m) (β := Fin (teacherWidth d m))
    (by simp only [TeacherNeuron,Fintype.card_prod,Fintype.card_fin]; rfl)).symm

def gridWeights {d m : ℕ} (S : Fin (m+1) → Finset (Fin d))
    (a : Fin (m+1) → ℝ) (A : ℝ) : Weights d (teacherWidth d m) 0
  | .inl (i,j) =>
      let z := teacherIndex d m i
      Fin.cases (Fin.cases 1 (fun _ => 0) j)
        (fun l => Fin.cases (A*((S z.1).card/2-l-1/2))
          (fun h => if h∈S z.1 then -A/2 else 0) j) z.2
  | .inr (.inl (s,_,_)) => Fin.elim0 s
  | .inr (.inr i) =>
      let z := teacherIndex d m i
      2*a z.1 * Fin.cases ((1+(-1:ℝ)^d)/2/Real.tanh 1)
        (fun j => (((-1:ℝ)^(j.val+1)-(-1:ℝ)^j.val)/2)) z.2

theorem count_sum_affine {d : ℕ} (S : Finset (Fin d)) (x : Cube d) :
    (S.card:ℝ)/2 + ∑ i : Fin d, (if i∈S then -(1/2:ℝ) else 0)*labelReal (x i) =
      (OnlineLower.falseCount S x : ℝ) := by
  rw [OnlineLower.falseCount_affine]
  simp only [ite_mul, zero_mul, Finset.sum_ite_mem, Finset.univ_inter]
  rw [← Finset.sum_div, Finset.sum_sub_distrib]
  simp only [Finset.sum_const, nsmul_eq_mul, mul_one]
  rw [← Finset.mul_sum]
  ring

theorem gridWeights_first_zero {d m : ℕ} (S : Fin (m+1) → Finset (Fin d))
    (a : Fin (m+1) → ℝ) (A : ℝ) (x : Cube d) (i : Fin (m+1)) :
    firstHidden Real.tanh (gridWeights S a A) x ((teacherIndex d m).symm (i,0)) = Real.tanh 1 := by
  simp [firstHidden, gridWeights, Fin.sum_univ_succ, inputVector]

theorem gridWeights_first_succ {d m : ℕ} (S : Fin (m+1) → Finset (Fin d))
    (a : Fin (m+1) → ℝ) (A : ℝ) (x : Cube d) (i : Fin (m+1)) (j : Fin d) :
    firstHidden Real.tanh (gridWeights S a A) x ((teacherIndex d m).symm (i,j.succ)) =
      Real.tanh (A*((OnlineLower.falseCount (S i) x:ℝ)-j-1/2)) := by
  unfold firstHidden
  congr 1
  simp only [gridWeights, Equiv.apply_symm_apply, Fin.cases_succ, Fin.sum_univ_succ,
    Fin.cases_zero, inputVector, mul_one]
  have he (h : Fin d) : (if h∈S i then -A/2 else 0)*labelReal (x h) =
      A*((if h∈S i then -(1/2:ℝ) else 0)*labelReal (x h)) := by split_ifs <;> ring
  simp_rw [he]
  rw [← Finset.mul_sum]
  have hh := count_sum_affine (S i) x
  rw [← hh]
  ring

theorem gridWeights_output {d m : ℕ} (S : Fin (m+1) → Finset (Fin d))
    (a : Fin (m+1) → ℝ) (A : ℝ) (x : Cube d) :
    networkOutput Real.tanh (gridWeights S a A) x =
      2 * ∑ i, a i * gridInterpolant A (fun j => (-1:ℝ)^j) d (OnlineLower.falseCount (S i) x) := by
  have ht : Real.tanh 1 ≠ 0 := ne_of_gt (lt_trans (by norm_num) ParityNetwork.tanh_one_gt_half)
  simp only [networkOutput,finalHidden,List.finRange_zero,List.foldl_nil]
  rw [← (teacherIndex d m).symm.sum_comp]
  simp only [gridWeights,Equiv.apply_symm_apply]
  rw [Fintype.sum_prod_type]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  rw [Fin.sum_univ_succ]
  simp only [Fin.cases_zero,Fin.cases_succ,gridWeights_first_zero,gridWeights_first_succ]
  rw [show 2*a i*((1+(-1:ℝ)^d)/2/Real.tanh 1)*Real.tanh 1 =
      2*a i*((1+(-1:ℝ)^d)/2) by field_simp]
  simp_rw [mul_assoc]
  rw [← Finset.mul_sum, ← Finset.mul_sum]
  rw [Fin.sum_univ_eq_sum_range (fun j : ℕ =>
    (((-1:ℝ)^(j+1)-(-1:ℝ)^j)/2)*Real.tanh (A*((OnlineLower.falseCount (S i) x:ℝ)-j-1/2)))]
  simp only [gridInterpolant,pow_zero]
  ring

end NeuralGeneralization.OnlineLowerTanh
