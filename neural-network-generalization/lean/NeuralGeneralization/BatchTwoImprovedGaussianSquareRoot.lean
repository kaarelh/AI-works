import NeuralGeneralization.RobustCompressionLayerGaussian

/-! Retain the exact square-root covariance term in the existing measurable
full-field Gaussian coupling, rather than replacing it by absolute variance. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoImprovedGaussianSquareRoot
open RobustCompressionGaussian RobustCompressionLayerGaussian
variable {I : Type*} [Fintype I]

theorem vectorGaussianCoupling_error_exact (a b : I → ℝ) (v w : I → ℝ≥0) :
    (∫ p : (I → ℝ) × (I → ℝ), ∑ i, (p.1 i-p.2 i)^2
      ∂(vectorGaussianCoupling a b v w).joint) =
        ∑ i, ((a i-b i)^2+(Real.sqrt (v i:ℝ)-Real.sqrt (w i:ℝ))^2) := by
  change (∫ p : (I → ℝ) × (I → ℝ), ∑ i, (p.1 i-p.2 i)^2
    ∂(Measure.pi (fun _ : I => gaussianReal 0 1)).map _) = _
  rw [integral_map (by fun_prop) (by fun_prop)]
  rw [integral_finsetSum Finset.univ (fun i _ =>
    integrable_comp_eval (μ := fun _ : I => gaussianReal 0 1) (i := i)
      (gaussian_affine_difference_integrable (a i) (b i) (v i) (w i)))]
  apply Finset.sum_congr rfl
  intro i _
  rw [integral_comp_eval (μ := fun _ : I => gaussianReal 0 1) (i := i)
    (f := fun z : ℝ => ((a i+Real.sqrt (v i:ℝ)*z)-(b i+Real.sqrt (w i:ℝ)*z))^2) (by fun_prop)]
  exact scalar_gaussian_reconstruction_error _ _ _ _

theorem vectorGaussianCoupling_activation_error_sharp (a b : I → ℝ) (v w : I → ℝ≥0)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) :
    (∫ p : (I → ℝ) × (I → ℝ), ∑ i, (φ (p.1 i)-φ (p.2 i))^2
      ∂(vectorGaussianCoupling a b v w).joint) ≤
        ∑ i, ((a i-b i)^2+(Real.sqrt (v i:ℝ)-Real.sqrt (w i:ℝ))^2) := by
  have hpoint (p : (I → ℝ) × (I → ℝ)) :
      (∑ i, (φ (p.1 i)-φ (p.2 i))^2) ≤ ∑ i, (p.1 i-p.2 i)^2 := by
    apply Finset.sum_le_sum
    intro i _
    have h := hφ.dist_le_mul (p.1 i) (p.2 i)
    simp only [Real.dist_eq,NNReal.coe_one,one_mul] at h
    exact (sq_le_sq).mpr h
  have hi := vectorGaussianCoupling_error_integrable a b v w
  have hm : Measurable (fun p : (I → ℝ) × (I → ℝ) => ∑ i, (φ (p.1 i)-φ (p.2 i))^2) := by
    have hφm := hφ.continuous.measurable
    fun_prop
  have hleft := hi.mono' hm.aestronglyMeasurable (Filter.Eventually.of_forall (fun p => by
    rw [Real.norm_eq_abs,abs_of_nonneg (Finset.sum_nonneg (fun i _ => sq_nonneg _))]
    exact hpoint p))
  exact (integral_mono hleft hi hpoint).trans_eq (vectorGaussianCoupling_error_exact a b v w)

theorem fullCoupling_activation_error_sharp {A : Type*} [MeasurableSpace A] {N m q : ℕ}
    (p : GaussianLayerParameters A N m q) (hp : p.Contractive)
    (θ : A) (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) :
    (∫ z, ∑ i, (φ (p.idealObservable (θ,z.1) i)-φ (p.finiteObservable (θ,z.2) i))^2
      ∂p.fullCoupling θ) ≤ ∑ i, ((p.idealMean θ i-p.finiteMean θ i)^2+
        (Real.sqrt (p.idealVariance θ i:ℝ)-Real.sqrt (p.finiteVariance θ i:ℝ))^2) := by
  have hh := vectorGaussianCoupling_activation_error_sharp
    (p.idealMean θ) (p.finiteMean θ) (p.idealVariance θ) (p.finiteVariance θ) φ hφ
  rw [← vectorGaussianKernel_apply p.idealMean p.finiteMean p.idealVariance p.finiteVariance
    p.idealMean_measurable p.finiteMean_measurable p.idealVariance_measurable p.finiteVariance_measurable] at hh
  change (∫ z : (Fin N → ℝ) × (Fin N → ℝ), ∑ i, (φ (z.1 i)-φ (z.2 i))^2
    ∂p.evaluationCoupling θ) ≤ _ at hh
  rw [← p.fullCoupling_evaluations hp θ] at hh
  have hmap : Measurable (fun z : (Fin N → ℝ) × (Fin N → Fin m → ℝ) =>
      (p.idealObservable (θ,z.1),p.finiteObservable (θ,z.2))) :=
    ((p.idealObservable_measurable.comp measurable_prodMk_left).comp measurable_fst).prodMk
      ((p.finiteObservable_measurable.comp measurable_prodMk_left).comp measurable_snd)
  have hφm := hφ.continuous.measurable
  rw [integral_map hmap.aemeasurable (by fun_prop)] at hh
  exact hh

end NeuralGeneralization.BatchTwoImprovedGaussianSquareRoot
