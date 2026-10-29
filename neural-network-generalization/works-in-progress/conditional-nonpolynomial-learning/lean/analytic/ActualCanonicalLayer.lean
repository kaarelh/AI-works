import ActualGaussianL2Layer

/-! A canonical finite-dimensional layer made from actual Gaussian-controlled
tanh features, including all anchor constraints and dimension bounds. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic

variable {I J : Type*} [Fintype I] [Fintype J]

def actualCanonicalSpan (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (anchors : J → EuclideanSpace ℝ I) : Submodule ℝ (Lp ℝ 2 Q) :=
  ConditionalAnalytic.canonicalFeatureSpan (coordinateL2 Q hKL) (fun j => actualTanhL2 Q (anchors j))

instance actualCanonicalSpan_finite (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (anchors : J → EuclideanSpace ℝ I) : FiniteDimensional ℝ (actualCanonicalSpan Q hKL anchors) :=
  ConditionalAnalytic.canonicalFeatureSpan_finite _ _

abbrev CanonicalIndex (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (anchors : J → EuclideanSpace ℝ I) :=
  Fin (Module.finrank ℝ (actualCanonicalSpan Q hKL anchors)) ⊕ Unit

def canonicalGaussianMap (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (anchors : J → EuclideanSpace ℝ I) (a : EuclideanSpace ℝ I) :
    EuclideanSpace ℝ (CanonicalIndex Q hKL anchors) :=
  ConditionalAnalytic.canonicalVector (actualCanonicalSpan Q hKL anchors) (actualTanhL2 Q a)

def canonicalGaussianLinear (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (anchors : J → EuclideanSpace ℝ I) :
    EuclideanSpace ℝ I →ₗ[ℝ] EuclideanSpace ℝ (CanonicalIndex Q hKL anchors) :=
  (ConditionalAnalytic.canonicalLinear (actualCanonicalSpan Q hKL anchors)).comp (linearL2Map Q hKL)

def canonicalGaussianResidual (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (anchors : J → EuclideanSpace ℝ I) (a : EuclideanSpace ℝ I) :
    EuclideanSpace ℝ (CanonicalIndex Q hKL anchors) :=
  canonicalGaussianMap Q hKL anchors a-canonicalGaussianLinear Q hKL anchors a

theorem canonicalGaussian_decomposition (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (anchors : J → EuclideanSpace ℝ I) (a : EuclideanSpace ℝ I) :
    canonicalGaussianMap Q hKL anchors a = canonicalGaussianLinear Q hKL anchors a+
      canonicalGaussianResidual Q hKL anchors a := by
  simp only [canonicalGaussianResidual, add_sub_cancel]

theorem actualCanonicalSpan_linear_mem (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (anchors : J → EuclideanSpace ℝ I) (a : EuclideanSpace ℝ I) :
    linearL2Map Q hKL a ∈ actualCanonicalSpan Q hKL anchors :=
  ConditionalAnalytic.linear_feature_mem _ _ (fun i => a i)

theorem canonicalGaussian_dimension (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (anchors : J → EuclideanSpace ℝ I) :
    Fintype.card (CanonicalIndex Q hKL anchors) ≤ Fintype.card I+Fintype.card J+1 := by
  change Fintype.card (Fin (Module.finrank ℝ (actualCanonicalSpan Q hKL anchors)) ⊕ Unit) ≤ _
  rw [Fintype.card_sum, Fintype.card_fin, Fintype.card_unique]
  exact ConditionalAnalytic.canonicalFeatureSpan_dimension (coordinateL2 Q hKL)
    (fun j => actualTanhL2 Q (anchors j))

theorem canonicalGaussian_norm_sq (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (anchors : J → EuclideanSpace ℝ I) (a : EuclideanSpace ℝ I) :
    ‖canonicalGaussianMap Q hKL anchors a‖^2 =
      ∫ z, (Real.tanh (gaussianLinearForm a z))^2 ∂Q := by
  rw [canonicalGaussianMap, ConditionalAnalytic.canonicalVector_norm_sq,
    ← real_inner_self_eq_norm_sq, L2.inner_def]
  apply integral_congr_ae
  filter_upwards [actualTanhL2_ae Q a] with z hz
  simp [hz, Real.inner_apply, pow_two]

theorem canonicalGaussianMap_zero (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (anchors : J → EuclideanSpace ℝ I) : canonicalGaussianMap Q hKL anchors 0 = 0 := by
  apply norm_eq_zero.mp
  apply sq_eq_zero_iff.mp
  rw [canonicalGaussian_norm_sq]
  simp [gaussianLinearForm]

theorem canonicalGaussianResidual_zero (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (anchors : J → EuclideanSpace ℝ I) : canonicalGaussianResidual Q hKL anchors 0 = 0 := by
  simp only [canonicalGaussianResidual, canonicalGaussianMap_zero, map_zero, sub_zero]

theorem canonicalGaussian_anchor_gram (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (anchors : J → EuclideanSpace ℝ I) (a : EuclideanSpace ℝ I) (j : J) :
    ⟪canonicalGaussianMap Q hKL anchors a,canonicalGaussianMap Q hKL anchors (anchors j)⟫ =
      ∫ z, Real.tanh (gaussianLinearForm a z)*Real.tanh (gaussianLinearForm (anchors j) z) ∂Q := by
  change ⟪ConditionalAnalytic.canonicalVector _ _,ConditionalAnalytic.canonicalVector _ _⟫ = _
  change ⟪ConditionalAnalytic.canonicalVector
      (ConditionalAnalytic.canonicalFeatureSpan (coordinateL2 Q hKL) (fun j => actualTanhL2 Q (anchors j)))
      (actualTanhL2 Q a), ConditionalAnalytic.canonicalVector
      (ConditionalAnalytic.canonicalFeatureSpan (coordinateL2 Q hKL) (fun j => actualTanhL2 Q (anchors j)))
      (actualTanhL2 Q (anchors j))⟫ = _
  rw [ConditionalAnalytic.canonical_anchor_data (coordinateL2 Q hKL)
    (fun j => actualTanhL2 Q (anchors j)) (actualTanhL2 Q a) j, L2.inner_def]
  apply integral_congr_ae
  filter_upwards [actualTanhL2_ae Q a, actualTanhL2_ae Q (anchors j)] with z ha hj
  simp only [ha, hj, Real.inner_apply]

theorem canonicalGaussianLinear_norm (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (anchors : J → EuclideanSpace ℝ I) (a : EuclideanSpace ℝ I) :
    ‖canonicalGaussianLinear Q hKL anchors a‖ = ‖linearL2Map Q hKL a‖ := by
  let V := actualCanonicalSpan Q hKL anchors
  have hzero : ConditionalAnalytic.canonicalVector V (0 : Lp ℝ 2 Q) = 0 := by
    apply norm_eq_zero.mp
    rw [ConditionalAnalytic.canonicalVector_norm, norm_zero]
  have heq := ConditionalAnalytic.canonicalVector_add_mem V 0 (linearL2Map Q hKL a)
    (actualCanonicalSpan_linear_mem Q hKL anchors a)
  rw [zero_add, hzero, zero_add] at heq
  change ‖ConditionalAnalytic.canonicalLinear V (linearL2Map Q hKL a)‖ = _
  rw [← heq, ConditionalAnalytic.canonicalVector_norm]

theorem canonicalGaussianLinear_norm_le (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (anchors : J → EuclideanSpace ℝ I) (a : EuclideanSpace ℝ I) :
    ‖canonicalGaussianLinear Q hKL anchors a‖ ≤
      (1+Real.sqrt (2*(klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal))*‖a‖ := by
  rw [canonicalGaussianLinear_norm]
  exact linearL2Map_norm_le Q hKL a

theorem canonicalGaussianResidual_ball_lipschitz
    (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (anchors : J → EuclideanSpace ℝ I)
    (s : ℝ) (hs : 0 < s) (a b : EuclideanSpace ℝ I)
    (ha : ‖a‖ ≤ s) (hb : ‖b‖ ≤ s) :
    ‖canonicalGaussianResidual Q hKL anchors a-canonicalGaussianResidual Q hKL anchors b‖ ≤
      112*(s^2+Real.sqrt ((klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal))*‖a-b‖ := by
  have h := ConditionalAnalytic.canonicalVector_residual_distance (actualCanonicalSpan Q hKL anchors)
    (actualTanhL2 Q a) (actualTanhL2 Q b) (linearL2Map Q hKL a) (linearL2Map Q hKL b)
    (actualCanonicalSpan_linear_mem Q hKL anchors a) (actualCanonicalSpan_linear_mem Q hKL anchors b)
  exact h.trans (actualResidualL2_ball_lipschitz Q hKL s hs a b ha hb)

#print axioms canonicalGaussianLinear_norm_le
#print axioms canonicalGaussianResidual_ball_lipschitz
#print axioms canonicalGaussian_anchor_gram
#print axioms canonicalGaussian_dimension
end ConditionalNonpolynomial.Analytic
