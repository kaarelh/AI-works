# Technical FAQ: Bayesian neural-network generalization

This FAQ explains what the current results say, which assumptions matter, and where we expect extensions. It is intended for readers considering this research program, including readers of the original [Vaintrob–Hänni slides](https://kaarelh.github.io/ai/nnbayes-generalization.pdf). It is a research snapshot, not a claim that the open questions below have been resolved.

**Status labels:** **Proved** means that the linked manuscript contains a proof under its stated assumptions. **Extension suggested by the proof** means that we have identified a plausible adaptation but are not citing a completed theorem. **Heuristic** is an informed expectation. **Open** means that the available results do not settle the question. Machine verification is a separate issue; see the final question.

**Jump to:** [prediction thresholds](#5-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23) · [scaling tuples](#9-can-we-classify-all-tuples-of-layerwise-scaling-exponents) · [robustness and depth](#12-what-robustness-condition-gives-polynomial-depth-dependence) · [out-of-distribution learning](#why-expect-occam-learning-to-transfer-out-of-distribution) · [label noise](#24-do-the-good-generalization-results-survive-a-small-amount-of-label-noise) · [SLT likelihoods](#do-the-polynomial-bounds-survive-the-likelihood-based-setup-used-in-singular-learning-theory) · [formal verification](#26-how-much-of-this-is-formally-verified)

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

**The positive learning results extend to continuous inputs for real-valued regression.** The [continuous-domain paper](side-results/continuous-domains/paper.pdf) treats arbitrary input distributions on a compact subset of the unit ball, including the full sphere. A teacher has depth $L$, width $C$, and weights bounded by $B$. At each fixed depth, the sample bound is polynomial in $d,C,B$ and accuracy parameters, independently of **every learner width $N\ge C$**. This holds for the strong-prior limit and for each finite exponent $\gamma\ge1$, including mean field, with Gaussian weights or the non-Gaussian family in Question 20. The proof uses an input net; the learner and data remain continuous.

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

A small parity eigenvalue, or poor correlation of the regression mean, is therefore not by itself a lower bound for the posterior-confidence convention used here. This was a substantive gap in the original slides' kernel discussion. The later lower bounds analyze the appropriate conditioned law.

Nor does every Gaussian rate description identify an exact GP posterior: this distinction is important for $0<\gamma<1$, as explained in [Question 10](#10-does-a-quantitative-central-limit-theorem-make-all-0gamma1-into-gaussian-conditioning).

There is a separate [NNGP note](side-results/nngp-sample-complexity/paper.pdf) with an exponential confidence lower bound for a deep, variance-normalized tanh GP family. Its depth grows with the input dimension. It should not be silently substituted for the fixed-depth theorem for all $\gamma<1$.

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
| Fixed $\gamma>1$ | Polynomial samples at fixed depth for every actual $N\ge C_L(f)$. Unrestricted results also remove bad learner-depth dependence for substantial target classes. | The general bound’s polynomial degree depends on depth and on the gap above one. The full arbitrary-deep-target problem remains open. |
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

For bookkeeping outside that assumption, let typical *unconditioned* hidden activation variance scale as $N^{-b_s}$. For fixed-depth tanh networks the amplitude heuristic is

$$
b_1\approx\max\lbrace a_1,0\rbrace ,\qquad
b_s\approx\max\lbrace a_s+b_{s-1}-1,0\rbrace ,
$$

and output variance has scale $N^{1-a_L-b_{L-1}}$. A negative value before taking a maximum indicates diverging preactivations and saturation. This recursion helps locate possible linear or saturated layers; it does not determine what rare conditioning selects.

**Do we still expect just circuit learning versus exponential sample complexity?** Those remain useful broad possibilities, but I would not currently conjecture an exhaustive two-way classification of *all* tuples. In particular, a different prior mechanism need not imply a different sample-complexity outcome. Here are concrete predictions, with their status:

| Exponent tuples | Prediction and current status |
|---|---|
| $a_1\le0$, every internal $a_s\le1$, and $a_L<2$ | **Conjectured frozen-feature region.** Hidden activations remain order one, possibly saturated. With a nondegenerate limiting kernel and empirical-kernel deviations costing order $N$, forcing margins costs only $N^{a_L-1}=o(N)$ when $1<a_L<2$. Thus conditioning should leave the leading kernel fixed. Exponential parity sample bounds are plausible but still require a spectrum and posterior-confidence argument for these kernels. |
| Exact fan-in hidden scaling $(0,1,\ldots,1,a_L)$ with $a_L\ge2$ | **Conjectured circuit-learning side.** The endpoint $a_L=2$ is proved in our critical results. For $a_L>2$, changing features can be cheaper than forcing the output through fixed features; I expect positive learning results, but output-dominated saturation and subleading costs need analysis. This does not assert the same circuit-prior ordering at every exponent. |
| One hidden layer: $(a_1,a_L)=(a,b)$ with $a>0$ and $a\le b\le a+2$ | **Tentative larger circuit-learning region.** Using $M=N^{(b-a)/2}$ active neurons balances feature cost $MN^a$ against readout cost $N^b/M$. At $b=a+2$ this is the established balanced strong-prior family; the interior suggests that a smaller active population can suffice. A construction alone does not control the remaining neurons or the posterior. |
| One hidden layer: $a>b>1$ | **Proved degree-based prior ordering; learning rate open.** The collapsing layer produces the threshold-degree hierarchy below. It is not a circuit-size prior, but it could still have exponential parity sample complexity. |

In the frozen-feature prediction, $a_L<1$ gives a normalized GP with vanishing absolute margin, $a_L=1$ retains a fixed global margin, and $1<a_L<2$ gives a Gaussian minimum-energy description at leading order. The last statement does not determine posterior weights among tied minimizers. These distinctions already occur within the proposed hard-learning side.

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

## 11. How close are we to a $d^{\Omega(k)}$ sparse-XOR lower bound?

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

This includes the desired $\exp(\Omega(k))$ obstruction, but does not give the full natural sparse scale.

**Open:** that full growing-sparse scale for $0<\gamma<1$, and the corresponding growing-sparse endpoint problem at $\gamma=0$.

There is a genuine regime distinction: a one-coordinate parity learns with $O(\log d)$ examples for $0<\gamma<1$. A uniform $d^{ck}$ claim covering all $k\ge1$ in that regime is therefore false. This does not disprove the proposed bound restricted to sufficiently growing $k$.

See [sparse parity](side-results/sparse-parity/paper.pdf) and [growing positive-subcritical parity](side-results/growing-sparse-positive/paper.pdf). These are iid-sample results, not lower bounds for an active learner allowed to choose informative inputs.

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

For a layered Boolean target circuit of width $C$, this gives sample complexity polynomial jointly in $d,L,C,c+c^{-1},\varepsilon^{-1},\log(1/\delta)$, simultaneously for every $N\ge C$ and every $\gamma\ge1$. The proof builds a robust implementation with enough Gaussian prior mass and compresses posterior draws through small internal disturbances.

The condition has a recognizable interpretation: the prediction score must survive a small amount of simultaneous internal numerical error. Clipping avoids treating a change from output $10$ to output $1$ as a prediction failure. The RMS normalization makes perturbations comparable across widths. The radius compensates for accumulating layer disturbances and readout amplification.

It is nevertheless a particular sufficient condition, with a strong “every input, every perturbation” quantifier. Calling it natural does not establish that arbitrary trained networks satisfy it.

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

**Yes for unrestricted continuous-output regression; open for the original Boolean-cube model.** The [continuous-depth lower bound](works-in-progress/continuous-depth-lower-bound/) gives teachers of constant width, weights bounded by 30, and growing depth on the unit circle. For a fixed, nonatomic input distribution, learning their real outputs requires exponentially many samples in depth. This holds in the strong-prior limit, at every fixed exponent $\gamma>1$ at sufficiently large finite widths, and at mean-field scaling in the width-first limit. Training and test tolerances are fixed constants, and the failure concerns the actual posterior-confidence criterion, including mixtures. The mean-field result does not give a quantitative width threshold.

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

**The present bounds are constructive but very loose.** “Polynomial” refers to the stated parameters with the stated fixed quantities; it is not shorthand for a small numerical exponent.

For example, the original strong-prior proof bounds target energy by

$$
B_L(d,C)=d(d+1)C^2+LC^4.
$$

Its compression width at energy $K$ can be taken as

$$
\rho=\frac{2^{-L}K^{-(L-1)/2}}{12(L-1)},
\qquad
m_L(d,K)=\max\!\left\lbrace \lceil9K\rceil,
\left\lceil256\rho^{-4}[d+\log(L/\rho)]\right\rceil\right\rbrace .
$$

Counting the compressed networks gives an explicit log-class-size bound $Q_L(d,K)$ in the paper, and

$$
n\ge\frac2\varepsilon\left[
Q_L(d,B_L(d,C)+1)+\log(1/\delta)\right]
$$

suffices in the strong-prior limit. This displays the bad depth dependence rather than hiding it behind “fixed depth.”

The fixed-depth all-width mean-field proof is quantitative but grows rapidly with depth: one intermediate truncation budget has order $O_L(dK^{4\cdot3^{L-2}-1})$. That is an intermediate proof quantity, not an optimized final sample exponent.

The critical theorems in Question 17 use a different finite-representation estimate. A path of action at most $A_0\ge1$ and square-root entropy sum $S$ has a same-depth tanh realization of width at most $C(d+L+A_0)^{30}e^{20S}$. The standard sigmoid VC bound is quartic in parameter count. The resulting sample polynomial has a universal, unoptimized degree; its depth dependence also uses the scalar entropy estimate to bound $S$. The finite-width extension adds an exchangeability argument and an explicit target-mass construction. Their unoptimized polynomial width thresholds are absorbed into the learning bound by a VC argument for smaller widths, so the target-based guarantees hold at every realizable width.

The robust proof replaces depth-dependent polynomial degrees by a universal degree. It supplies explicit nested compression parameters and a bound of the form

$$
n\ge\frac{16}{\varepsilon}
\left[\log|\mathcal H|+\log(1/\delta)\right],
$$

where its appendix constructs $\mathcal H$ with polynomial log-cardinality in the displayed theorem parameters. It is a qualitative statistical theorem, not a prediction of MNIST sample counts.

The current Lean resource accounting also verifies a deliberately loose explicit envelope for the formal proof's finite-class sample budget:

$$
A\left[2+d+C+(L-2)+c+c^{-1}+\varepsilon^{-1}+\log(1/\delta)\right]^{10974},
$$

for one universal constant $A$. This comes from the formal proof's more conservative entropy estimates and rounding bounds; it is not a claim that exponent $10974$ is necessary, or that the manuscript's sharper argument has been optimized. Both the degree calculation and the analytic construction are machine-checked. The exact formal scope is stated below. Improving these enormous exponents is a major open problem.

**Hope, not theorem:** substantially smaller complexity dependence, perhaps near quadratic in the bounded-width parameter in suitable settings, or near description length for a better complexity measure. A generic prefix-code prior over Boolean circuits can give Occam bounds of order circuit description length divided by error tolerance. Showing that this Gaussian neural prior matches that behavior is the problem, not a consequence of the generic bound. Counting many functions at width $C$ also does not prove that every such function individually needs $\Omega(C^2)$ examples under every distribution.

## 20. Do independent non-Gaussian weight priors give the same results?

**Yes, for a substantial family of independent coordinate laws.** The [non-Gaussian paper](side-results/non-gaussian-priors/paper.pdf) proves the analogues of main results 1, 2, and 3 for tanh networks when each standardized weight has an even, variance-one density

$$
q(u)=Z^{-1}e^{-V(u)},\qquad V\in C^2,\qquad
0<m\le V''(u)\le M<\infty.
$$

The constants $m,M$ are fixed independently of width. This says that the negative log density has positive curvature bounded above and below; it need not be quadratic. For example, take the variance-standardized version of the density proportional to $e^{-u^2/2-b\log\cosh u}$, for any fixed $b>0$.

The conclusions retain the original layer scales, global margin conditioning, exact noiseless-label posterior, arbitrary common training/test distribution, and **every learner width $N\ge C_L(f)$**. At each fixed depth, the sample bound is polynomial in dimension and target complexity, independently of learner width. This covers both the strong-prior limit at each fixed width and the finite-scale regimes $\gamma>1$ and $\gamma=1$. Correct-label posterior probability exceeds $2/3$ on almost all test inputs, including when the posterior mixes different functions. No added restriction on which network functions the prior supports is needed.

The proof replaces Gaussian target-mass calculations with a translation bound and concentration for the stated coordinate laws. At $\gamma=1$, a quantitative replacement argument compares **log partition functions for bounded covariance tests**, with only polynomial losses in the test budget. Auxiliary Gaussian distributions help construct short descriptions of likely functions; the learner itself keeps its non-Gaussian weights. The paper also proves polynomial comparison between bounded-weight circuit complexity and normalized negative log function prior mass.

**The strong-prior result permits more general laws.** Two-sided quadratic density envelopes suffice, without symmetry or log-concavity. If the negative log density is asymptotic to a common quadratic coefficient times $u^2$, the original weighted-energy ordering of function probabilities holds exactly at exponential-rate level. Curvature bounds alone give the learning guarantee and polynomial comparisons, but need not give a limiting exact rate.

These are conventional proofs with [independent AI-agent review records](side-results/non-gaussian-priors/verification/README.md); the extension is a side result and **has not been Lean verified**. The sample polynomials may depend on the coordinate law and depth. The theorem does not cover Laplace, uniform, Student, or pure quartic-exponential coordinates at the original scales. For a compactly supported law, taking the scale to zero at fixed width can even make the global-margin conditioning event empty. Broader families, alternative width normalizations, and non-Gaussian subcritical learning remain open.

## 21. What about ReLU, sigmoid, GELU, or other activations?

**Proved:** the original strong-prior compression theorem, and the argument for fixed $\gamma>1$ using it, allow bounded Lipschitz activations once the target has the required representation. Tanh is not essential to those statements. A rescaled bounded sigmoid or a bounded clipped activation is therefore a natural fit, with constants and representation assumptions made explicit.

The more specialized results use more structure. Robust digital implementations use reliable gate restoration under finite noise. The subcritical kernel and sharp conditioning results use the tanh saturation limit. The critical rate constructions use particular tanh inequalities. “Bounded Lipschitz” is not a license to import all of those conclusions unchanged.

**Open in this program:** the corresponding full results for ReLU and other unbounded activations such as GELU or SiLU. ReLU is Lipschitz and positively homogeneous, which gives useful alternative norm tools, but it is not bounded. The original width-independent truncation/subsampling proof uses bounded hidden states. Restricting attention to a compact input domain does not by itself bound those states uniformly over the prior and all widths. A separate argument is needed.

Hard threshold activations have the opposite issue: they are bounded but discontinuous, so the numerical compression proof does not transfer directly. Universal approximation by itself also supplies neither the quantitative circuit size nor the robustness needed here. See [Appendix L of the audit](side-results/strong-prior-appendix-audit/paper.pdf).

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

Thus if $\kappa_N(g)>\kappa_N(f)$, the prior ratio $\pi_{N,\sigma}(g)/\pi_{N,\sigma}(f)$ tends to zero. Cloning and compression give the two directions of the complexity comparison: for fixed depth $L$, there are polynomials $P_L,Q_L$, independent of learner width, such that for every $N\ge C_L(f)$,

$$
\kappa_N(f)\le P_L(d,C_L(f)),
\qquad
C_L(f)\le Q_L(d,1+\kappa_N(f)).
$$

This is the slides' circuit-prior claim in a quantitative form: prior preference is governed by a complexity measure polynomially equivalent to small-network complexity. It need not preserve the ordering of two functions with similar circuit sizes. Counting the functions whose energy is no greater than the target's then gives the strong-prior generalization theorem. See the Gaussian-rate lemma and the “Uniform count and complexity comparison” proposition in the [strong-prior paper](main-results/strong-prior-generalization/paper.pdf).

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
| Improve the polynomial | **Open.** Explicit bounds exist, but are far from optimized; no near-description-length Gaussian-prior theorem. |
| Remove bad depth dependence | **Partly resolved.** Joint polynomial depth under the robust support restriction; unrestricted positive results for substantial Boolean classes. The general Boolean case remains open. Continuous-output regression has an exponential-depth lower bound without a robustness restriction. |
| Lower-bound log prior mass | **Partly resolved.** The strong-prior rate is polynomially equivalent to bounded-weight network complexity; finite-variance target-mass bounds also exist. Sharp absolute-mass formulas remain open. |
| Classify scaling regimes | **Partly resolved on a particular one-parameter line.** The three positive learning regimes also extend to the non-Gaussian family in [question 20](#20-do-independent-non-gaussian-weight-priors-give-the-same-results). General exponent tuples, mixed regimes, and non-Gaussian subcritical behavior remain open. |
| Out-of-distribution learning | **Heuristic.** Mistakes by the simplest consistent hypothesis may often eliminate many surviving low-complexity competitors, even as the input distribution changes. The [conditional online argument below](#why-expect-occam-learning-to-transfer-out-of-distribution) makes this expectation precise; its genericity premise remains unproved. |
| Online mistake bounds | **Open for the desired width-uniform neural statement.** The genericity argument below gives a conditional bound for a simplest-consistent learner; its premise and its analogue for the NNBayes posterior remain unproved. Generic Bayesian code-length bounds also exist. |
| Other architectures | **Open here.** CNN weight sharing, recurrence, attention, normalization, and residual structure need their own prior and complexity accounting. |
| Gradient descent | **Open as a learning theorem.** The experiments concern a sufficient stability property, not equivalence between SGD and the exact Bayesian posterior. |

The [appendix audit](side-results/strong-prior-appendix-audit/paper.pdf) checks every original appendix in turn. In particular, the original depth example is a capacity/proof obstruction rather than a sample lower bound; the scaling classification is not exhaustive; the kernel-to-classification inference needed repair; and some online-learning claims were false under their stated conventions. These qualifications are part of the current account, not claims silently inherited from the slides.

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

**Yes, when the noise rate is sufficiently small relative to dimension, depth, and target complexity.** The [noisy-interpolation theorem](works-in-progress/noisy-interpolation/README.md) gives a clean-error bound for fixed-depth tanh networks that fit every training label, including flipped labels. Its proof has undergone independent AI-agent mathematical checks; it is a supporting result, not a Lean-verified main result.

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
- **Finite exponents:** for every fixed $\gamma\ge1$, use our finite-exponent weight prior and Gaussian observation variance $N^{-\gamma}$. A separate argument gives the polynomial bound at **every $N\ge C$**, with no limit required. The polynomial may depend on fixed depth and fixed $\gamma$; the mean-field endpoint $\gamma=1$ is included.

Both versions observe clean labels from the teacher. They do not assert the same bound for data corrupted by fixed positive observation noise.

For the strong-prior version, a replicated teacher has bounded energy independent of learner width, so the posterior concentrates on networks whose **energy plus total squared training error** is bounded by the teacher's energy. Our compression argument covers all such bounded-energy networks with a finite collection of size independent of learner width. A sampling bound then rules out appreciable test error. The finite-exponent proof instead combines the existing teacher-neighborhood mass estimates and covers of most prior outputs with a bound on posterior training loss; it does not assume that typical mean-field networks have bounded total energy. The [note](works-in-progress/slt-likelihood/README.md) spells out both arguments. A Boolean sign teacher gives positive variants of both Gaussian results after adding one tanh layer to approximate its labels; a logistic analogue works when its inverse temperature grows together with prior strength. These are explicit changes of scale, not a claim about the unchanged fixed-likelihood model.

**What about the usual fixed-likelihood setup?** At fixed architecture and fixed prior, standard prior-mass arguments do give sample upper bounds. They pay for the negative log prior mass of a small neighborhood of the teacher. Our available neighborhood estimate grows like $N^\gamma$ in the finite-exponent models with fixed $\gamma\ge1$, yielding polynomial bounds when learner width is itself polynomially bounded by teacher resources, but not the arbitrary-width guarantee of the main papers. A different prior with a sufficiently strong, quantitative circuit-description mass bound could give better results. Calling a model “SLT” alone supplies neither that prior-mass bound nor an all-width learning theorem.

**Still open here:** a complete smooth-likelihood theorem with joint polynomial dependence on depth under our robustness restriction. The regularized-loss argument makes this a reasonable target, but we have not checked the required prior mass and cover estimates within that restricted support. The unrestricted polynomial-depth problem is also not settled. Without rescaling the likelihood, the counterexamples above already prevent a blanket transfer of the main guarantees.

Finally, prediction conventions must match. Logistic posterior-predictive confidence is $\mathbb E_Q[(1+e^{-yz_w(x)})^{-1}]$, whereas our classification papers use $Q(yz_w(x)>0)$. A score margin of $1/2$ gives only about $0.622$ logistic label probability, even if the parameters are known exactly. A $2/3$ predictive guarantee therefore needs a suitable link scale or a larger score margin. The Gaussian result above controls proximity of the latent output to the clean teacher; a future noisy observation is a separate random quantity.

## 25. What other questions matter before interpreting this as an explanation of practical deep learning?

The largest missing links are:

- **Finite width in the negative regimes.** The exponential parity results take $N\to\infty$ at fixed dimension, depth, and sample. They do not provide a useful width threshold uniform in growing $d,k,n$. The positive all-width theorems have a stronger finite-width quantifier.
- **Orders of limits.** Fixing width and shrinking variance, taking width first at a specified scaling, and growing dimension and width together can give different answers. Theorems should specify which is being taken.
- **Computational cost.** Exact posterior conditioning and sampling may be intractable. Polynomial examples do not imply polynomial computation, and no theorem here identifies SGD's output law with that posterior.
- **Noisy or misspecified data.** The strong-prior exact-interpolation theorem has resource-dependent noise tolerance. The [label-noise discussion](#24-do-the-good-generalization-results-survive-a-small-amount-of-label-noise) explains its scope; dimension-independent fixed-noise tolerance and broader misspecification remain open.
- **Typical data and architectures.** Uniform parity is a useful separation, not a model of all natural data. Current empirical certificates do not establish a theorem for modern large-model training.
- **Prediction rules.** Gibbs draws, posterior majority, mean-score prediction, and confidence-threshold success are different losses. A statement about one should not be relabeled as a statement about another.
- **Selection of examples.** Passive iid sample lower bounds need not hold for active learning, teaching sets, or adversarially selected informative inputs. They are also usually stated for each specified sample size, not on one common event for every prefix of an infinite stream.

## 26. How much of this is formally verified?

The repository includes closed Lean formalizations of all five main learning statements, including the polynomial-depth generalization theorem under a robustness restriction; their exact theorem declarations, hypotheses, dependencies, and build instructions are the appropriate source for the machine-checked scope. A successful Lean build verifies the formal statements actually written, so alignment with the intended analytic network model is a separate review obligation.

The [verification record](lean/VERIFICATION.md) gives the exact-type gates, independent source rebuild, and axiom checks. The formal proof under the robustness restriction uses a looser Pinsker-and-energy construction; its exact learning statement does not include every optional posterior variant or sharp manuscript constant. The supporting depth manuscripts and the noisy-interpolation note have undergone independent AI-agent mathematical audits but remain outside the main Lean verification. An audited manuscript or exact numerical certificate is not thereby a Lean proof. The FAQ's heuristic extensions and open-problem assessments are not formalized theorems.

Readers should start with the main theorem and conventions in the relevant paper, then use this FAQ to identify the limitations and possible extensions. The [collection index](README.md) distinguishes main results, side results, and work in progress.
