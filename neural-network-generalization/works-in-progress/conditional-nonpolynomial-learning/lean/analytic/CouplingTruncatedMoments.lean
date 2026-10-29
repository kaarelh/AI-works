import AnchorReplacement
import ScalarMomentEntropy
import SharpGaussianFeatureGain
import GaussianEntropyTail

/-! A variance-scaled coupling estimate from a common-part mismatch bound
and scalar tail moments. It does not invoke an optimal-transport theorem. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.ConcreteModel

lemma scalar_square_cutoff {R y : ℝ} (hR : 0≤R) :
    y^2≤R^2+(if R < |y| then y^2 else 0) := by
  split_ifs with h
  · nlinarith [sq_nonneg R]
  · have hh : |y|≤R := le_of_not_gt h
    have hs := (sq_le_sq₀ (abs_nonneg y) hR).mpr hh
    simpa only [sq_abs,add_zero] using hs

lemma coupling_square_truncation {R y z : ℝ} (hR : 0≤R) :
    (y-z)^2≤4*R^2*(if y=z then 0 else 1)+
      4*(if R < |y| then y^2 else 0)+4*(if R < |z| then z^2 else 0) := by
  have hy := scalar_square_cutoff (y:=y) hR
  have hz := scalar_square_cutoff (y:=z) hR
  have hty : 0≤(if R < |y| then y^2 else 0) := by split_ifs <;> positivity
  have htz : 0≤(if R < |z| then z^2 else 0) := by split_ifs <;> positivity
  by_cases he : y=z
  · subst z
    by_cases h : R < |y| <;> simp [h] <;> nlinarith [sq_nonneg y]
  · simp only [he,ite_false,mul_one]
    nlinarith [sq_nonneg (y+z)]

variable {Ω : Type*} [MeasurableSpace Ω]

theorem coupling_integral_square_truncation (M : Measure Ω) [IsProbabilityMeasure M]
    (Y Z : Ω → ℝ) (hY : Measurable Y) (hZ : Measurable Z)
    (hiY : Integrable (fun w => Y w^2) M) (hiZ : Integrable (fun w => Z w^2) M)
    {R : ℝ} (hR : 0≤R) :
    (∫w,(Y w-Z w)^2 ∂M)≤4*R^2*M.real {w | Y w≠Z w}+
      4*(∫w,(if R < |Y w| then Y w^2 else 0) ∂M)+
      4*(∫w,(if R < |Z w| then Z w^2 else 0) ∂M) := by
  classical
  let E : Set Ω := {w | Y w≠Z w}
  have hE : MeasurableSet E := (measurableSet_eq_fun hY hZ).compl
  let FY := fun w => if R < |Y w| then Y w^2 else 0
  let FZ := fun w => if R < |Z w| then Z w^2 else 0
  have hiy : Integrable FY M := by
    apply hiY.mono' ((gaussian_tail_square_measurable R).comp hY).aestronglyMeasurable
    filter_upwards [] with w
    dsimp [FY]
    split_ifs
    · simp only [Real.norm_eq_abs,abs_sq,le_refl]
    · exact (norm_zero : ‖(0:ℝ)‖=0).le.trans (sq_nonneg _)
  have hiz : Integrable FZ M := by
    apply hiZ.mono' ((gaussian_tail_square_measurable R).comp hZ).aestronglyMeasurable
    filter_upwards [] with w
    dsimp [FZ]
    split_ifs
    · simp only [Real.norm_eq_abs,abs_sq,le_refl]
    · exact (norm_zero : ‖(0:ℝ)‖=0).le.trans (sq_nonneg _)
  have hie : Integrable (E.indicator (fun _ => (1:ℝ))) M := (integrable_const 1).indicator hE
  have hi : Integrable (fun w => (Y w-Z w)^2) M := by
    apply ((hiY.add hiZ).const_mul 2).mono' ((hY.sub hZ).pow_const 2).aestronglyMeasurable
    filter_upwards [] with w
    simp only [Real.norm_eq_abs,Pi.add_apply,Pi.sub_apply,abs_sq]
    nlinarith [sq_nonneg (Y w+Z w)]
  have hm := integral_mono hi ((hie.const_mul (4*R^2)).add (hiy.const_mul 4) |>.add (hiz.const_mul 4))
    (fun w => by
      have hh := coupling_square_truncation (y:=Y w) (z:=Z w) hR
      simpa only [FY,FZ,E,Set.indicator_apply,Set.mem_setOf_eq,ite_not,Pi.add_apply] using hh)
  simp only [Pi.add_apply] at hm
  rw [integral_add (f:=fun w =>4*R^2*E.indicator (fun _ => (1:ℝ)) w+4*FY w) (g:=fun w =>4*FZ w)
      ((hie.const_mul _).add (hiy.const_mul _)) (hiz.const_mul _),
    integral_add (f:=fun w =>4*R^2*E.indicator (fun _ => (1:ℝ)) w) (g:=fun w =>4*FY w)
      (hie.const_mul _) (hiy.const_mul _),integral_const_mul,integral_const_mul,integral_const_mul,
    integral_indicator_const 1 hE] at hm
  simpa only [smul_eq_mul,mul_one] using hm

/-- An arbitrary shared offset cancels from the tanh Lipschitz estimate. -/
theorem tanh_coupling_integral_scaled (M : Measure Ω) [IsProbabilityMeasure M]
    (Y Z b : Ω → ℝ) (hY : Measurable Y) (hZ : Measurable Z) (hb : Measurable b)
    (hiY : Integrable (fun w => Y w^2) M) (hiZ : Integrable (fun w => Z w^2) M)
    (σ : ℝ) :
    (∫w,(Real.tanh (b w+σ*Y w)-Real.tanh (b w+σ*Z w))^2 ∂M)≤
      σ^2*(∫w,(Y w-Z w)^2 ∂M) := by
  have hi : Integrable (fun w => (Y w-Z w)^2) M := by
    apply ((hiY.add hiZ).const_mul 2).mono' ((hY.sub hZ).pow_const 2).aestronglyMeasurable
    filter_upwards [] with w
    simp only [Real.norm_eq_abs,Pi.add_apply,Pi.sub_apply,abs_sq]
    nlinarith [sq_nonneg (Y w+Z w)]
  have ht (w : Ω) : (Real.tanh (b w+σ*Y w)-Real.tanh (b w+σ*Z w))^2≤σ^2*(Y w-Z w)^2 := by
    have hl := tanh_lipschitzWith.dist_le_mul (b w+σ*Y w) (b w+σ*Z w)
    simp only [Real.dist_eq,NNReal.coe_one,one_mul] at hl
    have hs := (sq_le_sq₀ (abs_nonneg _) (abs_nonneg _)).mpr hl
    simp only [sq_abs] at hs
    nlinarith only [hs]
  have hit : Integrable (fun w => (Real.tanh (b w+σ*Y w)-Real.tanh (b w+σ*Z w))^2) M := by
    apply (hi.const_mul (σ^2)).mono' (by fun_prop)
    filter_upwards [] with w
    simpa only [Real.norm_eq_abs,abs_sq] using ht w
  have hm := integral_mono hit (hi.const_mul (σ^2)) ht
  rwa [integral_const_mul] at hm

#print axioms coupling_integral_square_truncation
#print axioms tanh_coupling_integral_scaled
end ConditionalNonpolynomial.Analytic
