# Global Margin Conditioning Amplifies a Gaussian Posterior Mean

**Status:** Proved side result

At gamma = 0, one noiseless label can already produce a posterior mean with growing RKHS energy after global margin conditioning. At depth L >= 3, this rules out a proposed dimension-free O(n/tau) mean-energy estimate (the divergence is not claimed at L = 2); it does not itself establish a new parity sample bound.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/gamma-zero-mean-energy.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF was reviewed and rebuilt from the included source on 29 October 2026. The [review record](../../verification/remaining-papers-2026-10-29.md) describes exposition changes, mathematical corrections, and the limits of the checks. Existing formalization claims retain their stated scope.
