# Agnostic learning with layerwise heavy-tailed neural-network priors

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

One fixed dense Bayesian neural network can compete with every smaller bounded-weight network using **any fixed globally Lipschitz hidden activation**. ReLU, GELU, tanh, sigmoid, SiLU and softplus all qualify, and the activation need not vanish at zero. The output passes through a bounded link such as tanh or clipping before entering a Gaussian likelihood.

The prior has continuous independent coordinates, with no mixture over architectures or network sizes. A row of fan-in F and tail index alpha_l uses weight scale F^(-1/alpha_l). Tail indices decrease strictly through the layers:

    0 < alpha_(H+1) < ... < alpha_2 < min(1, alpha_1),   alpha_1 < 2.

Student-family and comparable symmetric power-tailed densities qualify. The first layer may use ordinary Cauchy weights.

Let a = alpha_2, R0 be irreducible label-noise risk, and A_* the best smaller network's approximation error above that noise floor. For every chosen constant eta > 0, the ordinary final posterior mean satisfies

    R(posterior mean) <= R0 + (1+eta) A_*
                        + (C/eta) * [(1+noise_proxy)*(K+log(1/delta))/n]^(1-a/2).

The likelihood variance is the fixed constant 16*(1+noise_proxy)/eta, independent of sample size, learner width and comparator complexity. The guarantee holds at every finite learner width at least the comparator width and allows conditional sub-Gaussian label noise, including unbounded Gaussian labels. The regression mean must lie in [-1,1].

For a = 1/2, the rate is **n^(-3/4) for ReLU and the other activations alike**. Smooth hidden activations and a smooth output link (or clipping) improve the dependence on eta, but are unnecessary for this sample-size power.

At fixed depth H, the comparator resource K is polynomial in input dimension, teacher width m and coefficient bound B, with no learner-width factor. Up to logarithms:

- The width degree is max(H, H-1 + 2H*a/(2-a)).
- The coefficient-bound degree is at most aH + 2H*a/(2-a).
- At a = 1/2, these become max(H, 5H/3-1) and 7H/6.

Constants can depend badly on depth and on gaps between successive tail indices. The result is not a polynomial-depth theorem. A proof-only confidence allocation gives one simultaneous oracle over all teacher widths and coefficient bounds; it changes neither prior nor learner.

There is also a **sharp all-data expected-risk oracle** at fixed likelihood variance 128*(1+noise_proxy). Smooth activations give coefficient one on comparator risk with the same n^(-1+a/2) rate. For merely Lipschitz activations and a=1/2, the expected remainder is of order A_g^(1/5)*n^(-3/5) + n^(-3/4), with resource factors restored in the paper. It uses the ordinary final posterior and every observation. The full arbitrary-prior leave-one-out proof extends the 2026 argument of Høgsgaard, Rebeschini and Wegel to conditional sub-Gaussian labels.

The paper also proves:

- A bounded-label, coefficient-one oracle for one calibrated final posterior: R <= R_* + C(sqrt(R_* u) + u), where u = ((K+logs)/n)^(1-a/2).
- Width-independent prior mass for uniform function neighborhoods on the entire input cube.
- Polynomial total exact-sign Bayesian mistakes and confidence failures on every adaptive query sequence for margin-implementable targets on a prescribed compact input set.
- A growing-comparator oracle: for explicit positive polynomial width and coefficient exponents, a logarithmically increasing likelihood variance gives risk at most the best comparator risk plus a vanishing remainder.
- Almost-sure risk consistency under any deterministic width schedule tending to infinity, for universal comparator families such as ReLU with a final tanh or clip.

The proof uses a conditional comparison measure. It truncates unused incoming weights according to the magnitudes of preceding features; the actual learner does not impose these cutoffs. Strictly decreasing tails supply the required fractional moments, while the number of possible small-network embeddings compensates their coordinate probabilities.

The bounded output is substantive. Without it, a ReLU feature that is inactive on all training points can leave a heavy-tailed readout unconstrained. On a continuous sphere domain, the raw posterior mean can then be undefined at almost every new test point after any finite sample.

The architecture is fixed before observing the data. Uniform constants do not give a common event for arbitrary data-dependent selection among infinitely many learner widths. No efficient posterior-computation claim or Lean verification is made.

Dense independent heavy-tailed network priors already appear in Castillo and Egels (JMLR, 2025). The specific target here is a finite-sample agnostic smaller-network oracle with sample-size-independent fan-in scaling and constants uniform over every prescribed learner width.

The arguments have received independent AI-agent mathematical review. Build with bash build.sh.
