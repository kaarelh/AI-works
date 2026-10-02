import Paulsen

/-!
# Independent restatement check

The target statements are written below from scratch, using only standard
Mathlib vocabulary (Loewner order via `PosSemidef`, dot products, trace,
`IsIdempotentElem`, `Matrix.rank`), without any definition from the
`Paulsen` namespace. Each is then derived from the project's theorems.
-/

open Matrix

/-- The real Paulsen bound in standard vocabulary:
`(1-ε)I ≼ UᵀU ≼ (1+ε)I`, `(1-ε)d/n ≤ ‖uᵢ‖² ≤ (1+ε)d/n` ⟹ some `W` with
`WᵀW = I`, `‖wᵢ‖² = d/n`, and `tr((U-W)ᵀ(U-W)) ≤ C ε d`. -/
theorem paulsen_independent :
    ∃ C : ℝ, 0 < C ∧ ∀ (n d : ℕ), 0 < d → d ≤ n → ∀ ε : ℝ, 0 < ε → ε < 1 →
    ∀ U : Matrix (Fin n) (Fin d) ℝ,
      (Uᵀ * U - (1 - ε) • (1 : Matrix (Fin d) (Fin d) ℝ)).PosSemidef →
      ((1 + ε) • (1 : Matrix (Fin d) (Fin d) ℝ) - Uᵀ * U).PosSemidef →
      (∀ i, (1 - ε) * ((d : ℝ) / n) ≤ U i ⬝ᵥ U i ∧
            U i ⬝ᵥ U i ≤ (1 + ε) * ((d : ℝ) / n)) →
      ∃ W : Matrix (Fin n) (Fin d) ℝ, Wᵀ * W = 1 ∧
        (∀ i, W i ⬝ᵥ W i = (d : ℝ) / n) ∧
        ((U - W)ᵀ * (U - W)).trace ≤ C * ε * d := by
  obtain ⟨C, hC, H⟩ := Paulsen.sharpPaulsenBound
  refine ⟨C, hC, ?_⟩
  intro n d hd hdn ε hε hε1 U hlo hhi hrow
  -- quadratic form of UᵀU equals the frame energy
  have hq : ∀ x : Fin d → ℝ, x ⬝ᵥ ((Uᵀ * U) *ᵥ x) = Paulsen.frameEnergy U x := by
    intro x
    rw [← Matrix.mulVec_mulVec, Matrix.dotProduct_mulVec, Matrix.vecMul_transpose]
    simp [Paulsen.frameEnergy, dotProduct, Matrix.mulVec, sq]
  have hnear : Paulsen.IsNearlyEqualNormParseval ε U := by
    refine ⟨?_, ?_⟩
    · intro x
      have h1 := hlo.2 x
      have h2 := hhi.2 x
      simp only [star_trivial, Matrix.sub_mulVec, dotProduct_sub, Matrix.smul_mulVec,
        Matrix.one_mulVec, dotProduct_smul, smul_eq_mul] at h1 h2
      rw [hq] at h1 h2
      have hx : x ⬝ᵥ x = Paulsen.vectorNormSq x := by
        simp [Paulsen.vectorNormSq, dotProduct, sq]
      rw [hx] at h1 h2
      constructor <;> linarith
    · intro i
      have hr : U i ⬝ᵥ U i = Paulsen.rowNormSq U i := by
        simp [Paulsen.rowNormSq, dotProduct, sq]
      rw [← hr]
      exact hrow i
  obtain ⟨W, ⟨hWp, hWn⟩, hdist⟩ := H n d hd hdn ε U hε hε1 hnear
  refine ⟨W, hWp, ?_, ?_⟩
  · intro i
    have := hWn i
    simpa [Paulsen.rowNormSq, dotProduct, sq] using this
  · have htr : ((U - W)ᵀ * (U - W)).trace = Paulsen.sqDistance U W := by
      simp only [Matrix.trace, Matrix.diag, Matrix.mul_apply, Matrix.transpose_apply,
        Matrix.sub_apply, Paulsen.sqDistance]
      rw [Finset.sum_comm]
      simp [sq]
    rw [htr]
    exact hdist

/-- The projection form in standard vocabulary. -/
theorem paulsen_projection_independent :
    ∃ C : ℝ, 0 < C ∧ ∀ (n d : ℕ), 0 < n →
    ∀ P : Matrix (Fin n) (Fin n) ℝ, P.IsHermitian → IsIdempotentElem P → P.rank = d →
    ∀ β : ℝ, 0 ≤ β → (∀ i, |P i i - (d : ℝ) / n| ≤ β) →
    ∃ Q : Matrix (Fin n) (Fin n) ℝ, Q.IsHermitian ∧ IsIdempotentElem Q ∧ Q.rank = d ∧
      (∀ i, Q i i = (d : ℝ) / n) ∧
      ((P - Q)ᵀ * (P - Q)).trace ≤ C * n * β := by
  obtain ⟨C, hC, H⟩ := Paulsen.sharpProjectionBound
  refine ⟨C, hC, ?_⟩
  intro n d hn P hP hPi hrank β hβ hdiag
  have hPt : P.transpose = P := by
    simpa [Matrix.IsHermitian, Matrix.conjTranspose] using hP
  obtain ⟨Q, hQt, hQi, hQr, hQd, hdist⟩ := H n d hn P hPt hPi hrank β hβ hdiag
  refine ⟨Q, ?_, hQi, hQr, hQd, ?_⟩
  · simpa [Matrix.IsHermitian, Matrix.conjTranspose] using hQt
  · have htr : ((P - Q)ᵀ * (P - Q)).trace = Paulsen.sqDistance P Q := by
      simp only [Matrix.trace, Matrix.diag, Matrix.mul_apply, Matrix.transpose_apply,
        Matrix.sub_apply, Paulsen.sqDistance]
      rw [Finset.sum_comm]
      simp [sq]
    rw [htr]
    exact hdist

#print axioms paulsen_independent
#print axioms paulsen_projection_independent
