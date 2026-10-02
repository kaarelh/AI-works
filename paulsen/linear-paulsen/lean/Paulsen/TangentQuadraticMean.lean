import Paulsen.TangentQuadraticVariance
import Paulsen.TangentRemainderBound
import Mathlib.LinearAlgebra.Trace

/-!
# Mean of the conditioned quadratic error

The quadratic mean is linear in covariance. Removing an orthogonal projection
changes its quadratic forms by at most the removed covariance trace.
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory

namespace Paulsen
noncomputable section

/-- The quadratic error, tested against an ambient vector. -/
theorem tangentQuadratic_quadratic {n d : ℕ} (X Z : Frame n d)
    (a : ℝ) (x : Fin d → ℝ) :
    matrixQuadratic (tangentQuadratic X Z a) x =
      ∑ i, ((∑ j, Z i j * x j) ^ 2 - tangentRatio a Z i * (∑ j, X i j * x j) ^ 2) := by
  let C (i : Fin n) : Matrix (Fin d) (Fin d) ℝ :=
    Matrix.of (fun j k => Z i j * Z i k) -
      tangentRatio a Z i • Matrix.of (fun j k => X i j * X i k)
  have hQ : tangentQuadratic X Z a = ∑ i, C i := by
    ext j k
    simp only [tangentQuadratic, Matrix.of_apply, Matrix.sum_apply, C,
      Matrix.sub_apply, Matrix.smul_apply, smul_eq_mul]
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [hQ, matrixQuadratic_sum]
  simp only [C, matrixQuadratic_sub, matrixQuadratic_smul, matrixQuadratic_row_product]
  simp only [pow_two]

/-- Both positive terms of the quadratic error are bounded by the total noise
energy, so their difference has the same bound, with constant one. -/
theorem tangentQuadratic_quadratic_abs_le {n d : ℕ} (X Z : Frame n d)
    {a : ℝ} (ha : 0 < a) (hrows : ∀ i, rowNormSq X i = a) (x : Fin d → ℝ) :
    |matrixQuadratic (tangentQuadratic X Z a) x| ≤
      (∑ i, rowNormSq Z i) * vectorNormSq x := by
  rw [tangentQuadratic_quadratic]
  have hrow (i : Fin n) :
      |(∑ j, Z i j * x j) ^ 2 - tangentRatio a Z i * (∑ j, X i j * x j) ^ 2| ≤
        rowNormSq Z i * vectorNormSq x := by
    have hz := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (Z i) x
    change _ ≤ rowNormSq Z i * vectorNormSq x at hz
    have hx := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (X i) x
    change _ ≤ rowNormSq X i * vectorNormSq x at hx
    rw [hrows] at hx
    have hr := tangentRatio_nonneg a ha Z i
    have hmul := mul_le_mul_of_nonneg_left hx hr
    have hra : tangentRatio a Z i * a = rowNormSq Z i := by
      unfold tangentRatio
      exact div_mul_cancel₀ _ ha.ne'
    rw [← mul_assoc, hra] at hmul
    exact abs_le.mpr ⟨by nlinarith [sq_nonneg (∑ j, Z i j * x j)],
      by nlinarith [mul_nonneg hr (sq_nonneg (∑ j, X i j * x j))]⟩
  exact (Finset.abs_sum_le_sum_abs _ _).trans ((Finset.sum_le_sum fun i _ => hrow i).trans_eq
    (Finset.sum_mul ..).symm)

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Concrete matrix of orthogonal projection onto a Euclidean subspace. -/
def subspaceProjectionMatrix (E : Submodule ℝ (EuclideanSpace ℝ ι)) : Matrix ι ι ℝ :=
  Matrix.toEuclideanLin.symm E.starProjection.toLinearMap

@[simp] theorem subspaceProjectionMatrix_toEuclideanLin
    (E : Submodule ℝ (EuclideanSpace ℝ ι)) :
    Matrix.toEuclideanLin (subspaceProjectionMatrix E) = E.starProjection.toLinearMap :=
  Matrix.toEuclideanLin.apply_symm_apply _

theorem subspaceProjectionMatrix_symmetric (E : Submodule ℝ (EuclideanSpace ℝ ι)) :
    (subspaceProjectionMatrix E).IsSymm := by
  apply Matrix.toEuclideanLin.injective
  rw [show (subspaceProjectionMatrix E).transpose =
    (subspaceProjectionMatrix E).conjTranspose by simp]
  rw [Matrix.toEuclideanLin_conjTranspose_eq_adjoint, subspaceProjectionMatrix_toEuclideanLin]
  have h := LinearMap.adjoint_toContinuousLinearMap E.starProjection.toLinearMap
  have hself : ContinuousLinearMap.adjoint E.starProjection = E.starProjection :=
    isSelfAdjoint_starProjection E
  have heq : (LinearMap.adjoint E.starProjection.toLinearMap).toContinuousLinearMap =
      E.starProjection := h.trans hself
  exact congrArg ContinuousLinearMap.toLinearMap heq

theorem subspaceProjectionMatrix_idempotent (E : Submodule ℝ (EuclideanSpace ℝ ι)) :
    subspaceProjectionMatrix E * subspaceProjectionMatrix E = subspaceProjectionMatrix E := by
  apply Matrix.toEuclideanLin.injective
  simp only [Matrix.toEuclideanLin, Matrix.toLpLin_mul_same]
  change (Matrix.toEuclideanLin (subspaceProjectionMatrix E)).comp
    (Matrix.toEuclideanLin (subspaceProjectionMatrix E)) = _
  rw [subspaceProjectionMatrix_toEuclideanLin]
  exact congrArg ContinuousLinearMap.toLinearMap E.isIdempotentElem_starProjection.eq

theorem subspaceProjectionMatrix_trace (E : Submodule ℝ (EuclideanSpace ℝ ι)) :
    (subspaceProjectionMatrix E).trace = Module.finrank ℝ E := by
  have hproj : LinearMap.IsProj E E.starProjection.toLinearMap :=
    ⟨E.starProjection_apply_mem, fun _ h => Submodule.starProjection_eq_self_iff.mpr h⟩
  have htrace := hproj.trace
  rw [LinearMap.trace_eq_matrix_trace ℝ (EuclideanSpace.basisFun ι ℝ).toBasis] at htrace
  convert htrace using 1
  unfold subspaceProjectionMatrix
  rw [Matrix.toEuclideanLin_eq_toLin_orthonormal]
  rfl

theorem subspaceProjectionMatrix_sq_sum (E : Submodule ℝ (EuclideanSpace ℝ ι)) :
    (∑ p, ∑ q, (subspaceProjectionMatrix E p q) ^ 2) = Module.finrank ℝ E := by
  have hid := subspaceProjectionMatrix_idempotent E
  have hsym := subspaceProjectionMatrix_symmetric E
  calc
    _ = (subspaceProjectionMatrix E * subspaceProjectionMatrix E).trace := by
      simp only [Matrix.trace, Matrix.diag, Matrix.mul_apply]
      apply Finset.sum_congr rfl
      intro p _
      apply Finset.sum_congr rfl
      intro q _
      rw [hsym.apply]
      ring
    _ = _ := by rw [hid, subspaceProjectionMatrix_trace]


/-- The quadratic mean as a linear function of the covariance matrix. -/
def tangentCovarianceMean {n d : ℕ} (X : Frame n d) (a : ℝ)
    (S : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) : Matrix (Fin d) (Fin d) ℝ :=
  Matrix.of fun j k => (tangentQuadraticCoefficient X a j k * S).trace

variable {κ : Type*} [Fintype κ] [DecidableEq κ]

omit [DecidableEq κ] in
theorem tangentQuadraticMean_eq_covarianceMean {n d : ℕ} (X : Frame n d) (a : ℝ)
    (C : Matrix (Fin n × Fin d) κ ℝ) :
    tangentQuadraticMean X a C = tangentCovarianceMean X a (C * C.transpose) := by
  ext j k
  change (C.transpose * tangentQuadraticCoefficient X a j k * C).trace =
    (tangentQuadraticCoefficient X a j k * (C * C.transpose)).trace
  rw [Matrix.trace_mul_cycle, Matrix.trace_mul_comm]

theorem tangentCovarianceMean_sub {n d : ℕ} (X : Frame n d) (a : ℝ)
    (S T : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) :
    tangentCovarianceMean X a (S - T) = tangentCovarianceMean X a S -
      tangentCovarianceMean X a T := by
  ext j k
  simp [tangentCovarianceMean, Matrix.mul_sub, Matrix.trace_sub]

theorem tangentCovarianceMean_smul {n d : ℕ} (X : Frame n d) (a c : ℝ)
    (S : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) :
    tangentCovarianceMean X a (c • S) = c • tangentCovarianceMean X a S := by
  ext j k
  simp [tangentCovarianceMean, Matrix.trace_smul]

omit [DecidableEq κ] in
/-- A covariance-factor mean is a sum of deterministic errors, one for each
column of the factor. -/
theorem tangentQuadraticMean_eq_sum_columns {n d : ℕ} (X : Frame n d) (a : ℝ)
    (C : Matrix (Fin n × Fin d) κ ℝ) :
    tangentQuadraticMean X a C =
      ∑ s, tangentQuadratic X (Matrix.of fun i j => C (i,j) s) a := by
  ext j k
  change (C.transpose * tangentQuadraticCoefficient X a j k * C).trace = _
  simp only [Matrix.trace, Matrix.diag, Matrix.sum_apply]
  apply Finset.sum_congr rfl
  intro s _
  rw [← tangentQuadraticCoefficient_identity]
  simp only [matrixQuadratic, Matrix.mul_apply, Matrix.transpose_apply, Matrix.of_apply,
    Finset.sum_mul]
  exact Finset.sum_comm

theorem tangentCovarianceMean_projection {n d : ℕ} (X : Frame n d) (a : ℝ)
    (E : Submodule ℝ (FrameVector n d)) :
    tangentCovarianceMean X a (subspaceProjectionMatrix E) =
      tangentQuadraticMean X a (subspaceProjectionMatrix E) := by
  rw [tangentQuadraticMean_eq_covarianceMean,
    (subspaceProjectionMatrix_symmetric E).eq, subspaceProjectionMatrix_idempotent]

omit [DecidableEq κ] in
theorem matrixQuadratic_fintype_sum {d : ℕ} (A : κ → Matrix (Fin d) (Fin d) ℝ)
    (x : Fin d → ℝ) :
    matrixQuadratic (∑ i, A i) x = ∑ i, matrixQuadratic (A i) x := by
  simp only [matrixQuadratic, Matrix.sum_apply, Finset.mul_sum, Finset.sum_mul]
  calc
    _ = ∑ j : Fin d, ∑ i : κ, ∑ k : Fin d, x j * A i j k * x k :=
      Finset.sum_congr rfl fun j _ => Finset.sum_comm
    _ = _ := Finset.sum_comm

/-- A rank-r covariance projection changes every ambient quadratic form by
at most r times the squared test-vector norm. -/
theorem tangentCovarianceMean_projection_abs_le {n d : ℕ} (X : Frame n d)
    {a : ℝ} (ha : 0 < a) (hrows : ∀ i, rowNormSq X i = a)
    (E : Submodule ℝ (FrameVector n d)) (x : Fin d → ℝ) :
    |matrixQuadratic (tangentCovarianceMean X a (subspaceProjectionMatrix E)) x| ≤
      (Module.finrank ℝ E : ℝ) * vectorNormSq x := by
  rw [tangentCovarianceMean_projection, tangentQuadraticMean_eq_sum_columns, matrixQuadratic_fintype_sum]
  have h := (Finset.abs_sum_le_sum_abs _ (Finset.univ : Finset (Fin n × Fin d))).trans
    (Finset.sum_le_sum fun s _ =>
      tangentQuadratic_quadratic_abs_le X (Matrix.of fun i j => subspaceProjectionMatrix E (i,j) s)
        ha hrows x)
  calc
    _ ≤ ∑ s, (∑ i, rowNormSq (Matrix.of fun i j => subspaceProjectionMatrix E (i,j) s) i) *
        vectorNormSq x := h
    _ = (Module.finrank ℝ E : ℝ) * vectorNormSq x := by
      rw [← Finset.sum_mul]
      congr 1
      simp only [rowNormSq, Matrix.of_apply]
      calc
        _ = ∑ s, ∑ p : Fin n × Fin d, subspaceProjectionMatrix E p s ^ 2 :=
          Finset.sum_congr rfl fun s _ => (Fintype.sum_prod_type _).symm
        _ = ∑ p, ∑ s, subspaceProjectionMatrix E p s ^ 2 := Finset.sum_comm
        _ = _ := subspaceProjectionMatrix_sq_sum E


/-- The independent row-tangent Gaussian, before the global constraint. -/
def rowTangentNoiseFactor {n d : ℕ} (X : Frame n d) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  (1 / Real.sqrt (n : ℝ)) • subspaceProjectionMatrix (rowTangentSpace X)

theorem tangentQuadraticMean_smul_projection {n d : ℕ} (X : Frame n d)
    (a c : ℝ) (E : Submodule ℝ (FrameVector n d)) :
    tangentQuadraticMean X a (c • subspaceProjectionMatrix E) =
      c ^ 2 • tangentCovarianceMean X a (subspaceProjectionMatrix E) := by
  rw [tangentQuadraticMean_eq_covarianceMean]
  have hc : (c • subspaceProjectionMatrix E) * (c • subspaceProjectionMatrix E).transpose =
      c ^ 2 • subspaceProjectionMatrix E := by
    rw [Matrix.transpose_smul, (subspaceProjectionMatrix_symmetric E).eq,
      Matrix.smul_mul, Matrix.mul_smul, smul_smul,
      subspaceProjectionMatrix_idempotent, pow_two]
  rw [hc, tangentCovarianceMean_smul]

theorem tangentQuadraticMean_tangentNoiseFactor {n d : ℕ} (X : Frame n d) (a : ℝ) :
    tangentQuadraticMean X a (tangentNoiseFactor X) =
      (1 / (n : ℝ)) • tangentCovarianceMean X a
        (subspaceProjectionMatrix (globalTangentSpace X)) := by
  change tangentQuadraticMean X a
    ((1 / Real.sqrt (n : ℝ)) • subspaceProjectionMatrix (globalTangentSpace X)) = _
  rw [tangentQuadraticMean_smul_projection, div_pow, one_pow,
    Real.sq_sqrt (Nat.cast_nonneg n)]

theorem tangentQuadraticMean_rowTangentNoiseFactor {n d : ℕ} (X : Frame n d) (a : ℝ) :
    tangentQuadraticMean X a (rowTangentNoiseFactor X) =
      (1 / (n : ℝ)) • tangentCovarianceMean X a
        (subspaceProjectionMatrix (rowTangentSpace X)) := by
  rw [rowTangentNoiseFactor, tangentQuadraticMean_smul_projection, div_pow, one_pow,
    Real.sq_sqrt (Nat.cast_nonneg n)]

theorem removedTangentProjectionMatrix_eq_sub {n d : ℕ} (X : Frame n d) :
    subspaceProjectionMatrix (removedTangentSpace X) =
      subspaceProjectionMatrix (rowTangentSpace X) -
        subspaceProjectionMatrix (globalTangentSpace X) := by
  apply Matrix.toEuclideanLin.injective
  rw [map_sub]
  simp only [subspaceProjectionMatrix_toEuclideanLin]
  exact congrArg ContinuousLinearMap.toLinearMap (removedTangentProjection_eq_sub X)

/-- Conditioning changes the ambient quadratic mean by at most d²/n in
operator norm, with no loss depending on the ambient number of rows. -/
theorem tangentQuadraticMean_conditioning_bias_le {n d : ℕ} (X : Frame n d)
    {a : ℝ} (ha : 0 < a) (hrows : ∀ i, rowNormSq X i = a) (x : Fin d → ℝ) :
    |matrixQuadratic (tangentQuadraticMean X a (tangentNoiseFactor X) -
      tangentQuadraticMean X a (rowTangentNoiseFactor X)) x| ≤
        ((d : ℝ) ^ 2 / n) * vectorNormSq x := by
  have heq : tangentQuadraticMean X a (rowTangentNoiseFactor X) -
      tangentQuadraticMean X a (tangentNoiseFactor X) =
      (1 / (n : ℝ)) • tangentCovarianceMean X a
        (subspaceProjectionMatrix (removedTangentSpace X)) := by
    rw [tangentQuadraticMean_tangentNoiseFactor, tangentQuadraticMean_rowTangentNoiseFactor,
      ← smul_sub, removedTangentProjectionMatrix_eq_sub, tangentCovarianceMean_sub]
  rw [matrixQuadratic_sub, abs_sub_comm, ← matrixQuadratic_sub, heq,
    matrixQuadratic_smul, abs_mul, abs_of_nonneg (by positivity : 0 ≤ 1 / (n : ℝ))]
  calc
    _ ≤ (1 / (n : ℝ)) * ((Module.finrank ℝ (removedTangentSpace X) : ℝ) * vectorNormSq x) :=
      mul_le_mul_of_nonneg_left (tangentCovarianceMean_projection_abs_le X ha hrows _ x)
        (by positivity)
    _ ≤ (1 / (n : ℝ)) * ((d : ℝ) ^ 2 * vectorNormSq x) := by
      apply mul_le_mul_of_nonneg_left _ (by positivity)
      apply mul_le_mul_of_nonneg_right _ (vectorNormSq_nonneg x)
      exact_mod_cast removedTangentSpace_finrank_le X
    _ = _ := by ring


/-- Orthogonal projection onto the row tangent space acts independently on rows. -/
theorem rowTangentProjection_apply {n d : ℕ} (X : Frame n d) {a : ℝ}
    (ha : 0 < a) (hrows : ∀ i, rowNormSq X i = a) (z : FrameVector n d) :
    (rowTangentSpace X).starProjection z = WithLp.toLp 2 (fun p : Fin n × Fin d =>
      z p - (∑ j, X p.1 j * z (p.1,j)) / a * X p.1 p.2) := by
  apply Submodule.eq_starProjection_of_mem_of_inner_eq_zero
  · rw [mem_rowTangentSpace]
    intro i
    change (∑ j, X i j * (z (i,j) - (∑ k, X i k * z (i,k)) / a * X i j)) = 0
    have hi : (∑ j, X i j * X i j) = a := by simpa [rowNormSq, pow_two] using hrows i
    simp only [mul_sub, Finset.sum_sub_distrib]
    have heq : (∑ j, X i j * ((∑ k, X i k * z (i,k)) / a * X i j)) =
        ((∑ k, X i k * z (i,k)) / a) * ∑ j, X i j * X i j := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro j _
      ring
    rw [heq, hi, div_mul_cancel₀ _ ha.ne', sub_self]
  · intro y hy
    have hy' := (mem_rowTangentSpace X y).mp hy
    simp only [PiLp.inner_apply, Real.inner_apply, PiLp.sub_apply,
      sub_sub_cancel, Fintype.sum_prod_type]
    apply Finset.sum_eq_zero
    intro i _
    change (∑ j, ((∑ k, X i k * z (i,k)) / a * X i j) * y (i,j)) = 0
    have heq : (∑ j, ((∑ k, X i k * z (i,k)) / a * X i j) * y (i,j)) =
        ((∑ k, X i k * z (i,k)) / a) * ∑ j, X i j * y (i,j) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro j _
      ring
    rw [heq]
    change _ * rowDot X (frameOfVector y) i = 0
    rw [hy', mul_zero]


theorem rowTangentProjectionMatrix_apply {n d : ℕ} (X : Frame n d) {a : ℝ}
    (ha : 0 < a) (hrows : ∀ i, rowNormSq X i = a) (i l : Fin n) (j k : Fin d) :
    subspaceProjectionMatrix (rowTangentSpace X) (i,j) (l,k) =
      if i = l then (if j = k then 1 else 0) - X i j * X i k / a else 0 := by
  let z : FrameVector n d := WithLp.toLp 2 (fun p => if p = (l,k) then 1 else 0)
  have h := congrArg (fun v : FrameVector n d => v (i,j))
    (rowTangentProjection_apply X ha hrows z)
  have hentry : ((rowTangentSpace X).starProjection z) (i,j) =
      subspaceProjectionMatrix (rowTangentSpace X) (i,j) (l,k) := by
    calc
      _ = (Matrix.toEuclideanLin (subspaceProjectionMatrix (rowTangentSpace X)) z) (i,j) :=
        congrArg (fun f : FrameVector n d →ₗ[ℝ] FrameVector n d => f z (i,j))
          (subspaceProjectionMatrix_toEuclideanLin (rowTangentSpace X)).symm
      _ = _ := by
        change (∑ p : Fin n × Fin d, subspaceProjectionMatrix (rowTangentSpace X) (i,j) p *
          (if p = (l,k) then 1 else 0)) = _
        simp only [mul_ite, mul_one, mul_zero, Finset.sum_ite_eq', Finset.mem_univ, if_true]
  rw [hentry] at h
  change subspaceProjectionMatrix (rowTangentSpace X) (i,j) (l,k) =
    z (i,j) - (∑ s, X i s * z (i,s)) / a * X i j at h
  rw [h]
  dsimp only [z]
  by_cases hil : i = l
  · subst l
    simp only [Prod.mk.injEq, true_and, if_true, mul_ite, mul_one, mul_zero,
      Finset.sum_ite_eq', Finset.mem_univ]
    ring
  · simp [Prod.mk.injEq, hil]


theorem coordinatePairCoefficient_trace_mul {d : ℕ} (j k : Fin d)
    (M : Matrix (Fin d) (Fin d) ℝ) :
    (coordinatePairCoefficient j k * M).trace = (M j k + M k j) / 2 := by
  simp only [Matrix.trace, Matrix.diag, Matrix.mul_apply, coordinatePairCoefficient,
    Matrix.of_apply, add_div, add_mul, Finset.sum_add_distrib]
  simp only [mul_ite, ite_div, ite_mul, zero_mul, mul_zero, mul_one, zero_div]
  simp
  ring

theorem tangentRowCoefficient_trace_mul {n d : ℕ} (X : Frame n d) (a : ℝ)
    (i : Fin n) (j k : Fin d) (M : Matrix (Fin d) (Fin d) ℝ) :
    (tangentRowCoefficient X a i j k * M).trace =
      (M j k + M k j) / 2 - (X i j * X i k / a) * M.trace := by
  rw [tangentRowCoefficient, Matrix.sub_mul, Matrix.trace_sub,
    coordinatePairCoefficient_trace_mul, Matrix.smul_mul, Matrix.one_mul, Matrix.trace_smul]
  rfl

theorem tangentCovarianceMean_apply {n d : ℕ} (X : Frame n d) (a : ℝ)
    (S : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) (j k : Fin d) :
    tangentCovarianceMean X a S j k =
      ∑ i, ((S (i,j) (i,k) + S (i,k) (i,j)) / 2 -
        (X i j * X i k / a) * ∑ u, S (i,u) (i,u)) := by
  change (tangentQuadraticCoefficient X a j k * S).trace = _
  simp only [Matrix.trace, Matrix.diag, Matrix.mul_apply, Fintype.sum_prod_type]
  apply Finset.sum_congr rfl
  intro i _
  have hinner (u : Fin d) :
      (∑ l, ∑ v, tangentQuadraticCoefficient X a j k (i,u) (l,v) * S (l,v) (i,u)) =
        ∑ v, tangentRowCoefficient X a i j k u v * S (i,v) (i,u) := by
    change (∑ l : Fin n, ∑ v : Fin d,
      (if i = l then tangentRowCoefficient X a i j k u v else 0) * S (l,v) (i,u)) = _
    rw [Finset.sum_eq_single i]
    · simp only [if_true]
    · intro l _ hli
      simp only [if_neg (Ne.symm hli), zero_mul, Finset.sum_const_zero]
    · simp
  simp_rw [hinner]
  exact tangentRowCoefficient_trace_mul X a i j k (Matrix.of fun u v => S (i,u) (i,v))


theorem rowTangentProjectionMatrix_block_trace {n d : ℕ} (X : Frame n d) {a : ℝ}
    (ha : 0 < a) (hrows : ∀ i, rowNormSq X i = a) (i : Fin n) :
    (∑ u, subspaceProjectionMatrix (rowTangentSpace X) (i,u) (i,u)) = (d : ℝ) - 1 := by
  simp_rw [rowTangentProjectionMatrix_apply X ha hrows]
  simp only [if_true, Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul, mul_one, ← Finset.sum_div, ← pow_two]
  change (d : ℝ) - rowNormSq X i / a = _
  rw [hrows, div_self ha.ne']

theorem tangentCovarianceMean_rowProjection {n d : ℕ} (X : Frame n d) {a : ℝ}
    (ha : 0 < a) (hrows : ∀ i, rowNormSq X i = a) :
    tangentCovarianceMean X a (subspaceProjectionMatrix (rowTangentSpace X)) =
      (n : ℝ) • (1 : Matrix (Fin d) (Fin d) ℝ) -
        ((d : ℝ) / a) • (X.transpose * X) := by
  ext j k
  rw [tangentCovarianceMean_apply]
  simp_rw [rowTangentProjectionMatrix_block_trace X ha hrows,
    rowTangentProjectionMatrix_apply X ha hrows]
  simp only [if_true]
  have heach (i : Fin n) :
      (((if j = k then (1 : ℝ) else 0) - X i j * X i k / a +
        ((if k = j then 1 else 0) - X i k * X i j / a)) / 2 -
        (X i j * X i k / a) * ((d : ℝ) - 1)) =
      (if j = k then 1 else 0) - ((d : ℝ) / a) * (X i j * X i k) := by
    have hif : (if k = j then (1 : ℝ) else 0) = (if j = k then 1 else 0) := by
      simp only [eq_comm]
    rw [hif]
    ring
  simp_rw [heach]
  simp only [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul, ← Finset.mul_sum, Matrix.sub_apply, Matrix.smul_apply, smul_eq_mul,
    Matrix.one_apply, Matrix.mul_apply, Matrix.transpose_apply]

/-- The independent tangent noise has exactly mean I-XᵀX. -/
theorem tangentQuadraticMean_rowTangentNoiseFactor_eq {n d : ℕ} (hn : 0 < n)
    (hd : 0 < d) (X : Frame n d) (hrows : ∀ i, rowNormSq X i = (d : ℝ) / n) :
    tangentQuadraticMean X ((d : ℝ) / n) (rowTangentNoiseFactor X) =
      (1 : Matrix (Fin d) (Fin d) ℝ) - X.transpose * X := by
  have ha : 0 < (d : ℝ) / n := by positivity
  rw [tangentQuadraticMean_rowTangentNoiseFactor,
    tangentCovarianceMean_rowProjection X ha hrows, smul_sub, smul_smul, smul_smul]
  have hn' : (n : ℝ) ≠ 0 := by exact_mod_cast hn.ne'
  have hd' : (d : ℝ) ≠ 0 := by exact_mod_cast hd.ne'
  have h1 : 1 / (n : ℝ) * n = 1 := by field_simp
  have h2 : 1 / (n : ℝ) * ((d : ℝ) / ((d : ℝ) / n)) = 1 := by field_simp
  rw [h1, h2, one_smul, one_smul]

/-- The actual globally conditioned Gaussian has mean within d²/n of I-XᵀX. -/
theorem tangentQuadraticMean_conditioned_bias_le {n d : ℕ} (hn : 0 < n)
    (hd : 0 < d) (X : Frame n d) (hrows : ∀ i, rowNormSq X i = (d : ℝ) / n)
    (x : Fin d → ℝ) :
    |matrixQuadratic (tangentQuadraticMean X ((d : ℝ) / n) (tangentNoiseFactor X) -
      ((1 : Matrix (Fin d) (Fin d) ℝ) - X.transpose * X)) x| ≤
        ((d : ℝ) ^ 2 / n) * vectorNormSq x := by
  rw [← tangentQuadraticMean_rowTangentNoiseFactor_eq hn hd X hrows]
  exact tangentQuadraticMean_conditioning_bias_le X (by positivity) hrows x

end
end Paulsen
