# Exponential sample lower bounds for sparse parity under a globally separated neural prior

**Status:** Proved side result; conventional proof, not Lean verified

For 0 < gamma < 1, proves confidence failure at every specified n <= exp(c max{k,sqrt(k) log(e(d+1)/sqrt(k))}) for growing sparse parity. Gives an exp(Omega(k)) obstruction and an upper bound at the natural scale exp(O(k log(ed/k))), which the lower bound matches only when k/d is bounded below, but not the full natural sparse lower bound.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/growing-sparse-positive.tex) · [Collection index](../../README.md)

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The PDF is the existing manuscript copied into this collection; its mathematical text has not been rewritten for publication here. Later results and current scope are summarized in the collection index.
