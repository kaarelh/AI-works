import Paulsen.TangentSeed
import Paulsen.TangentSubspace
import Paulsen.GaussianLinearImage

/-!
# Quadratic coefficients of the conditioned tangent seed

The ambient quadratic error is a family of symmetric quadratic forms on the
vectorized noise matrix. Their total squared coefficient norm is O(nd²).
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory

namespace Paulsen

noncomputable section

/-- Symmetrized matrix unit, representing the product of two coordinates. -/
def coordinatePairCoefficient {d : ℕ} (j k : Fin d) : Matrix (Fin d) (Fin d) ℝ :=
  Matrix.of fun u v =>
    (((if u = j then 1 else 0) * (if v = k then 1 else 0)) +
      ((if u = k then 1 else 0) * (if v = j then 1 else 0))) / 2

def tangentRowCoefficient {n d : ℕ} (X : Frame n d) (a : ℝ)
    (i : Fin n) (j k : Fin d) : Matrix (Fin d) (Fin d) ℝ :=
  coordinatePairCoefficient j k - (X i j * X i k / a) • (1 : Matrix (Fin d) (Fin d) ℝ)

/-- Block-diagonal coefficient matrix on the vectorized noise space. -/
def tangentQuadraticCoefficient {n d : ℕ} (X : Frame n d) (a : ℝ)
    (j k : Fin d) : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  Matrix.of fun p q => if p.1 = q.1 then
    tangentRowCoefficient X a p.1 j k p.2 q.2 else 0

theorem coordinatePairCoefficient_symmetric {d : ℕ} (j k : Fin d) :
    (coordinatePairCoefficient j k).IsSymm := by
  ext u v
  simp only [coordinatePairCoefficient, Matrix.transpose_apply, Matrix.of_apply]
  ring

theorem tangentRowCoefficient_symmetric {n d : ℕ} (X : Frame n d) (a : ℝ)
    (i : Fin n) (j k : Fin d) : (tangentRowCoefficient X a i j k).IsSymm := by
  apply Matrix.IsSymm.sub (coordinatePairCoefficient_symmetric j k)
  exact Matrix.IsSymm.smul Matrix.isSymm_one _

theorem tangentQuadraticCoefficient_isHermitian {n d : ℕ} (X : Frame n d) (a : ℝ)
    (j k : Fin d) : (tangentQuadraticCoefficient X a j k).IsHermitian := by
  apply Matrix.isHermitian_iff_isSymm.mpr
  ext p q
  simp only [tangentQuadraticCoefficient, Matrix.transpose_apply, Matrix.of_apply]
  by_cases hpq : p.1 = q.1
  · rw [if_pos hpq, if_pos hpq.symm, ← hpq]
    exact congrArg (fun M : Matrix (Fin d) (Fin d) ℝ => M p.2 q.2)
      (tangentRowCoefficient_symmetric X a p.1 j k).eq
  · rw [if_neg hpq, if_neg (Ne.symm hpq)]

theorem coordinatePairCoefficient_quadratic {d : ℕ} (j k : Fin d) (z : Fin d → ℝ) :
    matrixQuadratic (coordinatePairCoefficient j k) z = z j * z k := by
  simp only [matrixQuadratic, coordinatePairCoefficient, Matrix.of_apply,
    add_div, mul_add, add_mul, Finset.sum_add_distrib]
  simp only [mul_ite, ite_div, ite_mul, zero_mul, mul_zero, mul_one, zero_div]
  simp
  ring

theorem tangentRowCoefficient_quadratic {n d : ℕ} (X : Frame n d) (a : ℝ)
    (i : Fin n) (j k : Fin d) (z : Fin d → ℝ) :
    matrixQuadratic (tangentRowCoefficient X a i j k) z =
      z j * z k - ((∑ u, z u ^ 2) / a) * X i j * X i k := by
  rw [tangentRowCoefficient, matrixQuadratic_sub, coordinatePairCoefficient_quadratic]
  have hdiag : (X i j * X i k / a) • (1 : Matrix (Fin d) (Fin d) ℝ) =
      Matrix.diagonal (fun _ => X i j * X i k / a) := by
    ext u v
    simp [Matrix.one_apply, Matrix.diagonal_apply]
  rw [hdiag, matrixQuadratic_diagonal, ← Finset.mul_sum]
  ring

/-- The coefficient matrices give the actual entries of the ambient error. -/
theorem tangentQuadraticCoefficient_identity {n d : ℕ}
    (X Z : Frame n d) (a : ℝ) (j k : Fin d) :
    matrixQuadratic (tangentQuadraticCoefficient X a j k) (fun p => Z p.1 p.2) =
      tangentQuadratic X Z a j k := by
  have hblock (i : Fin n) (u : Fin d) :
      (∑ q : Fin n × Fin d, Z i u *
        tangentQuadraticCoefficient X a j k (i, u) q * Z q.1 q.2) =
        ∑ v, Z i u * tangentRowCoefficient X a i j k u v * Z i v := by
    simp only [tangentQuadraticCoefficient, Matrix.of_apply, Fintype.sum_prod_type]
    change (∑ l : Fin n, ∑ v : Fin d,
      Z i u * (if i = l then tangentRowCoefficient X a i j k u v else 0) * Z l v) = _
    rw [Finset.sum_eq_single i]
    · simp only [if_true]
    · intro l _ hli
      apply Finset.sum_eq_zero
      intro v _
      rw [if_neg (Ne.symm hli), mul_zero, zero_mul]
    · simp
  unfold matrixQuadratic
  rw [Fintype.sum_prod_type]
  change (∑ i, ∑ u, ∑ q : Fin n × Fin d, Z i u *
    tangentQuadraticCoefficient X a j k (i,u) q * Z q.1 q.2) = _
  simp_rw [hblock]
  change (∑ i, matrixQuadratic (tangentRowCoefficient X a i j k) (Z i)) = _
  simp only [tangentRowCoefficient_quadratic, tangentQuadratic, Matrix.of_apply,
    tangentRatio, rowNormSq]

theorem coordinatePairCoefficient_sq_sum_le {d : ℕ} (j k : Fin d) :
    (∑ u, ∑ v, (coordinatePairCoefficient j k u v) ^ 2) ≤ 1 := by
  have hpoint : ∀ u v : Fin d, (coordinatePairCoefficient j k u v) ^ 2 ≤
      (((if u = j then (1 : ℝ) else 0) * (if v = k then 1 else 0)) ^ 2 +
        ((if u = k then (1 : ℝ) else 0) * (if v = j then 1 else 0)) ^ 2) / 2 := by
    intro u v
    unfold coordinatePairCoefficient
    simp only [Matrix.of_apply]
    nlinarith [sq_nonneg
      (((if u = j then (1 : ℝ) else 0) * (if v = k then 1 else 0)) -
        ((if u = k then (1 : ℝ) else 0) * (if v = j then 1 else 0)))]
  calc
    _ ≤ ∑ u, ∑ v,
        (((if u = j then (1 : ℝ) else 0) * (if v = k then 1 else 0)) ^ 2 +
          ((if u = k then (1 : ℝ) else 0) * (if v = j then 1 else 0)) ^ 2) / 2 :=
      Finset.sum_le_sum (fun u _ => Finset.sum_le_sum (fun v _ => hpoint u v))
    _ = 1 := by
      simp only [add_div, Finset.sum_add_distrib, ← Finset.sum_div,
        ite_pow, one_pow, zero_pow (by decide : 2 ≠ 0), mul_ite, mul_one, mul_zero]
      norm_num


theorem tangentRowCoefficient_sq_sum_le {n d : ℕ} (X : Frame n d) (a : ℝ)
    (i : Fin n) (j k : Fin d) :
    (∑ u, ∑ v, tangentRowCoefficient X a i j k u v ^ 2) ≤
      2 + 2 * d * (X i j * X i k / a) ^ 2 := by
  have hpoint (u v : Fin d) : tangentRowCoefficient X a i j k u v ^ 2 ≤
      2 * coordinatePairCoefficient j k u v ^ 2 +
        2 * ((X i j * X i k / a) * (1 : Matrix (Fin d) (Fin d) ℝ) u v) ^ 2 := by
    change (coordinatePairCoefficient j k u v -
      (X i j * X i k / a) * (1 : Matrix (Fin d) (Fin d) ℝ) u v) ^ 2 ≤ _
    nlinarith [sq_nonneg (coordinatePairCoefficient j k u v +
      (X i j * X i k / a) * (1 : Matrix (Fin d) (Fin d) ℝ) u v)]
  calc
    _ ≤ ∑ u, ∑ v, (2 * coordinatePairCoefficient j k u v ^ 2 +
        2 * ((X i j * X i k / a) * (1 : Matrix (Fin d) (Fin d) ℝ) u v) ^ 2) :=
      Finset.sum_le_sum fun u _ => Finset.sum_le_sum fun v _ => hpoint u v
    _ = 2 * (∑ u, ∑ v, coordinatePairCoefficient j k u v ^ 2) +
        2 * d * (X i j * X i k / a) ^ 2 := by
      simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
      simp [Matrix.one_apply, mul_ite, ite_pow]
      ring
    _ ≤ _ := by nlinarith [coordinatePairCoefficient_sq_sum_le j k]

theorem tangentQuadraticCoefficient_sq_sum {n d : ℕ} (X : Frame n d) (a : ℝ)
    (j k : Fin d) :
    (∑ p, ∑ q, tangentQuadraticCoefficient X a j k p q ^ 2) =
      ∑ i, ∑ u, ∑ v, tangentRowCoefficient X a i j k u v ^ 2 := by
  rw [Fintype.sum_prod_type]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro u _
  rw [Fintype.sum_prod_type]
  change (∑ l : Fin n, ∑ v : Fin d,
    (if i = l then tangentRowCoefficient X a i j k u v else 0) ^ 2) = _
  rw [Finset.sum_eq_single i]
  · simp only [if_true]
  · intro l _ hli
    simp only [if_neg (Ne.symm hli), zero_pow (by decide : 2 ≠ 0), Finset.sum_const_zero]
  · simp

theorem normalized_row_pair_sq_sum {n d : ℕ} (X : Frame n d) {a : ℝ}
    (ha : 0 < a) (i : Fin n) (hi : rowNormSq X i = a) :
    (∑ j, ∑ k, (X i j * X i k / a) ^ 2) = 1 := by
  calc
    _ = (∑ j, X i j ^ 2) * (∑ k, X i k ^ 2) / a ^ 2 := by
      simp only [div_pow, mul_pow, ← Finset.sum_div, ← Finset.mul_sum,
        ← Finset.sum_mul]
    _ = 1 := by rw [← rowNormSq, hi]; field_simp

/-- The quadratic error has total squared coefficient norm at most `4 n d²`. -/
theorem tangentQuadraticCoefficient_total_sq_le {n d : ℕ}
    (X : Frame n d) {a : ℝ} (ha : 0 < a)
    (hrows : ∀ i, rowNormSq X i = a) :
    (∑ j, ∑ k, ∑ p, ∑ q, tangentQuadraticCoefficient X a j k p q ^ 2) ≤
      4 * n * d ^ 2 := by
  simp_rw [tangentQuadraticCoefficient_sq_sum]
  have hi (i : Fin n) :
      (∑ j, ∑ k, ∑ u, ∑ v, tangentRowCoefficient X a i j k u v ^ 2) ≤
        2 * d ^ 2 + 2 * d := by
    calc
      _ ≤ ∑ j, ∑ k, (2 + 2 * d * (X i j * X i k / a) ^ 2) :=
        Finset.sum_le_sum fun j _ => Finset.sum_le_sum fun k _ =>
          tangentRowCoefficient_sq_sum_le X a i j k
      _ = _ := by
        simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
        rw [normalized_row_pair_sq_sum X ha i (hrows i)]
        simp
        ring
  calc
    _ = ∑ i, ∑ j, ∑ k, ∑ u, ∑ v, tangentRowCoefficient X a i j k u v ^ 2 := by
      calc
        _ = ∑ j, ∑ i, ∑ k, ∑ u, ∑ v,
            tangentRowCoefficient X a i j k u v ^ 2 :=
          Finset.sum_congr rfl fun j _ => Finset.sum_comm
        _ = _ := Finset.sum_comm
    _ ≤ ∑ _i : Fin n, (2 * (d : ℝ) ^ 2 + 2 * d) :=
      Finset.sum_le_sum fun i _ => hi i
    _ ≤ _ := by
      simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
      have hd : (d : ℝ) ≤ (d : ℝ) ^ 2 := by
        simpa only [pow_two, Nat.cast_mul] using (Nat.cast_le.mpr (Nat.le_mul_self d) :
          (d : ℝ) ≤ ((d * d : ℕ) : ℝ))
      nlinarith [mul_nonneg (show (0 : ℝ) ≤ n by positivity)
        (sub_nonneg.mpr hd)]


variable {κ : Type*} [Fintype κ] [DecidableEq κ]

/-- Exact Gaussian mean of the quadratic error, expressed by traces of pullbacks. -/
def tangentQuadraticMean {n d : ℕ} (X : Frame n d) (a : ℝ)
    (C : Matrix (Fin n × Fin d) κ ℝ) : Matrix (Fin d) (Fin d) ℝ :=
  Matrix.of fun j k => (C.transpose * tangentQuadraticCoefficient X a j k * C).trace

theorem tangentQuadratic_linear_image {n d : ℕ} (X : Frame n d) (a : ℝ)
    (C : Matrix (Fin n × Fin d) κ ℝ) (g : EuclideanSpace ℝ κ) (j k : Fin d) :
    tangentQuadratic X (frameOfVector (Matrix.toEuclideanLin C g)) a j k =
      euclideanQuadratic (C.transpose * tangentQuadraticCoefficient X a j k * C) g := by
  rw [← euclideanQuadratic_linear_image, euclideanQuadratic_eq_matrixQuadratic]
  exact (tangentQuadraticCoefficient_identity X
    (frameOfVector (Matrix.toEuclideanLin C g)) a j k).symm

theorem tangentQuadratic_centered_memLp {n d : ℕ} (X : Frame n d) (a : ℝ)
    (C : Matrix (Fin n × Fin d) κ ℝ) (j k : Fin d) :
    MemLp (fun g : EuclideanSpace ℝ κ =>
      tangentQuadratic X (frameOfVector (Matrix.toEuclideanLin C g)) a j k -
        tangentQuadraticMean X a C j k) 2 (stdGaussian (EuclideanSpace ℝ κ)) := by
  simp_rw [tangentQuadratic_linear_image]
  exact memLp_centered_euclideanQuadratic_stdGaussian _
    (isHermitian_quadratic_pullback _ (tangentQuadraticCoefficient_isHermitian X a j k) C)

theorem integral_tangentQuadratic_centered {n d : ℕ} (X : Frame n d) (a : ℝ)
    (C : Matrix (Fin n × Fin d) κ ℝ) (j k : Fin d) :
    (∫ g : EuclideanSpace ℝ κ,
      tangentQuadratic X (frameOfVector (Matrix.toEuclideanLin C g)) a j k -
        tangentQuadraticMean X a C j k ∂stdGaussian (EuclideanSpace ℝ κ)) = 0 := by
  simp_rw [tangentQuadratic_linear_image]
  exact integral_centered_euclideanQuadratic_stdGaussian _
    (isHermitian_quadratic_pullback _ (tangentQuadraticCoefficient_isHermitian X a j k) C)

/-- The trace formula is the actual entrywise expectation. -/
theorem integral_tangentQuadratic {n d : ℕ} (X : Frame n d) (a : ℝ)
    (C : Matrix (Fin n × Fin d) κ ℝ) (j k : Fin d) :
    (∫ g : EuclideanSpace ℝ κ,
      tangentQuadratic X (frameOfVector (Matrix.toEuclideanLin C g)) a j k
        ∂stdGaussian (EuclideanSpace ℝ κ)) = tangentQuadraticMean X a C j k := by
  have h := integral_tangentQuadratic_centered X a C j k
  have hint := (tangentQuadratic_centered_memLp X a C j k).integrable (by norm_num)
  have hraw : Integrable (fun g : EuclideanSpace ℝ κ =>
      tangentQuadratic X (frameOfVector (Matrix.toEuclideanLin C g)) a j k)
      (stdGaussian (EuclideanSpace ℝ κ)) := by
    exact (hint.add (integrable_const (tangentQuadraticMean X a C j k))).congr
      (Filter.Eventually.of_forall fun g => sub_add_cancel _ _)
  rw [integral_sub hraw (integrable_const _)] at h
  simpa using sub_eq_zero.mp h

/-- A general covariance-factor bound for the Frobenius mean square fluctuation. -/
theorem integral_sq_tangentQuadratic_centered_le {n d : ℕ}
    (X : Frame n d) {a : ℝ} (ha : 0 < a) (hrows : ∀ i, rowNormSq X i = a)
    (C : Matrix (Fin n × Fin d) κ ℝ) (σ : ℝ)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ σ) :
    (∫ g : EuclideanSpace ℝ κ, ∑ j, ∑ k,
      (tangentQuadratic X (frameOfVector (Matrix.toEuclideanLin C g)) a j k -
        tangentQuadraticMean X a C j k) ^ 2 ∂stdGaussian (EuclideanSpace ℝ κ)) ≤
      8 * σ ^ 2 * n * d ^ 2 := by
  have hint (j k : Fin d) := (tangentQuadratic_centered_memLp X a C j k).integrable_sq
  rw [integral_finsetSum Finset.univ (fun j _ => integrable_finsetSum _ (fun k _ => hint j k))]
  simp_rw [integral_finsetSum Finset.univ (fun k _ => hint _ k)]
  have hentry (j k : Fin d) :
      (∫ g : EuclideanSpace ℝ κ,
        (tangentQuadratic X (frameOfVector (Matrix.toEuclideanLin C g)) a j k -
          tangentQuadraticMean X a C j k) ^ 2 ∂stdGaussian (EuclideanSpace ℝ κ)) ≤
        2 * σ ^ 2 * ∑ p, ∑ q, tangentQuadraticCoefficient X a j k p q ^ 2 := by
    simp_rw [tangentQuadratic_linear_image]
    change (∫ g : EuclideanSpace ℝ κ,
      (euclideanQuadratic (C.transpose * tangentQuadraticCoefficient X a j k * C) g -
        (C.transpose * tangentQuadraticCoefficient X a j k * C).trace) ^ 2
        ∂stdGaussian (EuclideanSpace ℝ κ)) ≤ _
    rw [integral_sq_centered_euclideanQuadratic_stdGaussian _
      (isHermitian_quadratic_pullback _ (tangentQuadraticCoefficient_isHermitian X a j k) C)]
    have hv := variance_euclideanQuadratic_linear_image_le _
      (tangentQuadraticCoefficient_isHermitian X a j k) C σ hC
    rw [variance_euclideanQuadratic_linear_image _
      (tangentQuadraticCoefficient_isHermitian X a j k) C] at hv
    exact hv
  calc
    _ ≤ ∑ j, ∑ k, 2 * σ ^ 2 * ∑ p, ∑ q,
        tangentQuadraticCoefficient X a j k p q ^ 2 :=
      Finset.sum_le_sum fun j _ => Finset.sum_le_sum fun k _ => hentry j k
    _ = 2 * σ ^ 2 * (∑ j, ∑ k, ∑ p, ∑ q,
        tangentQuadraticCoefficient X a j k p q ^ 2) := by simp only [Finset.mul_sum]
    _ ≤ 2 * σ ^ 2 * (4 * n * d ^ 2) :=
      mul_le_mul_of_nonneg_left (tangentQuadraticCoefficient_total_sq_le X ha hrows)
        (by positivity)
    _ = _ := by ring

/-- Under covariance norm at most `1/n`, fluctuation costs at most `8d²/n`. -/
theorem integral_sq_tangentQuadratic_centered_le_div {n d : ℕ}
    (hn : 0 < n) (X : Frame n d) {a : ℝ} (ha : 0 < a)
    (hrows : ∀ i, rowNormSq X i = a) (C : Matrix (Fin n × Fin d) κ ℝ)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ 1 / n) :
    (∫ g : EuclideanSpace ℝ κ, ∑ j, ∑ k,
      (tangentQuadratic X (frameOfVector (Matrix.toEuclideanLin C g)) a j k -
        tangentQuadraticMean X a C j k) ^ 2 ∂stdGaussian (EuclideanSpace ℝ κ)) ≤
      8 * d ^ 2 / n := by
  have h := integral_sq_tangentQuadratic_centered_le X ha hrows C (1 / n) hC
  convert h using 1
  have hn' : (n : ℝ) ≠ 0 := by exact_mod_cast hn.ne'
  field_simp


/-- The actual Gaussian conditioned on all tangent constraints satisfies the
required ambient quadratic fluctuation estimate. -/
theorem integral_sq_tangentQuadratic_conditioned_le {n d : ℕ}
    (hn : 0 < n) (X : Frame n d) {a : ℝ} (ha : 0 < a)
    (hrows : ∀ i, rowNormSq X i = a) :
    (∫ g : FrameVector n d, ∑ j, ∑ k,
      (tangentQuadratic X (frameOfVector (Matrix.toEuclideanLin (tangentNoiseFactor X) g))
          a j k - tangentQuadraticMean X a (tangentNoiseFactor X) j k) ^ 2
        ∂stdGaussian (FrameVector n d)) ≤ 8 * d ^ 2 / n :=
  integral_sq_tangentQuadratic_centered_le_div hn X ha hrows (tangentNoiseFactor X)
    (tangentNoiseFactor_operator_norm_sq_le X hn)

end

end Paulsen
