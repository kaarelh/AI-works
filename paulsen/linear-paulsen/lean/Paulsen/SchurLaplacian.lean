import Paulsen.KilledLaplacian

/-!
# Graph structure of a Schur complement

Eliminating a coercive exceptional block adds nonnegative edge weights to the
good graph. The forcing transfer and harmonic extension are stochastic in the
required directions; these properties are proved, rather than assumed.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

variable {ι κ : Type*} [Fintype ι] [Fintype κ] [DecidableEq ι] [DecidableEq κ]

omit [Fintype ι] [DecidableEq ι] [DecidableEq κ] in
theorem matrix_mul_entry_nonneg
    {ν : Type*} [Fintype ν]
    (A : Matrix ι κ ℝ) (B : Matrix κ ν ℝ)
    (hA : ∀ i j, 0 ≤ A i j) (hB : ∀ i j, 0 ≤ B i j) (i : ι) (j : ν) :
    0 ≤ (A * B) i j := by
  exact Finset.sum_nonneg (fun k _ => mul_nonneg (hA i k) (hB k j))

omit [DecidableEq ι] in
/-- The inverse times the boundary weights extends constants as constants. -/
theorem schur_harmonic_row_sum
    (E : Matrix ι κ ℝ) (D R : Matrix κ κ ℝ)
    (hRD : R * D = 1)
    (hrows : ∀ i, (∑ j, D i j) = ∑ j, E j i) (i : κ) :
    (∑ j, (R * E.transpose) i j) = 1 := by
  have hones : D *ᵥ (fun _ => (1 : ℝ)) = E.transpose *ᵥ (fun _ => (1 : ℝ)) := by
    ext k
    simpa only [Matrix.mulVec, dotProduct, mul_one, Matrix.transpose_apply] using hrows k
  have he := congrArg (fun x => R *ᵥ x) hones
  rw [Matrix.mulVec_mulVec, hRD, Matrix.one_mulVec, Matrix.mulVec_mulVec] at he
  have hi := congrFun he i
  simpa only [Matrix.mulVec, dotProduct, mul_one] using hi.symm

omit [DecidableEq ι] in
theorem schur_transfer_column_sum
    (E : Matrix ι κ ℝ) (D R : Matrix κ κ ℝ)
    (hRD : R * D = 1) (hR : R.IsSymm)
    (hrows : ∀ i, (∑ j, D i j) = ∑ j, E j i) (j : κ) :
    (∑ i, (E * R) i j) = 1 := by
  have ht : (E * R).transpose = R * E.transpose := by
    rw [Matrix.transpose_mul, hR.eq]
  simpa only [← ht, Matrix.transpose_apply] using schur_harmonic_row_sum E D R hRD hrows j

omit [DecidableEq ι] in
theorem schur_transfer_row_bound
    (E : Matrix ι κ ℝ) (D R : Matrix κ κ ℝ)
    (hRD : R * D = 1) (hR : R.IsSymm)
    (hrows : ∀ i, (∑ j, D i j) = ∑ j, E j i)
    (hE : ∀ i j, 0 ≤ E i j) (hRn : ∀ i j, 0 ≤ R i j) (i : ι) :
    (∑ j, |(E * R) i j|) ≤ (Fintype.card κ : ℝ) := by
  have hnonneg := matrix_mul_entry_nonneg E R hE hRn
  have hone : ∀ j, (E * R) i j ≤ 1 := by
    intro j
    rw [← schur_transfer_column_sum E D R hRD hR hrows j]
    exact Finset.single_le_sum (fun k _ => hnonneg k j) (Finset.mem_univ i)
  calc
    _ = ∑ j, (E * R) i j := by simp_rw [abs_of_nonneg (hnonneg i _)]
    _ ≤ ∑ _j : κ, (1 : ℝ) := Finset.sum_le_sum (fun j _ => hone j)
    _ = _ := by simp

omit [DecidableEq ι] in
theorem schur_added_weights_row_sum
    (E : Matrix ι κ ℝ) (D R : Matrix κ κ ℝ)
    (hRD : R * D = 1)
    (hrows : ∀ i, (∑ j, D i j) = ∑ j, E j i) (i : ι) :
    (∑ j, (E * R * E.transpose) i j) = ∑ j, E i j := by
  have hH : (R * E.transpose) *ᵥ (fun _ => (1 : ℝ)) = fun _ => 1 := by
    ext k
    simpa only [Matrix.mulVec, dotProduct, mul_one] using
      schur_harmonic_row_sum E D R hRD hrows k
  have h := congrArg (fun x => (E *ᵥ x) i) hH
  rw [Matrix.mulVec_mulVec, ← Matrix.mul_assoc] at h
  simpa only [Matrix.mulVec, dotProduct, mul_one] using h

omit [Fintype ι] [DecidableEq ι] [DecidableEq κ] in
theorem schur_added_weights_symmetric
    (E : Matrix ι κ ℝ) (R : Matrix κ κ ℝ) (hR : R.IsSymm) :
    (E * R * E.transpose).IsSymm := by
  show (E * R * E.transpose).transpose = E * R * E.transpose
  rw [Matrix.transpose_mul, Matrix.transpose_mul, Matrix.transpose_transpose,
    hR.eq, Matrix.mul_assoc]

omit [DecidableEq ι] in
/-- Keeping self-loops makes the effective total row masses identical to the
original total row masses. -/
theorem schur_weights_row_sum
    (W : Matrix ι ι ℝ) (E : Matrix ι κ ℝ) (D R : Matrix κ κ ℝ)
    (hRD : R * D = 1)
    (hrows : ∀ i, (∑ j, D i j) = ∑ j, E j i) (i : ι) :
    (∑ j, (W + E * R * E.transpose) i j) = (∑ j, W i j) + ∑ j, E i j := by
  simp only [Matrix.add_apply, Finset.sum_add_distrib,
    schur_added_weights_row_sum E D R hRD hrows]

/-- The graph Laplacian of the enlarged weights is exactly the Schur complement. -/
theorem schur_weights_laplacian
    (W : Matrix ι ι ℝ) (E : Matrix ι κ ℝ) (D R : Matrix κ κ ℝ)
    (hRD : R * D = 1)
    (hrows : ∀ i, (∑ j, D i j) = ∑ j, E j i) :
    graphLaplacian (W + E * R * E.transpose) =
      (Matrix.diagonal (fun i => (∑ j, W i j) + ∑ j, E i j) - W) -
        (-E) * R * (-E.transpose) := by
  unfold graphLaplacian
  simp only [schur_weights_row_sum W E D R hRD hrows,
    Matrix.neg_mul, Matrix.mul_neg, neg_neg]
  abel

omit [Fintype ι] [DecidableEq ι] [DecidableEq κ] in
theorem nonneg_matrix_mul_row_bound
    (E : Matrix ι κ ℝ) (R : Matrix κ κ ℝ) (degree b : ℝ)
    (hb : 0 ≤ b) (hE : ∀ i j, 0 ≤ E i j) (hR : ∀ i j, 0 ≤ R i j)
    (hErows : ∀ i, (∑ j, E i j) ≤ degree)
    (hRrows : ∀ i, (∑ j, |R i j|) ≤ b) (i : ι) :
    (∑ j, |(E * R) i j|) ≤ degree * b := by
  have hER := matrix_mul_entry_nonneg E R hE hR
  have hRrows' : ∀ i, (∑ j, R i j) ≤ b := by
    intro i
    simpa only [abs_of_nonneg (hR i _)] using hRrows i
  simp_rw [abs_of_nonneg (hER i _)]
  calc
    (∑ j, (E * R) i j) = ∑ k, E i k * ∑ j, R k j := by
      simp only [Matrix.mul_apply, Finset.mul_sum]
      rw [Finset.sum_comm]
    _ ≤ ∑ k, E i k * b := Finset.sum_le_sum (fun k _ =>
      mul_le_mul_of_nonneg_left (hRrows' k) (hE i k))
    _ = (∑ k, E i k) * b := (Finset.sum_mul _ _ _).symm
    _ ≤ degree * b := mul_le_mul_of_nonneg_right (hErows i) hb

/-- The exceptional-set Poisson estimate with both forcing-transfer bounds.
The retained graph uses the direct maximum--minimum comparison. -/
theorem boundedPoisson_of_exceptional_inverse [Nonempty ι]
    (w : Matrix (ι ⊕ κ) (ι ⊕ κ) ℝ) (γ r degree : ℝ)
    (hγ : 0 < γ) (hr : 0 ≤ r) (hdegree0 : 0 ≤ degree)
    (hw : ∀ i j, 0 ≤ w i j) (hsymm : ∀ i j, w i j = w j i)
    (hdegree : ∀ i : ι, (∑ j, w (Sum.inl i) j) ≤ degree)
    (hDR : (graphLaplacian w).submatrix Sum.inr Sum.inr *
      ((graphLaplacian w).submatrix Sum.inr Sum.inr)⁻¹ = 1)
    (hRn : ∀ i j, 0 ≤ ((graphLaplacian w).submatrix Sum.inr Sum.inr)⁻¹ i j)
    (hRrows : ∀ i, (∑ j, |((graphLaplacian w).submatrix Sum.inr Sum.inr)⁻¹ i j|) ≤ r)
    (hoverlap : ∀ i k : ι, γ ≤ ∑ j : ι,
      min (w (Sum.inl i) (Sum.inl j)) (w (Sum.inl k) (Sum.inl j))) :
    BoundedPoissonSolvability w
      ((1 + min (Fintype.card κ : ℝ) (degree * r)) / γ + r) := by
  let W := w.submatrix Sum.inl Sum.inl
  let E := w.submatrix Sum.inl Sum.inr
  let D := (graphLaplacian w).submatrix Sum.inr Sum.inr
  let R := D⁻¹
  let A := Matrix.diagonal (fun i => (∑ j, W i j) + ∑ j, E i j) - W
  have hRD : R * D = 1 := mul_eq_one_comm.mpr hDR
  have hDsymm : D.IsSymm := by
    ext i j
    simp only [D, Matrix.transpose_apply, Matrix.submatrix_apply, graphLaplacian,
      Matrix.sub_apply, Matrix.diagonal_apply]
    by_cases hij : i = j
    · subst j
      rfl
    · simp only [Sum.inr.injEq, hij, Ne.symm hij, if_false]
      rw [hsymm]
  have hRsymm : R.IsSymm := hDsymm.inv
  have hDrows : ∀ i, (∑ j, D i j) = ∑ j, E j i := by
    intro i
    simp only [D, E, Matrix.submatrix_apply, graphLaplacian, Matrix.sub_apply,
      Matrix.diagonal_apply, Sum.inr.injEq, Finset.sum_sub_distrib,
      Finset.sum_ite_eq, Finset.mem_univ, if_true, Fintype.sum_sum_type]
    simp only [add_sub_cancel_right]
    exact Finset.sum_congr rfl (fun j _ => hsymm (Sum.inr i) (Sum.inl j))
  have hE : ∀ i j, 0 ≤ E i j := fun i j => hw (Sum.inl i) (Sum.inr j)
  have hEt : ∀ i j, 0 ≤ E.transpose i j := fun i j => hE j i
  have hQnonneg : ∀ i j, 0 ≤ (E * R * E.transpose) i j :=
    matrix_mul_entry_nonneg (E * R) E.transpose
      (matrix_mul_entry_nonneg E R hE hRn) hEt
  let wEff := W + E * R * E.transpose
  have hEffsymm : ∀ i j, wEff i j = wEff j i := by
    intro i j
    have hQ := congrArg (fun M : Matrix ι ι ℝ => M j i)
      (schur_added_weights_symmetric E R hRsymm).eq
    change (E * R * E.transpose) i j = (E * R * E.transpose) j i at hQ
    change W i j + (E * R * E.transpose) i j =
      W j i + (E * R * E.transpose) j i
    rw [hQ]
    exact congrArg (fun a => a + (E * R * E.transpose) j i)
      (hsymm (Sum.inl i) (Sum.inl j))
  have hEffoverlap : ∀ i k, γ ≤ ∑ j, min (wEff i j) (wEff k j) := by
    intro i k
    refine (hoverlap i k).trans (Finset.sum_le_sum (fun j _ => ?_))
    apply min_le_min
    · change W i j ≤ W i j + (E * R * E.transpose) i j
      exact le_add_of_nonneg_right (hQnonneg i j)
    · change W k j ≤ W k j + (E * R * E.transpose) k j
      exact le_add_of_nonneg_right (hQnonneg k j)
  have hsolve := boundedPoisson_of_overlap_extrema wEff γ hγ hEffsymm hEffoverlap
  have hblocks : graphLaplacian w = Matrix.fromBlocks A (-E) (-E.transpose) D := by
    ext i j
    cases i with
    | inl i =>
      cases j with
      | inl j =>
        simp [A, W, E, graphLaplacian, Matrix.diagonal_apply, Fintype.sum_sum_type]
      | inr j => simp [E, graphLaplacian]
    | inr i =>
      cases j with
      | inl j => simp [E, graphLaplacian, hsymm (Sum.inr i) (Sum.inl j)]
      | inr j => rfl
  have hEff : graphLaplacian wEff = A - (-E) * R * (-E.transpose) :=
    schur_weights_laplacian W E D R hRD hDrows
  have htransferCols : ∀ j, (∑ i, (-((-E) * R)) i j) = 1 := by
    simpa only [Matrix.neg_mul, neg_neg] using
      schur_transfer_column_sum E D R hRD hRsymm hDrows
  have hErows : ∀ i, (∑ j, E i j) ≤ degree := by
    intro i
    have hi := hdegree i
    rw [Fintype.sum_sum_type] at hi
    have hgood : 0 ≤ ∑ j : ι, w (Sum.inl i) (Sum.inl j) :=
      Finset.sum_nonneg (fun j _ => hw _ _)
    change (∑ j : κ, w (Sum.inl i) (Sum.inr j)) ≤ degree
    linarith
  have htransferRows : ∀ i, (∑ j, |(-((-E) * R)) i j|) ≤
      min (Fintype.card κ : ℝ) (degree * r) := by
    intro i
    simp only [Matrix.neg_mul, neg_neg]
    exact le_min (schur_transfer_row_bound E D R hRD hRsymm hDrows hE hRn i)
      (nonneg_matrix_mul_row_bound E R degree r hr hE hRn hErows hRrows i)
  have hharmonicRows : ∀ i, (∑ j, |(-(R * (-E.transpose))) i j|) ≤ 1 := by
    intro i
    simp only [Matrix.mul_neg, neg_neg]
    have hnonneg := matrix_mul_entry_nonneg R E.transpose hRn hEt
    simp_rw [abs_of_nonneg (hnonneg i _)]
    exact le_of_eq (schur_harmonic_row_sum E D R hRD hDrows i)
  have hsolveFull := boundedPoisson_of_schur w wEff A (-E) (-E.transpose) D R
    (1 / γ) (min (Fintype.card κ : ℝ) (degree * r)) r
    (le_of_lt (one_div_pos.mpr hγ))
    (le_min (Nat.cast_nonneg _) (mul_nonneg hdegree0 hr)) hr
    hblocks hDR hEff hsolve htransferCols htransferRows hharmonicRows hRrows
  simpa only [mul_one_div] using hsolveFull

/-- The complete exceptional-block estimate. All inverse sign, inverse norm,
and stochastic-transfer conclusions are derived from coercivity and graph
structure. The only mixing input is overlap on the retained vertices. -/
theorem boundedPoisson_of_coercive_exceptional_block [Nonempty ι]
    (w : Matrix (ι ⊕ κ) (ι ⊕ κ) ℝ) (γ δ : ℝ)
    (hγ : 0 < γ) (hδ : 0 < δ)
    (hw : ∀ i j, 0 ≤ w i j) (hsymm : ∀ i j, w i j = w j i)
    (hmass : ∀ i, (∑ j, w i j) ≤ 1)
    (hcoerce : ∀ x : κ → ℝ, δ * (∑ i, x i ^ 2) ≤
      ∑ i, x i * ((graphLaplacian w).submatrix Sum.inr Sum.inr *ᵥ x) i)
    (hoverlap : ∀ i k : ι, γ ≤ ∑ j : ι,
      min (w (Sum.inl i) (Sum.inl j)) (w (Sum.inl k) (Sum.inl j))) :
    BoundedPoissonSolvability w
      ((1 + (Fintype.card κ : ℝ)) * (2 / γ) + (Fintype.card κ : ℝ) / δ) := by
  let D := (graphLaplacian w).submatrix Sum.inr Sum.inr
  have hDoff : ∀ i j, i ≠ j → D i j ≤ 0 := by
    intro i j hij
    simpa [D, graphLaplacian, Matrix.submatrix, Matrix.diagonal_apply, hij] using
      neg_nonpos.mpr (hw (Sum.inr i) (Sum.inr j))
  obtain ⟨hDR, _hRD, hRn⟩ := coercive_zMatrix_inverse D δ hδ hDoff hcoerce
  have hRrows := coercive_inverse_row_bound D δ hδ hcoerce hDR
  apply (boundedPoisson_of_exceptional_inverse w γ ((Fintype.card κ : ℝ) / δ) 1
    hγ (by positivity) (by norm_num) hw hsymm (fun i => hmass (Sum.inl i))
    hDR hRn hRrows hoverlap).mono
  have hmin := min_le_left (Fintype.card κ : ℝ) (1 * ((Fintype.card κ : ℝ) / δ))
  have hfirst : (1 + min (Fintype.card κ : ℝ) (1 * ((Fintype.card κ : ℝ) / δ))) / γ ≤
      (1 + (Fintype.card κ : ℝ)) / γ :=
    div_le_div_of_nonneg_right (by linarith) hγ.le
  have hnonneg : 0 ≤ (1 + (Fintype.card κ : ℝ)) / γ := by positivity
  calc
    _ ≤ (1 + (Fintype.card κ : ℝ)) / γ + (Fintype.card κ : ℝ) / δ := by linarith
    _ ≤ (1 + (Fintype.card κ : ℝ)) * (2 / γ) + (Fintype.card κ : ℝ) / δ := by
      nlinarith [show (1 + (Fintype.card κ : ℝ)) * (2 / γ) =
        2 * ((1 + (Fintype.card κ : ℝ)) / γ) by ring]

end Paulsen
