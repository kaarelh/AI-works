import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Field
import Mathlib.Algebra.Order.BigOperators.Ring.Finset
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum

/-!
# Finite geometry used by the neural online lower bounds

These are the finite inequalities used in the ReLU/softplus and tanh
calibration proofs.  They do not assume a neural atomic inequality, a
particular affine coset, or a posterior theorem.  The concrete rail-code
and neural analytic hypotheses must be proved separately before these
lemmas imply a neural online lower bound.

The existing cube and Fourier model is reused; no Bayesian model is
introduced in this module.
-/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

variable {ι : Type*} [Fintype ι]

/-- Weighted coefficient `ℓ¹` cost. -/
def weightedL1 (w a : ι → ℝ) : ℝ := ∑ i, w i * |a i|

theorem weightedL1_nonneg (w a : ι → ℝ) (hw : ∀ i, 0 ≤ w i) :
    0 ≤ weightedL1 w a := by
  exact Finset.sum_nonneg fun i _ => mul_nonneg (hw i) (abs_nonneg _)

/-- Feasibility of a coefficientwise dual gives its lower bound on the
whole weighted Fourier cost. -/
theorem dual_pairing_le_weightedL1 (w a dual : ι → ℝ)
    (hdual : ∀ i, |dual i| ≤ w i) :
    (∑ i, dual i * a i) ≤ weightedL1 w a := by
  apply Finset.sum_le_sum
  intro i _
  calc
    dual i * a i ≤ |dual i * a i| := le_abs_self _
    _ = |dual i| * |a i| := abs_mul _ _
    _ ≤ w i * |a i| := mul_le_mul_of_nonneg_right (hdual i) (abs_nonneg _)

/-- The exact slack in an unsaturated coefficient controls its magnitude. -/
theorem coefficient_slack (w a dual s : ℝ) (h : s ≤ w - |dual|) :
    s * |a| ≤ w * |a| - dual * a := by
  have h₁ : dual * a ≤ |dual| * |a| := by
    simpa only [abs_mul] using le_abs_self (dual * a)
  have h₂ := mul_le_mul_of_nonneg_right h (abs_nonneg a)
  nlinarith

theorem coefficient_defect_nonneg (w a dual : ℝ) (h : |dual| ≤ w) :
    0 ≤ w * |a| - dual * a := by
  have := coefficient_slack w a dual 0 (by linarith)
  simpa using this

/-- Each selected coefficient slack is bounded by the total dual defect. -/
theorem coefficient_slack_le_total (w a dual : ι → ℝ)
    (hdual : ∀ i, |dual i| ≤ w i) (i : ι) (s : ℝ)
    (hs : s ≤ w i - |dual i|) :
    s * |a i| ≤ weightedL1 w a - ∑ j, dual j * a j := by
  classical
  have hterm := coefficient_slack (w i) (a i) (dual i) s hs
  have hsum : w i * |a i| - dual i * a i ≤
      ∑ j, (w j * |a j| - dual j * a j) := by
    exact Finset.single_le_sum
      (fun j _ => coefficient_defect_nonneg (w j) (a j) (dual j) (hdual j))
      (Finset.mem_univ i)
  simpa only [Finset.sum_sub_distrib, weightedL1] using hterm.trans hsum

/-- A translation-invariant nonnegative energy has at most half its mass
on a set containing no pair of translated points.  In applications `e`
is translation by one nonzero physical code column. -/
theorem independent_set_mass_le_complement
    (e : ι ≃ ι) (J : Set ι) (q : ι → ℝ)
    (hq : ∀ x, 0 ≤ q x) (hinv : ∀ x, q (e x) = q x)
    (hind : ∀ x, x ∈ J → e x ∉ J) :
    (∑ x, if x ∈ J then q x else 0) ≤
      ∑ x, if x ∉ J then q x else 0 := by
  classical
  have hchange : (∑ x, if e x ∈ J then q x else 0) =
      ∑ x, if x ∈ J then q x else 0 := by
    simpa only [hinv] using e.sum_comp (fun x => if x ∈ J then q x else 0)
  rw [← hchange]
  apply Finset.sum_le_sum
  intro x _
  by_cases hx : x ∈ J
  · simp only [if_neg (hind x hx), if_neg (not_not.mpr hx)]
    exact le_rfl
  · by_cases he : e x ∈ J
    · simp [hx, he]
    · simpa [hx, he] using hq x

/-- The factor-two observability estimate, before inserting the physical
first-defective-rail decomposition. -/
theorem independent_set_observability
    (e : ι ≃ ι) (J : Set ι) (q : ι → ℝ)
    (hq : ∀ x, 0 ≤ q x) (hinv : ∀ x, q (e x) = q x)
    (hind : ∀ x, x ∈ J → e x ∉ J) :
    (∑ x, q x) ≤ 2 * ∑ x, if x ∉ J then q x else 0 := by
  classical
  have hmass := independent_set_mass_le_complement e J q hq hinv hind
  have hsplit : (∑ x, q x) =
      (∑ x, if x ∈ J then q x else 0) +
        ∑ x, if x ∉ J then q x else 0 := by
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro x _
    by_cases hx : x ∈ J <;> simp [hx]
  linarith

/-- Summing independent-set observability over conditionally orthogonal
first-defect components.  The invariance premises are local statements
about the component energies, rather than the desired total inequality. -/
theorem component_observability {κ : Type*} [Fintype κ]
    (e : κ → ι ≃ ι) (J : Set ι) (q : κ → ι → ℝ)
    (hq : ∀ i x, 0 ≤ q i x)
    (hinv : ∀ i x, q i (e i x) = q i x)
    (hind : ∀ i x, x ∈ J → e i x ∉ J) :
    (∑ i, ∑ x, q i x) ≤
      2 * ∑ i, ∑ x, if x ∉ J then q i x else 0 := by
  have h := Finset.sum_le_sum fun i (_ : i ∈ Finset.univ) =>
    independent_set_observability (e i) J (q i) (hq i) (hinv i) (hind i)
  simpa only [← Finset.mul_sum] using h

/-- A closed absolute half-margin supplies the elementary second-moment
inequality used to round a fractional logical score. -/
theorem half_margin_square (y : ℝ) (hy : (1 : ℝ) / 2 ≤ |y|) :
    (1 : ℝ) / 4 ≤ y ^ 2 := by
  nlinarith [sq_abs y]

/-- The exact scalar variance identity underlying `p(1-p)` rounding. -/
theorem fractional_variance_identity (p y : ℝ) :
    (y - (p - 1 / 2)) ^ 2 - p * (1 - p) =
      (y ^ 2 - 1 / 4) - 2 * (p - 1 / 2) * (y - (p - 1 / 2)) := by
  ring

/-- Averaging a half-margin variable with mean `p - 1/2` forces the
fractional variance cost `p(1-p)`. -/
theorem fractional_variance_bound (μ y : ι → ℝ) (p : ℝ)
    (hμ : ∀ i, 0 ≤ μ i) (hsum : ∑ i, μ i = 1)
    (hmean : ∑ i, μ i * y i = p - 1 / 2)
    (hy : ∀ i, (1 : ℝ) / 2 ≤ |y i|) :
    p * (1 - p) ≤ ∑ i, μ i * (y i - (p - 1 / 2)) ^ 2 := by
  have hsquare : (1 : ℝ) / 4 ≤ ∑ i, μ i * y i ^ 2 := by
    have h := Finset.sum_le_sum fun i (_ : i ∈ Finset.univ) =>
      mul_le_mul_of_nonneg_left (half_margin_square (y i) (hy i)) (hμ i)
    simpa only [← Finset.sum_mul, hsum, one_mul] using h
  have hexpand : (∑ i, μ i * (y i - (p - 1 / 2)) ^ 2) =
      (∑ i, μ i * y i ^ 2) - (p - 1 / 2) ^ 2 := by
    calc
      (∑ i, μ i * (y i - (p - 1 / 2)) ^ 2) =
          ∑ i, (μ i * y i ^ 2 - 2 * (p - 1 / 2) * (μ i * y i) +
            (p - 1 / 2) ^ 2 * μ i) := by
        apply Finset.sum_congr rfl
        intro i _
        ring
      _ = _ := by
        rw [Finset.sum_add_distrib, Finset.sum_sub_distrib,
          ← Finset.mul_sum, ← Finset.mul_sum, hmean, hsum]
        ring
  rw [hexpand]
  nlinarith

/-- On an observed fiber a signed margin variable lies above its margin.
Its mean excess controls its absolute deviation with the exact factor two. -/
theorem mean_absolute_deviation_of_lower (μ y : ι → ℝ) (a m : ℝ)
    (hμ : ∀ i, 0 ≤ μ i) (hsum : ∑ i, μ i = 1)
    (hmean : ∑ i, μ i * y i = m) (hy : ∀ i, a ≤ y i) :
    (∑ i, μ i * |y i - m|) ≤ 2 * (m - a) := by
  have ham : a ≤ m := by
    have h := Finset.sum_le_sum fun i (_ : i ∈ Finset.univ) =>
      mul_le_mul_of_nonneg_left (hy i) (hμ i)
    simpa only [← Finset.sum_mul, hsum, one_mul, hmean] using h
  have hpoint (i : ι) : |y i - m| ≤ y i + m - 2 * a := by
    apply abs_le.mpr
    constructor <;> linarith [hy i]
  have h := Finset.sum_le_sum fun i (_ : i ∈ Finset.univ) =>
    mul_le_mul_of_nonneg_left (hpoint i) (hμ i)
  have hexpand : (∑ i, μ i * (y i + m - 2 * a)) = 2 * (m - a) := by
    simp only [mul_sub, mul_add, Finset.sum_sub_distrib, Finset.sum_add_distrib,
      ← Finset.sum_mul, hsum, hmean, one_mul]
    ring
  rw [hexpand] at h
  exact h

theorem bounded_square_le_absolute (μ r : ι → ℝ) (B : ℝ)
    (hμ : ∀ i, 0 ≤ μ i) (hr : ∀ i, |r i| ≤ B) :
    (∑ i, μ i * r i ^ 2) ≤ B * ∑ i, μ i * |r i| := by
  have hpoint (i : ι) : r i ^ 2 ≤ B * |r i| := by
    have h := mul_le_mul_of_nonneg_right (hr i) (abs_nonneg (r i))
    simpa only [← pow_two, sq_abs] using h
  have h := Finset.sum_le_sum fun i (_ : i ∈ Finset.univ) =>
    mul_le_mul_of_nonneg_left (hpoint i) (hμ i)
  calc
    (∑ i, μ i * r i ^ 2) ≤ ∑ i, μ i * (B * |r i|) := h
    _ = B * ∑ i, μ i * |r i| := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      ring

/-- The exact factor-five physical variance calculation.  The orthogonal
residual split and independent-set observability are supplied separately;
the conclusion is proved from their finite sums. -/
theorem orthogonal_observability_variance_bound
    (μ R A E : ι → ℝ) (O : Set ι)
    (hμ : ∀ i, 0 ≤ μ i) (hsplit : ∀ i, R i = A i + E i)
    (horth : ∑ i, μ i * (A i * E i) = 0)
    (hobs : (∑ i, μ i * A i ^ 2) ≤
      2 * ∑ i, if i ∈ O then μ i * A i ^ 2 else 0) :
    (∑ i, μ i * R i ^ 2) ≤
      4 * (∑ i, if i ∈ O then μ i * R i ^ 2 else 0) +
        5 * ∑ i, μ i * E i ^ 2 := by
  have hpoint (i : ι) :
      (if i ∈ O then μ i * A i ^ 2 else 0) ≤
        2 * (if i ∈ O then μ i * R i ^ 2 else 0) + 2 * μ i * E i ^ 2 := by
    by_cases hi : i ∈ O
    · simp only [if_pos hi]
      have hsquare : A i ^ 2 ≤ 2 * R i ^ 2 + 2 * E i ^ 2 := by
        rw [hsplit i]
        nlinarith [sq_nonneg (A i + 2 * E i)]
      have h := mul_le_mul_of_nonneg_left hsquare (hμ i)
      nlinarith
    · simp only [if_neg hi, mul_zero, zero_add]
      exact mul_nonneg (mul_nonneg (by norm_num) (hμ i)) (sq_nonneg _)
  have hsum := Finset.sum_le_sum fun i (_ : i ∈ Finset.univ) => hpoint i
  simp only [Finset.sum_add_distrib, mul_assoc, ← Finset.mul_sum] at hsum
  have hpythagoras : (∑ i, μ i * R i ^ 2) =
      (∑ i, μ i * A i ^ 2) + ∑ i, μ i * E i ^ 2 := by
    calc
      (∑ i, μ i * R i ^ 2) =
          ∑ i, (μ i * A i ^ 2 + μ i * E i ^ 2 + 2 * (μ i * (A i * E i))) := by
        apply Finset.sum_congr rfl
        intro i _
        rw [hsplit i]
        ring
      _ = _ := by
        rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, horth]
        ring
  rw [hpythagoras]
  nlinarith

/-- The absorption step shared by both activations.  Its premises are
the exact calibrated decomposition and the separately proved rounding
estimate; it makes no assertion that a neural model satisfies them. -/
theorem cost_absorption (B C D S W K : ℝ)
    (hdecomp : C + D + S - W * (K * (D + S)) ≤ B) :
    C + (1 - W * K) * (D + S) ≤ B := by
  nlinarith [hdecomp]

theorem cost_absorption_equality (B C D S W K : ℝ)
    (hD : 0 ≤ D) (hS : 0 ≤ S) (hsmall : W * K < 1)
    (hlower : C + (1 - W * K) * (D + S) ≤ B)
    (heq : B = C) : D = 0 ∧ S = 0 := by
  have hpos : 0 < 1 - W * K := by linarith
  have hsum : D + S = 0 := by
    have hprod : (1 - W * K) * (D + S) ≤ 0 := by linarith
    have : D + S ≤ 0 := by
      by_contra h
      exact (not_lt_of_ge hprod) (mul_pos hpos (lt_of_not_ge h))
    linarith
  constructor <;> linarith

end NeuralGeneralization.OnlineLowerGeometry
