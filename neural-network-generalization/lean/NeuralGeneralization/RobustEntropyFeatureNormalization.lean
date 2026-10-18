import NeuralGeneralization.RobustEntropyProjectionCoordinates
import NeuralGeneralization.RobustGaussianGeometrySourceBank

/-! # Exact physical normalization of the selected Gaussian source features -/
noncomputable section
open MeasureTheory ProbabilityTheory InnerProductSpace
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.RobustEntropy
open RobustGaussianGeometry RobustCompressionClipping
variable {N q : ℕ}
local notation "E" => EuclideanSpace ℝ (Fin N)

theorem normalizedFeature_norm_sq (h : Fin N → ℝ) :
    ‖normalizedFeature h‖^2 = (∑ i, h i^2)/(N : ℝ) := by
  rw [EuclideanSpace.real_norm_sq_eq]
  change (∑ i, (h i / Real.sqrt (N : ℝ))^2) = _
  simp only [div_pow,Real.sq_sqrt (Nat.cast_nonneg N)]
  exact (Finset.sum_div _ _ _).symm

theorem normalizedFeature_norm_le_one (h : Fin N → ℝ) (hN : 0 < N)
    (hh : ∀ i, |h i| ≤ 1) : ‖normalizedFeature h‖ ≤ 1 := by
  have hNR : (0:ℝ) < N := by exact_mod_cast hN
  have hs : (∑ i, h i^2) ≤ (N : ℝ) := by
    have hp (i : Fin N) : h i^2 ≤ 1 := by nlinarith [abs_le.mp (hh i)]
    simpa using Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hp i)
  have hsq : ‖normalizedFeature h‖^2 ≤ 1 := by
    rw [normalizedFeature_norm_sq]
    exact (div_le_one hNR).mpr hs
  nlinarith [norm_nonneg (normalizedFeature h)]

theorem sourceRows_feature_eq_coordinates (b : Fin q → E) (h : Fin N → ℝ) (hN : 0 < N) :
    finiteAverage (fun i => h i • sourceRows b i) = activeCoordinateVector b (normalizedFeature h) :=
  sourceRows_feature_eq b h hN

/-- The residual variance is exactly the difference of the empirical kernel
diagonal and the active feature energy, including dependent query vectors. -/
theorem source_feature_residual_variance (b : Fin q → E) (h : Fin N → ℝ) (hN : 0 < N) :
    ‖queryResidual b (normalizedFeature h)‖^2 =
      (∑ i, h i^2)/(N : ℝ)-‖finiteAverage (fun i => h i • sourceRows b i)‖^2 := by
  rw [sourceRows_feature_eq_coordinates b h hN,queryResidual_norm_sq,normalizedFeature_norm_sq]

theorem source_feature_residual_norm_le_one (b : Fin q → E) (h : Fin N → ℝ)
    (hN : 0 < N) (hh : ∀ i, |h i| ≤ 1) :
    ‖queryResidual b (normalizedFeature h)‖ ≤ 1 :=
  (queryResidual_norm_le b _).trans (normalizedFeature_norm_le_one h hN hh)

/-- Exact preactivation bridge to the literal source-bank means used by the
Gaussian layer comparison. No approximation or law identity is assumed. -/
theorem source_feature_preactivation (b : Fin q → E) (h : Fin N → ℝ)
    (hN : 0 < N) (g : E) (t : ℝ) :
    t*⟪normalizedFeature h,g⟫ =
      ⟪t • activeCoordinateVector b g,finiteAverage (fun i => h i • sourceRows b i)⟫+
      t*‖queryResidual b (normalizedFeature h)‖*
        ⟪normalizedQueryResidual b (normalizedFeature h),g⟫ := by
  rw [sourceRows_feature_eq_coordinates b h hN]
  exact scaled_query_decomposition b _ g t

/-- The square root of the literal ideal Gaussian variance is t times the
actual normalized residual length, including the zero-variance branch. -/
theorem sqrt_source_feature_variance (b : Fin q → E) (h : Fin N → ℝ)
    (hN : 0 < N) {t : ℝ} (ht : 0 ≤ t) :
    Real.sqrt (t^2*((∑ i, h i^2)/(N : ℝ)-
      ‖finiteAverage (fun i => h i • sourceRows b i)‖^2)) =
        t*‖queryResidual b (normalizedFeature h)‖ := by
  rw [←source_feature_residual_variance b h hN,←mul_pow,
    Real.sqrt_sq (mul_nonneg ht (norm_nonneg _))]

/-- Compact padding and the full selected-input family induce exactly the
same residual. This prevents a hidden dependence on the whole input set. -/
theorem queryResidual_eq_of_span_eq {m : ℕ} (b : Fin q → E) (c : Fin m → E)
    (hs : Submodule.span ℝ (Set.range b) = Submodule.span ℝ (Set.range c)) (x : E) :
    queryResidual b x = queryResidual c x := by
  unfold queryResidual
  simp only [activeProjection_eq_starProjection,hs]

end NeuralGeneralization.RobustEntropy
