import GaussianRegressionSplit

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt

variable {X I : Type*} [Fintype X] [DecidableEq X] [Fintype I]

theorem gaussian_anchor_zero_residual (A : X→I→ℝ) (S : Finset X) (x : X) (c : S→ℝ)
    (hzero : (∑i,(anchorRegressionResidual A S x c i)^2)=0) :
    ∀ᵐp ∂(fieldLaw A).map (coordinatePair S x), p.2=anchorRegressionMean S c p.1 := by
  have he (i:I) : anchorRegressionResidual A S x c i=0 := by
    have hi := Finset.single_le_sum (fun j _=>sq_nonneg (anchorRegressionResidual A S x c j))
      (Finset.mem_univ i)
    nlinarith
  have hpoint (ξ:I→ℝ) : fieldLinear A ξ x=
      anchorRegressionMean S c (maskCoordinates S (fieldLinear A ξ)) := by
    apply sub_eq_zero.mp
    rw [anchorRegression_residual_identity]
    simp only [he,zero_mul,Finset.sum_const_zero]
  unfold fieldLaw
  rw [Measure.map_map (measurable_coordinatePair S x) (fieldLinear A).continuous.measurable]
  apply (ae_map_iff ((measurable_coordinatePair S x).comp
    (fieldLinear A).continuous.measurable).aemeasurable (by measurability)).mpr
  exact Filter.Eventually.of_forall hpoint

/-- Exact Gaussian regression decomposition for any finite field and any set
of anchors. Positive residual variance gives independent standard Gaussian
innovation; zero residual variance gives an exact deterministic relation. -/
theorem exists_gaussian_anchor_innovation (A : X→I→ℝ) (S : Finset X) (x : X) :
    ∃ (m : (X→ℝ)→ℝ) (σ : ℝ),
      Measurable m ∧ 0≤σ ∧ σ^2≤‖WithLp.toLp 2 (A x)‖^2 ∧
      (σ=0 → ∀ᵐp ∂(fieldLaw A).map (coordinatePair S x),p.2=m p.1) ∧
      (0<σ → ((fieldLaw A).map (coordinatePair S x)).map
        (fun p=>(p.1,(p.2-m p.1)/σ))=
        ((fieldLaw A).map (coordinatePair S x)).fst.prod (gaussianReal 0 1)) := by
  obtain ⟨c,horth,hbound⟩ := exists_anchor_regression_coefficients A S x
  let q := ∑i,(anchorRegressionResidual A S x c i)^2
  let σ := Real.sqrt q
  have hq : 0≤q := Finset.sum_nonneg fun i _=>sq_nonneg _
  have hσsq : σ^2=q := Real.sq_sqrt hq
  refine ⟨anchorRegressionMean S c,σ,anchorRegressionMean_measurable S c,
    Real.sqrt_nonneg _,hσsq.le.trans hbound,?_,?_⟩
  · intro hσ
    have hz : q=0 := by rw [hσ] at hσsq; simpa using hσsq.symm
    exact gaussian_anchor_zero_residual A S x c hz
  · intro hσ
    exact gaussian_anchor_normalized_innovation A S x c horth hσ hσsq

#print axioms exists_gaussian_anchor_innovation
end ConditionalNonpolynomial.Analytic
