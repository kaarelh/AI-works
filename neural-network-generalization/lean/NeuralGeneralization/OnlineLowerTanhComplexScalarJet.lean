import NeuralGeneralization.OnlineLowerTanhHolomorphicRootData
import Mathlib.Analysis.Calculus.IteratedDeriv.Defs

/-! Actual complex derivatives of the limiting scalar, identified with its
checked real derivatives. These statements have no derivative-certificate premise. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology
open Complex Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

lemma complexF1_differentiableOn : DifferentiableOn ℂ complexF1 {a:ℂ|1<a.re} := by
  apply DifferentiableOn.const_mul
  apply weightedLogistic_differentiableOn
    (fun j=>(-1:ℂ)^j*(prefactoredFirst j:ℂ)) 3 2
  intro j
  simpa only [norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul,
    Complex.norm_real,Real.norm_eq_abs] using prefactoredFirst_abs_bound j

lemma complexF2_differentiableOn : DifferentiableOn ℂ complexF2 {a:ℂ|1<a.re} := by
  apply DifferentiableOn.const_mul
  apply weightedLogistic_differentiableOn
    (fun j=>(-1:ℂ)^j*(prefactoredSecond j:ℂ)) 7 4
  intro j
  simpa only [norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul,
    Complex.norm_real,Real.norm_eq_abs,abs_of_nonneg (prefactoredSecond_nonneg j)]
    using prefactoredSecond_bound j

lemma complexF1Derivative_differentiableOn :
    DifferentiableOn ℂ complexF1Derivative {a:ℂ|1<a.re} := by
  apply DifferentiableOn.const_mul
  apply weightedLogisticFirst_differentiableOn
    (fun j=>(-1:ℂ)^j*(prefactoredFirst j:ℂ)) 3 2
  intro j
  simpa only [norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul,
    Complex.norm_real,Real.norm_eq_abs] using prefactoredFirst_abs_bound j

lemma complexStationary1_differentiableOn :
    DifferentiableOn ℂ complexStationary1 {a:ℂ|1<a.re} :=
  (differentiableOn_id.mul complexF1Derivative_differentiableOn).sub
    complexF1_differentiableOn

private lemma complex_derivative_from_real
    (f : ℂ → ℂ) (g : ℝ → ℝ) (g' a : ℝ)
    (hf : DifferentiableAt ℂ f (a:ℂ))
    (he : ∀x:ℝ, f (x:ℂ)=(g x:ℂ))
    (hg : HasDerivAt g g' a) : HasDerivAt f (g':ℂ) (a:ℂ) := by
  have hc := hf.hasDerivAt
  have hr := hc.comp_ofReal
  have hreal := hg.ofReal_comp
  have heq : (fun y:ℝ=>f (y:ℂ))=(fun y:ℝ=>(g y:ℂ)) := funext he
  rw [heq] at hr
  have hd := hr.unique hreal
  rw [hd] at hc
  exact hc

lemma complexF0_hasDerivAt_real (a:ℝ) (ha:6/5<a) :
    HasDerivAt complexF0 (scalarF0First a:ℂ) (a:ℂ) := by
  apply complex_derivative_from_real complexF0 scalarF0 _ a
  · exact complexF0_differentiableOn.differentiableAt
      ((isOpen_lt continuous_const Complex.continuous_re).mem_nhds
        (show 1<(a:ℂ).re by simp; linarith))
  · exact complexF0_ofReal
  · exact hasDerivAt_scalarF0 a ha

lemma complexF0Derivative_hasDerivAt_real (a:ℝ) (ha:6/5<a) :
    HasDerivAt complexF0Derivative (scalarF0Second a:ℂ) (a:ℂ) := by
  apply complex_derivative_from_real complexF0Derivative scalarF0First _ a
  · exact complexF0Derivative_differentiableOn.differentiableAt
      ((isOpen_lt continuous_const Complex.continuous_re).mem_nhds
        (show 1<(a:ℂ).re by simp; linarith))
  · exact complexF0Derivative_ofReal
  · exact hasDerivAt_scalarF0First a ha

lemma complexF1_hasDerivAt_real (a:ℝ) (ha:6/5<a) :
    HasDerivAt complexF1 (scalarF1First a:ℂ) (a:ℂ) := by
  apply complex_derivative_from_real complexF1 scalarF1 _ a
  · exact complexF1_differentiableOn.differentiableAt
      ((isOpen_lt continuous_const Complex.continuous_re).mem_nhds
        (show 1<(a:ℂ).re by simp; linarith))
  · exact complexF1_ofReal
  · exact hasDerivAt_scalarF1 a ha

lemma complexF0_hasDerivAt {a:ℂ} (ha:1<a.re) :
    HasDerivAt complexF0 (complexF0Derivative a) a := by
  let S : ℂ→ℂ := fun b=>∑'j:ℕ,(-1:ℂ)^j*complexLogistic j b
  have hd (j:ℕ) : DifferentiableOn ℂ
      (fun b=>(-1:ℂ)^j*complexLogistic j b) {b:ℂ|1<b.re} := by
    intro b hb
    exact ((complexLogistic_hasDerivAt j hb.le).const_mul _).differentiableAt.differentiableWithinAt
  have hb (j:ℕ) (b:ℂ) (hb:1<b.re) :
      ‖(-1:ℂ)^j*complexLogistic j b‖≤logisticMajorant j := by
    simpa only [norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul]
      using complexLogistic_bound j hb.le
  have hs:=hasSum_deriv_of_summable_norm logisticMajorant_summable hd
    (isOpen_lt continuous_const Complex.continuous_re) hb ha
  have hterm (j:ℕ) : deriv (fun b=>(-1:ℂ)^j*complexLogistic j b) a=
      (-1:ℂ)^j*complexLogisticFirst j a :=
    ((complexLogistic_hasDerivAt j ha.le).const_mul _).deriv
  simp_rw [hterm] at hs
  have hSd : DifferentiableAt ℂ S a :=
    (weightedLogistic_differentiableOn (fun j=>(-1:ℂ)^j) 1 0 (fun j=>by simp)).differentiableAt
      ((isOpen_lt continuous_const Complex.continuous_re).mem_nhds ha)
  have hS := hSd.hasDerivAt
  rw [←hs.tsum_eq] at hS
  unfold complexF0Derivative
  convert! (hasDerivAt_const a 1).sub (hS.const_mul 4) using 1 <;>
    first | rfl | ring | (dsimp only [complexF0,S,Pi.sub_apply]; ring)

lemma complexF0_iteratedDeriv_two_real (a:ℝ) (ha:6/5<a) :
    iteratedDeriv 2 complexF0 (a:ℂ)=(scalarF0Second a:ℂ) := by
  have he : deriv complexF0 =ᶠ[𝓝 (a:ℂ)] complexF0Derivative := by
    filter_upwards [(isOpen_lt continuous_const Complex.continuous_re).mem_nhds
      (show 1<(a:ℂ).re by simp; linarith)] with z hz
    exact (complexF0_hasDerivAt hz).deriv
  rw [show (2:ℕ)=1+1 by rfl,iteratedDeriv_succ,iteratedDeriv_one]
  rw [he.deriv_eq]
  exact (complexF0Derivative_hasDerivAt_real a ha).deriv

lemma complexF0_limitingGain_deriv :
    deriv complexF0 (limitingGain:ℂ)=(scalarF0First limitingGain:ℂ) :=
  (complexF0_hasDerivAt_real limitingGain (by linarith [limitingGain_mem.1])).deriv

lemma complexF0_limitingGain_iteratedDeriv_two :
    iteratedDeriv 2 complexF0 (limitingGain:ℂ)=(scalarF0Second limitingGain:ℂ) :=
  complexF0_iteratedDeriv_two_real limitingGain (by linarith [limitingGain_mem.1])

lemma complexF1_limitingGain_deriv :
    deriv complexF1 (limitingGain:ℂ)=(scalarF1First limitingGain:ℂ) :=
  (complexF1_hasDerivAt_real limitingGain (by linarith [limitingGain_mem.1])).deriv

end NeuralGeneralization.OnlineLowerTanh
