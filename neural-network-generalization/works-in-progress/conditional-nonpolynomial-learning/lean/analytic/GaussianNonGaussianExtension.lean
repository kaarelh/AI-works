import GaussianIndependentExtension

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2500000
open MeasureTheory ProbabilityTheory InformationTheory Matrix
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt
variable {I J : Type*} [Fintype I] [Fintype J] [DecidableEq I] [DecidableEq J]

def gaussianExtensionMatrix (B : I→I→ℝ) : I⊕J→I⊕J→ℝ
  | .inl i,.inl k=>B i k
  | .inr i,.inr k=>if i=k then 1 else 0
  | _,_=>0

theorem gaussianExtensionMatrix_gram_left (B : I→I→ℝ) (i k:I) :
    NeuralGeneralization.GaussianAngularPrice.gram (gaussianExtensionMatrix (J:=J) B) (.inl i) (.inl k)=NeuralGeneralization.GaussianAngularPrice.gram B i k := by
  simp [NeuralGeneralization.GaussianAngularPrice.gram,gaussianExtensionMatrix,Fintype.sum_sum_type]

theorem gaussianExtensionMatrix_gram_right (B : I→I→ℝ) (i k:J) :
    NeuralGeneralization.GaussianAngularPrice.gram (gaussianExtensionMatrix B) (.inr i) (.inr k)=if i=k then 1 else 0 := by
  simp [NeuralGeneralization.GaussianAngularPrice.gram,gaussianExtensionMatrix,Fintype.sum_sum_type]

theorem gaussianExtensionMatrix_gram_cross (B : I→I→ℝ) (i:I) (k:J) :
    NeuralGeneralization.GaussianAngularPrice.gram (gaussianExtensionMatrix B) (.inl i) (.inr k)=0 := by
  simp [NeuralGeneralization.GaussianAngularPrice.gram,gaussianExtensionMatrix,Fintype.sum_sum_type]

theorem standardGaussianExtension_fieldLaw (B : I→I→ℝ) :
    standardGaussianExtension (fieldLaw B) J=fieldLaw (gaussianExtensionMatrix (J:=J) B) := by
  let e := MeasurableEquiv.sumPiEquivProdPi (fun _ : I⊕J=>ℝ)
  let F : (I→ℝ)×(J→ℝ)→(I→ℝ)×(J→ℝ) := Prod.map (fieldLinear B) id
  have hF : Measurable F := (fieldLinear B).continuous.measurable.prodMap measurable_id
  have he : (standardLaw (I⊕J)).map e=(standardLaw I).prod (standardLaw J) :=
    (measurePreserving_sumPiEquivProdPi (fun _ : I⊕J=>gaussianReal (0:ℝ) (1:ℝ≥0))).map_eq
  have hp := Measure.map_prod_map (standardLaw I) (standardLaw J)
    (fieldLinear B).continuous.measurable measurable_id
  rw [Measure.map_id] at hp
  have hcompose : gaussianCoordinateJoin ∘ F ∘ e=fieldLinear (gaussianExtensionMatrix (J:=J) B) := by
    funext z k
    cases k <;> simp [gaussianCoordinateJoin,F,e,MeasurableEquiv.coe_sumPiEquivProdPi,MeasurableEquiv.coe_sumPiEquivProdPi_symm,
      fieldLinear_apply,gaussianExtensionMatrix,Fintype.sum_sum_type]

  unfold standardGaussianExtension fieldLaw
  rw [hp,←he,Measure.map_map hF e.measurable,
    Measure.map_map gaussianCoordinateJoin.measurable (hF.comp e.measurable),hcompose]

theorem matchingGaussian_standardGaussianExtension (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (standardLaw I)≠∞) :
    matchingGaussian (standardGaussianExtension Q J)=standardGaussianExtension (matchingGaussian Q) J := by
  let B := gaussianUnwhiteningMatrix Q
  let R := standardGaussianExtension Q J
  have hR : klDiv R (standardLaw (I⊕J))≠∞ := standardGaussianExtension_finite Q hKL
  have href : standardGaussianExtension (matchingGaussian Q) J=
      fieldLaw (gaussianExtensionMatrix (J:=J) B) := by
    rw [matchingGaussian_eq_fieldLaw Q hKL,standardGaussianExtension_fieldLaw]
  have hM : secondMomentMatrix R=secondMomentMatrix (fieldLaw (gaussianExtensionMatrix (J:=J) B)) := by
    ext i k
    cases i with
    | inl i =>
      cases k with
      | inl k =>
        rw [standardGaussianExtension_moment_left,fieldLaw_secondMomentMatrix,
          gaussianExtensionMatrix_gram_left,←fieldLaw_secondMomentMatrix B,
          ←matchingGaussian_eq_fieldLaw Q hKL,matchingGaussian_secondMomentMatrix Q hKL]
      | inr k =>
        rw [standardGaussianExtension_moment_cross,fieldLaw_secondMomentMatrix,
          gaussianExtensionMatrix_gram_cross]
    | inr i =>
      cases k with
      | inl k =>
        have hs := congrFun (congrFun (secondMomentMatrix_isHermitian R) (.inl k)) (.inr i)
        simp only [Matrix.conjTranspose_apply,star_trivial] at hs
        rw [hs,standardGaussianExtension_moment_cross,fieldLaw_secondMomentMatrix]
        simp [NeuralGeneralization.GaussianAngularPrice.gram,gaussianExtensionMatrix,Fintype.sum_sum_type]
      | inr k =>
        rw [standardGaussianExtension_moment_right,fieldLaw_secondMomentMatrix,
          gaussianExtensionMatrix_gram_right]
  rw [href,matchingGaussian_eq_fieldLaw R hR]
  apply fieldLaw_eq_of_secondMomentMatrix_eq
  rw [←matchingGaussian_eq_fieldLaw R hR,matchingGaussian_secondMomentMatrix R hR]
  exact hM

/-- Adding an untouched independent standard Gaussian complement preserves
exactly the non-Gaussian entropy, with all matching laws constructed above. -/
theorem nonGaussianKL_standardGaussianExtension (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (standardLaw I)≠∞) :
    klDiv (standardGaussianExtension Q J) (matchingGaussian (standardGaussianExtension Q J))=
      klDiv Q (matchingGaussian Q) := by
  rw [matchingGaussian_standardGaussianExtension Q hKL,standardGaussianExtension_kl]

#print axioms nonGaussianKL_standardGaussianExtension
end ConditionalNonpolynomial.Analytic
