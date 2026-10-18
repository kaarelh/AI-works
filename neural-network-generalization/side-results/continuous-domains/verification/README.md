# Review and publication checks

This is a conventional mathematical proof, **not a Lean formalization**. Independent AI-agent reviews checked the continuous-domain extension, the posterior and covering arguments, and the exact-interpolation corollary. They are not external peer review.

- [Independent mathematical audit](mathematical-audit.md).
- [Independent cross-check of regression and mean-field arguments](cross-audit.md).
- [Assembled manuscript review](manuscript-audit.md).
- [Additional assembled mean-field review](meanfield-audit.md).

The reviews check the separation between teacher width and weight magnitude, the uniformity over learner width, the train/test tolerance gap, and the distinction between binary labels and real-valued scores. The exact-interpolation argument requires the stated order of limits: strong prior first, zero training tolerance second.

The [build record](build.json) identifies the published source and PDF hashes and records an isolated rebuild, extracted-text agreement, and checks for unresolved references and LaTeX warnings. Complete source is included under [source/](../source/). The manuscript explicitly cites the shared finite-input compression ingredients from the [non-Gaussian paper](../../non-gaussian-priors/paper.pdf); its continuous-domain reductions and exact-interpolation argument are proved in the paper.

The review files refer to research-note filenames or a `paper/` source directory used during development. The final source hashes in the build record identify the published version.
