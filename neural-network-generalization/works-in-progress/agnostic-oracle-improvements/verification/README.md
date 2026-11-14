# Verification record

The paper has conventional mathematical proofs and independent AI-agent reviews. It has **not** been formalized in Lean or externally peer reviewed.

- [Mathematical audit](mathematical-audit.md): checks the supplied Opus theorem against its supporting proof, the improved Gaussian absorption argument, the finite-scale extension (`γ≥2`, or `γ≥1` with one hidden layer), and the raw-output extension using Srebro–Sridharan–Tewari's smooth-loss theorem.
- [Final-posterior-mean review](posterior-mean-review.md): independently derives the continuous-prior leave-one-out oracle inequality, checks its constants, identifies the existing aggregation literature, and distinguishes expectation from high-probability claims.
- [Fresh-reader review](fresh-reader-review.md): standalone presentation, theorem quantifiers and the one-hidden-layer tuning; its requests about the smooth-loss calibration and weighted Laplace tail are resolved in the final source. The external constant was separately verified against the published theorem.
- [Architectural-prior review](architecture-prior-review.md): checks parameter perturbations, neighborhood prior mass, maximum-width/depth quantifiers, and teacher width/depth dependence.

The main Gaussian proof is self-contained apart from standard empirical-process inequalities; the raw-output appendix explicitly invokes the published smooth-loss theorem. The architectural-prior proof is self-contained apart from the Gibbs variational identity. The generic final-aggregation phenomenon is credited to the literature rather than presented as a new discovery.

Build metadata, source/PDF hashes and computational sanity checks are recorded alongside these reviews. Numerical checks supplement the proofs; they do not verify them. Internal scratch paths in the review records identify working drafts; the published mathematical source is the `source/` directory one level above.
