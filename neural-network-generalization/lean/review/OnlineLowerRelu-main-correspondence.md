# ReLU main theorem: statement correspondence audit

**Semantic review: PASS (2026-11-08).** The unconditional theorem
[`relu_concrete_main`](../NeuralGeneralization/OnlineLowerReluMain.lean)
proves the full ReLU main theorem in the
[manuscript](../../works-in-progress/online-mistakes/isotropic-relu-allwidth/source/paper.tex),
including the explicit learner-width threshold. It does not merely prove an
abstract posterior implication or assume the main Fourier, geometric, or
energy-gap conclusions.

The review followed the definitions behind
[`ReLUConcreteMainStatement`](../NeuralGeneralization/OnlineLowerReluConcreteStatement.lean)
through the actual network, prior, posterior, teacher, circuit and input-order
interfaces. A second agent independently reviewed the statement and the final
rounding constants, with the same conclusion.

| Manuscript claim | Exact formal counterpart |
| --- | --- |
| Fixed rail length and dimensions | `reluFixedRailSize = 2^1024`; `Family.logicalDim k = 6*k+4`; `Family.pairDim k = 8*k+4`; `reluConcreteDimension k = (8*k+4)*(2*2^1024+4)`. |
| Same-depth bounded teacher | `BoundedTeacher` uses the literal one-hidden-layer network, margin at least one at **every** Boolean input, and every incoming/readout coefficient bounded by its specified width. The width is exactly `3*(m+1)*(d+1)`, with unused neurons allowed. |
| Small Boolean circuit | `HasCircuitAtMost` uses actual fan-in-two NAND circuits. The explicit bound `17*d+5` implies the paper's `O(d)` gate count. |
| Complete nonrepeating sequence | `InputOrder d` is an equivalence from `Fin (card (Cube d))` to the entire Boolean cube. `observedPrefix` contains exactly the earlier inputs, excluding the queried input. |
| Exact mistake count and width threshold | `ReluConcreteProtocol` has `J.card = 2^(k-1)` and quantifies over **every** `N ≥ 2^(m+d+1)`. The threshold is proved large enough for both the teacher and every Fourier orbit used by the wrong completion. |
| Actual Gaussian NNbayes | `posteriorAt` uses independent Gaussian coordinates with incoming variance `N*σ²/d` and readout variance `σ²/N`, including the constant-input weight. The full-cube absolute margin is strictly `>1/2`; earlier Boolean labels are fit by their signs with that margin. This is not Gaussian regression or a distribution postulated directly on hypotheses. |
| Correct-label probability tends to zero | The limit is `σ → 0` through positive values, at each fixed qualifying width. The target, full permutation and designated set are selected **before** quantifying over widths and scales. Every posterior denominator is positive for every positive scale. |
| Three finite-scale prediction conclusions | `ReluConcreteProtocol.finite_scale` supplies one positive scale threshold for the simultaneous sampling, majority and `2/3` statements. Sampling uses the literal normalized finite joint law of fresh posterior draws. It proves probability **greater than** `1−η` of at least `2^(k−1)` designated errors; correct-label probability is strictly below both `1/2` and `2/3` on every designated round. These slightly strengthen the manuscript's non-strict probability lower bound. |
| Exponential square-root interpretation | `relu_square_root_main` proves the polynomial-resource formulation, and `relu_width_square_root_lower_bound` proves the width-rate formulation with arbitrarily large specified bounded teacher widths. `C` denotes a displayed implementing width; neither text nor Lean asserts it is the minimum width. |

There is no width-first limit hidden in these quantifiers, no tie-selection
hypothesis, and no iid sampling assumption. The result concerns cumulative
mistakes on the constructed input order. The source also proves the concrete
physical-code and cost identities needed to connect the analytic construction
to the target and protocol; they are not fields of an assumed certificate at
the final endpoint.

This audit covers the **ReLU main theorem and its stated finite-scale
consequences**. It does not claim formalization of the separate softplus
extension or the ordinary-tanh manuscript.

The canonical dependency build passed, including all 171 new online-lower-bound modules (3296 jobs). [`CheckOnlineLowerRelu.lean`](../CheckOnlineLowerRelu.lean) then passed its exact-type gates and axiom checks. The [recorded output](OnlineLowerRelu-axioms.txt) lists only `propext`, `Classical.choice`, and `Quot.sound` for all six audited endpoints. The separate analytic and tanh-support gates also passed. [Build and source record](OnlineLowerRelu-build.json).

The final manuscript adds only a formal-verification paragraph and link after the audited main theorem. Four Lean module introductions were updated to link the completed endpoint; no proof terms or theorem statements changed in this documentation pass.

Reviewed source SHA-256 values:

- `OnlineLowerReluMain.lean`: `5a97c9311329e3deca0b995351545ea807f4661cd257692d6f20f968d5f0058c`
- `OnlineLowerReluConcreteStatement.lean`: `7ba52485f652190e1b9671aa2944a54121e7195fd4045d3b8f1cc4668a5825e9`
- ReLU manuscript `source/paper.tex`: `d6dc1476f7eb3dad8310fc2ab3a451ae0b7755ffc95b01b077af559ccc2bdfdd`
