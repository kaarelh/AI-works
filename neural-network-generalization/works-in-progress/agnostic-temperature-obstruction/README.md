# Limits of temperature tuning for Gaussian Bayesian neural networks

**[Paper (PDF)](paper.pdf) · [Source](source/paper.tex) · [Verification](verification/README.md)**

Authors: ChatGPT-6 Astra, Claude Opus 5.5, Kaarel Hänni, Dmitry Vaintrob. Authors are listed in alphabetical order.

For a dense Gaussian Bayesian learner with a Gaussian squared-error likelihood, this paper constructs **one data law on which every likelihood temperature has a constant excess risk**. The conclusion is simultaneous over all sufficiently large learner widths, so choosing the temperature or width after seeing the data does not repair the example.

The labels have a bounded-weight neural network as their exact conditional mean. Inputs have fixed coordinate range and covariance eigenvalues in `[1/20,1]`. The difficulty comes from combining a noisy component that is cheap to memorize with a steep signal component that is expensive in weighted parameter norm. A shifted Gaussian comparison law keeps the original covariance, compensates the Gaussian bulk through a scalar tanh recursion, and gives the mean-field extension. Posterior operator-norm moments control the competing high-temperature branch.

## Quantitative result

There are `H≥2` hidden tanh layers and a linear readout. At sample counts `n=2^k`, ambient dimension is `d=k+2`. The teacher has width at most `n^a` and weights at most `n^b`, where

```text
H a + (H+1)b > (H+1)/(2H),   a>0, b≥0.
```

With probability at least `1−2 exp(−n^(1/3)/2)`, every positive temperature and every learner width above

```text
N_*(n) = O_H(n^a + (log n)^3 n^(1+1/H))
```

give test MSE at least `1/100` above the Bayes-optimal teacher, for all sufficiently large `n`. This smaller width threshold covers every actual canonical finite prior `σ²=N^(-γ)` with `γ≥2`, as well as the strong-prior limit. **Every canonical exponent `γ≥1`, including mean field, is covered without a limit** at the enlarged threshold `N_**(n)=O_H(n^a+n²(log n)^5)`. This covers posterior-averaged risks, the ordinary raw-output posterior mean, and the stated clipped prediction conventions.

For equal width and weight exponents, the failure condition is `a>(H+1)/(2H(2H+1))`; the existing positive bound works for `a<1/(4H)`. With a fixed coefficient bound, the corresponding negative and positive thresholds are `(H+1)/(2H²)` and `1/(2H)`. The gaps remain open. A self-contained appendix proves that the tanh memorizer already has the optimal energy exponent `n^(1/H)`, up to logarithms, even if first-layer weights are free. It gives a high-probability lower bound on the random noisy singleton labels as well as a worst-case statement.

A fixed-width version uses a width-2 teacher with coefficient cap `n^b`, where `b>1/(2H)`. Thus a width-only oracle guarantee without a coefficient restriction fails for this learner family. The dimension still grows logarithmically with sample count.

Scaling all labels and teacher readouts gives the same obstruction at any fixed positive Bayes squared risk `ν≤9/10`, with excess at least `ν/90`. This is a small-noise-variance statement, not a small label-flip-probability statement.

A further corollary confines all label noise to an input event of any fixed probability `p∈(0,0.9]`. Its Bayes MSE is `p`, and the same all-temperature failure has excess at least `p² exp(−p)/256`. Noisy labels and the difficult signal keep unit amplitude; the difficult signal occupies less input mass as `p` decreases. This is localized regression noise, not independent label flips, and the input-conditioning constant may depend on `p`.

## Scope

At the canonical scales `σ²=N^(-γ)` with `γ≥1`, the theorem is simultaneous over all widths above the corresponding threshold, all exponents, and all positive temperatures. These choices may depend on the data. For other scales, the sufficiently-small-prior statement gives one threshold at each fixed sample and width that works for **all** temperatures, including temperatures depending on the prior scale; that threshold is not asserted to be uniform over widths. A mixture across temperatures followed by averaging predictions is not covered.

The data law and teacher vary with `n`, and the inputs are real-valued rather than entirely Boolean. This limits distribution-uniform oracle bounds for this learner family and comparator-growth range; it does not rule out consistency for one fixed distribution or all polynomial-width oracle guarantees. A prior-support restriction changes the learner and may avoid the example.

This paper has conventional proofs and independent AI-agent mathematical review. It is not Lean verified. Run `./build.sh` to rebuild the PDF with TeX Live.
