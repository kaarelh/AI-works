# A polynomial-depth learning bound for NNBayes on robust networks

**Status:** Main result; public research draft

**Authors:** Dmitry Vaintrob, Kaarel Hänni, OpenAI Codex, and Claude.

Can Bayesian neural networks learn small circuits with sample complexity polynomial in circuit width and depth? This paper proves such a bound after restricting the Gaussian prior to networks whose clipped predictions are stable under calibrated internal perturbations. One polynomial works jointly in input dimension, layered Boolean-circuit width, learner depth, robustness calibration, and statistical parameters, simultaneously at every learner width above circuit width and every Gaussian scale in the stated family, including all $\gamma\ge1$. The full joint polynomial result without this additional restriction remains open.

The paper defines the learning setup and restriction before stating the theorem, then gives the statistical proof and robust target construction. Certificates, variants, and detailed experiments are collected in appendices. Training requires signed output above $1/2$; test error is measured at margin $1/4$, which also controls sign error. No global clean-output margin is assumed.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/robustness-paper.tex) · [Collection index](../../README.md)

## Formal verification status

The [exact qualitative main learning theorem](../../lean/NeuralGeneralization/RobustStatements.lean) has a [closed Lean proof](../../lean/NeuralGeneralization/RobustMain.lean), using only `propext`, `Classical.choice`, and `Quot.sound`. It has no unproved compression or analytic premise. The [verification record](../../lean/VERIFICATION.md) documents the independent project-source rebuild and exact-type checks.

The formal proof uses a looser Pinsker-and-energy construction and verifies a sufficient universal polynomial bound. This does not certify the manuscript's sharper constants, optional extra all-input-margin learning variant, other extensions, or every appendix. Its comparator is the stated layered Boolean circuit, not every small analog neural circuit.

The empirical findings are separate from the learning theorem: trained-network accuracy does not validate a Bayesian posterior guarantee. Exact integer/interval certificates are computational proofs with their own documented trusted components, not Lean proofs.

[Empirical source and reproduction scope](../../works-in-progress/depth-experiments/README.md) · [Technical FAQ](../../TECHNICAL-FAQ.md)

## Build

Run `bash build.sh` from this directory with a standard TeX Live installation. It runs three LaTeX passes in `build/` and refreshes `paper.pdf`. All LaTeX inputs and figures are included under `source/`; no network access is needed.

[Source provenance](verification/source-provenance.json) retains the original source hashes and the editorial revision history. The [latest editorial build record](../../verification/robust-abstract-revision-2026-10-18.json) checks an independent rebuild against the published PDF text and verifies that the mathematical source files are unchanged.
