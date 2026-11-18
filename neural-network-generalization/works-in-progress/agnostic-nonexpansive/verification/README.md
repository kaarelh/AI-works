# Verification record

The paper has conventional mathematical proofs and an independent AI-agent review. It is not Lean formalized or externally peer reviewed.

The [mathematical review](review.md) checks the capacity bound, cloning construction, strong-prior limit, finite-prior comparison distribution, raw posterior tails, and counterexample below `γ=2`. It also checks the tanh depth-attenuation caveat and the distinction between this restricted teacher class and arbitrary small networks.

The [build record](build-record.json) records the current source/PDF hashes and an isolated rebuild with matching PDF text. The published source has three files: `paper.tex`, `finite-section.tex`, and `counterexample-section.tex` in `source/`. Run `bash build.sh` from the package root to rebuild it.

A successful build validates the document and its references, not the mathematics. The mathematical checks listed above are independent AI-agent reviews of conventional proofs.
