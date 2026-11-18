# Agnostic Bayesian learning with nonexpansive internal layers

**[Paper (PDF)](paper.pdf) · [Source](source/paper.tex) · [Mathematical review](verification/review.md)**

Authors: ChatGPT-6 Astra, Claude Opus 5.5, Kaarel Hänni, Dmitry Vaintrob. Authors are listed in alphabetical order.

This paper proves a squared-loss comparison with the best small network under arbitrary bounded IID labels, including noise and model misspecification. The learner uses a specified dense Gaussian architecture, conditioned so that every hidden-to-hidden matrix has absolute row sums at most one. The teacher satisfies the same condition. Such internal layers cannot increase a perturbation measured in the coordinate maximum norm.

At fixed input dimension and teacher weight bound, the sufficient sample count is

```text
n = O_tilde((m² + Hm) / ε²),
```

where `m` is teacher width and `H` is the number of hidden layers. The learner may have any larger width. The result controls the **ordinary mean of the raw posterior outputs**, as well as posterior-average squared loss, with leading coefficient one on the best teacher's loss.

## Positive results

| Prior regime | Input domain | Guarantee |
|---|---|---|
| Strong-prior limit at each fixed learner width | Any distribution on `R^d` | The bound above at every eligible width; prescribed products of internal gains are also allowed |
| Actual finite prior, every `γ≥2` | Any distribution on `[-1,1]^d` | The same polynomial bound, on one sample event for every eligible width and every such exponent |
| Actual finite prior, one hidden layer, every `γ≥1` | Any distribution on `[-1,1]^d` | The same raw-output oracle bound |

The activations covered are continuous, odd, nondecreasing, 1-Lipschitz, and bounded by one. Examples include tanh, hardtanh, softsign, and a suitably scaled erf. Total depth is `L=H+1`, including the readout.

For teacher weights bounded by `B`, define

```text
E = d(d+1) B² + 2(H−1)m + 2m²B².
```

Up to logarithms, a sufficient sample count is

```text
n = O_tilde(((d+1)(E+1) + (mB+1)²) / ε²).
```

The finite-prior theorem adds terms of order `d+H` inside the resource budget; they are absorbed by the displayed polynomial when `B≥1`. The paper supplies explicit formulas before simplifying the rates.

At fixed dimension and depth, teachers may have width and weight bound `n^α` for any `α<1/4`. If the weight bound is fixed, widths up to `n^α` work for any `α<1/2`. Depth may grow too: with fixed dimension and weight bound, widths `n^α` and hidden depth `n^β` are allowed whenever `2α<1` and `α+β<1`. These comparator classes retain the internal row-sum restriction.

## A sharp limitation of this prior restriction

For two hidden tanh layers, the corresponding guarantee is **false at every `1≤γ<2`** under the same likelihood family and a calibration independent of learner width. On the constant input-label pair `(0,1)`, an admissible width-one teacher with weights bounded by two fits exactly. Yet at every fixed sample count, the posterior prediction tends to zero as learner width grows, so its test loss tends to one.

This is a theorem about the Gaussian prior **conditioned on the nonexpansive-row restriction**. It is not a counterexample to the collection's results for unrestricted Gaussian priors. The restriction improves capacity but also changes the prior's large-width function probabilities. The negative theorem permits arbitrary sample-dependent calibration `λ_n>0`, but does not rule out additional width-dependent likelihood schedules.

## Scope and proof idea

The learner's Gaussian likelihood has variance `n λ_n σ²`, where `λ_n` is the displayed deterministic calibration and `σ²=N^(−γ)` in the finite-scale theorem. The likelihood uses raw squared error; it is not exact interpolation of noisy labels. No prior over network sizes is introduced.

Absolute row-sum bounds turn hidden neurons into nested convex combinations. Rademacher contraction then bounds capacity using only readout energy, without a depth factor. Exact balanced cloning preserves the restriction at every learner width. Quadratic regularization gives the strong-prior result; a Gaussian comparison distribution and an entropy inequality extend it to finite scales.

The condition is a familiar sufficient Lipschitz constraint, but is conservative. It excludes internal amplification and can miss stability produced by signed cancellations. An arbitrary small tanh network need not admit an implementation satisfying it. The paper does not establish that the condition is typical of trained networks, nor does it give the same polynomial for unrestricted small MLPs.

For tanh there is a further depth caveat: unit internal row-sum bounds imply hidden amplitudes at depth `H` are at most `sqrt(3/(H+2))`. A width-`m` teacher with readout weights bounded by `B` therefore has output magnitude at most `mB sqrt(3/(H+2))`. At fixed width and readout bound, deep teachers in this class become small-amplitude; keeping a nonvanishing signal can require those resources to grow. This is not true for every activation covered by the theorem: hardtanh permits exact identity layers on `[-1,1]`.

## Verification and files

The paper received an independent AI-agent mathematical review covering the statements, raw-output bounds, all-width quantifiers, finite-scale comparison distribution, and the negative theorem. It is **not Lean formalized or human peer reviewed**.

The source consists of `source/paper.tex`, `source/finite-section.tex`, and `source/counterexample-section.tex`. Run `bash build.sh` to rebuild the PDF with pdfLaTeX.
