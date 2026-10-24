# Independent review of the shallow learning theorem

Reviewed on 22 October 2026 by a separate agent from the author of the
shallow endpoint modules. The reviewer supplied the generic pair-swap
concentration helper used by the sharper proof; this review is independent
of the shallow model, target construction, resource calculations, and
endpoint assembly, but is not an independent reimplementation of that
helper.

**Conclusion:** I found no substantive mismatch between the manuscript's
first and sharper sample-complexity statements and their Lean endpoints.
The following are genuine statements about the specified Gaussian neural
posterior, rather than conditional reductions assuming the main analytic
ingredients.

## Statements checked

The manuscript is
`works-in-progress/improved-polynomials/shallow/source/paper.tex`.

| Manuscript claim | Checked Lean endpoint |
| --- | --- |
| First boxed budget, `16/epsilon * [m h_d + log(1/delta)]` | `BatchTwoShallow.shallow_all_width_all_scale` |
| Sharper implicit budget, `64/epsilon * [m(d+1) log(2 e n) + log(4(m+2)/delta)]` | `BatchTwoShallow.shallow_sharp_all_width_all_scale` |
| Sharper explicit ceiling, `ceil(4 T log(8 e T))` | `BatchTwoShallow.shallow_explicit_sharp_all_width_all_scale` |
| Cost essentially linear in the actual weighted teacher norm | `BatchTwoShallow.targetCost_le_energy` |
| Explicit dependence on first-layer and readout coefficient bounds | `BatchTwoShallow.targetCost_le_width_resources` |

The definitions of `U`, `rho`, `D_*`, `B^2`, `m`, `h_d`, and `T`
match the displayed manuscript formulas, including all constants and
logarithms. The first-layer and readout resource estimates also match.
The hypotheses allow arbitrary teacher coefficients in the main theorem;
coefficient bounds are imposed only in the resource corollaries.

## Model and quantifiers

- `Weights d N 0` is an actual one-hidden-layer network with `N` hidden
  neurons and a linear readout. The constant input coordinate appears first
  in Lean and last in the manuscript. This is only a coordinate ordering;
  all first-layer coordinates have the same variance.
- Under the substitution `sigma = t / sqrt(N)`, `smallPrior` has exactly
  first-layer variance `t^2/d` and readout variance `t^2/N^2`. Thus
  `sigma > 0` and `N sigma^2 <= 1` describe the paper's `0 < t <= 1`.
  `good_event_all_t_scales` and `good_event_all_power_priors` make these
  scale conventions explicit. The latter covers every `gamma >= 1`.
- `priorSupport` covers the raw Gaussian, global absolute-margin
  conditioning, the original calibrated robustness restriction, and that
  robustness restriction combined with global-margin conditioning. At one
  hidden layer the radius is exactly `c / sqrt(1 + N sum(v_i^2))`; the
  perturbation norm and clipped-score tolerance are the manuscript's.
- The likelihood requires the **strict** training margin
  `f(x_i) z_w(x_i) > 1/2`. The conclusion bounds the posterior-averaged
  test event `f(x) z_w(x) <= 1/4`, including equality at the threshold.
  It is a Gibbs margin-risk conclusion, not a claim about posterior-mean
  regression or selection of a single minimum-energy network.
- `posterior_eq_twoStage` identifies conditioning the raw Gaussian on the
  intersection with first restricting the prior and then conditioning on
  training data. The conclusion is therefore about the intended learner.
- The input distribution is an arbitrary probability measure on the
  Boolean cube; the sample law is its actual IID product. A single
  measurable good-sample event has probability at least `1-delta` and
  works for **every** learner width `N >= C` and every allowed scale.
  Width and scale are quantified after the event, as in the manuscript.
- The conclusion includes strictly positive mass of the conditioning
  event. The posterior cannot satisfy the risk statement merely by being
  a zero measure produced by conditioning on an impossible event.

## Proof audit

The target-mass lower bound is proved from an explicit cloned teacher and
an actual Gaussian coordinate rectangle. The weighted quadratic cost is
`(d/N) sum(W_ij^2) + N sum(v_i^2)`, exactly the norm corresponding to the
prior after the scale substitution. There is no assumption that a good
function neighborhood has sufficient mass.

The readout-energy tail is proved for the Gaussian prior, then divided by
the proved target-cylinder lower bound. The halfspace approximation is an
explicit probability law obtained from uniform thresholding of each tanh
ridge. Its mean is proved to equal the network output. The finite class
size and the restricted-sample growth bound are proved from affine
halfspace counting. No sampling, compression, or capacity conclusion is
supplied as an endpoint hypothesis.

The good-sample event controls every retained network separately; the
formal proof subsequently integrates this pointwise fact against the
actual posterior. This handles posterior mixtures and avoids an
unproved measurable-selection requirement for compression.

There are three harmless differences from the manuscript proof: equal
clones plus disconnected padding replace balanced groups; an indicator
at margin `3/8` replaces a ramp loss; and independent pair swaps replace
the hypergeometric argument. All final displayed sample budgets are
preserved.

## Validation and scope

The targeted build

```
lake build NeuralGeneralization.BatchTwoShallowPriorConventions NeuralGeneralization.BatchTwoShallowResources
```

completed successfully, including both main theorem modules and their
dependencies. The source scan of the shallow modules found no `sorry`,
`admit`, or added axiom. A project-level clean rebuild and axiom audit
remain the publication checks; this review does not replace those checks.

The subsequent `BatchTwoShallowWidthPolynomials` module was also reviewed.
`quadratic_width_sample_bound` assumes first-layer coefficients at most
`C` and readout coefficients at most a separate `V`; its multiplier
depends on `d,s,V,epsilon,delta` and not on `C`. It therefore proves the
literal quadratic claim when `V` and the other parameters are fixed.
`quartic_width_sample_bound` permits every teacher coefficient to reach
`C` and gives a multiplier independent of `C` times `C^4`. The intermediate
logarithmic target-cost term is absorbed using a valid upper bound for the
logarithm. These statements concern the first finite-cube sample bound;
they do not erroneously remove the additional logarithm from the sharper
growth-function bound.
