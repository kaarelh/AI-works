import NeuralGeneralization.OnlineLowerTanhSeriesCertificate
import Mathlib.Analysis.Calculus.SmoothSeries

/-! Derivatives of the literal limiting scalar series near the stationary gain. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Set
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

def scalarMajorant (j : ℕ) : ℝ := 64*((j : ℝ)+1)^4*(1/10 : ℝ)^(2*j+1)

theorem scalarMajorant_nonneg (j : ℕ) : 0 ≤ scalarMajorant j := by unfold scalarMajorant; positivity

theorem scalarMajorant_tail (j : ℕ) : scalarMajorant (j+4) ≤ (1/25000 : ℝ)*(3/100 : ℝ)^j := by
  have hj := fourth_power_five_bound j
  unfold scalarMajorant
  calc
    64*((j+4 : ℕ)+1 : ℝ)^4*(1/10 : ℝ)^(2*(j+4)+1) ≤
      64*(625*(3 : ℝ)^j)*(1/10 : ℝ)^(2*(j+4)+1) :=
      mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left
        (by simpa only [Nat.cast_add,Nat.cast_ofNat,show (j : ℝ)+4+1=j+5 by ring] using hj)
        (by norm_num)) (by positivity)
    _ = _ := by
      rw [show 2*(j+4)+1=2*j+9 by omega,pow_add,pow_mul]
      norm_num
      rw [show (3/100 : ℝ)=3*(1/100) by norm_num,mul_pow]
      ring

theorem scalarMajorant_summable : Summable scalarMajorant := by
  apply (summable_nat_add_iff 4).mp
  apply Summable.of_norm_bounded ((summable_geometric_of_norm_lt_one
    (by norm_num : ‖(3/100 : ℝ)‖ < 1)).mul_left (1/25000 : ℝ))
  intro j
  rw [Real.norm_eq_abs,abs_of_nonneg (scalarMajorant_nonneg _)]
  exact scalarMajorant_tail j

theorem exp_neg_two_le_tenth (a : ℝ) (ha : 6/5 ≤ a) : Real.exp (-2*a) ≤ 1/10 := by
  have ht := Real.sum_le_exp_of_nonneg (by norm_num : (0 : ℝ) ≤ 12/5) 6
  norm_num [Finset.sum_range_succ] at ht
  have hm : Real.exp (12/5) ≤ Real.exp (2*a) := Real.exp_le_exp.mpr (by linarith)
  rw [show -2*a=-(2*a) by ring,Real.exp_neg]
  have hi := inv_anti₀ (by norm_num : (0 : ℝ) < 10) (show 10 ≤ Real.exp (2*a) by nlinarith)
  simpa only [one_div] using hi

theorem scalarTermY_uniform_bound (i : Fin 6) (j : ℕ) (a : ℝ) (ha : 6/5 ≤ a) :
    ‖scalarTermY i j (Real.exp (-2*a))‖ ≤ scalarMajorant j := by
  have hy := (Real.exp_pos (-2*a)).le
  have hy1 := exp_neg_two_le_tenth a ha
  have h := scalarTermY_bound i j (Real.exp (-2*a)) hy (by linarith)
  exact h.trans (mul_le_mul_of_nonneg_left (pow_le_pow_left₀ hy hy1 _) (by positivity))

theorem scalarTerm_derivative_0 (j : ℕ) (a : ℝ) :
    HasDerivAt (fun x => scalarTermY 0 j (Real.exp (-2*x)))
      (scalarTermY 3 j (Real.exp (-2*a))) a := by
  convert (hasDerivAt_logisticTail j a).const_mul (-4*(-1 : ℝ)^j) using 1 <;> try rfl
  all_goals norm_num [scalarTermY,logisticTail,logisticFirst]

theorem scalarTerm_derivative_3 (j : ℕ) (a : ℝ) :
    HasDerivAt (fun x => scalarTermY 3 j (Real.exp (-2*x)))
      (scalarTermY 4 j (Real.exp (-2*a))) a := by
  convert (hasDerivAt_logisticFirst j a).const_mul (-4*(-1 : ℝ)^j) using 1 <;> try rfl
  all_goals norm_num [scalarTermY,logisticFirst,logisticSecond]

theorem scalarTerm_derivative_1 (j : ℕ) (a : ℝ) :
    HasDerivAt (fun x => scalarTermY 1 j (Real.exp (-2*x)))
      (scalarTermY 5 j (Real.exp (-2*a))) a := by
  convert (hasDerivAt_logisticTail j a).const_mul (4*(-1 : ℝ)^j*(1+2*(j : ℝ)*(j+1))) using 1 <;> try rfl
  all_goals norm_num [scalarTermY,logisticTail,logisticFirst]

private theorem scalar_series_derivative (i j : Fin 6)
    (hd : ∀ n a, HasDerivAt (fun x => scalarTermY i n (Real.exp (-2*x)))
      (scalarTermY j n (Real.exp (-2*a))) a) (a : ℝ) (ha : 6/5 < a) :
    HasDerivAt (fun x => ∑' n : ℕ, scalarTermY i n (Real.exp (-2*x)))
      (∑' n : ℕ, scalarTermY j n (Real.exp (-2*a))) a := by
  apply hasDerivAt_tsum_of_isPreconnected scalarMajorant_summable isOpen_Ioi isPreconnected_Ioi
    (fun n x hx => hd n x) (fun n x hx => scalarTermY_uniform_bound j n x hx.le)
    (show (5/4 : ℝ) ∈ Ioi (6/5) by norm_num)
    (scalarTermY_summable i (Real.exp (-2*(5/4 : ℝ))) (Real.exp_pos _).le
      (exp_neg_two_le_tenth (5/4) (by norm_num))) ha

theorem hasDerivAt_scalarF0 (a : ℝ) (ha : 6/5 < a) :
    HasDerivAt scalarF0 (scalarF0First a) a := by
  have h := (scalar_series_derivative 0 3 scalarTerm_derivative_0 a ha).const_add 1
  have he0 (x : ℝ) := scalarComponentY_eq_tsum 0 (Real.exp (-2*x))
  have he3 := scalarComponentY_eq_tsum 3 (Real.exp (-2*a))
  convert h using 1 <;> try rfl
  · funext x
    simpa [scalarF0,scalarComponentY,componentConstant] using he0 x
  · simpa [scalarF0First,scalarComponentY,componentConstant] using he3

theorem hasDerivAt_scalarF0First (a : ℝ) (ha : 6/5 < a) :
    HasDerivAt scalarF0First (scalarF0Second a) a := by
  have h := scalar_series_derivative 3 4 scalarTerm_derivative_3 a ha
  have he3 (x : ℝ) := scalarComponentY_eq_tsum 3 (Real.exp (-2*x))
  have he4 := scalarComponentY_eq_tsum 4 (Real.exp (-2*a))
  convert h using 1 <;> try rfl
  · funext x
    simpa [scalarF0First,scalarComponentY,componentConstant] using he3 x
  · simpa [scalarF0Second,scalarComponentY,componentConstant] using he4

theorem hasDerivAt_scalarF1 (a : ℝ) (ha : 6/5 < a) :
    HasDerivAt scalarF1 (scalarF1First a) a := by
  have h := scalar_series_derivative 1 5 scalarTerm_derivative_1 a ha
  have he1 (x : ℝ) := scalarComponentY_eq_tsum 1 (Real.exp (-2*x))
  have he5 := scalarComponentY_eq_tsum 5 (Real.exp (-2*a))
  convert h using 1 <;> try rfl
  · funext x
    simpa [scalarF1,scalarComponentY,componentConstant] using he1 x
  · simpa [scalarF1First,scalarComponentY,componentConstant] using he5

end NeuralGeneralization.OnlineLowerTanh
