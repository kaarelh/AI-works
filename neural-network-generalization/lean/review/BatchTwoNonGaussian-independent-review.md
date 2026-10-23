# Non-Gaussian priors: independent statement review

Reviewer: the coordinating ChatGPT-6 Astra agent, separately from the agent
that wrote the non-Gaussian formalization. This is an AI review, not a human
review. Date: 22 October 2026.

Scope: the two main theorems in
`side-results/non-gaussian-priors/source/paper.tex`, compared with
`BatchTwoNonGaussianStatements.lean`, the concrete model and function-posterior
definitions, and the completed strong, mean-field, above-mean-field, and combined
endpoints. Auxiliary extensions mentioned in prose are not included in this
two-theorem verification claim.

## Findings

- The coordinate-law structure describes a probability density with the paper's
  even C² potential, positive two-sided curvature bounds, and second moment one.
  It has no concentration or learning theorem among its fields. The proved
  standard Gaussian example also prevents a vacuous empty-law interpretation.
- The product law uses independent scalar coordinates with exactly the three
  specified scales. The formal network has `r+1` hidden layers and one linear
  readout, so `L=r+2`. The input cube and the counted constant coordinate agree
  with the manuscript.
- The teacher premise is the manuscript's minimum width with coefficient bound
  and strict margin; it is not an unrestricted circuit gate count. The learner
  ranges over every width at least that teacher complexity.
- Function masses are actual parameter measures of global strict-margin
  regions. The posterior is their normalized restriction to exact label
  consistency. The common prior normalization cancels. Neither a chosen energy
  minimizer nor a Gaussian-process surrogate replaces this posterior.
- Gibbs risk and the at-most-2/3 correct-label-probability failure set agree
  with the paper, including mixtures and ties. The conclusion also explicitly
  proves positivity of every training normalizer.
- The strong-prior threshold is chosen after finite learner width and desired
  accuracy, but before the input distribution, confidence, and sample size.
  Its sample polynomial is independent of learner width.
- The finite-scale theorem covers every fixed γ≥1; its polynomial may depend
  on γ, depth, and the scalar law, but not learner width. The γ=1 and γ>1 proofs
  are combined without a uniformity claim as γ approaches one.
- The displayed 6/ε factors and confidence logarithms match both manuscript
  statements. The formal polynomial envelope is a valid particular polynomial
  of the permitted variables.

The endpoint proofs discharge their internal tail, target-mass, finite-class,
and budget premises with proved results. The alternate clone-group/small-width
argument changes the proof, not either main statement. In particular it is
not being used to claim an unproved logarithmic continuous-tolerance bound.

No statement mismatch was found in these two main theorems. The separate
`BatchTwoNonGaussianAudit` build reports only `propext`, `Classical.choice`,
and `Quot.sound` for all main endpoints. A final clean collection build and
publication integrity checks are still required.
