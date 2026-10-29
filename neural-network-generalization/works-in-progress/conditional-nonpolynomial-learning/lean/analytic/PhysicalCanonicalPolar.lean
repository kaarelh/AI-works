import CanonicalGaussianPolar
import GaussianCovarianceCost
import PhysicalCanonicalLayerModel

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch

lemma frobeniusSq_comp_linearIsometry {E F G : Type*}
    [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]
    [NormedAddCommGroup F] [InnerProductSpace ℝ F] [FiniteDimensional ℝ F]
    [NormedAddCommGroup G] [InnerProductSpace ℝ G] [FiniteDimensional ℝ G]
    (A : E→ₗ[ℝ] F) (U : F→ₗᵢ[ℝ] G) :
    frobeniusSq (U.toLinearMap.comp A)=frobeniusSq A := by
  rw [frobeniusSq_eq_sum_norm_sq _ (stdOrthonormalBasis ℝ E),
    frobeniusSq_eq_sum_norm_sq _ (stdOrthonormalBasis ℝ E)]
  simp only [LinearMap.comp_apply,LinearIsometry.coe_toLinearMap,U.norm_map]

namespace CanonicalLayerModel
variable {I J K : Type*} [Fintype I] [DecidableEq I] [Fintype J] [Fintype K]
variable {anchors : K→EuclideanSpace ℝ I} {D : ℝ}

/-- The actual physical linear part admits one polar isometry, with its
Hilbert--Schmidt error paid only by its own Gaussian covariance entropy. -/
theorem physical_entropy_polar (M : CanonicalLayerModel (J:=J) anchors D) :
    ∃U : EuclideanSpace ℝ I→ₗᵢ[ℝ] EuclideanSpace ℝ J,
      ∀t:ℝ,frobeniusSq (t • M.linear.toLinearMap-t • U.toLinearMap)≤
        2*t^2*gaussianCovarianceCost M.law := by
  obtain ⟨U,hU⟩ := canonicalGaussianLinear_entropy_polar M.law M.finiteKL anchors
    (C:=gaussianCovarianceCost M.law) le_rfl
  refine ⟨M.output.comp U,?_⟩
  intro t
  have he : t • M.linear.toLinearMap-t • (M.output.comp U).toLinearMap=
      M.output.toLinearMap.comp (t • canonicalGaussianLinear M.law M.finiteKL anchors-t • U.toLinearMap) := by
    ext1 x
    change t • M.output (canonicalGaussianLinear M.law M.finiteKL anchors x)-t • M.output (U x)=
      M.output (t • canonicalGaussianLinear M.law M.finiteKL anchors x-t • U x)
    rw [map_sub,map_smul,map_smul]
  rw [he,frobeniusSq_comp_linearIsometry]
  exact hU t

end CanonicalLayerModel
#print axioms CanonicalLayerModel.physical_entropy_polar
end ConditionalNonpolynomial.Analytic
