# Independent exact-source review

18 November 2026 — agnostic_proof_audit. Mathematical review, not formal verification.

The active final-tanh extension passes. The transformed target arctanh((1−η)f) has amplitude Aη=O(log(1/η)) and coordinate-line variation at most 2Aη(C+1)^h. The existing shifted hierarchical interpolation proof uses precisely those two facts, so its width and path estimates transfer with only logarithmic overhead. The displayed mesh and η=ε/32 give squared-risk comparison error below ε/4.

Oddness, boundedness, and 1-Lipschitz continuity transfer the Gaussian certificate. Loss threshold patterns reduce to at most two raw-output threshold patterns, retaining the parameter certificate. The small-width branch contains the original tanh-output teacher using its constant wire and identity relays. Thus the same sample polynomial and common-event width/scale quantifiers hold. The statement correctly compares with tanh-output teachers; it does not silently give the same all-width theorem for raw teachers. The inactive fragments are outside this review.
