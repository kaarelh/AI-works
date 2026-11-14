# Verification record

The paper has conventional mathematical proofs and independent AI-agent reviews. It has **not** been formalized in Lean or externally peer reviewed.

- [Mathematical audit](mathematical-audit.md): checks the supplied Opus positive theorem, the improved Gaussian absorption argument, the finite-scale extension (`γ≥2`, or `γ≥1` with one hidden layer), and the raw-output extension using Srebro–Sridharan–Tewari's smooth-loss theorem.
- [Fresh-reader review](fresh-reader-review.md): standalone presentation, theorem quantifiers, the one-hidden-layer tuning, and the finite-prior argument.
- [Build record](build-record.json): source/PDF hashes and an independent isolated rebuild with matching extracted text and no LaTeX warnings.

The main Gaussian proof is self-contained apart from standard empirical-process inequalities. The raw-output appendix explicitly invokes the published smooth-loss theorem; its numerical constant was checked against Theorem 1, page 4 of the cited full-length paper. The finite-scale proof uses an explicitly proved Gaussian entropy inequality and an explicit Gaussian comparison measure.

Internal scratch paths in the mathematical audit identify working drafts. The published mathematical source is the `source/` directory one level above. Review records describe mathematical checks by AI agents, not a Lean certificate or external peer review.
