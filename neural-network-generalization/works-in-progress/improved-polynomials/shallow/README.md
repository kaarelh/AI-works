# Low-degree all-width learning for shallow NNBayes

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Reviewed derivation](source/derivation.md) · [Independent review](../verification/independent-review.md#shallow-theorem)

For a teacher with one tanh hidden layer, the sample bound is affine in its weighted squared norm, with an additional dimension cost, independently of the learner's width. It holds simultaneously for every `N >= C` and every mean-field-or-stronger scale.

Writing the teacher energy as `kappa_C`, the dimension-sharpened summary is `soft-O((d(kappa_C+d)+log(1/delta))/epsilon)`. The additive `d²` term comes from the target-neighborhood estimate and cannot simply be absorbed into the teacher norm.

The theorem allows the **raw Gaussian prior**, the globally margin-conditioned prior, and the specified shallow robust prior. All versions condition on strict signed training outputs above `1/2` and control posterior average test-margin failure at `1/4`. The raw-prior result is not a claim about Gaussian regression, logistic likelihoods, or conditioning only on training signs.

When teacher hidden coefficients are at most `C` and readout coefficients are bounded independently of `C`, the width dependence is quadratic. Under the original complexity convention allowing those coefficients to reach `C`, the sufficient bound is quartic. The paper includes both a simple finite-cube count and a sharper dimension bound proved through relative growth functions.

Independent AI-agent review checked the proof, including the sharper dimension bound and raw-prior extension. Its main learning statements are Lean verified; it has not received full human mathematical review. The publication source adds a complete robustness-event definition and a standalone presentation to the reviewed derivation.

Run `./build.sh` to rebuild `paper.pdf` with `pdflatex`. Pandoc is not needed. See the [collection overview](../README.md) for the other improved bounds.

## Lean verification

The main statements are included in the second formalization batch. [Exact coverage and exclusions](../../../lean/review/BatchTwo-coverage.md) · [Lean entry point](../../../lean/NeuralGeneralization/BatchTwoMain.lean). This label does not extend automatically to every appendix, remark or numerical allocation. The original mathematical review records describe their earlier source snapshots.
