# Independent semantic review: continuous-domain regression

Reviewed source: `side-results/continuous-domains/source/paper.tex`, especially Theorems `thm:strong` and `thm:finite` and their model definitions. Reviewed endpoints: `BatchTwoContinuousStrongMain.strongPriorRegression : StrongPriorRegression` and `BatchTwoContinuousFiniteMain.finiteScaleRegression : FiniteScaleRegression`, including their explicit mean-field and supercritical branches. This review was performed by a separate agent from the authors of those continuous regression formalizations.

**Finding: the two headline theorem statements match.** No additional analytic-oracle premise, width cutoff, Gaussian replacement of the original scalar prior, teacher regularity hypothesis, or weakened prediction convention appears in the final statements.

| Item | Semantic check |
| --- | --- |
| Architecture and depth | The actual real-input network has a constant input coordinate, `r+1` tanh hidden layers, no separate internal biases, and a linear readout. Thus the manuscript's total depth is `L=r+2`. |
| Scalar law | `CoordinateLaw` specifies the actual density of a fixed even variance-one law with a twice continuously differentiable potential and positive lower/finite upper curvature bounds. Its fields do not assume concentration, compression, or learning. |
| Prior scaling | `smallScale` and `powerScale` are exactly the first/internal/readout scales in the manuscript. The product measure uses independent copies of the supplied law. |
| Teacher | Every specified teacher of width `C≥1` at the same depth is included, with an independent bound `B≥1` on all coordinates. No Boolean target, minimum-complexity, global margin, or robustness assumption is added. |
| Input domain | Every nonempty compact subset of the Euclidean unit ball is included. A Borel probability measure on that subset is represented by an ambient probability measure with zero mass outside it, which is equivalent here. |
| Likelihood and loss | The prior is conditioned only on the observed strict output tolerances `<ρ`. Risk is full posterior-mixture error `>τ`; confidence failure means correct-within-`τ` probability `≤2/3`. These match the paper. |
| Strong-prior quantifiers | The polynomial constants depend only on depth and coordinate law. The positive scale threshold is selected after teacher, finite learner width and tolerances, and before input distribution, confidence level and sample count. |
| Finite-scale quantifiers | Each fixed `γ≥1` has one polynomial independent of teacher and learner width. All `N≥C` are included, with a separate proved critical endpoint and supercritical branch. The statement does not assert one common event across `N` or `γ`; neither does the paper. |
| Sample budget | The exact `6/ε` factors, inverse tolerance gap, logarithmic inverse training tolerance, logarithmic inverse error, and displayed confidence logarithms match. `regressionEnvelope` is a literal positive constant times a fixed natural power of the sum of arguments. |
| Posterior normalization | Although positivity is not separately repeated in the two headline proposition types, the learning proofs establish positive uniform-teacher-tube mass, transfer it to every training event whose inputs lie in the domain, and instantiate `IsProbabilityMeasure` for the actual conditioned posterior. Thus the risk conclusion is not obtained by allowing a zero posterior. |

The proof files establish the target tube, actual exceptional mass, finite cover, and polynomial envelopes before invoking the generic statistical lemma. Intermediate lemmas may expose these ingredients as hypotheses; the two final endpoints do not.

Verification performed for this review:

```
lake build NeuralGeneralization.BatchTwoContinuousStrongMain NeuralGeneralization.BatchTwoContinuousFiniteMain
```

The build passed (3,415 jobs including cached dependencies). Exact axiom checks of `strongPriorRegression`, `finiteScaleRegression`, `FiniteMeanField.meanField`, and `Above.aboveMeanField` reported only `propext`, `Classical.choice`, and `Quot.sound`; none included `sorryAx` or a project-specific axiom. Audit log: `/tmp/continuous-main-independent-audit.log`.

This review covers the two headline main theorems. It does not certify every ancillary weak-limit, classification, or bounded-coordinate-domain remark; the separate theorem map records that narrower coverage.
