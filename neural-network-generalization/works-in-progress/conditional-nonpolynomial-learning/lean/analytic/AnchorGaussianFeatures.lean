import AnchorGaussianCoupling
import ControlledL2Features
import CanonicalAnchorStep

noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.FiniteDifferential
open NeuralGeneralization.GaussianAngularFields NeuralGeneralization.GaussianFieldTilt

variable {X I : Type*} [Fintype X] [DecidableEq X] [Fintype I]

lemma tanhL2Feature_moment_of_field_map
    (L : Measure (I → ℝ)) [IsProbabilityMeasure L] (A : X → I → ℝ)
    (R : Measure (X → ℝ)) (hmap : L.map (fieldLinear A)=R) (x y : X) :
    inner ℝ (tanhL2Feature L A x) (tanhL2Feature L A y)=
      ∫z,Real.tanh (z x)*Real.tanh (z y) ∂R := by
  rw [tanhL2Feature_inner,← hmap]
  symm
  exact integral_map (fieldLinear A).continuous.measurable.aemeasurable (by fun_prop)

/-- Transfer one query between two anchor-aligned Gaussian references. The
result is a genuine coupling of their anchor-only controlled feature laws. -/
theorem anchor_gaussian_feature_coupling
    (A B : X → EuclideanSpace ℝ I) (Q : Measure (X → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (fieldLaw (fun x i => A x i))≠∞) (S : Finset X)
    (hanchor : ∀x∈S,A x=B x) (x : X) {ε : ℝ} (hε : 0≤ε)
    (hclose : ‖A x-B x‖≤ε) :
    ∃U V : X → EuclideanSpace ℝ (X ⊕ X),
      (∀i j,inner ℝ (U i) (U j)=
        ∫z,Real.tanh (z i)*Real.tanh (z j)
          ∂fieldAnchorReplacement Q (fieldLaw (fun x i => A x i)) (maskCoordinates S)) ∧
      (∀i j,inner ℝ (V i) (V j)=
        ∫z,Real.tanh (z i)*Real.tanh (z j)
          ∂fieldAnchorReplacement Q (fieldLaw (fun x i => B x i)) (maskCoordinates S)) ∧
      (∀s∈S,U s=V s) ∧
      ‖U x-V x‖≤(1+Real.sqrt (2*(klDiv Q (fieldLaw (fun x i => A x i))).toReal))*ε := by
  obtain ⟨L,hprob,hfinite,hcost,hleft,hright,herror⟩ :=
    anchor_gaussian_dimension_free_coupling_pointwise
      (fun x i => A x i) (fun x i => B x i) Q hKL S (by
        intro y hy
        funext i
        rw [hanchor y hy])
  letI := hprob
  let u := tanhL2Feature L (fun x i => A x i)
  let v := tanhL2Feature L (fun x i => B x i)
  obtain ⟨U,V,hU,hV,hUV,hdist⟩ := compress_feature_pair u v
  refine ⟨U,V,?_,?_,?_,?_⟩
  · intro i j
    rw [hU]
    exact tanhL2Feature_moment_of_field_map L _ _ hleft i j
  · intro i j
    rw [hV]
    exact tanhL2Feature_moment_of_field_map L _ _ hright i j
  · intro s hs
    apply sub_eq_zero.mp
    apply norm_eq_zero.mp
    rw [hdist]
    have he : u s=v s := by
      dsimp [u,v,tanhL2Feature]
      simp only [fieldLinear_apply,hanchor s hs]
    rw [he,sub_self,norm_zero]
  · rw [hdist]
    apply (sq_le_sq₀ (norm_nonneg _) (by positivity)).mp
    rw [tanhL2Feature_norm_sub_sq,mul_pow]
    apply herror x ε
    have hs := (sq_le_sq₀ (norm_nonneg _) hε).mpr hclose
    rw [EuclideanSpace.norm_sq_eq] at hs
    simpa only [PiLp.sub_apply,Real.norm_eq_abs,sq_abs] using hs

#print axioms anchor_gaussian_feature_coupling
end ConditionalNonpolynomial.Analytic
