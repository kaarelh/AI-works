import Paulsen.TangentSubspace
import Paulsen.GaussianFourthMoment
import Mathlib.Probability.Distributions.Gaussian.Multivariate
import Mathlib.Algebra.Order.Chebyshev

/-!
# Row moments of projected Gaussian noise

The covariance bound is checked on the concrete matrix factor. No coordinate
moment assumptions are introduced.
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory NNReal

noncomputable section

namespace Paulsen

variable {κ : Type*} [Fintype κ]

theorem hasLaw_dual_stdGaussian (L : StrongDual ℝ (EuclideanSpace ℝ κ)) :
    HasLaw L (gaussianReal 0 (‖L‖ ^ 2).toNNReal)
      (stdGaussian (EuclideanSpace ℝ κ)) where
  map_eq := by
    simpa only [integral_strongDual_stdGaussian, variance_dual_stdGaussian] using
      (IsGaussian.map_eq_gaussianReal (μ := stdGaussian (EuclideanSpace ℝ κ)) L)

theorem integral_sq_dual_stdGaussian (L : StrongDual ℝ (EuclideanSpace ℝ κ)) :
    (∫ g, (L g) ^ 2 ∂stdGaussian (EuclideanSpace ℝ κ)) = ‖L‖ ^ 2 := by
  calc
    _ = ∫ x : ℝ, x ^ 2 ∂gaussianReal 0 (‖L‖ ^ 2).toNNReal :=
      (hasLaw_dual_stdGaussian L).integral_comp (by fun_prop)
    _ = _ := by
      rw [integral_pow_two_gaussianReal, Real.coe_toNNReal _ (sq_nonneg _)]

theorem integral_four_dual_stdGaussian (L : StrongDual ℝ (EuclideanSpace ℝ κ)) :
    (∫ g, (L g) ^ 4 ∂stdGaussian (EuclideanSpace ℝ κ)) = 3 * (‖L‖ ^ 2) ^ 2 := by
  simpa only [Real.coe_toNNReal _ (sq_nonneg _)] using
    integral_pow_four_of_hasLaw (hasLaw_dual_stdGaussian L)

variable [DecidableEq κ]

/-- One output coordinate of a matrix-valued Gaussian linear image. -/
def gaussianCoordinate {n d : ℕ} (C : Matrix (Fin n × Fin d) κ ℝ)
    (p : Fin n × Fin d) : StrongDual ℝ (EuclideanSpace ℝ κ) :=
  (EuclideanSpace.proj p).comp (Matrix.toEuclideanLin C).toContinuousLinearMap

@[simp] theorem gaussianCoordinate_apply {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ) (p : Fin n × Fin d)
    (g : EuclideanSpace ℝ κ) :
    gaussianCoordinate C p g = Matrix.toEuclideanLin C g p := rfl

theorem gaussianCoordinate_norm_le {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ) (p : Fin n × Fin d) :
    ‖gaussianCoordinate C p‖ ≤ ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ := by
  apply ContinuousLinearMap.opNorm_le_bound _ (norm_nonneg _)
  intro g
  exact (PiLp.norm_apply_le (Matrix.toEuclideanLin C g) p).trans
    ((Matrix.toEuclideanLin C).toContinuousLinearMap.le_opNorm g)

theorem gaussianCoordinate_norm_sq_le {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ 1 / (n : ℝ))
    (p : Fin n × Fin d) : ‖gaussianCoordinate C p‖ ^ 2 ≤ 1 / (n : ℝ) :=
  (pow_le_pow_left₀ (norm_nonneg _) (gaussianCoordinate_norm_le C p) 2).trans hC

theorem memLp_sq_gaussianCoordinate {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ) (p : Fin n × Fin d) :
    MemLp (fun g => (Matrix.toEuclideanLin C g p) ^ 2) 2
      (stdGaussian (EuclideanSpace ℝ κ)) :=
  memLp_square_of_hasLaw (hasLaw_dual_stdGaussian (gaussianCoordinate C p))

theorem integral_sq_gaussianCoordinate_le {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ 1 / (n : ℝ))
    (p : Fin n × Fin d) :
    (∫ g, (Matrix.toEuclideanLin C g p) ^ 2 ∂stdGaussian (EuclideanSpace ℝ κ)) ≤
      1 / (n : ℝ) := by
  change (∫ g, (gaussianCoordinate C p g) ^ 2 ∂_) ≤ _
  rw [integral_sq_dual_stdGaussian]
  exact gaussianCoordinate_norm_sq_le C hC p

theorem integral_four_gaussianCoordinate_le {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ 1 / (n : ℝ))
    (p : Fin n × Fin d) :
    (∫ g, (Matrix.toEuclideanLin C g p) ^ 4 ∂stdGaussian (EuclideanSpace ℝ κ)) ≤
      3 * (1 / (n : ℝ)) ^ 2 := by
  change (∫ g, (gaussianCoordinate C p g) ^ 4 ∂_) ≤ _
  rw [integral_four_dual_stdGaussian]
  exact mul_le_mul_of_nonneg_left
    (pow_le_pow_left₀ (sq_nonneg _) (gaussianCoordinate_norm_sq_le C hC p) 2) (by norm_num)

/-- The squared norm of one row of the Gaussian linear image is square integrable. -/
theorem memLp_rowNormSq_gaussianImage {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ) (i : Fin n) :
    MemLp (fun g => rowNormSq (frameOfVector (Matrix.toEuclideanLin C g)) i) 2
      (stdGaussian (EuclideanSpace ℝ κ)) := by
  exact memLp_finsetSum _ fun j _ => memLp_sq_gaussianCoordinate C (i, j)

theorem integral_rowNormSq_gaussianImage_le {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ 1 / (n : ℝ))
    (i : Fin n) :
    (∫ g, rowNormSq (frameOfVector (Matrix.toEuclideanLin C g)) i
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤ (d : ℝ) / n := by
  change (∫ g, ∑ j : Fin d, (Matrix.toEuclideanLin C g (i, j)) ^ 2 ∂_) ≤ _
  rw [integral_finsetSum _ (fun j _ => (memLp_sq_gaussianCoordinate C (i, j)).integrable (by norm_num))]
  calc
    _ ≤ ∑ _j : Fin d, 1 / (n : ℝ) :=
      Finset.sum_le_sum fun j _ => integral_sq_gaussianCoordinate_le C hC (i, j)
    _ = _ := by simp [div_eq_mul_inv]

theorem rowNormSq_sq_le_sum_four {n d : ℕ} (Z : Frame n d) (i : Fin n) :
    rowNormSq Z i ^ 2 ≤ (d : ℝ) * ∑ j, Z i j ^ 4 := by
  have h := sq_sum_le_card_mul_sum_sq (s := Finset.univ) (f := fun j : Fin d => Z i j ^ 2)
  simpa only [rowNormSq, Finset.card_univ, Fintype.card_fin, ← pow_mul] using h

theorem integral_rowNormSq_sq_gaussianImage_le {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ 1 / (n : ℝ))
    (i : Fin n) :
    (∫ g, rowNormSq (frameOfVector (Matrix.toEuclideanLin C g)) i ^ 2
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤ 3 * ((d : ℝ) / n) ^ 2 := by
  have hi (j : Fin d) : Integrable
      (fun g => (Matrix.toEuclideanLin C g (i, j)) ^ 4)
      (stdGaussian (EuclideanSpace ℝ κ)) := by
    simpa only [← pow_mul] using (memLp_sq_gaussianCoordinate C (i, j)).integrable_sq
  calc
    _ ≤ ∫ g, (d : ℝ) * ∑ j : Fin d, (Matrix.toEuclideanLin C g (i, j)) ^ 4 ∂_ :=
      integral_mono (memLp_rowNormSq_gaussianImage C i).integrable_sq
        ((integrable_finsetSum _ fun j _ => hi j).const_mul _) fun g =>
          rowNormSq_sq_le_sum_four (frameOfVector (Matrix.toEuclideanLin C g)) i
    _ = (d : ℝ) * ∑ j : Fin d, ∫ g, (Matrix.toEuclideanLin C g (i, j)) ^ 4 ∂_ := by
      rw [integral_const_mul, integral_finsetSum _ (fun j _ => hi j)]
    _ ≤ (d : ℝ) * ∑ _j : Fin d, 3 * (1 / (n : ℝ)) ^ 2 :=
      mul_le_mul_of_nonneg_left
        (Finset.sum_le_sum fun j _ => integral_four_gaussianCoordinate_le C hC (i, j))
        (Nat.cast_nonneg _)
    _ = _ := by simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin,
        nsmul_eq_mul]; ring

theorem memLp_tangentRatio_gaussianImage {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ) (a : ℝ) (i : Fin n) :
    MemLp (fun g => tangentRatio a (frameOfVector (Matrix.toEuclideanLin C g)) i) 2
      (stdGaussian (EuclideanSpace ℝ κ)) := by
  simpa only [tangentRatio, div_eq_mul_inv, mul_comm] using
    (memLp_rowNormSq_gaussianImage C i).const_mul a⁻¹

theorem integral_tangentRatio_gaussianImage_le {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ) (hn : 0 < n) (hd : 0 < d)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ 1 / (n : ℝ))
    (i : Fin n) :
    (∫ g, tangentRatio ((d : ℝ) / n) (frameOfVector (Matrix.toEuclideanLin C g)) i
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤ 1 := by
  have ha : 0 < (d : ℝ) / n := div_pos (Nat.cast_pos.mpr hd) (Nat.cast_pos.mpr hn)
  simp only [tangentRatio, integral_div]
  exact (div_le_one ha).2 (integral_rowNormSq_gaussianImage_le C hC i)

theorem integral_tangentRatio_sq_gaussianImage_le {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ) (hn : 0 < n) (hd : 0 < d)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ 1 / (n : ℝ))
    (i : Fin n) :
    (∫ g, tangentRatio ((d : ℝ) / n) (frameOfVector (Matrix.toEuclideanLin C g)) i ^ 2
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤ 3 := by
  have ha : 0 < (d : ℝ) / n := div_pos (Nat.cast_pos.mpr hd) (Nat.cast_pos.mpr hn)
  simp only [tangentRatio, div_pow, integral_div]
  simpa only [div_pow] using
    (div_le_iff₀ (sq_pos_of_pos ha)).2 (integral_rowNormSq_sq_gaussianImage_le C hC i)

/-- Uniform moment bounds for every row of the actual conditioned tangent noise. -/
theorem tangentNoiseFactor_row_moments {n d : ℕ} (X : Frame n d)
    (hn : 0 < n) (hd : 0 < d) (i : Fin n) :
    let r := fun g : FrameVector n d =>
      tangentRatio ((d : ℝ) / n) (frameOfVector (Matrix.toEuclideanLin (tangentNoiseFactor X) g)) i
    MemLp r 2 (stdGaussian (FrameVector n d)) ∧
      (∫ g, r g ∂stdGaussian (FrameVector n d)) ≤ 1 ∧
      (∫ g, (r g) ^ 2 ∂stdGaussian (FrameVector n d)) ≤ 3 := by
  exact ⟨memLp_tangentRatio_gaussianImage _ _ _,
    integral_tangentRatio_gaussianImage_le _ hn hd (tangentNoiseFactor_operator_norm_sq_le X hn) _,
    integral_tangentRatio_sq_gaussianImage_le _ hn hd (tangentNoiseFactor_operator_norm_sq_le X hn) _⟩

theorem integral_sum_tangentRatio_gaussianImage_le {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ) (hn : 0 < n) (hd : 0 < d)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ 1 / (n : ℝ)) :
    (∫ g, ∑ i, tangentRatio ((d : ℝ) / n) (frameOfVector (Matrix.toEuclideanLin C g)) i
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤ (n : ℝ) := by
  rw [integral_finsetSum _ (fun i _ =>
    (memLp_tangentRatio_gaussianImage C _ i).integrable (by norm_num))]
  simpa using Finset.sum_le_sum (s := Finset.univ)
    (fun i _ => integral_tangentRatio_gaussianImage_le C hn hd hC i)

theorem integral_sum_tangentRatio_sq_gaussianImage_le {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ) (hn : 0 < n) (hd : 0 < d)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ^ 2 ≤ 1 / (n : ℝ)) :
    (∫ g, ∑ i, tangentRatio ((d : ℝ) / n) (frameOfVector (Matrix.toEuclideanLin C g)) i ^ 2
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤ 3 * (n : ℝ) := by
  rw [integral_finsetSum _ (fun i _ =>
    (memLp_tangentRatio_gaussianImage C _ i).integrable_sq)]
  simpa [mul_comm] using Finset.sum_le_sum (s := Finset.univ)
    (fun i _ => integral_tangentRatio_sq_gaussianImage_le C hn hd hC i)

/-- The aggregate row quantities used in the seed remainder are integrable,
and have dimension-free normalized moment bounds. -/
theorem tangentNoiseFactor_sum_moments {n d : ℕ} (X : Frame n d)
    (hn : 0 < n) (hd : 0 < d) :
    let r := fun (g : FrameVector n d) (i : Fin n) =>
      tangentRatio ((d : ℝ) / n) (frameOfVector (Matrix.toEuclideanLin (tangentNoiseFactor X) g)) i
    Integrable (fun g => ∑ i, r g i) (stdGaussian (FrameVector n d)) ∧
      Integrable (fun g => ∑ i, (r g i) ^ 2) (stdGaussian (FrameVector n d)) ∧
      (∫ g, ∑ i, r g i ∂stdGaussian (FrameVector n d)) ≤ (n : ℝ) ∧
      (∫ g, ∑ i, (r g i) ^ 2 ∂stdGaussian (FrameVector n d)) ≤ 3 * (n : ℝ) := by
  refine ⟨integrable_finsetSum _ (fun i _ => ?_),
    integrable_finsetSum _ (fun i _ => ?_), ?_, ?_⟩
  · exact (memLp_tangentRatio_gaussianImage _ _ i).integrable (by norm_num)
  · exact (memLp_tangentRatio_gaussianImage _ _ i).integrable_sq
  · exact integral_sum_tangentRatio_gaussianImage_le _ hn hd
      (tangentNoiseFactor_operator_norm_sq_le X hn)
  · exact integral_sum_tangentRatio_sq_gaussianImage_le _ hn hd
      (tangentNoiseFactor_operator_norm_sq_le X hn)

end Paulsen
