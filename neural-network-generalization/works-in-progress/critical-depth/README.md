# Depth dependence of Gaussian prior costs in critical neural networks

**Status:** Non-main research draft / work in progress

At gamma = 1, studies depth-dependent variational costs, target comparisons, and a polynomial width-first parity sample lower bound. Absolute prior-cost statements are distinguished from learning lower bounds. These results remain outside the main-results list.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/critical-paper.tex) · [Collection index](../../README.md)

The controlled-feature construction gives polynomial teacher-depth dependence in the critical prior-rate upper bound for arbitrary bounded-weight, globally margined tanh teachers on Boolean inputs. It preserves the original Gaussian prior. All parities attain a bounded rate already at depth of order the square of the logarithm of input dimension, matching the universal necessary depth scale.

A separate sample-dependent bound shows that the actual width-first posterior concentrates on functions whose rates exceed the common limit by at most a squared logarithm of sample size, dimension, and depth, divided by depth. These results sharpen the remaining comparison between accurate and inaccurate sample-consistent functions; they do **not** yet give a joint polynomial-depth learning theorem. The exact formulas are in [FAQ Question 17](../../TECHNICAL-FAQ.md#17-what-does-the-critical-depth-result-imply-about-learning).

The excess rate is sharply controlled for constants, dictators, and parities: it is of order `(log d)^2 / L` between a sufficiently large logarithmic depth and a sufficiently small fixed power of dimension. The lower bound applies to every Boolean function. Its proof bounds the sum of square roots of layer entropies after accounting for the common scalar baseline.

The entropy estimate also gives a [covariance and output transfer theorem](source/critical-bures-transfer.tex): its amplification factor is at most a polynomial in depth times `exp(C sqrt(L epsilon))`, where `epsilon` is the excess rate. Free layers are nonexpansive in the chosen Gaussian-coupling distance. This controls propagation of approximation error; constructing an adequately small network approximation remains a separate problem.

There is also an **actual posterior learning lower bound** for full parity through depths `L <= c eta log(d) / log log(d)`: at `n <= d^((1-eta)/(L-1))`, limiting Gibbs error is one half and the confidence-error lower limit is at least one quarter, with high training probability. This extends the fixed-depth comparison and includes mixtures of minimizers. It is not an exponential sample lower bound in teacher depth.

Structural sections identify what remains missing: the entropy decomposition gives a shallow representation when the conditional entropy outside one selected pair vanishes, and translation-invariant terminal kernels admit a separate product bound. A fixed three-bit example shows why small positive entropy alone gives no depth-uniform version. General critical-rate-to-representation compression remains open.

## Scope and status

This paper is a non-main research draft for informal public sharing. Its results may be useful independently, but it is not included among the promoted main results. Mathematical audit notes are retained under `verification/`; they are independent AI-agent reviews, not a claim of Lean formalization.

[Technical FAQ](../../TECHNICAL-FAQ.md)

## Build

Run `bash build.sh` from this directory with a standard TeX Live installation. It runs three LaTeX passes in `build/` and refreshes `paper.pdf`. All LaTeX inputs and figures are included under `source/`; no network access is needed.

`verification/source-provenance.json` lists the original source hashes. The publication build check compares extracted PDF text with the preserved manuscript.

The [latest Boolean-depth revision record](../../verification/boolean-depth-structure-2026-10-18.json) records the current source and PDF hashes and matching isolated rebuild. Independent mathematical audits are in `verification/`; the [earlier revision record](../../verification/boolean-depth-progress-2026-10-18.json) preserves the Fourier, posterior-ceiling, and circuit-construction snapshot. These additions are not Lean verified.
