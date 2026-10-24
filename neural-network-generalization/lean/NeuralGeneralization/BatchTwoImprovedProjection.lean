import NeuralGeneralization.RobustGaussianGeometryActive
import Mathlib.LinearAlgebra.Finsupp.LinearCombination

/-! # Whitened regression without a choice of matrix square root

The measurable Gram--Schmidt projection has exactly the residual covariance
needed for reconstruction. Its energy is controlled by a lower Gram bound.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InnerProductSpace Submodule
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoImprovedProjection
open RobustGaussianGeometry
variable {m q : ℕ}

theorem projection_mem_span (f : Fin q → EuclideanSpace ℝ (Fin m))
    (r : EuclideanSpace ℝ (Fin m)) : activeProjection f r ∈ Submodule.span ℝ (Set.range f) := by
  rw [activeProjection_eq_starProjection]
  exact ((Submodule.span ℝ (Set.range f)).orthogonalProjectionOnto r).property

theorem projection_inner_self (f : Fin q → EuclideanSpace ℝ (Fin m))
    (r : EuclideanSpace ℝ (Fin m)) : ⟪activeProjection f r,r⟫ = ‖activeProjection f r‖^2 := by
  have h := (Submodule.span ℝ (Set.range f)).re_inner_starProjection_eq_normSq r
  rw [← activeProjection_eq_starProjection] at h
  change ⟪activeProjection f r,r⟫ = _ at h
  have hn : ‖(Submodule.span ℝ (Set.range f)).orthogonalProjectionOnto r‖ =
      ‖activeProjection f r‖ := by
    rw [activeProjection_eq_starProjection]
    rfl
  rwa [hn] at h

/-- A lower frame bound controls the energy removed by regression.
This is the inverse-Gram estimate, proved without any matrix inversion. -/
theorem projection_energy_le (f : Fin q → EuclideanSpace ℝ (Fin m))
    (hgram : ∀ v : Fin q → ℝ, (∑ k, (v k)^2) ≤ 2*‖∑ k, v k • f k‖^2)
    (r : EuclideanSpace ℝ (Fin m)) :
    ‖activeProjection f r‖^2 ≤ 2*∑ k, ⟪f k,r⟫^2 := by
  obtain ⟨v,hv⟩ := (Submodule.mem_span_range_iff_exists_fun ℝ).mp (projection_mem_span f r)
  have hco := hgram v
  rw [hv] at hco
  have hip : (∑ k, v k*⟪f k,r⟫) = ‖activeProjection f r‖^2 := by
    rw [← projection_inner_self, ← hv, sum_inner]
    simp only [inner_smul_left, RCLike.conj_to_real]
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ v (fun k => ⟪f k,r⟫)
  rw [hip] at hcs
  have hB : 0 ≤ ∑ k, ⟪f k,r⟫^2 := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have hmul := mul_le_mul_of_nonneg_right hco hB
  by_cases hz : ‖activeProjection f r‖^2 = 0
  · rw [hz]; positivity
  · have hp : 0 < ‖activeProjection f r‖^2 := lt_of_le_of_ne (sq_nonneg _) (Ne.symm hz)
    nlinarith

/-- Zero active columns need not satisfy a coercive bound. Removing their
coefficients leaves the represented vector unchanged. -/
theorem projection_energy_le_active (f : Fin q → EuclideanSpace ℝ (Fin m))
    (S : Finset (Fin q)) (hzero : ∀ k, k ∉ S → f k = 0)
    (hgram : ∀ v : Fin q → ℝ, (∀ k, k ∉ S → v k = 0) →
      (∑ k, (v k)^2) ≤ 2*‖∑ k, v k • f k‖^2)
    (r : EuclideanSpace ℝ (Fin m)) :
    ‖activeProjection f r‖^2 ≤ 2*∑ k, ⟪f k,r⟫^2 := by
  classical
  obtain ⟨w,hw⟩ := (Submodule.mem_span_range_iff_exists_fun ℝ).mp (projection_mem_span f r)
  let v := fun k => if k ∈ S then w k else 0
  have hv : ∑ k, v k • f k = activeProjection f r := by
    rw [← hw]
    apply Finset.sum_congr rfl
    intro k hk
    by_cases h : k ∈ S
    · simp [v,h]
    · simp [v,h,hzero k h]
  have hco := hgram v (by intro k hk; simp [v,hk])
  rw [hv] at hco
  have hip : (∑ k, v k*⟪f k,r⟫) = ‖activeProjection f r‖^2 := by
    rw [← projection_inner_self, ← hv, sum_inner]
    simp only [inner_smul_left, RCLike.conj_to_real]
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ v (fun k => ⟪f k,r⟫)
  rw [hip] at hcs
  have hB : 0 ≤ ∑ k, ⟪f k,r⟫^2 := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have hmul := mul_le_mul_of_nonneg_right hco hB
  by_cases hz : ‖activeProjection f r‖^2 = 0
  · rw [hz]; positivity
  · have hp : 0 < ‖activeProjection f r‖^2 := lt_of_le_of_ne (sq_nonneg _) (Ne.symm hz)
    nlinarith

theorem residual_pythagoras (f : Fin q → EuclideanSpace ℝ (Fin m))
    (r : EuclideanSpace ℝ (Fin m)) :
    ‖queryResidual f r‖^2+‖activeProjection f r‖^2 = ‖r‖^2 := by
  have ho := queryResidual_mem_orthogonal f r
  have hi : ⟪queryResidual f r,activeProjection f r⟫ = 0 :=
    (real_inner_comm _ _).trans ((Submodule.mem_orthogonal _ _).mp ho _ (projection_mem_span f r))
  have he := norm_add_sq_eq_norm_sq_add_norm_sq_of_inner_eq_zero
    (queryResidual f r) (activeProjection f r) hi
  simp only [queryResidual, sub_add_cancel] at he
  simpa only [queryResidual, pow_two] using he.symm

theorem residual_norm_gap_square_le (f : Fin q → EuclideanSpace ℝ (Fin m))
    (r : EuclideanSpace ℝ (Fin m)) :
    (‖r‖-‖queryResidual f r‖)^2 ≤ ‖activeProjection f r‖^2 := by
  have hp := residual_pythagoras f r
  have hr := norm_nonneg r
  have hs := norm_nonneg (queryResidual f r)
  have hp0 := sq_nonneg ‖activeProjection f r‖
  have hle : ‖queryResidual f r‖ ≤ ‖r‖ := by nlinarith
  nlinarith

theorem residual_norm_gap_square_le_gram (f : Fin q → EuclideanSpace ℝ (Fin m))
    (hgram : ∀ v : Fin q → ℝ, (∑ k, (v k)^2) ≤ 2*‖∑ k, v k • f k‖^2)
    (r : EuclideanSpace ℝ (Fin m)) :
    (‖r‖-‖queryResidual f r‖)^2 ≤ 2*∑ k, ⟪f k,r⟫^2 :=
  (residual_norm_gap_square_le f r).trans (projection_energy_le f hgram r)

end NeuralGeneralization.BatchTwoImprovedProjection
