import Paulsen.HorizontalGaussianMean
import Paulsen.NormalizedTangentNoise

/-!
# Concentration of the actual horizontal quadratic diagonal

Each row error is a symmetric quadratic form with operator norm at most one
and squared Frobenius norm controlled by `2 (d+n pᵢ²)`. The Gaussian tail uses
the actual retained noise factor and is centered at its actual expectation.
-/

namespace Paulsen
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory
noncomputable section

def horizontalQuadraticCoefficient {n d : ℕ} (U : Frame n d) (i : Fin n) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  Matrix.diagonal (fun p => if p.1 = i then 1 else 0) -
    Matrix.kronecker (1 : Matrix (Fin n) (Fin n) ℝ) (Matrix.vecMulVec (U i) (U i))

theorem horizontalQuadraticCoefficient_isHermitian {n d : ℕ} (U : Frame n d) (i : Fin n) :
    (horizontalQuadraticCoefficient U i).IsHermitian := by
  apply Matrix.isHermitian_iff_isSymm.mpr
  ext p q
  simp only [horizontalQuadraticCoefficient, Matrix.transpose_sub, Matrix.diagonal_transpose,
    Matrix.kronecker, ← Matrix.kroneckerMap_transpose, Matrix.transpose_one,
    Matrix.transpose_vecMulVec]

theorem horizontalQuadraticCoefficient_mulVec {n d : ℕ} (U : Frame n d) (i r : Fin n)
    (z : Fin n × Fin d → ℝ) (a : Fin d) :
    (horizontalQuadraticCoefficient U i *ᵥ z) (r, a) =
      (if r = i then z (r, a) else 0) - U i a * ∑ b, U i b * z (r, b) := by
  rw [horizontalQuadraticCoefficient, Matrix.sub_mulVec]
  simp only [Matrix.mulVec_diagonal, Pi.sub_apply]
  have hk : (Matrix.kronecker (1 : Matrix (Fin n) (Fin n) ℝ)
      (Matrix.vecMulVec (U i) (U i)) *ᵥ z) (r,a) = U i a * ∑ b, U i b * z (r,b) := by
    simp only [Matrix.mulVec, dotProduct, Matrix.kronecker, Matrix.kronecker_apply,
      Fintype.sum_prod_type, Matrix.one_apply, Matrix.vecMulVec_apply]
    simp only [ite_mul, one_mul, zero_mul, Finset.sum_ite_irrel, Finset.sum_const_zero]
    simp only [Finset.sum_ite_eq, Finset.mem_univ, if_true]
    rw [Finset.mul_sum]
    simp only [mul_assoc]
  rw [hk]
  simp only [ite_mul, one_mul, zero_mul]

theorem horizontalQuadraticCoefficient_identity {n d : ℕ} (U H : Frame n d) (i : Fin n) :
    matrixQuadratic (horizontalQuadraticCoefficient U i) (fun p => H p.1 p.2) =
      horizontalQuadraticDiagonal U H i := by
  have heq : matrixQuadratic (horizontalQuadraticCoefficient U i) (fun p => H p.1 p.2) =
      ∑ r, ∑ a, H r a * ((if r = i then H r a else 0) -
        U i a * ∑ b, U i b * H r b) := by
    simp only [matrixQuadratic, mul_assoc, ← Finset.mul_sum]
    change (∑ p, H p.1 p.2 * (horizontalQuadraticCoefficient U i *ᵥ (fun q => H q.1 q.2)) p) = _
    rw [Fintype.sum_prod_type]
    simp_rw [horizontalQuadraticCoefficient_mulVec]
  rw [heq]
  simp only [mul_sub, Finset.sum_sub_distrib]
  have hfirst : (∑ r, ∑ a, H r a * (if r = i then H r a else 0)) = rowNormSq H i := by
    simp [mul_ite, Finset.sum_ite_irrel, rowNormSq, pow_two]
  have hsecond : (∑ r, ∑ a, H r a * (U i a * ∑ b, U i b * H r b)) =
      rowNormSq (U * H.transpose) i := by
    simp only [rowNormSq, Matrix.mul_apply, Matrix.transpose_apply, ← mul_assoc,
      ← Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro r _
    rw [show (∑ a, H r a * U i a) = ∑ a, U i a * H r a by
      apply Finset.sum_congr rfl; intro a _; ring]
    ring
  rw [hfirst, hsecond]
  rfl

/-- A rank-one contraction and its complementary map both contract norm. -/
theorem row_rankOne_contraction_sq {d : ℕ} (u x : Fin d → ℝ)
    (hu : (∑ a, u a ^ 2) ≤ 1) :
    (∑ a, (u a * ∑ b, u b * x b) ^ 2) ≤ ∑ a, x a ^ 2 ∧
      (∑ a, (x a - u a * ∑ b, u b * x b) ^ 2) ≤ ∑ a, x a ^ 2 := by
  let t := ∑ b, u b * x b
  let p := ∑ a, u a ^ 2
  let q := ∑ a, x a ^ 2
  have hp : 0 ≤ p := Finset.sum_nonneg fun a _ => sq_nonneg _
  have hq : 0 ≤ q := Finset.sum_nonneg fun a _ => sq_nonneg _
  have ht : t ^ 2 ≤ p * q := Finset.sum_mul_sq_le_sq_mul_sq _ u x
  have htq : t ^ 2 ≤ q := ht.trans (mul_le_of_le_one_left hq hu)
  have hfirst : (∑ a, (u a * t) ^ 2) = p * t ^ 2 := by
    simp only [mul_pow, ← Finset.sum_mul, p]
  have hsecond : (∑ a, (x a - u a * t) ^ 2) = q - 2 * t ^ 2 + p * t ^ 2 := by
    calc
      _ = ∑ a, (x a ^ 2 - 2 * (u a * x a) * t + u a ^ 2 * t ^ 2) := by
        apply Finset.sum_congr rfl; intro a _; ring
      _ = _ := by
        simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.sum_mul,
          ← Finset.mul_sum, p, q, t]
        ring
  change (∑ a, (u a * t) ^ 2) ≤ q ∧ (∑ a, (x a - u a * t) ^ 2) ≤ q
  rw [hfirst, hsecond]
  constructor
  · exact (mul_le_of_le_one_left (sq_nonneg t) hu).trans htq
  · nlinarith [mul_le_of_le_one_left (sq_nonneg t) hu]

/-- The sharp contraction bound uses the block structure of the coefficient. -/
theorem horizontalQuadraticCoefficient_operator_norm_le {n d : ℕ}
    (U : Frame n d) (i : Fin n) (hp : rowNormSq U i ≤ 1) :
    ‖(Matrix.toEuclideanLin (horizontalQuadraticCoefficient U i)).toContinuousLinearMap‖ ≤ 1 := by
  apply ContinuousLinearMap.opNorm_le_bound _ (by norm_num)
  intro x
  have hs : ‖Matrix.toEuclideanLin (horizontalQuadraticCoefficient U i) x‖ ^ 2 ≤ ‖x‖ ^ 2 := by
    simp only [EuclideanSpace.real_norm_sq_eq, Matrix.toLpLin_apply, Fintype.sum_prod_type]
    apply Finset.sum_le_sum
    intro r _
    have hr := row_rankOne_contraction_sq (U i) (fun a => x (r, a)) hp
    simp_rw [horizontalQuadraticCoefficient_mulVec]
    by_cases hri : r = i
    · simpa only [if_pos hri] using hr.2
    · simpa only [if_neg hri, zero_sub, neg_sq] using hr.1
  change ‖Matrix.toEuclideanLin (horizontalQuadraticCoefficient U i) x‖ ≤ 1 * ‖x‖
  nlinarith [norm_nonneg x, norm_nonneg (Matrix.toEuclideanLin (horizontalQuadraticCoefficient U i) x)]

/-- Squared coefficient energy preserves the useful leverage scale. -/
theorem horizontalQuadraticCoefficient_sq_sum_le {n d : ℕ} (U : Frame n d) (i : Fin n) :
    (∑ p, ∑ q, (horizontalQuadraticCoefficient U i p q) ^ 2) ≤
      2 * ((d : ℝ) + n * rowNormSq U i ^ 2) := by
  let D : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
    Matrix.diagonal (fun p => if p.1 = i then 1 else 0)
  let K := Matrix.kronecker (1 : Matrix (Fin n) (Fin n) ℝ) (Matrix.vecMulVec (U i) (U i))
  have hD : (∑ p, ∑ q, (D p q) ^ 2) = (d : ℝ) := by
    simp only [D, Matrix.diagonal_apply, ite_pow, zero_pow (by decide : 2 ≠ 0),
      one_pow, Finset.sum_ite_eq, Finset.mem_univ, if_true]
    rw [Fintype.sum_prod_type]
    change (∑ r : Fin n, ∑ _a : Fin d, if r = i then (1 : ℝ) else 0) = d
    rw [Finset.sum_comm]
    simp
  have hK : (∑ p, ∑ q, (K p q) ^ 2) = (n : ℝ) * rowNormSq U i ^ 2 := by
    simp only [K, Matrix.kronecker, Fintype.sum_prod_type, Matrix.kronecker_apply,
      Matrix.one_apply, Matrix.vecMulVec_apply]
    simp only [ite_mul, one_mul, zero_mul, ite_pow, zero_pow (by decide : 2 ≠ 0),
      Finset.sum_ite_irrel, Finset.sum_const_zero]
    simp only [Finset.sum_ite_eq, Finset.mem_univ, if_true, mul_pow,
      ← Finset.mul_sum, ← Finset.sum_mul]
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    change rowNormSq U i * ((n : ℝ) * rowNormSq U i) = _
    ring
  calc
    _ ≤ ∑ p, ∑ q, (2 * (D p q) ^ 2 + 2 * (K p q) ^ 2) := by
      apply Finset.sum_le_sum
      intro p _
      apply Finset.sum_le_sum
      intro q _
      change (D p q - K p q) ^ 2 ≤ _
      nlinarith [sq_nonneg (D p q + K p q)]
    _ = _ := by
      simp only [Finset.sum_add_distrib, ← Finset.mul_sum, hD, hK]
      ring

theorem horizontalQuadraticCoefficient_sq_sum_le_six_d {n d : ℕ}
    (U : Frame n d) (i : Fin n) (hp : rowNormSq U i ≤ 1)
    (hnear : rowNormSq U i ≤ 2 * (d : ℝ) / n) :
    (∑ p, ∑ q, (horizontalQuadraticCoefficient U i p q) ^ 2) ≤ 6 * d := by
  have hn : (0 : ℝ) < n := Nat.cast_pos.mpr (lt_of_le_of_lt (Nat.zero_le i.val) i.isLt)
  have hnp : (n : ℝ) * rowNormSq U i ≤ 2 * d := by
    simpa only [mul_comm] using (le_div_iff₀ hn).mp hnear
  have hp2 : rowNormSq U i ^ 2 ≤ rowNormSq U i := by
    nlinarith [rowNormSq_nonneg U i]
  have hnp2 := (mul_le_mul_of_nonneg_left hp2 hn.le).trans hnp
  exact (horizontalQuadraticCoefficient_sq_sum_le U i).trans (by nlinarith)

variable {κ : Type*} [Fintype κ] [DecidableEq κ]

theorem horizontalQuadraticDiagonal_linear_image {n d : ℕ} (U : Frame n d)
    (C : Matrix (Fin n × Fin d) κ ℝ) (g : EuclideanSpace ℝ κ) (i : Fin n) :
    horizontalQuadraticDiagonal U (frameOfVector (Matrix.toEuclideanLin C g)) i =
      euclideanQuadratic (horizontalQuadraticCoefficient U i) (Matrix.toEuclideanLin C g) := by
  rw [euclideanQuadratic_eq_matrixQuadratic]
  exact (horizontalQuadraticCoefficient_identity U
    (frameOfVector (Matrix.toEuclideanLin C g)) i).symm

/-- The coefficient trace is exactly the actual Gaussian mean. -/
theorem horizontalQuadraticDiagonal_mean_eq_trace {n d : ℕ} (U : Frame n d)
    (C : Matrix (Fin n × Fin d) κ ℝ) (i : Fin n) :
    (∫ g, horizontalQuadraticDiagonal U (frameOfVector (Matrix.toEuclideanLin C g)) i
      ∂stdGaussian (EuclideanSpace ℝ κ)) =
        (C.transpose * horizontalQuadraticCoefficient U i * C).trace := by
  simp_rw [horizontalQuadraticDiagonal_linear_image, euclideanQuadratic_linear_image]
  exact integral_euclideanQuadratic_stdGaussian _
    (isHermitian_quadratic_pullback _ (horizontalQuadraticCoefficient_isHermitian U i) C)

/-- Tail of an actual horizontal quadratic row error, centered at its expectation.
The source Gaussian may have any finite dimension and the factor may be singular. -/
theorem horizontalQuadraticDiagonal_gaussianImage_abs_tail {n d : ℕ}
    (U : Frame n d) (hd : 0 < d) (i : Fin n)
    (hp : rowNormSq U i ≤ 1) (hnear : rowNormSq U i ≤ 2 * (d : ℝ) / n)
    (C : Matrix (Fin n × Fin d) κ ℝ) {σ u : ℝ} (hσ : 0 < σ) (hu : 0 ≤ u)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ σ) :
    (stdGaussian (EuclideanSpace ℝ κ)).real {g |
      u ≤ |horizontalQuadraticDiagonal U (frameOfVector (Matrix.toEuclideanLin C g)) i -
        ∫ h, horizontalQuadraticDiagonal U (frameOfVector (Matrix.toEuclideanLin C h)) i
          ∂stdGaussian (EuclideanSpace ℝ κ)|} ≤
      2 * Real.exp (-min (u ^ 2 / (96 * σ ^ 2 * d)) (u / (16 * σ))) := by
  simp_rw [horizontalQuadraticDiagonal_mean_eq_trace, horizontalQuadraticDiagonal_linear_image]
  have h := euclideanQuadratic_linear_image_abs_tail_of_bounds
    (horizontalQuadraticCoefficient U i) (horizontalQuadraticCoefficient_isHermitian U i)
    C σ 1 (6 * d) u hσ (by norm_num) (by positivity) hu hC
    (horizontalQuadraticCoefficient_operator_norm_le U i hp)
    (horizontalQuadraticCoefficient_sq_sum_le_six_d U i hp hnear)
  have he : 16 * (σ ^ 2 * (6 * (d : ℝ))) = 96 * σ ^ 2 * d := by ring
  simpa only [mul_one, he] using h

/-- The concrete retained Gaussian has Bernstein fluctuations on scale √d/n. -/
theorem normalizedTangentNoise_quadratic_abs_tail {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0 < n) (hd : 0 < d) (i : Fin n)
    (hnear : rowNormSq U i ≤ 2 * (d : ℝ) / n) {ρ u : ℝ} (hρ : 0 ≤ ρ) (hu : 0 ≤ u) :
    (stdGaussian (FrameVector n d)).real {g |
      u ≤ |horizontalQuadraticDiagonal U
        (frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g)) i -
          ∫ h, horizontalQuadraticDiagonal U
            (frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) h)) i
              ∂stdGaussian (FrameVector n d)|} ≤
      2 * Real.exp (-min ((n : ℝ) ^ 2 * u ^ 2 / (96 * d)) ((n : ℝ) * u / 16)) := by
  have hn' : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have h := horizontalQuadraticDiagonal_gaussianImage_abs_tail U hd i (hU.leverage_le_one i)
    hnear (normalizedTangentNoiseFactor U ρ) (one_div_pos.mpr hn') hu
    (normalizedTangentNoiseFactor_operator_norm_sq_le hU hρ)
  have he₁ : u ^ 2 / (96 * (1 / (n : ℝ)) ^ 2 * d) =
      (n : ℝ) ^ 2 * u ^ 2 / (96 * d) := by field_simp
  have he₂ : u / (16 * (1 / (n : ℝ))) = (n : ℝ) * u / 16 := by field_simp
  simpa only [he₁, he₂] using h

/-- Simultaneous control of all centered quadratic diagonal errors. -/
theorem normalizedTangentNoise_quadratic_max_abs_tail {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0 < n) (hd : 0 < d)
    (hnear : ∀ i, rowNormSq U i ≤ 2 * (d : ℝ) / n)
    {ρ u : ℝ} (hρ : 0 ≤ ρ) (hu : 0 ≤ u) :
    (stdGaussian (FrameVector n d)).real {g | ∃ i,
      u ≤ |horizontalQuadraticDiagonal U
        (frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g)) i -
          ∫ h, horizontalQuadraticDiagonal U
            (frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) h)) i
              ∂stdGaussian (FrameVector n d)|} ≤
      2 * n * Real.exp (-min ((n : ℝ) ^ 2 * u ^ 2 / (96 * d)) ((n : ℝ) * u / 16)) := by
  let bad (i : Fin n) : Set (FrameVector n d) := {g |
    u ≤ |horizontalQuadraticDiagonal U
      (frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g)) i -
        ∫ h, horizontalQuadraticDiagonal U
          (frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) h)) i
            ∂stdGaussian (FrameVector n d)|}
  change (stdGaussian (FrameVector n d)).real {g | ∃ i, g ∈ bad i} ≤ _
  rw [show {g | ∃ i, g ∈ bad i} = ⋃ i, bad i by ext g; simp]
  calc
    _ ≤ ∑ i, (stdGaussian (FrameVector n d)).real (bad i) := measureReal_iUnion_fintype_le bad
    _ ≤ ∑ _i : Fin n, 2 * Real.exp (-min ((n : ℝ) ^ 2 * u ^ 2 / (96 * d)) ((n : ℝ) * u / 16)) :=
      Finset.sum_le_sum fun i _ => normalizedTangentNoise_quadratic_abs_tail hU hn hd i (hnear i) hρ hu
    _ = _ := by simp; ring

end
end Paulsen
