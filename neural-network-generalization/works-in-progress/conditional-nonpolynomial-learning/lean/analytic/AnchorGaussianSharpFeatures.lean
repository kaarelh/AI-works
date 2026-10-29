import AnchorGaussianFeatures
import SharpGaussianFeatureGain
import ScalarPhysicalGain

/-! Sharp actual Gaussian gain for canonical anchor/query transport. -/
noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.FiniteDifferential
open NeuralGeneralization.GaussianAngularFields NeuralGeneralization.GaussianFieldTilt
variable {X I : Type*} [Fintype X] [DecidableEq X] [Fintype I]

theorem tanhL2Feature_eq_actualTanhL2 (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (A : X → EuclideanSpace ℝ I) (x : X) :
    tanhL2Feature Q (fun x i => A x i) x=actualTanhL2 Q (A x) := by
  apply Lp.ext
  filter_upwards [boundedL2Feature_ae Q (fun z => Real.tanh (fieldLinear (fun x i => A x i) z x))
    (by fun_prop) (fun _ => (Real.abs_tanh_lt_one _).le), actualTanhL2_ae Q (A x)] with z hz hz'
  change tanhL2Feature Q (fun x i => A x i) x z=_
  rw [hz',show tanhL2Feature Q (fun x i => A x i) x z=
    Real.tanh (fieldLinear (fun x i => A x i) z x) from hz]
  simp only [fieldLinear_apply,gaussianLinearForm,PiLp.inner_apply,Real.inner_apply]

theorem anchor_gaussian_feature_coupling_sharp
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
      ‖U x-V x‖≤Real.sqrt (gaussianEntropyGain ((klDiv Q (fieldLaw (fun x i => A x i))).toReal))*ε := by
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
    change ‖tanhL2Feature L (fun x i => A x i) x-tanhL2Feature L (fun x i => B x i) x‖≤_
    rw [tanhL2Feature_eq_actualTanhL2,tanhL2Feature_eq_actualTanhL2]
    have hh := actualTanhL2_sharp_gain L hfinite (A x) (B x)
    have hc := Real.sqrt_le_sqrt (gaussianEntropyGain_mono ENNReal.toReal_nonneg hcost)
    exact hh.trans (mul_le_mul hc hclose (norm_nonneg _) (Real.sqrt_nonneg _))

#print axioms anchor_gaussian_feature_coupling_sharp
end ConditionalNonpolynomial.Analytic
