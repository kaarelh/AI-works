import NeuralGeneralization.OnlineLowerTanhCurvature

/-! Uniform summability and an explicit four-term tail estimate. -/
noncomputable section
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

def scalarTermY (i : Fin 6) (j : ℕ) (y : ℝ) : ℝ :=
  match i.val with
  | 0 => -4*(-1 : ℝ)^j*logisticValue j y
  | 1 => 4*(-1 : ℝ)^j*(1+2*(j : ℝ)*(j+1))*logisticValue j y
  | 2 => -4*(-1 : ℝ)^j*(1+4*(j : ℝ)*(j+1)+2*((j : ℝ)*(j+1))^2)*logisticValue j y
  | 3 => -4*(-1 : ℝ)^j*logisticSlopeY j y
  | 4 => -4*(-1 : ℝ)^j*logisticCurvatureY j y
  | _ => 4*(-1 : ℝ)^j*(1+2*(j : ℝ)*(j+1))*logisticSlopeY j y

theorem scalarTermY_bound (i : Fin 6) (j : ℕ) (y : ℝ) (hy : 0 ≤ y) (hy1 : y ≤ 1) :
    |scalarTermY i j y| ≤ 64*((j : ℝ)+1)^4*logisticPower j y := by
  have hp := logisticPower_nonneg j hy
  have hv := logisticValue_le_power j hy
  have hv0 := logisticValue_nonneg j hy
  have hvs : |logisticValue j y| ≤ logisticPower j y := by rwa [abs_of_nonneg hv0]
  have hsl := logisticSlopeY_abs_le j hy
  have hcu := logisticCurvatureY_abs_le j hy hy1
  have hj : (0 : ℝ) ≤ (j : ℝ) := Nat.cast_nonneg j
  have hj3 : 0 ≤ (j : ℝ)^3 := by positivity
  have hj4 : 0 ≤ (j : ℝ)^4 := by positivity
  have hc1 : 0 ≤ 1+2*(j : ℝ)*(j+1) := by positivity
  have hc2 : 0 ≤ 1+4*(j : ℝ)*(j+1)+2*((j : ℝ)*(j+1))^2 := by positivity
  have hb0 : 4 ≤ 64*((j : ℝ)+1)^4 := by nlinarith only [hj,hj3,hj4,sq_nonneg (j : ℝ)]
  have hb1 : 4*(1+2*(j : ℝ)*(j+1)) ≤ 64*((j : ℝ)+1)^4 := by nlinarith only [hj,hj3,hj4,sq_nonneg (j : ℝ)]
  have hb2 : 4*(1+4*(j : ℝ)*(j+1)+2*((j : ℝ)*(j+1))^2) ≤ 64*((j : ℝ)+1)^4 := by nlinarith only [hj,hj3,hj4,sq_nonneg (j : ℝ)]
  have hb3 : 4*(2*(2*(j : ℝ)+1)) ≤ 64*((j : ℝ)+1)^4 := by nlinarith only [hj,hj3,hj4,sq_nonneg (j : ℝ)]
  have hb4 : 4*(2*(2*(j : ℝ)+1))^2 ≤ 64*((j : ℝ)+1)^4 := by nlinarith only [hj,hj3,hj4,sq_nonneg (j : ℝ)]
  have hb5 : 4*(1+2*(j : ℝ)*(j+1))*(2*(2*(j : ℝ)+1)) ≤ 64*((j : ℝ)+1)^4 := by nlinarith only [hj,hj3,hj4,sq_nonneg (j : ℝ)]
  fin_cases i <;> simp only [scalarTermY, abs_mul, abs_pow, abs_neg, abs_one, one_pow,
    one_mul, abs_of_nonneg hc1, abs_of_nonneg hc2] <;> norm_num only [abs_of_pos (by norm_num : (0 : ℝ) < 4), abs_neg, mul_one]
  · exact (mul_le_mul_of_nonneg_left hvs (by norm_num : (0 : ℝ) ≤ 4)).trans
      (mul_le_mul_of_nonneg_right hb0 hp)
  · exact (mul_le_mul_of_nonneg_left hvs (by positivity)).trans (mul_le_mul_of_nonneg_right hb1 hp)
  · exact (mul_le_mul_of_nonneg_left hvs (by positivity)).trans (mul_le_mul_of_nonneg_right hb2 hp)
  · calc
      4*|logisticSlopeY j y| ≤ 4*(2*(2*j+1)*logisticPower j y) := mul_le_mul_of_nonneg_left hsl (by norm_num)
      _ ≤ _ := by nlinarith only [mul_le_mul_of_nonneg_right hb3 hp]
  · calc
      4*|logisticCurvatureY j y| ≤ 4*((2*(2*j+1))^2*logisticPower j y) := mul_le_mul_of_nonneg_left hcu (by norm_num)
      _ ≤ _ := by nlinarith only [mul_le_mul_of_nonneg_right hb4 hp]
  · calc
      4*(1+2*(j : ℝ)*(j+1))*|logisticSlopeY j y| ≤
        4*(1+2*(j : ℝ)*(j+1))*(2*(2*j+1)*logisticPower j y) := mul_le_mul_of_nonneg_left hsl (by positivity)
      _ ≤ _ := by nlinarith only [mul_le_mul_of_nonneg_right hb5 hp]

theorem fourth_power_five_bound (n : ℕ) : ((n : ℝ)+5)^4 ≤ 625*(3 : ℝ)^n := by
  induction n with
  | zero => norm_num
  | succ n ih =>
      have hr : ((n : ℝ)+6)^4 ≤ 3*((n : ℝ)+5)^4 := by
        have hn : (0 : ℝ) ≤ n := Nat.cast_nonneg n
        nlinarith [sq_nonneg (n : ℝ), show 0 ≤ (n : ℝ)^3 by positivity,
          show 0 ≤ (n : ℝ)^4 by positivity]
      push_cast
      rw [pow_succ (3 : ℝ)]
      nlinarith only [hr, ih]

theorem scalarTermY_tail_geometric (i : Fin 6) (j : ℕ) (y : ℝ)
    (hy : 0 ≤ y) (hy1 : y ≤ 1/10) :
    |scalarTermY i (j+4) y| ≤ (1/25000 : ℝ)*(3/100 : ℝ)^j := by
  have h := scalarTermY_bound i (j+4) y hy (by linarith)
  have hp : logisticPower (j+4) y ≤ (1/10 : ℝ)^(2*(j+4)+1) :=
    pow_le_pow_left₀ hy hy1 _
  have hj := fourth_power_five_bound j
  calc
    |scalarTermY i (j+4) y| ≤ 64*((j+4 : ℕ)+1 : ℝ)^4*(1/10 : ℝ)^(2*(j+4)+1) :=
      h.trans (mul_le_mul_of_nonneg_left hp (by positivity))
    _ ≤ 64*(625*(3 : ℝ)^j)*(1/10 : ℝ)^(2*(j+4)+1) :=
      mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left (by simpa only [Nat.cast_add,Nat.cast_ofNat,show (j : ℝ)+4+1=j+5 by ring] using hj) (by norm_num)) (by positivity)
    _ = (1/25000 : ℝ)*(3/100 : ℝ)^j := by
      rw [show 2*(j+4)+1=2*j+9 by omega, pow_add, pow_mul]
      norm_num
      rw [show (3/100 : ℝ)=3*(1/100) by norm_num, mul_pow]
      ring

theorem scalarTermY_tail_summable (i : Fin 6) (y : ℝ) (hy : 0 ≤ y) (hy1 : y ≤ 1/10) :
    Summable (fun j => scalarTermY i (j+4) y) := by
  apply Summable.of_norm_bounded ((summable_geometric_of_norm_lt_one
    (by norm_num : ‖(3/100 : ℝ)‖ < 1)).mul_left (1/25000 : ℝ))
  intro j
  exact scalarTermY_tail_geometric i j y hy hy1

theorem scalarTermY_summable (i : Fin 6) (y : ℝ) (hy : 0 ≤ y) (hy1 : y ≤ 1/10) :
    Summable (fun j => scalarTermY i j y) := by
  exact (summable_nat_add_iff 4).mp (scalarTermY_tail_summable i y hy hy1)

theorem scalarTermY_tail_abs_le (i : Fin 6) (y : ℝ) (hy : 0 ≤ y) (hy1 : y ≤ 1/10) :
    |∑' j : ℕ, scalarTermY i (j+4) y| ≤ (1/10000 : ℝ) := by
  have hg := (hasSum_geometric_of_norm_lt_one
    (by norm_num : ‖(3/100 : ℝ)‖ < 1)).mul_left (1/25000 : ℝ)
  have h : ‖∑' j : ℕ, scalarTermY i (j+4) y‖ ≤
      (1/25000 : ℝ)*(1-(3/100 : ℝ))⁻¹ :=
    tsum_of_norm_bounded (f := fun j => scalarTermY i (j+4) y) hg
      (fun j => scalarTermY_tail_geometric i j y hy hy1)
  rw [Real.norm_eq_abs] at h
  norm_num at h
  linarith

end NeuralGeneralization.OnlineLowerTanh
