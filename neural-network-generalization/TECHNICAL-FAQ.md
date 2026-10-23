# Technical FAQ: Bayesian neural-network generalization

This FAQ explains what the current results say, which assumptions matter, where we expect extensions, and what the main open problems are. Each answer is meant to be readable on its own: it recalls the notation it uses and links to the questions that develop it. The papers themselves are listed in the [collection index](README.md).

**Status labels:** **Proved** means that the linked manuscript contains a proof under its stated assumptions. **Extension suggested by the proof** means that we have identified a plausible adaptation but are not citing a completed theorem. **Heuristic** is an informed expectation. **Open** means that the available results do not settle the question. **Numerical** means computer experiments at small sizes, which are evidence rather than proof. **Literature (abstract-level)** means a published result checked only against its abstract. Machine verification is a separate issue; see [Question 45](#45-how-much-of-this-is-formally-verified).

## Contents

**The model and its conventions.** [1. The model and the circuit prior](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here) · [2. Prior probability of a function](#2-can-we-bound-the-prior-probability-of-a-function) · [3. Boolean inputs](#3-how-important-is-it-that-the-inputs-are-boolean) · [4. Real-valued outputs](#4-are-the-network-outputs-boolean-and-what-happens-if-we-scale-them-up) · [5. Margins before training](#5-can-we-drop-the-global-margin-condition-imposed-on-every-input-before-training) · [6. Confidence thresholds](#6-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23) · [7. Mixtures of bad predictors](#7-why-are-mixtures-of-individually-bad-predictors-not-already-a-problem-at-23)

**Prior scalings and Gaussian limits.** [8. The one-parameter family of scalings](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings) · [9. Relation to NNGP and kernel regression](#9-how-do-the-nnbayes-results-here-relate-to-nngp-and-kernel-regression) · [10. Gaussian conditioning for $0<\gamma<1$](#10-does-a-quantitative-central-limit-theorem-make-all-0gamma1-into-gaussian-conditioning) · [11. The $\gamma<1$ learners at infinite width](#11-what-do-the-three-gamma1-learners-look-like-in-the-infinite-width-limit) · [12. General scaling tuples](#12-can-we-classify-all-tuples-of-layerwise-scaling-exponents) · [13. The usual NNGP scaling](#13-what-is-known-at-the-usual-nngp-scaling) · [14. A prior that prefers low threshold degree](#14-can-a-scaling-make-the-prior-prefer-something-other-than-small-circuits)

**Hard and easy targets for the $\gamma<1$ learners.** [15. Sparse parity](#15-for-gamma1-how-close-are-we-to-a-domegak-lower-bound-on-the-sample-complexity-of-sparse-xor) · [16. Is parity special?](#16-for-gamma1-is-the-bad-sample-complexity-specific-to-parity) · [17. Polynomially hard and cheap targets](#17-for-gamma1-which-targets-need-a-high-power-of-d-samples-and-which-are-cheap) · [18. Exponentially hard targets](#18-for-gamma1-which-targets-need-exponentially-many-samples) · [19. Comparison with SGD](#19-how-do-the-gamma1-learners-sample-costs-compare-with-what-sgd-needs) · [20. A target gradient descent can climb](#20-is-there-a-small-circuit-that-gradient-descent-learns-but-the-gamma1-learners-provably-cannot) · [21. Comparison with kernel regression](#21-do-the-gamma1-sign-posteriors-and-kernel-regression-find-the-same-targets-hard)

**Robustness and depth.** [22. The robustness condition](#22-what-robustness-condition-gives-polynomial-depth-dependence) · [23. Checking the condition](#23-how-can-we-check-whether-a-network-satisfies-the-robustness-condition) · [24. Trained networks](#24-do-gradient-trained-networks-satisfy-the-robustness-condition) · [25. Robustness near the data](#25-can-robustness-be-required-only-near-the-data-or-on-average) · [26. Depth without robustness](#26-is-exponential-depth-dependence-necessary-without-any-robustness-restriction) · [27. Depth above mean field](#27-without-a-robustness-restriction-which-targets-have-polynomial-learner-depth-bounds-above-mean-field) · [28. Depth at the critical scaling](#28-without-a-robustness-restriction-what-depth-dependence-does-the-critical-gamma1-prior-have) · [29. Teacher depth](#29-can-the-exponential-dependence-on-the-teachers-depth-be-removed-without-a-robustness-restriction)

**Explicit polynomials and stronger restrictions.** [30. The actual polynomials](#30-what-are-the-explicit-sample-complexity-polynomials-and-are-practical-sample-bounds-close) · [31. Shallow, Lean-checked, and unrestricted bounds](#31-what-do-the-shallow-lean-checked-and-unrestricted-deep-bounds-look-like) · [32. Neuron merging](#32-how-natural-is-the-neuron-merging-restriction) · [33. Alternatives to neuron merging](#33-are-there-more-natural-alternatives-to-neuron-merging-stability)

**Other weight priors and activations.** [34. Non-Gaussian weight priors](#34-do-independent-non-gaussian-weight-priors-give-the-same-results) · [35. Other activations](#35-what-about-relu-sigmoid-gelu-or-other-activations)

**Online learning and distribution shift.** [36. Total mistakes](#36-can-we-bound-the-total-number-of-mistakes-during-online-learning) · [37. Mistakes and circuit size](#37-does-making-few-mistakes-imply-that-the-target-has-a-small-circuit) · [38. Out-of-distribution learning](#38-why-expect-occam-learning-to-transfer-out-of-distribution)

**Label noise, likelihoods, and singular learning theory.** [39. Label noise](#39-do-the-good-generalization-results-survive-a-small-amount-of-label-noise) · [40. SLT likelihoods](#40-do-the-polynomial-bounds-survive-the-likelihood-based-setup-used-in-singular-learning-theory) · [41. Comparison with SLT bounds](#41-does-singular-learning-theory-already-give-comparable-generalization-bounds) · [42. Prior scaling and log-prior bounds](#42-can-prior-scaling-force-direct-prior-mass-bounds-to-depend-on-width-or-target-complexity)

**Status and outlook.** [43. Resolved and open problems](#43-which-original-open-problems-have-been-resolved-and-which-remain) · [44. Before explaining practical deep learning](#44-what-other-questions-matter-before-interpreting-this-as-an-explanation-of-practical-deep-learning) · [45. Formal verification](#45-how-much-of-this-is-formally-verified)

## 1. What is the basic model, and what does “a circuit prior” mean here?

**Proved, with several different quantifier orders.** The original model is a fully connected network with bounded hidden activations, usually tanh, and a real-valued linear readout $z_w(x)$. Inputs and target labels are Boolean: $x\in\lbrace -1,1\rbrace ^d$, $f(x)\in\lbrace -1,1\rbrace $. There are $L-1$ hidden layers of width $N$, a constant input coordinate, and no separate internal biases.

The original Gaussian prior is conditioned, before observing labels, on

$$
|z_w(x)|>1/2\qquad\text{at every Boolean input }x.
$$

The posterior then conditions on the observed training signs. Under that prior restriction, this is equivalent to requiring $f(X_i)z_w(X_i)>1/2$ at each noiseless training input. In the main results, training inputs are iid. Positive results allow an arbitrary input distribution, common to training and test, whereas the parity lower bounds use the uniform distribution. The separate noisy-interpolation result in [Question 39](#39-do-the-good-generalization-results-survive-a-small-amount-of-label-noise) uses distinct uniformly sampled inputs.

**Prior scalings.** The weights are independent centered Gaussians. Their variances either scale with width through an exponent $\gamma$ ($\gamma=1$ is mean field) or tend to zero at fixed width (the *strong-prior limit*); [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings) lists these regimes.

**What “circuit prior” means.** “Circuit prior” is a claim about the **prior on functions**: its preference for different functions approximately tracks the complexity of small circuits implementing them. In the strong-prior setting of the [original slides](https://kaarelh.github.io/ai/nnbayes-generalization.pdf), this is made precise through the Gaussian energy cost $\kappa_N(f)$, the infimum weighted squared parameter norm of a network realizing $f$ with signed margin greater than $1/2$ at every input. This cost determines the leading exponential order of prior probability ratios. It is polynomially related to the bounded-weight network complexity $C_L(f)$ defined below, at fixed depth and uniformly over all learner widths $N\ge C_L(f)$.

The sample-complexity theorem is a **consequence** of that prior-complexity comparison, together with a bound on the number of low-complexity competitors. A polynomial sample bound alone is not the definition of a circuit prior. “Approximately” here allows polynomial distortion and dimension/depth dependence; it does not assert an exact ordering of every pair by circuit size or efficient posterior sampling. [Question 2](#2-can-we-bound-the-prior-probability-of-a-function) gives the precise strong-prior comparison.

**Two comparator complexities.** The results measure the target's complexity in two different ways:

- The original $C_L(f)$ is the least width of a neural network of depth $L$ realizing $f$ with the prescribed margin and with every physical weight bounded by that width.
- The polynomial-depth generalization theorem under a robustness restriction ([Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence)) uses the width of a layered **Boolean** circuit at the required depth, counting constant wires and any compilation overhead.

These should not be interchanged without a representation theorem. See the [strong-prior paper](main-results/strong-prior-generalization/paper.pdf) and [robust polynomial-depth paper](main-results/robust-polynomial-depth/paper.pdf).

<a id="22-can-we-bound-the-prior-probability-of-a-function"></a>

## 2. Can we bound the prior probability of a function?

**Yes. In particular, the strong-prior argument establishes a prior-complexity comparison, not only a learning guarantee.** In the model of [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here), the Gaussian weight prior is conditioned on $|z_w(x)|>1/2$ at every Boolean input. The strong-prior argument fixes the width $N$ and lets the prior scale $\sigma$ tend to zero. The unconditioned Gaussian prior $\mu_{N,\sigma}$ has density proportional to $\exp[-\kappa_N(w)/(2\sigma^2)]$ for a weighted squared parameter norm $\kappa_N(w)$. Let $U_f$ be the set of weights realizing $f$ with the prescribed margin, $f(x)z_w(x)>1/2$ at every input. The argument identifies the fixed-width rate

$$
2\sigma^2\log\mu_{N,\sigma}(U_f)\longrightarrow-\kappa_N(f).
$$

Here $\kappa_N(f)$ is the infimum weighted squared parameter norm over networks realizing $f$ with the prescribed margin. For the globally margin-conditioned function prior $\pi_{N,\sigma}$, the common normalization cancels in ratios, so at fixed $d,L,N$, for functions $f,g$ realizable at width $N$ with the prescribed margin,

$$
\lim_{\sigma\downarrow0}2\sigma^2
\log\frac{\pi_{N,\sigma}(g)}{\pi_{N,\sigma}(f)}
=\kappa_N(f)-\kappa_N(g).
$$

Thus if $\kappa_N(g)>\kappa_N(f)$, the prior ratio $\pi_{N,\sigma}(g)/\pi_{N,\sigma}(f)$ tends to zero.

**Comparison with network complexity.** Let $C_L(f)$ be the bounded-weight network complexity of [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here): the least width of a network of depth $L$ realizing $f$ with the prescribed margin and every weight bounded by that width. Cloning and compression give the two directions of the complexity comparison: for fixed depth $L$, there are polynomials $P_L,M_L$, independent of learner width, such that for every $N\ge C_L(f)$,

$$
\kappa_N(f)\le P_L(d,C_L(f)),
\qquad
C_L(f)\le M_L(d,1+\kappa_N(f)).
$$

This is the circuit-prior claim of the [original slides](https://kaarelh.github.io/ai/nnbayes-generalization.pdf) in a quantitative form: prior preference is governed by a complexity measure polynomially equivalent to small-network complexity. It need not preserve the ordering of two functions with similar circuit sizes. Counting the functions whose energy is no greater than the target's then gives the strong-prior generalization theorem. In the [strong-prior paper](main-results/strong-prior-generalization/paper.pdf), $M_L(d,K)$ can be taken to be the compression width $m_L(d,\max\lbrace K,2\rbrace)$, displayed in [Question 31](#31-what-do-the-shallow-lean-checked-and-unrestricted-deep-bounds-look-like); this differs from the log-count $Q_L$ in that question's sample bound. See the Gaussian-rate lemma and the “Uniform count and complexity comparison” proposition in the same paper.

The main Lean gate certifies the learning theorem and the ingredients used in its proof; it does not separately assert this displayed two-sided complexity comparison as an additional main theorem. The [coverage inventory](lean/review/formal-coverage-inventory.txt) distinguishes these scopes; see also [Question 45](#45-how-much-of-this-is-formally-verified).

**Absolute prior mass at finite variance.** Write $\mu_{N,t}$ for the raw Gaussian prior with first-layer, internal, and readout variances $t^2/d$, $t^2/N$, and $t^2/N^2$; the family of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings) has $t^2=N^{1-\gamma}$. Finite-variance target-neighborhood constructions give lower bounds of the form

$$
\mu_{N,t}(\text{a target-realizing neighborhood})
\ge\exp[-(N/t^2)\,\mathrm{poly}(\text{target resources})].
$$

The [critical-depth paper](works-in-progress/critical-depth/paper.pdf) on $\gamma=1$ ([Question 28](#28-without-a-robustness-restriction-what-depth-dependence-does-the-critical-gamma1-prior-have)) gives a variational characterization and depth bounds for the corresponding rate. These answer parts of the slides' absolute prior-mass question. Absolute negative log probabilities can still grow with width or prior strength, consistently with the normalized rate comparison above.

**Growing absolute costs do not contradict width-independent learning.** The generalization argument controls competitors relative to the target, or compresses a posterior with controlled relative entropy. It need not pay the full raw $-\log\mu(U_f)$ as a sample bound. The globally conditioned function prior also includes a normalization denominator that must be retained for absolute probabilities and comparisons across different priors; it cancels when comparing two functions under the same prior, as above.

**Conversely, a tiny target probability alone is not a sample lower bound.** A prior can assign a target tiny mass while assigning almost all remaining mass to a single competitor that one informative example eliminates. Both this mistake and the omission of the global-conditioning denominator occurred in heuristic arguments discussed in the [appendix audit](side-results/strong-prior-appendix-audit/paper.pdf).

<a id="2-how-important-is-it-that-the-inputs-are-boolean"></a>

## 3. How important is it that the inputs are Boolean?

**Partly technical, partly substantive.** A finite domain permits the global margin conditioning of [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here), $|z_w(x)|>1/2$ at every input, as well as a finite list of Boolean functions and uniform compression over the input set. The cube has $2^d$ points, so a union bound over all inputs costs only $O(d)$ in a logarithm. Its Fourier structure is also central to the parity lower bounds ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)); those are not distribution-free lower bounds.

**The positive learning results extend to continuous inputs for real-valued regression.** The [continuous-domain paper](side-results/continuous-domains/paper.pdf) treats arbitrary input distributions on a compact subset of the unit ball, including the full sphere. The target is the real-valued output of a teacher network with depth $L$, width $C$, and weights bounded by $B$. At each fixed depth, the sample bound is polynomial in $d,C,B$ and accuracy parameters, independently of **every learner width $`N\ge C`$**. This holds in the strong-prior limit (width fixed, prior variance tending to zero) and for each finite scaling exponent $\gamma\ge1$, including mean field ($\gamma=1$), with Gaussian weights or the non-Gaussian family in [Question 34](#34-do-independent-non-gaussian-weight-priors-give-the-same-results). The proof uses an input net; the learner and data remain continuous.

The finite-scale regression theorem observes clean real-valued labels, accepts training error below a positive tolerance $\rho$, and requires test error at most a larger tolerance $\tau>\rho$. It controls the actual posterior's probability of meeting that test tolerance. A separate exact-interpolation result covers minimum-energy interpolants and Gaussian posteriors with the **strong-prior limit taken before the zero-tolerance limit**. Neither result assumes a teacher margin or a gap in the input distribution's support. Teacher weight magnitude is counted; a pure-width bound for arbitrarily large weights is not proved.

Depth is substantive in this extension: [Question 26](#26-is-exponential-depth-dependence-necessary-without-any-robustness-restriction) describes an exponential-depth regression lower bound at constant teacher width and bounded weights. The original Boolean-cube depth question remains open.

**Binary classification needs a distinction.** A continuous network with a nonzero absolute margin everywhere on a connected sphere has a constant sign. The original globally margin-conditioned learner therefore cannot simply be transplanted there. Training-only margin conditioning does give a learning theorem when the data support stays a positive teacher margin away from its decision boundary ([Question 5](#5-can-we-drop-the-global-margin-condition-imposed-on-every-input-before-training)). The corresponding unrestricted binary-label theorem on the full sphere remains open. These continuous-domain results are side results with conventional proofs, not Lean verified.

**Finite precision versus a change of prior.** An 8-bit pixel can be expressed exactly as a linear combination of eight Boolean bits. Composing that fixed decoder with a network preserves its computations and its internal-noise stability (the robustness condition of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence)) on the corresponding images. It does **not** identify the resulting tied first-layer weights with independent Gaussian weights on the bits, and checking real images does not check all bit strings.

<a id="3-are-the-network-outputs-boolean-what-if-we-scale-them-up"></a>

## 4. Are the network outputs Boolean, and what happens if we scale them up?

**In the main classification papers, the labels are Boolean and the network outputs are real.** Classification uses their signs, with output margins imposed in the prior or likelihood; the original model of [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here) conditions its prior on $|z_w(x)|>1/2$ at every input. The arguments do not require a network to output exactly $+1$ or $-1$. The [continuous-domain paper](side-results/continuous-domains/paper.pdf) also studies learning a teacher network's real-valued outputs directly, as described in [Question 3](#3-how-important-is-it-that-the-inputs-are-boolean).

**Scaling up the readout.** Multiplying the readout by $A>0$ preserves signs and can improve output margins, but multiplies its squared Gaussian energy by $A^2$ (the energy is the weighted squared norm in the exponent of the prior density; see [Question 2](#2-can-we-bound-the-prior-probability-of-a-function)). It is therefore not free in a Bayesian prior. In particular, an implementation that needs an enormous output scale to become stable need not give a polynomial prior-mass or sample bound in the original implementation's size.

For a finite input cube and nonzero clean outputs, sufficiently large readout amplification can eventually enforce the clipped-score stability condition of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence), which requires clipped outputs to survive small internal disturbances. This does not show that the **raw trained network** satisfies the condition, or that the required amplification has polynomial cost. The robust Boolean-circuit construction behind that question's theorem instead supplies a controlled implementation and a controlled neighborhood of prior mass around it.

**Open:** an equally general theory for real-valued regression with noisy observations, or for multiclass outputs. The continuous-domain regression theorem uses clean observations; its nonzero training tolerance is not a theorem about corrupted labels. Binary label noise is discussed in [Question 39](#39-do-the-good-generalization-results-survive-a-small-amount-of-label-noise).

<a id="4-can-we-drop-the-requirement-of-a-margin-on-every-input-before-training"></a>

## 5. Can we drop the global margin condition imposed on every input before training?

**Yes at fixed depth, while retaining a quantitative training margin.** The original model of [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here) conditions its Gaussian prior, before any labels are seen, on $|z_w(x)|>1/2$ at every input. The [continuous-domain paper](side-results/continuous-domains/paper.pdf) proves a classification theorem for the raw prior, without that conditioning, in the strong-prior and finite-scale $\gamma\ge1$ regimes of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings), at every width above teacher width. It assumes a bounded-weight teacher has a uniform positive signed margin on the input distribution's support. This includes the original finite Boolean targets. The theorem requires no internal-stability restriction on the prior, such as the robustness condition of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence), which keeps only networks whose clipped outputs survive small internal disturbances. The posterior conditions only on

$$
f(X_i)z_w(X_i)>1/2,
$$

and its correct-sign probability exceeds $2/3$ on almost all test inputs after polynomially many samples at fixed depth. The teacher-margin assumption is substantive on continuous supports: it excludes data arbitrarily close to a sign-changing decision boundary.

**For a bound jointly polynomial in depth,** the theorem under the internal-stability restriction described in [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence) also permits outputs arbitrarily close to zero at unobserved inputs. It uses the same training likelihood and bounds posterior test-margin error $f(X)z_w(X)\le1/4$, hence also sign error. Removing both restrictions while retaining a general polynomial-depth guarantee remains open.

The constants $1/2$ and $1/4$ are not fundamental. The robust argument has a version with training margin $m$, test threshold $u<m$, and quantitative dependence on the gap $m-u$. Taking $u=0$ addresses sign prediction directly. Merely conditioning on positive training signs with no quantitative training margin is a different problem.

The original subcritical lower bounds, for $\gamma<1$, also use their stated global conditioning. One cannot remove it from those proofs by changing only the test loss. See the [robust paper](main-results/robust-polynomial-depth/paper.pdf) and [subcritical paper](main-results/subcritical-exponential/paper.pdf).

<a id="5-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23"></a>

## 6. What changes if correctness means posterior probability above $1/2$, rather than $2/3$?

**For the positive results, only constants change. For the lower bounds the threshold matters, and the exact $1/2$ threshold is open in those arguments.** The usual criterion counts a test input as correctly predicted when the posterior gives its correct label probability greater than $2/3$.

**Two conversions.** Let $p_S(x)$ be the posterior probability of the correct label at input $x$, given the training sample $S$, and let

$$
R_S=\mathbb E_x[1-p_S(x)]
$$

be the error of a posterior draw, usually called Gibbs error. Here $x$ is drawn from the test distribution $D$, so $D\lbrace p_S\le q\rbrace$ is the fraction of test inputs that fail at threshold $q$. There are two different conversions:

$$
D\lbrace p_S\le q\rbrace \le \frac{R_S}{1-q},
\qquad
D\lbrace p_S\le q\rbrace \ge \frac{R_S-(1-q)}{q}.
$$

The second is informative only when its numerator is positive.

**Proved for all the positive results:** a small Gibbs error gives a small failure fraction at every fixed $q<1$, including $q=1/2$, $2/3$, and intermediate values. Only constants change. A posterior-majority classifier, with any tie rule, has error at most $2R_S$.

**For the lower bounds, the distinction matters.** The published proofs of the full-parity lower bounds at $0<\gamma<1$ and $\gamma=0$ ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)) give $R_S\ge3/8$ in the relevant limit. At $q=2/3$, the second conversion turns this into a failure fraction at least $1/16$. The displayed constant also works for every $q>5/8$. It says nothing at $q=1/2$.

**Extension suggested by the proof:** the cutoffs in those two proofs can be made smaller to bring the Gibbs lower bound closer to $1/2$, at the cost of a smaller exponential sample constant. This strongly suggests the same qualitative result for each fixed $q>1/2$. The stated main theorem is still the $2/3$ version; this FAQ is not a substitute for writing out that extension.

For $\gamma<0$, the direct confidence argument is different: a log-concavity step naturally reaches thresholds above $1-e^{-1}\approx0.632$. It does not establish the entire interval $q>1/2$. For the **critical** $\gamma=1$ polynomial parity lower bound of the [critical-depth paper](works-in-progress/critical-depth/paper.pdf), Gibbs error tends to $1/2$, so every fixed $q>1/2$ is covered, but majority failure still does not follow.

**Open in these lower-bound arguments:** the exact $1/2$ threshold. It is possible for $p_S(x)=0.5001$ at every input: Gibbs error is almost $1/2$, yet the posterior majority is correct everywhere. A result about confidence bounded away from $1/2$ is therefore not automatically a result about majority prediction. The distinction between $<$, $\le$, and the rule for ties should also be specified when stating an exact theorem.

<a id="6-why-are-mixtures-of-individually-bad-predictors-not-already-a-problem-at-23"></a>

## 7. Why are mixtures of individually bad predictors not already a problem at $2/3$?

**Because the lower bound controls their average error by enough to cross that threshold.** For $0<\gamma<1$, the width-limit posterior concentrates on minimum-energy sign functions consistent with the data, and tied minimizers may receive any weights ([Question 11](#11-what-do-the-three-gamma1-learners-look-like-in-the-infinite-width-limit)). It may therefore mix several bad predictors. Its Gibbs error $R_S$, the error of one posterior draw, is their weighted average error.

If every minimum-energy sign function has error at least $3/8$, every mixture of them has Gibbs error at least $3/8$. The second conversion of [Question 6](#6-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23), $`D\lbrace p_S\le q\rbrace\ge (R_S-(1-q))/q`$ at $q=2/3$, then forces a $1/16$ fraction of inputs to have correct-label probability at most $2/3$, regardless of the mixture weights. Here $p_S(x)$ is the posterior probability of the correct label and $D$ is the test distribution.

A majority of bad predictors can nevertheless be accurate. Their mistakes may occur on different inputs. Thus the proof never needed a unique minimizer for its $2/3$ conclusion, but a majority lower bound would require additional information about how the minimizers' errors align; [Question 6](#6-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23) discusses the exact threshold $1/2$.

In each regime, the relevant quantities are the Gibbs-error bound, the requested confidence threshold, and any additional control over how the predictors vote at individual inputs.

<a id="8-what-is-actually-known-for-the-one-parameter-family-of-scalings"></a>

## 8. What is known for the one-parameter family of prior scalings?

**At fixed depth, the strong-prior limit and every $\gamma\ge1$ give polynomial sample bounds at every learner width $`N\ge C_L(f)`$, while every $\gamma<1$ gives an exponential lower bound for full parity.**

The learner is the Bayesian posterior for the network of [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here): a fully connected network with bounded hidden activations, usually tanh, and $L-1$ hidden layers of width $N$. Its Gaussian weight prior is conditioned on an output margin at every Boolean input and then on exact training labels. The one-parameter family sets the entry **variances**, not standard deviations, by an exponent $\gamma$:

$$
\mathrm{Var}\,W^1=N^{1-\gamma}/d,
\qquad \mathrm{Var}\,W^s=N^{-\gamma}\ (1<s<L),
\qquad \mathrm{Var}\,v=N^{-\gamma-1}.
$$

Here $W^1$ is the first layer, $W^s$ an internal layer, and $v$ the readout. Larger $\gamma$ means smaller variances. The value $\gamma=1$ is the mean-field, or critical, scaling; $\gamma<1$ is called subcritical. The **strong-prior limit** instead fixes the width and lets the prior variance tend to zero ([Question 2](#2-can-we-bound-the-prior-probability-of-a-function)). The target complexity $C_L(f)$ is the least width of a depth-$`L`$ network realizing $f$ with the prescribed margin and weights bounded by that width.

The table concerns this particular family and the indicated conditioning conventions.

| Regime | Current conclusion | Important qualification |
|---|---|---|
| Strong-prior limit at fixed $N$ | Prior rate polynomially equivalent to bounded-weight network complexity at fixed depth; consequently polynomial samples, uniformly in the sample bound over all $N\ge C_L(f)$. | Variance tends to zero **after fixing width**; no width-uniform variance threshold. |
| Fixed $\gamma>1$ | Polynomial samples at fixed depth for every actual $N\ge C_L(f)$. Unrestricted results also remove bad learner-depth dependence for substantial target classes ([Question 26](#26-is-exponential-depth-dependence-necessary-without-any-robustness-restriction)). | The original bound depends on the gap above one; the [unified activation theorem](works-in-progress/unbounded-activations/) removes that dependence with one polynomial for all $\gamma\ge1$. Its degree still depends on depth. The full arbitrary-deep-target problem remains open. |
| $\gamma=1$ | Polynomial samples at each fixed depth, every actual $N\ge C_L(f)$. Without a robustness restriction, the critical theorem ([Question 28](#28-without-a-robustness-restriction-what-depth-dependence-does-the-critical-gamma1-prior-have)) also gives polynomial learner-depth bounds at every realizable width for low-Fourier-variation targets, including all parities at sufficient logarithmic depth. With the robustness restriction ([Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence)), jointly polynomial dependence on depth for Boolean-circuit targets. | Joint polynomial dependence on arbitrary teacher width and depth for the unrestricted prior remains open. |
| $0<\gamma<1$ | A Gaussian minimum-energy description at leading exponential order; exponential full-parity confidence lower bound. | This is not exact Gaussian-posterior equivalence throughout the interval. Limits are width first. |
| $\gamma=0$ | A fixed-margin globally conditioned Gaussian limit; exponential full-parity confidence lower bound. | The global margin remains in the limiting law. |
| $\gamma<0$ | After output normalization, a Gaussian law conditioned on training signs; exponential full-parity and stronger sparse-parity lower bounds ([Question 15](#15-for-gamma1-how-close-are-we-to-a-domegak-lower-bound-on-the-sample-complexity-of-sparse-xor)). | The original fixed margin vanishes under this normalization. |

[Question 11](#11-what-do-the-three-gamma1-learners-look-like-in-the-infinite-width-limit) describes the three $\gamma<1$ limits, [Question 10](#10-does-a-quantitative-central-limit-theorem-make-all-0gamma1-into-gaussian-conditioning) explains the leading-order qualification at $0<\gamma<1$, and [Question 12](#12-can-we-classify-all-tuples-of-layerwise-scaling-exponents) treats general layerwise scalings.

The $\gamma\le0$ exponential result is included in the [main subcritical paper](main-results/subcritical-exponential/paper.pdf), which covers every $\gamma<1$; it is not an omitted fifth scaling result. The [collection index](README.md) separates the main papers and supporting results.

<a id="7-how-do-the-nnbayes-results-here-relate-to-nngp-and-kernel-regression"></a>

## 9. How do the NNBayes results here relate to NNGP and kernel regression?

**The learners of the main positive results are not the usual NNGP: they need no infinite-width limit, and their prior scalings differ from the usual NNGP scaling. Where a Gaussian-process (GP) description does apply, as in some lower bounds, the conditioning and the prediction rule are further distinctions.**

Here NNBayes means exact Bayesian inference over the weights of the network of [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here), with the Gaussian prior scalings of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings), indexed by an exponent $\gamma$. The NNGP (neural-network Gaussian process) is the GP that a random network's output approaches as width grows at the usual fan-in scaling. Kernel regression is the posterior mean of a GP given real-valued labels.

**Width and prior scaling are the first distinctions for the main positive learning results.**

- **No infinite-width limit is required.** The positive theorems apply at every actual learner width above the relevant target complexity, including widths close to that complexity. They also cover arbitrarily large finite widths. In the strong-prior theorem, width is fixed before the prior variance tends to zero.
- **The prior scalings differ from the usual nondegenerate NNGP scaling.** For example, at $\gamma=1$ the readout-weight variance scales as $N^{-2}$, whereas the standard NNGP parameterization uses $N^{-1}$. Taking a large width alone therefore does not justify replacing these learners by the usual NNGP. [Questions 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings) and [12](#12-can-we-classify-all-tuples-of-layerwise-scaling-exponents) give the layerwise scalings.

**Conditioning and prediction rules are additional distinctions where a GP description does apply.** These matter for the Gaussian limits used in some lower bounds and for the separate NNGP note below. A Gaussian-process prior conditioned on training signs is not the same posterior as Gaussian regression conditioned on exact real output values. Conditioning additionally on an absolute margin at every input changes it again. Moreover,

$$
\mathrm{sign}\,\mathbb E[z(x)\mid S]
\quad\text{and}\quad
\mathrm{sign}\,\mathbb E[\mathrm{sign}\,z(x)\mid S]
$$

are different prediction rules: a few large-magnitude outputs can affect the former without affecting the latter in the same way.

A small parity eigenvalue, or poor correlation of the regression mean, is therefore not by itself a lower bound for the posterior-confidence convention used here. This was a substantive gap in the kernel discussion of the [original slides](https://kaarelh.github.io/ai/nnbayes-generalization.pdf). The later lower bounds analyze the appropriate conditioned law. For targets other than parity the two notions come apart further: majority is costly for squared-error regression but cheap for the sign posteriors ([Question 21](#21-do-the-gamma1-sign-posteriors-and-kernel-regression-find-the-same-targets-hard)).

Nor does every Gaussian rate description identify an exact GP posterior: this distinction is important for $0<\gamma<1$, as explained in [Question 10](#10-does-a-quantitative-central-limit-theorem-make-all-0gamma1-into-gaussian-conditioning).

**Related Gaussian-process lower bounds.** There is a separate [NNGP note](side-results/nngp-sample-complexity/paper.pdf) with an exponential confidence lower bound for a deep, variance-normalized tanh GP family. Its depth grows with the input dimension. It should not be silently substituted for the fixed-depth theorem for all $\gamma<1$.

At fixed depth and the usual NNGP scaling, a [later side result](side-results/standard-nngp-parity/paper.pdf) proves superpolynomial and nearly exponential confidence lower bounds for full parity; [Question 13](#13-what-is-known-at-the-usual-nngp-scaling) states them. Whether $\exp(\Omega(d))$ samples are needed at that scaling is open.

## 10. Does a quantitative central limit theorem make all $0<\gamma<1$ into Gaussian conditioning?

**At leading exponential order, yes; for posterior probabilities, no.** Here $\gamma$ is the exponent of the layerwise prior scaling of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings), and width is taken to infinity first. Moderate deviations justify a Gaussian rate function in this interval. At that order, the learner has the Gaussian minimum-energy description of [Question 11](#11-what-do-the-three-gamma1-learners-look-like-in-the-infinite-width-limit). But conditioning on rare events can magnify smaller corrections that a leading-rate approximation discards.

The [Gaussian-conditioning paper](side-results/subcritical-gaussian-conditioning/paper.pdf) proves a relative approximation in the range $0<\gamma<1/2$, under its stated finite-domain assumptions, and gives an actual tanh-network counterexample at and above $\gamma=1/2$. Covariance fluctuations generate a correction on the scale $N^{2\gamma-1}$. This is smaller than the leading $N^\gamma$ rate, but can change the relative weights of tied minimum-energy functions. It can even change whether posterior confidence exceeds $2/3$, the correctness criterion of [Question 6](#6-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23).

Thus the moderate-deviation intuition was useful and partly correct. The stronger claim “the whole posterior is just a Gaussian conditioned on the observations throughout $\gamma<1$” is false. The exponential parity lower bound of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings) survives because it controls all the relevant minimizers, rather than choosing Gaussian mixture weights among ties; [Question 7](#7-why-are-mixtures-of-individually-bad-predictors-not-already-a-problem-at-23) explains why that suffices at the $2/3$ threshold.

## 11. What do the three $\gamma<1$ learners look like in the infinite-width limit?

**All three are described by one arcsine kernel $K$ on the Boolean cube.** At $\gamma<0$, after output normalization, the posterior is a Gaussian process with covariance $K$ conditioned on the training signs. At $\gamma=0$, the same process is also conditioned on a fixed margin at every input. For $0<\gamma<1$, the posterior concentrates on the signs of the functions of least squared $`K`$-norm that satisfy a margin at every input and the training signs.

The three **$\gamma<1$ learners** are the regimes $\gamma<0$, $\gamma=0$ and $0<\gamma<1$ of the one-parameter family of prior scalings in [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings). Each is the Bayesian posterior for the network of [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here): a tanh network on $\lbrace -1,1\rbrace ^d$ with $L-1$ hidden layers of width $N$ and a constant input coordinate, whose Gaussian weight prior is conditioned on a global output margin and then on exact training labels. All limits here are width first: $N\to\infty$ with the dimension $d$, the depth $L$, and the training sample fixed.

**The kernel.** As the width tends to infinity at fixed $\gamma<1$, the hidden preactivations diverge and tanh acts as a sign function. Each layer then maps the correlation between two inputs through the arcsine function $\Psi$ below. The three $\gamma<1$ learners are thus described by one kernel on the cube:

$$
K(x,y)=\Psi^{\circ(L-1)}\left(\frac{1+x\cdot y}{d+1}\right),\qquad \Psi(t)=\frac2\pi\arcsin t .
$$

The $1$ is the constant input coordinate.

**The three limits.**

- **$`\gamma<0`$.** After the output normalization of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings), the posterior is the law of a centered Gaussian process $G$ on the cube with covariance $K$, conditioned on the training signs. The original fixed margin vanishes under this normalization.
- **$`\gamma=0`$.** $G$ is also conditioned on a fixed absolute margin, $\lvert G(x)\rvert>a$ at every input, where $a>0$ comes from the global output-margin condition of [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here).
- **$`0<\gamma<1`$.** The posterior concentrates on the signs of the functions $v$ that minimize the energy $v^{\mathsf T}K^{-1}v$, the squared $`K`$-norm, subject to two constraints: $\lvert v(x)\rvert\ge a$ at every input, and the correct signs at the training inputs. Tied minimizers may receive any weights: as [Question 10](#10-does-a-quantitative-central-limit-theorem-make-all-0gamma1-into-gaussian-conditioning) explains, this Gaussian description holds at leading exponential order, and smaller corrections can change the relative weights of ties.

**Error criteria.** As in [Question 6](#6-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23), the **Gibbs error** is the expected error of one posterior draw. The **confidence failure** is the fraction of test inputs at which the posterior gives the correct label probability at most $2/3$.

These are the learners for which [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings) records exponential full-parity lower bounds. [Questions 15](#15-for-gamma1-how-close-are-we-to-a-domegak-lower-bound-on-the-sample-complexity-of-sparse-xor) to [21](#21-do-the-gamma1-sign-posteriors-and-kernel-regression-find-the-same-targets-hard) study which other targets they find hard or cheap.

<a id="9-can-we-classify-all-tuples-of-layerwise-scaling-exponents"></a>

## 12. Can we classify **all** tuples of layerwise scaling exponents?

**We don't have learning results for all exponent tuples.** Off the one-parameter line of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings), the usual NNGP (neural-network Gaussian process) tuple has proved parity lower bounds ([Question 13](#13-what-is-known-at-the-usual-nngp-scaling)), and one collapsed one-hidden-layer region has a proved prior ordering ([Question 14](#14-can-a-scaling-make-the-prior-prefer-something-other-than-small-circuits)). This answer describes the heuristic layer-collapse argument of the original slides, explains why it is not a proof, and lists our predictions with their status.

**Notation.** Write a general variance tuple as

$$
\mathrm{Var}\,W^1=c_1N^{-a_1}/d,
\quad \mathrm{Var}\,W^s=c_sN^{-a_s},
\quad \mathrm{Var}\,v=c_LN^{-a_L}.
$$

Here $W^1$, $W^s$ with $1<s<L$, and $v$ are the first-layer, internal, and readout weights of the network of [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here), $N$ is its width, and the gains $`c_s>0`$ are constants. Our one-parameter family of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings), with exponent $\gamma$, occupies only the line

$$
(a_1,a_2,\ldots,a_{L-1},a_L)
=(\gamma-1,\gamma,\ldots,\gamma,\gamma+1).
$$

In contrast, the usual nondegenerate tanh NNGP scaling is $(0,1,\ldots,1,1)$. All discussion below fixes depth and dimension before taking width to infinity, and retains our global output-margin and exact-label conditioning conventions.

**What is the layer-collapse argument?** The [original slides](https://kaarelh.github.io/ai/nnbayes-generalization.pdf) try to reduce the many layer scales to a small number of effective learners by asking where it is cheapest to perform the computation. They first assume that the *conditioned* network has order-one hidden preactivations: no hidden layer becomes nearly linear through vanishing amplitudes, or fully saturated through diverging amplitudes. They also take the first layer to be a fixed random embedding. Under those assumptions, the proposed argument is:

1. **Assign each layer a price.** With order-one incoming activations, making a positive fraction of a hidden layer's neurons perform a specified task has a Gaussian energy price of order $p_s=1/\sigma_s^2=N^{a_s}$, when this is a rare event. A single readout has price $p_L=1/(N\sigma_L^2)=N^{a_L-1}$. Prices here mean negative log-probability scales; they omit representation entropy and the task's geometry.
2. **An expensive layer followed by a cheaper one can shrink and amplify.** Suppose a useful feature comes from the term of degree $k$ in tanh's Taylor expansion. Shrinking the incoming weights by $t$ makes that feature smaller by $t^k$. Amplifying it downstream by $t^{-k}$ restores its size. The schematic cost is $p_s t^2+p_{s+1}t^{-2k}$, minimized at $t_{\mathrm{opt}}=(k p_{s+1}/p_s)^{1/(2k+2)}$.

   If the earlier layer is increasingly more expensive, the optimum has $t\to0$. This is the proposed **collapse**: a layer operates near zero, and a later layer amplifies its small signal. Recovering a particular nonlinear term also requires cancelling lower Taylor terms; simple amplification alone does not do that. The slides exclude this outcome using their order-one-activation assumption. They do not classify the collapsed learner.
3. **A cheaper prefix followed by an expensive suffix might finish early.** The proposed “truncation” is to compute the answer in the cheap prefix and have the expensive tail transmit it. The resulting prior would resemble a shallower learner. This step needs an efficient way to move the computation into the prefix; universal approximation alone does not provide one.
4. **Balance the remaining live layers.** If the internal variances are comparable, equating their price to the readout price gives $a_L=a_s+1$. At the fan-in scale $a_s=1$, changing an empirical feature distribution costs order $N$, whereas forcing a margin through the readout costs order $N^{a_L-1}$. Their competition occurs at $a_L=2$, the critical case. This motivates the slides' kernel/feature-learning picture.

**Why isn't that a proof?** For several inputs at once, prescribing preactivations $u$ from an incoming feature matrix $A$ costs $u^\top(AA^\top)^+u/(2\sigma^2)$, when feasible. The full Gram matrix controls which computations are possible and affordable. Scalar prices miss its rank and conditioning, representation entropy, and changes in earlier features induced by later labels. Collapsing, saturating, and unequal-depth representations are also legitimate possibilities for the actual prior. [Appendix I of the audit](side-results/strong-prior-appendix-audit/paper.pdf) explains these gaps. The heuristic is useful, but its standing assumption excludes part of the space we want to understand.

**Amplitude bookkeeping.** Outside that assumption, let typical *unconditioned* hidden activation variance scale as $N^{-h_s}$. For fixed-depth tanh networks the amplitude heuristic is

$$
h_1\approx\max\lbrace a_1,0\rbrace ,\qquad
h_s\approx\max\lbrace a_s+h_{s-1}-1,0\rbrace ,
$$

and output variance has scale $N^{1-a_L-h_{L-1}}$. A negative value before taking a maximum indicates diverging preactivations and saturation. This recursion helps locate possible linear or saturated layers; it does not determine what rare conditioning selects.

**Do we still expect just circuit learning versus exponential sample complexity?** Those remain useful broad possibilities, but we would not currently conjecture an exhaustive two-way classification of *all* tuples. In particular, a different prior mechanism need not imply a different sample-complexity outcome. Here are concrete predictions, with their status:

| Exponent tuples | Prediction and current status |
|---|---|
| $a_1\le0$, every internal $a_s\le1$, and $a_L<2$ | **Conjectured frozen-feature region.** Hidden activations remain order one, possibly saturated. With a nondegenerate limiting kernel and empirical-kernel deviations costing order $N$, forcing margins costs only $N^{a_L-1}=o(N)$ when $1<a_L<2$. Thus conditioning should leave the leading kernel fixed. Exponential parity sample bounds are plausible but still require a spectrum and posterior-confidence argument for these kernels. The usual NNGP tuple $(0,1,\ldots,1,1)$ lies in this region and now has proved superpolynomial and nearly exponential lower bounds; see [Question 13](#13-what-is-known-at-the-usual-nngp-scaling). |
| Exact fan-in hidden scaling $(0,1,\ldots,1,a_L)$ with $a_L\ge2$ | **Conjectured circuit-learning side.** The endpoint $a_L=2$, which is $\gamma=1$ on the one-parameter line, is proved in our critical results ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)). For $a_L>2$, changing features can be cheaper than forcing the output through fixed features; we expect positive learning results, but output-dominated saturation and subleading costs need analysis. This does not assert the same circuit-prior ordering at every exponent. |
| One hidden layer: $(a_1,a_L)=(a,b)$ with $a>0$ and $a\le b\le a+2$ | **Tentative larger circuit-learning region.** Using $M=N^{(b-a)/2}$ active neurons balances feature cost $MN^a$ against readout cost $N^b/M$. At $b=a+2$ (so $M=N$) this is the one-hidden-layer case of the established $\gamma=a+1>1$ family (main result 2 in the [collection index](README.md)). In the interior, the active block is itself a $\gamma'=(a+b)/(b-a)>1$ network at its own width $M$, which suggests that a smaller active population can suffice. A construction alone does not control the remaining neurons or the posterior. |
| One hidden layer: $a>b>1$ | **Proved degree-based prior ordering; learning rate open.** The collapsing layer produces the threshold-degree hierarchy of [Question 14](#14-can-a-scaling-make-the-prior-prefer-something-other-than-small-circuits). It is not a circuit-size prior, but it could still have exponential parity sample complexity. |

In the frozen-feature prediction, $a_L<1$ gives a normalized GP with vanishing absolute margin, $a_L=1$ retains a fixed global margin, and $1<a_L<2$ gives a Gaussian minimum-energy description at leading order; compare the three $\gamma<1$ learners of [Question 11](#11-what-do-the-three-gamma1-learners-look-like-in-the-infinite-width-limit), which have $`a_L=\gamma+1`$. The last statement does not determine posterior weights among tied minimizers ([Question 10](#10-does-a-quantitative-central-limit-theorem-make-all-0gamma1-into-gaussian-conditioning)). These distinctions already occur within the proposed hard-learning side.

## 13. What is known at the usual NNGP scaling?

**Proved: superpolynomial and nearly exponential lower bounds for full parity. Open: whether $\exp(\Omega(d))$ samples are needed.**

The usual NNGP (neural-network Gaussian process) tuple is another scaling with a result, besides the one-parameter family of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings). In the notation of [Question 12](#12-can-we-classify-all-tuples-of-layerwise-scaling-exponents), a prior scaling is a tuple of exponents $`(a_1,\ldots,a_L)`$: layer $s$ of a width-$`N`$ network has weight variance $`c_sN^{-a_s}`$, divided by $d$ in the first layer, with constant gains $`c_s`$. The usual NNGP scaling is the tuple $(0,1,\ldots,1,1)$, which is not on the one-parameter line $(\gamma-1,\gamma,\ldots,\gamma,\gamma+1)$.

At $(0,1,\ldots,1,1)$, hidden preactivations stay of order one. The width limit is therefore the NNGP kernel of the activation itself, not the arcsine kernel of the $\gamma<1$ line ([Question 11](#11-what-do-the-three-gamma1-learners-look-like-in-the-infinite-width-limit)). Since $a_L=1$, the global margin survives in the limit, as at $\gamma=0$.

The results concern two learners. The **margin learner** conditions the prior on a global output margin at every input, as in [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here), before conditioning on the training signs; the **sign-only learner** conditions on the training signs only. An input fails when the posterior does not give its correct label probability above $2/3$, the criterion of [Question 6](#6-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23). The [standard-scaling paper](side-results/standard-nngp-parity/paper.pdf) proves the following lower bounds for full parity on $d$ bits, at fixed depth and any layer gains, with width taken to infinity first.

- **Global margin, $\tanh$ (proved).** For large $d$, with probability at least $1-e^{-d/10}$ over the sample, $n\le\exp(\frac1{20}\sqrt d\log d)$ uniform iid examples leave at least $1/16$ of the inputs without correct-label probability above $2/3$.
- **Training signs only, every training set (proved).** This is the limit of the margin learner when $a_L<1$, and the learner without the global margin at $a_L=1$. For every bounded continuous nonconstant activation, every depth and every gain, every training set of size $n\le d^{\sqrt d/10-1/2}/6000$ fails on at least a quarter of the inputs. That includes deliberately chosen training sets.
- **Training signs only, typical samples, $\tanh$ (proved).** $n\le\exp(10^{-3}d\log\log d/\log d)$ uniform iid examples leave at least $3/8$ of the inputs failing, with probability at least $13/16$. It is proved only for $d\ge d_0$, where $d_0$ is explicit but astronomically large. Its coercivity input is a theorem of the Lean project; the rest of the proof is conventional.

**Open:** whether $\exp(\Omega(d))$ samples are needed, as on the $\gamma<1$ line.

- For the sign-only learner, the proof suggests this would follow from two log-free sampling estimates at linear degree.
- For the margin learner, the paper proves that the per-sample conditioning-cost bound used by the subcritical proof fails at this tuple. The subcritical proof is the proof of the exponential $\gamma<1$ parity lower bound of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings).

So far this tuple sits on the hard-learning side, as the frozen-feature prediction of [Question 12](#12-can-we-classify-all-tuples-of-layerwise-scaling-exponents) expects. The proved exponents are not yet the exponential one.

## 14. Can a scaling make the prior prefer something other than small circuits?

**Yes (proved): for one hidden tanh layer in a collapsed scaling region, the prior prefers functions of low (odd-rounded) polynomial threshold degree, rather than small circuits. This is a prior ordering, not a sample-complexity result; the learning rate is open.**

In the exponent notation of [Question 12](#12-can-we-classify-all-tuples-of-layerwise-scaling-exponents), consider the network of [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here) with one hidden tanh layer of width $N$. Its independent Gaussian weights have variance $`c_1N^{-a}/d`$ in the first layer and $`c_2N^{-b}`$ in the readout, so the tuple is $`(a_1,a_L)=(a,b)`$. The one-parameter family of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings) has $b=a+2$. This answer concerns $a>b>1$, where the table in [Question 12](#12-can-we-classify-all-tuples-of-layerwise-scaling-exponents) places a collapsing layer: in the layer-collapse heuristic described there, a layer operates near zero and a later layer amplifies its small signal.

**In this region, a collapse calculation can actually be made rigorous.** For a Boolean function $f$, let $r(f)$, its polynomial threshold degree, be the smallest degree of a real polynomial whose sign equals $f$; [Question 17](#17-for-gamma1-which-targets-need-a-high-power-of-d-samples-and-which-are-cheap) writes $\mathrm{thr}(f)$. Let $k$ be the smallest positive odd integer at least $r(f)$. Let $`A_{N,f}`$ be the event that the network implements $f$ with the global margin: $f(x)z(x)>1/2$ at every input $x$, where $z$ is the network output. Then its raw prior probability satisfies

$$
\Pr(A_{N,f})=\exp\!\left[-\Theta_f\!\left(N^{(ka+b)/(k+1)}\right)\right].
$$

The [proof note](works-in-progress/scaling-tuples/README.md) supplies matching Taylor-expansion lower bounds and finite-neuron constructions, and converts their energy costs into Gaussian probability bounds. Consequently, after conditioning on any fixed training set, the width-first posterior first minimizes **odd-rounded polynomial threshold degree** among consistent functions. Constants and widths in this result are not uniform in growing dimension; the proof has independent AI-agent checks but is not Lean verified.

**This can sharply disagree with circuit size.** For even dimension, full parity is less probable asymptotically than every other Boolean function except its negation, including functions of exponentially greater circuit complexity. However, excluding the exact target from the limiting posterior does not imply poor test predictions: the remaining functions might be almost correct. So this result establishes a distinct prior-ordering mechanism, **not a third sample-complexity phase or an exponential sample lower bound**. Establishing the learning behavior of this explicit collapsed region is a useful next test of the broad dichotomy between circuit learning and exponential sample complexity proposed in [Question 12](#12-can-we-classify-all-tuples-of-layerwise-scaling-exponents).

<a id="11-for-gamma1-how-close-are-we-to-a-domegak-lower-bound-on-the-sample-complexity-of-sparse-xor"></a>

## 15. For $\gamma<1$, how close are we to a $d^{\Omega(k)}$ lower bound on the sample complexity of sparse XOR?

**Proved at the natural sparse scale for $\gamma<0$. For $0<\gamma<1$, the proved bounds give $\exp(\Omega(k))$; for growing $k$, the full natural scale is open there and at $\gamma=0$.**

Sparse XOR is the parity of $k$ of the $d$ input bits. The **$\gamma<1$ learners** are the Bayesian posteriors of [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here) at the prior scalings $\gamma<0$, $\gamma=0$ and $0<\gamma<1$ of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings), with width taken to infinity first ([Question 11](#11-what-do-the-three-gamma1-learners-look-like-in-the-infinite-width-limit)). A test input fails the **$2/3$ confidence criterion** when its correct label gets posterior probability at most $2/3$ ([Question 6](#6-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23)).

**The natural scale** is

$$
\exp\!\left(\Omega\!\left(k\log\frac{ed}{k}\right)\right).
$$

Here $k$ is the parity size and $d$ the ambient dimension. For $k\le d^{1-\eta}$ with fixed $\eta>0$, this is $d^{\Omega(k)}$. For $k=d$, it becomes exponential in $d$, as it must: observing most of the finite input space is enough.

**Proved for $\gamma<0$:** the natural sparse scale, at the $2/3$ confidence criterion, with width taken first. The theorem's universal failure fraction is positive but small; it is not a claim of, say, 10% error.

**Proved for $0<\gamma<1$:** for growing sparse parity, a lower bound of the form

$$
n\le\exp\!\left(c\max\left\lbrace k,\sqrt{k}\log\frac{e(d+1)}{\sqrt{k}}\right\rbrace \right).
$$

This includes the desired $\exp(\Omega(k))$ obstruction, but does not give the full natural sparse scale. Two further results:

- For $k\le d^{1-\eta}$, a [refinement](side-results/intermediate-parity/paper.pdf) proves failure at specified sample sizes $n$ with $\log n$ of order $\max\lbrace k^{\theta}\log(ed/k),\,k[\log(ed/k)]^{2-1/\theta}\rbrace$, where $`\theta=\theta_L\in(1/2,1)`$ and $`\theta_2\approx0.719`$. It does not assert failure at every smaller $n$.
- When depth grows as $`\log_2\log\log d+O(1)`$ and $`d^{\eta_1}\le k\le d^{1-\eta_2}`$, the [growing-depth paper](side-results/growing-depth-parity/paper.pdf) reaches the natural scale at specified sample sizes.

Neither settles the fixed-depth natural scale.

**Open:** that full growing-sparse scale for $0<\gamma<1$, and the corresponding growing-sparse endpoint problem at $\gamma=0$.

**There is a genuine regime distinction at small $k$.** A one-coordinate parity learns with $O(\log d)$ examples for $0<\gamma<1$. A uniform $d^{ck}$ claim covering all $k\ge1$ in that regime is therefore false. This does not disprove the proposed bound restricted to sufficiently growing $k$.

**Random versus selected training sets.** See the [sparse parity](side-results/sparse-parity/paper.pdf) and [growing positive-subcritical parity](side-results/growing-sparse-positive/paper.pdf) papers. Their results are for iid samples, not lower bounds for an active learner allowed to choose informative inputs. Typical sampling is essential for $0<\gamma<1$: [deliberately selected](side-results/selected-examples-parity/paper.pdf) training sets of size $`d^{O_\delta(\sqrt k)}`$ teach sufficiently large odd $k$ when $`d\ge(C_Lk)^{C_Lk}`$.

For $\gamma<0$, a [later work-in-progress note](works-in-progress/beyond-parity/README.md), with independent AI-agent checks only, gives a lower bound for every training set, selected or not. For any fixed $c\le1/2$ and large $k$, fewer than $(d/\sqrt k)^{c\sqrt k}$ examples leave the confidence-failure fraction above a constant depending on $c$. This uses its Proposition 3 with $r\asymp\sqrt k$ and the Aspnes–Beigel–Furst–Rudich bound. The exponent has the same order as the selected-set upper bound above. Whether selected sets of that size suffice at $\gamma<0$ is open.

For parities of fixed size $k\ge2$, [Question 17](#17-for-gamma1-which-targets-need-a-high-power-of-d-samples-and-which-are-cheap) gives explicit power-of-$`d`$ bounds. For targets other than parity, see [Question 16](#16-for-gamma1-is-the-bad-sample-complexity-specific-to-parity).

<a id="for-gamma1-is-the-bad-sample-complexity-specific-to-parity"></a>

## 16. For $\gamma<1$, is the bad sample complexity specific to parity?

**Largely no, and certainly not technically.** Many other targets also need a high power of $d$ samples. More strikingly, some targets with small circuits that gradient descent appears to learn quickly still need exponentially many samples in this regime. The clearest example is the target $`f^*`$ of [Question 20](#20-is-there-a-small-circuit-that-gradient-descent-learns-but-the-gamma1-learners-provably-cannot), computed by a Boolean circuit of $O(d)$ gates. The $\gamma<1$ learners provably need $\exp(\Omega(d))$ samples for it. A layerwise learner provably learns it from polynomially many, and Adam on a two-head network learned it at every dimension tested (numerical). Some restricted class of targets may still be learned well in this regime, but we do not have a good characterization.

**Scope.** The **$\gamma<1$ learners** are the Bayesian network posteriors of [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here) at the prior scalings $\gamma<0$, $\gamma=0$ and $0<\gamma<1$ of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings), with width taken to infinity first. [Question 11](#11-what-do-the-three-gamma1-learners-look-like-in-the-infinite-width-limit) describes them through one arcsine kernel on the cube. All Bayesian results in this answer, and in Questions 17 to 21, concern these learners, except the two-head variant of [Question 20](#20-is-there-a-small-circuit-that-gradient-descent-learns-but-the-gamma1-learners-provably-cannot). The greedy learner and the Adam runs of that question are other learners, included for comparison.

**Other regimes and depths.** The $\gamma\ge1$ regimes learn every small circuit, parity included ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)). At depth linear in $d$, the deep NNGP family of [Question 9](#9-how-do-the-nnbayes-results-here-relate-to-nngp-and-kernel-regression) and a deep family at $\gamma\le0$ from a [side result](side-results/gamma-below-one/paper.pdf) fail on every target, so their lower bounds say nothing specific about parity.

**From parity to other targets.** The exponential lower bounds for $\gamma<1$ summarized in [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings) come from the [subcritical paper](main-results/subcritical-exponential/paper.pdf). They are stated for parity. Applied to another target, the same proof gives a bound governed by how far the target is from polynomial threshold functions of low degree. Concretely:

- **Many targets other than parity need a high power of $d$ samples ([Question 17](#17-for-gamma1-which-targets-need-a-high-power-of-d-samples-and-which-are-cheap)).**
  - For a **junta**, a target that depends on a constant number of coordinates, the exponent is roughly its **threshold degree**: the least degree of a real polynomial whose sign equals the target at every input.
  - For example, $`h=\mathrm{MAJ}(x_1x_2,x_3x_4,x_5x_6)`$ needs at least about $d^2$ samples in every $\gamma<1$ regime, and about $d^3$ at $\gamma<0$. This holds even under the confidence criterion of [Question 6](#6-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23).
  - A function $g$ that mixes a three-bit parity with a three-bit majority needs at least about $d^3$ samples at $\gamma<0$, although SGD is expected to learn it from about $d$ ([Question 19](#19-how-do-the-gamma1-learners-sample-costs-compare-with-what-sgd-needs)).
- **Some targets with full Fourier degree are cheap.** Majority of all $d$ bits is learned from polynomially many samples ([Question 17](#17-for-gamma1-which-targets-need-a-high-power-of-d-samples-and-which-are-cheap)).
- **A large parity on a subcube is enough for an exponential bound ([Question 18](#18-for-gamma1-which-targets-need-exponentially-many-samples)).** Parity is close to threshold functions of degree about $\sqrt d$, so this distance argument gives it only $\exp(\Theta(\sqrt d\log d))$. The exponential parity bound uses two further margin-sensitive lemmas. These localize. Suppose the target equals a parity of linearly many bits wherever a constant number of other coordinates take fixed values. Then it needs $\exp(\Omega(d))$ samples, whatever it does elsewhere.
- **Such a target can still be easy for a layerwise learner ([Question 20](#20-is-there-a-small-circuit-that-gradient-descent-learns-but-the-gamma1-learners-provably-cannot)).** The target $`f^*`$ is a sign-staircase on half of the cube and full parity on the other half. The $\gamma<1$ learners need exponentially many samples for it (proved). A layerwise greedy learner provably learns it from polynomially many. Adam on a two-head network learned it at every dimension tested, up to $d=35$, but this range cannot separate polynomial from exponential growth, and a plain fully connected network did not learn it at $d=23$, 27, or 31 (numerical).
- **Which targets are learned well is open.** Every fixed junta is learned from polynomially many samples, with an exponent set by its threshold degree, and so is majority of all $d$ bits (proved; [Question 17](#17-for-gamma1-which-targets-need-a-high-power-of-d-samples-and-which-are-cheap)). Beyond such examples, we know no natural class of targets of growing complexity that these learners learn well, and no characterization.

[Question 21](#21-do-the-gamma1-sign-posteriors-and-kernel-regression-find-the-same-targets-hard) compares which targets are hard for these learners and for kernel regression with the same kernel.

**Sources and status.** The [supporting note](works-in-progress/beyond-parity/README.md) gives the statements, proofs, and checks behind this answer, and a [second note](works-in-progress/beyond-parity/subcube-parity.md), the subcube note, covers parity on a subcube and the target $`f^*`$. Their new arguments combine lemmas of the subcritical paper, standard learning-theory bounds, and elementary Boolean-function facts. They have independent AI-agent checks, but they are not Lean verified and have not been reviewed by a human.

## 17. For $\gamma<1$, which targets need a high power of $d$ samples, and which are cheap?

**For a target that depends on a constant number of coordinates, the exponent of $d$ in the sample complexity is roughly its threshold degree (proved).** For threshold degree at least two, the proved lower and upper exponents differ by at most two in each $\gamma<1$ regime; at $0\le\gamma<1$ the lower bounds concern Gibbs error. Halfspace juntas are cheap, and so is majority of all $d$ bits, although it has full Fourier degree. Targets of high threshold degree that are nearly constant under uniform inputs are open.

**Background.** The **$\gamma<1$ learners** are the Bayesian network posteriors at the prior scalings $\gamma<0$, $\gamma=0$ and $0<\gamma<1$ of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings), with width taken to infinity first. [Question 11](#11-what-do-the-three-gamma1-learners-look-like-in-the-infinite-width-limit) describes them through one arcsine kernel $K$ on the cube. At $\gamma<0$, after an output normalization, the posterior is a centered Gaussian process with covariance $K$ conditioned on the training signs; at $\gamma=0$, the same process is also conditioned on an absolute margin $a>0$ at every input. At $0<\gamma<1$, the posterior concentrates on the signs of the minimum-energy functions: those of least $`K`$-norm with absolute value at least $a$ at every input and the correct training signs. **Gibbs error** is the expected error of one posterior draw; **confidence failure** is the fraction of test inputs whose correct label gets posterior probability at most $2/3$ ([Question 6](#6-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23)).

**Notation.** For a target $f$ on $\lbrace -1,1\rbrace ^d$:

- Its **threshold degree** $\mathrm{thr}(f)$ is the least degree of a real polynomial whose sign equals $f$ at every input; [Question 14](#14-can-a-scaling-make-the-prior-prefer-something-other-than-small-circuits) writes $r(f)$. Every nonconstant halfspace, including majority and AND, has threshold degree one. Parity of $k$ bits has threshold degree $k$.
- $`\mathrm{err}_r(f)`$ is the least fraction of uniformly distributed inputs on which a polynomial threshold function of degree at most $r$ disagrees with $f$. It is positive exactly when $r<\mathrm{thr}(f)$.

Other notation:

- A **junta** is a target that depends on a constant number of coordinates, independent of $d$.
- For an integer $k$, $`k^*`$ denotes $k$ rounded up to an odd integer.
- $n$ is the number of training examples.
- $\beta=2^{-(L-1)}$, where $L-1$ is the number of hidden layers, governs the decay of the spectrum of $K$, and costs a factor $d^{\beta}$ or $d^{2\beta}$ in some bounds below.
- The constants $`c_f,C_f>0`$ depend on $f$, the depth, and at $0\le\gamma<1$ the margin $a$, but not on $d$. The statements hold for large $d$.

**Lower bounds for every target.** For smaller training sets, the [subcritical paper](main-results/subcritical-exponential/paper.pdf) proves its parity lower bounds in three steps:

1. For typical uniform iid training inputs, every labeling has an interpolant of small $`K`$-norm that satisfies the margin condition at every input. At $\gamma<0$, where there is no such margin, the analogue holds for every training set: the posterior mean has squared $`K`$-norm at most $n$.
2. The eigenvalues of $K$ decay with Fourier degree, so posterior-typical functions are close to polynomial threshold functions of low degree.
3. Parity is far from all such functions.

For large training sets, the paper instead replaces steps 2 and 3 by the margin-sensitive parity lemmas described in [Question 18](#18-for-gamma1-which-targets-need-exponentially-many-samples). The [supporting note](works-in-progress/beyond-parity/README.md) on targets beyond parity uses a simpler step 2 that does not depend on the target at any sample size: it bounds the high-degree part of the posterior by Markov's inequality. Replacing step 3 by $`\mathrm{err}_r(f)`$ then gives a lower bound for every target. The bound holds while $n$ stays well below about $\binom{d+1}{r+2}$, up to small polynomial factors. At $\gamma=0$ the fixed-degree version also uses the paper's posterior-amplitude lemma.

**Juntas of threshold degree at least two.** For a junta $f$ with $t=\mathrm{thr}(f)\ge2$:

- **$`\gamma<0`$ (proved).** Confidence failure is at least $`\mathrm{err}_{t^*-2}(f)/2>0`$ on every training set with $`n\le c_fd^{t^*}`$. Up to a logarithmic term, $`C_fd^{t^*+1}/\varepsilon`$ iid samples bring it below $\varepsilon$.
- **$`\gamma=0`$ (proved).** For typical uniform iid samples with $`n\le c_fd^{t^*-2\beta}`$, the Gibbs error is at least $`\mathrm{err}_{t^*-2}(f)/2`$. As at $\gamma<0$, about $`C_fd^{t^*+1}/\varepsilon`$ iid samples bring the confidence failure below $\varepsilon$.
- **$`0<\gamma<1`$ (proved).** For typical uniform iid samples with $`n\le c_fd^{t^*-\beta}`$, every minimum-energy sign function has error at least $`\mathrm{err}_{t^*-2}(f)/2`$. Order $`C_fd^{t^*}/\varepsilon^2`$ samples bring every minimizer's error below $\varepsilon$.

The sample-size exponents of these lower and upper bounds differ by at most two. The proofs also give more than these halved bounds. For $`n=o(d^{t^*})`$ at $\gamma<0$, $`n=o(d^{t^*-2\beta})`$ at $\gamma=0$, and $`n=o(d^{t^*-\beta})`$ at $0<\gamma<1$, the lower bound is $`\mathrm{err}_{t^*-2}(f)-o(1)`$.

**From Gibbs error to confidence.** At $0\le\gamma<1$ these lower bounds concern Gibbs error. By [Question 6](#6-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23)'s second inequality at $q=2/3$, a Gibbs-error lower bound $R$ gives a confidence-failure lower bound $(3R-1)/2$, which is positive only when $R>1/3$. Since $`\mathrm{err}_r(f)\le1/2`$, the halved bounds never give a confidence statement, but the sharper ones can. Two examples:

- **A majority of XORs.** $`h=\mathrm{MAJ}(x_1x_2,x_3x_4,x_5x_6)`$ has threshold degree two and $`\mathrm{err}_1=11/32>1/3`$.
  - At $\gamma<0$, its confidence failure stays at least $11/32-o(1)$ on every training set with $n=o(d^3)$.
  - At $0\le\gamma<1$, its confidence failure is at least $(3\cdot11/32-1)/2-o(1)=1/64-o(1)$, for $n=o(d^{3-2\beta})$ at $\gamma=0$ and $n=o(d^{3-\beta})$ at $0<\gamma<1$.
- **A parity–majority mixture.** Let $g$ be the function equal to $`x_1x_2x_3`$ when $`x_4=1`$ and to $`\mathrm{MAJ}(x_1,x_2,x_3)`$ when $`x_4=-1`$. It has threshold degree three and $`\mathrm{err}_1=3/16`$, so at $\gamma<0$ it needs at least about $d^3$ samples.

**Sparse parity.** The $`k`$-bit parity $`\chi_k(x)=x_1\cdots x_k`$ with fixed $k\ge2$ is also covered, at the natural scale $d^{\Omega(k)}$ of [Question 15](#15-for-gamma1-how-close-are-we-to-a-domegak-lower-bound-on-the-sample-complexity-of-sparse-xor). For example, two-bit XOR has $`\mathrm{err}_1=1/4`$, so at $\gamma<0$ its confidence failure stays at least $1/4-o(1)$ on every training set with $n=o(d^3)$. At $0\le\gamma<1$ these sparse-parity bounds hold only for Gibbs error. [Question 15](#15-for-gamma1-how-close-are-we-to-a-domegak-lower-bound-on-the-sample-complexity-of-sparse-xor)'s open problems concern $k$ growing with $d$, where the constants and $`\mathrm{err}_{k^*-2}(\chi_k)`$ degrade.

**Cheap targets: threshold degree one (proved; standard PAC-Bayes and margin arguments).**

- **Halfspace juntas.** Every halfspace junta, including majority and AND of a constant number of bits, is learned from at most about $d^2/\varepsilon$ samples at $\gamma\le0$ and $d/\varepsilon^2$ at $0<\gamma<1$.
- **Majority of all $d$ bits ($d$ odd).** It depends on every coordinate and has Fourier degree $d$. It costs at most about $d^3/\varepsilon$ samples at $\gamma\le0$ and $d^2/\varepsilon^2$ at $0<\gamma<1$.

Full Fourier degree is therefore no obstacle for these learners. A sign prediction needs only a polynomial with the right sign, and the sign of majority's degree-one part is majority itself.

**Open: high threshold degree on nearly constant targets.** Exact threshold degree is a worst-case notion. Functions with high threshold degree, such as the Minsky–Papert AND of ORs, can be nearly constant under uniform inputs. For such targets our lower bounds are weak, because $`\mathrm{err}_r(f)`$ is small. Our upper bounds are also weak, because exact sign representations need high degree or tiny margins. So the sample complexity of such targets for these learners remains open.

**Numerical illustrations.** The supporting note's numerical illustrations only illustrate the asymptotic statements. At $d=12$, $L=2$, and $\gamma<0$:

- majority of seven bits reaches confidence failure $0.03$ at $n=200$;
- three-bit parity falls below $0.01$ by $n=2400$;
- $g$ still fails at $n=2400$ on $23\%$ of all inputs and $41\%$ of unseen ones.

In these runs, $g$ is learned more slowly than three-bit parity. The supporting note's explanation, via $g$'s larger kernel norm, is heuristic.

The supporting note gives the statements, proofs, and checks behind this answer. It has independent AI-agent checks, but it is not Lean verified and has not been reviewed by a human ([Question 16](#16-for-gamma1-is-the-bad-sample-complexity-specific-to-parity)).

## 18. For $\gamma<1$, which targets need exponentially many samples?

**A target needs $\exp(\Omega(d))$ samples if, on some subcube of constant codimension, it equals $\pm$ a parity of linearly many bits, whatever it does elsewhere (proved).** So, with qualifications, does every target that stays a constant distance from all threshold functions of degree linear in $d$. Parity is not of that kind; its exponential bound uses further lemmas, and these localize to subcubes. Targets that are a large parity only on subcubes of linear codimension, such as inner product mod 2, are open; so is whether the sign-staircase is exponentially hard.

**Background.** The **$\gamma<1$ learners** are the Bayesian network posteriors at the prior scalings $\gamma<0$, $\gamma=0$ and $0<\gamma<1$ of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings), with width taken to infinity first. [Question 11](#11-what-do-the-three-gamma1-learners-look-like-in-the-infinite-width-limit) describes them through one arcsine kernel $K$ on the cube. A test input fails the **confidence criterion** when its correct label gets posterior probability at most $2/3$; **Gibbs error** is the expected error of one posterior draw ([Question 6](#6-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23)). The **distance argument** of [Question 17](#17-for-gamma1-which-targets-need-a-high-power-of-d-samples-and-which-are-cheap) shows that posterior-typical functions are close to polynomial threshold functions (signs of real polynomials) of low degree, so a target far from all of them is hard.

**Targets far from threshold functions of linear degree.** The distance argument gives exponential lower bounds for every target that stays a constant distance from threshold functions of degree linear in $d$. At $\gamma<0$ they hold on every training set. At $0\le\gamma<1$ they hold in Gibbs error for typical samples, and only for $n\le e^{d/25}$. Most Boolean functions are of this kind, but that says little, since a random function needs exponentially many samples for any learner.

**Why parity needs more.** Parity, by contrast, is close to threshold functions of degree about $\sqrt d$, so the distance argument gives it only $\exp(\Theta(\sqrt d\log d))$. The [subcritical paper](main-results/subcritical-exponential/paper.pdf)'s exponential parity theorem reaches $\exp(\Omega(d))$ through two further margin-sensitive lemmas. Both use the fact that parity changes sign along every edge of the cube.

**Parity on a subcube (proved).** These lemmas localize to any subcube on which the target is a parity. Write inputs as $(x,z)$ with $x\in\lbrace -1,1\rbrace ^d$ and $z\in\lbrace -1,1\rbrace ^k$, and let the $\gamma<1$ learners act on all $d+k$ input bits, with $d+k$ in place of $d$ in the kernel $K$. Fixing $`z=z_0`$ gives a subcube of codimension $k$; here $k$ is the codimension, not a parity size. Suppose that on one such subcube the target equals $\pm$ a parity of at least $`c_Rd`$ of the $`x`$-coordinates, with arbitrary values elsewhere. Fix $k$, $`c_R`$, the depth, and the margin. Then there is $c>0$ such that, for large $d$, every $n\le e^{cd}$, and every fixed $\gamma<1$, the following holds with probability at least $3/4$ over uniform iid samples:

- in the width limit, at least $1/16$ of the subcube fails the confidence criterion, so at least $2^{-k}/16$ of all inputs fail;
- at $\gamma<0$, at least $3/8$ of the subcube fails even with the threshold lowered to $13/20$.

Labels off the subcube enter the subcritical paper's proof only through bounds that hold for every labeling, so they cannot help on the subcube. The proof's constant $c$ is at worst of order $8^{-k}$. The [subcube note](works-in-progress/beyond-parity/subcube-parity.md) covers this theorem. [Question 20](#20-is-there-a-small-circuit-that-gradient-descent-learns-but-the-gamma1-learners-provably-cannot) applies it, with codimension one, to a small circuit that gradient descent appears to learn.

**Open:** targets that are a large parity only on subcubes of linear codimension. Inner product mod 2 is an example: fixing half of its coordinates leaves a parity of about a quarter of them. The [supporting note](works-in-progress/beyond-parity/README.md) suggests that the margin-sensitive lemmas transfer to such targets one restriction at a time (extension suggested by the proof), but this has not been written out.

**Targets without a parity subcube.** The sign-staircase $`\mathrm{sign}(x_1+x_1x_2+\cdots+x_1\cdots x_d)`$, with $d$ odd, needs at least $\exp(\Omega(\sqrt d\log d))$ samples for these learners in all three regimes (proved). The distance argument cannot give more, because the sign-staircase is close to threshold functions of degree $O(\sqrt{d\log(1/\varepsilon)})$. Whether it is exponentially hard is open. The sign-staircase is also one half of the target of [Question 20](#20-is-there-a-small-circuit-that-gradient-descent-learns-but-the-gamma1-learners-provably-cannot).

Every function of $`\sum_ix_i`$ alone has the same ceiling for the distance argument. Some such functions still reach $\exp(\Omega(d))$, for example $(-1)^{\lfloor w/2\rfloor}$, where $w$ is the number of coordinates equal to $-1$. The argument uses a random restriction that ties coordinates together in blocks (extension suggested by the proof: the target-dependent steps of the subcritical paper were audited, but the transferred proof has not been written out).

The supporting and subcube notes have independent AI-agent checks, but they are not Lean verified and have not been reviewed by a human ([Question 16](#16-for-gamma1-is-the-bad-sample-complexity-specific-to-parity)).

## 19. How do the $\gamma<1$ learners' sample costs compare with what SGD needs?

**For a fixed junta of leap $\ell\ge2$, the $\gamma<1$ learners need at least about $d^{\ell}$ samples (proved; in Gibbs error at $0\le\gamma<1$), while SGD is conjectured to learn it from about $d^{\ell-1}$. The converse fails: the leap-one target $g$ defined below needs at least about $d^3$ samples at $\gamma<0$, against a conjectured $d$ for SGD.** The SGD rates come from the cited papers' abstracts, and no theorem here relates SGD to these posteriors.

**Background.** The **$\gamma<1$ learners** are the Bayesian network posteriors at the prior scalings $\gamma<0$, $\gamma=0$ and $0<\gamma<1$ of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings), with width taken to infinity first ([Question 11](#11-what-do-the-three-gamma1-learners-look-like-in-the-infinite-width-limit)). Their lower bounds are stated **in confidence**, meaning that a positive fraction of test inputs get correct-label posterior probability at most $2/3$, or in **Gibbs error**, the expected error of one posterior draw ([Question 6](#6-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23)). Their sample costs are in [Question 17](#17-for-gamma1-which-targets-need-a-high-power-of-d-samples-and-which-are-cheap), whose notation we use:

- A **junta** is a target that depends on a constant number of coordinates.
- The **threshold degree** $\mathrm{thr}(f)$ is the least degree of a real polynomial whose sign equals $f$ at every input; $\deg f$ is the Fourier degree.
- $`k^*`$ is $k$ rounded up to an odd integer, and $\beta=2^{-(L-1)}$ for $L-1$ hidden layers.
- The target $g$ equals $`x_1x_2x_3`$ when $`x_4=1`$ and $`\mathrm{MAJ}(x_1,x_2,x_3)`$ when $`x_4=-1`$.

**The leap.** The **leap** $\mathrm{Leap}(f)$ of a target is the least $\ell$ such that the sets in its Fourier support can be ordered so that each contains at most $\ell$ coordinates outside the union of the earlier ones.

- [Abbe, Boix-Adserà, and Misiakiewicz](https://arxiv.org/abs/2302.11055) conjecture that online SGD on two-layer networks learns a junta from about $d^{\max(\mathrm{Leap}-1,1)}$ samples. They prove a version for a class of targets on Gaussian data.
- Their [earlier paper](https://arxiv.org/abs/2202.08658) calls leap one the merged-staircase property. It shows that this property is necessary and nearly sufficient for SGD in the mean-field regime to learn from $O(d)$ samples.

These SGD statements concern exponents for fixed juntas and are taken from the papers' abstracts. No theorem here relates SGD to these posteriors.

**High leap forces high threshold degree.** Every Boolean function satisfies $\mathrm{Leap}(f)\le\mathrm{thr}(f)\le\deg f$; the proof is elementary. So a junta of leap $\ell\ge2$ has threshold degree at least $\ell$. These learners then need at least about $d^{\ell}$ samples: in confidence on every training set at $\gamma<0$, and in Gibbs error for typical samples at $0\le\gamma<1$, up to a factor $d^{2\beta}$.

**The converse fails.** The leap-one target $g$ needs at least about $d^3$ samples at $\gamma<0$, while SGD is conjectured to need about $d$. The [supporting note](works-in-progress/beyond-parity/README.md)'s exhaustive four-bit census suggests that targets like $g$ are common: 97.5% of the leap-one functions depending on all four of their bits have threshold degree at least two.

**Sparse parity.** For $`k`$-sparse parity with fixed $k\ge2$, leap, threshold degree, and degree all equal $k$. Under the conjectured rate, SGD needs about $d^{k-1}$ samples. At $\gamma<0$ these learners need between about $`d^{k^*}`$ and $`d^{k^*+1}`$. At $0\le\gamma<1$ they need at least about $`d^{k^*}`$ up to a factor $d^{2\beta}$, in Gibbs error. So the exponents differ only by a small constant. [Barak et al.](https://arxiv.org/abs/2207.08799) find SGD taking $d^{O(k)}$ iterations on sparse parity, near the statistical-query limit.

## 20. Is there a small circuit that gradient descent learns but the $\gamma<1$ learners provably cannot?

**We have a candidate, the target $`f^*`$ below. It has a Boolean circuit of $O(d)$ gates, and the $\gamma<1$ learners provably need $\exp(\Omega(d))$ samples for it. The gradient side is not a theorem about end-to-end SGD.** A layerwise greedy learner provably learns $`f^*`$ from polynomially many samples, but it is a correlation-query procedure, not gradient descent on a standard network. Adam on a two-head network learned $`f^*`$ at every dimension tested, up to $d=35$ (numerical). This range cannot separate polynomial from exponential growth, and a plain fully connected network did not learn it at $d=23$, 27, or 31.

**Background.** The **$\gamma<1$ learners** are the Bayesian network posteriors at the prior scalings $\gamma<0$, $\gamma=0$ and $0<\gamma<1$ of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings), with width taken to infinity first. [Question 11](#11-what-do-the-three-gamma1-learners-look-like-in-the-infinite-width-limit) describes them through one arcsine kernel on the cube. A test input fails the **confidence criterion** when the posterior gives its correct label probability at most $2/3$ ([Question 6](#6-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23)). The **subcube theorem** of [Question 18](#18-for-gamma1-which-targets-need-exponentially-many-samples) says that these learners need $\exp(\Omega(d))$ samples for any target that equals $\pm$ a parity of linearly many bits on a subcube of constant codimension, whatever it does elsewhere.

**The target.** For an exponential gap, let $d$ be odd and add one selector bit $z$ to $x\in\lbrace -1,1\rbrace ^d$:

$$
f^*(x,z)=\begin{cases}
\mathrm{sign}\left(x_1+x_1x_2+\cdots+x_1x_2\cdots x_d\right),&z=+1,\\
x_1x_2\cdots x_d,&z=-1.
\end{cases}
$$

On $z=+1$ it is the sign of a staircase. A chain of XOR gates computes the prefix parities, a linear-size majority circuit combines them, and one selector picks the half, so $`f^*`$ has a Boolean circuit of $O(d)$ gates. For $t<d$, each prefix parity $`x_1\cdots x_t`$ correlates with $`f^*`$ at about $(2\pi d)^{-1/2}$, and each extends the previous one by one coordinate, so a learner can find them one at a time. The last, $`x_1\cdots x_d`$, is the full parity that $`f^*`$ equals on $z=-1$.

**On the Bayesian side:**

- **The $\gamma<1$ learners need $\exp(\Omega(d))$ samples (proved).** This is the subcube theorem of [Question 18](#18-for-gamma1-which-targets-need-exponentially-many-samples) with codimension $k=1$, for the $\gamma<1$ learners on all $d+1$ bits. In the width limit, for every $n\le e^{cd}$ and with probability at least $3/4$ over uniform iid samples, at least $1/32$ of all inputs fail the confidence criterion, and at least $3/16$ at $\gamma<0$.
- **Two-head Bayesian networks (proved).** Give the network a shared stack of hidden layers that sees only $x$, and two readouts with equal variances, one used when $z=+1$ and one when $z=-1$. In the width limit, at $\gamma\le0$ the posterior splits into independent posteriors on the two halves, and at $0<\gamma<1$ the minimum-energy problem splits. So the parity half fails exactly as in the [subcritical paper](main-results/subcritical-exponential/paper.pdf). This is a modified prior. Its width limit is two independent Gaussian processes, so its hardness is that of parity on one half.

**On the gradient side:**

- **A layerwise learner provably climbs it (proved).** Consider a greedy procedure in the spirit of the staircase learner of [Abbe, Boix-Adserà, Brennan, Bresler, and Nagaraj](https://arxiv.org/abs/2108.10573). It grows product units $`x_{i_1}\cdots x_{i_m}`$ one coordinate at a time, keeping a unit when its correlation with the target, or with $z$ times the target, is above a threshold. It then trains two linear heads on these units, one for each value of $z$. It finds exactly the $d$ prefix parities from $O(d\log d)$ samples, and the heads reach error $\varepsilon$ from $O(d^2/\varepsilon)$ more. It is a correlation-query procedure, not gradient descent on a standard network. It stalls on parity alone, and on the control target that is $`x_1`$ on $z=+1$ and parity on $z=-1$.
- **Adam on a two-head network learned it at every dimension tested (numerical).** A ReLU network computes three hidden layers of width 512 from $x$, giving $\phi(x)$, and outputs $`w_1\cdot\phi(x)+z\,w_2\cdot\phi(x)`$. It was trained with Gaussian initialization on fresh samples. Its error on the parity half fell below 5% after about $2.7\cdot10^6$, $8.8\cdot10^6$, $1.7\cdot10^7$, $4.8\cdot10^7$, and $7.6\cdot10^7$ samples at $d=19$, 23, 27, 31, and 35.
  - On the control target, the parity half needed about $1.0\cdot10^7$ and $1.8\cdot10^7$ samples at $d=19$ (two seeds) and $1.9\cdot10^7$ and $2.6\cdot10^7$ at $d=23$, and was not learned within $4\cdot10^7$ at $d=27$ or $6\cdot10^7$ at $d=31$.
  - Parity alone, on the same hidden layers with one readout, was not learned at any of $d=19$, 23, 27, and 31, within budgets of $2\cdot10^7$ to $6\cdot10^7$ samples.
  - So on this network, parity was learned only as half of a two-half target, and at $d=27$ and 31 only next to the staircase half.
  - SGD with momentum, in place of Adam, also learned $`f^*`$ at $d=19$: its parity half fell below 5% after $6.4\cdot10^6$ samples and its staircase half after $8.4\cdot10^6$.
- **What the numerics do not show.** There are one or two seeds per dimension, $d\le35$, and at $d=19$ the runs used more samples than there are inputs. This range cannot separate polynomial from exponential growth.
  - A plain fully connected network with $z$ as an ordinary input, the shape of the learners in the subcube theorem, learned $`f^*`$ only at $d=19$ and 21, each time after more samples than there are inputs. With Gaussian initialization it learned the staircase half but not the parity half at $d=23$ and 27, within $5\cdot10^7$ and $6\cdot10^7$ samples, and with PyTorch's default initialization it did not learn $`f^*`$ at $d=31$ within $6\cdot10^7$.
  - Parity alone, on a smaller one-hidden-layer network with Gaussian initialization, was learned at $d=19$, 23, and 27 from $2.3\cdot10^6$, $3.8\cdot10^6$, and $1.6\cdot10^7$ samples, no more than the parity half of $`f^*`$ needed. It was not learned within $1.5\cdot10^8$ samples at $d=31$. With PyTorch's default uniform initialization, the same network learned parity alone at $d=31$ from about $3\cdot10^6$ samples. So the comparison with parity alone depends on the initialization and on the architecture.
- **Open: no theorem for end-to-end SGD.** We found no theorem in which end-to-end SGD from a Gaussian initialization learns a linear-degree parity, or $`f^*`$, on uniform inputs; the search was at abstract level. The positive results for almost-full parities, by [Abbe, Cornacchia, Hązła, and Kougang-Yombi](https://arxiv.org/abs/2412.04910), start from $\pm1$ first-layer weights, possibly with Gaussian perturbations of size $O(1/d)$, and a large Gaussian perturbation prevents learning (literature, abstract-level). We read this as an effect of initialization (heuristic).

**Why both halves (heuristic).** Two proved facts suggest why simpler targets do not work for the available proof routes. If a target is within distance $\eta$ of a single parity, all its other Fourier coefficients are at most $2\eta$, so there is little low-degree signal to climb. If instead a target becomes $\pm$ a parity of at least $\alpha d$ bits once some coordinates are fixed at uniformly random values, except with probability $\delta$, then its Fourier weight below degree $\alpha d$ is at most $\delta$. $`f^*`$ avoids both. It is at distance about $1/4$ or more from every parity, and at least about $\alpha/\pi$ of its Fourier weight lies below degree $\alpha d$. Yet it equals a parity exactly on half of the cube.

**Sources.** The [subcube note](works-in-progress/beyond-parity/subcube-parity.md) covers this target, including the greedy learner and the numerical runs. As [Question 16](#16-for-gamma1-is-the-bad-sample-complexity-specific-to-parity) records, it has independent AI-agent checks, but it is not Lean verified and has not been reviewed by a human.

## 21. Do the $\gamma<1$ sign posteriors and kernel regression find the same targets hard?

**Not always. Kernel regression's squared error is governed by a target's Fourier weight, whereas the sign posteriors' lower bounds are governed by its distance from low-degree threshold functions.** Majority of all $d$ bits is costly for regression but cheap for the sign posteriors. But every target that our lower bounds certify as hard for the sign posteriors is also hard for squared-error regression.

**Background.** The **$\gamma<1$ sign posteriors** are the $\gamma<1$ learners: the Bayesian network posteriors at the prior scalings $\gamma<0$, $\gamma=0$ and $0<\gamma<1$ of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings), in the width-first limit. [Question 11](#11-what-do-the-three-gamma1-learners-look-like-in-the-infinite-width-limit) describes them through one arcsine kernel $K$ on the cube $\lbrace -1,1\rbrace ^d$, which arises because tanh acts as a sign function in that limit. [Question 17](#17-for-gamma1-which-targets-need-a-high-power-of-d-samples-and-which-are-cheap) bounds their sample costs through $`\mathrm{err}_r(f)`$, the least fraction of uniformly distributed inputs on which a polynomial threshold function of degree at most $r$ disagrees with $f$. We also use its notation: $`k^*`$ is $k$ rounded up to an odd integer, $\beta=2^{-(L-1)}$ for $L-1$ hidden layers, and $g$ is the target equal to $`x_1x_2x_3`$ when $`x_4=1`$ and to $`\mathrm{MAJ}(x_1,x_2,x_3)`$ when $`x_4=-1`$.

**Kernel regression.** For contrast, consider a different predictor built from the same kernel $K$. It is the posterior mean of the centered Gaussian process with covariance $K$, given the noiseless labels as real values. That process is the NNGP of the sign-activation network of [Question 11](#11-what-do-the-three-gamma1-learners-look-like-in-the-infinite-width-limit), not the NNGP at the usual scaling ([Questions 9](#9-how-do-the-nnbayes-results-here-relate-to-nngp-and-kernel-regression) and [13](#13-what-is-known-at-the-usual-nngp-scaling)). This posterior mean is kernel interpolation, called kernel regression below. Its squared error is governed by Fourier weight rather than by distance from threshold functions.

Write $`\mathrm{wt}_k(f)`$ for the Fourier weight of $f$ at degree $k$, and $`\mathrm{wt}_{>r}(f)`$ for its total weight above degree $r$.

**A lower bound for kernel regression.** For uniformly sampled inputs, the expected squared error of kernel regression depends on the target only through the weights $`\mathrm{wt}_k(f)`$. The [supporting note](works-in-progress/beyond-parity/README.md) proves this by a symmetry argument. For fixed $k$ and $`n\le c_k\,d^{k^*}(d\log d)^{-\beta}`$, where $`c_k>0`$ depends on $k$ and the depth, at least half of the weight at degrees $k$ and above remains as squared error. For $`n=o(d^{k^*}(d\log d)^{-\beta})`$, all of it remains up to $o(1)$.

The odd rounding comes from the odd activation and the constant input coordinate, which together give $`x_1x_2`$ the same eigenvalue as $`x_1x_2x_3`$. This is the lower-bound half of the standard polynomial-regime picture of kernel regression, as in [Mei, Misiakiewicz, and Montanari](https://arxiv.org/abs/2101.10588), whose examples include the hypercube. We have not checked that paper's hypotheses for this kernel.

**The two criteria differ:**

- **Majority of all $d$ bits** keeps weight of order $k^{-1/2}$ above every degree $k\ll d$. Squared error $\varepsilon$ therefore needs at least $d^{\Omega(1/\varepsilon^2)}$ samples once $d$ is polynomially larger than $1/\varepsilon^2$. The sign posteriors learn majority at polynomial cost ([Question 17](#17-for-gamma1-which-targets-need-a-high-power-of-d-samples-and-which-are-cheap)).
- **AND of all $d$ bits** has degree $d$, but all except $O(2^{-d})$ of its weight is at degree zero. So the regression lower bound gives nothing for it: that bound depends on high-degree weight, not on Fourier degree.
- **The target $`g`$** has $9/16$ of its weight at degree four. Regression keeps its squared error at least $9/16-o(1)$ while $n=o(d^5(d\log d)^{-\beta})$.

**In one direction the criteria are linked.** Since $`\mathrm{err}_r(f)\le\mathrm{wt}_{>r}(f)`$, every target that our lower bounds certify as hard for the sign posteriors is also hard for squared-error regression.

<a id="12-what-robustness-condition-gives-polynomial-depth-dependence"></a>

## 22. What robustness condition gives polynomial depth dependence?

**Proved under a restriction on the prior: the clipped prediction score must survive small simultaneous disturbances inside the network, at every input.** The learner is the Bayesian posterior for a fully connected tanh network with $L-1$ hidden layers of width $N$, readout weights $v$, and real output $`z_w(x)`$ on Boolean inputs ([Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here)). The exponent $\gamma$ sets how the Gaussian prior variances scale with width, and $\gamma=1$ is mean field ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)).

**The condition.** Add a disturbance $\eta^s$ after each hidden layer $s$ and a disturbance $\eta^{\mathrm{out}}$ at the readout, with total budget

$$
\Vert \eta\Vert _*^2=\sum_{s=1}^{L-1}\frac{\Vert \eta^s\Vert _2^2}{N}+|\eta^{\mathrm{out}}|^2.
$$

For the readout energy $`E_v=N\Vert v\Vert _2^2`$, use radius

$$
r_c(w)=\frac{c}{\sqrt{1+(L-1)E_v}},
$$

where the calibration constant $c>0$ is fixed. Clip the output at the training margin, $T(z)=\max\lbrace -1/2,\min\lbrace 1/2,z\rbrace \rbrace $. Writing $`z_w(x;\eta)`$ for the disturbed output, restrict the Gaussian prior to networks for which

$$
|T(z_w(x;\eta))-T(z_w(x))|\le1/16
$$

at every input and every disturbance in that ball.

**The guarantee.** For the tanh learner and a layered Boolean target circuit of width $C$, counting constant wires and any compilation overhead, this gives sample complexity polynomial jointly in $d,L,C,c+c^{-1},\varepsilon^{-1},\log(1/\delta)$, simultaneously for every $N\ge C$ and every $\gamma\ge1$. Here $\varepsilon$ is the accuracy and $\delta$ the failure probability; training requires signed output above $1/2$, and test error uses margin $1/4$ ([Question 5](#5-can-we-drop-the-global-margin-condition-imposed-on-every-input-before-training)). The proof builds a robust implementation with enough Gaussian prior mass and compresses posterior draws through small internal disturbances.

**Interpretation.** The condition has a recognizable interpretation: the prediction score must survive a small amount of simultaneous internal numerical error. Clipping avoids treating a change from output $10$ to output $1$ as a prediction failure. The root-mean-square (RMS) normalization, dividing each hidden-layer term by $N$, makes perturbations comparable across widths. The radius compensates for accumulating layer disturbances and readout amplification.

It is nevertheless a particular sufficient condition, with a strong “every input, every perturbation” quantifier. Calling it natural does not establish that arbitrary trained networks satisfy it. [Question 23](#23-how-can-we-check-whether-a-network-satisfies-the-robustness-condition) explains how to certify it, [Question 24](#24-do-gradient-trained-networks-satisfy-the-robustness-condition) reports what is known for trained networks, and [Question 25](#25-can-robustness-be-required-only-near-the-data-or-on-average) discusses requiring it only near the data.

**A different restriction for ReLU and GELU.** A [separate polynomial-depth theorem](works-in-progress/relu-gelu-polynomial-depth/) instead restricts the prior by stability under merging neuron populations. It gives quadratic width dependence up to logarithms. That condition is not proved equivalent to the internal-noise condition above. [Question 30](#30-what-are-the-explicit-sample-complexity-polynomials-and-are-practical-sample-bounds-close) describes the merging condition, and [Question 32](#32-how-natural-is-the-neuron-merging-restriction) gives its ReLU/GELU polynomial.

<a id="13-how-can-we-check-whether-a-network-satisfies-the-robustness-condition"></a>

## 23. How can we check whether a network satisfies the robustness condition?

**By a certificate: a sufficient check that bounds how much disturbances introduced at each layer can change the final prediction.** The robustness condition of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence) requires the clipped output to change by at most $1/16$ at every input, under every simultaneous disturbance of the hidden layers and readout within a calibrated noise ball. The radius of that ball is proportional to a fixed calibration constant $c>0$.

**A simple certificate: nonexpansive layers.** One simple certificate requires the internal layers not to amplify Euclidean distances, a property called **nonexpansiveness**. Tanh applied coordinatewise has this property, as does a linear layer whose operator norm is at most one. Under these layerwise bounds, Cauchy–Schwarz bounds the readout change by $c$ under the calibrated noise budget of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence). Thus $c\le1/16$ supplies a sufficient certificate.

**Proved:** the robustness restriction used for polynomial-depth generalization also admits more flexible certificates. Finite-radius Jacobian bounds, bounds on reachable activation intervals, and suitable weighted layer metrics can certify the restriction. These allow expansion in one direction or layer when later contraction or saturation controls the total effect; individual operator norms can exceed one.

**What does not certify it.** A Jacobian computed only at the clean network state is not a finite-perturbation certificate. Likewise, flatness under parameter perturbations, a small training-loss Hessian, or robustness to one kind of input noise does not by itself control arbitrary internal disturbances. Explicit examples separate these properties.

[Question 24](#24-do-gradient-trained-networks-satisfy-the-robustness-condition) reports certificates computed for trained networks.

<a id="14-is-the-condition-satisfied-by-actual-gradient-descent-trained-networks"></a>

## 24. Do gradient-trained networks satisfy the robustness condition?

**Sometimes, but not universally; the evidence is deliberately narrower than a general claim about deep learning.** The condition is the robustness restriction of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence): at every input, the clipped output must survive every small simultaneous internal disturbance within a ball of radius proportional to a calibration constant $c$. A **global** certificate ([Question 23](#23-how-can-we-check-whether-a-network-satisfies-the-robustness-condition)) verifies it on the entire input domain.

The experiments use ordinary SGD/Adam on fully connected tanh image classifiers and some finite Boolean tasks. They are not tests of transformers, ReLU architectures, or posterior sampling. There are positive global certificates and negative examples.

**Stable on the data, unstable elsewhere.** A particularly useful comparison is one fully fitted MNIST SGD model. Every one of its 60,000 recorded training inputs and 10,000 held-out inputs has a rigorous certificate at $c=10^{-3}$, yet a valid off-distribution 8-bit image violates the global condition. Its training margins were also checked rigorously. This separates “stable on all the data we checked” from “stable on the entire Boolean input domain.” [Question 3](#3-how-important-is-it-that-the-inputs-are-boolean) explains how 8-bit images correspond to Boolean inputs.

**Whole-cube certificates, and a counterexample.** Two smaller Boolean classifiers have certificates on their entire finite input cube. Conversely, there is also an analytic gradient-descent construction that remains perfectly fitted while violating the global condition off the data support. Ordinary gradient descent therefore does not imply the condition as a matter of logic.

**Smaller radii (exploratory).** There is a stronger positive observation at a smaller radius. In an explicitly exploratory follow-up, the same fitted depth-16 MNIST model has an exact **global** certificate at $c=0.001/16$, and a fitted depth-32 continuation has one at $c=0.001/32$, without changing their trained weights. The [reproduction guide](works-in-progress/depth-experiments/REPRODUCTION.md) includes the depth-32 model and an offline verifier. Since the bound of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence) is polynomial in $c+c^{-1}$ and depth, choosing $c=0.001/(L-1)$ still gives polynomial depth dependence in the theorem. This is encouraging evidence for a polynomially shrinking calibration, but two depths do not establish an asymptotic training law. These smaller-radius successes also do not erase the primary-radius counterexamples.

**What the checks are.** The image checks are finite collections of exact inequalities, not a population coverage theorem. The models, calibration choices, exploratory follow-ups, and certificate provenance are recorded in the [experimental package](works-in-progress/depth-experiments/). Successful pointwise checks are evidence for investigating a distributional version ([Question 25](#25-can-robustness-be-required-only-near-the-data-or-on-average)), not evidence that the existing global-support theorem already applies to that model.

**Neuron merging is a different condition.** The stronger neuron-merging restriction used for quadratic width dependence requires that averaging weights within suitably few groups of neurons barely changes clipped predictions ([Question 30](#30-what-are-the-explicit-sample-complexity-polynomials-and-are-practical-sample-bounds-close)). It has its own naturality study, described in [Question 32](#32-how-natural-is-the-neuron-merging-restriction), with fresh trained examples and different certificates. Membership in one condition should not be inferred from membership in the other.

<a id="15-can-robustness-be-required-only-near-the-data-or-on-average"></a>

## 25. Can robustness be required only near the data, or on average?

**Yes with additional bookkeeping; arbitrary average robustness is not currently enough.** The robustness restriction of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence) requires the clipped output to survive every small simultaneous internal disturbance at **every** input. That quantifier is strong: [Question 24](#24-do-gradient-trained-networks-satisfy-the-robustness-condition) describes a trained network certified at all of its recorded data that still violates the condition elsewhere. The variants below require stability on less of the input space.

**Proved variants.** There are several in the [robust paper](main-results/robust-polynomial-depth/paper.pdf):

- A fixed trusted region, with a bounded probability of landing outside it. Stability is required throughout that region.
- A controlled-complexity family of exceptional regions, allowing a posterior to choose an exception set while uniform sampling bounds control its coverage. The theorem pays for the size or complexity of that family.
- A region or finite catalog chosen from an independent unlabeled pilot, with coverage assessed on validation data. A frozen single region has no selection-complexity penalty merely because its construction was complicated.
- Stability imposed at a finite iid unlabeled pool, including the labeled inputs. This retains a polynomial, width-independent **labeled** sample bound, but the current unlabeled budget grows like $N/t^2$ times a polynomial, where $N$ is learner width and $t^2=N^{1-\gamma}$ for the prior-scaling exponent $\gamma$ of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings). It is not a width-independent total-data theorem.

**Certifying a region.** For the first three routes, one still needs a certificate on the whole chosen region, not just its observed points. In high dimension, extending point certificates to tiny neighborhoods can give negligible coverage. One tested neighborhood-cover construction indeed gave poor coverage; that is a limitation of that construction, not a proof that broad robust regions do not exist.

**Open for the original conditioning rule:** merely requiring each prior-supported network to be unstable on at most a $\rho$ fraction of inputs, with no complexity control on those exceptional sets. The selected posterior may concentrate its exceptional sets around the training sample. An abstract sparse-patch counterexample shows why a generic averaging argument fails; it is not a counterexample for the specific Gaussian neural prior.

**Random-noise and soft variants.** Other candidates include robustness to dropout, random quantization, or random internal noise. These are plausible training objectives, but average random-noise robustness does not automatically imply the adversarial finite-noise condition used by the current compressor, the step of the proof that compresses posterior draws through small internal disturbances. Soft penalties also require explicit control of how much unstable posterior mass remains. They should be presented as research directions unless the additional bridge is supplied. [Question 33](#33-are-there-more-natural-alternatives-to-neuron-merging-stability) discusses alternative restrictions that do have completed arguments.

<a id="16-is-exponential-depth-dependence-necessary-without-any-robustness-restriction"></a>

## 26. Is exponential depth dependence necessary without any robustness restriction?

**Yes for unrestricted continuous-output regression; open for the original Boolean-cube model.** The internal-noise robustness restriction of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence) gives sample bounds polynomial jointly in depth for Boolean-circuit targets. This question concerns the Gaussian prior without it, whose general positive bounds are polynomial at each fixed depth ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)). In that question's notation, $\gamma$ is the prior-scaling exponent, with $\gamma=1$ the mean-field scaling, and the strong-prior limit fixes the width and lets the prior variance tend to zero. Below, $N$ is learner width and $C$ teacher width.

**A continuous-output lower bound.** The [continuous-depth lower bound](works-in-progress/continuous-depth-lower-bound/) gives teachers of constant width, weights bounded by 30, and growing depth on the unit circle. Learning here means predicting their real outputs, as in the continuous-domain regression results of [Question 3](#3-how-important-is-it-that-the-inputs-are-boolean). For a fixed, nonatomic input distribution, this requires exponentially many samples in depth. The lower bound holds in three regimes:

- in the strong-prior limit, at every fixed width above a threshold polynomial in the sample size;
- at every fixed exponent $\gamma>1$, at widths above a threshold polynomial in the sample size and depth;
- at mean-field scaling, in the width-first limit. The mean-field result does not give a quantitative width threshold.

These thresholds are far above teacher width, so the result refutes guarantees asserted at every width $N\ge C$, not behavior near the teacher width. Training and test tolerances are fixed constants, and the failure concerns the actual posterior-confidence criterion, including mixtures.

**The mechanism.** The teacher separates outputs at exponentially close input pairs. For the strong-prior and above-mean-field ($\gamma>1$) cases, a small random sample can instead be fit exactly by a network whose energy permits only a polynomial-in-sample-size Lipschitz constant, independently of depth. The posterior favors those fits, which must fail on at least one member of every close pair. This also gives a lower bound for minimum-energy exact interpolation and the specified strong-prior-then-zero-tolerance posterior limit. The mean-field proof uses a separate entropy-rate comparison and the same paired inputs. The fixed input distribution is supported on a Cantor subset of the circle; smooth densities depending on depth are also covered. Uniform spherical inputs remain open.

**For Boolean inputs,** the original depth example and later critical-rate constructions remain capacity or proof obstructions, rather than exponential sample lower bounds. Distinct cube inputs do not become exponentially close, so the continuous counterexample does not settle that question.

Without a robustness restriction, polynomial dependence on learner depth is nevertheless proved for substantial Boolean target classes: above mean field in [Question 27](#27-without-a-robustness-restriction-which-targets-have-polynomial-learner-depth-bounds-above-mean-field), and at the critical scaling $\gamma=1$ in [Question 28](#28-without-a-robustness-restriction-what-depth-dependence-does-the-critical-gamma1-prior-have).

## 27. Without a robustness restriction, which targets have polynomial learner-depth bounds above mean field?

**Proved for substantial target classes, at every fixed exponent $`\gamma\ge1+\zeta`$ above mean field.** Without the internal-noise robustness restriction of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence), the general positive bounds for the Gaussian prior are polynomial only at each fixed depth ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)); here $\gamma$ is the prior-scaling exponent, with $\gamma=1$ the mean-field scaling. The [unrestricted-depth paper](works-in-progress/unrestricted-depth/paper.pdf) shows that polynomial dependence on learner depth nevertheless holds for shallow tanh targets, Boolean halfspaces, fixed-depth threshold circuits, functions of polynomially bounded Fourier $`\ell_1`$ norm, and teachers with few hidden states. General Boolean circuits get an improved bound that is not jointly polynomial. [Question 28](#28-without-a-robustness-restriction-what-depth-dependence-does-the-critical-gamma1-prior-have) gives the corresponding results at $\gamma=1$, and [Question 26](#26-is-exponential-depth-dependence-necessary-without-any-robustness-restriction) shows that exponential depth dependence is necessary for continuous-output regression.

**Shallow targets, halfspaces, and small Fourier norm.** At exponents $\gamma\ge1+\zeta$, for every fixed gap $\zeta>0$, the [unrestricted-depth paper](works-in-progress/unrestricted-depth/paper.pdf) gives polynomial dependence on learner depth for all bounded-weight shallow tanh targets and for all Boolean halfspaces. This holds at every actual width above the original $`C_L(f)`$, the least width of a depth-$`L`$ network realizing the target $f$ with the prescribed margin and weights bounded by that width ([Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here)). The halfspace result does not depend on the target's original coefficient precision or geometric margin. Other covered classes include fixed-depth threshold circuits and functions with polynomially bounded Fourier $`\ell_1`$ norm, including parity. [Question 28](#28-without-a-robustness-restriction-what-depth-dependence-does-the-critical-gamma1-prior-have) gives polynomial learner-depth bounds for substantial classes at the critical scaling $\gamma=1$.

**Deep computation after few hidden states.** A further positive case allows arbitrarily deep computation after a small set of hidden states. Suppose a bounded-weight teacher of depth $D$ takes only $K$ distinct hidden-state values after a fixed number of initial layers. The sample bound is polynomial in $K$, teacher resources, and learner depth, at every $L\ge D$ and every actual width $`N\ge C_L(f)`$, for each fixed exponent above one. No robustness condition is added to the prior. Examples include a fixed-width first layer with polynomially bounded integer weights, or a first layer driven by a fixed number of groupwise bit counts. The proof replaces the remaining computation by a lookup circuit; it does not require the hidden states to be well separated. The initial number of layers must be fixed, and $K$ can be exponential for an arbitrary teacher.

**General Boolean circuits.** For a general fan-in-two Boolean circuit of size $s$, logical depth $h$, and $S=\max\lbrace 16,2+d+s\rbrace $, a proved sample bound is

$$
S^{O_\zeta(1+h/\log\log S)}\,
\mathrm{poly}(L,\varepsilon^{-1},\log(1/\delta)),
$$

at learner depths $L\ge\max\lbrace 2,h\rbrace $. This improves the direct exponential dependence on $h\log S$, but is not a joint polynomial. Formula balancing gives a quasipolynomial alternative for formulas, with the corresponding learner-depth qualification. [Question 29](#29-can-the-exponential-dependence-on-the-teachers-depth-be-removed-without-a-robustness-restriction) discusses the dependence on the teacher's depth.

**A barrier, and a reason for caution.** The same paper identifies a function-level product-norm representation barrier: low sample complexity forces suitable approximate low-product-norm representatives in a specified large-width regime. No explicit small deep circuit violating the necessary approximation condition is known here. Indeed, an explicit superpolynomial-sample counterexample within $\mathsf{NC}^1$ (polynomial-size fan-in-two circuits of logarithmic depth), in the regime covered by these positive results, would separate $\mathsf{NC}^1$ from $\mathsf{TC}^0$ (polynomial-size constant-depth threshold circuits). This is a reason for caution about easy purported counterexamples, not a proof that the desired theorem is true.

<a id="17-what-does-the-critical-depth-result-imply-about-learning"></a>

## 28. Without a robustness restriction, what depth dependence does the critical ($\gamma=1$) prior have?

**The original critical prior has polynomial learner-depth bounds for substantial target classes, at every width capable of representing the target.** The critical prior is the mean-field scaling $\gamma=1$ of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings), for a fully connected tanh network of depth $L$ and width $N$ with real output $`z_w(x)`$ on Boolean inputs ([Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here)). The [critical-depth paper](works-in-progress/critical-depth/paper.pdf) uses the original global output-margin condition and exact noiseless training fit. It adds no internal robustness restriction of the kind in [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence). These results remain independently reviewed research drafts, outside the five promoted main results; they are not Lean verified.

**What “every realizable width” means.** It means every width at which the specified depth admits a tanh network implementing the target's signs. Rescaling the readout gives strict margin $1/2$, so the target event has positive Gaussian probability. There is no additional lower bound on learner width. The input distribution on the Boolean cube is arbitrary. The conclusions concern the full posterior, including mixtures: with training probability at least $1-\delta$, the correct-label probability exceeds $2/3$ except on test mass at most $\varepsilon$.

**Every parity has polynomial sample complexity at sufficiently large logarithmic learner depth.** More generally, let $`A_F(f)=\sum_S|\widehat f(S)|`$, the Fourier variation, where $\widehat f(S)$ are the Fourier coefficients of $f$, and put $`R_F=(d+L+2)A_F(f)`$. At every realizable width, a sufficient sample size is

$$
n\ge\frac C\varepsilon\left[R_F^c(1+\log(1/\varepsilon))^c+\log(1/\delta)\right]
\qquad\text{if }L\ge C_0\log R_F.
$$

The constants are universal. All signed parities have $`A_F=1`$, regardless of degree, so this includes full parity. Reaching a *bounded absolute prior rate* requires depth of order $(\log d)^2$; that is a different criterion, and the learning theorem does not require it.

**Tanh teachers and threshold circuits.** For a tanh teacher of depth $D$, width $`C_T`$, parameter magnitudes at most $B$, and global signed output margin at least $1/2$, put $`R=d+C_T+B+D+L+2`$. When $`L\ge C_0(D+1)\log R`$, the sufficient sample size at every realizable width is

$$
n\ge\frac C\varepsilon\left[R^{c(D+1)}(1+\log(1/\varepsilon))^c+\log(1/\delta)\right].
$$

This is polynomial in learner depth for every fixed teacher depth; [Question 29](#29-can-the-exponential-dependence-on-the-teachers-depth-be-removed-without-a-robustness-restriction) asks whether the dependence on teacher depth can be removed. For Boolean threshold circuits, the original coefficients may be arbitrary real numbers: a teacher of depth $h$ and width $`C_T`$ gives the analogous $R^{O(h)}$ bound with $`R=d+C_T+h+L+2`$, independent of coefficient magnitudes or precision. In particular, Boolean halfspaces have a polynomial bound at every width $N\ge1$ under the logarithmic depth condition.

**Long sequential computations and other classes.** Some long sequential computations also have polynomial bounds. These include two-state branching programs, programs over fixed solvable finite groups, and permutation branching programs of width at most four. A teacher with a fixed-rank first-layer bottleneck has a polynomial bound in its product norm even when its remaining depth is arbitrary. General formulas have a quasipolynomial bound in dimension and formula size. The paper states the precise resource and minimum-depth conditions for each class. **Joint polynomial sample complexity in arbitrary teacher width and depth remains open.**

**The general theorem: a bound through the raw prior cost.** The general finite-width theorem uses the target's actual raw prior cost

$$
a_N(f)=-\frac1N\log\Pr\lbrace f(x)z_w(x)>1/2\text{ for every }x\rbrace .
$$

There is a universal baseline $`V_{\ast}\in(1,2)`$. At every realizable width, the sample bound is a universal polynomial in $`d,L,a_N(f),1/\varepsilon`$ and $\log(1/\delta)$, multiplied by

$$
\exp\bigl(C\sqrt{L[a_N(f)-V_{\ast}]_+}\bigr).
$$

Here $`[u]_+=\max\lbrace u,0\rbrace `$ is the positive part.

**How the proof works.** The proof has two parts. Forward conditional entropy extracts approximate covariance paths from finite-width events. Preserving a small set of input-anchor covariances then produces finite tanh representations, whose VC dimension controls competing functions. Separately, a finite-width construction tracks a planted target signal and residual variance to lower-bound the target's actual prior probability. That construction needs a quantified width threshold; ordinary VC bounds handle every smaller realizable width. The resulting learning theorem has no such threshold.

**What the result does not say.** It does not make the function prior uniform or approximate circuit description length exactly. The prior's limiting rate $`J_L(f)=\lim_N a_N(f)`$ still controls exponential preferences at large width, and small positive rate differences are multiplied by $N$. The explicit finite-width construction need not be optimal for a target. Nor does the theorem bound the compressed network's weight norms or give an efficient posterior-sampling algorithm.

<a id="18-can-the-exponential-dependence-on-the-teachers-depth-be-removed-unconditionally"></a>

## 29. Can the exponential dependence on the *teacher's* depth be removed without a robustness restriction?

**For substantial Boolean target classes, yes; for arbitrary continuous-output teachers, no.** Several positive bounds are polynomial only at each fixed teacher depth: for example, for a tanh teacher of depth $D$, the exponent in the critical-depth bound of [Question 28](#28-without-a-robustness-restriction-what-depth-dependence-does-the-critical-gamma1-prior-have) grows linearly with $D$. Under the internal-noise robustness restriction of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence), Boolean-circuit targets have jointly polynomial depth dependence; this question concerns the unrestricted prior.

**A continuous-output counterexample.** The [continuous regression counterexample](works-in-progress/continuous-depth-lower-bound/) of [Question 26](#26-is-exponential-depth-dependence-necessary-without-any-robustness-restriction) has constant teacher width and bounded weights, but needs exponentially many examples in teacher depth. It uses the unrestricted Gaussian learner and a fixed nonuniform distribution on the circle. The general Boolean-cube question remains open. Teacher depth, learner depth, and the norm of a teacher representation are different parameters.

**Shallow representations and product norms.** The unrestricted results ([Questions 26](#26-is-exponential-depth-dependence-necessary-without-any-robustness-restriction) and [28](#28-without-a-robustness-restriction-what-depth-dependence-does-the-critical-gamma1-prior-have)) remove dependence on a chosen teacher's depth when the function has another controlled shallow representation. More generally, a globally unit-margin network whose weight matrices have product of Frobenius norms $P$ has a Boolean normal form with depth, width, and finite description polynomial in $P$, apart from specifying at most $P^2$ relevant input coordinates. This bound is independent of the original teacher's depth and width. The learning theorem for product-controlled targets has an explicit additional-learner-depth requirement.

**Why this does not cover all small networks.** However, $P$ can itself grow exponentially with the depth of a bounded-weight teacher. Replacing teacher depth by $P$ does not prove a polynomial bound in arbitrary neural-circuit size. Nor does it show that a same-depth, same-width robust realization, one satisfying the restriction of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence), always exists. Digital simulation of a margin-separated real neural circuit may add depth and width, and those costs must be counted.

Thus we should not advertise “depth dependence eliminated for all small neural networks.” The established statement is a collection of representation-sensitive improvements, plus a joint polynomial-depth theorem under the explicit robustness restriction for Boolean-circuit targets.

<a id="19-what-are-the-actual-polynomials-are-practical-sample-bounds-close"></a>

## 30. What are the explicit sample-complexity polynomials, and are practical sample bounds close?

**Substantially smaller bounds are available in several settings, but these are still theoretical sample guarantees.** Predicting useful numerical sample counts from the present estimates remains open. Most bounds below concern the internal-noise robustness restriction of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence), under which the Bayesian tanh learner's sample complexity is jointly polynomial in input dimension $d$, depth $L$, teacher width $C$, $c+c^{-1}$ for a calibration constant $c$, inverse accuracy $\varepsilon^{-1}$, and $\log(1/\delta)$ for failure probability $\delta$. The exponent $\gamma$ scales the prior variances with learner width $N$, with $\gamma=1$ mean field; the strong-prior limit sends the variance to zero at fixed width ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)). [Question 31](#31-what-do-the-shallow-lean-checked-and-unrestricted-deep-bounds-look-like) gives the shallow bound, and the original and Lean-checked polynomials for comparison.

**The improved bounds.** The [improved-polynomials papers](works-in-progress/improved-polynomials/) give explicit estimates, with independent AI-agent mathematical reviews. They are supporting research papers, **not Lean-verified improvements** to the collection's five main theorems. In the table, the powers of teacher width hold with input dimension, depth, calibration, accuracy, and confidence fixed; the papers also specify those dependences.

| Setting | Dependence on teacher width | Scope |
|---|---|---|
| [Original internal-noise robustness restriction, every mean-field-or-stronger scale](works-in-progress/improved-polynomials/original-support-all-scales/paper.pdf) | $O(C^6\log^{13}(2+C))$ | One sample event works at every $N\ge C$ and every $\gamma\ge1$, including the actual finite mean-field prior. No neuron-averaging assumption is added. |
| [Original restriction, stronger scales](works-in-progress/improved-polynomials/original-support/paper.pdf) | $O(C^4\log^9(2+C))$ | Strong-prior limit at each width, and actual finite priors at every $\gamma\ge2$. The quartic argument does not cover $1\le\gamma<2$. |
| [Additional stability under neuron averaging](works-in-progress/improved-polynomials/neuron-averaging/paper.pdf) | Quadratic, with polynomial depth dependence | Every $N\ge C$ and $\gamma\ge1$, but under a **stronger structural support condition**. This is not a quadratic bound for the original restriction alone. |
| [One hidden layer](works-in-progress/improved-polynomials/shallow/paper.pdf) | Quadratic when teacher readout coefficients are bounded independently of width; a quartic term for the original larger coefficient class | Every $N\ge C$ and $\gamma\ge1$. Covers the raw Gaussian prior as well as the globally margin-conditioned and shallow robust priors. Positive training margins are still required. |

The first three rows compare with layered Boolean circuits, including constant wires and compilation overhead. The shallow row compares with an implementing tanh network and states its coefficient assumptions separately. None of these rates is a lower bound or a claim of optimality.

**The original robust prior throughout $\gamma\ge1$.** The sextic bound retains exactly the main robustness theorem's learner: clipped predictions survive a calibrated ball of simultaneous internal disturbances; training requires signed output above $1/2$; test error uses margin $1/4$. Its sample polynomial is joint in depth and the other resources, independent of learner width and Gaussian scale. It controls the posterior average, so a strict $2/3$ confidence guarantee follows by rescaling the error tolerance by three.

The improvement comes from sampling source neurons partly uniformly and partly according to their contribution to retained directions, then matching the sampled covariance more accurately. This removes large truncation losses from the original compression proof. The [paper](works-in-progress/improved-polynomials/original-support-all-scales/) gives all intermediate budgets; the displayed sixth power describes dependence on $C$, **not** degree six in all parameters. A quadratic bound for this unchanged support condition remains open. The simpler quartic proof at $\gamma\ge2$ controls total network energy directly; that argument alone cannot discard the growing Gaussian background at mean-field scaling.

**What the quadratic alternative assumes.** The added condition, neuron averaging (also called neuron merging), requires a balanced grouping of neurons into at most $1+N\lVert v\rVert_2^2$ groups per hidden layer, where $v$ is the readout weight vector, such that averaging weights within the groups barely changes clipped predictions. The prior does not know the target's width, but it explicitly requires a small compressed representation relative to readout energy. Imposing this in addition to internal-noise stability further restricts the prior, and is a substantive structural assumption. A [follow-up theorem and naturality study](works-in-progress/improved-polynomials/neuron-merging-naturality/) allows signed, unequal groups and an output-normalized count budget while retaining quadratic dependence. It gives some rigorously certified ordinarily trained examples; no general training guarantee is established. [Question 32](#32-how-natural-is-the-neuron-merging-restriction) discusses how natural the condition is, and [Question 33](#33-are-there-more-natural-alternatives-to-neuron-merging-stability) discusses alternatives.

**Sharper bounds under neuron averaging.** At fixed calibration, a sharper bound for this prior is

$$
n=\widetilde O\!\left(\frac{L^2(d+LC)^2+\log(1/\delta)}{\varepsilon}\right),
$$

where the notation suppresses logarithmic factors, including accuracy logarithms. A literal quadratic-width envelope, with no hidden logarithms of $C$, is

$$
n\ge\frac{A}{\varepsilon}\left[C^2S_0^9+\log(1/\delta)\right],
\qquad S_0=2+d+L+c+\log(4/\varepsilon),
$$

for a universal constant $A$. It uses the bounded fan-in and single-output convention to prune irrelevant teacher wires and absorb their logarithmic cost into depth. A different, stronger calibration of the permitted group count gives approximately $\widetilde O((LdC+L^2C^2)/\varepsilon)$ at fixed calibration, accuracy, and confidence. Changing that calibration changes the prior restriction.

**For ReLU and GELU, the analogous merging restriction also gives a quadratic bound.** The [separate paper](works-in-progress/relu-gelu-polynomial-depth/paper.pdf) uses unsigned populations of arbitrary sizes and the same output-normalized count budget. It proves, for every $\gamma\ge1$,

$$
n\ge\frac{A}{\varepsilon}\left[C^2\bigl(2+d+L+\log(4/\varepsilon)\bigr)^9+\log(1/\delta)\right]
$$

as a sufficient sample budget for a single-output bounded-fan-in Boolean teacher, with input dimension $d$, depth $L$, accuracy $\varepsilon$, and failure probability $\delta$. Here $C$ counts the Boolean circuit's width, including constant wires; the eligible learner widths are $N\ge C$ for ReLU and $N\ge2C$ for the exact GELU compilation. A more informative nested budget has $O(C^2\log^3(2+C))$ dependence at fixed other resources. ReLU removes population-size parameters by homogeneity; GELU retains them but they admit a uniformly controlled finite cover. This is a conventional, independently reviewed result, not an update to the Lean polynomial ([Question 31](#31-what-do-the-shallow-lean-checked-and-unrestricted-deep-bounds-look-like)).

**Is quadratic the right target?** Quadratic dependence on teacher width is a useful dense-parameter benchmark, but not a universal lower bound. Bounded-fan-in Boolean circuits can have descriptions of order $LC\log(C+d)$ rather than $LC^2$ real parameters. A generic circuit-code prior can turn that description length into an Occam bound. Obtaining comparably sharp behavior for these Gaussian neural priors remains open, as does predicting useful numerical sample counts from the present estimates.

## 31. What do the shallow, Lean-checked, and unrestricted deep bounds look like?

**These are sufficient sample sizes from particular proof constructions, not claimed to be tight.** They complement the improved polynomials of [Question 30](#30-what-are-the-explicit-sample-complexity-polynomials-and-are-practical-sample-bounds-close). In brief: for one hidden layer, the bound is affine in a weighted squared norm of the teacher, and quadratic in teacher width up to logarithms when hidden coefficients are at most $C$ and readout coefficients are bounded by a fixed constant; the Lean-checked polynomial for the robust main theorem is deliberately loose, with degree 10974; and the deep bounds without a robustness restriction retain poor depth dependence. Whether quadratic width dependence is the right target is discussed at the end of [Question 30](#30-what-are-the-explicit-sample-complexity-polynomials-and-are-practical-sample-bounds-close). Throughout, $C$ is teacher width, $d$ input dimension, $L$ depth, $\varepsilon$ accuracy, and $\delta$ failure probability.

**The shallow bound is affine in a weighted squared norm, with a dimension overhead.** The [one-hidden-layer paper](works-in-progress/improved-polynomials/shallow/paper.pdf) compares with a width-$C$ tanh teacher with hidden matrix $W$ and readout $a$. Write

$$
\kappa_C=\frac dC\lVert W\rVert_F^2+C\lVert a\rVert_2^2.
$$

For the raw Gaussian prior, or the prior conditioned on a global output margin at every input ([Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here)), a sufficient sample bound is

$$
n=\widetilde O\!\left(\frac{d(\kappa_C+d)+\log(1/\delta)}{\varepsilon}\right).
$$

The additional $d^2$ term comes from the target-neighborhood probability estimate; the teacher norm need not dominate $d$. The shallow robust prior is also covered, with calibration dependence.

If hidden coefficients are at most $C$ and readout coefficients are bounded by a fixed constant, this is quadratic in $C$ up to logarithms; a second estimate is literally quadratic with a worse dimension factor. If **all** coefficients may be as large as $C$, then $\kappa_C$ can contain a $C^4$ readout term. The paper does not prove that this quartic dependence is necessary. Its argument controls the readout norm and represents tanh units as mixtures of halfspaces, avoiding the deep-network compressor.

**What is formally checked?** The robust main theorem of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence) restricts the prior by internal-noise stability, with calibration constant $c$. Its existing Lean proof still has the deliberately loose sufficient budget

$$
A\left[2+d+C+(L-2)+c+c^{-1}+\varepsilon^{-1}+\log(1/\delta)\right]^{10974}.
$$

The original manuscript's transport construction has a conservative degree-510 estimate. The new all-scales paper of [Question 30](#30-what-are-the-explicit-sample-complexity-polynomials-and-are-practical-sample-bounds-close) gives a much smaller conventional envelope,

$$
n\ge A\left[2+d+L+C+c+c^{-1}+\varepsilon^{-1}+\log(1/\delta)\right]^{46}.
$$

This degree-46 bound is still deliberately loose; the paper's explicit nested budget and its $C^6\log^{13}(2+C)$ rate are more informative. These are upper bounds from particular proof constructions, not necessary exponents. The smaller rates, here and in [Questions 30](#30-what-are-the-explicit-sample-complexity-polynomials-and-are-practical-sample-bounds-close) and [32](#32-how-natural-is-the-neuron-merging-restriction), have conventional proofs and separate review records; they have not been substituted into the [Lean verification record](lean/VERIFICATION.md#generalization-under-a-robustness-restriction-scope-and-correspondence).

**The unrestricted deep bounds retain poor depth dependence.** For comparison, consider the prior without a robustness restriction. In the strong-prior limit, the prior variance tends to zero at fixed width ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)), and the teacher width is the bounded-weight complexity $`C=C_L(f)`$ of [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here). The original [strong-prior proof](main-results/strong-prior-generalization/paper.pdf), outlined in [Question 2](#2-can-we-bound-the-prior-probability-of-a-function), bounds target energy by

$$
B_L(d,C)=d(d+1)C^2+LC^4
$$

and, at energy level $K$, uses compression width

$$
\rho=\frac{2^{-L}K^{-(L-1)/2}}{12(L-1)},
\qquad
m_L(d,K)=\max\!\left\lbrace \lceil9K\rceil,
\left\lceil256\rho^{-4}[d+\log(L/\rho)]\right\rceil\right\rbrace .
$$

If $Q_L(d,K)$ denotes the resulting log-class-size bound in that paper, then

$$
n\ge\frac2\varepsilon\left[Q_L(d,B_L(d,C)+1)+\log(1/\delta)\right]
$$

suffices in the strong-prior limit. The fixed-depth all-width mean-field proof likewise has rapidly growing intermediate budgets, including $O_L(dK^{4\cdot3^{L-2}-1})$. The unrestricted critical-depth results in [Question 28](#28-without-a-robustness-restriction-what-depth-dependence-does-the-critical-gamma1-prior-have) use a different finite-representation argument; their polynomials are also not optimized. Neither the robustness improvements of [Question 30](#30-what-are-the-explicit-sample-complexity-polynomials-and-are-practical-sample-bounds-close) nor the shallow theorem establishes a small joint polynomial for arbitrary unrestricted deep teachers.

<a id="how-natural-is-the-neuron-merging-restriction"></a>

## 32. How natural is the neuron-merging restriction?

**Every eligible layered Boolean circuit has a suitable implementation, but the condition is a real additional assumption on the learner.** This restriction, also called neuron averaging, is the stronger support condition under which [Question 30](#30-what-are-the-explicit-sample-complexity-polynomials-and-are-practical-sample-bounds-close) gives quadratic dependence on teacher width $C$, with polynomial depth dependence. It is imposed in addition to the internal-noise stability of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence). In its original form, it keeps only networks whose neurons in each hidden layer can be grouped into at most $`1+E_v`$ balanced groups such that averaging weights within the groups barely changes clipped predictions. Here $`E_v=N\lVert v\rVert_2^2`$ is the readout energy of a width-$`N`$ network with readout weights $v$.

**Good implementations exist.** At every learner width $N\ge C$, the construction assigns cloned neurons to the circuit's wires. Merging preserves its output, and an explicit neighborhood with positive Gaussian probability also satisfies the restriction. This proves existence of good implementations, not that all implementations of the same function qualify.

**Signs and group sizes.** The original unsigned condition has an artificial dependence on neuron signs: flipping a tanh neuron's incoming and outgoing signs preserves the function and Gaussian density but can break averaging. The [signed-merging paper](works-in-progress/improved-polynomials/neuron-merging-naturality/paper.pdf) fixes this and also permits unequal group sizes. Both changes preserve quadratic teacher-width and polynomial depth dependence for every $\gamma\ge1$ and every $N\ge C$, where $\gamma$ is the prior-scaling exponent of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings).

**The group-count budget.** The calibration of the number $q$ of groups also matters. The original budget $`q\le1+E_v`$ permits the identity partition, with every neuron in its own group, whenever $`E_v\ge N-1`$. Such membership does not demonstrate compression. A proved alternative is

$$
(q-1)\left(\max_x|z_w(x)|\right)^2\le4E_v(w).
$$

This count budget is independent of a global readout rescaling. The complete condition still uses clipped outputs and fixed margins. A more local sufficient condition asks neurons in a signed group to respond similarly to signals constant within the preceding groups; together with the original internal-noise condition, it implies merging stability and still gives the quadratic bound. These variants are more principled, but none is established as a general property of gradient training.

**The empirical evidence is mixed and search-dependent.** All 40 fresh tanh networks in the [reproduction package](works-in-progress/improved-polynomials/neuron-merging-naturality/experiments/), separate from the robustness experiments of [Question 24](#24-do-gradient-trained-networks-satisfy-the-robustness-condition), fit their training margins after ordinary SGD or Adam from mean-field initialization. Five pass the original count budget automatically. Among the remaining 35, unsigned balanced activation clustering found no witnesses; signed clustering found six, and an additional output-aware sign search raised the total to 14. Across all 40 models, that follow-up found 11 networks reducible to one signed population per layer. The searches use the network's own activations and outputs, not target labels. A failed search does not prove failure of an existential condition.

Three examples have exhaustive interval certificates, including a width-32, four-hidden-layer Adam network whose clipped outputs are preserved exactly by one signed population on all 256 inputs. Other witnesses use exhaustive float64 checks. These certify merging stability, not automatically internal-noise robustness or Bayesian learning behavior. The local operator-norm certificate is too conservative to explain these examples at the small noise calibrations previously tested. A quadratic bound under the original internal-noise restriction alone remains open.

<a id="are-there-more-natural-alternatives-to-neuron-merging-stability"></a>

## 33. Are there more natural alternatives to neuron-merging stability?

**Yes, with different tradeoffs. The strongest candidate here is stability to internal noise together with bounded hidden activity.** Neuron-merging stability ([Questions 30](#30-what-are-the-explicit-sample-complexity-polynomials-and-are-practical-sample-bounds-close) and [32](#32-how-natural-is-the-neuron-merging-restriction)) restricts the prior to networks whose weights can be averaged within suitably few groups of neurons per hidden layer without changing clipped predictions; it gives quadratic dependence on teacher width $C$. Neuron merging directly requires that a particular small representation preserve predictions; that makes its connection to the proof unusually close. A condition about tolerating numerical errors has a motivation independent of compression. The [alternative-restriction notes](works-in-progress/robustness-alternatives/) give completed arguments for three alternatives, together with their limitations.

Below, $\gamma$ is the exponent that scales the Gaussian prior variances with learner width $N$ ($\gamma=1$ is mean field), and the strong-prior limit sends the prior variance to zero at fixed width ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)).

**Internal noise and bounded activity.** Keep the requirement of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence) that clipped predictions survive every simultaneous internal disturbance within the calibrated root-mean-square (RMS) noise ball. Additionally require every hidden state's RMS magnitude to remain below a fixed bound throughout that same noise ball. Individual neurons can still be large; this is not a coordinatewise activation cap. Neither condition mentions neuron groups, pruning, or a compressed network.

For ReLU and GELU, these conditions give a [polynomial-depth learning theorem](works-in-progress/robustness-alternatives/internal-noise.md) in the strong-prior limit and for every finite $\gamma\ge2$, at every learner width $N\ge2C$. Here $C$ is layered Boolean teacher width, with constant wires counted. The sample bound has roughly sixth-power dependence on $C$, up to logarithms, and polynomial dependence on depth. The prior retains our global output-margin convention. Every eligible Boolean circuit has a suitable implementation: pairs of neurons implement gates that restore perturbed bits to the correct logical state, at the same depth and twice the width. The proof then derives compression by clipping at justified neuronwise envelopes and sampling neurons with probabilities proportional to squared envelope size.

This is a more directly motivated restriction than merging, at the cost of a worse width polynomial and a narrower proved finite-scale range. **The extension to $1\le\gamma<2$ remains open for this ReLU/GELU theorem.** For tanh, the original internal-noise condition already has an all-$\gamma\ge1$ theorem ([Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence)); it does not need this added activity condition because tanh itself bounds the pre-disturbance activations.

**A path-norm cap.** The absolute ReLU path norm sums absolute weight products along all input-to-output paths. It is computable by a forward pass through the absolute-weight network and is unchanged by positive neuron rescaling with compensating outgoing rescaling. Write $\mathcal P(w)$ for this path norm. By the [path-norm note](works-in-progress/robustness-alternatives/path-norm.md), a hard cap $\mathcal P(w)<R$, declared before seeing labels, gives a sufficient bound of order

$$
\frac{R^2\,[L+\log(d+1)]\,(d+1)+\log(1/\delta)}{\varepsilon},
$$

at every eligible width and every positive Gaussian scale, where $d$ is input dimension, $L$ depth, $\varepsilon$ accuracy, and $\delta$ failure probability. A Boolean **formula** with $s$ gates has a ReLU implementation with path norm at most $4s+3$, so this gives quadratic dependence on formula width and polynomial depth. The distinction between a formula and a circuit matters: a circuit may reuse a subcomputation many times. We have not shown that every small circuit has polynomial path norm. Nor does a fixed cap automatically adapt to an unknown smaller target. This theorem works even at prior scales outside the usual good regime (the strong-prior limit and $\gamma\ge1$) because the new restriction makes the entire hypothesis class small; it does not describe the original unrestricted function prior.

**Severe dropout stability.** A [third theorem](works-in-progress/robustness-alternatives/dropout.md) requires predictions to survive random neuron subsampling with inverse-retention rescaling, down to a count calibrated by readout energy. For tanh it gives quadratic teacher-width dependence up to logarithms and polynomial depth, in the strong-prior limit and for every $\gamma\ge2$, at every $N\ge C$. For the Boolean teacher witnesses, $O(C\log(LC))$ retained neurons suffice even when $N$ is arbitrarily large; the general support condition uses each network's own readout-energy/output-amplitude ratio, not the unknown teacher width. The operation is familiar, but this degree of redundancy is stronger than ordinary dropout. Fixed-fraction dropout still leaves a number proportional to $N$. This alternative remains a compression assumption, and its mean-field extension is open.

**Why not just bound spectral norms or input sensitivity?** A per-layer norm bound slightly above one can still compound through depth. The [counterexamples](works-in-progress/robustness-alternatives/obstructions.md) show that low normalized energy, polynomial input Lipschitzness, and an internal spectral cap by any fixed constant greater than one can coexist with every Boolean truth table. That is a capacity obstruction, not a posterior sample lower bound. Another example contracts a signal and later expands it: its path norm is one, but a tiny disturbance in the middle erases the signal. Thus input sensitivity, total path norm, and finite internal-noise stability control different properties. Bounds on actual accumulated amplification, with the right width normalization, are more promising than isolated layer norms or clean-state Jacobians ([Question 23](#23-how-can-we-check-whether-a-network-satisfies-the-robustness-condition)).

**What is known about trained networks?** Existing tanh experiments give mixed evidence for internal-noise and merging certificates ([Questions 24](#24-do-gradient-trained-networks-satisfy-the-robustness-condition) and [32](#32-how-natural-is-the-neuron-merging-restriction)); they do not certify these new ReLU/GELU conditions. A [small dropout diagnostic](works-in-progress/robustness-alternatives/dropout.md#a-small-diagnostic-on-already-trained-networks) reuses twelve ordinary Adam-trained tanh networks. Four had perfect full-cube classification and clean margins above $1/2$, yet at 75% retention only 6–21 of 100 sampled masks preserved their entire clipped function, despite average sign disagreement of only 0.2–1.3%. This illustrates the gap between average accuracy and uniform score preservation. It is not a general empirical conclusion or an exact certificate. The theorem's deliberately conservative retention calibration keeps all neurons at these small widths, so the diagnostic does not refute membership in its literal support condition.

Dropout training, numerical precision tolerance, and norm regularization motivate the candidates, but do not imply the required quantitative, all-input statements. Our current preference is to investigate finite internal-noise stability and bounded activity first. A natural condition known to hold for relevant trained networks and giving the general quadratic-width theorem throughout $\gamma\ge1$ remains a research goal.

These notes have independent AI-agent mathematical reviews and are **not Lean verified**.

<a id="20-do-independent-non-gaussian-weight-priors-give-the-same-results"></a>

## 34. Do independent non-Gaussian weight priors give the same results?

**Yes, for a substantial family of independent coordinate laws.** The original tanh model has independent Gaussian weights, with variances set by width and an exponent $\gamma$ ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)), and a prior conditioned on a global output margin ([Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here)). The [non-Gaussian paper](side-results/non-gaussian-priors/paper.pdf) proves, for tanh networks, analogues of the first three [main results](README.md#main-results): the strong-prior limit (prior variance tending to zero at fixed width), fixed $\gamma>1$, and the mean-field scaling $\gamma=1$. They hold when the weights are independent and each standardized weight has an even, variance-one density

$$
q(u)=Z^{-1}e^{-V(u)},\qquad V\in C^2,\qquad
0<m\le V''(u)\le M<\infty.
$$

The constants $m,M$ are fixed independently of width. The condition says that the negative log density $V$ has positive curvature bounded above and below; it need not be quadratic. For example, take the variance-standardized version of the density proportional to $e^{-u^2/2-b\log\cosh u}$, for any fixed $b>0$.

**What carries over.** The conclusions retain the original layer scales, global margin conditioning, exact noiseless-label posterior, arbitrary common training/test distribution, and **every learner width $`N\ge C_L(f)`$**. Here $`C_L(f)`$ is the target's bounded-weight network complexity at depth $L$ ([Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here)). At each fixed depth, the sample bound is polynomial in dimension and target complexity, independently of learner width. This covers both the strong-prior limit at each fixed width and the finite-scale regimes $\gamma>1$ and $\gamma=1$. Correct-label posterior probability exceeds $2/3$ on almost all test inputs, including when the posterior mixes different functions. No added restriction on which network functions the prior supports is needed.

**How the proof adapts.** The proof replaces Gaussian target-mass calculations with a translation bound and concentration for the stated coordinate laws. At $\gamma=1$, a quantitative replacement argument compares **log partition functions for bounded covariance tests**, with only polynomial losses in the test budget. Auxiliary Gaussian distributions help construct short descriptions of likely functions; the learner itself keeps its non-Gaussian weights. The paper also proves polynomial comparison between bounded-weight circuit complexity and normalized negative log function prior mass: the analogue of the Gaussian comparison in [Question 2](#2-can-we-bound-the-prior-probability-of-a-function).

**The strong-prior result permits more general laws.** Two-sided quadratic density envelopes suffice, without symmetry or log-concavity. If the negative log density is asymptotic to a common quadratic coefficient times $u^2$, the original weighted-energy ordering of function probabilities ([Question 2](#2-can-we-bound-the-prior-probability-of-a-function)) holds exactly at exponential-rate level. Curvature bounds alone give the learning guarantee and polynomial comparisons, but need not give a limiting exact rate.

**Scope and status.** These are conventional proofs with [independent AI-agent review records](side-results/non-gaussian-priors/verification/README.md); the extension is a side result and **has not been Lean verified**. The sample polynomials may depend on the coordinate law and depth. The theorem does not cover Laplace, uniform, Student, or pure quartic-exponential coordinates at the original scales. For a compactly supported law, taking the scale to zero at fixed width can even make the global-margin conditioning event empty. Broader families, alternative width normalizations, and non-Gaussian subcritical ($\gamma<1$) learning remain open.

<a id="21-what-about-relu-sigmoid-gelu-or-other-activations"></a>

## 35. What about ReLU, sigmoid, GELU, or other activations?

**The positive learning theorem covers every fixed globally Lipschitz activation that vanishes at zero.** This includes ReLU, exact GELU, SiLU, tanh, centered softplus, and centered bounded sigmoids. The original model uses a bounded hidden activation, usually tanh ([Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here)). The [unified activation paper](works-in-progress/unbounded-activations/paper.pdf) gives one fixed-depth polynomial sample bound throughout the mean-field-or-stronger Gaussian regime, that is, $\gamma\ge1$ in the scaling family of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings), at every learner width above teacher complexity. This result needs no additional robustness restriction of the kind in [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence).

**The setting.** The input domain is the Boolean cube, and the readout is linear. A teacher of depth $L$ and width $C$ has weights bounded by $C$ and signed output margin strictly greater than $1/2$ at every input. The learner uses independent Gaussian weights with variances

$$
\frac{t^2}{d},\qquad \frac{t^2}{N},\qquad \frac{t^2}{N^2}
$$

in the first layer, internal layers, and readout, respectively, with $0<t\le1$. Its prior is conditioned on $|z_w(x)|>1/2$ at every Boolean input; training then conditions on exact noiseless labels.

**The guarantee.** For any common iid training and test distribution on the cube, a sufficient sample bound is

$$
n\ge\frac{p_{L,\lambda}(d,C,\log(1/\varepsilon))+O(\log(1/\delta))}{\varepsilon},
$$

where $\lambda$ bounds the activation's Lipschitz constant. With probability at least $1-\delta$, posterior average sign error is at most $\varepsilon$, simultaneously for every $N\ge C$ and every $0<t\le1$. Taking $t=N^{(1-\gamma)/2}$ recovers the layer variances of [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings), so the bound covers **all $\gamma\ge1$, including deep mean field**, with no deterioration as $\gamma$ approaches one. Using $\varepsilon/3$ gives correct-label posterior probability strictly greater than $2/3$ on all but an $\varepsilon$ fraction of test inputs. The polynomial is large, and its degree depends on depth.

**Why are ReLU and GELU harder than tanh?** Tanh bounds each hidden activation by one. ReLU and GELU permit an individual neuron to make a very large contribution, so a compression argument cannot assume every neuron is harmless to omit. The proof controls the total contribution of large neurons and retains an approximation to it.

There are two parts to this control. A capacity bound uses products of layer norms to bound how many globally margin-separated Boolean functions low-energy networks can represent, independently of their width. At small prior scales, spectral truncation then removes matrix components with small operator norm. At mean field, those components are no longer small enough to discard: the proof represents their covariance using bounded Gaussian features, while a separate construction retains rare large contributions with controlled total cost. Keeping that tail matters because conditioning on a target can make an ordinarily rare event significant.

**ReLU's rescaling identity helps, but GELU does not need to share it.** For $a>0$, ReLU satisfies $\mathrm{ReLU}(au)=a\,\mathrm{ReLU}(u)$, which allows a simpler norm argument in the [earlier ReLU paper](works-in-progress/relu-learning/). GELU does not satisfy this identity. The common proof instead allows its *auxiliary counting networks* to have different Lipschitz activations at different neurons; the capacity bound controls all those choices uniformly. The actual Bayesian learner always uses its original fixed activation. Thus the generic theorem is a learning guarantee. It is not a claim that the auxiliary reconstruction uses the same activation, nor a converse comparing smallest fixed-activation implementations with prior probability.

**Boolean circuits supply the required teachers for ReLU and GELU.** Layered NOR/COPY/NOT circuits have exact ReLU implementations. An exact two-neuron GELU identity implements each gate at the same depth, with hidden width at most twice the Boolean circuit width and weights bounded by four. Constant wires and any compilation from another gate basis must be counted. For a general activation, the theorem assumes the specified teacher exists; it does not infer such an implementation merely from universal approximation.

**Polynomial-depth results use additional restrictions.** The [ReLU/GELU neuron-merging paper](works-in-progress/relu-gelu-polynomial-depth/) gives quadratic teacher-width dependence up to logarithms and polynomial depth dependence for every $\gamma\ge1$. Its prior keeps networks whose clipped predictions survive averaging neurons into suitably few populations. Every eligible Boolean circuit has a positive-mass implementation satisfying this condition. An [alternative theorem](works-in-progress/robustness-alternatives/internal-noise.md) uses internal-noise stability and bounded noisy hidden activity instead; it covers ReLU/GELU in the strong-prior limit and at every $\gamma\ge2$, with roughly sixth-power width dependence and polynomial depth. Neither condition is established as typical of gradient-trained networks. [Question 32](#32-how-natural-is-the-neuron-merging-restriction) gives the ReLU/GELU merging polynomial (the merging condition itself is described in [Question 30](#30-what-are-the-explicit-sample-complexity-polynomials-and-are-practical-sample-bounds-close)), and [Question 33](#33-are-there-more-natural-alternatives-to-neuron-merging-stability) discusses the tradeoffs between the alternatives.

**What is not covered.** An activation with a nonzero value at zero is outside the theorem as stated; an ordinary uncentered sigmoid is an example. Hard thresholds fail the Lipschitz assumption. The $\gamma<1$ lower bounds ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)) and the tanh-specific unrestricted-depth constructions ([Questions 26](#26-is-exponential-depth-dependence-necessary-without-any-robustness-restriction) and [28](#28-without-a-robustness-restriction-what-depth-dependence-does-the-critical-gamma1-prior-have)) also require separate analysis for other activations. These positive activation results have independent AI-agent mathematical reviews and reproducible PDFs; **they are not Lean verified**.

<a id="can-we-bound-the-total-number-of-mistakes-during-learning"></a>
<a id="can-we-bound-total-mistakes-and-recover-circuit-complexity-from-them"></a>

## 36. Can we bound the total number of mistakes during online learning?

**Yes: the good NNBayes regimes have polynomial total-mistake bounds when Boolean inputs arrive uniformly at random.** Here NNBayes is the Bayesian posterior of the original model: a neural network whose Gaussian weight prior is conditioned on a global output margin, and then on exact training labels ([Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here)). Its good regimes are those with polynomial sample bounds in [Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings). The [online-learning paper](works-in-progress/online-mistakes/upper/) proves bounds in expectation and with high probability for the original strong-prior, fixed $\gamma>1$, and mean-field ($\gamma=1$) learners. The same statistical argument applies to the [unified activation theorem](works-in-progress/unbounded-activations/) of [Question 35](#35-what-about-relu-sigmoid-gelu-or-other-activations), including deep ReLU and GELU throughout $\gamma\ge1$. At fixed depth, the bounds are polynomial in teacher complexity and input dimension, independently of learner width.

**The online protocol.** The learner sees an input, predicts its label, and then receives the true label, even when its prediction was correct. It conditions on every revealed label. The bound counts mistakes over the **entire** learning process, including mistakes on rare inputs first encountered much later. A fixed-sample accuracy guarantee alone does not bound this total; on the cube, the trivial upper bound is still $2^d$ mistakes.

On a finite domain, exact conditioning makes every repetition of a previously revealed input correct. An infinite uniform iid stream therefore has the same total-mistake law as one uniformly random permutation of the whole cube. Both sampling protocols are covered.

**Which notion of mistake?** Let $`p_j`$ be the posterior probability of the correct answer at round $j$, and let $`S=\sum_j(1-p_j)`$ be cumulative posterior error. The theorem bounds $S$ and the actual number of errors made by posterior sampling, with separate expectation and high-probability guarantees. Two other prediction conventions follow directly:

- Posterior-majority mistakes, with any tie rule, are at most $2S$.
- Failures of the criterion “the correct label has probability strictly greater than $\theta$” are at most $S/(1-\theta)$, for every fixed $0<\theta<1$.

Thus the strict `>2/3` criterion costs a factor of three. These statements allow arbitrary mixtures of tied minimizers. The pointwise inequalities above concern $S$; an actual sequence of posterior-sampling errors additionally requires the sampling concentration argument in the paper.

**Why does the sample-complexity argument extend?** Suppose a fixed relevant family contains the target, has log cardinality at most $h$, and the prior mass outside it is at most $\beta$ times the target's prior mass. The posterior then keeps at least $1-\beta$ of its mass in that family after every noiseless history. On a domain of size $M$, the expected number of posterior-sampling mistakes in random order is at most

$$
1+2(h+1)H_{M-1}+M\beta,
$$

where $`H_r=\sum_{j=1}^r1/j`$. On the cube, $M=2^d$ and $`H_{M-1}=O(d)`$. Choose $\beta=2^{-d}$: the neural compression theorems pay only polynomially for $\log(1/\beta)$, so $h$ and the resulting total-mistake bound remain polynomial. High-probability bounds add only polynomial dependence on $\log(1/\delta)$. Some earlier small-width branches use the direct Bayesian log-prior bound instead.

**Width and depth.** These cumulative probability statements concern each fixed learner, with constants independent of its width. They do not assert one event controlling the sampled predictions of every width simultaneously. In the original strong-prior argument, the sufficiently small variance is chosen separately at each width, and that one choice works for the entire stream.

The neuron-merging restrictions on the prior ([Question 32](#32-how-natural-is-the-neuron-merging-restriction)) also give polynomial **depth** dependence for layered Boolean-circuit teachers, counting constant wires and compilation overhead. The weaker internal-noise restriction of [Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence) has a present approximate-compression proof that does not yet establish that cumulative polynomial-depth extension.

**The input-order assumption is substantive.** For a nonuniform iid distribution on a finite support, an expected bound depends on $`\log(1/p_{\min})`$, where $`p_{\min}`$ is the smallest positive input probability. It stays polynomial when that logarithm does. A finite family with sufficiently unequal prior weights can nevertheless make many mistakes in an adverse order, or under a sufficiently nonuniform distribution. These examples refute an arbitrary-order inference from class cardinality alone; they are not counterexamples proved for the particular Gaussian neural priors. The desired width-independent Gaussian guarantee in arbitrary order remains open. The genericity argument of [Question 38](#38-why-expect-occam-learning-to-transfer-out-of-distribution) describes one possible route.

The cumulative results and their activation extensions have independent AI-agent mathematical reviews, not Lean formalizations. For the converse question, whether few mistakes imply that the target has a small circuit, see [Question 37](#37-does-making-few-mistakes-imply-that-the-target-has-a-small-circuit).

<a id="does-making-few-mistakes-imply-that-the-target-has-a-small-circuit"></a>

## 37. Does making few mistakes imply that the target has a small circuit?

**For specified circuit-induction rules, yes. For NNBayes, we have converses in a particular order of limits, including a polynomial-depth result under additional prior restrictions.** The setting is the online protocol of [Question 36](#36-can-we-bound-the-total-number-of-mistakes-during-online-learning): the learner predicts each input's label, then sees the true label, and we count its mistakes over the whole process. That question bounds the total for the Bayesian neural-network posteriors (NNBayes) in their good regimes, when inputs arrive uniformly at random; a converse asks whether a small total forces the target to be simple.

**Why assumptions are needed.** A converse needs assumptions about both the learner and which inputs are eventually revealed. An arbitrary learner can hard-code a complicated target and make no mistakes. Even an informative learner's success on a small observed subset says little about the target elsewhere.

**Circuit induction has precise converses.** In the [circuit-converse paper](works-in-progress/online-mistakes/circuit-converse/), $C(f)$ counts NAND gates with unrestricted depth. After the full input domain is revealed:

- A learner that always predicts with a smallest consistent circuit satisfies $C(f)\le(3d+3)B$, where $B$ is its actual total mistake count.
- For Bayesian posterior sampling with a geometric prior on gate count and uniformly random wiring conditional on that count, expected total mistakes $m$ imply $C(f)=O(dm\log(d+dm))$.
- An explicit prefix circuit language with a short exception constructor improves the latter bound to $O(dm+1)$.

The first argument is particularly simple. A correct prediction leaves the smallest compatible circuit size unchanged. After a wrong prediction, the current circuit can be repaired at that single input with at most $3d+3$ new gates. Summing those increases bounds the final circuit size. For Bayesian sampling, the analogous proof must also control the probability cost of repairs; injectivity of the description repair and the prior's length tail matter. Merely saying that the prior favors small circuits is insufficient.

The two Bayesian circuit converses use **expected posterior-sampling errors**. They do not assert the same converse for posterior majority, or for one run with unusually lucky sampled predictions. All three results allow arbitrary reveal order with complete coverage. An infinite iid stream with full support supplies that coverage; on a smaller support the circuit conclusion concerns an extension agreeing with the target there.

**The neural converses currently concern tanh and take the strong-prior limit first.** At each fixed learner width, first let the Gaussian prior variance tend to zero; then let width tend to infinity. The limiting predictor is supported on functions of minimum compatible limiting energy. Here a function's energy is the least weighted squared parameter norm of a network realizing it with the prescribed margin; it governs prior probability ratios in the strong-prior limit ([Question 2](#2-can-we-bound-the-prior-probability-of-a-function)). The predictor can sample from these minimizers, select one, or use a posterior majority or confidence threshold. Ties are allowed. The full domain must eventually be revealed, but its reveal order can be arbitrary.

Here complexity $`C_L(f)`$ means the smallest width of a tanh network of depth $L$ realizing $f$ with signed margin greater than $1/2$ and with every weight bounded by that width. This differs from the NAND gate count above. Let $m$ be the actual or expected total mistakes under the selected neural prediction rule. The [neural converse note](works-in-progress/online-mistakes/nn-converse.md) proves, under the original global-margin support (the prior conditioned on $`|z_w(x)|>1/2`$ at every input; [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here)),

$$
C_L(f)\le\mathrm{poly}_L(d)\exp(O_L(m)).
$$

Adding a fixed output cap $|z_w(x)|<U$, with $U>1$, makes the converse polynomial in $d,U,m$ at each fixed depth. The cap matters because correcting a very large wrong output can otherwise cost a great deal of energy. These neural statements cover actual or expected total mistakes under the specified minimum-energy prediction rules, including sampling, majority, and failures of any fixed confidence threshold.

**An additional control on internal amplification gives polynomial dependence on depth.** The [polynomial-depth converse](works-in-progress/online-mistakes/depth-polynomial-converse/) keeps the output cap and requires a certificate bounding how finite internal disturbances reach the output. It is a condition on the network weights, independent of the target, training sample, and mistake count. Requiring every internal matrix to have operator norm strictly below one is sufficient; the certificate also allows some expansions compensated by later layers.

For fixed cap $U>1$ and certificate parameter $\Lambda>1$, put

$$
K=1+P(d,L,U)(m+1)^2,
\qquad P=O\!\left(d^3\log^2(2+d)+L(U+1)^2\right).
$$

The target then has a tanh network of the same depth, with width and individual weights bounded by

$$
\left\lceil65536\Lambda^2K\bigl[1+(L-1)K\bigr]
\bigl[d+\log(400L)\bigr]\right\rceil.
$$

The leading dependence on mistakes is fourth power; the polynomial degree and implicit constants are independent of depth. The proof repairs a new label with an exact singleton correction, increasing the square root of minimum energy by only a polynomial-depth additive cost. Every strict increase in minimum compatible energy forces a mistake under each of the stated prediction conventions. A deterministic compressor then turns the resulting energy bound into a small network.

**Scope.** This is a converse for the **strong-prior-then-width limit**, not for every fixed realizable learner width or for the finite-exponent mean-field posterior. It does not remove the output cap or prove that every small deep Boolean circuit has a cheap implementation satisfying the amplification certificate. The reconstructed small network need not itself satisfy the prior restriction. These converses are independently AI-reviewed and are not Lean verified.

<a id="why-expect-occam-learning-to-transfer-out-of-distribution"></a>

## 38. Why expect Occam learning to transfer out of distribution?

**Heuristic: when the simplest surviving explanation is wrong, its mistake often rules out many other surviving explanations.** Occam learning here means predicting with a simplest hypothesis consistent with the labels seen so far. [Question 36](#36-can-we-bound-the-total-number-of-mistakes-during-online-learning) proves polynomial total-mistake bounds for the Bayesian neural-network posteriors (NNBayes) when inputs arrive uniformly at random; the desired width-independent guarantee for the Gaussian priors in arbitrary input order remains open. This question describes a conditional argument, for a learner that predicts with a shortest consistent description, that needs no iid assumption.

**The intuition.** A physicist's argument runs as follows. The simplest hypothesis still consistent with the observations is not too atypical of the remaining hypotheses simpler than the target. When it makes a mistake, a substantial fraction of those hypotheses should often make the same mistake. Revealing the correct label then eliminates them together. There can only be logarithmically many substantial reductions of a finite candidate pool.

**A conditional counting argument.** Suppose the target $f$ has a description of length $b$ bits. Let $`V_t`$ contain all descriptions of length at most $b$ still consistent with the labels observed before round $t$, and predict with a shortest consistent description. Include descriptions of the same length as the target so that ties are covered. The target's description always survives. Write $`M_0=|V_0|`$; for binary descriptions, $`M_0<2^{b+1}`$.

Suppose that among the first $m$ mistakes, at least $\beta m$ of them each eliminate at least an $\alpha$ fraction of the **current survivors**. Then

$$
1\le |V_{\mathrm{after}}|\le M_0(1-\alpha)^{\beta m},
\qquad
m\le\frac{\log M_0}{\beta\log(1/(1-\alpha))}
\le\frac{\log M_0}{\alpha\beta}.
$$

For example, the 10%/10% condition ($\alpha=\beta=0.1$) gives fewer than $66(b+1)$ mistakes. If this condition, the genericity premise, continues to hold as the sequence grows, it bounds the total number of mistakes. A circuit over a fixed finite gate basis has description length polynomial in its width, depth, and input dimension, so this gives the desired polynomial bound **conditional on the genericity premise**. Counting wrong hypotheses in the original pool would not suffice: they may already have been ruled out.

**A probabilistic version.** One probabilistic formulation makes the intended typicality explicit. Let $`Z_t`$ indicate that the simplest survivor is wrong, and let $`q_t`$ be the fraction of current survivors wrong on that same input. The condition

$$
\mathbb E[q_t\mid Z_t=1,\text{past observations}]\ge c>0
$$

says that, conditional on a mistake by the simplest survivor, a uniformly sampled surviving description also has a nonnegligible chance of being wrong. It implies an expected total mistake bound of $`\log M_0/c`$: revealing a label decreases $`\log|V_t|`$ by $`-\log(1-q_t)\ge q_t`$, and the total available decrease is at most $`\log M_0`$. This is a precise version of the heuristic that the simplest predictor's errors are not usually exceptional among the other low-complexity candidates. Approximate independence of the two error events would suffice if the comparison candidate's error probability were also bounded below; independence alone does not supply that lower bound.

**Changing input distributions.** The counting step needs no iid assumption. It allows inputs from changing or previously unseen regions, provided the genericity premise continues to hold and the true label is revealed after each prediction. This is why the argument is relevant to out-of-distribution learning. It gives an **online mistake bound with feedback**, rather than a guarantee for a predictor trained once and then tested without further labels under an arbitrary shift.

**What remains heuristic.** The heuristic part is whether this genericity premise holds for relevant tasks, representations, and input sequences. A sequence can instead expose errors peculiar to the current simplest hypothesis, eliminating very few other candidates at each mistake. Establishing that such behavior is atypical, and transferring the argument from a simplest-consistent description to the actual NNBayes posterior, remain open. The present iid theorems do not establish those claims.

<a id="24-do-the-good-generalization-results-survive-a-small-amount-of-label-noise"></a>

## 39. Do the good generalization results survive a small amount of label noise?

**Yes, when the noise rate is sufficiently small relative to dimension, depth, and target complexity.** The [noisy-interpolation theorem](works-in-progress/noisy-interpolation/README.md) gives a clean-error bound for fixed-depth tanh networks that fit every training label, including flipped labels. The tolerance is inverse-polynomial, with large explicit constants that were not optimized. The proof has undergone independent AI-agent mathematical checks; it is a supporting result, not a Lean-verified main result.

The learner is the original model of [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here): a Gaussian prior on tanh-network weights, conditioned on output margin $`|z_w(x)|>1/2`$ at every Boolean input $x$ and then exactly on the training labels. The theorem takes the **strong-prior limit**: the prior variance $\sigma^2$ tends to zero at each fixed learner width $N$ ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)). Without noise, that limit needs only polynomially many samples at fixed depth.

**Sampling and conditioning conventions.** The sampling convention matters: choose $n$ distinct points uniformly from the Boolean cube, flip each label independently with probability $\eta$, and evaluate against the underlying clean function. Keep the original Gaussian prior, its all-input margin restriction, and exact conditioning on the observed labels. Thus the clean target itself is excluded when any label flips; the proof constructs a different, inexpensive network that fits all the corruptions.

**The bound.** Suppose the clean target has an implementation of depth $L$ and width $C$ with weights bounded by $C$, margin above $1/2$, and output magnitude at most $U\ge1$. At every sufficiently large learner width $N$, the strong-prior limit satisfies a bound of the form

$$
\limsup_{\sigma\downarrow0}R_{\mathrm{clean}}(N,\sigma)
\le P(d,L,U)\eta+
\frac{B_L(d,C,U)+P(d,L,U)\log(2/\delta)}{n}
\quad\text{with probability at least }1-\delta.
$$

Here $`R_{\mathrm{clean}}`$ is posterior average error against the clean function on the full cube. The function $P$ is a polynomial jointly in its arguments; $`B_L`$ is polynomial in $d,C,U$ at each fixed depth, with potentially bad depth dependence. Constants are absorbed into these two functions.

Every bounded-weight target has $U\le C^2$, so this covers the original target class. A layered Boolean circuit can instead be implemented with $U=1$, counting constant wires and compilation overhead: **for these targets the coefficient of the noise rate is independent of circuit width**, although the sample overhead still depends on it.

**Learner width.** The learner width must be large enough to accommodate the corruptions: a sufficient threshold is a constant times $C$, plus a polynomial in $d,U$ times $\eta n+\log(2/\delta)+1$. The theorem holds at **every** width above that threshold, with prior variance tending to zero separately at each fixed width. It does not retain the noiseless condition $`N\ge C_L(f)`$ alone, where $`C_L(f)`$ is the least width of a bounded-weight depth-$`L`$ network realizing the target ([Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here)). A network just large enough for the clean target may be unable to interpolate the noisy labels. The strong-prior posterior concentrates on the consistent functions of minimum energy $`\kappa_N`$, the least weighted squared parameter norm of a network realizing the function ([Question 2](#2-can-we-bound-the-prior-probability-of-a-function)); the proof controls all of them, so mixtures of tied minimizers cause no gap.

**Adversarial corruptions.** The stronger statement proved in the note allows **any** $s$ corrupted labels, even chosen after seeing the sample, and bounds clean error by

$$
\frac{B_L(d,C,U)+P(d,L,U)s+8\log(1/\delta)}{n}.
$$

The allowed number of corruptions can be proportional to $n$. For accuracy $\varepsilon$, it gives polynomial sample complexity at fixed depth when $\eta$ is smaller than $\varepsilon$ divided by a resource polynomial. To measure error on unseen inputs, multiply the whole-cube bound by at most $2^d/(2^d-n)$; this is at most two when $n\le2^{d-1}$. Failure to assign the correct label probability strictly above $q<1$ costs a further factor $1/(1-q)$, hence three for the usual $2/3$ criterion ([Question 6](#6-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23)).

**How small must the noise be?** The coefficient of the corrupted fraction exceeds $10^6$ times a polynomial in $d$. So, as stated, the bound is informative only when the corrupted fraction is below about $10^{-6}$ divided by a polynomial in $d$. Since there are only $2^d$ distinct inputs, a single corruption already makes it vacuous unless $2^d$ exceeds that coefficient (about $d\ge44$ even for $U=1$).

**What remains open:** can we replace the resource-dependent noise term by $\rho(\eta)$, where $\rho(\eta)\to0$ as $\eta\to0$ independently of input dimension and target complexity, after paying a polynomial sample overhead? The proved bound can become vacuous at a fixed numerical noise rate as dimension grows. It does not establish such a dimension-independent guarantee or arbitrarily accurate clean recovery at a fixed positive noise rate.

**Why the proof works.** As in the noiseless case ([Question 2](#2-can-we-bound-the-prior-probability-of-a-function)), the proof is an Occam argument: it counts the functions whose energy is at most that of one network fitting the observed labels. Here that network is the clean implementation **plus a correction that fits the flips**. Polynomial equivalence between circuit complexity and neural prior complexity alone does not control the cost of this correction sharply enough: raising a cost proportional to $s\simeq\eta n$ to a power greater than one can destroy the sample bound. The proof matches two exponents. With $H=L-1$ hidden layers, the correction has energy at most $`K_0+K_1(s+1)^{1/H}`$. The logarithm of the number of globally margin-separated functions of energy at most $K$ grows at most like a resource factor times $(K+1)^H$. Their combination gives the required bound linear in $s$.

There is a precise limitation to improving this particular counting argument. Our common energy budget contains the target with **every possible set of $s$ cube labels flipped**, so its function class has at least $\binom{2^d}{s}$ members. Its log-cardinality is therefore at least $s\log(2^d/s)$, which carries a dimension factor when $s$ is polynomial in $d$. This is a limitation of using that entire class in one union bound, not evidence that the learner itself generalizes badly.

**Possible improvements.** One promising next step is to make the correction cheaper by allowing it to change some unseen labels. Approximate-membership constructions used in circuit learning trade a controlled amount of off-sample error for a shorter description. Obtaining a corresponding sharp neural-energy bound could help; alternatively, a more selective counting argument might avoid paying for all those almost-correct functions. Neither improvement has yet been proved for this posterior.

**Scope.** These conclusions are specific to the stated sampling and interpolation conventions. Repeated inputs with contradictory labels would make exact conditioning impossible. If we instead allow training errors, ordinary finite-class noisy-error minimization has standard clean-learning guarantees, but that is a different learner. Replacing exact fit by a positive noisy likelihood also needs care in the **strong-prior-first limit**: its likelihood ratios are at most $((1-\eta)/\eta)^n$, whereas a fixed gap $\Delta\kappa$ between the prior energies of two functions contributes $\exp[-\Delta\kappa/(2\sigma^2)]$. At fixed $n$, the prior gap wins as $\sigma\to0$. The noisy-interpolation theorem uses the exact-fit likelihood throughout. [Question 40](#40-do-the-polynomial-bounds-survive-the-likelihood-based-setup-used-in-singular-learning-theory) discusses smooth likelihoods.

<a id="do-the-polynomial-bounds-survive-the-likelihood-based-setup-used-in-singular-learning-theory"></a>

## 40. Do the polynomial bounds survive the likelihood-based setup used in singular learning theory?

**Yes, for a Gaussian likelihood scaled together with the prior: we get polynomial sample bounds in the strong-prior and all finite-exponent regimes $\gamma\ge1$. Simply substituting a fixed Gaussian or logistic likelihood does not preserve the main results.** The balance between likelihood strength and prior strength matters. This is a statement about the learner itself, independent of which generalization bound one uses to analyze it; [Question 41](#41-does-singular-learning-theory-already-give-comparable-generalization-bounds) compares the bounds. The [supporting proof note](works-in-progress/slt-likelihood/README.md) gives positive variants and counterexamples; these are conventional arguments with independent AI-agent checks, not Lean-verified main results.

**Our setup.** The main papers take a Gaussian prior on network weights $w$, condition it on the global output margin $`|z_w(x)|>1/2`$ at every Boolean input, and then condition exactly on the training labels ([Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here)). The prior variances scale with learner width $N$ through an exponent $\gamma$, with readout variance $N^{-\gamma-1}$ and mean field at $\gamma=1$; the strong-prior limit instead sends the variance to zero at fixed width ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)). For $\gamma\ge1$ and in the strong-prior limit, the sample bounds are polynomial at fixed depth in the resources of a *teacher*, a network implementing the target, at every learner width above the teacher's.

**The SLT setup.** Singular learning theory (SLT) studies a broad class of statistical models, rather than specifying one neural-network prior. Its usual Bayesian setup is

$$
Q_{\beta,S}(dw)\ \propto\ \pi(dw)\prod_{i=1}^n p_w(Y_i\mid X_i)^\beta.
$$

Here $\pi$ is the prior and $`p_w`$ the model's likelihood. The inverse temperature $\beta=1$ is ordinary Bayes; other temperatures give a power posterior. For example, Gaussian regression uses a likelihood proportional to $`\exp[-(y-z_w(x))^2/(2s^2)]`$, and binary logistic classification uses $`(1+e^{-yz_w(x)})^{-1}`$. These give positive weight to imperfect fits. Our main papers instead impose hard training constraints, assigning zero likelihood to violations. See [Watanabe's definition of the posterior and predictive distribution](https://jmlr.org/papers/volume11/watanabe10a/watanabe10a.pdf), equations (1)–(2). Nothing about that definition fixes how network width, weight variance, observation variance, and sample size should scale together.

**Why a fixed smooth likelihood can fail with our shrinking priors.** Under the raw Gaussian prior in our finite-exponent models, without margin conditioning, the bounded hidden activations and readout variance give

$$
\mathbb E[z_w(x)^2]\le N^{-\gamma}.
$$

For every $\gamma>0$, all scores at a fixed finite set of inputs therefore approach zero as width grows. At a fixed sample size and temperature, the Gaussian or logistic likelihood approaches a positive constant under this prior. Reweighting by it barely changes the prior: the posterior approaches the prior in total variation. Consequently latent-sign confidence approaches $1/2$, and logistic posterior-predictive confidence does too, **even for the constant target**. This rules out our width-independent confidence guarantee for the raw prior with that likelihood. The same argument applies at fixed width as the prior variance tends to zero. It does not prove failure of the sign of the posterior mean: a vanishingly small positive bias could still have the right sign.

**Keeping the global margin.** The original global-margin restriction also does not automatically rescue the strong-prior theorem. There is an explicit two-bit XOR counterexample: at depth two and every fixed width $N\ge3$, the least-energy globally margined functions are constants and signed coordinates. Each has error $1/2$ against XOR. A fixed positive Gaussian or logistic likelihood cannot overcome their strict prior-energy advantage as the prior variance tends to zero, for any fixed finite training sample. Mixtures still have Gibbs error $1/2$, the error of a random posterior draw ([Question 6](#6-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23)). XOR itself has an exact width-three, bounded-weight real-output implementation, so lack of representation is not the issue. This example takes the **strong-prior limit after choosing the sample size**; it does not say that more data cannot eventually overcome a fixed prior.

**A positive result with an ordinary Gaussian likelihood.** Let the prior density be proportional to $`\exp[-\kappa_N(w)/(2\sigma^2)]`$, where $`\kappa_N(w)`$ is the weighted squared parameter norm that defines the energy of [Question 2](#2-can-we-bound-the-prior-probability-of-a-function). Choose Gaussian observation variance $\sigma^2$ as well. For clean observations $`Y_i=f(X_i)`$, ordinary Bayes then gives

$$
Q_{\sigma,S}(dw)\ \propto
\exp\left[-\frac{\kappa_N(w)+\sum_{i=1}^n(z_w(X_i)-f(X_i))^2}{2\sigma^2}\right]dw.
$$

At every fixed depth, this learner has a sample bound polynomial in input dimension, teacher width $C$, teacher weight bound, inverse accuracy, inverse output tolerance, and log inverse failure probability, **independent of every learner width above teacher width**. With high probability over training data, the posterior assigns probability above $2/3$ to $`|z_w(x)-f(x)|\le\tau`$ outside a test set of probability at most $\varepsilon$. Inputs can have any distribution on a compact subset of the unit ball, or the coordinate cube. No global-margin conditioning is needed. There are two versions:

- **Strong-prior limit:** choose a sufficient sample size and a finite learner width, then take $\sigma\to0$. The required small variance may depend on both; this version alone supplies no uniform positive variance threshold over all widths.
- **Finite exponents:** for every fixed $\gamma\ge1$, use our finite-exponent weight prior and Gaussian observation variance $N^{-\gamma}$. A separate argument gives the polynomial bound at **every $`N\ge C`$**, with no limit required. The polynomial may depend on fixed depth and fixed $\gamma$; the mean-field endpoint $\gamma=1$ is included.

Both versions observe clean labels from the teacher. They do not assert the same bound for data corrupted by fixed positive observation noise.

**How the proofs work.** For the strong-prior version, a replicated teacher, cloned to the learner's width, has bounded energy independent of learner width. So the posterior concentrates on networks whose **energy plus total squared training error** is bounded by the teacher's energy. Our compression argument covers all such bounded-energy networks with a finite collection of size independent of learner width. A sampling bound then rules out appreciable test error. The finite-exponent proof instead combines the existing teacher-neighborhood mass estimates and covers of most prior outputs with a bound on posterior training loss; it does not assume that typical mean-field networks have bounded total energy. The [note](works-in-progress/slt-likelihood/README.md) spells out both arguments.

A Boolean sign teacher gives positive variants of both Gaussian results after adding one tanh layer to approximate its labels; a logistic analogue works when its inverse temperature grows together with prior strength. These are explicit changes of scale, not a claim about the unchanged fixed-likelihood model.

**What about the usual fixed-likelihood setup?** At fixed architecture and fixed prior, standard prior-mass arguments do give sample upper bounds. They pay for the negative log prior mass of a small neighborhood of the teacher. Our available neighborhood estimate grows like $N^\gamma$ in the finite-exponent models with fixed $\gamma\ge1$. This yields polynomial bounds when learner width is itself polynomially bounded by teacher resources, but not the arbitrary-width guarantee of the main papers. A different prior with a sufficiently strong, quantitative circuit-description mass bound could give better results. Calling a model “SLT” alone supplies neither that prior-mass bound nor an all-width learning theorem. [Question 42](#42-can-prior-scaling-force-direct-prior-mass-bounds-to-depend-on-width-or-target-complexity) discusses when such direct prior-mass costs must grow with width.

**Still open here:** a complete smooth-likelihood theorem with joint polynomial dependence on depth under our robustness restriction ([Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence)). The regularized-loss argument makes this a reasonable target, but we have not checked the required prior mass and cover estimates within that restricted support. The unrestricted polynomial-depth problem ([Question 26](#26-is-exponential-depth-dependence-necessary-without-any-robustness-restriction)) is also not settled. Without rescaling the likelihood, the counterexamples above already prevent a blanket transfer of the main guarantees.

**Prediction conventions must match.** Logistic posterior-predictive confidence is $`\mathbb E_Q[(1+e^{-yz_w(x)})^{-1}]`$, whereas our classification papers use $`Q(yz_w(x)>0)`$. A score margin of $1/2$ gives only about $0.622$ logistic label probability, even if the parameters are known exactly. A $2/3$ predictive guarantee therefore needs a suitable link scale or a larger score margin. The Gaussian result above controls proximity of the latent output to the clean teacher; a future noisy observation is a separate random quantity.

<a id="does-slt-already-give-comparable-generalization-bounds"></a>

## 41. Does singular learning theory already give comparable generalization bounds?

**The usual asymptotic formulas of singular learning theory (SLT) do not give our finite-sample learning guarantees, and finite-sample generalization has not been reduced to the learning coefficient and other local asymptotic quantities.** Prior scale and the amount of prior mass near good predictors can dominate learning at the sample sizes of interest, even when the leading coefficients are known exactly. Finite-sample Bayesian bounds can nevertheless exploit a small teacher inside a much larger learner. The question is how their full constants depend on teacher resources, learner width, and prior scaling.

Here a *teacher* is a small network implementing the target, and the learner may be much wider. In the good prior scalings, our guarantees are sample bounds polynomial in teacher resources at fixed depth, independent of arbitrarily larger learner width, under specified prior, likelihood, and limit conventions ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)). [Question 40](#40-do-the-polynomial-bounds-survive-the-likelihood-based-setup-used-in-singular-learning-theory) recalls SLT's Bayesian posterior and asks whether our bounds survive it; this question compares the bounds themselves. The table at the end summarizes which bounds are useful where.

**What the asymptotic formulas establish.** Under the appropriate realizability and regularity assumptions, ordinary Bayes at a fixed model and prior satisfies

$$
\mathbb E[B_n]-L_0=\frac{\lambda}{n}+o(1/n),
\qquad
\mathbb E[G_n]-L_0=\frac{\lambda+\nu}{n}+o(1/n).
$$

Here $B_n$ is posterior-predictive test log loss, $G_n$ averages test log loss over individual posterior draws, and the expectations include the training sample. The baseline $L_0$ is optimal log loss; $\lambda$ is the learning coefficient and $\nu$ the singular fluctuation at inverse temperature one. See [Watanabe's equations of states](https://arxiv.org/abs/0712.0653), Corollary 3. These are leading large-sample expansions. They give neither a numerical error bound at a specified sample size nor uniform control as architecture and prior scale vary.

**The proposed reduction.** [Daniel Murfet's comment](https://www.lesswrong.com/posts/ALJYj4PpkqyseL7kZ/my-criticism-of-singular-learning-theory?commentId=KYT7aPu5LhktFQ6LR) describes a reduction of generalization questions to understanding $L_0,\lambda,\nu$. Read as a claim about **finite-sample overparameterized generalization**, that reduction has not been supplied and those quantities are insufficient. Read as a claim about the **leading fixed-model asymptotic term**, it is correct and mathematically substantive. His full comment acknowledges asymptotic applicability and the separate gap between Bayesian posteriors and SGD. Those qualifications do not supply the missing finite-sample theorem. A [local-posterior expansion](https://arxiv.org/abs/2308.12108v1) also does not show that the global posterior selects the neighborhood being analyzed.

**Why prior scaling is more than a technical remainder issue.** Take observations from $\mathcal N(1,1)$, model $\mathcal N(\theta,1)$, and prior $\theta\sim\mathcal N(0,1/a)$. Every fixed prior precision $a>0$ has $\lambda=\nu=1/2$. Yet the exact expected Gibbs excess log loss is

$$
\mathbb E[G_n]-L_0=\frac{a^2+2n+a}{2(n+a)^2}.
$$

This is at least $1/8$ for every $n\le a$, although its asymptotic leading term is always $1/n$. Thus the same coefficients allow arbitrarily delayed learning. Calling the prior-dependent contribution “lower order” describes a limit with $a$ fixed; it says little when $a$ is large relative to the available data.

There is a stronger version: smooth positive priors can agree exactly near the truth, with identical local asymptotic constants, while their useful neighborhoods shrink and learning is arbitrarily delayed. The [review record](verification/slt-bounds-comparison-2026-10-19.md#identical-local-information-does-not-give-a-uniform-sample-threshold) gives a construction. Quantitative neighborhood radii and masses detect this problem; local asymptotic invariants alone do not.

**Finite-sample bounds require additional information.** For example, [Wang–Yang (2026)](https://arxiv.org/abs/2604.17219), Theorem 5, gives a high-probability PAC-Bayes bound involving the full population integral $\int e^{-c n R(w)}\pi(dw)$ under a moment condition. Replacing that integral by an SLT expression introduces an uncontrolled additive constant. Their neural-network specialization does not quantify that constant uniformly in width. This is useful additional finite-sample analysis, but it does not make the local coefficients sufficient.

**A teacher-sized leading term can hide a parameter-sized volume cost.** [Nagayasu–Watanabe (2023)](https://arxiv.org/pdf/2303.15739v3), Theorem 3.1, gives a free-energy upper bound for a realizable Gaussian-noise ReLU teacher on bounded input support, under their embedding and prior-support conditions. Its coefficient of $\log n$ is half the teacher parameter count; its additive constant is not controlled uniformly in learner architecture. In their concrete neighborhood construction, all incoming weights to redundant neurons in an internal layer have specified negative signs. Under independent centered Gaussian priors, for learner width $N$ and active teacher width $C$, that sign event alone costs at least

$$
-\log\pi(\text{neighborhood})\ge (N-C)N\log 2.
$$

That particular certificate therefore retains a quadratic width cost, regardless of the Gaussian variances. A teacher-sized asymptotic coefficient does not remove it. This is a limitation of that construction, **not** a lower bound on the learner or on every possible SLT-inspired proof. Moreover, a cumulative predictive-loss bound cannot simply be differenced to bound the final predictor.

**A finite-sample variational argument can improve on parameter counting.** The [supporting note](works-in-progress/slt-finite-sample/README.md) gives a direct calculation for tanh networks with the standard independent Gaussian fan-in prior: variance $1/(d+1)$ in the first layer and $1/N$ in subsequent layers, including the readout. This is the usual NNGP parameterization ([Question 9](#9-how-do-the-nnbayes-results-here-relate-to-nngp-and-kernel-regression)), not one of our $\gamma$ scalings. The likelihood is Gaussian with fixed variance.

A teacher has hidden width $C\le N$, depth $L$, and weights bounded by $B$. Use a product Gaussian comparison distribution whose mean is the zero-padded teacher. Only the weights **entering the teacher's neurons**, and the readout, need smaller variances. There are

$$
Q=C(d+1)+(L-2)CN+N
$$

such coordinates. The other hidden weights retain their prior distribution; bounded tanh activations control their influence. Both the teacher's mean-shift cost and this variance-shrinkage cost are linear in $N$ at fixed teacher resources.

**This comparison distribution is broad in parameter space.** When the learner is much wider than the teacher, most hidden weights retain their full prior fluctuations; the distribution is not concentrated in a small ball around the teacher. The proof uses independent, centered perturbations of incoming weights, whose variances add within each neuron's weighted sum. This bounds expected **squared** output error at each input; errors are not canceled across training inputs. An entropy inequality then lower-bounds the posterior's normalizing integral. The comparison Gaussian is an auxiliary distribution, not a claimed description of the posterior.

This is a quantitative finite-sample variational calculation, rather than a derivation from the usual SLT local asymptotic expansion. SLT can also integrate along redundant parameter directions, so the distinction is not that every SLT argument requires a tiny Euclidean ball. The result below specifically uses broad parameter fluctuations and explicit moment and entropy bounds; it does not establish that the standard local-coefficient calculation yields the same guarantee.

The resulting **nonasymptotic final-posterior** guarantee needs $O(N)$ samples for fixed accuracy and confidence. It applies to clean real-valued teacher outputs under the chosen Gaussian likelihood, and ensures greater than $2/3$ posterior probability of an accurate latent output on most test inputs. The explicit bound is polynomial in depth as well, while retaining its learner-width dependence. For genuinely Gaussian-noisy observations, the note also proves an expected averaged-predictive log-loss bound with the same width scaling.

For $L\ge3$, the full parameter count is

$$
P_N=N(d+1)+(L-2)N^2+N.
$$

Consequently there are regimes where this certificate is useful with far fewer samples than parameters. It does **not** establish practical numerical sharpness, or a theorem uniform over arbitrarily large width at fixed sample size. These are explicit variational calculations, not consequences of $\lambda,\nu$ alone; the note has independent AI-agent mathematical checks but is not Lean verified. [Question 42](#42-can-prior-scaling-force-direct-prior-mass-bounds-to-depend-on-width-or-target-complexity) discusses obstructions to removing this width dependence from direct prior-mass certificates.

**Which bounds are useful where?**

| Bound | What must be controlled | Relevant regime and limitation |
|---|---|---|
| Parameter-counting PAC bounds | Capacity of the whole learner class, with activation-dependent factors. | Often useful for a modest-size learner; typically uninformative when that capacity greatly exceeds sample size. |
| Standard SLT expansions | Local coefficients **and a justified asymptotic regime**. | Describe leading learning curves at fixed model and prior; do not alone certify finite-sample error. |
| Quantitative prior-mass or variational bounds | The full cost of a good neighborhood or comparison distribution. | Can work with many more parameters than samples; width and prior-scale costs must actually be calculated. |
| This collection's all-width NNBayes upper bounds | Teacher resources and the specified prior, likelihood, and limit conventions. | Polynomial teacher-complexity bounds at fixed depth, independent of arbitrarily larger learner width; generally unoptimized constants. |

Having fewer samples than parameters does not invalidate every classical bound. Norm, margin, compression, and PAC-Bayes bounds can use other complexity measures; for example, [spectral norm and margin bounds](https://arxiv.org/abs/1706.08498). Nor is a fixed finite Boolean domain a useful way to separate bounds indefinitely as width grows: its finite support supplies another capacity ceiling. The variational argument above also permits continuous inputs.

<a id="can-prior-scaling-obstruct-a-width-independent-log-prior-bound"></a>

## 42. Can prior scaling force direct prior-mass bounds to depend on width or target complexity?

**Yes, for direct bounds based on the raw prior probability of accurately reproducing a prescribed real-valued function.** Such a bound pays a cost like $`-\log\pi_N(G)`$, where $`\pi_N`$ is the prior on networks of width $N$ and $G$ is a set of accurate predictors. A variational proof instead pays the relative entropy of an accurate comparison distribution. These costs can rule out a bound that is both independent of learner width and polynomial in teacher resources. This limits a proof route; it is not a sample-complexity lower bound for the learner. The [supporting analysis](works-in-progress/slt-finite-sample/PRIOR-MASS-OBSTRUCTIONS.md) proves the following distinctions.

**Context.** The question comes from the comparison with singular learning theory in [Question 41](#41-does-singular-learning-theory-already-give-comparable-generalization-bounds), where a variational certificate for the standard fan-in Gaussian prior needs $O(N)$ samples at learner width $N$. Here “raw” means the Gaussian prior before the global-margin conditioning of [Question 1](#1-what-is-the-basic-model-and-what-does-a-circuit-prior-mean-here); teacher resources are the width, depth, and weight bound of a small network implementing the target; and our finite-exponent priors scale their variances with width through an exponent $\gamma$ ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)). [Question 2](#2-can-we-bound-the-prior-probability-of-a-function) notes that absolute negative log prior probabilities can grow with width or prior strength, consistently with its normalized comparison of prior probabilities between functions.

**Shrinking output scale forces a width cost.** If the prior output tends to zero, its probability of approximating a fixed nonzero value tends to zero. In our Gaussian finite-exponent priors, bounded hidden activations and readout variance $N^{-\gamma-1}$ give a particularly strong statement. For any input distribution, approximating the constant function $1$ within root-mean-square error $\rho<1$ has raw prior cost at least

$$
-\log\pi_N\big(\lVert z_w-1\rVert_{L^2}\le\rho\big)
\ge\frac{(1-\rho)^2}{2}N^\gamma.
$$

The same lower bound holds for the relative entropy of any comparison distribution whose expected squared prediction error is at most $\rho^2$. Thus allowing a broad comparison distribution does not remove this obstruction when $\gamma>0$.

**Growing output scale also costs probability when a bounded amplitude is required.** For a centered Gaussian output of standard deviation $`s_N\to\infty`$, hitting a fixed bounded interval has probability $`O(1/s_N)`$ and hence a cost at least $`\log s_N-O(1)`$. The interval probability also tends to zero for Gaussian readout mixtures when their conditional variance diverges in probability; a quantitative rate requires quantitative concentration. Diverging unconditional variance alone is insufficient: rare large outputs can inflate variance while most prior mass remains at a useful scale.

**An order-one Gaussian-process limit has a different obstruction: target complexity.** Suppose the raw function prior converges to a centered Gaussian process (GP) $F$ on the Boolean cube, with average output variance at most $V>0$, and that the limiting law is invariant under coordinate permutations. For every parity $`\chi_S`$ on $k$ coordinates and every $0<\rho<1$,

$$
-\log\Pr\big(\lVert F-\chi_S\rVert_{L^2}\le\rho\big)
\ge\frac{(1-\rho)^2}{2V}\binom dk,
$$

where $L^2$ uses the uniform input distribution. The proof is a Fourier variance budget: the total variance of all parity coefficients is $V$, and the $\binom dk$ coefficients of a given degree have equal variance. Approximating a parity requires its coefficient to be close to one. When $V$ is bounded or grows at most polynomially in $d$, taking $k$ near $d/2$ gives an exponential log-prior cost, although parity has a small circuit and can be approximated by a shallow tanh teacher with polynomially bounded resources. Without permutation symmetry, a related argument still finds at least one hard parity. These are bounds on raw good-function mass, not posterior sample-complexity lower bounds.

Output variance of order one **does not by itself imply a GP**. The Gaussian limit needs a separate argument about the architecture and coordinate laws. A structured mixture that first chooses a small circuit can have order-one output variance and a circuit prior. The supporting analysis proves a restricted classification for one hidden tanh layer with independent Gaussian weights and power-law variance scalings. For that family, direct raw-prior certificates incur either a width cost or a nonpolynomial teacher-complexity cost. It does not classify every deep architecture or scaling tuple.

**The distinction from the main learning theorems is essential.** Sign-only predictions are unchanged by positive output rescaling, and conditioning the prior on global margins changes the probabilities being compared. A common amplitude penalty can cancel between numerator and denominator. Our positive results use additional structure, including relative prior costs, posterior concentration, and compression ([Question 2](#2-can-we-bound-the-prior-probability-of-a-function)). A diverging raw log-prior penalty therefore does not contradict those theorems or prove that the actual learner needs more samples. For the Gaussian families covered by these obstructions, a successful width-independent, teacher-polynomial proof must use information beyond a direct raw-mass certificate.

<a id="23-which-original-open-problems-have-been-resolved-and-which-remain"></a>

## 43. Which original open problems have been resolved, and which remain?

**Five of the eight original directions are partly resolved; out-of-distribution learning, other architectures, and gradient descent remain open or heuristic.** The original directions are the open problems posed in [Dmitry and Kaarel's slides](https://kaarelh.github.io/ai/nnbayes-generalization.pdf), from which this collection started. Each row links to the question with the details.

| Original direction | Current status |
|---|---|
| Improve the polynomial | **Partly resolved.** [Question 30](#30-what-are-the-explicit-sample-complexity-polynomials-and-are-practical-sample-bounds-close) gives sextic width dependence under the original robust restriction at every gamma >= 1, a quartic stronger-scale bound, and quadratic bounds with additional assumptions. Quadratic dependence for the original robust prior and near-description-length guarantees remain open. |
| Remove bad depth dependence | **Partly resolved.** Joint polynomial depth under the robust support restriction ([Question 22](#22-what-robustness-condition-gives-polynomial-depth-dependence)); unrestricted positive results for substantial Boolean classes ([Questions 26](#26-is-exponential-depth-dependence-necessary-without-any-robustness-restriction) and [28](#28-without-a-robustness-restriction-what-depth-dependence-does-the-critical-gamma1-prior-have)). The general Boolean case remains open. Continuous-output regression has an exponential-depth lower bound without a robustness restriction. |
| Lower-bound log prior mass | **Partly resolved.** The strong-prior rate is polynomially equivalent to bounded-weight network complexity; finite-variance target-mass bounds also exist ([Question 2](#2-can-we-bound-the-prior-probability-of-a-function)). Sharp absolute-mass formulas remain open. |
| Classify scaling regimes | **Partly resolved on a particular one-parameter line** ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)). The three positive learning regimes also extend to the non-Gaussian family in [Question 34](#34-do-independent-non-gaussian-weight-priors-give-the-same-results). General exponent tuples ([Question 12](#12-can-we-classify-all-tuples-of-layerwise-scaling-exponents)), mixed regimes, and non-Gaussian subcritical behavior remain open. |
| Out-of-distribution learning | **Heuristic.** Mistakes by the simplest consistent hypothesis may often eliminate many surviving low-complexity competitors, even as the input distribution changes. The [conditional online argument of Question 38](#38-why-expect-occam-learning-to-transfer-out-of-distribution) makes this expectation precise; its genericity premise remains unproved. |
| Online mistake bounds | **Proved for uniform random Boolean inputs.** All three positive NNBayes regimes have polynomial expected and high-probability total mistake bounds, independent of learner width. Circuit-induction converses are proved for specified rules; the original fixed-width neural polynomial converse and arbitrary-order Gaussian guarantees remain open. See Questions [36](#36-can-we-bound-the-total-number-of-mistakes-during-online-learning) and [37](#37-does-making-few-mistakes-imply-that-the-target-has-a-small-circuit). |
| Other architectures | **Open here.** CNN weight sharing, recurrence, attention, normalization, and residual structure need their own prior and complexity accounting. |
| Gradient descent | **Open as a learning theorem.** The robustness experiments ([Question 24](#24-do-gradient-trained-networks-satisfy-the-robustness-condition)) concern a sufficient stability property, not equivalence between SGD and the exact Bayesian posterior. [Question 20](#20-is-there-a-small-circuit-that-gradient-descent-learns-but-the-gamma1-learners-provably-cannot) adds Adam runs on a target that the $\gamma<1$ learners provably need exponentially many samples for (numerical, $d\le35$). |

The [appendix audit](side-results/strong-prior-appendix-audit/paper.pdf) checks every appendix of the slides in turn. In particular, the original depth example is a capacity/proof obstruction rather than a sample lower bound; the scaling classification is not exhaustive; the kernel-to-classification inference needed repair; and some online-learning claims were false under their stated conventions. These qualifications are part of the current account, not claims silently inherited from the slides.

<a id="25-what-other-questions-matter-before-interpreting-this-as-an-explanation-of-practical-deep-learning"></a>

## 44. What other questions matter before interpreting this as an explanation of practical deep learning?

**Several, each of which a statement about these Bayesian learners can blur.** The results in this FAQ concern exact Bayesian posteriors over neural networks, under specified priors, limits, and prediction rules. The largest missing links to practice are:

- **Finite width in the negative regimes.** The exponential parity results for the subcritical scalings $\gamma<1$ ([Question 8](#8-what-is-known-for-the-one-parameter-family-of-prior-scalings)) take $N\to\infty$ at fixed dimension, depth, and sample. They do not provide a useful width threshold uniform in growing $d,k,n$. The positive all-width theorems have a stronger finite-width quantifier.
- **Orders of limits.** Fixing width and shrinking variance, taking width first at a specified scaling, and growing dimension and width together can give different answers. Theorems should specify which is being taken.
- **Computational cost.** Exact posterior conditioning and sampling may be intractable. Polynomial examples do not imply polynomial computation, and no theorem here identifies SGD's output law with that posterior.
- **Noisy or misspecified data.** The strong-prior exact-interpolation theorem has resource-dependent noise tolerance. The [label-noise question](#39-do-the-good-generalization-results-survive-a-small-amount-of-label-noise) explains its scope; dimension-independent fixed-noise tolerance and broader misspecification remain open.
- **Typical data and architectures.** Uniform parity is a useful separation, not a model of all natural data. [Which other targets are hard](#16-for-gamma1-is-the-bad-sample-complexity-specific-to-parity) for the subcritical learners is a separate question. Current empirical certificates do not establish a theorem for modern large-model training.
- **Prediction rules.** Gibbs draws, posterior majority, mean-score prediction, and confidence-threshold success are different losses ([Question 6](#6-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23)). A statement about one should not be relabeled as a statement about another.
- **Selection of examples.** Passive iid sample lower bounds need not hold for active learning, teaching sets, or adversarially selected informative inputs. They are also usually stated for each specified sample size, not on one common event for every prefix of an infinite stream.

<a id="26-how-much-of-this-is-formally-verified"></a>

## 45. How much of this is formally verified?

**Closed Lean proofs cover the five main learning statements; the other results in this FAQ are conventional proofs unless stated otherwise.** The repository includes closed Lean formalizations of all five main learning statements, including the polynomial-depth generalization theorem under a robustness restriction; their exact theorem declarations, hypotheses, dependencies, and build instructions are the appropriate source for the machine-checked scope. A successful Lean build verifies the formal statements actually written, so alignment with the intended analytic network model is a separate review obligation.

The [verification record](lean/VERIFICATION.md) gives the exact-type gates, independent source rebuild, and axiom checks. The formal proof under the robustness restriction uses a looser Pinsker-and-energy construction; its exact learning statement does not include every optional posterior variant or sharp manuscript constant. The supporting depth manuscripts and the noisy-interpolation note have undergone independent AI-agent mathematical audits but remain outside the main Lean verification. An audited manuscript or exact numerical certificate is not thereby a Lean proof. The FAQ's heuristic extensions and open-problem assessments are not formalized theorems.

Readers should start with the main theorem and conventions in the relevant paper, then use this FAQ to identify the limitations and possible extensions. The [collection index](README.md) distinguishes main results, side results, and work in progress.
