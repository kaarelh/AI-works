import PhysicalCanonicalLayerModel

/-! Normalization by actual entropy gains makes the linear dynamics
contractive. Small physical scales cancel exactly, including in the residual
Lipschitz bound, so no inverse scale is charged to Picard resources. -/
noncomputable section
set_option maxHeartbeats 2200000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
variable {I J A : Type*} [Fintype I] [DecidableEq I] [Fintype J] [Fintype A]
namespace CanonicalLayerModel
variable {anchors : A→EuclideanSpace ℝ I} {D : ℝ}

lemma entropyRoot_one_le (D : ℝ) : 1≤Real.sqrt (gaussianEntropyGain D) := by
  simpa using Real.sqrt_le_sqrt (gaussianEntropyGain_one_le D)
lemma entropyRoot_pos (D : ℝ) : 0<Real.sqrt (gaussianEntropyGain D) :=
  zero_lt_one.trans_le (entropyRoot_one_le D)

lemma linear_sharp_bound (M : CanonicalLayerModel (J:=J) anchors D)
    (u : EuclideanSpace ℝ I) : ‖M.linear u‖≤Real.sqrt (gaussianEntropyGain D)*‖u‖ := by
  change ‖M.output (canonicalGaussianLinear M.law M.finiteKL anchors u)‖≤_
  rw [M.output.norm_map,canonicalGaussianLinear_norm]
  apply (linearL2Map_sharp_gain M.law M.finiteKL u).trans
  exact mul_le_mul_of_nonneg_right
    (Real.sqrt_le_sqrt (gaussianEntropyGain_mono ENNReal.toReal_nonneg M.cost_le)) (norm_nonneg _)

lemma preconditioner_sharp_bound (M : CanonicalLayerModel (J:=J) anchors D) :
    ‖gaussianFeaturePreconditioner M.law‖≤Real.sqrt (gaussianEntropyGain D) := by
  apply ContinuousLinearMap.opNorm_le_bound _ (Real.sqrt_nonneg _)
  intro u
  rw [←M.linear_norm_preconditioner]
  exact M.linear_sharp_bound u

def gainLinear (M : CanonicalLayerModel (J:=J) anchors D) :
    EuclideanSpace ℝ I→L[ℝ] EuclideanSpace ℝ J :=
  (Real.sqrt (gaussianEntropyGain D))⁻¹ • M.linear

def gainValue (M : CanonicalLayerModel (J:=J) anchors D) (S : ℝ) (u : EuclideanSpace ℝ I) :
    EuclideanSpace ℝ J := (S*Real.sqrt (gaussianEntropyGain D))⁻¹ • M.value (S • u)

def gainResidual (M : CanonicalLayerModel (J:=J) anchors D) (S : ℝ) (u : EuclideanSpace ℝ I) :
    EuclideanSpace ℝ J := (S*Real.sqrt (gaussianEntropyGain D))⁻¹ • M.residual (S • u)

lemma gainLinear_contraction (M : CanonicalLayerModel (J:=J) anchors D)
    (u : EuclideanSpace ℝ I) : ‖M.gainLinear u‖≤‖u‖ := by
  simp only [gainLinear,ContinuousLinearMap.smul_apply,norm_smul,Real.norm_eq_abs,
    abs_inv,abs_of_pos (entropyRoot_pos D)]
  have hh := mul_le_mul_of_nonneg_left (M.linear_sharp_bound u) (inv_nonneg.mpr (entropyRoot_pos D).le)
  simpa [←mul_assoc,(entropyRoot_pos D).ne'] using hh

lemma gainValue_lipschitz (M : CanonicalLayerModel (J:=J) anchors D)
    {S : ℝ} (hS : 0<S) (u v : EuclideanSpace ℝ I) :
    ‖M.gainValue S u-M.gainValue S v‖≤‖u-v‖ := by
  have hh := M.physical_value_lipschitz hS.le M.preconditioner_sharp_bound u v
  simp only [gainValue,←smul_sub,norm_smul,Real.norm_eq_abs,abs_inv,
    abs_of_pos (mul_pos hS (entropyRoot_pos D))]
  have hm := mul_le_mul_of_nonneg_left hh (inv_nonneg.mpr (mul_pos hS (entropyRoot_pos D)).le)
  simpa only [←mul_assoc,inv_mul_cancel₀ (mul_pos hS (entropyRoot_pos D)).ne',one_mul] using hm

lemma gainValue_zero (M : CanonicalLayerModel (J:=J) anchors D) (S : ℝ) :
    M.gainValue S 0=0 := by
  simp [gainValue,value,canonicalGaussianMap_zero]

lemma gainResidual_zero (M : CanonicalLayerModel (J:=J) anchors D) (S : ℝ) :
    M.gainResidual S 0=0 := by simp [gainResidual,M.residual_zero]

lemma gain_decomposition (M : CanonicalLayerModel (J:=J) anchors D)
    {S : ℝ} (hS : S≠0) (u : EuclideanSpace ℝ I) :
    M.gainValue S u=M.gainLinear u+M.gainResidual S u := by
  simp only [gainValue,gainResidual,M.decomposition,map_smul,smul_add,smul_smul,
    gainLinear,ContinuousLinearMap.smul_apply]
  have he : (S*Real.sqrt (gaussianEntropyGain D))⁻¹*S=(Real.sqrt (gaussianEntropyGain D))⁻¹ := by
    field_simp
  rw [he]

lemma gainResidual_ball (M : CanonicalLayerModel (J:=J) anchors D)
    {S r : ℝ} (hS : 0<S) (hr : 0<r)
    (u v : EuclideanSpace ℝ I) (hu : ‖u‖≤r) (hv : ‖v‖≤r) :
    ‖M.gainResidual S u-M.gainResidual S v‖≤112*((S*r)^2+Real.sqrt D)*‖u-v‖ := by
  have hSu : ‖S • u‖≤S*r := by
    rw [norm_smul,Real.norm_eq_abs,abs_of_pos hS]
    exact mul_le_mul_of_nonneg_left hu hS.le
  have hSv : ‖S • v‖≤S*r := by
    rw [norm_smul,Real.norm_eq_abs,abs_of_pos hS]
    exact mul_le_mul_of_nonneg_left hv hS.le
  have hh := M.residual_ball_lipschitz (mul_pos hS hr) (S • u) (S • v) hSu hSv
  rw [←smul_sub,norm_smul,Real.norm_eq_abs,abs_of_pos hS] at hh
  simp only [gainResidual,←smul_sub,norm_smul,Real.norm_eq_abs,abs_inv,
    abs_of_pos (mul_pos hS (entropyRoot_pos D))]
  have hm := mul_le_mul_of_nonneg_left hh (inv_nonneg.mpr (mul_pos hS (entropyRoot_pos D)).le)
  have he : (S*Real.sqrt (gaussianEntropyGain D))⁻¹*
      (112*((S*r)^2+Real.sqrt D)*(S*‖u-v‖))=
      (Real.sqrt (gaussianEntropyGain D))⁻¹*(112*((S*r)^2+Real.sqrt D)*‖u-v‖) := by
    field_simp
  rw [he] at hm
  apply hm.trans
  apply mul_le_of_le_one_left (by positivity)
  exact (inv_le_one₀ (entropyRoot_pos D)).mpr (entropyRoot_one_le D)

lemma gainResidual_clipped (M : CanonicalLayerModel (J:=J) anchors D)
    {S r : ℝ} (hS : 0<S) (hr : 0<r) (u v : EuclideanSpace ℝ I) :
    ‖M.gainResidual S (radialClip r u)-M.gainResidual S (radialClip r v)‖≤
      224*((S*r)^2+Real.sqrt D)*‖u-v‖ := by
  have hh := radial_residual_lipschitz (M.gainResidual S) hr
    (show 0≤112*((S*r)^2+Real.sqrt D) by positivity)
    (fun u v hu hv=>M.gainResidual_ball hS hr u v hu hv) u v
  convert hh using 1 <;> ring

end CanonicalLayerModel
#print axioms CanonicalLayerModel.gainResidual_clipped
#print axioms CanonicalLayerModel.gainLinear_contraction
#print axioms CanonicalLayerModel.gainValue_lipschitz
end ConditionalNonpolynomial.Analytic
