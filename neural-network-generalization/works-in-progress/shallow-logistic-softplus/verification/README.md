# Verification record

These are conventional mathematical audits and reproducible LaTeX builds, not Lean verification.

- [Logistic full-manuscript audit](logistic-shallow-manuscript-independent-audit.md): independent check of the complete theorem, self-contained compression, paired transmission, Gaussian subtraction, finite-width fallback, and limiting quantifiers.
- [Logistic derivation audit](logistic-nonconstant-energy-and-cold-learning-independent-audit.md): separate checks of the original cold argument and its finite-scale extension.
- [Softplus derivation audit](softplus-positive-channel-transmission-independent-audit.md): independent check of the positive-channel wire, charged constant subtraction, arbitrary-diagonal stability, and posterior transfer. Its final paragraph records the exposition-only cloning clarification.
- [Softplus full-manuscript audit](softplus-shallow-manuscript-finite-n-audit.md): fresh independent check of the then-current softplus assembly, including the unbounded-activation small-width argument and explicit parity construction. The [assembly record](softplus-shallow-manuscript-assembly.md) records its dependency on the general cover in the logistic companion.
- [Constant-target posterior audit](nonzero-offset-activation-posterior-audit.md): the separate logistic/softplus ordering theorem, including its actual conditioning denominator.

The [build manifest](build-manifest.json) distinguishes the audited scratch snapshots from packaged sources. The linked build manifest identifies the earlier audited snapshot. The manuscripts were subsequently reviewed and rebuilt on 29 October 2026: the logistic proof now explicitly unions the small-width classes and allocates failure probability across depths, and both manuscripts clarify the scale schedule and fixed parity-sign convention. The softplus proof also makes its small-width class union explicit. These changes preserve the theorem conclusions and do not extend Lean coverage. Current hashes and review scope are in the [collection review](../../../verification/remaining-papers-2026-10-29.md). The softplus companion assembles its audited derivation and cites the logistic paper for the general covering and Gaussian arguments. Exact file hashes are listed in [SHA256SUMS.json](SHA256SUMS.json).

The conclusions concern shallow targets and cold or fixed-`gamma > 1` priors. They do not prove a critical-`gamma = 1` result or an original exact-tanh depth theorem.
