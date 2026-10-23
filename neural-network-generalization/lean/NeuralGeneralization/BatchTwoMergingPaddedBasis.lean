import NeuralGeneralization.BatchTwoMergingBasis
import Mathlib.Data.Matrix.Mul

/-! # Population coordinates padded to a common finite width -/
noncomputable section
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging

def paddedLabel {N Q : ℕ} (p : PopulationPartition N) (hq : populationCount p ≤ Q)
    (i : Fin N) : Fin Q := ⟨(populationLabel p i).val, (populationLabel p i).isLt.trans_le hq⟩

def paddedBasis {N Q : ℕ} (p : PopulationPartition N) (hq : populationCount p ≤ Q) :
    Matrix (Fin N) (Fin Q) ℝ := fun i a =>
  if paddedLabel p hq i = a then (Real.sqrt (populationSize p (populationLabel p i)))⁻¹ else 0

theorem paddedLabel_inj {N Q : ℕ} (p : PopulationPartition N) (hq : populationCount p ≤ Q)
    (i j : Fin N) : paddedLabel p hq i = paddedLabel p hq j ↔
      populationLabel p i = populationLabel p j := by
  simp only [paddedLabel, Fin.mk.injEq, Fin.ext_iff]

theorem paddedBasis_mulVec {N Q : ℕ} (p : PopulationPartition N)
    (hq : populationCount p ≤ Q) (h : Fin Q → ℝ) (i : Fin N) :
    (paddedBasis p hq *ᵥ h) i =
      h (paddedLabel p hq i) / Real.sqrt (populationSize p (populationLabel p i)) := by
  classical
  simp [Matrix.mulVec, dotProduct, paddedBasis, div_eq_mul_inv, mul_comm]

theorem relu_paddedBasis_mulVec {N Q : ℕ} (p : PopulationPartition N)
    (hq : populationCount p ≤ Q) (h : Fin Q → ℝ) :
    (fun i => relu ((paddedBasis p hq *ᵥ h) i)) =
      paddedBasis p hq *ᵥ (fun a => relu (h a)) := by
  funext i
  rw [paddedBasis_mulVec, paddedBasis_mulVec]
  rw [div_eq_mul_inv, mul_comm, relu_mul_nonneg _ _ (by positivity)]
  ring

theorem paddedBasis_mul_transpose {N Q : ℕ} (p : PopulationPartition N)
    (hq : populationCount p ≤ Q) :
    paddedBasis p hq * (paddedBasis p hq)ᵀ = Matrix.of (populationProjection p) := by
  classical
  ext i j
  simp only [Matrix.mul_apply, Matrix.transpose_apply, Matrix.of_apply, paddedBasis]
  rw [Finset.sum_eq_single (paddedLabel p hq i)]
  · by_cases hij : populationLabel p i = populationLabel p j
    · have hp := (paddedLabel_inj p hq i j).mpr hij
      simp only [↓reduceIte, hp, populationProjection, hij]
      rw [← mul_inv, ← pow_two, Real.sq_sqrt (populationSize_pos p _).le]
      rfl
    · have hp : paddedLabel p hq j ≠ paddedLabel p hq i := by
        intro h; exact hij ((paddedLabel_inj p hq i j).mp h.symm)
      simp [hp, populationProjection, hij]
  · intro a _ ha
    simp [Ne.symm ha]
  · simp

theorem projection_paddedBasis_mulVec {N Q : ℕ} (p : PopulationPartition N)
    (hq : populationCount p ≤ Q) (h : Fin Q → ℝ) :
    Matrix.of (populationProjection p) *ᵥ (paddedBasis p hq *ᵥ h) = paddedBasis p hq *ᵥ h := by
  funext i
  change populationAverage p (paddedBasis p hq *ᵥ h) i = _
  rw [populationAverage_eq, paddedBasis_mulVec]
  have hs : (∑ j ∈ populationMembers p (populationLabel p i),
      (paddedBasis p hq *ᵥ h) j) = populationSize p (populationLabel p i) *
        (h (paddedLabel p hq i) / Real.sqrt (populationSize p (populationLabel p i))) := by
    calc
      _ = ∑ _j ∈ populationMembers p (populationLabel p i),
          h (paddedLabel p hq i) / Real.sqrt (populationSize p (populationLabel p i)) := by
        apply Finset.sum_congr rfl
        intro j hj
        have hji := (mem_populationMembers p _ _).mp hj
        rw [paddedBasis_mulVec, hji, (paddedLabel_inj p hq j i).mpr hji]
      _ = _ := by simp [populationSize]
  rw [hs]
  field_simp [populationSize_ne_zero]

theorem projection_paddedBasis {N Q : ℕ} (p : PopulationPartition N)
    (hq : populationCount p ≤ Q) :
    Matrix.of (populationProjection p) * paddedBasis p hq =
      paddedBasis p hq := by
  classical
  apply Matrix.ext
  intro i a
  have hh := congrFun (projection_paddedBasis_mulVec p hq (Pi.single a 1)) i
  simpa [Matrix.mulVec, Matrix.mul_apply, dotProduct, Pi.single_apply] using hh

theorem paddedBasis_active {N Q : ℕ} (p : PopulationPartition N)
    (hq : populationCount p ≤ Q) (a : Fin (populationCount p)) (i : Fin N) :
    paddedBasis p hq i (Fin.castLE hq a) = populationBasis p a i := by
  have heq : paddedLabel p hq i = Fin.castLE hq a ↔ populationLabel p i = a := by
    simp only [paddedLabel, Fin.ext_iff, Fin.val_castLE]
  by_cases h : populationLabel p i = a
  · simp [paddedBasis, populationBasis, heq, h]
  · simp [paddedBasis, populationBasis, heq, h]

theorem paddedBasis_inactive {N Q : ℕ} (p : PopulationPartition N)
    (hq : populationCount p ≤ Q) (a : Fin Q) (ha : populationCount p ≤ a.val)
    (i : Fin N) : paddedBasis p hq i a = 0 := by
  have hn : paddedLabel p hq i ≠ a := by
    intro h
    have hv := congrArg Fin.val h
    have hl := (populationLabel p i).isLt
    simp only [paddedLabel] at hv
    omega
  simp [paddedBasis, hn]

end NeuralGeneralization.BatchTwoMerging
