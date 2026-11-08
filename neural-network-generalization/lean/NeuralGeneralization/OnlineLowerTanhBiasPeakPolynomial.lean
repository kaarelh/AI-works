import NeuralGeneralization.OnlineLowerTanhPositiveSeries
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Chebyshev.Basic

/-! Exact polynomial identities for the periodic bias peaks. Their first
moments are the coefficients of the strict `1/n` peak penalties. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Polynomial
namespace NeuralGeneralization.OnlineLowerTanh

open Polynomial.Chebyshev

def oddBiasPeakPolynomial (l : ℕ) : Polynomial ℝ :=
  (T ℝ (l:ℤ)).comp (2*X-1)

def evenBiasPeakPolynomial (l : ℕ) : Polynomial ℝ :=
  ((U ℝ (l:ℤ))-(U ℝ ((l:ℤ)-1))).comp (2*X-1)

@[simp] theorem oddBiasPeakPolynomial_eval_one (l : ℕ) :
    (oddBiasPeakPolynomial l).eval 1=1 := by
  norm_num [oddBiasPeakPolynomial,eval_comp,T_eval_one]

@[simp] theorem evenBiasPeakPolynomial_eval_one (l : ℕ) :
    (evenBiasPeakPolynomial l).eval 1=1 := by
  norm_num [evenBiasPeakPolynomial,eval_comp,U_eval_one]

@[simp] theorem oddBiasPeakPolynomial_deriv_one (l : ℕ) :
    (oddBiasPeakPolynomial l).derivative.eval 1=2*(l:ℝ)^2 := by
  norm_num [oddBiasPeakPolynomial,derivative_comp,eval_comp,derivative_T_eval_one]

@[simp] theorem evenBiasPeakPolynomial_deriv_one (l : ℕ) :
    (evenBiasPeakPolynomial l).derivative.eval 1=2*(l:ℝ)*((l:ℝ)+1) := by
  have h0 := derivative_U_eval_one (R:=ℝ) (l:ℤ)
  have h1 := derivative_U_eval_one (R:=ℝ) ((l:ℤ)-1)
  simp only [Int.cast_natCast,Int.cast_sub,Int.cast_one] at h0 h1
  simp only [evenBiasPeakPolynomial,derivative_comp,eval_mul,eval_comp,eval_sub,
    eval_ofNat,eval_X,eval_one,derivative_sub,derivative_mul,derivative_ofNat,
    zero_mul,derivative_X,mul_one,zero_add,derivative_one,sub_zero]
  norm_num only [mul_one,show (2:ℝ)-1=1 by norm_num]
  nlinarith

lemma oddBiasPeakPolynomial_trig (l : ℕ) (θ : ℝ) :
    (oddBiasPeakPolynomial l).eval ((Real.sin θ)^2) =
      (-1:ℝ)^l*Real.cos (2*(l:ℝ)*θ) := by
  have hc : 2*(Real.sin θ)^2-1 = -Real.cos (2*θ) := by
    rw [Real.cos_two_mul]
    nlinarith [Real.sin_sq_add_cos_sq θ]
  simp only [oddBiasPeakPolynomial,eval_comp,eval_sub,eval_mul,eval_ofNat,eval_X,eval_one]
  rw [hc,T_eval_neg,T_real_cos]
  simp only [Int.cast_negOnePow_natCast,Int.cast_natCast]
  congr 2 <;> ring

lemma evenBiasPeakPolynomial_zero : evenBiasPeakPolynomial 0=1 := by
  simp [evenBiasPeakPolynomial]

lemma evenBiasPeakPolynomial_one : evenBiasPeakPolynomial 1=4*X-3 := by
  simp [evenBiasPeakPolynomial,U_one,U_zero,sub_comp,mul_comp]
  ring

lemma evenBiasPeakPolynomial_succ_succ (l : ℕ) :
    evenBiasPeakPolynomial (l+2) =
      (4*X-2)*evenBiasPeakPolynomial (l+1)-evenBiasPeakPolynomial l := by
  have h0 := U_add_two ℝ (l:ℤ)
  have h1 := U_add_two ℝ ((l:ℤ)-1)
  have he : ((l:ℤ)-1+2)=(l:ℤ)+1 := by ring
  have he' : ((l:ℤ)-1+1)=(l:ℤ) := by ring
  rw [he,he'] at h1
  unfold evenBiasPeakPolynomial
  push_cast
  rw [show (l:ℤ)+2-1=(l:ℤ)+1 by ring,show (l:ℤ)+1-1=(l:ℤ) by ring]
  rw [h0]
  have hpoly : 2*X*U ℝ ((l:ℤ)+1)-U ℝ (l:ℤ)-U ℝ ((l:ℤ)+1)=
      2*X*(U ℝ ((l:ℤ)+1)-U ℝ (l:ℤ))-(U ℝ (l:ℤ)-U ℝ ((l:ℤ)-1)) := by
    linear_combination -h1
  rw [hpoly]
  simp only [sub_comp,mul_comp,ofNat_comp,X_comp]
  ring

lemma evenBiasPeakPolynomial_trig (l : ℕ) (θ : ℝ) :
    (evenBiasPeakPolynomial l).eval ((Real.sin θ)^2)*Real.sin θ =
      (-1:ℝ)^l*Real.sin ((2*(l:ℝ)+1)*θ) := by
  induction l using Nat.twoStepInduction with
  | zero => simp [evenBiasPeakPolynomial_zero]
  | one =>
    rw [evenBiasPeakPolynomial_one]
    simp only [eval_sub,eval_mul,eval_ofNat,eval_X,pow_one,Nat.cast_one]
    have hh := Real.sin_three_mul θ
    norm_num at hh ⊢
    nlinarith
  | more l ih0 ih1 =>
    rw [evenBiasPeakPolynomial_succ_succ]
    simp only [eval_sub,eval_mul,eval_ofNat,eval_X,sub_mul,mul_assoc]
    rw [ih1,ih0]
    have hc : 4*(Real.sin θ)^2-2 = -2*Real.cos (2*θ) := by
      rw [Real.cos_two_mul]
      nlinarith [Real.sin_sq_add_cos_sq θ]
    have hs := Real.sin_add_sin ((2*(l:ℝ)+5)*θ) ((2*(l:ℝ)+1)*θ)
    have hmid : ((2*(l:ℝ)+5)*θ+(2*(l:ℝ)+1)*θ)/2=(2*(l:ℝ)+3)*θ := by ring
    have hdiff : ((2*(l:ℝ)+5)*θ-(2*(l:ℝ)+1)*θ)/2=2*θ := by ring
    rw [hmid,hdiff] at hs
    rw [pow_add,pow_succ]
    push_cast
    norm_num only [neg_one_sq,mul_one]
    rw [show 2*((l:ℝ)+1)+1=2*(l:ℝ)+3 by ring,
      show 2*((l:ℝ)+2)+1=2*(l:ℝ)+5 by ring]
    linear_combination -((-1:ℝ)^l)*hs - ((-1:ℝ)^l*Real.sin ((2*(l:ℝ)+3)*θ))*hc

end NeuralGeneralization.OnlineLowerTanh
