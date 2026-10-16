import NeuralGeneralization.GaussianConditionalSubspace
import NeuralGeneralization.KernelEnergy

/-! Exact sample-count energy bounds for the actual Gaussian sign posterior.
No invertibility of the sample covariance and no regression formula are assumed. -/
noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators NNReal RealInnerProductSpace
namespace NeuralGeneralization.GaussianSignRegression
open GaussianOrthogonal GaussianConeRadial GaussianSignCone GaussianConditionalSubspace
variable {I J : Type*} [Fintype I] [Fintype J]

def observationSpan (A : J → I → ℝ) : Submodule ℝ (EuclideanSpace ℝ I) :=
  Submodule.span ℝ (Set.range (fun j => toLp 2 (A j)))

theorem observation_mem (A : J → I → ℝ) (j : J) :
    toLp 2 (A j) ∈ observationSpan A := Submodule.subset_span ⟨j, rfl⟩

def reducedMatrix (A : J → I → ℝ) :
    J → Fin (Module.finrank ℝ (observationSpan A)) → ℝ :=
  fun j k => ⟪toLp 2 (A j), ((stdOrthonormalBasis ℝ (observationSpan A) k : observationSpan A) : EuclideanSpace ℝ I)⟫

theorem reduced_form (A : J → I → ℝ) (x : EuclideanSpace ℝ I) (j : J) :
    (∑ k, reducedMatrix A j k * coordinates (observationSpan A) x k) =
      ∑ i, A j i * x i := by
  let a : observationSpan A := ⟨toLp 2 (A j), observation_mem A j⟩
  have h := (stdOrthonormalBasis ℝ (observationSpan A)).sum_inner_mul_inner a
    ((observationSpan A).orthogonalProjectionOnto x)
  have hip (u : observationSpan A) : ⟪u, (observationSpan A).orthogonalProjectionOnto x⟫ =
      ⟪(u : EuclideanSpace ℝ I), x⟫ :=
    Submodule.inner_orthogonalProjectionOnto_eq_of_mem_left u x
  simp_rw [hip] at h
  have hh : (∑ k, reducedMatrix A j k * coordinates (observationSpan A) x k) =
      ⟪toLp 2 (A j), x⟫ := by
    simpa only [Submodule.inner_orthogonalProjectionOnto_eq_of_mem_left,
      Submodule.coe_inner, a, reducedMatrix, coordinates] using h
  rw [hh]
  simp [EuclideanSpace.inner_eq_star_dotProduct, dotProduct, mul_comm]

theorem euclidean_event_eq (A : J → I → ℝ) :
    (fun x : EuclideanSpace ℝ I => ofLp x) ⁻¹' signCone A =
      coordinates (observationSpan A) ⁻¹' signCone (reducedMatrix A) := by
  ext x
  simp only [Set.mem_preimage, signCone, Set.mem_setOf_eq, reduced_form]

theorem finrank_observationSpan_le (A : J → I → ℝ) :
    Module.finrank ℝ (observationSpan A) ≤ Fintype.card J := by
  classical
  exact (finrank_span_le_card _).trans (by
    simpa only [Set.toFinset_card] using Fintype.card_range_le (fun j => toLp 2 (A j)))

/-- For any finite collection of signed observations, the squared norm of
the actual whitened posterior mean is at most the observation rank. -/
theorem conditional_mean_sq_le_rank (A : J → I → ℝ)
    (hprob : (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A) ≠ 0) :
    (∑ i, (∫ x : I → ℝ, x i ∂cond (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A)) ^ 2)
      ≤ Module.finrank ℝ (observationSpan A) := by
  let E := (fun x : EuclideanSpace ℝ I => ofLp x) ⁻¹' signCone A
  have hE : MeasurableSet E := (WithLp.measurable_ofLp 2 (I → ℝ)) (measurableSet_signCone A)
  have hpre : (toLp 2 : (I → ℝ) → EuclideanSpace ℝ I) ⁻¹' E = signCone A := rfl
  have hp : (euclideanGaussian (ι := I) 1) E ≠ 0 := by
    unfold euclideanGaussian
    rw [Measure.map_apply (WithLp.measurable_toLp 2 (I → ℝ)) hE, hpre]
    exact hprob
  have hb := conditional_mean_norm_sq_le_finrank (observationSpan A)
    (signCone (reducedMatrix A)) (measurableSet_signCone _) (positiveHomogeneous_signCone _)
    (by rw [← euclidean_event_eq]; exact hp)
  rw [← euclidean_event_eq] at hb
  have hmap : (cond (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A)).map (toLp 2) =
      cond (euclideanGaussian (ι := I) 1) E := by
    rw [← hpre, map_cond_preimage _ _ (WithLp.measurable_toLp 2 (I → ℝ)) E hE]
    rfl
  have hvec : (∫ x, x ∂cond (euclideanGaussian (ι := I) 1) E) =
      toLp 2 (fun i => ∫ x : I → ℝ, x i ∂cond (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A)) := by
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
  change ‖∫ x, x ∂cond (euclideanGaussian (ι := I) 1) E‖ ^ 2 ≤ _ at hb
  rw [hvec, EuclideanSpace.real_norm_sq_eq] at hb
  exact hb

/-- The sample-count bound includes repeated or linearly dependent observations. -/
theorem conditional_mean_sq_le_sample_count (A : J → I → ℝ)
    (hprob : (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A) ≠ 0) :
    (∑ i, (∫ x : I → ℝ, x i ∂cond (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A)) ^ 2)
      ≤ Fintype.card J :=
  (conditional_mean_sq_le_rank A hprob).trans (by exact_mod_cast finrank_observationSpan_le A)

end NeuralGeneralization.GaussianSignRegression
