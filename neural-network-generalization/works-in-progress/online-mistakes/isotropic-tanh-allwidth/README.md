# Superpolynomial online mistakes for isotropic Bayesian tanh networks

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Build and proof status](verification/README.md)

This paper proves an adversarial online lower bound for **ordinary tanh**, with one hidden layer, a linear readout, and independent Gaussian weights isotropic within each layer.

There are Boolean targets with same-depth tanh teachers of width `C`, margin one, and coefficients bounded by `C`, and fixed nonrepeating input sequences with **exp(Ω(√C / log C)) designated mistakes**. At every sufficiently large fixed learner width, the actual posterior probability of the correct label tends to zero at each designated round in the strong-prior limit. For each such fixed width, sufficiently small positive Gaussian scales also make all designated posterior-majority predictions wrong; under fresh posterior sampling, all designated predictions are wrong simultaneously with probability arbitrarily close to one.

The prior is conditioned from the start on an absolute output margin greater than `1/2` at every input of the full Boolean cube. For each revealed Boolean label `yᵢ`, training conditions on `yᵢF(xᵢ) > 1/2`: the output has the correct sign and margin, while its real value remains free. The sequence can be extended to a permutation of the cube. It has a large calibration prefix, and the sufficiently large width threshold is existential. This concerns adversarial input order, not iid sample complexity.

The construction has input dimension `d = Θ(m log² m)`, teacher width `C = O(m² log² m)`, a Boolean circuit with `O(d)` gates, and `exp(Ω(m))` designated mistakes. A triangular path transfer gives strictly ordered competing costs. A joint parity estimate for all rail pairs permits rails of size `O(log² m)`.

The paper includes the complete argument: the sharp global affine single-parity theorem, polynomial support stability, a sharp weighted norm for a transversal code, optimized competing scores, physical calibration and rounding, and the finite-width Gaussian posterior comparison. The analytic proof includes the periodic-response, lattice-localization, residual central-limit, and equal-bulk bias estimates. The positive curvature certificate uses exact rational arithmetic; its source is included under `verification/`.

The improved main theorem and its finite-scale prediction consequences are **Lean verified**, using the actual Gaussian posterior and only Lean's standard axioms. Independent reviews checked the correspondence between the paper and the formal statements. [Main Lean theorem](../../../lean/NeuralGeneralization/OnlineLowerTanhMain.lean) · [Exact statement and axiom checks](../../../lean/CheckOnlineLowerTanh.lean) · [Verification scope](verification/README.md). A [full-paper coverage inventory](../../../lean/review/OnlineLowerTanh-full-paper-coverage.md) maps all 32 numbered mathematical results to their formalizations and states the exclusions for illustrative decimal values and intermediate proof identities. The extensions include the three-bit theorem, optimizer equality classifications, exact support constants, generic weighted-Fourier optimization, and residual approximations with derivatives of every fixed order.

Run `bash build.sh` to rebuild the PDF with pdfLaTeX. Run `python verification/certify_curvature.py` to repeat the rational curvature certificate.

Companion results give [exp(Ω(√C)) mistakes for ReLU and softplus](../isotropic-relu-allwidth/README.md) and [exp(Ω(C^(1/3))) for hardtanh](../isotropic-hardtanh-allwidth/README.md).
