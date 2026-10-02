import Paulsen.MatrixScaling

/-!
# Complementary subspaces under reciprocal diagonal scaling

The proof is by explicit matrix factorizations, without rank or dimension
arguments. No analytic scaling-existence theorem is asserted here.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

variable {ι κ ν : Type*}
variable [Fintype ι] [DecidableEq ι]
variable [Fintype κ] [DecidableEq κ]
variable [Fintype ν] [DecidableEq ν]

/-- The Gram-inverse formula for the projection onto a full-column-rank matrix. -/
noncomputable def columnSpaceProjection (C : Matrix ι κ ℝ) : Matrix ι ι ℝ :=
  C * (C.transpose * C)⁻¹ * C.transpose

theorem transpose_mul_columnSpaceProjection_complement
    (C : Matrix ι κ ℝ) (hC : (C.transpose * C).PosDef) :
    C.transpose * (1 - columnSpaceProjection C) = 0 := by
  have hdet := (Matrix.isUnit_iff_isUnit_det (C.transpose * C)).mp hC.isUnit
  have hinv := Matrix.mul_nonsing_inv (C.transpose * C) hdet
  have hprod : C.transpose * columnSpaceProjection C = C.transpose := by
    unfold columnSpaceProjection
    calc
      C.transpose * (C * (C.transpose * C)⁻¹ * C.transpose) =
          ((C.transpose * C) * (C.transpose * C)⁻¹) * C.transpose := by
        simp only [Matrix.mul_assoc]
      _ = C.transpose := by rw [hinv, Matrix.one_mul]
  rw [Matrix.mul_sub, Matrix.mul_one, hprod, sub_self]

/-- If a complement factors through an orthogonal family, its Gram-inverse
projection is that complement. -/
theorem columnSpaceProjection_eq_complement_of_factor
    (C : Matrix ι κ ℝ) (E : Matrix ι ν ℝ)
    (hE : (E.transpose * E).PosDef)
    (horth : C.transpose * E = 0)
    (B : Matrix ν ι ℝ)
    (hfactor : 1 - columnSpaceProjection C = E * B) :
    columnSpaceProjection E = 1 - columnSpaceProjection C := by
  have horth' : E.transpose * C = 0 := by
    have h := congrArg Matrix.transpose horth
    simpa only [Matrix.transpose_mul, Matrix.transpose_transpose, Matrix.transpose_zero] using h
  have htest : E.transpose * (1 - columnSpaceProjection C) = E.transpose := by
    unfold columnSpaceProjection
    rw [Matrix.mul_sub, Matrix.mul_one]
    have hz : E.transpose * (C * (C.transpose * C)⁻¹ * C.transpose) = 0 := by
      calc
        E.transpose * (C * (C.transpose * C)⁻¹ * C.transpose) =
            (E.transpose * C) * ((C.transpose * C)⁻¹ * C.transpose) := by
          simp only [Matrix.mul_assoc]
        _ = 0 := by rw [horth', Matrix.zero_mul]
    rw [hz, sub_zero]
  have hGB : (E.transpose * E) * B = E.transpose := by
    rw [hfactor] at htest
    simpa only [Matrix.mul_assoc] using htest
  have hdet := (Matrix.isUnit_iff_isUnit_det (E.transpose * E)).mp hE.isUnit
  have hinv := Matrix.nonsing_inv_mul (E.transpose * E) hdet
  have hB : B = (E.transpose * E)⁻¹ * E.transpose := by
    calc
      B = ((E.transpose * E)⁻¹ * (E.transpose * E)) * B := by
        rw [hinv, Matrix.one_mul]
      _ = (E.transpose * E)⁻¹ * E.transpose := by
        rw [Matrix.mul_assoc, hGB]
  rw [hfactor, hB]
  unfold columnSpaceProjection
  exact Matrix.mul_assoc _ _ _

/-- Algebraic reciprocal-complement identity for symmetric inverse row maps. -/
theorem columnSpaceProjection_reciprocal_complement
    (U : Matrix ι κ ℝ) (V : Matrix ι ν ℝ)
    (D J : Matrix ι ι ℝ)
    (hD : D.transpose = D) (hDJ : D * J = 1) (hJD : J * D = 1)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0)
    (hC : ((D * U).transpose * (D * U)).PosDef)
    (hE : ((J * V).transpose * (J * V)).PosDef) :
    columnSpaceProjection (J * V) = 1 - columnSpaceProjection (D * U) := by
  let K : Matrix ι ι ℝ := 1 - columnSpaceProjection (D * U)
  have hUK : U.transpose * (D * K) = 0 := by
    have h := transpose_mul_columnSpaceProjection_complement (D * U) hC
    simpa only [Matrix.transpose_mul, hD, Matrix.mul_assoc] using h
  have hCE : (D * U).transpose * (J * V) = 0 := by
    rw [Matrix.transpose_mul, hD]
    calc
      (U.transpose * D) * (J * V) = U.transpose * ((D * J) * V) := by
        simp only [Matrix.mul_assoc]
      _ = 0 := by rw [hDJ, Matrix.one_mul, horth]
  have hfactor : K = (J * V) * (V.transpose * (D * K)) := by
    calc
      K = J * ((U * U.transpose + V * V.transpose) * (D * K)) := by
        rw [hcomplete, Matrix.one_mul, ← Matrix.mul_assoc, hJD, Matrix.one_mul]
      _ = (J * U) * (U.transpose * (D * K)) +
          (J * V) * (V.transpose * (D * K)) := by
        simp only [Matrix.add_mul, Matrix.mul_add, Matrix.mul_assoc]
      _ = (J * V) * (V.transpose * (D * K)) := by
        rw [hUK, Matrix.mul_zero, zero_add]
  exact columnSpaceProjection_eq_complement_of_factor (D * U) (J * V) hE hCE
    (V.transpose * (D * K)) hfactor

/-- Multiply each row by its specified scale. -/
noncomputable def rowScale (U : Matrix ι κ ℝ) (d : ι → ℝ) : Matrix ι κ ℝ :=
  Matrix.diagonal d * U

omit [Fintype κ] [DecidableEq κ] in
theorem rowScale_gram (U : Matrix ι κ ℝ) (d : ι → ℝ) :
    (rowScale U d).transpose * rowScale U d =
      weightedFrameGram U (fun i => d i ^ 2) := by
  have hDD : Matrix.diagonal d * Matrix.diagonal d = Matrix.diagonal (fun i => d i ^ 2) := by
    rw [Matrix.diagonal_mul_diagonal]
    simp only [pow_two]
  unfold rowScale weightedFrameGram
  rw [Matrix.transpose_mul, Matrix.diagonal_transpose]
  calc
    (U.transpose * Matrix.diagonal d) * (Matrix.diagonal d * U) =
        U.transpose * (Matrix.diagonal d * Matrix.diagonal d) * U := by
      simp only [Matrix.mul_assoc]
    _ = _ := by rw [hDD]

theorem rowScale_gram_posDef (U : Matrix ι κ ℝ) (d : ι → ℝ)
    (hU : U.transpose * U = 1) (hd : ∀ i, d i ≠ 0) :
    ((rowScale U d).transpose * rowScale U d).PosDef := by
  rw [rowScale_gram]
  exact weightedFrameGram_posDef U _ hU (fun i => sq_pos_of_ne_zero (hd i))

theorem rowScale_projection_diagonal (U : Matrix ι κ ℝ) (d : ι → ℝ) (i : ι) :
    columnSpaceProjection (rowScale U d) i i = scaledLeverage U (fun j => d j ^ 2) i := by
  unfold columnSpaceProjection
  rw [rowScale_gram]
  have hmat : rowScale U d * (weightedFrameGram U (fun j => d j ^ 2))⁻¹ *
      (rowScale U d).transpose =
      Matrix.diagonal d * (U * (weightedFrameGram U (fun j => d j ^ 2))⁻¹ * U.transpose) *
        Matrix.diagonal d := by
    simp only [rowScale, Matrix.transpose_mul, Matrix.diagonal_transpose, Matrix.mul_assoc]
  rw [hmat, Matrix.mul_diagonal, Matrix.diagonal_mul]
  unfold scaledLeverage
  ring

/-- Orthogonal complementary Parseval frames remain complementary when their
row scales are reciprocal. -/
theorem rowScale_reciprocal_complement
    (U : Matrix ι κ ℝ) (V : Matrix ι ν ℝ) (d : ι → ℝ)
    (hU : U.transpose * U = 1) (hV : V.transpose * V = 1)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (hd : ∀ i, d i ≠ 0) :
    columnSpaceProjection (rowScale V (fun i => (d i)⁻¹)) =
      1 - columnSpaceProjection (rowScale U d) := by
  have hDJ : Matrix.diagonal d * Matrix.diagonal (fun i => (d i)⁻¹) = 1 := by
    rw [Matrix.diagonal_mul_diagonal]
    simp only [mul_inv_cancel₀ (hd _), Matrix.diagonal_one]
  have hJD : Matrix.diagonal (fun i => (d i)⁻¹) * Matrix.diagonal d = 1 := by
    rw [Matrix.diagonal_mul_diagonal]
    simp only [inv_mul_cancel₀ (hd _), Matrix.diagonal_one]
  exact columnSpaceProjection_reciprocal_complement U V
    (Matrix.diagonal d) (Matrix.diagonal (fun i => (d i)⁻¹))
    (Matrix.diagonal_transpose d) hDJ hJD hcomplete horth
    (rowScale_gram_posDef U d hU hd)
    (rowScale_gram_posDef V _ hV (fun i => inv_ne_zero (hd i)))

/-- The leverage scores of reciprocally scaled complementary subspaces add
to one, for arbitrary strictly positive squared row scales. -/
theorem scaledLeverage_reciprocal_complement
    (U : Matrix ι κ ℝ) (V : Matrix ι ν ℝ) (z : ι → ℝ)
    (hU : U.transpose * U = 1) (hV : V.transpose * V = 1)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (hz : ∀ i, 0 < z i) (i : ι) :
    scaledLeverage V (fun j => (z j)⁻¹) i = 1 - scaledLeverage U z i := by
  let d : ι → ℝ := fun j => Real.sqrt (z j)
  have hd : ∀ j, d j ≠ 0 := fun j => ne_of_gt (Real.sqrt_pos.mpr (hz j))
  have hsq : (fun j => d j ^ 2) = z := by
    funext j
    exact Real.sq_sqrt (le_of_lt (hz j))
  have hisq : (fun j => ((d j)⁻¹) ^ 2) = fun j => (z j)⁻¹ := by
    funext j
    rw [inv_pow]
    congr 1
    exact Real.sq_sqrt (le_of_lt (hz j))
  have h := congrArg (fun M : Matrix ι ι ℝ => M i i)
    (rowScale_reciprocal_complement U V d hU hV hcomplete horth hd)
  simp only [Matrix.sub_apply, Matrix.one_apply_eq, rowScale_projection_diagonal, hsq, hisq] at h
  exact h

/-- The second exact diagonal-scaling inequality, obtained from the first
one on the reciprocal complement. -/
theorem diagonal_scaling_reciprocal_inequality
    (U : Matrix ι κ ℝ) (V : Matrix ι ν ℝ) (z : ι → ℝ)
    (hU : U.transpose * U = 1) (hV : V.transpose * V = 1)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (hz : ∀ i, 0 < z i) (i : ι) :
    (projectionLaplacian (U * U.transpose) *ᵥ (fun j => (z j)⁻¹)) i ≤
      -(z i)⁻¹ * (scaledLeverage U z i - (U * U.transpose) i i) := by
  have hPV : V * V.transpose = 1 - U * U.transpose := by
    rw [← hcomplete]
    abel
  have hp := parseval_diagonal_scaling_first_inequality V (fun j => (z j)⁻¹)
    hV (fun j => inv_pos.mpr (hz j)) i
  rw [scaledLeverage_reciprocal_complement U V z hU hV hcomplete horth hz i,
    hPV, projectionLaplacian_complement] at hp
  simp only [Matrix.sub_apply, Matrix.one_apply_eq] at hp
  nlinarith

/-- A uniform bound on diagonal movement gives both subsolution inequalities
needed by the scalar median-barrier argument. -/
theorem diagonal_scaling_two_subsolutions
    (U : Matrix ι κ ℝ) (V : Matrix ι ν ℝ) (z : ι → ℝ) (β : ℝ)
    (hU : U.transpose * U = 1) (hV : V.transpose * V = 1)
    (hcomplete : U * U.transpose + V * V.transpose = 1)
    (horth : U.transpose * V = 0) (hz : ∀ i, 0 < z i)
    (herror : ∀ i, |scaledLeverage U z i - (U * U.transpose) i i| ≤ β) :
    ∀ i,
      (projectionLaplacian (U * U.transpose) *ᵥ z) i ≤ β * z i ∧
      (projectionLaplacian (U * U.transpose) *ᵥ (fun j => (z j)⁻¹)) i ≤
        β * (z i)⁻¹ := by
  have hupper : ∀ i, scaledLeverage U z i - (U * U.transpose) i i ≤ β :=
    fun i => (abs_le.mp (herror i)).2
  intro i
  constructor
  · exact parseval_diagonal_scaling_subsolution U z β hU hz hupper i
  · have hp := diagonal_scaling_reciprocal_inequality U V z hU hV hcomplete horth hz i
    have hlower := (abs_le.mp (herror i)).1
    have hm := mul_le_mul_of_nonneg_left hlower (le_of_lt (inv_pos.mpr (hz i)))
    nlinarith

end Paulsen
