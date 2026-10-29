import GaussianWhiteningOperator
import IsotropicCanonicalLayer

/-! Non-Gaussian residual bounds for the original canonical map. Whitening is
used only inside exact L² integrals; the output coordinates, anchor span, and
canonical state are not replaced or enlarged. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
variable {I J : Type*} [Fintype I] [DecidableEq I] [Fintype J]

lemma whitened_law_finiteKL (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    klDiv (Q.map (gaussianWhiten Q)) (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞ := by
  rw [whitening_kl_identity Q hKL]
  exact (gaussian_full_moment_entropy_decomposition Q hKL).1

lemma whitened_law_reconstruction (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    (Q.map (gaussianWhiten Q)).map (gaussianUnwhiten Q)=Q := by
  rw [Measure.map_map (gaussianUnwhiten_measurable Q) (gaussianWhiten_measurable Q),
    gaussianUnwhiten_whiten Q hKL,Measure.map_id]

lemma actualResidualL2_whitened_norm (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (a b : EuclideanSpace ℝ I) :
    letI : IsProbabilityMeasure (Q.map (gaussianWhiten Q)) :=
    Measure.isProbabilityMeasure_map (gaussianWhiten_measurable Q).aemeasurable
    ‖actualResidualL2 Q hKL a-actualResidualL2 Q hKL b‖=
      ‖actualResidualL2 (Q.map (gaussianWhiten Q)) (whitened_law_finiteKL Q hKL)
        (gaussianFeaturePreconditioner Q a)-
        actualResidualL2 (Q.map (gaussianWhiten Q)) (whitened_law_finiteKL Q hKL)
        (gaussianFeaturePreconditioner Q b)‖ := by
  letI : IsProbabilityMeasure (Q.map (gaussianWhiten Q)) :=
    Measure.isProbabilityMeasure_map (gaussianWhiten_measurable Q).aemeasurable
  apply (sq_eq_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
  rw [actualResidualL2_distance_sq,actualResidualL2_distance_sq]
  conv_lhs => rw [←whitened_law_reconstruction Q hKL]
  rw [integral_map (gaussianUnwhiten_measurable Q).aemeasurable (by
    unfold tanhResidualFeature tanhRemainder gaussianLinearForm; fun_prop)]
  apply integral_congr_ae
  exact Filter.Eventually.of_forall fun z=>by
    simp only [tanhResidualFeature,gaussianLinearForm_unwhiten]

lemma linearL2Map_whitened_norm (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (a : EuclideanSpace ℝ I) :
    ‖linearL2Map Q hKL a‖=‖gaussianFeaturePreconditioner Q a‖ := by
  let W := Q.map (gaussianWhiten Q)
  letI : IsProbabilityMeasure W := Measure.isProbabilityMeasure_map (gaussianWhiten_measurable Q).aemeasurable
  have hn : ‖linearL2Map W (whitened_law_finiteKL Q hKL) (gaussianFeaturePreconditioner Q a)‖=
      ‖gaussianFeaturePreconditioner Q a‖ :=
    linearL2Map_norm_isotropic W (whitened_law_finiteKL Q hKL) (whitened_secondMomentMatrix Q hKL) _
  rw [←hn]
  apply (sq_eq_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
  rw [linearL2Map_norm_sq,linearL2Map_norm_sq]
  conv_lhs => rw [←whitened_law_reconstruction Q hKL]
  rw [integral_map (gaussianUnwhiten_measurable Q).aemeasurable (by
    unfold gaussianLinearForm; fun_prop)]
  apply integral_congr_ae
  exact Filter.Eventually.of_forall fun z=>by dsimp only; rw [gaussianLinearForm_unwhiten]

/-- Original L² residual, charged to its actual non-Gaussian divergence. -/
theorem actualResidualL2_nongaussian_ball (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    {g s : ℝ} (hg0 : 0<g) (hs : 0<s)
    (hg : ‖gaussianFeaturePreconditioner Q‖≤g)
    (a b : EuclideanSpace ℝ I) (ha : ‖a‖≤s) (hb : ‖b‖≤s) :
    ‖actualResidualL2 Q hKL a-actualResidualL2 Q hKL b‖≤
      112*g*(g^2*s^2+Real.sqrt ((klDiv Q (matchingGaussian Q)).toReal))*‖a-b‖ := by
  let W := Q.map (gaussianWhiten Q)
  letI : IsProbabilityMeasure W := Measure.isProbabilityMeasure_map (gaussianWhiten_measurable Q).aemeasurable
  have hnorm (u : EuclideanSpace ℝ I) : ‖gaussianFeaturePreconditioner Q u‖≤g*‖u‖ :=
    ((gaussianFeaturePreconditioner Q).le_opNorm u).trans (mul_le_mul_of_nonneg_right hg (norm_nonneg _))
  have ha' := (hnorm a).trans (mul_le_mul_of_nonneg_left ha hg0.le)
  have hb' := (hnorm b).trans (mul_le_mul_of_nonneg_left hb hg0.le)
  have hd : ‖gaussianFeaturePreconditioner Q a-gaussianFeaturePreconditioner Q b‖≤g*‖a-b‖ := by
    rw [←map_sub]; exact hnorm (a-b)
  rw [actualResidualL2_whitened_norm Q hKL a b]
  have hh := actualResidualL2_ball_lipschitz W (whitened_law_finiteKL Q hKL)
    (g*s) (mul_pos hg0 hs) _ _ ha' hb'
  have hw : klDiv W (Measure.pi fun _ : I=>gaussianReal 0 1)=klDiv Q (matchingGaussian Q) :=
    whitening_kl_identity Q hKL
  rw [hw] at hh
  apply hh.trans
  calc
    _ ≤112*((g*s)^2+Real.sqrt ((klDiv Q (matchingGaussian Q)).toReal))*(g*‖a-b‖) :=
      mul_le_mul_of_nonneg_left hd (by positivity)
    _ =_ := by ring

/-- The already constructed canonical output coordinates obey the sharper
residual estimate; no second canonical construction or isometry is needed. -/
theorem canonicalGaussianResidual_nongaussian_ball
    (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (anchors : J→EuclideanSpace ℝ I)
    {g s : ℝ} (hg0 : 0<g) (hs : 0<s)
    (hg : ‖gaussianFeaturePreconditioner Q‖≤g)
    (a b : EuclideanSpace ℝ I) (ha : ‖a‖≤s) (hb : ‖b‖≤s) :
    ‖canonicalGaussianResidual Q hKL anchors a-canonicalGaussianResidual Q hKL anchors b‖≤
      112*g*(g^2*s^2+Real.sqrt ((klDiv Q (matchingGaussian Q)).toReal))*‖a-b‖ := by
  have hh := ConditionalAnalytic.canonicalVector_residual_distance (actualCanonicalSpan Q hKL anchors)
    (actualTanhL2 Q a) (actualTanhL2 Q b) (linearL2Map Q hKL a) (linearL2Map Q hKL b)
    (actualCanonicalSpan_linear_mem Q hKL anchors a) (actualCanonicalSpan_linear_mem Q hKL anchors b)
  exact hh.trans (actualResidualL2_nongaussian_ball Q hKL hg0 hs hg a b ha hb)

#print axioms canonicalGaussianResidual_nongaussian_ball
#print axioms linearL2Map_whitened_norm
end ConditionalNonpolynomial.Analytic
