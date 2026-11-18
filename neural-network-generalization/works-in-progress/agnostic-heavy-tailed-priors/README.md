# Agnostic learning with a fixed heavy-tailed neural-network prior

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

A single dense Bayesian network with independent heavy-tailed weights can compete with every smaller bounded-weight network, uniformly over all finite learner widths above comparator width. The prior has continuous independent coordinates and no mixture over architectures or network sizes. The main theorem uses one fixed Gaussian likelihood variance, independent of sample size and width.

For a fixed tail index `0 < alpha < 2`, a row of fan-in `F` uses weight scale `F^(-1/alpha)`. Student-family and symmetric stable priors qualify; `alpha = 1` includes ordinary Cauchy weights. Hidden activations are bounded with bounded first and second derivatives, as tanh is. A fixed bounded link, such as tanh or clipping to `[-1,1]`, is applied to the linear readout before entering the likelihood. Thus tanh may be used in every layer.

Let `R0` be the irreducible label-noise risk and `A_*` the best smaller network's approximation error above that noise floor. For any chosen constant `eta > 0`, the ordinary final posterior mean satisfies

```text
R(posterior mean) <= R0 + (1+eta) A_*
                    + O_alpha(((1+noise_proxy)*(K+log(1/delta))/(eta*n))^(1-alpha/2)).
```

Here `K` is polynomial in teacher width, coefficient bound and input dimension at fixed depth, and independent of learner width. Conditional sub-Gaussian label noise is allowed, including unbounded Gaussian labels. The regression mean must lie in `[-1,1]`. The actual likelihood variance is the fixed constant `16*(1+noise_proxy)/eta`.

Independent Cauchy weights give a `n^(-1/2)` remainder. Tail index `alpha = 1/2` gives `n^(-3/4)`. For Cauchy weights, the dominant teacher-width degree in `K` is `3H`, where `H` is hidden depth. At fixed remaining resources the paper proves an explicit `exp(O(H))` sample upper bound. A bounded-Lipschitz extension has the same sample-size power without requiring derivatives; its dependence on the approximation factor is weaker.

The same familiar prior also has a **sharp all-data expected-risk oracle** at fixed likelihood variance 128*(1+noise_proxy):

    E_sample R(final posterior mean) <= R(g)
        + C_alpha * [(1+noise_proxy)*K/(n+1)]^(1-alpha/2).

This has coefficient exactly one on comparator risk, uses every observation, and needs no averaging over posterior prefixes. It is an expectation theorem; the earlier statement is its separate high-probability companion. The paper gives the full arbitrary-prior leave-one-out argument, extending the 2026 method of Høgsgaard, Rebeschini and Wegel to conditional sub-Gaussian labels.

The paper also proves complementary guarantees:

- For bounded labels, an observable temperature calibration gives leading coefficient exactly one on comparator risk. With `q = alpha/(2-alpha)` and `T = K + confidence logarithms`, its remainder is `O((T R_*/n)^(1/(q+2)) + (T/n)^(1/(q+1)))`. For Cauchy weights this is `(T R_*/n)^(1/3) + (T/n)^(1/2)`.
- Averaging the successive posterior predictions at fixed temperature gives expected population-risk excess `O((K/n)^(1/(q+1)))` with leading coefficient one. This averaged predictor is distinct from the ordinary final posterior mean.
- On a finite Boolean domain, the prior gives a margin-implementing small network at least `exp(-poly(complexity))` function probability, uniformly in learner width. Exact sign conditioning therefore has polynomial total expected sampled-prediction mistakes, majority mistakes, and confidence failures on every adaptive input sequence. Initial all-input margin conditioning preserves this guarantee.

The proof unrolls a comparator's computation. The number of possible placements compensates the small probability of each designated large weight. Truncated background coordinates cancel in mean square, while unbiased perturbations and smooth hidden activations preserve a second-order risk estimate.

The bounded-hidden restriction matters. A one-hidden-layer ReLU network with the same Cauchy scaling and fixed likelihood temperature fails a width-uniform vanishing-risk guarantee even on a constant noiseless target. Conversely, the tanh model has an order-one initialization standard deviation after its final bounded output link while still having the proved circuit-neighborhood prior mass; output scale alone does not imply Gaussian-process behavior.

The learner architecture must be fixed before observing the sample. Uniform constants do not mean a common event for unrestricted data-dependent selection among infinitely many learner widths. The calibrated theorem's selected temperature can depend on width through its partition function; the main fixed-temperature theorem has no such dependence.

Dense independent heavy-tailed network priors already appear in Castillo and Egels (JMLR, 2025). This paper focuses on a finite-sample agnostic smaller-network oracle, fixed fan-in scaling independent of sample size, and constants uniform over every prescribed learner width.

The mathematical arguments have received independent AI-agent review. They have not been formalized in Lean.

Build with `bash build.sh`.
