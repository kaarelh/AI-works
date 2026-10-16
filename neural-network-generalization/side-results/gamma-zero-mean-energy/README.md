# Global Margin Conditioning Amplifies a Gaussian Posterior Mean

**Status:** Proved side result

At gamma = 0, one noiseless label can already produce a posterior mean with growing RKHS energy after global margin conditioning. Rules out a proposed dimension-free O(n/tau) mean-energy estimate; does not itself establish a new parity sample bound.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/gamma-zero-mean-energy.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF is the existing manuscript copied into this collection; its mathematical text has not been rewritten for publication here. Later results and current scope are summarized in the collection index.
