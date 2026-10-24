# ReLU/GELU polynomial-depth paper: statement review

Reviewer: coordinating ChatGPT-6 Astra agent, separate from the agent writing
the main formalization. The reviewer also supplied the sharp bulk-probability
and cylinder-mass lemmas; this is therefore not an independent review of those
two helper proofs. Date: 22 October 2026.

The review compared `works-in-progress/relu-gelu-polynomial-depth/source/paper.tex`
with `BatchTwoMergingModel`, `Circuit`, `SharpRadius`, `SharpTarget`,
`SharpBudgets`, `SharpMain`, and `SharpScales`.

## Checked correspondence

- The support quantifies over actual nonempty neuron populations of arbitrary
  sizes and applies their averaging matrices to actual network weights.
  `population_budget_iff_maxima` proves equivalence to the manuscript's
  `(q−1)M² ≤ 4E_v` condition. The clipped discrepancy is at most 1/16.
- The raw Gaussian variances match after substituting `σ=t/√N`. The explicit
  wrappers cover all `0<t≤1` and all exponents γ≥1. The support condition has
  no dependence on the target or teacher complexity.
- The posterior is Gaussian measure conditioned on the support and observed
  strict 1/2 margins. `posterior_eq_two_stage` identifies this with first
  restricting the prior and then conditioning on training. Both normalizers
  are separately positive for every sample, even before imposing a sample
  size condition.
- The teachers are actual layered NOR/COPY/NOT circuits with counted constant
  wires and one output. `r=L−2` gives exactly the paper's hidden-layer count.
  ReLU permits every learner width N≥C; exact CDF-defined GELU permits N≥2C.
- The radius, bulk bound, target energy, constrained-coordinate count,
  logarithmic cylinder cost, readout cutoff, population count, energy cutoff,
  and grid entropy in the sharp modules match the displayed formulas.
  In particular the formal sample factor is exactly 2/ε.
- `manuscript_relu_learning` and `manuscript_gelu_learning` give one measurable
  IID event independent of learner width and scale. Within that event their
  conclusions quantify over every permitted width, every permitted scale,
  and both optional all-input-margin choices. This preserves the manuscript's
  simultaneity rather than proving only a separate event for each learner.
- The risk averages the actual posterior probability of signed output at
  most 1/4. It does not substitute a selected network or posterior-mean output.

No mismatch was found in the two exact numerical main learning statements.
The separately proved literal C²S⁹ corollaries use actual ancestor pruning.
The additional C²log³C sufficient-sample asymptotic arithmetic has also
compiled in `BatchTwoMergingSharpWidthAsymptotics`; the formal asymptotic
statement is recorded in the separate theorem map. A clean collection build
and final axiom/integrity audit remain required before publication.
