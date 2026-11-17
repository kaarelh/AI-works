# Exponential depth dependence in Bayesian neural-network regression

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Review and build records](verification/README.md) · [Collection index](../../README.md)

Exponential dependence on depth is necessary for a distribution-free, learner-width-independent regression guarantee under the unrestricted Gaussian prior. A tanh teacher of constant width and bounded weights can require exponentially many examples, even in input dimension two. The theorem concerns the actual Bayesian posterior, including mixtures of equally preferred fits.

## Result and conventions

Here `L` is network depth, `N` is learner width, and `γ` specifies the Gaussian scale `σ²=N^(-γ)`. The constant `c>0` in the sample ceiling below is independent of depth.

There is a fixed, nonatomic distribution on the unit circle and a sequence of teachers with depth $L$, width three, and weights bounded by 30. The teachers have bounded real outputs on the data support. Training observes their exact real-valued outputs and conditions the original Gaussian parameter prior on fitting each observation within $1/8$. Test success requires posterior probability strictly above $2/3$ of output error at most $1/4$. There is no robustness restriction or global output-margin conditioning.

For every sufficiently large depth and every specified sample size up to $\exp(cL)$, the posterior has a confidence-failure lower bound of one half, with training-sample probability at least $49/50$, in the following precise senses:

- **Strong-prior limit:** at every fixed learner width above an explicit polynomial in sample size, as the prior variance tends to zero. The sample-probability statement uses a lower limit in the variance.
- **Every fixed exponent above one:** at the actual scale $\sigma^2=N^{-\gamma}$, at every width above a polynomial in sample size and depth, whose degree can depend on $\gamma-1$.
- **Mean-field scaling:** at $\gamma=1$, the lower limit of the confidence-failure fraction is at least one half as width tends to infinity, on a sample event of probability at least $49/50$. This uses the same fixed nonatomic distribution. It does not give a quantitative width threshold.
- **Exact interpolation:** the same obstruction holds for every minimum-energy exact interpolant and every mixture of them. It also holds for posterior limits obtained by taking the strong-prior limit before sending the training tolerance to zero.

These are lower bounds at sufficiently large widths. They disprove a polynomial-depth guarantee claimed uniformly over all learner widths above teacher complexity; they do not say that every width is hard.

## Why the learner fails

Iterating a fixed expanding tanh map creates pairs of inputs whose distance shrinks exponentially with depth while their target outputs remain separated by a constant. A small random sample typically does not contain such close pairs. It can be fit exactly by a network with low weighted energy and a Lipschitz constant polynomial in sample size, independently of depth.

The posterior prefers that energy range. Every function in it must fail on at least one member of each close pair. A paired probability argument shows that posterior mixtures cannot repair the failure.

## What remains open

The input distribution is supported on a Cantor subset of the circle; it is not the uniform spherical distribution. A corollary replaces it with smooth densities that depend on depth. The result does not settle the original Boolean-cube classification problem, uniform spherical inputs, or the case of a fixed shallow target and an unnecessarily deep learner. It also does not identify the posterior conditioned directly on exact real outputs at a fixed nonzero prior scale.

The [unrestricted Boolean-depth investigation](verification/boolean-depth-investigation.md) records why several representation-based approaches still fall short. The [fixed-depth continuous-domain upper bound](../../side-results/continuous-domains/) remains valid: its depth dependence cannot in general be replaced by a universal polynomial in this unrestricted regression model.

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes and refreshes `paper.pdf`. No network access is needed.

## Lean verification

The main lower bounds, exact minimizers and their mixtures, actual iterated posterior limits, and the varying smooth-density construction have Lean proofs. The [current coverage record](../../lean/review/coverage-completion-2026-11-15.txt) and [detailed inventory](../../lean/review/coverage-extension-2026-10-30.txt) supersede the exclusions in the [earlier endpoint map](../../lean/review/BatchTwo-coverage.md). The [Lean entry point](../../lean/NeuralGeneralization/BatchTwoMain.lean) identifies the original main endpoints.

This is a supporting research result with independent AI-agent mathematical reviews, not external peer review. The [review and build records](verification/README.md) describe their dated source snapshots; formal coverage does not imply that every informal calculation has a separately named theorem.
