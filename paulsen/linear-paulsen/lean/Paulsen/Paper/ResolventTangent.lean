import Paulsen.ResolventNoiseBounds
import Paulsen.ResolventResidualVariance
import Paulsen.ExpectedTangentExpansion
import Paulsen.GaussianSchurSquare

/-! Tangent and Gaussian adapters for the ordinary resolvent covariance. -/
namespace Paulsen.Resolvent
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators
noncomputable section

def retainedTangentFactor {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    Matrix (Fin n × Fin n) (Fin n × Fin d) ℝ :=
  tangentLiftMatrix U * normalizedTangentNoiseFactor U ρ

def tangentLiftRowMatrix {n d : ℕ} (U : Frame n d) (i : Fin n) :
    Matrix (Fin n) (Fin n × Fin d) ℝ :=
  Matrix.of fun k p => tangentLiftMatrix U (i,k) p

def retainedTangentRowFactor {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i : Fin n) :
    Matrix (Fin n) (Fin n × Fin d) ℝ :=
  tangentLiftRowMatrix U i * normalizedTangentNoiseFactor U ρ

theorem retainedTangentRowFactor_apply {n d : ℕ} (U : Frame n d) (ρ : ℝ)
    (i k : Fin n) (p : Fin n × Fin d) :
    retainedTangentRowFactor U ρ i k p = retainedTangentFactor U ρ (i,k) p := rfl

theorem retainedTangentFactor_norm_sq {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (ρ : ℝ) (g : EuclideanSpace ℝ (Fin n × Fin d)) :
    ‖Matrix.toEuclideanLin (retainedTangentFactor U ρ) g‖ ^ 2 =
      2 * ‖Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g‖ ^ 2 := by
  let H : Frame n d := Matrix.of fun i a =>
    Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g (i,a)
  have hH : U.transpose * H = 0 := normalizedTangentNoiseFactor_horizontal hU ρ (fun p => g p)
  have hv : Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g = normalFrobVector H := by
    ext p
    rfl
  have hprod : Matrix.toEuclideanLin (retainedTangentFactor U ρ) g =
      Matrix.toEuclideanLin (tangentLiftMatrix U)
        (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g) := by
    simp only [retainedTangentFactor, Matrix.toEuclideanLin, Matrix.toLpLin_mul_same, LinearMap.comp_apply]
  rw [hprod, hv, tangentLiftMatrix_apply]
  exact horizontal_tangent_frobenius_sq hU hH

/-- A squared pointwise norm bound gives the corresponding squared operator bound. -/
theorem euclidean_operator_norm_sq_le_of_pointwise {ι κ : Type*}
    [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]
    (M : Matrix ι κ ℝ) {v : ℝ} (hv : 0 ≤ v)
    (hM : ∀ x : EuclideanSpace ℝ κ, ‖Matrix.toEuclideanLin M x‖ ^ 2 ≤ v * ‖x‖ ^ 2) :
    ‖(Matrix.toEuclideanLin M).toContinuousLinearMap‖ ^ 2 ≤ v := by
  have hb : ‖(Matrix.toEuclideanLin M).toContinuousLinearMap‖ ≤ Real.sqrt v := by
    apply ContinuousLinearMap.opNorm_le_bound _ (Real.sqrt_nonneg v)
    intro x
    have hx := hM x
    have hs := Real.sq_sqrt hv
    change ‖Matrix.toEuclideanLin M x‖ ≤ Real.sqrt v * ‖x‖
    nlinarith [norm_nonneg (Matrix.toEuclideanLin M x), norm_nonneg x,
      mul_nonneg (Real.sqrt_nonneg v) (norm_nonneg x)]
  nlinarith [norm_nonneg (Matrix.toEuclideanLin M).toContinuousLinearMap,
    Real.sqrt_nonneg v, Real.sq_sqrt hv]

theorem retainedTangentFactor_pointwise_sq_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ)
    (g : EuclideanSpace ℝ (Fin n × Fin d)) :
    ‖Matrix.toEuclideanLin (retainedTangentFactor U ρ) g‖ ^ 2 ≤
      (2 / (n : ℝ)) * ‖g‖ ^ 2 := by
  rw [retainedTangentFactor_norm_sq hU]
  have hn := normalizedTangentNoiseFactor_operator_norm_sq_le hU hρ
  have hx := (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ)).toContinuousLinearMap.le_opNorm g
  have hx2 := (sq_le_sq₀ (norm_nonneg _) (mul_nonneg (norm_nonneg _) (norm_nonneg g))).2 hx
  rw [mul_pow] at hx2
  have hm := mul_le_mul_of_nonneg_right hn (sq_nonneg ‖g‖)
  change ‖Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g‖ ^ 2 ≤ _ at hx2
  calc
    _ ≤ 2 * ((1 / (n : ℝ)) * ‖g‖ ^ 2) := mul_le_mul_of_nonneg_left (hx2.trans hm) (by norm_num)
    _ = _ := by ring

theorem retainedTangentFactor_operator_norm_sq_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    ‖(Matrix.toEuclideanLin (retainedTangentFactor U ρ)).toContinuousLinearMap‖ ^ 2 ≤
      2 / (n : ℝ) :=
  euclidean_operator_norm_sq_le_of_pointwise _ (by positivity)
    (retainedTangentFactor_pointwise_sq_le hU hρ)

theorem retainedTangentRowFactor_operator_norm_sq_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) (i : Fin n) :
    ‖(Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i)).toContinuousLinearMap‖ ^ 2 ≤
      2 / (n : ℝ) := by
  apply euclidean_operator_norm_sq_le_of_pointwise _ (by positivity)
  intro g
  have hs : ‖Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i) g‖ ^ 2 ≤
      ‖Matrix.toEuclideanLin (retainedTangentFactor U ρ) g‖ ^ 2 := by
    simp only [EuclideanSpace.real_norm_sq_eq, Fintype.sum_prod_type]
    change (∑ k : Fin n, (Matrix.toEuclideanLin (retainedTangentFactor U ρ) g (i,k)) ^ 2) ≤ _
    exact Finset.single_le_sum
      (fun (j : Fin n) _ => Finset.sum_nonneg fun (k : Fin n) _ =>
        sq_nonneg (Matrix.toEuclideanLin (retainedTangentFactor U ρ) g (j,k))) (Finset.mem_univ i)
  exact hs.trans (retainedTangentFactor_pointwise_sq_le hU hρ g)

def moderateNoiseFrame {n d : ℕ} (U : Frame n d) (ρ : ℝ) (g : FrameVector n d) : Frame n d :=
  frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g)

theorem moderateNoiseFrame_horizontal {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (ρ : ℝ) (g : FrameVector n d) : U.transpose * moderateNoiseFrame U ρ g = 0 :=
  normalizedTangentNoiseFactor_horizontal hU ρ g.ofLp

theorem moderateNoiseFrame_tangent {n d : ℕ} (U : Frame n d) (ρ : ℝ) (g : FrameVector n d) :
    gaussianMatrixImage (retainedTangentFactor U ρ) g =
      moderateNoiseFrame U ρ g * U.transpose + U * (moderateNoiseFrame U ρ g).transpose := by
  have he : Matrix.toEuclideanLin (retainedTangentFactor U ρ) g =
      Matrix.toEuclideanLin (tangentLiftMatrix U)
        (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g) := by
    simp only [retainedTangentFactor, Matrix.toEuclideanLin, Matrix.toLpLin_mul_same,
      LinearMap.comp_apply]
  ext i j
  change Matrix.toEuclideanLin (retainedTangentFactor U ρ) g (i,j) = _
  rw [he]
  exact tangentLiftMatrix_mulVec U (moderateNoiseFrame U ρ g) i j

theorem retainedTangentFactor_covariance {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0≤ρ) :
    retainedTangentFactor U ρ*(retainedTangentFactor U ρ).transpose=
      (1/(n:ℝ)) • (tangentLiftMatrix U*covariance U ρ*(tangentLiftMatrix U).transpose) := by
  unfold retainedTangentFactor
  rw [Matrix.transpose_mul]
  calc
    _ = tangentLiftMatrix U*(normalizedTangentNoiseFactor U ρ*
        (normalizedTangentNoiseFactor U ρ).transpose)*(tangentLiftMatrix U).transpose := by
      simp only [Matrix.mul_assoc]
    _ = _ := by rw [normalizedTangentNoiseFactor_covariance hU hρ,Matrix.mul_smul,Matrix.smul_mul]

theorem covariance_eq_horizontal_sub {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i,0<rowNormSq U i) {ρ : ℝ} (hρ : 0≤ρ) :
    covariance U ρ=horizontalProjectionMatrix U-baseWeight ρ • normalizedNormalCovariance U-normalizedPositiveResidual U ρ := by
  unfold normalizedPositiveResidual
  rw [max_eq_right hρ]
  have hh:=congrArg (fun M=>horizontalProjectionMatrix U-M) (residual_decomposition hU hp hρ)
  convert hh using 1 <;> abel

theorem integral_retainedTangent_graphEnergy_eq {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0≤ρ) (x : Fin n→ℝ) :
    (∫ g,graphEnergy (Matrix.of fun i j=>(Matrix.toEuclideanLin (retainedTangentFactor U ρ) g (i,j))^2) x
      ∂stdGaussian (FrameVector n d))=(1/(n:ℝ))*tangentCovarianceGraph U x (covariance U ρ) := by
  rw [integral_gaussianImage_graphEnergy_eq_covariance,retainedTangentFactor_covariance hU hρ,
    tangentCovarianceGraph_eq,←graphEnergy_smul_eq]
  rfl

theorem tangentCovarianceGraph_positive {n d : ℕ} (U : Frame n d) (ρ : ℝ) (x : Fin n→ℝ) :
    (1/(n:ℝ))*tangentCovarianceGraph U x (normalizedPositiveResidual U ρ)=
      graphEnergy (Matrix.of (positiveResidualEntryLoss U ρ)) x := by
  rw [tangentCovarianceGraph_eq,←graphEnergy_smul_eq]
  rfl

def retainedTangentEntryVariance {n d : ℕ} (U : Frame n d) (ρ : ℝ)
    (i j : Fin n) : ℝ :=
  (retainedTangentFactor U ρ * (retainedTangentFactor U ρ).transpose) (i,j) (i,j)

theorem tangentCovarianceEntry_nonneg {n d : ℕ} (U : Frame n d) (i j : Fin n)
    (C : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) (hC : C.PosSemidef) :
    0 ≤ tangentCovarianceEntry U i j C := by
  have h := hC.mul_mul_conjTranspose_same (tangentLiftMatrix U)
  simpa only [tangentCovarianceEntry, LinearMap.coe_mk, AddHom.coe_mk,
    Matrix.conjTranspose_eq_transpose_of_trivial] using h.diag_nonneg (i := (i,j))

theorem tangentCovarianceEntry_base {n d : ℕ} (U : Frame n d) (i j : Fin n) :
    (1/(n:ℝ))*tangentCovarianceEntry U i j (normalizedNormalCovariance U) =
      baseNormalTangentVariance U i j := by
  simp only [normalizedNormalCovariance_base_decomposition, map_sum,
    tangentCovarianceEntry_outer, baseNormalTangentVariance, Matrix.of_apply,
    baseNormalTangent]

theorem retainedTangentEntryVariance_lower {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i,0<rowNormSq U i) {ρ : ℝ} (hρ : 0≤ρ)
    (i j : Fin n) (hij : i≠j) :
    (rowNormSq U i+rowNormSq U j-2*rowNormSq U i*rowNormSq U j-
        2*(frameProjection U i j)^2)/(n:ℝ)-baseWeight ρ * baseNormalTangentVariance U i j-
        positiveResidualEntryLoss U ρ i j≤retainedTangentEntryVariance U ρ i j := by
  have he : retainedTangentEntryVariance U ρ i j=
      (1/(n:ℝ))*tangentCovarianceEntry U i j (covariance U ρ) := by
    rw [retainedTangentEntryVariance,retainedTangentFactor_covariance hU hρ]
    rfl
  rw [he,covariance_eq_horizontal_sub hU hp hρ,map_sub,map_sub,map_smul]
  have hb:=tangentCovarianceEntry_base U i j
  have hr : (1/(n:ℝ))*tangentCovarianceEntry U i j (normalizedPositiveResidual U ρ)=
      positiveResidualEntryLoss U ρ i j := rfl
  have hu:=unconditionedTangent_entry_variance_offDiagonal U i j hij
  change (1/(n:ℝ))*tangentCovarianceEntry U i j (horizontalProjectionMatrix U)=_ at hu
  simp only [smul_eq_mul]
  rw [mul_sub, mul_sub]
  nlinarith only [hr, hu, congrArg (fun z : ℝ => baseWeight ρ * z) hb]


end
end Paulsen.Resolvent
