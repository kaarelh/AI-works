import NeuralGeneralization.BatchTwoContinuousCompression

/-! Width-independent input sensitivity from the actual weighted energy. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel CompressionSampling Compression

theorem augmented_difference_sq_sum {d : ℕ} (x y : RealInput d) :
    (∑ j, (augmentedInput x j-augmentedInput y j)^2)=∑ i, (x i-y i)^2 := by
  simp [augmentedInput, Fin.sum_univ_succ]

theorem firstHidden_input_distance {d N r : ℕ} (hN : 0 < N)
    (φ : ℝ → ℝ) (hφ : ∀ t s, |φ t-φ s| ≤ |t-s|)
    (w : Weights d N r) {K η : ℝ} (hw : weightedSquaredNorm w ≤ K) (hη : 0 ≤ η)
    (x y : RealInput d) (hxy : ∀ i, |x i-y i| ≤ η) :
    squaredDistance (firstHidden φ w x) (firstHidden φ w y) ≤ (N : ℝ)*K*η^2 := by
  let F := ∑ i : Fin N, ∑ j : Fin (d+1), w (Sum.inl (i,j))^2
  have hF0 : 0 ≤ F := by dsimp [F]; positivity
  have hF : (d : ℝ)/N*F ≤ K := by
    unfold weightedSquaredNorm at hw
    have hi : 0 ≤ ∑ s : Fin r, ∑ i : Fin N, ∑ j : Fin N, w (Sum.inr (Sum.inl (s,i,j)))^2 := by positivity
    have ho : 0 ≤ (N : ℝ)*∑ i : Fin N, w (Sum.inr (Sum.inr i))^2 := by positivity
    change (d : ℝ)/N*F+_+_ ≤ K at hw
    linarith
  have hNF := mul_le_mul_of_nonneg_right hF (Nat.cast_nonneg N : (0 : ℝ) ≤ N)
  have hN0 : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
  have hcancel : ((d : ℝ)/N*F)*(N : ℝ)=(d : ℝ)*F := by field_simp
  rw [hcancel] at hNF
  have hdist : (∑ j, (augmentedInput x j-augmentedInput y j)^2) ≤ (d : ℝ)*η^2 := by
    rw [augmented_difference_sq_sum]
    calc
      _ ≤ ∑ _i : Fin d, η^2 := by
        apply Finset.sum_le_sum
        intro i _
        have h := (sq_le_sq₀ (abs_nonneg (x i-y i)) hη).mpr (hxy i)
        simpa only [sq_abs] using h
      _ = _ := by simp
  have hh := activated_matrix_squaredDistance_le φ hφ
    (fun i j => w (Sum.inl (i,j))) (augmentedInput x) (augmentedInput y)
  change squaredDistance (firstHidden φ w x) (firstHidden φ w y) ≤
    F*(∑ j, (augmentedInput x j-augmentedInput y j)^2) at hh
  calc
    _ ≤ F*(∑ j, (augmentedInput x j-augmentedInput y j)^2) := hh
    _ ≤ F*((d : ℝ)*η^2) := mul_le_mul_of_nonneg_left hdist hF0
    _ ≤ (N : ℝ)*K*η^2 := by nlinarith [mul_le_mul_of_nonneg_right hNF (sq_nonneg η)]

theorem output_input_squared_distance {d N r : ℕ} (hN : 0 < N)
    (φ : ℝ → ℝ) (hφ : ∀ t s, |φ t-φ s| ≤ |t-s|)
    (w : Weights d N r) {K η : ℝ} (hK : 0 ≤ K) (hw : weightedSquaredNorm w ≤ K) (hη : 0 ≤ η)
    (x y : RealInput d) (hxy : ∀ i, |x i-y i| ≤ η) :
    (output φ w x-output φ w y)^2 ≤ K^(r+2)*η^2 := by
  have hs := suffix_readout_squaredDistance_le φ hφ w 0 (firstHidden φ w x) (firstHidden φ w y)
  have hs' : (output φ w x-output φ w y)^2 ≤
      suffixSquaredGain w 0*squaredDistance (firstHidden φ w x) (firstHidden φ w y) := by
    simpa [output,finalHidden,linearReadout,hiddenSuffix] using hs
  have hg := suffixSquaredGain_le_of_cost hN w hK hw 0
  simp only [Nat.sub_zero] at hg
  have hdist := firstHidden_input_distance hN φ hφ w hw hη x y hxy
  have hN0 : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
  calc
    _ ≤ suffixSquaredGain w 0*squaredDistance (firstHidden φ w x) (firstHidden φ w y) := hs'
    _ ≤ (K/(N : ℝ)*K^r)*((N : ℝ)*K*η^2) := mul_le_mul hg hdist
      (by unfold squaredDistance; positivity) (by positivity)
    _ = _ := by rw [pow_add]; norm_num; field_simp

/-- The integer-power bound is intentionally loose; at fixed depth it is
polynomial in energy and independent of learner width. -/
theorem output_input_stability {d N r : ℕ} (hN : 0 < N)
    (φ : ℝ → ℝ) (hφ : ∀ t s, |φ t-φ s| ≤ |t-s|)
    (w : Weights d N r) {K η : ℝ} (hK : 1 ≤ K) (hw : weightedSquaredNorm w ≤ K) (hη : 0 ≤ η)
    (x y : RealInput d) (hxy : ∀ i, |x i-y i| ≤ η) :
    |output φ w x-output φ w y| ≤ K^(r+2)*η := by
  have hK0 : 0 ≤ K := by linarith
  have hs := output_input_squared_distance hN φ hφ w hK0 hw hη x y hxy
  have hp : 1 ≤ K^(r+2) := one_le_pow₀ hK
  apply abs_le_of_sq_le_sq _ (by positivity)
  have hpp : K^(r+2) ≤ (K^(r+2))^2 := by nlinarith
  nlinarith [mul_le_mul_of_nonneg_right hpp (sq_nonneg η)]

end NeuralGeneralization.BatchTwoContinuous
