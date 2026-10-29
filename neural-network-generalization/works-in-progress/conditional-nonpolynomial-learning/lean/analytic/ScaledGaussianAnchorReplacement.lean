import SharedAnchorInnovation
import GaussianAnchorInnovation
import AnchorQueryFeatures

/-! Actual variance-scaled anchor replacement for arbitrary finite Gaussian
fields, including singular fields and deterministic queries. The weaker
polynomial modulus suffices for uniform normalized anchor selection. -/
noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.RobustEntropy
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianFieldTilt
variable {X I : Type*} [Fintype X] [DecidableEq X] [Fintype I]

def gaussianAnchorModulus (δ : ℝ) : ℝ := 520*Real.sqrt (Real.sqrt δ)+16*δ

lemma gaussianAnchorModulus_nonneg {δ : ℝ} (hδ : 0≤δ) : 0≤gaussianAnchorModulus δ := by
  unfold gaussianAnchorModulus
  positivity

theorem coordinateAnchorCoupling_gaussian_tanh_error
    (A : X → I → ℝ) (Q : Measure (X → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (fieldLaw A)≠∞) (S : Finset X) (x : X) {δ : ℝ} (hδ : 0<δ)
    (hgap : coordinateEntropy Q (fieldLaw A) (insert x S)-coordinateEntropy Q (fieldLaw A) S≤δ) :
    (∫p,(Real.tanh p.2.1-Real.tanh p.2.2)^2 ∂coordinateAnchorCoupling Q (fieldLaw A) S x)≤
      ‖WithLp.toLp 2 (A x)‖^2*gaussianAnchorModulus δ := by
  let Qp := Q.map (coordinatePair S x)
  let Gp := (fieldLaw A).map (coordinatePair S x)
  haveI : IsProbabilityMeasure Qp := Measure.isProbabilityMeasure_map (measurable_coordinatePair S x).aemeasurable
  haveI : IsProbabilityMeasure Gp := Measure.isProbabilityMeasure_map (measurable_coordinatePair S x).aemeasurable
  have hf : klDiv Qp Gp≠∞ := ne_top_of_le_ne_top hKL
    (klDiv_map_le Q (fieldLaw A) (measurable_coordinatePair S x))
  have hg : (klDiv Qp Gp).toReal-(klDiv Qp.fst Gp.fst).toReal≤δ := by
    dsimp [Qp,Gp]
    rw [coordinatePair_klDiv,coordinatePair_fst,coordinatePair_fst]
    exact hgap
  obtain ⟨m,σ,hm,hσ,hσbound,hzero,hpositive⟩ := exists_gaussian_anchor_innovation A S x
  change (∫p,(Real.tanh p.2.1-Real.tanh p.2.2)^2 ∂sharedAnchorCoupling Qp Gp)≤_
  by_cases hz : σ=0
  · rw [sharedAnchorCoupling_deterministic_error Qp Gp hf m hm (hzero hz)]
    exact mul_nonneg (sq_nonneg _) (gaussianAnchorModulus_nonneg hδ.le)
  · have hp : 0<σ := lt_of_le_of_ne hσ (Ne.symm hz)
    exact (sharedAnchorCoupling_gaussian_innovation Qp Gp hf m hm hp hδ (hpositive hp) hg).trans
      (mul_le_mul_of_nonneg_right hσbound (gaussianAnchorModulus_nonneg hδ.le))

/-- Actual feature coupling with physical input norm in front of the
polynomial entropy modulus. All anchor/query Grams are retained exactly. -/
theorem gaussian_coordinate_anchor_replacement_features
    (A : X → I → ℝ) (Q : Measure (X → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (fieldLaw A)≠∞) (S : Finset X) (x : X) {δ : ℝ} (hδ : 0<δ)
    (hgap : coordinateEntropy Q (fieldLaw A) (insert x S)-coordinateEntropy Q (fieldLaw A) S≤δ) :
    ∃U V : S ⊕ Unit → EuclideanSpace ℝ ((S ⊕ Unit) ⊕ (S ⊕ Unit)),
      (∀i j,inner ℝ (U i) (U j)=
        ∫z,Real.tanh (z (anchorQueryIndex S x i))*Real.tanh (z (anchorQueryIndex S x j)) ∂Q) ∧
      (∀i j,inner ℝ (V i) (V j)=
        ∫z,Real.tanh (z (anchorQueryIndex S x i))*Real.tanh (z (anchorQueryIndex S x j))
          ∂fieldAnchorReplacement Q (fieldLaw A) (maskCoordinates S)) ∧
      (∀s:S,U (.inl s)=V (.inl s)) ∧
      ‖U (.inr ())-V (.inr ())‖≤‖WithLp.toLp 2 (A x)‖*Real.sqrt (gaussianAnchorModulus δ) := by
  letI := coordinateAnchorCoupling_probability Q (fieldLaw A) S x
  letI := fieldAnchorReplacement_probability Q (fieldLaw A) (measurable_maskCoordinates S)
  obtain ⟨U,V,hU,hV,hanchor,herror⟩ := anchor_query_coupling_features Q _ S x
    (coordinateAnchorCoupling Q (fieldLaw A) S x)
    (coordinateAnchorCoupling_left Q (fieldLaw A) S x)
    (coordinateAnchorCoupling_right Q (fieldLaw A) hKL S x)
    (mul_nonneg (norm_nonneg _) (Real.sqrt_nonneg _))
    (show (∫p,(Real.tanh p.2.1-Real.tanh p.2.2)^2 ∂coordinateAnchorCoupling Q (fieldLaw A) S x)≤
      (‖WithLp.toLp 2 (A x)‖*Real.sqrt (gaussianAnchorModulus δ))^2 from by
      rw [mul_pow,Real.sq_sqrt (gaussianAnchorModulus_nonneg hδ.le)]
      exact coordinateAnchorCoupling_gaussian_tanh_error A Q hKL S x hδ hgap)
  exact ⟨U,V,hU,hV,hanchor,herror⟩

#print axioms coordinateAnchorCoupling_gaussian_tanh_error
end ConditionalNonpolynomial.Analytic
