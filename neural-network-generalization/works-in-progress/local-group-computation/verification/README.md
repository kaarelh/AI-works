# Verification record

This package contains conventionally checked mathematical proofs, not a Lean formalization.

The [independent full-assembly audit](local-group-wasserstein-full-assembly-audit.md) reviewed the complete standalone source. It passed every proof and displayed constant, requesting one explicit architecture clarification: the bands must form an ordered exhaustive partition of the physical layers preceding the readout. That clarification and the harmless sign conventions `C_0>0`, `K>=0` were added, and the auditor approved the corrected source hash recorded in its final entry.

The packaged source differs from that corrected audited snapshot only in its author line and PDF author metadata, now listing ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob. These editorial changes do not affect the mathematical content. The [build manifest](build-manifest.json) records the exact compiled source/PDF hashes and the clean build. The [package hash manifest](SHA256SUMS.json) covers package files except itself and generated build auxiliaries. Hashes are artifact identifiers, not formal proof certificates.

The audit includes an independent direct calculation of the shallow parity witness. This is essential to the scope: the lower bound applies to the stated local architecture and can fail for a global network computing the same function. No intrinsic product-norm lower bound, Bayesian sample lower bound, or circuit separation is asserted.
