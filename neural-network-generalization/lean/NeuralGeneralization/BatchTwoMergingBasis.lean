import NeuralGeneralization.BatchTwoMergingGeometry
import NeuralGeneralization.BatchTwoMergingGaussian

/-! # Normalized population indicators and their exact Gaussian law -/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal

namespace NeuralGeneralization.BatchTwoMerging

def populationBasis {N : ℕ} (p : PopulationPartition N)
    (a : Fin (populationCount p)) (i : Fin N) : ℝ :=
  if populationLabel p i = a then (Real.sqrt (populationSize p a))⁻¹ else 0

theorem populationBasis_nonneg {N : ℕ} (p : PopulationPartition N)
    (a : Fin (populationCount p)) (i : Fin N) : 0 ≤ populationBasis p a i := by
  unfold populationBasis
  split_ifs <;> positivity

theorem populationBasis_sum_mul {N : ℕ} (p : PopulationPartition N)
    (a b : Fin (populationCount p)) :
    (∑ i, populationBasis p a i * populationBasis p b i) = if a = b then 1 else 0 := by
  classical
  by_cases hab : a = b
  · subst b
    rw [if_pos rfl]
    have hk := populationSize_pos p a
    have hs : Real.sqrt (populationSize p a) ≠ 0 := (Real.sqrt_pos.mpr hk).ne'
    calc
      _ = ∑ i ∈ populationMembers p a, (Real.sqrt (populationSize p a))⁻¹ ^ 2 := by
        rw [populationMembers, Finset.sum_filter]
        apply Finset.sum_congr rfl
        intro i _
        by_cases hi : populationLabel p i = a <;> simp [populationBasis, hi, pow_two]
      _ = populationSize p a * (Real.sqrt (populationSize p a))⁻¹ ^ 2 := by
        simp [populationSize]
      _ = 1 := by
        rw [inv_pow, Real.sq_sqrt hk.le, mul_inv_cancel₀ hk.ne']
  · rw [if_neg hab]
    apply Finset.sum_eq_zero
    intro i _
    by_cases ha : populationLabel p i = a
    · have hb : populationLabel p i ≠ b := by simpa [ha] using hab
      simp [populationBasis, hb]
    · simp [populationBasis, ha]

theorem populationCoordinates_eq_basis {N : ℕ} (p : PopulationPartition N)
    (h : Fin N → ℝ) (a : Fin (populationCount p)) :
    populationCoordinates p h a = ∑ i, populationBasis p a i * h i := by
  classical
  unfold populationCoordinates populationBasis populationMembers
  rw [Finset.sum_filter, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro i _
  by_cases hi : populationLabel p i = a <;> simp [hi, div_eq_mul_inv, mul_comm]

theorem populationLift_eq_basis {N : ℕ} (p : PopulationPartition N)
    (h : Fin (populationCount p) → ℝ) (i : Fin N) :
    populationLift p h i = ∑ a, populationBasis p a i * h a := by
  classical
  rw [Finset.sum_eq_single (populationLabel p i)]
  · simp [populationLift, populationBasis, div_eq_mul_inv, mul_comm]
  · intro a _ ha
    have hh : populationLabel p i ≠ a := Ne.symm ha
    simp [populationBasis, hh]
  · simp

theorem populationProjection_eq_basis {N : ℕ} (p : PopulationPartition N)
    (i j : Fin N) :
    populationProjection p i j = ∑ a, populationBasis p a i * populationBasis p a j := by
  classical
  rw [Finset.sum_eq_single (populationLabel p i)]
  · by_cases hij : populationLabel p i = populationLabel p j
    · simp only [populationProjection, hij, ↓reduceIte, populationBasis]
      rw [← mul_inv, ← pow_two, Real.sq_sqrt (populationSize_pos p _).le]
      rfl
    · simp [populationProjection, populationBasis, hij, Ne.symm hij]
  · intro a _ ha
    have hh : populationLabel p i ≠ a := Ne.symm ha
    simp [populationBasis, hh]
  · simp

/-- Population coordinates of a finite isotropic Gaussian are independent
Gaussians with the original variance, even when population sizes differ. -/
theorem productGaussian_map_populationCoordinates {N : ℕ}
    (p : PopulationPartition N) (v : ℝ≥0) :
    (Measure.pi fun _ : Fin N => gaussianReal 0 v).map (populationCoordinates p) =
      Measure.pi (fun _ : Fin (populationCount p) => gaussianReal 0 v) := by
  have heq : populationCoordinates p = (fun z a => ∑ i, populationBasis p a i * z i) := by
    funext z a
    exact populationCoordinates_eq_basis p z a
  rw [heq]
  exact productGaussian_map_orthonormal_rows (populationBasis p)
    (populationBasis_sum_mul p) v

end NeuralGeneralization.BatchTwoMerging
