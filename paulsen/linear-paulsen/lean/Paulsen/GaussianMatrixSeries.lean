import Paulsen.GaussianLinearImage
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Matrix.Normed
import Mathlib.LinearAlgebra.Matrix.PosDef

/-!
# Deterministic trace estimates for Gaussian matrix series

The key trace estimate follows by pairing transposed entries. This avoids
fractional powers and weighted Young's inequality, and includes exponent zero.
-/

open MeasureTheory ProbabilityTheory Unitary
open scoped BigOperators ProbabilityTheory NNReal

noncomputable section

namespace Paulsen

/-- The two-variable inequality needed after pairing symmetric matrix entries. -/
theorem paired_mixed_powers_le (x y : ℝ) (hx : 0 ≤ x) (hy : 0 ≤ y) (k l : ℕ) :
    x ^ k * y ^ l + y ^ k * x ^ l ≤ x ^ (k + l) + y ^ (k + l) := by
  have hprod : 0 ≤ (x ^ k - y ^ k) * (x ^ l - y ^ l) := by
    rcases le_total x y with hxy | hyx
    · apply mul_nonneg_of_nonpos_of_nonpos
      · exact sub_nonpos.2 (pow_le_pow_left₀ hx hxy k)
      · exact sub_nonpos.2 (pow_le_pow_left₀ hx hxy l)
    · apply mul_nonneg
      · exact sub_nonneg.2 (pow_le_pow_left₀ hy hyx k)
      · exact sub_nonneg.2 (pow_le_pow_left₀ hy hyx l)
  rw [pow_add, pow_add]
  nlinarith

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

omit [DecidableEq ι] in
/-- Symmetric nonnegative weights remove all mixed powers from the double sum. -/
theorem symmetric_weight_mixed_powers_le (w : ι → ι → ℝ)
    (hw : ∀ i j, 0 ≤ w i j) (hsymm : ∀ i j, w i j = w j i)
    (x : ι → ℝ) (hx : ∀ i, 0 ≤ x i) (k l : ℕ) :
    (∑ i, ∑ j, w i j * (x j ^ k * x i ^ l)) ≤
      ∑ i, ∑ j, w i j * x i ^ (k + l) := by
  have hswap : (∑ i, ∑ j, w i j * (x j ^ l * x i ^ k)) =
      ∑ i, ∑ j, w i j * (x j ^ k * x i ^ l) := by
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro i hi
    apply Finset.sum_congr rfl
    intro j hj
    rw [hsymm j i]
    ring
  have hend : (∑ i, ∑ j, w i j * x j ^ (k + l)) =
      ∑ i, ∑ j, w i j * x i ^ (k + l) := by
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro i hi
    apply Finset.sum_congr rfl
    intro j hj
    rw [hsymm j i]
  have hpoint := Finset.sum_le_sum (s := Finset.univ) (fun i _ =>
    Finset.sum_le_sum (s := Finset.univ) (fun j _ =>
      mul_le_mul_of_nonneg_left (paired_mixed_powers_le (x j) (x i) (hx j) (hx i) k l)
        (hw i j)))
  simp only [mul_add, Finset.sum_add_distrib] at hpoint
  have hcross : (∑ i, ∑ j, w i j * (x i ^ k * x j ^ l)) =
      ∑ i, ∑ j, w i j * (x j ^ l * x i ^ k) := by
    apply Finset.sum_congr rfl
    intro i hi
    apply Finset.sum_congr rfl
    intro j hj
    ring
  rw [hcross, hswap, hend] at hpoint
  linarith

/-- Expansion of the trace when the powers are diagonal. -/
theorem trace_mul_diagonal_mul_mul_diagonal (A : Matrix ι ι ℝ)
    (hA : A.IsHermitian) (x y : ι → ℝ) :
    (A * Matrix.diagonal x * A * Matrix.diagonal y).trace =
      ∑ i, ∑ j, (A i j) ^ 2 * (x j * y i) := by
  simp only [Matrix.trace, Matrix.diag_apply]
  apply Finset.sum_congr rfl
  intro i hi
  rw [Matrix.mul_diagonal, Matrix.mul_apply, Finset.sum_mul]
  simp only [Matrix.mul_diagonal]
  apply Finset.sum_congr rfl
  intro j hj
  rw [(Matrix.isHermitian_iff_isSymm.mp hA).apply j i]
  ring

/-- The deterministic trace bound in diagonal coordinates. -/
theorem abs_trace_diagonal_mixed_powers_le (A : Matrix ι ι ℝ)
    (hA : A.IsHermitian) (x : ι → ℝ) (k l : ℕ) (heven : Even (k + l)) :
    |(A * (Matrix.diagonal x) ^ k * A * (Matrix.diagonal x) ^ l).trace| ≤
      (A ^ 2 * (Matrix.diagonal x) ^ (k + l)).trace := by
  rw [Matrix.diagonal_pow, Matrix.diagonal_pow, trace_mul_diagonal_mul_mul_diagonal A hA]
  have habs : |∑ i, ∑ j, (A i j) ^ 2 * (x j ^ k * x i ^ l)| ≤
      ∑ i, ∑ j, (A i j) ^ 2 * (|x j| ^ k * |x i| ^ l) := by
    calc
      _ ≤ ∑ i, |∑ j, (A i j) ^ 2 * (x j ^ k * x i ^ l)| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ i, ∑ j, |(A i j) ^ 2 * (x j ^ k * x i ^ l)| := by
        apply Finset.sum_le_sum
        intro i hi
        exact Finset.abs_sum_le_sum_abs _ _
      _ = _ := by simp only [abs_mul, abs_pow, sq_abs]
  have hs := symmetric_weight_mixed_powers_le (fun i j => (A i j) ^ 2)
    (fun i j => sq_nonneg _) (fun i j => congrArg (fun z : ℝ => z ^ 2)
      ((Matrix.isHermitian_iff_isSymm.mp hA).apply i j).symm)
    (fun i => |x i|) (fun i => abs_nonneg _) k l
  apply habs.trans
  calc
    _ ≤ ∑ i, ∑ j, (A i j) ^ 2 * |x i| ^ (k + l) := hs
    _ = (A ^ 2 * (Matrix.diagonal x) ^ (k + l)).trace := by
      rw [pow_two, Matrix.diagonal_pow]
      simp only [heven.pow_abs, Matrix.trace, Matrix.diag_apply]
      apply Finset.sum_congr rfl
      intro i hi
      rw [Matrix.mul_diagonal, Matrix.mul_apply, Finset.sum_mul]
      simp only [Pi.pow_apply]
      apply Finset.sum_congr rfl
      intro j hj
      rw [(Matrix.isHermitian_iff_isSymm.mp hA).apply j i]
      ring

/-- Trace is invariant under a unitary star-algebra conjugation. -/
theorem trace_conjStarAlgAut (U : Matrix.unitaryGroup ι ℝ) (A : Matrix ι ι ℝ) :
    (conjStarAlgAut ℝ (Matrix ι ι ℝ) U A).trace = A.trace := by
  rw [conjStarAlgAut_apply, Matrix.trace_mul_cycle, Unitary.coe_star_mul_self, Matrix.one_mul]

/-- The deterministic noncommutative trace inequality for all real symmetric
matrices. The mixed exponents may be zero, and only their sum must be even. -/
theorem abs_trace_mixed_powers_le (A X : Matrix ι ι ℝ)
    (hA : A.IsHermitian) (hX : X.IsHermitian)
    (k l : ℕ) (heven : Even (k + l)) :
    |(A * X ^ k * A * X ^ l).trace| ≤ (A ^ 2 * X ^ (k + l)).trace := by
  let e := conjStarAlgAut ℝ (Matrix ι ι ℝ) hX.eigenvectorUnitary
  let B := e.symm A
  have hB : B.IsHermitian :=
    Matrix.isHermitian_iff_isSelfAdjoint.mpr
      ((Matrix.isHermitian_iff_isSelfAdjoint.mp hA).map e.symm)
  have hspec : X = e (Matrix.diagonal hX.eigenvalues) := by
    simpa only [Function.comp_def, RCLike.ofReal_real_eq_id, id_eq] using hX.spectral_theorem
  have hAeq : A = e B := (e.apply_symm_apply A).symm
  have htrace (Y : Matrix ι ι ℝ) : (e Y).trace = Y.trace :=
    trace_conjStarAlgAut hX.eigenvectorUnitary Y
  have hleft : A * X ^ k * A * X ^ l =
      e (B * (Matrix.diagonal hX.eigenvalues) ^ k * B *
        (Matrix.diagonal hX.eigenvalues) ^ l) := by
    rw [map_mul, map_mul, map_mul, map_pow, map_pow, ← hAeq, ← hspec]
  have hright : A ^ 2 * X ^ (k + l) =
      e (B ^ 2 * (Matrix.diagonal hX.eigenvalues) ^ (k + l)) := by
    rw [map_mul, map_pow, map_pow, ← hAeq, ← hspec]
  rw [hleft, hright, htrace, htrace]
  exact abs_trace_diagonal_mixed_powers_le B hB hX.eigenvalues k l heven

/-- A semidefinite upper bound controls trace against an even symmetric power. -/
theorem trace_mul_even_pow_le (S X : Matrix ι ι ℝ) (hX : X.IsHermitian)
    (v : ℝ) (hS : (v • (1 : Matrix ι ι ℝ) - S).PosSemidef) (p : ℕ) :
    (S * X ^ (2 * p)).trace ≤ v * (X ^ (2 * p)).trace := by
  have hnonneg := (hS.conjTranspose_mul_mul_same (X ^ p)).trace_nonneg
  rw [(hX.pow p).eq, Matrix.trace_mul_cycle, ← pow_add, ← two_mul p,
    Matrix.trace_mul_comm, Matrix.sub_mul, Matrix.smul_mul, Matrix.one_mul, Matrix.trace_sub,
    Matrix.trace_smul, smul_eq_mul] at hnonneg
  linarith

/-- Summing the trace inequality over a coefficient family uses only its
matrix variance bound, with no dimension-dependent loss. -/
theorem sum_abs_trace_mixed_powers_le {τ : Type*} [Fintype τ]
    (A : τ → Matrix ι ι ℝ) (hA : ∀ j, (A j).IsHermitian)
    (X : Matrix ι ι ℝ) (hX : X.IsHermitian) (v : ℝ)
    (hvar : (v • (1 : Matrix ι ι ℝ) - ∑ j, A j ^ 2).PosSemidef)
    (k l p : ℕ) (hkl : k + l = 2 * p) :
    (∑ j, |(A j * X ^ k * A j * X ^ l).trace|) ≤
      v * (X ^ (2 * p)).trace := by
  calc
    _ ≤ ∑ j, (A j ^ 2 * X ^ (k + l)).trace := by
      apply Finset.sum_le_sum
      intro j hj
      exact abs_trace_mixed_powers_le (A j) X (hA j) hX k l (hkl ▸ even_two_mul p)
    _ = ((∑ j, A j ^ 2) * X ^ (2 * p)).trace := by
      rw [hkl, Matrix.sum_mul, Matrix.trace_sum]
    _ ≤ _ := trace_mul_even_pow_le _ X hX v hvar p

/-- The Euclidean operator norm bounds a quadratic form on every vector. -/
theorem euclideanQuadratic_le_operator_norm (S : Matrix ι ι ℝ) (x : EuclideanSpace ℝ ι) :
    euclideanQuadratic S x ≤ ‖(Matrix.toEuclideanLin S).toContinuousLinearMap‖ * ‖x‖ ^ 2 := by
  calc
    _ ≤ ‖x‖ * ‖Matrix.toEuclideanLin S x‖ := real_inner_le_norm _ _
    _ ≤ ‖x‖ * (‖(Matrix.toEuclideanLin S).toContinuousLinearMap‖ * ‖x‖) :=
      mul_le_mul_of_nonneg_left ((Matrix.toEuclideanLin S).toContinuousLinearMap.le_opNorm x)
        (norm_nonneg _)
    _ = _ := by ring

/-- The usual operator-norm upper bound implies the semidefinite variance
assumption in the trace moment theorem. -/
theorem posSemidef_scalar_sub_of_operator_norm (S : Matrix ι ι ℝ)
    (hS : S.IsHermitian) (v : ℝ)
    (hv : ‖(Matrix.toEuclideanLin S).toContinuousLinearMap‖ ≤ v) :
    (v • (1 : Matrix ι ι ℝ) - S).PosSemidef := by
  apply Matrix.PosSemidef.of_dotProduct_mulVec_nonneg
    ((Matrix.isHermitian_one.smul (IsSelfAdjoint.all v)).sub hS)
  intro x
  have hquad := (euclideanQuadratic_le_operator_norm S (WithLp.toLp 2 x)).trans
    (mul_le_mul_of_nonneg_right hv (sq_nonneg _))
  have hdot : euclideanQuadratic S (WithLp.toLp 2 x) = dotProduct x (Matrix.mulVec S x) := by
    simp [euclideanQuadratic, EuclideanSpace.inner_eq_star_dotProduct,
      Matrix.toLpLin_apply, dotProduct_comm]
  rw [hdot, EuclideanSpace.real_norm_sq_eq] at hquad
  simpa only [star_trivial, Matrix.sub_mulVec, Matrix.smul_mulVec, Matrix.one_mulVec,
    dotProduct, Pi.sub_apply, Pi.smul_apply, smul_eq_mul, pow_two, mul_sub,
    Finset.sum_sub_distrib, Finset.mul_sum, mul_left_comm] using sub_nonneg.2 hquad

section TraceDerivative

open scoped Matrix.Norms.Operator

/-- The full noncommutative polynomial derivative appearing in Gaussian
integration by parts. No commuting hypothesis is imposed on A and X. -/
theorem hasDerivAt_trace_mul_affine_pow (A X : Matrix ι ι ℝ) (p : ℕ) (s : ℝ) :
    HasDerivAt (fun t : ℝ => (A * (X + t • A) ^ p).trace)
      (∑ k ∈ Finset.range p,
        (A * (X + s • A) ^ (p.pred - k) * A * (X + s • A) ^ k).trace) s := by
  have haff : HasDerivAt (fun t : ℝ => X + t • A) A s := by
    simpa only [one_smul, id_eq] using! ((hasDerivAt_id s).smul_const A).const_add X
  have hp := (hasDerivAt_const s A).mul (haff.fun_pow' p)
  have ht := (Matrix.traceLinearMap ι ℝ ℝ).toContinuousLinearMap.hasFDerivAt.comp_hasDerivAt s hp
  convert! ht using 1
  simp only [zero_mul, zero_add, Matrix.mul_sum, Matrix.mul_assoc, map_sum]
  rfl

end TraceDerivative

end Paulsen
