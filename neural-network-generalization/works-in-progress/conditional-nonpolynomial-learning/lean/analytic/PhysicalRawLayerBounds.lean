import PhysicalCanonicalLayerModel

/-! The critical raw-entropy layer estimates remain valid, with the same
constants, for every physical coefficient scale between zero and one. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
variable {I J A : Type*} [Fintype I] [Fintype J] [Fintype A]
namespace CanonicalLayerModel
variable {anchors : A→EuclideanSpace ℝ I} {D : ℝ}

lemma physical_linear_raw_bound (M : CanonicalLayerModel (J:=J) anchors D)
    {t : ℝ} (ht : 0≤t) (ht1 : t≤1) (u : EuclideanSpace ℝ I) :
    ‖M.linear (t • u)‖≤(1+Real.sqrt (2*D))*‖u‖ := by
  have hh := M.linearMap_bound (t • u)
  rw [norm_smul,Real.norm_eq_abs,abs_of_nonneg ht] at hh
  exact hh.trans (mul_le_mul_of_nonneg_left
    (mul_le_of_le_one_left (norm_nonneg _) ht1) (by positivity))

lemma physical_residual_raw_ball (M : CanonicalLayerModel (J:=J) anchors D)
    {t s : ℝ} (ht : 0≤t) (ht1 : t≤1) (hs : 0<s)
    (u v : EuclideanSpace ℝ I) (hu : ‖u‖≤s) (hv : ‖v‖≤s) :
    ‖M.residual (t • u)-M.residual (t • v)‖≤112*(s^2+Real.sqrt D)*‖u-v‖ := by
  have hnorm (z : EuclideanSpace ℝ I) : ‖t • z‖≤‖z‖ := by
    rw [norm_smul,Real.norm_eq_abs,abs_of_nonneg ht]
    exact mul_le_of_le_one_left (norm_nonneg _) ht1
  have hh := M.residual_ball_lipschitz hs (t • u) (t • v) ((hnorm u).trans hu) ((hnorm v).trans hv)
  rw [←smul_sub] at hh
  exact hh.trans (mul_le_mul_of_nonneg_left (hnorm (u-v)) (by positivity))

lemma physical_residual_raw_clipped (M : CanonicalLayerModel (J:=J) anchors D)
    {t s : ℝ} (ht : 0≤t) (ht1 : t≤1) (hs : 0<s)
    (u v : EuclideanSpace ℝ I) :
    ‖M.residual (t • radialClip s u)-M.residual (t • radialClip s v)‖≤
      224*(s^2+Real.sqrt D)*‖u-v‖ := by
  have hh := radial_residual_lipschitz (fun w=>M.residual (t • w)) hs
    (show 0≤112*(s^2+Real.sqrt D) by positivity)
    (fun u v hu hv=>M.physical_residual_raw_ball ht ht1 hs u v hu hv) u v
  convert hh using 1 <;> ring

lemma physical_residual_raw_clipped_range (M : CanonicalLayerModel (J:=J) anchors D)
    {t s : ℝ} (ht : 0≤t) (ht1 : t≤1) (hs : 0<s) (u : EuclideanSpace ℝ I) :
    ‖M.residual (t • radialClip s u)‖≤112*(s^2+Real.sqrt D)*s := by
  apply radial_residual_range (fun w=>M.residual (t • w)) hs (by positivity)
  · simp [M.residual_zero]
  · intro u v hu hv
    exact M.physical_residual_raw_ball ht ht1 hs u v hu hv

lemma physical_raw_decomposition_on_ball (M : CanonicalLayerModel (J:=J) anchors D)
    {t s : ℝ} (hs : 0<s) (u : EuclideanSpace ℝ I) (hu : ‖u‖≤s) :
    M.value (t • u)=M.linear (t • u)+M.residual (t • radialClip s u) := by
  rw [radialClip_eq_self hs hu]
  exact M.decomposition _

end CanonicalLayerModel
#print axioms CanonicalLayerModel.physical_residual_raw_clipped
end ConditionalNonpolynomial.Analytic
