# Review and publication checks

**Current formalization status:** The main learning statements and the important extensions identified in the audit now have Lean proofs. See the [15 November completion record](../../../lean/review/coverage-completion-2026-11-15.txt) and [current coverage inventory](../../../lean/review/coverage-extension-2026-10-30.txt). The [second-batch coverage record](../../../lean/review/BatchTwo-coverage.md) is an earlier baseline; the conventional-proof reviews below describe the pre-formalization snapshot.

## Mathematical review

The snapshot reviewed here had a conventional mathematical proof and no Lean formalization. The main learning statements were formalized later, as indicated above. Three independent AI-agent reviews checked the assembled source, with separate emphasis on the strong-prior argument, target mass and finite exponents, and mean-field comparison and compression. These reviews are not external peer review.

- [Strong-prior and deterministic-compression review](strong-prior-audit.md).
- [Target-mass, spectral-tail, and prior-complexity review](target-mass-audit.md).
- [Mean-field, finite-description, and prior-complexity review](meanfield-audit.md).

No substantive mathematical issue was identified in these reviews. Two requested clarifications were incorporated: the mean-field finite class is explicitly defined through bounded implementations, and exact prior ordering is distinguished from polynomial prior-complexity comparison. The final cosmetic change adjusted bibliography placement and spacing only.

## Build evidence and source paths

The [build record](build.json) identifies the source and PDF hashes of the reviewed publication snapshot and records an isolated rebuild, extracted-text agreement, and checks for unresolved references and LaTeX warnings. It is historical evidence; use the collection's `SHA256SUMS` for the current files. The source fragments are all included under [source/](../source/). The collection inventory and local Markdown links were checked before publication.

The review files retain the source names used during review. Their `paper/` directory corresponds to this package's `source/` directory. The final source hashes in the build record identify the published version.
