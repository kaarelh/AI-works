import NeuralGeneralization.BatchTwoMergingEvaluation
import NeuralGeneralization.BatchTwoMergingCompressedTail
import NeuralGeneralization.NetworkCylinderScaling

/-! # The actual compressed network coefficients obey the Gaussian energy budget -/
noncomputable section
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

 theorem compressedWhitened_first {d N r : ℕ} (p : LayerPartitions N r)
    (w : Weights d N r) (a : Fin (populationCount (p 0))) (j : Fin (d+1)) :
    compressedWhitened p w (Sum.inl (a,j)) =
      ∑ i, populationBasis (p 0) a i * whiten w (Sum.inl (i,j)) := by
  classical
  simp [compressedWhitened, Fintype.sum_sum_type, Fintype.sum_prod_type,
    compressionRow, mul_ite, ite_mul]

theorem compressedWhitened_internal {d N r : ℕ} (p : LayerPartitions N r)
    (w : Weights d N r) (s : Fin r) (a : Fin (populationCount (p s.succ)))
    (b : Fin (populationCount (p s.castSucc))) :
    compressedWhitened p w (Sum.inr (Sum.inl ⟨s,a,b⟩)) =
      ∑ i, ∑ j, populationBasis (p s.succ) a i *
        w (Sum.inr (Sum.inl (s,i,j))) * populationBasis (p s.castSucc) b j := by
  classical
  simp only [compressedWhitened, Fintype.sum_sum_type, Fintype.sum_prod_type,
    compressionRow, zero_mul, Finset.sum_const_zero, zero_add, add_zero, ite_mul]
  simp only [Finset.sum_ite_irrel, Finset.sum_const_zero, Finset.sum_ite_eq,
    Finset.mem_univ, ↓reduceIte]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  rw [whiten_internal]
  ring

theorem compressedWhitened_readout {d N r : ℕ} (p : LayerPartitions N r)
    (w : Weights d N r) (a : Fin (populationCount (p (Fin.last r)))) :
    compressedWhitened p w (Sum.inr (Sum.inr a)) =
      Real.sqrt (N : ℝ) * ∑ i, populationBasis (p (Fin.last r)) a i *
        w (Sum.inr (Sum.inr i)) := by
  simp only [compressedWhitened, Fintype.sum_sum_type, Fintype.sum_prod_type,
    compressionRow, zero_mul, Finset.sum_const_zero, zero_add]
  simp only [whiten, coordinateScale, smallVariance, one_pow, one_mul,
    Real.sqrt_div, Real.sqrt_one, div_one, div_div, one_div, Real.sqrt_inv, inv_inv]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  simp only [div_eq_mul_inv, inv_inv]
  ring

theorem compressedWeights_first_active {d N r Q : ℕ} (hd : 0 < d) (hN : 0 < N)
    (p : LayerPartitions N r) (hq : ∀ s, populationCount (p s) ≤ Q)
    (w : Weights d N r) (a : Fin (populationCount (p 0))) (j : Fin (d+1)) :
    compressedWeights p hq w (Sum.inl (Fin.castLE (hq 0) a,j)) =
      compressedWhitened p w (Sum.inl (a,j)) / Real.sqrt (d : ℝ) := by
  have hds : Real.sqrt (d : ℝ) ≠ 0 := (Real.sqrt_pos.mpr (by exact_mod_cast hd)).ne'
  rw [compressedWhitened_first]
  simp only [compressedWeights, Matrix.mul_apply, Matrix.transpose_apply,
    paddedBasis_active, firstMatrix, Matrix.of_apply, Finset.sum_div,
    Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  simp only [whiten, coordinateScale, smallVariance, one_pow, mul_one,
    Real.sqrt_div, one_mul, Real.sqrt_mul (Nat.cast_nonneg N), Real.sqrt_inv]
  field_simp
  rw [Real.sqrt_div (Nat.cast_nonneg N)]
  field_simp
  <;> ring

theorem compressedWeights_internal_active {d N r Q : ℕ}
    (p : LayerPartitions N r) (hq : ∀ s, populationCount (p s) ≤ Q)
    (w : Weights d N r) (s : Fin r) (a : Fin (populationCount (p s.succ)))
    (b : Fin (populationCount (p s.castSucc))) :
    compressedWeights p hq w (Sum.inr (Sum.inl
      (s,Fin.castLE (hq s.succ) a,Fin.castLE (hq s.castSucc) b))) =
        compressedWhitened p w (Sum.inr (Sum.inl ⟨s,a,b⟩)) := by
  rw [compressedWhitened_internal]
  simp only [compressedWeights, Matrix.mul_apply, Matrix.transpose_apply,
    paddedBasis_active, internalMatrix, Matrix.of_apply, Finset.sum_mul]
  rw [Finset.sum_comm]

theorem compressedWeights_readout_active {d N r Q : ℕ}
    (p : LayerPartitions N r) (hq : ∀ s, populationCount (p s) ≤ Q)
    (w : Weights d N r) (a : Fin (populationCount (p (Fin.last r)))) :
    compressedWeights p hq w (Sum.inr (Sum.inr (Fin.castLE (hq (Fin.last r)) a))) =
      compressedWhitened p w (Sum.inr (Sum.inr a)) := by
  rw [compressedWhitened_readout]
  simp [compressedWeights, Matrix.mulVec, dotProduct, paddedBasis_active,
    Matrix.transpose_apply, readoutVector]

theorem compressedWhitened_abs_le_sqrt {d N r : ℕ} (p : LayerPartitions N r)
    (w : Weights d N r) {J : ℝ} (hJ : compressedEnergy p w ≤ J)
    (a : CompressedIndex d N r p) : |compressedWhitened p w a| ≤ Real.sqrt J := by
  have hsq : (compressedWhitened p w a)^2 ≤ J :=
    (Finset.single_le_sum (fun i _ => sq_nonneg (compressedWhitened p w i))
      (Finset.mem_univ a)).trans hJ
  have hJ0 : 0 ≤ J := (sq_nonneg _).trans hsq
  have hs := Real.sq_sqrt hJ0
  have ha := sq_abs (compressedWhitened p w a)
  nlinarith [Real.sqrt_nonneg J, abs_nonneg (compressedWhitened p w a)]


theorem compressedWeights_first_inactive {d N r Q : ℕ}
    (p : LayerPartitions N r) (hq : ∀ s, populationCount (p s) ≤ Q)
    (w : Weights d N r) (a : Fin Q) (ha : populationCount (p 0) ≤ a.val)
    (j : Fin (d+1)) : compressedWeights p hq w (Sum.inl (a,j)) = 0 := by
  simp [compressedWeights, Matrix.mul_apply, Matrix.transpose_apply,
    paddedBasis_inactive _ _ _ ha]

theorem compressedWeights_internal_inactive_left {d N r Q : ℕ}
    (p : LayerPartitions N r) (hq : ∀ s, populationCount (p s) ≤ Q)
    (w : Weights d N r) (s : Fin r) (a b : Fin Q)
    (ha : populationCount (p s.succ) ≤ a.val) :
    compressedWeights p hq w (Sum.inr (Sum.inl (s,a,b))) = 0 := by
  simp [compressedWeights, Matrix.mul_apply, Matrix.transpose_apply,
    paddedBasis_inactive _ _ _ ha]

theorem compressedWeights_internal_inactive_right {d N r Q : ℕ}
    (p : LayerPartitions N r) (hq : ∀ s, populationCount (p s) ≤ Q)
    (w : Weights d N r) (s : Fin r) (a b : Fin Q)
    (hb : populationCount (p s.castSucc) ≤ b.val) :
    compressedWeights p hq w (Sum.inr (Sum.inl (s,a,b))) = 0 := by
  simp [compressedWeights, Matrix.mul_apply, paddedBasis_inactive _ _ _ hb]

theorem compressedWeights_readout_inactive {d N r Q : ℕ}
    (p : LayerPartitions N r) (hq : ∀ s, populationCount (p s) ≤ Q)
    (w : Weights d N r) (a : Fin Q) (ha : populationCount (p (Fin.last r)) ≤ a.val) :
    compressedWeights p hq w (Sum.inr (Sum.inr a)) = 0 := by
  simp [compressedWeights, Matrix.mulVec, Matrix.transpose_apply, dotProduct,
    paddedBasis_inactive _ _ _ ha]

/-- The energy-controlled compressed parameters are the actual coefficients of
an ordinary ReLU network, after division by sqrt(d) in the first layer. -/
theorem compressedWeights_abs_le_sqrt {d N r Q : ℕ} (hd : 0 < d) (hN : 0 < N)
    (p : LayerPartitions N r) (hq : ∀ s, populationCount (p s) ≤ Q)
    (w : Weights d N r) {J : ℝ} (hJ : compressedEnergy p w ≤ J)
    (i : WeightIndex d Q r) : |compressedWeights p hq w i| ≤ Real.sqrt J := by
  rcases i with ⟨a,j⟩ | ⟨s,a,b⟩ | a
  · by_cases ha : a.val < populationCount (p 0)
    · let aa : Fin (populationCount (p 0)) := ⟨a.val,ha⟩
      have he : Fin.castLE (hq 0) aa = a := rfl
      rw [← he, compressedWeights_first_active hd hN, abs_div,
        abs_of_nonneg (Real.sqrt_nonneg _)]
      have hds : 1 ≤ Real.sqrt (d : ℝ) := Real.one_le_sqrt.mpr (by exact_mod_cast hd)
      have hcoord := compressedWhitened_abs_le_sqrt p w hJ (Sum.inl (aa,j))
      apply (div_le_iff₀ (by linarith : 0 < Real.sqrt (d : ℝ))).mpr
      nlinarith [Real.sqrt_nonneg J]
    · rw [compressedWeights_first_inactive p hq w a (Nat.le_of_not_gt ha) j, abs_zero]
      exact Real.sqrt_nonneg J
  · by_cases ha : a.val < populationCount (p s.succ)
    · by_cases hb : b.val < populationCount (p s.castSucc)
      · let aa : Fin (populationCount (p s.succ)) := ⟨a.val,ha⟩
        let bb : Fin (populationCount (p s.castSucc)) := ⟨b.val,hb⟩
        have hea : Fin.castLE (hq s.succ) aa = a := rfl
        have heb : Fin.castLE (hq s.castSucc) bb = b := rfl
        rw [← hea, ← heb, compressedWeights_internal_active]
        exact compressedWhitened_abs_le_sqrt p w hJ _
      · rw [compressedWeights_internal_inactive_right p hq w s a b (Nat.le_of_not_gt hb), abs_zero]
        exact Real.sqrt_nonneg J
    · rw [compressedWeights_internal_inactive_left p hq w s a b (Nat.le_of_not_gt ha), abs_zero]
      exact Real.sqrt_nonneg J
  · by_cases ha : a.val < populationCount (p (Fin.last r))
    · let aa : Fin (populationCount (p (Fin.last r))) := ⟨a.val,ha⟩
      have he : Fin.castLE (hq (Fin.last r)) aa = a := rfl
      rw [← he, compressedWeights_readout_active]
      exact compressedWhitened_abs_le_sqrt p w hJ _
    · rw [compressedWeights_readout_inactive p hq w a (Nat.le_of_not_gt ha), abs_zero]
      exact Real.sqrt_nonneg J

end NeuralGeneralization.BatchTwoMerging
