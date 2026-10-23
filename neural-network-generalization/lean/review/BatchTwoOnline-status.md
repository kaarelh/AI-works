**Current status:** The core statistical theorem and all three boxed neural budgets have closed Lean proofs. See [the coverage table](BatchTwo-coverage.md) for optional extensions outside certification. Earlier development notes below are retained as history; the final exact-endpoint section supersedes their gap lists.

# Online cumulative mistakes: formalization status

This is an interim theorem map, not a claim that every quantitative formula
or extension in the manuscript has been formalized.

## Completed core

`BatchTwoOnlineMain.cumulative_errors_both_protocols` proves the principal
finite-relevant-class theorem with the manuscript's exact constants:

- `expectationBudget m h beta = 1 + 2(h+1) H_(m-1) + m beta`;
- `highProbabilityBudget m h beta delta = (exp(1)-1)
  [1 + 2(h+log(2m/delta)) H_(m-1) + m beta] + log(2/delta)`;
- the actual uniform permutation and infinite uniform IID query laws;
- actual independent draws from the successive consistency posteriors;
- equality of expected actual sampled mistakes and cumulative posterior
  error, and the two separate upper-tail conclusions.

The two protocols are proved separately. The infinite proof uses finite
prefix domination and monotone passage; it does not assume that the order
of first appearances is uniform or assume the claimed equality in law.

`BatchTwoOnlineConfidenceInfinite.iid_confidence_bounds` and
`BatchTwoOnlineConfidence.confidence_bounds_of_randomOrderBounds` prove
the strict confidence convention, including the weak failure inequality,
with factor `1/(1-theta)`. The finite majority-error implication is also
proved, with arbitrary tie behavior satisfying the majority rule.

`BatchTwoOnlinePosterior.totalError_le_neg_log` proves the direct infinite
pathwise prior-mass bound. `BatchTwoOnlineMain.infinite_sampled_prior_tail`
proves the corresponding actual posterior-draw upper tail on a fixed
query stream. The pathwise inequality permits any input sequence; the
sampled-tail formalization here does not separately package query streams
adapted to previous sampled predictions.

## Concrete Gaussian neural endpoints

The following theorems have no capacity, target-mass, or concentration
conclusion as a hypothesis. They derive those facts from the existing
formalized neural-network proofs and use the actual function-mass prior:

| Paper conclusion | Lean theorem |
| --- | --- |
| Strong-prior cumulative learning at every fixed admissible width | `BatchTwoOnlineMain.strongPrior_online_bounds` |
| Every fixed exponent greater than one, every admissible width | `BatchTwoOnlineMain.aboveMeanField_online_bounds` |
| Mean-field tanh, every admissible width | `BatchTwoOnlineMain.meanField_online_bounds` |
| Polynomial overhead, including logarithmic confidence dependence | `BatchTwoOnlinePolynomial.online_budget_polynomial_majorant` |
| Exact posterior identification with the network posterior | `BatchTwoOnlineNetwork.permutationPosterior_eq_networkPosterior`, `BatchTwoOnlinePosterior.onlinePosterior_eq_networkPosterior` |
| Zero-at-zero Lipschitz activations, including ReLU, in the strong-prior regime | `BatchTwoOnline.lipschitz_strongPrior_online_bounds` in `BatchTwoOnlineActivation` |

The strong-prior variance is selected once before the entire run. The
finite-scale theorems use the stated positive-variance priors. The bounds
are independent of learner width; depth is fixed.

**Quantitative matching limitation:** the finite-scale neural endpoints use
the explicit structural polynomial budgets already checked in the main
Lean development. They establish the paper's polynomial all-width
conclusions, but do not yet prove the exact optimized `K,T,h,J` formulas
displayed in its application sections. Those formulas must not be described
as checked merely because the qualitative polynomial conclusion is checked.

## Still outside the completed core

- The unboxed ReLU extension's sharp product-norm constants and finite-scale
  `gamma >= 2` / shallow `gamma >= 1` formulas.
- For the raw-posterior merging extension, the actual independent posterior-draw
  upper-tail theorem is not yet attached. The cumulative posterior-risk
  expectation and upper tails, for both input protocols, are completed below.
- The corresponding merging instantiations for other supported activations
  and arbitrary support constants are not yet attached; the completed literal
  neural endpoint here uses the ReLU merging support of `BatchTwoMergingModel`.
- The optional function-MAP and limiting-posterior remarks.

## Actual merging-restricted posterior extension

The new `BatchTwoOnlineRaw` modules prove the finite-comparison-class
argument for raw posterior mixtures directly. They do not replace the
posterior by a selected minimizer or assume a posterior concentration claim.

- `BatchTwoOnlineMergingProcess.mergingCoverProcess` identifies the literal
  conditioned Gaussian posterior at each history, proves its probability
  normalization and adaptation, and transfers the actual deterministic grid
  cover to its tested-margin error probability.
- `BatchTwoOnlineMergingMain.merging_online_expected_polynomial` proves
  the bound `2 + 2 (10^24 C^2 (5+2d+r)^9 + 1) (1+d)` for a uniform complete
  permutation. It holds at every `N >= C` and every `N sigma^2 <= 1`, with
  either setting of optional initial global-margin conditioning.
- `merging_online_high_probability` proves the exact harmonic exponential
  upper-tail form with this capacity.
- `BatchTwoOnlineMergingIID.merging_iid_expected` and
  `merging_iid_high_probability` prove the same cumulative posterior-risk
  conclusions under the actual infinite uniform IID query law. The
  first-appearance reduction, repeated-query zero risk, and monotone passage
  are proved, including literal posterior identification at every history.

The teacher is the actual layered Boolean NOR circuit, with the same width
and depth convention as the merging paper. Same-depth pruning removes the
unnecessary logarithmic dependence on teacher width. Tested error is the
weak event `f(x) z_w(x) <= 1/4`; training requires strict margin `> 1/2`.
The finite comparison losses used here are Boolean threshold losses at
`11/32`, which satisfy the paper's required domination and consistency
properties; the proof does not need the optional ramp interpolation.

## Exact boxed-budget matching still required

The boxed neural corollaries specify explicit budgets as well as polynomial
existence. The strong-prior formula is now checked exactly; the two finite-scale
formulas still require the remaining bridges:

| Paper item | Exact formula not yet matched |
| --- | --- |
| `cor:strong` | **Completed exactly:** `BatchTwoOnlineSharp.strongPrior_online_paper` in `BatchTwoOnlineSharpMain` |
| `cor:above` | `K=4A+8 log(Lm)`, the explicit maximum defining `T`, `h=F_L(d,(L+3)K)`, `J=A T^gamma/2` |
| `cor:meanfield` | The same `K`, the appendix `T_L(d,K)` and `G_L(d,K)`, `J=A T/2` |

`F_L`, `A_L`, `T_L`, and `G_L` are fixed by manuscript source lines 500–551.
The earlier finite-scale wrappers use larger structural budgets (and, for
the above-mean-field spectral argument, different constants).
It proves the stated qualitative polynomial all-width learning claims but
is insufficient to assert these exact numerical formulas. A full-paper
formalization claim must wait for these gaps to be closed.

## Exact strong-prior budget

`BatchTwoOnlineSharpMain.strongPrior_online_paper` proves the literal boxed
strong-prior result, including `h = F_L(d,B_L(d,C))`, `beta = 2^-d`, a single
sufficiently small positive variance fixed for the entire run, and both uniform
input protocols. `NetworkOnlineBounds` includes actual posterior-draw expectation
and its separate high-probability tail, as well as cumulative posterior risk.

The proof uses the actual network and its global strict-margin event. The new
sharp compression modules establish the appendix retained-row union bound,
sampling error, width, and parameter-rounding count. `BatchTwoOnlineSharpTeacher`
proves the exact cloning budget: only the readout incurs the factor two at a
nonmultiple learner width. The network energy definition includes a factor one
half, which is accounted for explicitly before applying compression.

`normCapacity d r J` is exactly `F_L(d,J)` with `L = r+2`; its radius is written
using `(sqrt (J+1))^(r+1)`, equivalent to the manuscript's half-integer real power.
No attained energy minimizer or unique minimizing sign function is assumed.

## Checks

`lake build NeuralGeneralization.BatchTwoOnlineAudit` passed on 22 October
2026. The audit prints the axiom dependencies of the generic theorem, the
three concrete regime endpoints, the polynomial envelope, the infinite
confidence theorem, and the direct prior-mass statements. Every audited
theorem uses only `propext`, `Classical.choice`, and `Quot.sound`.

`lake build NeuralGeneralization.BatchTwoOnlineSharpAudit` also passed (3403
jobs); its four printed exact-budget dependencies use only the same three
standard axioms.

A clean project rebuild and independent paper/statement review remain
publication requirements. No `sorry`, `admit`, or added axiom is used.

## Final exact neural endpoints

`BatchTwoOnlineSharpNeuralMain` closes `aboveMeanField_online_paper` and `meanField_online_paper`, in addition to the exact strong-prior endpoint. All three boxed budgets are proved, including literal target cost `A_L`, compression `F_L/G_L`, thresholds and small-width paths. `BatchTwoOnlineSharpAudit` now checks ten exact-budget endpoints and dependencies. The general polynomial conclusion is additionally proved by `online_budget_polynomial_majorant`; the exact displayed resource formulas need not be the witness to that separate existential conclusion. Optional unboxed extensions remain limited as recorded in [coverage](BatchTwo-coverage.md).
