# Continuous-domain paper: formalization status

Manuscript: `side-results/continuous-domains/source/paper.tex`.

**Both headline main theorems are proved.** The strong-prior and finite-scale
regression theorems, including every fixed exponent gamma at least one, have
compiled and passed an independent semantic review. Ancillary weak-limit and
classification corollaries are not all formalized. See
[the literal theorem map](BatchTwoContinuous-finite-theorem-map.md) and
[the independent review](BatchTwoContinuous-independent-review.md).

## Strong-prior main theorem

`BatchTwoContinuousStrongMain.strongPriorRegression` proves the literal
`BatchTwoContinuousStatements.StrongPriorRegression` proposition:

- the actual even, variance-one, twice differentiable strongly log-concave
  independent coordinate prior, with the manuscript's layer scales;
- actual tanh teachers on arbitrary nonempty compact subsets of the unit ball,
  with hidden width C, fixed depth, and a separate weight bound B;
- every learner width N ≥ C;
- the actual posterior conditioned only on observed real-output tolerances;
- sample size `(6/ε)(p(d,C,B,1/min(1,τ−ρ)) + log(1/δ))`;
- full posterior-mixture risk ≤ ε/3 and posterior-confidence failure ≤ ε;
- the positive scale threshold is chosen before the input distribution,
  sample size, and confidence parameter.

The polynomial envelope is proved, rather than supplied as a capacity
assumption. Its constants depend on depth and the coordinate law, not width.

## Proof differences

Real-input compression is obtained from the existing neuron-sampling proof
by freezing each input into the constant column. This operation commutes
with pruning, sampling and cloning. Energy controls input sensitivity
independently of width. A finite input net therefore extends compression
to the domain; actual rounded networks provide the finite cover. This
avoids needing a measurable map selecting a compressed representative.

The statistical step proves exact IID survival for finite measurable
error-set families, then integrates pointwise risk over the posterior.
Strong-prior concentration follows from proved Gaussian open-event rates
and the actual non-Gaussian density comparisons. Compactness gives openness
of the uniform teacher tube.

## Verification

Targeted command:

```
lake build NeuralGeneralization.BatchTwoContinuousStrongMain
```

Passed, 3,236 jobs (including cached dependencies). The endpoint axiom
report lists only `propext`, `Classical.choice`, and `Quot.sound`.
The independent statement review and joint targeted build of both main
endpoints have now passed; the collection-wide build is a separate check.
