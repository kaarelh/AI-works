# Integration review: finite-width critical learning

The main result of this revision is an every-realizable-width posterior learning bound for the original critical Gaussian prior. It retains global output margins and exact noiseless training fit. Independent mathematical AI-agent audits are included alongside this record; no new Lean verification is claimed.

The review checked the following points separately:

- Forward conditioning preserves hidden-row exchangeability for each relevant function event. The entropy-decrement argument approximates moments without claiming an absolutely continuous exact empirical law.
- The projected actual readout has Gaussian rank at most the witness size. Its entropy bound therefore works for arbitrary function events and loses only an additive action tolerance, rather than a fixed scalar-baseline cost.
- Witness compression has architecture width independent of the witness cardinality. Local representability on every witness set gives a genuine collective exceptional-prior-mass bound, not a union over all truth tables.
- The scalar-channel construction has one causal joint law on actual weights. Bounded auxiliary scores, exact empirical projection, and Gaussian conditional decompositions justify the finite-width concentration and entropy accounting.
- The component/residual metric propagates with a factor bounded by the exponential of square-root entropy. No simultaneous coupling of all query residuals is assumed.
- The final target event has probability close to one under the controlled law. Binary relative entropy then gives the stated raw Gaussian target-probability lower bound.
- The deterministic circuit groups reset gate errors by saturation. Their actual weight shifts have the charged Gaussian entropy; no changes to the prior or free conditioning on tags are used.
- Quantified large-width target mass and the intrinsic learning theorem cover large widths. Ordinary tanh VC bounds cover every smaller realizable width. No target-mass estimate is assumed at those smaller widths.
- The arithmetic compiler removes real threshold-weight magnitudes only for Boolean gates. The separate bounded-weight tanh-teacher compiler retains its stated parameter assumptions.
- The confidence conclusion uses correct-label probability strictly greater than 2/3, so ties at 2/3 are included in the error event.

The following proof sources were copied unchanged from their independently reviewed versions:

- `critical-approximate-entropy-budget.tex`: `49f89f7ff4e1c0622bbb5dfa4ec135f2f93e2f73247ee376e2f64148bbf7e413`
- `critical-finite-width-certificate.tex`: `6d7f660e55bf4619224f6e9ddb2e3d312b8d60df57bbfca2fb64f9ac040b48e6`
- `critical-finite-width-channel.tex`: `6a45c4abf1df7a1e503d5dd5d7449ee4c4822ca86df16574eff6f007abe68dde`
- `critical-finite-width-circuit-prefix.tex`: `4de365738a40063f994336c130d703533ba6c43429cd0c91af4c9486ef21a628`
- `critical-finite-width-circuit-mass.tex`: `7eda110d5ba2210bd1a966a87591941173369a50f4de0d5f0609cad3fa0f8553`
- `critical-weight-independent-threshold-compiler.tex`: `86a22f3164adabfc04a72abdb4f5fe79a1e9b2a5eeb284c5320cde40f8749632`
- `critical-all-width-target-learning.tex`: `12189cd5401374d9bb6749e9b502fb7c663a99b28fd7853b318b2f0eb967fef3`
- `critical-sequential-program-learning.tex`: `e552d1a1d3c692238eeeab6b74a008bcca896bb0c1792793eedf7bba6bb902ac`
- `critical-low-rank-bottleneck.tex`: `b8655c9bd07b84229e6af0ffafdecb6bc986de39d387d5bdaf33478f44145042`
- `critical-optimized-circuit-blocking.tex`: `0c83d78ae1f387e590de0e7f4eaf8a4253209b234b376e534a30f0fe76dbe255`

The final paragraph of `critical-finite-width-learning.tex` was edited only to point to the subsequent quantitative target-mass constructions; its theorem and proof are unchanged from the audited source. The paper wrapper was rewritten to lead with the every-width conclusions and place the target-based theorems before their technical ingredients. `critical-main-theorem.tex` received a section-title change only, from “Main theorem” to “Universal critical-rate bounds.”

The generic empirical-Cramer shortcut was rejected after a rigorous two-dimensional counterexample. That diagnosis is retained as a verification note and is not used as a premise of the positive proof.

Remaining limitations: joint polynomial dependence on arbitrary teacher width and depth is open; the current general teacher exponent grows with depth. The results do not give efficient posterior sampling, small compressed weight norms, or a quantitative convergence bound to the optimal limiting rate for every target. The five promoted main results and their Lean files are unchanged.
