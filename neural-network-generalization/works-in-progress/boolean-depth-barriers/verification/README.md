# Verification record

The manuscript and supporting analytic notes received conventional mathematical reviews. They are not a Lean verification of the full statistical results.

- [Fresh resumed audit](resume-main-audit.md): canonical invariants and evaluators, nearcritical block covers, actual finite-width extraction, posterior mixtures, and complexity quantifiers. Its recorded hash identifies the main source before the constant-width appendix and editorial constant split.
- [Earlier independent adversarial audit](fresh-barrier-independent-audit.md): structural and statistical proof mechanisms, imported inputs, and limits of the claimed conclusions.
- [Uniform block-cover audit](root-uniform-block-audit.md): the replacement for the invalid earlier per-layer branching argument; no withdrawn argument is used in the paper.
- [Analog compiler audit](analog-register-audit.md) and [adversarial compiler audit](analog-base4-adversarial-audit.md): fixed register schedule, all sixteen Boolean gates, constants, global error bootstrap, width and coefficient accounting, and finite precision. The resulting construction is included in Appendix A.

The publication combines the audited proofs, separates the uniform-ceiling constants, adds exact dependency references, and states the formalization boundary. The PDF build is checked separately from mathematical validity. The source hashes in individual audit records describe the versions reviewed at those times; they should not be read as hashes of a later typeset revision.

The [Lean directory](../lean/README.md) contains ten checked analytic modules and their build record. Its scope ends before the finite-bit circuit compiler and the posterior theorems. The overall unrestricted Boolean-depth question remains open.

[Publication checks](publication-check.json) record the clean PDF builds, a fresh check of all ten Lean sources using the portable script, source-hash equality, and relative-link/dependency checks. [SHA256SUMS.json](SHA256SUMS.json) identifies the curated files.
