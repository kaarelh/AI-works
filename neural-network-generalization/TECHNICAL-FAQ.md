# Technical FAQ: Bayesian neural-network generalization

This FAQ explains what the current results say, which assumptions matter, and where we expect extensions. It is intended for readers considering this research program, including readers of the original [Vaintrob–Hänni slides](https://kaarelh.github.io/ai/nnbayes-generalization.pdf). It is a research snapshot, not a claim that the open questions below have been resolved.

**Status labels:** **Proved** means that the linked manuscript contains a proof under its stated assumptions. **Extension suggested by the proof** means that we have identified a plausible adaptation but are not citing a completed theorem. **Heuristic** is an informed expectation. **Open** means that the available results do not settle the question. Machine verification is a separate issue; see the final question.

**Jump to:** [prediction thresholds](#5-what-changes-if-correctness-means-posterior-probability-above-12-rather-than-23) · [scaling tuples](#9-can-we-classify-all-tuples-of-layerwise-scaling-exponents) · [robustness and depth](#12-what-robustness-condition-gives-polynomial-depth-dependence) · [label noise](#24-do-the-good-generalization-results-survive-a-small-amount-of-label-noise) · [formal verification](#26-how-much-of-this-is-formally-verified)

## 1. What is the basic model, and what does “a circuit prior” mean here?

**Proved, with several different quantifier orders.** The original model is a fully connected network with bounded hidden activations, usually tanh, and a real-valued linear readout $z_w(x)$. Inputs and target labels are Boolean: $x\in\lbrace -1,1\rbrace ^d$, $f(x)\in\lbrace -1,1\rbrace $. There are $L-1$ hidden layers of width $N$, a constant input coordinate, and no separate internal biases.

The original Gaussian prior is conditioned, before observing labels, on

$$
|z_w(x)|>1/2\qquad\text{at every Boolean input }x.
$$

The posterior then conditions on the observed training signs. Under that prior restriction, this is equivalent to requiring $f(X_i)z_w(X_i)>1/2$ at each training input. Training inputs are iid; positive results allow an arbitrary common input distribution, whereas the parity lower bounds use the uniform distribution.

“Circuit prior” is a claim about the **prior on functions**: its preference for different functions approximately tracks the complexity of small circuits implementing them. In the slides' strong-prior setting, this is made precise through the Gaussian energy cost $\kappa_N(f)$, which determines the leading exponential order of prior probability ratios and is polynomially related to bounded-weight network complexity at fixed depth, uniformly over all learner widths $N\ge C_L(f)$.

The sample-complexity theorem is a **consequence** of that prior-complexity comparison, together with a bound on the number of low-complexity competitors. A polynomial sample bound alone is not the definition of a circuit prior. “Approximately” here allows polynomial distortion and dimension/depth dependence; it does not assert an exact ordering of every pair by circuit size or efficient posterior sampling. [Question 22](#22-do-we-now-have-a-useful-lower-bound-on-the-prior-probability-of-a-function) gives the precise strong-prior comparison.

There are two different comparator complexities:

- The original $C_L(f)$ is the least width of a depth-$L$ neural network realizing $f$ with the prescribed margin and with every physical weight bounded by that width.
- The polynomial-depth generalization theorem under a robustness restriction uses the width of a layered **Boolean** circuit at the required depth, counting constant wires and any compilation overhead.

These should not be interchanged without a representation theorem. See the [strong-prior paper](main-results/strong-prior-generalization/paper.pdf) and [robust polynomial-depth paper](main-results/robust-polynomial-depth/paper.pdf).

## 2. How important is it that the inputs are Boolean?

**Partly technical, partly substantive.** A finite domain permits global margin conditioning, a finite list of Boolean functions, and uniform compression over the input set. The cube has $2^d$ points, so a union bound over all inputs costs only $O(d)$ in a logarithm. Its Fourier structure is also central to the parity lower bounds; those are not distribution-free lower bounds.

**Extension suggested by the proof:** several upper-bound arguments should extend to a general finite input set, with dependence on its log-cardinality and input norm. A continuous bounded domain would require an additional covering or regularity argument. The exact statements in the main papers should not be read as already covering arbitrary continuous inputs.

There is also a useful distinction between finite precision and a change of prior. An 8-bit pixel can be expressed exactly as a linear combination of eight Boolean bits. Composing that fixed decoder with a network preserves its computations and internal-noise stability on the corresponding images. It does **not** identify the resulting tied first-layer weights with independent Gaussian weights on the bits, and checking real images does not check all bit strings.

## 3. Are the network outputs Boolean? What if we scale them up?

**The labels are Boolean; the network outputs are real.** Classification uses their signs, with output margins imposed in the prior or likelihood. The arguments do not require a network to output exactly $+1$ or $-1$.

Multiplying the readout by $A>0$ preserves signs and can improve output margins, but multiplies its squared Gaussian energy by $A^2$. It is therefore not free in a Bayesian prior. In particular, an implementation that needs an enormous output scale to become stable need not give a polynomial prior-mass or sample bound in the original implementation's size.

For a finite input cube and nonzero clean outputs, sufficiently large readout amplification can eventually enforce the clipped-score stability condition used below. This does not show that the **raw trained network** satisfies the condition, or that the required amplification has polynomial cost. The robust Boolean-circuit construction instead supplies a controlled implementation and a controlled neighborhood of prior mass around it.

**Open:** an equally general theory for real-valued regression targets, noisy observations, or multiclass outputs. The binary margin proofs suggest useful starting points, but they are not regression theorems.

## 4. Can we drop the requirement of a margin on every input before training?

**Yes under the new robustness restriction; not as an automatic corollary of the old unrestricted theorems.** The polynomial-depth generalization theorem allows the prior to contain outputs arbitrarily close to zero at unobserved inputs. It still uses the training likelihood

$$
f(X_i)z_w(X_i)>1/2,
$$

and bounds the posterior probability of test-margin error $f(X)z_w(X)\le1/4$. Consequently it also bounds sign error. Keeping the original all-input clean-margin restriction is permitted and gives the same conclusion.

The replacement assumption is a finite internal-noise stability condition on the prior's support. This is doing real work. We have not shown that one can simultaneously remove the original global margin restriction **and** the new stability restriction while retaining the same guarantees.

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

For $\gamma<0$, the current direct confidence argument is different: a log-concavity step naturally reaches thresholds above $1-e^{-1}\approx0.632$. It does not establish the entire interval $q>1/2$. For the newer **critical** $\gamma=1$ polynomial parity lower bound, Gibbs error tends to $1/2$, so every fixed $q>1/2$ is covered, but majority failure still does not follow.

**Open in these lower-bound arguments:** the exact $1/2$ threshold. It is possible for $p_S(x)=0.5001$ at every input: Gibbs error is almost $1/2$, yet the posterior majority is correct everywhere. A result about confidence bounded away from $1/2$ is therefore not automatically a result about majority prediction. The distinction between $<$, $\le$, and the rule for ties should also be specified when stating an exact theorem.

## 6. Why are mixtures of individually bad predictors not already a problem at $2/3$?

**Because the lower bound controls their average error by enough to cross that threshold.** If every minimum-energy sign function has error at least $3/8$, every mixture of them has Gibbs error at least $3/8$. The second inequality above then forces a $1/16$ fraction of inputs to have correct-label probability at most $2/3$, regardless of the mixture weights.

A majority of bad predictors can nevertheless be accurate. Their mistakes may occur on different inputs. Thus the proof never needed a unique minimizer for its $2/3$ conclusion, but a majority lower bound would require additional information about how the minimizers' errors align.

An earlier informal explanation that treated mixture ties as a problem unique to a particular scaling regime was too broad. The right questions are the available Gibbs-error bound, the requested confidence threshold, and whether a stronger pointwise or voting argument is available.

## 7. Is this just kernel regression or NNGP posterior-mean prediction?

**No.** A Gaussian-process prior conditioned on training signs is not the same posterior as Gaussian regression conditioned on exact real output values. Conditioning additionally on an absolute margin at every input changes it again. Moreover,

$$
\operatorname{sign}\mathbb E[z(x)\mid S]
\quad\text{and}\quad
\operatorname{sign}\mathbb E[\operatorname{sign}z(x)\mid S]
$$

are different prediction rules: a few large-magnitude outputs can affect the former without affecting the latter in the same way.

A small parity eigenvalue, or poor correlation of the regression mean, is therefore not by itself a lower bound for the posterior-confidence convention used here. This was a substantive gap in the original slides' kernel discussion. The later lower bounds analyze the appropriate conditioned law.

There is a separate [NNGP note](side-results/nngp-sample-complexity/paper.pdf) with an exponential confidence lower bound for a deep, variance-normalized tanh GP family. Its depth grows with the input dimension. It should not be silently substituted for the fixed-depth theorem for all $\gamma<1$.

## 8. What is actually known for the one-parameter family of scalings?

Here the entry **variances**, not standard deviations, are

$$
\operatorname{Var}W^1=N^{1-\gamma}/d,
\qquad \operatorname{Var}W^s=N^{-\gamma}\ (1<s<L),
\qquad \operatorname{Var}v=N^{-\gamma-1}.
$$

The table concerns this particular family and the indicated conditioning conventions.

| Regime | Current conclusion | Important qualification |
|---|---|---|
| Strong-prior limit at fixed $N$ | Prior rate polynomially equivalent to bounded-weight network complexity at fixed depth; consequently polynomial samples, uniformly in the sample bound over all $N\ge C_L(f)$. | Variance tends to zero **after fixing width**; no width-uniform variance threshold. |
| Fixed $\gamma>1$ | Polynomial samples at fixed depth for every actual $N\ge C_L(f)$. New unrestricted results also remove bad learner-depth dependence for substantial target classes. | The old polynomial degree depends on depth and on the gap above one. The full arbitrary-deep-target problem remains open. |
| $\gamma=1$ | Polynomial samples at each fixed depth, every actual $N\ge C_L(f)$. With the robustness restriction, jointly polynomial dependence on depth for Boolean-circuit targets. | A joint polynomial-depth theorem for the original unrestricted critical prior is open. |
| $0<\gamma<1$ | A Gaussian minimum-energy description at leading exponential order; exponential full-parity confidence lower bound. | This is not exact Gaussian-posterior equivalence throughout the interval. Limits are width first. |
| $\gamma=0$ | A fixed-margin globally conditioned Gaussian limit; exponential full-parity confidence lower bound. | The global margin remains in the limiting law. |
| $\gamma<0$ | After output normalization, a Gaussian law conditioned on training signs; exponential full-parity and stronger sparse-parity lower bounds. | The original fixed margin vanishes under this normalization. |

The $\gamma\le0$ exponential result is included in the [main subcritical paper](main-results/subcritical-exponential/paper.pdf); it is not an omitted fifth scaling result. The [collection index](README.md) separates the main papers and supporting results.

## 9. Can we classify **all** tuples of layerwise scaling exponents?

**Open. We do not have an exhaustive classification.** Write a general variance tuple as

$$
\operatorname{Var}W^1=c_1N^{-a_1}/d,
\quad \operatorname{Var}W^s=c_sN^{-a_s},
\quad \operatorname{Var}v=c_LN^{-a_L}.
$$

Our one-parameter family occupies only the line

$$
(a_1,a_2,\ldots,a_{L-1},a_L)
=(\gamma-1,\gamma,\ldots,\gamma,\gamma+1).
$$

In contrast, the usual nondegenerate tanh NNGP scaling is $(0,1,\ldots,1,1)$. Calling both constructions “NNGP-like” does not make their kernels or conditioning identical.

**Heuristic for typical unconditioned amplitudes:** for fixed depth, tanh, fixed dimension, and nondegenerate coordinates, let the hidden activation variance scale like $N^{-b_s}$. Then

$$
b_1\approx\max\lbrace a_1,0\rbrace ,\qquad
b_s\approx\max\lbrace a_s+b_{s-1}-1,0\rbrace ,
$$

and the output variance has scale $N^{1-a_L-b_{L-1}}$. This suggests linear, order-one nonlinear, and saturated layers. It is useful bookkeeping, **not a classification of the conditioned Bayesian learner**. Covariances can degenerate, boundary constants matter, and rare margin conditioning can select features that are atypical under the unconditioned calculation.

The deeper obstruction to the slides' proposed classification is that implementing a layer simultaneously on many inputs depends on the full feature Gram matrix. For incoming feature matrix $A$, a prescribed preactivation vector $b$ has Gaussian cost proportional to $b^\top(AA^\top)^+b$, when feasible. Scalar amplitude prices omit rank, conditioning, and the entropy of possible feature representations. Downstream labels can also change the upstream feature law.

Consequently, the slides' “step-up collapse,” “step-down truncation,” and reduction of every scaling to a short list remain heuristics. Neither the table above nor the amplitude recursion fills the remaining tuples. See [Appendix I of the audit](side-results/strong-prior-appendix-audit/paper.pdf).

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

- **Proved for $\gamma<0$:** the natural sparse scale, at the $2/3$ confidence criterion, with width taken first. The theorem's universal failure fraction is positive but small; it is not a claim of, say, 10% error.
- **Proved for $0<\gamma<1$:** for growing sparse parity, a lower bound of the form
  $$
  n\le\exp\!\left(c\max\left\lbrace k,\sqrt{k}\log\frac{e(d+1)}{\sqrt{k}}\right\rbrace \right).
  $$
  This includes the desired $\exp(\Omega(k))$ obstruction, but does not give the full natural sparse scale.
- **Open:** that full growing-sparse scale for $0<\gamma<1$, and the corresponding growing-sparse endpoint problem at $\gamma=0$.

There is a genuine regime distinction: a one-coordinate parity learns with $O(\log d)$ examples for $0<\gamma<1$. A uniform $d^{ck}$ claim covering all $k\ge1$ in that regime is therefore false. This does not disprove the proposed bound restricted to sufficiently growing $k$.

See [sparse parity](side-results/sparse-parity/paper.pdf) and [growing positive-subcritical parity](side-results/growing-sparse-positive/paper.pdf). These are iid-sample results, not lower bounds for an active learner allowed to choose informative inputs.

## 12. What robustness condition gives polynomial depth dependence?

**Proved in the new robust paper.** Add a disturbance after each hidden layer and at the readout, with total budget

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

## 13. What is a nonexpansive network, and must every layer be nonexpansive?

A map is nonexpansive if it does not increase Euclidean distances. Tanh applied coordinatewise is nonexpansive; a linear layer has this property when its operator norm is at most one. If the internal weight matrices have operator norm at most one, disturbances cannot be amplified as they travel through those layers. Cauchy–Schwarz then bounds the readout change by $c$ under the calibrated noise budget above. Thus $c\le1/16$ supplies a simple sufficient certificate.

**Proved:** the robustness restriction used for polynomial-depth generalization does not require all those operator norms to be at most one. Finite-radius Jacobian bounds, bounds on reachable activation intervals, and suitable weighted layer metrics can also certify the restriction. These allow expansion in one direction or layer when later contraction or saturation controls the total effect.

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

**Open for the general learning question.** The original depth example and later critical-rate constructions show that broad low-energy sets can contain enormously many functions. They obstruct certain norm-counting proofs. They do not establish that a particular small target needs exponentially many examples: one must show that the bad competitors retain enough posterior mass after the labels are observed.

There is now substantial positive evidence against treating bad depth dependence as automatic. For every fixed gap $\gamma\ge1+\zeta$, the [unrestricted-depth paper](works-in-progress/unrestricted-depth/paper.pdf) gives polynomial dependence on learner depth for all bounded-weight shallow tanh targets and for all Boolean halfspaces, at every actual width above the original $C_L(f)$. The halfspace result does not depend on the target's original coefficient precision or geometric margin. Other covered classes include fixed-depth threshold circuits and functions with polynomially bounded Fourier $\ell_1$ norm, including parity.

For a general fan-in-two Boolean circuit of size $s$, logical depth $h$, and $S=\max\lbrace 16,2+d+s\rbrace $, a current bound is

$$
S^{O_\zeta(1+h/\log\log S)}\,
\operatorname{poly}(L,\varepsilon^{-1},\log(1/\delta)),
$$

at learner depths $L\ge\max\lbrace 2,h\rbrace $. This improves the direct exponential dependence on $h\log S$, but is not a joint polynomial. Formula balancing gives a quasipolynomial alternative for formulas, with the corresponding learner-depth qualification.

The same paper identifies a function-level product-norm representation barrier: low sample complexity forces suitable approximate low-product-norm representatives in a specified large-width regime. No explicit small deep circuit violating the necessary approximation condition is known here. Indeed, an explicit superpolynomial-sample counterexample within $\mathsf{NC}^1$, in the regime covered by these positive results, would separate $\mathsf{NC}^1$ from $\mathsf{TC}^0$. This is a reason for caution about easy purported counterexamples, not a proof that the desired theorem is true.

## 17. What does the new critical-depth result imply about learning?

**It gives both rate information and a separate, more limited learning lower bound.** At $\gamma=1$, define the raw prior rate

$$
J_L(f)=\lim_{N\to\infty}-\frac1N\log\Pr\lbrace f(x)z_w(x)>1/2\text{ for all }x\rbrace .
$$

The [critical-depth paper](works-in-progress/critical-depth/paper.pdf) proves that the absolute rates of all Boolean functions approach the same universal $V_*\in(1,2)$ as depth increases, with quantitative polynomial-depth bounds. It also identifies the minimum rate scale, up to universal factors, as

$$
1+L\bigl(d^{1/(2L)}-1\bigr)^2.
$$

**This does not make the conditioned function prior uniform.** A width-first posterior is governed by differences $N[J_L(f)-J_L(g)]$. A tiny positive rate gap can dominate when $N\to\infty$. Near equality of absolute rates is not a sample-complexity lower bound.

A separate rate comparison does prove a critical parity lower bound. At fixed $L\ge2$, put

$$
M=\min\lbrace k,d^{1/(L-1)}\rbrace .
$$

For fixed $\eta>0$, $M\to\infty$, and $n\le M^{1-\eta}$, the limiting Gibbs error is $1/2$ with high probability over uniform training inputs. Thus full parity remains difficult up to $d^{(1-\eta)/(L-1)}$ examples. This is a **polynomial** lower bound, not the subcritical exponential bound. It is compatible with the fixed-depth polynomial upper theorem and does not resolve the unrestricted joint polynomial-depth question.

## 18. Can the exponential dependence on the *teacher's* depth be removed unconditionally?

**For substantial classes, yes; for every small deep neural circuit, not yet.** Teacher depth, learner depth, and the norm of a teacher representation are different parameters.

The new unrestricted results remove dependence on a chosen teacher's depth when the function has another controlled shallow representation. More generally, a globally unit-margin network with product of Frobenius norms $P$ has a Boolean normal form with depth, width, and finite description polynomial in $P$, apart from specifying at most $P^2$ relevant input coordinates. This bound is independent of the original teacher's depth and width. The learning theorem for product-controlled targets has an explicit additional-learner-depth requirement.

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

The fixed-depth mean-field proof is also quantitative but grows rapidly with depth: one intermediate truncation budget has order $O_L(dK^{4\cdot3^{L-2}-1})$. That is an intermediate proof quantity, not an optimized final sample exponent.

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

**Independence alone is not enough.** The Gaussian proofs use more than independence: quadratic small-noise rates, concentration, Gaussian conditional laws, relative-entropy transport, and sometimes exact kernel or spectral calculations.

For the fixed-width strong-prior argument, the most portable idea is a large-deviation rate $I(w)$: if function probabilities have rate given by the minimum $I$ over their realizations, and $I$ has suitable cloning and compression properties, the relevance argument can be repeated. A prior with a rate uniformly comparable to the weighted quadratic energy is a plausible candidate. This is a conditional proof strategy, not a theorem for every independent sub-Gaussian distribution.

Laplace-type priors suggest an $\ell_1$-type cost; other generalized Gaussian priors suggest $\ell_p$ costs. Their width normalization and cloning algebra must be redone. Discrete support can fail to realize targets or give no open target neighborhood; bounded support and heavy tails can change the rare-event mechanism substantially. Even a universality theorem for typical random features would not automatically survive the rare global-margin conditioning.

**Open:** a useful broad non-Gaussian universality theorem for the finite-variance all-width conclusions, and a corresponding classification of subcritical learning behavior. Robust entropy compression suggests investigating product measures with appropriate transport and moment inequalities, but the target-mass construction and all width factors still have to be checked.

## 21. What about ReLU, sigmoid, GELU, or other activations?

**Proved:** the original strong-prior compression theorem, and the fixed-$\gamma>1$ argument using it, allow bounded Lipschitz activations once the target has the required representation. Tanh is not essential to those statements. A rescaled bounded sigmoid or a bounded clipped activation is therefore a natural fit, with constants and representation assumptions made explicit.

The more specialized results use more structure. Robust digital implementations use reliable gate restoration under finite noise. The subcritical kernel and sharp conditioning results use the tanh saturation limit. The critical rate constructions use particular tanh inequalities. “Bounded Lipschitz” is not a license to import all of those conclusions unchanged.

**Open in this program:** the corresponding full results for ReLU and other unbounded activations such as GELU or SiLU. ReLU is Lipschitz and positively homogeneous, which gives useful alternative norm tools, but it is not bounded. The original width-independent truncation/subsampling proof uses bounded hidden states. Restricting attention to a compact input domain does not by itself bound those states uniformly over the prior and all widths. A separate argument is needed.

Hard threshold activations have the opposite issue: they are bounded but discontinuous, so the numerical compression proof does not transfer directly. Universal approximation by itself also supplies neither the quantitative circuit size nor the robustness needed here. See [Appendix L of the audit](side-results/strong-prior-appendix-audit/paper.pdf).

## 22. Do we now have a useful lower bound on the prior probability of a function?

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
\ge\exp[-(N/t^2)\,\operatorname{poly}(\text{target resources})].
$$

The critical paper gives a variational characterization and depth bounds for the corresponding rate. These answer parts of the slides' absolute prior-mass question. Absolute negative log probabilities can still grow with width or prior strength, consistently with the normalized rate comparison above.

This does not contradict width-independent learning. The generalization argument controls competitors relative to the target, or compresses a posterior with controlled relative entropy. It need not pay the full raw $-\log\mu(U_f)$ as a sample bound. The globally conditioned function prior also includes a normalization denominator that must be retained for absolute probabilities and comparisons across different priors; it cancels when comparing two functions under the same prior, as above.

Conversely, a tiny target probability alone is not a sample lower bound. A prior can assign a target tiny mass while assigning almost all remaining mass to a single competitor that one informative example eliminates. Both this mistake and the omission of the global-conditioning denominator occurred in heuristic arguments discussed in the [appendix audit](side-results/strong-prior-appendix-audit/paper.pdf).

## 23. Which original open problems have been resolved, and which remain?

| Original direction | Current status |
|---|---|
| Improve the polynomial | **Open.** Explicit bounds exist, but are far from optimized; no near-description-length Gaussian-prior theorem. |
| Remove bad depth dependence | **Partly resolved.** Joint polynomial depth under the robust support restriction; unrestricted positive results for substantial classes. General unrestricted small-deep-target case remains open. |
| Lower-bound log prior mass | **Partly resolved.** The strong-prior rate is polynomially equivalent to bounded-weight network complexity; finite-variance target-mass bounds also exist. Sharp absolute-mass formulas remain open. |
| Classify scaling regimes | **Partly resolved on a particular one-parameter line.** All tuples, mixed regimes, and broad non-Gaussian universality remain open. |
| Out-of-distribution learning | **No general guarantee.** The iid conclusions use the same training and test distribution; arbitrary distribution shift admits elementary counterexamples. |
| Online mistake bounds | **Open for the desired width-uniform neural statement.** Generic Bayesian code-length bounds exist, but the slides' stronger heuristic is not established. Cheapest-consistent circuit/formula analogies can fail. |
| Other architectures | **Open here.** CNN weight sharing, recurrence, attention, normalization, and residual structure need their own prior and complexity accounting. |
| Gradient descent | **Open as a learning theorem.** The experiments concern a sufficient stability property, not equivalence between SGD and the exact Bayesian posterior. |

The [appendix audit](side-results/strong-prior-appendix-audit/paper.pdf) checks every original appendix in turn. In particular, the original depth example is a capacity/proof obstruction rather than a sample lower bound; the scaling classification is not exhaustive; the kernel-to-classification inference needed repair; and some online-learning claims were false under their stated conventions. These qualifications are part of the current account, not claims silently inherited from the slides.

## 24. Do the good generalization results survive a small amount of label noise?

**Noisy Occam learning is possible, but the present posterior theorems do not automatically extend. There is also a real issue with the strong-prior limit.** It matters whether “noise” means independent random label flips, input-dependent flip probabilities uniformly below one half, or adversarial corruptions, and whether test error is measured against the clean target or a fresh noisy label.

With the **current exact-consistency learner**, two observations of the same input with opposite labels make the conditioning event empty. Even without repeated inputs, a flipped label excludes the clean target from the posterior. The target-neighborhood comparison used in the existing proofs is therefore lost; the learner would need to interpolate the corrupted labels, and we have no theorem here saying that the resulting posterior still generalizes well.

Your Occam intuition is right at the level of **learning from a controlled-complexity class**. For example, let a finite class $H$ contain the clean target, and independently flip each training label with probability $\eta<1/2$. If a predictor has clean error $e$, its expected noisy-label error is

$$
\eta+(1-2\eta)e.
$$

Thus empirical noisy-error minimization can still identify a predictor with small clean error. A simple union-bound/Hoeffding argument gives the sufficient bound

$$
n=O\!\left(\frac{\log|H|+\log(1/\delta)}{(1-2\eta)^2\varepsilon^2}\right)
$$

for clean error at most $\varepsilon$. This deliberately loose bound illustrates the point: a polynomial description-length bound can yield a polynomial noisy-learning bound. Analogous finite-class arguments work for independent input-dependent flip probabilities uniformly bounded by $\eta<1/2$. These are standard noisy-learning observations, **not yet an extension proved for our exact Bayesian learner**.

There is a subtle obstruction to simply replacing hard consistency by an ordinary noisy likelihood and then taking the same **strong-prior-first limit**. For a fixed sample of size $n$ and fixed $0<\eta<1/2$, the likelihood ratio of any two Boolean hypotheses is at most $((1-\eta)/\eta)^n$. But if their prior rates differ by $\Delta\kappa>0$, their prior probability ratio has an exponential factor $\exp[-\Delta\kappa/(2\sigma^2)]$. As $\sigma\to0$ at fixed width and fixed $n$, the prior-rate difference wins. The positive noisy likelihood cannot exclude a strictly cheaper wrong hypothesis in the way exact consistency does. Consequently, **a naive noisy-likelihood substitution can fail even with very little noise**. A successful extension needs a specified balance between prior strength, likelihood strength, and sample size, or a different rule such as a controlled empirical-error constraint; it is not a free corollary of the noiseless theorem.

My expectation is that useful noisy analogues can be proved using the compression/Occam structure with an appropriately calibrated learner. The right result should state the noise model and order of limits explicitly, and account for the complexity of fitting or tolerating corruptions. Arbitrary adversarial corruption is a different problem and generally prevents arbitrarily small clean error at a fixed positive corruption rate without more assumptions. Finally, if confidence refers to a **fresh noisy label**, rather than the latent clean function, even knowing the target perfectly gives confidence only $1-\eta$ under symmetric flips.

## 25. What other questions matter before interpreting this as an explanation of practical deep learning?

The largest missing links are:

- **Finite width in the negative regimes.** The exponential parity results take $N\to\infty$ at fixed dimension, depth, and sample. They do not provide a useful width threshold uniform in growing $d,k,n$. The positive all-width theorems have a stronger finite-width quantifier.
- **Orders of limits.** Fixing width and shrinking variance, taking width first at a specified scaling, and growing dimension and width together can give different answers. Theorems should specify which is being taken.
- **Computational cost.** Exact posterior conditioning and sampling may be intractable. Polynomial examples do not imply polynomial computation, and no theorem here identifies SGD's output law with that posterior.
- **Noisy or misspecified data.** Exact sign/margin consistency assumes realizability. The [label-noise discussion](#24-do-the-good-generalization-results-survive-a-small-amount-of-label-noise) explains both the noisy-Occam route and the obstruction from taking the strong-prior limit first.
- **Typical data and architectures.** Uniform parity is a useful separation, not a model of all natural data. Current empirical certificates do not establish a theorem for modern large-model training.
- **Prediction rules.** Gibbs draws, posterior majority, mean-score prediction, and confidence-threshold success are different losses. A statement about one should not be relabeled as a statement about another.
- **Selection of examples.** Passive iid sample lower bounds need not hold for active learning, teaching sets, or adversarially selected informative inputs. They are also usually stated for each specified sample size, not on one common event for every prefix of an infinite stream.

## 26. How much of this is formally verified?

The repository includes closed Lean formalizations of all five main learning statements, including the polynomial-depth generalization theorem under a robustness restriction; their exact theorem declarations, hypotheses, dependencies, and build instructions are the appropriate source for the machine-checked scope. A successful Lean build verifies the formal statements actually written, so alignment with the intended analytic network model is a separate review obligation.

The [verification record](lean/VERIFICATION.md) gives the exact-type gates, independent source rebuild, and axiom checks. The formal proof under the robustness restriction uses a looser Pinsker-and-energy construction; its exact learning statement does not include every optional posterior variant or sharp manuscript constant. The other recent depth manuscripts have undergone independent AI-agent mathematical audits but remain outside the main Lean verification. An audited manuscript or exact numerical certificate is not thereby a Lean proof. The FAQ's heuristic extensions and open-problem assessments are not formalized theorems.

Readers should start with the main theorem and conventions in the relevant paper, then use this FAQ to identify the limitations and possible extensions. The [collection index](README.md) distinguishes main results, side results, and work in progress.
