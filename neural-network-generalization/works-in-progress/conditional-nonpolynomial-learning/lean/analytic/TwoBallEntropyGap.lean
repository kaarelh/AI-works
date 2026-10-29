import TwoEigenvalueEntropy
import Mathlib.Analysis.Calculus.Deriv.MeanValue

noncomputable section
namespace ConditionalNonpolynomial.Analytic

theorem twoBallEntropyGap_hasDerivAt {a : ℝ} (ha : 0≤a) :
    HasDerivAt twoBallEntropyGap
      ((Real.log (a+1)-Real.log ((a+2)/2))/2) a := by
  have ha1 : a+1≠0 := by positivity
  have ha2 : (a+2)/2≠0 := by positivity
  have h1 := (hasDerivAt_id a).add_const 1
  have h2 := (hasDerivAt_id a).add_const 2
  have h := ((h1.mul (h1.log ha1)).sub (h2.mul ((h2.div_const 2).log ha2))).div_const 2
  convert h using 1 <;> first | rfl | (try simp only [twoBallEntropyGap,Pi.mul_apply,Pi.sub_apply,Pi.pow_apply,id_eq])
    <;> (try field_simp) <;> ring

theorem twoBallEntropyGap_lower {a : ℝ} (ha : 0≤a) :
    a^2/(8*(a+1))≤twoBallEntropyGap a := by
  let F := fun x : ℝ => twoBallEntropyGap x-x^2/(8*(x+1))
  let F' := fun x : ℝ => (Real.log (x+1)-Real.log ((x+2)/2))/2-
    x*(x+2)/(8*(x+1)^2)
  have hd (x : ℝ) (hx : 0≤x) : HasDerivAt F (F' x) x := by
    have hx1 : 8*(x+1)≠0 := by positivity
    have hrat := ((hasDerivAt_id x).pow 2).div
      (((hasDerivAt_id x).add_const 1).const_mul 8) hx1
    have hh := (twoBallEntropyGap_hasDerivAt hx).sub hrat
    convert hh using 1 <;> first | rfl | (try simp only [F,F',Pi.mul_apply,Pi.sub_apply,Pi.pow_apply,id_eq])
      <;> (try field_simp) <;> ring
  have hn (x : ℝ) (hx : 0≤x) : 0≤F' x := by
    have hx1 : 0<x+1 := by positivity
    have hx2 : 0<(x+2)/2 := by positivity
    have hl := Real.log_le_sub_one_of_pos (div_pos hx2 hx1)
    rw [Real.log_div hx2.ne' hx1.ne'] at hl
    have he : (x+2)/2/(x+1)-1= -x/(2*(x+1)) := by field_simp <;> ring
    rw [he] at hl
    have hmul := mul_le_mul_of_nonneg_left hl (by positivity : 0≤4*(x+1)^2)
    dsimp [F']
    apply (mul_nonneg_iff_of_pos_left (by positivity : 0<8*(x+1)^2)).mp
    field_simp at hmul ⊢
    nlinarith [sq_nonneg x]
  have hm : MonotoneOn F (Set.Ici 0) :=
    monotoneOn_of_hasDerivWithinAt_nonneg (convex_Ici 0)
      (fun x hx => (hd x hx).continuousAt.continuousWithinAt)
      (fun x hx => (hd x (le_of_lt (by simpa using hx))).hasDerivWithinAt)
      (fun x hx => hn x (le_of_lt (by simpa using hx)))
  have hh := hm (by simp) ha ha
  dsimp [F] at hh
  norm_num [twoBallEntropyGap] at hh
  exact hh

theorem twoBallEntropyGap_uniform {a : ℝ} (ha : 1/4≤a) :
    (1/40:ℝ)≤twoBallEntropyGap a/a := by
  have hap : 0<a := by linarith
  have hl := twoBallEntropyGap_lower hap.le
  apply (le_div_iff₀ hap).mpr
  have he : a/40≤a^2/(8*(a+1)) := by
    apply (le_div_iff₀ (by positivity : 0<8*(a+1))).mpr
    nlinarith
  linarith

#print axioms twoBallEntropyGap_uniform
end ConditionalNonpolynomial.Analytic
