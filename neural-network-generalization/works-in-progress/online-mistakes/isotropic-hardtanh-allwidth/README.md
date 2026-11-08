# Superpolynomial online mistakes for isotropic Bayesian hardtanh networks

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Build and proof status](verification/README.md)

This paper proves an adversarial online lower bound for the bounded activation `hardtanh(t) = max(-1, min(1, t))`.

There are Boolean targets with same-depth, one-hidden-layer hardtanh teachers of width `C`, margin one, and coefficients bounded by `C`, and fixed nonrepeating input sequences with **exp(Ω(C^(1/3))) designated mistakes**. At every sufficiently large fixed learner width, the actual posterior probability of the correct label tends to zero on each designated round in the strong-prior limit.

The prior has independent Gaussian coordinates and is isotropic within each layer. It is conditioned on an absolute output margin greater than `1/2` everywhere on the full Boolean cube; training conditions on `yᵢF(xᵢ) > 1/2` for each revealed Boolean label. The real-valued output is not fixed to the label value. The sequence has a large calibration prefix, and the sufficient width threshold is large. The theorem concerns adversarial input order, not iid sample complexity. For the smooth activation tanh, see the [separate result](../isotropic-tanh-allwidth/README.md).

The proof includes an exact unequal-rail hardtanh norm and polynomial stability, an explicit dual for the optimized competing scores, exact ordering by square-root independence, and a finite-width Gaussian posterior argument. The atomic argument is self-contained: a monotone finite-difference estimate for ReLU coefficients and a shared-coordinate Cauchy inequality give the hardtanh norm. The scalar ordering uses a path transfer matrix and exact square-root independence. The atomic proof has received independent AI-agent mathematical audits; the new path and retained-code steps have also been checked independently of their drafting agent. The paper has not been formalized in Lean.

Run `bash build.sh` from this directory to rebuild the PDF with pdfLaTeX.
