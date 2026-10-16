import NeuralGeneralization.GaussianSignCone
import NeuralGeneralization.GaussianOrthogonal
import NeuralGeneralization.GaussianFieldCovariance
import Mathlib.Analysis.InnerProductSpace.Projection.Reflection
import Mathlib.MeasureTheory.Integral.Bochner.ContinuousLinearMap
import Mathlib.MeasureTheory.SpecificCodomains.Pi

/-! Conditional Gaussian means for events determined by a finite-dimensional
linear subspace. Reflection gives the actual regression subspace; Gaussian
orthonormal coordinates give the sharp dimension bound. -/
noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators NNReal RealInnerProductSpace
namespace NeuralGeneralization.GaussianConditionalSubspace
open GaussianOrthogonal GaussianConeRadial
open FiniteDifferential GaussianAngularFields GaussianAngularPrice GaussianFieldTilt
variable {I : Type*} [Fintype I]

/-- Conditioning commutes with a measurable map when the event is a preimage. -/
theorem map_cond_preimage {Ω Ω' : Type*} [MeasurableSpace Ω] [MeasurableSpace Ω']
    (μ : Measure Ω) (f : Ω → Ω') (hf : Measurable f)
    (E : Set Ω') (hE : MeasurableSet E) :
    (cond μ (f ⁻¹' E)).map f = cond (μ.map f) E := by
  unfold ProbabilityTheory.cond
  rw [Measure.map_smul, ← Measure.restrict_map hf hE, Measure.map_apply hf hE]

theorem integrable_toLp : Integrable (toLp 2 : (I → ℝ) → EuclideanSpace ℝ I)
    (Measure.pi (fun _ : I => gaussianReal 0 1)) := by
  have h : Integrable (fun x : I → ℝ => x) (Measure.pi (fun _ : I => gaussianReal 0 1)) :=
    integrable_pi_iff.mpr (fun i => (GaussianConeRadial.memLp_eval i).integrable (by norm_num))
  exact (PiLp.continuousLinearEquiv 2 ℝ (fun _ : I => ℝ)).symm.toContinuousLinearMap.integrable_comp h

theorem integrable_id_euclidean : Integrable (fun x : EuclideanSpace ℝ I => x)
    (euclideanGaussian 1) := by
  unfold euclideanGaussian
  exact (integrable_map_measure (by fun_prop) (WithLp.measurable_toLp 2 (I → ℝ)).aemeasurable).2
    integrable_toLp

/-- A Gaussian conditional mean lies in every linear subspace on which the
event depends. This is proved by actual orthogonal-reflection invariance. -/
theorem conditional_mean_mem (K : Submodule ℝ (EuclideanSpace ℝ I))
    (E : Set (EuclideanSpace ℝ I)) (hE : MeasurableSet E)
    (hdep : ∀ x, K.reflection x ∈ E ↔ x ∈ E) :
    (∫ x, x ∂cond (euclideanGaussian (ι := I) 1) E) ∈ K := by
  have hpre : K.reflection ⁻¹' E = E := Set.ext hdep
  have hmap : (cond (euclideanGaussian (ι := I) 1) E).map K.reflection =
      cond (euclideanGaussian (ι := I) 1) E := by
    rw [← hpre, map_cond_preimage _ _ K.reflection.continuous.measurable E hE,
      euclideanGaussian_map, hpre]
  apply (K.reflection_eq_self_iff _).mp
  have hi := K.reflection.toLinearIsometry.integral_comp_comm
    (μ := cond (euclideanGaussian (ι := I) 1) E) (fun x => x)
  calc
    _ = ∫ x, K.reflection x ∂cond (euclideanGaussian (ι := I) 1) E := hi.symm
    _ = _ := by
      have hj := integral_map (μ := cond (euclideanGaussian (ι := I) 1) E)
        K.reflection.continuous.measurable.aemeasurable
        (f := fun x : EuclideanSpace ℝ I => x) (by fun_prop)
      simpa only [hmap] using hj.symm

def coordinateMatrix (K : Submodule ℝ (EuclideanSpace ℝ I)) :
    Fin (Module.finrank ℝ K) → I → ℝ :=
  fun j i => ((stdOrthonormalBasis ℝ K j : K) : EuclideanSpace ℝ I) i

def coordinates (K : Submodule ℝ (EuclideanSpace ℝ I))
    (x : EuclideanSpace ℝ I) : Fin (Module.finrank ℝ K) → ℝ :=
  fun j => ⟪((stdOrthonormalBasis ℝ K j : K) : EuclideanSpace ℝ I), x⟫

@[fun_prop] theorem continuous_coordinates (K : Submodule ℝ (EuclideanSpace ℝ I)) :
    Continuous (coordinates K) := by
  unfold coordinates
  fun_prop

theorem coordinates_toLp (K : Submodule ℝ (EuclideanSpace ℝ I)) (x : I → ℝ) :
    coordinates K (toLp 2 x) = fieldLinear (coordinateMatrix K) x := by
  ext j
  simp [coordinates, coordinateMatrix, EuclideanSpace.inner_eq_star_dotProduct,
    dotProduct, fieldLinear_apply, mul_comm]

theorem coordinateMatrix_gram (K : Submodule ℝ (EuclideanSpace ℝ I))
    (j k : Fin (Module.finrank ℝ K)) :
    gram (coordinateMatrix K) j k = if j = k then 1 else 0 := by
  have h := (stdOrthonormalBasis ℝ K).inner_eq_ite j k
  simpa [gram, coordinateMatrix, Submodule.coe_inner,
    EuclideanSpace.inner_eq_star_dotProduct, dotProduct, mul_comm] using h

/-- The orthonormal coordinates of the actual standard Gaussian are an
actual standard product Gaussian of dimension `finrank K`. -/
theorem map_coordinates (K : Submodule ℝ (EuclideanSpace ℝ I)) :
    (euclideanGaussian (ι := I) 1).map (coordinates K) =
      Measure.pi (fun _ : Fin (Module.finrank ℝ K) => gaussianReal 0 1) := by
  classical
  let B : Fin (Module.finrank ℝ K) → Fin (Module.finrank ℝ K) → ℝ :=
    fun j k => if j = k then 1 else 0
  have hB : fieldLinear B = ContinuousLinearMap.id ℝ (Fin (Module.finrank ℝ K) → ℝ) := by
    ext x j
    simp [fieldLinear_apply, B]
  have hg : ∀ j k, gram (coordinateMatrix K) j k = gram B j k := by
    intro j k
    rw [coordinateMatrix_gram]
    simp [gram, B]
  unfold euclideanGaussian
  rw [Measure.map_map (continuous_coordinates K).measurable
    (WithLp.measurable_toLp 2 (I → ℝ))]
  have hf : coordinates K ∘ toLp 2 = fieldLinear (coordinateMatrix K) := by
    funext x
    exact coordinates_toLp K x
  rw [hf]
  change fieldLaw (coordinateMatrix K) = _
  rw [GaussianFieldCovariance.fieldLaw_eq_of_gram_eq _ B hg]
  unfold fieldLaw
  rw [hB]
  exact Measure.map_id

/-- Reflection in the conditioning subspace fixes every observed coordinate. -/
theorem coordinates_reflection (K : Submodule ℝ (EuclideanSpace ℝ I))
    (x : EuclideanSpace ℝ I) : coordinates K (K.reflection x) = coordinates K x := by
  ext j
  change ⟪((stdOrthonormalBasis ℝ K j : K) : EuclideanSpace ℝ I), K.reflection x⟫ = _
  have h := K.reflection.inner_map_map
    (((stdOrthonormalBasis ℝ K j : K) : EuclideanSpace ℝ I)) x
  rw [Submodule.reflection_mem_subspace_eq_self (stdOrthonormalBasis ℝ K j).property] at h
  exact h

/-- Sharp dimension bound for the actual Gaussian conditional mean under a
homogeneous event in the orthonormal coordinates of any subspace. -/
theorem conditional_mean_norm_sq_le_finrank (K : Submodule ℝ (EuclideanSpace ℝ I))
    (C : Set (Fin (Module.finrank ℝ K) → ℝ)) (hC : MeasurableSet C)
    (hcone : PositiveHomogeneous C)
    (hprob : (euclideanGaussian (ι := I) 1) (coordinates K ⁻¹' C) ≠ 0) :
    ‖∫ x, x ∂cond (euclideanGaussian (ι := I) 1) (coordinates K ⁻¹' C)‖ ^ 2 ≤
      Module.finrank ℝ K := by
  let ν := cond (euclideanGaussian (ι := I) 1) (coordinates K ⁻¹' C)
  let m := ∫ x, x ∂ν
  have hmi : Integrable (fun x : EuclideanSpace ℝ I => x) ν :=
    (integrable_id_euclidean (I := I)).restrict.smul_measure (ENNReal.inv_ne_top.mpr hprob)
  have hm : m ∈ K := conditional_mean_mem K _
    ((continuous_coordinates K).measurable hC) (fun x => by simp [coordinates_reflection])
  have hmap : ν.map (coordinates K) =
      cond (Measure.pi (fun _ : Fin (Module.finrank ℝ K) => gaussianReal 0 1)) C := by
    dsimp [ν]
    rw [map_cond_preimage _ _ (continuous_coordinates K).measurable C hC, map_coordinates]
  have hp : (Measure.pi (fun _ : Fin (Module.finrank ℝ K) => gaussianReal 0 1)) C ≠ 0 := by
    rw [← map_coordinates K, Measure.map_apply (continuous_coordinates K).measurable hC]
    exact hprob
  have hcoord (j : Fin (Module.finrank ℝ K)) :
      (∫ x, x j ∂cond (Measure.pi (fun _ : Fin (Module.finrank ℝ K) => gaussianReal 0 1)) C) =
        ⟪((stdOrthonormalBasis ℝ K j : K) : EuclideanSpace ℝ I), m⟫ := by
    rw [← hmap, integral_map (continuous_coordinates K).measurable.aemeasurable
      (measurable_pi_apply j).aestronglyMeasurable]
    exact (innerSL ℝ (((stdOrthonormalBasis ℝ K j : K) : EuclideanSpace ℝ I))).integral_comp_comm hmi
  have hb := sum_sq_conditional_mean_le_card C hC hcone hp
  simp only [hcoord, Fintype.card_fin] at hb
  have heq := (stdOrthonormalBasis ℝ K).sum_sq_norm_inner_right (⟨m, hm⟩ : K)
  simp only [Submodule.coe_inner, Real.norm_eq_abs, sq_abs, Submodule.norm_coe] at heq
  rw [heq] at hb
  exact hb

end NeuralGeneralization.GaussianConditionalSubspace
