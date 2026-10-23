# Second-batch verification evidence

The release uses Lean 4.32.0 and mathlib `81a5d257c8e410db227a6665ed08f64fea08e997`. The mathlib checkout was checked clean at that revision. The project was copied into a new directory with an empty project build cache; no project OLeans were copied. The pinned dependency build cache was reused.

- `result.json` records the gates, source comparison and declaration count.
- `source-checksums.json` hashes every included Lean source and project configuration, excluding the untracked development scratch file.
- `clean-source-build.log` is the initial fresh build of every library module.
- `final-source-check.log` confirms that the final sources and all targets are current, including the real-energy rounding refinement.
- `all-imported-axioms.log` audits every imported project theorem and the original five exact main types.
- `batch-two-endpoint-axioms.log` audits the listed new endpoints and imports the detailed shallow, online and non-Gaussian audits.
- The remaining logs check the original main statements, robustness statement, parity supplement and confidence supplement.

The axiom audit accepts only `propext`, `Classical.choice` and `Quot.sound`. The [coverage table](../../BatchTwo-coverage.md) separately records the manuscript comparison and exclusions. Build success does not certify every assertion in each PDF.
