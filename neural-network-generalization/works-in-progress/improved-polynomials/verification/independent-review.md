# Independent mathematical review of the improved bounds

Review date: 22 October 2026 (UTC). This is an AI mathematical review, not a
Lean formalization. The reviewer independently checked the constructions,
probability estimates, and advertised quantifiers in the following drafts:

- [Shallow derivation](../shallow/source/derivation.md)
- An earlier unpublished Markov-compression prototype (retained in the research workspace, not presented as a new publication here)
- [Original-support paper](../original-support/source/paper.tex), prepared from the subsequent sharper derivation

## Conclusion

Both arguments are mathematically sound as written, subject to the explicit
scope restrictions below. No substantive mathematical error was found.
One conditioning phrase in the neuron-sampling argument should be made more
precise: the relevant conditional expectation fixes index lists only through
layer `s-2`, before drawing the list at layer `s-1`.

These results do **not** establish a quadratic bound in the original
bounded-weight teacher complexity for the original robust prior throughout
the whole regime `gamma >= 1`.

## Shallow theorem

The theorem covers every width `N >= C` and every `0 < t <= 1`, including
mean-field scaling. It applies to the raw Gaussian prior, the original
globally margin-conditioned prior, and the stated shallow robust prior,
with or without the additional global margin restriction. Its sample event can be chosen simultaneously
for all these widths and scales because the finite compressed class depends
only on the teacher and statistical parameters.

Checks performed:

1. **Target cylinder.** Balanced clone groups satisfy `N/k_j <= 2C`. The
   first-layer center cost is at most `N U`, and the readout center cost is at
   most `2 s^2 N C sum_j a_j^2`. The prescribed coordinate radius gives
   uniform output error at most `1/4`, including both the readout perturbation
   and hidden-activation perturbation terms. The scalar Gaussian interval
   lower bound is valid for every center, all `t > 0`, and `rho <= 1/4`.

2. **Robust membership.** With one hidden layer, postactivation disturbances
   affect the output exactly by `v . eta + eta_out`. Cauchy--Schwarz in the
   normalized disturbance metric bounds this by
   `sqrt(1+E_v) ||eta||_*`. Hence the calibrated ball changes the raw output by
   at most `c`; the cylinder's stronger margin makes its clipped score
   constant throughout that ball. This argument does not require bounds on
   hidden weights or a deep stability recurrence.

3. **Posterior readout tail.** `N E_v/t^2` is chi-square with `N` degrees of
   freedom. The stated exponential tail, divided by the target-cylinder
   mass, gives posterior discarded mass at most `epsilon/4`. Cauchy--Schwarz
   then bounds readout variation by `B` on the retained event.

4. **Halfspace representation.** A scalar tanh is exactly the expectation of
   a random-threshold sign function for the specified logistic-type threshold
   distribution. Negative readout coefficients can be absorbed into
   negated halfspace patterns. Boundary ties have probability zero
   simultaneously on the finite Boolean input set. Mixing equally between
   constant `+1` and `-1` patterns fills unused variation mass.

5. **Finite compression.** The affine-halfspace pattern count is bounded by
   the stated exponential in `d^2`, including the small-dimensional cases.
   Hoeffding at output error `1/16` gives exactly the exponent
   `-m/(512 B^2)`. The representation's sampling law is independent of the
   input, even though success is asserted pointwise, so averaging over the
   sample-dependent posterior produces one common compressed law.

6. **Statistical step.** The ramp endpoints `5/16` and `7/16` correctly
   separate compressed images of test-margin failures and exact training
   fits. The finite-class relative Chernoff inequality applies to every
   mixture over that class, including the posterior-induced mixture. The
   specified sample budget leaves total risk at most `epsilon`.

The quadratic-width conclusion is valid when teacher readout coefficients
are bounded independently of width (more generally when the displayed
teacher mass cost is quadratic). If all coefficients, including the
readout, may be as large as `C`, the same argument has a `C^4` term. There
is no proved lower bound here showing that quartic dependence is necessary.

The original review suggested replacing the full-cube pattern count by
sample-pattern growth bounds for votes of `m` halfspaces. The author
subsequently supplied a self-contained proof of that improvement. It has
now also passed review, as recorded below.

## Original-support quartic theorem

The theorem retains the published deep robustness restriction. It proves
a quartic teacher-width bound up to logarithms in the strong-prior limit,
and also for every actual finite scale satisfying `t^2 <= 1/N`, including
every `gamma >= 2`. It does not establish that rate at mean-field scaling
or throughout `1 < gamma < 2`.

Checks performed:

1. **Sampling dependence.** The virtual state at layer `s-1` depends on
   selected index lists only through layer `s-2`. The fresh independent list
   at layer `s-1` is therefore a valid sample for estimating each coordinate
   of `W^s htilde_(s-1)`. Conditional variance is bounded by the row squared
   norm times `N/m`; averaging over the `N` output coordinates gives
   `||W^s||_F^2/m`.

2. **Original histories.** Defining the postactivation disturbance as the
   difference between the sampled virtual activation and the original
   layer applied to the previous virtual state gives an exact recursive
   identity. The original network under these disturbances has the virtual
   states and sampled output. Thus the proof does not omit an amplification
   factor from propagating errors through later layers.

3. **Compressed energy.** Independence of index lists in adjacent layers
   gives `E kappa_m(w_comp) = kappa_N(w)` exactly. Sampling with replacement
   causes no problem; duplicate indices represent duplicate neurons.
   Neither this expectation nor the disturbance expectation conditions on
   successful sampling. Separate Markov bounds and a union bound therefore
   provide the advertised common-law compression event.

4. **Quantization.** The compressed energy bound implies the stated
   uniform entry bound. With coordinate rounding error `u`, hidden
   coordinate errors obey the recurrence
   `e_s <= m(B+1)e_(s-1) + m u`, initialized by
   `e_1 <= (d+1)u`; the readout obeys the analogous recurrence. The chosen
   mesh therefore yields output error at most `1/48`. The grid-cardinality
   bound covers endpoints and the default zero network.

5. **Uniform risk.** Original robustness contributes clipped error at most
   `1/16` and rounding at most `1/48`, totaling `1/12`. The ramp comparison
   and relative Chernoff event therefore hold uniformly over every robust
   energy-bounded exact-fitting network, and hence every posterior mixture.
   With `alpha=epsilon/12`, the stated sample budget gives risk at most
   `epsilon/2` on the retained energy class.

6. **Actual Gaussian posterior.** The normalized full energy is chi-square
   with the stated parameter count. The target-cylinder denominator gives
   the stated posterior energy tail. The strong-prior cutoff makes that
   tail at most `epsilon/2`. For the finite-scale result, the key estimate
   is `t^2 P_N/N <= d+L` when `t^2 <= 1/N`; substitution in the displayed
   energy cutoff gives the same posterior tail bound. This justifies the
   extension to every `gamma >= 2` at all widths.

7. **Asymptotic width exponent.** At fixed remaining parameters, the target
   cost is `O(C log^2 C)`, inverse squared robustness radius is `O(C log^2 C)`,
   and compressed width is `O(C^2 log^4 C)`. The dense-grid code is quadratic
   in that compressed width with one additional logarithm, giving the
   advertised `O(C^4 log^9 C)` sufficient sample size.

The failure to cover `gamma < 2` is substantive for this proof: its full
energy contains a Gaussian bulk contribution growing as `N^(2-gamma)`.
The older entropy-compression argument handles that bulk, whereas this
elementary sampler does not.

## Subsequent sharper compressor review

The sharper draft replaces pointwise Markov compression by uniform
pruning-and-Bernstein compression, an argument already present in the
17 October research report. Its attribution to that report is accurate.
The adaptation to the current clipped-score support and finite-scale
posterior tail also checks out.

Additional checks:

1. Pruning above the row-dependent threshold makes deleted row absolute
   mass at most the row squared norm divided by that threshold. Squaring
   and summing gives the stated whole-layer pruning bound.
2. A sampled column contribution has conditional second moment at most
   `N k_s` and centered norm at most `16 sqrt(N K k_s)/r`. These follow
   directly from the entrywise pruning threshold and bounded activations.
3. At the desired mean error `r sqrt(N k_s/K)/8`, dimension-free Hilbert
   Bernstein gives exponent `3 m r^2/(640 K)`: the variance-plus-range
   denominator is `2(N k_s + (2/3)N k_s)`. The weaker exponent used in the
   final formula is therefore valid. The corresponding scalar readout
   calculation removes the factors of `N`.
4. Conditional bounds hold for every preceding index history. A union
   bound over the whole Boolean cube and all layers then has failure
   probability at most `1/200` for the stated width. This uniform event
   intersects the event of compressed energy at most `4K` with positive
   probability.
5. Consequently each original robust low-energy network has one grid
   candidate approximating it at every input, with zero empirical ramp
   loss whenever the original network fits all training margins. The
   finite-class zero-loss bound justifies
   `n >= (2/epsilon)(J+log(1/delta))` without a sampling-failure accuracy
   penalty.

The sharper theorem therefore retains the same quartic width dependence
up to logarithms and improves the explicit accuracy dependence from the
prototype's `epsilon^-3` term to an `epsilon^-1` factor, with additional
logarithmic accuracy dependence in the finite-scale energy cutoff. It is
the preferable version to report.

## Subsequent shallow teacher-cost refinement

The replacement of the first-layer center-cost quantity by
`U = d min(max_j ||b_j||^2, (2/C) sum_j ||b_j||^2)` is valid: balanced clone
groups obey both `k_j/N <= 1` and `k_j/N <= 2/C`. It strengthens the
teacher-cost estimate without changing the other proof steps. In
particular, the stated bound linear in the teacher's weighted energy,
apart from logarithmic interval costs, follows.

## Shallow dimension-sharpening appendix

The new appendix proving the bound approximately linear in input dimension
also passes review. Its sufficient rate is
`soft-O((d D_* + log(1/delta))/epsilon)`, with all hidden logarithms exposed
by the displayed formulas.

Specific checks:

1. A finite-class bad witness selected from the first sample is independent
   of the ghost sample. The ghost lower Chernoff bound at `3p/4` has failure
   probability at most `exp(-np/32)`, which is at most one half under the
   stated condition on `nu`.
2. Conditional on the pooled sample, exchangeability permits a uniformly
   random equal-size split. For a pattern with `k` marked positions, the
   first-half marked count `K` has the claimed hypergeometric law. The
   Hoeffding denominator `k` is valid: equivalently, draw the `k` marked
   positions' group labels without replacement from a population of `2n`
   labels containing exactly `n` labels for each group.
3. The bad split implies `K < 2k/5 - 3nu/10`. Expanding the Hoeffding exponent
   gives `k/50 + 3nu/25 + 9(nu)^2/(50k)`, which is at least `6nu/25` by
   arithmetic-geometric mean. The case `k=0` cannot be bad.
4. Union bounding the pooled membership patterns and inserting the chosen
   `u` proves the relative growth-function inequality with the conservative
   constant `32`.
5. Multiplication by the labels does not change the symmetric finite grid
   of possible voted outputs. A fixed vote therefore has at most `m+1`
   loss values and at most `m+2` strict level-set patterns. Together with
   the halfspace growth bound this gives
   `(m+2)(er)^(m(d+1))` as stated.
6. Integrating the simultaneous level-set inequality by the layer-cake
   formula proves the relative bound for the ramp losses. It can then be
   averaged over the same posterior-induced compressed mixture as before.
7. The explicit sample size `ceil(4 T log(8eT))` satisfies the implicit
   bound: at the unrounded value its logarithmic right-hand side is at
   most `T[log(8eT)+log log(8eT)+1]`; the difference between the two sides
   is increasing thereafter. The theorem's parameters make `T>1`, so
   the elementary logarithmic inequality used here is valid.

This improvement preserves the original simultaneous quantifiers over
learner width and Gaussian scale. It does not alter the distinction
between quadratic teacher-width dependence with bounded readout
coefficients and quartic dependence for the original bounded-weight
complexity convention.

## Final shallow scope clarification

The added case with no initial support restriction is valid. For the raw
Gaussian prior conditioned only on strict signed training margins, the
same target cylinder lower-bounds the conditioning probability. The readout
tail and subsequent compressed-ramp proof require no global clean-output
margin or robustness property. The target scale `s=3` therefore suffices
without any other change.

At fixed dimension and other theorem parameters, the original finite-cube
bound gives literal `O(C^2)` sample dependence when hidden coefficients are
bounded by `C` and readout coefficients are bounded independently of `C`.
Its teacher cost has a quadratic leading term and only an additive
`log C` term, which is absorbed by `C^2`; the compressed-class bound is
linear in that teacher cost. The dimension-sharpened version improves
dimension dependence while introducing additional logarithms. Both bounds
remain available, so one may take their minimum.

## Publication correspondence

The publication sources add titles, model definitions, author information, and references. The original-support paper reproduces the canonical target-cylinder argument in full in its appendix. Mathematical claims and explicit budgets are those reviewed above; the superseded Markov prototype is not a separate published result.

## Publication review: retaining the shallow dimension overhead

A final FAQ and overview review found that the compressed norm-only summary
`soft-O((d kappa_C + log(1/delta))/epsilon)` omitted the additive dimension
cost in the exact target-cylinder estimate. The exact paper proof and its
explicit sample formulas already retain this cost and require no change.
The supported summary is

`soft-O((d(kappa_C+d) + log(1/delta))/epsilon)`.

Indeed, `D_* <= 2 s^2 kappa_C + (d+2) log(e sqrt(2pi)/(2rho))`, and
`sum |a_j| <= sqrt(kappa_C)` bounds the interval-cost logarithm. One cannot
absorb the additive dimension cost into `kappa_C`: a constant teacher using
bias `b=d^(-1/4)` and readout `1/tanh(b)` has teacher energy of order
`sqrt(d)`. This observation concerns the stated proof budget; it is not a
counterexample to a potentially sharper learning theorem.

The FAQ, package overview, leaf README, and supporting derivation now retain
the dimension overhead. The quadratic and quartic teacher-width conclusions
are unchanged.
