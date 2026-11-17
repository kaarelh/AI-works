# Low-degree all-width learning for shallow NNBayes

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Reviewed derivation](source/derivation.md) · [Independent review](../verification/independent-review.md#shallow-theorem)

For a teacher with one tanh hidden layer, the sample bound is affine in its weighted squared norm, with an additional dimension cost, independently of the learner's width. It holds simultaneously for every `N >= C` and every mean-field-or-stronger scale.

Here `C` is teacher width, `N` learner width, and `d` input dimension. For hidden matrix `W` and readout vector `a`, the teacher energy is

$$
\kappa_C=\frac dC\lVert W\rVert_F^2+C\lVert a\rVert_2^2.
$$

With test-error tolerance `epsilon` and sample failure probability `delta`, the dimension-sharpened summary is `soft-O((d(kappa_C+d)+log(1/delta))/epsilon)`, where `soft-O` suppresses logarithmic factors. The additive `d²` term comes from the target-neighborhood estimate and cannot simply be absorbed into the teacher norm.

The theorem allows the **raw Gaussian prior**, the globally margin-conditioned prior, and the specified shallow robust prior. All versions condition on strict signed training outputs above `1/2` and control posterior average test-margin failure at `1/4`. The raw-prior result is not a claim about Gaussian regression, logistic likelihoods, or conditioning only on training signs.

When teacher hidden coefficients are at most `C` and readout coefficients are bounded independently of `C`, the width dependence is quadratic. Under the original complexity convention allowing those coefficients to reach `C`, the sufficient bound is quartic. The paper includes both a simple finite-cube count and a sharper dimension bound proved through relative growth functions.

Independent AI-agent review checked the proof, including the sharper dimension bound and raw-prior extension. Its main learning statements are Lean verified; it has not received full human mathematical review. The publication source adds a complete robustness-event definition and a standalone presentation to the reviewed derivation.

Run `./build.sh` to rebuild `paper.pdf` with `pdflatex`. Pandoc is not needed. See the [collection overview](../README.md) for the other improved bounds.

## Lean verification

The three numerical sample budgets and their readout-norm, weighted-energy, and quadratic resource consequences have Lean proofs. The [current coverage record](../../../lean/review/coverage-completion-2026-11-15.txt) supersedes the corresponding exclusions in the [earlier endpoint map](../../../lean/review/BatchTwo-coverage.md); the [Lean entry point](../../../lean/NeuralGeneralization/BatchTwoMain.lean) identifies the original main statements. Dated mathematical reviews describe their own source snapshots. This coverage concerns the stated results, not every informal calculation in the manuscript.
