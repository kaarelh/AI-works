**Current formalization status:** The main learning statements now have Lean proofs. [Exact scope and exclusions](../../../lean/review/BatchTwo-coverage.md). The earlier conventional-proof and review record below describes the pre-formalization snapshot.

# Review and publication checks

At the time of this record the result had a conventional mathematical proof and no Lean formalization; the main statements were formalized later (see the status line above). (Revised 10 November 2026.) Independent AI-agent reviews checked the continuous-domain extension, the posterior and covering arguments, and the exact-interpolation corollary. They are not external peer review.

- [Independent mathematical audit](mathematical-audit.md).
- [Independent cross-check of regression and mean-field arguments](cross-audit.md).
- [Assembled manuscript review](manuscript-audit.md).
- [Additional assembled mean-field review](meanfield-audit.md).

The reviews check the separation between teacher width and weight magnitude, the uniformity over learner width, the train/test tolerance gap, and the distinction between binary labels and real-valued scores. The exact-interpolation argument requires the stated order of limits: strong prior first, zero training tolerance second.

The [build record](build.json) identifies the source and PDF hashes of the 18 October snapshot, which predates later revisions (for the current files, use the collection's `SHA256SUMS`; noted 10 November 2026), and records an isolated rebuild, extracted-text agreement, and checks for unresolved references and LaTeX warnings. Complete source is included under [source/](../source/). The manuscript explicitly cites the shared finite-input compression ingredients from the [non-Gaussian paper](../../non-gaussian-priors/paper.pdf); its continuous-domain reductions and exact-interpolation argument are proved in the paper.

The review files refer to research-note filenames or a `paper/` source directory used during development. The final source hashes in the build record identify the version published on 18 October.
