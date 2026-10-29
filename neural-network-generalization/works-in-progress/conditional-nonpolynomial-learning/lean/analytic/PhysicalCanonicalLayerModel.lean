import GaussianWhitenedResidual
import PhysicalNormalizedCompression
import SharpGaussianFeatureGain

/-! The literal physical canonical layer and its matched-Gaussian estimates.
All bounds concern the same finite-dimensional states used in compression. -/
noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel
variable {I J A : Type*} [Fintype I] [DecidableEq I] [Fintype J] [Fintype A]

lemma actualTanhL2_le_linearL2 (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (a b : EuclideanSpace ℝ I) :
    ‖actualTanhL2 Q a-actualTanhL2 Q b‖≤‖linearL2Map Q hKL (a-b)‖ := by
  apply Lp.norm_le_norm_of_ae_le
  filter_upwards [Lp.coeFn_sub (actualTanhL2 Q a) (actualTanhL2 Q b),
    actualTanhL2_ae Q a,actualTanhL2_ae Q b,linearL2Map_ae Q hKL (a-b)] with z hs ha hb hl
  have ht := tanh_lipschitzWith.dist_le_mul (gaussianLinearForm a z) (gaussianLinearForm b z)
  simp only [Real.dist_eq,NNReal.coe_one,one_mul] at ht
  simpa only [hs,Pi.sub_apply,ha,hb,hl,Real.norm_eq_abs,gaussianLinearForm,inner_sub_left] using ht

namespace CanonicalLayerModel
variable {anchors : A→EuclideanSpace ℝ I} {D : ℝ}

def nongaussianCost (M : CanonicalLayerModel (J:=J) anchors D) : ℝ :=
  (klDiv M.law (matchingGaussian M.law)).toReal

lemma linear_norm_preconditioner (M : CanonicalLayerModel (J:=J) anchors D)
    (u : EuclideanSpace ℝ I) : ‖M.linear u‖=‖gaussianFeaturePreconditioner M.law u‖ := by
  change ‖M.output (canonicalGaussianLinear M.law M.finiteKL anchors u)‖=_
  rw [M.output.norm_map,canonicalGaussianLinear_norm,linearL2Map_whitened_norm]

lemma value_lipschitz_preconditioner (M : CanonicalLayerModel (J:=J) anchors D)
    {g : ℝ} (hg : ‖gaussianFeaturePreconditioner M.law‖≤g)
    (u v : EuclideanSpace ℝ I) : ‖M.value u-M.value v‖≤g*‖u-v‖ := by
  change ‖M.output _-M.output _‖≤_
  rw [←M.output.map_sub,M.output.norm_map]
  have hh := ConditionalAnalytic.canonicalVector_distance (actualCanonicalSpan M.law M.finiteKL anchors)
    (actualTanhL2 M.law u) (actualTanhL2 M.law v)
  apply hh.trans
  apply (actualTanhL2_le_linearL2 M.law M.finiteKL u v).trans
  rw [linearL2Map_whitened_norm]
  exact ((gaussianFeaturePreconditioner M.law).le_opNorm (u-v)).trans
    (mul_le_mul_of_nonneg_right hg (norm_nonneg _))

lemma physical_linear_bound (M : CanonicalLayerModel (J:=J) anchors D)
    {t g : ℝ} (ht : 0≤t) (hg : ‖gaussianFeaturePreconditioner M.law‖≤g)
    (u : EuclideanSpace ℝ I) : ‖M.linear (t • u)‖≤(t*g)*‖u‖ := by
  rw [M.linear_norm_preconditioner,map_smul,norm_smul,Real.norm_eq_abs,abs_of_nonneg ht]
  have hh := ((gaussianFeaturePreconditioner M.law).le_opNorm u).trans
    (mul_le_mul_of_nonneg_right hg (norm_nonneg _))
  nlinarith [mul_le_mul_of_nonneg_left hh ht]

lemma physical_value_lipschitz (M : CanonicalLayerModel (J:=J) anchors D)
    {t g : ℝ} (ht : 0≤t) (hg : ‖gaussianFeaturePreconditioner M.law‖≤g)
    (u v : EuclideanSpace ℝ I) : ‖M.value (t • u)-M.value (t • v)‖≤(t*g)*‖u-v‖ := by
  have hh := M.value_lipschitz_preconditioner hg (t • u) (t • v)
  rw [←smul_sub,norm_smul,Real.norm_eq_abs,abs_of_nonneg ht] at hh
  convert hh using 1 <;> ring

lemma physical_residual_ball (M : CanonicalLayerModel (J:=J) anchors D)
    {t g s : ℝ} (ht : 0<t) (hg0 : 0<g) (hs : 0<s)
    (hg : ‖gaussianFeaturePreconditioner M.law‖≤g)
    (u v : EuclideanSpace ℝ I) (hu : ‖u‖≤s) (hv : ‖v‖≤s) :
    ‖M.residual (t • u)-M.residual (t • v)‖≤
      (t*g)*(112*((t*g)^2*s^2+Real.sqrt M.nongaussianCost))*‖u-v‖ := by
  have htu : ‖t • u‖≤t*s := by
    rw [norm_smul,Real.norm_eq_abs,abs_of_pos ht]
    exact mul_le_mul_of_nonneg_left hu ht.le
  have htv : ‖t • v‖≤t*s := by
    rw [norm_smul,Real.norm_eq_abs,abs_of_pos ht]
    exact mul_le_mul_of_nonneg_left hv ht.le
  change ‖M.output _-M.output _‖≤_
  rw [←M.output.map_sub,M.output.norm_map]
  have hh := canonicalGaussianResidual_nongaussian_ball M.law M.finiteKL anchors hg0 (mul_pos ht hs)
    hg (t • u) (t • v) htu htv
  rw [←smul_sub,norm_smul,Real.norm_eq_abs,abs_of_pos ht] at hh
  convert hh using 1 <;> unfold nongaussianCost <;> ring
end CanonicalLayerModel

theorem PhysicalCanonicalProgramStep.layerModel {d H : ℕ} {t : ℝ}
    {f : BooleanFunction d} {P : ControlledMarginPath d H t f} {S : Finset (Cube d)}
    {j : ℕ} {B C : CanonicalProgramState d}
    (hstep : PhysicalCanonicalProgramStep P S j B C) :
    ∃M : CanonicalLayerModel (J:=C.Index) (fun s:S=>t • B.feature s) (physicalLayerCost P j),
      ∀x,C.feature x=M.value (t • B.feature x) := by
  obtain ⟨L,hprob,hKL,hcost,hmap,hreplacement,e,he⟩ := hstep
  letI := hprob
  exact ⟨{law:=L,probability:=hprob,finiteKL:=hKL,cost_le:=hcost,output:=e},he⟩

#print axioms CanonicalLayerModel.physical_residual_ball
#print axioms PhysicalCanonicalProgramStep.layerModel
end ConditionalNonpolynomial.Analytic
