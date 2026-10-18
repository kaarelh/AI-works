import NeuralGeneralization.RobustCompressionReconstruction
import NeuralGeneralization.RobustCompressionActiveFeature
import NeuralGeneralization.RobustGaussianGeometryScalar

/-! # Exact normalization of the actual finite reconstruction coefficients -/
noncomputable section
open MeasureTheory ProbabilityTheory Matrix
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.RobustCompressionReconstruction
open RobustCompressionClipping RobustCompressionRows RobustCompressionActiveFeature
open RobustGaussianGeometry
variable {N m q : ℕ}

/-- Each normalized sampled-matrix contraction is literally the corresponding
coordinate of the sampled active feature. -/
theorem sampledMatrix_active_coordinate
    (u : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    (h : Fin N → ℝ) {a T : ℝ} (ha : 0 ≤ a) (hm : 0 < m) (k : Fin q) :
    (∑ j, sampledMatrix u I a T j k * h (I j)) / Real.sqrt (m : ℝ) =
      sampledActive (fun i => wholeClip T (u i)) I h a k := by
  have hmR : (0 : ℝ) < m := by exact_mod_cast hm
  have haR : 0 < 1+a := by positivity
  have hsm : Real.sqrt (m : ℝ) ≠ 0 := (Real.sqrt_pos.mpr hmR).ne'
  have hsa : Real.sqrt (1+a) ≠ 0 := (Real.sqrt_pos.mpr haR).ne'
  have hs2 : Real.sqrt (m : ℝ)^2 = (m : ℝ) := Real.sq_sqrt hmR.le
  have hsum : (∑ j, h (I j) • wholeClip T (u (I j))) k =
      ∑ j, h (I j) * wholeClip T (u (I j)) k := by
    change (EuclideanSpace.proj k) (∑ j, h (I j) • wholeClip T (u (I j))) = _
    simp
  unfold sampledMatrix sampledActive finiteAverage
  simp only [PiLp.smul_apply, smul_eq_mul, hsum]
  rw [Real.sqrt_mul hmR.le]
  simp only [div_mul_eq_mul_div, ← Finset.sum_div]
  have he : (∑ j, wholeClip T (u (I j)) k * h (I j)) =
      ∑ j, h (I j) * wholeClip T (u (I j)) k := by
    apply Finset.sum_congr rfl
    intro j hj
    ring
  rw [he]
  field_simp
  rw [hs2]

/-- The active term subtracted from the residual variance is precisely the
squared Euclidean norm used in the paper. -/
theorem sampledMatrix_active_energy
    (u : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    (h : Fin N → ℝ) {a T : ℝ} (ha : 0 ≤ a) (hm : 0 < m) :
    (∑ k, ((∑ j, sampledMatrix u I a T j k * h (I j)) / Real.sqrt (m : ℝ))^2) =
      ‖sampledActive (fun i => wholeClip T (u i)) I h a‖^2 := by
  simp_rw [sampledMatrix_active_coordinate u I h ha hm]
  exact (EuclideanSpace.real_norm_sq_eq _).symm

/-- The actual sampled coefficient matrix is a contraction on the concrete
entrywise good-Gram event. -/
theorem sampledMatrix_contraction
    (u : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    {a T : ℝ} (ha : 0 ≤ a) (hm : 0 < m)
    (hu : ∀ v : EuclideanSpace ℝ (Fin q),
      (∑ i, ⟪u i, v⟫^2) / (N : ℝ) ≤ ‖v‖^2)
    (hgram : ∀ j k,
      |(∑ i, wholeClip T (u (I i)) j * wholeClip T (u (I i)) k) / (m : ℝ) -
        (∑ i, wholeClip T (u i) j * wholeClip T (u i) k) / (N : ℝ)| ≤
      a / ((q : ℝ)+1)) :
    ∀ v : Fin q → ℝ,
      ∑ i, (Matrix.of (sampledMatrix u I a T) *ᵥ v) i^2 ≤ ∑ j, v j^2 := by
  apply normalized_sample_contraction (fun i j => wholeClip T (u (I i)) j) hm ha
  intro v
  have hq := sampled_quadratic_of_good_gram u I ha hu hgram (WithLp.toLp 2 v)
  have he := gram_quadratic_eq (fun i => wholeClip T (u (I i))) (WithLp.toLp 2 v)
  simpa only [WithLp.ofLp_toLp, EuclideanSpace.real_norm_sq_eq] using he.trans_le hq

/-- The literal residual variance is nonnegative; it is not rescued by
NNReal truncation in the Gaussian-law statement. -/
theorem sampledMatrix_residual_variance_nonneg
    (u : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    (h : Fin N → ℝ) {a T : ℝ} (ha : 0 ≤ a) (hm : 0 < m)
    (hD : ∀ v : Fin q → ℝ,
      ∑ i, (Matrix.of (sampledMatrix u I a T) *ᵥ v) i^2 ≤ ∑ j, v j^2) :
    0 ≤ (∑ j, h (I j)^2)/(m : ℝ) -
      ‖sampledActive (fun i => wholeClip T (u i)) I h a‖^2 := by
  have ht := transpose_contraction (Matrix.of (sampledMatrix u I a T)) hD (fun j => h (I j))
  have ht' : (∑ k, (∑ j, sampledMatrix u I a T j k * h (I j))^2) ≤
      ∑ j, h (I j)^2 := by
    simpa only [Matrix.mulVec, dotProduct, Matrix.transpose_apply, Matrix.of_apply] using ht
  rw [← sampledMatrix_active_energy u I h ha hm]
  simp_rw [div_pow, Real.sq_sqrt (Nat.cast_nonneg m), ← Finset.sum_div]
  exact sub_nonneg.mpr (div_le_div_of_nonneg_right ht' (Nat.cast_nonneg m))

/-- The exact scalar residual law expressed using the literal empirical
kernel diagonal and sampled active feature. -/
theorem sampledMatrix_residual_scalar_law
    (u : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    (h : Fin N → ℝ) (t : ℝ) {a T : ℝ} (ha : 0 ≤ a) (hm : 0 < m)
    (hD : ∀ v : Fin q → ℝ,
      ∑ i, (Matrix.of (sampledMatrix u I a T) *ᵥ v) i^2 ≤ ∑ j, v j^2) :
    (sourceResidualKernel (sampledMatrix u I a T)).map
      (fun z => (t / Real.sqrt (m : ℝ)) * ∑ j, h (I j) * z j) =
      gaussianReal 0 (t^2 * ((∑ j, h (I j)^2) / (m : ℝ) -
        ‖sampledActive (fun i => wholeClip T (u i)) I h a‖^2)).toNNReal := by
  rw [sourceResidualKernel_scaled_scalar_law _ hD _ t hm,
    sampledMatrix_active_energy u I h ha hm]

end NeuralGeneralization.RobustCompressionReconstruction
