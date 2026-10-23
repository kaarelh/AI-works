# A polynomial-depth learning bound for NNBayes on robust networks

**Status:** Main result; public research draft

**Authors:** ChatGPT-6 Astra, Claude Fable 5 and Opus 5, Kaarel Hänni, and Dmitry Vaintrob (alphabetical order).

Can Bayesian neural networks learn small circuits with sample complexity polynomial in circuit width and depth? This paper proves such a bound after restricting the Gaussian prior to networks whose clipped predictions are stable under calibrated internal perturbations. One polynomial works jointly in input dimension, layered Boolean-circuit width, learner depth, robustness calibration, and statistical parameters, simultaneously at every learner width at least the circuit width (N >= C) and every Gaussian scale in the stated family, including all $\gamma\ge1$. The full joint polynomial result without this additional restriction remains open.

The paper defines the learning setup and restriction before stating the theorem, then gives the statistical proof and robust target construction. Certificates, variants, and detailed experiments are collected in appendices. Training requires signed output above $1/2$; test error is measured at margin $1/4$, which also controls sign error. No global clean-output margin is assumed.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/robustness-paper.tex) · [Collection index](../../README.md)

## Formal verification status

The [exact qualitative main learning theorem](../../lean/NeuralGeneralization/RobustStatements.lean) has a [closed Lean proof](../../lean/NeuralGeneralization/RobustMain.lean), using only `propext`, `Classical.choice`, and `Quot.sound`. It has no unproved compression or analytic premise. The [verification record](../../lean/VERIFICATION.md) documents the independent project-source rebuild and exact-type checks.

The formal proof uses a looser Pinsker-and-energy construction and verifies a sufficient universal polynomial bound. This does not certify the manuscript's sharper constants, optional extra all-input-margin learning variant, other extensions, or every appendix. Its comparator is the stated layered Boolean circuit, not every small analog neural circuit.

The empirical findings are separate from the learning theorem: trained-network accuracy does not validate a Bayesian posterior guarantee. Exact integer/interval certificates are computational proofs with their own documented trusted components, not Lean proofs.

[Empirical source and reproduction scope](../../works-in-progress/depth-experiments/README.md) · [Technical FAQ](../../TECHNICAL-FAQ.md)

## Sharper polynomial bounds

A [new standalone paper](../../works-in-progress/improved-polynomials/original-support-all-scales/paper.pdf) keeps this prior restriction unchanged and gives $O(C^6\log^{13}(2+C))$ at fixed remaining parameters for every $\gamma\ge1$ and every $N\ge C$. It has a conservative joint degree-46 envelope, replacing the manuscript's degree-510 estimate. Its new compression argument and exponents have independent AI-agent review but are **not Lean verified**; the formal theorem and its sufficient budget remain unchanged. The [companion package](../../works-in-progress/improved-polynomials/) also contains a quartic stronger-scale bound and quadratic bounds under additional assumptions.

## Build

Run `bash build.sh` from this directory with a standard TeX Live installation. It runs three LaTeX passes in `build/` and refreshes `paper.pdf`. All LaTeX inputs and figures are included under `source/`; no network access is needed.

[Source provenance](verification/source-provenance.json) retains the original source hashes and the editorial revision history. The [latest editorial build record](../../verification/robust-abstract-revision-2026-10-18.json) checks an independent rebuild against the published PDF text and verifies that the mathematical source files are unchanged.
