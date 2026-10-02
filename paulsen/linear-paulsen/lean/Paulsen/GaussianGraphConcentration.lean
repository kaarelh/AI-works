import Paulsen.GaussianDegreeConcentration

/-!
# Uniform graph-energy control of the retained tangent Gaussian

The centered weighted Laplacian is a diagonal degree fluctuation minus the
centered Schur square. Their separately proved bounds give uniform graph energy.
-/

namespace Paulsen
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory Matrix.Norms.Elementwise
noncomputable section

local instance {n : ℕ} : ContinuousENorm (Matrix (Fin n) (Fin n) ℝ) :=
  inferInstanceAs (ContinuousENorm (Fin n → Fin n → ℝ))

theorem diagonal_euclideanOperator_norm_le {n : ℕ} (r : Fin n → ℝ) {t : ℝ}
    (ht : 0 ≤ t) (hr : ∀ i, |r i| ≤ t) :
    ‖matrixEuclideanOperator (Matrix.diagonal r)‖ ≤ t := by
  apply ContinuousLinearMap.opNorm_le_bound _ ht
  intro x
  have hs : ‖Matrix.toEuclideanLin (Matrix.diagonal r) x‖ ^ 2 ≤ (t * ‖x‖) ^ 2 := by
    simp only [EuclideanSpace.real_norm_sq_eq, Matrix.toLpLin_apply,
      Matrix.mulVec_diagonal, mul_pow]
    rw [Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i _
    apply mul_le_mul_of_nonneg_right _ (sq_nonneg _)
    nlinarith [(abs_le.mp (hr i)).1, (abs_le.mp (hr i)).2]
  change ‖Matrix.toEuclideanLin (Matrix.diagonal r) x‖ ≤ t * ‖x‖
  exact (sq_le_sq₀ (norm_nonneg _) (mul_nonneg ht (norm_nonneg _))).mp hs

theorem graphLaplacian_operator_norm_le {n : ℕ} (W : Frame n n) {t s : ℝ}
    (ht : 0 ≤ t) (hdegree : ∀ i, |∑ j, W i j| ≤ t)
    (hW : ‖matrixEuclideanOperator W‖ ≤ s) :
    ‖matrixEuclideanOperator (graphLaplacian W)‖ ≤ t + s := by
  rw [graphLaplacian, map_sub]
  exact (norm_sub_le _ _).trans (add_le_add
    (diagonal_euclideanOperator_norm_le _ ht hdegree) hW)

theorem abs_matrixQuadratic_le_operator_norm {n : ℕ} (A : Frame n n) (x : Fin n → ℝ) :
    |matrixQuadratic A x| ≤ ‖matrixEuclideanOperator A‖ * vectorNormSq x := by
  let y : EuclideanSpace ℝ (Fin n) := WithLp.toLp 2 x
  have he : matrixQuadratic A x = inner ℝ y (Matrix.toEuclideanLin A y) :=
    (euclideanQuadratic_eq_matrixQuadratic A y).symm
  rw [he]
  calc
    _ ≤ ‖y‖ * ‖Matrix.toEuclideanLin A y‖ := abs_real_inner_le_norm _ _
    _ ≤ ‖y‖ * (‖matrixEuclideanOperator A‖ * ‖y‖) :=
      mul_le_mul_of_nonneg_left ((matrixEuclideanOperator A).le_opNorm y) (norm_nonneg _)
    _ = _ := by
      rw [show ‖y‖ * (‖matrixEuclideanOperator A‖ * ‖y‖) =
        ‖matrixEuclideanOperator A‖ * ‖y‖ ^ 2 by ring]
      rw [EuclideanSpace.real_norm_sq_eq]
      rfl

theorem graphEnergy_abs_le_operator_norm {n : ℕ} (W : Frame n n)
    (hW : ∀ i j, W i j = W j i) (x : Fin n → ℝ) :
    |graphEnergy W x| ≤ ‖matrixEuclideanOperator (graphLaplacian W)‖ * vectorNormSq x := by
  rw [← graphLaplacian_quadratic W hW]
  exact abs_matrixQuadratic_le_operator_norm _ _

variable {κ : Type*} [Fintype κ] [DecidableEq κ]

def centeredGaussianSchurSquare {n : ℕ} (C : Matrix (Fin n × Fin n) κ ℝ)
    (g : EuclideanSpace ℝ κ) : Frame n n :=
  gaussianSchurSquare C g - ∫ h, gaussianSchurSquare C h ∂stdGaussian (EuclideanSpace ℝ κ)

theorem centeredGaussianSchurSquare_symmetric {n : ℕ} (C : Matrix (Fin n × Fin n) κ ℝ)
    (hCs : ∀ s i j, C (i,j) s = C (j,i) s) (g : EuclideanSpace ℝ κ) (i j : Fin n) :
    centeredGaussianSchurSquare C g i j = centeredGaussianSchurSquare C g j i := by
  have hmean (a b : Fin n) :
      (∫ h, gaussianSchurSquare C h ∂stdGaussian (EuclideanSpace ℝ κ)) a b =
        ∑ s, C (a,b) s ^ 2 := by
    exact gaussianSchurSquare_integral_entry C a b
  change (gaussianMatrixImage C g i j) ^ 2 -
      (∫ h, gaussianSchurSquare C h ∂stdGaussian (EuclideanSpace ℝ κ)) i j =
    (gaussianMatrixImage C g j i) ^ 2 -
      (∫ h, gaussianSchurSquare C h ∂stdGaussian (EuclideanSpace ℝ κ)) j i
  rw [hmean, hmean]
  congr 1
  · exact congrArg (fun z : ℝ => z ^ 2) ((gaussianMatrixImage_symmetric C hCs g).apply i j).symm
  · apply Finset.sum_congr rfl
    intro s _
    rw [hCs s i j]


/-- Combining the two actual fluctuations bounds the full centered graph Laplacian. -/
theorem retainedTangentGraph_operator_tail {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U) (hd : 0 < d) {ρ t s : ℝ}
    (hρ : 0 ≤ ρ) (ht : 0 < t) (hs : 0 < s)
    (hnear : ∀ i, rowNormSq U i ≤ 2 * (d : ℝ) / n)
    (hlog : Real.log n ≤ (d : ℝ)) :
    (stdGaussian (FrameVector n d)).real {g | t + s <
      ‖matrixEuclideanOperator (graphLaplacian (centeredGaussianSchurSquare (retainedTangentFactor U ρ) g))‖} ≤
      2 * n * Real.exp (-min ((n : ℝ) ^ 2 * t ^ 2 / (192 * d)) ((n : ℝ) * t / 32)) +
        (4 * Real.sqrt (80 * Real.exp 1 * (d : ℝ) * (Real.log n + 2)) / n) / s := by
  let degreeBad : Set (FrameVector n d) := {g | ∃ i,
    t ≤ |rowNormSq (gaussianMatrixImage (retainedTangentFactor U ρ) g) i -
      ∫ h, rowNormSq (gaussianMatrixImage (retainedTangentFactor U ρ) h) i
        ∂stdGaussian (FrameVector n d)|}
  let schurBad : Set (FrameVector n d) := {g | s ≤
    ‖matrixEuclideanOperator (centeredGaussianSchurSquare (retainedTangentFactor U ρ) g)‖}
  have hsubset : {g | t + s <
      ‖matrixEuclideanOperator (graphLaplacian (centeredGaussianSchurSquare (retainedTangentFactor U ρ) g))‖} ⊆
      degreeBad ∪ schurBad := by
    intro g hg
    by_contra hbad
    have hD : ∀ i, |∑ j, centeredGaussianSchurSquare (retainedTangentFactor U ρ) g i j| ≤ t := by
      intro i
      rw [centeredGaussianSchurSquare, gaussianSchurSquare_centered_row_sum]
      have hnot : ¬t ≤ |rowNormSq (gaussianMatrixImage (retainedTangentFactor U ρ) g) i -
        ∫ h, rowNormSq (gaussianMatrixImage (retainedTangentFactor U ρ) h) i
          ∂stdGaussian (FrameVector n d)| := by
        intro hi
        exact hbad (Or.inl ⟨i, hi⟩)
      exact (lt_of_not_ge hnot).le
    have hS : ‖matrixEuclideanOperator (centeredGaussianSchurSquare (retainedTangentFactor U ρ) g)‖ ≤ s := by
      apply le_of_not_ge
      intro hi
      exact hbad (Or.inr hi)
    exact (not_lt_of_ge (graphLaplacian_operator_norm_le _ ht.le hD hS)) hg
  calc
    _ ≤ (stdGaussian (FrameVector n d)).real (degreeBad ∪ schurBad) := measureReal_mono hsubset
    _ ≤ (stdGaussian (FrameVector n d)).real degreeBad + (stdGaussian (FrameVector n d)).real schurBad :=
      measureReal_union_le _ _
    _ ≤ _ := add_le_add (retainedTangentRow_degree_max_tail hU hd hρ ht.le hnear)
      (retainedTangentSchurSquare_operator_tail hU hρ hs hnear hlog)

/-- Every successful sample has a uniform quadratic-form error bound. -/
theorem retainedTangentGraph_energy_bound_of_operator {n d : ℕ}
    (U : Frame n d) (ρ : ℝ) (g : FrameVector n d) {δ : ℝ}
    (hbound : ‖matrixEuclideanOperator
      (graphLaplacian (centeredGaussianSchurSquare (retainedTangentFactor U ρ) g))‖ ≤ δ) :
    ∀ x : Fin n → ℝ,
      |graphEnergy (centeredGaussianSchurSquare (retainedTangentFactor U ρ) g) x| ≤ δ * vectorNormSq x := by
  intro x
  exact (graphEnergy_abs_le_operator_norm _
    (centeredGaussianSchurSquare_symmetric _ (retainedTangentFactor_symmetric U ρ) g) x).trans
    (mul_le_mul_of_nonneg_right hbound (vectorNormSq_nonneg x))

end
end Paulsen
