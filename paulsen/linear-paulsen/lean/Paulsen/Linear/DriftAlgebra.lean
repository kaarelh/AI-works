import Paulsen.SmoothMean
import Paulsen.NormalResidualVariance

/-!
# Algebra of the deterministic drift

For a potential `f` the normal direction `N_f = (I-P) Diag f U` has quadratic
diagonal `q(N_f) = 𝒜 Γ_f` with the explicit horizontal matrix
`Γ_f = (I-P) Diag f (I-2P) Diag f U`, and `‖Γ_f‖_F ≤ 2 ‖f‖_∞ ‖N_f‖_F`.
Averaging over the filtered modes gives the drift `m_*` with `𝒜 m_* = b_*`
and `‖m_*‖_F² ≤ a² / (p ρ)`. We also record the polarisation of the quadratic
diagonal and the elementary row estimates used for the drifted retraction.
-/

namespace Paulsen.Linear

open Matrix Paulsen
open scoped BigOperators

noncomputable section

/-! ### Frobenius norm helpers -/

theorem normalFrobVector_norm_sq_eq_sum {n d : ℕ} (H : Frame n d) :
    ‖normalFrobVector H‖ ^ 2 = ∑ i, rowNormSq H i := by
  simp only [normalFrobVector, EuclideanSpace.real_norm_sq_eq, Fintype.sum_prod_type,
    rowNormSq]

theorem rowNormSq_le_frob_sq {n d : ℕ} (H : Frame n d) (i : Fin n) :
    rowNormSq H i ≤ ‖normalFrobVector H‖ ^ 2 := by
  rw [normalFrobVector_norm_sq_eq_sum]
  exact Finset.single_le_sum (fun j _ => rowNormSq_nonneg H j) (Finset.mem_univ i)

theorem normalFrobVector_sub' {n d : ℕ} (A B : Frame n d) :
    normalFrobVector (A - B) = normalFrobVector A - normalFrobVector B := rfl

theorem normalFrobVector_smul' {n d : ℕ} (c : ℝ) (A : Frame n d) :
    normalFrobVector (c • A) = c • normalFrobVector A := rfl

theorem normalFrobVector_sum' {n d : ℕ} {ι : Type*} (s : Finset ι) (A : ι → Frame n d) :
    normalFrobVector (∑ j ∈ s, A j) = ∑ j ∈ s, normalFrobVector (A j) := by
  ext p
  simp [normalFrobVector, Matrix.sum_apply]

theorem rowNormSq_eq_mul_transpose {n d : ℕ} (X : Frame n d) (i : Fin n) :
    rowNormSq X i = (X * X.transpose) i i := by
  simp [rowNormSq, Matrix.mul_apply, sq]

/-- Splitting of the Frobenius norm along `P` and `I-P`. -/
theorem frob_sq_split {n d m : ℕ} {U : Frame n d} (hU : IsParseval U)
    (X : Matrix (Fin n) (Fin m) ℝ) :
    ‖normalFrobVector (frameComplementProjection U * X)‖ ^ 2 +
      ‖normalFrobVector (U.transpose * X)‖ ^ 2 = ‖normalFrobVector X‖ ^ 2 := by
  rw [normalFrobVector_norm_sq, normalFrobVector_norm_sq, normalFrobVector_norm_sq,
    ← Matrix.trace_add]
  congr 1
  rw [Matrix.transpose_mul, Matrix.transpose_mul, Matrix.transpose_transpose,
    frameComplementProjection_transpose]
  have hQ : X.transpose * frameComplementProjection U * (frameComplementProjection U * X) =
      X.transpose * frameComplementProjection U * X := by
    rw [← Matrix.mul_assoc, Matrix.mul_assoc X.transpose,
      hU.frameComplementProjection_idempotent]
  rw [hQ]
  simp only [frameComplementProjection, frameProjection, Matrix.mul_sub, Matrix.sub_mul,
    Matrix.mul_one, Matrix.mul_assoc]
  abel

theorem frob_complement_mul_le {n d m : ℕ} {U : Frame n d} (hU : IsParseval U)
    (X : Matrix (Fin n) (Fin m) ℝ) :
    ‖normalFrobVector (frameComplementProjection U * X)‖ ≤ ‖normalFrobVector X‖ := by
  have h := frob_sq_split hU X
  have h0 := sq_nonneg ‖normalFrobVector (U.transpose * X)‖
  exact (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mp (by linarith)

theorem frob_transpose_mul_le {n d m : ℕ} {U : Frame n d} (hU : IsParseval U)
    (X : Matrix (Fin n) (Fin m) ℝ) :
    ‖normalFrobVector (U.transpose * X)‖ ≤ ‖normalFrobVector X‖ := by
  have h := frob_sq_split hU X
  have h0 := sq_nonneg ‖normalFrobVector (frameComplementProjection U * X)‖
  exact (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mp (by linarith)

/-- The operator norm is at most the Frobenius norm. -/
theorem opNorm_le_frob {n d : ℕ} (K : Frame n d) :
    ‖(Matrix.toEuclideanLin K).toContinuousLinearMap‖ ≤ ‖normalFrobVector K‖ := by
  apply ContinuousLinearMap.opNorm_le_bound _ (norm_nonneg _)
  intro x
  have hsq : ‖(Matrix.toEuclideanLin K).toContinuousLinearMap x‖ ^ 2 ≤
      (‖normalFrobVector K‖ * ‖x‖) ^ 2 := by
    rw [mul_pow, normalFrobVector_norm_sq_eq_sum, EuclideanSpace.real_norm_sq_eq,
      EuclideanSpace.real_norm_sq_eq, Finset.sum_mul]
    apply Finset.sum_le_sum
    intro i _
    simp only [LinearMap.coe_toContinuousLinearMap', Matrix.toLpLin_apply,
      Matrix.mulVec, dotProduct, Real.norm_eq_abs, sq_abs, rowNormSq]
    exact Finset.sum_mul_sq_le_sq_mul_sq _ _ _
  exact (sq_le_sq₀ (norm_nonneg _) (by positivity)).mp hsq

/-! ### The commutator matrix `Γ_f` -/

/-- `Γ_f = (I-P) Diag f (I-2P) Diag f U`, in ambient coordinates. -/
def driftGamma {n d : ℕ} (U : Frame n d) (f : Fin n → ℝ) : Frame n d :=
  frameComplementProjection U * Matrix.diagonal f *
    (1 - (2 : ℝ) • frameProjection U) * Matrix.diagonal f * U

theorem driftGamma_eq {n d : ℕ} (U : Frame n d) (f : Fin n → ℝ) :
    driftGamma U f = frameComplementProjection U * (Matrix.diagonal f * ambientNormal U f) -
      ambientNormal U f * (U.transpose * Matrix.diagonal f * U) := by
  unfold driftGamma ambientNormal
  have h2 : (1 : Matrix (Fin n) (Fin n) ℝ) - (2 : ℝ) • frameProjection U =
      frameComplementProjection U - frameProjection U := by
    simp only [frameComplementProjection, two_smul]; abel
  rw [h2]
  simp only [frameProjection, Matrix.mul_sub, Matrix.sub_mul, Matrix.mul_assoc]

theorem driftGamma_horizontal {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (f : Fin n → ℝ) : U.transpose * driftGamma U f = 0 := by
  have hUQ : U.transpose * frameComplementProjection U = 0 := by
    simp only [frameComplementProjection, frameProjection, Matrix.mul_sub, Matrix.mul_one,
      ← Matrix.mul_assoc]
    rw [show U.transpose * U = 1 from hU, Matrix.one_mul, sub_self]
  unfold driftGamma
  simp only [Matrix.mul_assoc] at hUQ ⊢
  rw [← Matrix.mul_assoc, hUQ, Matrix.zero_mul]

/-- Lemma `commutator`(a): `q(N_f) = 𝒜 Γ_f`. -/
theorem horizontalQuadraticDiagonal_ambientNormal {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (f : Fin n → ℝ) (i : Fin n) :
    horizontalQuadraticDiagonal U (ambientNormal U f) i =
      (driftGamma U f * U.transpose) i i := by
  set Q := frameComplementProjection U with hQdef
  set P := frameProjection U with hPdef
  set F := Matrix.diagonal f with hFdef
  have hQt : Q.transpose = Q := frameComplementProjection_transpose U
  have hFt : F.transpose = F := Matrix.diagonal_transpose f
  have hQQ : ∀ X : Matrix (Fin n) (Fin n) ℝ, Q * (Q * X) = Q * X := by
    intro X; rw [← Matrix.mul_assoc, hU.frameComplementProjection_idempotent]
  have hUU : ∀ X : Matrix (Fin n) (Fin n) ℝ, U * (U.transpose * X) = P * X := by
    intro X; rw [← Matrix.mul_assoc]; rfl
  have hUU' : ∀ X : Matrix (Fin n) (Fin d) ℝ, U * (U.transpose * X) = P * X := by
    intro X; rw [← Matrix.mul_assoc]; rfl
  have hUU0 : U * U.transpose = P := rfl
  have key : ambientNormal U f * (ambientNormal U f).transpose -
      (U * (ambientNormal U f).transpose) * (U * (ambientNormal U f).transpose).transpose -
      driftGamma U f * U.transpose = (Q * F * P) * F - F * (Q * F * P) := by
    have h2 : (1 : Matrix (Fin n) (Fin n) ℝ) - (2 : ℝ) • frameProjection U =
        Q - P := by
      simp only [hQdef, hPdef, frameComplementProjection, two_smul]; abel
    unfold driftGamma ambientNormal
    rw [h2]
    simp only [Matrix.transpose_mul, Matrix.transpose_transpose, ← hQdef, ← hFdef, hQt, hFt,
      Matrix.mul_assoc, hQQ, hUU, hUU', hUU0]
    simp only [hQdef, hPdef, frameComplementProjection, Matrix.transpose_sub,
      Matrix.transpose_one, frameProjection_transpose]
    noncomm_ring
  have hd : (ambientNormal U f * (ambientNormal U f).transpose) i i -
      ((U * (ambientNormal U f).transpose) * (U * (ambientNormal U f).transpose).transpose) i i -
      (driftGamma U f * U.transpose) i i = 0 := by
    rw [← Matrix.sub_apply, ← Matrix.sub_apply, key, Matrix.sub_apply, hFdef,
      Matrix.mul_diagonal, Matrix.diagonal_mul]
    ring
  unfold horizontalQuadraticDiagonal
  rw [rowNormSq_eq_mul_transpose, rowNormSq_eq_mul_transpose]
  linarith

/-- `‖Γ_f‖_F ≤ 2 ‖f‖_∞ ‖N_f‖_F`. -/
theorem driftGamma_norm_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (f : Fin n → ℝ) {M : ℝ} (hM : 0 ≤ M) (hf : ∀ i, |f i| ≤ M) :
    ‖normalFrobVector (driftGamma U f)‖ ≤ 2 * M * ‖normalFrobVector (ambientNormal U f)‖ := by
  set N := ambientNormal U f
  rw [driftGamma_eq, normalFrobVector_sub']
  have h1 : ‖normalFrobVector (frameComplementProjection U * (Matrix.diagonal f * N))‖ ≤
      M * ‖normalFrobVector N‖ :=
    (frob_complement_mul_le hU _).trans (normalFrobVector_diagonal_mul_norm_le N f hM hf)
  have h2 : ‖normalFrobVector (N * (U.transpose * Matrix.diagonal f * U))‖ ≤
      M * ‖normalFrobVector N‖ := by
    have he : (N * (U.transpose * Matrix.diagonal f * U)).transpose =
        U.transpose * (Matrix.diagonal f * (U * N.transpose)) := by
      simp only [Matrix.transpose_mul, Matrix.transpose_transpose, Matrix.diagonal_transpose,
        Matrix.mul_assoc]
    rw [← normalFrobVector_transpose_norm, he]
    refine (frob_transpose_mul_le hU _).trans ?_
    refine (normalFrobVector_diagonal_mul_norm_le _ f hM hf).trans ?_
    have h3 : U * N.transpose = (N * U.transpose).transpose := by
      rw [Matrix.transpose_mul, Matrix.transpose_transpose]
    rw [h3, normalFrobVector_transpose_norm, normalFrobVector_mul_parseval_transpose_norm hU]
  calc _ ≤ _ := norm_sub_le _ _
    _ ≤ M * ‖normalFrobVector N‖ + M * ‖normalFrobVector N‖ := add_le_add h1 h2
    _ = _ := by ring

/-! ### The drift `m_*` -/

/-- `m_* = (1/n) ∑_{μ>0} (r_μ/μ) Γ_{f_y}`. -/
def driftMean {n d : ℕ} (U : Frame n d) (ρ : ℝ) : Frame n d :=
  (1 / (n : ℝ)) • ∑ j ∈ highNormalizedModes U 0,
    (Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) /
      normalizedFisherEigenvalue U j) • driftGamma U (normalizedNormalPotential U j)

theorem driftMean_horizontal {n d : ℕ} {U : Frame n d} (hU : IsParseval U) (ρ : ℝ) :
    U.transpose * driftMean U ρ = 0 := by
  unfold driftMean
  rw [Matrix.mul_smul, Matrix.mul_sum]
  simp [Matrix.mul_smul, driftGamma_horizontal hU]

/-- `𝒜 m_* = b_*`. -/
theorem driftMean_diagonal {n d : ℕ} {U : Frame n d} (hU : IsParseval U) (ρ : ℝ)
    (i : Fin n) :
    (driftMean U ρ * U.transpose) i i = Smooth.normalResidualDiagonal U ρ i := by
  unfold driftMean Smooth.normalResidualDiagonal
  rw [Matrix.smul_mul, Matrix.sum_mul, Matrix.smul_apply, Matrix.sum_apply, smul_eq_mul]
  congr 1
  apply Finset.sum_congr rfl
  intro j hj
  have hμ : 0 < normalizedFisherEigenvalue U j := (Finset.mem_filter.mp hj).2
  rw [Matrix.smul_mul, Matrix.smul_apply, smul_eq_mul, normalizedNormalFrame_eq,
    horizontalQuadraticDiagonal_smul, horizontalQuadraticDiagonal_ambientNormal hU,
    inv_pow, Real.sq_sqrt hμ.le]
  field_simp

/-- `‖m_*‖_F ≤ a / √(p ρ)` when all leverages are at least `p`. -/
theorem driftMean_norm_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    {p ρ : ℝ} (hp : 0 < p) (hrows : ∀ i, p ≤ rowNormSq U i) (hρ : 0 < ρ) :
    ‖normalFrobVector (driftMean U ρ)‖ ≤
      ((d : ℝ) / n) / (Real.sqrt p * Real.sqrt ρ) := by
  have hpi : ∀ i, 0 < rowNormSq U i := fun i => hp.trans_le (hrows i)
  have hsp : 0 < Real.sqrt p := Real.sqrt_pos.mpr hp
  have hsρ : 0 < Real.sqrt ρ := Real.sqrt_pos.mpr hρ
  unfold driftMean
  rw [normalFrobVector_smul', norm_smul, normalFrobVector_sum']
  have hterm : ∀ j ∈ highNormalizedModes U 0,
      ‖normalFrobVector ((Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) /
        normalizedFisherEigenvalue U j) • driftGamma U (normalizedNormalPotential U j))‖ ≤
      (2 * (Real.sqrt p)⁻¹) * (Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) /
        Real.sqrt (normalizedFisherEigenvalue U j)) := by
    intro j hj
    have hμ : 0 < normalizedFisherEigenvalue U j := (Finset.mem_filter.mp hj).2
    have hw := Smooth.residualWeight_nonneg hρ.le (normalizedFisherEigenvalue_nonneg U j)
      (normalizedFisherEigenvalue_le_one hU hpi j)
    rw [normalFrobVector_smul', norm_smul, Real.norm_eq_abs,
      abs_of_nonneg (div_nonneg hw hμ.le)]
    have hg := driftGamma_norm_le hU (normalizedNormalPotential U j)
      (inv_nonneg.mpr (Real.sqrt_nonneg p))
      (fun i => normalizedNormalPotential_abs_le U j i hp (hrows i))
    rw [normalizedNormalPotential_image_norm] at hg
    have hsμ : 0 < Real.sqrt (normalizedFisherEigenvalue U j) := Real.sqrt_pos.mpr hμ
    calc _ ≤ (Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) /
          normalizedFisherEigenvalue U j) *
          (2 * (Real.sqrt p)⁻¹ * Real.sqrt (normalizedFisherEigenvalue U j)) :=
          mul_le_mul_of_nonneg_left hg (div_nonneg hw hμ.le)
      _ = _ := by
          have key : Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) /
              normalizedFisherEigenvalue U j * Real.sqrt (normalizedFisherEigenvalue U j) =
              Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) /
              Real.sqrt (normalizedFisherEigenvalue U j) := by
            rw [div_mul_eq_mul_div, div_eq_div_iff hμ.ne' hsμ.ne', mul_assoc,
              Real.mul_self_sqrt hμ.le]
          rw [← key]; ring
  calc _ ≤ ‖(1 / (n : ℝ))‖ * ∑ j ∈ highNormalizedModes U 0,
        (2 * (Real.sqrt p)⁻¹) * (Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) /
          Real.sqrt (normalizedFisherEigenvalue U j)) := by
        gcongr
        exact (norm_sum_le _ _).trans (Finset.sum_le_sum hterm)
    _ = (1 / (n : ℝ)) * (2 * (Real.sqrt p)⁻¹) * ∑ j ∈ highNormalizedModes U 0,
        (Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) /
          Real.sqrt (normalizedFisherEigenvalue U j)) := by
        rw [← Finset.mul_sum, Real.norm_eq_abs, abs_of_nonneg (by positivity)]; ring
    _ ≤ (1 / (n : ℝ)) * (2 * (Real.sqrt p)⁻¹) * ((d : ℝ) / (2 * Real.sqrt ρ)) := by
        gcongr
        exact Smooth.residual_inverse_sqrt_sum_le hU hpi hρ
    _ = _ := by field_simp

theorem driftMean_norm_sq_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (hn : 0 < n) (hd : 0 < d)
    (hrows : ∀ i, ((d : ℝ) / n) / 2 ≤ rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) :
    ‖normalFrobVector (driftMean U ρ)‖ ^ 2 ≤ 2 * ((d : ℝ) / n) / ρ := by
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  have ha : 0 < (d : ℝ) / n := by positivity
  have hp : 0 < ((d : ℝ) / n) / 2 := by positivity
  have h := driftMean_norm_le hU hp hrows hρ
  have h2 := pow_le_pow_left₀ (norm_nonneg _) h 2
  refine h2.trans (le_of_eq ?_)
  rw [div_pow, mul_pow, Real.sq_sqrt hp.le, Real.sq_sqrt hρ.le]
  field_simp

/-! ### Polarisation of the quadratic diagonal -/

/-- `q_i(H,K)`. -/
def horizontalQuadraticCross {n d : ℕ} (U H K : Frame n d) (i : Fin n) : ℝ :=
  (∑ k, H i k * K i k) - ∑ k, (U * H.transpose) i k * (U * K.transpose) i k

theorem horizontalQuadraticDiagonal_add {n d : ℕ} (U H K : Frame n d) (i : Fin n) :
    horizontalQuadraticDiagonal U (H + K) i = horizontalQuadraticDiagonal U H i +
      2 * horizontalQuadraticCross U H K i + horizontalQuadraticDiagonal U K i := by
  simp only [horizontalQuadraticDiagonal, horizontalQuadraticCross, rowNormSq,
    Matrix.transpose_add, Matrix.mul_add, Matrix.add_apply, add_sq, Finset.sum_add_distrib,
    mul_sub, Finset.mul_sum]
  ring_nf

theorem horizontalQuadraticCross_smul {n d : ℕ} (U H K : Frame n d) (c : ℝ) (i : Fin n) :
    horizontalQuadraticCross U H (c • K) i = c * horizontalQuadraticCross U H K i := by
  simp only [horizontalQuadraticCross, Matrix.transpose_smul, Matrix.mul_smul,
    Matrix.smul_apply, smul_eq_mul, mul_sub, Finset.mul_sum]
  congr 1 <;> apply Finset.sum_congr rfl <;> intro k _ <;> ring

theorem abs_mul_le_weighted (a b s : ℝ) (hs : 0 < s) :
    |a * b| ≤ (s * a ^ 2 + b ^ 2 / s) / 2 := by
  rw [show (s * a ^ 2 + b ^ 2 / s) / 2 = (s ^ 2 * a ^ 2 + b ^ 2) / (2 * s) by
    field_simp]
  rw [le_div_iff₀ (by positivity), abs_mul]
  nlinarith [sq_nonneg (s * |a| - |b|), sq_abs a, sq_abs b, abs_nonneg a, abs_nonneg b]

/-- Weighted Cauchy–Schwarz for the polarisation. -/
theorem horizontalQuadraticCross_abs_le {n d : ℕ} (U H K : Frame n d) (i : Fin n)
    {s : ℝ} (hs : 0 < s) :
    |horizontalQuadraticCross U H K i| ≤
      (s * (rowNormSq H i + rowNormSq (U * H.transpose) i) +
        (rowNormSq K i + rowNormSq (U * K.transpose) i) / s) / 2 := by
  unfold horizontalQuadraticCross
  have h1 : |∑ k, H i k * K i k| ≤ ∑ k, (s * H i k ^ 2 + K i k ^ 2 / s) / 2 :=
    (Finset.abs_sum_le_sum_abs _ _).trans
      (Finset.sum_le_sum fun k _ => abs_mul_le_weighted _ _ s hs)
  have h2 : |∑ k, (U * H.transpose) i k * (U * K.transpose) i k| ≤
      ∑ k, (s * (U * H.transpose) i k ^ 2 + (U * K.transpose) i k ^ 2 / s) / 2 :=
    (Finset.abs_sum_le_sum_abs _ _).trans
      (Finset.sum_le_sum fun k _ => abs_mul_le_weighted _ _ s hs)
  have he : (s * (rowNormSq H i + rowNormSq (U * H.transpose) i) +
        (rowNormSq K i + rowNormSq (U * K.transpose) i) / s) / 2 =
      (∑ k, (s * H i k ^ 2 + K i k ^ 2 / s) / 2) +
        ∑ k, (s * (U * H.transpose) i k ^ 2 + (U * K.transpose) i k ^ 2 / s) / 2 := by
    simp only [rowNormSq, ← Finset.sum_div, Finset.sum_add_distrib, ← Finset.mul_sum]
    ring
  rw [he]
  exact (abs_sub _ _).trans (add_le_add h1 h2)

theorem horizontalQuadraticDiagonal_abs_le {n d : ℕ} (U K : Frame n d) (i : Fin n) :
    |horizontalQuadraticDiagonal U K i| ≤ rowNormSq K i + rowNormSq (U * K.transpose) i := by
  unfold horizontalQuadraticDiagonal
  have h1 := rowNormSq_nonneg K i
  have h2 := rowNormSq_nonneg (U * K.transpose) i
  rw [abs_le]; constructor <;> linarith

/-! ### Row estimates -/

/-- Rows of `Y_H = H Uᵀ + U Hᵀ` for horizontal `H`. -/
theorem rowNormSq_tangent_horizontal {n d : ℕ} {U H : Frame n d} (hU : IsParseval U)
    (hUH : U.transpose * H = 0) (i : Fin n) :
    rowNormSq (H * U.transpose + U * H.transpose) i =
      rowNormSq H i + rowNormSq (U * H.transpose) i := by
  rw [rowNormSq_eq_mul_transpose, rowNormSq_eq_mul_transpose,
    rowNormSq_eq_mul_transpose (U * H.transpose)]
  have hHU : H.transpose * U = 0 := by
    rw [← Matrix.transpose_transpose (H.transpose * U), Matrix.transpose_mul,
      Matrix.transpose_transpose, hUH, Matrix.transpose_zero]
  have hUtU : U.transpose * U = 1 := hU
  have he : (H * U.transpose + U * H.transpose) * (H * U.transpose + U * H.transpose).transpose =
      H * H.transpose + (U * H.transpose) * (U * H.transpose).transpose := by
    simp only [Matrix.transpose_add, Matrix.transpose_mul, Matrix.transpose_transpose,
      Matrix.add_mul, Matrix.mul_add]
    have e1 : H * U.transpose * (U * H.transpose) = H * H.transpose := by
      rw [Matrix.mul_assoc, ← Matrix.mul_assoc U.transpose, hUtU, Matrix.one_mul]
    have e2 : H * U.transpose * (H * U.transpose) = 0 := by
      rw [Matrix.mul_assoc, ← Matrix.mul_assoc U.transpose, hUH, Matrix.zero_mul,
        Matrix.mul_zero]
    have e3 : U * H.transpose * (U * H.transpose) = 0 := by
      rw [Matrix.mul_assoc, ← Matrix.mul_assoc H.transpose, hHU, Matrix.zero_mul,
        Matrix.mul_zero]
    rw [e1, e2, e3]
    abel
  rw [he, Matrix.add_apply]

theorem rowNormSq_add_le {n d : ℕ} (A B : Frame n d) (i : Fin n) :
    rowNormSq (A + B) i ≤ 2 * rowNormSq A i + 2 * rowNormSq B i := by
  simp only [rowNormSq, Matrix.add_apply, Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro k _
  nlinarith [sq_nonneg (A i k - B i k)]

theorem rowNormSq_smul {n d : ℕ} (c : ℝ) (A : Frame n d) (i : Fin n) :
    rowNormSq (c • A) i = c ^ 2 * rowNormSq A i := by
  simp only [rowNormSq, Matrix.smul_apply, smul_eq_mul, mul_pow, Finset.mul_sum]

theorem rowNormSq_mul_transpose_le {n d : ℕ} (U K : Frame n d) (i : Fin n) :
    rowNormSq (U * K.transpose) i ≤ rowNormSq U i * ‖normalFrobVector K‖ ^ 2 := by
  rw [normalFrobVector_norm_sq_eq_sum, Finset.mul_sum]
  unfold rowNormSq
  apply Finset.sum_le_sum
  intro k _
  simp only [Matrix.mul_apply, Matrix.transpose_apply]
  exact Finset.sum_mul_sq_le_sq_mul_sq _ _ _

end

end Paulsen.Linear
