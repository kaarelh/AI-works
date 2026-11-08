import NeuralGeneralization.OnlineLowerPathTransfer

/-!
# A common strict order for the scalar path boundary values

The path transfer has a common scalar boundary term once the free syndrome
bits have fixed total parity.  Its remaining dependence on the syndrome is
a positive affine function of a signed geometric expansion.  We prove a
single order that works simultaneously for every ratio in `(0, 1/3]`.

This is the scalar ordering component, not a theorem about the Gaussian
posterior or the analytic realization of its Bernstein kernel.
-/

noncomputable section

namespace NeuralGeneralization.OnlineLower

def digitLexLt : List Bool → List Bool → Prop
  | a :: as, b :: bs => (a = false ∧ b = true) ∨ (a = b ∧ digitLexLt as bs)
  | _, _ => False

theorem digitLexLt_or_reverse {xs ys : List Bool}
    (hlen : xs.length = ys.length) (hne : xs ≠ ys) :
    digitLexLt xs ys ∨ digitLexLt ys xs := by
  induction xs generalizing ys with
  | nil =>
    cases ys with
    | nil => exact (hne rfl).elim
    | cons b ys => simp at hlen
  | cons a xs ih =>
    cases ys with
    | nil => simp at hlen
    | cons b ys =>
      have ht : xs.length = ys.length := by simpa using hlen
      by_cases hab : a = b
      · subst b
        have hn : xs ≠ ys := by
          intro he
          exact hne (congrArg (List.cons a) he)
        rcases ih ht hn with h | h
        · exact Or.inl (Or.inr ⟨rfl, h⟩)
        · exact Or.inr (Or.inr ⟨rfl, h⟩)
      · cases a <;> cases b <;> simp_all [digitLexLt]

theorem signedSeries_lt_of_digitLexLt (r : ℝ) (hr0 : 0 < r)
    (hr : r ≤ 1 / 3) {xs ys : List Bool} (h : digitLexLt xs ys) :
    signedSeries r xs < signedSeries r ys := by
  induction xs generalizing ys with
  | nil => exact h.elim
  | cons a xs ih =>
    cases ys with
    | nil => exact h.elim
    | cons b ys =>
      rcases h with ⟨ha, hb⟩ | ⟨hab, ht⟩
      · subst a
        subst b
        have hx := abs_le.mp (signedSeries_abs_le r hr0.le hr xs)
        have hy := abs_le.mp (signedSeries_abs_le r hr0.le hr ys)
        have hxu := mul_le_mul_of_nonneg_left hx.2 hr0.le
        have hyl := mul_le_mul_of_nonneg_left hy.1 hr0.le
        simp only [signedSeries, digitSign, Bool.false_eq_true, if_false, if_true]
        nlinarith
      · subst b
        have ht' := mul_lt_mul_of_pos_left (ih ht) hr0
        simpa only [signedSeries, add_comm] using add_lt_add_left ht' (digitSign a)

/-- The original scalar coordinate after fixed-parity triangular transfer,
with its common positive prefactor omitted.  The endpoint sign `endpoint`
and the number of blocks `k` are fixed across the candidate family. -/
def pathBoundaryScalar (x : ℝ) (k : ℕ) (endpoint : ℝ) (digits : List Bool) : ℝ :=
  1 + x ^ 2 *
    (pathSlope x * (1 + pathRatio x * signedSeries (pathRatio x) digits) +
      endpoint * pathRatio x ^ k)

theorem pathBoundaryScalar_lt (x : ℝ) (hx0 : 0 < x) (hx1 : x ≤ 1)
    (k : ℕ) (endpoint : ℝ) {xs ys : List Bool} (h : digitLexLt xs ys) :
    pathBoundaryScalar x k endpoint xs < pathBoundaryScalar x k endpoint ys := by
  have hr0 := pathRatio_pos x hx0
  have hr := pathRatio_le_third x hx0.le hx1
  have hs := signedSeries_lt_of_digitLexLt (pathRatio x) hr0 hr h
  have hm := mul_lt_mul_of_pos_left hs hr0
  have hb := mul_lt_mul_of_pos_left (add_lt_add_left hm 1) (pathSlope_pos x hx0)
  have hx2 : 0 < x ^ 2 := pow_pos hx0 2
  have hh := mul_lt_mul_of_pos_left
    (add_lt_add_right hb (endpoint * pathRatio x ^ k)) hx2
  simpa only [pathBoundaryScalar, add_comm] using add_lt_add_left hh 1

theorem pathBoundaryScalar_ne_of_ne (x : ℝ) (hx0 : 0 < x) (hx1 : x ≤ 1)
    (k : ℕ) (endpoint : ℝ) {xs ys : List Bool}
    (hlen : xs.length = ys.length) (hne : xs ≠ ys) :
    pathBoundaryScalar x k endpoint xs ≠ pathBoundaryScalar x k endpoint ys := by
  rcases digitLexLt_or_reverse hlen hne with h | h
  · exact (pathBoundaryScalar_lt x hx0 hx1 k endpoint h).ne
  · exact (pathBoundaryScalar_lt x hx0 hx1 k endpoint h).ne'

/-- The full scalar Fourier factor is a positive common multiple of the
boundary value, so the same ordering survives that normalization. -/
theorem normalized_path_scalar_lt (x scale : ℝ) (hx0 : 0 < x) (hx1 : x ≤ 1)
    (hscale : 0 < scale) (k : ℕ) (endpoint : ℝ)
    {xs ys : List Bool} (h : digitLexLt xs ys) :
    scale * pathBoundaryScalar x k endpoint xs <
      scale * pathBoundaryScalar x k endpoint ys :=
  mul_lt_mul_of_pos_left (pathBoundaryScalar_lt x hx0 hx1 k endpoint h) hscale

end NeuralGeneralization.OnlineLower
