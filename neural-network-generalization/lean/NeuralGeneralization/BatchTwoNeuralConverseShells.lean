import NeuralGeneralization.BatchTwoNeuralConverseStaircase
import NeuralGeneralization.RobustCircuitSaturation
import Mathlib.Analysis.Complex.Exponential

/-! Exact, bounded-variation tanh interpolation on Hamming shells. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
open ConcreteModel

def singletonSlope (d : ℕ) : ℝ := (1/2 : ℝ)*Real.log (4*(d+1 : ℝ))

theorem singletonSlope_pos (d : ℕ) : 0 < singletonSlope d := by
  unfold singletonSlope
  apply mul_pos (by norm_num)
  apply Real.log_pos
  have hd : (0 : ℝ) ≤ d := Nat.cast_nonneg d
  linarith

theorem singletonSlope_exp (d : ℕ) :
    Real.exp (-2*singletonSlope d) = 1/(4*(d+1 : ℝ)) := by
  unfold singletonSlope
  rw [show -2*((1/2 : ℝ)*Real.log (4*(d+1 : ℝ))) = -Real.log (4*(d+1 : ℝ)) by ring,
    Real.exp_neg, Real.exp_log (by positivity)]
  simp

theorem logistic_positive_error {A q : ℝ} (hq : A ≤ q) :
    |(1+Real.tanh q)/2-1| ≤ Real.exp (-2*A) := by
  have ht : Real.tanh q ≤ 1 := (le_abs_self _).trans (Real.abs_tanh_lt_one q).le
  have he : (1+Real.tanh q)/2-1 = -(1-Real.tanh q)/2 := by ring
  rw [he, abs_div, abs_neg, abs_of_nonneg (by linarith : 0 ≤ 1-Real.tanh q)]
  rw [one_sub_tanh_eq]
  norm_num only [abs_of_nonneg (by norm_num : (0 : ℝ) ≤ 2)]
  have hden : 0 < Real.exp (2*q)+1 := by positivity
  have heq : (2/(Real.exp (2*q)+1))/2 = 1/(Real.exp (2*q)+1) := by ring
  rw [heq, show -2*A = -(2*A) by ring, Real.exp_neg, ← one_div]
  apply one_div_le_one_div_of_le (Real.exp_pos _)
  have hm := Real.exp_le_exp.mpr (show 2*A ≤ 2*q by linarith)
  linarith

theorem logistic_negative_error {A q : ℝ} (hq : q ≤ -A) :
    |(1+Real.tanh q)/2| ≤ Real.exp (-2*A) := by
  have h := logistic_positive_error (show A ≤ -q by linarith)
  rw [Real.tanh_neg] at h
  have he : (1+-Real.tanh q)/2-1 = -((1+Real.tanh q)/2) := by ring
  rwa [he, abs_neg] at h

def shellFeature {d : ℕ} (s j : Fin (d+1)) : ℝ :=
  if j=0 then Real.tanh 1 else Real.tanh (singletonSlope d*(2*j.val-2*s.val-1))

def softShellColumn {d : ℕ} (s j : Fin (d+1)) : ℝ :=
  if j=0 then 1 else (1+shellFeature s j)/2

theorem softShell_error {d : ℕ} (s j : Fin (d+1)) :
    |softShellColumn s j-staircase s j| ≤ 1/(4*(d+1 : ℝ)) := by
  by_cases hj : j=0
  · simp [softShellColumn, staircase, hj]
    positivity
  · simp only [softShellColumn, shellFeature, staircase, hj, ↓reduceIte]
    by_cases hsj : s.val<j.val
    · simp only [hsj, ↓reduceIte]
      have hdiff : (1 : ℝ) ≤ 2*(j.val : ℝ)-2*(s.val : ℝ)-1 := by
        have hc : (s.val : ℝ)+1 ≤ j.val := by exact_mod_cast hsj
        linarith
      have hA := singletonSlope_pos d
      simpa only [singletonSlope_exp] using logistic_positive_error
        (show singletonSlope d ≤ singletonSlope d*(2*(j.val : ℝ)-2*(s.val : ℝ)-1) by nlinarith)
    · simp only [hsj, ↓reduceIte, sub_zero]
      have hc : (j.val : ℝ) ≤ s.val := by exact_mod_cast Nat.le_of_not_gt hsj
      have hA := singletonSlope_pos d
      simpa only [singletonSlope_exp] using logistic_negative_error
        (show singletonSlope d*(2*(j.val : ℝ)-2*(s.val : ℝ)-1) ≤ -singletonSlope d by nlinarith)

theorem tanh_one_ge_half : (1 : ℝ)/2 ≤ Real.tanh 1 := by
  have he := Real.quadratic_le_exp_of_nonneg (by norm_num : (0 : ℝ) ≤ 2)
  norm_num at he
  have hden : 0 < Real.exp (2 : ℝ)+1 := by positivity
  have hdiv : 2/(Real.exp (2 : ℝ)+1) ≤ 1/2 := (div_le_iff₀ hden).mpr (by linarith)
  have h := one_sub_tanh_eq (1 : ℝ)
  norm_num at h
  linarith

def tanhCoefficients {d : ℕ} (c : Fin (d+1) → ℝ) : Fin (d+1) → ℝ :=
  Fin.cases ((c 0+(∑ i : Fin d, c i.succ)/2)/Real.tanh 1) (fun i => c i.succ/2)

theorem tanhCoefficients_l1 {d : ℕ} (c : Fin (d+1) → ℝ) :
    vectorL1 (tanhCoefficients c) ≤ 2*vectorL1 c := by
  have ht : 0 < Real.tanh 1 := by linarith [tanh_one_ge_half]
  have hsum := Finset.abs_sum_le_sum_abs (s := Finset.univ) (f := fun i : Fin d => c i.succ)
  have hnum := abs_add_le (c 0) ((∑ i : Fin d, c i.succ)/2)
  rw [abs_div, abs_of_pos (by norm_num : (0 : ℝ) < 2)] at hnum
  have hnum' : |c 0+(∑ i : Fin d, c i.succ)/2| ≤
      (Real.tanh 1)*(2*|c 0|+∑ i : Fin d, |c i.succ|) := by
    have hb : 0 ≤ 2*|c 0|+∑ i : Fin d, |c i.succ| := by positivity
    have hmul := mul_le_mul_of_nonneg_right tanh_one_ge_half hb
    linarith
  have hzero : |(c 0+(∑ i : Fin d, c i.succ)/2)/Real.tanh 1| ≤
      2*|c 0|+∑ i : Fin d, |c i.succ| := by
    rw [abs_div, abs_of_pos ht]
    exact (div_le_iff₀ ht).mpr (by simpa only [mul_comm] using hnum')
  have hs : 0 ≤ ∑ i : Fin d, |c i.succ| := by positivity
  unfold vectorL1
  rw [Fin.sum_univ_succ, Fin.sum_univ_succ]
  simp only [tanhCoefficients, Fin.cases_zero, Fin.cases_succ, abs_div,
    abs_of_nonneg (by norm_num : (0 : ℝ) ≤ 2),
    ← Finset.sum_div]
  simp only [abs_div] at hzero
  linarith

theorem tanhCoefficients_apply {d : ℕ} (c : Fin (d+1) → ℝ) (s : Fin (d+1)) :
    (∑ j, tanhCoefficients c j*shellFeature s j) = applyMatrix softShellColumn c s := by
  have ht : Real.tanh 1 ≠ 0 := by linarith [tanh_one_ge_half]
  unfold applyMatrix
  rw [Fin.sum_univ_succ, Fin.sum_univ_succ]
  simp only [tanhCoefficients, Fin.cases_zero, Fin.cases_succ, shellFeature, softShellColumn,
    ↓reduceIte, Fin.succ_ne_zero, mul_one, one_mul]
  rw [div_mul_cancel₀ _ ht]
  have he (a b : ℝ) : (1+a)/2*b = b/2+(b/2)*a := by ring
  simp_rw [he]
  rw [Finset.sum_add_distrib, ← Finset.sum_div]
  ring

theorem exists_exact_shell_indicator (d : ℕ) (hd : 0 < d) :
    ∃ b : Fin (d+1) → ℝ, vectorL1 b ≤ 4 ∧
      ∀ s : Fin (d+1), (∑ j, b j*shellFeature s j) = if s=0 then 1 else 0 := by
  obtain ⟨c,hc,hinterp⟩ := exists_staircase_coefficients hd softShellColumn softShell_error
  refine ⟨tanhCoefficients c, (tanhCoefficients_l1 c).trans (by linarith), ?_⟩
  intro s
  rw [tanhCoefficients_apply]
  exact hinterp s

end
end NeuralGeneralization.BatchTwoNeuralConverse
