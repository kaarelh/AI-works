# Verification record

The proof establishes an online mistake lower bound for a fixed continuous triangle-wave activation under the exact Gaussian variances displayed in the paper. It does not establish the analogous theorem for tanh, ReLU, GELU, or hardtanh. For construction index `m` and input dimension `d`, the mistake count is `2^(m-4)` with `d = Θ(m^6)`, and therefore is stretched exponential in input dimension and Boolean-circuit size. Calibration covers `15/16` of the cube. The result is for every sufficiently large finite width followed by the strong-prior limit at that width; there is no claimed polynomial sufficient-width bound or width-uniform variance threshold.

This package contains a conventional mathematical proof, not a Lean formalization. The reviews below were performed by separate AI agents; they are independent checks within the research session, not external peer review.

The recorded checks are:

- [Complete manuscript: exact-search audit](exact-search-whole-theorem-audit.md), covering the full mathematical chain and its quantifiers.
- [Complete manuscript: new-lens audit](new-lens-full-source-audit.md), including the atomic appendix, constants, exact ordering, and posterior transfer.
- [Complete manuscript: tanh audit](tanh-full-paper-audit.md), emphasizing normalization, strict margins, arbitrary high widths, and individual queries after complete-fiber calibration.
- [Atomic norm audit](atomic-norm-audit.md), checking the exact weighted Fourier inequality and equality cases.
- [Quantitative fiber reduction audit](tanh-fiber-reduction-audit.md), checking unrestricted non-code competitors and the margin argument.
- [Weighted star audit](weighted-star-audit.md), checking the latent LP, subgroup costs, strict Fourier signs, and algebraic ordering.

The complete reviews found no substantive mathematical gap. Two display/wording edits requested in review were applied: the free-coset display's missing `\qquad` backslash, and an explicit positive formula for the energy gap. Subsequent clarifications state the original actual-weight convention for `C_2`, enlarge the sufficient width to contain the target teacher, and explain finiteness of the variation norm. These do not change the argument. The source also handles the zero reduced-parameter vector explicitly and uses a non-strict sign at zero perturbation in the last small-perturbation inequality. The positive-perturbation gap and all theorem statements are unchanged; the coordinating agent checked these endpoint clarifications.

[build-record.json](build-record.json) records source and PDF hashes and the build checks. [publication-build.json](publication-build.json) records the current source/PDF hashes after the endpoint clarifications and an isolated rebuild. The PDF was compiled with three `pdflatex` passes; the final log has no warnings or overfull/underfull boxes. The first page was visually checked for the title, model display, alphabetical author order, and author-order footnote. The standalone source contains all mathematical proofs used by the theorem.

No numerical optimization or floating-point experiment is a premise of the main result. The decimal constants in the atomic estimates are conservative numerical bounds on the displayed elementary expressions; their strict margins were checked in the reviews.
