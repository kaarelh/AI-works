# Online mistake lower bounds at arbitrary width

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification and exact scope](verification/README.md)

Two nonlinear variants give exponentially many online mistakes on a Boolean target with a small circuit, at arbitrarily large learner widths. **The fully nonlinear, fixed-activation tanh/ReLU/GELU problem with an appended constant input remains open.**

Both results use independent Gaussian weights, a strict absolute output margin greater than 1/2 on every Boolean input, exact training-label conditioning, and the strong-prior limit at each fixed learner width. The input sequence is fixed, has no repetitions, and can be completed to a permutation of the cube.

| Result | Activation and architecture | Widths | Restriction |
|---|---|---|---|
| Near-identity theorem | The same nonlinear activation in every hidden layer; appended constant input | Every fixed `N ≥ 1` | The activation must approach identity as target size grows. The required closeness is independent of `N`. |
| One-nonlinear-layer theorem | Fixed GELU, SiLU, ReLU, leaky ReLU, or softplus in the first hidden layer; all later hidden layers linear | Every fixed `N ≥ 2` | No appended constant input and no biases. |

For a target of Boolean circuit size Θ(k), both theorems force at least `2^k − k − 1` mistakes. At every depth `L ≥ k+2`, the target has a teacher whose hidden width and every coefficient are bounded by two, and its bounded-width-and-weight complexity is exactly two. Thus both results apply at every learner width above that complexity. The sufficiently small positive prior scale may depend on width; neither theorem interchanges the width and strong-prior limits.

The conclusion concerns the actual posterior, including mixtures of tied energy minimizers. At a sufficiently small common positive scale, the probability that posterior sampling makes all designated mistakes is arbitrarily close to one. Posterior majority is wrong, and the strict 2/3 confidence criterion fails, on those rounds as well. These are cumulative online-error lower bounds, not iid sample-complexity lower bounds.

For the near-identity family, the very same learner has an iid upper bound of `O((d² + log(1/η))/ε)` examples, at every width and depth, with failure probability `η` and strict 2/3 confidence on a test set of measure at least `1−ε`. The small-prior-scale threshold may depend on width and depth. This gives an explicit polynomial-iid versus exponential-online separation without changing the prior between the two protocols.

The first theorem also covers smooth activations such as `(1−ε)t + ε tanh(t)`. Its sufficient upper bound on `ε` is of order `8^(−k)/[(L−1)k^(3/2)]`. An improved variant permits the larger deviation `O(4^(−k)/[(L−1)√k])` while forcing `2^(k−1)` mistakes on the last half of the same sequence. The iid upper bound and teacher complexity two apply to this variant as well. Both bounds still require the activation to approach identity as the target grows; neither establishes the same result for one fixed standard activation.

The paper includes two tanh energy comparisons explaining why wider learners need a new argument. For every `k ≥ 128` and `N ≥ 2`, a simple three-bit function fits the entire proposed query suffix more cheaply than any scalar realization of the affine candidate. A separate exact rational certificate proves a similar comparison for the full target at `k=3` and every `N ≥ 64`. Neither comparison determines the wider posterior's predictions or lower-bounds all wider implementations of the wrong function.

Run `bash build.sh` to rebuild the PDF. Run `python3 verification/check_finite_certificate.py` for the exact rational certificate; it needs only Python's standard library.

**Status:** conventional proofs with independent AI-agent mathematical checks; not Lean formalized and not human peer reviewed. This is a supporting research note, not a resolution of the remaining fixed-activation question.

Authors: ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob.[^authors]

[^authors]: Authors are listed in alphabetical order.
