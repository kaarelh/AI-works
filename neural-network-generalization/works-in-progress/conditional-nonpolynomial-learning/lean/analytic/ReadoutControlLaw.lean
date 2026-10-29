import FinalReadoutChannel
import GaussianDirectionSplit
import IndependentControlEntropy

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianAngularFields

lemma scalar_shift_kl (μ : ℝ) :
    klDiv (gaussianReal μ 1) (gaussianReal 0 1)=ENNReal.ofReal (μ^2/2) := by
  let e := MeasurableEquiv.funUnique Unit ℝ
  have heQ := (measurePreserving_funUnique (gaussianReal μ (1:ℝ≥0)) Unit).map_eq
  have heP := (measurePreserving_funUnique (gaussianReal (0:ℝ) (1:ℝ≥0)) Unit).map_eq
  have hh := control_kl_measurableEquiv
    (Measure.pi fun _ : Unit=>gaussianReal μ 1)
    (Measure.pi fun _ : Unit=>gaussianReal 0 1) e
  rw [heQ,heP] at hh
  rw [hh]
  have hfin := ConditionalAnalytic.gaussianMeanPi_kl_ne_top (fun _ : Unit=>μ) 1 (by norm_num)
  rw [←ENNReal.ofReal_toReal hfin,ConditionalAnalytic.gaussianMeanPi_kl_toReal
    (fun _ : Unit=>μ) 1 (by norm_num)]
  simp

def readoutControlLaw (N : ℕ) (μ : ℝ) : Measure (ℝ×(Fin N→ℝ)) :=
  (gaussianReal μ 1).prod (standardLaw (Fin N))

instance readoutControlLaw_probability (N : ℕ) (μ : ℝ) :
    IsProbabilityMeasure (readoutControlLaw N μ) := by unfold readoutControlLaw; infer_instance

theorem readoutControlLaw_kl (N : ℕ) (μ : ℝ) :
    klDiv (readoutControlLaw N μ) (readoutControlLaw N 0)=ENNReal.ofReal (μ^2/2) := by
  rw [readoutControlLaw,readoutControlLaw,product_control_kl,klDiv_self,add_zero,scalar_shift_kl]

/-- A shifted scalar Gaussian in an arbitrary unit direction gives exactly
the isotropic shifted Gaussian readout used in the finite-width success bound. -/
theorem directionSplit_shifted_law {N : ℕ} (u : Fin N→ℝ) (hu : ∑i,u i^2=1) (μ : ℝ) :
    (readoutControlLaw N μ).map (fun p=>directionSplit u p.1 p.2)=shiftedReadoutLaw u μ := by
  let T : ℝ×(Fin N→ℝ)→ℝ×(Fin N→ℝ) := fun p=>(p.1+μ,p.2)
  have hT : Measurable T := by fun_prop
  have hshift : (readoutControlLaw N 0).map T=readoutControlLaw N μ := by
    have h := Measure.map_prod_map (gaussianReal (0:ℝ) (1:ℝ≥0)) (standardLaw (Fin N))
      (show Measurable (fun z : ℝ=>z+μ) by fun_prop) measurable_id
    rw [gaussianReal_map_add_const,zero_add,Measure.map_id] at h
    exact h.symm
  have hm : Measurable (fun p : ℝ×(Fin N→ℝ)=>directionSplit u p.1 p.2) := by
    unfold directionSplit; fun_prop
  have he : (fun p : ℝ×(Fin N→ℝ)=>directionSplit u p.1 p.2) ∘ T=
      (fun z : Fin N→ℝ=>fun i=>z i+μ*u i) ∘ (fun p=>directionSplit u p.1 p.2) := by
    funext p i
    simp only [Function.comp_apply,T,directionSplit]
    ring
  rw [←hshift,Measure.map_map hm hT,he,←Measure.map_map (by fun_prop) hm]
  change (((gaussianReal 0 1).prod (standardLaw (Fin N))).map
    (fun p=>directionSplit u p.1 p.2)).map _=_
  rw [directionSplit_product_map u hu,shiftedReadoutLaw_map]

/-- The full readout reference law remains independent of history. -/
theorem adaptive_readout_reference {H Y : Type*}
    [MeasurableSpace H] [MeasurableSpace Y]
    (P : Measure H) [IsProbabilityMeasure P] (ν : Measure Y)
    (F : H→Y) (hF : MeasurePreserving F P ν) {N : ℕ}
    (u : H→Fin N→ℝ) (hu : Measurable u) (hnorm : ∀h,∑i,u h i^2=1) :
    MeasurePreserving (fun p : H×(ℝ×(Fin N→ℝ))=>
      (F p.1,directionSplit (u p.1) p.2.1 p.2.2))
      (P.prod (readoutControlLaw N 0)) (ν.prod (standardLaw (Fin N))) := by
  apply hF.skew_product (g := fun h (p : ℝ×(Fin N→ℝ))=>directionSplit (u h) p.1 p.2)
  · unfold Function.uncurry directionSplit
    fun_prop
  · exact ae_of_all _ (fun h=>directionSplit_product_map (u h) (hnorm h))

#print axioms directionSplit_shifted_law
#print axioms readoutControlLaw_kl
end ConditionalNonpolynomial.Analytic
