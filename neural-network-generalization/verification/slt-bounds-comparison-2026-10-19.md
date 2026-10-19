# SLT and sample-complexity comparison: review record

19 October 2026. This records a focused source and mathematical review for the [FAQ comparison](../TECHNICAL-FAQ.md#does-slt-already-give-comparable-generalization-bounds). It is not a new main result, a Lean formalization, an exhaustive literature survey, or a full audit of the reports discussed below.

In the initial publication, three separate Codex agents reviewed the primary SLT sources and the two Claude reports. The parent checked the cited comment in context, the network-capacity comparison, and the final exposition. Two agents then reviewed the completed FAQ section. No substantive correction was required in those final reviews; a sentence about the local-posterior theorem was made more precise.

The **reassessment below supersedes the initial editorial assessment** of the reduction claim and adds a finite-sample theorem and further counterexample.

## Sources checked

- Sumio Watanabe, [Equations of States in Singular Statistical Estimation](https://arxiv.org/abs/0712.0653), Corollary 3: distinguishes expected predictive and Gibbs excess log losses. The FAQ uses ordinary Bayes in the realizable setting.
- Sumio Watanabe, [Asymptotic Equivalence of Bayes Cross Validation and Widely Applicable Information Criterion in Singular Learning Theory](https://jmlr.org/papers/volume11/watanabe10a/watanabe10a.pdf), sections 2.3 and 4.3: hypotheses and coefficient definitions.
- Lau, Murfet, and Wei, [Quantifying degeneracy in singular models via the learning coefficient](https://arxiv.org/abs/2308.12108v1), original version, Appendix A.1: the local-posterior formulation. Later versions have different titles and numbering.
- Nagayasu and Watanabe, [Bayesian Free Energy of Deep ReLU Neural Network in Overparametrized Cases](https://arxiv.org/pdf/2303.15739v3), Theorem 3.1, especially equation (40): the bounded-input teacher-dependent coefficient. The introduction qualifies its pointwise prediction conclusion; the proof's equation (88) retains prior-density and neighborhood-volume costs. We checked the scope of this theorem, not every step of its proof.
- [Murfet's full comment](https://www.greaterwrong.com/posts/ALJYj4PpkqyseL7kZ/my-criticism-of-singular-learning-theory/comment/KYT7aPu5LhktFQ6LR), through the GreaterWrong mirror: his qualifications are preserved in the FAQ.
- Bartlett, Harvey, Liaw, and Mehrabian, [Nearly-tight VC-dimension and Pseudodimension Bounds for Piecewise Linear Neural Networks](https://jmlr.org/papers/volume20/17-612/17-612.pdf): the stated architecture example is explicitly piecewise linear, not a tanh bound.
- Bartlett, Foster, and Telgarsky, [Spectrally-normalized margin bounds for neural networks](https://arxiv.org/abs/1706.08498): an example of classical complexity control beyond raw parameter count.

## Exact delayed-learning example

Let the training observations be independent with distribution $\mathcal N(1,1)$. The statistical model is $\mathcal N(\theta,1)$ and the prior is $\mathcal N(0,1/a)$, with $a>0$. Conjugacy gives

$$
\theta\mid Y_1,\ldots,Y_n\sim\mathcal N(m_n,v_n),\qquad
m_n=\frac{\sum_iY_i}{n+a},\qquad v_n=\frac1{n+a}.
$$

The posterior mean has bias $-a/(n+a)$ and training-sample variance $n/(n+a)^2$. The KL divergence from $\mathcal N(1,1)$ to $\mathcal N(\theta,1)$ is $(\theta-1)^2/2$. Consequently the expected Gibbs excess log loss is exactly

$$
\frac12\left[\frac{a^2+n}{(n+a)^2}+\frac1{n+a}\right]
=\frac{a^2+2n+a}{2(n+a)^2}.
$$

For $n\le a$, the squared-bias term alone is at least $1/8$. For every fixed $a$, the full expression is $1/n+O_a(n^{-2})$, consistent with the regular coefficients $\lambda=\nu=1/2$. Thus these coefficients supply no uniform sample threshold over prior precision. In fact a close relative approximation by $1/n$ can require $n$ much larger than $a^2$, even though a fixed-error threshold scales differently.

This calculation was independently checked by the parent and two agents. It is an elementary exact example; its validity does not depend on applying a compact-parameter SLT theorem to an unbounded Gaussian prior. It concerns a fixed observation variance and genuine Gaussian observations, not the clean-data, co-scaled likelihood theorem in the preceding FAQ section.

## Scope of the Claude-report reviews

The review considered two unpublished reports by Claude Opus 5.5:

1. *Does singular learning theory say anything interesting about learning parity?* Version 2, revised 13–15 October 2026.
2. *How many samples suffice for a Bayesian tanh network to learn a small circuit?* Revised 14–15 October 2026.

The review focused on the mathematical claims and derivations; the reports' own claims of verification were not treated as independent evidence. The source PDFs are not republished in this collection.

The targeted inspection found no major error in the core prior-neighborhood and variational route. The small-circuit report explicitly improves the certificate's logarithmic count from all learner parameters to $(C(d+1)+N)/2$ in the shallow case. Its clean-label arguments give online guarantees, while its iid conclusions concern an averaged predictive distribution. The report does not claim the same high-probability final-posterior guarantee as the main NNBayes results. Its fixed-likelihood and readout-prior conventions differ from this collection's positive regimes.

The parity report's higher-dimensional comparisons use a heuristic phase model and a proxy for the predictive classifier; some assumed global learning coefficients are not established. The report itself notes instances where missing configurations cause a phase-model free-energy estimate to exceed a claimed rigorous upper bound. Those estimates therefore cannot be treated as certified ground truth. Nor is a lower bound on what one certificate can establish a lower bound on what the learner can learn.

The explicit constants, local-coefficient equalities, optimality claims, all companion proofs, and numerical experiments were not fully audited or rerun. The FAQ retains the constructive comparison and these scope distinctions; it does not endorse a general negative conclusion about SLT from the phase-model experiments.

## What the comparison establishes

The leading coefficients, quantitative finite-sample remainder, prior mass, prediction object, and training-sample probability must all be compared. Different losses are often convertible, so they are not by themselves a reason to dismiss a result. An upper bound on cumulative predictive loss does not automatically upper-bound its final increment. An expected-risk bound can be converted using Markov's inequality, but this alone does not recover logarithmic dependence on the failure probability.

The existing manuscripts and Lean sources are unchanged. This FAQ addition and review record do not extend the scope of machine verification.

## Reassessment of the finite-sample claim

The initial review above checked the formulas and source scopes but accepted an emphasis that was too favorable to an unqualified “reduction” of generalization to local coefficients. The revised FAQ leads with the stronger conclusion: **the local coefficients do not determine useful finite-sample guarantees**. This is a mathematical obstruction, not merely a request for a more explicit remainder in an otherwise sufficient list of inputs. The Gaussian example above already establishes this for the usual coefficients; the construction below also fixes the entire local prior germ.

The reassessment also found a positive counterweight to a blanket negative conclusion about finite-volume methods. The [supporting note](../works-in-progress/slt-finite-sample/README.md) proves an explicit finite-sample bound for standard fan-in Gaussian tanh networks, linear in learner width and polynomial in depth and bounded-weight teacher resources. It controls the final posterior for clean data under a fixed Gaussian likelihood. A separate statement controls expected averaged predictive KL for matched Gaussian observation noise. These are conventional variational proofs, not consequences of SLT coefficients or Lean-verified main results.

One agent constructed the selective Gaussian witness; the parent independently checked its layerwise error and KL costs. A separate agent checked the noisy-data argument, then the clean-data final-posterior extension and strict confidence threshold. The [mathematical review](../works-in-progress/slt-finite-sample/verification/README.md) records the checks and scope. Additional agents reviewed the FAQ's mathematical and source claims. The construction was prompted by Kaarel Hänni's suggestion to calculate prior mass near a small implementation and by the two Claude reports listed above.

A further primary source is Wang and Yang, [PAC-Bayes Bounds for Gibbs Posteriors via Singular Learning Theory](https://arxiv.org/abs/2604.17219), April 2026, Theorem 5, equations (9)–(10), and Theorem 7. Its finite-sample integral bound uses a global moment condition. The coefficient-based version leaves an additive constant uncontrolled in width; the neural specialization also requires a uniform output bound. We checked these statements and their scope, not the entire paper. Thus a field-wide assertion that no finite-sample PAC-Bayes/SLT bounds exist would be incorrect.

### The width cost of the ReLU neighborhood certificate

In the essential set constructed in Nagayasu–Watanabe (2023), equations (57)–(61), the blocks feeding redundant neurons in an internal layer have negative coordinates. If that layer has learner width $N$ and active width $C$, the two incoming blocks contain $(N-C)N$ such weights. Under independent centered Gaussian coordinates, the sign event has probability $2^{-(N-C)N}$. The additional interval constraints can only reduce its probability.

For every comparison distribution supported on this set,

$$
\mathrm{KL}(\rho\Vert\pi)\ge-\log\pi(W_E)
\ge(N-C)N\log 2.
$$

The first inequality follows by writing the KL relative to the prior conditioned on $W_E$. This lower-bounds the cost of **that particular certificate**. It does not lower-bound the learner's error, the best available variational certificate, or an optimally chosen additive constant in the theorem. Other neighborhoods or unions of neighborhoods could do better. Changing Gaussian coordinate variances alone does not remove the sign cost.

### Identical local information does not give a uniform sample threshold

Here is an explicit stronger obstruction. The model has parameter $\theta\in[-2,2]$, observations $Y_i\mid\theta\sim\mathcal N(\theta,1)$, and truth $\theta=1$. Fix a smooth probability density $g$ supported inside $I=[-1.1,-0.9]$. For any integer $T\ge2$, put

$$
\delta_T=e^{-10T-10},\qquad \eta_T=\delta_T^2,\qquad c=1/4.
$$

Choose a smooth cutoff $\chi_T$ equal to one on $|\theta-1|\le\delta_T$, zero on $|\theta-1|\ge2\delta_T$, and between zero and one elsewhere. Define the density on $[-2,2]$ by

$$
\pi_T(\theta)=c\chi_T(\theta)+\eta_T[1-\chi_T(\theta)]+a_T g(\theta),
$$

where

$$
a_T=1-c\int_{-2}^{2}\chi_T(\theta)\,d\theta
-\eta_T\left(4-\int_{-2}^{2}\chi_T(\theta)\,d\theta\right).
$$

This is normalized and strictly positive, with $a_T\ge1/2$. Every density is exactly the same constant $c$ on a neighborhood of the truth. Consequently they have identical local germs and derivatives, regular coefficients $\lambda=\nu=1/2$, multiplicity one, and the same local Laplace constant. More explicitly, for each fixed $T$ there is $b_T>0$ such that

$$
\int_{-2}^{2} e^{-n(\theta-1)^2/2}\pi_T(\theta)\,d\theta
=c\sqrt{2\pi/n}+O_T(e^{-b_T n}).
$$

To see this, compare with the constant-density Gaussian integral on the real line. The integrands agree within distance $\delta_T$ of the truth; all remaining terms are exponentially small for fixed $T$. Thus even all algebraic correction coefficients in this population Laplace expansion agree. The exponential remainder scale is not uniform in $T$.

At sample size $n=T$, the sample mean belongs to $[0,2]$ with probability at least $1-2e^{-T/2}$. On this event, the likelihood factor $e^{-T(\theta-\bar Y)^2/2}$ is at least $e^{-4.805T}$ throughout $I$. The posterior normalizer is at least $a_T e^{-4.805T}$. The prior mass outside $I$ is at most $\delta_T+4\delta_T^2\le2\delta_T$, and the likelihood factor is everywhere at most one. Hence

$$
Q_T(\theta\notin I\mid Y_1,\ldots,Y_T)
\le4\delta_T e^{4.805T}\le e^{-5T}.
$$

The posterior is therefore concentrated near negative means despite truth $+1$. Its Gibbs excess KL on this event is at least

$$
\frac{1.9^2}{2}(1-e^{-5T}).
$$

Learning can thus be delayed past arbitrarily large $T$ without changing the local germ or these asymptotic invariants. The priors are smooth, not globally analytic; a positive smooth prior factor is allowed in common SLT hypotheses. The simpler Gaussian-prior calculation already handles a familiar globally analytic prior family when only the usual leading coefficients are fixed.

The neighborhoods on which the priors agree shrink with $T$. A theorem prescribing a fixed common neighborhood or its finite-scale prior mass would see the missing information and is not contradicted. This is exactly why a quantitative finite-volume argument remains possible, whereas the local asymptotic data alone cannot give a uniform sample threshold.
