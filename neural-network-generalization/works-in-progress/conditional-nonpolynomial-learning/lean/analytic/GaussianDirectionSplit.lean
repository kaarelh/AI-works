import NeuralGeneralization.GaussianNoiseSplit
import ProductControlEntropy
import Mathlib.Tactic.FunProp
import Mathlib.Tactic.Ring

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt

variable {I : Type*} [Fintype I] [DecidableEq I]

/-- A scalar control in a chosen unit direction, plus untouched Gaussian noise
in its orthogonal complement. -/
def directionSplit (u : I→ℝ) (z : ℝ) (ξ : I→ℝ) : I→ℝ :=
  fun i => z*u i + ξ i-u i*(∑j,u j*ξ j)

def directionSplitMatrix (u : I→ℝ) (i : I) : Unit⊕I→ℝ :=
  Sum.elim (fun _ => u i) (fun j => (if i=j then 1 else 0)-u i*u j)

theorem directionSplitMatrix_gram (u : I→ℝ) (hu : ∑i,u i^2=1) (i k : I) :
    gram (directionSplitMatrix u) i k=(if i=k then 1 else 0) := by
  classical
  simp only [gram,directionSplitMatrix,Fintype.sum_sum_type,Sum.elim_inl,Sum.elim_inr,
    Fintype.sum_unique]
  have he : ∑j,((if i=j then 1 else 0)-u i*u j)*((if k=j then 1 else 0)-u k*u j)=
      (if i=k then 1 else 0)-u k*u i-u i*u k+(u i*u k)*(∑j,u j^2) := by
    calc
      _ = ∑j, ((if i=j then (if k=j then (1:ℝ) else 0) else 0)
          -(if i=j then u k*u j else 0)-(if k=j then u i*u j else 0)
          +(u i*u k)*(u j)^2) := by
        apply Finset.sum_congr rfl
        intro j hj
        split_ifs <;> ring
      _ = _ := by simp [Finset.sum_add_distrib,Finset.sum_sub_distrib,Finset.mul_sum,eq_comm]
  rw [he,hu]
  ring

theorem directionSplit_product_map_unit (u : I→ℝ) (hu : ∑i,u i^2=1) :
    ((standardLaw Unit).prod (standardLaw I)).map
      (fun p : (Unit→ℝ)×(I→ℝ) => directionSplit u (p.1 ()) p.2) = standardLaw I := by
  classical
  let e := MeasurableEquiv.sumPiEquivProdPi (fun _ : Unit⊕I=>ℝ)
  let F : (Unit→ℝ)×(I→ℝ) → I→ℝ := fun p=>directionSplit u (p.1 ()) p.2
  have hF : Measurable F := by unfold F directionSplit; fun_prop
  have he : (standardLaw (Unit⊕I)).map e=(standardLaw Unit).prod (standardLaw I) :=
    (measurePreserving_sumPiEquivProdPi (fun _ : Unit⊕I=>gaussianReal (0:ℝ) (1:ℝ≥0))).map_eq
  have hfield : F ∘ e=fieldLinear (directionSplitMatrix u) := by
    funext z i
    simp [F,e,directionSplit,directionSplitMatrix,fieldLinear_apply,
      MeasurableEquiv.coe_sumPiEquivProdPi,Fintype.sum_sum_type,
      sub_mul,ite_mul,Finset.sum_sub_distrib,Finset.mul_sum,mul_assoc]
    ring
  change ((standardLaw Unit).prod (standardLaw I)).map F=_
  rw [←he,Measure.map_map hF e.measurable,hfield]
  change fieldLaw (directionSplitMatrix u)=_
  have hgram : fieldLaw (directionSplitMatrix u)=fieldLaw (fun i j:I=>if i=j then 1 else 0) := by
    apply NeuralGeneralization.GaussianFieldCovariance.fieldLaw_eq_of_gram_eq
    intro i k
    rw [directionSplitMatrix_gram u hu]
    simp [gram]
  rw [hgram]
  have hi : fieldLinear (fun i j:I=>if i=j then (1:ℝ) else 0)=ContinuousLinearMap.id ℝ (I→ℝ) := by
    ext z i
    simp [fieldLinear_apply]
  simp [fieldLaw,hi]

theorem directionSplit_product_map (u : I→ℝ) (hu : ∑i,u i^2=1) :
    ((gaussianReal 0 1).prod (standardLaw I)).map
      (fun p : ℝ×(I→ℝ) => directionSplit u p.1 p.2) = standardLaw I := by
  let e := MeasurableEquiv.funUnique Unit ℝ
  have he : (standardLaw Unit).map e=gaussianReal 0 1 :=
    (measurePreserving_funUnique (gaussianReal (0:ℝ) (1:ℝ≥0)) Unit).map_eq
  have hp := Measure.map_prod_map (standardLaw Unit) (standardLaw I)
    e.measurable measurable_id
  rw [he,Measure.map_id] at hp
  rw [hp,Measure.map_map]
  · simpa [Function.comp_def,e] using directionSplit_product_map_unit u hu
  · unfold directionSplit
    fun_prop
  · exact e.measurable.prodMap measurable_id

/-- Any scalar control space whose reference marginal is standard Gaussian
can be used; the auxiliary score coordinate is discarded in the raw prior. -/
theorem directionSplit_reference {Ω : Type*} [MeasurableSpace Ω]
    (P : Measure Ω) [IsProbabilityMeasure P]
    (Z : Ω→ℝ) (hZ : Measurable Z) (hP : P.map Z=gaussianReal 0 1)
    (u : I→ℝ) (hu : ∑i,u i^2=1) :
    (P.prod (standardLaw I)).map (fun p=>directionSplit u (Z p.1) p.2)=standardLaw I := by
  have hp := Measure.map_prod_map P (standardLaw I) hZ measurable_id
  rw [hP,Measure.map_id] at hp
  calc
    _ = ((gaussianReal 0 1).prod (standardLaw I)).map
      (fun p : ℝ×(I→ℝ)=>directionSplit u p.1 p.2) := by
        rw [hp,Measure.map_map]
        · rfl
        · unfold directionSplit; fun_prop
        · exact hZ.prodMap measurable_id
    _ = _ := directionSplit_product_map u hu

end ConditionalNonpolynomial.Analytic
