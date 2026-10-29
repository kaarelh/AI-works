import EnvelopeQuadrature
import NormalizedTanh
import Mathlib.Analysis.InnerProductSpace.ProdL2

/-! Pointwise bounds for the actual joint canonical observable: projection
coordinates together with the squared normalized feature norm. The scalar
tanh scale does not occur in the bounds. -/

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

lemma prodL2_norm_le_add (z : WithLp 2 (E × ℝ)) : ‖z‖ ≤ ‖z.fst‖+|z.snd| := by
  have hsq := WithLp.prod_norm_sq_eq_of_L2 z
  rw [Real.norm_eq_abs] at hsq
  nlinarith [norm_nonneg z, norm_nonneg z.fst, abs_nonneg z.snd,
    mul_nonneg (norm_nonneg z.fst) (abs_nonneg z.snd)]

def jointCanonicalObservable (e : E) (k a s : ℝ) : WithLp 2 (E × ℝ) :=
  WithLp.toLp 2 ((k*normalizedTanh a s) • e, (k*normalizedTanh a s)^2)

def canonicalEnvelope (e : E) (k : ℝ) : ℝ := 1+‖e‖^2+k^2

lemma canonicalEnvelope_one_le (e : E) (k : ℝ) : 1 ≤ canonicalEnvelope e k := by
  unfold canonicalEnvelope
  nlinarith [sq_nonneg ‖e‖, sq_nonneg k]

lemma projection_factor_le_envelope (e : E) (k : ℝ) :
    |k| * ‖e‖ ≤ canonicalEnvelope e k := by
  unfold canonicalEnvelope
  nlinarith [sq_nonneg (|k|-‖e‖), sq_abs k, sq_nonneg ‖e‖, sq_nonneg k]

lemma square_factor_le_envelope (e : E) (k : ℝ) : k^2 ≤ canonicalEnvelope e k := by
  unfold canonicalEnvelope
  nlinarith [sq_nonneg ‖e‖]

/-- A joint projection/norm sample has an integrable quadratic envelope. -/
theorem jointCanonicalObservable_bound (e : E) (k a s B : ℝ)
    (hs : |s| ≤ B) :
    ‖jointCanonicalObservable e k a s‖ ≤ canonicalEnvelope e k*(B+B^2) := by
  have hB : 0 ≤ B := (abs_nonneg s).trans hs
  have hH : 0 ≤ canonicalEnvelope e k := (by norm_num : (0:ℝ) ≤ 1).trans (canonicalEnvelope_one_le e k)
  have hpsi := (normalizedTanh_bound a s).trans hs
  have hvec : ‖(k*normalizedTanh a s) • e‖ ≤ canonicalEnvelope e k*B := by
    rw [norm_smul, Real.norm_eq_abs, abs_mul]
    calc
      |k| * |normalizedTanh a s| * ‖e‖ = (|k| * ‖e‖)*|normalizedTanh a s| := by ring
      _ ≤ canonicalEnvelope e k*B := mul_le_mul (projection_factor_le_envelope e k) hpsi
        (abs_nonneg _) hH
  have hsq : |(k*normalizedTanh a s)^2| ≤ canonicalEnvelope e k*B^2 := by
    rw [abs_of_nonneg (sq_nonneg _), mul_pow]
    have hpsi2 : (normalizedTanh a s)^2 ≤ B^2 := by nlinarith [sq_abs (normalizedTanh a s), abs_nonneg (normalizedTanh a s)]
    exact mul_le_mul (square_factor_le_envelope e k) hpsi2 (sq_nonneg _) hH
  have hp := prodL2_norm_le_add (jointCanonicalObservable e k a s)
  change ‖jointCanonicalObservable e k a s‖ ≤ ‖(k*normalizedTanh a s) • e‖ + |(k*normalizedTanh a s)^2| at hp
  nlinarith

/-- Lipschitz envelope for the same joint observable, uniformly in arbitrary
positive or negative scalar normalization. -/
theorem jointCanonicalObservable_lipschitz (e : E) (k a s t B : ℝ)
    (hs : |s| ≤ B) (ht : |t| ≤ B) :
    ‖jointCanonicalObservable e k a s-jointCanonicalObservable e k a t‖ ≤
      canonicalEnvelope e k*((1+2*B)*|s-t|) := by
  have hB : 0 ≤ B := (abs_nonneg s).trans hs
  have hH : 0 ≤ canonicalEnvelope e k := (by norm_num : (0:ℝ) ≤ 1).trans (canonicalEnvelope_one_le e k)
  have hvec : ‖(k*normalizedTanh a s) • e-(k*normalizedTanh a t) • e‖ ≤
      canonicalEnvelope e k*|s-t| := by
    rw [← sub_smul, ← mul_sub, norm_smul, Real.norm_eq_abs, abs_mul]
    calc
      |k| * |normalizedTanh a s-normalizedTanh a t| * ‖e‖ =
        (|k| * ‖e‖)*|normalizedTanh a s-normalizedTanh a t| := by ring
      _ ≤ canonicalEnvelope e k*|s-t| :=
        mul_le_mul (projection_factor_le_envelope e k) (normalizedTanh_lipschitz a s t)
          (abs_nonneg _) hH
  have hsq : |(k*normalizedTanh a s)^2-(k*normalizedTanh a t)^2| ≤
      canonicalEnvelope e k*(2*B*|s-t|) := by
    rw [mul_pow, mul_pow, ← mul_sub, abs_mul, abs_of_nonneg (sq_nonneg k)]
    exact mul_le_mul (square_factor_le_envelope e k)
      (normalizedTanh_square_lipschitz a s t B hs ht) (abs_nonneg _) hH
  have hp := prodL2_norm_le_add (jointCanonicalObservable e k a s-jointCanonicalObservable e k a t)
  change ‖jointCanonicalObservable e k a s-jointCanonicalObservable e k a t‖ ≤
    ‖(k*normalizedTanh a s) • e-(k*normalizedTanh a t) • e‖+
      |(k*normalizedTanh a s)^2-(k*normalizedTanh a t)^2| at hp
  nlinarith

#print axioms jointCanonicalObservable_bound
#print axioms jointCanonicalObservable_lipschitz
end ConditionalNonpolynomial.Analytic
