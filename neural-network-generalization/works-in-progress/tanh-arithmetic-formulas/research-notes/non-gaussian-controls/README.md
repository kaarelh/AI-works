# Derivations for the non-Gaussian controls companion

The [companion PDF](../../non-gaussian-controls.pdf) is the current presentation. These notes preserve the independently checked local constructions, including explicitly marked intermediate limitations subsequently resolved by the manuscript.

## Component derivations

| Note | Subject |
| --- | --- |
| [Block-tilt factory interface](block-tilt-quantitative-factory-interface.md) | Quantitative local factory interface |
| [Bounded-rank independent tilts](bounded-rank-independent-tilt-extension.md) | Independent non-Gaussian blocks of fixed rank |
| [Endpoint Poisson rank mixture](endpoint-poisson-rank-mixture.md) | Endpoint mixture construction |
| [Entropy and formula interfaces](nongaussian-entropy-formula-interfaces.md) | Interfaces for non-Gaussian controls |
| [Rank-one Fock interface](rank-one-tilt-fock-interface.md) | Rank-one tilt construction |
| [Same-child precision](same-child-multilinear-precision.md) | Multilinear finite-precision argument |

## Normalized ridge tilts and endpoint laws

The [normalized ridge-difference extension](normalized-ridge-difference-tilt-compiler.md) uses a Gaussian envelope and logarithmic Sobolev estimates for an exact positive Poisson mixture with unbounded factors. It avoids any lower bound on anchor separation.

The [global polar improvement](global-polar-normalized-ridge-compiler.md) strengthens the normalized-ridge theorem: only a uniform small coefficient-mass bound is required, and the accumulated budget uses actual entropy. The earlier normalized-ridge note preserves the weaker intermediate sum-of-masses bound.

The [arbitrary endpoint extension](arbitrary-first-and-last-row-laws.md) allows unrestricted finite-entropy laws at the first and last layers around a compiled middle. The [final-density deletion lemma](arbitrary-entropy-endpoint-deletion.md) gives its exact readout overhead; no internal-law extension is asserted.
