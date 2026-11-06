# Verification and exact scope

[Paper](../paper.pdf) · [Source](../source/paper.tex)

These are conventional mathematical proofs with independent AI-agent mathematical reviews; they are not Lean formalized.

- [Full manuscript review](full-paper-review.md) checks the assembled source, all-width energy comparisons, both calibration constructions, the exact projection-fiber count, actual posterior concentration, the common mean-field scale, the IID bound, and the prior-exponent corollary.
- [Quantitative review](quantitative-review.md) checks the explicit rigidity estimate, its constants, the perturbation amplitude, and the integrated linear-calibration theorem.

Both reviews identify the exact final source hash. The source incorporates the earlier width-one anisotropic construction through a citation to the [AND manuscript](../../and-gaussian/paper.pdf), while supplying all proofs needed for the new results.

The scope qualifications are part of the theorems:

- The activation is fixed standard tanh, with one hidden layer, a constant input coordinate, the full Boolean cube, absolute output margin greater than `1/2` everywhere, and exact label updates.
- The first-layer covariance is genuinely anisotropic: `λ_0 = 1` and `λ_i = 1 + δ 2^(-i)`. The perturbation may be arbitrarily small but is positive. The exactly isotropic question remains open.
- For every odd `d >= 17`, the first construction permits every fixed `δ` in `(0,1)` and forces at least `2^floor(d/8)` mistakes after a large calibration prefix.
- For odd `q >= 3` and `d = 9q`, the second construction uses exactly `2q` distinct calibration examples and forces exactly `9^((q+1)/2)` designated mistakes. It permits every `0 < δ <= 1/(80000 q³)`.
- The target is full majority, with Boolean circuit size `Θ(d)` and bounded-weight teacher complexity `C_2 = 1`. Every finite width `N >= 1` is covered, including all nonlinear competitors.
- In the canonical scale `σ`, the positive scale threshold may depend on width. In the mean-field parametrization `t = sqrt(N) σ`, one sufficiently small positive `t` works for every width. This statement is proved by a product-ball lower bound and a chi-squared tail upper bound, without exchanging width and small-noise limits.
- At every fixed prior exponent `γ > 1`, unit prefactor gives the conclusions at every sufficiently large width. A sufficiently small common prefactor gives them simultaneously for every width and every `γ >= 1`. The unit-prefactor case `γ = 1` is not covered.
- The same prior and target have a width-independent IID sample bound `O((d⁴ + log(1/β))/ρ)` for the mass of inputs failing strict `2/3` posterior confidence. Its small mean-field scale can also be chosen uniformly over widths and all target-consistent histories.
- Exact isotropy gives equal masses within the relevant minimum-energy majority tier and a logarithmic expected sampling-error bound before that tier is exhausted. This is not an upper bound for the entire isotropic online process.

Run `bash ../build.sh` from this directory to rebuild the published PDF. The [publication build record](publication-build.json) records source/PDF hashes, a clean isolated three-pass rebuild, extracted-text equality, author-order checks, local citation resolution, visual checks, and the absence of LaTeX warnings or unresolved references. Later source edits require corresponding review and build-record updates.
