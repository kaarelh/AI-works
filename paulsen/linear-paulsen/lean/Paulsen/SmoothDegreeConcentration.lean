import Paulsen.SmoothSchurConcentration

/-!
# Concentration of Gaussian squared-entry row degrees

Positive quadratic coefficients have squared Frobenius norm at most their
operator norm times their trace. This supplies the useful d/n² variance scale.
-/

namespace Paulsen.Smooth
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory Matrix.Norms.Elementwise
noncomputable section

local instance {n : ℕ} : ContinuousENorm (Matrix (Fin n) (Fin n) ℝ) :=
  inferInstanceAs (ContinuousENorm (Fin n → Fin n → ℝ))

variable {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]

theorem posSemidef_entry_sq_sum_le_norm_mul_trace (A : Matrix κ κ ℝ) (hA : A.PosSemidef)
    {v : ℝ} (hbound : ‖(Matrix.toEuclideanLin A).toContinuousLinearMap‖ ≤ v) :
    (∑ i, ∑ j, A i j ^ 2) ≤ v * A.trace := by
  rw [← eigenvalues_sq_sum_eq_entry_sq_sum A hA.isHermitian]
  have htrace := hA.isHermitian.trace_eq_sum_eigenvalues
  simp only [RCLike.ofReal_real_eq_id, id_eq] at htrace
  rw [htrace, Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  have hi := (le_abs_self (hA.isHermitian.eigenvalues i)).trans
    ((abs_eigenvalue_le_euclidean_operator_norm A hA.isHermitian i).trans hbound)
  have hp := hA.eigenvalues_nonneg i
  nlinarith

/-- Bernstein tail for a norm square under a possibly singular Gaussian image. -/
theorem gaussianImage_norm_sq_centered_tail (D : Matrix ι κ ℝ)
    {v R t : ℝ} (hv : 0 < v) (hR : 0 < R) (ht : 0 ≤ t)
    (hD : ‖(Matrix.toEuclideanLin D).toContinuousLinearMap‖ ^ 2 ≤ v)
    (henergy : (∑ i, ∑ s, D i s ^ 2) ≤ R) :
    (stdGaussian (EuclideanSpace ℝ κ)).real {g |
      t ≤ |‖Matrix.toEuclideanLin D g‖ ^ 2 -
        ∫ h, ‖Matrix.toEuclideanLin D h‖ ^ 2 ∂stdGaussian (EuclideanSpace ℝ κ)|} ≤
      2 * Real.exp (-min (t ^ 2 / (16 * v * R)) (t / (16 * v))) := by
  have hpsd : (D.transpose * D).PosSemidef := by
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using Matrix.posSemidef_conjTranspose_mul_self D
  have hop : ‖(Matrix.toEuclideanLin (D.transpose * D)).toContinuousLinearMap‖ ≤ v := by
    calc
      _ ≤ ‖(Matrix.toEuclideanLin D.transpose).toContinuousLinearMap‖ *
          ‖(Matrix.toEuclideanLin D).toContinuousLinearMap‖ := euclidean_operator_norm_mul_le _ _
      _ = ‖(Matrix.toEuclideanLin D).toContinuousLinearMap‖ ^ 2 := by
        rw [euclidean_operator_norm_transpose, pow_two]
      _ ≤ _ := hD
  have htrace : (D.transpose * D).trace = ∑ i, ∑ s, D i s ^ 2 := by
    simp only [Matrix.trace, Matrix.diag_apply, Matrix.mul_apply, Matrix.transpose_apply, ← sq]
    exact Finset.sum_comm
  have hF : (∑ i, ∑ j, (D.transpose * D) i j ^ 2) ≤ v * R :=
    (posSemidef_entry_sq_sum_le_norm_mul_trace _ hpsd hop).trans
      (mul_le_mul_of_nonneg_left (by rw [htrace]; exact henergy) hv.le)
  simp_rw [norm_sq_gaussianImage_eq_quadratic]
  rw [integral_euclideanQuadratic_stdGaussian _ hpsd.isHermitian]
  have h := euclideanQuadratic_stdGaussian_abs_tail_of_operator_norm (D.transpose * D)
    hpsd.isHermitian v (v * R) t hv (mul_pos hv hR) ht hop hF
  simpa only [mul_assoc] using h

/-- Centered row degrees of the actual retained tangent matrix. -/
theorem retainedTangentRow_degree_tail {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) (hd : 0 < d) {ρ t : ℝ} (hρ : 0 ≤ ρ) (ht : 0 ≤ t)
    (hnear : ∀ i, rowNormSq U i ≤ 2 * (d : ℝ) / n) (i : Fin n) :
    (stdGaussian (FrameVector n d)).real {g |
      t ≤ |rowNormSq (gaussianMatrixImage (retainedTangentFactor U ρ) g) i -
        ∫ h, rowNormSq (gaussianMatrixImage (retainedTangentFactor U ρ) h) i
          ∂stdGaussian (FrameVector n d)|} ≤
      2 * Real.exp (-min ((n : ℝ) ^ 2 * t ^ 2 / (192 * d)) ((n : ℝ) * t / 32)) := by
  have hn : (0 : ℝ) < n := Nat.cast_pos.mpr (Nat.pos_of_ne_zero (NeZero.ne n))
  have he (g : FrameVector n d) :
      rowNormSq (gaussianMatrixImage (retainedTangentFactor U ρ) g) i =
        ‖Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i) g‖ ^ 2 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    rfl
  simp_rw [he]
  have h := gaussianImage_norm_sq_centered_tail (retainedTangentRowFactor U ρ i)
    (by positivity : (0 : ℝ) < 2 / n) (by positivity : (0 : ℝ) < 6 * (d : ℝ) / n) ht
    (retainedTangentRowFactor_operator_norm_sq_le hU hρ i)
    (retainedTangentRowFactor_sq_sum_le hU hρ i (hnear i))
  have he₁ : t ^ 2 / (16 * (2 / (n : ℝ)) * (6 * (d : ℝ) / n)) =
      (n : ℝ) ^ 2 * t ^ 2 / (192 * d) := by field_simp; ring
  have he₂ : t / (16 * (2 / (n : ℝ))) = (n : ℝ) * t / 32 := by field_simp; ring
  simpa only [he₁, he₂] using h

theorem retainedTangentRow_degree_max_tail {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) (hd : 0 < d) {ρ t : ℝ} (hρ : 0 ≤ ρ) (ht : 0 ≤ t)
    (hnear : ∀ i, rowNormSq U i ≤ 2 * (d : ℝ) / n) :
    (stdGaussian (FrameVector n d)).real {g | ∃ i,
      t ≤ |rowNormSq (gaussianMatrixImage (retainedTangentFactor U ρ) g) i -
        ∫ h, rowNormSq (gaussianMatrixImage (retainedTangentFactor U ρ) h) i
          ∂stdGaussian (FrameVector n d)|} ≤
      2 * n * Real.exp (-min ((n : ℝ) ^ 2 * t ^ 2 / (192 * d)) ((n : ℝ) * t / 32)) := by
  let bad (i : Fin n) : Set (FrameVector n d) := {g |
    t ≤ |rowNormSq (gaussianMatrixImage (retainedTangentFactor U ρ) g) i -
      ∫ h, rowNormSq (gaussianMatrixImage (retainedTangentFactor U ρ) h) i
        ∂stdGaussian (FrameVector n d)|}
  change (stdGaussian (FrameVector n d)).real {g | ∃ i, g ∈ bad i} ≤ _
  rw [show {g | ∃ i, g ∈ bad i} = ⋃ i, bad i by ext g; simp]
  calc
    _ ≤ ∑ i, (stdGaussian (FrameVector n d)).real (bad i) := measureReal_iUnion_fintype_le bad
    _ ≤ ∑ _i : Fin n, 2 * Real.exp (-min ((n : ℝ) ^ 2 * t ^ 2 / (192 * d)) ((n : ℝ) * t / 32)) :=
      Finset.sum_le_sum fun i _ => retainedTangentRow_degree_tail hU hd hρ ht hnear i
    _ = _ := by simp; ring

/-- Row sums of the centered Schur square are exactly the centered row energies. -/
theorem gaussianSchurSquare_centered_row_sum {n : ℕ}
    (C : Matrix (Fin n × Fin n) κ ℝ) (g : EuclideanSpace ℝ κ) (i : Fin n) :
    (∑ j, (gaussianSchurSquare C g - ∫ h, gaussianSchurSquare C h
      ∂stdGaussian (EuclideanSpace ℝ κ)) i j) =
      rowNormSq (gaussianMatrixImage C g) i -
        ∫ h, rowNormSq (gaussianMatrixImage C h) i ∂stdGaussian (EuclideanSpace ℝ κ) := by
  simp only [Matrix.sub_apply, Finset.sum_sub_distrib]
  congr 1
  rw [show (fun h => rowNormSq (gaussianMatrixImage C h) i) =
      (fun h => ∑ j, gaussianSchurSquare C h i j) by rfl]
  rw [integral_finsetSum _ (fun j _ =>
    ((integrable_gaussianSchurSquare C).eval i).eval j)]
  apply Finset.sum_congr rfl
  intro j _
  have hi : (∫ h, gaussianSchurSquare C h ∂stdGaussian (EuclideanSpace ℝ κ)) i =
      ∫ h, gaussianSchurSquare C h i ∂stdGaussian (EuclideanSpace ℝ κ) :=
    eval_integral (fun r => (integrable_gaussianSchurSquare C).eval r) i
  rw [hi]
  exact eval_integral (fun k => ((integrable_gaussianSchurSquare C).eval i).eval k) j
end
end Paulsen.Smooth
