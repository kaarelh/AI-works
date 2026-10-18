import NeuralGeneralization.RobustGaussianGeometryActive
import NeuralGeneralization.RobustGaussianGeometryCovariance
import NeuralGeneralization.RobustCompressionClipping

/-! # The actual finite source bank of a zero-safe active Gaussian basis -/
noncomputable section
open MeasureTheory ProbabilityTheory InnerProductSpace Matrix WithLp
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.RobustGaussianGeometry
open RobustCompressionClipping
variable {N q : ℕ}

/-- Original activation vector in the layer's normalized Euclidean convention. -/
def normalizedFeature (h : Fin N → ℝ) : EuclideanSpace ℝ (Fin N) :=
  toLp 2 (fun i => h i / Real.sqrt (N : ℝ))

/-- A source row consists of all zero-safe active basis coordinates, multiplied
by sqrt(N). Its empirical covariance is therefore a contraction independent
of the original width. -/
def sourceRows (b : Fin q → EuclideanSpace ℝ (Fin N))
    (i : Fin N) : EuclideanSpace ℝ (Fin q) :=
  toLp 2 (fun j => Real.sqrt (N : ℝ) * gramSchmidtNormed ℝ b j i)

@[fun_prop] theorem measurable_normalizedFeature :
    Measurable (normalizedFeature (N := N)) := by
  unfold normalizedFeature
  exact (WithLp.measurable_toLp 2 (Fin N → ℝ)).comp (by fun_prop)

@[fun_prop] theorem measurable_sourceRows :
    Measurable (sourceRows (N := N) (q := q)) := by
  apply measurable_pi_lambda
  intro i
  unfold sourceRows
  apply (WithLp.measurable_toLp 2 (Fin q → ℝ)).comp
  apply measurable_pi_lambda
  intro j
  exact ((EuclideanSpace.proj i : EuclideanSpace ℝ (Fin N) →L[ℝ] ℝ).measurable.comp
    (measurable_gramSchmidtNormed j)).const_mul _

/-- Taking all zero-safe active coordinates is a Euclidean contraction. -/
theorem active_coordinates_quadratic_le
    (b : Fin q → EuclideanSpace ℝ (Fin N)) (v : Fin N → ℝ) :
    (∑ j, ((fun j i => gramSchmidtNormed ℝ b j i) *ᵥ v) j^2) ≤ ∑ i, v i^2 := by
  have hn := (Submodule.span ℝ (Set.range b)).norm_starProjection_apply_le (toLp 2 v)
  rw [← activeProjection_eq_starProjection] at hn
  have hs := (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mpr hn
  rw [← active_energy_eq_projection] at hs
  simpa [evaluations, Matrix.mulVec, dotProduct, EuclideanSpace.inner_eq_star_dotProduct,
    EuclideanSpace.real_norm_sq_eq, mul_comm] using hs

/-- Exact source-bank quadratic control, including dependent and zero active
columns. -/
theorem sourceRows_quadratic_le
    (b : Fin q → EuclideanSpace ℝ (Fin N)) (hN : 0 < N)
    (v : EuclideanSpace ℝ (Fin q)) :
    (∑ i, ⟪sourceRows b i, v⟫^2)/(N : ℝ) ≤ ‖v‖^2 := by
  let D : Matrix (Fin q) (Fin N) ℝ := fun j i => gramSchmidtNormed ℝ b j i
  have hD : ∀ z : Fin N → ℝ, ∑ j, (D *ᵥ z) j^2 ≤ ∑ i, z i^2 :=
    active_coordinates_quadratic_le b
  have ht := transpose_contraction D hD (ofLp v)
  have hinner (i : Fin N) : ⟪sourceRows b i,v⟫ =
      Real.sqrt (N : ℝ) * (D.transpose *ᵥ ofLp v) i := by
    simp [sourceRows, EuclideanSpace.inner_eq_star_dotProduct, Matrix.mulVec, dotProduct,
      D, Finset.mul_sum, mul_comm, mul_left_comm]
  simp_rw [hinner, mul_pow, Real.sq_sqrt (Nat.cast_nonneg N)]
  rw [← Finset.mul_sum, mul_div_cancel_left₀ _ (by exact_mod_cast (Nat.ne_of_gt hN))]
  simpa only [EuclideanSpace.real_norm_sq_eq] using ht

/-- The average squared source norm is at most the active slot count q,
not the original hidden width N. -/
theorem sourceRows_trace_le
    (b : Fin q → EuclideanSpace ℝ (Fin N)) (hN : 0 < N) :
    (∑ i, ‖sourceRows b i‖^2)/(N : ℝ) ≤ q := by
  have he (i : Fin N) : ‖sourceRows b i‖^2 =
      (N : ℝ) * ∑ j, (gramSchmidtNormed ℝ b j i)^2 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    simp only [sourceRows, ofLp_toLp, mul_pow, Real.sq_sqrt (Nat.cast_nonneg N), Finset.mul_sum]
  simp_rw [he]
  rw [← Finset.mul_sum, mul_div_cancel_left₀ _ (by exact_mod_cast (Nat.ne_of_gt hN)),
    Finset.sum_comm]
  calc
    (∑ j, ∑ i, (gramSchmidtNormed ℝ b j i)^2) = ∑ j, ‖gramSchmidtNormed ℝ b j‖^2 := by
      simp only [EuclideanSpace.real_norm_sq_eq]
    _ ≤ ∑ _j : Fin q, (1 : ℝ) := by
      apply Finset.sum_le_sum
      intro j hj
      rcases gramSchmidtNormed_norm_zero_or_one b j with hn | hn <;> simp [hn]
    _ = q := by simp

/-- Exact active-feature coordinate identity with all sqrt(N) factors. -/
theorem sourceRows_feature_coordinate
    (b : Fin q → EuclideanSpace ℝ (Fin N)) (h : Fin N → ℝ)
    (hN : 0 < N) (j : Fin q) :
    finiteAverage (fun i => h i • sourceRows b i) j =
      evaluations (gramSchmidtNormed ℝ b) (normalizedFeature h) j := by
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  have hs : Real.sqrt (N : ℝ) ≠ 0 := (Real.sqrt_pos.mpr hNR).ne'
  have hs2 : Real.sqrt (N : ℝ)^2 = (N : ℝ) := Real.sq_sqrt hNR.le
  have hsum : (∑ i, h i • sourceRows b i) j = ∑ i, h i * sourceRows b i j := by
    change (EuclideanSpace.proj j) (∑ i, h i • sourceRows b i) = _
    simp
  change (N : ℝ)⁻¹ * (∑ i, h i • sourceRows b i) j = _
  rw [hsum]
  unfold evaluations normalizedFeature
  simp only [sourceRows, ofLp_toLp,
    EuclideanSpace.inner_eq_star_dotProduct, dotProduct, star_trivial, Pi.star_apply]
  simp only [div_mul_eq_mul_div, ← Finset.sum_div]
  have he : (∑ i, h i * (Real.sqrt (N : ℝ) * gramSchmidtNormed ℝ b j i)) =
      Real.sqrt (N : ℝ) * ∑ i, h i * gramSchmidtNormed ℝ b j i := by
    simp only [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i hi
    ring
  rw [he]
  field_simp
  rw [hs2]

/-- The literal population source-feature vector is the active coordinate
vector of the normalized original activation. -/
theorem sourceRows_feature_eq
    (b : Fin q → EuclideanSpace ℝ (Fin N)) (h : Fin N → ℝ) (hN : 0 < N) :
    finiteAverage (fun i => h i • sourceRows b i) =
      toLp 2 (evaluations (gramSchmidtNormed ℝ b) (normalizedFeature h)) := by
  ext j
  exact sourceRows_feature_coordinate b h hN j

end NeuralGeneralization.RobustGaussianGeometry
