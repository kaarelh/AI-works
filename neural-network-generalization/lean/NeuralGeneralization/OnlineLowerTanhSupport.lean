import NeuralGeneralization.OnlineLowerTanhAlgebra
import Mathlib.Analysis.Real.Sqrt
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity.Basic
import Mathlib.Tactic.GCongr
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.SplitIfs

/-!
# Quantitative support stability for odd-parity tanh atoms

This file proves the real-variable inequalities used in the support-stability
step of the ordinary-tanh online lower bound. The analytic sharp intrinsic
parity theorem is a separate dependency: it is not assumed as an axiom here.
The purely algebraic support estimate uses the harmless constant `288` in
place of the manuscript's `96 * sqrt 6`.
-/

noncomputable section

namespace NeuralGeneralization.OnlineLowerTanh

open scoped BigOperators

/-- The mean of the two square roots arising when an effective bias is
transferred, with either sign, into one selected incoming coefficient. -/
def sqrtPair (x t : ℝ) : ℝ :=
  (Real.sqrt (x + t) + Real.sqrt (x - t)) / 2

/-- Quantitative midpoint concavity of the square root, with denominators
cleared. This includes the boundary cases `x = |t|`. -/
theorem sqrtPair_gap_mul (x t : ℝ) (ht : |t| ≤ x) :
    t ^ 2 ≤ 8 * x * Real.sqrt x * (Real.sqrt x - sqrtPair x t) := by
  have hx : 0 ≤ x := (abs_nonneg t).trans ht
  have hp : 0 ≤ x + t := by have := (abs_le.mp ht).1; linarith
  have hm : 0 ≤ x - t := by have := (abs_le.mp ht).2; linarith
  exact midpoint_gap_mul_of_sq x t (Real.sqrt (x + t)) (Real.sqrt (x - t))
    (Real.sqrt x) hx (Real.sqrt_nonneg _) (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
    (Real.sq_sqrt hp) (Real.sq_sqrt hm) (Real.sq_sqrt hx)

/-- The corresponding ordinary midpoint-concavity inequality. -/
theorem sqrtPair_le (x t : ℝ) (ht : |t| ≤ x) :
    sqrtPair x t ≤ Real.sqrt x := by
  have hx : 0 ≤ x := (abs_nonneg t).trans ht
  by_cases hx0 : x = 0
  · have ht0 : t = 0 := abs_eq_zero.mp (le_antisymm (hx0 ▸ ht) (abs_nonneg t))
    simp [hx0, ht0, sqrtPair]
  · have hxpos : 0 < x := lt_of_le_of_ne hx (Ne.symm hx0)
    have hspos : 0 < Real.sqrt x := Real.sqrt_pos.2 hxpos
    have h := sqrtPair_gap_mul x t ht
    have hfac : 0 < 8 * x * Real.sqrt x := by positivity
    have hg : 0 ≤ Real.sqrt x - sqrtPair x t := by
      by_contra hneg
      have hneg' : Real.sqrt x - sqrtPair x t < 0 := lt_of_not_ge hneg
      have := mul_neg_of_pos_of_neg hfac hneg'
      nlinarith [sq_nonneg t]
    linarith

/-- The geometric constraint on the bias-transfer square roots. -/
theorem biasTransfer_abs_le (U a B : ℝ) (ha : a ^ 2 ≤ U) :
    |2 * a * B| ≤ U + B ^ 2 := by
  apply abs_le.mpr
  constructor <;> nlinarith [sq_nonneg (a + B), sq_nonneg (a - B)]

/-- A useful polynomial form of the pointwise bias-transfer gap on a bounded
second-moment slice. -/
theorem biasTransfer_gap_slice (U a B r : ℝ) (hr : 0 < r)
    (ha : a ^ 2 ≤ U) (hupper : U + B ^ 2 ≤ 6 * r ^ 2) :
    a ^ 2 * B ^ 2 ≤
      36 * r ^ 3 * (Real.sqrt (U + B ^ 2) - sqrtPair (U + B ^ 2) (2 * a * B)) := by
  have hx0 : 0 ≤ U + B ^ 2 := by nlinarith [sq_nonneg a, sq_nonneg B]
  have hroot : Real.sqrt (U + B ^ 2) ≤ 3 * r := by
    have hs := Real.sq_sqrt hx0
    have hn := Real.sqrt_nonneg (U + B ^ 2)
    nlinarith
  have hgap : 0 ≤ Real.sqrt (U + B ^ 2) - sqrtPair (U + B ^ 2) (2 * a * B) :=
    sub_nonneg.mpr (sqrtPair_le _ _ (biasTransfer_abs_le U a B ha))
  have hbase := sqrtPair_gap_mul (U + B ^ 2) (2 * a * B)
    (biasTransfer_abs_le U a B ha)
  have hprod : 8 * (U + B ^ 2) * Real.sqrt (U + B ^ 2) *
      (Real.sqrt (U + B ^ 2) - sqrtPair (U + B ^ 2) (2 * a * B)) ≤
      144 * r ^ 3 * (Real.sqrt (U + B ^ 2) - sqrtPair (U + B ^ 2) (2 * a * B)) := by
    calc
      _ ≤ 8 * (6 * r ^ 2) * (3 * r) *
          (Real.sqrt (U + B ^ 2) - sqrtPair (U + B ^ 2) (2 * a * B)) := by
        gcongr
      _ = _ := by ring
  nlinarith

section FiniteExpectation

variable {ι : Type*} [Fintype ι]

/-- A fourth-moment bound retains at least half of the second moment on the
slice `B² ≤ 6 v`. The weights may be any nonnegative finite measure. -/
theorem fourthMoment_good_mass (p B : ι → ℝ) (v : ℝ)
    (hp : ∀ i, 0 ≤ p i) (hv : 0 < v)
    (hsecond : ∑ i, p i * B i ^ 2 = v)
    (hfourth : ∑ i, p i * B i ^ 4 ≤ 3 * v ^ 2) :
    v ≤ 2 * ∑ i, p i * (if B i ^ 2 ≤ 6 * v then B i ^ 2 else 0) := by
  classical
  have hpoint (i : ι) : 6 * v * (p i * B i ^ 2) ≤
      6 * v * (p i * (if B i ^ 2 ≤ 6 * v then B i ^ 2 else 0)) +
        p i * B i ^ 4 := by
    split_ifs with hi
    · nlinarith [mul_nonneg (hp i) (by positivity : 0 ≤ B i ^ 4)]
    · have htail : 6 * v * B i ^ 2 ≤ B i ^ 4 := by
        have hh := mul_le_mul_of_nonneg_right (lt_of_not_ge hi).le (sq_nonneg (B i))
        nlinarith
      have hh := mul_le_mul_of_nonneg_left htail (hp i)
      nlinarith
  have hsum := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hpoint i)
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum, hsecond] at hsum
  by_contra h
  have hn : 0 < v - 2 * ∑ i, p i *
      (if B i ^ 2 ≤ 6 * v then B i ^ 2 else 0) := by linarith
  have hh := mul_pos hv hn
  nlinarith

/-- Finite weighted Jensen for the square root, proved by expanding the
nonnegative squared deviation from `r`. -/
theorem weighted_sqrt_le (p X : ι → ℝ) (r : ℝ)
    (hp : ∀ i, 0 ≤ p i) (hpsum : ∑ i, p i = 1)
    (hX : ∀ i, 0 ≤ X i) (hr : 0 < r)
    (hsecond : ∑ i, p i * X i = r ^ 2) :
    ∑ i, p i * Real.sqrt (X i) ≤ r := by
  have hpoint (i : ι) : p i * (Real.sqrt (X i) - r) ^ 2 =
      p i * X i - 2 * r * (p i * Real.sqrt (X i)) + r ^ 2 * p i := by
    rw [sub_sq, Real.sq_sqrt (hX i)]
    ring
  have hn : 0 ≤ ∑ i, p i * (Real.sqrt (X i) - r) ^ 2 :=
    Finset.sum_nonneg (fun i _ => mul_nonneg (hp i) (sq_nonneg _))
  simp_rw [hpoint] at hn
  simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib,
    ← Finset.mul_sum, hsecond, hpsum, mul_one] at hn
  by_contra h
  have hh := mul_pos hr (show 0 < (∑ i, p i * Real.sqrt (X i)) - r by linarith)
  nlinarith

/-- Fully finite support Jensen estimate. The hypotheses on `B` are exactly
the second- and fourth-moment facts for an affine Rademacher sum. -/
theorem weighted_biasTransfer_gap (p B : ι → ℝ) (U a v r : ℝ)
    (hp : ∀ i, 0 ≤ p i) (hpsum : ∑ i, p i = 1)
    (ha : a ^ 2 ≤ U) (hv : 0 < v) (hr : 0 < r)
    (hsecond : ∑ i, p i * B i ^ 2 = v)
    (hfourth : ∑ i, p i * B i ^ 4 ≤ 3 * v ^ 2)
    (hrsq : r ^ 2 = U + v) :
    a ^ 2 * v ≤ 72 * r ^ 3 *
      (r - ∑ i, p i * sqrtPair (U + B i ^ 2) (2 * a * B i)) := by
  classical
  have hU : 0 ≤ U := (sq_nonneg a).trans ha
  have hX (i : ι) : 0 ≤ U + B i ^ 2 := add_nonneg hU (sq_nonneg _)
  have hmean : ∑ i, p i * (U + B i ^ 2) = r ^ 2 := by
    simp only [mul_add, Finset.sum_add_distrib, ← Finset.sum_mul, hpsum,
      one_mul, hsecond, hrsq]
  have hjensen := weighted_sqrt_le p (fun i => U + B i ^ 2) r
    hp hpsum hX hr hmean
  have hgood := fourthMoment_good_mass p B v hp hv hsecond hfourth
  have hpoint (i : ι) : a ^ 2 *
      (p i * (if B i ^ 2 ≤ 6 * v then B i ^ 2 else 0)) ≤
      36 * r ^ 3 * (p i * (Real.sqrt (U + B i ^ 2) -
        sqrtPair (U + B i ^ 2) (2 * a * B i))) := by
    have hg : 0 ≤ Real.sqrt (U + B i ^ 2) -
        sqrtPair (U + B i ^ 2) (2 * a * B i) :=
      sub_nonneg.mpr (sqrtPair_le _ _ (biasTransfer_abs_le U a (B i) ha))
    split_ifs with hi
    · have hu : U + B i ^ 2 ≤ 6 * r ^ 2 := by nlinarith
      have hh := mul_le_mul_of_nonneg_left
        (biasTransfer_gap_slice U a (B i) r hr ha hu) (hp i)
      nlinarith
    · simp only [mul_zero]
      exact mul_nonneg (by positivity) (mul_nonneg (hp i) hg)
  have hsum := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hpoint i)
  simp only [← Finset.mul_sum, mul_sub, Finset.sum_sub_distrib] at hsum
  have hgood' := mul_le_mul_of_nonneg_left hgood (sq_nonneg a)
  have hfactor : 0 ≤ 36 * r ^ 3 := by positivity
  have hupper := mul_le_mul_of_nonneg_left hjensen hfactor
  nlinarith

/-- The algebraic final step: a midpoint gap and the one-coordinate Lipschitz
bound control all squared energy outside the selected parity support. -/
theorem support_of_midpoint_gap (r v a w q : ℝ) (hr : 0 < r)
    (hv : 0 ≤ v) (hvupper : v ≤ r ^ 2) (hw : 0 ≤ w)
    (hq : q ≤ r) (hcoordinate : q ≤ w * |a|)
    (hgap : a ^ 2 * v ≤ 72 * r ^ 3 * (r - q)) :
    v ≤ max 2 (288 * w ^ 2) * r * (r - q) := by
  have hdelta : 0 ≤ r - q := sub_nonneg.mpr hq
  by_cases hsmall : q < r / 2
  · have hsimple : v ≤ 2 * r * (r - q) := by
      have hh := mul_nonneg (le_of_lt hr) (show 0 ≤ r - 2 * q by linarith)
      nlinarith
    calc
      v ≤ 2 * r * (r - q) := hsimple
      _ ≤ max 2 (288 * w ^ 2) * r * (r - q) := by gcongr; exact le_max_left _ _
  · have hsize : r ^ 2 ≤ 4 * w ^ 2 * a ^ 2 := by
      have hlin : r ≤ 2 * w * |a| := by linarith
      have hnonneg : 0 ≤ 2 * w * |a| := by positivity
      have hsquare := mul_self_le_mul_self (le_of_lt hr) hlin
      have he : (2 * w * |a|) * (2 * w * |a|) = 4 * w ^ 2 * a ^ 2 := by
        rw [← pow_two, mul_pow, mul_pow, sq_abs]
        ring
      rw [he] at hsquare
      nlinarith
    have hmul : r ^ 2 * v ≤ r ^ 2 * (288 * w ^ 2 * r * (r - q)) := by
      calc
        r ^ 2 * v ≤ (4 * w ^ 2 * a ^ 2) * v :=
          mul_le_mul_of_nonneg_right hsize hv
        _ = 4 * w ^ 2 * (a ^ 2 * v) := by ring
        _ ≤ 4 * w ^ 2 * (72 * r ^ 3 * (r - q)) := by
          exact mul_le_mul_of_nonneg_left hgap (by positivity)
        _ = _ := by ring
    have hstrong : v ≤ 288 * w ^ 2 * r * (r - q) :=
      (mul_le_mul_iff_right₀ (sq_pos_of_pos hr)).mp hmul
    calc
      v ≤ 288 * w ^ 2 * r * (r - q) := hstrong
      _ ≤ max 2 (288 * w ^ 2) * r * (r - q) := by gcongr; exact le_max_right _ _

/-- Finite-expectation support stability. In the tanh application `q` is the
sharp intrinsic weight times the absolute selected parity correlation;
`htransfer` comes from the exact odd-parity bias-transfer identity and the
intrinsic sharp inequality. The analytic intrinsic theorem is intentionally
an explicit, separately named dependency rather than an added axiom. -/
theorem finite_support_stability (p B : ι → ℝ) (U a v r w q : ℝ)
    (hp : ∀ i, 0 ≤ p i) (hpsum : ∑ i, p i = 1)
    (ha : a ^ 2 ≤ U) (hr : 0 < r) (hw : 0 ≤ w)
    (hsecond : ∑ i, p i * B i ^ 2 = v)
    (hfourth : ∑ i, p i * B i ^ 4 ≤ 3 * v ^ 2)
    (hrsq : r ^ 2 = U + v)
    (htransfer : q ≤ ∑ i, p i * sqrtPair (U + B i ^ 2) (2 * a * B i))
    (hcoordinate : q ≤ w * |a|) :
    v ≤ max 2 (288 * w ^ 2) * r * (r - q) := by
  have hU : 0 ≤ U := (sq_nonneg a).trans ha
  have hv : 0 ≤ v := by
    rw [← hsecond]
    exact Finset.sum_nonneg (fun i _ => mul_nonneg (hp i) (sq_nonneg _))
  have hX (i : ι) : 0 ≤ U + B i ^ 2 := add_nonneg hU (sq_nonneg _)
  have hmean : ∑ i, p i * (U + B i ^ 2) = r ^ 2 := by
    simp only [mul_add, Finset.sum_add_distrib, ← Finset.sum_mul, hpsum,
      one_mul, hsecond, hrsq]
  have hjensen := weighted_sqrt_le p (fun i => U + B i ^ 2) r hp hpsum hX hr hmean
  have hpair : (∑ i, p i * sqrtPair (U + B i ^ 2) (2 * a * B i)) ≤
      ∑ i, p i * Real.sqrt (U + B i ^ 2) := by
    apply Finset.sum_le_sum
    intro i _
    exact mul_le_mul_of_nonneg_left
      (sqrtPair_le _ _ (biasTransfer_abs_le U a (B i) ha)) (hp i)
  have hq : q ≤ r := htransfer.trans (hpair.trans hjensen)
  apply support_of_midpoint_gap r v a w q hr hv (by linarith) hw hq hcoordinate
  by_cases hv0 : v = 0
  · rw [hv0, mul_zero]
    positivity
  · have hvpos : 0 < v := lt_of_le_of_ne hv (Ne.symm hv0)
    have hgap := weighted_biasTransfer_gap p B U a v r
      hp hpsum ha hvpos hr hsecond hfourth hrsq
    have hbound := mul_le_mul_of_nonneg_left htransfer (show 0 ≤ 72 * r ^ 3 by positivity)
    linarith

end FiniteExpectation

end NeuralGeneralization.OnlineLowerTanh
