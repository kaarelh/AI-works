import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.LinearAlgebra.Matrix.Rank
import Mathlib.LinearAlgebra.Trace
import Mathlib.Analysis.Matrix.Hermitian
import Mathlib.Analysis.InnerProductSpace.Projection.FiniteDimensional
import Mathlib.Tactic

/-!
Finite matrix algebra behind cancellation of a low-rank contamination.
The trace/rank identity is checked as well as the squared-error algebra.
The finite kernel projection is constructed using the Euclidean-space
orthogonal projection. The probabilistic posterior application is not
formalized here.
-/
noncomputable section
namespace IndependentResearch
open Matrix
open scoped BigOperators

variable {m n : Type*} [Fintype m] [Fintype n] [DecidableEq n]

/-- The finite Hilbert--Schmidt square in coordinates. -/
def matrixSquare (A : Matrix m n ℝ) : ℝ := Matrix.trace (Aᵀ * A)

theorem matrixSquare_eq_sum (A : Matrix m n ℝ) :
    matrixSquare A = ∑ j, ∑ i, A i j ^ 2 := by
  simp [matrixSquare, Matrix.trace, Matrix.mul_apply, pow_two]

theorem matrixSquare_nonneg (A : Matrix m n ℝ) : 0 ≤ matrixSquare A := by
  rw [matrixSquare_eq_sum]
  exact Finset.sum_nonneg fun j _ => Finset.sum_nonneg fun i _ => sq_nonneg _

theorem matrixSquare_sub (A B : Matrix m n ℝ) :
    matrixSquare (A - B) = matrixSquare A + matrixSquare B -
      2 * Matrix.trace (Aᵀ * B) := by
  have hcross : Matrix.trace (Bᵀ * A) = Matrix.trace (Aᵀ * B) := by
    rw [← Matrix.trace_transpose (Bᵀ * A), Matrix.transpose_mul,
      Matrix.transpose_transpose]
  simp only [matrixSquare, Matrix.transpose_sub, Matrix.sub_mul, Matrix.mul_sub,
    Matrix.trace_sub]
  rw [hcross]
  ring

theorem projection_complement_mul (P : Matrix n n ℝ) (hP : P * P = P) :
    P * (1 - P) = 0 ∧ (1 - P) * P = 0 ∧ (1 - P) * (1 - P) = 1 - P := by
  constructor
  · rw [Matrix.mul_sub, Matrix.mul_one, hP, sub_self]
  constructor
  · rw [Matrix.sub_mul, Matrix.one_mul, hP, sub_self]
  · simp only [Matrix.sub_mul, Matrix.mul_sub, Matrix.one_mul, Matrix.mul_one, hP]
    abel

/-- Right projection splits a matrix's full squared norm exactly. -/
theorem matrixSquare_projection_split (A : Matrix m n ℝ) (P : Matrix n n ℝ)
    (hs : Pᵀ = P) (hi : P * P = P) :
    matrixSquare (A * P) + matrixSquare (A * (1 - P)) = matrixSquare A := by
  have hp := projection_complement_mul P hi
  have hfirst : matrixSquare (A * P) = Matrix.trace (Aᵀ * A * P) := by
    simp only [matrixSquare, Matrix.transpose_mul, hs]
    calc
      _ = Matrix.trace (P * (Aᵀ * A) * P) := by simp only [Matrix.mul_assoc]
      _ = Matrix.trace (P * P * (Aᵀ * A)) := Matrix.trace_mul_cycle _ _ _
      _ = Matrix.trace (Aᵀ * A * P) := by rw [hi, Matrix.trace_mul_comm]
  have hsecond : matrixSquare (A * (1 - P)) = Matrix.trace (Aᵀ * A * (1 - P)) := by
    simp only [matrixSquare, Matrix.transpose_mul, Matrix.transpose_sub,
      Matrix.transpose_one, hs]
    calc
      _ = Matrix.trace ((1 - P) * (Aᵀ * A) * (1 - P)) := by simp only [Matrix.mul_assoc]
      _ = Matrix.trace ((1 - P) * (1 - P) * (Aᵀ * A)) := Matrix.trace_mul_cycle _ _ _
      _ = Matrix.trace (Aᵀ * A * (1 - P)) := by rw [hp.2.2, Matrix.trace_mul_comm]
  rw [hfirst, hsecond, Matrix.mul_sub, Matrix.mul_one, Matrix.trace_sub]
  simp [matrixSquare]

theorem matrixSquare_projection_le (A : Matrix m n ℝ) (P : Matrix n n ℝ)
    (hs : Pᵀ = P) (hi : P * P = P) :
    matrixSquare (A * P) ≤ matrixSquare A := by
  have h := matrixSquare_projection_split A P hs hi
  have hn := matrixSquare_nonneg (A * (1 - P))
  linarith

/-- Exact cancellation: the target-complement error and the projected
perturbation have zero total cross term. -/
theorem low_rank_projection_error_identity (J E : Matrix m n ℝ)
    (P : Matrix n n ℝ) (hs : Pᵀ = P) (hi : P * P = P)
    (hJ : Jᵀ * J = 1) :
    matrixSquare (E * P - J * (1 - P)) =
      Matrix.trace (1 - P) + matrixSquare (E * P) := by
  have hp := projection_complement_mul P hi
  have htarget : matrixSquare (J * (1 - P)) = Matrix.trace (1 - P) := by
    simp only [matrixSquare, Matrix.transpose_mul, Matrix.transpose_sub,
      Matrix.transpose_one, hs]
    calc
      _ = Matrix.trace ((1 - P) * (Jᵀ * J) * (1 - P)) := by simp only [Matrix.mul_assoc]
      _ = Matrix.trace (1 - P) := by rw [hJ, Matrix.mul_one, hp.2.2]
  have hcross : Matrix.trace ((E * P)ᵀ * (J * (1 - P))) = 0 := by
    simp only [Matrix.transpose_mul, hs]
    calc
      _ = Matrix.trace (P * (Eᵀ * J) * (1 - P)) := by simp only [Matrix.mul_assoc]
      _ = Matrix.trace ((1 - P) * P * (Eᵀ * J)) := Matrix.trace_mul_cycle _ _ _
      _ = 0 := by rw [hp.2.1, Matrix.zero_mul, Matrix.trace_zero]
  rw [matrixSquare_sub, htarget, hcross]
  ring

/-- The deterministic squared-error budget. The analytic application
supplies a kernel projection with trace deficit equal to its lost rank. -/
theorem low_rank_projection_error_bound (J E : Matrix m n ℝ)
    (P : Matrix n n ℝ) (hs : Pᵀ = P) (hi : P * P = P)
    (hJ : Jᵀ * J = 1) (d error : ℝ)
    (htrace : Matrix.trace (1 - P) ≤ d) (herror : matrixSquare E ≤ error) :
    matrixSquare (E * P - J * (1 - P)) ≤ d + error := by
  rw [low_rank_projection_error_identity J E P hs hi hJ]
  exact add_le_add htrace ((matrixSquare_projection_le E P hs hi).trans herror)


/-- An idempotent real matrix has trace equal to the dimension of its image. -/
theorem idempotent_matrix_trace (P : Matrix n n ℝ) (hi : P * P = P) :
    Matrix.trace P = (Matrix.rank P : ℝ) := by
  have hid : IsIdempotentElem P.toLin' := by
    change P.toLin' * P.toLin' = P.toLin'
    rw [Module.End.mul_eq_comp, ← Matrix.toLin'_mul, hi]
  have h := (LinearMap.IsIdempotentElem.isProj_range P.toLin' hid).trace
  change Matrix.trace P = (Module.finrank ℝ (LinearMap.range P.toLin') : ℝ)
  simpa only [Matrix.trace_toLin'_eq] using h

/-- A projection onto a linear kernel loses exactly the rank of that map. -/
theorem kernel_projection_trace_deficit (L : Matrix m n ℝ) (P : Matrix n n ℝ)
    (hi : P * P = P)
    (hrange : LinearMap.range P.toLin' = LinearMap.ker L.toLin') :
    Matrix.trace (1 - P) = (Matrix.rank L : ℝ) := by
  have hp : Matrix.trace P = (Module.finrank ℝ (LinearMap.ker L.toLin') : ℝ) := by
    rw [idempotent_matrix_trace P hi]
    change (Module.finrank ℝ (LinearMap.range P.toLin') : ℝ) = _
    rw [hrange]
  have hdim : Matrix.rank L + Module.finrank ℝ (LinearMap.ker L.toLin') = Fintype.card n := by
    change Module.finrank ℝ (LinearMap.range L.toLin') + _ = _
    simpa using L.toLin'.finrank_range_add_finrank_ker
  have hdim' : (Matrix.rank L : ℝ) +
      (Module.finrank ℝ (LinearMap.ker L.toLin') : ℝ) = (Fintype.card n : ℝ) := by
    exact_mod_cast hdim
  rw [Matrix.trace_sub, Matrix.trace_one, hp]
  linarith

/-- Actual synthesis with projected coefficients has the stated residual. -/
theorem low_rank_synthesis_residual {c : Type*} [Fintype c]
    (Φ : Matrix m c ℝ) (C : Matrix c n ℝ) (J L E : Matrix m n ℝ)
    (P : Matrix n n ℝ) (hsynth : Φ * C = J + L + E) (hLP : L * P = 0) :
    Φ * (C * P) - J = E * P - J * (1 - P) := by
  rw [← Matrix.mul_assoc, hsynth]
  simp only [Matrix.add_mul, hLP, add_zero, Matrix.mul_sub, Matrix.mul_one]
  abel

/-- Finite low-rank cancellation, with the lost rank proved through
rank-nullity rather than inserted as a trace assumption. -/
theorem low_rank_synthesis_error {c : Type*} [Fintype c]
    (Φ : Matrix m c ℝ) (C : Matrix c n ℝ) (J L E : Matrix m n ℝ)
    (P : Matrix n n ℝ) (hsynth : Φ * C = J + L + E) (hLP : L * P = 0)
    (hs : Pᵀ = P) (hi : P * P = P) (hJ : Jᵀ * J = 1)
    (hrange : LinearMap.range P.toLin' = LinearMap.ker L.toLin') :
    matrixSquare (Φ * (C * P) - J) ≤ (Matrix.rank L : ℝ) + matrixSquare E := by
  rw [low_rank_synthesis_residual Φ C J L E P hsynth hLP,
    low_rank_projection_error_identity J E P hs hi hJ,
    kernel_projection_trace_deficit L P hi hrange]
  exact add_le_add le_rfl (matrixSquare_projection_le E P hs hi)

/-- Every finite real matrix has an orthogonal projection onto its kernel.
The matrix is constructed, rather than supplied as an extra hypothesis. -/
theorem exists_matrix_kernel_projection (L : Matrix m n ℝ) :
    ∃ P : Matrix n n ℝ, Pᵀ = P ∧ P * P = P ∧ L * P = 0 ∧
      LinearMap.range P.toLin' = LinearMap.ker L.toLin' := by
  let K := LinearMap.ker L.toEuclideanLin
  let p := K.starProjection.toLinearMap
  let P : Matrix n n ℝ := Matrix.toEuclideanLin.symm p
  have hP : P.toEuclideanLin = p := LinearEquiv.apply_symm_apply _ _
  have hs : Pᵀ = P := by
    have hsym : P.toEuclideanLin.IsSymmetric := by
      rw [hP]
      exact K.starProjection_isSymmetric
    have hh := Matrix.isSymmetric_toEuclideanLin_iff.mp hsym
    simpa only [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial] using hh
  have hi : P * P = P := by
    apply Matrix.toEuclideanLin.injective
    rw [Matrix.toLpLin_mul_same, hP]
    exact congrArg ContinuousLinearMap.toLinearMap K.isIdempotentElem_starProjection
  have hrange : LinearMap.range P.toLin' = LinearMap.ker L.toLin' := by
    ext x
    constructor
    · rintro ⟨y, rfl⟩
      change L.toLin' (P.toLin' y) = 0
      have hm := K.starProjection_apply_mem (WithLp.toLp 2 y)
      change L.toEuclideanLin (p (WithLp.toLp 2 y)) = 0 at hm
      rw [← hP] at hm
      simpa only [Matrix.toEuclideanLin, Matrix.toLpLin_toLp,
        WithLp.toLp_eq_zero] using hm
    · intro hx
      change L.toLin' x = 0 at hx
      have hx' : WithLp.toLp 2 x ∈ K := by
        change L.toEuclideanLin (WithLp.toLp 2 x) = 0
        simpa only [Matrix.toEuclideanLin, Matrix.toLpLin_toLp,
          WithLp.toLp_eq_zero] using hx
      have hf : p (WithLp.toLp 2 x) = WithLp.toLp 2 x :=
        Submodule.starProjection_eq_self_iff.mpr hx'
      rw [← hP] at hf
      refine ⟨x, ?_⟩
      exact congrArg WithLp.ofLp hf
  have hLP : L * P = 0 := by
    apply Matrix.toLin'.injective
    rw [Matrix.toLin'_mul, map_zero]
    apply LinearMap.ext
    intro x
    exact (show P.toLin' x ∈ LinearMap.ker L.toLin' from
      hrange ▸ LinearMap.mem_range_self P.toLin' x)
  exact ⟨P, hs, hi, hLP, hrange⟩

/-- The finite-dimensional low-rank transfer lemma, with no projection
existence hypothesis. The new coefficients satisfy both error and norm
bounds simultaneously. -/
theorem exists_low_rank_transfer_coefficients {c : Type*} [Fintype c]
    (Φ : Matrix m c ℝ) (C : Matrix c n ℝ) (J L E : Matrix m n ℝ)
    (hsynth : Φ * C = J + L + E) (hJ : Jᵀ * J = 1) :
    ∃ C' : Matrix c n ℝ,
      matrixSquare (Φ * C' - J) ≤ (Matrix.rank L : ℝ) + matrixSquare E ∧
      matrixSquare C' ≤ matrixSquare C := by
  obtain ⟨P, hs, hi, hLP, hrange⟩ := exists_matrix_kernel_projection L
  exact ⟨C * P, low_rank_synthesis_error Φ C J L E P hsynth hLP hs hi hJ hrange,
    matrixSquare_projection_le C P hs hi⟩

end IndependentResearch

