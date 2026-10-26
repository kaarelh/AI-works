# Verification record

The [six-page source](../source/nearcritical-positive-window.tex) is byte-identical to the final audited scratch manuscript, SHA256 `3983ca89775173e5abb80ce0c94876495ac3317188e1118c929bdc8bdb5d8ca1`.

- [Scalar baseline comparison audit](supercritical-scalar-baseline-logarithmic-gap-canonical-audit.md): existence of the supercritical boundary value and the rigorous logarithmic deficit; no posterior consequence.
- [Intrinsic theorem audit](nearcritical-supercritical-positive-gain-finite-n-audit.md): scalar reference identity, bootstrap, and compact-prefactor extension of the imported finite-width machinery.
- [Target-mass audit](nearcritical-positive-target-mass-canonical-audit.md): actual perpendicular covariance, invariant residual, exact depth, scalar suffix, and raw finite-width probability.
- [Independent crossover audit](nearcritical-positive-crossover-nongaussian-audit.md): fresh check of both derivations.
- [Independent assembly audit](nearcritical-positive-crossover-assembled-nongaussian-audit.md): full manuscript and explicit iid train/test clarification.
- [Occupation-author assembly audit](nearcritical-positive-crossover-assembled-occupation-audit.md): full assembly, direct comparison to the target construction, and final source hash.

[Build manifest](build-manifest.json) records the packaged source/PDF hashes and imported-source snapshots. [Package hashes](SHA256SUMS.json) cover every distributable file except that hash list itself. Generated LaTeX logs are ignored in `.build/`.

These are conventional independent mathematical audits, not a formal proof verification. They explicitly retain the imported critical and finite-width inputs. The all-target canonical tanh depth question remains open.
