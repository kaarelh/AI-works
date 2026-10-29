import PhysicalRawLayerBounds

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
variable {I J A : Type*} [Fintype I] [Fintype J] [Fintype A]
namespace CanonicalLayerModel
variable {anchors : A→EuclideanSpace ℝ I} {D : ℝ}

lemma scaled_clippedResidual_lipschitz (M : CanonicalLayerModel (J:=J) anchors D)
    {t s : ℝ} (ht : 0<t) (ht1 : t≤1) (hs : 0<s) (u v : EuclideanSpace ℝ I) :
    ‖M.clippedResidual (t*s) (t • u)-M.clippedResidual (t*s) (t • v)‖≤
      224*(s^2+Real.sqrt D)*‖u-v‖ := by
  have hh := M.clippedResidual_lipschitz (mul_pos ht hs) (t • u) (t • v)
  rw [←smul_sub,norm_smul,Real.norm_eq_abs,abs_of_pos ht] at hh
  have hts : (t*s)^2≤s^2 := pow_le_pow_left₀ (mul_nonneg ht.le hs.le)
    (mul_le_of_le_one_left hs.le ht1) 2
  have hb : 224*((t*s)^2+Real.sqrt D)≤224*(s^2+Real.sqrt D) := by linarith
  have hn : t*‖u-v‖≤‖u-v‖ := mul_le_of_le_one_left (norm_nonneg _) ht1
  exact hh.trans (mul_le_mul hb hn (mul_nonneg ht.le (norm_nonneg _)) (by positivity))

lemma scaled_clippedResidual_range (M : CanonicalLayerModel (J:=J) anchors D)
    {t s : ℝ} (ht : 0<t) (ht1 : t≤1) (hs : 0<s) (u : EuclideanSpace ℝ I) :
    ‖M.clippedResidual (t*s) (t • u)‖≤112*(s^2+Real.sqrt D)*s := by
  have hh := M.clippedResidual_range (mul_pos ht hs) (t • u)
  have hts : t*s≤s := mul_le_of_le_one_left hs.le ht1
  have hsq : (t*s)^2≤s^2 := pow_le_pow_left₀ (mul_nonneg ht.le hs.le) hts 2
  exact hh.trans (mul_le_mul (by linarith : 112*((t*s)^2+Real.sqrt D)≤112*(s^2+Real.sqrt D))
    hts (mul_nonneg ht.le hs.le) (by positivity))

lemma scaled_decomposition_on_ball (M : CanonicalLayerModel (J:=J) anchors D)
    {t s : ℝ} (ht : 0<t) (hs : 0<s) (u : EuclideanSpace ℝ I) (hu : ‖u‖≤s) :
    M.value (t • u)=(t • M.linear) u+M.clippedResidual (t*s) (t • u) := by
  have hn : ‖t • u‖≤t*s := by
    rw [norm_smul,Real.norm_eq_abs,abs_of_pos ht]
    exact mul_le_mul_of_nonneg_left hu ht.le
  simpa only [ContinuousLinearMap.smul_apply,map_smul] using
    M.decomposition_on_ball (mul_pos ht hs) (t • u) hn

lemma input_scaled_clippedResidual_lipschitz (M : CanonicalLayerModel (J:=J) anchors D)
    {t s : ℝ} (ht : 0<t) (ht1 : t≤1) (hs : 0<s) (u v : EuclideanSpace ℝ I) :
    ‖M.clippedResidual s (t • u)-M.clippedResidual s (t • v)‖≤
      224*(s^2+Real.sqrt D)*‖u-v‖ := by
  have hh := M.clippedResidual_lipschitz hs (t • u) (t • v)
  rw [←smul_sub,norm_smul,Real.norm_eq_abs,abs_of_pos ht] at hh
  exact hh.trans (mul_le_mul_of_nonneg_left
    (mul_le_of_le_one_left (norm_nonneg _) ht1) (by positivity))

lemma input_scaled_clippedResidual_range (M : CanonicalLayerModel (J:=J) anchors D)
    {t s : ℝ} (hs : 0<s) (u : EuclideanSpace ℝ I) :
    ‖M.clippedResidual s (t • u)‖≤112*(s^2+Real.sqrt D)*s :=
  M.clippedResidual_range hs _

lemma input_scaled_decomposition_on_ball (M : CanonicalLayerModel (J:=J) anchors D)
    {t s : ℝ} (ht : 0<t) (ht1 : t≤1) (hs : 0<s) (u : EuclideanSpace ℝ I) (hu : ‖u‖≤s) :
    M.value (t • u)=(t • M.linear) u+M.clippedResidual s (t • u) := by
  have hn : ‖t • u‖≤s := by
    rw [norm_smul,Real.norm_eq_abs,abs_of_pos ht]
    exact (mul_le_of_le_one_left (norm_nonneg _) ht1).trans hu
  simpa only [ContinuousLinearMap.smul_apply,map_smul] using M.decomposition_on_ball hs (t • u) hn

end CanonicalLayerModel
#print axioms CanonicalLayerModel.scaled_clippedResidual_lipschitz
end ConditionalNonpolynomial.Analytic
