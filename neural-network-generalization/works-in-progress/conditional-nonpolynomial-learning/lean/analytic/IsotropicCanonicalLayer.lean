import CanonicalLayerModel
import GaussianMomentMatrix
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianAngularFields
variable {I J A K : Type*} [Fintype I] [DecidableEq I] [Fintype J] [Fintype A] [Fintype K]

lemma linearL2Map_norm_isotropic (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (standardLaw I)≠∞) (hM : secondMomentMatrix Q=1)
    (u : EuclideanSpace ℝ I) : ‖linearL2Map Q hKL u‖=‖u‖ := by
  have hsq : ‖linearL2Map Q hKL u‖^2=‖u‖^2 := by
    rw [linearL2Map_norm_sq]
    have hform (z : I→ℝ) : gaussianLinearForm u z=(WithLp.ofLp u) ⬝ᵥ z := by
      simp only [gaussianLinearForm,PiLp.inner_apply,Real.inner_apply,WithLp.ofLp_toLp,dotProduct]
    simp_rw [hform]
    rw [gaussian_integral_dotProduct_sq Q hKL,hM,Matrix.one_mulVec]
    rw [PiLp.norm_sq_eq_of_L2]
    simp only [dotProduct,Real.norm_eq_abs,←pow_two,sq_abs]
  nlinarith [norm_nonneg (linearL2Map Q hKL u),norm_nonneg u]

namespace CanonicalLayerModel
variable {anchors : A→EuclideanSpace ℝ I} {D : ℝ}

lemma linear_norm_isotropic (M : CanonicalLayerModel (J:=J) anchors D)
    (hM : secondMomentMatrix M.law=1) (u : EuclideanSpace ℝ I) :
    ‖M.linear u‖=‖u‖ := by
  change ‖M.output (canonicalGaussianLinear M.law M.finiteKL anchors u)‖=‖u‖
  rw [M.output.norm_map,canonicalGaussianLinear_norm]
  exact linearL2Map_norm_isotropic M.law M.finiteKL hM u

lemma preconditioned_linear_bound (M : CanonicalLayerModel (J:=J) anchors D)
    (hM : secondMomentMatrix M.law=1)
    (A : EuclideanSpace ℝ K→L[ℝ] EuclideanSpace ℝ I)
    {g : ℝ} (hg : ‖A‖≤g) (u : EuclideanSpace ℝ K) :
    ‖M.linear (A u)‖≤g*‖u‖ := by
  rw [M.linear_norm_isotropic hM]
  exact (A.le_opNorm u).trans (mul_le_mul_of_nonneg_right hg (norm_nonneg _))

/-- After whitening, the residual is charged only to the non-Gaussian
entropy D. The physical covariance scale enters through g, not through the
possibly much larger relative entropy to the original prior. -/
theorem preconditioned_residual_ball (M : CanonicalLayerModel (J:=J) anchors D)
    (A : EuclideanSpace ℝ K→L[ℝ] EuclideanSpace ℝ I)
    {g s : ℝ} (hg0 : 0<g) (hs : 0<s) (hg : ‖A‖≤g)
    (u v : EuclideanSpace ℝ K) (hu : ‖u‖≤s) (hv : ‖v‖≤s) :
    ‖M.residual (A u)-M.residual (A v)‖≤112*g*(g^2*s^2+Real.sqrt D)*‖u-v‖ := by
  have hnorm (w : EuclideanSpace ℝ K) : ‖A w‖≤g*‖w‖ :=
    (A.le_opNorm w).trans (mul_le_mul_of_nonneg_right hg (norm_nonneg _))
  have hu' : ‖A u‖≤g*s := (hnorm u).trans (mul_le_mul_of_nonneg_left hu hg0.le)
  have hv' : ‖A v‖≤g*s := (hnorm v).trans (mul_le_mul_of_nonneg_left hv hg0.le)
  have hdiff : ‖A u-A v‖≤g*‖u-v‖ := by rw [←A.map_sub]; exact hnorm (u-v)
  have hh := M.residual_ball_lipschitz (mul_pos hg0 hs) (A u) (A v) hu' hv'
  calc
    _ ≤ 112*((g*s)^2+Real.sqrt D)*‖A u-A v‖ := hh
    _ ≤ 112*((g*s)^2+Real.sqrt D)*(g*‖u-v‖) :=
      mul_le_mul_of_nonneg_left hdiff (by positivity)
    _ = _ := by ring

theorem preconditioned_residual_clipped (M : CanonicalLayerModel (J:=J) anchors D)
    (A : EuclideanSpace ℝ K→L[ℝ] EuclideanSpace ℝ I)
    {g s : ℝ} (hg0 : 0<g) (hs : 0<s) (hg : ‖A‖≤g)
    (u v : EuclideanSpace ℝ K) :
    ‖M.residual (A (radialClip s u))-M.residual (A (radialClip s v))‖≤
      224*g*(g^2*s^2+Real.sqrt D)*‖u-v‖ := by
  have hh := radial_residual_lipschitz (fun w=>M.residual (A w)) hs
    (show 0≤112*g*(g^2*s^2+Real.sqrt D) by positivity)
    (fun u v hu hv=>M.preconditioned_residual_ball A hg0 hs hg u v hu hv) u v
  convert hh using 1 <;> ring

end CanonicalLayerModel
#print axioms linearL2Map_norm_isotropic
#print axioms CanonicalLayerModel.preconditioned_residual_clipped
end ConditionalNonpolynomial.Analytic
