import Circuits
import NeuralGeneralization.ModelFacts
import Mathlib.Tactic.FieldSimp

/-!
# The concrete Gaussian NNbayes statement

`ConditionalImpossibility` below defines the exact main statement. Its closed
proof is `conditionalImpossibility` in `ClosedConditionalImpossibility.lean`. Its Gaussian prior, network outputs,
global-margin conditioning, posterior and iid sample probability are the
existing concrete definitions. No abstract learner or posterior ceiling is a
hypothesis of that proposition.

Depth is `L = r + 2`. The central impossibility already uses fixed accuracy
`1/16`, confidence `1/2`, and depths at least three. Consequently it also rules
out a joint polynomial guarantee with variable accuracy and confidence.
-/

noncomputable section

namespace ConditionalNonpolynomial

open NeuralGeneralization.ConcreteModel

/-- A prescribed scale schedule, chosen before the input law and sample.
Its value may depend on input dimension, learner depth and learner width. -/
structure CanonicalSchedule where
  scale : ℕ → ℕ → ℕ → ℝ
  positive : ∀ d L N, 0 < d → 3 ≤ L → 0 < N → 0 < scale d L N
  atMostOne : ∀ d L N, 0 < d → 3 ≤ L → 0 < N → scale d L N ≤ 1

/-- The actual independent Gaussian prior: first-layer variance `t²/d`,
hidden-layer variance `t²/N`, and readout variance `t²/N²`. -/
def canonicalPrior (T : CanonicalSchedule) (d N r : ℕ) :=
  smallPrior d N r (T.scale d (r + 2) N / Real.sqrt N)

/-- Explicit verification of the variances stated in the paper. -/
theorem canonical_variance (T : CanonicalSchedule) {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (i : WeightIndex d N r) :
    smallVariance d N r (T.scale d (r + 2) N / Real.sqrt N) i =
      match i with
      | Sum.inl _ => T.scale d (r + 2) N ^ 2 / d
      | Sum.inr (Sum.inl _) => T.scale d (r + 2) N ^ 2 / N
      | Sum.inr (Sum.inr _) => T.scale d (r + 2) N ^ 2 / (N : ℝ) ^ 2 := by
  have hNr : (0 : ℝ) < N := Nat.cast_pos.mpr hN
  have hdr : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  rcases i with i | (i | i)
  · simp only [smallVariance, div_pow, Real.sq_sqrt hNr.le]
    field_simp
  · simp only [smallVariance, div_pow, Real.sq_sqrt hNr.le]
  · simp only [smallVariance, div_pow, Real.sq_sqrt hNr.le]
    field_simp

/-- The posterior probability that at most `1/16` of test inputs fail the
strict correct-label confidence requirement `> 2/3`, over the actual iid
training sample of size `n`. -/
def successProbability (T : CanonicalSchedule) {d r N n : ℕ}
    (f : BooleanFunction d) (D : InputLaw d) : ℝ :=
  sampleProbability D n (fun s =>
    confidenceFailure D f
      (networkPosterior Real.tanh (1 / 2) (canonicalPrior T d N r) f s) ≤ 1 / 16)

/-- Complementary formulation used in the displayed informal lower bound. -/
theorem successProbability_add_failure (T : CanonicalSchedule) {d r N n : ℕ}
    (f : BooleanFunction d) (D : InputLaw d) :
    successProbability (r := r) (N := N) (n := n) T f D +
      sampleProbability D n (fun s =>
        1 / 16 < confidenceFailure D f
          (networkPosterior Real.tanh (1 / 2) (canonicalPrior T d N r) f s)) = 1 := by
  classical
  refine Eq.trans ?_ (sampleProbability_true D n)
  unfold successProbability sampleProbability
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro s _
  by_cases h : confidenceFailure D f
      (networkPosterior Real.tanh (1 / 2) (canonicalPrior T d N r) f s) ≤ 1 / 16
  · simp only [if_pos h, if_neg (not_lt_of_ge h), if_pos True.intro, add_zero]
  · simp only [if_neg h, if_pos (lt_of_not_ge h), if_pos True.intro, zero_add]

/-- A confidence-success probability below one half is exactly a probability
above one half of the strict failure event stated in the paper. -/
theorem successProbability_lt_half_iff (T : CanonicalSchedule) {d r N n : ℕ}
    (f : BooleanFunction d) (D : InputLaw d) :
    successProbability (r := r) (N := N) (n := n) T f D < 1 / 2 ↔
      1 / 2 < sampleProbability D n (fun s =>
        1 / 16 < confidenceFailure D f
          (networkPosterior Real.tanh (1 / 2) (canonicalPrior T d N r) f s)) := by
  have h := successProbability_add_failure (r := r) (N := N) (n := n) T f D
  constructor <;> intro hh <;> linarith

/-- One polynomial in input dimension, teacher width and depth. Its
coefficient and exponent are independent of depth, width and input law. -/
def sampleEnvelope (A : ℝ) (k d C r : ℕ) : ℝ :=
  A * (1 + (d : ℝ) + (C : ℝ) + ((r + 2 : ℕ) : ℝ)) ^ k

/-- A particular coefficient and degree give a distribution-free guarantee
at every learner width at least the teacher width. -/
def PolynomialGuaranteeAt (T : CanonicalSchedule) (A : ℝ) (k : ℕ) : Prop :=
  ∀ d : ℕ, 1 ≤ d → ∀ r : ℕ, 1 ≤ r →
  ∀ f : BooleanFunction d, ∀ C : ℕ,
    realizesAtComplexity (r := r) Real.tanh f C →
  ∀ N : ℕ, C ≤ N → ∀ D : InputLaw d, ∀ n : ℕ,
    sampleEnvelope A k d C r ≤ (n : ℝ) →
      1 / 2 ≤ successProbability (r := r) (N := N) (n := n) T f D

/-- The polynomial guarantee whose impossibility is the paper's main claim.
The existential coefficient/degree are outside the depth quantifier. -/
def UniversalPolynomialGuarantee (T : CanonicalSchedule) : Prop :=
  ∃ A : ℝ, 0 < A ∧ ∃ k : ℕ, PolynomialGuaranteeAt T A k

/-- A genuine finite-width failure of one proposed polynomial bound. -/
def PolynomialCounterexample (T : CanonicalSchedule) (A : ℝ) (k : ℕ) : Prop :=
  ∃ d : ℕ, 1 ≤ d ∧ ∃ r : ℕ, 1 ≤ r ∧
  ∃ f : BooleanFunction d, ∃ C : ℕ,
    realizesAtComplexity (r := r) Real.tanh f C ∧
  ∃ N : ℕ, C ≤ N ∧ ∃ D : InputLaw d, ∃ n : ℕ,
    sampleEnvelope A k d C r ≤ (n : ℝ) ∧
      successProbability (r := r) (N := N) (n := n) T f D < 1 / 2

/-- Logical expansion of failure: every proposed polynomial has an actual
counterexample at a sample count at least its claimed sufficient threshold.
This theorem is proved; it does not assert the complexity conjecture or the
neural-to-circuit implication, whose proof is assembled separately. -/
theorem not_polynomial_guarantee_iff (T : CanonicalSchedule) :
    ¬ UniversalPolynomialGuarantee T ↔
      ∀ A : ℝ, 0 < A → ∀ k : ℕ, PolynomialCounterexample T A k := by
  classical
  constructor
  · intro h A hA k
    by_contra hno
    apply h
    refine ⟨A, hA, k, ?_⟩
    intro d hd r hr f C hf N hN D n hn
    by_contra hs
    apply hno
    exact ⟨d, hd, r, hr, f, C, hf, N, hN, D, n, hn, lt_of_not_ge hs⟩
  · intro h hyes
    obtain ⟨A, hA, k, hg⟩ := hyes
    obtain ⟨d, hd, r, hr, f, C, hf, N, hN, D, n, hn, hbad⟩ := h A hA k
    exact (not_le_of_gt hbad) (hg d hd r hr f C hf N hN D n hn)

/-- All samples in the formal main statement have a strictly positive
conditioning denominator, using the proved concrete Gaussian/cloning theorem.
Thus its counterexamples concern prediction, not undefined conditioning. -/
theorem canonical_posteriorDenominator_pos (T : CanonicalSchedule)
    {d C N r n : ℕ} (hd : 1 ≤ d) (hr : 1 ≤ r)
    (f : BooleanFunction d)
    (hf : realizesAtComplexity (r := r) Real.tanh f C) (hCN : C ≤ N)
    (s : Fin n → Cube d) :
    0 < posteriorDenominator Real.tanh (1 / 2) (canonicalPrior T d N r) f s := by
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have ht := T.positive d (r + 2) N (by omega) (by omega) hN
  have hNr : (0 : ℝ) < N := Nat.cast_pos.mpr hN
  exact small_posteriorDenominator_pos (by omega) tanh_continuous f hf hCN
    (div_pos ht (Real.sqrt_pos.mpr hNr)) s

/-- Exact concrete statement of the paper. The closed theorem of this type is
`conditionalImpossibility` in `ClosedConditionalImpossibility.lean`; no additional
analytic premise appears in that theorem. -/
def ConditionalImpossibility : Prop :=
  PPoly ≠ TC1 → ∀ T : CanonicalSchedule, ¬ UniversalPolynomialGuarantee T

/-- Equivalent concrete counterexample formulation of the same main statement. -/
def ConditionalCounterexamples : Prop :=
  PPoly ≠ TC1 → ∀ T : CanonicalSchedule,
    ∀ A : ℝ, 0 < A → ∀ k : ℕ, PolynomialCounterexample T A k

/-- The two exact main statements have equivalent quantifiers. -/
theorem conditional_statement_iff :
    ConditionalImpossibility ↔ ConditionalCounterexamples := by
  constructor
  · intro h hsep T
    exact (not_polynomial_guarantee_iff T).mp (h hsep T)
  · intro h hsep T
    exact (not_polynomial_guarantee_iff T).mpr (h hsep T)

#print axioms successProbability_lt_half_iff
#print axioms canonical_variance
#print axioms not_polynomial_guarantee_iff
#print axioms canonical_posteriorDenominator_pos
#print axioms conditional_statement_iff

end ConditionalNonpolynomial
