# Verification

The [paper](../paper.pdf) has conventional proofs with independent AI-agent mathematical reviews; it is not Lean formalized.

- [Full-paper review](full-paper-review.md): theorem statements, finite-width posterior comparison, scaffold, circuit complexity, and IID guarantee.
- [Scaffold review](scaffold-review.md): four-register arithmetic pinning, every positive helper, exact common-mode ray, explicit constants, and scope.
- [Volume and posterior review](volume-posterior-review.md): entire function cones, Gaussian integration, strict neighboring cone ratios, and width/scale quantifiers.
- [Publication build record](publication-build.json): final source and PDF hashes, PDF metadata, isolated rebuild, and visual checks.

Each review identifies the exact source hashes it checked. The source consists of [paper.tex](../source/paper.tex) and [volume.tex](../source/volume.tex). The build uses three `pdflatex` passes and an isolated rebuild compares extracted PDF text. No Lean source is changed or claimed to formalize this result.

The principal scope checks are explicit: the activation is discontinuous sign; the Gaussian prior is exactly isotropic; all comparisons concern the actual posterior over every wide-network output; the calibration prefix is exponential; the conclusion holds at every sufficiently large width; and the fixed-`γ` width requirement is distinguished from the cold-posterior width bound.
