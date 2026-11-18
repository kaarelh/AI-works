# Verification record

The current paper has undergone independent AI-agent mathematical review. It has **not** been formalized in Lean.

The Gaussian core is covered by [the all-depth integration review](independent-all-depth-integration-review.md), with [SHA-256 hashes of its 13-source snapshot](independent-all-depth-integration-review-hashes.json). That record checks the main theorem against the assembled proofs, including every depth and realizable width, removal of the teacher-output cap, prefactor simultaneity, the sample-count width cap, and sub-Gaussian labels.

The controlling record for the current combined paper is the [final sixteen-source integration review](independent-final-sixteen-source-review.md), with [exact source hashes](independent-final-sixteen-source-review-hashes.json). It includes the three additional modules: exact-baseline matrix moments and transport entropy, finite-width conditional central-limit transfer, and the all-width non-Gaussian statistical assembly. All twelve Gaussian proof modules are unchanged from the earlier reviewed version.

An earlier record concerns a weaker version with a logarithmic minimum depth and a fixed output envelope. That version is superseded; it is not the scope of the current theorem.

The PDF builds successfully with two `pdflatex` passes. The build has no undefined references, TeX errors, or overfull boxes. Source hashes verify the reviewed snapshot; they are not a machine check of the mathematics.

The explicit Gaussian-mixture extension is in `source/gaussian-mixtures.tex`. The preceding sixteen-source snapshot is preserved in the sibling scratch package; a separate integration record identifies this added scope.
