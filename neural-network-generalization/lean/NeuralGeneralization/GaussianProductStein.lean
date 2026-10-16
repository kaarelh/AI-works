import NeuralGeneralization.GaussianStein
import NeuralGeneralization.CoordinateSplit
import Mathlib.MeasureTheory.Integral.Pi

/-!
# Coordinate integration by parts for finite Gaussian products

The product identity follows from the actual measure-preserving coordinate split,
Fubini's theorem, and the proved scalar Gaussian Stein identity. Coordinates may
have different variances, including zero variance.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped NNReal
namespace NeuralGeneralization.GaussianProductStein

variable {I : Type*} [Fintype I] [DecidableEq I]

omit [DecidableEq I] in
/-- Each Gaussian coordinate is integrable in the actual finite product law. -/
theorem integrable_coord (v : I → ℝ≥0) (i : I) :
    Integrable (fun z : I → ℝ => z i) (Measure.pi fun j => gaussianReal 0 (v j)) := by
  exact integrable_comp_eval (μ := fun j : I => gaussianReal 0 (v j)) (i := i)
    (f := fun x : ℝ => x) (GaussianStein.integrable_id_gaussian (v i))

omit [DecidableEq I] in
/-- Coordinate times a bounded measurable function is integrable. -/
theorem integrable_coord_mul_of_bounded (v : I → ℝ≥0) (i : I)
    (F : (I → ℝ) → ℝ) (hF : Measurable F) (B : ℝ) (hFB : ∀ z, |F z| ≤ B) :
    Integrable (fun z => z i * F z) (Measure.pi fun j => gaussianReal 0 (v j)) := by
  exact (integrable_coord v i).mul_bdd hF.aestronglyMeasurable
    (Filter.Eventually.of_forall fun z => by simpa only [Real.norm_eq_abs] using hFB z)

omit [DecidableEq I] in
/-- Every bounded measurable function is integrable under the finite Gaussian product. -/
theorem integrable_of_bounded (v : I → ℝ≥0) (F : (I → ℝ) → ℝ)
    (hF : Measurable F) (B : ℝ) (hFB : ∀ z, |F z| ≤ B) :
    Integrable F (Measure.pi fun j => gaussianReal 0 (v j)) := by
  apply Integrable.of_bound hF.aestronglyMeasurable B
  exact Filter.Eventually.of_forall fun z => by
    simpa only [Real.norm_eq_abs] using hFB z

/-- Actual finite-product Gaussian integration by parts along a selected coordinate. -/
theorem gaussian_integral_coord_mul_eq_integral_partial (v : I → ℝ≥0) (i : I)
    (F D : (I → ℝ) → ℝ) (hF : Measurable F) (hD : Measurable D)
    (hpartial : ∀ z, HasDerivAt (fun t => F (Function.update z i t)) (D z) (z i))
    (B B' : ℝ) (hFB : ∀ z, |F z| ≤ B) (hDB : ∀ z, |D z| ≤ B') :
    (∫ z : I → ℝ, z i * F z ∂(Measure.pi fun j => gaussianReal 0 (v j))) =
      (v i : ℝ) * ∫ z : I → ℝ, D z ∂(Measure.pi fun j => gaussianReal 0 (v j)) := by
  let μ : I → Measure ℝ := fun j => gaussianReal 0 (v j)
  let ν : Measure ({j : I // j ≠ i} → ℝ) := Measure.pi fun j => μ j
  let e := CoordinateSplit.split i
  have hsplit := (CoordinateSplit.measurePreserving_split μ i).symm
  have hFI := integrable_coord_mul_of_bounded v i F hF B hFB
  have hDI := integrable_of_bounded v D hD B' hDB
  have hFpull : Integrable (fun p : ℝ × ({j : I // j ≠ i} → ℝ) =>
      (e.symm p) i * F (e.symm p)) ((μ i).prod ν) :=
    hsplit.integrable_comp_of_integrable hFI
  have hDpull : Integrable (fun p : ℝ × ({j : I // j ≠ i} → ℝ) =>
      D (e.symm p)) ((μ i).prod ν) :=
    hsplit.integrable_comp_of_integrable hDI
  have hslice (y : {j : I // j ≠ i} → ℝ) :
      (∫ t : ℝ, t * F (e.symm (t, y)) ∂μ i) =
        (v i : ℝ) * ∫ t : ℝ, D (e.symm (t, y)) ∂μ i := by
    refine GaussianStein.gaussian_integral_mul_eq_integral_deriv (v i)
      (fun t => F (e.symm (t, y))) (fun t => D (e.symm (t, y))) ?_ ?_
      B B' (fun t => hFB _) (fun t => hDB _)
    · intro t
      simpa only [e, CoordinateSplit.update_split_symm, CoordinateSplit.split_symm_self]
        using hpartial (e.symm (t, y))
    · exact hD.comp (e.symm.measurable.comp (measurable_id.prodMk measurable_const))
  change (∫ z, z i * F z ∂Measure.pi μ) = (v i : ℝ) * ∫ z, D z ∂Measure.pi μ
  calc
    (∫ z, z i * F z ∂Measure.pi μ) =
        ∫ p : ℝ × ({j : I // j ≠ i} → ℝ), (e.symm p) i * F (e.symm p)
          ∂((μ i).prod ν) := (hsplit.integral_comp' (fun z => z i * F z)).symm
    _ = ∫ y, ∫ t : ℝ, t * F (e.symm (t, y)) ∂μ i ∂ν := by
      rw [integral_prod_symm _ hFpull]
      simp only [e, CoordinateSplit.split_symm_self]
    _ = ∫ y, (v i : ℝ) * (∫ t : ℝ, D (e.symm (t, y)) ∂μ i) ∂ν := by
      apply integral_congr_ae
      exact Filter.Eventually.of_forall hslice
    _ = (v i : ℝ) * ∫ y, ∫ t : ℝ, D (e.symm (t, y)) ∂μ i ∂ν :=
      integral_const_mul _ _
    _ = (v i : ℝ) * ∫ p : ℝ × ({j : I // j ≠ i} → ℝ), D (e.symm p)
          ∂((μ i).prod ν) := by rw [integral_prod_symm _ hDpull]
    _ = (v i : ℝ) * ∫ z, D z ∂Measure.pi μ := by
      rw [hsplit.integral_comp' D]

/-- Unit-variance specialization used by Gaussian interpolation. -/
theorem gaussian_integral_coord_mul_eq_integral_partial_standard (i : I)
    (F D : (I → ℝ) → ℝ) (hF : Measurable F) (hD : Measurable D)
    (hpartial : ∀ z, HasDerivAt (fun t => F (Function.update z i t)) (D z) (z i))
    (B B' : ℝ) (hFB : ∀ z, |F z| ≤ B) (hDB : ∀ z, |D z| ≤ B') :
    (∫ z : I → ℝ, z i * F z ∂(Measure.pi fun _ : I => gaussianReal 0 1)) =
      ∫ z : I → ℝ, D z ∂(Measure.pi fun _ : I => gaussianReal 0 1) := by
  simpa only [NNReal.coe_one, one_mul] using
    gaussian_integral_coord_mul_eq_integral_partial (fun _ => 1) i F D hF hD
      hpartial B B' hFB hDB

end NeuralGeneralization.GaussianProductStein
