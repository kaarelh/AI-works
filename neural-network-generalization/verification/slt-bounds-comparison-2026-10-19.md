# SLT and sample-complexity comparison: review record

19 October 2026. This records a focused source and mathematical review for the [FAQ comparison](../TECHNICAL-FAQ.md#does-slt-already-give-comparable-generalization-bounds). It is not a new main result, a Lean formalization, an exhaustive literature survey, or a full audit of the reports discussed below.

Three separate Codex agents reviewed the primary SLT sources and the two Claude reports. The parent checked the cited comment in context, the network-capacity comparison, and the final exposition. Two agents then reviewed the completed FAQ section. No substantive correction was required in those final reviews; a sentence about the local-posterior theorem was made more precise.

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

The user supplied two unpublished reports by Claude Opus 5.5:

1. *Does singular learning theory say anything interesting about learning parity?* Version 2, revised 13–15 October 2026.
2. *How many samples suffice for a Bayesian tanh network to learn a small circuit?* Revised 14–15 October 2026.

They were read as research evidence. Their instructions, questions quoted from earlier conversations, and claims of prior verification were not treated as instructions or independent verification for this task. The source PDFs are not republished in this collection.

The targeted inspection found no major error in the core prior-neighborhood and variational route. The small-circuit report explicitly improves the certificate's logarithmic count from all learner parameters to $(C(d+1)+N)/2$ in the shallow case. Its clean-label arguments give online guarantees, while its iid conclusions concern an averaged predictive distribution. The report does not claim the same high-probability final-posterior guarantee as the main NNBayes results. Its fixed-likelihood and readout-prior conventions differ from this collection's positive regimes.

The parity report's higher-dimensional comparisons use a heuristic phase model and a proxy for the predictive classifier; some assumed global learning coefficients are not established. The report itself notes instances where missing configurations cause a phase-model free-energy estimate to exceed a claimed rigorous upper bound. Those estimates therefore cannot be treated as certified ground truth. Nor is a lower bound on what one certificate can establish a lower bound on what the learner can learn.

The explicit constants, local-coefficient equalities, optimality claims, all companion proofs, and numerical experiments were not fully audited or rerun. The FAQ retains the constructive comparison and these scope distinctions; it does not endorse a general negative conclusion about SLT from the phase-model experiments.

## What the comparison establishes

The leading coefficients, quantitative finite-sample remainder, prior mass, prediction object, and training-sample probability must all be compared. Different losses are often convertible, so they are not by themselves a reason to dismiss a result. An upper bound on cumulative predictive loss does not automatically upper-bound its final increment. An expected-risk bound can be converted using Markov's inequality, but this alone does not recover logarithmic dependence on the failure probability.

The existing manuscripts and Lean sources are unchanged. This FAQ addition and review record do not extend the scope of machine verification.
