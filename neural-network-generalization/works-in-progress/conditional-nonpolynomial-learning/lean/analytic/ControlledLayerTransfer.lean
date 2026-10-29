import GaussianFeatureRepair
import BoundedTiltLift

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalAnalytic
open NeuralGeneralization
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianFieldTilt NeuralGeneralization.BoundedTilt
open ConditionalNonpolynomial.Analytic

variable {X I : Type*} [Fintype X] [Fintype I]

/-- Repair a controlled Gaussian field using close feature vectors. The new
law is constructed by lifting the old tilt to common Gaussian coordinates and
pushing the same law through the new field; its KL cost never increases. -/
theorem controlled_gaussian_layer_transfer
    (A B : X → I → ℝ) (V : (X → ℝ) → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G)
    {δ : ℝ} (hδ : 0 ≤ δ) (hclose : ∀ x, ∑ i, (A x i-B x i)^2 ≤ δ^2) :
    ∃ Q' : Measure (X → ℝ), IsProbabilityMeasure Q' ∧
      klDiv Q' (fieldLaw B) ≠ ∞ ∧
      (klDiv Q' (fieldLaw B)).toReal ≤
        (klDiv ((fieldLaw A).tilted V) (fieldLaw A)).toReal ∧
      ∀ x y,
        |(∫ z, Real.tanh (z x)*Real.tanh (z y) ∂Q')-
          (∫ z, Real.tanh (z x)*Real.tanh (z y) ∂(fieldLaw A).tilted V)| ≤
          2*δ*(1+4*(klDiv ((fieldLaw A).tilted V) (fieldLaw A)).toReal+
            2*Fintype.card I) := by
  let μ := standardLaw I
  let Q := μ.tilted (V ∘ fieldLinear A)
  have hA : Measurable (fieldLinear A) := (fieldLinear A).continuous.measurable
  have hB : Measurable (fieldLinear B) := (fieldLinear B).continuous.measurable
  letI : IsProbabilityMeasure Q := tilted_probability μ (V ∘ fieldLinear A)
    (hV.comp hA) (fun z => hbound (fieldLinear A z))
  have hKL : klDiv Q μ ≠ ∞ := boundedTilt_klDiv_ne_top μ
    (V ∘ fieldLinear A) (hV.comp hA) (fun z => hbound (fieldLinear A z))
  have hcost : (klDiv Q μ).toReal =
      (klDiv ((fieldLaw A).tilted V) (fieldLaw A)).toReal :=
    klDiv_tilted_pullback μ (fieldLinear A) hA V hV hbound
  have hmapA : Q.map (fieldLinear A) = (fieldLaw A).tilted V :=
    map_tilted_pullback μ (fieldLinear A) hA V hV
  let Q' := Q.map (fieldLinear B)
  have hDP : klDiv Q' (fieldLaw B) ≤ klDiv Q μ :=
    RobustEntropy.klDiv_map_le Q μ hB
  have hKL' : klDiv Q' (fieldLaw B) ≠ ∞ := ne_top_of_le_ne_top hKL hDP
  refine ⟨Q',Measure.isProbabilityMeasure_map hB.aemeasurable,hKL',?_,?_⟩
  · exact (ENNReal.toReal_mono hKL hDP).trans_eq hcost
  · intro x y
    have htest : Measurable (fun z : X → ℝ => Real.tanh (z x)*Real.tanh (z y)) := by fun_prop
    have h1 : (∫ z, Real.tanh (z x)*Real.tanh (z y) ∂Q') =
        ∫ g, Real.tanh (fieldLinear B g x)*Real.tanh (fieldLinear B g y) ∂Q :=
      integral_map hB.aemeasurable htest.aestronglyMeasurable
    have h2 : (∫ z, Real.tanh (z x)*Real.tanh (z y) ∂(fieldLaw A).tilted V) =
        ∫ g, Real.tanh (fieldLinear A g x)*Real.tanh (fieldLinear A g y) ∂Q := by
      rw [← hmapA]
      exact integral_map hA.aemeasurable htest.aestronglyMeasurable
    rw [h1,h2,abs_sub_comm]
    change (klDiv Q (standardLaw I)).toReal = _ at hcost
    simpa only [fieldLinear_apply,hcost] using
      tanh_pair_repair Q hKL (A x) (B x) (A y) (B y) hδ (hclose x) (hclose y)

/-- The common-coordinate controlled coupling is itself provided, with an L²
feature error. Keeping this coupling allows subsequent Gram gluing to preserve
linear feature-error accumulation rather than repeatedly taking square roots. -/
theorem controlled_gaussian_feature_coupling
    (A B : X → I → ℝ) (V : (X → ℝ) → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G)
    {δ : ℝ} (hclose : ∀ x, ∑ i, (A x i-B x i)^2 ≤ δ^2) :
    ∃ Q : Measure (I → ℝ), IsProbabilityMeasure Q ∧
      klDiv Q (standardLaw I) ≠ ∞ ∧
      (klDiv Q (standardLaw I)).toReal =
        (klDiv ((fieldLaw A).tilted V) (fieldLaw A)).toReal ∧
      Q.map (fieldLinear A) = (fieldLaw A).tilted V ∧
      ∀ x, (∫ g, (Real.tanh (fieldLinear A g x)-Real.tanh (fieldLinear B g x))^2 ∂Q) ≤
        δ^2*(4*(klDiv ((fieldLaw A).tilted V) (fieldLaw A)).toReal+2*Fintype.card I) := by
  let μ := standardLaw I
  let Q := μ.tilted (V ∘ fieldLinear A)
  have hA : Measurable (fieldLinear A) := (fieldLinear A).continuous.measurable
  letI : IsProbabilityMeasure Q := tilted_probability μ (V ∘ fieldLinear A)
    (hV.comp hA) (fun z => hbound (fieldLinear A z))
  have hKL : klDiv Q μ ≠ ∞ := boundedTilt_klDiv_ne_top μ
    (V ∘ fieldLinear A) (hV.comp hA) (fun z => hbound (fieldLinear A z))
  have hcost : (klDiv Q (standardLaw I)).toReal =
      (klDiv ((fieldLaw A).tilted V) (fieldLaw A)).toReal :=
    klDiv_tilted_pullback μ (fieldLinear A) hA V hV hbound
  refine ⟨Q,inferInstance,hKL,hcost,map_tilted_pullback μ (fieldLinear A) hA V hV,?_⟩
  intro x
  simpa only [fieldLinear_apply,hcost] using
    tanh_feature_repair_squared Q hKL (A x) (B x) (hclose x)

#print axioms controlled_gaussian_feature_coupling
#print axioms controlled_gaussian_layer_transfer
end ConditionalAnalytic
