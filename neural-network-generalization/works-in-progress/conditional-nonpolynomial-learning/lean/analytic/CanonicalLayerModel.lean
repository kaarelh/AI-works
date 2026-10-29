import CanonicalCompression
import RadialResidualExtension

noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianAngularFields

variable {I J A : Type*} [Fintype I] [Fintype J] [Fintype A]

/-- Concrete analytic data behind one canonical layer, retaining the law and
isometry needed by the separate finite evaluator. -/
structure CanonicalLayerModel (anchors : A → EuclideanSpace ℝ I) (D : ℝ) where
  law : Measure (I → ℝ)
  [probability : IsProbabilityMeasure law]
  finiteKL : klDiv law (standardLaw I)≠∞
  cost_le : (klDiv law (standardLaw I)).toReal≤D
  output : EuclideanSpace ℝ (CanonicalIndex law finiteKL anchors) →ₗᵢ[ℝ] EuclideanSpace ℝ J

attribute [instance] CanonicalLayerModel.probability

namespace CanonicalLayerModel
variable {anchors : A → EuclideanSpace ℝ I} {D : ℝ}

def value (M : CanonicalLayerModel (J:=J) anchors D) (u : EuclideanSpace ℝ I) : EuclideanSpace ℝ J :=
  M.output (canonicalGaussianMap M.law M.finiteKL anchors u)

def linearMap (M : CanonicalLayerModel (J:=J) anchors D) :
    EuclideanSpace ℝ I →ₗ[ℝ] EuclideanSpace ℝ J :=
  M.output.toLinearMap.comp (canonicalGaussianLinear M.law M.finiteKL anchors)

lemma linearMap_bound (M : CanonicalLayerModel (J:=J) anchors D) (u : EuclideanSpace ℝ I) :
    ‖M.linearMap u‖≤(1+Real.sqrt (2*D))*‖u‖ := by
  change ‖M.output (canonicalGaussianLinear M.law M.finiteKL anchors u)‖≤_
  rw [M.output.norm_map]
  apply (canonicalGaussianLinear_norm_le M.law M.finiteKL anchors u).trans
  exact mul_le_mul_of_nonneg_right
    (add_le_add le_rfl (Real.sqrt_le_sqrt (mul_le_mul_of_nonneg_left M.cost_le (by norm_num))))
    (norm_nonneg _)

def linear (M : CanonicalLayerModel (J:=J) anchors D) :
    EuclideanSpace ℝ I →L[ℝ] EuclideanSpace ℝ J :=
  M.linearMap.mkContinuous (1+Real.sqrt (2*D)) M.linearMap_bound

lemma linear_norm_le (M : CanonicalLayerModel (J:=J) anchors D) :
    ‖M.linear‖≤1+Real.sqrt (2*D) :=
  M.linear.opNorm_le_bound (by positivity) M.linearMap_bound

def residual (M : CanonicalLayerModel (J:=J) anchors D) (u : EuclideanSpace ℝ I) : EuclideanSpace ℝ J :=
  M.output (canonicalGaussianResidual M.law M.finiteKL anchors u)

lemma decomposition (M : CanonicalLayerModel (J:=J) anchors D) (u : EuclideanSpace ℝ I) :
    M.value u=M.linear u+M.residual u := by
  change M.output (canonicalGaussianMap M.law M.finiteKL anchors u)=
    M.output (canonicalGaussianLinear M.law M.finiteKL anchors u)+
      M.output (canonicalGaussianResidual M.law M.finiteKL anchors u)
  rw [canonicalGaussian_decomposition,M.output.map_add]

lemma residual_zero (M : CanonicalLayerModel (J:=J) anchors D) : M.residual 0=0 := by
  simp only [residual,canonicalGaussianResidual_zero,map_zero]

lemma residual_ball_lipschitz (M : CanonicalLayerModel (J:=J) anchors D)
    {s : ℝ} (hs : 0<s) (u v : EuclideanSpace ℝ I) (hu : ‖u‖≤s) (hv : ‖v‖≤s) :
    ‖M.residual u-M.residual v‖≤112*(s^2+Real.sqrt D)*‖u-v‖ := by
  change ‖M.output _-M.output _‖≤_
  rw [← M.output.map_sub,M.output.norm_map]
  apply (canonicalGaussianResidual_ball_lipschitz M.law M.finiteKL anchors s hs u v hu hv).trans
  have hsq := Real.sqrt_le_sqrt M.cost_le
  exact mul_le_mul_of_nonneg_right
    (mul_le_mul_of_nonneg_left (add_le_add le_rfl hsq) (by norm_num)) (norm_nonneg _)

def clippedResidual (M : CanonicalLayerModel (J:=J) anchors D) (s : ℝ) (u : EuclideanSpace ℝ I) :
    EuclideanSpace ℝ J := M.residual (radialClip s u)

lemma clippedResidual_zero (M : CanonicalLayerModel (J:=J) anchors D) (s : ℝ) :
    M.clippedResidual s 0=0 := by simp [clippedResidual,radialClip_zero,M.residual_zero]

lemma clippedResidual_lipschitz (M : CanonicalLayerModel (J:=J) anchors D)
    {s : ℝ} (hs : 0<s) (u v : EuclideanSpace ℝ I) :
    ‖M.clippedResidual s u-M.clippedResidual s v‖≤224*(s^2+Real.sqrt D)*‖u-v‖ := by
  have hh := radial_residual_lipschitz M.residual hs
    (show 0≤112*(s^2+Real.sqrt D) by positivity) (fun u v hu hv => M.residual_ball_lipschitz hs u v hu hv) u v
  have he : (2:ℝ)*(112*(s^2+Real.sqrt D))=224*(s^2+Real.sqrt D) := by ring
  simpa only [he,clippedResidual] using hh

lemma clippedResidual_range (M : CanonicalLayerModel (J:=J) anchors D)
    {s : ℝ} (hs : 0<s) (u : EuclideanSpace ℝ I) :
    ‖M.clippedResidual s u‖≤112*(s^2+Real.sqrt D)*s :=
  radial_residual_range M.residual hs (by positivity) M.residual_zero
    (fun u v hu hv => M.residual_ball_lipschitz hs u v hu hv) u

lemma decomposition_on_ball (M : CanonicalLayerModel (J:=J) anchors D)
    {s : ℝ} (hs : 0<s) (u : EuclideanSpace ℝ I) (hu : ‖u‖≤s) :
    M.value u=M.linear u+M.clippedResidual s u := by
  rw [clippedResidual,radialClip_eq_self hs hu]
  exact M.decomposition u
end CanonicalLayerModel

theorem CanonicalProgramStep.layerModel {d H : ℕ}
    {f : NeuralGeneralization.ConcreteModel.BooleanFunction d}
    {P : ControlledMarginPath d H 1 f} {S : Finset (NeuralGeneralization.ConcreteModel.Cube d)}
    {j : ℕ} {B C : CanonicalProgramState d}
    (hstep : CanonicalProgramStep P S j B C) :
    ∃M : CanonicalLayerModel (J:=C.Index) (fun s:S => B.feature s) (criticalLayerCost P j),
      ∀x,C.feature x=M.value (B.feature x) := by
  obtain ⟨L,hprob,hKL,hcost,hmap,hreplacement,e,he⟩ := hstep
  letI := hprob
  have hc : scaledFeatureCoefficients 1 (P.feature j)=(fun x i => P.feature j x i) := by
    funext x i
    exact one_mul _
  rw [hc] at hcost
  exact ⟨{law := L, probability := hprob, finiteKL := hKL, cost_le := hcost, output := e},he⟩

#print axioms CanonicalProgramStep.layerModel
#print axioms CanonicalLayerModel.clippedResidual_lipschitz
end ConditionalNonpolynomial.Analytic
