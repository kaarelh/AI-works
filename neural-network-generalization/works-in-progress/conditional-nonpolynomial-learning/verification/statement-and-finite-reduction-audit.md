# Independent statement and finite-reduction audit

26 October 2026. This audit compares the concrete Lean definitions with the manuscript and checks the finite statistical reduction. It does **not** certify the analytic Gaussian-posterior circuit ceiling or a closed proof of the main conditional impossibility theorem.

## Concrete main statement

The inspected `NNBayesStatement.lean` snapshot has SHA256 `71cdfc7a13164df1424ea22f6e4dbcd354be47c60be3482e66dda0db0488025b`. Its `ConditionalImpossibility` definition agrees with the main theorem's proposition:

- Input dimension is positive, teacher width is positive, and weighted depth is `L=r+2` with `r>=1`.
- The teacher is an actual tanh network at width `C`, with every coefficient bounded by `C` and strict signed margin greater than `1/2` at every Boolean input. This agrees with the paper's at-most-width convention because zero padding is allowed.
- `CanonicalSchedule` is chosen independently of target sample and input law and has `0<t(d,L,N)<=1`. Substituting `t/sqrt(N)` in the existing concrete Gaussian prior gives variances `t²/d`, `t²/N`, `t²/N²`; `canonical_variance` proves the identity.
- The imported network output includes the constant input coordinate, no separate hidden biases, and a linear readout. Input and label Booleans are identified with signs by the existing `labelReal` definition.
- The posterior uses actual Gaussian sign-function masses, strict global margin, and exact label consistency. Its denominator is proved positive for every sample in the main statement; undefined conditioning is not a source of counterexamples.
- Correct-label probability equal to `2/3` belongs to the confidence-failure set. Success means test failure mass at most `1/16`, with iid sample probability at least `1/2`.
- The polynomial coefficient is an arbitrary positive real `A`, its exponent is a natural `k`, and both are outside the dimension, depth, target, learner-width, input-law, and sample-count quantifiers. Every integer `n>=A(1+d+C+L)^k` is covered.
- The negated guarantee is expanded into a genuine finite-width counterexample. The paper's failure-probability form is the complement of the formal success-probability event on the same normalized finite iid sample space; `successProbability_add_failure` and `successProbability_lt_half_iff` now prove that equivalence explicitly. The final source proves this exact correspondence in `successProbability_add_failure` and `successProbability_lt_half_iff`.

The inspected concrete circuit definitions are in `Circuits.lean`, SHA256 `c28eb88c23b1216798d63349b35768a6144a16d1ac3c68ee199f79ce84f657f3`. `PPoly` uses actual topologically ordered NAND circuits. `TC1` uses actual acyclic threshold/NAND circuits, with size counting gates and input wires and depth bounded by a constant times `Nat.log2(d+2)`. Unrestricted cutoffs do not hide large-weight arithmetic: each threshold only counts its listed Boolean inputs, so cutoffs above the list length are constant false. These are standard-equivalent nonuniform circuit classes, not abstract predicates named after those classes.

`ConditionalImpossibility` is a **definition of a proposition**, not a theorem proving that proposition. The file explicitly says so. Its proved quantifier-expansion theorem must not be presented as a proof of the complexity-theoretic implication.

## Finite probability and boosting

The following four frozen source files were inspected:

| File | SHA256 |
|---|---|
| `FiniteReductionBoosting.lean` | `47c7b89b5bc6de17ed6eee567d8c03dadb532a273b0ab55e5183142a8e306814` |
| `FiniteReductionPosterior.lean` | `68b55011b76f27d3bf0a69002e8fb3bfd6b522c817f55984195eafc2838300bd` |
| `FiniteReductionConverse.lean` | `b2e2326fb332ac28489d0f7cea9661979830494fac089fa16ab5c7a9abe9c700` |
| `FiniteReductionCircuits.lean` | `a7fb7351caa9d1736fc721d51400ea35229f37653204d94336791bd2ee05be0e` |

The numerical transfer is exact: confidence-failure mass at most `1/16` implies average classification error at most `3/8`; mass at least `5/6` on the fixed class then supplies one class member of error at most `9/20`. Normalization and nonnegativity are explicit hypotheses. The finite posterior may depend on the input distribution, but its predictor class and enumeration are fixed before that distribution.

The boosting proof uses the actual update factors `9/10` on correct predictions and `10/9` on wrong predictions. Its total potential contracts by at most `199/200`. With exactly `400(d+1)` voters, the potential is below one on any domain with at most `2^d` points. Every input therefore has a strictly positive signed vote. An odd voter count is unnecessary: the proof excludes ties pointwise.

The normalization lemma handles the zero weighting separately and derives the class's nonemptiness from a normalized distribution. The constructor in `FiniteReductionCircuits.lean` composes actual circuit witnesses in parallel, adds one threshold-majority gate, and proves size at most `m(S+1)+1` and depth at most `D+1`. No circuit is supplied as an unexplained consequence of an abstract voting assumption.

The generic contrapositive is also correctly scoped: if no such exact short majority exists, one input distribution defeats every normalized posterior placing at least `5/6` mass on that same class. Applying it to NNbayes still requires the separate analytic circuit-ceiling theorem.

## Result and boundary

**PASS for statement correspondence and the finite reduction described above.** The code's mathematical premises match the paper's proof, and no mismatch in strict thresholds, quantifier order, or mixture handling was found. The implementation agent reports clean kernel compilation with only Lean's standard axioms; the package build record separately records actual build replay.

This audit does not turn the remaining analytic ceiling into a proved theorem. In particular, a Lean implication with that ceiling explicitly assumed is a valid partial formalization, but is not the requested closed proof from `PPoly != TC1` alone.
