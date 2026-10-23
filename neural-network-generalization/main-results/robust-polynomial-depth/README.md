# A polynomial-depth learning bound for NNBayes on robust networks

**Status:** Main result; public research draft

**Authors:** ChatGPT-6 Astra, Claude Fable 5 and Opus 5, Kaarel Hänni, and Dmitry Vaintrob (alphabetical order).

Can Bayesian neural networks learn small circuits with sample complexity polynomial in circuit width and depth? This paper proves such a bound after restricting the Gaussian prior to networks whose clipped predictions are stable under calibrated internal perturbations. One polynomial works jointly in input dimension, layered Boolean-circuit width, learner depth, robustness calibration, and statistical parameters, simultaneously at every learner width at least the circuit width (N >= C) and every Gaussian scale in the stated family, including all $\gamma\ge1$. The full joint polynomial result without this additional restriction remains open.

The paper defines the learning setup and restriction before stating the theorem, then gives the statistical proof and robust target construction. Certificates, variants, and detailed experiments are collected in appendices. Training requires signed output above $1/2$; test error is measured at margin $1/4$, which also controls sign error. No global clean-output margin is assumed.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/robustness-paper.tex) · [Collection index](../../README.md)

## Formal verification status

The [qualitative main learning theorem for the formal circuit class](../../lean/NeuralGeneralization/RobustStatements.lean) has a [closed Lean proof](../../lean/NeuralGeneralization/RobustMain.lean), using only `propext`, `Classical.choice`, and `Quot.sound`. It has no unproved compression or analytic premise. The [verification record](../../lean/VERIFICATION.md) documents the independent project-source rebuild and exact-type checks.

The formal circuit reserves a counted constant-`+1` wire at every stage, including the final stage. As the paper's introduction explains, a width-one circuit computing anything other than constant `+1` under its prose convention needs formal width two; its learner-width-one case is not certified. The [statement audit](../../lean/review/statement-audit-2026-10-23/original-lower-robust.md) checks the actual model and this width qualification.

The formal proof uses a looser Pinsker-and-energy construction and verifies a sufficient universal polynomial bound. This does not certify the manuscript's sharper constants, optional extra all-input-margin learning variant, other extensions, or every appendix. Its comparator is the stated layered Boolean circuit, not every small analog neural circuit.

The empirical findings are separate from the learning theorem: trained-network accuracy does not validate a Bayesian posterior guarantee. Exact integer/interval certificates are computational proofs with their own documented trusted components, not Lean proofs.

[Empirical source and reproduction scope](../../works-in-progress/depth-experiments/README.md) · [Technical FAQ](../../TECHNICAL-FAQ.md)

## Sharper polynomial bounds

A [standalone paper](../../works-in-progress/improved-polynomials/original-support-all-scales/paper.pdf) keeps this prior restriction unchanged and gives $O(C^6\log^{13}(2+C))$ at fixed remaining parameters for every $\gamma\ge1$ and every $N\ge C$, using the same formal circuit-width convention. Its sixth-power width rate and conservative joint degree-46 envelope are **Lean verified in the second batch**. Its separate printed numerical `16/ε` allocation is outside that certification. The original proof and its degree-10974 budget remain available. The [companion package](../../works-in-progress/improved-polynomials/) also contains a quartic stronger-scale bound and quadratic bounds under additional assumptions, with their own verification scopes.

## Build

Run `bash build.sh` from this directory with a standard TeX Live installation. It runs three LaTeX passes in `build/` and refreshes `paper.pdf`. All LaTeX inputs and figures are included under `source/`; no network access is needed.

[Source provenance](verification/source-provenance.json) retains the original source hashes and the editorial revision history. The [latest editorial build record](../../verification/robust-abstract-revision-2026-10-18.json) checks an independent rebuild against the published PDF text and verifies that the mathematical source files are unchanged.
