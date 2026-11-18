# Independent audit: same-width continuous shallow compactification

Reviewed 18 November 2026, source `levy-width-oracle/source/shallow-continuous-grid.tex`, together with `source/shallow-Boolean.tex`, the stable-padding interface, and `relu-threshold/levy-fanin-paper/source/padding.tex`.

No substantive gap found in the statements checked below.

1. **Integer polyhedron.** The minimum-norm feasible point is in the span of active rows because every null direction admits both small feasible perturbations. This remains true with equality constraints, redundant active rows, arbitrary real right-hand sides, and an arbitrarily large finite number of constraints. Independent integer active rows give a positive integer Gram determinant. The stated adjugate bound and coefficient cap `(2PQ)^(2P+2)` are safe.

2. **Grid encoding.** Multiplying constraints at vertices `-1+2j/Q` by `Q` makes every coefficient integral and at most `Q` in absolute value. The output right-hand sides are arbitrary real numbers in `[-Q,Q]`, as allowed by the lemma. Fixing the original closed activation masks gives a feasible system after readout-sign normalization. An active preactivation becoming zero preserves the ReLU value and causes no semantic problem.

3. **Cells and disagreement.** Each of the two shallow networks has at most `(C+1)^d` full-dimensional activation regions. On each, its raw output is affine, so two additional proper hyperplanes suffice to describe clipping changes. Extending these hyperplanes to all of space is harmless and only enlarges the exceptional set. A closed grid cell avoiding their union has both clipped functions affine or constant throughout. Since the two functions agree at every vertex, they agree throughout the cell. Any point in a bad cell is within the cell diameter of a listed hyperplane. Slab anti-concentration and a union bound therefore give the stated disagreement bound. Zero-normal affine functions need no hyperplane, correctly covering degenerate pieces.

4. **Risk and resources.** For bounded outputs and bounded conditional mean, the noise floor cancels and risk difference is at most four times the expected absolute output difference. The chosen deterministic `Q` makes the discrepancy cost `O(1/n)`. Its logarithm is `O(log d + [log(κn)+d log(C+1)]/α)`, and the coefficient cap has logarithm `O(P L_n)`. Substitution into the stable-padding interface gives `O(HP²L_n + HP log(Hn))`, with constants depending only on the fixed scalar prior. The exponential number of grid vertices never enters this entropy bound. This is an existential, sample-independent comparison construction, not an efficient training or compilation claim.

5. **Final tanh.** Compactify the clipped normalized raw teacher at level `M = (1/2) log(16(n+1))`. On a good cell, either the raw values agree, or they lie beyond the same threshold `±M`, where their tanh outputs differ by at most `2e^(-2M)`. The cap grows only by the factor `M`, so the same entropy order applies. The stated risk arithmetic is correct.

6. **Architecture and statistical interface.** One constant hidden neuron implements an affine output bias, accounting for `N≥C+1`; zero output bias permits `N≥C`. ReLU identity padding preserves the target. The separate first-absolute-moment padding argument makes extra depth nearly linear, rather than applying the generic exponentially growing stability bound. The final learner remains the single ordinary posterior using all observations and fixed Gaussian variance `128(1+σ²)`. The approximation may depend on `n` and the deterministic teacher, but not on observed data. Taking an infimum over deterministic teachers in the expected-risk bound is valid.

The conclusion is an expectation oracle. This review does not promote it to a coefficient-one high-probability statement or an efficient algorithm for computing the posterior.

Exact reviewed source SHA-256: `8638b69fd6cb73bb4ed9a27f617dbeb374e5248ea42e0df13bfa08a490678163`.
Reviewer: independent fresh-reader agent; source author was a different agent.
