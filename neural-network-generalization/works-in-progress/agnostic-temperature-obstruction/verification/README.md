# Verification record

The paper gives conventional proofs of the single-law temperature obstruction, its quantitative width threshold, and the posterior prediction consequences. These claims have undergone independent AI-agent mathematical review, not Lean formalization or external peer review.

The [independent mathematical review](review.md) covers the final theorem statements and proofs. The canonical finite-prior theorem applies directly at every `σ²=N^(-γ)` with `γ≥1`, uniformly over all eligible widths and temperatures. Its shifted comparison Gaussian keeps the original covariance; a conditional scalar recursion controls its output error, and Gaussian operator moments give the posterior sensitivity bound. A simpler `γ≥2` proof has a smaller width threshold. The fixed-width corollary uses a width-2 teacher with growing coefficients. The self-contained memorizer-optimality appendix proves the first-layer-free capacity bound and both deterministic-label and random-singleton energy lower bounds.

The proof includes the Boolean-cube memorizer construction, the bounded two-chain teacher, the common occupancy event, and the separate arguments for posterior averages and posterior means. The latter use residual or prediction-difference inequalities preserved under averaging; they do not average individual risk lower bounds.

The [two-chain check](check_two_chain.py) checks 84 numerical instances of the analytic teacher formulas. Its [recorded output](two-chain-check.json) is a sanity check and is not a proof assumption. Run it with Python 3.

The PDF was built twice with pdfLaTeX. No unresolved references, LaTeX warnings, or overfull/underfull boxes remained. The first page was visually checked for title, abstract, author order, and the alphabetical-order footnote. [Build record](build-record.json).

The localized-noise corollary keeps unit signal and noisy-label amplitudes while reducing their input probabilities. Its constants and simultaneous-parameter scope were independently checked; it does not assert a fixed excess as noise tends to zero.
