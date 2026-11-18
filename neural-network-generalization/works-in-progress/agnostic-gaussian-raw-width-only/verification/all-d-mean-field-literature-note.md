# Focused primary-literature check: all-dimensional finite Gaussian tanh oracle

Reviewer: fresh_reader_approximation. Date: 18 November 2026. Scope: approximately twenty minutes of primary-source checking, not an exhaustive novelty search.

The closest verified literature already establishes entropy-regularized mean-field learning, generalization bounds, and finite-particle Gibbs approximation. I did not find in this focused check a theorem with the full combination of the present result: the actual finite-width correlated Gaussian posterior, raw linear readout, high-probability random-design risk with exact comparator coefficient one, explicit polynomial dimension/teacher resources, and uniformity over every eligible finite width and every native scale nu<=1. This is a scope comparison, not a first-ever claim.

## Closest references

1. Atsushi Nitanda (2024), **Improved Particle Approximation Error for Mean Field Neural Networks**, NeurIPS 2024. [Primary paper](https://arxiv.org/pdf/2405.15767); [proceedings](https://papers.nips.cc/paper/2024/hash/ce5f18eba5e5e9c7c166062300c677c3-Abstract-Conference.html).

Theorem 1 bounds the finite-particle stationary Gibbs regularized-objective gap by L R²/(2N), and also controls relative entropy to the product mean-field optimum. This is genuinely finite-Gibbs prior work. Its Assumption 1 imposes globally bounded/Lipschitz first-variation gradients, and Assumption 3 gives a smooth-loss/feature-moment condition. The raw neuron G phi(theta dot x) does not automatically meet the bounded-gradient requirement. The theorem concerns an objective gap, rather than the present high-probability random-design risk oracle. Its convexity/Bregman and finite-particle variance arguments deserve attribution.

2. Atsushi Nitanda, Denny Wu, Taiji Suzuki (2022), **Convex Analysis of the Mean Field Langevin Dynamics**, AISTATS, PMLR 151:9741–9757. [Primary proceedings and PDF](https://proceedings.mlr.press/v151/nitanda22a.html).

This supplies convex analysis and convergence guarantees for entropy-regularized mean-field Langevin dynamics using proximal Gibbs distributions. It is appropriate background for the entropy/convexity viewpoint, rather than a directly matching finite raw-posterior oracle.

3. Naoki Nishikawa, Taiji Suzuki, Atsushi Nitanda, Denny Wu (2022), **Two-layer neural network on infinite-dimensional data: global optimization guarantee in the mean-field regime**, NeurIPS 2022. [Primary PDF](https://proceedings.neurips.cc/paper_files/paper/2022/file/d2155b1f7eb42350d7bc3013eefe5480-Paper-Conference.pdf).

The model uses bounded neuron h_theta(x)=sigma_1(a)sigma_2(<w,x>) and KL regularization relative to a Gaussian reference. It combines mean-field optimization with generalization guarantees, including a classification theorem in the main text. The optimized predictor is the mean under a single-neuron measure; this is different from the finite correlated full-network Gibbs distribution. Thus neither Gaussian-reference mean-field learning nor its generalization analysis should be portrayed as new here.

4. Gholamali Aminian, Samuel N. Cohen, Łukasz Szpruch (2023 preprint), **Mean-field Analysis of Generalization Errors**, arXiv:2306.11623. [Primary paper](https://arxiv.org/pdf/2306.11623).

Sections 4–5 analyze weak and L2 generalization of a KL-regularized measure minimizer, including raw neurons a phi(w dot x). They obtain O(1/n) generalization-gap bounds with temperature-dependent constants and an expected population-risk balance of order n^-1/2. The measure solves a nonlinear Gibbs fixed point for risk of its mean predictor, rather than the finite full-network posterior. Assumption 5 requires a confining potential U growing faster than ||theta||^p for p>=2, which excludes the ordinary quadratic Gaussian potential from that stated neural specialization. This is important related generalization work, but does not directly provide the present theorem.

## Tools to credit explicitly

- Nathan Srebro, Karthik Sridharan, Ambuj Tewari (2010), **Smoothness, Low-Noise and Fast Rates**, NeurIPS 2010, Theorem 1. [Primary PDF](https://www.cs.cornell.edu/~sridharan/smoothness.pdf). This is the actual smooth-loss relative-risk ingredient in AD6, with worst-case Rademacher complexity; the deterministic ridge-hull bound supplies its hypothesis.
- The earlier note in this directory verifies Bach (2017) for convex ridge/variation classes and finite atomic representers; Caputo–Parisi (2021) for product-reference subset relative entropy; and Tinsi–Dalalyan (2022) for Gaussian-prior shallow-network aggregation. The latter distinguishes fixed-design final exponential weighting from random-design mirror averaging.

## Suggested concise related-work paragraph

Entropy-regularized mean-field learning and its generalization theory are well established, including the convex analysis of Nitanda, Wu and Suzuki (2022), Gaussian-reference mean-field learning of Nishikawa et al. (2022), and the generalization analysis of Aminian, Cohen and Szpruch (2023). Nitanda (2024) also proves an explicit finite-particle stationary Gibbs objective bound. The result here concerns the actual finite-width correlated Gaussian posterior with an unbounded linear readout and gives a high-probability random-design oracle, using product-subset relative entropy and the smooth-loss complexity bound of Srebro, Sridharan and Tewari (2010). The proof uses established entropy and empirical-process tools; no global priority claim is made.

## Search limits

Primary sources above were inspected through the public web tool. This was a focused comparison, not a systematic survey of all PAC-Bayesian neural-network or statistical-mechanics literature. No paper was ruled out solely by its abstract. No claim of novelty should be inferred from not finding a direct match.
