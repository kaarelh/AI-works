import GaussianMatchingProjection
import IndependentControlEntropy

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Matrix
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt
variable {I J : Type*} [Fintype I] [Fintype J]

def gaussianCoordinateJoin : ((I→ℝ)×(J→ℝ))≃ᵐ(I⊕J→ℝ) :=
  (MeasurableEquiv.sumPiEquivProdPi (fun _ : I⊕J=>ℝ)).symm

def standardGaussianExtension (Q : Measure (I→ℝ)) (J : Type*) [Fintype J] :
    Measure (I⊕J→ℝ) := (Q.prod (standardLaw J)).map gaussianCoordinateJoin

instance standardGaussianExtension_probability (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q] :
    IsProbabilityMeasure (standardGaussianExtension Q J) :=
  Measure.isProbabilityMeasure_map gaussianCoordinateJoin.measurable.aemeasurable

theorem standardGaussianExtension_standard :
    standardGaussianExtension (standardLaw I) J=standardLaw (I⊕J) := by
  let e := MeasurableEquiv.sumPiEquivProdPi (fun _ : I⊕J=>ℝ)
  have he : (standardLaw (I⊕J)).map e=(standardLaw I).prod (standardLaw J) :=
    (measurePreserving_sumPiEquivProdPi (fun _ : I⊕J=>gaussianReal (0:ℝ) (1:ℝ≥0))).map_eq
  change ((standardLaw I).prod (standardLaw J)).map e.symm=_
  rw [←he,Measure.map_map e.symm.measurable e.measurable,
    MeasurableEquiv.symm_comp_self,Measure.map_id]

theorem standardGaussianExtension_kl (Q P : Measure (I→ℝ))
    [IsProbabilityMeasure Q] [IsProbabilityMeasure P] :
    klDiv (standardGaussianExtension Q J) (standardGaussianExtension P J)=klDiv Q P := by
  rw [standardGaussianExtension,standardGaussianExtension,
    control_kl_measurableEquiv,product_control_kl,klDiv_self,add_zero]

theorem standardGaussianExtension_finite (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (standardLaw I)≠∞) :
    klDiv (standardGaussianExtension Q J) (standardLaw (I⊕J))≠∞ := by
  rw [←standardGaussianExtension_standard,standardGaussianExtension_kl]
  exact hKL

theorem standardGaussian_coordinate_mean (i:I) : (∫x:I→ℝ,x i ∂standardLaw I)=0 := by
  have hh := integral_comp_eval (μ:=fun _ : I=>gaussianReal 0 1) (i:=i)
    (f:=fun x:ℝ=>x) measurable_id.aestronglyMeasurable
  exact hh.trans integral_id_gaussianReal

theorem standardGaussianExtension_moment_left (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q] (i k:I) :
    secondMomentMatrix (standardGaussianExtension Q J) (.inl i) (.inl k)=secondMomentMatrix Q i k := by
  unfold secondMomentMatrix standardGaussianExtension
  rw [integral_map gaussianCoordinateJoin.measurable.aemeasurable (by fun_prop)]
  change (∫p:(I→ℝ)×(J→ℝ),p.1 i*p.1 k ∂Q.prod (standardLaw J))=_
  simpa only [probReal_univ,one_smul] using integral_fun_fst (μ:=Q) (ν:=standardLaw J)
    (fun x=>x i*x k)

theorem standardGaussianExtension_moment_right [DecidableEq J]
    (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q] (i k:J) :
    secondMomentMatrix (standardGaussianExtension Q J) (.inr i) (.inr k)=if i=k then 1 else 0 := by
  unfold secondMomentMatrix standardGaussianExtension
  rw [integral_map gaussianCoordinateJoin.measurable.aemeasurable (by fun_prop)]
  change (∫p:(I→ℝ)×(J→ℝ),p.2 i*p.2 k ∂Q.prod (standardLaw J))=_
  rw [integral_fun_snd (μ:=Q) (ν:=standardLaw J) (fun x:J→ℝ=>x i*x k)]
  simp only [probReal_univ,one_smul]
  have hh := congrFun (congrFun (standardGaussian_secondMomentMatrix (I:=J)) i) k
  exact hh

theorem standardGaussianExtension_moment_cross (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q] (i:I) (k:J) :
    secondMomentMatrix (standardGaussianExtension Q J) (.inl i) (.inr k)=0 := by
  unfold secondMomentMatrix standardGaussianExtension
  rw [integral_map gaussianCoordinateJoin.measurable.aemeasurable (by fun_prop)]
  change (∫p:(I→ℝ)×(J→ℝ),p.1 i*p.2 k ∂Q.prod (standardLaw J))=_
  rw [integral_prod_mul (μ:=Q) (ν:=standardLaw J) (fun x:I→ℝ=>x i) (fun x:J→ℝ=>x k),
    standardGaussian_coordinate_mean]
  ring

#print axioms standardGaussianExtension_kl
#print axioms standardGaussianExtension_moment_cross
end ConditionalNonpolynomial.Analytic
