import NeuralGeneralization.NetworkRowRotation

/-! # Translating whitened cylinder radii to actual network coefficients -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel

variable {d N r : ℕ}

@[simp] theorem whiten_internal (w : Weights d N r) (s : Fin r) (i j : Fin N) :
    whiten w (Sum.inr (Sum.inl (s,i,j))) = w (Sum.inr (Sum.inl (s,i,j))) := by
  simp [whiten, coordinateScale, smallVariance]

theorem coordinate_error_of_whitened (hd : 0 < d) (hN : 0 < N)
    (w v : Weights d N r) (q : WeightIndex d N r) (η : ℝ)
    (h : |whiten w q-whiten v q| ≤ η) :
    |w q-v q| ≤ η*coordinateScale d N r q := by
  unfold whiten at h
  rw [← sub_div, abs_div, abs_of_pos (coordinateScale_pos hd hN q)] at h
  exact (div_le_iff₀ (coordinateScale_pos hd hN q)).mp h

theorem input_scale_mul_sigma_le (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 ≤ σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (i : Fin N) (j : Fin (d+1)) :
    coordinateScale d N r (Sum.inl (i,j))*σ ≤ 1 := by
  have hdR : (1:ℝ) ≤ d := by exact_mod_cast hd
  have hpos := (coordinateScale_pos (r := r) hd hN (Sum.inl (i,j))).le
  have hsq := coordinateScale_sq (r := r) hd hN (Sum.inl (i,j))
  simp only [smallVariance, one_pow, mul_one] at hsq
  apply (sq_le_sq₀ (mul_nonneg hpos hσ) (by norm_num : (0:ℝ) ≤ 1)).mp
  rw [mul_pow, hsq]
  have heq : (N:ℝ)/d*σ^2 = ((N:ℝ)*σ^2)/d := by ring
  rw [heq]
  apply (div_le_iff₀ (Nat.cast_pos.mpr hd)).mpr
  norm_num
  linarith

theorem readout_scale_mul_sigma_le (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 ≤ σ) (hscale : (N:ℝ)*σ^2 ≤ 1) (i : Fin N) :
    coordinateScale d N r (Sum.inr (Sum.inr i))*σ ≤ 1/(N:ℝ) := by
  have hNR : (0:ℝ) < N := Nat.cast_pos.mpr hN
  have hpos := (coordinateScale_pos (r := r) hd hN (Sum.inr (Sum.inr i))).le
  have hsq := coordinateScale_sq (r := r) hd hN (Sum.inr (Sum.inr i))
  simp only [smallVariance, one_pow] at hsq
  apply (sq_le_sq₀ (mul_nonneg hpos hσ) (by positivity : (0:ℝ) ≤ 1/N)).mp
  rw [mul_pow, hsq]
  rw [one_div_pow]
  apply (le_div_iff₀ (sq_pos_of_pos hNR)).mpr
  have heq : (1/(N:ℝ)*σ^2)*(N:ℝ)^2 = (N:ℝ)*σ^2 := by field_simp
  rw [heq]
  exact hscale

theorem input_error_of_whitened (hd : 0 < d) (hN : 0 < N)
    {σ ρ : ℝ} (hσ : 0 ≤ σ) (hρ : 0 ≤ ρ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (w v : Weights d N r) (i : Fin N) (j : Fin (d+1))
    (h : |whiten w (Sum.inl (i,j))-whiten v (Sum.inl (i,j))| ≤ ρ*σ) :
    |w (Sum.inl (i,j))-v (Sum.inl (i,j))| ≤ ρ := by
  have hh := coordinate_error_of_whitened hd hN w v (Sum.inl (i,j)) (ρ*σ) h
  have hs := mul_le_mul_of_nonneg_left (input_scale_mul_sigma_le (r := r) hd hN hσ hscale i j) hρ
  nlinarith

theorem readout_error_of_whitened (hd : 0 < d) (hN : 0 < N)
    {σ ρ : ℝ} (hσ : 0 ≤ σ) (hρ : 0 ≤ ρ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (w v : Weights d N r) (i : Fin N)
    (h : |whiten w (Sum.inr (Sum.inr i))-whiten v (Sum.inr (Sum.inr i))| ≤ ρ*σ) :
    |w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))| ≤ ρ/N := by
  have hh := coordinate_error_of_whitened hd hN w v (Sum.inr (Sum.inr i)) (ρ*σ) h
  have hs := mul_le_mul_of_nonneg_left (readout_scale_mul_sigma_le (r := r) hd hN hσ hscale i) hρ
  exact hh.trans (by simpa only [div_eq_mul_inv, one_mul, mul_one, mul_assoc, mul_left_comm, mul_comm] using hs)

/-- Selected center coordinates cost no more energy than the complete teacher. -/
theorem selected_rotated_center_energy_le (hd : 0 < d) (hN : 0 < N)
    (U : EuclideanSpace ℝ (Fin N) ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin N))
    (p : WeightIndex d N r → Prop) [DecidablePred p] (v : Weights d N r) :
    (∑ q : {q // p q}, (rotateInternalRows U (whiten v) q.val)^2) ≤
      weightedSquaredNorm v := by
  classical
  have hall : (∑ q, (rotateInternalRows U (whiten v) q)^2) = weightedSquaredNorm v := by
    rw [rotateInternalRows_squareSum, ← weightedSquaredNorm_unwhiten hd hN,
      unwhiten_whiten hd hN]
  rw [← hall]
  calc
    _ = ∑ q ∈ Finset.univ.filter p, (rotateInternalRows U (whiten v) q)^2 := by
      exact (Finset.sum_subtype (Finset.univ.filter p)
        (show ∀ q, q ∈ Finset.univ.filter p ↔ p q by simp)
        (fun q => (rotateInternalRows U (whiten v) q)^2)).symm
    _ ≤ _ := Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
      (fun q hq hq' => sq_nonneg _)

end NeuralGeneralization.ConcreteModel
