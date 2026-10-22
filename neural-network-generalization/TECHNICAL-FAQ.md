# Technical FAQ: Bayesian neural-network generalization

This FAQ explains what the current results say, which assumptions matter, where we expect extensions, and what the main open problems are.

**Status labels:** **Proved** means that the linked manuscript contains a proof under its stated assumptions. **Extension suggested by the proof** means that we have identified a plausible adaptation but are not citing a completed theorem. **Heuristic** is an informed expectation. **Open** means that the available results do not settle the question. **Numerical** means computer experiments at small sizes, which are evidence rather than proof. **Literature (abstract-level)** means a published result checked only against its abstract. Machine verification is a separate issue; see the final question.

**Jump to:** [prediction thresholds](#5-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23) · [scaling tuples](#9-can-we-classify-all-tuples-of-layerwise-scaling-exponents) · [targets beyond parity](#for-gamma1-is-the-bad-sample-complexity-specific-to-parity) · [robustness and depth](#12-what-robustness-condition-gives-polynomial-depth-dependence) · [out-of-distribution learning](#why-expect-occam-learning-to-transfer-out-of-distribution) · [label noise](#24-do-the-good-generalization-results-survive-a-small-amount-of-label-noise) · [SLT likelihoods](#do-the-polynomial-bounds-survive-the-likelihood-based-setup-used-in-singular-learning-theory) · [comparing generalization bounds](#does-slt-already-give-comparable-generalization-bounds) · [formal verification](#26-how-much-of-this-is-formally-verified)

## 1. What is the basic model, and what does “a circuit prior” mean here?

**Proved, with several different quantifier orders.** The original model is a fully connected network with bounded hidden activations, usually tanh, and a real-valued linear readout $z_w(x)$. Inputs and target labels are Boolean: $x\in\lbrace -1,1\rbrace ^d$, $f(x)\in\lbrace -1,1\rbrace $. There are $L-1$ hidden layers of width $N$, a constant input coordinate, and no separate internal biases.

The original Gaussian prior is conditioned, before observing labels, on

$$
|z_w(x)|>1/2\qquad\text{at every Boolean input }x.
$$

The posterior then conditions on the observed training signs. Under that prior restriction, this is equivalent to requiring $f(X_i)z_w(X_i)>1/2$ at each noiseless training input. In the main results, training inputs are iid; positive results allow an arbitrary common input distribution, whereas the parity lower bounds use the uniform distribution. The separate noisy-interpolation result in Question 24 uses distinct uniformly sampled inputs.

“Circuit prior” is a claim about the **prior on functions**: its preference for different functions approximately tracks the complexity of small circuits implementing them. In the slides' strong-prior setting, this is made precise through the Gaussian energy cost $\kappa_N(f)$, which determines the leading exponential order of prior probability ratios and is polynomially related to bounded-weight network complexity at fixed depth, uniformly over all learner widths $N\ge C_L(f)$.

The sample-complexity theorem is a **consequence** of that prior-complexity comparison, together with a bound on the number of low-complexity competitors. A polynomial sample bound alone is not the definition of a circuit prior. “Approximately” here allows polynomial distortion and dimension/depth dependence; it does not assert an exact ordering of every pair by circuit size or efficient posterior sampling. [Question 22](#22-can-we-bound-the-prior-probability-of-a-function) gives the precise strong-prior comparison.

There are two different comparator complexities:

- The original $C_L(f)$ is the least width of a neural network of depth $L$ realizing $f$ with the prescribed margin and with every physical weight bounded by that width.
- The polynomial-depth generalization theorem under a robustness restriction uses the width of a layered **Boolean** circuit at the required depth, counting constant wires and any compilation overhead.

These should not be interchanged without a representation theorem. See the [strong-prior paper](main-results/strong-prior-generalization/paper.pdf) and [robust polynomial-depth paper](main-results/robust-polynomial-depth/paper.pdf).

## 2. How important is it that the inputs are Boolean?

**Partly technical, partly substantive.** A finite domain permits global margin conditioning, a finite list of Boolean functions, and uniform compression over the input set. The cube has $2^d$ points, so a union bound over all inputs costs only $O(d)$ in a logarithm. Its Fourier structure is also central to the parity lower bounds; those are not distribution-free lower bounds.

**The positive learning results extend to continuous inputs for real-valued regression.** The [continuous-domain paper](side-results/continuous-domains/paper.pdf) treats arbitrary input distributions on a compact subset of the unit ball, including the full sphere. A teacher has depth $L$, width $C$, and weights bounded by $B$. At each fixed depth, the sample bound is polynomial in $d,C,B$ and accuracy parameters, independently of **every learner width $`N\ge C`$**. This holds for the strong-prior limit and for each finite exponent $\gamma\ge1$, including mean field, with Gaussian weights or the non-Gaussian family in Question 20. The proof uses an input net; the learner and data remain continuous.

The finite-scale regression theorem observes clean real-valued labels, accepts training error below a positive tolerance $\rho$, and requires test error at most a larger tolerance $\tau>\rho$. It controls the actual posterior's probability of meeting that test tolerance. A separate exact-interpolation result covers minimum-energy interpolants and Gaussian posteriors with the **strong-prior limit taken before the zero-tolerance limit**. Neither result assumes a teacher margin or a gap in the input distribution's support. Teacher weight magnitude is counted; a pure-width bound for arbitrarily large weights is not proved.

Depth is substantive in this extension: [Question 16](#16-is-exponential-depth-dependence-necessary-without-any-robustness-restriction) describes an exponential-depth regression lower bound at constant teacher width and bounded weights. The original Boolean-cube depth question remains open.

Binary classification needs a distinction. A continuous network with a nonzero absolute margin everywhere on a connected sphere has a constant sign. The original globally margin-conditioned learner therefore cannot simply be transplanted there. Training-only margin conditioning does give a learning theorem when the data support stays a positive teacher margin away from its decision boundary. The corresponding unrestricted binary-label theorem on the full sphere remains open. These continuous-domain results are side results with conventional proofs, not Lean verified.

There is also a useful distinction between finite precision and a change of prior. An 8-bit pixel can be expressed exactly as a linear combination of eight Boolean bits. Composing that fixed decoder with a network preserves its computations and internal-noise stability on the corresponding images. It does **not** identify the resulting tied first-layer weights with independent Gaussian weights on the bits, and checking real images does not check all bit strings.

## 3. Are the network outputs Boolean? What if we scale them up?

**In the main classification papers, the labels are Boolean and the network outputs are real.** Classification uses their signs, with output margins imposed in the prior or likelihood. The arguments do not require a network to output exactly $+1$ or $-1$. The [continuous-domain paper](side-results/continuous-domains/paper.pdf) also studies learning the teacher's real-valued outputs directly, as described in Question 2.

Multiplying the readout by $A>0$ preserves signs and can improve output margins, but multiplies its squared Gaussian energy by $A^2$. It is therefore not free in a Bayesian prior. In particular, an implementation that needs an enormous output scale to become stable need not give a polynomial prior-mass or sample bound in the original implementation's size.

For a finite input cube and nonzero clean outputs, sufficiently large readout amplification can eventually enforce the clipped-score stability condition used below. This does not show that the **raw trained network** satisfies the condition, or that the required amplification has polynomial cost. The robust Boolean-circuit construction instead supplies a controlled implementation and a controlled neighborhood of prior mass around it.

**Open:** an equally general theory for real-valued regression with noisy observations, or for multiclass outputs. The continuous-domain regression theorem uses clean observations; its nonzero training tolerance is not a theorem about corrupted labels. Binary label noise is discussed in [Question 24](#24-do-the-good-generalization-results-survive-a-small-amount-of-label-noise).

## 4. Can we drop the requirement of a margin on every input before training?

**Yes at fixed depth, while retaining a quantitative training margin.** The [continuous-domain paper](side-results/continuous-domains/paper.pdf) proves a classification theorem for the raw prior in the strong-prior and finite-scale $\gamma\ge1$ regimes, at every width above teacher width. It assumes a bounded-weight teacher has a uniform positive signed margin on the input distribution's support. This includes the original finite Boolean targets, and requires no internal-stability restriction on the prior. The posterior conditions only on

$$
f(X_i)z_w(X_i)>1/2,
$$

and its correct-sign probability exceeds $2/3$ on almost all test inputs after polynomially many samples at fixed depth. The teacher-margin assumption is substantive on continuous supports: it excludes data arbitrarily close to a sign-changing decision boundary.

**For a bound jointly polynomial in depth,** the theorem under the internal-stability restriction described in Question 12 also permits outputs arbitrarily close to zero at unobserved inputs. It uses the same training likelihood and bounds posterior test-margin error $f(X)z_w(X)\le1/4$, hence also sign error. Removing both restrictions while retaining a general polynomial-depth guarantee remains open.

The constants $1/2$ and $1/4$ are not fundamental. The robust argument has a version with training margin $m$, test threshold $u<m$, and quantitative dependence on the gap $m-u$. Taking $u=0$ addresses sign prediction directly. Merely conditioning on positive training signs with no quantitative training margin is a different problem.

The original subcritical lower bounds also use their stated global conditioning. One cannot remove it from those proofs by changing only the test loss. See the [robust paper](main-results/robust-polynomial-depth/paper.pdf) and [subcritical paper](main-results/subcritical-exponential/paper.pdf).

## 5. What changes if correctness means posterior probability above $1/2$, rather than $2/3$?

Let $p_S(x)$ be the posterior probability of the correct label, and let

$$
R_S=\mathbb E_x[1-p_S(x)]
$$

be the error of a posterior draw, usually called Gibbs error. There are two different conversions:

$$
D\lbrace p_S\le q\rbrace \le \frac{R_S}{1-q},
\qquad
D\lbrace p_S\le q\rbrace \ge \frac{R_S-(1-q)}{q}.
$$

The second is informative only when its numerator is positive.

**Proved for all the positive results:** a small Gibbs error gives a small failure fraction at every fixed $q<1$, including $q=1/2$, $2/3$, and intermediate values. Only constants change. A posterior-majority classifier, with any tie rule, has error at most $2R_S$.

**For the lower bounds, the distinction matters.** The published $0<\gamma<1$ and $\gamma=0$ proofs give $R_S\ge3/8$ in the relevant limit. At $q=2/3$, this yields a failure fraction at least $1/16$. The displayed constant also works for every $q>5/8$. It says nothing at $q=1/2$.

**Extension suggested by the proof:** the cutoffs in those two proofs can be made smaller to bring the Gibbs lower bound closer to $1/2$, at the cost of a smaller exponential sample constant. This strongly suggests the same qualitative result for each fixed $q>1/2$. The stated main theorem is still the $2/3$ version; this FAQ is not a substitute for writing out that extension.

For $\gamma<0$, the direct confidence argument is different: a log-concavity step naturally reaches thresholds above $1-e^{-1}\approx0.632$. It does not establish the entire interval $q>1/2$. For the **critical** $\gamma=1$ polynomial parity lower bound, Gibbs error tends to $1/2$, so every fixed $q>1/2$ is covered, but majority failure still does not follow.

**Open in these lower-bound arguments:** the exact $1/2$ threshold. It is possible for $p_S(x)=0.5001$ at every input: Gibbs error is almost $1/2$, yet the posterior majority is correct everywhere. A result about confidence bounded away from $1/2$ is therefore not automatically a result about majority prediction. The distinction between $<$, $\le$, and the rule for ties should also be specified when stating an exact theorem.

## 6. Why are mixtures of individually bad predictors not already a problem at $2/3$?

**Because the lower bound controls their average error by enough to cross that threshold.** If every minimum-energy sign function has error at least $3/8$, every mixture of them has Gibbs error at least $3/8$. The second inequality above then forces a $1/16$ fraction of inputs to have correct-label probability at most $2/3$, regardless of the mixture weights.

A majority of bad predictors can nevertheless be accurate. Their mistakes may occur on different inputs. Thus the proof never needed a unique minimizer for its $2/3$ conclusion, but a majority lower bound would require additional information about how the minimizers' errors align.

In each regime, the relevant quantities are the Gibbs-error bound, the requested confidence threshold, and any additional control over how the predictors vote at individual inputs.

## 7. How do the NNBayes results here relate to NNGP and kernel regression?

**For the main positive learning results, width and prior scaling are the first distinctions.**

- **No infinite-width limit is required.** The positive theorems apply at every actual learner width above the relevant target complexity, including widths close to that complexity. They also cover arbitrarily large finite widths. In the strong-prior theorem, width is fixed before the prior variance tends to zero.
- **The prior scalings differ from the usual nondegenerate NNGP scaling.** For example, at $\gamma=1$ the readout-weight variance scales as $N^{-2}$, whereas the standard NNGP parameterization uses $N^{-1}$. Taking a large width alone therefore does not justify replacing these learners by the usual NNGP. [Questions 8](#8-what-is-actually-known-for-the-one-parameter-family-of-scalings) and [9](#9-can-we-classify-all-tuples-of-layerwise-scaling-exponents) give the layerwise scalings.

**Conditioning and prediction rules are additional distinctions where a GP description does apply.** These matter for the Gaussian limits used in some lower bounds and for the separate NNGP note below. A Gaussian-process prior conditioned on training signs is not the same posterior as Gaussian regression conditioned on exact real output values. Conditioning additionally on an absolute margin at every input changes it again. Moreover,

$$
\mathrm{sign}\,\mathbb E[z(x)\mid S]
\quad\text{and}\quad
\mathrm{sign}\,\mathbb E[\mathrm{sign}\,z(x)\mid S]
$$

are different prediction rules: a few large-magnitude outputs can affect the former without affecting the latter in the same way.

A small parity eigenvalue, or poor correlation of the regression mean, is therefore not by itself a lower bound for the posterior-confidence convention used here. This was a substantive gap in the original slides' kernel discussion. The later lower bounds analyze the appropriate conditioned law. For targets other than parity the two notions come apart further: majority is costly for squared-error regression but cheap for the sign posteriors ([details](#for-gamma1-is-the-bad-sample-complexity-specific-to-parity)).

Nor does every Gaussian rate description identify an exact GP posterior: this distinction is important for $0<\gamma<1$, as explained in [Question 10](#10-does-a-quantitative-central-limit-theorem-make-all-0gamma1-into-gaussian-conditioning).

There is a separate [NNGP note](side-results/nngp-sample-complexity/paper.pdf) with an exponential confidence lower bound for a deep, variance-normalized tanh GP family. Its depth grows with the input dimension. It should not be silently substituted for the fixed-depth theorem for all $\gamma<1$.

At fixed depth and the usual NNGP scaling, a [later side result](side-results/standard-nngp-parity/paper.pdf) proves superpolynomial and nearly exponential confidence lower bounds for full parity; [Question 9](#9-can-we-classify-all-tuples-of-layerwise-scaling-exponents) states them. Whether $\exp(\Omega(d))$ samples are needed at that scaling is open.

## 8. What is actually known for the one-parameter family of scalings?

Here the entry **variances**, not standard deviations, are

$$
\mathrm{Var}\,W^1=N^{1-\gamma}/d,
\qquad \mathrm{Var}\,W^s=N^{-\gamma}\ (1<s<L),
\qquad \mathrm{Var}\,v=N^{-\gamma-1}.
$$

The table concerns this particular family and the indicated conditioning conventions.

| Regime | Current conclusion | Important qualification |
|---|---|---|
| Strong-prior limit at fixed $N$ | Prior rate polynomially equivalent to bounded-weight network complexity at fixed depth; consequently polynomial samples, uniformly in the sample bound over all $N\ge C_L(f)$. | Variance tends to zero **after fixing width**; no width-uniform variance threshold. |
| Fixed $\gamma>1$ | Polynomial samples at fixed depth for every actual $N\ge C_L(f)$. Unrestricted results also remove bad learner-depth dependence for substantial target classes. | The original bound depends on the gap above one; the [unified activation theorem](works-in-progress/unbounded-activations/) removes that dependence with one polynomial for all $\gamma\ge1$. Its degree still depends on depth. The full arbitrary-deep-target problem remains open. |
| $\gamma=1$ | Polynomial samples at each fixed depth, every actual $N\ge C_L(f)$. Without a robustness restriction, the critical theorem also gives polynomial learner-depth bounds at every realizable width for low-Fourier-variation targets, including all parities at sufficient logarithmic depth. With the robustness restriction, jointly polynomial dependence on depth for Boolean-circuit targets. | Joint polynomial dependence on arbitrary teacher width and depth for the unrestricted prior remains open. |
| $0<\gamma<1$ | A Gaussian minimum-energy description at leading exponential order; exponential full-parity confidence lower bound. | This is not exact Gaussian-posterior equivalence throughout the interval. Limits are width first. |
| $\gamma=0$ | A fixed-margin globally conditioned Gaussian limit; exponential full-parity confidence lower bound. | The global margin remains in the limiting law. |
| $\gamma<0$ | After output normalization, a Gaussian law conditioned on training signs; exponential full-parity and stronger sparse-parity lower bounds. | The original fixed margin vanishes under this normalization. |

The $\gamma\le0$ exponential result is included in the [main subcritical paper](main-results/subcritical-exponential/paper.pdf); it is not an omitted fifth scaling result. The [collection index](README.md) separates the main papers and supporting results.

## 9. Can we classify **all** tuples of layerwise scaling exponents?

**We don't have learning results for all exponent tuples.** Write a general variance tuple as

$$
\mathrm{Var}\,W^1=c_1N^{-a_1}/d,
\quad \mathrm{Var}\,W^s=c_sN^{-a_s},
\quad \mathrm{Var}\,v=c_LN^{-a_L}.
$$

Our one-parameter family occupies only the line

$$
(a_1,a_2,\ldots,a_{L-1},a_L)
=(\gamma-1,\gamma,\ldots,\gamma,\gamma+1).
$$

In contrast, the usual nondegenerate tanh NNGP scaling is $(0,1,\ldots,1,1)$. All discussion below fixes depth and dimension before taking width to infinity, and retains our global output-margin and exact-label conditioning conventions.

**What is the layer-collapse argument?** The slides try to reduce the many layer scales to a small number of effective learners by asking where it is cheapest to perform the computation. They first assume that the *conditioned* network has order-one hidden preactivations: no hidden layer becomes nearly linear through vanishing amplitudes, or fully saturated through diverging amplitudes. They also take the first layer to be a fixed random embedding. Under those assumptions, the proposed argument is:

1. **Assign each layer a price.** With order-one incoming activations, making a positive fraction of a hidden layer's neurons perform a specified task has a Gaussian energy price of order $p_s=1/\sigma_s^2=N^{a_s}$, when this is a rare event. A single readout has price $p_L=1/(N\sigma_L^2)=N^{a_L-1}$. Prices here mean negative log-probability scales; they omit representation entropy and the task's geometry.
2. **An expensive layer followed by a cheaper one can shrink and amplify.** Suppose a useful feature comes from the term of degree $k$ in tanh's Taylor expansion. Shrinking the incoming weights by $t$ makes that feature smaller by $t^k$. Amplifying it downstream by $t^{-k}$ restores its size. The schematic cost is $p_s t^2+p_{s+1}t^{-2k}$, minimized at $t_{\mathrm{opt}}=(k p_{s+1}/p_s)^{1/(2k+2)}$.

   If the earlier layer is increasingly more expensive, the optimum has $t\to0$. This is the proposed **collapse**: a layer operates near zero, and a later layer amplifies its small signal. Recovering a particular nonlinear term also requires cancelling lower Taylor terms; simple amplification alone does not do that. The slides exclude this outcome using their order-one-activation assumption. They do not classify the collapsed learner.
3. **A cheaper prefix followed by an expensive suffix might finish early.** The proposed “truncation” is to compute the answer in the cheap prefix and have the expensive tail transmit it. The resulting prior would resemble a shallower learner. This step needs an efficient way to move the computation into the prefix; universal approximation alone does not provide one.
4. **Balance the remaining live layers.** If the internal variances are comparable, equating their price to the readout price gives $a_L=a_s+1$. At the fan-in scale $a_s=1$, changing an empirical feature distribution costs order $N$, whereas forcing a margin through the readout costs order $N^{a_L-1}$. Their competition occurs at $a_L=2$, the critical case. This motivates the slides' kernel/feature-learning picture.

**Why isn't that a proof?** For several inputs at once, prescribing preactivations $u$ from an incoming feature matrix $A$ costs $u^\top(AA^\top)^+u/(2\sigma^2)$, when feasible. The full Gram matrix controls which computations are possible and affordable. Scalar prices miss its rank and conditioning, representation entropy, and changes in earlier features induced by later labels. Collapsing, saturating, and unequal-depth representations are also legitimate possibilities for the actual prior. [Appendix I of the audit](side-results/strong-prior-appendix-audit/paper.pdf) explains these gaps. The heuristic is useful, but its standing assumption excludes part of the space we want to understand.

For bookkeeping outside that assumption, let typical *unconditioned* hidden activation variance scale as $N^{-h_s}$. For fixed-depth tanh networks the amplitude heuristic is

$$
h_1\approx\max\lbrace a_1,0\rbrace ,\qquad
h_s\approx\max\lbrace a_s+h_{s-1}-1,0\rbrace ,
$$

and output variance has scale $N^{1-a_L-h_{L-1}}$. A negative value before taking a maximum indicates diverging preactivations and saturation. This recursion helps locate possible linear or saturated layers; it does not determine what rare conditioning selects.

**Do we still expect just circuit learning versus exponential sample complexity?** Those remain useful broad possibilities, but I would not currently conjecture an exhaustive two-way classification of *all* tuples. In particular, a different prior mechanism need not imply a different sample-complexity outcome. Here are concrete predictions, with their status:

| Exponent tuples | Prediction and current status |
|---|---|
| $a_1\le0$, every internal $a_s\le1$, and $a_L<2$ | **Conjectured frozen-feature region.** Hidden activations remain order one, possibly saturated. With a nondegenerate limiting kernel and empirical-kernel deviations costing order $N$, forcing margins costs only $N^{a_L-1}=o(N)$ when $1<a_L<2$. Thus conditioning should leave the leading kernel fixed. Exponential parity sample bounds are plausible but still require a spectrum and posterior-confidence argument for these kernels. The usual NNGP tuple $(0,1,\ldots,1,1)$ lies in this region and now has proved superpolynomial and nearly exponential lower bounds; see the paragraph on it below the table. |
| Exact fan-in hidden scaling $(0,1,\ldots,1,a_L)$ with $a_L\ge2$ | **Conjectured circuit-learning side.** The endpoint $a_L=2$ is proved in our critical results. For $a_L>2$, changing features can be cheaper than forcing the output through fixed features; I expect positive learning results, but output-dominated saturation and subleading costs need analysis. This does not assert the same circuit-prior ordering at every exponent. |
| One hidden layer: $(a_1,a_L)=(a,b)$ with $a>0$ and $a\le b\le a+2$ | **Tentative larger circuit-learning region.** Using $M=N^{(b-a)/2}$ active neurons balances feature cost $MN^a$ against readout cost $N^b/M$. At $b=a+2$ (so $M=N$) this is the one-hidden-layer case of the established $\gamma=a+1>1$ family (main result 2). In the interior, the active block is itself a $\gamma'=(a+b)/(b-a)>1$ network at its own width $M$, which suggests that a smaller active population can suffice. A construction alone does not control the remaining neurons or the posterior. |
| One hidden layer: $a>b>1$ | **Proved degree-based prior ordering; learning rate open.** The collapsing layer produces the threshold-degree hierarchy below. It is not a circuit-size prior, but it could still have exponential parity sample complexity. |

In the frozen-feature prediction, $a_L<1$ gives a normalized GP with vanishing absolute margin, $a_L=1$ retains a fixed global margin, and $1<a_L<2$ gives a Gaussian minimum-energy description at leading order. The last statement does not determine posterior weights among tied minimizers. These distinctions already occur within the proposed hard-learning side.

**The usual NNGP tuple is another scaling with a result.** At $(0,1,\ldots,1,1)$, hidden preactivations stay of order one. The width limit is therefore the NNGP kernel of the activation itself, not the arcsine kernel of the $\gamma<1$ line. Since $a_L=1$, the global margin survives in the limit, as at $\gamma=0$. The [standard-scaling paper](side-results/standard-nngp-parity/paper.pdf) proves the following lower bounds for full parity on $d$ bits, at fixed depth and any layer gains, with width taken to infinity first.

- **Global margin, $\tanh$ (proved).** For large $d$, with probability at least $1-e^{-d/10}$ over the sample, $n\le\exp(\frac1{20}\sqrt d\log d)$ uniform IID examples leave at least $1/16$ of the inputs without correct-label probability above $2/3$.
- **Training signs only, every training set (proved).** This is the limit of the margin learner when $a_L<1$, and the learner without the global margin at $a_L=1$. For every bounded continuous nonconstant activation, every depth and every gain, every training set of size $n\le d^{\sqrt d/10-1/2}/6000$ fails on at least a quarter of the inputs. That includes deliberately chosen training sets.
- **Training signs only, typical samples, $\tanh$ (proved).** $n\le\exp(10^{-3}d\log\log d/\log d)$ uniform IID examples leave at least $3/8$ of the inputs failing, with probability at least $13/16$. It is proved only for $d\ge d_0$, where $d_0$ is explicit but astronomically large. Its coercivity input is a theorem of the Lean project; the rest of the proof is conventional.

**Open:** whether $\exp(\Omega(d))$ samples are needed, as on the $\gamma<1$ line.
- For the sign-only learner, the proof suggests this would follow from two log-free sampling estimates at linear degree.
- For the margin learner, the paper proves that the per-sample conditioning-cost bound used by the subcritical proof fails at this tuple.

So far this tuple sits on the hard-learning side, as the frozen-feature prediction above expects. The proved exponents are not yet the exponential one.

**A collapse calculation can actually be made rigorous.** For one hidden tanh layer with $a>b>1$, let $r(f)$ be the smallest degree of a real polynomial whose sign equals $f$, and let $k$ be the smallest positive odd integer at least $r(f)$. Then the raw probability of implementing $f$ with the global margin satisfies

$$
\Pr(A_{N,f})=\exp\!\left[-\Theta_f\!\left(N^{(ka+b)/(k+1)}\right)\right].
$$

The [proof note](works-in-progress/scaling-tuples/README.md) supplies matching Taylor-expansion lower bounds and finite-neuron constructions, and converts their energy costs into Gaussian probability bounds. Consequently, after conditioning on any fixed training set, the width-first posterior first minimizes **odd-rounded polynomial threshold degree** among consistent functions. Constants and widths in this result are not uniform in growing dimension; the proof has independent AI-agent checks but is not Lean verified.

This can sharply disagree with circuit size: for even dimension, full parity is less probable asymptotically than every other Boolean function except its negation, including functions of exponentially greater circuit complexity. However, excluding the exact target from the limiting posterior does not imply poor test predictions: the remaining functions might be almost correct. So this result establishes a distinct prior-ordering mechanism, **not a third sample-complexity phase or an exponential sample lower bound**. Establishing the learning behavior of this explicit collapsed region is a useful next test of the proposed broad dichotomy.

## 10. Does a quantitative central limit theorem make all $0<\gamma<1$ into Gaussian conditioning?

**At leading exponential order, yes; for posterior probabilities, no.** Moderate deviations justify a Gaussian rate function in this interval. But conditioning on rare events can magnify smaller corrections that a leading-rate approximation discards.

The [Gaussian-conditioning paper](side-results/subcritical-gaussian-conditioning/paper.pdf) proves a relative approximation in the range $0<\gamma<1/2$, under its stated finite-domain assumptions, and gives an actual tanh-network counterexample at and above $\gamma=1/2$. Covariance fluctuations generate a correction on the scale $N^{2\gamma-1}$. This is smaller than the leading $N^\gamma$ rate, but can change the relative weights of tied minimum-energy functions and even change whether posterior confidence exceeds $2/3$.

Thus the moderate-deviation intuition was useful and partly correct. The stronger claim “the whole posterior is just a Gaussian conditioned on the observations throughout $\gamma<1$” is false. The exponential parity lower bound survives because it controls all the relevant minimizers, rather than choosing Gaussian mixture weights among ties.

## 11. For $\gamma<1$, how close are we to a $d^{\Omega(k)}$ lower bound on the sample complexity of sparse XOR?

Let $k$ be the parity size and $d$ the ambient dimension. The natural scale is

$$
\exp\!\left(\Omega\!\left(k\log\frac{ed}{k}\right)\right).
$$

For $k\le d^{1-\eta}$ with fixed $\eta>0$, this is $d^{\Omega(k)}$. For $k=d$, it becomes exponential in $d$, as it must: observing most of the finite input space is enough.

**Proved for $\gamma<0$:** the natural sparse scale, at the $2/3$ confidence criterion, with width taken first. The theorem's universal failure fraction is positive but small; it is not a claim of, say, 10% error.

**Proved for $0<\gamma<1$:** for growing sparse parity, a lower bound of the form

$$
n\le\exp\!\left(c\max\left\lbrace k,\sqrt{k}\log\frac{e(d+1)}{\sqrt{k}}\right\rbrace \right).
$$

This includes the desired $\exp(\Omega(k))$ obstruction, but does not give the full natural sparse scale. For $k\le d^{1-\eta}$, a [refinement](side-results/intermediate-parity/paper.pdf) proves failure at specified sample sizes $n$ with $\log n$ of order $\max\lbrace k^{\theta}\log(ed/k),\,k[\log(ed/k)]^{2-1/\theta}\rbrace$, where $\theta=\theta_L\in(1/2,1)$ and $\theta_2\approx0.719$; it does not assert failure at every smaller $n$. When depth grows as $\log_2\log\log d+O(1)$ and $d^{\eta_1}\le k\le d^{1-\eta_2}$, the [growing-depth paper](side-results/growing-depth-parity/paper.pdf) reaches the natural scale at specified sample sizes. Neither settles the fixed-depth natural scale.

**Open:** that full growing-sparse scale for $0<\gamma<1$, and the corresponding growing-sparse endpoint problem at $\gamma=0$.

There is a genuine regime distinction: a one-coordinate parity learns with $O(\log d)$ examples for $0<\gamma<1$. A uniform $d^{ck}$ claim covering all $k\ge1$ in that regime is therefore false. This does not disprove the proposed bound restricted to sufficiently growing $k$.

See [sparse parity](side-results/sparse-parity/paper.pdf) and [growing positive-subcritical parity](side-results/growing-sparse-positive/paper.pdf). These are iid-sample results, not lower bounds for an active learner allowed to choose informative inputs. Typical sampling is essential for $0<\gamma<1$: [deliberately selected](side-results/selected-examples-parity/paper.pdf) training sets of size $d^{O_\delta(\sqrt k)}$ teach sufficiently large odd $k$ when $d\ge(C_Lk)^{C_Lk}$. For $\gamma<0$, a [later work-in-progress note](works-in-progress/beyond-parity/README.md), with independent AI-agent checks only, gives a lower bound for every training set, selected or not. For any fixed $c\le1/2$ and large $k$, fewer than $(d/\sqrt k)^{c\sqrt k}$ examples leave the confidence-failure fraction above a constant depending on $c$. This uses its Proposition 3 with $r\asymp\sqrt k$ and the Aspnes–Beigel–Furst–Rudich bound. The exponent has the same order as the selected-set upper bound above. Whether selected sets of that size suffice at $\gamma<0$ is open.

For targets other than parity, see the [next question](#for-gamma1-is-the-bad-sample-complexity-specific-to-parity).

## For $\gamma<1$, is the bad sample complexity specific to parity?

**Largely no, and certainly not technically.** Many other targets also need a high power of $d$ samples. More strikingly, some targets with small circuits that gradient descent appears to learn quickly still need exponentially many samples in this regime. The clearest example is the target $`f^*`$ below, computed by a Boolean circuit of $O(d)$ gates. The $\gamma<1$ learners provably need $\exp(\Omega(d))$ samples for it. A layerwise learner provably learns it from polynomially many, and Adam on a two-head network learned it at every dimension tested (numerical). Some restricted class of targets may still be learned well in this regime, but we do not have a good characterization.

The exponential lower bounds for $\gamma<1$ summarized in Question 8 come from the [subcritical paper](main-results/subcritical-exponential/paper.pdf). They are stated for parity. Applied to another target, the same proof gives a bound governed by how far the target is from polynomial threshold functions of low degree. Concretely:

- **Many targets other than parity need a high power of $d$ samples.**
  - For a target that depends on a constant number of coordinates, the exponent is roughly its threshold degree, defined below.
  - For example, $`h=\mathrm{MAJ}(x_1x_2,x_3x_4,x_5x_6)`$ needs at least about $d^2$ samples in every $\gamma<1$ regime, and about $d^3$ at $\gamma<0$. This holds even under the confidence criterion of Question 5.
  - A function $g$ that mixes a three-bit parity with a three-bit majority needs at least about $d^3$ samples at $\gamma<0$, although SGD is expected to learn it from about $d$.
- **Some targets with full Fourier degree are cheap.** Majority of all $d$ bits is learned from polynomially many samples.
- **A large parity on a subcube is enough for an exponential bound.** Parity is close to threshold functions of degree about $\sqrt d$, so the distance argument gives it only $\exp(\Theta(\sqrt d\log d))$. The exponential parity bound uses two further margin-sensitive lemmas. These localize. Suppose the target equals a parity of linearly many bits wherever a constant number of other coordinates take fixed values. Then it needs $\exp(\Omega(d))$ samples, whatever it does elsewhere.
- **Such a target can still be easy for a layerwise learner.** The target $`f^*`$ defined below is a sign-staircase on half of the cube and full parity on the other half. The $\gamma<1$ learners need exponentially many samples for it (proved). A layerwise greedy learner provably learns it from polynomially many. Adam on a two-head network learned it at every dimension tested, up to $d=35$, but this range cannot separate polynomial from exponential growth, and a plain fully connected network did not learn it at $d=23$, 27, or 31 (numerical).
- **Which targets are learned well is open.** Every fixed junta is learned from polynomially many samples, with an exponent set by its threshold degree, and so is majority of all $d$ bits (proved). Beyond such examples, we know no natural class of targets of growing complexity that these learners learn well, and no characterization.

The [supporting note](works-in-progress/beyond-parity/README.md) gives the statements, proofs, and checks behind this answer, and a [second note](works-in-progress/beyond-parity/subcube-parity.md), the subcube note, covers parity on a subcube and the target $`f^*`$. Their new arguments combine lemmas of the subcritical paper, standard learning-theory bounds, and elementary Boolean-function facts. They have independent AI-agent checks, but they are not Lean verified and have not been reviewed by a human.

**Setting.** As the width tends to infinity at fixed $\gamma<1$, the hidden preactivations diverge and tanh acts as a sign function. Each layer then maps the correlation between two inputs through the arcsine function $\Psi$ below. The three $\gamma<1$ learners of Question 8 are thus described by one kernel on the cube:

$$
K(x,y)=\Psi^{\circ(L-1)}\left(\frac{1+x\cdot y}{d+1}\right),\qquad \Psi(t)=\frac2\pi\arcsin t .
$$

The $1$ is the constant input coordinate.

- **$`\gamma<0`$.** After the output normalization of Question 8, the posterior is the law of a centered Gaussian process $G$ on the cube with covariance $K$, conditioned on the training signs.
- **$`\gamma=0`$.** $G$ is also conditioned on a fixed absolute margin, $\lvert G(x)\rvert>a$ at every input, where $a>0$ comes from the global output-margin condition of Question 1.
- **$`0<\gamma<1`$.** The posterior concentrates on the signs of the functions $v$ that minimize the energy $v^{\mathsf T}K^{-1}v$, the squared $`K`$-norm, subject to two constraints: $\lvert v(x)\rvert\ge a$ at every input, and the correct signs at the training inputs. Tied minimizers may receive any weights (Question 10).

As in Question 5, the **Gibbs error** is the expected error of one posterior draw. The **confidence failure** is the fraction of test inputs at which the posterior gives the correct label probability at most $2/3$.

For a target $f$ on $\lbrace -1,1\rbrace ^d$:

- Its **threshold degree** $\mathrm{thr}(f)$ is the least degree of a real polynomial whose sign equals $f$ at every input; Question 9 writes $r(f)$. Every nonconstant halfspace, including majority and AND, has threshold degree one. Parity of $k$ bits has threshold degree $k$.
- $`\mathrm{err}_r(f)`$ is the least fraction of uniformly distributed inputs on which a polynomial threshold function of degree at most $r$ disagrees with $f$. It is positive exactly when $r<\mathrm{thr}(f)$.

Other notation:

- A **junta** is a target that depends on a constant number of coordinates, independent of $d$.
- For an integer $k$, $`k^*`$ denotes $k$ rounded up to an odd integer.
- $n$ is the number of training examples.
- $\beta=2^{-(L-1)}$ governs the decay of the kernel's spectrum, and costs a factor $d^{\beta}$ or $d^{2\beta}$ in some bounds below.
- The constants $`c_f,C_f>0`$ depend on $f$, the depth, and at $0\le\gamma<1$ the margin $a$, but not on $d$. The statements hold for large $d$.

**Lower bounds for every target.** For smaller training sets, the subcritical paper proves its parity lower bounds in three steps:

1. For typical uniform iid training inputs, every labeling has an interpolant of small $`K`$-norm that satisfies the margin condition at every input. At $\gamma<0$, where there is no such margin, the analogue holds for every training set: the posterior mean has squared $`K`$-norm at most $n$.
2. The eigenvalues of $K$ decay with Fourier degree, so posterior-typical functions are close to polynomial threshold functions of low degree.
3. Parity is far from all such functions.

For large training sets, the paper instead replaces steps 2 and 3 by the margin-sensitive parity lemmas described below. The supporting note uses a simpler step 2 that does not depend on the target at any sample size: it bounds the high-degree part of the posterior by Markov's inequality. Replacing step 3 by $`\mathrm{err}_r(f)`$ then gives a lower bound for every target. The bound holds while $n$ stays well below about $\binom{d+1}{r+2}$, up to small polynomial factors. At $\gamma=0$ the fixed-degree version also uses the paper's posterior-amplitude lemma.

For a junta $f$ with $t=\mathrm{thr}(f)\ge2$:

- **$`\gamma<0`$ (proved).** Confidence failure is at least $`\mathrm{err}_{t^*-2}(f)/2>0`$ on every training set with $`n\le c_fd^{t^*}`$. Up to a logarithmic term, $`C_fd^{t^*+1}/\varepsilon`$ iid samples bring it below $\varepsilon$.
- **$`\gamma=0`$ (proved).** For typical uniform iid samples with $`n\le c_fd^{t^*-2\beta}`$, the Gibbs error is at least $`\mathrm{err}_{t^*-2}(f)/2`$. As at $\gamma<0$, about $`C_fd^{t^*+1}/\varepsilon`$ iid samples bring the confidence failure below $\varepsilon$.
- **$`0<\gamma<1`$ (proved).** For typical uniform iid samples with $`n\le c_fd^{t^*-\beta}`$, every minimum-energy sign function has error at least $`\mathrm{err}_{t^*-2}(f)/2`$. Order $`C_fd^{t^*}/\varepsilon^2`$ samples bring every minimizer's error below $\varepsilon$.

The sample-size exponents of these lower and upper bounds differ by at most two. The proofs also give more than these halved bounds. For $`n=o(d^{t^*})`$ at $\gamma<0$, $`n=o(d^{t^*-2\beta})`$ at $\gamma=0$, and $`n=o(d^{t^*-\beta})`$ at $0<\gamma<1$, the lower bound is $`\mathrm{err}_{t^*-2}(f)-o(1)`$.

At $0\le\gamma<1$ these lower bounds concern Gibbs error. By Question 5's second inequality at $q=2/3$, a Gibbs-error lower bound $R$ gives a confidence-failure lower bound $(3R-1)/2$, which is positive only when $R>1/3$. Since $`\mathrm{err}_r(f)\le1/2`$, the halved bounds never give a confidence statement, but the sharper ones can. Two examples:

- **A majority of XORs.** $`h=\mathrm{MAJ}(x_1x_2,x_3x_4,x_5x_6)`$ has threshold degree two and $`\mathrm{err}_1=11/32>1/3`$.
  - At $\gamma<0$, its confidence failure stays at least $11/32-o(1)$ on every training set with $n=o(d^3)$.
  - At $0\le\gamma<1$, its confidence failure is at least $(3\cdot11/32-1)/2-o(1)=1/64-o(1)$, for $n=o(d^{3-2\beta})$ at $\gamma=0$ and $n=o(d^{3-\beta})$ at $0<\gamma<1$.
- **A parity–majority mixture.** Let $g$ be the function equal to $`x_1x_2x_3`$ when $`x_4=1`$ and to $`\mathrm{MAJ}(x_1,x_2,x_3)`$ when $`x_4=-1`$. It has threshold degree three and $`\mathrm{err}_1=3/16`$, so at $\gamma<0$ it needs at least about $d^3$ samples.

The $`k`$-bit parity $`\chi_k(x)=x_1\cdots x_k`$ with fixed $k\ge2$ is also covered, at the natural scale $d^{\Omega(k)}$ of Question 11. For example, two-bit XOR has $`\mathrm{err}_1=1/4`$, so at $\gamma<0$ its confidence failure stays at least $1/4-o(1)$ on every training set with $n=o(d^3)$. At $0\le\gamma<1$ these sparse-parity bounds hold only for Gibbs error. Question 11's open problems concern $k$ growing with $d$, where the constants and $`\mathrm{err}_{k^*-2}(\chi_k)`$ degrade.

**Cheap targets: threshold degree one (proved; standard PAC-Bayes and margin arguments).**

- **Halfspace juntas.** Every halfspace junta, including majority and AND of a constant number of bits, is learned from at most about $d^2/\varepsilon$ samples at $\gamma\le0$ and $d/\varepsilon^2$ at $0<\gamma<1$.
- **Majority of all $d$ bits ($d$ odd).** It depends on every coordinate and has Fourier degree $d$. It costs at most about $d^3/\varepsilon$ samples at $\gamma\le0$ and $d^2/\varepsilon^2$ at $0<\gamma<1$.

Full Fourier degree is therefore no obstacle for these learners. A sign prediction needs only a polynomial with the right sign, and the sign of majority's degree-one part is majority itself.

**Exponential failure uses more of parity's structure.** The same arguments give exponential lower bounds for every target that stays a constant distance from threshold functions of degree linear in $d$. At $\gamma<0$ they hold on every training set. At $0\le\gamma<1$ they hold in Gibbs error for typical samples, and only for $n\le e^{d/25}$. Most Boolean functions are of this kind, but that says little, since a random function needs exponentially many samples for any learner.

Parity, by contrast, is close to threshold functions of degree about $\sqrt d$, so this route gives it only $\exp(\Theta(\sqrt d\log d))$. The subcritical paper's exponential parity theorem reaches $\exp(\Omega(d))$ through two further margin-sensitive lemmas. Both use the fact that parity changes sign along every edge of the cube.

**Parity on a subcube (proved).** These lemmas localize to any subcube on which the target is a parity. Write inputs as $(x,z)$ with $x\in\lbrace -1,1\rbrace ^d$ and $z\in\lbrace -1,1\rbrace ^k$, and let the learners of Setting act on all $d+k$ input bits, with $d+k$ in place of $d$ in the kernel. Fixing $`z=z_0`$ gives a subcube of codimension $k$; here $k$ is the codimension, not a parity size. Suppose that on one such subcube the target equals $\pm$ a parity of at least $`c_Rd`$ of the $`x`$-coordinates, with arbitrary values elsewhere. Fix $k$, $`c_R`$, the depth, and the margin. Then there is $c>0$ such that, for large $d$, every $n\le e^{cd}$, and every fixed $\gamma<1$, the following holds with probability at least $3/4$ over uniform iid samples:

- in the width limit, at least $1/16$ of the subcube fails the confidence criterion, so at least $2^{-k}/16$ of all inputs fail;
- at $\gamma<0$, at least $3/8$ of the subcube fails even with the threshold lowered to $13/20$.

Labels off the subcube enter the subcritical paper's proof only through bounds that hold for every labeling, so they cannot help on the subcube. The proof's constant $c$ is at worst of order $8^{-k}$.

**Open:** targets that are a large parity only on subcubes of linear codimension. Inner product mod 2 is an example: fixing half of its coordinates leaves a parity of about a quarter of them. The supporting note suggests that the margin-sensitive lemmas transfer to such targets one restriction at a time (extension suggested by the proof), but this has not been written out.

**Targets without a parity subcube.** The sign-staircase $`\mathrm{sign}(x_1+x_1x_2+\cdots+x_1\cdots x_d)`$, with $d$ odd, needs at least $\exp(\Omega(\sqrt d\log d))$ samples for these learners in all three regimes (proved). The distance argument cannot give more, because the sign-staircase is close to threshold functions of degree $O(\sqrt{d\log(1/\varepsilon)})$. Whether it is exponentially hard is open. Every function of $`\sum_ix_i`$ alone has the same ceiling for the distance argument. Some such functions still reach $\exp(\Omega(d))$, for example $(-1)^{\lfloor w/2\rfloor}$, where $w$ is the number of coordinates equal to $-1$. The argument uses a random restriction that ties coordinates together in blocks (extension suggested by the proof: the target-dependent steps of the subcritical paper were audited, but the transferred proof has not been written out).

Exact threshold degree is a worst-case notion. Functions with high threshold degree, such as the Minsky–Papert AND of ORs, can be nearly constant under uniform inputs. For such targets our lower bounds are weak, because $`\mathrm{err}_r(f)`$ is small. Our upper bounds are also weak, because exact sign representations need high degree or tiny margins. So the sample complexity of such targets for these learners remains open.

**Scope.** All Bayesian results in this answer concern the $\gamma<1$ learners described in Setting, except the two-head variant below. The greedy learner and the Adam runs below are other learners, included for comparison. The $\gamma\ge1$ regimes learn every small circuit, parity included ([Question 8](#8-what-is-actually-known-for-the-one-parameter-family-of-scalings)). At depth linear in $d$, the deep NNGP family of [Question 7](#7-how-do-the-nnbayes-results-here-relate-to-nngp-and-kernel-regression) and a [deep $\gamma\le0$ family](side-results/gamma-below-one/paper.pdf) fail on every target, so their lower bounds say nothing specific about parity.

The supporting note's numerical illustrations only illustrate the asymptotic statements. At $d=12$, $L=2$, and $\gamma<0$:

- majority of seven bits reaches confidence failure $0.03$ at $n=200$;
- three-bit parity falls below $0.01$ by $n=2400$;
- $g$ still fails at $n=2400$ on $23\%$ of all inputs and $41\%$ of unseen ones.

In these runs, $g$ is learned more slowly than three-bit parity. The supporting note's explanation, via $g$'s larger kernel norm, is heuristic.

**Comparison with SGD.** The **leap** $\mathrm{Leap}(f)$ of a target is the least $\ell$ such that the sets in its Fourier support can be ordered so that each contains at most $\ell$ coordinates outside the union of the earlier ones.

- [Abbe, Boix-Adserà, and Misiakiewicz](https://arxiv.org/abs/2302.11055) conjecture that online SGD on two-layer networks learns a junta from about $d^{\max(\mathrm{Leap}-1,1)}$ samples. They prove a version for a class of targets on Gaussian data.
- Their [earlier paper](https://arxiv.org/abs/2202.08658) calls leap one the merged-staircase property. It shows that this property is necessary and nearly sufficient for SGD in the mean-field regime to learn from $O(d)$ samples.

These SGD statements concern exponents for fixed juntas and are taken from the papers' abstracts. No theorem here relates SGD to these posteriors.

Every Boolean function satisfies $\mathrm{Leap}(f)\le\mathrm{thr}(f)\le\deg f$; the proof is elementary. So a junta of leap $\ell\ge2$ has threshold degree at least $\ell$. These learners then need at least about $d^{\ell}$ samples: in confidence on every training set at $\gamma<0$, and in Gibbs error for typical samples at $0\le\gamma<1$, up to a factor $d^{2\beta}$.

The converse fails. The leap-one target $g$ needs at least about $d^3$ samples at $\gamma<0$, while SGD is conjectured to need about $d$. The supporting note's exhaustive four-bit census suggests that targets like $g$ are common: 97.5% of the leap-one functions depending on all four of their bits have threshold degree at least two.

For $`k`$-sparse parity with fixed $k\ge2$, leap, threshold degree, and degree all equal $k$. Under the conjectured rate, SGD needs about $d^{k-1}$ samples. At $\gamma<0$ these learners need between about $`d^{k^*}`$ and $`d^{k^*+1}`$. At $0\le\gamma<1$ they need at least about $`d^{k^*}`$ up to a factor $d^{2\beta}$, in Gibbs error. So the exponents differ only by a small constant. [Barak et al.](https://arxiv.org/abs/2207.08799) find SGD taking $d^{O(k)}$ iterations on sparse parity, near the statistical-query limit.

**A target that gradient descent can climb.** For an exponential gap, let $d$ be odd and add one selector bit $z$ to $x\in\lbrace -1,1\rbrace ^d$:

$$
f^*(x,z)=\begin{cases}
\mathrm{sign}\left(x_1+x_1x_2+\cdots+x_1x_2\cdots x_d\right),&z=+1,\\
x_1x_2\cdots x_d,&z=-1.
\end{cases}
$$

On $z=+1$ it is the sign of a staircase. A chain of XOR gates computes the prefix parities, a linear-size majority circuit combines them, and one selector picks the half, so $`f^*`$ has a Boolean circuit of $O(d)$ gates. For $t<d$, each prefix parity $`x_1\cdots x_t`$ correlates with $`f^*`$ at about $(2\pi d)^{-1/2}$, and each extends the previous one by one coordinate, so a learner can find them one at a time. The last, $`x_1\cdots x_d`$, is the full parity that $`f^*`$ equals on $z=-1$.

On the Bayesian side:

- **The $\gamma<1$ learners need $\exp(\Omega(d))$ samples (proved).** This is the subcube theorem above with codimension $k=1$, for the learners of Setting on all $d+1$ bits. In the width limit, for every $n\le e^{cd}$ and with probability at least $3/4$ over uniform iid samples, at least $1/32$ of all inputs fail the confidence criterion, and at least $3/16$ at $\gamma<0$.
- **Two-head Bayesian networks (proved).** Give the network a shared stack of hidden layers that sees only $x$, and two readouts with equal variances, one used when $z=+1$ and one when $z=-1$. In the width limit, at $\gamma\le0$ the posterior splits into independent posteriors on the two halves, and at $0<\gamma<1$ the minimum-energy problem splits. So the parity half fails exactly as in the subcritical paper. This is a modified prior. Its width limit is two independent Gaussian processes, so its hardness is that of parity on one half.

On the gradient side:

- **A layerwise learner provably climbs it (proved).** Consider a greedy procedure in the spirit of the staircase learner of [Abbe, Boix-Adserà, Brennan, Bresler, and Nagaraj](https://arxiv.org/abs/2108.10573). It grows product units $`x_{i_1}\cdots x_{i_m}`$ one coordinate at a time, keeping a unit when its correlation with the target, or with $z$ times the target, is above a threshold. It then trains two linear heads on these units, one for each value of $z$. It finds exactly the $d$ prefix parities from $O(d\log d)$ samples, and the heads reach error $\varepsilon$ from $O(d^2/\varepsilon)$ more. It is a correlation-query procedure, not gradient descent on a standard network. It stalls on parity alone, and on the control target that is $`x_1`$ on $z=+1$ and parity on $z=-1$.
- **Adam on a two-head network learned it at every dimension tested (numerical).** A ReLU network computes three hidden layers of width 512 from $x$, giving $\phi(x)$, and outputs $`w_1\cdot\phi(x)+z\,w_2\cdot\phi(x)`$. It was trained with Gaussian initialization on fresh samples. Its error on the parity half fell below 5% after about $2.7\cdot10^6$, $8.8\cdot10^6$, $1.7\cdot10^7$, $4.8\cdot10^7$, and $7.6\cdot10^7$ samples at $d=19$, 23, 27, 31, and 35. On the control target, the parity half needed about $1.0\cdot10^7$ and $1.8\cdot10^7$ samples at $d=19$ (two seeds) and $1.9\cdot10^7$ and $2.6\cdot10^7$ at $d=23$, and was not learned within $4\cdot10^7$ at $d=27$ or $6\cdot10^7$ at $d=31$. Parity alone, on the same hidden layers with one readout, was not learned at any of $d=19$, 23, 27, and 31, within budgets of $2\cdot10^7$ to $6\cdot10^7$ samples. So on this network, parity was learned only as half of a two-half target, and at $d=27$ and 31 only next to the staircase half. SGD with momentum, in place of Adam, also learned $`f^*`$ at $d=19$: its parity half fell below 5% after $6.4\cdot10^6$ samples and its staircase half after $8.4\cdot10^6$.
- **What the numerics do not show.** There are one or two seeds per dimension, $d\le35$, and at $d=19$ the runs used more samples than there are inputs. This range cannot separate polynomial from exponential growth. A plain fully connected network with $z$ as an ordinary input, the shape of the learners in the subcube theorem, learned $`f^*`$ only at $d=19$ and 21, each time after more samples than there are inputs. With Gaussian initialization it learned the staircase half but not the parity half at $d=23$ and 27, within $5\cdot10^7$ and $6\cdot10^7$ samples, and with PyTorch's default initialization it did not learn $`f^*`$ at $d=31$ within $6\cdot10^7$. Parity alone, on a smaller one-hidden-layer network with Gaussian initialization, was learned at $d=19$, 23, and 27 from $2.3\cdot10^6$, $3.8\cdot10^6$, and $1.6\cdot10^7$ samples, no more than the parity half of $`f^*`$ needed. It was not learned within $1.5\cdot10^8$ samples at $d=31$. With PyTorch's default uniform initialization, the same network learned parity alone at $d=31$ from about $3\cdot10^6$ samples. So the comparison with parity alone depends on the initialization and on the architecture.
- **Open: no theorem for end-to-end SGD.** We found no theorem in which end-to-end SGD from a Gaussian initialization learns a linear-degree parity, or $`f^*`$, on uniform inputs; the search was at abstract level. The positive results for almost-full parities, by [Abbe, Cornacchia, Hązła, and Kougang-Yombi](https://arxiv.org/abs/2412.04910), start from $\pm1$ first-layer weights, possibly with Gaussian perturbations of size $O(1/d)$, and a large Gaussian perturbation prevents learning (literature, abstract-level). We read this as an effect of initialization (heuristic).

**Why both halves (heuristic).** Two proved facts suggest why simpler targets do not work for the available proof routes. If a target is within distance $\eta$ of a single parity, all its other Fourier coefficients are at most $2\eta$, so there is little low-degree signal to climb. If instead a target becomes $\pm$ a parity of at least $\alpha d$ bits once some coordinates are fixed at uniformly random values, except with probability $\delta$, then its Fourier weight below degree $\alpha d$ is at most $\delta$. $`f^*`$ avoids both. It is at distance about $1/4$ or more from every parity, and at least about $\alpha/\pi$ of its Fourier weight lies below degree $\alpha d$. Yet it equals a parity exactly on half of the cube.

**Comparison with kernel regression.** For contrast, consider a different predictor built from the same kernel $K$. It is the posterior mean of the centered Gaussian process with covariance $K$, given the noiseless labels as real values. That process is the NNGP of the sign-activation network in Setting, not the standard-scaling NNGP of Question 7. This posterior mean is kernel interpolation, called kernel regression below. Its squared error is governed by Fourier weight rather than by distance from threshold functions.

Write $`\mathrm{wt}_k(f)`$ for the Fourier weight of $f$ at degree $k$, and $`\mathrm{wt}_{>r}(f)`$ for its total weight above degree $r$.

For uniformly sampled inputs, the expected squared error of kernel regression depends on the target only through the weights $`\mathrm{wt}_k(f)`$. The supporting note proves this by a symmetry argument. For fixed $k$ and $`n\le c_k\,d^{k^*}(d\log d)^{-\beta}`$, where $`c_k>0`$ depends on $k$ and the depth, at least half of the weight at degrees $k$ and above remains as squared error. For $`n=o(d^{k^*}(d\log d)^{-\beta})`$, all of it remains up to $o(1)$.

The odd rounding comes from the odd activation and the constant input coordinate, which together give $`x_1x_2`$ the same eigenvalue as $`x_1x_2x_3`$. This is the lower-bound half of the standard polynomial-regime picture of kernel regression, as in [Mei, Misiakiewicz, and Montanari](https://arxiv.org/abs/2101.10588), whose examples include the hypercube. We have not checked that paper's hypotheses for this kernel.

The two criteria differ:

- **Majority of all $d$ bits** keeps weight of order $k^{-1/2}$ above every degree $k\ll d$. Squared error $\varepsilon$ therefore needs at least $d^{\Omega(1/\varepsilon^2)}$ samples once $d$ is polynomially larger than $1/\varepsilon^2$. The sign posteriors learn majority at polynomial cost.
- **AND of all $d$ bits** has degree $d$, but all except $O(2^{-d})$ of its weight is at degree zero. So the regression lower bound gives nothing for it: that bound depends on high-degree weight, not on Fourier degree.
- **The target $`g`$** has $9/16$ of its weight at degree four. Regression keeps its squared error at least $9/16-o(1)$ while $n=o(d^5(d\log d)^{-\beta})$.

In one direction the criteria are linked. Since $`\mathrm{err}_r(f)\le\mathrm{wt}_{>r}(f)`$, every target that our lower bounds certify as hard for the sign posteriors is also hard for squared-error regression.

## 12. What robustness condition gives polynomial depth dependence?

**Proved under a restriction on the prior.** Add a disturbance after each hidden layer and at the readout, with total budget

$$
\Vert \eta\Vert _*^2=\sum_{s=1}^{L-1}\frac{\Vert \eta^s\Vert _2^2}{N}+|\eta^{\mathrm{out}}|^2.
$$

For $E_v=N\Vert v\Vert _2^2$, use radius

$$
r_c(w)=\frac{c}{\sqrt{1+(L-1)E_v}},
$$

where $c>0$ is fixed. Clip the output at the training margin, $T(z)=\max\lbrace -1/2,\min\lbrace 1/2,z\rbrace \rbrace $. Restrict the Gaussian prior to networks for which

$$
|T(z_w(x;\eta))-T(z_w(x))|\le1/16
$$

at every input and every disturbance in that ball.

For the tanh learner and a layered Boolean target circuit of width $C$, this gives sample complexity polynomial jointly in $d,L,C,c+c^{-1},\varepsilon^{-1},\log(1/\delta)$, simultaneously for every $N\ge C$ and every $\gamma\ge1$. The proof builds a robust implementation with enough Gaussian prior mass and compresses posterior draws through small internal disturbances.

The condition has a recognizable interpretation: the prediction score must survive a small amount of simultaneous internal numerical error. Clipping avoids treating a change from output $10$ to output $1$ as a prediction failure. The RMS normalization makes perturbations comparable across widths. The radius compensates for accumulating layer disturbances and readout amplification.

It is nevertheless a particular sufficient condition, with a strong “every input, every perturbation” quantifier. Calling it natural does not establish that arbitrary trained networks satisfy it.

For ReLU and GELU, a [separate polynomial-depth theorem](works-in-progress/relu-gelu-polynomial-depth/) instead restricts the prior by stability under merging neuron populations. It gives quadratic width dependence up to logarithms. That condition is not proved equivalent to the internal-noise condition above; its definition and polynomial are discussed in [Question 19](#19-what-are-the-actual-polynomials-are-practical-sample-bounds-close).

## 13. How can we check whether a network satisfies the robustness condition?

A sufficient check bounds how much disturbances introduced at each layer can change the final prediction. One simple certificate requires the internal layers not to amplify Euclidean distances, a property called **nonexpansiveness**. Tanh applied coordinatewise has this property, as does a linear layer whose operator norm is at most one. Under these layerwise bounds, Cauchy–Schwarz bounds the readout change by $c$ under the calibrated noise budget above. Thus $c\le1/16$ supplies a sufficient certificate.

**Proved:** the robustness restriction used for polynomial-depth generalization also admits more flexible certificates. Finite-radius Jacobian bounds, bounds on reachable activation intervals, and suitable weighted layer metrics can certify the restriction. These allow expansion in one direction or layer when later contraction or saturation controls the total effect; individual operator norms can exceed one.

A Jacobian computed only at the clean network state is not a finite-perturbation certificate. Likewise, flatness under parameter perturbations, a small training-loss Hessian, or robustness to one kind of input noise does not by itself control arbitrary internal disturbances. Explicit examples separate these properties.

## 14. Is the condition satisfied by actual gradient-descent-trained networks?

**Sometimes, but not universally; the evidence is deliberately narrower than a general claim about deep learning.** The experiments use ordinary SGD/Adam on fully connected tanh image classifiers and some finite Boolean tasks. They are not tests of transformers, ReLU architectures, or posterior sampling.

There are positive global certificates and negative examples. A particularly useful comparison is one fully fitted MNIST SGD model: every one of its 60,000 recorded training inputs and 10,000 held-out inputs has a rigorous certificate at $c=10^{-3}$, yet a valid off-distribution 8-bit image violates the global condition. Its training margins were also checked rigorously. This separates “stable on all the data we checked” from “stable on the entire Boolean input domain.”

Two smaller Boolean classifiers have certificates on their entire finite input cube. Conversely, there is also an analytic gradient-descent construction that remains perfectly fitted while violating the global condition off the data support. Ordinary gradient descent therefore does not imply the condition as a matter of logic.

There is a stronger positive observation at a smaller radius. In an explicitly exploratory follow-up, the same fitted depth-16 MNIST model has an exact **global** certificate at $c=0.001/16$, and a fitted depth-32 continuation has one at $c=0.001/32$, without changing their trained weights. The [reproduction guide](works-in-progress/depth-experiments/REPRODUCTION.md) includes the depth-32 model and an offline verifier. Choosing $c=0.001/(L-1)$ still gives polynomial depth dependence in the theorem. This is encouraging evidence for a polynomially shrinking calibration, but two depths do not establish an asymptotic training law. These smaller-radius successes also do not erase the primary-radius counterexamples.

The image checks are finite collections of exact inequalities, not a population coverage theorem. The models, calibration choices, exploratory follow-ups, and certificate provenance are recorded in the [experimental package](works-in-progress/depth-experiments/). Successful pointwise checks are evidence for investigating a distributional version, not evidence that the existing global-support theorem already applies to that model.

The stronger neuron-merging restriction used for quadratic width dependence has its own [naturality study](#how-natural-is-the-neuron-merging-restriction), with fresh trained examples and different certificates. Membership in one condition should not be inferred from membership in the other.

## 15. Can robustness be required only near the data, or on average?

**Yes with additional bookkeeping; arbitrary average robustness is not currently enough.** There are several proved variants in the [robust paper](main-results/robust-polynomial-depth/paper.pdf):

- A fixed trusted region, with a bounded probability of landing outside it. Stability is required throughout that region.
- A controlled-complexity family of exceptional regions, allowing a posterior to choose an exception set while uniform sampling bounds control its coverage. The theorem pays for the size or complexity of that family.
- A region or finite catalog chosen from an independent unlabeled pilot, with coverage assessed on validation data. A frozen single region has no selection-complexity penalty merely because its construction was complicated.
- Stability imposed at a finite iid unlabeled pool, including the labeled inputs. This retains a polynomial, width-independent **labeled** sample bound, but the current unlabeled budget grows like $N/t^2$ times a polynomial, where $t^2=N^{1-\gamma}$. It is not a width-independent total-data theorem.

For the first three routes, one still needs a certificate on the whole chosen region, not just its observed points. In high dimension, extending point certificates to tiny neighborhoods can give negligible coverage. One tested neighborhood-cover construction indeed gave poor coverage; that is a limitation of that construction, not a proof that broad robust regions do not exist.

**Open for the original conditioning rule:** merely requiring each prior-supported network to be unstable on at most a $\rho$ fraction of inputs, with no complexity control on those exceptional sets. The selected posterior may concentrate its exceptional sets around the training sample. An abstract sparse-patch counterexample shows why a generic averaging argument fails; it is not a counterexample for the specific Gaussian neural prior.

Other candidates include robustness to dropout, random quantization, or random internal noise. These are plausible training objectives, but average random-noise robustness does not automatically imply the adversarial finite-noise condition used by the current compressor. Soft penalties also require explicit control of how much unstable posterior mass remains. They should be presented as research directions unless the additional bridge is supplied.

## 16. Is exponential depth dependence necessary without any robustness restriction?

**Yes for unrestricted continuous-output regression; open for the original Boolean-cube model.** The [continuous-depth lower bound](works-in-progress/continuous-depth-lower-bound/) gives teachers of constant width, weights bounded by 30, and growing depth on the unit circle. For a fixed, nonatomic input distribution, learning their real outputs requires exponentially many samples in depth. This holds in the strong-prior limit at every fixed width above a threshold polynomial in the sample size, at every fixed exponent $\gamma>1$ at widths above a threshold polynomial in the sample size and depth, and at mean-field scaling in the width-first limit. These thresholds are far above teacher width, so the result refutes guarantees asserted at every width $N\ge C$, not behavior near the teacher width. Training and test tolerances are fixed constants, and the failure concerns the actual posterior-confidence criterion, including mixtures. The mean-field result does not give a quantitative width threshold.

The mechanism is that the teacher separates outputs at exponentially close input pairs. For the strong-prior and above-mean-field cases, a small random sample can instead be fit exactly by a network whose energy permits only a polynomial-in-sample-size Lipschitz constant, independently of depth. The posterior favors those fits, which must fail on at least one member of every close pair. This also gives a lower bound for minimum-energy exact interpolation and the specified strong-prior-then-zero-tolerance posterior limit. The mean-field proof uses a separate entropy-rate comparison and the same paired inputs. The fixed input distribution is supported on a Cantor subset of the circle; smooth densities depending on depth are also covered. Uniform spherical inputs remain open.

**For Boolean inputs,** the original depth example and later critical-rate constructions remain capacity or proof obstructions, rather than exponential sample lower bounds. Distinct cube inputs do not become exponentially close, so the continuous counterexample does not settle that question.

Polynomial dependence on learner depth is possible for substantial target classes. For every fixed gap $\gamma\ge1+\zeta$, the [unrestricted-depth paper](works-in-progress/unrestricted-depth/paper.pdf) gives polynomial dependence on learner depth for all bounded-weight shallow tanh targets and for all Boolean halfspaces, at every actual width above the original $C_L(f)$. The halfspace result does not depend on the target's original coefficient precision or geometric margin. Other covered classes include fixed-depth threshold circuits and functions with polynomially bounded Fourier $\ell_1$ norm, including parity.

A further positive case allows arbitrarily deep computation after a small set of hidden states. Suppose a bounded-weight teacher of depth $D$ takes only $K$ distinct hidden-state values after a fixed number of initial layers. The sample bound is polynomial in $K$, teacher resources, and learner depth, at every $L\ge D$ and every actual width $N\ge C_L(f)$, for each fixed exponent above one. No robustness condition is added to the prior. Examples include a fixed-width first layer with polynomially bounded integer weights, or a first layer driven by a fixed number of groupwise bit counts. The proof replaces the remaining computation by a lookup circuit; it does not require the hidden states to be well separated. The initial number of layers must be fixed, and $K$ can be exponential for an arbitrary teacher.

For a general fan-in-two Boolean circuit of size $s$, logical depth $h$, and $S=\max\lbrace 16,2+d+s\rbrace $, a proved bound is

$$
S^{O_\zeta(1+h/\log\log S)}\,
\mathrm{poly}(L,\varepsilon^{-1},\log(1/\delta)),
$$

at learner depths $L\ge\max\lbrace 2,h\rbrace $. This improves the direct exponential dependence on $h\log S$, but is not a joint polynomial. Formula balancing gives a quasipolynomial alternative for formulas, with the corresponding learner-depth qualification.

The same paper identifies a function-level product-norm representation barrier: low sample complexity forces suitable approximate low-product-norm representatives in a specified large-width regime. No explicit small deep circuit violating the necessary approximation condition is known here. Indeed, an explicit superpolynomial-sample counterexample within $\mathsf{NC}^1$, in the regime covered by these positive results, would separate $\mathsf{NC}^1$ from $\mathsf{TC}^0$. This is a reason for caution about easy purported counterexamples, not a proof that the desired theorem is true.

## 17. What does the critical-depth result imply about learning?

**The original critical prior has polynomial learner-depth bounds for substantial target classes, at every width capable of representing the target.** The [critical-depth paper](works-in-progress/critical-depth/paper.pdf) uses the original global output-margin condition and exact noiseless training fit. It adds no internal robustness restriction. These results remain independently reviewed research drafts, outside the five promoted main results; they are not Lean verified.

“Every realizable width” means every width at which the specified depth admits a tanh network implementing the target's signs. Rescaling the readout gives strict margin $1/2$, so the target event has positive Gaussian probability. There is no additional lower bound on learner width. The input distribution on the Boolean cube is arbitrary. The conclusions concern the full posterior, including mixtures: with training probability at least $1-\delta$, the correct-label probability exceeds $2/3$ except on test mass at most $\varepsilon$.

**Every parity has polynomial sample complexity at sufficiently large logarithmic learner depth.** More generally, let $A_F(f)=\sum_S|\widehat f(S)|$, the Fourier variation, and put $R_F=(d+L+2)A_F(f)$. At every realizable width, a sufficient sample size is

$$
n\ge\frac C\varepsilon\left[R_F^c(1+\log(1/\varepsilon))^c+\log(1/\delta)\right]
\qquad\text{if }L\ge C_0\log R_F.
$$

The constants are universal. All signed parities have $A_F=1$, regardless of degree, so this includes full parity. Reaching a *bounded absolute prior rate* requires depth of order $(\log d)^2$; that is a different criterion, and the learning theorem does not require it.

For a tanh teacher of depth $D$, width $C_T$, parameter magnitudes at most $B$, and global signed output margin at least $1/2$, put $R=d+C_T+B+D+L+2$. When $L\ge C_0(D+1)\log R$, the sufficient sample size at every realizable width is

$$
n\ge\frac C\varepsilon\left[R^{c(D+1)}(1+\log(1/\varepsilon))^c+\log(1/\delta)\right].
$$

This is polynomial in learner depth for every fixed teacher depth. For Boolean threshold circuits, the original coefficients may be arbitrary real numbers: a teacher of depth $h$ and width $C_T$ gives the analogous $R^{O(h)}$ bound with $R=d+C_T+h+L+2$, independent of coefficient magnitudes or precision. In particular, Boolean halfspaces have a polynomial bound at every width $N\ge1$ under the logarithmic depth condition.

Some long sequential computations also have polynomial bounds. These include two-state branching programs, programs over fixed solvable finite groups, and permutation branching programs of width at most four. A teacher with a fixed-rank first-layer bottleneck has a polynomial bound in its product norm even when its remaining depth is arbitrary. General formulas have a quasipolynomial bound in dimension and formula size. **Joint polynomial sample complexity in arbitrary teacher width and depth remains open.** The paper states the precise resource and minimum-depth conditions for each class.

The general finite-width theorem uses the target's actual raw prior cost

$$
a_N(f)=-\frac1N\log\Pr\lbrace f(x)z_w(x)>1/2\text{ for every }x\rbrace .
$$

There is a universal baseline $V_{\ast}\in(1,2)$. At every realizable width, the sample bound is a universal polynomial in $d,L,a_N(f),1/\varepsilon$ and $\log(1/\delta)$, multiplied by

$$
\exp\bigl(C\sqrt{L[a_N(f)-V_{\ast}]_+}\bigr).
$$

The proof has two parts. Forward conditional entropy extracts approximate covariance paths from finite-width events. Preserving a small set of input-anchor covariances then produces finite tanh representations, whose VC dimension controls competing functions. Separately, a finite-width construction tracks a planted target signal and residual variance to lower-bound the target's actual prior probability. That construction needs a quantified width threshold; ordinary VC bounds handle every smaller realizable width. The resulting learning theorem has no such threshold.

This does not make the function prior uniform or approximate circuit description length exactly. Its limiting rate $J_L(f)=\lim_N a_N(f)$ still controls exponential preferences at large width, and small positive rate differences are multiplied by $N$. The explicit finite-width construction need not be optimal for a target. Nor does the theorem bound the compressed network's weight norms or give an efficient posterior-sampling algorithm.

## 18. Can the exponential dependence on the *teacher's* depth be removed unconditionally?

**For substantial Boolean target classes, yes; for arbitrary continuous-output teachers, no.** The [continuous regression counterexample](works-in-progress/continuous-depth-lower-bound/) has constant teacher width and bounded weights, but needs exponentially many examples in teacher depth. It uses the unrestricted Gaussian learner and a fixed nonuniform distribution on the circle. The general Boolean-cube question remains open. Teacher depth, learner depth, and the norm of a teacher representation are different parameters.

The unrestricted results remove dependence on a chosen teacher's depth when the function has another controlled shallow representation. More generally, a globally unit-margin network with product of Frobenius norms $P$ has a Boolean normal form with depth, width, and finite description polynomial in $P$, apart from specifying at most $P^2$ relevant input coordinates. This bound is independent of the original teacher's depth and width. The learning theorem for product-controlled targets has an explicit additional-learner-depth requirement.

However, $P$ can itself grow exponentially with the depth of a bounded-weight teacher. Replacing teacher depth by $P$ does not prove a polynomial bound in arbitrary neural-circuit size. Nor does it show that a same-depth, same-width robust realization always exists. Digital simulation of a margin-separated real neural circuit may add depth and width, and those costs must be counted.

Thus we should not advertise “depth dependence eliminated for all small neural networks.” The established statement is a collection of representation-sensitive improvements, plus a joint polynomial-depth theorem under the explicit robustness restriction for Boolean-circuit targets.

## 19. What are the actual polynomials? Are practical sample bounds close?

**Substantially smaller bounds are available in several settings, but these are still theoretical sample guarantees.** The [improved-polynomials papers](works-in-progress/improved-polynomials/) give explicit estimates, with independent AI-agent mathematical reviews. They are supporting research papers, **not Lean-verified improvements** to the five main theorems. In the table, the powers of teacher width hold with input dimension, depth, calibration, accuracy, and confidence fixed; the papers also specify those dependences.

| Setting | Dependence on teacher width | Scope |
|---|---|---|
| [Original internal-noise robustness restriction, every mean-field-or-stronger scale](works-in-progress/improved-polynomials/original-support-all-scales/paper.pdf) | $O(C^6\log^{13}(2+C))$ | One sample event works at every $N\ge C$ and every $\gamma\ge1$, including the actual finite mean-field prior. No neuron-averaging assumption is added. |
| [Original restriction, stronger scales](works-in-progress/improved-polynomials/original-support/paper.pdf) | $O(C^4\log^9(2+C))$ | Strong-prior limit at each width, and actual finite priors at every $\gamma\ge2$. The quartic argument does not cover $1\le\gamma<2$. |
| [Additional stability under neuron averaging](works-in-progress/improved-polynomials/neuron-averaging/paper.pdf) | Quadratic, with polynomial depth dependence | Every $N\ge C$ and $\gamma\ge1$, but under a **stronger structural support condition**. This is not a quadratic bound for the original restriction alone. |
| [One hidden layer](works-in-progress/improved-polynomials/shallow/paper.pdf) | Quadratic when teacher readout coefficients are bounded independently of width; a quartic term for the original larger coefficient class | Every $N\ge C$ and $\gamma\ge1$. Covers the raw Gaussian prior as well as the globally margin-conditioned and shallow robust priors. Positive training margins are still required. |

The first three rows compare with layered Boolean circuits, including constant wires and compilation overhead. The shallow row compares with an implementing tanh network and states its coefficient assumptions separately. None of these rates is a lower bound or a claim of optimality.

**The original robust prior throughout $\gamma\ge1$.** The sextic bound retains exactly the main robustness theorem's learner: clipped predictions survive a calibrated ball of simultaneous internal disturbances; training requires signed output above $1/2$; test error uses margin $1/4$. Its sample polynomial is joint in depth and the other resources, independent of learner width and Gaussian scale. It controls the posterior average, so a strict $2/3$ confidence guarantee follows by rescaling the error tolerance by three.

The improvement comes from sampling source neurons partly uniformly and partly according to their contribution to retained directions, then matching the sampled covariance more accurately. This removes large truncation losses from the original compression proof. The [paper](works-in-progress/improved-polynomials/original-support-all-scales/) gives all intermediate budgets; the displayed sixth power describes dependence on $C$, **not** degree six in all parameters. A quadratic bound for this unchanged support condition remains open. The simpler quartic proof at $\gamma\ge2$ controls total network energy directly; that argument alone cannot discard the growing Gaussian background at mean-field scaling.

**What the quadratic alternative assumes.** The added condition requires a balanced grouping of neurons into at most $1+N\lVert v\rVert_2^2$ groups per hidden layer such that averaging weights within the groups barely changes clipped predictions. The prior does not know the target's width, but it explicitly requires a small compressed representation relative to readout energy. Imposing this in addition to internal-noise stability further restricts the prior, and is a substantive structural assumption. A [follow-up theorem and naturality study](works-in-progress/improved-polynomials/neuron-merging-naturality/) allows signed, unequal groups and an output-normalized count budget while retaining quadratic dependence. It gives some rigorously certified ordinarily trained examples; no general training guarantee is established.

At fixed calibration, a sharper bound for this prior is

$$
n=\widetilde O\!\left(\frac{L^2(d+LC)^2+\log(1/\delta)}{\varepsilon}\right),
$$

where the notation suppresses logarithmic factors, including accuracy logarithms. A literal quadratic-width envelope, with no hidden logarithms of $C$, is

$$
n\ge\frac{A}{\varepsilon}\left[C^2S_0^9+\log(1/\delta)\right],
\qquad S_0=2+d+L+c+\log(4/\varepsilon),
$$

for a universal constant $A$. It uses the bounded fan-in and single-output convention to prune irrelevant teacher wires and absorb their logarithmic cost into depth. A different, stronger calibration of the permitted group count gives approximately $\widetilde O((LdC+L^2C^2)/\varepsilon)$ at fixed calibration, accuracy, and confidence. Changing that calibration changes the prior restriction.

### How natural is the neuron-merging restriction?

**Every eligible layered Boolean circuit has a suitable implementation, but the condition is a real additional assumption on the learner.** At every `N >= C`, the construction assigns cloned neurons to the circuit's wires. Merging preserves its output, and an explicit neighborhood with positive Gaussian probability also satisfies the restriction. This proves existence of good implementations, not that all implementations of the same function qualify.

The original unsigned condition has an artificial dependence on neuron signs: flipping a tanh neuron's incoming and outgoing signs preserves the function and Gaussian density but can break averaging. The [signed-merging paper](works-in-progress/improved-polynomials/neuron-merging-naturality/paper.pdf) fixes this and also permits unequal group sizes. Both changes preserve quadratic teacher-width and polynomial depth dependence for every `gamma >= 1` and every `N >= C`.

The group-count calibration also matters. With `Ev = N ||v||²`, the original budget `q <= 1 + Ev` permits the identity partition whenever `Ev >= N-1`. Such membership does not demonstrate compression. A proved alternative is

$$
(q-1)\left(\max_x|z_w(x)|\right)^2\le4E_v(w).
$$

This count budget is independent of a global readout rescaling. The complete condition still uses clipped outputs and fixed margins. A more local sufficient condition asks neurons in a signed group to respond similarly to signals constant within the preceding groups; together with the original internal-noise condition, it implies merging stability and still gives the quadratic bound. These variants are more principled, but none is established as a general property of gradient training.

**The empirical evidence is mixed and search-dependent.** All 40 fresh tanh networks in the [reproduction package](works-in-progress/improved-polynomials/neuron-merging-naturality/experiments/) fit their training margins after ordinary SGD or Adam from mean-field initialization. Five pass the original count budget automatically. Among the remaining 35, unsigned balanced activation clustering found no witnesses; signed clustering found six, and an additional output-aware sign search raised the total to 14. Across all 40 models, that follow-up found 11 networks reducible to one signed population per layer. The searches use the network's own activations and outputs, not target labels. A failed search does not prove failure of an existential condition.

Three examples have exhaustive interval certificates, including a width-32, four-hidden-layer Adam network whose clipped outputs are preserved exactly by one signed population on all 256 inputs. Other witnesses use exhaustive float64 checks. These certify merging stability, not automatically internal-noise robustness or Bayesian learning behavior. The local operator-norm certificate is too conservative to explain these examples at the small noise calibrations previously tested. A quadratic bound under the original internal-noise restriction alone remains open.

**For ReLU and GELU, the analogous merging restriction also gives a quadratic bound.** The [separate paper](works-in-progress/relu-gelu-polynomial-depth/paper.pdf) uses unsigned populations of arbitrary sizes and the same output-normalized count budget. It proves, for every $\gamma\ge1$,

$$
n\ge\frac{A}{\varepsilon}\left[C^2\bigl(2+d+L+\log(4/\varepsilon)\bigr)^9+\log(1/\delta)\right]
$$

as a sufficient sample budget for a single-output bounded-fan-in Boolean teacher. Here $C$ counts the Boolean circuit's width, including constant wires; the eligible learner widths are $N\ge C$ for ReLU and $N\ge2C$ for the exact GELU compilation. A more informative nested budget has $O(C^2\log^3(2+C))$ dependence at fixed other resources. ReLU removes population-size parameters by homogeneity; GELU retains them but they admit a uniformly controlled finite cover. This is a conventional, independently reviewed result, not an update to the Lean polynomial.

### Other polynomial estimates and verification

**The shallow bound is affine in a weighted squared norm, with a dimension overhead.** For a width-$C$ teacher with hidden matrix $W$ and readout $a$, write

$$
\kappa_C=\frac dC\lVert W\rVert_F^2+C\lVert a\rVert_2^2.
$$

For the raw Gaussian or globally margin-conditioned prior, a sufficient sample bound is

$$
n=\widetilde O\!\left(\frac{d(\kappa_C+d)+\log(1/\delta)}{\varepsilon}\right).
$$

The additional $d^2$ term comes from the target-neighborhood probability estimate; the teacher norm need not dominate $d$. The shallow robust prior is also covered, with calibration dependence. If hidden coefficients are at most $C$ and readout coefficients are bounded by a fixed constant, this is quadratic in $C$ up to logarithms; a second estimate is literally quadratic with a worse dimension factor. If **all** coefficients may be as large as $C$, then $\kappa_C$ can contain a $C^4$ readout term. The paper does not prove that this quartic dependence is necessary. Its argument controls the readout norm and represents tanh units as mixtures of halfspaces, avoiding the deep-network compressor.

**What is formally checked?** The existing Lean proof of the robust main theorem still has its deliberately loose sufficient budget

$$
A\left[2+d+C+(L-2)+c+c^{-1}+\varepsilon^{-1}+\log(1/\delta)\right]^{10974}.
$$

The original manuscript's transport construction has a conservative degree-510 estimate. The new all-scales paper gives a much smaller conventional envelope,

$$
n\ge A\left[2+d+L+C+c+c^{-1}+\varepsilon^{-1}+\log(1/\delta)\right]^{46}.
$$

This degree-46 bound is still deliberately loose; the paper's explicit nested budget and the $C^6\log^{13}(2+C)$ rate are more informative. These are upper bounds from particular proof constructions, not necessary exponents. The smaller rates above have conventional proofs and separate review records; they have not been substituted into the [Lean verification record](lean/VERIFICATION.md#generalization-under-a-robustness-restriction-scope-and-correspondence).

**The unrestricted deep bounds retain poor depth dependence.** For comparison, the original strong-prior proof bounds target energy by

$$
B_L(d,C)=d(d+1)C^2+LC^4
$$

and uses compression width

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

suffices in the strong-prior limit. The fixed-depth all-width mean-field proof likewise has rapidly growing intermediate budgets, including $O_L(dK^{4\cdot3^{L-2}-1})$. The unrestricted critical-depth results in Question 17 use a different finite-representation argument; their polynomials are also not optimized. Neither the robustness improvements nor the shallow theorem establishes a small joint polynomial for arbitrary unrestricted deep teachers.

**Is quadratic the right target?** It is a useful dense-parameter benchmark, but not a universal lower bound. Bounded-fan-in Boolean circuits can have descriptions of order $LC\log(C+d)$ rather than $LC^2$ real parameters. A generic circuit-code prior can turn that description length into an Occam bound. Obtaining comparably sharp behavior for these Gaussian neural priors remains open, as does predicting useful numerical sample counts from the present estimates.

## 20. Do independent non-Gaussian weight priors give the same results?

**Yes, for a substantial family of independent coordinate laws.** The [non-Gaussian paper](side-results/non-gaussian-priors/paper.pdf) proves the analogues of main results 1, 2, and 3 for tanh networks when each standardized weight has an even, variance-one density

$$
q(u)=Z^{-1}e^{-V(u)},\qquad V\in C^2,\qquad
0<m\le V''(u)\le M<\infty.
$$

The constants $m,M$ are fixed independently of width. This says that the negative log density has positive curvature bounded above and below; it need not be quadratic. For example, take the variance-standardized version of the density proportional to $e^{-u^2/2-b\log\cosh u}$, for any fixed $b>0$.

The conclusions retain the original layer scales, global margin conditioning, exact noiseless-label posterior, arbitrary common training/test distribution, and **every learner width $`N\ge C_L(f)`$**. At each fixed depth, the sample bound is polynomial in dimension and target complexity, independently of learner width. This covers both the strong-prior limit at each fixed width and the finite-scale regimes $\gamma>1$ and $\gamma=1$. Correct-label posterior probability exceeds $2/3$ on almost all test inputs, including when the posterior mixes different functions. No added restriction on which network functions the prior supports is needed.

The proof replaces Gaussian target-mass calculations with a translation bound and concentration for the stated coordinate laws. At $\gamma=1$, a quantitative replacement argument compares **log partition functions for bounded covariance tests**, with only polynomial losses in the test budget. Auxiliary Gaussian distributions help construct short descriptions of likely functions; the learner itself keeps its non-Gaussian weights. The paper also proves polynomial comparison between bounded-weight circuit complexity and normalized negative log function prior mass.

**The strong-prior result permits more general laws.** Two-sided quadratic density envelopes suffice, without symmetry or log-concavity. If the negative log density is asymptotic to a common quadratic coefficient times $u^2$, the original weighted-energy ordering of function probabilities holds exactly at exponential-rate level. Curvature bounds alone give the learning guarantee and polynomial comparisons, but need not give a limiting exact rate.

These are conventional proofs with [independent AI-agent review records](side-results/non-gaussian-priors/verification/README.md); the extension is a side result and **has not been Lean verified**. The sample polynomials may depend on the coordinate law and depth. The theorem does not cover Laplace, uniform, Student, or pure quartic-exponential coordinates at the original scales. For a compactly supported law, taking the scale to zero at fixed width can even make the global-margin conditioning event empty. Broader families, alternative width normalizations, and non-Gaussian subcritical learning remain open.

## 21. What about ReLU, sigmoid, GELU, or other activations?

**The positive learning theorem extends to every fixed globally Lipschitz activation that vanishes at zero, including ReLU, exact GELU, SiLU, and tanh.** The [unified activation paper](works-in-progress/unbounded-activations/paper.pdf) proves a polynomial sample bound at fixed depth, independent of learner width, throughout the mean-field-or-stronger Gaussian regime. No additional robustness restriction is needed for this fixed-depth result.

More precisely, use independent Gaussian variances

$$
\frac{t^2}{d},\qquad \frac{t^2}{N},\qquad \frac{t^2}{N^2}
$$

in the first layer, internal layers, and linear readout, respectively, with $0<t\le1$. The prior retains the original absolute output margin greater than $1/2$ at every Boolean input, and training conditions on exact labels. A target with an implementing network of depth $L$, width $C$, weights bounded by $C$, and signed output margin strictly greater than $1/2$ at every input can be learned from

$$
n\ge\frac{p_{L,\lambda}(d,C,\log(1/\varepsilon))+O(\log(1/\delta))}{\varepsilon}
$$

examples, where $\lambda$ bounds the activation's Lipschitz constant. One sample event works simultaneously for every $N\ge C$ and every $0<t\le1$. Taking $t=N^{(1-\gamma)/2}$ covers **all $\gamma\ge1$, including deep mean field**, with one polynomial that does not deteriorate as $\gamma$ approaches one. The bound controls posterior average sign error; a factor of three in accuracy gives the usual strict `>2/3` confidence guarantee. The polynomial is large and its degree depends on depth.

**What replaces bounded hidden activations?** First, a product-of-layer-norm capacity bound works even for an auxiliary class with different Lipschitz activations at different neurons. Second, the mean-field proof separates each Gaussian layer into a bounded part and a controlled collection of large contributions. Gaussian concentration bounds the total cost of those contributions, and they can be represented by a small auxiliary network. Simply discarding large neurons would miss events that matter after conditioning on the target. At smaller variances, spectral truncation supplies a simpler argument. Combining these estimates gives the uniform scale bound.

The auxiliary networks are used to count possible sign functions. For an arbitrary activation, this step is **not** a claim that the reconstructed network uses that same activation, or a converse comparing its smallest fixed-activation implementation with prior probability. The Bayesian learner itself always uses the original fixed activation.

**Ordinary Boolean circuits are covered for ReLU and GELU.** Layered NOR/COPY/NOT circuits have exact ReLU implementations. An exact two-neuron GELU identity implements each gate without adding hidden layers, with weights bounded by four; constant wires and compilation overhead must be counted. Thus these results apply to small Boolean circuits, not only to an assumed analog teacher. The [earlier ReLU paper](works-in-progress/relu-learning/) retains a simpler proof and sharper explicit strong-prior estimates using positive homogeneity.

**Our polynomial-depth theorem uses a separate condition.** The [ReLU/GELU neuron-merging paper](works-in-progress/relu-gelu-polynomial-depth/) gives quadratic teacher-width dependence up to logarithms and polynomial depth dependence for every $\gamma\ge1$. Its prior keeps networks whose clipped predictions survive averaging neurons into suitably few populations. Every eligible Boolean circuit has a positive-mass implementation satisfying this condition. It is not proved equivalent to the original internal-noise restriction or typical of gradient-trained networks. See [Question 19](#19-what-are-the-actual-polynomials-are-practical-sample-bounds-close) for the explicit polynomial.

The $\gamma<1$ lower bounds and the tanh-specific unrestricted-depth constructions require separate analysis for these activations. A centered bounded sigmoid is covered by the positive theorem; an activation with a nonzero value at zero is outside it as stated. Hard thresholds fail its Lipschitz assumption. Universal approximation alone supplies neither the quantitative teacher complexity nor the required learning bound. These new activation results have independent AI-agent mathematical reviews and reproducible PDFs; **they are not Lean verified**.

## 22. Can we bound the prior probability of a function?

**Yes. In particular, the strong-prior argument establishes a prior-complexity comparison, not only a learning guarantee.** It identifies the fixed-width rate

$$
2\sigma^2\log\mu_{N,\sigma}(U_f)\longrightarrow-\kappa_N(f).
$$

Here $\kappa_N(f)$ is the infimum weighted squared parameter norm over networks realizing $f$ with the prescribed margin. For the globally margin-conditioned function prior $\pi_{N,\sigma}$, the common normalization cancels in ratios, so at fixed $d,L,N$, for functions $f,g$ realizable at width $N$ with the prescribed margin,

$$
\lim_{\sigma\downarrow0}2\sigma^2
\log\frac{\pi_{N,\sigma}(g)}{\pi_{N,\sigma}(f)}
=\kappa_N(f)-\kappa_N(g).
$$

Thus if $\kappa_N(g)>\kappa_N(f)$, the prior ratio $\pi_{N,\sigma}(g)/\pi_{N,\sigma}(f)$ tends to zero. Cloning and compression give the two directions of the complexity comparison: for fixed depth $L$, there are polynomials $P_L,M_L$, independent of learner width, such that for every $N\ge C_L(f)$,

$$
\kappa_N(f)\le P_L(d,C_L(f)),
\qquad
C_L(f)\le M_L(d,1+\kappa_N(f)).
$$

In the paper, $M_L(d,K)$ can be taken to be the compression width $m_L(d,\max\lbrace K,2\rbrace)$; this differs from the log-count $Q_L$ of Question 19. This is the slides' circuit-prior claim in a quantitative form: prior preference is governed by a complexity measure polynomially equivalent to small-network complexity. It need not preserve the ordering of two functions with similar circuit sizes. Counting the functions whose energy is no greater than the target's then gives the strong-prior generalization theorem. See the Gaussian-rate lemma and the “Uniform count and complexity comparison” proposition in the [strong-prior paper](main-results/strong-prior-generalization/paper.pdf).

The main Lean gate certifies the learning theorem and the ingredients used in its proof; it does not separately assert this displayed two-sided complexity comparison as an additional main theorem. The [coverage inventory](lean/review/formal-coverage-inventory.txt) distinguishes these scopes.

Finite-variance target-neighborhood constructions give lower bounds of the form

$$
\mu_{N,t}(\text{a target-realizing neighborhood})
\ge\exp[-(N/t^2)\,\mathrm{poly}(\text{target resources})].
$$

The critical paper gives a variational characterization and depth bounds for the corresponding rate. These answer parts of the slides' absolute prior-mass question. Absolute negative log probabilities can still grow with width or prior strength, consistently with the normalized rate comparison above.

This does not contradict width-independent learning. The generalization argument controls competitors relative to the target, or compresses a posterior with controlled relative entropy. It need not pay the full raw $-\log\mu(U_f)$ as a sample bound. The globally conditioned function prior also includes a normalization denominator that must be retained for absolute probabilities and comparisons across different priors; it cancels when comparing two functions under the same prior, as above.

Conversely, a tiny target probability alone is not a sample lower bound. A prior can assign a target tiny mass while assigning almost all remaining mass to a single competitor that one informative example eliminates. Both this mistake and the omission of the global-conditioning denominator occurred in heuristic arguments discussed in the [appendix audit](side-results/strong-prior-appendix-audit/paper.pdf).

## 23. Which original open problems have been resolved, and which remain?

| Original direction | Current status |
|---|---|
| Improve the polynomial | **Partly resolved.** [Question 19](#19-what-are-the-actual-polynomials-are-practical-sample-bounds-close) gives sextic width dependence under the original robust restriction at every gamma >= 1, a quartic stronger-scale bound, and quadratic bounds with additional assumptions. Quadratic dependence for the original robust prior and near-description-length guarantees remain open. |
| Remove bad depth dependence | **Partly resolved.** Joint polynomial depth under the robust support restriction; unrestricted positive results for substantial Boolean classes. The general Boolean case remains open. Continuous-output regression has an exponential-depth lower bound without a robustness restriction. |
| Lower-bound log prior mass | **Partly resolved.** The strong-prior rate is polynomially equivalent to bounded-weight network complexity; finite-variance target-mass bounds also exist. Sharp absolute-mass formulas remain open. |
| Classify scaling regimes | **Partly resolved on a particular one-parameter line.** The three positive learning regimes also extend to the non-Gaussian family in [question 20](#20-do-independent-non-gaussian-weight-priors-give-the-same-results). General exponent tuples, mixed regimes, and non-Gaussian subcritical behavior remain open. |
| Out-of-distribution learning | **Heuristic.** Mistakes by the simplest consistent hypothesis may often eliminate many surviving low-complexity competitors, even as the input distribution changes. The [conditional online argument below](#why-expect-occam-learning-to-transfer-out-of-distribution) makes this expectation precise; its genericity premise remains unproved. |
| Online mistake bounds | **Proved for uniform random Boolean inputs.** All three positive NNBayes regimes have polynomial expected and high-probability total mistake bounds, independent of learner width. Circuit-induction converses are proved for specified rules; the original fixed-width neural polynomial converse and arbitrary-order Gaussian guarantees remain open. See [the cumulative-mistake discussion](#can-we-bound-total-mistakes-and-recover-circuit-complexity-from-them). |
| Other architectures | **Open here.** CNN weight sharing, recurrence, attention, normalization, and residual structure need their own prior and complexity accounting. |
| Gradient descent | **Open as a learning theorem.** The robustness experiments concern a sufficient stability property, not equivalence between SGD and the exact Bayesian posterior. The [targets-beyond-parity question](#for-gamma1-is-the-bad-sample-complexity-specific-to-parity) adds Adam runs on a target that the $\gamma<1$ learners provably need exponentially many samples for (numerical, $d\le35$). |

The [appendix audit](side-results/strong-prior-appendix-audit/paper.pdf) checks every original appendix in turn. In particular, the original depth example is a capacity/proof obstruction rather than a sample lower bound; the scaling classification is not exhaustive; the kernel-to-classification inference needed repair; and some online-learning claims were false under their stated conventions. These qualifications are part of the current account, not claims silently inherited from the slides.

### Can we bound total mistakes and recover circuit complexity from them?

**The total-mistake upper bound holds for all three original positive NNBayes regimes under uniform random Boolean inputs. Circuit converses also hold for specified induction rules; the original fixed-width neural polynomial converse remains open.** The [papers and neural note](works-in-progress/online-mistakes/) give the precise statements and proofs. They have independent AI-agent mathematical reviews, not Lean formalizations.

At each round the learner sees an input, predicts, and then receives its true label, even after a correct prediction. Exact conditioning makes every later repetition of that input correct. An infinite uniform iid stream therefore has the same total-mistake law as a uniformly random permutation of the cube. This is a cumulative guarantee over the whole learning process, rather than a bound on error after some fixed sample size.

If a fixed relevant function class has log cardinality at most $h$, and posterior mass outside it is at most $\beta$ after every history, the expected total posterior-sampling mistakes are at most

$$
1+2(h+1)H_{2^d-1}+2^d\beta,
$$

where $H_r$ is the harmonic sum. Take $\beta=2^{-d}$. The existing exact-function compression theorems pay only polynomially for $\log(1/\beta)$, giving $O(d(h+1))$ expected mistakes. The smaller-width branches use the direct Bayesian log-prior bound. High-probability bounds also hold, with polynomial dependence on $\log(1/\delta)$. The constants are independent of learner width; the strong-prior variance threshold is still chosen separately at each width, and one sufficiently small variance works for the entire stream. These cumulative high-probability statements concern each fixed learner with width-independent constants, not one event simultaneously controlling every learner width.

This argument permits mixtures of tied minimizers. Counting a failure whenever the correct label has probability at most $\theta<1$ costs a factor of at most $1/(1-\theta)$ relative to cumulative posterior error; majority errors cost at most two. Thus it covers the usual strict `>2/3` convention. The neuron-merging restrictions also retain joint polynomial depth dependence for layered Boolean-circuit teachers, counting constant wires and compilation overhead. The weaker internal-noise condition's current approximate compressor does not yet establish that polynomial-depth cumulative extension. The general finite-class argument also applies to the [unified Lipschitz-activation theorem](works-in-progress/unbounded-activations/), including deep ReLU and GELU at every $\gamma\ge1$: its exceptional-mass budget is polynomial in $\log(1/\beta)$, as required here.

**Input order matters for this proof.** On a nonuniform finite support, an expected bound depends on $\log(1/p_{\min})$, where $p_{\min}$ is the smallest positive input probability. It remains polynomial when that logarithm does. A finite class with very unequal prior weights can make many mistakes under an adverse order, or a sufficiently nonuniform iid distribution. This refutes an arbitrary-order inference from class cardinality alone, not the desired claim for the specific Gaussian priors. Arbitrary-order Gaussian guarantees still need another argument, such as a suitable version of the genericity premise below.

**The circuit converses can be made precise.** Here $C(f)$ counts NAND gates, with unrestricted depth, and the full input domain must eventually be revealed.

- A learner that always predicts with a smallest consistent circuit satisfies $C(f)\le(3d+3)B$, where $B$ is its actual total mistake count. A correct prediction leaves minimum consistent size unchanged; a mistake can be repaired with at most $3d+3$ extra gates.
- For Bayesian posterior sampling, use a geometric distribution on gate count and uniformly random wiring conditional on that count. Expected total mistakes $m$ imply $C(f)=O(dm\log(d+dm))$. The same prior has an upper bound $O(C(f)\log(d+C(f))+1)$ for any input order.
- An explicit prefix circuit language with a short exception constructor improves the converse to $O(dm+1)$. Its prior has an additional length penalty that supplies the needed exponential description-length tail.

Injectivity of repairs and their probability cost matter: a prior that merely favors small circuits is not enough. These Bayesian converses are for posterior sampling, not a proved converse for posterior majority. For an infinite iid stream, any full-support input distribution suffices for the converse; without full support the conclusion concerns a small circuit agreeing with the target on that support. An arbitrary learner or prior can hard-code a complex target and make no mistakes.

**For neural minimum-energy learning, there is a partial converse.** Here $m$ may be expected total mistakes, and $C_L(f)$ is bounded-weight depth-$L$ neural-network width, rather than the NAND gate count above. In the limit that first takes prior variance to zero at fixed width and then lets width grow, an exact tanh singleton repair gives

$$
C_L(f)\le\mathrm{poly}_L(d)\exp(O_L(m)).
$$

Adding the prior restriction $1/2<|z_w(x)|<U$ on every input, for fixed $U>1$, improves this to a polynomial in $d,U,m$ at fixed depth. These statements cover sampling, majority, and confidence mistakes, including ties.

**A stronger restricted-prior converse has polynomial depth dependence.** The [controlled-amplification paper](works-in-progress/online-mistakes/depth-polynomial-converse/) adds a certificate bounding how finite internal disturbances reach the output. Requiring all internal matrices to have operator norm less than one is sufficient; the certificate also allows some expansions compensated by later layers. With fixed cap $U$ and certificate parameter $\Lambda>1$, put

$$
K=1+P(d,L,U)(m+1)^2,
\qquad P=O\!\left(d^3\log^2(2+d)+L(U+1)^2\right).
$$

The target then has a network of the same depth, with width and individual weights bounded by

$$
\left\lceil65536\Lambda^2K\bigl[1+(L-1)K\bigr]
\bigl[d+\log(400L)\bigr]\right\rceil.
$$

Thus the leading mistake dependence is fourth power, and no exponent grows with depth. An exact singleton correction increases the square root of minimum energy by only a polynomial-depth additive cost. Every increase in minimum compatible energy forces a mistake, even with tied minimizers; a deterministic compressor gives the small network.

This theorem still takes the strong-prior limit before the width limit and requires complete input coverage. It does not prove the converse at every fixed realizable width, remove the output cap, or show that every small deep Boolean circuit has a cheap implementation satisfying the stronger certificate. Those remain separate questions. The reconstructed small network need not satisfy the prior restriction. The new converse is independently AI-reviewed, not Lean verified.

### Why expect Occam learning to transfer out of distribution?

**Heuristic: when the simplest surviving explanation is wrong, its mistake often rules out many other surviving explanations.** The physicist's argument is that the simplest hypothesis still consistent with the observations is not too atypical of the remaining hypotheses simpler than the target. When it makes a mistake, a substantial fraction of those hypotheses should often make the same mistake. Revealing the correct label then eliminates them together. There can only be logarithmically many substantial reductions of a finite candidate pool.

Here is a conditional counting argument. Suppose the target $f$ has a description of length $b$ bits. Let $V_t$ contain all descriptions of length at most $b$ still consistent with the labels observed before round $t$, and predict with a shortest consistent description. Include descriptions of the same length as the target so that ties are covered. The target's description always survives. Write $M_0=|V_0|$; for binary descriptions, $M_0<2^{b+1}$.

Suppose that among the first $m$ mistakes, at least $\beta m$ of them each eliminate at least an $\alpha$ fraction of the **current survivors**. Then

$$
1\le |V_{\mathrm{after}}|\le M_0(1-\alpha)^{\beta m},
\qquad
m\le\frac{\log M_0}{\beta\log(1/(1-\alpha))}
\le\frac{\log M_0}{\alpha\beta}.
$$

For example, the 10%/10% condition gives fewer than $66(b+1)$ mistakes. If this condition continues to hold as the sequence grows, it bounds the total number of mistakes. A circuit over a fixed finite gate basis has description length polynomial in its width, depth, and input dimension, so this gives the desired polynomial bound **conditional on the genericity premise**. Counting wrong hypotheses in the original pool would not suffice: they may already have been ruled out.

One probabilistic formulation makes the intended typicality explicit. Let $Z_t$ indicate that the simplest survivor is wrong, and let $q_t$ be the fraction of current survivors wrong on that same input. The condition

$$
\mathbb E[q_t\mid Z_t=1,\text{past observations}]\ge c>0
$$

says that, conditional on a mistake by the simplest survivor, a uniformly sampled surviving description also has a nonnegligible chance of being wrong. It implies an expected total mistake bound of $\log M_0/c$: revealing a label decreases $\log|V_t|$ by $-\log(1-q_t)\ge q_t$, and the total available decrease is at most $\log M_0$. This is a precise version of the heuristic that the simplest predictor's errors are not usually exceptional among the other low-complexity candidates. Approximate independence of the two error events would suffice if the comparison candidate's error probability were also bounded below; independence alone does not supply that lower bound.

The counting step needs no iid assumption. It allows inputs from changing or previously unseen regions, provided the genericity premise continues to hold and the true label is revealed after each prediction. This is why the argument is relevant to OOD learning. It gives an **online mistake bound with feedback**, rather than a guarantee for a predictor trained once and then tested without further labels under an arbitrary shift.

The heuristic part is whether this genericity premise holds for relevant tasks, representations, and input sequences. A sequence can instead expose errors peculiar to the current simplest hypothesis, eliminating very few other candidates at each mistake. Establishing that such behavior is atypical, and transferring the argument from a simplest-consistent description to the actual NNBayes posterior, remain open. The present iid theorems do not establish those claims.

## 24. Do the good generalization results survive a small amount of label noise?

**Yes, when the noise rate is sufficiently small relative to dimension, depth, and target complexity.** The tolerance is inverse-polynomial with large explicit constants: the coefficient of the corrupted fraction exceeds $10^6$ times a polynomial in $d$, so as stated the bound is informative only when the corrupted fraction is below about $10^{-6}$ divided by a polynomial in $d$. Since there are only $2^d$ distinct inputs, a single corruption already makes it vacuous unless $2^d$ exceeds that coefficient (about $d\ge44$ even for $U=1$). The constants were not optimized. The [noisy-interpolation theorem](works-in-progress/noisy-interpolation/README.md) gives a clean-error bound for fixed-depth tanh networks that fit every training label, including flipped labels. Its proof has undergone independent AI-agent mathematical checks; it is a supporting result, not a Lean-verified main result.

The sampling convention matters: choose $n$ distinct points uniformly from the Boolean cube, flip each label independently with probability $\eta$, and evaluate against the underlying clean function. Keep the original Gaussian prior, its all-input margin restriction, and exact conditioning on the observed labels. Thus the clean target itself is excluded when any label flips; the proof constructs a different, inexpensive network that fits all the corruptions.

Suppose the clean target has an implementation of depth $L$ and width $C$ with weights bounded by $C$, margin above $1/2$, and output magnitude at most $U\ge1$. At every sufficiently large learner width $N$, the strong-prior limit satisfies a bound of the form

$$
\limsup_{\sigma\downarrow0}R_{\mathrm{clean}}(N,\sigma)
\le P(d,L,U)\eta+
\frac{B_L(d,C,U)+P(d,L,U)\log(2/\delta)}{n}
\quad\text{with probability at least }1-\delta.
$$

Here $R_{\mathrm{clean}}$ is posterior average error against the clean function on the full cube. The function $P$ is a polynomial jointly in its arguments; $B_L$ is polynomial in $d,C,U$ at each fixed depth, with potentially bad depth dependence. Constants are absorbed into these two functions. Every bounded-weight target has $U\le C^2$, so this covers the original target class. A layered Boolean circuit can instead be implemented with $U=1$, counting constant wires and compilation overhead: **for these targets the coefficient of the noise rate is independent of circuit width**, although the sample overhead still depends on it.

The learner width must be large enough to accommodate the corruptions: a sufficient threshold is a constant times $C$, plus a polynomial in $d,U$ times $\eta n+\log(2/\delta)+1$. The theorem holds at **every** width above that threshold, with prior variance tending to zero separately at each fixed width. It does not retain the noiseless condition $N\ge C_L(f)$ alone; a network just large enough for the clean target may be unable to interpolate the noisy labels. The proof controls all minimum-energy consistent functions, so mixtures of tied minimizers cause no gap.

The stronger statement proved in the note allows **any** $s$ corrupted labels, even chosen after seeing the sample, and bounds clean error by

$$
\frac{B_L(d,C,U)+P(d,L,U)s+8\log(1/\delta)}{n}.
$$

The allowed number of corruptions can be proportional to $n$. For accuracy $\varepsilon$, it gives polynomial sample complexity at fixed depth when $\eta$ is smaller than $\varepsilon$ divided by a resource polynomial. To measure error on unseen inputs, multiply the whole-cube bound by at most $2^d/(2^d-n)$; this is at most two when $n\le2^{d-1}$. Failure to assign the correct label probability strictly above $q<1$ costs a further factor $1/(1-q)$, hence three for the usual $2/3$ criterion.

**What remains open:** can we replace the resource-dependent noise term by $\rho(\eta)$, where $\rho(\eta)\to0$ as $\eta\to0$ independently of input dimension and target complexity, after paying a polynomial sample overhead? The proved bound can become vacuous at a fixed numerical noise rate as dimension grows. It does not establish such a dimension-independent guarantee or arbitrarily accurate clean recovery at a fixed positive noise rate.

The Occam argument compares the learner with the clean implementation **plus a correction that fits the flips**. Polynomial equivalence between circuit complexity and neural prior complexity alone does not control the cost of this correction sharply enough: raising a cost proportional to $s\simeq\eta n$ to a power greater than one can destroy the sample bound. The proof matches two exponents. With $H=L-1$ hidden layers, the correction has energy at most $K_0+K_1(s+1)^{1/H}$, and the logarithm of the number of globally separated functions of energy at most $K$ grows at most like a resource factor times $(K+1)^H$. Their combination gives the required bound linear in $s$.

There is a precise limitation to improving this particular counting argument. Our common energy budget contains the target with **every possible set of $s$ cube labels flipped**, so its function class has at least $\binom{2^d}{s}$ members. Its log-cardinality is therefore at least $s\log(2^d/s)$, which carries a dimension factor when $s$ is polynomial in $d$. This is a limitation of using that entire class in one union bound, not evidence that the learner itself generalizes badly.

One promising next step is to make the correction cheaper by allowing it to change some unseen labels. Approximate-membership constructions used in circuit learning trade a controlled amount of off-sample error for a shorter description. Obtaining a corresponding sharp neural-energy bound could help; alternatively, a more selective counting argument might avoid paying for all those almost-correct functions. Neither improvement has yet been proved for this posterior.

These conclusions are specific to the stated sampling and interpolation conventions. Repeated inputs with contradictory labels would make exact conditioning impossible. If we instead allow training errors, ordinary finite-class noisy-error minimization has standard clean-learning guarantees, but that is a different learner. Replacing exact fit by a positive noisy likelihood also needs care in the **strong-prior-first limit**: its likelihood ratios are at most $((1-\eta)/\eta)^n$, whereas a fixed prior-energy gap contributes $\exp[-\Delta\kappa/(2\sigma^2)]$. At fixed $n$, the prior gap wins as $\sigma\to0$. The noisy-interpolation theorem uses the exact-fit likelihood throughout.

## Do the polynomial bounds survive the likelihood-based setup used in singular learning theory?

**Yes, for a Gaussian likelihood scaled together with the prior: we get polynomial sample bounds in the strong-prior and all finite-exponent regimes $\gamma\ge1$. Simply substituting a fixed Gaussian or logistic likelihood does not preserve the main results.** The balance between likelihood strength and prior strength matters. This is a statement about the learner itself, independent of which generalization bound one uses to analyze it. The [supporting proof note](works-in-progress/slt-likelihood/README.md) gives positive variants and counterexamples; these are conventional arguments with independent AI-agent checks, not Lean-verified main results.

Singular learning theory (SLT) studies a broad class of statistical models, rather than specifying one neural-network prior. Its usual Bayesian setup is

$$
Q_{\beta,S}(dw)\ \propto\ \pi(dw)\prod_{i=1}^n p_w(Y_i\mid X_i)^\beta.
$$

Here $\beta=1$ is ordinary Bayes; other temperatures give a power posterior. For example, Gaussian regression uses a likelihood proportional to $\exp[-(y-z_w(x))^2/(2s^2)]$, and binary logistic classification uses $(1+e^{-yz_w(x)})^{-1}$. These give positive weight to imperfect fits. Our main papers instead impose hard training constraints, assigning zero likelihood to violations. See [Watanabe's definition of the posterior and predictive distribution](https://jmlr.org/papers/volume11/watanabe10a/watanabe10a.pdf), equations (1)–(2). Nothing about that definition fixes how network width, weight variance, observation variance, and sample size should scale together.

**Why a fixed smooth likelihood can fail with our shrinking priors.** Under the raw Gaussian prior in our finite-exponent models, the bounded hidden activations and readout variance give

$$
\mathbb E[z_w(x)^2]\le N^{-\gamma}.
$$

For every $\gamma>0$, all scores at a fixed finite set of inputs therefore approach zero as width grows. At a fixed sample size and temperature, the Gaussian or logistic likelihood approaches a positive constant under this prior. Reweighting by it barely changes the prior: the posterior approaches the prior in total variation. Consequently latent-sign confidence approaches $1/2$, and logistic posterior-predictive confidence does too, **even for the constant target**. This rules out our width-independent confidence guarantee for the raw prior with that likelihood. The same argument applies at fixed width as the prior variance tends to zero. It does not prove failure of the sign of the posterior mean: a vanishingly small positive bias could still have the right sign.

Keeping the original global-margin restriction also does not automatically rescue the strong-prior theorem. There is an explicit two-bit XOR counterexample: at depth two and every fixed width $N\ge3$, the least-energy globally margined functions are constants and signed coordinates. Each has error $1/2$ against XOR. A fixed positive Gaussian or logistic likelihood cannot overcome their strict prior-energy advantage as the prior variance tends to zero, for any fixed finite training sample. Mixtures still have Gibbs error $1/2$. XOR itself has an exact width-three, bounded-weight real-output implementation, so lack of representation is not the issue. This example takes the **strong-prior limit after choosing the sample size**; it does not say that more data cannot eventually overcome a fixed prior.

**A positive result with an ordinary Gaussian likelihood.** Let the prior density be proportional to $\exp[-\kappa_N(w)/(2\sigma^2)]$, and choose Gaussian observation variance $\sigma^2$ as well. For clean observations $Y_i=f(X_i)$, ordinary Bayes then gives

$$
Q_{\sigma,S}(dw)\ \propto
\exp\left[-\frac{\kappa_N(w)+\sum_{i=1}^n(z_w(X_i)-f(X_i))^2}{2\sigma^2}\right]dw.
$$

At every fixed depth, this learner has a sample bound polynomial in input dimension, teacher width, teacher weight bound, inverse accuracy, inverse output tolerance, and log inverse failure probability, **independent of every learner width above teacher width**. With high probability over training data, the posterior assigns probability above $2/3$ to $|z_w(x)-f(x)|\le\tau$ outside a test set of probability at most $\varepsilon$. Inputs can have any distribution on a compact subset of the unit ball, or the coordinate cube. No global-margin conditioning is needed. There are two versions:

- **Strong-prior limit:** choose a sufficient sample size and a finite learner width, then take $\sigma\to0$. The required small variance may depend on both; this version alone supplies no uniform positive variance threshold over all widths.
- **Finite exponents:** for every fixed $\gamma\ge1$, use our finite-exponent weight prior and Gaussian observation variance $N^{-\gamma}$. A separate argument gives the polynomial bound at **every $`N\ge C`$**, with no limit required. The polynomial may depend on fixed depth and fixed $\gamma$; the mean-field endpoint $\gamma=1$ is included.

Both versions observe clean labels from the teacher. They do not assert the same bound for data corrupted by fixed positive observation noise.

For the strong-prior version, a replicated teacher has bounded energy independent of learner width, so the posterior concentrates on networks whose **energy plus total squared training error** is bounded by the teacher's energy. Our compression argument covers all such bounded-energy networks with a finite collection of size independent of learner width. A sampling bound then rules out appreciable test error. The finite-exponent proof instead combines the existing teacher-neighborhood mass estimates and covers of most prior outputs with a bound on posterior training loss; it does not assume that typical mean-field networks have bounded total energy. The [note](works-in-progress/slt-likelihood/README.md) spells out both arguments. A Boolean sign teacher gives positive variants of both Gaussian results after adding one tanh layer to approximate its labels; a logistic analogue works when its inverse temperature grows together with prior strength. These are explicit changes of scale, not a claim about the unchanged fixed-likelihood model.

**What about the usual fixed-likelihood setup?** At fixed architecture and fixed prior, standard prior-mass arguments do give sample upper bounds. They pay for the negative log prior mass of a small neighborhood of the teacher. Our available neighborhood estimate grows like $N^\gamma$ in the finite-exponent models with fixed $\gamma\ge1$, yielding polynomial bounds when learner width is itself polynomially bounded by teacher resources, but not the arbitrary-width guarantee of the main papers. A different prior with a sufficiently strong, quantitative circuit-description mass bound could give better results. Calling a model “SLT” alone supplies neither that prior-mass bound nor an all-width learning theorem.

**Still open here:** a complete smooth-likelihood theorem with joint polynomial dependence on depth under our robustness restriction. The regularized-loss argument makes this a reasonable target, but we have not checked the required prior mass and cover estimates within that restricted support. The unrestricted polynomial-depth problem is also not settled. Without rescaling the likelihood, the counterexamples above already prevent a blanket transfer of the main guarantees.

Finally, prediction conventions must match. Logistic posterior-predictive confidence is $\mathbb E_Q[(1+e^{-yz_w(x)})^{-1}]$, whereas our classification papers use $Q(yz_w(x)>0)$. A score margin of $1/2$ gives only about $0.622$ logistic label probability, even if the parameters are known exactly. A $2/3$ predictive guarantee therefore needs a suitable link scale or a larger score margin. The Gaussian result above controls proximity of the latent output to the clean teacher; a future noisy observation is a separate random quantity.

## Does SLT already give comparable generalization bounds?

**The usual SLT asymptotic formulas do not give our finite-sample learning guarantees, and finite-sample generalization has not been reduced to the learning coefficient and other local asymptotic quantities.** Prior scale and the amount of prior mass near good predictors can dominate learning at the sample sizes of interest, even when the leading coefficients are known exactly. Finite-sample Bayesian bounds can nevertheless exploit a small teacher inside a much larger learner. The question is how their full constants depend on teacher resources, learner width, and prior scaling.

**What the asymptotic formulas establish.** Under the appropriate realizability and regularity assumptions, ordinary Bayes at a fixed model and prior satisfies

$$
\mathbb E[B_n]-L_0=\frac{\lambda}{n}+o(1/n),
\qquad
\mathbb E[G_n]-L_0=\frac{\lambda+\nu}{n}+o(1/n).
$$

Here $B_n$ is posterior-predictive test log loss, $G_n$ averages test log loss over individual posterior draws, and the expectations include the training sample. The baseline $L_0$ is optimal log loss; $\lambda$ is the learning coefficient and $\nu$ the singular fluctuation at inverse temperature one. See [Watanabe's equations of states](https://arxiv.org/abs/0712.0653), Corollary 3. These are leading large-sample expansions. They give neither a numerical error bound at a specified sample size nor uniform control as architecture and prior scale vary.

[Daniel Murfet's comment](https://www.lesswrong.com/posts/ALJYj4PpkqyseL7kZ/my-criticism-of-singular-learning-theory?commentId=KYT7aPu5LhktFQ6LR) describes a reduction of generalization questions to understanding $L_0,\lambda,\nu$. Read as a claim about **finite-sample overparameterized generalization**, that reduction has not been supplied and those quantities are insufficient. Read as a claim about the **leading fixed-model asymptotic term**, it is correct and mathematically substantive. His full comment acknowledges asymptotic applicability and the separate gap between Bayesian posteriors and SGD. Those qualifications do not supply the missing finite-sample theorem. A [local-posterior expansion](https://arxiv.org/abs/2308.12108v1) also does not show that the global posterior selects the neighborhood being analyzed.

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

**A finite-sample variational argument can improve on parameter counting.** The [supporting note](works-in-progress/slt-finite-sample/README.md) gives a direct calculation for tanh networks with the standard independent Gaussian fan-in prior: variance $1/(d+1)$ in the first layer and $1/N$ in subsequent layers, including the readout. The likelihood is Gaussian with fixed variance.

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

Consequently there are regimes where this certificate is useful with far fewer samples than parameters. It does **not** establish practical numerical sharpness, or a theorem uniform over arbitrarily large width at fixed sample size. These are explicit variational calculations, not consequences of $\lambda,\nu$ alone; the note has independent AI-agent mathematical checks but is not Lean verified.

**Which bounds are useful where?**

| Bound | What must be controlled | Relevant regime and limitation |
|---|---|---|
| Parameter-counting PAC bounds | Capacity of the whole learner class, with activation-dependent factors. | Often useful for a modest-size learner; typically uninformative when that capacity greatly exceeds sample size. |
| Standard SLT expansions | Local coefficients **and a justified asymptotic regime**. | Describe leading learning curves at fixed model and prior; do not alone certify finite-sample error. |
| Quantitative prior-mass or variational bounds | The full cost of a good neighborhood or comparison distribution. | Can work with many more parameters than samples; width and prior-scale costs must actually be calculated. |
| This collection's all-width NNBayes upper bounds | Teacher resources and the specified prior, likelihood, and limit conventions. | Polynomial teacher-complexity bounds at fixed depth, independent of arbitrarily larger learner width; generally unoptimized constants. |

Having fewer samples than parameters does not invalidate every classical bound. Norm, margin, compression, and PAC-Bayes bounds can use other complexity measures; for example, [spectral norm and margin bounds](https://arxiv.org/abs/1706.08498). Nor is a fixed finite Boolean domain a useful way to separate bounds indefinitely as width grows: its finite support supplies another capacity ceiling. The positive comparison above also permits continuous inputs.

## Can prior scaling obstruct a width-independent log-prior bound?

**Yes, for direct bounds based on the raw prior probability of accurately reproducing a prescribed real-valued function.** Such a bound pays a cost like $-\log\pi_N(G)$, where $G$ is a set of accurate predictors. A variational proof instead pays the relative entropy of an accurate comparison distribution. These costs can rule out a bound that is both independent of learner width and polynomial in teacher resources. The [supporting analysis](works-in-progress/slt-finite-sample/PRIOR-MASS-OBSTRUCTIONS.md) proves the following distinctions.

**Shrinking output scale forces a width cost.** If the prior output tends to zero, its probability of approximating a fixed nonzero value tends to zero. In our Gaussian finite-exponent priors, bounded hidden activations and readout variance $N^{-\gamma-1}$ give a particularly strong statement. For any input distribution, approximating the constant function $1$ within root-mean-square error $\rho<1$ has raw prior cost at least

$$
-\log\pi_N\big(\lVert z_w-1\rVert_{L^2}\le\rho\big)
\ge\frac{(1-\rho)^2}{2}N^\gamma.
$$

The same lower bound holds for the relative entropy of any comparison distribution whose expected squared prediction error is at most $\rho^2$. Thus allowing a broad comparison distribution does not remove this obstruction when $\gamma>0$.

**Growing output scale also costs probability when a bounded amplitude is required.** For a centered Gaussian output of standard deviation $s_N\to\infty$, hitting a fixed bounded interval has probability $O(1/s_N)$ and hence a cost at least $\log s_N-O(1)$. The interval probability also tends to zero for Gaussian readout mixtures when their conditional variance diverges in probability; a quantitative rate requires quantitative concentration. Diverging unconditional variance alone is insufficient: rare large outputs can inflate variance while most prior mass remains at a useful scale.

**An order-one Gaussian-process limit has a different obstruction: target complexity.** Suppose the raw function prior converges to a centered GP on the Boolean cube, with average output variance at most $V>0$, and that the limiting law is invariant under coordinate permutations. For every parity $\chi_S$ on $k$ coordinates and every $0<\rho<1$,

$$
-\log\Pr\big(\lVert F-\chi_S\rVert_{L^2}\le\rho\big)
\ge\frac{(1-\rho)^2}{2V}\binom dk,
$$

where $L^2$ uses the uniform input distribution. The proof is a Fourier variance budget: the total variance of all parity coefficients is $V$, and the $\binom dk$ coefficients of a given degree have equal variance. Approximating a parity requires its coefficient to be close to one. When $V$ is bounded or grows at most polynomially in $d$, taking $k$ near $d/2$ gives an exponential log-prior cost, although parity has a small circuit and can be approximated by a shallow tanh teacher with polynomially bounded resources. Without permutation symmetry, a related argument still finds at least one hard parity. These are bounds on raw good-function mass, not posterior sample-complexity lower bounds.

Output variance of order one **does not by itself imply a GP**. The Gaussian limit needs a separate argument about the architecture and coordinate laws. A structured mixture that first chooses a small circuit can have order-one output variance and a circuit prior. The supporting analysis proves a restricted classification for one hidden tanh layer with independent Gaussian weights and power-law variance scalings. For that family, direct raw-prior certificates incur either a width cost or a nonpolynomial teacher-complexity cost. It does not classify every deep architecture or scaling tuple.

The distinction from the main learning theorems is essential. Sign-only predictions are unchanged by positive output rescaling, and conditioning the prior on global margins changes the probabilities being compared. A common amplitude penalty can cancel between numerator and denominator. Our positive results use additional structure, including relative prior costs, posterior concentration, and compression. A diverging raw log-prior penalty therefore does not contradict those theorems or prove that the actual learner needs more samples. For the Gaussian families covered by these obstructions, a successful width-independent, teacher-polynomial proof must use information beyond a direct raw-mass certificate.

## 25. What other questions matter before interpreting this as an explanation of practical deep learning?

The largest missing links are:

- **Finite width in the negative regimes.** The exponential parity results take $N\to\infty$ at fixed dimension, depth, and sample. They do not provide a useful width threshold uniform in growing $d,k,n$. The positive all-width theorems have a stronger finite-width quantifier.
- **Orders of limits.** Fixing width and shrinking variance, taking width first at a specified scaling, and growing dimension and width together can give different answers. Theorems should specify which is being taken.
- **Computational cost.** Exact posterior conditioning and sampling may be intractable. Polynomial examples do not imply polynomial computation, and no theorem here identifies SGD's output law with that posterior.
- **Noisy or misspecified data.** The strong-prior exact-interpolation theorem has resource-dependent noise tolerance. The [label-noise discussion](#24-do-the-good-generalization-results-survive-a-small-amount-of-label-noise) explains its scope; dimension-independent fixed-noise tolerance and broader misspecification remain open.
- **Typical data and architectures.** Uniform parity is a useful separation, not a model of all natural data. [Which other targets are hard](#for-gamma1-is-the-bad-sample-complexity-specific-to-parity) for the subcritical learners is a separate question. Current empirical certificates do not establish a theorem for modern large-model training.
- **Prediction rules.** Gibbs draws, posterior majority, mean-score prediction, and confidence-threshold success are different losses. A statement about one should not be relabeled as a statement about another.
- **Selection of examples.** Passive iid sample lower bounds need not hold for active learning, teaching sets, or adversarially selected informative inputs. They are also usually stated for each specified sample size, not on one common event for every prefix of an infinite stream.

## 26. How much of this is formally verified?

The repository includes closed Lean formalizations of all five main learning statements, including the polynomial-depth generalization theorem under a robustness restriction; their exact theorem declarations, hypotheses, dependencies, and build instructions are the appropriate source for the machine-checked scope. A successful Lean build verifies the formal statements actually written, so alignment with the intended analytic network model is a separate review obligation.

The [verification record](lean/VERIFICATION.md) gives the exact-type gates, independent source rebuild, and axiom checks. The formal proof under the robustness restriction uses a looser Pinsker-and-energy construction; its exact learning statement does not include every optional posterior variant or sharp manuscript constant. The supporting depth manuscripts and the noisy-interpolation note have undergone independent AI-agent mathematical audits but remain outside the main Lean verification. An audited manuscript or exact numerical certificate is not thereby a Lean proof. The FAQ's heuristic extensions and open-problem assessments are not formalized theorems.

Readers should start with the main theorem and conventions in the relevant paper, then use this FAQ to identify the limitations and possible extensions. The [collection index](README.md) distinguishes main results, side results, and work in progress.
