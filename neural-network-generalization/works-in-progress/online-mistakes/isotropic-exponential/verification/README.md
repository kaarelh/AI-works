# Verification and exact scope

5 November 2026. [Paper](../paper.pdf) · [Source](../source/paper.tex)

Conventional mathematical proofs, independently checked by collaborating AI agents and the integrating agent. **Not Lean formalized or human peer reviewed.**

The reviews checked the following claims against the manuscript:

- The `O(k)` diagonal and carry calibration inequalities hold for arbitrary affine coefficients, without assuming symmetry of a competing classifier.
- After the negative query at integer `t≥k`, the unique convex training-margin norm minimizer has bias `−t`, selector coefficient `−t−1`, and paired bit coefficients `±2^i`. Its scores are odd integers on the entire cube, so it also solves the globally constrained problem.
- The next prescribed query has score `+1` and true label `−1`. The sequence is fixed and has no repetitions after calibration duplicates are removed.
- At every scalar tanh depth, minimum Gaussian function energy is strictly increasing in the affine unit-margin norm. Coercivity, readout scaling, and finite-dimensional Gaussian small-noise bounds justify concentration on the unique function after each history. Equal-energy prefactors and MAP tie-breaking are not used.
- A single sufficiently small scale controls all designated rounds, giving the simultaneous sampled-error guarantee, majority mistakes, and confidence failures.
- The target's Boolean gate count is `Θ(k)`. Its depth-`2k+2` scalar tanh teacher has weights at most two, strict output margin, and Gaussian energy less than `(40k+11)/3`.
- The exact teacher complexity is `C_L=2`, while the tanh learner has `N=1`. No tanh result for `N≥C_L` follows from padding the teacher.
- The separate identity-activation appendix proves the exact factorization energy `L(d Q/4)^(1/L)`, so its all-width conclusion is valid. This appendix changes the activation and is not a wider-tanh theorem.
- The IID comparison follows from the finite affine-threshold class and is independent of depth and prior scale.

The [full-source tanh audit](lower-selector-final-audit.md) and [linear-appendix audit](lower-linear-audit.md) retain the review history. Their suggested wording edits were incorporated. The publication record binds the final sources, integrated appendix, and PDF by hashes.

## Exact finite checks

`python3 lower-check-selector.py` uses only the Python standard library and exact integers/Fractions. It exhaustively checks the full cube at `k=3,…,6`, including global margins, calibration labels, every forced round, and norm/count formulas.

`python3 check_affine.py` requires NumPy, SciPy, and SymPy. For 20 selected instances at `k=3,…,7`, an LP locates a candidate dual support; **all accepted certificates are then checked exactly over the rationals**, including nonnegative multipliers and their exact conic combination. The resulting [certificates](affine-certificates.json) establish those instances' norm optimality and uniqueness independently of the floating-point solver. These checks support the general proof; they do not replace it.

The PDF was rebuilt in isolation with matching extracted text and no unresolved references or LaTeX warnings. Its title/abstract and theorem pages were inspected for rendering problems. See [record.json](record.json) for hashes and build checks.
