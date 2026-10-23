import NeuralGeneralization.BatchTwoOnlineNeuralMain
import Mathlib.NumberTheory.Harmonic.Bounds

/-! # Polynomial overhead on the Boolean cube -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnline
open ConcreteModel

lemma harmonicSum_eq_harmonic (n : ℕ) : harmonicSum n = (harmonic n : ℝ) := by
  unfold harmonicSum
  rw [Fin.sum_univ_eq_sum_range (fun i => 1/((i : ℝ)+1)) n]
  simp only [harmonic, Rat.cast_sum, Rat.cast_inv, Rat.cast_natCast, Nat.cast_add,
    Nat.cast_one, one_div, Rat.cast_add, Rat.cast_one, Rat.cast_natCast]

lemma cube_harmonic_bound (d : ℕ) (hd : 1 ≤ d) :
    harmonicSum (Fintype.card (Cube d)-1) ≤ 1+(d : ℝ)*Real.log 2 := by
  have hm := cube_card_ge_two d hd
  have hn : (0 : ℝ) < (Fintype.card (Cube d)-1 : ℕ) := by exact_mod_cast (show 0 < Fintype.card (Cube d)-1 by omega)
  rw [harmonicSum_eq_harmonic]
  apply (harmonic_le_one_add_log _).trans
  have hlog := Real.log_le_log hn
    (show ((Fintype.card (Cube d)-1 : ℕ) : ℝ) ≤ Fintype.card (Cube d) by exact_mod_cast Nat.sub_le _ _)
  have he : Real.log (Fintype.card (Cube d) : ℝ)=(d : ℝ)*Real.log 2 := by
    rw [cube_card_eq, Nat.cast_pow, Nat.cast_ofNat, Real.log_pow]
  rw [he] at hlog
  linarith

lemma cube_harmonic_le_dimension (d : ℕ) (hd : 1 ≤ d) :
    harmonicSum (Fintype.card (Cube d)-1) ≤ 1+(d : ℝ) := by
  have hh := cube_harmonic_bound d hd
  have hl := Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 2)
  have hm := mul_le_mul_of_nonneg_left hl (Nat.cast_nonneg d (α := ℝ))
  linarith

lemma cube_log_budget (d : ℕ) (δ : ℝ) (hδ : 0 < δ) :
    Real.log (2*(Fintype.card (Cube d) : ℝ)/δ) ≤ 1+(d : ℝ)+Real.log (1/δ) := by
  have hm : (Fintype.card (Cube d) : ℝ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  rw [Real.log_div (mul_ne_zero (by norm_num) hm) hδ.ne', Real.log_mul (by norm_num) hm,
    cube_card_eq, Nat.cast_pow, Nat.cast_ofNat, Real.log_pow]
  rw [Real.log_div one_ne_zero hδ.ne', Real.log_one]
  have hl := Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 2)
  have hp := mul_le_mul_of_nonneg_left hl (Nat.cast_nonneg d (α := ℝ))
  linarith

lemma cube_expectationBudget_bound (d : ℕ) (hd : 1 ≤ d) (h : ℝ) (hh : 0 ≤ h) :
    expectationBudget (Fintype.card (Cube d)) h (1/Fintype.card (Cube d)) ≤
      2+2*(h+1)*(1+(d : ℝ)) := by
  have hm : (Fintype.card (Cube d) : ℝ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  unfold expectationBudget
  rw [mul_one_div_cancel hm]
  have he := mul_le_mul_of_nonneg_left (cube_harmonic_le_dimension d hd)
    (show 0 ≤ 2*(h+1) by linarith)
  linarith

lemma cube_highProbabilityBudget_bound (d : ℕ) (hd : 1 ≤ d) (h δ : ℝ)
    (hh : 0 ≤ h) (hδ : 0 < δ) (hδ1 : δ < 1) :
    highProbabilityBudget (Fintype.card (Cube d)) h (1/Fintype.card (Cube d)) δ ≤
      (Real.exp 1-1)*(2+2*(h+1+(d : ℝ)+Real.log (1/δ))*(1+d))+1+Real.log (1/δ) := by
  have hm : (Fintype.card (Cube d) : ℝ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  have hc : 0 ≤ Real.exp 1-1 := by linarith [Real.add_one_le_exp (1 : ℝ)]
  have ht : 0 ≤ Real.log (1/δ) := Real.log_nonneg ((one_le_div hδ).mpr hδ1.le)
  have hH := harmonicSum_nonneg (Fintype.card (Cube d)-1)
  have hlog := cube_log_budget d δ hδ
  have hprod : (h+Real.log (2*(Fintype.card (Cube d) : ℝ)/δ))*harmonicSum (Fintype.card (Cube d)-1) ≤
      (h+1+(d : ℝ)+Real.log (1/δ))*(1+d) := by
    exact mul_le_mul (by linarith) (cube_harmonic_le_dimension d hd) hH (by positivity)
  have hlogδ : Real.log (2/δ) ≤ 1+Real.log (1/δ) := by
    rw [Real.log_div (by norm_num) hδ.ne', Real.log_div one_ne_zero hδ.ne', Real.log_one]
    linarith [Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 2)]
  unfold highProbabilityBudget
  rw [mul_one_div_cancel hm]
  have hb := mul_le_mul_of_nonneg_left (show
      1+2*(h+Real.log (2*(Fintype.card (Cube d) : ℝ)/δ))*harmonicSum (Fintype.card (Cube d)-1)+1 ≤
        2+2*(h+1+(d : ℝ)+Real.log (1/δ))*(1+d) by nlinarith) hc
  linarith

/-- A genuine polynomial majorant for both displayed online budgets. The
confidence variable occurs only through `log (1/δ)`. -/
theorem online_budget_polynomial_majorant (P : ℕ → ℕ → ℕ) (hP : PolynomialGrowth2 P) :
    ∃ A : ℝ, 0 < A ∧ ∃ k : ℕ, ∀ d C : ℕ, 1 ≤ d → ∀ δ : ℝ, 0 < δ → δ < 1 →
      expectationBudget (Fintype.card (Cube d)) (P d C) (1/Fintype.card (Cube d)) ≤
        A*(1+(d : ℝ)+C+Real.log (1/δ))^k ∧
      highProbabilityBudget (Fintype.card (Cube d)) (P d C) (1/Fintype.card (Cube d)) δ ≤
        A*(1+(d : ℝ)+C+Real.log (1/δ))^k := by
  obtain ⟨A₀,hA₀,k,hpoly⟩ := hP.real_envelope
  let c := Real.exp 1-1
  let A := (c+1)*(2*A₀+4)+1
  have hc : 1 ≤ c := by dsimp [c]; linarith [Real.add_one_le_exp (1 : ℝ)]
  refine ⟨A, by dsimp [A]; nlinarith, k+2, ?_⟩
  intro d C hd δ hδ hδ1
  let t := Real.log (1/δ)
  let b := 1+(d : ℝ)+C+t
  have ht : 0 ≤ t := Real.log_nonneg ((one_le_div hδ).mpr hδ1.le)
  have hb : 1 ≤ b := by dsimp [b]; linarith [Nat.cast_nonneg d (α := ℝ), Nat.cast_nonneg C (α := ℝ)]
  have hbase : 1+(d : ℝ)+C ≤ b := by dsimp [b]; linarith
  have hPbound : (P d C : ℝ) ≤ A₀*b^k :=
    (hpoly d C).trans (mul_le_mul_of_nonneg_left
      (pow_le_pow_left₀ (by positivity) hbase k) hA₀.le)
  have hpowk : b^k ≤ b^(k+1) := pow_le_pow_right₀ hb (by omega)
  have hpow1 : b ≤ b^(k+1) := by
    simpa only [pow_one] using pow_le_pow_right₀ hb (show 1 ≤ k+1 by omega)
  have hpow2 : b ≤ b^(k+2) := by
    simpa only [pow_one] using pow_le_pow_right₀ hb (show 1 ≤ k+2 by omega)
  have hpow0 : 1 ≤ b^(k+2) := one_le_pow₀ hb
  have hsum : (P d C : ℝ)+1+d+t ≤ (A₀+1)*b^(k+1) := by
    have hp := mul_le_mul_of_nonneg_left hpowk hA₀.le
    have hsmall : 1+(d : ℝ)+t ≤ b := by dsimp [b]; linarith [Nat.cast_nonneg C (α := ℝ)]
    nlinarith
  have hprod : ((P d C : ℝ)+1+d+t)*(1+d) ≤ (A₀+1)*b^(k+2) := by
    have hh := mul_le_mul hsum (show (1 : ℝ)+d ≤ b by dsimp [b]; linarith [Nat.cast_nonneg C (α := ℝ)])
      (by positivity : (0 : ℝ) ≤ 1+d) (by positivity : 0 ≤ (A₀+1)*b^(k+1))
    calc
      _ ≤ ((A₀+1)*b^(k+1))*b := hh
      _ = _ := by rw [pow_succ]; ring
  have hinner : 2+2*((P d C : ℝ)+1+d+t)*(1+d) ≤ (2*A₀+4)*b^(k+2) := by nlinarith
  have hE := cube_expectationBudget_bound d hd (P d C) (Nat.cast_nonneg _)
  have hU := cube_highProbabilityBudget_bound d hd (P d C) δ (Nat.cast_nonneg _) hδ hδ1
  have heprod : ((P d C : ℝ)+1)*(1+d) ≤ ((P d C : ℝ)+1+d+t)*(1+d) :=
    mul_le_mul_of_nonneg_right (by linarith [Nat.cast_nonneg d (α := ℝ)]) (by positivity)
  have hUE : c*(2+2*((P d C : ℝ)+1+d+t)*(1+d))+1+t ≤
      (c*(2*A₀+4)+1)*b^(k+2) := by
    have hh := mul_le_mul_of_nonneg_left hinner (by linarith : 0 ≤ c)
    have hsmall : 1+t ≤ b := by dsimp [b]; linarith [Nat.cast_nonneg d (α := ℝ), Nat.cast_nonneg C (α := ℝ)]
    nlinarith
  have hcoef : c*(2*A₀+4)+1 ≤ A := by dsimp [A]; nlinarith
  have hfinal := mul_le_mul_of_nonneg_right hcoef (by positivity : 0 ≤ b^(k+2))
  constructor
  · change _ ≤ A*b^(k+2)
    have hcinner : (2*A₀+4)*b^(k+2) ≤ A*b^(k+2) := by
      apply mul_le_mul_of_nonneg_right _ (by positivity)
      dsimp [A]
      nlinarith
    nlinarith
  · change _ ≤ A*b^(k+2)
    exact hU.trans (hUE.trans hfinal)

end NeuralGeneralization.BatchTwoOnline
