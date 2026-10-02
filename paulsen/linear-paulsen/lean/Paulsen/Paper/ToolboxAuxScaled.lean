import Paulsen.Paper.ToolboxAuxPolar
import Paulsen.ScalingDistance
import Paulsen.NormalTangentGraph
import Paulsen.MedianBarrier
import Paulsen.BoxScaling
import Paulsen.FrameComplement
import Paulsen.RadialExistence

/-!
# Helper for `Paulsen.Paper.Toolbox`: `lem:energy`, `lem:scaled`, `lem:potential` (except
convexity), `lem:scaling-ineq`.
-/

namespace Paulsen.Paper.ToolboxAux

open Matrix Paulsen
open scoped BigOperators

noncomputable section

theorem weightedLaplacian_offdiag {ι : Type*} [Fintype ι] [DecidableEq ι] (w : ι → ι → ℝ)
    (x : ι → ℝ) (i : ι) :
    weightedLaplacian (fun i j => if i = j then 0 else w i j) x i = weightedLaplacian w x i := by
  unfold weightedLaplacian
  apply Finset.sum_congr rfl; intro j _
  by_cases h : i = j
  · subst h; simp
  · simp [h]

/-- `lem:energy`, with `frobSq` unfolded. -/
theorem lem_energy' {n d : ℕ} (U : Frame n d) (hU : IsParseval U) :
    (∀ (x : Fin n → ℝ) (i : Fin n),
      (projectionLaplacian (frameProjection U) *ᵥ x) i =
        weightedLaplacian (fun i j => if i = j then 0 else frameProjection U i j ^ 2) x i) ∧
    (projectionLaplacian (frameProjection U)).PosSemidef ∧
    projectionLaplacian (frameProjection U) *ᵥ (fun _ => (1 : ℝ)) = 0 ∧
    projectionLaplacian (1 - frameProjection U) = projectionLaplacian (frameProjection U) ∧
    ∀ x : Fin n → ℝ,
      matrixQuadratic (projectionLaplacian (frameProjection U)) x =
          (1 / 2) * ∑ i, ∑ j, frameProjection U i j ^ 2 * (x i - x j) ^ 2 ∧
      matrixQuadratic (projectionLaplacian (frameProjection U)) x =
          ∑ i, ∑ j, (((1 : Matrix (Fin n) (Fin n) ℝ) - frameProjection U) *
            Matrix.diagonal x * U) i j ^ 2 ∧
      matrixQuadratic (projectionLaplacian (frameProjection U)) x =
          (1 / 2) * ∑ i, ∑ j, (diagonalCommutator x (frameProjection U)) i j ^ 2 := by
  refine ⟨?_, hU.laplacian_posSemidef, ?_, projectionLaplacian_complement _, ?_⟩
  · intro x i
    rw [weightedLaplacian_offdiag]
    exact parseval_laplacian_apply_eq_weighted U hU x i
  · rw [projectionLaplacian_eq_graph _ (frameProjection_symm U) hU.frameProjection_idempotent]
    exact graphLaplacian_mulVec_const _ 1
  · intro x
    refine ⟨hU.laplacian_energy x, ?_, ?_⟩
    · rw [← rowScale_residual_energy U hU x]
      simp only [rowScale, Matrix.mul_assoc]
    · have h := diagonalCommutator_frob_sq x (frameProjection U)
      simp only [normalFrobVector, EuclideanSpace.real_norm_sq_eq, Fintype.sum_prod_type] at h
      have h2 : ∑ i, ∑ j, (diagonalCommutator x (frameProjection U)) i j ^ 2 =
          2 * graphEnergy (Matrix.of fun i j => (frameProjection U i j) ^ 2) x := by
        rw [← h]
      rw [h2, hU.laplacian_energy x]
      unfold graphEnergy
      simp only [Matrix.of_apply]
      ring

theorem diagonal_sq {n : ℕ} (w : Fin n → ℝ) :
    Matrix.diagonal w ^ 2 = Matrix.diagonal (fun i => w i ^ 2) := by
  rw [Matrix.diagonal_pow]; rfl

/-- `lem:scaled`, with `invSqrt` and `frobSq` unfolded. -/
theorem lem_scaled' {n d : ℕ} (U : Frame n d) (hU : IsParseval U) (w : Fin n → ℝ)
    (hw : ∀ i, 0 < w i) {m : ℝ} (hm : 0 < m) (hmw : ∀ i, m ≤ w i) :
    let M := cfc (fun x : ℝ => (Real.sqrt x)⁻¹) (U.transpose * Matrix.diagonal w ^ 2 * U)
    IsParseval (Matrix.diagonal w * U * M) ∧
    LinearMap.range (Matrix.mulVecLin (Matrix.diagonal w * U * M)) =
      LinearMap.range (Matrix.mulVecLin (Matrix.diagonal w * U)) ∧
    sqDistance (frameProjection (Matrix.diagonal w * U * M)) (frameProjection U) =
      2 * ∑ i, ∑ j, (((1 : Matrix (Fin n) (Fin n) ℝ) - frameProjection U) *
        (Matrix.diagonal w * U * M)) i j ^ 2 ∧
    2 * ∑ i, ∑ j, (((1 : Matrix (Fin n) (Fin n) ℝ) - frameProjection U) *
        (Matrix.diagonal w * U * M)) i j ^ 2 ≤
      2 * matrixQuadratic (projectionLaplacian (frameProjection U)) w / m ^ 2 := by
  intro M
  have hG : (U.transpose * Matrix.diagonal w ^ 2 * U) =
      (Matrix.diagonal w * U).transpose * (Matrix.diagonal w * U) := by
    rw [diagonal_sq, Matrix.transpose_mul, Matrix.diagonal_transpose]
    simp only [Matrix.mul_assoc]
    rw [← Matrix.mul_assoc (Matrix.diagonal w) (Matrix.diagonal w), Matrix.diagonal_mul_diagonal]
    simp only [pow_two]
  have hGpd : (U.transpose * Matrix.diagonal w ^ 2 * U).PosDef := by
    rw [hG]
    exact rowScale_gram_posDef U w hU (fun i => (hw i).ne')
  obtain ⟨hMpd, -, hMGM⟩ := invSqrt_spec' _ hGpd
  have hMt : M.transpose = M := by
    have := hMpd.isHermitian
    unfold Matrix.IsHermitian at this
    rwa [Matrix.conjTranspose_eq_transpose_of_trivial] at this
  have hpars : IsParseval (Matrix.diagonal w * U * M) := by
    unfold IsParseval
    rw [Matrix.transpose_mul, hMt]
    calc M * (Matrix.diagonal w * U).transpose * (Matrix.diagonal w * U * M) =
        M * ((Matrix.diagonal w * U).transpose * (Matrix.diagonal w * U)) * M := by
          simp only [Matrix.mul_assoc]
      _ = 1 := by rw [← hG]; exact hMGM
  have hV : IsParseval (rowScale U w * M) := hpars
  refine ⟨hpars, ?_, ?_, ?_⟩
  · rw [Matrix.mulVecLin_mul]
    apply LinearMap.range_comp_of_range_eq_top
    rw [LinearMap.range_eq_top]
    intro y
    refine ⟨((U.transpose * Matrix.diagonal w ^ 2 * U) * M) *ᵥ y, ?_⟩
    rw [Matrix.mulVecLin_apply, Matrix.mulVec_mulVec, ← Matrix.mul_assoc, hMGM,
      Matrix.one_mulVec]
  · rw [sqDistance_symm]
    exact projection_sqDistance_eq_twice_residual U _ hU hpars
  · rw [← projection_sqDistance_eq_twice_residual U _ hU hpars]
    have h := diagonal_scaling_projection_distance_le U w M hU hV m hm hmw
    have : (2 / m ^ 2) * matrixQuadratic (projectionLaplacian (frameProjection U)) w =
        2 * matrixQuadratic (projectionLaplacian (frameProjection U)) w / m ^ 2 := by ring
    rw [← this]
    exact h

/-- Parseval frames have `d ≤ n`. -/
theorem parseval_dim_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U) : d ≤ n := by
  have h1 := hU.total_rowNormSq
  have h2 : ∑ i, rowNormSq U i ≤ ∑ _i : Fin n, (1 : ℝ) :=
    Finset.sum_le_sum fun i _ => hU.leverage_le_one i
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one] at h2
  rw [h1] at h2
  exact_mod_cast h2

theorem sqrt_scaled_leverage {n d : ℕ} (U : Frame n d) (z : Fin n → ℝ) (hz : ∀ i, 0 < z i)
    (i : Fin n) :
    columnSpaceProjection (Matrix.diagonal (fun j => Real.sqrt (z j)) * U) i i =
      scaledLeverage U z i := by
  have h := rowScale_projection_diagonal U (fun j => Real.sqrt (z j)) i
  unfold rowScale at h
  rw [h]
  congr 1
  funext j
  exact Real.sq_sqrt (hz j).le

/-- `lem:scaling-ineq`, with `sqrtScaledDiagonal` unfolded. -/
theorem lem_scaling_ineq' {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (z : Fin n → ℝ) (hz : ∀ i, 0 < z i) (i : Fin n) :
    weightedLaplacian (fun i j => frameProjection U i j ^ 2) z i ≤
      z i * (columnSpaceProjection (Matrix.diagonal (fun j => Real.sqrt (z j)) * U) i i -
        rowNormSq U i) ∧
    weightedLaplacian (fun i j => frameProjection U i j ^ 2) (fun j => (z j)⁻¹) i ≤
      -(z i)⁻¹ * (columnSpaceProjection (Matrix.diagonal (fun j => Real.sqrt (z j)) * U) i i -
        rowNormSq U i) := by
  rw [sqrt_scaled_leverage U z hz i, ← frameProjection_diagonal]
  obtain ⟨V, hV, hcomplete, horth⟩ := hU.exists_complement U (parseval_dim_le hU)
  constructor
  · have h1 := parseval_diagonal_scaling_first_inequality U z hU hz i
    rw [parseval_laplacian_apply_eq_weighted U hU] at h1
    exact h1
  · have h1 := diagonal_scaling_reciprocal_inequality U V z hU hV hcomplete horth hz i
    rw [parseval_laplacian_apply_eq_weighted U hU] at h1
    exact h1

/-- The library potential equals the paper's `F`. -/
theorem potential_eq {n d : ℕ} (U : Frame n d) :
    diagonalScalingPotential U = fun s =>
      (1 / 2) * Real.log (U.transpose * Matrix.diagonal (fun i => Real.exp (2 * s i)) * U).det := by
  funext s
  rw [diagonalScalingPotential_eq_logdet]
  rfl

theorem exp_scaled_leverage {n d : ℕ} (U : Frame n d) (s : Fin n → ℝ) (i : Fin n) :
    columnSpaceProjection (Matrix.diagonal (fun i => Real.exp (s i)) * U) i i =
      scaledLeverage U (fun j => Real.exp (2 * s j)) i := by
  have h := rowScale_projection_diagonal U (fun j => Real.exp (s j)) i
  unfold rowScale at h
  rw [h]
  congr 1
  funext j
  rw [pow_two, ← Real.exp_add]; congr 1; ring

/-- `lem:potential`, all parts but convexity, unfolded. -/
theorem lem_potential_basic {n d : ℕ} (U : Frame n d) (hU : IsParseval U) :
    let F : (Fin n → ℝ) → ℝ := fun s =>
      (1 / 2) * Real.log (U.transpose * Matrix.diagonal (fun i => Real.exp (2 * s i)) * U).det
    let r : (Fin n → ℝ) → Fin n → ℝ := fun s i =>
      columnSpaceProjection (Matrix.diagonal (fun i => Real.exp (s i)) * U) i i
    (∀ k : WithTop ℕ∞, ContDiff ℝ k F) ∧
    (∀ s, HasFDerivAt F
      (∑ i, r s i • (ContinuousLinearMap.proj i : (Fin n → ℝ) →L[ℝ] ℝ)) s) ∧
    (∀ s, ∑ i, r s i = (d : ℝ)) ∧
    ∀ s (c : ℝ), F (fun i => s i + c) = F s + c * d := by
  intro F r
  have hF : F = diagonalScalingPotential U := (potential_eq U).symm
  have hr : ∀ s i, r s i = scaledLeverage U (fun j => Real.exp (2 * s j)) i :=
    fun s i => exp_scaled_leverage U s i
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro k; rw [hF]; exact diagonalScalingPotential_contDiff hU k
  · intro s
    rw [hF]
    have h := hasFDerivAt_diagonalScalingPotential hU s
    have : (∑ i, r s i • (ContinuousLinearMap.proj i : (Fin n → ℝ) →L[ℝ] ℝ)) =
        diagonalScalingDerivative U s := by
      simp only [hr]; rfl
    rw [this]; exact h
  · intro s
    simp only [hr]
    exact sum_exp_scaledLeverage hU s
  · intro s c
    have hG : U.transpose * Matrix.diagonal (fun i => Real.exp (2 * (s i + c))) * U =
        Real.exp (2 * c) • (U.transpose * Matrix.diagonal (fun i => Real.exp (2 * s i)) * U) := by
      have : Matrix.diagonal (fun i => Real.exp (2 * (s i + c))) =
          Real.exp (2 * c) • Matrix.diagonal (fun i => Real.exp (2 * s i)) := by
        rw [← Matrix.diagonal_smul]
        congr 1; funext i
        rw [Pi.smul_apply, smul_eq_mul, ← Real.exp_add]; congr 1; ring
      rw [this, Matrix.mul_smul, Matrix.smul_mul]
    have hpos : 0 < (U.transpose * Matrix.diagonal (fun i => Real.exp (2 * s i)) * U).det :=
      (weightedFrameGram_posDef U _ hU (fun i => Real.exp_pos _)).det_pos
    simp only [F]
    rw [hG, Matrix.det_smul, Fintype.card_fin, Real.log_mul (by positivity) hpos.ne',
      Real.log_pow, Real.log_exp]
    ring

end

end Paulsen.Paper.ToolboxAux
