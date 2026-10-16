import NeuralGeneralization.TanhSaturation
import NeuralGeneralization.ParityModelBridge
import NeuralGeneralization.Cloning
import Mathlib.Tactic.Ring

/-! A quantitative, finite-grid tanh interpolation construction. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ParityNetwork
open ConcreteModel

def gridStep (t j : ℕ) : ℝ := if j < t then 1 else -1

theorem grid_interpolation (y : ℕ → ℝ) {d t : ℕ} (ht : t ≤ d) :
    (y 0 + y d) / 2 +
      ∑ j ∈ Finset.range d, ((y (j+1) - y j) / 2) * gridStep t j = y t := by
  induction d generalizing t with
  | zero => simp_all [gridStep]
  | succ d ih =>
    by_cases htd : t ≤ d
    · rw [Finset.sum_range_succ]
      have hg : gridStep t d = -1 := if_neg (by omega)
      rw [hg]
      have hh := ih htd
      linarith
    · have ht' : t = d+1 := by omega
      subst t
      have hs : (∑ j ∈ Finset.range (d+1),
          ((y (j+1)-y j)/2) * gridStep (d+1) j) = (y (d+1)-y 0)/2 := by
        calc
          _ = ∑ j ∈ Finset.range (d+1), (y (j+1)-y j)/2 := by
            apply Finset.sum_congr rfl
            intro j hj
            simp [gridStep, Finset.mem_range.mp hj]
          _ = _ := by rw [← Finset.sum_div, Finset.sum_range_sub]
      rw [hs]
      ring

theorem one_sub_tanh_le {A z : ℝ} (hA : 0 ≤ A) (hz : A/2 ≤ z) :
    |Real.tanh z - 1| ≤ 2 / (A+2) := by
  have hden : 0 < Real.exp (2*z)+1 := by positivity
  have hAe : A+2 ≤ Real.exp (2*z)+1 := by
    have he := Real.add_one_le_exp (2*z)
    linarith
  rw [TanhSaturation.tanh_exp_formula]
  have heq : 1 - 2/(Real.exp (2*z)+1)-1 = -(2/(Real.exp (2*z)+1)) := by ring
  rw [heq, abs_neg, abs_of_pos (div_pos (by norm_num) hden)]
  exact div_le_div_of_nonneg_left (by norm_num) (by linarith) hAe

theorem soft_grid_step_error {A : ℝ} (hA : 0 ≤ A) (t j : ℕ) :
    |Real.tanh (A*((t:ℝ)-j-1/2)) - gridStep t j| ≤ 2/(A+2) := by
  by_cases h : j < t
  · have hcast : (j:ℝ)+1 ≤ t := by exact_mod_cast h
    simpa [gridStep, h] using
      one_sub_tanh_le hA (show A/2 ≤ A*((t:ℝ)-j-1/2) by nlinarith)
  · have hcast : (t:ℝ) ≤ j := by exact_mod_cast (Nat.le_of_not_gt h)
    have hh := one_sub_tanh_le hA
      (show A/2 ≤ -(A*((t:ℝ)-j-1/2)) by nlinarith)
    rw [Real.tanh_neg] at hh
    have heq : -Real.tanh (A*((t:ℝ)-j-1/2))-1 =
        -(Real.tanh (A*((t:ℝ)-j-1/2))+1) := by ring
    rw [heq, abs_neg] at hh
    simpa [gridStep, h] using hh

/-- The deliberately generous linear slope avoids any logarithmic estimates. -/
def gridSlope (d : ℕ) : ℝ := 16*((d:ℝ)+1)

def gridInterpolant (y : ℕ → ℝ) (d : ℕ) (t : ℝ) : ℝ :=
  (y 0+y d)/2 + ∑ j ∈ Finset.range d,
    ((y (j+1)-y j)/2)*Real.tanh (gridSlope d*(t-j-1/2))

theorem gridInterpolant_error (y : ℕ → ℝ) (hy : ∀ j, |y j| ≤ 1)
    {d t : ℕ} (ht : t ≤ d) :
    |gridInterpolant y d t-y t| < 1/8 := by
  have hcoeff (j : ℕ) : |(y (j+1)-y j)/2| ≤ 1 := by
    rw [abs_div, abs_of_pos (show (0:ℝ)<2 by norm_num)]
    have hsub := (abs_sub (y (j+1)) (y j)).trans (add_le_add (hy _) (hy _))
    exact (div_le_one (by norm_num)).2 (by linarith)
  have hsl : 0 ≤ gridSlope d := by unfold gridSlope; positivity
  have heq : gridInterpolant y d t-y t =
      ∑ j ∈ Finset.range d, ((y (j+1)-y j)/2)*
        (Real.tanh (gridSlope d*((t:ℝ)-j-1/2))-gridStep t j) := by
    rw [← grid_interpolation y ht]
    simp only [gridInterpolant, mul_sub, Finset.sum_sub_distrib]
    ring
  rw [heq]
  calc
    _ ≤ ∑ j ∈ Finset.range d, |((y (j+1)-y j)/2)*
        (Real.tanh (gridSlope d*((t:ℝ)-j-1/2))-gridStep t j)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _j ∈ Finset.range d, 2/(gridSlope d+2) := by
      apply Finset.sum_le_sum
      intro j hj
      rw [abs_mul]
      exact (mul_le_mul (hcoeff j) (soft_grid_step_error hsl t j)
        (abs_nonneg _) (by norm_num)).trans_eq (one_mul _)
    _ = (d:ℝ)*2/(16*((d:ℝ)+1)+2) := by simp [gridSlope]; ring
    _ < 1/8 := by
      apply (div_lt_iff₀ (by positivity : (0:ℝ)<16*((d:ℝ)+1)+2)).2
      nlinarith [show (0:ℝ) ≤ d from Nat.cast_nonneg d]

end NeuralGeneralization.ParityNetwork
