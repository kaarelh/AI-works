import NeuralGeneralization.BatchTwoImprovedBankSampling
import NeuralGeneralization.BatchTwoImprovedCoefficientLayerClipping
import NeuralGeneralization.RobustEntropyFeatureNormalization

/-! Physical normalization and clipping budgets for the actual sharp bank. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
open MeasureTheory ProbabilityTheory InnerProductSpace WithLp
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling RobustGaussianGeometry RobustCompressionReconstruction
open RobustCompression RobustCompressionClipping RobustCompressionGaussian
open RobustCompressionLayerGaussian RobustEntropy Classical
variable {A : Type*} [MeasurableSpace A] {N q m D : ℕ}
namespace SharpBankData

theorem sharpParameters_idealMean_inner (b : SharpBankData A N D m q) (hN : 0 < N)
    (t BH : ℝ) (θ : A) (i : Fin D) :
    (b.sharpParameters t BH).idealMean θ i =
      ⟪wholeClip BH (b.active θ i),activeCoordinateVector (b.basis θ) (normalizedFeature (b.feature θ))⟫ := by
  rw [←sourceRows_feature_eq_coordinates _ _ hN]
  simp only [finiteAverage,inner_smul_right,inner_sum,inner_smul_right]
  change (∑ j, linearEvaluation (b.sources θ j) (b.clippedActive BH θ i)*b.feature θ j)/(N:ℝ) = _
  rw [div_eq_mul_inv,mul_comm]
  congr 1
  apply Finset.sum_congr rfl
  intro j _
  rw [mul_comm]
  congr 1

theorem sharpParameters_idealVariance_le (b : SharpBankData A N D m q) (hN : 0 < N)
    (t BH : ℝ) (θ : A) (hh : ∀ j, |b.feature θ j| ≤ 1) (i : Fin D) :
    ((b.sharpParameters t BH).idealVariance θ i:ℝ) ≤ t^2 := by
  change (((t^2*‖queryResidual (b.basis θ) (normalizedFeature (b.feature θ))‖^2).toNNReal):ℝ) ≤ _
  rw [Real.coe_toNNReal _ (mul_nonneg (sq_nonneg _) (sq_nonneg _))]
  have hn := source_feature_residual_norm_le_one (b.basis θ) (b.feature θ) hN hh
  have hsq : ‖queryResidual (b.basis θ) (normalizedFeature (b.feature θ))‖^2 ≤ 1 := by
    nlinarith [norm_nonneg (queryResidual (b.basis θ) (normalizedFeature (b.feature θ)))]
  nlinarith only [mul_le_mul_of_nonneg_left hsq (sq_nonneg t)]

theorem sharpParameters_coefficient_energy (b : SharpBankData A N D m q)
    (hN : 0 < N) (hq : 0 < q) (hm : 0 < m)
    {t : ℝ} (ht : |t| ≤ 1) (BH : ℝ) (θ : A) (hh : ∀ j, |b.feature θ j| ≤ 1) :
    (∑ j, ((b.sharpParameters t BH).scale/Real.sqrt (m:ℝ)*
      (b.sharpParameters t BH).sourceFeature θ j)^2) ≤ 2 := by
  let u := b.sources θ
  have ha := sourceMultiplier_le_two hN hq u (sourceRows_trace (b.basis θ) hN)
  have hpos := fun j => (sourceMultiplier_pos hN hq u j).le
  have ht2 : t^2 ≤ 1 := by nlinarith [sq_abs t,abs_nonneg t]
  have hsum : (∑ j, sourceMultiplier u (b.indices θ j)*(b.feature θ (b.indices θ j))^2) ≤ 2*m := by
    calc
      _ ≤ ∑ _ : Fin m, (2:ℝ) := by
        apply Finset.sum_le_sum
        intro j _
        have hh2 : (b.feature θ (b.indices θ j))^2 ≤ 1 := by
          nlinarith [abs_le.mp (hh (b.indices θ j))]
        calc
          _ ≤ 2*1 := mul_le_mul (ha _) hh2 (sq_nonneg _) (by norm_num)
          _ = _ := by ring
      _ = _ := by simp; ring
  have hmR : (0:ℝ) < m := Nat.cast_pos.mpr hm
  change (∑ j, (t/Real.sqrt (m:ℝ)*(Real.sqrt (sourceMultiplier u (b.indices θ j))*
    b.feature θ (b.indices θ j)))^2) ≤ _
  simp only [mul_pow,div_pow,Real.sq_sqrt hmR.le,Real.sq_sqrt (hpos _),← Finset.mul_sum]
  calc
    _ ≤ (1/(m:ℝ))*(2*m) := mul_le_mul
      (div_le_div_of_nonneg_right ht2 hmR.le) hsum
        (Finset.sum_nonneg (fun j _ => mul_nonneg (hpos _) (sq_nonneg _))) (by positivity)
    _ = 2 := by field_simp

end SharpBankData
end NeuralGeneralization.BatchTwoImprovedWeightedSampling
