# Depth dependence of Gaussian prior costs in critical neural networks

**Status:** Non-main research draft / work in progress

At gamma = 1, studies depth-dependent variational costs, target comparisons, and a polynomial width-first parity sample lower bound. Absolute prior-cost statements are distinguished from learning lower bounds. These results remain outside the main-results list.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/critical-paper.tex) · [Collection index](../../README.md)

The controlled-feature construction gives polynomial teacher-depth dependence in the critical prior-rate upper bound for arbitrary bounded-weight, globally margined tanh teachers on Boolean inputs. It preserves the original Gaussian prior. All parities attain a bounded rate already at depth of order the square of the logarithm of input dimension, matching the universal necessary depth scale.

A separate sample-dependent bound shows that the actual width-first posterior concentrates on functions whose rates exceed the common limit by at most a squared logarithm of sample size, dimension, and depth, divided by depth. These results sharpen the remaining comparison between accurate and inaccurate sample-consistent functions; they do **not** yet give a joint polynomial-depth learning theorem. The exact formulas are in [FAQ Question 17](../../TECHNICAL-FAQ.md#17-what-does-the-critical-depth-result-imply-about-learning).

## Scope and status

This paper is a non-main research draft for informal public sharing. Its results may be useful independently, but it is not included among the promoted main results. Mathematical audit notes are retained under `verification/`; they are independent AI-agent reviews, not a claim of Lean formalization.

[Technical FAQ](../../TECHNICAL-FAQ.md)

## Build

Run `bash build.sh` from this directory with a standard TeX Live installation. It runs three LaTeX passes in `build/` and refreshes `paper.pdf`. All LaTeX inputs and figures are included under `source/`; no network access is needed.

`verification/source-provenance.json` lists the original source hashes. The publication build check compares extracted PDF text with the preserved manuscript.

The [Boolean-depth revision record](../../verification/boolean-depth-progress-2026-10-18.json) records the current source and PDF hashes and matching isolated rebuild. The Fourier construction, posterior ceiling, exact feature repair, circuit steering, and analog-teacher compilation have independent mathematical audits in `verification/`; these additions are not Lean verified.
