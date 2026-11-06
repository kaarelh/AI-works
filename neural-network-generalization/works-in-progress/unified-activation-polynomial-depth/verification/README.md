# Verification and scope

**Author-order revision, 6 November 2026.** The author declarations, alphabetical-order footnotes, and PDF author metadata were updated without changing the document bodies. [Current hashes and clean rebuild checks](../../../verification/author-order-2026-11-06.md) supersede the earlier manuscript hashes below; the dated mathematical reviews remain records of their original snapshots.

The main theorem is a conventional mathematical proof, not a new Lean theorem. Earlier formalizations of tanh and ReLU/GELU results do not certify a changed activation class or prior support automatically.

The manuscript was checked by separate AI-agent reviews:

- [Target mass, readout normalization, and polynomial depth](target-mass-review.md).
- [Gaussian partition control and finite coding](compression-review.md).
- [Independent review of the complete main argument](independent-review.md).
- [Fixed-depth nonzero-offset extension: construction audit](offset-review.md).
- [Independent adversarial review of the offset appendix](offset-independent-review.md).

The main result uses **balanced** populations and the absolute count calibration `q≤1+E_v`. The optional global-margin restriction is permitted. No optional internal-noise restriction is included for arbitrary neural teachers. The target is a bounded-weight neural implementation, with its own activation and a uniform signed output margin.

The degree-13 envelope is a conservative sufficient bound, not an optimized exponent. The single good sample event is uniform over learner width and prior scale; the activation is fixed before sampling. Full posterior mixtures and strict-confidence conversion are retained.

[Publication build record](publication-build.json) records source/PDF hashes, compilation, isolated rebuild comparison, and reference checks. These checks validate packaging; they do not replace the mathematical reviews or establish empirical prevalence of the prior restriction.
