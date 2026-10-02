import Paulsen.Linear.ManyRowRemainder
import Paulsen.HugeSeedAssembly
import Paulsen.HorizontalRetraction

/-!
# Dense reference graph with operator-norm control

Copy of the deterministic huge-seed assembly in which the Frobenius proxy
`‖Z₀‖_F²` for the operator norm of the reference noise is replaced by an
operator-norm bound `‖Z₀‖² ≤ Q₀`. This is what allows `t² ≍ η` to be an
absolute constant while `d` is unbounded.
-/

namespace Paulsen.Linear

open Paulsen
open scoped BigOperators

noncomputable section

theorem rowTangentNoiseFactor_toContinuousLinearMap' {n d : ℕ} (X : Frame n d) :
    (Matrix.toEuclideanLin (rowTangentNoiseFactor X)).toContinuousLinearMap =
      (1 / Real.sqrt (n : ℝ)) • (rowTangentSpace X).starProjection := by
  apply ContinuousLinearMap.ext
  intro z
  exact rowTangentNoiseFactor_apply X z

theorem rowTangentNoiseFactor_operator_norm_sq_le' {n d : ℕ} (X : Frame n d) (hn : 0 < n) :
    ‖(Matrix.toEuclideanLin (rowTangentNoiseFactor X)).toContinuousLinearMap‖ ^ 2 ≤
      1 / (n : ℝ) := by
  rw [rowTangentNoiseFactor_toContinuousLinearMap', norm_smul, Real.norm_eq_abs,
    abs_of_nonneg (by positivity : 0 ≤ 1 / Real.sqrt (n : ℝ)), mul_pow]
  have hproj : ‖(rowTangentSpace X).starProjection‖ ^ 2 ≤ 1 := by
    have h := pow_le_pow_left₀ (norm_nonneg _) (rowTangentSpace X).starProjection_norm_le 2
    simpa only [one_pow] using h
  calc
    (1 / Real.sqrt (n : ℝ)) ^ 2 * ‖(rowTangentSpace X).starProjection‖ ^ 2 ≤
        (1 / Real.sqrt (n : ℝ)) ^ 2 := by
      simpa only [mul_one] using mul_le_mul_of_nonneg_left hproj (sq_nonneg _)
    _ = 1 / (n : ℝ) := by rw [div_pow, one_pow, Real.sq_sqrt (Nat.cast_nonneg n)]

theorem frameEnergy_le_of_operator_norm_le {n d : ℕ} (H : Frame n d) (K : ℝ)
    (hK : ‖(Matrix.toEuclideanLin H).toContinuousLinearMap‖ ≤ K) (x : Fin d → ℝ) :
    frameEnergy H x ≤ K ^ 2 * vectorNormSq x := by
  apply (frameEnergy_le_operator_norm_sq H x).trans
  apply mul_le_mul_of_nonneg_right _ (vectorNormSq_nonneg x)
  exact pow_le_pow_left₀ (norm_nonneg _) hK 2

theorem frameEnergy_add_smul_le {n d : ℕ} (X Z : Frame n d) (t : ℝ) (x : Fin d → ℝ) :
    frameEnergy (X + t • Z) x ≤ 2 * frameEnergy X x + 2 * t ^ 2 * frameEnergy Z x := by
  unfold frameEnergy
  rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro i _
  have hrow : (∑ j, (X + t • Z) i j * x j) = (∑ j, X i j * x j) + t * (∑ j, Z i j * x j) := by
    simp only [Matrix.add_apply, Matrix.smul_apply, smul_eq_mul, add_mul, Finset.sum_add_distrib,
      Finset.mul_sum, mul_assoc]
  rw [hrow]
  nlinarith [sq_nonneg ((∑ j, X i j * x j) - t * (∑ j, Z i j * x j))]

theorem tangentSeed_operator_norm_sq_le_op {n d : ℕ}
    (X Z : Frame n d) (a t η Q : ℝ) (ha : 0 < a)
    (hη : 0 ≤ η) (hQ : 0 ≤ Q) (hXp : IsNearlyParseval η X)
    (hZ : ∀ x, frameEnergy Z x ≤ Q * vectorNormSq x) :
    ‖(Matrix.toEuclideanLin (tangentSeed X Z a t)).toContinuousLinearMap‖ ^ 2 ≤
      2 * (1 + η) + 2 * t ^ 2 * Q := by
  apply euclidean_operator_norm_sq_le_of_frameEnergy _ _ (by positivity)
  intro x
  apply (frameEnergy_tangentSeed_le_perturbed X Z a t ha x).trans
  apply (frameEnergy_add_smul_le X Z t x).trans
  have h1 := (hXp x).2
  have h2 := mul_le_mul_of_nonneg_left (hZ x) (show 0 ≤ 2 * t ^ 2 by positivity)
  nlinarith

theorem tangentSeed_gram_coupling_le_op {n d : ℕ}
    (X Z Z₀ : Frame n d) (a t η δ Q₀ C : ℝ) (ha : 0 < a)
    (hη : 0 ≤ η) (hδ : 0 ≤ δ) (hQ₀ : 0 ≤ Q₀) (hXn : ∀ i, rowNormSq X i = a)
    (hXp : IsNearlyParseval η X) (hZ : ∀ i, rowDot X Z i = 0)
    (hZ₀ : ∀ i, rowDot X Z₀ i = 0)
    (hVp : IsNearlyParseval δ (tangentSeed X Z a t))
    (hZ₀op : ∀ x, frameEnergy Z₀ x ≤ Q₀ * vectorNormSq x) (hC : sqDistance Z₀ Z ≤ C) :
    sqDistance (frameProjection (tangentSeed X Z₀ a t))
      (frameProjection (tangentSeed X Z a t)) ≤
        2 * (2 * (1 + η) + 2 * t ^ 2 * Q₀ + 1 + δ) * t ^ 2 * C := by
  have hnorm₀ := tangentSeed_operator_norm_sq_le_op X Z₀ a t η Q₀ ha hη hQ₀ hXp hZ₀op
  have hnorm := hVp.euclidean_operator_norm_sq_le hδ
  have hdist := (tangentSeed_sqDistance_le X Z₀ Z a t ha hXn hZ₀ hZ).trans
    (mul_le_mul_of_nonneg_left hC (sq_nonneg t))
  apply (sqDistance_gram_le (tangentSeed X Z₀ a t) (tangentSeed X Z a t)).trans
  calc
    _ ≤ (2 * ((2 * (1 + η) + 2 * t ^ 2 * Q₀) + (1 + δ))) * (t ^ 2 * C) :=
      mul_le_mul (by linarith) hdist (sqDistance_nonneg _ _) (by positivity)
    _ = _ := by ring

/-- Deterministic many-row seed implication with operator-norm control of the
reference noise. -/
theorem manyRow_seed_correction_of_budgets {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (X Z Z₀ : Frame n d)
    (η t δ γ ρ H Q₀ C : ℝ)
    (hXn : IsEqualNorm X) (hXp : IsNearlyParseval η X) (hη : 0 ≤ η)
    (hZ : ∀ i, rowDot X Z i = 0) (hZ₀ : ∀ i, rowDot X Z₀ i = 0)
    (hVp : IsNearlyParseval δ (tangentSeed X Z ((d : ℝ) / n) t))
    (hδ0 : 0 ≤ δ) (hδhalf : δ ≤ 1 / 2)
    (hH : (∑ i, rowNormSq Z i) ≤ H) (hQ₀ : 0 ≤ Q₀)
    (hZ₀op : ∀ x, frameEnergy Z₀ x ≤ Q₀ * vectorNormSq x)
    (hC : sqDistance Z₀ Z ≤ C) (hγ : 0 < γ) (hγa : γ ≤ (d : ℝ) / n) (hρ : 0 < ρ)
    (hdense : ∀ i, 17 * n ≤ 20 * (largeNeighbors
      (fun i j => (frameProjection (tangentSeed X Z₀ ((d : ℝ) / n) t) i j) ^ 2)
        (4 * γ) i).card)
    (hrow : 12 * ((d : ℝ) / n) * δ ^ 2 + 2 * ρ ≤ γ / 20)
    (hcount : 10 * (2 * (2 * (1 + η) + 2 * t ^ 2 * Q₀ + 1 + δ) * t ^ 2 * C) ≤ ρ * n)
    (hleverage : (2 * ((d : ℝ) / n) / ρ) *
      (2 * (2 * (1 + η) + 2 * t ^ 2 * Q₀ + 1 + δ) * t ^ 2 * C) ≤ 1 / 4)
    (hsmall : 224 * δ * ((d : ℝ) / n) ≤ γ) :
    HasCorrection X (2 * t ^ 2 * H + 4 * δ ^ 2 * (d : ℝ) + 64 * δ * (d : ℝ)) := by
  have ha : 0 < (d : ℝ) / n := div_pos (Nat.cast_pos.mpr hd)
    (Nat.cast_pos.mpr (lt_of_lt_of_le hd hdn))
  have hVn := tangentSeed_isEqualNorm X Z t ha hXn hZ
  have he := tangentSeed_gram_coupling_le_op X Z Z₀ ((d : ℝ) / n) t η δ Q₀ C
    ha hη hδ0 hQ₀ hXn hXp hZ hZ₀ hVp hZ₀op hC
  have hc := correction_of_dense_reference_gram_generic hd hdn
    (tangentSeed X Z ((d : ℝ) / n) t)
    (frameProjection (tangentSeed X Z₀ ((d : ℝ) / n) t)) δ γ ρ _
    hVn hVp hδ0 hδhalf hγ hγa hρ hdense he hrow hcount hleverage hsmall
  have hdistance : sqDistance X (tangentSeed X Z ((d : ℝ) / n) t) ≤ t ^ 2 * H := by
    rw [sqDistance_symm]
    exact (tangentSeed_distance_from_input X Z ((d : ℝ) / n) t ha hXn hZ).trans
      (mul_le_mul_of_nonneg_left hH (sq_nonneg t))
  convert hc.transfer hdistance using 1
  ring

/-- The many-row deterministic implication instantiated with the coupled
Gaussian noises: the centred remainder, operator-norm bounds on `Z` and `Z₀`,
and the dense reference core give a correction. -/
theorem manyRow_conditioned_correction_of_sample {n d : ℕ}
    (hd : 0 < d) (hdn : d ≤ n) (X : Frame n d)
    (η t δ γ ρ H C b Q M : ℝ) (g : FrameVector n d)
    (hXn : IsEqualNorm X) (hXp : IsNearlyParseval η X) (hη : 0 ≤ η)
    (hQ : 0 ≤ Q) (hM0 : 0 ≤ M)
    (hH : (∑ i, rowNormSq (conditionedNoise X g) i) ≤ H)
    (hC : sqDistance (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
      (conditionedNoise X g) ≤ C)
    (hb : ‖conditionedFluctuation X g‖ ≤ b)
    (hZop : ∀ x, frameEnergy (conditionedNoise X g) x ≤ Q * vectorNormSq x)
    (hZ₀op : ∀ x, frameEnergy (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g)) x
      ≤ Q * vectorNormSq x)
    (hM : rowFourthDeviation ((d : ℝ) / n) (conditionedNoise X g) ≤ M)
    (hδbound : η + t ^ 2 * (η + (d : ℝ) ^ 2 / n + b) +
      (2 * |t| ^ 3 * (Real.sqrt (1 + η) * Real.sqrt M) +
        t ^ 4 * (Q + Real.sqrt Q * Real.sqrt M + (1 + η) +
          Real.sqrt (1 + η) * Real.sqrt M)) ≤ δ)
    (hδ0 : 0 ≤ δ) (hδhalf : δ ≤ 1 / 2)
    (hγ : 0 < γ) (hγa : γ ≤ (d : ℝ) / n) (hρ : 0 < ρ)
    (hdense : ∀ i, 17 * n ≤ 20 * (largeNeighbors
      (fun i j => (frameProjection (tangentSeed X
        (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
        ((d : ℝ) / n) t) i j) ^ 2) (4 * γ) i).card)
    (hrow : 12 * ((d : ℝ) / n) * δ ^ 2 + 2 * ρ ≤ γ / 20)
    (hcount : 10 * (2 * (2 * (1 + η) + 2 * t ^ 2 * Q + 1 + δ) * t ^ 2 * C) ≤ ρ * n)
    (hleverage : (2 * ((d : ℝ) / n) / ρ) *
      (2 * (2 * (1 + η) + 2 * t ^ 2 * Q + 1 + δ) * t ^ 2 * C) ≤ 1 / 4)
    (hsmall : 224 * δ * ((d : ℝ) / n) ≤ γ) :
    HasCorrection X (2 * t ^ 2 * H + 4 * δ ^ 2 * (d : ℝ) + 64 * δ * (d : ℝ)) := by
  have hn : 0 < n := lt_of_lt_of_le hd hdn
  have hVp : IsNearlyParseval δ (conditionedSeed X t g) :=
    (conditionedSeed_nearParseval_centred X hn hd hXn η t b Q M hη hQ hM0 hXp g hb hZop hM).2.mono
      hδbound
  exact manyRow_seed_correction_of_budgets hd hdn X (conditionedNoise X g)
    (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
    η t δ γ ρ H Q C hXn hXp hη
    (tangentNoiseFactor_constraints X g).1 (rowTangentNoiseFactor_constraints X g)
    hVp hδ0 hδhalf hH hQ hZ₀op hC hγ hγa hρ hdense hrow hcount hleverage hsmall

end

end Paulsen.Linear
