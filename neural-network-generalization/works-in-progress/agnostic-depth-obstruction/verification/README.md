# Verification record

The paper has conventional mathematical proofs. It is not Lean verified.

The independent reviews in this folder identify the exact source snapshots they cover. Earlier reviews cover the small-prefactor proof and its Gaussian-noise, affine-output, bounded-output-likelihood and ReLU extensions. The current source adds the matching covariance-entropy argument for every fixed prefactor below one; its review is recorded separately rather than treating an earlier review as evidence for later edits.

The added argument has four main components:

1. An exact fractional chi-square moment gives a normalized prior cost `(1 − ν + ν log ν) H` for any fixed nonzero output.
2. A finite Gaussian covariance construction realizes a scalar variance/correlation recursion with its exact chain-rule relative entropy.
3. A growth phase followed by variance-holding realizes arbitrary bounded functions with asymptotically the same normalized cost.
4. The original segment and sample-witness argument then applies uniformly over any compact prefactor interval below one. Combining it with the small-prefactor proof gives the full range `0 < Ns ≤ ν_max < 1`.

The build script runs pdfLaTeX twice and checks for unresolved references. The PDF metadata records the manuscript's title and all four authors.
