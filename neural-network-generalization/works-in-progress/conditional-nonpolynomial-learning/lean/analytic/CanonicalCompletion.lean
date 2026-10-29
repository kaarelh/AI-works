import CanonicalRidgeBounds
import Mathlib.Algebra.Order.Group.MinMax

/-! Quantitative error control for the clipped square-root completion of the
canonical map. This is the step that squares the needed quadrature accuracy. -/

noncomputable section
namespace ConditionalNonpolynomial.Analytic

lemma sqrt_difference_bound {a b : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b) :
    |Real.sqrt a-Real.sqrt b| ≤ Real.sqrt |a-b| := by
  have hsqA := Real.sq_sqrt ha
  have hsqB := Real.sq_sqrt hb
  have hs : (Real.sqrt a-Real.sqrt b)^2 ≤ |a-b| := by
    by_cases hab : a ≤ b
    · rw [abs_of_nonpos (by linarith : a-b ≤ 0)]
      have hmon := Real.sqrt_le_sqrt hab
      have hmul := mul_nonneg (Real.sqrt_nonneg a) (sub_nonneg.mpr hmon)
      nlinarith
    · rw [abs_of_nonneg (by linarith : 0 ≤ a-b)]
      have hmon := Real.sqrt_le_sqrt (le_of_not_ge hab)
      have hmul := mul_nonneg (Real.sqrt_nonneg b) (sub_nonneg.mpr hmon)
      nlinarith
  have hc := Real.sq_sqrt (abs_nonneg (a-b))
  nlinarith [sq_abs (Real.sqrt a-Real.sqrt b), abs_nonneg (Real.sqrt a-Real.sqrt b),
    Real.sqrt_nonneg |a-b|]

lemma clipped_sqrt_difference_bound (a b : ℝ) :
    |Real.sqrt (max 0 a)-Real.sqrt (max 0 b)| ≤ Real.sqrt |a-b| := by
  have hmax : |max 0 a-max 0 b| ≤ |a-b| := by
    simpa only [max_comm a 0, max_comm b 0] using abs_max_sub_max_le_abs a b 0
  exact (sqrt_difference_bound (le_max_left _ _) (le_max_left _ _)).trans
    (Real.sqrt_le_sqrt hmax)

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

def canonicalCompletion (b : E) (q : ℝ) : WithLp 2 (E × ℝ) :=
  WithLp.toLp 2 (b, Real.sqrt (max 0 (q-‖b‖^2)))

/-- Canonical completion is uniformly continuous with an explicit square-root
modulus, including when numerical rounding makes the residual square negative. -/
theorem canonicalCompletion_error (b b' : E) (q q' R δ : ℝ)
    (hR : 0 ≤ R) (hδ : 0 ≤ δ) (hb : ‖b‖ ≤ R) (hb' : ‖b'‖ ≤ R)
    (herr : ‖b-b'‖ ≤ δ) (hq : |q-q'| ≤ δ) :
    ‖canonicalCompletion b q-canonicalCompletion b' q'‖ ≤
      δ+Real.sqrt ((1+2*R)*δ) := by
  have hnorm := (abs_norm_sub_norm_le b b').trans herr
  have hsq : |‖b‖^2-‖b'‖^2| ≤ 2*R*δ := by
    have hid : ‖b‖^2-‖b'‖^2 = (‖b‖-‖b'‖)*(‖b‖+‖b'‖) := by ring
    rw [hid, abs_mul, abs_of_nonneg (add_nonneg (norm_nonneg _) (norm_nonneg _))]
    have hh := mul_le_mul hnorm (add_le_add hb hb')
      (add_nonneg (norm_nonneg _) (norm_nonneg _)) hδ
    nlinarith
  have hresidual : |(q-‖b‖^2)-(q'-‖b'‖^2)| ≤ (1+2*R)*δ := by
    have hid : (q-‖b‖^2)-(q'-‖b'‖^2) = (q-q')-(‖b‖^2-‖b'‖^2) := by ring
    rw [hid]
    have hh := abs_sub_le (q-q') 0 (‖b‖^2-‖b'‖^2)
    simp only [sub_zero, zero_sub, abs_neg] at hh
    nlinarith
  have hroot := (clipped_sqrt_difference_bound (q-‖b‖^2) (q'-‖b'‖^2)).trans
    (Real.sqrt_le_sqrt hresidual)
  have hh := prodL2_norm_le_add (canonicalCompletion b q-canonicalCompletion b' q')
  change ‖canonicalCompletion b q-canonicalCompletion b' q'‖ ≤
    ‖b-b'‖+|Real.sqrt (max 0 (q-‖b‖^2))-Real.sqrt (max 0 (q'-‖b'‖^2))| at hh
  exact hh.trans (add_le_add herr hroot)

/-- An inverse-polynomial accuracy loss suffices through completion. -/
theorem canonicalCompletion_accuracy (b b' : E) (q q' R δ ε : ℝ)
    (hR : 0 ≤ R) (hδ : 0 ≤ δ) (hε : 0 ≤ ε)
    (hb : ‖b‖ ≤ R) (hb' : ‖b'‖ ≤ R)
    (herr : ‖b-b'‖ ≤ δ) (hq : |q-q'| ≤ δ)
    (hsmall : δ ≤ ε/2) (hsquare : (1+2*R)*δ ≤ (ε/2)^2) :
    ‖canonicalCompletion b q-canonicalCompletion b' q'‖ ≤ ε := by
  have hsqrt : Real.sqrt ((1+2*R)*δ) ≤ ε/2 := by
    have hh := Real.sqrt_le_sqrt hsquare
    simpa only [Real.sqrt_sq (by positivity : 0 ≤ ε/2)] using hh
  exact (canonicalCompletion_error b b' q q' R δ hR hδ hb hb' herr hq).trans (by linarith)

#print axioms canonicalCompletion_error
#print axioms canonicalCompletion_accuracy
end ConditionalNonpolynomial.Analytic
