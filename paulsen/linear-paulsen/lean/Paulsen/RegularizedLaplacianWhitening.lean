import Paulsen.WhitenedGraphCross
import Paulsen.RadialExistence

/-! An actual inverse-square-root whitener for a regularized PSD matrix. -/
open Matrix
open scoped BigOperators MatrixOrder
noncomputable section
namespace Paulsen
variable {ι : Type*} [Fintype ι] [DecidableEq ι]

theorem exists_regularized_whitener (L : Matrix ι ι ℝ) (hL : L.PosSemidef)
    {r : ℝ} (hr : 0<r) :
    ∃ M : Matrix ι ι ℝ, M.PosDef ∧
      M * (L + r • 1) * M.transpose = 1 ∧
      (1 - M*L*M.transpose).PosSemidef ∧
      ‖(Matrix.toEuclideanLin M).toContinuousLinearMap‖^2 ≤ 1/r := by
  let J := L + r • (1 : Matrix ι ι ℝ)
  have hJ : J.PosDef := by
    simpa only [J, add_comm] using (Matrix.PosDef.one.smul hr).add_posSemidef hL
  let H := CFC.sqrt J
  have hHpsd : H.PosSemidef := Matrix.nonneg_iff_posSemidef.mp (CFC.sqrt_nonneg J)
  have hHunit : IsUnit H := (CFC.isUnit_sqrt_iff J hJ.posSemidef.nonneg).mpr hJ.isUnit
  have hHpos : H.PosDef := hHpsd.posDef_iff_isUnit.mpr hHunit
  have hsq : H*H=J := by
    simpa only [pow_two] using CFC.sq_sqrt J hJ.posSemidef.nonneg
  have hleft : H⁻¹*H=1 := Matrix.nonsing_inv_mul H
    ((Matrix.isUnit_iff_isUnit_det H).mp hHunit)
  have hright : H*H⁻¹=1 := Matrix.mul_nonsing_inv H
    ((Matrix.isUnit_iff_isUnit_det H).mp hHunit)
  let M := H⁻¹
  have hMpos : M.PosDef := hHpos.inv
  have hsym : M.transpose=M := by
    simpa only [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial]
      using hMpos.isHermitian
  have hW : M*J*M.transpose=1 := by
    rw [hsym, ← hsq]
    change H⁻¹*(H*H)*H⁻¹=1
    calc
      _ = (H⁻¹*H)*(H*H⁻¹) := by simp only [Matrix.mul_assoc]
      _ = 1 := by rw [hleft, hright, Matrix.one_mul]
  have hW' : M*L*M.transpose + r • (M*M.transpose) = 1 := by
    simpa only [J, Matrix.mul_add, Matrix.add_mul, Matrix.mul_smul, Matrix.smul_mul,
      Matrix.mul_one] using hW
  have hframe : (1 - M*L*M.transpose).PosSemidef := by
    have hh : (r • (M*M.transpose)).PosSemidef := by
      simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
        (Matrix.posSemidef_self_mul_conjTranspose M).smul hr.le
    convert hh using 1
    rw [← hW']; abel
  have hbound : (1 - r • (M*M.transpose)).PosSemidef := by
    have hh : (M*L*M.transpose).PosSemidef := by
      simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
        hL.mul_mul_conjTranspose_same M
    convert hh using 1
    rw [← hW']; abel
  refine ⟨M, hMpos, hW, hframe, ?_⟩
  apply euclidean_operator_norm_sq_le_of_pointwise M (by positivity)
  intro x
  have hh : 0≤euclideanQuadratic (1 - r • (M*M.transpose)) x := by
    rw [euclideanQuadratic, real_inner_comm]
    simpa only [EuclideanSpace.inner_eq_star_dotProduct,
      Matrix.toLpLin_apply, WithLp.ofLp_toLp, star_trivial] using
      hbound.dotProduct_mulVec_nonneg (fun i => x i)
  have he : euclideanQuadratic (1 - r • (M*M.transpose)) x =
      ‖x‖^2 - r*‖Matrix.toEuclideanLin M x‖^2 := by
    simp only [euclideanQuadratic, map_sub, map_smul, LinearMap.sub_apply,
      LinearMap.smul_apply, inner_sub_right, real_inner_smul_right]
    simp only [Matrix.toEuclideanLin, Matrix.toLpLin_one, LinearMap.id_apply]
    change inner ℝ x x - r*euclideanQuadratic (M*M.transpose) x = _
    have hn := norm_sq_gaussianImage_eq_quadratic M.transpose x
    simp only [hsym] at hn
    rw [real_inner_self_eq_norm_sq, hsym, ← hn]
  rw [he] at hh
  rw [one_div_mul_eq_div]
  apply (le_div_iff₀ hr).mpr
  nlinarith only [hh]

/-- A whitened operator-norm bound controls the original quadratic form in the
regularized energy, simultaneously for every vector. -/
theorem quadratic_cross_le_of_whitened_norm (J C M : Matrix ι ι ℝ)
    (hM : M.PosDef) (hW : M*J*M.transpose=1) {δ : ℝ}
    (hC : ‖(Matrix.toEuclideanLin (M*C*M.transpose)).toContinuousLinearMap‖≤δ)
    (x : EuclideanSpace ℝ ι) :
    |euclideanQuadratic C x| ≤ δ*euclideanQuadratic J x := by
  have hsym : M.transpose=M := by
    simpa only [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial] using hM.isHermitian
  let y := Matrix.toEuclideanLin M⁻¹ x
  have hxy : Matrix.toEuclideanLin M.transpose y=x := by
    rw [hsym]
    dsimp [y]
    simp only [Matrix.toEuclideanLin, ← Matrix.toLpLin_mul_same, ← LinearMap.comp_apply]
    rw [Matrix.mul_nonsing_inv M ((Matrix.isUnit_iff_isUnit_det M).mp hM.isUnit)]
    simp only [Matrix.toLpLin_one, LinearMap.id_apply]
  have hq (A : Matrix ι ι ℝ) : euclideanQuadratic (M*A*M.transpose) y = euclideanQuadratic A x := by
    have hh := euclideanQuadratic_linear_image A M.transpose y
    simpa only [Matrix.transpose_transpose, hxy] using hh.symm
  have hnorm : ‖y‖^2=euclideanQuadratic J x := by
    rw [← hq J, hW]
    simp [euclideanQuadratic, Matrix.toEuclideanLin, Matrix.toLpLin_one]
  rw [← hq C, ← hnorm]
  calc
    _ ≤ ‖y‖*‖Matrix.toEuclideanLin (M*C*M.transpose) y‖ := abs_real_inner_le_norm _ _
    _ ≤ ‖y‖*(‖(Matrix.toEuclideanLin (M*C*M.transpose)).toContinuousLinearMap‖*‖y‖) :=
      mul_le_mul_of_nonneg_left
        ((Matrix.toEuclideanLin (M*C*M.transpose)).toContinuousLinearMap.le_opNorm y) (norm_nonneg _)
    _ ≤ ‖y‖*(δ*‖y‖) := by gcongr
    _ = _ := by ring

end Paulsen
