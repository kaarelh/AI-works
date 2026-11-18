# Raw-output Bayesian learning with continuous shrinkage priors

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

A single dense neural network can compete with smaller networks while using its **unrestricted real-valued output in both the likelihood and prediction**. The returned predictor is the ordinary posterior mean after all training observations. The prior is fixed independently of sample count once the learner's width and depth are prescribed; there is no prior over network sizes.

The principal model has tanh hidden activations, continuous Gamma gates shared by outgoing hidden weights, Student hidden factors, and a Gaussian readout whose variances have a Dirichlet allocation. It has full support. This is a different prior from ordinary independent Gaussian weights, rather than a restriction to robust networks.

## Main guarantees

Inputs may have any distribution on the cube `[-1,1]^d`. Write `R(g)` for a comparison network's population squared loss and `K` for its implementation resource, including logarithmic accuracy factors. The comparison has the same hidden depth as the learner and any width no larger than the learner's.

| Setting | Actual likelihood temperature | Guarantee |
| --- | --- | --- |
| Arbitrary regression problem, marginal sub-Gaussian labels | `T ≍ sqrt(n)` | Expected risk of the ordinary raw mean is at most `R(g) + Õ(K/sqrt(n))`. |
| The regression function is implemented by a comparison network; conditional sub-Gaussian label noise | Any fixed `T ≥ 8σ² + 1` | Posterior-averaged raw risk, and hence mean risk, is at most the noise floor plus `Õ((K² + TK)/n)`. Expected and high-probability versions hold. |
| Exactly Gaussian realizable observation noise | The true likelihood variance `σ²`, with no tempering | Expected and high-probability raw posterior-averaged bounds; at fixed depth and dimension, excess `Õ(K⁴/n)` for Student hidden factors. The paper gives the joint polynomial resource. |
| Prescribed complexity and approximation-error budgets; bounded regression mean and conditional sub-Gaussian noise | A deterministic temperature depending on those budgets | A leading-one expected oracle with remainder `Õ((K² + Kσ²)/n + K sqrt(A₀/n))`, where `A₀` bounds approximation error, excluding the noise floor. |
| Only a finite second label moment | `T = n^(5/6)(1 + empirical mean(Y²))` | A polynomial expected oracle with leading statistical exponent `1/6`, for the same Student-hidden prior. |

The Gaussian observation variance is `T/2`. The general agnostic and prescribed-budget optimistic rows concern the ordinary posterior mean; both realizable rows and the finite-variance row also control posterior-averaged risk. No observed label is clipped.

For a width-`m`, depth-`H` comparison network on `d` inputs, hidden coefficients bounded by `B`, and readout coefficients `v_j`, the principal resource is of order

```text
K ≲ [(d+1)m + Hm²] [H log((d+m)B) + log n]
    + (sum_j |v_j|)² + output_bias² + 1.
```

The exact theorem counts all coefficient positions in the selected blocks, including zeros. The bound is polynomial in width and depth, logarithmic in hidden coefficient magnitudes, and independent of the learner's potentially much larger width. There is no additional cap on comparison outputs.

## Other priors and activations

A **very light-tailed readout** gives a nearly inverse-sample raw oracle. Keep the Student/Gamma hidden layers, draw `P` from a Dirichlet law, and use readout coefficients `P_j asinh(Z_j)` with Gaussian `Z_j`. This fixed prior still has full support and unbounded outputs. The scalar factor is an instance of the established sinh-normal distribution; its use in this neural-network prior is a separate modeling choice. At `T ≍ log²(n)`, the ordinary raw mean has expected risk `R(g) + Õ(K/n)` for comparisons with bounded readout variation. A high-probability version controls posterior-averaged risk with approximation coefficient `1+η` at `T ≍ log²(n)/η` for fixed confidence (with explicit confidence logarithms in the paper), even under only marginal sub-Gaussian labels. Large readout variation has an exponential comparison cost under this law; bounded-output compilers can instead incur an `n^{o(1)}` factor for marginally sub-Gaussian labels. The actual learner never clips outputs or labels.

An optional **bounded final hidden layer** removes the comparison readout restriction. A depth-`h` teacher may use any fixed globally Lipschitz activations, including ReLU, GELU, or tanh. The learner uses those `h` layers, one additional hardtanh or ReLU6 hidden layer, and the same unbounded sinh-normal readout. For every `N ≥ m` and any distribution on the input cube, the comparison resource is

```text
K = Õ(((d+1)m + hm²) h), with logarithmic dependence on the coefficient cap B.
```

The expected raw-mean remainder is `Õ(K/n)` when the regression mean is bounded by one, and gains an additive `n^(-1+o(1))` term under marginal sub-Gaussian labels alone. A high-probability version also controls posterior-averaged risk. With the normalized Gaussian readout instead, this architecture gives `Õ(K/√n)` under marginal sub-Gaussian labels, still logarithmic in all teacher coefficient magnitudes; a bounded realizable regression function also has the fixed-temperature `Õ((K²+TK)/n)` bound. This theorem explicitly adds a bounded hidden layer; it is not an all-ReLU learner or a claim for unchanged independent Gaussian weights. It requires a coefficient cap, unlike the separate coefficient-free compiler results.

An **independent-coordinate variance-gamma prior** gives a raw agnostic remainder `Õ(K/n^(1/3))`, with `K` measured by formula expansion rather than arbitrary shared-circuit size. It uses no shared gates. An optional normalized power readout trades different coefficient costs for rates approaching `1/n`; its distribution is fixed before seeing data.

The unnormalized Gamma/Gaussian model also covers ReLU and GELU at fixed depth, with slower explicit exponents. Gaussian hidden factors improve the finite-variance-label rate for the normalized readout from `1/6` to `1/5`.

## What the result does and does not establish

The prior's native output tails make it possible to compare the actual raw posterior with a bounded auxiliary posterior in the proof. The actual learner is never truncated. A separate finite-dictionary argument handles labels with only a second moment.

The results concern exact Bayesian inference, not an efficient sampling algorithm or gradient descent. The general agnostic theorem uses a growing likelihood variance; the fixed-variance theorems assume a realizable regression function. The exactly matched-variance version additionally assumes Gaussian observation noise. These are expectation guarantees unless a high-probability version is stated explicitly. They do not establish the same results for the original independent Gaussian priors.

The manuscript has independent AI-agent mathematical reviews. It is **not Lean formalized**. The verification record identifies the reviewed sources and separates the final integrated version from earlier snapshots.

## Build

Run `bash build.sh` with `pdflatex` installed. The source uses standard TeX Live packages.
