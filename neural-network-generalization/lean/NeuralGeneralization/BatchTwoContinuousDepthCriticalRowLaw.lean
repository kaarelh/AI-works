import NeuralGeneralization.BatchTwoContinuousDepthCriticalStein
import NeuralGeneralization.GaussianFieldCovariance

/-! Scalar laws of actual Gaussian rows, including singular variance zero. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open FiniteDifferential GaussianFieldTilt GaussianAngularFields GaussianAngularPrice
variable {I:Type*} [Fintype I]

theorem gaussian_row_integral (c:I→ℝ) (g:ℝ→ℝ) (hg:Measurable g) :
    (∫z:I→ℝ,g (∑i,c i*z i) ∂(Measure.pi fun _ : I=>gaussianReal 0 1))=
      ∫z:ℝ,g (Real.sqrt (∑i,c i^2)*z) ∂gaussianReal 0 1 := by
  let A:Unit→I→ℝ:=fun _=>c
  let B:Unit→Unit→ℝ:=fun _ _=>Real.sqrt (∑i,c i^2)
  have hgram : ∀x y,gram A x y=gram B x y := by
    intro x y
    simp only [gram,A,B,Finset.sum_const,Fintype.card_unit,Finset.card_univ,nsmul_eq_mul,Nat.cast_one,one_mul,←sq]
    exact (Real.sq_sqrt (Finset.sum_nonneg fun i _=>sq_nonneg (c i))).symm
  have he := congrArg (fun μ:Measure (Unit→ℝ)=>∫z,g (z ()) ∂μ)
    (GaussianFieldCovariance.fieldLaw_eq_of_gram_eq A B hgram)
  rw [integral_fieldLaw A (fun z:Unit→ℝ=>g (z ())) (hg.comp (measurable_pi_apply ())),
    integral_fieldLaw B (fun z:Unit→ℝ=>g (z ())) (hg.comp (measurable_pi_apply ()))] at he
  simp only [fieldLinear_apply,A,B,standardLaw] at he
  simp only [Fintype.sum_unique] at he
  rw [integral_comp_eval (μ:=fun _ : Unit=>gaussianReal 0 1) (i:=())
    (f:=fun z:ℝ=>g (Real.sqrt (∑i,c i^2)*z)) (hg.comp (by fun_prop)).aestronglyMeasurable] at he
  exact he

theorem gaussian_row_secondMoment (c:I→ℝ) :
    (∫z:I→ℝ,(Real.tanh (∑i,c i*z i))^2 ∂(Measure.pi fun _ : I=>gaussianReal 0 1))=
      coolingSecondMoment (∑i,c i^2) := gaussian_row_integral c (fun z=>Real.tanh z^2) (by fun_prop)

theorem gaussian_row_derivative (c:I→ℝ) :
    (∫z:I→ℝ,TanhDifferential.tanhFirst (∑i,c i*z i) ∂(Measure.pi fun _ : I=>gaussianReal 0 1))=
      coolingDerivative (∑i,c i^2) := gaussian_row_integral c TanhDifferential.tanhFirst (by fun_prop)

theorem gaussian_projected_tanh_zero [DecidableEq I] (c t:I→ℝ) :
    (∫z:I→ℝ,(∑i,t i*z i)*Real.tanh (∑j,c j*z j) ∂(Measure.pi fun _ : I=>gaussianReal 0 1))=
      (∑i,t i*c i)*coolingDerivative (∑i,c i^2) := by
  have hs:=gaussian_projected_tanh c t 0
  simpa only [zero_add,gaussian_row_derivative] using hs

end NeuralGeneralization.BatchTwoContinuousDepthCritical
