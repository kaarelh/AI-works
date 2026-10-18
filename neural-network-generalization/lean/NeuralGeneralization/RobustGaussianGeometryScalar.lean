import NeuralGeneralization.RobustGaussianGeometryCovariance
import NeuralGeneralization.RobustGaussianGeometry

/-! # Exact scalar laws for the reconstructed residual Gaussian kernel -/
noncomputable section
open MeasureTheory ProbabilityTheory Matrix WithLp
open scoped BigOperators RealInnerProductSpace MatrixOrder
namespace NeuralGeneralization.RobustGaussianGeometry
variable {m q : ℕ}

/-- Any linear functional of the actual centered multivariate Gaussian is the
one-dimensional Gaussian with its actual quadratic covariance. -/
theorem multivariateGaussian_map_inner (Q : Matrix (Fin m) (Fin m) ℝ)
    (hQ : Q.PosSemidef) (h : EuclideanSpace ℝ (Fin m)) :
    (multivariateGaussian 0 Q).map (fun z => ⟪h, z⟫) =
      gaussianReal 0 (h ⬝ᵥ (Q *ᵥ h)).toNNReal := by
  have hg : HasGaussianLaw (fun z : EuclideanSpace ℝ (Fin m) => ⟪h, z⟫)
      (multivariateGaussian 0 Q) :=
    IsGaussian.hasGaussianLaw_id.map_fun (innerSL ℝ h)
  rw [hg.map_eq_gaussianReal]
  congr 1
  · have hh := (innerSL ℝ h).integral_comp_comm
      (IsGaussian.integrable_id (μ := multivariateGaussian (0 : EuclideanSpace ℝ (Fin m)) Q))
    simpa using hh
  · congr 1
    rw [← covariance_self, ← covarianceBilin_apply_eq_cov IsGaussian.memLp_two_id,
      covarianceBilin_multivariateGaussian hQ]
    fun_prop

/-- The unscaled scalar source residual has exactly the covariance quadratic
form, including its possibly degenerate zero-variance case. -/
theorem residualKernel_scalar_law (Q : Fin m → Fin m → ℝ)
    (hQ : (Matrix.of Q).PosSemidef) (h : Fin m → ℝ) :
    (residualKernel Q).map (fun z => ∑ j, h j * z j) =
      gaussianReal 0 (h ⬝ᵥ (Matrix.of Q *ᵥ h)).toNNReal := by
  have hmap := multivariateGaussian_map_inner (Matrix.of Q) hQ (toLp 2 h)
  rw [← residualKernel_toLp Q,
    Measure.map_map (by fun_prop) (WithLp.measurable_toLp 2 (Fin m → ℝ))] at hmap
  convert hmap using 1
  congr 1
  funext z
  simp [Function.comp_apply, EuclideanSpace.inner_eq_star_dotProduct, dotProduct, mul_comm]

/-- Variance before the scalar normalization, written as total energy minus
its contracted active-coordinate energy. -/
def sourceResidualVariance (D : Fin m → Fin q → ℝ) (h : Fin m → ℝ) : ℝ :=
  (∑ j, h j ^ 2) - ∑ k, (∑ j, D j k * h j)^2

theorem sourceResidualVariance_eq (D : Fin m → Fin q → ℝ) (h : Fin m → ℝ) :
    sourceResidualVariance D h = h ⬝ᵥ (Matrix.of (residualCovariance D) *ᵥ h) := by
  rw [residualCovariance_eq]
  simp only [Matrix.sub_mulVec, Matrix.one_mulVec, dotProduct_sub]
  have heq : h ⬝ᵥ ((Matrix.of D * (Matrix.of D).transpose) *ᵥ h) =
      ∑ k, (∑ j, D j k * h j)^2 := by
    rw [← Matrix.mulVec_mulVec, dotProduct_mulVec, ← Matrix.mulVec_transpose]
    simp [dotProduct, Matrix.mulVec, pow_two]
  rw [heq]
  simp [sourceResidualVariance, dotProduct, pow_two]

theorem sourceResidualVariance_nonneg (D : Fin m → Fin q → ℝ)
    (hD : ∀ v : Fin q → ℝ, ∑ i, (Matrix.of D *ᵥ v) i ^ 2 ≤ ∑ j, v j ^ 2)
    (h : Fin m → ℝ) : 0 ≤ sourceResidualVariance D h := by
  have hh := transpose_contraction (Matrix.of D) hD h
  exact sub_nonneg.mpr hh

theorem sourceResidualKernel_scalar_law (D : Fin m → Fin q → ℝ)
    (hD : ∀ v : Fin q → ℝ, ∑ i, (Matrix.of D *ᵥ v) i ^ 2 ≤ ∑ j, v j ^ 2)
    (h : Fin m → ℝ) :
    (sourceResidualKernel D).map (fun z => ∑ j, h j * z j) =
      gaussianReal 0 (sourceResidualVariance D h).toNNReal := by
  rw [sourceResidualVariance_eq]
  exact residualKernel_scalar_law (residualCovariance D)
    (by rw [residualCovariance_eq]; exact residualCovariance_posSemidef _ hD) h

/-- The scalar law in the paper's t/sqrt(m) convention. -/
theorem sourceResidualKernel_scaled_scalar_law (D : Fin m → Fin q → ℝ)
    (hD : ∀ v : Fin q → ℝ, ∑ i, (Matrix.of D *ᵥ v) i ^ 2 ≤ ∑ j, v j ^ 2)
    (h : Fin m → ℝ) (t : ℝ) (hm : 0 < m) :
    (sourceResidualKernel D).map (fun z => (t / Real.sqrt (m : ℝ)) * ∑ j, h j * z j) =
      gaussianReal 0 (t^2 * ((∑ j, h j^2) / (m : ℝ) -
        ∑ k, ((∑ j, D j k * h j) / Real.sqrt (m : ℝ))^2)).toNNReal := by
  have hsc : (fun z : Fin m → ℝ => (t / Real.sqrt (m : ℝ)) * ∑ j, h j * z j) =
      (fun y : ℝ => (t / Real.sqrt (m : ℝ)) * y) ∘ (fun z => ∑ j, h j * z j) := rfl
  rw [hsc, ← Measure.map_map (by fun_prop) (by fun_prop),
    sourceResidualKernel_scalar_law D hD h, gaussianReal_map_const_mul]
  simp only [mul_zero]
  congr 1
  apply NNReal.eq
  have hmR : 0 ≤ (m : ℝ) := by positivity
  have hV := sourceResidualVariance_nonneg D hD h
  have hEq : (t / Real.sqrt (m : ℝ))^2 * sourceResidualVariance D h =
      t^2 * ((∑ j, h j^2) / (m : ℝ) -
        ∑ k, ((∑ j, D j k * h j) / Real.sqrt (m : ℝ))^2) := by
    simp_rw [div_pow, Real.sq_sqrt hmR, ← Finset.sum_div]
    unfold sourceResidualVariance
    ring
  rw [NNReal.coe_mul, NNReal.coe_mk, Real.coe_toNNReal _ hV, Real.coe_toNNReal]
  · exact hEq
  · rw [← hEq]
    exact mul_nonneg (sq_nonneg _) hV

/-- Exact scalar moments follow from the actual Gaussian pushforward law. -/
theorem scalar_moments_of_gaussian_map {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (F : Ω → ℝ) (hF : Measurable F) (V : ℝ) (hV : 0 ≤ V)
    (hlaw : μ.map F = gaussianReal 0 V.toNNReal) :
    Integrable F μ ∧ Integrable (fun x => (F x)^2) μ ∧
      (∫ x, F x ∂μ) = 0 ∧ (∫ x, (F x)^2 ∂μ) = V := by
  have hg : HasGaussianLaw F μ := {
    isGaussian_map := by rw [hlaw]; infer_instance }
  refine ⟨hg.integrable, hg.memLp_two.integrable_sq, ?_, ?_⟩
  · have h := integral_id_gaussianReal (μ := (0 : ℝ)) (v := V.toNNReal)
    rw [← hlaw, integral_map hF.aemeasurable (by fun_prop)] at h
    exact h
  · have h := variance_fun_id_gaussianReal (μ := (0 : ℝ)) (v := V.toNNReal)
    rw [variance_eq_integral (show AEMeasurable (fun x : ℝ => x)
      (gaussianReal 0 V.toNNReal) by fun_prop)] at h
    simp only [integral_id_gaussianReal, sub_zero, Real.coe_toNNReal V hV] at h
    rw [← hlaw, integral_map hF.aemeasurable (by fun_prop)] at h
    exact h

theorem sourceResidualKernel_scalar_moments (D : Fin m → Fin q → ℝ)
    (hD : ∀ v : Fin q → ℝ, ∑ i, (Matrix.of D *ᵥ v) i ^ 2 ≤ ∑ j, v j ^ 2)
    (h : Fin m → ℝ) :
    Integrable (fun z => ∑ j, h j * z j) (sourceResidualKernel D) ∧
      Integrable (fun z => (∑ j, h j * z j)^2) (sourceResidualKernel D) ∧
      (∫ z, (∑ j, h j * z j) ∂sourceResidualKernel D) = 0 ∧
      (∫ z, (∑ j, h j * z j)^2 ∂sourceResidualKernel D) = sourceResidualVariance D h :=
  scalar_moments_of_gaussian_map _ _ (by fun_prop) _
    (sourceResidualVariance_nonneg D hD h) (sourceResidualKernel_scalar_law D hD h)


end NeuralGeneralization.RobustGaussianGeometry
