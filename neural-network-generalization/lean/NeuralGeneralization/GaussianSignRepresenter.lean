import NeuralGeneralization.GaussianPosteriorFeatures

/-! The exact kernel representer formula for the actual Gaussian sign posterior. -/
noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators NNReal RealInnerProductSpace
namespace NeuralGeneralization.GaussianSignRepresenter
open GaussianOrthogonal GaussianConeRadial GaussianSignCone GaussianConditionalSubspace
open GaussianSignRegression GaussianPosteriorFeatures
variable {I J X : Type*} [Fintype I] [Fintype J]

theorem euclidean_conditional_mean_eq (A : J → I → ℝ)
    (hprob : (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A) ≠ 0) :
    (∫ x, x ∂cond (euclideanGaussian (ι := I) 1)
      ((fun x : EuclideanSpace ℝ I => ofLp x) ⁻¹' signCone A)) =
      toLp 2 (fun i => ∫ x : I → ℝ, x i ∂cond (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A)) := by
  let E := (fun x : EuclideanSpace ℝ I => ofLp x) ⁻¹' signCone A
  have hE : MeasurableSet E := (WithLp.measurable_ofLp 2 (I → ℝ)) (measurableSet_signCone A)
  have hpre : (toLp 2 : (I → ℝ) → EuclideanSpace ℝ I) ⁻¹' E = signCone A := rfl
  have hmap : (cond (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A)).map (toLp 2) =
      cond (euclideanGaussian (ι := I) 1) E := by
    rw [← hpre, map_cond_preimage _ _ (WithLp.measurable_toLp 2 (I → ℝ)) E hE]
    rfl
  change (∫ x, x ∂cond (euclideanGaussian (ι := I) 1) E) = _
  rw [← hmap, integral_map (WithLp.measurable_toLp 2 (I → ℝ)).aemeasurable
    (f := fun x : EuclideanSpace ℝ I => x) (by fun_prop)]
  calc
    _ = toLp 2 (∫ x : I → ℝ, x ∂cond (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A)) :=
      (PiLp.continuousLinearEquiv 2 ℝ (fun _ : I => ℝ)).symm.integral_comp_comm _
    _ = _ := by
      congr 1
      ext i
      exact eval_integral (fun j => ((memLp_eval j).integrable (by norm_num)).restrict.smul_measure
        (ENNReal.inv_ne_top.mpr hprob)) i

/-- The actual posterior whitened mean lies in the span of the observed rows. -/
theorem conditional_mean_mem_observationSpan (A : J → I → ℝ)
    (hprob : (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A) ≠ 0) :
    toLp 2 (fun i => ∫ x : I → ℝ, x i ∂cond (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A))
      ∈ observationSpan A := by
  rw [← euclidean_conditional_mean_eq A hprob]
  apply conditional_mean_mem (observationSpan A) _
    ((WithLp.measurable_ofLp 2 (I → ℝ)) (measurableSet_signCone A))
  intro x
  rw [euclidean_event_eq]
  simp only [Set.mem_preimage, coordinates_reflection]

/-- Regression coefficients exist even for singular or repeated observations. -/
theorem exists_regression_coefficients (A : J → I → ℝ)
    (hprob : (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A) ≠ 0) :
    ∃ b : J → ℝ, ∀ i,
      (∫ x : I → ℝ, x i ∂cond (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A)) =
        ∑ j, b j * A j i := by
  obtain ⟨b, hb⟩ := (Submodule.mem_span_range_iff_exists_fun ℝ).mp
    (conditional_mean_mem_observationSpan A hprob)
  refine ⟨b, fun i => ?_⟩
  have h := congrArg (fun x : EuclideanSpace ℝ I => x i) hb
  simpa only [WithLp.ofLp_sum, Finset.sum_apply, WithLp.ofLp_smul, Pi.smul_apply, smul_eq_mul, WithLp.ofLp_toLp] using h.symm

/-- Exact kernel representation of the actual posterior mean, with no inverse
or positive-definiteness premise for the sample Gram matrix. -/
theorem exists_kernel_representer (φ : I → X → ℝ) (w : I → ℝ) (hw : ∀ i, 0 ≤ w i)
    (s : J → X) (y : J → ℝ)
    (hprob : (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone (trainingMatrix φ w s y)) ≠ 0) :
    ∃ b : J → ℝ,
      posteriorCoefficients (trainingMatrix φ w s y) w = representerCoefficients φ w s b ∧
      ∀ x, (∫ z, gaussianField φ w z x
        ∂cond (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone (trainingMatrix φ w s y))) =
          ∑ j, b j * featureKernel φ w (s j) x := by
  obtain ⟨b, hb⟩ := exists_regression_coefficients (trainingMatrix φ w s y) hprob
  have hc : posteriorCoefficients (trainingMatrix φ w s y) w =
      representerCoefficients φ w s (fun j => b j * y j) := by
    funext i
    unfold posteriorCoefficients representerCoefficients
    rw [hb i]
    unfold trainingMatrix
    rw [Finset.mul_sum, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j hj
    calc
      _ = Real.sqrt (w i) ^ 2 * (b j * y j * φ i (s j)) := by ring
      _ = _ := by rw [Real.sq_sqrt (hw i)]
  refine ⟨fun j => b j * y j, hc, fun x => ?_⟩
  rw [mean_eq_featureField φ w _ hprob x, hc, representer_field]

end NeuralGeneralization.GaussianSignRepresenter
