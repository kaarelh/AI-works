# Concrete statement and conditional-proof audit

26 October 2026. AI-agent review of the final paper statement and its Lean
counterpart. The inspected source hashes are in
[lean-statement-audit-sha256.json](lean-statement-audit-sha256.json).

**Result: the concrete main statement is faithfully encoded. The complete main
theorem does not yet have a closed Lean proof.** The checked family reduction
retains exactly one explicit analytic premise. The paper's verification-scope
paragraph correctly reports this boundary.

## Main statement

The paper's `PolyLearn(t)` matches `UniversalPolynomialGuarantee T`:

| Paper convention | Concrete Lean counterpart |
|---|---|
| Dimension `d≥1`, depth `L≥3` | `d≥1`, internal-layer count `r≥1`, `L=r+2` |
| Teacher width at most `C`, weights bounded by `C` | `realizesAtComplexity Real.tanh f C`; exact width `C` is equivalent by zero padding |
| Strict teacher signed margin above `1/2` on the whole Boolean cube | The actual `marginEvent`, quantified over every `Cube d` input |
| Independent Gaussian variances `t²/d`, `t²/N`, `t²/N²` | `canonicalPrior` built from the actual `smallPrior`; `canonical_variance` proves these variances |
| Prior restricted to global absolute margin, then exact noiseless labels | Existing actual Gaussian function masses and `networkPosterior`, with normalization |
| Correct-label posterior probability must exceed `2/3` | `confidenceFailure` includes equality at `2/3` |
| Test confidence-failure mass at most `1/16` | The event in `successProbability` |
| Probability at least `1/2` over iid training samples | Existing concrete finite-product `sampleProbability` |
| One polynomial in dimension, teacher width and depth | `∃ A>0, ∃ k`, before every depth and resource quantifier |
| Every integer sample count above `A(1+d+C+L)^k` | The final universal sample-count quantifier in `PolynomialGuaranteeAt` |
| Every learner width at least `C`, and every common input law | `∀ N, C≤N → ∀ D : InputLaw d` |

`CanonicalSchedule` is fixed before target samples and input laws. It may depend
on dimension, depth and learner width. Its positivity and upper-bound fields
are required only on the eligible positive-index domain. That is equivalent to
the paper's convention: values outside the domain can be assigned arbitrarily,
for example one, and are never used by the theorem.

`canonical_posteriorDenominator_pos` proves strict positivity of every eligible
conditioning denominator from the actual Gaussian and cloning results. A
formal counterexample therefore cannot arise solely because conditioning was
undefined. `not_polynomial_guarantee_iff` proves the full quantifier negation.
The paper displays a failure event of probability strictly greater than one
half; the Lean counterexample uses success probability strictly below one
half. Their exact equivalence is proved by
`successProbability_add_failure` and `successProbability_lt_half_iff`, on the
same normalized iid sample space.

The concrete class definitions have the intended meaning. `PPoly` uses actual
finite NAND circuits. `TC1` uses actual acyclic NAND and unweighted-threshold
circuits, with polynomial gate-plus-wire size and logarithmic depth. Input
lists can repeat wires, and thresholds above their length are simply false.
`ThresholdToBoolean.lean` proves an actual NAND simulation with size at most
`7*(thresholdSize+1)^2`, so `TC1_subset_PPoly` is proved, not assumed. The reverse
inclusion in the collapse conclusion is therefore not a hidden complexity
premise.

## What the closed family proof establishes

The actual type of the assembled result is

```lean
conditionalImpossibility_of_posteriorCeiling
  (hceiling : AnalyticPosteriorCeiling) : ConditionalImpossibility
```

`ConditionalImpossibility` itself is the exact concrete proposition

```lean
PPoly ≠ TC1 → ∀ T : CanonicalSchedule, ¬ UniversalPolynomialGuarantee T
```

Both named propositions are definitions, not axioms. The second displayed
proposition has no closed proof from the complexity assumption alone in this
package. Defining it and proving a theorem *with the first proposition as an
additional premise* must not be described as completing the original requested
formal proof.

Every other step in the family implication is now discharged:

- `TeacherCompilation` constructs actual tanh weights and proves their margin
  and magnitude bounds. `TeacherFamilies` supplies polynomial resources and
  learner depth at least the input dimension.
- The real sample coefficient is bounded by an integer `A0`; the proof chooses
  the integer sample count `A0*(1+d+C+L)^k`. `FamilyResources` proves the
  resulting polynomial resource bound and an explicit eventual logarithmic
  padding inequality, without an asymptotic-growth hypothesis.
- The learner width is selected as the maximum of teacher width and the
  ceiling's width threshold. This is before the input law is chosen. The
  prescribed scale schedule is evaluated at that same width, with no circular
  dependence on an input distribution.
- `PosteriorBridge` uses actual Gaussian posterior normalization and
  nonnegativity. Confidence success implies a weak predictor in the common
  circuit class, assuming its separately stated posterior mass ceiling.
- The finite reduction uses deterministic multiplicative-weight boosting;
  it does **not** assume or invoke a minimax theorem. It produces exactly
  `400*(d+1)` voters with strictly positive signed vote at every input.
- `CircuitOperations` and `FiniteReductionCircuits` compose the actual voter
  circuits and add one actual threshold gate. `CircuitFamilies` handles
  finitely many exceptional input dimensions by embedding the already given
  NAND circuits and increasing uniform constants.
- `FamilyCollapse` combines these results and takes the contrapositive. No
  learner efficiency, effective family generation, single-predictor posterior
  concentration, or uniform-input-law assumption is introduced.

## The extra analytic premise

`AnalyticPosteriorCeiling` is a specific assertion about the same actual
Gaussian neural posterior. It is not a generic learner substituted for that
posterior. It demands posterior mass at least `5/6` on actual threshold
circuits of size at most `R^K` and depth at most `K*Nat.log2 R`, where
`R=d+n+L+2`. The common class is independent of sample, width, and scale.

The premise is a sufficient integer-budget specialization of the conventional
uniform-ceiling theorem used by the paper:

- It fixes the exceptional posterior mass to `1/6` and uses exactly `n`
  observations. The source theorem also covers every consistent sample of at
  most `n` points, which is stronger.
- It assumes an admissible teacher at width at most the learner width. This
  ensures the posterior is defined; the conventional ceiling applies more
  broadly to consistent samples.
- For `R≥2`, natural logarithms and `Nat.log2 R` differ by fixed multiplicative
  factors after allowing for the floor. Increasing universal integer padding
  and circuit constants gives the stated inequalities. This is only a
  numerical convention change, not a proof of the analytic ceiling.
- Choosing the integer width constant above the source's real constant makes
  `2^(W*d)*R^W + 2*W*(L-1)` dominate its width requirement at `β=1/6`, since
  `log 6<2`. Larger fixed circuit exponents also absorb gate-to-wire size
  conventions and fixed multiplicative factors.

What remains unformalized is precisely the analytical proof that this premise
holds: the finite-width posterior circuit ceiling, including its rate/entropy
extraction, target-mass inputs, canonical-feature parallelization and numerical
circuit evaluation. The older ten analytic prefix modules prove useful
geometric components, but they do not discharge this premise.

The package's fresh build record is the authoritative kernel-replay record.
This statement audit checks correspondence and the explicit assumption
boundary; it does not assert that a build with standard axioms can remove an
ordinary theorem hypothesis.
