# Superpolynomial online mistakes for isotropic Bayesian tanh networks

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Build and proof status](verification/README.md)

This paper proves an adversarial online lower bound for **ordinary tanh**, with one hidden layer, a linear readout, and independent Gaussian weights isotropic within each layer.

There are Boolean targets with same-depth tanh teachers of width `C`, margin one, and coefficients bounded by `C`, and fixed nonrepeating input sequences with **exp(Ω(C^(1/8))) designated mistakes**. At every sufficiently large fixed learner width, the actual posterior probability of the correct label tends to zero at each designated round in the strong-prior limit. For each such fixed width, sufficiently small positive Gaussian scales also make all designated posterior-majority predictions wrong; under fresh posterior sampling, all designated predictions are wrong simultaneously with probability arbitrarily close to one.

The prior is conditioned from the start on an absolute output margin greater than `1/2` at every input of the full Boolean cube. Training requires exact fit of every revealed label. The sequence can be extended to a permutation of the cube. It has a large calibration prefix, and the sufficiently large width threshold is existential. This concerns adversarial input order, not iid sample complexity.

The paper includes the complete argument: the sharp global affine single-parity theorem, polynomial support stability, a sharp weighted norm for a transversal code, optimized competing scores, a cycle construction with distinct costs, physical calibration and rounding, and the finite-width Gaussian posterior comparison. The analytic proof includes the periodic-response, lattice-localization, residual central-limit, and equal-bulk bias estimates. The positive curvature certificate uses exact rational arithmetic; its source is included under `verification/`.

The results received independent AI-agent mathematical audits, including an integrated theorem/proof correspondence review. They have **not** been formalized in Lean. 

Run `bash build.sh` to rebuild the PDF with pdfLaTeX. Run `python verification/certify_curvature.py` to repeat the rational curvature certificate.

Companion results give [exp(Ω(√C)) mistakes for ReLU and softplus](../isotropic-relu-allwidth/README.md) and [exp(Ω(C^(1/3))) for hardtanh](../isotropic-hardtanh-allwidth/README.md).
