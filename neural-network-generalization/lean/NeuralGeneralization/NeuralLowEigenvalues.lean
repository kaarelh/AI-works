import NeuralGeneralization.KernelPoissonOdd

/-! Explicit polynomial lower bounds at the lowest actual neural levels. -/
noncomputable section
namespace NeuralGeneralization
open scoped BigOperators

/-- The bias contributes exactly one unit out of `d+1` to the degree-zero
coefficient before applying the neural nonlinearity. -/
theorem biasedProfile_id_coefficient_empty (d : ℕ) :
    walshCoefficients (biasedProfile (d := d) id) ∅ = 1/((d : ℝ)+1) := by
  classical
  have hz (i : Fin d) : (∑ x : ClippingCube d,cubeCoordinateSign (x i)) = 0 := by
    have h := walshCharacter_orthogonal (∅ : Finset (Fin d)) {i}
    simpa [walshCharacter] using h
  have hsum : (∑ x : ClippingCube d,∑ i,cubeCoordinateSign (x i)) = 0 := by
    rw [Finset.sum_comm]
    simp [hz]
  have hM : (Fintype.card (ClippingCube d) : ℝ) ≠ 0 :=
    ne_of_gt (Nat.cast_pos.mpr Fintype.card_pos)
  unfold walshCoefficients uniformCubeMean biasedProfile
  simp only [id_eq,walshCharacter,Finset.prod_empty,mul_one,← Finset.sum_div,
    Finset.sum_add_distrib,hsum,add_zero,Finset.sum_const,Finset.card_univ,nsmul_eq_mul,mul_one]
  field_simp

/-- The actual constant-mode eigenvalue is at least a depth-dependent
constant divided by `d+1`, including the depth-zero identity. -/
theorem arcsineProfile_coefficient_empty_lower (d k : ℕ) :
    (2/Real.pi)^k/((d : ℝ)+1) ≤ walshCoefficients (arcsineProfile d k) ∅ := by
  have h := iterated_profile_coefficient_lower (fun j => arcsineProfile d j)
    arcsineLinkCoefficient (fun n => 2*n+1)
    (arcsineProfile_coefficient_nonneg d 0)
    (fun n => (arcsineLinkCoefficient_pos n).le) (by norm_num)
    (arcsineProfile_series d) k ∅
  have hbase : walshCoefficients (arcsineProfile d 0) ∅=1/((d : ℝ)+1) :=
    biasedProfile_id_coefficient_empty d
  simpa only [arcsineLinkCoefficient_zero,hbase,mul_one_div] using h

theorem arcsineProfile_coefficient_singleton_lower (d k : ℕ) (i : Fin d) :
    (2/Real.pi)^k/((d : ℝ)+1) ≤ walshCoefficients (arcsineProfile d k) {i} := by
  have hpair := arcsineProfile_coefficient_even_pair k ∅ i (by simp) (by simp)
  change walshCoefficients (arcsineProfile d k) ∅ =
    walshCoefficients (arcsineProfile d k) {i} at hpair
  rw [← hpair]
  exact arcsineProfile_coefficient_empty_lower d k

end NeuralGeneralization
