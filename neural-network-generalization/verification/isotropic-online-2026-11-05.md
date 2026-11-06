# Isotropic online-learning publication check

5 November 2026. Base commit: `b61f2c7a`.

Two supporting papers were added, with conventional proofs and independent AI-agent reviews:

- [Exponential mistakes](../works-in-progress/online-mistakes/isotropic-exponential/): unchanged Gaussian tanh prior and actual posterior; scalar width one, linear-depth weight-two teacher, and the explicit `N=1<C_L=2` qualification. A separately identified identity-activation appendix proves the all-width version.
- [Subexponential bounds](../works-in-progress/online-mistakes/isotropic-subexponential/): scalar affine-cost bounds, scalar AND and weight-one targets, and every fixed shallow width for `C₂=1` targets. No polynomial or growing-width guarantee.

The [fresh paper-first audit](isotropic-online-fresh-audit-2026-11-05.md) and [fresh higher-moment audit](isotropic-online-upper-fresh-audit-2026-11-05.md) found no blocking issue. The suggested alternative-exponent scope clarification was incorporated. Earlier independent reviews and final source/PDF hashes are in each paper's verification folder.

Both PDFs built in isolation with matching extracted text, no unresolved references, and no LaTeX warnings or overfull boxes. Title, abstract, and principal theorem pages were rendered and inspected. Twenty finite affine instances have exact rational nonnegative dual certificates; a separate standard-library script exhaustively checks the construction on cubes for `k=3,…,6`.

The collection checker passes for all **74** canonical PDFs and all relative Markdown links. Existing paper mathematics, PDFs, and Lean sources were not changed, and no new Lean certification is claimed. One pre-existing link to an unpublished `analytic-build.log` was replaced with links to the existing publication check and analytic-interface record; its local checksum was updated.

The collection checksum manifest was refreshed against the tracked publication tree. This also reconciles 36 checksum entries that were already stale at the base commit; it does not assert that all earlier Lean proofs or PDFs were rebuilt during this task. Only the two new PDFs were rebuilt here.

The FAQ, project README, online-learning index, and earlier AND note now distinguish the scalar counterexample, sufficient-width tanh question, and restricted subexponential upper bounds.
