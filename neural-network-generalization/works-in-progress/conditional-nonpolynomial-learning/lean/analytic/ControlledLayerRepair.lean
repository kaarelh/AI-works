import ControlledL2Features
import NeuralGeneralization.GaussianFieldCovariance

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators InnerProductSpace ENNReal Matrix
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.FiniteDifferential
open NeuralGeneralization.GaussianAngularFields NeuralGeneralization.BoundedTilt
open NeuralGeneralization.GaussianFieldTilt

variable {X I : Type*} [Fintype X] [DecidableEq X] [Fintype I]

/-- A single fully constructed controlled-path repair step. The exact target
Gram K replaces the approximate certificate moment, while the other feature
family represents a genuine controlled Gaussian layer. Both families are
compressed jointly to 2|X| coordinates, so dimension does not accumulate. -/
theorem repair_controlled_gaussian_layer
    (A B : X → I → ℝ) (V : (X → ℝ) → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ z, |V z| ≤ G)
    (K : Matrix X X ℝ) (hK : K.PosSemidef)
    (δ ε : ℝ) (hδ : 0 ≤ δ) (hε : 0 ≤ ε)
    (hclose : ∀ x, ∑ i, (A x i-B x i)^2 ≤ δ^2)
    (hdefect : ∀ x y,
      |(∫ z, Real.tanh (z x)*Real.tanh (z y) ∂(fieldLaw A).tilted V)-K x y| ≤ ε^2) :
    ∃ Q' : Measure (X → ℝ),
      ∃ C D : X → EuclideanSpace ℝ (X ⊕ X),
      IsProbabilityMeasure Q' ∧ klDiv Q' (fieldLaw B) ≠ ∞ ∧
      (klDiv Q' (fieldLaw B)).toReal ≤
        (klDiv ((fieldLaw A).tilted V) (fieldLaw A)).toReal ∧
      (∀ x y, inner ℝ (C x) (C y)=K x y) ∧
      (∀ x y, inner ℝ (D x) (D y)=∫ z, Real.tanh (z x)*Real.tanh (z y) ∂Q') ∧
      (∀ x, ‖C x-D x‖ ≤
        δ*(1+4*(klDiv ((fieldLaw A).tilted V) (fieldLaw A)).toReal+2*Fintype.card I)+
          (Fintype.card X:ℝ)^4*ε) := by
  obtain ⟨Q,hprob,hKL,hcost,hmapA,herr⟩ :=
    ConditionalAnalytic.controlled_gaussian_feature_coupling A B V hV hbound hclose
  letI : IsProbabilityMeasure Q := hprob
  have hA : Measurable (fieldLinear A) := (fieldLinear A).continuous.measurable
  have hB : Measurable (fieldLinear B) := (fieldLinear B).continuous.measurable
  let Q' := Q.map (fieldLinear B)
  have hprob' : IsProbabilityMeasure Q' := Measure.isProbabilityMeasure_map hB.aemeasurable
  have hDP : klDiv Q' (fieldLaw B) ≤ klDiv Q (standardLaw I) :=
    RobustEntropy.klDiv_map_le Q (standardLaw I) hB
  have hKL' : klDiv Q' (fieldLaw B) ≠ ∞ := ne_top_of_le_ne_top hKL hDP
  have hcost' : (klDiv Q' (fieldLaw B)).toReal ≤
      (klDiv ((fieldLaw A).tilted V) (fieldLaw A)).toReal :=
    (ENNReal.toReal_mono hKL hDP).trans_eq hcost
  let u := tanhL2Feature Q A
  let w := tanhL2Feature Q B
  have hmomentA (x y : X) : inner ℝ (u x) (u y) =
      ∫ z, Real.tanh (z x)*Real.tanh (z y) ∂(fieldLaw A).tilted V := by
    rw [← hmapA]
    rw [integral_map hA.aemeasurable (by fun_prop)]
    exact tanhL2Feature_inner Q A A x y
  have hmomentB (x y : X) : inner ℝ (w x) (w y) =
      ∫ z, Real.tanh (z x)*Real.tanh (z y) ∂Q' := by
    rw [integral_map hB.aemeasurable (by fun_prop)]
    exact tanhL2Feature_inner Q B B x y
  have hdefect' : ∀ x y, |inner ℝ (u x) (u y)-K x y| ≤ ε^2 := by
    intro x y
    rw [hmomentA]
    exact hdefect x y
  have herror : ∀ x, ‖w x-u x‖ ≤
      δ*(1+4*(klDiv ((fieldLaw A).tilted V) (fieldLaw A)).toReal+2*Fintype.card I) := by
    intro x
    rw [norm_sub_rev]
    simpa only [u,w,hcost] using tanhL2Feature_error Q hKL A B hδ hclose x
  obtain ⟨U,v,hv,herror'⟩ := repair_coupled_hilbert_features u w hK ε _ hε hdefect' herror
  obtain ⟨C,D,hC,hD,hCD,hCDdist⟩ := compress_feature_pair v (fun x => U (w x))
  refine ⟨Q',C,D,hprob',hKL',hcost',?_,?_,?_⟩
  · intro x y
    exact (hC x y).trans (hv x y)
  · intro x y
    rw [hD,U.inner_map_map,hmomentB]
  · intro x
    rw [hCDdist,norm_sub_rev]
    exact herror' x

end ConditionalNonpolynomial.Analytic
