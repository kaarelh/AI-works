import ScalarChannelPopulation
import DirectionSplitScalarChannel
import ProductControlEntropy

/-! Scalar-coordinate laws and moments of the literal direction-split
Gaussian network row, including zero residual variance. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianAngularFields

def channelPairCoordinates (p : ℝ×ℝ) : Fin 2→ℝ :=
  (MeasurableEquiv.piFinTwo (fun _ : Fin 2=>ℝ)).symm p

lemma channelPairCoordinates_measurable : Measurable channelPairCoordinates :=
  (MeasurableEquiv.piFinTwo (fun _ : Fin 2=>ℝ)).symm.measurable

def channelPairCoefficients : WithLp 2 (ℝ×ℝ) →ₗᵢ[ℝ] EuclideanSpace ℝ (Fin 2) where
  toFun p := WithLp.toLp 2 ![p.fst,p.snd]
  map_add' p q := by ext i; fin_cases i <;> rfl
  map_smul' c p := by ext i; fin_cases i <;> rfl
  norm_map' p := by
    apply (sq_eq_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
    rw [EuclideanSpace.norm_sq_eq,WithLp.prod_norm_sq_eq_of_L2]
    simp

lemma channelPair_linear (c r z g : ℝ) :
    gaussianLinearForm (channelPairCoefficients (WithLp.toLp 2 (c,r)))
      (channelPairCoordinates (z,g))=c*z+r*g := by
  simp [gaussianLinearForm,PiLp.inner_apply,channelPairCoefficients,
    channelPairCoordinates,MeasurableEquiv.piFinTwo_symm_apply,Fin.sum_univ_two,
    Real.inner_apply,mul_comm]

lemma channelPairCoordinates_reference :
    ((gaussianReal 0 1).prod (gaussianReal 0 1)).map channelPairCoordinates=
      standardLaw (Fin 2) := by
  exact (MeasurePreserving.symm (MeasurableEquiv.piFinTwo (fun _ : Fin 2=>ℝ))
    (measurePreserving_piFinTwo (fun _ : Fin 2=>gaussianReal 0 1))).map_eq

variable {Ω : Type*} [MeasurableSpace Ω]

def scalarSourceCoordinates (Z : Ω→ℝ) (p : Ω×ℝ) : Fin 2→ℝ :=
  channelPairCoordinates (Z p.1,p.2)

lemma scalarSourceCoordinates_measurable (Z : Ω→ℝ) (hZ : Measurable Z) :
    Measurable (scalarSourceCoordinates Z) :=
  channelPairCoordinates_measurable.comp ((hZ.comp measurable_fst).prodMk measurable_snd)

lemma scalarSourceCoordinates_reference (P : Measure Ω) [IsProbabilityMeasure P]
    (Z : Ω→ℝ) (hZ : Measurable Z) (hP : P.map Z=gaussianReal 0 1) :
    (P.prod (gaussianReal 0 1)).map (scalarSourceCoordinates Z)=standardLaw (Fin 2) := by
  have he := Measure.map_prod_map P (gaussianReal 0 1) hZ measurable_id
  rw [hP,Measure.map_id] at he
  rw [←channelPairCoordinates_reference,he,Measure.map_map channelPairCoordinates_measurable
    (hZ.prodMap measurable_id)]
  rfl

theorem scalarSourceCoordinates_entropy [StandardBorelSpace Ω] [Nonempty Ω]
    (Q P : Measure Ω) [IsProbabilityMeasure Q] [IsProbabilityMeasure P]
    (Z : Ω→ℝ) (hZ : Measurable Z) (hP : P.map Z=gaussianReal 0 1) :
    klDiv ((Q.prod (gaussianReal 0 1)).map (scalarSourceCoordinates Z))
      (standardLaw (Fin 2))≤klDiv Q P := by
  rw [←scalarSourceCoordinates_reference P Z hZ hP]
  have hh := mapped_product_control_kl Q P (gaussianReal 0 1) (gaussianReal 0 1)
    (scalarSourceCoordinates Z) (scalarSourceCoordinates_measurable Z hZ)
  simpa only [klDiv_self,add_zero] using hh

def splitRowFeature {N : ℕ} (Z : Ω→ℝ) (u h : Fin N→ℝ)
    (p : Ω×(Fin N→ℝ)) : ℝ :=
  Real.tanh (∑i,directionSplit u (Z p.1) p.2 i*h i)

theorem splitRowFeature_moments (Q : Measure Ω) [IsProbabilityMeasure Q]
    {N : ℕ} (hN : 0<N) (Z b : Ω→ℝ) (hZ : Measurable Z) (hb : Measurable b)
    (u h : Fin N→ℝ) (hu : ∑i,u i^2=1) :
    (∫p,b p.1*splitRowFeature Z u h p ∂Q.prod (standardLaw (Fin N)))=
      (∫p,b p.1*scalarChannelFeature (scalarSourceCoordinates Z)
        (channelPairCoefficients (canonicalCompletion (directionCoefficient u h)
          (∑i,h i^2))) p ∂Q.prod (gaussianReal 0 1)) ∧
    (∫p,(splitRowFeature Z u h p)^2 ∂Q.prod (standardLaw (Fin N)))=
      (∫p,(scalarChannelFeature (scalarSourceCoordinates Z)
        (channelPairCoefficients (canonicalCompletion (directionCoefficient u h)
          (∑i,h i^2))) p)^2 ∂Q.prod (gaussianReal 0 1)) := by
  let T : Ω×(Fin N→ℝ)→Ω×ℝ := fun p=>(p.1,directionNoise hN u h p.2)
  have hT : Measurable T := by unfold T directionNoise; fun_prop
  have hmap : (Q.prod (standardLaw (Fin N))).map T=Q.prod (gaussianReal 0 1) :=
    directionNoise_product_map Q hN u h
  have hres : 0≤(∑i,h i^2)-(directionCoefficient u h)^2 := by
    rw [←directionResidual_squared u h hu]
    exact Finset.sum_nonneg fun i _=>sq_nonneg _
  have hpoint (p : Ω×(Fin N→ℝ)) : splitRowFeature Z u h p=
      scalarChannelFeature (scalarSourceCoordinates Z)
        (channelPairCoefficients (canonicalCompletion (directionCoefficient u h) (∑i,h i^2))) (T p) := by
    unfold splitRowFeature scalarChannelFeature scalarSourceCoordinates canonicalCompletion
    rw [channelPair_linear,directionSplit_scalar_identity hN u h hu]
    simp only [Real.norm_eq_abs,sq_abs,max_eq_right hres,T]
  constructor
  · rw [←hmap,integral_map hT.aemeasurable]
    · apply integral_congr_ae
      exact Filter.Eventually.of_forall fun p=>by dsimp only; rw [hpoint]
    · exact ((hb.comp measurable_fst).mul
        (scalarChannelFeature_measurable _ (scalarSourceCoordinates_measurable Z hZ) _)).aestronglyMeasurable
  · rw [←hmap,integral_map hT.aemeasurable]
    · apply integral_congr_ae
      exact Filter.Eventually.of_forall fun p=>by dsimp only; rw [hpoint]
    · exact ((scalarChannelFeature_measurable _ (scalarSourceCoordinates_measurable Z hZ) _).pow_const 2).aestronglyMeasurable

#print axioms scalarSourceCoordinates_entropy
#print axioms splitRowFeature_moments
end ConditionalNonpolynomial.Analytic
