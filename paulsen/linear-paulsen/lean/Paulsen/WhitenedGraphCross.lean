import Paulsen.MatrixSeriesCovariance
import Paulsen.NormalizedTruncation
import Paulsen.RetainedTangentFactor

/-! The linear graph cross term after whitening by a regularized Laplacian. -/
open Matrix
open scoped BigOperators
noncomputable section
namespace Paulsen
variable {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]

def graphEdgeVector (i j : ι) : EuclideanSpace ℝ ι :=
  EuclideanSpace.single i 1 - EuclideanSpace.single j 1

omit [Fintype κ] [DecidableEq κ] in
theorem graphEdgeVector_norm_sq_le (i j : ι) : ‖graphEdgeVector i j‖^2 ≤ 2 := by
  rw [graphEdgeVector, norm_sub_sq_real]
  by_cases h : i=j
  · subst j; simp; norm_num
  · simp [PiLp.norm_single, EuclideanSpace.inner_single_left, h]; norm_num

def whitenedGraphEdge (M : Matrix ι ι ℝ) (i j : ι) : EuclideanSpace ℝ ι :=
  Matrix.toEuclideanLin M (graphEdgeVector i j)

omit [Fintype κ] [DecidableEq κ] in
theorem whitenedGraphEdge_inner (M : Matrix ι ι ℝ) (i j : ι)
    (x : EuclideanSpace ℝ ι) :
    inner ℝ (whitenedGraphEdge M i j) x =
      Matrix.toEuclideanLin M.transpose x i - Matrix.toEuclideanLin M.transpose x j := by
  have ht : Matrix.toEuclideanLin M.transpose = (Matrix.toEuclideanLin M).adjoint := by
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
      Matrix.toEuclideanLin_conjTranspose_eq_adjoint M
  rw [whitenedGraphEdge, ht, ← LinearMap.adjoint_inner_right]
  simp [graphEdgeVector, inner_sub_left, EuclideanSpace.inner_single_left]

omit [Fintype κ] [DecidableEq κ] in
theorem whitenedGraphEdge_norm_sq_le (M : Matrix ι ι ℝ) {R : ℝ}
    (hM : ‖(Matrix.toEuclideanLin M).toContinuousLinearMap‖^2≤R) (i j : ι) :
    ‖whitenedGraphEdge M i j‖^2 ≤ 2*R := by
  have h := pow_le_pow_left₀ (norm_nonneg _)
    ((Matrix.toEuclideanLin M).toContinuousLinearMap.le_opNorm (graphEdgeVector i j)) 2
  rw [mul_pow] at h
  have hR : 0≤R := (sq_nonneg _).trans hM
  exact h.trans ((mul_le_mul_of_nonneg_right hM (sq_nonneg _)).trans
    (by simpa only [mul_comm] using
      mul_le_mul_of_nonneg_left (graphEdgeVector_norm_sq_le i j) hR))

/-- Ordered edges are used, so their frame operator is twice the Laplacian. -/
theorem whitenedGraphEdge_frame_energy (P M : Matrix ι ι ℝ)
    (hP : ∀ i j, P i j=P j i) (hproj : P*P=P) (x : EuclideanSpace ℝ ι) :
    (∑ e : ι×ι, P e.1 e.2^2 * (inner ℝ (whitenedGraphEdge M e.1 e.2) x)^2) =
      2 * euclideanQuadratic (M * projectionLaplacian P * M.transpose) x := by
  have he := euclideanQuadratic_linear_image (projectionLaplacian P) M.transpose x
  simp only [Matrix.transpose_transpose] at he
  rw [← he]
  rw [euclideanQuadratic_eq_matrixQuadratic,
    projectionLaplacian_quadratic P hP hproj]
  simp only [Fintype.sum_prod_type, whitenedGraphEdge_inner]
  ring

/-- Rank-one coefficients of the actual linear graph cross term. -/
def whitenedGraphCoefficient (P M : Matrix ι ι ℝ) (t : ℝ) (e : ι×ι) : Matrix ι ι ℝ :=
  (t*P e.1 e.2) • Matrix.vecMulVec
    (fun i => whitenedGraphEdge M e.1 e.2 i) (fun i => whitenedGraphEdge M e.1 e.2 i)

omit [Fintype κ] [DecidableEq κ] in
theorem whitenedGraphCoefficient_isHermitian (P M : Matrix ι ι ℝ) (t : ℝ) (e : ι×ι) :
    (whitenedGraphCoefficient P M t e).IsHermitian := by
  unfold Matrix.IsHermitian whitenedGraphCoefficient
  simp [Matrix.conjTranspose_eq_transpose_of_trivial, Matrix.transpose_smul,
    Matrix.transpose_vecMulVec]

omit [Fintype κ] [DecidableEq κ] in
theorem whitenedGraphCoefficient_energy (P M : Matrix ι ι ℝ) (t : ℝ) (e : ι×ι)
    (x : EuclideanSpace ℝ ι) :
    ‖Matrix.toEuclideanLin (whitenedGraphCoefficient P M t e) x‖^2 =
      t^2 * P e.1 e.2^2 * (inner ℝ (whitenedGraphEdge M e.1 e.2) x)^2 *
        ‖whitenedGraphEdge M e.1 e.2‖^2 := by
  simp only [whitenedGraphCoefficient, map_smul, LinearMap.smul_apply,
    toEuclideanLin_vecMulVec_apply, norm_smul, Real.norm_eq_abs, mul_pow, sq_abs]
  ring

omit [Fintype κ] [DecidableEq κ] in
theorem whitenedGraphCoefficient_energy_le (P M : Matrix ι ι ℝ) (t : ℝ)
    (hP : ∀ i j, P i j=P j i) (hproj : P*P=P) {R : ℝ}
    (hM : ‖(Matrix.toEuclideanLin M).toContinuousLinearMap‖^2≤R)
    (hframe : (1 - M * projectionLaplacian P * M.transpose).PosSemidef)
    (x : EuclideanSpace ℝ ι) :
    (∑ e, ‖Matrix.toEuclideanLin (whitenedGraphCoefficient P M t e) x‖^2) ≤
      (4*t^2*R)*‖x‖^2 := by
  have hR : 0≤R := (sq_nonneg _).trans hM
  have hq : euclideanQuadratic (M * projectionLaplacian P * M.transpose) x ≤ ‖x‖^2 := by
    have hh := hframe.dotProduct_mulVec_nonneg (fun i => x i)
    change 0 ≤ _ at hh
    have he : euclideanQuadratic (1 - M * projectionLaplacian P * M.transpose) x =
        ‖x‖^2 - euclideanQuadratic (M * projectionLaplacian P * M.transpose) x := by
      simp [euclideanQuadratic, map_sub, LinearMap.sub_apply, inner_sub_right,
        Matrix.toEuclideanLin, Matrix.toLpLin_one]
    have hh' : 0≤euclideanQuadratic (1 - M * projectionLaplacian P * M.transpose) x := by
      simpa only [euclideanQuadratic, EuclideanSpace.inner_eq_star_dotProduct,
        Matrix.toLpLin_apply, star_trivial, dotProduct_comm] using hh
    rw [he] at hh'; linarith
  calc
    _ = ∑ e : ι×ι, t^2 * P e.1 e.2^2 * (inner ℝ (whitenedGraphEdge M e.1 e.2) x)^2 *
        ‖whitenedGraphEdge M e.1 e.2‖^2 := by simp only [whitenedGraphCoefficient_energy]
    _ ≤ ∑ e : ι×ι, t^2 * P e.1 e.2^2 * (inner ℝ (whitenedGraphEdge M e.1 e.2) x)^2 * (2*R) := by
      apply Finset.sum_le_sum
      intro e _
      exact mul_le_mul_of_nonneg_left (whitenedGraphEdge_norm_sq_le M hM e.1 e.2)
        (by positivity)
    _ = (2*t^2*R)*(2*euclideanQuadratic (M * projectionLaplacian P * M.transpose) x) := by
      rw [← whitenedGraphEdge_frame_energy P M hP hproj x]
      simp only [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro e _
      ring
    _ ≤ _ := by
      nlinarith only [mul_le_mul_of_nonneg_left hq (show 0≤4*t^2*R by positivity)]

omit [Fintype κ] [DecidableEq κ] in
theorem whitenedGraphCoefficient_variance_le (P M : Matrix ι ι ℝ) (t : ℝ)
    (hP : ∀ i j, P i j=P j i) (hproj : P*P=P) {R : ℝ}
    (hM : ‖(Matrix.toEuclideanLin M).toContinuousLinearMap‖^2≤R)
    (hframe : (1 - M * projectionLaplacian P * M.transpose).PosSemidef) :
    ((4*t^2*R) • (1 : Matrix ι ι ℝ) -
      ∑ e, (whitenedGraphCoefficient P M t e)^2).PosSemidef := by
  have hA := whitenedGraphCoefficient_isHermitian P M t
  rw [Matrix.posSemidef_iff_dotProduct_mulVec]
  refine ⟨?_, ?_⟩
  · unfold Matrix.IsHermitian
    simp only [Matrix.conjTranspose_sub, Matrix.conjTranspose_smul, star_trivial,
      Matrix.conjTranspose_one, Matrix.conjTranspose_sum, Matrix.conjTranspose_pow, (hA _).eq]
  · intro x
    have hh := whitenedGraphCoefficient_energy_le P M t hP hproj hM hframe (WithLp.toLp 2 x)
    have he : euclideanQuadratic ((4*t^2*R) • (1 : Matrix ι ι ℝ) -
        ∑ e, (whitenedGraphCoefficient P M t e)^2) (WithLp.toLp 2 x) =
        (4*t^2*R)*‖WithLp.toLp 2 x‖^2 -
          ∑ e, ‖Matrix.toEuclideanLin (whitenedGraphCoefficient P M t e) (WithLp.toLp 2 x)‖^2 := by
      simp only [euclideanQuadratic, map_sub, map_smul, LinearMap.sub_apply,
        LinearMap.smul_apply, inner_sub_right, real_inner_smul_right]
      simp only [Matrix.toEuclideanLin, Matrix.toLpLin_one, LinearMap.id_apply]
      change (4*t^2*R)*inner ℝ (WithLp.toLp 2 x) (WithLp.toLp 2 x) -
        euclideanQuadratic (∑ e, (whitenedGraphCoefficient P M t e)^2) _ = _
      simp only [real_inner_self_eq_norm_sq, euclideanQuadratic_fintype_sum,
        euclideanQuadratic_square_eq_norm_sq _ (hA _)]
    have hn : 0≤euclideanQuadratic ((4*t^2*R) • (1 : Matrix ι ι ℝ) -
        ∑ e, (whitenedGraphCoefficient P M t e)^2) (WithLp.toLp 2 x) := by
      rw [he]; linarith
    simpa only [euclideanQuadratic, PiLp.inner_apply, Real.inner_apply, Matrix.toLpLin_apply,
      Matrix.mulVec, dotProduct, star_trivial, mul_comm] using hn

/-- Actual covariance domination gives the variance parameter of the whitened
cross term, including arbitrarily correlated tangent entries. -/
theorem whitenedGraphCorrelated_variance_le (P M : Matrix ι ι ℝ) (t : ℝ)
    (hP : ∀ i j, P i j=P j i) (hproj : P*P=P) {R v : ℝ} (hv : 0≤v)
    (hM : ‖(Matrix.toEuclideanLin M).toContinuousLinearMap‖^2≤R)
    (hframe : (1 - M * projectionLaplacian P * M.transpose).PosSemidef)
    (C : Matrix (ι×ι) κ ℝ)
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖^2≤v) :
    ((v*(4*t^2*R)) • (1 : Matrix ι ι ℝ) -
      ∑ s, (correlatedMatrixCoefficient (whitenedGraphCoefficient P M t) C s)^2).PosSemidef :=
  correlatedMatrixCoefficient_scalar_variance_le _
    (whitenedGraphCoefficient_isHermitian P M t) C hv hC
    (whitenedGraphCoefficient_variance_le P M t hP hproj hM hframe)

omit [Fintype κ] [DecidableEq κ] in
theorem graphLaplacian_edge_sum (W : Matrix ι ι ℝ) (hW : ∀ i j, W i j=W j i) :
    (∑ e : ι×ι, W e.1 e.2 • Matrix.vecMulVec
      (fun k => graphEdgeVector e.1 e.2 k) (fun k => graphEdgeVector e.1 e.2 k)) =
    (2:ℝ) • graphLaplacian W := by
  ext r s
  simp only [Fintype.sum_prod_type, Matrix.sum_apply, Matrix.smul_apply, smul_eq_mul,
    Matrix.vecMulVec_apply, graphEdgeVector, PiLp.sub_apply, PiLp.single_apply,
    mul_sub, Finset.sum_sub_distrib, mul_ite, mul_zero, mul_one]
  simp only [Finset.sum_ite_eq, Finset.mem_univ, if_true]
  by_cases hrs : r=s
  · subst s
    simp [graphLaplacian, hW]
    ring
  · simp [graphLaplacian, hrs, hW]
    ring

/-- The linear cross term in the squared-entry graph Laplacian. -/
def graphLinearCross (P Y : Matrix ι ι ℝ) (t : ℝ) : Matrix ι ι ℝ :=
  (2*t) • graphLaplacian (Matrix.of fun i j => P i j * Y i j)

omit [Fintype κ] [DecidableEq κ] in
theorem whitenedGraphCoefficient_series (P M Y : Matrix ι ι ℝ) (t : ℝ)
    (hP : ∀ i j, P i j=P j i) (hY : ∀ i j, Y i j=Y j i) :
    gaussianMatrixSeries (whitenedGraphCoefficient P M t) (fun e => Y e.1 e.2) =
      M * graphLinearCross P Y t * M.transpose := by
  let W : Matrix ι ι ℝ := Matrix.of fun i j => P i j * Y i j
  have hW : ∀ i j, W i j=W j i := by
    intro i j
    simp only [W, Matrix.of_apply, hP i j, hY i j]
  calc
    _ = t • (M * (∑ e : ι×ι, W e.1 e.2 • Matrix.vecMulVec
        (fun k => graphEdgeVector e.1 e.2 k) (fun k => graphEdgeVector e.1 e.2 k)) * M.transpose) := by
      simp only [gaussianMatrixSeries, whitenedGraphCoefficient, Matrix.mul_sum,
        Matrix.sum_mul, Matrix.mul_smul, Matrix.smul_mul, matrix_outer_conjugation,
        Finset.smul_sum, smul_smul]
      apply Finset.sum_congr rfl
      intro e _
      have he : (M *ᵥ fun k => graphEdgeVector e.1 e.2 k) =
          fun k => whitenedGraphEdge M e.1 e.2 k := rfl
      rw [he]
      congr 1
      dsimp [W]
      ring
    _ = _ := by
      rw [graphLaplacian_edge_sum W hW]
      simp only [Matrix.mul_smul, Matrix.smul_mul, smul_smul, graphLinearCross]
      congr 1
      ring

end Paulsen
