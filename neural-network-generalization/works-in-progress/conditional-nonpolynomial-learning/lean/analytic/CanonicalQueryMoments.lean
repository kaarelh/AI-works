import AnchorQueryFeatures
import CanonicalProgramState

noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianFieldTilt NeuralGeneralization.GaussianAngularPrice

variable {X I : Type*} [Fintype X] [DecidableEq X] [Fintype I]

theorem canonicalGaussian_anchor_query_moments
    (L : Measure (I → ℝ)) [IsProbabilityMeasure L]
    (hKL : klDiv L (standardLaw I)≠∞)
    (B : X → EuclideanSpace ℝ I) (S : Finset X) (x : X) (i j : S ⊕ Unit) :
    inner ℝ
      (canonicalGaussianMap L hKL (fun s:S => B s) (B (anchorQueryIndex S x i)))
      (canonicalGaussianMap L hKL (fun s:S => B s) (B (anchorQueryIndex S x j)))=
      ∫z,Real.tanh (fieldLinear (fun x k => B x k) z (anchorQueryIndex S x i))*
        Real.tanh (fieldLinear (fun x k => B x k) z (anchorQueryIndex S x j)) ∂L := by
  have hlin (v : EuclideanSpace ℝ I) (z : I → ℝ) :
      gaussianLinearForm v z=∑k,v k*z k := by
    simp only [gaussianLinearForm,PiLp.inner_apply,Real.inner_apply]
  cases j with
  | inl s =>
    simpa only [anchorQueryIndex,Sum.elim_inl,hlin,fieldLinear_apply] using
      canonicalGaussian_anchor_gram L hKL (fun s:S => B s) (B (anchorQueryIndex S x i)) s
  | inr u =>
    cases i with
    | inl s =>
      rw [real_inner_comm]
      have hh := canonicalGaussian_anchor_gram L hKL (fun s:S => B s) (B x) s
      simpa only [anchorQueryIndex,Sum.elim_inl,Sum.elim_inr,hlin,fieldLinear_apply,mul_comm] using hh
    | inr v =>
      rw [real_inner_self_eq_norm_sq]
      simpa only [anchorQueryIndex,Sum.elim_inr,hlin,fieldLinear_apply,pow_two] using
        canonicalGaussian_norm_sq L hKL (fun s:S => B s) (B x)

/-- A canonical program step retains exactly the replacement law's anchor /
one-query moments. It makes no statement about two nonanchor queries. -/
theorem CanonicalProgramStep.queryMoments {d H : ℕ}
    {f : NeuralGeneralization.ConcreteModel.BooleanFunction d}
    {P : ControlledMarginPath d H 1 f} {S : Finset (NeuralGeneralization.ConcreteModel.Cube d)}
    {j : ℕ} {B C : CanonicalProgramState d}
    (hstep : CanonicalProgramStep P S j B C)
    (x : NeuralGeneralization.ConcreteModel.Cube d) (i k : S ⊕ Unit) :
    inner ℝ (C.feature (anchorQueryIndex S x i)) (C.feature (anchorQueryIndex S x k))=
      ∫z,Real.tanh (z (anchorQueryIndex S x i))*Real.tanh (z (anchorQueryIndex S x k))
        ∂fieldAnchorReplacement (P.law j) (fieldLaw (fun x i => B.feature x i))
          (ConditionalAnalytic.maskCoordinates S) := by
  obtain ⟨L,hprob,hKL,hcost,hmap,hreplacement,e,he⟩ := hstep
  letI := hprob
  rw [he,he,e.inner_map_map,canonicalGaussian_anchor_query_moments]
  rw [← hreplacement]
  symm
  exact integral_map (fieldLinear _).continuous.measurable.aemeasurable (by fun_prop)

#print axioms CanonicalProgramStep.queryMoments
end ConditionalNonpolynomial.Analytic
