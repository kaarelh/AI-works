# Global Margin Conditioning Amplifies a Gaussian Posterior Mean

**Status:** Proved side result

At prior-scaling exponent gamma = 0, one noiseless label can produce a posterior mean with growing reproducing-kernel Hilbert space (RKHS) energy after global margin conditioning. For depth L >= 3, this disproves a proposed dimension-free O(n/tau) mean-energy estimate, where n is the sample count and tau is the relevant high-degree spectral trace. The divergence is not claimed at L = 2.

This is an obstruction to a proposed proof estimate, not a new parity sample bound.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/gamma-zero-mean-energy.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

## Review record

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
