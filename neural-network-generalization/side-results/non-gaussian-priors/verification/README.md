# Review and publication checks

The paper is a conventional mathematical proof, **not a Lean formalization**. Three independent AI-agent reviews checked the assembled source, with separate emphasis on the strong-prior argument, target mass and finite exponents, and mean-field comparison and compression. These reviews are not external peer review.

- [Strong-prior and deterministic-compression review](strong-prior-audit.md).
- [Target-mass, spectral-tail, and prior-complexity review](target-mass-audit.md).
- [Mean-field, finite-description, and prior-complexity review](meanfield-audit.md).

No substantive mathematical issue was identified in these reviews. Two requested clarifications were incorporated: the mean-field finite class is explicitly defined through bounded implementations, and exact prior ordering is distinguished from polynomial prior-complexity comparison. The final cosmetic change adjusted bibliography placement and spacing only.

The [build record](build.json) records the published source and PDF hashes, an isolated rebuild, extracted-text agreement, and checks for unresolved references and LaTeX warnings. The source fragments are all included under [source/](../source/). The collection inventory and local Markdown links were checked before publication.

The review files retain the source names used during review. Their `paper/` directory corresponds to this package's `source/` directory. The final source hashes in the build record identify the published version.
